#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

environment = Igniter::Extensions::Contracts.with(
  Igniter::Extensions::Contracts::LookupPack,
  Igniter::Extensions::Contracts::ProvenancePack,
  Igniter::Contracts::ProjectPack
)

compiled = environment.compile do
  input :pricing
  input :tax_rates

  project :base_price, from: :pricing, key: :base_price
  project :quantity, from: :pricing, key: :quantity
  lookup :tax_rate, from: :tax_rates, key: :ua

  compute :subtotal, depends_on: %i[base_price quantity] do |base_price:, quantity:|
    base_price * quantity
  end

  compute :tax_amount, depends_on: %i[subtotal tax_rate] do |subtotal:, tax_rate:|
    subtotal * tax_rate
  end

  compute :grand_total, depends_on: %i[subtotal tax_amount] do |subtotal:, tax_amount:|
    subtotal + tax_amount
  end

  output :grand_total
end

result = environment.execute(
  compiled,
  inputs: {
    pricing: { base_price: 100.0, quantity: 3 },
    tax_rates: { ua: 0.2 }
  }
)

lineage = Igniter::Extensions::Contracts.lineage(result, :grand_total)
diagnostics = environment.diagnose(result)

puts "contracts_provenance_output=#{result.output(:grand_total)}"
puts "contracts_provenance_inputs=#{lineage.contributing_inputs.inspect}"
puts "contracts_provenance_path=#{lineage.path_to(:base_price).inspect}"
puts "contracts_provenance_sections=#{diagnostics.section_names.join(",")}"
puts "---"
puts Igniter::Extensions::Contracts.explain(result, :grand_total)
