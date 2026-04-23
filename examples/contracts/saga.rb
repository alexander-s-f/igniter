#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

environment = Igniter::Extensions::Contracts.with(
  Igniter::Extensions::Contracts::ExecutionReportPack,
  Igniter::Extensions::Contracts::SagaPack
)

compensation_log = []

compensations = Igniter::Extensions::Contracts.build_compensations do
  compensate :charge_card do |_inputs:, value:|
    compensation_log << "refund #{value[:charge_id]}"
  end

  compensate :reserve_stock do |_inputs:, value:|
    compensation_log << "release #{value[:reservation_id]}"
  end
end

result = Igniter::Extensions::Contracts.run_saga(
  environment,
  inputs: { order_id: "ord-002", amount: 999.0 },
  compensations: compensations
) do
  input :order_id
  input :amount

  compute :reserve_stock, depends_on: [:order_id] do |order_id:|
    { reservation_id: "rsv-#{order_id}" }
  end

  compute :charge_card, depends_on: %i[order_id amount reserve_stock] do |order_id:, amount:, **|
    raise "Card declined for #{order_id}" if amount > 500

    { charge_id: "chg-#{order_id}", amount: amount }
  end

  output :charge_card
end

diagnostics = environment.diagnose(result.execution_result)

puts "contracts_saga_success=#{result.success?}"
puts "contracts_saga_failed_node=#{result.failed_node.inspect}"
puts "contracts_saga_compensations=#{result.compensations.map(&:node_name).inspect}"
puts "contracts_saga_log=#{compensation_log.inspect}"
puts "contracts_saga_sections=#{diagnostics.section_names.join(',')}"
puts "---"
puts result.explain
