# frozen_string_literal: true

require "igniter"
require "igniter/core/incremental"

module Igniter
  module Extensions
    # Patches Igniter::Contract with:
    #   - Instance method: resolve_incrementally(new_inputs = {}) → Incremental::Result
    #
    # The method updates inputs, re-resolves, and returns a structured report
    # of which nodes changed, were memoized, or were backdated.
    #
    # Applied globally via:
    #   Igniter::Contract.include(Igniter::Extensions::Incremental)
    #
    module Incremental
      def self.included(base)
        base.include(InstanceMethods)
      end

      module InstanceMethods
        # Update inputs and re-resolve, returning a detailed incremental result.
        #
        # If called without arguments on an already-resolved contract, it
        # re-resolves with current inputs (useful for observing memoization).
        #
        # @param new_inputs [Hash] input values to update before re-resolving
        # @return [Igniter::Incremental::Result]
        def resolve_incrementally(new_inputs = {})
          unless execution.cache.values.any?
            raise Igniter::Incremental::IncrementalError,
                  "Contract has not been executed yet — call resolve_all first, " \
                  "then resolve_incrementally to get incremental results"
          end

          tracker = Igniter::Incremental::Tracker.new(execution)
          tracker.start!

          update_inputs(new_inputs) if new_inputs.any?
          resolve_all

          tracker.build_result
        end
      end
    end
  end
end

Igniter::Contract.include(Igniter::Extensions::Incremental)
