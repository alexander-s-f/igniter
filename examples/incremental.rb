# frozen_string_literal: true

# examples/incremental.rb
#
# Demonstrates Igniter's incremental computation: only the minimal set of
# nodes is re-executed when inputs change.
#
# Inspired by Salsa (Rust, rust-analyzer) and Adapton.
#
# Run with: bundle exec ruby examples/incremental.rb

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "igniter"
require "igniter/extensions/incremental"

# ─── Contract ──────────────────────────────────────────────────────────────
#
#   base_price ──┐
#                ├→ adjusted_price ──┐
#   user_tier ──→ tier_discount ──┘   ├→ converted_price
#                                     │
#   exchange_rate ────────────────────┘
#
# When only exchange_rate changes:
#   ✓ tier_discount   → SKIPPED (doesn't depend on exchange_rate)
#   ✓ adjusted_price  → SKIPPED (doesn't depend on exchange_rate)
#   ✓ converted_price → RECOMPUTED (directly depends on exchange_rate)
#
class PricingContract < Igniter::Contract
  define do
    input :base_price
    input :user_tier
    input :exchange_rate

    compute :tier_discount, depends_on: :user_tier, call: lambda { |user_tier:|
      case user_tier
      when "gold"     then 0.20
      when "silver"   then 0.10
      else                 0.0
      end
    }

    compute :adjusted_price, depends_on: %i[base_price tier_discount], call: lambda { |base_price:, tier_discount:|
      base_price * (1.0 - tier_discount)
    }

    compute :converted_price, depends_on: %i[adjusted_price exchange_rate], call: lambda { |adjusted_price:, exchange_rate:|
      (adjusted_price * exchange_rate).round(2)
    }

    output :tier_discount
    output :adjusted_price
    output :converted_price
  end
end

# ─── Helper to show node value_versions ────────────────────────────────────
def show_versions(contract, label)
  puts "\n#{label}"
  puts "-" * 50
  %i[base_price user_tier exchange_rate tier_discount adjusted_price converted_price].each do |name|
    node_name = name
    state = contract.execution.cache.fetch(node_name)
    next unless state

    status = state.status
    vv     = state.value_version
    val    = state.value
    mark   = case status
             when :stale     then "~"
             when :succeeded then "✓"
             else                 " "
             end
    puts "  #{mark} :#{name.to_s.ljust(20)} val=#{val.inspect.ljust(10)} vv=#{vv}"
  end
end

# ─── Run ───────────────────────────────────────────────────────────────────
puts "=" * 60
puts "Igniter Incremental Computation Demo"
puts "=" * 60

contract = PricingContract.new(
  base_price: 100.0,
  user_tier: "gold",
  exchange_rate: 1.0
)

contract.resolve_all
show_versions(contract, "After initial resolve_all")

puts "\n" + "=" * 60
puts "Scenario 1: exchange_rate changes 1.0 → 1.12"
puts "(tier_discount and adjusted_price should be SKIPPED)"
puts "=" * 60

result = contract.resolve_incrementally(exchange_rate: 1.12)

show_versions(contract, "After resolve_incrementally(exchange_rate: 1.12)")
puts "\nIncrementalResult:"
puts result.explain

puts "\nKey assertions:"
puts "  Skipped nodes:  #{result.skipped_nodes.inspect}"
puts "  Backdated:      #{result.backdated_nodes.inspect}"
puts "  Changed:        #{result.changed_nodes.inspect}"
puts "  Recomputed:     #{result.recomputed_count}"
puts "  Changed output: converted_price #{result.changed_outputs[:converted_price]&.values_at(:from, :to)&.join(" → ")}"

puts "\n" + "=" * 60
puts "Scenario 2: user_tier changes gold → silver"
puts "(tier_discount, adjusted_price, converted_price all recompute)"
puts "=" * 60

result2 = contract.resolve_incrementally(user_tier: "silver")
show_versions(contract, "After resolve_incrementally(user_tier: 'silver')")
puts "\nIncrementalResult:"
puts result2.explain

puts "\n" + "=" * 60
puts "Scenario 3: same exchange_rate again (no change)"
puts "(fully memoized — nothing recomputes)"
puts "=" * 60

result3 = contract.resolve_incrementally(exchange_rate: 1.12)
puts "\nIncrementalResult:"
puts result3.explain
puts "\nfully_memoized? #{result3.fully_memoized?}"
puts "outputs_changed? #{result3.outputs_changed?}"

puts "\n" + "=" * 60
puts "Scenario 4: base_price changes 100 → 100 (same value)"
puts "(demonstrates value-equality backdating in adjusted_price)"
puts "=" * 60

contract2 = PricingContract.new(base_price: 100.0, user_tier: "gold", exchange_rate: 1.0)
contract2.resolve_all

# Now change base_price to the same value — cache.write sees same value → value_version stays
result4 = contract2.resolve_incrementally(base_price: 100.0)
puts "\nIncrementalResult:"
puts result4.explain
puts "outputs_changed? #{result4.outputs_changed?}"
