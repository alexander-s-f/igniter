# frozen_string_literal: true

module Igniter
  module Cluster
    class CapabilityQuery
      attr_reader :required_capabilities, :preferred_peer, :metadata

      def initialize(required_capabilities: [], preferred_peer: nil, metadata: {})
        @required_capabilities = Array(required_capabilities).map(&:to_sym).uniq.sort.freeze
        @preferred_peer = preferred_peer&.to_sym
        @metadata = metadata.dup.freeze
        freeze
      end

      def self.from_routing(routing)
        new(
          required_capabilities: routing_capabilities(routing),
          preferred_peer: routing_peer(routing),
          metadata: routing_metadata(routing)
        )
      end

      def pinned?
        !preferred_peer.nil?
      end

      def empty?
        required_capabilities.empty? && !pinned?
      end

      def routing_mode
        return :pinned if pinned?
        return :capability unless required_capabilities.empty?

        :first_available
      end

      def matches_peer?(peer)
        return false if pinned? && peer.name != preferred_peer

        peer.supports_capabilities?(required_capabilities)
      end

      def to_h
        {
          required_capabilities: required_capabilities.dup,
          preferred_peer: preferred_peer,
          metadata: metadata.dup
        }
      end

      class << self
        private

        def routing_capabilities(routing)
          routing.fetch(:required_capabilities, routing.fetch("required_capabilities", legacy_capabilities(routing)))
        end

        def routing_peer(routing)
          routing.fetch(:preferred_peer, routing.fetch("preferred_peer", legacy_peer(routing)))
        end

        def routing_metadata(routing)
          routing.fetch(:metadata, routing.fetch("metadata", {}))
        end

        def legacy_capabilities(routing)
          routing.fetch(:all_of, routing.fetch("all_of", []))
        end

        def legacy_peer(routing)
          routing[:peer] || routing["peer"]
        end
      end
    end
  end
end
