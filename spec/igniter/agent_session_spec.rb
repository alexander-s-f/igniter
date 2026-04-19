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
    expect(session.reply_mode).to eq(:deferred)
    expect(session.turn).to eq(1)
    expect(session.phase).to eq(:waiting)
    expect(session.messages).to contain_exactly(
      include(turn: 1, kind: :request, name: :review, source: :contract, reply_mode: :deferred, payload: { queue: :review })
    )
    expect(session.last_request).to include(
      turn: 1,
      kind: :request,
      name: :review,
      reply_mode: :deferred,
      payload: { queue: :review }
    )
    expect(session.last_reply).to be_nil
    expect(session.history).to contain_exactly(
      include(turn: 1, event: :opened, token: session.token)
    )
    expect(session.trace).to eq(trace)
    expect(session.execution_id).to eq(contract.execution.events.execution_id)
    expect(session.graph).to eq(contract.execution.compiled_graph.name)
  end

  it "continues agent work across multiple turns before final resume" do
    contract = contract_class.new(name: "Alice")
    contract.result.approval
    session = contract.execution.agent_sessions.first
    continued_trace = trace.merge(reason: :awaiting_human_reply)

    contract.execution.continue_agent_session(
      session,
      payload: { prompt: "Need manager approval" },
      trace: continued_trace
    )

    continued = contract.execution.agent_sessions.first

    expect(contract.result.pending?).to be true
    expect(continued.token).to eq(session.token)
    expect(continued.turn).to eq(2)
    expect(continued.phase).to eq(:waiting)
    expect(continued.trace).to eq(continued_trace)
    expect(continued.payload).to eq(prompt: "Need manager approval")
    expect(continued.last_request).to include(
      turn: 2,
      kind: :request,
      name: :review,
      source: :continuation,
      reply_mode: :deferred,
      payload: { prompt: "Need manager approval" }
    )
    expect(continued.messages).to include(
      include(turn: 1, kind: :request, name: :review),
      include(turn: 2, kind: :request, name: :review, payload: { prompt: "Need manager approval" })
    )
    expect(continued.history).to include(
      include(turn: 1, event: :opened, token: session.token),
      include(turn: 2, event: :continued, token: session.token, payload: { prompt: "Need manager approval" })
    )
    expect(contract.events.map(&:type)).to include(:agent_session_continued, :node_pending)

    contract.execution.resume_agent_session(continued, value: "ok")

    report = contract.diagnostics.to_h
    entry = report.dig(:agents, :entries)&.find { |item| item[:node_name] == :approval }

    expect(contract.result.final_answer).to eq("approved: ok")
    expect(entry[:agent_session]).to include(
      token: session.token,
      turn: 3,
      phase: :completed
    )
    expect(entry[:agent_session][:last_reply]).to include(
      turn: 3,
      kind: :reply,
      name: :review,
      reply_mode: :deferred,
      payload: { value: "ok" }
    )
    expect(entry[:agent_session][:messages]).to include(
      include(turn: 3, kind: :reply, name: :review, reply_mode: :deferred, payload: { value: "ok" })
    )
    expect(entry[:agent_session][:history]).to include(
      include(turn: 3, event: :completed, token: session.token)
    )
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
    expect(session.turn).to eq(1)
    expect(session.phase).to eq(:waiting)
    expect(session.trace).to eq(trace)

    restored.execution.resume_agent_session(session.token, value: "approved")

    expect(restored.result.final_answer).to eq("approved: approved")
  end
end
