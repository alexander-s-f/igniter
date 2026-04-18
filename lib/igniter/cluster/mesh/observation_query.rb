# frozen_string_literal: true

module Igniter
  module Cluster
    module Mesh
      # Chainable, immutable query builder over a collection of NodeObservation.
      #
      # Each method returns a new ObservationQuery — the original is unchanged.
      # Execution is lazy: filtering and sorting happen only when #to_a / #each
      # / #first / #count is called.
      #
      # Entry points:
      #   Igniter::Cluster::Mesh.query(now:)
      #   registry.query(now:)
      #
      # Example:
      #   Igniter::Cluster::Mesh.query
      #     .with(:database)
      #     .healthy
      #     .max_load_cpu(0.7)
      #     .in_zone("us-east-1a")
      #     .trusted
      #     .order_by(:load_cpu)
      #     .limit(3)
      #     .to_a
      class ObservationQuery
        include Enumerable

        ORDERABLE_DIMENSIONS = %i[
          load_cpu load_memory concurrency queue_depth
          confidence hops governance_total capabilities_freshness
        ].freeze

        def initialize(observations)
          @observations = observations
          @filters      = [].freeze
          @orderings    = [].freeze
          @limit_count  = nil
          freeze
        end

        # ── Capabilities dimension ──────────────────────────────────────────

        def with(*caps)
          syms = caps.map(&:to_sym)
          add_filter { |o| syms.all? { |c| o.capability?(c) } }
        end

        def without(*caps)
          syms = caps.map(&:to_sym)
          add_filter { |o| syms.none? { |c| o.capability?(c) } }
        end

        def tagged(*tags)
          syms = tags.map(&:to_sym)
          add_filter { |o| syms.all? { |t| o.tag?(t) } }
        end

        # ── Trust dimension ─────────────────────────────────────────────────

        def trusted
          add_filter(&:trusted?)
        end

        def trust_status_in(*statuses)
          syms = statuses.map(&:to_sym)
          add_filter { |o| syms.include?(o.trust_status) }
        end

        # ── State dimension ─────────────────────────────────────────────────

        def healthy
          add_filter { |o| o.health == :healthy }
        end

        def health_in(*statuses)
          syms = statuses.map(&:to_sym)
          add_filter { |o| syms.include?(o.health) }
        end

        def max_load_cpu(threshold)
          add_filter { |o| o.load_cpu.nil? || o.load_cpu <= threshold }
        end

        def max_load_memory(threshold)
          add_filter { |o| o.load_memory.nil? || o.load_memory <= threshold }
        end

        def max_concurrency(threshold)
          add_filter { |o| o.concurrency <= threshold }
        end

        def max_queue_depth(threshold)
          add_filter { |o| o.queue_depth <= threshold }
        end

        # ── Locality dimension ──────────────────────────────────────────────

        def in_region(region)
          add_filter { |o| o.region == region }
        end

        def in_zone(zone)
          add_filter { |o| o.zone == zone }
        end

        def proximity_tagged(*tags)
          syms = tags.map(&:to_sym)
          add_filter { |o| syms.all? { |t| o.proximity_tags.include?(t) } }
        end

        # ── Governance dimension ────────────────────────────────────────────

        def governance_trusted
          add_filter { |o| o.governance_trust_status == :trusted }
        end

        # ── Observation quality ─────────────────────────────────────────────

        def fresh(max_seconds: 60)
          add_filter { |o| o.fresh?(max_seconds: max_seconds) }
        end

        def authoritative
          add_filter(&:authoritative?)
        end

        # ── General predicate ───────────────────────────────────────────────

        def where(&block)
          raise ArgumentError, "where requires a block" unless block

          add_filter(&block)
        end

        # ── CapabilityQuery passthrough ────────────────────────────────────

        def matching(query)
          normalized = Igniter::Cluster::Replication::CapabilityQuery.normalize(query)
          add_filter { |o| normalized.matches_profile?(o) }
        end

        # ── Ordering ────────────────────────────────────────────────────────

        def order_by(dimension, direction: :asc)
          raise ArgumentError, "direction must be :asc or :desc" unless %i[asc desc].include?(direction)
          unless ORDERABLE_DIMENSIONS.include?(dimension) || dimension.respond_to?(:call)
            raise ArgumentError, "Unknown ordering dimension: #{dimension.inspect}. " \
                                  "Use one of #{ORDERABLE_DIMENSIONS.inspect} or a Proc."
          end

          clone_query do |q|
            q.instance_variable_set(:@orderings, (@orderings + [{ dimension: dimension, direction: direction }]).freeze)
          end
        end

        # ── Limiting ────────────────────────────────────────────────────────

        def limit(n)
          clone_query { |q| q.instance_variable_set(:@limit_count, n) }
        end

        # ── Execution ───────────────────────────────────────────────────────

        def to_a
          result = @observations.select { |obs| match?(obs) }
          result = apply_orderings(result) unless @orderings.empty?
          @limit_count ? result.first(@limit_count) : result
        end

        def each(&block)
          to_a.each(&block)
        end

        def count
          @observations.count { |obs| match?(obs) }
        end

        def empty?
          !@observations.any? { |obs| match?(obs) }
        end

        def first(n = nil)
          n ? to_a.first(n) : to_a.first
        end

        # Summary of what this query will filter and sort by.
        def explain
          lines = ["ObservationQuery(#{@observations.size} candidates)"]
          lines << "  filters: #{@filters.size}"
          unless @orderings.empty?
            order_desc = @orderings.map { |o| "#{o[:dimension]} #{o[:direction]}" }.join(", ")
            lines << "  order_by: #{order_desc}"
          end
          lines << "  limit: #{@limit_count}" if @limit_count
          lines.join("\n")
        end

        private

        def add_filter(&block)
          clone_query { |q| q.instance_variable_set(:@filters, (@filters + [block]).freeze) }
        end

        def clone_query
          q = self.class.allocate
          q.instance_variable_set(:@observations, @observations)
          q.instance_variable_set(:@filters,      @filters.dup.freeze)
          q.instance_variable_set(:@orderings,    @orderings.dup.freeze)
          q.instance_variable_set(:@limit_count,  @limit_count)
          yield q
          q.freeze
          q
        end

        def match?(obs)
          @filters.all? { |f| f.call(obs) }
        end

        def apply_orderings(observations)
          observations.sort do |a, b|
            comparison = 0
            @orderings.each do |order|
              left  = dimension_value(a, order[:dimension])
              right = dimension_value(b, order[:dimension])
              comparison = compare_values(left, right, order[:direction])
              break unless comparison.zero?
            end
            comparison
          end
        end

        def dimension_value(obs, dimension)
          return dimension.call(obs) if dimension.respond_to?(:call)

          case dimension
          when :load_cpu                then obs.load_cpu
          when :load_memory             then obs.load_memory
          when :concurrency             then obs.concurrency
          when :queue_depth             then obs.queue_depth
          when :confidence              then obs.confidence
          when :hops                    then obs.hops
          when :governance_total        then obs.governance_total
          when :capabilities_freshness  then obs.capabilities_freshness_seconds
          end
        end

        def compare_values(left, right, direction)
          return 0 if left == right
          return (direction == :asc ? 1 : -1) if left.nil?
          return (direction == :asc ? -1 : 1) if right.nil?

          comparison = left <=> right
          direction == :desc ? -comparison : comparison
        end
      end
    end
  end
end
