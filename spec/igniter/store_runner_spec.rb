# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Igniter store-backed execution" do
  around do |example|
    original_store = Igniter.execution_store
    Igniter.execution_store = Igniter::Runtime::Stores::MemoryStore.new
    example.run
    Igniter.execution_store = original_store
  end

  class StoredAsyncExecutor < Igniter::Executor
    input :order_total, type: :numeric

    def call(order_total:)
      defer(token: "stored-#{order_total}", payload: { kind: "quote" })
    end
  end

  it "persists pending snapshots in the configured execution store" do
    contract_class = Class.new(Igniter::Contract) do
      run_with runner: :store

      define do
        input :order_total, type: :numeric
        compute :quote_total, depends_on: [:order_total], call: StoredAsyncExecutor
        output :quote_total
      end
    end

    contract = contract_class.new(order_total: 100)
    deferred = contract.result.quote_total
    execution_id = contract.execution.events.execution_id

    expect(deferred).to be_a(Igniter::Runtime::DeferredResult)
    expect(Igniter.execution_store.exist?(execution_id)).to eq(true)
  end

  it "restores stored pending execution and resumes by token" do
    contract_class = Class.new(Igniter::Contract) do
      run_with runner: :store

      define do
        input :order_total, type: :numeric
        compute :quote_total, depends_on: [:order_total], call: StoredAsyncExecutor
        compute :gross_total, depends_on: [:quote_total] do |quote_total:|
          quote_total * 1.2
        end
        output :gross_total
      end
    end

    original = contract_class.new(order_total: 100)
    original.result.gross_total
    execution_id = original.execution.events.execution_id

    restored = contract_class.restore_from_store(execution_id)
    expect(restored.result.pending?).to eq(true)

    restored.execution.resume_by_token("stored-100", value: 150)

    expect(restored.result.gross_total).to eq(180.0)
    expect(Igniter.execution_store.exist?(execution_id)).to eq(false)
  end
end
