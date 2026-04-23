# frozen_string_literal: true

module Igniter
  module Cluster
    class PolicyRouter
      attr_reader :policy

      def initialize(policy:)
        @policy = policy
        freeze
      end

      def route(request:, placement:)
        candidates = placement.candidates
        raise RoutingError, "no peers available for #{request.session_id}" if candidates.empty?

        selected_peer = policy.select_peer(query: request.query, candidates: candidates)
        raise RoutingError, missing_route_message(request) if selected_peer.nil?

        Route.new(
          peer: selected_peer,
          mode: policy.route_mode_for(request.query),
          metadata: route_metadata(request, candidates, selected_peer),
          explanation: policy.explanation_for(query: request.query, peer: selected_peer)
        )
      end

      private

      def route_metadata(request, candidates, selected_peer)
        {
          policy: policy.to_h,
          query: request.query.to_h,
          candidate_names: candidates.map(&:name),
          selected_capabilities: selected_peer.capabilities,
          selected_peer_profile: selected_peer.profile.to_h
        }
      end

      def missing_route_message(request)
        [
          "no route for #{request.session_id}",
          "query=#{request.query.to_h.inspect}",
          "policy=#{policy.to_h.inspect}"
        ].join(" ")
      end
    end
  end
end
