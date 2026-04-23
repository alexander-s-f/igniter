# frozen_string_literal: true

module Igniter
  module Cluster
    class MeshMembershipSource
      def call(environment:, allow_degraded:, metadata: {})
        MeshMembership.new(
          peers: environment.peers,
          allow_degraded: allow_degraded,
          metadata: metadata
        )
      end
    end
  end
end
