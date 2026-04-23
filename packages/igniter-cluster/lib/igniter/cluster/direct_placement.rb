# frozen_string_literal: true

module Igniter
  module Cluster
    class DirectPlacement
      def place(request:, peers:)
        selected_peers =
          if request.pinned_peer
            Array(peers).select { |peer| peer.name == request.pinned_peer }
          else
            Array(peers)
          end

        mode = request.pinned_peer ? :pinned : :direct
        explanation =
          if request.pinned_peer
            "preferred peer=#{request.pinned_peer}"
          else
            "direct placement across #{selected_peers.length} peer(s)"
          end

        PlacementDecision.new(
          mode: mode,
          candidates: selected_peers,
          metadata: { requested_peer: request.pinned_peer },
          explanation: explanation
        )
      end
    end
  end
end
