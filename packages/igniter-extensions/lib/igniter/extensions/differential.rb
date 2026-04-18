# frozen_string_literal: true

require "igniter"
require "igniter/core/differential"

module Igniter
  module Extensions
    # Patches Igniter::Contract with:
    #   - Class method: shadow_with(candidate, async:, on_divergence:, tolerance:)
    #   - Instance method: diff_against(candidate_class, tolerance:)
    #   - Automatic shadow execution after resolve_all (when shadow_with is declared)
    #
    # This module is applied globally via:
    #   Igniter::Contract.include(Igniter::Extensions::Differential)
    #
    module Differential
      def self.included(base)
        base.extend(ClassMethods)
        base.prepend(InstanceMethods)
      end

      # ── Class-level DSL ────────────────────────────────────────────────────

      module ClassMethods
        # Declare a shadow candidate that runs alongside every resolve_all call.
        #
        # @param candidate_class [Class<Igniter::Contract>]
        # @param async [Boolean]  run the shadow in a background Thread
        # @param on_divergence [#call, nil] invoked with a Report when outputs differ
        # @param tolerance [Numeric, nil]  passed to the differential runner
        def shadow_with(candidate_class, async: false, on_divergence: nil, tolerance: nil)
          @_shadow_candidate = candidate_class
          @_shadow_async = async
          @_shadow_on_divergence = on_divergence
          @_shadow_tolerance = tolerance
        end

        def shadow_candidate = @_shadow_candidate
        def shadow_async? = @_shadow_async || false
        def shadow_on_divergence = @_shadow_on_divergence
        def shadow_tolerance = @_shadow_tolerance
      end

      # ── Instance override + new public method ─────────────────────────────

      module InstanceMethods
        # Intercepts resolve_all to trigger shadow execution when shadow_with
        # has been declared.  Uses a thread-local flag to prevent recursive
        # shadow calls when the runner itself invokes resolve_all internally.
        def resolve_all(...)
          result = super
          run_shadow unless Thread.current[:igniter_skip_shadow]
          result
        end

        # Compare the already-executed primary contract against +candidate_class+.
        # Avoids re-running the primary (reads outputs from the existing cache).
        #
        # Raises DifferentialError if resolve_all has not been called yet.
        #
        # @return [Igniter::Differential::Report]
        def diff_against(candidate_class, tolerance: nil)
          unless execution.cache.values.any?
            raise Igniter::Differential::DifferentialError,
                  "Contract has not been executed — call resolve_all first"
          end

          inputs = extract_inputs_from_execution
          runner = Igniter::Differential::Runner.new(self.class, candidate_class, tolerance: tolerance)
          runner.run_with_primary_execution(execution, inputs)
        end

        private

        def run_shadow # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          candidate = self.class.shadow_candidate
          return unless candidate

          on_divergence = self.class.shadow_on_divergence
          tolerance = self.class.shadow_tolerance
          inputs = extract_inputs_from_execution

          task = lambda do
            runner = Igniter::Differential::Runner.new(self.class, candidate, tolerance: tolerance)
            report = runner.run_with_primary_execution(execution, inputs)
            on_divergence.call(report) if on_divergence && !report.match?
          end

          if self.class.shadow_async?
            Thread.new { task.call }
          else
            task.call
          end
        end

        # Reads input node values from the resolved cache for re-use in
        # secondary executions (shadow / diff_against).
        def extract_inputs_from_execution
          graph = execution.compiled_graph
          cache = execution.cache

          graph.nodes.each_with_object({}) do |node, acc|
            next unless node.kind == :input

            state = cache.fetch(node.name)
            acc[node.name] = state&.value
          end
        end
      end
    end
  end
end

Igniter::Contract.include(Igniter::Extensions::Differential)
