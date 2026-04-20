# frozen_string_literal: true

require_relative "agent_adapter"
require_relative "agent_route_resolver"
require_relative "agent_transport"

module Igniter
  module Runtime
    # Delegates local agent delivery to one adapter and remote delivery to a
    # transport chosen through a route resolver.
    class ProxyAgentAdapter < AgentAdapter
      def initialize(local_adapter:, route_resolver: AgentRouteResolver.new, transport: AgentTransport.new)
        @local_adapter = local_adapter
        @route_resolver = route_resolver
        @transport = transport
      end

      def call(node:, inputs:, execution: nil)
        route = @route_resolver.resolve(node: node, execution: execution)
        response =
          if route.local?
            @local_adapter.call(node: node, inputs: inputs, execution: execution)
          else
            @transport.call(route: route, node: node, inputs: inputs, execution: execution)
          end

        merge_route_trace(response, route)
      end

      def cast(node:, inputs:, execution: nil)
        route = @route_resolver.resolve(node: node, execution: execution)
        response =
          if route.local?
            @local_adapter.cast(node: node, inputs: inputs, execution: execution)
          else
            @transport.cast(route: route, node: node, inputs: inputs, execution: execution)
          end

        merge_route_trace(response, route)
      end

      private

      def merge_route_trace(response, route)
        return response unless response.is_a?(Hash)

        route_trace = {
          routing_mode: route.routing_mode,
          route_url: route.url,
          capability: route.capability,
          capability_query: route.query,
          pinned_to: route.pinned_to,
          remote: route.remote?
        }.reject { |_key, value| value.nil? }

        existing_trace = response[:agent_trace] || response["agent_trace"] || {}

        response.merge(agent_trace: route_trace.merge(existing_trace))
      end
    end
  end
end
