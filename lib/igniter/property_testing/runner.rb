# frozen_string_literal: true

module Igniter
  module PropertyTesting
    # Executes a contract repeatedly with random inputs and collects run results.
    #
    # Invariant violations are captured as data (not exceptions) using the
    # Thread.current[:igniter_skip_invariants] flag, which prevents the
    # automatic raise in resolve_all.
    class Runner
      def initialize(contract_class, generators:, runs: 100, seed: nil)
        @contract_class = contract_class
        @generators     = generators
        @total_runs     = runs
        @seed           = seed
      end

      # @return [Result]
      def run
        Random.srand(@seed) if @seed

        runs = (1..@total_runs).map { |n| execute_run(n) }
        Result.new(contract_class: @contract_class, total_runs: @total_runs, runs: runs)
      end

      private

      def execute_run(run_number)
        inputs   = generate_inputs
        contract = @contract_class.new(**inputs)

        Thread.current[:igniter_skip_invariants] = true
        contract.resolve_all
        violations = contract.check_invariants
        Run.new(run_number: run_number, inputs: inputs, violations: violations)
      rescue StandardError => e
        Run.new(run_number: run_number, inputs: inputs, execution_error: e)
      ensure
        Thread.current[:igniter_skip_invariants] = false
      end

      def generate_inputs
        @generators.transform_values(&:call)
      end
    end
  end
end
