# frozen_string_literal: true

# examples/invariants.rb
#
# Demonstrates Igniter Invariants and Property Testing — declare conditions
# that must always hold for a contract's outputs, then verify them against
# hundreds of randomly generated inputs.
#
# Run with: bundle exec ruby examples/invariants.rb

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "igniter"
require "igniter/extensions/invariants"
require "igniter/core/property_testing"

# ── 1. Define a contract with invariants ──────────────────────────────────────

class PricingContract < Igniter::Contract
  define do
    input :price
    input :quantity

    compute :subtotal, depends_on: %i[price quantity] do |price:, quantity:|
      price * quantity
    end

    compute :discount, depends_on: :subtotal do |subtotal:|
      subtotal > 100 ? subtotal * 0.1 : 0.0
    end

    compute :total, depends_on: %i[subtotal discount] do |subtotal:, discount:|
      subtotal - discount
    end

    output :total
    output :subtotal
    output :discount
  end

  # Block receives only declared output values as keyword args.
  # Use ** to absorb outputs you don't need to check.
  invariant(:total_non_negative)    { |total:, **|             total >= 0 }
  invariant(:discount_non_negative) { |discount:, **|          discount >= 0 }
  invariant(:total_le_subtotal)     { |total:, subtotal:, **|  total <= subtotal }
end

# ── 2. Happy path — invariants pass ───────────────────────────────────────────

puts "=" * 60
puts "HAPPY PATH — invariants pass"
puts "=" * 60
puts

contract = PricingContract.new(price: 20.0, quantity: 10)
contract.resolve_all

puts "  total:    #{contract.result.total}"
puts "  subtotal: #{contract.result.subtotal}"
puts "  discount: #{contract.result.discount}"
puts
puts "  check_invariants: #{contract.check_invariants.inspect}"
puts

# ── 3. Manual violation check — does not raise ───────────────────────────────

puts "=" * 60
puts "MANUAL CHECK — does not raise, returns violations"
puts "=" * 60
puts

class NegativePriceContract < Igniter::Contract
  define do
    input :price
    input :quantity
    compute :total, depends_on: %i[price quantity] do |price:, quantity:|
      price * quantity # can be negative if price < 0
    end
    output :total
  end

  invariant(:total_non_negative) { |total:, **| total >= 0 }
end

c = NegativePriceContract.new(price: -5.0, quantity: 3)

# Disable auto-raise to inspect violations manually
Thread.current[:igniter_skip_invariants] = true
c.resolve_all
Thread.current[:igniter_skip_invariants] = false

violations = c.check_invariants
puts "  violations: #{violations.map(&:name).inspect}"
puts "  total: #{c.result.total}"
puts

# ── 4. Automatic raise on violation ───────────────────────────────────────────

puts "=" * 60
puts "AUTO-RAISE — resolve_all raises InvariantError"
puts "=" * 60
puts

begin
  NegativePriceContract.new(price: -5.0, quantity: 3).resolve_all
rescue Igniter::InvariantError => e
  puts "  Caught InvariantError: #{e.message}"
  puts "  violations: #{e.violations.map(&:name).inspect}"
end
puts

# ── 5. Property testing — all inputs valid ────────────────────────────────────

puts "=" * 60
puts "PROPERTY TEST — PricingContract with valid inputs"
puts "=" * 60
puts

G = Igniter::PropertyTesting::Generators

result = PricingContract.property_test(
  generators: {
    price: G.float(0.0..500.0),
    quantity: G.positive_integer(max: 100)
  },
  runs: 200,
  seed: 42
)

puts result.explain
puts

# ── 6. Property testing — finds a counterexample ─────────────────────────────

puts "=" * 60
puts "PROPERTY TEST — NegativePriceContract with unconstrained inputs"
puts "=" * 60
puts

failing_result = NegativePriceContract.property_test(
  generators: {
    price: G.float(-100.0..100.0), # can be negative!
    quantity: G.positive_integer(max: 10)
  },
  runs: 100,
  seed: 1
)

puts failing_result.explain
puts
puts "  First counterexample inputs: #{failing_result.counterexample&.inputs.inspect}"
puts

# ── 7. Property testing — execution errors captured ──────────────────────────

puts "=" * 60
puts "PROPERTY TEST — execution errors captured as failed runs"
puts "=" * 60
puts

class FragileContract < Igniter::Contract
  define do
    input :value
    compute :result, depends_on: :value do |value:|
      raise ArgumentError, "value must be positive" if value <= 0

      Math.sqrt(value)
    end
    output :result
  end

  invariant(:result_non_negative) { |result:, **| result >= 0 }
end

fragile_result = FragileContract.property_test(
  generators: { value: G.integer(min: -10, max: 10) },
  runs: 50,
  seed: 7
)

puts fragile_result.explain
