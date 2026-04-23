# frozen_string_literal: true

# Saga Pattern — compensating transactions for Igniter contracts.
#
# When a step fails mid-execution, the saga system automatically runs
# compensating actions for all previously completed steps in reverse order.
#
# Run: ruby examples/saga.rb

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "igniter"
require "igniter/extensions/saga"
require "igniter/extensions/execution_report"

# ── Contracts ─────────────────────────────────────────────────────────────────

class OrderWorkflow < Igniter::Contract
  define do
    input :order_id, type: :string
    input :amount,   type: :numeric

    compute :reserve_stock, depends_on: :order_id do |order_id:|
      puts "  [forward] reserve_stock for order #{order_id}"
      { reservation_id: "rsv-#{order_id}" }
    end

    compute :charge_card, depends_on: %i[order_id amount reserve_stock] do |order_id:, amount:, **|
      puts "  [forward] charge_card: $#{amount}"
      raise "Card declined: amount $#{amount} exceeds limit" if amount > 500

      { charge_id: "chg-#{order_id}", amount: amount }
    end

    compute :send_confirmation, depends_on: %i[reserve_stock charge_card] do |charge_card:, **|
      puts "  [forward] send_confirmation for charge #{charge_card[:charge_id]}"
      { sent: true }
    end

    output :reserve_stock
    output :charge_card
    output :send_confirmation
  end

  compensate :charge_card do |_inputs:, value:|
    puts "  [compensate] refunding charge #{value[:charge_id]}"
  end

  compensate :reserve_stock do |_inputs:, value:|
    puts "  [compensate] releasing reservation #{value[:reservation_id]}"
  end
end

puts "=== Saga Demo ==="
puts

# ── 1. Successful saga ─────────────────────────────────────────────────────────

puts "--- 1. Successful execution (amount=$100) ---"
result_ok = OrderWorkflow.new(order_id: "ord-001", amount: 100.0).resolve_saga
puts result_ok.explain
puts

# ── 2. Failed saga — compensations triggered ───────────────────────────────────

puts "--- 2. Failed execution (amount=$999 — exceeds limit) ---"
result_fail = OrderWorkflow.new(order_id: "ord-002", amount: 999.0).resolve_saga
puts result_fail.explain
puts

# ── 3. Result query API ────────────────────────────────────────────────────────

puts "--- 3. Result query API ---"
puts "success?          = #{result_fail.success?}"
puts "failed_node       = #{result_fail.failed_node.inspect}"
puts "error             = #{result_fail.error.message}"
puts "compensations_ran = #{result_fail.compensations.map(&:node_name).inspect}"
puts "all compensations ok? #{result_fail.compensations.all?(&:success?)}"
puts

# ── 4. Execution report ────────────────────────────────────────────────────────

puts "--- 4. execution_report (after failed saga) ---"
failed_contract = OrderWorkflow.new(order_id: "ord-003", amount: 999.0)
begin
  failed_contract.resolve_all
rescue Igniter::Error
  nil
end
puts failed_contract.execution_report.explain
puts

# ── 5. Execution report on successful contract ────────────────────────────────

puts "--- 5. execution_report (successful) ---"
ok_contract = OrderWorkflow.new(order_id: "ord-004", amount: 50.0)
ok_contract.resolve_all
puts ok_contract.execution_report.explain
puts

# ── 6. to_h / structured output ───────────────────────────────────────────────

puts "--- 6. result.to_h ---"
h = result_fail.to_h
puts "success:       #{h[:success]}"
puts "failed_node:   #{h[:failed_node].inspect}"
puts "error:         #{h[:error]}"
puts "compensations: #{h[:compensations].map { |c| [c[:node], c[:success]] }.inspect}"
puts

puts "done=true"
