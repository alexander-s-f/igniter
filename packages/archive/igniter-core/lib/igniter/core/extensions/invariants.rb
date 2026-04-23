# frozen_string_literal: true

require_relative "../contract"
require_relative "../errors"
require_relative "../invariant"

module Igniter
  module Extensions
    # Patches Igniter::Contract with:
    #   - Class method: invariant(name) { |output:, **| condition }
    #   - Instance method: check_invariants -> Array<InvariantViolation>
    #   - Automatic post-execution check in resolve_all (raises InvariantError)
    module Invariants
      def self.included(base)
        base.extend(ClassMethods)
        base.prepend(InstanceMethods)
      end

      module ClassMethods
        def invariant(name, &block)
          @_invariants ||= {}
          @_invariants[name.to_sym] = Igniter::Invariant.new(name, &block)
        end

        def invariants
          @_invariants || {}
        end
      end

      module InstanceMethods
        def resolve_all(...)
          result = super
          validate_invariants! unless Thread.current[:igniter_skip_invariants]
          result
        end

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
