# frozen_string_literal: true

module Igniter
  module Differential
    # Captures a single output that differed between primary and candidate.
    class Divergence
      attr_reader :output_name, :primary_value, :candidate_value, :kind

      # @param output_name [Symbol]
      # @param primary_value [Object]
      # @param candidate_value [Object]
      # @param kind [Symbol] :value_mismatch | :type_mismatch
      def initialize(output_name:, primary_value:, candidate_value:, kind:)
        @output_name = output_name
        @primary_value = primary_value
        @candidate_value = candidate_value
        @kind = kind
        freeze
      end

      # Numeric difference (candidate − primary). nil for non-numeric values.
      def delta
        return nil unless primary_value.is_a?(Numeric) && candidate_value.is_a?(Numeric)

        candidate_value - primary_value
      end
    end
  end
end
