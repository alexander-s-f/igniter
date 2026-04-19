# frozen_string_literal: true

require "json"
require "uri"

module Igniter
  class App
    module Observability
      class OperatorActionHandler
        def initialize(app_class:, store: nil)
          @app_class = app_class
          @store = store
        end

        def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
          request_params = query_params(env).merge(symbolize_keys(params)).merge(symbolize_keys(body))
          id = request_params[:id].to_s
          raise ArgumentError, "id is required" if id.empty?

          item = app_class.orchestration_inbox.find(id)
          return json_response(404, error: "orchestration item #{id.inspect} was not found") unless item

          target = resolve_target(item, config: config)
          result = app_class.handle_orchestration_item(
            id,
            operation: request_params[:operation],
            target: target,
            value: normalize_value(request_params),
            assignee: present_value(request_params[:assignee]),
            queue: present_value(request_params[:queue]),
            channel: present_value(request_params[:channel]),
            note: present_value(request_params[:note]),
            audit: {
              source: :operator_action_api,
              actor: present_value(request_params[:actor]),
              origin: normalize_identity_value(request_params[:origin]),
              actor_channel: present_value(request_params[:actor_channel])
            }
          )

          record = app_class.operator_query(target || nil).where { |entry| entry[:id] == id }.first

          json_response(
            200,
            app: app_class.name,
            scope: action_scope(item),
            action: result,
            record: record
          )
        rescue ArgumentError => e
          json_response(400, error: e.message)
        rescue Igniter::ResolutionError => e
          json_response(404, error: e.message)
        rescue Igniter::Error => e
          json_response(422, error: e.message)
        end

        private

        attr_reader :app_class, :store

        def query_params(env)
          URI.decode_www_form(env.fetch("QUERY_STRING", "").to_s).each_with_object({}) do |(key, value), memo|
            memo[key.to_sym] = value
          end
        end

        def symbolize_keys(hash)
          hash.to_h.each_with_object({}) do |(key, value), memo|
            memo[key.to_sym] = value
          end
        end

        def normalize_value(request_params)
          return Igniter::Runtime::Execution::UNDEFINED_RESUME_VALUE unless request_params.key?(:value)

          value = request_params[:value]
          return Igniter::Runtime::Execution::UNDEFINED_RESUME_VALUE if value.is_a?(String) && value.empty?

          value
        end

        def resolve_target(item, config:)
          graph = item[:graph]
          execution_id = item[:execution_id]
          return nil if graph.nil? || execution_id.nil?

          app_class.send(
            :operator_target_for_execution,
            graph: graph,
            execution_id: execution_id,
            store: resolved_store(config)
          )
        rescue Igniter::Error, ArgumentError
          nil
        end

        def resolved_store(config)
          store || config&.store || Igniter.execution_store
        end

        def present_value(value)
          return nil if value.nil?

          string = value.to_s
          string.empty? ? nil : string
        end

        def normalize_identity_value(value)
          string = present_value(value)
          return nil unless string

          string.tr(" ", "_").to_sym
        end

        def action_scope(item)
          if item[:graph] && item[:execution_id]
            {
              mode: :execution,
              graph: item[:graph],
              execution_id: item[:execution_id]
            }.freeze
          else
            { mode: :app }.freeze
          end
        end

        def json_response(status, payload)
          {
            status: status,
            body: JSON.generate(payload),
            headers: { "Content-Type" => "application/json" }
          }
        end
      end
    end
  end
end
