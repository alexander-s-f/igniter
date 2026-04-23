# frozen_string_literal: true

require_relative "legacy"
Igniter::Core::Legacy.require!("igniter/core/saga")
require_relative "errors"
require_relative "saga/compensation"
require_relative "saga/compensation_record"
require_relative "saga/formatter"
require_relative "saga/result"
require_relative "saga/executor"

module Igniter
  # Saga pattern — compensating transactions for Igniter contracts.
  #
  # When a contract execution fails partway through, the saga system
  # automatically runs the compensating actions for all previously
  # SUCCEEDED nodes, in reverse topological order.
  #
  # Usage:
  #
  #   require "igniter/extensions/saga"
  #
  #   class OrderWorkflow < Igniter::Contract
  #     define do
  #       input  :order_id
  #       input  :amount
  #
  #       compute :reserve_stock, depends_on: :order_id do |order_id:|
  #         InventoryService.reserve(order_id)
  #       end
  #
  #       compute :charge_card, depends_on: %i[order_id amount reserve_stock] do |amount:, **|
  #         raise "Declined" if amount > 1000
  #         PaymentService.charge(amount)
  #       end
  #
  #       output :charge_card
  #     end
  #
  #     compensate :charge_card do |inputs:, value:|
  #       PaymentService.refund(value[:charge_id])
  #     end
  #
  #     compensate :reserve_stock do |inputs:, value:|
  #       InventoryService.release(value[:reservation_id])
  #     end
  #   end
  #
  #   result = OrderWorkflow.new(order_id: "x1", amount: 1500).resolve_saga
  #   result.success?            # => false
  #   result.failed_node         # => :charge_card
  #   result.compensations.map(&:node_name)  # => [:reserve_stock]
  #   puts result.explain
  #
  module Saga
    class SagaError < Igniter::Error; end
  end
end
