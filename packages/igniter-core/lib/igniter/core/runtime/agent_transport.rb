# frozen_string_literal: true

module Igniter
  module Runtime
    # Base transport seam for remotely routed agent nodes.
    class AgentTransport
      def call(route:, node:, inputs:, execution: nil) # rubocop:disable Lint/UnusedMethodArgument
        raise ResolutionError,
              "agent :#{node.name} requires a configured remote agent transport for #{route.routing_mode} routing"
      end

      def cast(route:, node:, inputs:, execution: nil) # rubocop:disable Lint/UnusedMethodArgument
        raise ResolutionError,
              "agent :#{node.name} requires a configured remote agent transport for #{route.routing_mode} routing"
      end
    end
  end
end
