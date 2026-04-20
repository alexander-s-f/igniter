# frozen_string_literal: true

module Igniter
  module Server
    module Handlers
      class AgentMessageHandler < Base
        def initialize(registry, store, mode:) # rubocop:disable Lint/UnusedMethodArgument
          super(registry, store)
          @mode = mode.to_sym
        end

        private

        def handle(params:, body:)
          require "igniter/agent"

          node = build_node(params, body)
          adapter = Igniter::Runtime::RegistryAgentAdapter.new
          response =
            if @mode == :cast
              adapter.cast(node: node, inputs: symbolize_inputs(body["inputs"] || {}))
            else
              adapter.call(node: node, inputs: symbolize_inputs(body["inputs"] || {}))
            end

          json_ok(serialize_agent_response(response))
        end

        def build_node(params, body)
          reply_mode =
            if @mode == :cast
              :none
            else
              raw = body["reply_mode"]
              raw ? raw.to_sym : :deferred
            end

          Igniter::Model::AgentNode.new(
            id: "server-agent:#{params[:via]}:#{params[:message]}:#{@mode}",
            name: :"server_#{params[:via]}_#{params[:message]}_#{@mode}",
            agent_name: params[:via],
            message_name: params[:message],
            input_mapping: symbolize_inputs(body["inputs"] || {}).transform_keys(&:to_sym),
            timeout: body["timeout"] || 5,
            mode: @mode,
            reply_mode: reply_mode
          )
        end

        def serialize_agent_response(response)
          data = {
            status: response[:status].to_s,
            output: to_json_value(response[:output]),
            payload: to_json_value(response[:payload]),
            agent_trace: to_json_value(response[:agent_trace]),
            agent_session: to_json_value(response[:agent_session]),
            message: response[:message]
          }

          if response[:deferred_result]
            data[:deferred_result] = {
              token: response[:deferred_result].token,
              source_node: response[:deferred_result].source_node,
              waiting_on: response[:deferred_result].waiting_on,
              payload: to_json_value(response[:deferred_result].payload)
            }
          end

          data[:error] = to_json_value(response[:error]) if response[:error]
          data.compact
        end
      end
    end
  end
end
