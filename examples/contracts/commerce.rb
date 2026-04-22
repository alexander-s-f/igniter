#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

environment = Igniter::Extensions::Contracts.with_preset(:commerce)

result = environment.run(inputs: {
  order: {
    items: [
      { amount: 10 },
      { amount: 20 }
    ]
  },
  tax_rate: 0.2,
  shipping: 5,
  discount: 3
}) do
  input :order
  input :tax_rate
  input :shipping
  input :discount

  order_items from: :order
  subtotal from: :items
  tax_amount amount: :subtotal, rate: :tax_rate
  grand_total subtotal: :subtotal, tax: :tax, shipping: :shipping, discount: :discount

  output :subtotal
  output :tax
  output :grand_total
end

diagnostics = environment.diagnose(result)

puts "commerce_subtotal=#{result.output(:subtotal)}"
puts "commerce_tax=#{result.output(:tax)}"
puts "commerce_grand_total=#{result.output(:grand_total)}"
puts "commerce_packs=#{environment.profile.pack_names.join(',')}"
puts "execution_report_sections=#{diagnostics.sections.keys.join(',')}"
