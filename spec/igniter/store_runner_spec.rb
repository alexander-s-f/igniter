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

  let(:pending_agent_trace) do
    {
      adapter: :queue,
      mode: :call,
      via: :reviewer,
      message: :review,
      outcome: :deferred,
      reason: :awaiting_review
    }
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

  it "resumes store-backed agent sessions through the class API" do
    trace = pending_agent_trace
    agent_adapter = Class.new do
      define_method(:call) do |node:, **|
        {
          status: :pending,
          payload: { queue: :review },
          agent_trace: trace,
          session: {
            node_name: node.name,
            node_path: node.path,
            agent_name: node.agent_name,
            message_name: node.message_name,
            mode: node.mode,
            waiting_on: node.name,
            source_node: node.name,
            trace: trace
          }
        }
      end

      define_method(:cast) do |**|
        raise "unexpected cast"
      end
    end.new

    contract_class = Class.new(Igniter::Contract) do
      run_with runner: :store, agent_adapter: agent_adapter

      define do
        input :name
        agent :approval, via: :reviewer, message: :review, inputs: { name: :name }
        compute :final_answer, depends_on: :approval do |approval:|
          "approved: #{approval}"
        end
        output :final_answer
      end
    end

    original = contract_class.new(name: "Alice")
    original.result.final_answer
    execution_id = original.execution.events.execution_id

    restored = contract_class.restore_from_store(execution_id)
    session = restored.execution.agent_sessions.first

    resumed = contract_class.resume_agent_session_from_store(execution_id, session: session, value: "ok")

    expect(resumed.result.final_answer).to eq("approved: ok")
    expect(Igniter.execution_store.exist?(execution_id)).to eq(false)
  end
end
