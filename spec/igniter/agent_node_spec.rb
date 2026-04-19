# frozen_string_literal: true

require "spec_helper"
require "igniter/agent"

RSpec.describe "agent: DSL node" do
  def wait_until(timeout: 1.0, interval: 0.01)
    deadline = Time.now + timeout
    sleep(interval) until yield || Time.now >= deadline
  end

  around do |example|
    previous_adapter = Igniter::Runtime.agent_adapter
    Igniter::Runtime.activate_agent_adapter!
    Igniter::Registry.clear
    example.run
    Igniter::Registry.clear
    Igniter::Runtime.agent_adapter = previous_adapter
  end

  describe "compilation" do
    it "compiles a graph with an agent: node" do
      contract_class = Class.new(Igniter::Contract) do
        define do
          input :name
          agent :greeting,
                via: :greeter,
                message: :greet,
                inputs: { name: :name },
                timeout: 2
          output :greeting
        end
      end

      node = contract_class.compiled_graph.fetch_node(:greeting)

      expect(node).to be_a(Igniter::Model::AgentNode)
      expect(node.kind).to eq(:agent)
      expect(node.agent_name).to eq(:greeter)
      expect(node.message_name).to eq(:greet)
      expect(node.input_mapping).to eq(name: :name)
      expect(node.mode).to eq(:call)
      expect(contract_class.graph.to_schema[:agents]).to include(
        hash_including(name: :greeting, via: :greeter, message: :greet, inputs: { name: :name }, mode: :call)
      )
    end

    it "raises CompileError when inputs: is not a Hash" do
      expect do
        Class.new(Igniter::Contract) do
          define do
            input :name
            agent :greeting, via: :greeter, message: :greet, inputs: :wrong
          end
        end
      end.to raise_error(Igniter::CompileError, /inputs: Hash/)
    end

    it "raises CompileError when via: is missing" do
      expect do
        Class.new(Igniter::Contract) do
          define do
            input :name
            agent :greeting, via: nil, message: :greet, inputs: { name: :name }
          end
        end
      end.to raise_error(Igniter::CompileError, /requires via:/)
    end

    it "raises CompileError when mode is unsupported" do
      expect do
        Class.new(Igniter::Contract) do
          define do
            input :name
            agent :greeting, via: :greeter, message: :greet, mode: :stream, inputs: { name: :name }
          end
        end
      end.to raise_error(Igniter::CompileError, /mode must be :call or :cast/)
    end

    it "raises ValidationError when dependency is not in graph" do
      expect do
        Class.new(Igniter::Contract) do
          define do
            input :name
            agent :greeting, via: :greeter, message: :greet, inputs: { name: :missing }
            output :greeting
          end
        end
      end.to raise_error(Igniter::ValidationError, /missing/)
    end
  end

  describe "runtime resolution" do
    let(:greeter_class) do
      Class.new(Igniter::Agent) do
        initial_state names: []

        on :greet do |payload:, **|
          "Hello, #{payload.fetch(:name)}"
        end

        on :remember do |state:, payload:, **|
          state.merge(names: state[:names] + [payload.fetch(:name)])
        end
      end
    end

    let(:contract_class) do
      Class.new(Igniter::Contract) do
        define do
          input :name
          agent :greeting,
                via: :greeter,
                message: :greet,
                inputs: { name: :name }
          output :greeting
        end
      end
    end

    it "resolves through the registered agent adapter" do
      ref = greeter_class.start(name: :greeter)

      contract = contract_class.new(name: "Alice")
      contract.resolve_all

      expect(contract.success?).to be true
      expect(contract.result.greeting).to eq("Hello, Alice")
      ref.stop
    end

    it "raises ResolutionError when no registered agent is available" do
      contract = contract_class.new(name: "Alice")

      expect { contract.resolve_all }
        .to raise_error(Igniter::ResolutionError, /No registered agent/)
    end

    it "supports fire-and-forget cast delivery" do
      ref = greeter_class.start(name: :greeter)

      contract_class = Class.new(Igniter::Contract) do
        define do
          input :name
          agent :notify,
                via: :greeter,
                message: :remember,
                mode: :cast,
                inputs: { name: :name }
          output :notify
        end
      end

      contract = contract_class.new(name: "Alice")
      contract.resolve_all

      wait_until { ref.state[:names] == ["Alice"] }

      expect(contract.success?).to be true
      expect(contract.result.notify).to be_nil
      expect(ref.state[:names]).to eq(["Alice"])
      ref.stop
    end
  end
end
