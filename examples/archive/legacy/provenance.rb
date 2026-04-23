# frozen_string_literal: true

# Provenance — data lineage for Igniter contracts
#
# After a contract resolves, provenance answers:
#   "How was this output computed, and which inputs influenced it?"
#
# Run: ruby examples/provenance.rb

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "igniter"
require "igniter/extensions/provenance"

# ── Contracts ─────────────────────────────────────────────────────────────────

class TierDiscountContract < Igniter::Contract
  TIERS = { bronze: 0, silver: 10, gold: 20, platinum: 30 }.freeze

  define do
    input :user_tier, type: :symbol

    compute :discount_pct, depends_on: :user_tier do |user_tier:|
      TierDiscountContract::TIERS.fetch(user_tier, 0)
    end

    output :discount_pct
  end
end

class PricingContract < Igniter::Contract
  define do
    input :base_price,     type: :numeric
    input :quantity,       type: :numeric
    input :user_tier,      type: :symbol

    compute :unit_price, depends_on: :base_price do |base_price:|
      (base_price * 1.08).round(2) # +8% margin
    end

    compute :subtotal, depends_on: %i[unit_price quantity] do |unit_price:, quantity:|
      (unit_price * quantity).round(2)
    end

    compose :tier_info, contract: TierDiscountContract,
                        inputs: { user_tier: :user_tier }

    compute :discount_amount, depends_on: %i[subtotal tier_info] do |subtotal:, tier_info:|
      (subtotal * tier_info.discount_pct / 100.0).round(2)
    end

    compute :grand_total, depends_on: %i[subtotal discount_amount] do |subtotal:, discount_amount:|
      (subtotal - discount_amount).round(2)
    end

    output :unit_price
    output :subtotal
    output :discount_amount
    output :grand_total
  end
end

# ── Run ───────────────────────────────────────────────────────────────────────

puts "=== Provenance Demo ==="
puts

contract = PricingContract.new(
  base_price: 100.0,
  quantity: 3,
  user_tier: :gold
)
contract.resolve_all

puts "grand_total=#{contract.result.grand_total}"
puts

# ── ASCII tree ────────────────────────────────────────────────────────────────

puts "--- explain(:grand_total) ---"
puts contract.explain(:grand_total)
puts

# ── Query API ─────────────────────────────────────────────────────────────────

lin = contract.lineage(:grand_total)

puts "--- contributing_inputs ---"
lin.contributing_inputs.each do |input_name, val|
  puts "  #{input_name} = #{val.inspect}"
end
puts

puts "--- sensitive_to? ---"
puts "sensitive_to?(:base_price)  = #{lin.sensitive_to?(:base_price)}"
puts "sensitive_to?(:quantity)    = #{lin.sensitive_to?(:quantity)}"
puts "sensitive_to?(:user_tier)   = #{lin.sensitive_to?(:user_tier)}"
puts "sensitive_to?(:unknown_key) = #{lin.sensitive_to?(:unknown_key)}"
puts

puts "--- path_to(:base_price) ---"
puts lin.path_to(:base_price).inspect
puts

puts "--- path_to(:user_tier) ---"
puts lin.path_to(:user_tier).inspect
puts

# ── Composition output lineage ────────────────────────────────────────────────

puts "--- explain(:discount_amount) ---"
puts contract.explain(:discount_amount)
puts

# ── Structured lineage (to_h) ─────────────────────────────────────────────────

puts "--- lineage(:subtotal).to_h (keys only) ---"
h = contract.lineage(:subtotal).to_h
puts "node=#{h[:node]}, kind=#{h[:kind]}, value=#{h[:value]}"
puts "contributing=#{h[:contributing].keys.inspect}"
puts

puts "done=true"
