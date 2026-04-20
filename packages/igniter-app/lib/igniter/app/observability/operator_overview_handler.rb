# frozen_string_literal: true

require "json"
require "uri"

module Igniter
  class App
    module Observability
      class OperatorOverviewHandler
        DEFAULT_LIMIT = 20
        LIST_FILTERS = %i[
          id status action node combined_state interaction reason policy lane queue
          channel assignee phase reply_mode mode tool_loop_status ownership
          session_lifecycle_state
          latest_action_actor latest_action_origin latest_action_source
        ].freeze
        BOOLEAN_FILTERS = %i[
          actionable attention_required resumable with_session
          with_inbox_item with_token handed_off interactive
          terminal continuable routed
        ].freeze
        EVENT_LIST_FILTERS = %i[
          node event event_class source status actor origin
          requested_operation lifecycle_operation execution_operation
        ].freeze
        EVENT_BOOLEAN_FILTERS = %i[terminal].freeze

        def initialize(app_class:, limit: DEFAULT_LIMIT, store: nil)
          @app_class = app_class
          @default_limit = limit
          @store = store
        end

        def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
          request_params = query_params(env).merge(symbolize_keys(params))
          limit = normalize_limit(request_params.delete(:limit))
          filters = extract_filters(request_params)
          order_by = normalize_order_by(request_params.delete(:order_by))
          direction = normalize_direction(request_params.delete(:direction))
          event_limit = normalize_limit(request_params.delete(:event_limit) || limit)
          event_filters = extract_event_filters(request_params)
          event_order_by = normalize_event_order_by(request_params.delete(:event_order_by))
          event_direction = normalize_direction(request_params.delete(:event_direction))

          overview =
            if request_params.key?(:graph) || request_params.key?(:execution_id)
              graph = request_params[:graph]
              execution_id = request_params[:execution_id]

              validate_execution_scope!(graph: graph, execution_id: execution_id)
              app_class.operator_overview_for_execution(
                graph: graph,
                execution_id: execution_id,
                limit: limit,
                store: resolved_store(config),
                filters: filters,
                order_by: order_by,
                direction: direction,
                event_filters: event_filters,
                event_order_by: event_order_by,
                event_direction: event_direction,
                event_limit: event_limit
              )
            else
              app_class.operator_overview(
                limit: limit,
                filters: filters,
                order_by: order_by,
                direction: direction,
                event_filters: event_filters,
                event_order_by: event_order_by,
                event_direction: event_direction,
                event_limit: event_limit
              ).merge(
                scope: { mode: :app }.freeze
              ).freeze
            end

          json_response(200, overview)
        rescue ArgumentError => e
          json_response(400, error: e.message)
        rescue Igniter::ResolutionError => e
          json_response(404, error: e.message)
        rescue Igniter::Error => e
          json_response(422, error: e.message)
        end

        private

        attr_reader :app_class, :default_limit, :store

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

        def normalize_limit(value)
          return default_limit if value.nil? || value.to_s.empty?

          limit = Integer(value)
          raise ArgumentError, "limit must be greater than or equal to 1" if limit < 1

          limit
        rescue ArgumentError, TypeError
          raise ArgumentError, "limit must be an integer greater than or equal to 1"
        end

        def extract_filters(request_params)
          filters = {}

          LIST_FILTERS.each do |name|
            next unless request_params.key?(name)

            values = normalize_list(request_params.delete(name), symbolize: symbol_filter?(name))
            filters[name] = values if values.any?
          end

          BOOLEAN_FILTERS.each do |name|
            next unless request_params.key?(name)

            filters[name] = normalize_boolean(request_params.delete(name), name)
          end

          filters.freeze
        end

        def extract_event_filters(request_params)
          filters = {}

          EVENT_LIST_FILTERS.each do |name|
            param_name = :"event_#{name}"
            next unless request_params.key?(param_name)

            values = normalize_list(request_params.delete(param_name), symbolize: event_symbol_filter?(name))
            filters[name] = values if values.any?
          end

          EVENT_BOOLEAN_FILTERS.each do |name|
            param_name = :"event_#{name}"
            next unless request_params.key?(param_name)

            filters[name] = normalize_boolean(request_params.delete(param_name), param_name)
          end

          filters.freeze
        end

        def symbol_filter?(name)
          !%i[
            id queue channel assignee latest_action_actor latest_action_origin
            latest_action_source
          ].include?(name)
        end

        def event_symbol_filter?(name)
          !%i[actor origin].include?(name)
        end

        def normalize_list(value, symbolize: false)
          Array(value)
            .flat_map { |entry| entry.to_s.split(",") }
            .map(&:strip)
            .reject(&:empty?)
            .map { |entry| symbolize ? entry.tr(" ", "_").to_sym : entry }
        end

        def normalize_boolean(value, name)
          case value.to_s.strip.downcase
          when "1", "true", "yes", "y", "on"
            true
          when "0", "false", "no", "n", "off"
            false
          else
            raise ArgumentError, "#{name} must be a boolean value"
          end
        end

        def normalize_order_by(value)
          return nil if value.nil? || value.to_s.strip.empty?

          order_by = value.to_s.strip.tr(" ", "_").to_sym
          allowed = Igniter::App::Orchestration::OperatorQuery::ORDERABLE_DIMENSIONS
          raise ArgumentError, "order_by must be one of #{allowed.inspect}" unless allowed.include?(order_by)

          order_by
        end

        def normalize_direction(value)
          return :asc if value.nil? || value.to_s.strip.empty?

          direction = value.to_s.strip.downcase.to_sym
          raise ArgumentError, "direction must be asc or desc" unless %i[asc desc].include?(direction)

          direction
        end

        def normalize_event_order_by(value)
          return nil if value.nil? || value.to_s.strip.empty?

          order_by = value.to_s.strip.tr(" ", "_").to_sym
          allowed = Igniter::App::Orchestration::RuntimeEventQuery::ORDERABLE_DIMENSIONS
          raise ArgumentError, "event_order_by must be one of #{allowed.inspect}" unless allowed.include?(order_by)

          order_by
        end

        def validate_execution_scope!(graph:, execution_id:)
          return if present?(graph) && present?(execution_id)

          raise ArgumentError, "graph and execution_id must be provided together"
        end

        def present?(value)
          !value.nil? && !value.to_s.empty?
        end

        def resolved_store(config)
          store || config&.store || Igniter.execution_store
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
