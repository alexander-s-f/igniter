#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

environment = Igniter::Contracts.with(
  Igniter::Extensions::Contracts::LookupPack,
  Igniter::Extensions::Contracts::AggregatePack
)

result = environment.run(inputs: {
  order: {
    items: [
      { amount: 10, taxable: true },
      { amount: 20, taxable: false },
      { amount: 30, taxable: true }
    ]
  }
}) do
  input :order
  lookup :items, from: :order, key: :items
  count :item_count, from: :items
  count :taxable_count, from: :items, matching: ->(item) { item.fetch(:taxable) }
  sum :total_amount, from: :items, using: :amount
  avg :average_amount, from: :items, using: :amount
  output :item_count
  output :taxable_count
  output :total_amount
  output :average_amount
end

puts "aggregate_item_count=#{result.output(:item_count)}"
puts "aggregate_taxable_count=#{result.output(:taxable_count)}"
puts "aggregate_total_amount=#{result.output(:total_amount)}"
puts "aggregate_average_amount=#{result.output(:average_amount)}"
