# frozen_string_literal: true

module Igniter
  module Saga
    # Declares the compensating action for a named compute node.
    #
    # The block is called with keyword arguments:
    #   inputs: Hash{ Symbol => value }  — dependency values the node consumed
    #   value:  Object                   — the value the node produced
    #
    # Example:
    #   compensate :charge_card do |inputs:, value:|
    #     PaymentService.refund(value[:charge_id])
    #   end
    class Compensation
      attr_reader :node_name, :block

      def initialize(node_name, &block)
        raise ArgumentError, "compensate :#{node_name} requires a block" unless block

        @node_name = node_name.to_sym
        @block = block
        freeze
      end

      def run(inputs:, value:)
        block.call(inputs: inputs, value: value)
      end
    end
  end
end
