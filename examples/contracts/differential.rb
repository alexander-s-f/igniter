# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

environment = Igniter::Contracts.with(Igniter::Extensions::Contracts::DifferentialPack)

primary = environment.compile do
  input :price
  input :quantity

  compute :subtotal, depends_on: %i[price quantity] do |price:, quantity:|
    (price * quantity).round(2)
  end

  compute :tax, depends_on: [:subtotal] do |subtotal:|
    (subtotal * 0.10).round(2)
  end

  compute :total, depends_on: %i[subtotal tax] do |subtotal:, tax:|
    (subtotal + tax).round(2)
  end

  output :subtotal
  output :tax
  output :total
end

candidate = environment.compile do
  input :price
  input :quantity

  compute :subtotal, depends_on: %i[price quantity] do |price:, quantity:|
    (price * quantity).round(2)
  end

  compute :tax, depends_on: [:subtotal] do |subtotal:|
    (subtotal * 0.15).round(2)
  end

  compute :discount, depends_on: [:subtotal] do |subtotal:|
    subtotal > 100 ? 10.0 : 0.0
  end

  compute :total, depends_on: %i[subtotal tax discount] do |subtotal:, tax:, discount:|
    (subtotal + tax - discount).round(2)
  end

  output :subtotal
  output :tax
  output :discount
  output :total
end

inputs = { price: 50.0, quantity: 3 }

report = Igniter::Extensions::Contracts.compare_differential(
  inputs: inputs,
  primary_environment: environment,
  primary_compiled_graph: primary,
  candidate_environment: environment,
  candidate_compiled_graph: candidate,
  primary_name: "PricingV1",
  candidate_name: "PricingV2"
)

tolerated = Igniter::Extensions::Contracts.compare_differential(
  inputs: inputs,
  primary_environment: environment,
  primary_compiled_graph: primary,
  candidate_environment: environment,
  candidate_compiled_graph: candidate,
  primary_name: "PricingV1",
  candidate_name: "PricingV2",
  tolerance: 10.0
)

primary_result = environment.execute(primary, inputs: inputs)
shadow = Igniter::Extensions::Contracts.shadow_differential(
  inputs: inputs,
  primary_result: primary_result,
  candidate_environment: environment,
  candidate_compiled_graph: candidate,
  primary_name: "PricingV1",
  candidate_name: "PricingV2"
)

puts "contracts_differential_match=#{report.match?}"
puts "contracts_differential_diverged=#{report.divergences.map(&:output_name).inspect}"
puts "contracts_differential_candidate_only=#{report.candidate_only.keys.inspect}"
puts "contracts_differential_tax_tolerated=#{tolerated.divergences.none? do |divergence|
  divergence.output_name == :tax
end}"
puts "contracts_shadow_match=#{shadow.match?}"
puts "contracts_shadow_summary=#{shadow.summary}"
