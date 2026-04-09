# frozen_string_literal: true

# Differential Execution — compare two contract implementations output-by-output.
#
# Use cases:
#   * Validate a refactored contract produces the same results
#   * Run a shadow/canary contract alongside production, catching divergences
#   * A/B test alternative business-rule implementations
#
# Run: ruby examples/differential.rb

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "igniter"
require "igniter/extensions/differential"

# ── Contracts ─────────────────────────────────────────────────────────────────

# V1 — production contract (10% tax, no discount)
class PricingV1 < Igniter::Contract
  define do
    input :price,    type: :numeric
    input :quantity, type: :numeric

    compute :subtotal, depends_on: %i[price quantity] do |price:, quantity:|
      (price * quantity).round(2)
    end

    compute :tax, depends_on: :subtotal do |subtotal:|
      (subtotal * 0.10).round(2)
    end

    compute :total, depends_on: %i[subtotal tax] do |subtotal:, tax:|
      subtotal + tax
    end

    output :subtotal
    output :tax
    output :total
  end
end

# V2 — candidate contract (15% tax + volume discount)
class PricingV2 < Igniter::Contract
  define do
    input :price,    type: :numeric
    input :quantity, type: :numeric

    compute :subtotal, depends_on: %i[price quantity] do |price:, quantity:|
      (price * quantity).round(2)
    end

    compute :tax, depends_on: :subtotal do |subtotal:|
      (subtotal * 0.15).round(2) # higher rate
    end

    compute :discount, depends_on: :subtotal do |subtotal:|
      subtotal > 100 ? 10.0 : 0.0
    end

    compute :total, depends_on: %i[subtotal tax discount] do |subtotal:, tax:, discount:|
      (subtotal + tax - discount).round(2)
    end

    output :subtotal
    output :tax
    output :discount # new output — absent in V1
    output :total
  end
end

puts "=== Differential Execution Demo ==="
puts

# ── 1. Standalone comparison ───────────────────────────────────────────────────

puts "--- Igniter::Differential.compare ---"
report = Igniter::Differential.compare(
  primary: PricingV1,
  candidate: PricingV2,
  inputs: { price: 50.0, quantity: 3 }
)
puts report.explain
puts

# ── 2. Numeric tolerance ───────────────────────────────────────────────────────

puts "--- compare with tolerance: 10.0 ---"
report_tol = Igniter::Differential.compare(
  primary: PricingV1,
  candidate: PricingV2,
  inputs: { price: 50.0, quantity: 3 },
  tolerance: 10.0
)
puts "tax within tolerance? #{report_tol.divergences.none? { |d| d.output_name == :tax }}"
puts

# ── 3. Instance diff_against ───────────────────────────────────────────────────

puts "--- contract.diff_against(PricingV2) ---"
contract = PricingV1.new(price: 50.0, quantity: 3)
contract.resolve_all
report2 = contract.diff_against(PricingV2)
puts "match?      = #{report2.match?}"
puts "diverged:   #{report2.divergences.map(&:output_name).inspect}"
puts "cand. only: #{report2.candidate_only.keys.inspect}"
puts

# ── 4. Query API on Report ─────────────────────────────────────────────────────

puts "--- Report query API ---"
report.divergences.each do |div|
  puts "  #{div.output_name}: #{div.primary_value} → #{div.candidate_value}  (delta: #{div.delta})"
end
puts "summary: #{report.summary}"
puts

# ── 5. Shadow mode ─────────────────────────────────────────────────────────────

puts "--- shadow_with (sync) ---"

class PricingWithShadow < Igniter::Contract
  shadow_with PricingV2, on_divergence: ->(r) { puts "  [shadow] #{r.summary}" }
  define do
    input :price,    type: :numeric
    input :quantity, type: :numeric

    compute :subtotal, depends_on: %i[price quantity] do |price:, quantity:|
      (price * quantity).round(2)
    end

    compute :tax, depends_on: :subtotal do |subtotal:|
      (subtotal * 0.10).round(2)
    end

    compute :total, depends_on: %i[subtotal tax] do |subtotal:, tax:|
      subtotal + tax
    end

    output :subtotal
    output :tax
    output :total
  end
end

shadow_contract = PricingWithShadow.new(price: 50.0, quantity: 3)
shadow_contract.resolve_all # shadow runs automatically
puts "primary total = #{shadow_contract.result.total}"
puts

# ── 6. Matching contracts ──────────────────────────────────────────────────────

puts "--- identical contracts match ---"
matching = Igniter::Differential.compare(
  primary: PricingV1,
  candidate: PricingV1,
  inputs: { price: 50.0, quantity: 3 }
)
puts "match? = #{matching.match?}"
puts

puts "done=true"
