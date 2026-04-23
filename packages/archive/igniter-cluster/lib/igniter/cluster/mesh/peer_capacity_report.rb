# frozen_string_literal: true

module Igniter
  module Cluster
    module Mesh
      # Aggregated capacity snapshot for a single peer, computed by WorkloadTracker.
      #
      # degraded?   — failure_rate >= degraded_threshold (default 0.3)
      # overloaded? — avg_duration_ms >= overload_threshold_ms (default 500)
      PeerCapacityReport = ::Data.define(
        :peer_name,
        :total,
        :successes,
        :failures,
        :failure_rate,
        :avg_duration_ms,
        :degraded,
        :overloaded,
        :capabilities
      ) do
        def degraded?;   degraded;   end
        def overloaded?; overloaded; end
        def healthy?;    !degraded? && !overloaded?; end

        def to_h
          {
            peer_name:       peer_name,
            total:           total,
            successes:       successes,
            failures:        failures,
            failure_rate:    failure_rate.round(4),
            avg_duration_ms: avg_duration_ms&.round(2),
            degraded:        degraded?,
            overloaded:      overloaded?,
            healthy:         healthy?,
            capabilities:    capabilities
          }.compact
        end
      end
    end
  end
end
