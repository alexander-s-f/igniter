#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

environment = Igniter::Extensions::Contracts.with(Igniter::Extensions::Contracts::IncrementalPack)

session = Igniter::Extensions::Contracts.build_incremental_session(environment) do
  input :base_price
  input :user_tier
  input :exchange_rate

  compute :tier_discount, depends_on: [:user_tier] do |user_tier:|
    case user_tier
    when "gold" then 0.20
    when "silver" then 0.10
    else 0.0
    end
  end

  compute :adjusted_price, depends_on: %i[base_price tier_discount] do |base_price:, tier_discount:|
    base_price * (1.0 - tier_discount)
  end

  compute :converted_price, depends_on: %i[adjusted_price exchange_rate] do |adjusted_price:, exchange_rate:|
    (adjusted_price * exchange_rate).round(2)
  end

  output :converted_price
end

session.run(inputs: { base_price: 100.0, user_tier: "gold", exchange_rate: 1.0 })
result = session.run(inputs: { base_price: 100.0, user_tier: "gold", exchange_rate: 1.12 })

puts "contracts_incremental_output=#{result.output(:converted_price)}"
puts "contracts_incremental_skipped=#{result.skipped_nodes.inspect}"
puts "contracts_incremental_changed_outputs=#{result.changed_outputs.inspect}"
puts "contracts_incremental_recomputed=#{result.recomputed_count}"
puts "---"
puts result.explain
