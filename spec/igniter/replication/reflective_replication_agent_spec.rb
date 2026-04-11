# frozen_string_literal: true

require "spec_helper"
require "igniter/integrations/agents"
require "igniter/replication"
require "igniter/memory"

RSpec.describe Igniter::Replication::ReflectiveReplicationAgent do
  let(:topology)     { Igniter::Replication::NetworkTopology.new }
  let(:bootstrapper) { instance_double(Igniter::Replication::Bootstrappers::Git) }
  let(:session)      { instance_double(Igniter::Replication::SSHSession) }

  before do
    described_class.enable_class_memory store: Igniter::Memory::Stores::InMemory.new
    allow(Igniter::Replication::SSHSession).to receive(:new).and_return(session)
    allow(Igniter::Replication).to receive(:bootstrapper_for).and_return(bootstrapper)
    allow(bootstrapper).to receive(:install)
    allow(bootstrapper).to receive(:start)
    allow(bootstrapper).to receive(:verify).and_return(true)
  end

  after { described_class.reset_class_memory! }

  def default_state(overrides = {})
    { topology: topology, host_pool: [], required_roles: [],
      last_plan: nil, last_reflection: nil }.merge(overrides)
  end

  def call_handler(type, state: default_state, payload: {})
    described_class.handlers[type].call(state: state, payload: payload)
  end

  # ── Class-level memory DSL ─────────────────────────────────────────────────

  describe ".enable_class_memory" do
    it "activates class memory" do
      expect(described_class.class_memory_enabled?).to be true
    end

    it "provides an AgentMemory facade" do
      expect(described_class.class_memory).to be_a(Igniter::Memory::AgentMemory)
    end

    it "re-enables with a new store on repeated calls" do
      store2 = Igniter::Memory::Stores::InMemory.new
      described_class.enable_class_memory store: store2
      expect(described_class.class_memory_enabled?).to be true
    end
  end

  describe ".class_memory_enabled? after reset" do
    it "returns false" do
      described_class.reset_class_memory!
      expect(described_class.class_memory_enabled?).to be false
    end
  end

  # ── Handler: :replicate ───────────────────────────────────────────────────

  describe "on :replicate" do
    it "has a :replicate handler registered" do
      expect(described_class.handlers).to have_key(:replicate)
    end

    it "records a replication_event episode on success" do
      call_handler(:replicate,
        payload: { host: "10.0.0.1", user: "deploy", strategy: :git,
                   bootstrapper_options: {} })
      episodes = described_class.class_memory.recent(last: 5, type: :replication_event)
      expect(episodes).not_to be_empty
    end

    it "records a failure episode when bootstrapper raises SSHError" do
      allow(bootstrapper).to receive(:install).and_raise(
        Igniter::Replication::SSHSession::SSHError.new("timeout")
      )
      call_handler(:replicate,
        payload: { host: "10.0.0.1", user: "deploy", strategy: :git,
                   bootstrapper_options: {} })
      failures = described_class.class_memory
                                .recent(last: 5, type: :replication_event)
                                .select { |e| e.outcome == "failure" }
      expect(failures).not_to be_empty
    end
  end

  # ── Handler: :assess_network ───────────────────────────────────────────────

  describe "on :assess_network" do
    it "has an :assess_network handler" do
      expect(described_class.handlers).to have_key(:assess_network)
    end

    it "returns a Hash with :topology key" do
      result = call_handler(:assess_network)
      expect(result).to include(:topology)
    end

    it "registers a new node when :replicate_role action fires" do
      Igniter::Replication::RoleRegistry.reset!
      Igniter::Replication::RoleRegistry.define(:worker)
      result = call_handler(:assess_network,
        state:   default_state(host_pool: ["10.0.0.5"], required_roles: [:worker]),
        payload: {}
      )
      expect(result[:topology].nodes(role: :worker)).not_to be_empty
    ensure
      Igniter::Replication::RoleRegistry.reset!
    end

    it "removes an unhealthy node when :retire_node action fires" do
      topology.register(node_id: "bad", host: "10.0.0.9", role: :worker)
      topology.mark_unhealthy(node_id: "bad")
      result = call_handler(:assess_network)
      expect(result[:topology].node_ids).not_to include("bad")
    end

    it "stores the last plan in state" do
      result = call_handler(:assess_network)
      expect(result[:last_plan]).to be_a(Hash)
    end

    it "records an :assessment episode in memory" do
      call_handler(:assess_network)
      episodes = described_class.class_memory.recent(last: 5, type: :assessment)
      expect(episodes).not_to be_empty
    end
  end

  # ── Handler: :reflect ─────────────────────────────────────────────────────

  describe "on :reflect" do
    it "has a :reflect handler" do
      expect(described_class.handlers).to have_key(:reflect)
    end

    it "stores last_reflection in state" do
      result = call_handler(:reflect)
      expect(result).to include(:last_reflection)
    end

    it "returns state unchanged when memory is disabled" do
      described_class.reset_class_memory!
      initial = default_state
      result  = call_handler(:reflect, state: initial)
      expect(result).to eq(initial)
    end
  end

  # ── Handler: :register_node ───────────────────────────────────────────────

  describe "on :register_node" do
    it "adds the node to the topology in state" do
      result = call_handler(:register_node,
        payload: { node_id: "new-node", host: "10.0.0.7", role: :worker }
      )
      expect(result[:topology].nodes(role: :worker).map(&:node_id)).to include("new-node")
    end

    it "creates a topology lazily when state has nil" do
      result = call_handler(:register_node,
        state:   default_state(topology: nil),
        payload: { node_id: "n1", host: "10.0.0.1" }
      )
      expect(result[:topology]).to be_a(Igniter::Replication::NetworkTopology)
    end
  end

  # ── Handler: :node_heartbeat ──────────────────────────────────────────────

  describe "on :node_heartbeat" do
    it "returns state" do
      topology.register(node_id: "n1", host: "10.0.0.1")
      result = call_handler(:node_heartbeat, payload: { node_id: "n1" })
      expect(result).to be_a(Hash)
    end

    it "tolerates a nil topology gracefully" do
      expect do
        call_handler(:node_heartbeat,
          state:   default_state(topology: nil),
          payload: { node_id: "n1" }
        )
      end.not_to raise_error
    end
  end

  # ── Handler: :signal_scale ────────────────────────────────────────────────

  describe "on :signal_scale" do
    it "records a :scale_signal episode" do
      call_handler(:signal_scale, payload: { role: :worker })
      signals = described_class.class_memory.recent(last: 5, type: :scale_signal)
      expect(signals.map(&:content)).to include("scale_out:worker")
    end
  end

  # ── deliver ───────────────────────────────────────────────────────────────

  describe "#deliver" do
    let(:agent) { described_class.new }

    it "records replication_event episodes" do
      agent.deliver(:replication_started, host: "10.0.0.1")
      episodes = described_class.class_memory.recent(last: 5, type: :replication_event)
      expect(episodes).not_to be_empty
    end

    it "records outcome as failure for :replication_failed" do
      agent.deliver(:replication_failed, host: "10.0.0.1", error: "timeout")
      failures = described_class.class_memory
                                .recent(last: 5, type: :replication_event)
                                .select { |e| e.outcome == "failure" }
      expect(failures).not_to be_empty
    end
  end

  # ── initial_state ──────────────────────────────────────────────────────────

  describe "default_state" do
    it "includes topology, host_pool, required_roles, last_plan, last_reflection" do
      expect(described_class.default_state.keys).to include(
        :topology, :host_pool, :required_roles, :last_plan, :last_reflection
      )
    end
  end
end
