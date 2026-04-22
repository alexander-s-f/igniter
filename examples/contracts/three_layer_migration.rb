#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter"
require "igniter/extensions/contracts"

class LegacyOrderPricingContract < Igniter::Contract
  define do
    input :order
    input :tax_rate, type: :numeric
    input :shipping, type: :numeric
    input :discount, type: :numeric

    compute :items, depends_on: [:order] do |order:|
      order.fetch(:items)
    end

    compute :subtotal, depends_on: [:items] do |items:|
      items.sum { |item| item.fetch(:amount) }
    end

    compute :tax, depends_on: %i[subtotal tax_rate] do |subtotal:, tax_rate:|
      subtotal * tax_rate
    end

    compute :grand_total, depends_on: %i[subtotal tax shipping discount] do |subtotal:, tax:, shipping:, discount:|
      subtotal + tax + shipping - discount
    end

    output :grand_total
  end
end

inputs = {
  order: {
    items: [
      { amount: 10 },
      { amount: 20 }
    ]
  },
  tax_rate: 0.2,
  shipping: 5,
  discount: 3
}.freeze

legacy_contract = LegacyOrderPricingContract.new(**inputs)
legacy_grand_total = legacy_contract.result.grand_total

raw_environment = Igniter::Contracts.with(
  Igniter::Extensions::Contracts::LookupPack,
  Igniter::Extensions::Contracts::AggregatePack
)

raw_result = raw_environment.run(inputs: inputs) do
  input :order
  input :tax_rate
  input :shipping
  input :discount
  lookup :items, from: :order, key: :items
  sum :subtotal, from: :items, using: :amount
  compute :tax, depends_on: %i[subtotal tax_rate] do |subtotal:, tax_rate:|
    subtotal * tax_rate
  end
  compute :grand_total, depends_on: %i[subtotal tax shipping discount] do |subtotal:, tax:, shipping:, discount:|
    subtotal + tax + shipping - discount
  end
  output :grand_total
end

preset_environment = Igniter::Extensions::Contracts.with_preset(:commerce)

preset_result = preset_environment.run(inputs: inputs) do
  input :order
  input :tax_rate
  input :shipping
  input :discount
  order_items from: :order
  subtotal from: :items
  tax_amount amount: :subtotal, rate: :tax_rate
  grand_total subtotal: :subtotal, tax: :tax, shipping: :shipping, discount: :discount
  output :grand_total
end

raw_grand_total = raw_result.output(:grand_total)
preset_grand_total = preset_result.output(:grand_total)

puts "legacy_grand_total=#{legacy_grand_total}"
puts "raw_contracts_grand_total=#{raw_grand_total}"
puts "preset_grand_total=#{preset_grand_total}"
puts "legacy_vs_raw_match=#{legacy_grand_total == raw_grand_total}"
puts "raw_vs_preset_match=#{raw_grand_total == preset_grand_total}"
puts "three_layer_match=#{legacy_grand_total == raw_grand_total && raw_grand_total == preset_grand_total}"
