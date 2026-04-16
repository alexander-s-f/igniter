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
        query = node.capability_query || { all_of: [node.capability] }
        deferred = Igniter::Runtime::DeferredResult.build(
          payload: { capability: node.capability, query: query },
          source_node: node.name,
          waiting_on: node.name
        )
        if node.capability_query
          Igniter::Cluster::Mesh.router.find_peer_for_query(node.capability_query, deferred)
        else
          Igniter::Cluster::Mesh.router.find_peer_for(node.capability, deferred)
        end
      end

      def resolve_pinned_url(node)
        Igniter::Cluster::Mesh.router.resolve_pinned(node.pinned_to)
      end
    end
  end
end
