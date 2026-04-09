# frozen_string_literal: true

module Igniter
  module PropertyTesting
    # Result of a single property-test execution.
    #
    # A run can fail in two ways:
    #   - :execution_error  — the contract raised an error
    #   - :invariant_violation — the contract completed but an invariant was violated
    class Run
      attr_reader :run_number, :inputs, :execution_error, :violations

      def initialize(run_number:, inputs:, execution_error: nil, violations: [])
        @run_number      = run_number
        @inputs          = inputs.freeze
        @execution_error = execution_error
        @violations      = violations.freeze
        freeze
      end

      def passed? = execution_error.nil? && violations.empty?
      def failed? = !passed?

      # @return [Symbol, nil] :execution_error, :invariant_violation, or nil
      def failure_type
        if execution_error
          :execution_error
        elsif violations.any?
          :invariant_violation
        end
      end

      # @return [String, nil]
      def failure_message
        if execution_error
          execution_error.message
        elsif violations.any?
          violations.map { |v| ":#{v.name} violated" }.join(", ")
        end
      end
    end
  end
end
