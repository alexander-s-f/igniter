# frozen_string_literal: true

require_relative "../../igniter"
require "igniter/core/saga"

module Igniter
  module Extensions
    # Adds saga/compensating-transaction support to all Igniter contracts.
    #
    # Class-level DSL:
    #   compensate :node_name do |inputs:, value:| ... end
    #
    # Instance methods added:
    #   resolve_saga → Igniter::Saga::Result
    #
    # Applied globally via:
    #   Igniter::Contract.include(Igniter::Extensions::Saga)
    #
    module Saga
      def self.included(base)
        base.extend(ClassMethods)
      end

      # ── Class-level DSL ────────────────────────────────────────────────────

      module ClassMethods
        # Declare a compensating action for a compute node.
        #
        # The block is called with:
        #   inputs: — Hash of the node's dependency values
        #   value:  — the value the node produced (now being rolled back)
        #
        # @param node_name [Symbol]
        def compensate(node_name, &block)
          @_compensations ||= {}
          @_compensations[node_name.to_sym] = Igniter::Saga::Compensation.new(node_name, &block)
        end

        # @return [Hash{ Symbol => Compensation }]
        def compensations
          @_compensations || {}
        end
      end

      # ── Instance methods ───────────────────────────────────────────────────

      # Execute the contract and handle compensations on failure.
      #
      # Unlike `resolve_all` (which raises on failure), `resolve_saga`:
      #   - Returns a successful Result when execution completes
      #   - Catches Igniter::Error, runs compensations, returns a failed Result
      #
      # @return [Igniter::Saga::Result]
      def resolve_saga # rubocop:disable Metrics/MethodLength
        resolve_all
        Igniter::Saga::Result.new(success: true, contract: self)
      rescue Igniter::Error => e
        executor = Igniter::Saga::Executor.new(self)
        compensations_ran = executor.run_compensations
        failed_node = executor.failed_node_name

        Igniter::Saga::Result.new(
          success: false,
          contract: self,
          error: e,
          failed_node: failed_node,
          compensations: compensations_ran
        )
      end
    end
  end
end

Igniter::Contract.include(Igniter::Extensions::Saga)
