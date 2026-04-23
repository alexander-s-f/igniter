# frozen_string_literal: true

module Igniter
  module Cluster
    class DirectPlacement
      def place(request:, peers:)
        selected_peers = selected_peers_for(request, peers)
        PlacementDecision.new(
          mode: placement_mode(request),
          candidates: selected_peers,
          metadata: { requested_peer: request.pinned_peer },
          explanation: explanation_for(request, selected_peers)
        )
      end

      private

      def selected_peers_for(request, peers)
        return Array(peers) unless request.pinned_peer

        Array(peers).select { |peer| peer.name == request.pinned_peer }
      end

      def placement_mode(request)
        request.pinned_peer ? :pinned : :direct
      end

      def explanation_for(request, selected_peers)
        return "preferred peer=#{request.pinned_peer}" if request.pinned_peer

        "direct placement across #{selected_peers.length} peer(s)"
      end
    end
  end
end
