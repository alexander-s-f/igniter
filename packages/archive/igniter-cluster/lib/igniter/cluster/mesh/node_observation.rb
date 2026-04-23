# frozen_string_literal: true

module Igniter
  module Cluster
    module Mesh
      # Canonical per-node snapshot: a typed, multi-dimensional observation of
      # a cluster peer at a point in time.
      #
      # Each NodeObservation is an OLAP Point — a slice through the cluster's
      # observable field across seven dimensions:
      #
      #   capabilities  — what the node can do and how fresh/trusted that claim is
      #   trust         — identity, signing key, trust status
      #   state         — runtime health, load, concurrency, queue depth
      #   locality      — region, zone, proximity tags
      #   governance    — signed checkpoint, trail crest, governance trust
      #   provenance    — who observed this, when, with what confidence, via how many hops
      #   workload      — live failure rate, avg latency, degraded/overloaded flags
      #
      # Implements the duck-typed interface expected by CapabilityQuery:
      #   capability?(cap), tag?(tag), metadata (Hash)
      #
      # Always build via NodeObservation.from_peer_hash so freshness is computed
      # at observation time. Do not cache long-lived instances — freshness_seconds
      # ages from the construction timestamp.
      class NodeObservation
        attr_reader :name, :url, :capabilities, :tags, :metadata

        def initialize(name:, url:, capabilities:, tags:, metadata:)
          @name         = name.to_s.freeze
          @url          = url.to_s.freeze
          @capabilities = Array(capabilities).map(&:to_sym).freeze
          @tags         = Array(tags).map(&:to_sym).freeze
          @metadata     = PeerMetadata.normalize(metadata).freeze
          freeze
        end

        # ── CapabilityQuery interface ─────────────────────────────────────────

        def capability?(capability)
          @capabilities.include?(capability.to_sym)
        end

        def tag?(tag)
          @tags.include?(tag.to_sym)
        end

        def matches_query?(query)
          normalized = Igniter::Cluster::Replication::CapabilityQuery.normalize(query)
          normalized.matches_profile?(self)
        end

        # ── Observation provenance ────────────────────────────────────────────

        def node_id
          @metadata.dig(:mesh_identity, :node_id) || @metadata.dig(:mesh, :origin)
        end

        def observed_at
          @metadata.dig(:mesh, :observed_at)
        end

        def observed_by
          @metadata.dig(:mesh, :origin)
        end

        def confidence
          @metadata.dig(:mesh, :confidence) || 1.0
        end

        def hops
          @metadata.dig(:mesh, :hops) || 0
        end

        def relayed_by
          @metadata.dig(:mesh, :relayed_by)
        end

        def authoritative?
          hops == 0
        end

        def fresh?(max_seconds: 60)
          freshness = @metadata.dig(:mesh, :freshness_seconds)
          freshness && freshness <= max_seconds
        end

        # ── Capabilities dimension ────────────────────────────────────────────

        def capabilities_trust_status
          @metadata.dig(:mesh_capabilities, :trust, :status)&.to_sym
        end

        def capabilities_freshness_seconds
          @metadata.dig(:mesh_capabilities, :freshness_seconds)
        end

        def capabilities_observed_at
          @metadata.dig(:mesh_capabilities, :observed_at)
        end

        # ── Trust dimension ───────────────────────────────────────────────────

        def trust_status
          @metadata.dig(:mesh_trust, :status)&.to_sym
        end

        def trusted?
          @metadata.dig(:mesh_trust, :trusted) == true
        end

        def identity_fingerprint
          @metadata.dig(:mesh_identity, :fingerprint)
        end

        def contracts
          Array(@metadata.dig(:mesh_identity, :contracts))
        end

        # ── State dimension ───────────────────────────────────────────────────

        def health
          @metadata.dig(:mesh_state, :health)&.to_sym || :unknown
        end

        def load_cpu
          @metadata.dig(:mesh_state, :load_cpu)
        end

        def load_memory
          @metadata.dig(:mesh_state, :load_memory)
        end

        def concurrency
          @metadata.dig(:mesh_state, :concurrency) || 0
        end

        def queue_depth
          @metadata.dig(:mesh_state, :queue_depth) || 0
        end

        # ── Locality dimension ────────────────────────────────────────────────

        def region
          @metadata.dig(:mesh_locality, :region)
        end

        def zone
          @metadata.dig(:mesh_locality, :zone)
        end

        def proximity_tags
          Array(@metadata.dig(:mesh_locality, :proximity_tags)).map(&:to_sym)
        end

        # ── Workload dimension ────────────────────────────────────────────────

        def workload_failure_rate
          @metadata.dig(:mesh_workload, :failure_rate)
        end

        def workload_avg_duration_ms
          @metadata.dig(:mesh_workload, :avg_duration_ms)
        end

        def workload_total
          @metadata.dig(:mesh_workload, :total) || 0
        end

        def workload_degraded?
          @metadata.dig(:mesh_workload, :degraded) == true
        end

        def workload_overloaded?
          @metadata.dig(:mesh_workload, :overloaded) == true
        end

        def workload_healthy?
          !workload_degraded? && !workload_overloaded?
        end

        # True only when the workload dimension was populated (tracker is present).
        def workload_observed?
          @metadata.key?(:mesh_workload)
        end

        # ── Governance dimension ──────────────────────────────────────────────

        def governance_trust_status
          @metadata.dig(:mesh_governance, :trust, :status)&.to_sym
        end

        def governance_freshness_seconds
          @metadata.dig(:mesh_governance, :freshness_seconds)
        end

        def governance_crest_digest
          @metadata.dig(:mesh_governance, :crest_digest)
        end

        def governance_total
          @metadata.dig(:mesh_governance, :total) || 0
        end

        # ── OLAP Point summary ────────────────────────────────────────────────

        def dimensions
          {
            capabilities: {
              values:           @capabilities,
              trust:            capabilities_trust_status,
              freshness_seconds: capabilities_freshness_seconds
            },
            trust: {
              status:      trust_status,
              trusted:     trusted?,
              fingerprint: identity_fingerprint
            },
            state: {
              health:      health,
              load_cpu:    load_cpu,
              load_memory: load_memory,
              concurrency: concurrency,
              queue_depth: queue_depth
            },
            locality: {
              region:         region,
              zone:           zone,
              proximity_tags: proximity_tags
            },
            governance: {
              trust:             governance_trust_status,
              freshness_seconds: governance_freshness_seconds,
              crest_digest:      governance_crest_digest,
              total:             governance_total
            },
            provenance: {
              observed_at:  observed_at,
              observed_by:  observed_by,
              confidence:   confidence,
              hops:         hops,
              authoritative: authoritative?
            },
            workload: {
              failure_rate:    workload_failure_rate,
              avg_duration_ms: workload_avg_duration_ms,
              total:           workload_total,
              degraded:        workload_degraded?,
              overloaded:      workload_overloaded?,
              observed:        workload_observed?
            }
          }.freeze
        end

        def to_h
          { name: @name, url: @url, capabilities: @capabilities, tags: @tags, metadata: @metadata }
        end

        # ── Factory ───────────────────────────────────────────────────────────

        # Build from a peer hash (PeerIdentityEnvelope output format) with
        # freshness computed at observation time.
        def self.from_peer_hash(hash, now: Time.now.utc)
          hash = PeerMetadata.normalize(hash)
          runtime_meta = PeerMetadata.runtime(hash[:metadata] || {}, now: now)
          new(
            name:         hash[:name] || "",
            url:          hash[:url] || "",
            capabilities: hash[:capabilities] || [],
            tags:         hash[:tags] || [],
            metadata:     runtime_meta
          )
        end

        def self.from_h(hash)
          from_peer_hash(PeerMetadata.normalize(hash))
        end
      end
    end
  end
end
