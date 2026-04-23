# frozen_string_literal: true

module Igniter
  module Cluster
    class RegistryMembershipSource < MeshMembershipSource
      attr_reader :metadata

      def initialize(metadata: {})
        super()
        @metadata = metadata.dup.freeze
        freeze
      end

      def call(environment:, allow_degraded:, metadata: {})
        MeshMembership.new(
          peers: environment.peers,
          allow_degraded: allow_degraded,
          metadata: @metadata.merge(metadata)
        )
      end

      def to_h
        {
          metadata: metadata.dup
        }
      end
    end
  end
end
