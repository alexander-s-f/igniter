# frozen_string_literal: true

require_relative "../../igniter"
require_relative "../extensions/invariants"
require_relative "property_testing/generators"
require_relative "property_testing/run"
require_relative "property_testing/result"
require_relative "property_testing/formatter"
require_relative "property_testing/runner"

module Igniter
  # Property-based testing for Igniter contracts.
  #
  # Generates hundreds of random inputs, runs the contract with each set,
  # and verifies that all declared invariants hold. Violations are collected
  # as data so you can inspect the first counterexample.
  #
  # @example
  #   require "igniter/core/property_testing"
  #
  #   G = Igniter::PropertyTesting::Generators
  #
  #   class PricingContract < Igniter::Contract
  #     define do
  #       input  :price
  #       input  :quantity
  #       compute :total, depends_on: %i[price quantity] do |price:, quantity:|
  #         price * quantity
  #       end
  #       output :total
  #     end
  #
  #     invariant(:total_non_negative) { |total:, **| total >= 0 }
  #   end
  #
  #   result = PricingContract.property_test(
  #     generators: { price: G.float(0.0..500.0), quantity: G.positive_integer(max: 100) },
  #     runs: 200,
  #     seed: 42
  #   )
  #
  #   puts result.explain
  #   puts result.counterexample&.inputs
  #
  module PropertyTesting
    # Class methods added to every Igniter::Contract subclass.
    module ClassMethods
      # Run the contract against randomly generated inputs and verify invariants.
      #
      # Requires at least one `invariant` to be declared on the contract class,
      # though it will still execute and collect execution errors without any.
      #
      # @param generators [Hash{Symbol => #call}] input name → generator callable
      # @param runs [Integer] number of test runs (default: 100)
      # @param seed [Integer, nil] optional RNG seed for reproducibility
      # @return [Igniter::PropertyTesting::Result]
      def property_test(generators:, runs: 100, seed: nil)
        Runner.new(self, generators: generators, runs: runs, seed: seed).run
      end
    end
  end
end

Igniter::Contract.extend(Igniter::PropertyTesting::ClassMethods)
