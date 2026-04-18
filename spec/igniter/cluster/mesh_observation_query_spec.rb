# frozen_string_literal: true

require "spec_helper"
require "igniter/cluster"

RSpec.describe Igniter::Cluster::Mesh::ObservationQuery do
  let(:now) { Time.utc(2026, 4, 18, 12, 0, 0) }
  let(:observed_at) { Time.utc(2026, 4, 18, 11, 59, 0).iso8601 }

  def make_obs(name:, caps: [], tags: [], state: {}, locality: {}, trust_status: nil)
    meta = { mesh: { observed_at: observed_at, confidence: 1.0, hops: 0, origin: name } }
    meta[:mesh_state]    = state    unless state.empty?
    meta[:mesh_locality] = locality unless locality.empty?
    meta[:mesh_trust]    = { status: trust_status.to_s, trusted: trust_status == :trusted } if trust_status

    Igniter::Cluster::Mesh::NodeObservation.new(
      name:         name,
      url:          "http://#{name}:4567",
      capabilities: caps,
      tags:         tags,
      metadata:     Igniter::Cluster::Mesh::PeerMetadata.runtime(meta, now: now)
    )
  end

  let(:obs_a) do
    make_obs(name: "node-a", caps: [:database, :orders], tags: [:linux],
             state: { health: "healthy", load_cpu: 0.3, load_memory: 0.4, concurrency: 2, queue_depth: 0 },
             locality: { region: "us-east-1", zone: "us-east-1a" },
             trust_status: :trusted)
  end

  let(:obs_b) do
    make_obs(name: "node-b", caps: [:database], tags: [:linux],
             state: { health: "healthy", load_cpu: 0.7, load_memory: 0.8, concurrency: 8, queue_depth: 3 },
             locality: { region: "us-east-1", zone: "us-east-1b" },
             trust_status: :trusted)
  end

  let(:obs_c) do
    make_obs(name: "node-c", caps: [:orders, :analytics], tags: [:darwin],
             state: { health: "degraded", load_cpu: 0.5, concurrency: 1 },
             locality: { region: "eu-central-1", zone: "eu-central-1a" },
             trust_status: :unknown)
  end

  let(:obs_d) do
    make_obs(name: "node-d", caps: [:database], tags: [:linux],
             state: { health: "healthy", load_cpu: 0.1, concurrency: 0 },
             locality: { region: "us-east-1", zone: "us-east-1a" })
  end

  let(:observations) { [obs_a, obs_b, obs_c, obs_d] }

  subject(:query) { described_class.new(observations) }

  # ── Immutability ──────────────────────────────────────────────────────────────

  describe "immutability" do
    it "is frozen" do
      expect(query).to be_frozen
    end

    it "each filter method returns a new query" do
      q1 = query.with(:database)
      q2 = query.with(:orders)
      expect(q1.object_id).not_to eq(q2.object_id)
      expect(query.object_id).not_to eq(q1.object_id)
    end

    it "original query is unaffected by chain" do
      _derived = query.with(:database).healthy.limit(1)
      expect(query.to_a.size).to eq(4)
    end
  end

  # ── Capabilities dimension ────────────────────────────────────────────────────

  describe "#with" do
    it "filters to nodes that have all given capabilities" do
      result = query.with(:database).to_a
      expect(result.map(&:name)).to contain_exactly("node-a", "node-b", "node-d")
    end

    it "requires all capabilities when multiple are given" do
      result = query.with(:database, :orders).to_a
      expect(result.map(&:name)).to eq(["node-a"])
    end
  end

  describe "#without" do
    it "excludes nodes that have any of the given capabilities" do
      result = query.without(:analytics).to_a
      expect(result.map(&:name)).not_to include("node-c")
    end
  end

  describe "#tagged" do
    it "filters by tags" do
      result = query.tagged(:linux).to_a
      expect(result.map(&:name)).to contain_exactly("node-a", "node-b", "node-d")
    end
  end

  # ── Trust dimension ───────────────────────────────────────────────────────────

  describe "#trusted" do
    it "filters to trusted nodes" do
      result = query.trusted.to_a
      expect(result.map(&:name)).to contain_exactly("node-a", "node-b")
    end
  end

  describe "#trust_status_in" do
    it "filters by specific trust statuses" do
      result = query.trust_status_in(:unknown).to_a
      expect(result.map(&:name)).to eq(["node-c"])
    end
  end

  # ── State dimension ───────────────────────────────────────────────────────────

  describe "#healthy" do
    it "filters to nodes with :healthy health" do
      result = query.healthy.to_a
      expect(result.map(&:name)).to contain_exactly("node-a", "node-b", "node-d")
    end
  end

  describe "#health_in" do
    it "filters by given health statuses" do
      result = query.health_in(:degraded).to_a
      expect(result.map(&:name)).to eq(["node-c"])
    end
  end

  describe "#max_load_cpu" do
    it "excludes nodes above the threshold" do
      result = query.max_load_cpu(0.5).to_a
      expect(result.map(&:name)).to contain_exactly("node-a", "node-c", "node-d")
    end
  end

  describe "#max_concurrency" do
    it "filters by max active executions" do
      result = query.max_concurrency(2).to_a
      expect(result.map(&:name)).to contain_exactly("node-a", "node-c", "node-d")
    end
  end

  # ── Locality dimension ────────────────────────────────────────────────────────

  describe "#in_region" do
    it "filters to nodes in a region" do
      result = query.in_region("us-east-1").to_a
      expect(result.map(&:name)).to contain_exactly("node-a", "node-b", "node-d")
    end
  end

  describe "#in_zone" do
    it "filters to nodes in a zone" do
      result = query.in_zone("us-east-1a").to_a
      expect(result.map(&:name)).to contain_exactly("node-a", "node-d")
    end
  end

  # ── General predicate ─────────────────────────────────────────────────────────

  describe "#where" do
    it "filters by arbitrary predicate" do
      result = query.where { |o| o.name.start_with?("node-a") }.to_a
      expect(result.map(&:name)).to eq(["node-a"])
    end

    it "raises when called without a block" do
      expect { query.where }.to raise_error(ArgumentError, /requires a block/)
    end
  end

  # ── CapabilityQuery passthrough ───────────────────────────────────────────────

  describe "#matching" do
    it "delegates to CapabilityQuery" do
      result = query.matching(all_of: [:database], tags: [:linux]).to_a
      expect(result.map(&:name)).to contain_exactly("node-a", "node-b", "node-d")
    end
  end

  # ── Ordering ──────────────────────────────────────────────────────────────────

  describe "#order_by" do
    it "orders by load_cpu ascending" do
      result = query.with(:database).order_by(:load_cpu).to_a
      expect(result.map(&:name)).to eq(%w[node-d node-a node-b])
    end

    it "orders by load_cpu descending" do
      result = query.with(:database).order_by(:load_cpu, direction: :desc).to_a
      expect(result.map(&:name)).to eq(%w[node-b node-a node-d])
    end

    it "applies secondary ordering" do
      result = query.with(:database).order_by(:load_cpu).order_by(:concurrency, direction: :desc).to_a
      expect(result.first.name).to eq("node-d")
    end

    it "places nil values last in :asc order" do
      obs_no_load = make_obs(name: "node-e", caps: [:database])
      q = described_class.new([obs_a, obs_no_load])
      result = q.with(:database).order_by(:load_cpu).to_a
      expect(result.last.name).to eq("node-e")
    end

    it "raises for unknown dimension" do
      expect { query.order_by(:unknown_dim) }.to raise_error(ArgumentError, /Unknown ordering dimension/)
    end

    it "accepts a Proc as ordering dimension" do
      result = query.with(:database).order_by(->(o) { o.concurrency }).to_a
      expect(result.first.name).to eq("node-d")
    end
  end

  # ── Limiting ──────────────────────────────────────────────────────────────────

  describe "#limit" do
    it "restricts result count" do
      result = query.limit(2).to_a
      expect(result.size).to eq(2)
    end
  end

  # ── Enumerable ───────────────────────────────────────────────────────────────

  describe "Enumerable" do
    it "#each yields matching observations" do
      names = []
      query.with(:database).each { |o| names << o.name }
      expect(names).to contain_exactly("node-a", "node-b", "node-d")
    end

    it "#count returns match count without materialising array" do
      expect(query.with(:database).count).to eq(3)
    end

    it "#empty? is false when there are matches" do
      expect(query.with(:database).empty?).to be false
    end

    it "#empty? is true when nothing matches" do
      expect(query.with(:nonexistent_cap).empty?).to be true
    end

    it "#first returns the first match" do
      result = query.with(:database).order_by(:load_cpu).first
      expect(result.name).to eq("node-d")
    end

    it "#first(n) returns n matches" do
      result = query.with(:database).order_by(:load_cpu).first(2)
      expect(result.map(&:name)).to eq(%w[node-d node-a])
    end

    it "supports map via Enumerable" do
      names = query.with(:database).map(&:name)
      expect(names).to contain_exactly("node-a", "node-b", "node-d")
    end
  end

  # ── Chaining ─────────────────────────────────────────────────────────────────

  describe "composed filter chains" do
    it "selects cheapest trusted database node in us-east-1a" do
      result = query
        .with(:database)
        .trusted
        .in_zone("us-east-1a")
        .max_load_cpu(0.5)
        .order_by(:load_cpu)
        .first

      expect(result.name).to eq("node-a")
    end

    it "returns empty when no node satisfies all constraints" do
      expect(query.with(:database).in_zone("ap-southeast-1").to_a).to be_empty
    end
  end

  # ── #explain ─────────────────────────────────────────────────────────────────

  describe "#explain" do
    it "describes the query" do
      explanation = query.with(:database).max_load_cpu(0.5).order_by(:load_cpu).limit(2).explain
      expect(explanation).to include("ObservationQuery")
      expect(explanation).to include("filters: 2")
      expect(explanation).to include("order_by: load_cpu asc")
      expect(explanation).to include("limit: 2")
    end
  end

  # ── PeerRegistry integration ──────────────────────────────────────────────────

  describe "PeerRegistry#query" do
    let(:registry) { Igniter::Cluster::Mesh::PeerRegistry.new }

    let(:peer_a) do
      Igniter::Cluster::Mesh::Peer.new(
        name: "node-a", url: "http://node-a:4567",
        capabilities: [:database], tags: [],
        metadata: {
          mesh: { observed_at: observed_at, confidence: 1.0, hops: 0, origin: "node-a" },
          mesh_state: { health: "healthy", load_cpu: 0.2 }
        }
      )
    end

    let(:peer_b) do
      Igniter::Cluster::Mesh::Peer.new(
        name: "node-b", url: "http://node-b:4567",
        capabilities: [:orders], tags: []
      )
    end

    before do
      registry.register(peer_a)
      registry.register(peer_b)
    end

    it "returns an ObservationQuery" do
      expect(registry.query(now: now)).to be_a(described_class)
    end

    it "chains correctly over registry observations" do
      result = registry.query(now: now).with(:database).healthy.to_a
      expect(result.map(&:name)).to eq(["node-a"])
    end
  end
end
