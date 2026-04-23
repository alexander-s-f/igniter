# frozen_string_literal: true

module Igniter
  module Runtime
    # Base transport seam for remotely routed agent nodes.
    class AgentTransport
      def session_lifecycle?
        false
      end

      def call(route:, node:, inputs:, execution: nil) # rubocop:disable Lint/UnusedMethodArgument
        raise ResolutionError,
              "agent :#{node.name} requires a configured remote agent transport for #{route.routing_mode} routing"
      end

      def cast(route:, node:, inputs:, execution: nil) # rubocop:disable Lint/UnusedMethodArgument
        raise ResolutionError,
              "agent :#{node.name} requires a configured remote agent transport for #{route.routing_mode} routing"
      end

      def continue_session(route:, session:, payload:, execution: nil, trace: nil, token: nil, waiting_on: nil, request: nil, reply: nil, phase: nil) # rubocop:disable Metrics/ParameterLists, Lint/UnusedMethodArgument
        nil
      end

      def resume_session(route:, session:, execution: nil, value: nil) # rubocop:disable Lint/UnusedMethodArgument
        nil
      end
    end
  end
end
