# frozen_string_literal: true

require "spec_helper"

RSpec.describe Igniter::Runtime::AgentAdapter do
  let(:adapter) { described_class.new }
  let(:node) do
    Igniter::Model::AgentNode.new(
      id: "test:1",
      name: :greeting,
      agent_name: :greeter,
      message_name: :greet,
      input_mapping: { name: :data }
    )
  end

  it "defaults call nodes to reply: :deferred" do
    expect(node.reply_mode).to eq(:deferred)
  end

  it "raises a helpful error when no agent adapter is configured" do
    expect {
      adapter.call(node: node, inputs: { name: "Alice" })
    }.to raise_error(Igniter::ResolutionError, /agent adapter|igniter\/agent|agent_adapter/)
  end

  it "raises a helpful error for cast delivery when no agent adapter is configured" do
    cast_node = Igniter::Model::AgentNode.new(
      id: "test:2",
      name: :notify,
      agent_name: :greeter,
      message_name: :remember,
      input_mapping: { name: :data },
      mode: :cast
    )

    expect(cast_node.reply_mode).to eq(:none)

    expect {
      adapter.cast(node: cast_node, inputs: { name: "Alice" })
    }.to raise_error(Igniter::ResolutionError, /agent adapter|igniter\/agent|agent_adapter/)
  end

  it "can be injected through execution options without loading the agents runtime" do
    custom_adapter = instance_double("CustomAgentAdapter")

    contract_class = Class.new(Igniter::Contract) do
      runner :inline, agent_adapter: custom_adapter

      define do
        input :data
        agent :result,
              via: :greeter,
              message: :greet,
              inputs: { name: :data }
        output :result
      end
    end

    allow(custom_adapter).to receive(:call).and_return(
      status: :succeeded,
      output: "Hello, Alice"
    )

    contract = contract_class.new(data: "Alice")
    contract.resolve_all

    expect(custom_adapter).to have_received(:call).with(
      hash_including(
        node: kind_of(Igniter::Model::AgentNode),
        inputs: { name: "Alice" },
        execution: kind_of(Igniter::Runtime::Execution)
      )
    )
    expect(contract.result.result).to eq("Hello, Alice")
  end

  it "can deliver a cast through an injected adapter" do
    custom_adapter = instance_double("CustomAgentAdapter")

    contract_class = Class.new(Igniter::Contract) do
      runner :inline, agent_adapter: custom_adapter

      define do
        input :data
        agent :notify,
              via: :greeter,
              message: :remember,
              mode: :cast,
              inputs: { name: :data }
        output :notify
      end
    end

    allow(custom_adapter).to receive(:cast).and_return(
      status: :succeeded,
      output: nil
    )

    contract = contract_class.new(data: "Alice")
    contract.resolve_all

    expect(custom_adapter).to have_received(:cast).with(
      hash_including(
        node: kind_of(Igniter::Model::AgentNode),
        inputs: { name: "Alice" },
        execution: kind_of(Igniter::Runtime::Execution)
      )
    )
    expect(contract.result.notify).to be_nil
  end

  it "maps local agent pending replies to a runtime pending response" do
    previous_adapter = Igniter::Runtime.agent_adapter
    Igniter::Runtime.activate_agent_adapter!
    Igniter::Registry.clear
    ref = nil

    agent_class = Class.new(Igniter::Agent) do
      on :greet do |payload:, **|
        raise Igniter::PendingDependencyError.new(
          "continue",
          token: "greeter-session",
          source_node: :greeting,
          payload: { requested_name: payload[:name] }
        )
      end
    end

    ref = agent_class.start(name: :greeter)
    registry_adapter = Igniter::Runtime::RegistryAgentAdapter.new

    response = registry_adapter.call(node: node, inputs: { name: "Alice" })

    expect(response).to include(
      status: :pending,
      message: "continue",
      payload: { requested_name: "Alice" }
    )
    expect(response[:deferred_result]).to have_attributes(
      token: "greeter-session",
      source_node: :greeting,
      waiting_on: :greeting
    )
    expect(response[:agent_trace]).to include(
      adapter: :registry,
      via: :greeter,
      message: :greet,
      outcome: :pending
    )
  ensure
    ref&.stop
    Igniter::Registry.clear
    Igniter::Runtime.agent_adapter = previous_adapter
  end
end
