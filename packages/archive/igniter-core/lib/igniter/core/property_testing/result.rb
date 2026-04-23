# frozen_string_literal: true

module Igniter
  module PropertyTesting
    # Aggregated result of a full property-test run.
    class Result
      attr_reader :contract_class, :total_runs, :runs

      def initialize(contract_class:, total_runs:, runs:)
        @contract_class = contract_class
        @total_runs     = total_runs
        @runs           = runs.freeze
      end

      def passed?     = failed_runs.empty?
      def failed_runs = runs.select(&:failed?)
      def passed_runs = runs.select(&:passed?)

      # The first failing run — the counterexample to inspect and debug.
      # nil when all runs passed.
      #
      # @return [Run, nil]
      def counterexample = failed_runs.first

      # @return [String]
      def explain = Formatter.new(self).render

      # @return [Hash]
      def to_h # rubocop:disable Metrics/MethodLength
        {
          contract: contract_class.name,
          total_runs: total_runs,
          passed: passed_runs.size,
          failed: failed_runs.size,
          passed?: passed?,
          counterexample: counterexample && {
            run_number: counterexample.run_number,
            inputs: counterexample.inputs,
            failure: counterexample.failure_message
          }
        }
      end
    end
  end
end
