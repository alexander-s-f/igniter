# frozen_string_literal: true

module Igniter
  module Cluster
    # Cluster-aware remote adapter.
    #
    # Builds on top of the plain server transport and adds capability/pinned
    # peer resolution via mesh routing.
    class RemoteAdapter < Igniter::Server::RemoteAdapter
      private

      def resolve_url(node)
        case node.routing_mode
        when :capability
          resolve_capability_url(node)
        when :pinned
          resolve_pinned_url(node)
        else
          super
        end
      end

      def resolve_capability_url(node)
        deferred = Igniter::Runtime::DeferredResult.build(
          payload: { capability: node.capability },
          source_node: node.name,
          waiting_on: node.name
        )
        Igniter::Cluster::Mesh.router.find_peer_for(node.capability, deferred)
      end

      def resolve_pinned_url(node)
        Igniter::Cluster::Mesh.router.resolve_pinned(node.pinned_to)
      end
    end
  end
end
