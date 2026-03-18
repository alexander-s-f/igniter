# frozen_string_literal: true

module Igniter
  module Runtime
    class Result
      attr_reader :execution

      def initialize(execution)
        @execution = execution
        define_output_readers!
      end

      def to_h
        @execution.compiled_graph.outputs.each_with_object({}) do |output_node, memo|
          memo[output_node.name] = serialize_value(public_send(output_node.name))
        end
      end

      def success?
        @execution.resolve_all
        !failed?
      end

      def failed?
        @execution.resolve_all
        @execution.cache.values.any?(&:failed?)
      end

      def errors
        @execution.resolve_all
        @execution.cache.values.each_with_object({}) do |state, memo|
          next unless state.failed?

          memo[state.node.name] = state.error
        end
      end

      def states
        @execution.resolve_all
        @execution.states
      end

      def explain(output_name)
        @execution.resolve_output(output_name)
        @execution.explain_output(output_name)
      end

      private

      def define_output_readers!
        @execution.compiled_graph.outputs.each do |output_node|
          define_singleton_method(output_node.name) do
            @execution.resolve_output(output_node.name)
          end
        end
      end

      def serialize_value(value)
        case value
        when Result
          value.to_h
        when Array
          value.map { |item| serialize_value(item) }
        else
          value
        end
      end
    end
  end
end
