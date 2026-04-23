# frozen_string_literal: true

module Igniter
  module Cluster
    class MeshMembership
      attr_reader :peers, :allow_degraded, :metadata

      def initialize(peers:, allow_degraded: false, metadata: {})
        @peers = Array(peers).freeze
        @allow_degraded = allow_degraded == true
        @metadata = metadata.dup.freeze
        freeze
      end

      def available_peers
        peers.select do |peer|
          peer.health.available?(allow_degraded: allow_degraded)
        end
      end

      def fetch(name)
        available_peers.find { |peer| peer.name == name.to_sym }
      end

      def include?(name)
        !fetch(name).nil?
      end

      def select(query: nil, names: nil)
        candidates = available_peers
        candidates = candidates.select { |peer| Array(names).map(&:to_sym).include?(peer.name) } unless names.nil?
        return candidates if query.nil?

        candidates.select { |peer| query.matches_peer?(peer) }
      end

      def to_h
        {
          peer_names: peers.map(&:name),
          available_peer_names: available_peers.map(&:name),
          allow_degraded: allow_degraded,
          metadata: metadata.dup
        }
      end
    end
  end
end
