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
        selected_peer =
          if request.pinned_peer
            candidates.find { |peer| peer.name == request.pinned_peer }
          else
            candidates.find { |peer| peer.supports_capabilities?(request.capabilities) }
          end

        return selected_peer unless selected_peer.nil?

        raise RoutingError, missing_route_message(request)
      end

      def route_metadata(request, candidates, selected_peer)
        {
          required_capabilities: request.capabilities,
          candidate_names: candidates.map(&:name),
          selected_capabilities: selected_peer.capabilities
        }
      end

      def missing_route_message(request)
        [
          "no route for #{request.session_id}",
          "capabilities=#{request.capabilities.inspect}",
          "peer=#{request.pinned_peer.inspect}"
        ].join(" ")
      end

      def routing_mode_for(request)
        return :pinned if request.pinned_peer
        return :capability unless request.capabilities.empty?

        :first_available
      end

      def explanation_for(request, peer)
        return "pinned route to #{peer.name}" if request.pinned_peer
        return "capability route to #{peer.name}" unless request.capabilities.empty?

        "first available peer #{peer.name}"
      end
    end
  end
end
