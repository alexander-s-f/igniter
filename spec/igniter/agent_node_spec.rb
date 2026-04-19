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
      expect(node.reply_mode).to eq(:deferred)
      expect(node.finalizer).to be_nil
      expect(contract_class.graph.to_schema[:agents]).to include(
        hash_including(name: :greeting, via: :greeter, message: :greet, inputs: { name: :name }, mode: :call, reply: :deferred, finalizer: nil)
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

    it "raises CompileError when reply mode is unsupported" do
      expect do
        Class.new(Igniter::Contract) do
          define do
            input :name
            agent :greeting, via: :greeter, message: :greet, reply: :many, inputs: { name: :name }
          end
        end
      end.to raise_error(Igniter::CompileError, /reply must be :single, :deferred, :stream, or :none/)
    end

    it "raises CompileError when cast uses a reply mode other than none" do
      expect do
        Class.new(Igniter::Contract) do
          define do
            input :name
            agent :greeting, via: :greeter, message: :greet, mode: :cast, reply: :deferred, inputs: { name: :name }
          end
        end
      end.to raise_error(Igniter::CompileError, /mode :cast only supports reply: :none/)
    end

    it "raises CompileError when finalizer is used without reply: :stream" do
      expect do
        Class.new(Igniter::Contract) do
          define do
            input :name
            agent :greeting, via: :greeter, message: :greet, finalizer: :join, inputs: { name: :name }
          end
        end
      end.to raise_error(Igniter::CompileError, /finalizer requires reply: :stream/)
    end

    it "compiles stream agents with default and custom finalizers" do
      contract_class = Class.new(Igniter::Contract) do
        define do
          input :name
          agent :default_summary, via: :writer, message: :summarize, reply: :stream, inputs: { name: :name }
          agent :custom_summary, via: :writer, message: :summarize, reply: :stream, finalizer: :array, inputs: { name: :name }
          output :default_summary
          output :custom_summary
        end
      end

      expect(contract_class.compiled_graph.fetch_node(:default_summary).finalizer).to eq(:join)
      expect(contract_class.compiled_graph.fetch_node(:custom_summary).finalizer).to eq(:array)
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

    it "rejects pending delivery for reply: :single" do
      adapter = Class.new do
        define_method(:call) do |node:, **|
          {
            status: :pending,
            payload: { queue: :review },
            agent_trace: {
              adapter: :queue,
              mode: node.mode,
              via: node.agent_name,
              message: node.message_name,
              outcome: :deferred
            }
          }
        end
      end.new

      contract_class = Class.new(Igniter::Contract) do
        runner :inline, agent_adapter: adapter

        define do
          input :name
          agent :approval, via: :reviewer, message: :review, reply: :single, inputs: { name: :name }
          output :approval
        end
      end

      contract = contract_class.new(name: "Alice")

      expect { contract.resolve_all }
        .to raise_error(Igniter::ResolutionError, /reply mode :single cannot return pending/)
    end

    it "opens streaming agent sessions for reply: :stream" do
      adapter = Class.new do
        define_method(:call) do |node:, **|
          {
            status: :pending,
            payload: { queue: :stream },
            agent_trace: {
              adapter: :queue,
              mode: node.mode,
              via: node.agent_name,
              message: node.message_name,
              outcome: :streaming
            }
          }
        end
      end.new

      contract_class = Class.new(Igniter::Contract) do
        runner :inline, agent_adapter: adapter

        define do
          input :name
          agent :summary, via: :writer, message: :summarize, reply: :stream, inputs: { name: :name }
          output :summary
        end
      end

      contract = contract_class.new(name: "Alice")
      contract.result.summary
      session = contract.execution.agent_sessions.first

      expect(session).not_to be_nil
      expect(contract.result.summary).to be_a(Igniter::Runtime::StreamResult)
      expect(contract.result.summary.chunks).to eq([])
      expect(session.reply_mode).to eq(:stream)
      expect(session.phase).to eq(:streaming)

      contract.execution.continue_agent_session(
        session,
        payload: {},
        reply: { turn: 2, kind: :reply, name: :summarize, source: :agent, payload: { chunk: "Hello" } },
        phase: :streaming
      )

      continued = contract.execution.agent_sessions.first
      stream_value = contract.result.summary
      runtime_value = contract.execution.states[:summary][:value]

      expect(stream_value).to be_a(Igniter::Runtime::StreamResult)
      expect(stream_value.chunks).to eq(["Hello"])
      expect(stream_value.events).to eq(
        [
          {
            turn: 2,
            source: :agent,
            message_name: :summarize,
            type: :chunk,
            chunk: "Hello"
          }
        ]
      )
      expect(stream_value.phase).to eq(:streaming)
      expect(continued.last_reply).to include(kind: :reply, payload: { chunk: "Hello" })
      expect(continued.last_event).to include(type: :chunk, chunk: "Hello")
      expect(continued.phase).to eq(:streaming)
      expect(runtime_value).to include(type: :stream, phase: :streaming, chunks: ["Hello"], event_count: 1)

      contract.execution.resume_agent_session(continued, value: "Hello, Alice")
      expect(contract.result.summary).to eq("Hello, Alice")
      expect(contract.execution.states[:summary].dig(:details, :agent_session, :last_reply)).to include(
        kind: :reply,
        payload: { event: :final, value: "Hello, Alice" }
      )
    end

    it "auto-finalizes stream results with the default join policy" do
      adapter = Class.new do
        define_method(:call) do |node:, **|
          {
            status: :pending,
            payload: { queue: :stream },
            agent_trace: {
              adapter: :queue,
              mode: node.mode,
              via: node.agent_name,
              message: node.message_name,
              outcome: :streaming
            }
          }
        end
      end.new

      contract_class = Class.new(Igniter::Contract) do
        runner :inline, agent_adapter: adapter

        define do
          input :name
          agent :summary, via: :writer, message: :summarize, reply: :stream, inputs: { name: :name }
          output :summary
        end
      end

      contract = contract_class.new(name: "Alice")
      contract.result.summary
      session = contract.execution.agent_sessions.first

      contract.execution.continue_agent_session(
        session,
        payload: {},
        reply: { turn: 2, kind: :reply, name: :summarize, source: :agent, payload: { chunk: "Hello, " } },
        phase: :streaming
      )
      contract.execution.continue_agent_session(
        session.token,
        payload: {},
        reply: { turn: 3, kind: :reply, name: :summarize, source: :agent, payload: { chunk: "Alice" } },
        phase: :streaming
      )

      continued = contract.execution.agent_sessions.first
      contract.execution.resume_agent_session(continued)

      expect(contract.result.summary).to eq("Hello, Alice")
    end

    it "supports custom stream finalizers on the contract instance" do
      adapter = Class.new do
        define_method(:call) do |node:, **|
          {
            status: :pending,
            payload: { queue: :stream },
            agent_trace: {
              adapter: :queue,
              mode: node.mode,
              via: node.agent_name,
              message: node.message_name,
              outcome: :streaming
            }
          }
        end
      end.new

      contract_class = Class.new(Igniter::Contract) do
        runner :inline, agent_adapter: adapter

        define_method(:finalize_words) do |chunks:, **|
          chunks.map(&:upcase)
        end

        define do
          input :name
          agent :summary, via: :writer, message: :summarize, reply: :stream, finalizer: :finalize_words, inputs: { name: :name }
          output :summary
        end
      end

      contract = contract_class.new(name: "Alice")
      contract.result.summary
      session = contract.execution.agent_sessions.first

      contract.execution.continue_agent_session(
        session,
        payload: {},
        reply: { turn: 2, kind: :reply, name: :summarize, source: :agent, payload: { chunk: "hello" } },
        phase: :streaming
      )
      contract.execution.continue_agent_session(
        session.token,
        payload: {},
        reply: { turn: 3, kind: :reply, name: :summarize, source: :agent, payload: { chunk: "alice" } },
        phase: :streaming
      )

      contract.execution.resume_agent_session(session.token)

      expect(contract.result.summary).to eq(%w[HELLO ALICE])
    end

    it "surfaces typed stream events and can finalize them as events" do
      adapter = Class.new do
        define_method(:call) do |node:, **|
          {
            status: :pending,
            payload: { queue: :stream },
            agent_trace: {
              adapter: :queue,
              mode: node.mode,
              via: node.agent_name,
              message: node.message_name,
              outcome: :streaming
            }
          }
        end
      end.new

      contract_class = Class.new(Igniter::Contract) do
        runner :inline, agent_adapter: adapter

        define do
          input :name
          agent :summary, via: :writer, message: :summarize, reply: :stream, finalizer: :events, inputs: { name: :name }
          output :summary
        end
      end

      contract = contract_class.new(name: "Alice")
      contract.result.summary
      session = contract.execution.agent_sessions.first

      contract.execution.continue_agent_session(
        session,
        payload: {},
        reply: {
          turn: 2,
          kind: :reply,
          name: :summarize,
          source: :agent,
          payload: {
            event: :status,
            status: "thinking"
          }
        },
        phase: :streaming
      )
      contract.execution.continue_agent_session(
        session.token,
        payload: {},
        reply: {
          turn: 3,
          kind: :reply,
          name: :summarize,
          source: :agent,
          payload: {
            events: [
              { type: :tool_call, name: :search, arguments: { q: "Alice" } },
              { type: :chunk, chunk: "Hello, Alice" }
            ]
          }
        },
        phase: :streaming
      )

      stream_value = contract.result.summary

      expect(stream_value.events).to eq(
        [
          {
            turn: 2,
            source: :agent,
            message_name: :summarize,
            type: :status,
            status: "thinking"
          },
          {
            turn: 3,
            source: :agent,
            message_name: :summarize,
            type: :tool_call,
            name: :search,
            arguments: { q: "Alice" }
          },
          {
            turn: 3,
            source: :agent,
            message_name: :summarize,
            type: :chunk,
            chunk: "Hello, Alice"
          }
        ]
      )
      expect(stream_value.chunks).to eq(["Hello, Alice"])

      contract.execution.resume_agent_session(session.token)

      expect(contract.result.summary).to eq(
        [
          {
            turn: 2,
            source: :agent,
            message_name: :summarize,
            type: :status,
            status: "thinking"
          },
          {
            turn: 3,
            source: :agent,
            message_name: :summarize,
            type: :tool_call,
            name: :search,
            arguments: { q: "Alice" }
          },
          {
            turn: 3,
            source: :agent,
            message_name: :summarize,
            type: :chunk,
            chunk: "Hello, Alice"
          }
        ]
      )
      expect(contract.execution.states[:summary].dig(:details, :agent_session, :last_reply)).to include(
        payload: { event: :final, value: stream_value.events }
      )
    end

    it "rejects unsupported stream event types" do
      adapter = Class.new do
        define_method(:call) do |node:, **|
          {
            status: :pending,
            payload: { queue: :stream },
            agent_trace: {
              adapter: :queue,
              mode: node.mode,
              via: node.agent_name,
              message: node.message_name,
              outcome: :streaming
            }
          }
        end
      end.new

      contract_class = Class.new(Igniter::Contract) do
        runner :inline, agent_adapter: adapter

        define do
          input :name
          agent :summary, via: :writer, message: :summarize, reply: :stream, inputs: { name: :name }
          output :summary
        end
      end

      contract = contract_class.new(name: "Alice")
      contract.result.summary
      session = contract.execution.agent_sessions.first

      expect do
        contract.execution.continue_agent_session(
          session,
          payload: {},
          reply: {
            turn: 2,
            kind: :reply,
            name: :summarize,
            source: :agent,
            payload: { event: :unknown, value: "bad" }
          },
          phase: :streaming
        )
      end.to raise_error(Igniter::ResolutionError, /Unsupported stream event type/)
    end

    it "rejects malformed stream event payloads" do
      adapter = Class.new do
        define_method(:call) do |node:, **|
          {
            status: :pending,
            payload: { queue: :stream },
            agent_trace: {
              adapter: :queue,
              mode: node.mode,
              via: node.agent_name,
              message: node.message_name,
              outcome: :streaming
            }
          }
        end
      end.new

      contract_class = Class.new(Igniter::Contract) do
        runner :inline, agent_adapter: adapter

        define do
          input :name
          agent :summary, via: :writer, message: :summarize, reply: :stream, inputs: { name: :name }
          output :summary
        end
      end

      contract = contract_class.new(name: "Alice")
      contract.result.summary
      session = contract.execution.agent_sessions.first

      expect do
        contract.execution.continue_agent_session(
          session,
          payload: {},
          reply: {
            turn: 2,
            kind: :reply,
            name: :summarize,
            source: :agent,
            payload: { event: :status }
          },
          phase: :streaming
        )
      end.to raise_error(Igniter::ResolutionError, /Stream :status events/)
    end

    it "rejects synchronous success for reply: :stream" do
      adapter = Class.new do
        define_method(:call) do |**|
          { status: :succeeded, output: "done" }
        end
      end.new

      contract_class = Class.new(Igniter::Contract) do
        runner :inline, agent_adapter: adapter

        define do
          input :name
          agent :summary, via: :writer, message: :summarize, reply: :stream, inputs: { name: :name }
          output :summary
        end
      end

      contract = contract_class.new(name: "Alice")

      expect { contract.resolve_all }
        .to raise_error(Igniter::ResolutionError, /reply mode :stream requires session-based pending delivery/)
    end
  end
end
