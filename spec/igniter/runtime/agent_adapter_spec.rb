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
end
