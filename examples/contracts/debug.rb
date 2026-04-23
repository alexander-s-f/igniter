# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

environment = Igniter::Extensions::Contracts.with(Igniter::Extensions::Contracts::DebugPack)

report = Igniter::Extensions::Contracts.debug_report(environment, inputs: {
                                                       amount: 100.0,
                                                       quantity: 2
                                                     }) do
  input :amount
  input :quantity

  compute :subtotal, depends_on: %i[amount quantity] do |amount:, quantity:|
    amount * quantity
  end

  compute :tax, depends_on: [:subtotal] do |subtotal:|
    subtotal * 0.2
  end

  output :tax
end

puts "contracts_debug_ok=#{report.ok?}"
puts "contracts_debug_packs=#{report.profile_snapshot.pack_names.join(",")}"
puts "contracts_debug_output=#{report.execution_result.output(:tax)}"
puts "contracts_debug_sections=#{report.diagnostics_report.section_names.join(",")}"
puts "contracts_debug_registry_keys=#{report.profile_snapshot.registry_keys.fetch(:diagnostics_contributors).join(",")}"
