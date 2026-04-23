# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

environment = Igniter::Contracts.with(Igniter::Extensions::Contracts::InvariantsPack)

suite = Igniter::Extensions::Contracts.build_invariants do
  invariant(:total_non_negative) { |total:, **| total >= 0 }
  invariant(:discount_non_negative) { |discount:, **| discount >= 0 }
  invariant(:total_le_subtotal) { |total:, subtotal:, **| total <= subtotal }
end

report = Igniter::Extensions::Contracts.run_invariants(
  environment,
  inputs: { price: 20.0, quantity: 10 },
  invariants: suite
) do
  input :price
  input :quantity

  compute :subtotal, depends_on: %i[price quantity] do |price:, quantity:|
    price * quantity
  end

  compute :discount, depends_on: [:subtotal] do |subtotal:|
    subtotal > 100 ? subtotal * 0.1 : 0.0
  end

  compute :total, depends_on: %i[subtotal discount] do |subtotal:, discount:|
    subtotal - discount
  end

  output :total
  output :subtotal
  output :discount
end

cases = Igniter::Extensions::Contracts.verify_invariant_cases(
  environment,
  cases: [
    { price: 20.0, quantity: 10 },
    { price: -5.0, quantity: 3 }
  ],
  invariants: suite,
  compiled_graph: report.execution_result.compiled_graph
)

puts "contracts_invariants_valid=#{report.valid?}"
puts "contracts_invariants_outputs=#{report.outputs.inspect}"
puts "contracts_invariants_cases_valid=#{cases.valid?}"
puts "contracts_invariants_invalid_case_count=#{cases.invalid_cases.length}"
