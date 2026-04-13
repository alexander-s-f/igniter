# frozen_string_literal: true

require "spec_helper"
require "igniter/cluster"

RSpec.describe Igniter::Cluster::Ownership do
  after { Igniter::Cluster::Ownership.reset! }

  describe Igniter::Cluster::Ownership::Claim do
    it "stores entity identity, owner, metadata, and timestamps" do
      claim = described_class.new(
        entity_type: :voice_session,
        entity_id: "abc123",
        owner: :edge_1,
        metadata: { priority: "high" }
      )

      expect(claim.entity_type).to eq("voice_session")
      expect(claim.entity_id).to eq("abc123")
      expect(claim.owner).to eq("edge_1")
      expect(claim.metadata).to eq("priority" => "high")
      expect(claim.key).to eq("voice_session:abc123")
      expect(claim).to be_frozen
    end
  end

  describe Igniter::Cluster::Ownership::Registry do
    subject(:registry) { described_class.new }

    it "claims and looks up ownership" do
      claim = registry.claim(:voice_session, "abc123", owner: :edge_1, metadata: { source: "esp32" })

      expect(registry.lookup(:voice_session, "abc123")).to eq(claim)
      expect(registry.owner_for(:voice_session, "abc123")).to eq("edge_1")
      expect(registry.claimed?(:voice_session, "abc123")).to be true
    end

    it "releases claims" do
      registry.claim(:voice_session, "abc123", owner: :edge_1)

      released = registry.release(:voice_session, "abc123")

      expect(released.owner).to eq("edge_1")
      expect(registry.lookup(:voice_session, "abc123")).to be_nil
    end

    it "does not release when owner guard does not match" do
      registry.claim(:voice_session, "abc123", owner: :edge_1)

      expect(registry.release(:voice_session, "abc123", owner: :edge_2)).to be_nil
      expect(registry.owner_for(:voice_session, "abc123")).to eq("edge_1")
    end

    it "lists claims for an owner" do
      registry.claim(:voice_session, "a", owner: :edge_1)
      registry.claim(:voice_session, "b", owner: :edge_1)
      registry.claim(:camera_event, "c", owner: :edge_2)

      expect(registry.claims_for_owner(:edge_1).map(&:entity_id)).to contain_exactly("a", "b")
    end
  end

  describe Igniter::Cluster::Ownership::Resolver do
    let(:registry) { Igniter::Cluster::Ownership::Registry.new }
    let(:mesh_router) { instance_double(Igniter::Cluster::Mesh::Router) }
    subject(:resolver) { described_class.new(registry: registry, mesh_router: mesh_router) }

    it "routes to the owner when a claim exists" do
      registry.claim(:voice_session, "abc123", owner: :edge_1)
      allow(mesh_router).to receive(:resolve_pinned).with("edge_1").and_return("http://edge-1:4570")

      result = resolver.resolve(:voice_session, "abc123")

      expect(result).to include(
        mode: :owner,
        owner: "edge_1",
        url: "http://edge-1:4570"
      )
    end

    it "falls back to capability routing when configured" do
      deferred = Igniter::Runtime::DeferredResult.build(payload: {}, source_node: :x, waiting_on: :x)
      allow(mesh_router).to receive(:find_peer_for).with(:edge_gateway, deferred).and_return("http://edge-2:4570")

      result = resolver.resolve(:voice_session, "missing", fallback_capability: :edge_gateway, deferred_result: deferred)

      expect(result).to include(
        mode: :capability,
        owner: nil,
        url: "http://edge-2:4570"
      )
    end

    it "raises NoOwnerError when no claim or fallback exists" do
      expect {
        resolver.resolve(:voice_session, "missing")
      }.to raise_error(Igniter::Cluster::Ownership::NoOwnerError)
    end
  end

  describe ".claim / .resolve_url" do
    it "provides module-level access to the ownership registry and resolver" do
      described_class.claim(:voice_session, "abc123", owner: :edge_1)
      router = instance_double(Igniter::Cluster::Mesh::Router)
      allow(Igniter::Cluster::Mesh).to receive(:router).and_return(router)
      allow(router).to receive(:resolve_pinned).with("edge_1").and_return("http://edge-1:4570")

      expect(described_class.owner_for(:voice_session, "abc123")).to eq("edge_1")
      expect(described_class.resolve_url(:voice_session, "abc123")).to eq("http://edge-1:4570")
    end
  end
end
