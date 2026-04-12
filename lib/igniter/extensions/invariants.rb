# frozen_string_literal: true

require_relative "../../igniter"
require_relative "../core/invariant"

module Igniter
  module Extensions
    # Patches Igniter::Contract with:
    #   - Class method: invariant(name) { |output:, **| condition }
    #   - Instance method: check_invariants → Array<InvariantViolation>
    #   - Automatic post-execution check in resolve_all (raises InvariantError)
    #
    # Invariant blocks receive ONLY the contract's declared output values as
    # keyword args — the stable public interface, independent of internal nodes.
    # Use ** to absorb outputs you don't need.
    #
    # @example
    #   class PricingContract < Igniter::Contract
    #     define do
    #       input  :price
    #       input  :quantity
    #       compute :total, depends_on: %i[price quantity] do |price:, quantity:|
    #         price * quantity
    #       end
    #       output :total
    #     end
    #
    #     invariant(:total_non_negative) { |total:, **| total >= 0 }
    #   end
    #
    # This module is applied globally via:
    #   Igniter::Contract.include(Igniter::Extensions::Invariants)
    #
    module Invariants
      def self.included(base)
        base.extend(ClassMethods)
        base.prepend(InstanceMethods)
      end

      # ── Class-level DSL ──────────────────────────────────────────────────────

      module ClassMethods
        # Declare a condition that must always hold after successful execution.
        #
        # The block receives the contract's declared output values as keyword
        # arguments; use ** to absorb outputs you don't care about. Return a
        # truthy value to indicate the invariant holds, falsy to indicate
        # a violation.
        #
        # @example
        #   invariant(:positive_total) { |total:, **| total >= 0 }
        #
        # @param name [Symbol]
        def invariant(name, &block)
          @_invariants ||= {}
          @_invariants[name.to_sym] = Igniter::Invariant.new(name, &block)
        end

        # @return [Hash{Symbol => Igniter::Invariant}]
        def invariants
          @_invariants || {}
        end
      end

      # ── Instance override + new public method ───────────────────────────────

      module InstanceMethods
        # Intercepts resolve_all to run invariant checks after execution.
        # Uses a thread-local flag so that property testing can disable the
        # automatic raise and collect violations as data instead.
        def resolve_all(...)
          result = super
          validate_invariants! unless Thread.current[:igniter_skip_invariants]
          result
        end

        # Run all invariants without raising. Returns violations as data.
        # Safe to call at any time after execution.
        #
        # @return [Array<Igniter::InvariantViolation>]
        def check_invariants
          return [] if self.class.invariants.empty?

          resolved = collect_output_values
          self.class.invariants.values.filter_map { |inv| inv.check(resolved) }
        end

        private

        def validate_invariants!
          violations = check_invariants
          return if violations.empty?

          names = violations.map { |v| ":#{v.name}" }.join(", ")
          raise Igniter::InvariantError.new(
            "#{violations.size} invariant(s) violated: #{names}",
            violations: violations,
            context: { contract: self.class.name }
          )
        end

        # Collect all declared output values from the resolved cache.
        # Keyed by output name (not source node name).
        def collect_output_values
          cache = execution.cache
          execution.compiled_graph.outputs.each_with_object({}) do |output_node, acc|
            state = cache.fetch(output_node.source_root)
            acc[output_node.name] = state.value if state&.succeeded?
          end
        end
      end
    end
  end
end

Igniter::Contract.include(Igniter::Extensions::Invariants)
