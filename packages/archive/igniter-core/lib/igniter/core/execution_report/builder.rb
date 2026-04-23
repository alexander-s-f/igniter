# frozen_string_literal: true

module Igniter
  module ExecutionReport
    # Builds an ExecutionReport::Report by reading the compiled graph's
    # resolution order and matching each node against the execution cache.
    #
    # Works for both successful and failed executions — nodes that never
    # ran (because a dependency failed) appear with status :pending.
    class Builder
      class << self
        def build(contract)
          new(contract).build
        end
      end

      def initialize(contract)
        @contract = contract
        @graph    = contract.execution.compiled_graph
        @cache    = contract.execution.cache
      end

      def build
        entries = @graph.resolution_order.map { |node| entry_for(node) }
        Report.new(contract_class: @contract.class, entries: entries)
      end

      private

      def entry_for(node) # rubocop:disable Metrics/MethodLength
        state = @cache.fetch(node.name)

        status = if state.nil?
                   :pending
                 elsif state.succeeded?
                   :succeeded
                 elsif state.failed?
                   :failed
                 else
                   :pending
                 end

        NodeEntry.new(
          name: node.name,
          kind: node.kind,
          status: status,
          value: state&.value,
          error: state&.error,
          effect_type: node.respond_to?(:effect_type) ? node.effect_type : nil
        )
      end
    end
  end
end
