# frozen_string_literal: true

module Igniter
  module Cluster
    class PolicyPlacement
      attr_reader :policy

      def initialize(policy:)
        @policy = policy
        freeze
      end

      def place(request:, peers:)
        selected_peers = policy.select_candidates(query: request.query, peers: peers)
        PlacementDecision.new(
          mode: policy.mode_for(request.query),
          candidates: selected_peers,
          metadata: {
            policy: policy.to_h,
            query: request.query.to_h
          },
          explanation: policy.explanation_for(query: request.query, candidates: selected_peers)
        )
      end
    end
  end
end
