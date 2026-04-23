# frozen_string_literal: true

module Igniter
  module Cluster
    class DirectPlacement
      def place(request:, peers:)
        selected_peers = selected_peers_for(request, peers)
        PlacementDecision.new(
          mode: request.query.pinned? ? :pinned : :direct,
          candidates: selected_peers,
          metadata: { query: request.query.to_h },
          explanation: explanation_for(request, selected_peers)
        )
      end

      private

      def selected_peers_for(request, peers)
        return Array(peers) unless request.query.pinned?

        Array(peers).select { |peer| peer.name == request.query.preferred_peer }
      end

      def explanation_for(request, selected_peers)
        return "preferred peer=#{request.query.preferred_peer}" if request.query.pinned?

        "direct placement across #{selected_peers.length} peer(s)"
      end
    end
  end
end
