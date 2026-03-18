# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "igniter"
require "tmpdir"

class AsyncQuoteExecutor < Igniter::Executor
  input :order_total, type: :numeric

  def call(order_total:)
    defer(token: "quote-#{order_total}", payload: { kind: "pricing_quote" })
  end
end

class AsyncPricingContract < Igniter::Contract
  run_with runner: :store

  define do
    input :order_total, type: :numeric

    compute :quote_total, depends_on: [:order_total], call: AsyncQuoteExecutor

    compute :gross_total, depends_on: [:quote_total] do |quote_total:|
      quote_total * 1.2
    end

    output :gross_total
  end
end

Dir.mktmpdir("igniter-example-store") do |dir|
  original_store = Igniter.execution_store
  Igniter.execution_store = Igniter::Runtime::Stores::FileStore.new(root: dir)

  contract = AsyncPricingContract.new(order_total: 100)
  deferred = contract.result.gross_total
  execution_id = contract.execution.events.execution_id

  puts "pending_token=#{deferred.token}"
  puts "stored_execution_id=#{execution_id}"
  puts "pending_status=#{contract.result.pending?}"

  resumed = AsyncPricingContract.resume_from_store(execution_id, token: deferred.token, value: 150)
  puts "resumed_gross_total=#{resumed.result.gross_total}"
ensure
  Igniter.execution_store = original_store
end
