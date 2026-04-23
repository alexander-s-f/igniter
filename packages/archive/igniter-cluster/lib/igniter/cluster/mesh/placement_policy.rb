# frozen_string_literal: true

module Igniter
  module Cluster
    module Mesh
      # Declarative placement constraints applied before multi-dimensional scoring.
      #
      # A PlacementPolicy acts as a hard filter gate — only candidates satisfying
      # all constraints reach the scorer. Soft preferences (zone/region affinity)
      # influence the locality score dimension without hard-excluding nodes unless
      # locality_preference is set to :zone or :region.
      #
      # degraded_fallback: when true, PlacementPlanner re-runs with a fully
      # relaxed policy when the primary candidate set is empty.
      class PlacementPolicy
        LOCALITY_PREFERENCES = %i[zone region any].freeze

        attr_reader :zone, :region,
                    :max_load_cpu, :max_load_memory, :max_concurrency, :max_queue_depth,
                    :require_trust, :require_health,
                    :locality_preference, :degraded_fallback

        def initialize(
          zone: nil,
          region: nil,
          max_load_cpu: nil,
          max_load_memory: nil,
          max_concurrency: nil,
          max_queue_depth: nil,
          require_trust: false,
          require_health: true,
          locality_preference: :any,
          degraded_fallback: false
        )
          lp = locality_preference.to_sym
          unless LOCALITY_PREFERENCES.include?(lp)
            raise ArgumentError, "locality_preference must be one of #{LOCALITY_PREFERENCES.inspect}"
          end

          @zone               = zone
          @region             = region
          @max_load_cpu       = max_load_cpu
          @max_load_memory    = max_load_memory
          @max_concurrency    = max_concurrency
          @max_queue_depth    = max_queue_depth
          @require_trust      = require_trust
          @require_health     = require_health
          @locality_preference = lp
          @degraded_fallback  = degraded_fallback
          freeze
        end

        # Apply hard constraints to an ObservationQuery.
        # Returns a new ObservationQuery with all applicable filters applied.
        def constrain(query)
          q = query
          q = q.healthy                       if @require_health
          q = q.trusted                       if @require_trust
          q = q.max_load_cpu(@max_load_cpu)       if @max_load_cpu
          q = q.max_load_memory(@max_load_memory) if @max_load_memory
          q = q.max_concurrency(@max_concurrency) if @max_concurrency
          q = q.max_queue_depth(@max_queue_depth) if @max_queue_depth
          case @locality_preference
          when :zone   then q = q.in_zone(@zone)     if @zone
          when :region then q = q.in_region(@region) if @region
          end
          q
        end

        # Return a maximally relaxed copy for degraded-mode fallback.
        def relaxed
          self.class.new(
            zone:                nil,
            region:              nil,
            max_load_cpu:        nil,
            max_load_memory:     nil,
            max_concurrency:     nil,
            max_queue_depth:     nil,
            require_trust:       false,
            require_health:      false,
            locality_preference: :any,
            degraded_fallback:   false
          )
        end

        def to_h
          {
            zone:                @zone,
            region:              @region,
            max_load_cpu:        @max_load_cpu,
            max_load_memory:     @max_load_memory,
            max_concurrency:     @max_concurrency,
            max_queue_depth:     @max_queue_depth,
            require_trust:       @require_trust,
            require_health:      @require_health,
            locality_preference: @locality_preference,
            degraded_fallback:   @degraded_fallback
          }
        end
      end
    end
  end
end
