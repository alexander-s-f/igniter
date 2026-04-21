# frozen_string_literal: true

require "time"

module Igniter
  module Cluster
    module Mesh
      # A single recorded runtime event for one peer-capability interaction.
      # Immutable — produced by WorkloadTracker#record.
      WorkloadSignal = ::Data.define(
        :peer_name,
        :capability,
        :success,
        :duration_ms,
        :error_class,
        :recorded_at
      ) do
        def self.build(peer_name:, capability:, success:, duration_ms: nil, error: nil, recorded_at: Time.now.utc.iso8601)
          new(
            peer_name:   peer_name.to_s,
            capability:  capability&.to_sym,
            success:     success ? true : false,
            duration_ms: duration_ms&.to_f,
            error_class: error ? error.class.name : nil,
            recorded_at: recorded_at.to_s
          )
        end

        def failure?
          !success
        end

        def to_h
          {
            peer_name:   peer_name,
            capability:  capability,
            success:     success,
            duration_ms: duration_ms,
            error_class: error_class,
            recorded_at: recorded_at
          }.compact
        end
      end
    end
  end
end
