# frozen_string_literal: true

module Igniter
  module Cluster
    class RoutePolicy
      attr_reader :name, :honor_preferred_peer, :require_capabilities, :allow_first_available, :metadata

      def initialize(name:, honor_preferred_peer: true, require_capabilities: true, allow_first_available: true,
                     metadata: {})
        @name = name.to_sym
        @honor_preferred_peer = honor_preferred_peer == true
        @require_capabilities = require_capabilities == true
        @allow_first_available = allow_first_available == true
        @metadata = metadata.dup.freeze
        freeze
      end

      def self.capability(metadata: {})
        new(name: :capability, metadata: metadata)
      end

      def route_mode_for(query)
        return :pinned if honor_preferred_peer && query.pinned?
        return :capability if require_capabilities && !query.required_capabilities.empty?
        return :first_available if allow_first_available

        :unroutable
      end

      def select_peer(query:, candidates:)
        Array(candidates).find do |peer|
          matches_peer?(query, peer)
        end
      end

      def explanation_for(query:, peer:)
        mode = route_mode_for(query)

        case mode
        when :pinned
          DecisionExplanation.new(
            code: :pinned_route,
            message: "pinned route to #{peer.name}",
            metadata: {
              peer: peer.name,
              preferred_peer: query.preferred_peer,
              policy: name
            }
          )
        when :capability
          DecisionExplanation.new(
            code: :capability_route,
            message: "capability route to #{peer.name}",
            metadata: {
              peer: peer.name,
              required_capabilities: query.required_capabilities,
              policy: name
            }
          )
        else
          DecisionExplanation.new(
            code: :first_available_route,
            message: "first available peer #{peer.name}",
            metadata: {
              peer: peer.name,
              policy: name
            }
          )
        end
      end

      def to_h
        {
          name: name,
          honor_preferred_peer: honor_preferred_peer,
          require_capabilities: require_capabilities,
          allow_first_available: allow_first_available,
          metadata: metadata.dup
        }
      end

      private

      def matches_peer?(query, peer)
        return false if honor_preferred_peer && query.pinned? && peer.name != query.preferred_peer
        return true unless require_capabilities

        peer.supports_capabilities?(query.required_capabilities)
      end
    end
  end
end
