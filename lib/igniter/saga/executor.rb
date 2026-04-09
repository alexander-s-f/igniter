# frozen_string_literal: true

module Igniter
  module Saga
    # Runs declared compensations for all successfully completed nodes,
    # in reverse topological order.
    #
    # A node is eligible for compensation if:
    #   1. Its state in the cache is `succeeded?`
    #   2. A compensation is declared for it, via one of:
    #      a. Contract-level `compensate :node_name do ... end`  (takes precedence)
    #      b. Built-in compensation defined on the Igniter::Effect adapter class
    #
    # Compensation failures are captured as failed CompensationRecords and
    # do NOT halt the rollback of other nodes.
    class Executor
      def initialize(contract)
        @contract = contract
        @graph    = contract.execution.compiled_graph
        @cache    = contract.execution.cache
      end

      # @return [Array<CompensationRecord>]
      def run_compensations
        eligible_nodes_reversed.filter_map do |node|
          compensation = find_compensation(node)
          next unless compensation

          attempt(compensation, node)
        end
      end

      # Find the first node whose state is :failed in the cache.
      # @return [Symbol, nil]
      def failed_node_name
        @cache.to_h.find { |_name, state| state.failed? }&.first
      end

      private

      # Resolve the compensation to use for a node, if any.
      #
      # Contract-level `compensate :node_name` takes precedence over built-in
      # compensation declared on an Igniter::Effect subclass.
      #
      # @return [Igniter::Saga::Compensation, nil]
      def find_compensation(node)
        declared = @contract.class.compensations
        return declared[node.name] if declared.key?(node.name)

        return nil unless node.kind == :effect

        built_in = node.adapter_class.built_in_compensation
        return nil unless built_in

        Compensation.new(node.name, &built_in)
      end

      # Nodes that succeeded, in reverse resolution order.
      def eligible_nodes_reversed
        @graph.resolution_order
              .select { |node| @cache.fetch(node.name)&.succeeded? }
              .reverse
      end

      def attempt(compensation, node)
        inputs = extract_inputs(node)
        value  = @cache.fetch(node.name)&.value

        compensation.run(inputs: inputs, value: value)
        CompensationRecord.new(node_name: compensation.node_name, success: true)
      rescue StandardError => e
        CompensationRecord.new(node_name: compensation.node_name, success: false, error: e)
      end

      # Gather the resolved values of the node's direct dependencies.
      def extract_inputs(node)
        node.dependencies.each_with_object({}) do |dep_name, acc|
          state = @cache.fetch(dep_name)
          acc[dep_name.to_sym] = state&.value
        end
      end
    end
  end
end
