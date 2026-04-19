# frozen_string_literal: true

require "spec_helper"

RSpec.describe "agent sessions" do
  let(:trace) do
    {
      adapter: :queue,
      mode: :call,
      via: :reviewer,
      message: :review,
      outcome: :deferred,
      reason: :awaiting_review
    }
  end

  let(:adapter) do
    pending_trace = trace
    Class.new do
      define_method(:call) do |node:, **|
        {
          status: :pending,
          payload: { queue: :review },
          agent_trace: pending_trace,
          session: {
            node_name: node.name,
            node_path: node.path,
            agent_name: node.agent_name,
            message_name: node.message_name,
            mode: node.mode,
            waiting_on: node.name,
            source_node: node.name,
            trace: pending_trace
          }
        }
      end

      define_method(:cast) do |**|
        raise "unexpected cast"
      end
    end.new
  end

  let(:contract_class) do
    custom_adapter = adapter
    Class.new(Igniter::Contract) do
      runner :inline, agent_adapter: custom_adapter

      define do
        input :name
        agent :approval, via: :reviewer, message: :review, inputs: { name: :name }
        compute :final_answer, depends_on: :approval do |approval:|
          "approved: #{approval}"
        end
        output :approval
        output :final_answer
      end
    end
  end

  it "exposes pending agent nodes as first-class runtime sessions" do
    contract = contract_class.new(name: "Alice")

    expect(contract.result.approval).to be_a(Igniter::Runtime::DeferredResult)

    sessions = contract.execution.agent_sessions
    expect(sessions.size).to eq(1)

    session = sessions.first
    expect(session).to be_a(Igniter::Runtime::AgentSession)
    expect(session.token).not_to be_nil
    expect(session.node_name).to eq(:approval)
    expect(session.agent_name).to eq(:reviewer)
    expect(session.message_name).to eq(:review)
    expect(session.mode).to eq(:call)
    expect(session.trace).to eq(trace)
    expect(session.execution_id).to eq(contract.execution.events.execution_id)
    expect(session.graph).to eq(contract.execution.compiled_graph.name)
  end

  it "resumes pending agent work through the session handle" do
    contract = contract_class.new(name: "Alice")
    contract.result.approval
    session = contract.execution.agent_sessions.first

    contract.execution.resume_agent_session(session, value: "ok")

    expect(contract.result.approval).to eq("ok")
    expect(contract.result.final_answer).to eq("approved: ok")
    expect(contract.execution.find_agent_session(session.token)).to be_nil
  end

  it "serializes and restores agent sessions through execution snapshots" do
    original = contract_class.new(name: "Alice")
    original.result.final_answer
    snapshot = original.snapshot

    restored = contract_class.restore(snapshot)
    session = restored.execution.agent_sessions.first

    expect(session.token).not_to be_nil
    expect(session.agent_name).to eq(:reviewer)
    expect(session.trace).to eq(trace)

    restored.execution.resume_agent_session(session.token, value: "approved")

    expect(restored.result.final_answer).to eq("approved: approved")
  end
end
