# frozen_string_literal: true

module Igniter
  module Cluster
    module Mesh
      # Multi-dimensional placement engine that selects the best NodeObservation
      # from a candidate pool for a given capability requirement.
      #
      # Placement proceeds in three stages:
      #   1. Filter  — apply PlacementPolicy hard constraints via ObservationQuery
      #   2. Score   — compute a weighted composite score across eight dimensions
      #   3. Select  — pick the highest-scoring candidate; ties broken by name (stable)
      #
      # When degraded_fallback is enabled in the policy and the primary candidate
      # set is empty, the planner retries with a fully relaxed policy and marks the
      # result as degraded.
      #
      # Scoring weights:
      #   health:      0.25  (healthy=1.0, degraded=0.3, unknown=0.0)
      #   trust:       0.20  (trusted=1.0, else=0.0)
      #   load_cpu:    0.18  (1 - load_cpu; nil → 0.5 neutral)
      #   load_memory: 0.12  (1 - load_memory; nil → 0.5 neutral)
      #   workload:    0.15  (live signals: healthy=1.0, overloaded=0.3, degraded=0.2, both=0.0, unknown=0.8)
      #   locality:    0.07  (zone match=1.0, region match=0.5, none=0.0)
      #   confidence:  0.02  (0..1, defaults to 1.0 when unknown)
      #   freshness:   0.01  (observed within 120s → 1.0, stale → 0.0)
      #
      # Entry points:
      #   PlacementPlanner.new(observations, policy: policy).place(:database)
      #   Igniter::Cluster::Mesh.place(:database, policy: policy)
      class PlacementPlanner
        WEIGHTS = {
          health:      0.25,
          trust:       0.20,
          load_cpu:    0.18,
          load_memory: 0.12,
          workload:    0.15,
          locality:    0.07,
          confidence:  0.02,
          freshness:   0.01
        }.freeze

        # @param observations [Array<NodeObservation>]
        # @param policy       [PlacementPolicy]
        def initialize(observations, policy: PlacementPolicy.new)
          @observations = observations
          @policy       = policy
        end

        # Select the best node for the given capabilities.
        #
        # @param capabilities [Symbol, Array<Symbol>, nil]  required capabilities; nil = any
        # @return [PlacementDecision]
        def place(capabilities = nil)
          base_query = ObservationQuery.new(@observations)
          base_query = base_query.with(*Array(capabilities)) unless capabilities.nil?

          candidates, degraded = filtered_candidates(base_query)

          if candidates.empty?
            return PlacementDecision.new(
              node: nil, score: nil, dimensions: {}, rejected: [],
              degraded: degraded, policy: @policy
            )
          end

          scored = score_all(candidates).sort_by { |obs, s| [-s[:total], obs.name] }
          best_node, best_score = scored.first

          rejected = scored.drop(1).map do |obs, s|
            { name: obs.name, url: obs.url, score: s[:total], dimensions: s.except(:total) }
          end

          PlacementDecision.new(
            node:       best_node,
            score:      best_score[:total],
            dimensions: best_score.except(:total),
            rejected:   rejected,
            degraded:   degraded,
            policy:     @policy
          )
        end

        private

        def filtered_candidates(base_query)
          candidates = @policy.constrain(base_query).to_a
          return [candidates, false] unless candidates.empty? && @policy.degraded_fallback

          [@policy.relaxed.constrain(base_query).to_a, true]
        end

        def score_all(candidates)
          candidates.map { |obs| [obs, score(obs)] }
        end

        def score(obs)
          dims = {
            health:      health_score(obs),
            trust:       trust_score(obs),
            load_cpu:    load_cpu_score(obs),
            load_memory: load_memory_score(obs),
            workload:    workload_score(obs),
            locality:    locality_score(obs),
            confidence:  obs.confidence || 1.0,
            freshness:   obs.fresh?(max_seconds: 120) ? 1.0 : 0.0
          }
          total = WEIGHTS.sum { |dim, w| w * dims.fetch(dim, 0.0) }
          dims.merge(total: total.round(6))
        end

        def health_score(obs)
          case obs.health
          when :healthy  then 1.0
          when :degraded then 0.3
          else 0.0
          end
        end

        def trust_score(obs)
          obs.trusted? ? 1.0 : 0.0
        end

        def load_cpu_score(obs)
          obs.load_cpu ? [1.0 - obs.load_cpu, 0.0].max : 0.5
        end

        def load_memory_score(obs)
          obs.load_memory ? [1.0 - obs.load_memory, 0.0].max : 0.5
        end

        def workload_score(obs)
          return 0.8 unless obs.workload_observed?

          degraded   = obs.workload_degraded?
          overloaded = obs.workload_overloaded?

          if degraded && overloaded then 0.0
          elsif degraded            then 0.2
          elsif overloaded          then 0.3
          else                           1.0
          end
        end

        def locality_score(obs)
          return 1.0 if @policy.zone && obs.zone == @policy.zone
          return 0.5 if @policy.region && obs.region == @policy.region

          0.0
        end
      end
    end
  end
end
