# frozen_string_literal: true

module Igniter
  module Provenance
    # Lineage captures the full provenance of a single contract output.
    #
    # It wraps the NodeTrace tree rooted at the node that produces the output
    # and exposes query methods for understanding what inputs shaped the result.
    #
    # Usage (after `require "igniter/extensions/provenance"`):
    #
    #   contract.resolve_all
    #   lin = contract.lineage(:grand_total)
    #
    #   lin.value                      # => 229.95
    #   lin.contributing_inputs        # => { base_price: 100.0, quantity: 2, ... }
    #   lin.sensitive_to?(:base_price) # => true
    #   lin.sensitive_to?(:user_name)  # => false
    #   lin.path_to(:base_price)       # => [:grand_total, :subtotal, :unit_price, :base_price]
    #   puts lin                        # prints ASCII tree
    #
    class Lineage
      # The NodeTrace rooted at the output's source computation node.
      attr_reader :trace

      def initialize(trace)
        @trace = trace
        freeze
      end

      # The output name (same as the root trace node name).
      def output_name
        trace.name
      end

      # The resolved output value.
      def value
        trace.value
      end

      # All :input nodes that transitively contributed to this output.
      # Returns Hash{ Symbol => value }.
      def contributing_inputs
        trace.contributing_inputs
      end

      # Does this output's value depend (transitively) on the given input?
      def sensitive_to?(input_name)
        trace.sensitive_to?(input_name)
      end

      # Ordered path of node names from the output down to the given input.
      # Returns nil if the input does not contribute to this output.
      def path_to(input_name)
        trace.path_to(input_name)
      end

      # Human-readable ASCII tree explaining how this output was derived.
      def explain
        TextFormatter.format(trace)
      end

      alias to_s explain

      # Structured (serialisable) representation of the full trace tree.
      def to_h
        serialize_trace(trace)
      end

      private

      def serialize_trace(trc)
        {
          node: trc.name,
          kind: trc.kind,
          value: trc.value,
          contributing: trc.contributing.transform_values { |dep| serialize_trace(dep) }
        }
      end
    end
  end
end
