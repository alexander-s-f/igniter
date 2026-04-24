#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))

require "igniter/contracts"

class QuoteSubtotal
  def self.call(line_items:)
    line_items.sum { |item| item.fetch(:quantity) * item.fetch(:unit_price) }
  end
end

class QuoteContract < Igniter::Contract
  define do
    input :line_items
    input :discount_rate

    compute :subtotal, depends_on: [:line_items], call: QuoteSubtotal

    compute :discount, depends_on: %i[subtotal discount_rate] do |subtotal:, discount_rate:|
      subtotal * discount_rate
    end

    compute :total, depends_on: %i[subtotal discount] do |subtotal:, discount:|
      subtotal - discount
    end

    output :subtotal
    output :total
  end
end

contract = QuoteContract.new(
  line_items: [
    { quantity: 2, unit_price: 15 },
    { quantity: 1, unit_price: 10 }
  ],
  discount_rate: 0.1
)

puts "contracts_class_callable_subtotal=#{contract.result.subtotal}"
puts "contracts_class_callable_total=#{contract.result.total}"
puts "contracts_class_callable_outputs=#{contract.outputs.keys.sort.join(",")}"
