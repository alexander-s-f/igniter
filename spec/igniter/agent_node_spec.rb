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
      expect(node.routing_mode).to eq(:local)
      expect(node.reply_mode).to eq(:deferred)
      expect(node.finalizer).to be_nil
      expect(node.tool_loop_policy).to be_nil
      expect(node.session_policy).to be_nil
      expect(contract_class.graph.to_schema[:agents]).to include(
        hash_including(name: :greeting, via: :greeter, message: :greet, inputs: { name: :name }, mode: :call, routing_mode: :local, reply: :deferred, finalizer: nil, tool_loop_policy: nil, session_policy: nil)
      )
    end

    it "compiles static routed agents" do
      contract_class = Class.new(Igniter::Contract) do
        define do
          input :name
          agent :review,
                via: :reviewer,
                message: :review,
                node: "http://agents:4567",
                inputs: { name: :name }
          output :review
        end
      end

      node = contract_class.compiled_graph.fetch_node(:review)

      expect(node.routing_mode).to eq(:static)
      expect(node.node_url).to eq("http://agents:4567")
      expect(contract_class.graph.to_schema[:agents]).to include(
        hash_including(name: :review, routing_mode: :static, node: "http://agents:4567")
      )
    end

    it "compiles capability-routed agents" do
      contract_class = Class.new(Igniter::Contract) do
        define do
          input :name
          agent :review,
                via: :reviewer,
                message: :review,
                query: { all_of: [:review], trust: { identity: :trusted } },
                inputs: { name: :name }
          output :review
        end
      end

      node = contract_class.compiled_graph.fetch_node(:review)

      expect(node.routing_mode).to eq(:capability)
      expect(node.capability_query).to eq(all_of: [:review], trust: { identity: :trusted })
      expect(contract_class.graph.to_schema[:agents]).to include(
        hash_including(
          name: :review,
          routing_mode: :capability,
          query: { all_of: [:review], trust: { identity: :trusted } }
        )
      )
    end

    it "raises CompileError when query: and pinned_to: are combined" do
      expect do
        Class.new(Igniter::Contract) do
          define do
            input :name
            agent :review,
                  via: :reviewer,
                  message: :review,
                  query: { all_of: [:review] },
                  pinned_to: "audit-node",
                  inputs: { name: :name }
          end
        end
      end.to raise_error(Igniter::CompileError, /capability:, query:, and pinned_to: are mutually exclusive/)
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

    it "raises CompileError when tool_loop_policy is used without reply: :stream" do
      expect do
        Class.new(Igniter::Contract) do
          define do
            input :name
            agent :greeting, via: :greeter, message: :greet, tool_loop_policy: :complete, inputs: { name: :name }
          end
        end
      end.to raise_error(Igniter::CompileError, /tool_loop_policy requires reply: :stream/)
    end

    it "raises CompileError when tool_loop_policy is unsupported" do
      expect do
        Class.new(Igniter::Contract) do
          define do
            input :name
            agent :greeting, via: :greeter, message: :greet, reply: :stream, tool_loop_policy: :strictest, inputs: { name: :name }
          end
        end
      end.to raise_error(Igniter::CompileError, /tool_loop_policy must be :ignore, :resolved, or :complete/)
    end

    it "raises CompileError when session_policy is used without reply: :stream" do
      expect do
        Class.new(Igniter::Contract) do
          define do
            input :name
            agent :greeting, via: :greeter, message: :greet, session_policy: :manual, inputs: { name: :name }
          end
        end
      end.to raise_error(Igniter::CompileError, /session_policy requires reply: :stream/)
    end

    it "raises CompileError when session_policy is unsupported" do
      expect do
        Class.new(Igniter::Contract) do
          define do
            input :name
            agent :greeting, via: :greeter, message: :greet, reply: :stream, session_policy: :durable, inputs: { name: :name }
          end
        end
      end.to raise_error(Igniter::CompileError, /session_policy must be :interactive, :single_turn, or :manual/)
    end

    it "compiles stream agents with default and custom finalizers" do
      contract_class = Class.new(Igniter::Contract) do
        define do
          input :name
          agent :default_summary, via: :writer, message: :summarize, reply: :stream, inputs: { name: :name }
          agent :custom_summary, via: :writer, message: :summarize, reply: :stream, finalizer: :array, tool_loop_policy: :resolved, session_policy: :manual, inputs: { name: :name }
          output :default_summary
          output :custom_summary
        end
      end

      expect(contract_class.compiled_graph.fetch_node(:default_summary).finalizer).to eq(:join)
      expect(contract_class.compiled_graph.fetch_node(:default_summary).tool_loop_policy).to eq(:complete)
      expect(contract_class.compiled_graph.fetch_node(:default_summary).session_policy).to eq(:interactive)
      expect(contract_class.compiled_graph.fetch_node(:custom_summary).finalizer).to eq(:array)
      expect(contract_class.compiled_graph.fetch_node(:custom_summary).tool_loop_policy).to eq(:resolved)
      expect(contract_class.compiled_graph.fetch_node(:custom_summary).session_policy).to eq(:manual)
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
        payload: { event: Igniter::Runtime::AgentSession.final_event(value: "Hello, Alice") }
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
            event: Igniter::Runtime::AgentSession.status_event(status: "thinking")
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
              Igniter::Runtime::AgentSession.tool_call_event(name: :search, arguments: { q: "Alice" }),
              Igniter::Runtime::AgentSession.tool_result_event(name: :search, result: { hits: 1 }),
              Igniter::Runtime::AgentSession.chunk_event(chunk: "Hello, Alice")
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
            type: :tool_result,
            name: :search,
            result: { hits: 1 }
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
            type: :tool_result,
            name: :search,
            result: { hits: 1 }
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
        payload: { event: Igniter::Runtime::AgentSession.final_event(value: stream_value.events) }
      )
    end

    it "exposes canonical tool-loop helpers on stream results" do
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
            events: [
              Igniter::Runtime::AgentSession.status_event(status: "planning"),
              Igniter::Runtime::AgentSession.tool_call_event(name: :search, arguments: { q: "Alice" }, call_id: "call-1"),
              Igniter::Runtime::AgentSession.tool_result_event(name: :search, result: { hits: 3 }, call_id: "call-1"),
              Igniter::Runtime::AgentSession.artifact_event(name: :notes, uri: "memory://notes/1"),
              Igniter::Runtime::AgentSession.chunk_event(chunk: "Hello, Alice")
            ]
          }
        },
        phase: :streaming
      )

      stream_value = contract.result.summary
      runtime_value = contract.execution.states[:summary][:value]

      expect(stream_value.statuses).to eq(["planning"])
      expect(stream_value.tool_calls).to eq(
        [
          {
            turn: 2,
            source: :agent,
            message_name: :summarize,
            type: :tool_call,
            name: :search,
            arguments: { q: "Alice" },
            call_id: "call-1"
          }
        ]
      )
      expect(stream_value.tool_results).to eq(
        [
          {
            turn: 2,
            source: :agent,
            message_name: :summarize,
            type: :tool_result,
            name: :search,
            result: { hits: 3 },
            call_id: "call-1"
          }
        ]
      )
      expect(stream_value.artifacts).to eq(
        [
          {
            turn: 2,
            source: :agent,
            message_name: :summarize,
            type: :artifact,
            name: :notes,
            uri: "memory://notes/1"
          }
        ]
      )
      expect(stream_value.final_event).to be_nil
      expect(runtime_value).to include(
        status_count: 1,
        tool_call_count: 1,
        tool_result_count: 1,
        artifact_count: 1
      )

      contract.execution.resume_agent_session(session.token)

      final_value = contract.result.summary
      expect(final_value.last).to include(type: :chunk, chunk: "Hello, Alice")
      expect(contract.execution.states[:summary].dig(:details, :agent_session, :last_reply)).to include(
        payload: {
          event: Igniter::Runtime::AgentSession.final_event(value: stream_value.events)
        }
      )
    end

    it "correlates tool interactions by call_id and tool-name fallback" do
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
            events: [
              Igniter::Runtime::AgentSession.tool_call_event(name: :search, arguments: { q: "Alice" }, call_id: "search-1"),
              Igniter::Runtime::AgentSession.tool_result_event(name: :search, result: { hits: 3 }, call_id: "search-1"),
              Igniter::Runtime::AgentSession.tool_call_event(name: :fetch, arguments: { url: "https://example.test" }),
              Igniter::Runtime::AgentSession.tool_result_event(name: :fetch, result: { status: 200 }),
              Igniter::Runtime::AgentSession.tool_result_event(name: :summarize, result: { orphan: true })
            ]
          }
        },
        phase: :streaming
      )

      stream_value = contract.result.summary
      runtime_value = contract.execution.states[:summary][:value]

      expect(stream_value.tool_interactions).to eq(
        [
          {
            key: "call_id:search-1",
            call_id: "search-1",
            tool_name: :search,
            call: {
              turn: 2,
              source: :agent,
              message_name: :summarize,
              type: :tool_call,
              name: :search,
              arguments: { q: "Alice" },
              call_id: "search-1"
            },
            results: [
              {
                turn: 2,
                source: :agent,
                message_name: :summarize,
                type: :tool_result,
                name: :search,
                result: { hits: 3 },
                call_id: "search-1"
              }
            ],
            status: :completed,
            complete: true
          },
          {
            key: "tool:fetch:1",
            call_id: nil,
            tool_name: :fetch,
            call: {
              turn: 2,
              source: :agent,
              message_name: :summarize,
              type: :tool_call,
              name: :fetch,
              arguments: { url: "https://example.test" }
            },
            results: [
              {
                turn: 2,
                source: :agent,
                message_name: :summarize,
                type: :tool_result,
                name: :fetch,
                result: { status: 200 }
              }
            ],
            status: :completed,
            complete: true
          },
          {
            key: "orphan_result:summarize:5",
            call_id: nil,
            tool_name: :summarize,
            call: nil,
            results: [
              {
                turn: 2,
                source: :agent,
                message_name: :summarize,
                type: :tool_result,
                name: :summarize,
                result: { orphan: true }
              }
            ],
            status: :orphan_result,
            complete: false
          }
        ]
      )
      expect(stream_value.completed_tool_interactions.map { |interaction| interaction[:tool_name] }).to eq(%i[search fetch])
      expect(stream_value.pending_tool_interactions).to eq([])
      expect(stream_value.orphan_tool_interactions.map { |interaction| interaction[:key] }).to eq(["orphan_result:summarize:5"])
      expect(stream_value.all_tool_calls_resolved?).to be true
      expect(stream_value.tool_loop_consistent?).to be false
      expect(stream_value.tool_loop_complete?).to be false
      expect(stream_value.tool_loop_status).to eq(:orphaned)
      expect(stream_value.tool_loop_summary).to eq(
        {
          status: :orphaned,
          total: 3,
          pending: 0,
          completed: 2,
          orphaned: 1,
          resolved: true,
          consistent: false,
          complete: false,
          open_keys: [],
          orphan_keys: ["orphan_result:summarize:5"]
        }
      )
      expect(runtime_value).to include(
        tool_interaction_count: 3,
        completed_tool_interaction_count: 2,
        pending_tool_interaction_count: 0,
        orphan_tool_interaction_count: 1,
        tool_loop_status: :orphaned,
        tool_loop_complete: false,
        tool_call_count: 2,
        tool_result_count: 3
      )
    end

    it "reports open tool loops when calls do not yet have results" do
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
            events: [
              Igniter::Runtime::AgentSession.tool_call_event(name: :search, arguments: { q: "Alice" }, call_id: "search-1")
            ]
          }
        },
        phase: :streaming
      )

      stream_value = contract.result.summary
      runtime_value = contract.execution.states[:summary][:value]

      expect(stream_value.pending_tool_interactions.map { |interaction| interaction[:key] }).to eq(["call_id:search-1"])
      expect(stream_value.completed_tool_interactions).to eq([])
      expect(stream_value.orphan_tool_interactions).to eq([])
      expect(stream_value.all_tool_calls_resolved?).to be false
      expect(stream_value.tool_loop_consistent?).to be true
      expect(stream_value.tool_loop_complete?).to be false
      expect(stream_value.tool_loop_status).to eq(:open)
      expect(stream_value.tool_loop_summary).to eq(
        {
          status: :open,
          total: 1,
          pending: 1,
          completed: 0,
          orphaned: 0,
          resolved: false,
          consistent: true,
          complete: false,
          open_keys: ["call_id:search-1"],
          orphan_keys: []
        }
      )
      expect(runtime_value).to include(
        tool_interaction_count: 1,
        pending_tool_interaction_count: 1,
        completed_tool_interaction_count: 0,
        orphan_tool_interaction_count: 0,
        tool_loop_status: :open,
        tool_loop_complete: false
      )
    end

    it "blocks auto-finalization while the tool loop is still open" do
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
            events: [
              Igniter::Runtime::AgentSession.tool_call_event(name: :search, arguments: { q: "Alice" }, call_id: "search-1")
            ]
          }
        },
        phase: :streaming
      )

      expect do
        contract.execution.resume_agent_session(session.token)
      end.to raise_error(Igniter::ResolutionError, /cannot auto-finalize while tool loop is :open/)

      contract.execution.resume_agent_session(session.token, value: [{ forced: true }])
      expect(contract.result.summary).to eq([{ forced: true }])
    end

    it "blocks auto-finalization while the tool loop is orphaned" do
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
            events: [
              Igniter::Runtime::AgentSession.tool_result_event(name: :search, result: { orphan: true })
            ]
          }
        },
        phase: :streaming
      )

      expect do
        contract.execution.resume_agent_session(session.token)
      end.to raise_error(Igniter::ResolutionError, /cannot auto-finalize while tool loop is :orphaned under policy :complete/)
    end

    it "allows orphaned tool loops to auto-finalize under policy :resolved" do
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
          agent :summary, via: :writer, message: :summarize, reply: :stream, finalizer: :events, tool_loop_policy: :resolved, inputs: { name: :name }
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
            events: [
              Igniter::Runtime::AgentSession.tool_result_event(name: :search, result: { orphan: true })
            ]
          }
        },
        phase: :streaming
      )

      contract.execution.resume_agent_session(session.token)

      expect(contract.result.summary).to eq(
        [
          {
            turn: 2,
            source: :agent,
            message_name: :summarize,
            type: :tool_result,
            name: :search,
            result: { orphan: true }
          }
        ]
      )
    end

    it "allows open tool loops to auto-finalize under policy :ignore" do
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
          agent :summary, via: :writer, message: :summarize, reply: :stream, finalizer: :events, tool_loop_policy: :ignore, inputs: { name: :name }
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
            events: [
              Igniter::Runtime::AgentSession.tool_call_event(name: :search, arguments: { q: "Alice" }, call_id: "search-1")
            ]
          }
        },
        phase: :streaming
      )

      contract.execution.resume_agent_session(session.token)

      expect(contract.result.summary).to eq(
        [
          {
            turn: 2,
            source: :agent,
            message_name: :summarize,
            type: :tool_call,
            name: :search,
            arguments: { q: "Alice" },
            call_id: "search-1"
          }
        ]
      )
    end

    it "blocks auto-finalization under session_policy :manual even when tool loop is complete" do
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
          agent :summary, via: :writer, message: :summarize, reply: :stream, session_policy: :manual, inputs: { name: :name }
          output :summary
        end
      end

      contract = contract_class.new(name: "Alice")
      contract.result.summary
      session = contract.execution.agent_sessions.first

      contract.execution.continue_agent_session(
        session,
        payload: {},
        reply: { turn: 2, kind: :reply, name: :summarize, source: :agent, payload: { chunk: "Hello" } },
        phase: :streaming
      )

      expect do
        contract.execution.resume_agent_session(session.token)
      end.to raise_error(Igniter::ResolutionError, /requires explicit value under session_policy :manual/)

      contract.execution.resume_agent_session(session.token, value: "Hello")
      expect(contract.result.summary).to eq("Hello")
    end

    it "blocks continuation under session_policy :single_turn" do
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
          agent :summary, via: :writer, message: :summarize, reply: :stream, session_policy: :single_turn, inputs: { name: :name }
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
          reply: { turn: 2, kind: :reply, name: :summarize, source: :agent, payload: { chunk: "Hello" } },
          phase: :streaming
        )
      end.to raise_error(Igniter::ResolutionError, /does not allow continuation under session_policy :single_turn/)
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
