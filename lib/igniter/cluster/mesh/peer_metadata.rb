# frozen_string_literal: true

require "time"

module Igniter
  module Cluster
    module Mesh
      # Normalizes and enriches peer metadata with mesh observation coordinates.
      #
      # The mesh envelope captures how fresh and how trustworthy a capability
      # snapshot is as it propagates through the network:
      #   - observed_at: original authoritative observation timestamp
      #   - confidence:  confidence in the snapshot after relay decay
      #   - hops:        relay distance from the authoritative source
      #
      # Freshness is derived dynamically from observed_at so it naturally ages.
      module PeerMetadata
        CONFIDENCE_DECAY = 0.9

        module_function

        def normalize(value)
          case value
          when Hash
            value.each_with_object({}) do |(key, nested), memo|
              memo[key.to_sym] = normalize(nested)
            end
          when Array
            value.map { |item| normalize(item) }
          else
            value
          end
        end

        def authoritative(metadata, origin: nil, observed_at: Time.now.utc)
          base = normalize(metadata)
          mesh = normalize(base[:mesh] || {})

          base.merge(
            mesh: mesh.merge(
              observed_at: iso8601(observed_at),
              confidence: 1.0,
              hops: 0,
              origin: origin&.to_s || mesh[:origin]
            ).compact
          )
        end

        def relay(metadata, relayed_by:, observed_at: Time.now.utc, confidence_decay: CONFIDENCE_DECAY)
          base = normalize(metadata)
          mesh = normalize(base[:mesh] || {})

          base.merge(
            mesh: mesh.merge(
              observed_at: mesh[:observed_at] || iso8601(observed_at),
              confidence: decayed_confidence(mesh[:confidence], confidence_decay),
              hops: mesh.fetch(:hops, 0).to_i + 1,
              relayed_by: relayed_by.to_s,
              relayed_at: iso8601(observed_at)
            )
          )
        end

        def runtime(metadata, now: Time.now.utc)
          base = normalize(metadata)
          mesh = normalize(base[:mesh] || {})
          attestation = normalize(base[:mesh_capabilities] || {})

          base = if mesh.empty?
                   base
                 else
                   observed_at = parse_time(mesh[:observed_at])
                   freshness_seconds = observed_at ? [(now - observed_at).to_i, 0].max : nil

                   base.merge(
                     mesh: mesh.merge(freshness_seconds: freshness_seconds).compact
                   )
                 end

          return base if attestation.empty?

          observed_at = parse_time(attestation[:observed_at])
          freshness_seconds = observed_at ? [(now - observed_at).to_i, 0].max : nil

          base.merge(
            mesh_capabilities: attestation.merge(freshness_seconds: freshness_seconds).compact
          )
        end

        def decayed_confidence(value, decay)
          upstream = value.nil? ? 1.0 : value.to_f
          (upstream * decay).round(4)
        end

        def iso8601(value)
          value.utc.iso8601
        end

        def parse_time(value)
          return value if value.is_a?(Time)
          return nil if value.nil?

          Time.iso8601(value.to_s)
        rescue ArgumentError
          nil
        end
      end
    end
  end
end
