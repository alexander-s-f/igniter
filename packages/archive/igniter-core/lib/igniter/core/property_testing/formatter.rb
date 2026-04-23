# frozen_string_literal: true

module Igniter
  module PropertyTesting
    # Renders a property-test Result as a human-readable ASCII report.
    class Formatter
      PASS_LABEL = "PASS"
      FAIL_LABEL = "FAIL"

      def initialize(result)
        @result = result
      end

      def render # rubocop:disable Metrics/MethodLength
        lines = []
        lines << header
        lines << summary_line
        lines << ""

        if @result.passed?
          lines << "  All #{@result.total_runs} runs passed."
        else
          lines << counterexample_section
          lines << ""
          lines << failed_runs_section
        end

        lines.join("\n")
      end

      private

      def header
        label = @result.passed? ? PASS_LABEL : FAIL_LABEL
        "PropertyTest: #{@result.contract_class.name}  [#{label}]"
      end

      def summary_line
        "Runs: #{@result.total_runs} | " \
          "Passed: #{@result.passed_runs.size} | " \
          "Failed: #{@result.failed_runs.size}"
      end

      def counterexample_section
        cx = @result.counterexample
        return "" unless cx

        [
          "COUNTEREXAMPLE (run ##{cx.run_number}):",
          "  Inputs:  #{cx.inputs.inspect}",
          "  Failure: #{cx.failure_message}"
        ].join("\n")
      end

      def failed_runs_section
        return "" if @result.failed_runs.empty?

        lines = ["FAILED RUNS:"]
        @result.failed_runs.each do |run|
          lines << "  ##{run.run_number.to_s.ljust(5)} #{run.failure_message.ljust(40)} inputs: #{run.inputs.inspect}"
        end
        lines.join("\n")
      end
    end
  end
end
