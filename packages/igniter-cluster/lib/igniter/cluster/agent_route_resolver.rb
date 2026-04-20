# frozen_string_literal: true

module Igniter
  module Cluster
    # Mesh-aware route resolver for agent nodes.
    class AgentRouteResolver < Igniter::Runtime::AgentRouteResolver
      def resolve(node:, execution: nil) # rubocop:disable Lint/UnusedMethodArgument
        case node.routing_mode
        when :capability
          resolve_capability_route(node)
        when :pinned
          resolve_pinned_route(node)
        else
          super
        end
      end

      private

      def resolve_capability_route(node)
        query = node.capability_query || { all_of: [node.capability] }
        deferred = Igniter::Runtime::DeferredResult.build(
          payload: {
            via: node.agent_name,
            message: node.message_name,
            capability: node.capability,
            query: query
          },
          source_node: node.name,
          waiting_on: node.name
        )
        url =
          if node.capability_query
            Igniter::Cluster::Mesh.router.find_peer_for_query(node.capability_query, deferred)
          else
            Igniter::Cluster::Mesh.router.find_peer_for(node.capability, deferred)
          end

        Igniter::Runtime::AgentRoute.static(
          via: node.agent_name,
          message: node.message_name,
          url: url,
          capability: node.capability,
          query: node.capability_query || query
        )
      end

      def resolve_pinned_route(node)
        Igniter::Runtime::AgentRoute.static(
          via: node.agent_name,
          message: node.message_name,
          url: Igniter::Cluster::Mesh.router.resolve_pinned(node.pinned_to),
          pinned_to: node.pinned_to
        )
      end
    end
  end
end
