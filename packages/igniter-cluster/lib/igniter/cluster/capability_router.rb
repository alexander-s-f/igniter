# frozen_string_literal: true

module Igniter
  module Cluster
    class CapabilityRouter
      def route(request:, placement:)
        candidates = placement.candidates
        raise RoutingError, "no peers available for #{request.session_id}" if candidates.empty?

        selected_peer = select_peer(request, candidates)
        Route.new(
          peer: selected_peer,
          mode: routing_mode_for(request),
          metadata: route_metadata(request, candidates, selected_peer),
          explanation: explanation_for(request, selected_peer)
        )
      end

      private

      def select_peer(request, candidates)
        selected_peer = candidates.find { |peer| request.query.matches_peer?(peer) }

        return selected_peer unless selected_peer.nil?

        raise RoutingError, missing_route_message(request)
      end

      def route_metadata(request, candidates, selected_peer)
        {
          query: request.query.to_h,
          candidate_names: candidates.map(&:name),
          selected_capabilities: selected_peer.capabilities
        }
      end

      def missing_route_message(request)
        [
          "no route for #{request.session_id}",
          "query=#{request.query.to_h.inspect}"
        ].join(" ")
      end

      def routing_mode_for(request)
        request.query.routing_mode
      end

      def explanation_for(request, peer)
        return "pinned route to #{peer.name}" if request.query.pinned?
        return "capability route to #{peer.name}" unless request.query.required_capabilities.empty?

        "first available peer #{peer.name}"
      end
    end
  end
end
