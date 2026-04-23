#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

environment = Igniter::Contracts.with(Igniter::Extensions::Contracts::CollectionPack)

result = environment.run(inputs: {
  items: [
    { sku: "a", amount: 10 },
    { sku: "b", amount: 20 }
  ],
  tax_rate: 0.2
}) do
  input :items
  input :tax_rate

  collection :priced_items, from: :items, key: :sku, inputs: { tax_rate: :tax_rate } do
    input :sku
    input :amount
    input :tax_rate

    compute :total, depends_on: %i[amount tax_rate] do |amount:, tax_rate:|
      amount + (amount * tax_rate)
    end

    output :total
  end

  compute :grand_total, depends_on: [:priced_items] do |priced_items:|
    priced_items.values.sum { |item| item.output(:total) }
  end

  output :priced_items
  output :grand_total
end

puts "contracts_collection_total=#{result.output(:grand_total)}"
puts "contracts_collection_keys=#{result.output(:priced_items).keys.join(',')}"
puts "contracts_collection_summary=#{result.output(:priced_items).summary}"
