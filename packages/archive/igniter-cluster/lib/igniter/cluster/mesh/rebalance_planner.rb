# frozen_string_literal: true

module Igniter
  module Cluster
    module Mesh
      # Analyses entity ownership distribution across cluster nodes and recommends
      # ownership transfers to balance load across eligible peers.
      #
      # Algorithm:
      #   1. Collect all Ownership::Claim objects from the registry.
      #   2. Identify eligible target nodes via ObservationQuery (healthy + capable).
      #   3. Count claims per owner. Owners absent from the eligible set are treated
      #      as transfer sources only ("orphaned" owners).
      #   4. target = floor(total_claims / eligible_node_count)
      #   5. Source priority: ineligible owners first, then most-overloaded eligible.
      #   6. Destination: eligible node with the fewest current claims.
      #   7. Greedily generate transfers until no source/destination pair remains.
      #
      # skew_threshold: minimum (max - min) count difference to trigger rebalancing.
      # Default is 2 — a skew of 1 is acceptable and avoids churn.
      #
      # Entry points:
      #   RebalancePlanner.new(ownership_registry: r, observations: obs).plan
      #   Igniter::Cluster::Mesh.rebalance(ownership_registry, capabilities: [:database])
      class RebalancePlanner
        DEFAULT_SKEW_THRESHOLD = 2
        MAX_ITERATIONS         = 10_000

        # @param ownership_registry [Ownership::Registry]    claim store
        # @param observations       [Array<NodeObservation>] live peer snapshot
        # @param capabilities       [Array<Symbol>, nil]     restrict eligible nodes to these caps
        # @param skew_threshold     [Integer]
        def initialize(ownership_registry:, observations:, capabilities: nil, skew_threshold: DEFAULT_SKEW_THRESHOLD)
          @registry       = ownership_registry
          @observations   = observations
          @capabilities   = capabilities ? Array(capabilities).map(&:to_sym) : nil
          @skew_threshold = skew_threshold
        end

        # @return [RebalancePlan]
        def plan
          eligible = eligible_node_names
          claims   = @registry.all

          if eligible.empty?
            return RebalancePlan.new(transfers: [], rationale: "no eligible nodes found", skew: 0)
          end

          if claims.empty?
            return RebalancePlan.new(transfers: [], rationale: "no claims to rebalance", skew: 0)
          end

          counts = build_counts(claims, eligible)
          skew   = counts.values.max - counts.values.min

          if skew <= @skew_threshold
            return RebalancePlan.new(
              transfers: [],
              rationale: "skew #{skew} is within threshold (#{@skew_threshold})",
              skew: skew
            )
          end

          transfers = compute_transfers(claims, counts, eligible)
          rationale = "skew #{skew} > threshold #{@skew_threshold}; #{transfers.size} transfer(s) planned"

          RebalancePlan.new(transfers: transfers, rationale: rationale, skew: skew)
        end

        private

        def eligible_node_names
          q = ObservationQuery.new(@observations).healthy
          q = q.with(*@capabilities) if @capabilities
          q.to_a.map(&:name).to_set
        end

        # Build a count map: every eligible node starts at 0, then add actual claims.
        def build_counts(claims, eligible)
          counts = eligible.each_with_object({}) { |name, h| h[name] = 0 }
          claims.each do |claim|
            counts[claim.owner] ||= 0
            counts[claim.owner] += 1
          end
          counts
        end

        def compute_transfers(all_claims, counts, eligible)
          target    = all_claims.size / eligible.size
          transfers = []
          remaining = all_claims.dup
          working   = counts.dup
          iterations = 0

          loop do
            iterations += 1
            break if iterations > MAX_ITERATIONS

            from_owner = pick_source(working, target, eligible)
            break unless from_owner

            to_owner = pick_destination(working, eligible)
            break unless to_owner
            break if from_owner == to_owner

            claim = remaining.find { |c| c.owner == from_owner }
            break unless claim

            transfers << {
              action:      :transfer_ownership,
              entity_type: claim.entity_type,
              entity_id:   claim.entity_id,
              from_owner:  from_owner,
              to_owner:    to_owner
            }

            remaining.delete(claim)
            working[from_owner] -= 1
            working[to_owner]   = (working[to_owner] || 0) + 1
          end

          transfers
        end

        # Highest-priority transfer source.
        # Ineligible owners (orphaned claims) take precedence over overloaded eligible nodes.
        # Eligible sources: stop when all eligible node counts are within 1 of each other.
        def pick_source(counts, _target, eligible)
          ineligible = counts
            .reject { |owner, _| eligible.include?(owner) }
            .select { |_, count| count > 0 }

          return ineligible.max_by { |_, c| c }.first if ineligible.any?

          eligible_counts = counts.select { |owner, _| eligible.include?(owner) }
          max_count = eligible_counts.values.max || 0
          min_count = eligible_counts.values.min || 0
          return nil if max_count - min_count <= 1

          eligible_counts.select { |_, c| c == max_count }.keys.min
        end

        # Eligible node with the fewest current claims (greedy destination).
        # Breaks ties by name for deterministic ordering.
        def pick_destination(counts, eligible)
          eligible_counts = counts.select { |owner, _| eligible.include?(owner) }
          min_count = eligible_counts.values.min
          eligible_counts.select { |_, c| c == min_count }.keys.min
        end
      end
    end
  end
end
