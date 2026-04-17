# frozen_string_literal: true

require "spec_helper"
require "igniter/cluster"

RSpec.describe "Igniter Cluster identity and trust" do
  let(:identity) { Igniter::Cluster::Identity::NodeIdentity.generate(node_id: "seed-node") }
  let(:manifest) do
    Igniter::Cluster::Identity::Manifest.build(
      identity: identity,
      peer_name: "seed-node",
      url: "http://seed:4567",
      capabilities: %i[mesh_seed notes_api],
      tags: %i[local seed],
      metadata: { region: "local" },
      contracts: ["SyncNotes"]
    )
  end

  it "builds a signed manifest that verifies with its own public key" do
    expect(manifest.verify_signature).to be(true)
    expect(manifest.capability_attestation).not_to be_nil
    expect(manifest.capability_attestation.verify_signature).to be(true)
    expect(manifest.identity_summary).to include(
      node_id: "seed-node",
      algorithm: "rsa-sha256",
      fingerprint: kind_of(String)
    )
  end

  it "assesses manifests as trusted when the trust store knows the public key" do
    trust_store = Igniter::Cluster::Trust::TrustStore.new(
      [
        { node_id: "seed-node", public_key: identity.public_key_pem, label: "bootstrap" }
      ]
    )

    assessment = Igniter::Cluster::Trust::Verifier.assess(manifest, trust_store: trust_store)

    expect(assessment.to_h).to include(
      status: :trusted,
      trusted: true,
      node_id: "seed-node",
      peer_name: "seed-node"
    )
  end

  it "wraps relayed peer metadata with mesh_identity and mesh_trust summaries" do
    trust_store = Igniter::Cluster::Trust::TrustStore.new(
      [
        { node_id: "seed-node", public_key: identity.public_key_pem, label: "bootstrap" }
      ]
    )

    envelope = Igniter::Cluster::Mesh::PeerIdentityEnvelope.build(
      source: manifest.to_h,
      trust_store: trust_store
    )

    expect(envelope).to include(
      name: "seed-node",
      url: "http://seed:4567",
      capabilities: %i[mesh_seed notes_api],
      tags: %i[local seed]
    )
    expect(envelope.dig(:metadata, :mesh_identity)).to include(
      node_id: "seed-node",
      peer_name: "seed-node",
      fingerprint: manifest.fingerprint
    )
    expect(envelope.dig(:metadata, :mesh_trust)).to include(
      status: :trusted,
      trusted: true
    )
    expect(envelope.dig(:metadata, :mesh_capabilities)).to include(
      node_id: "seed-node",
      observed_at: kind_of(String),
      capabilities: %i[mesh_seed notes_api],
      tags: %i[local seed]
    )
    expect(envelope.dig(:metadata, :mesh_capabilities, :trust)).to include(
      status: :trusted,
      trusted: true
    )
  end

  it "builds a trust admission plan for an unknown discovered peer and applies it after approval" do
    Igniter::Cluster::Mesh.reset!
    trust_store = Igniter::Cluster::Trust::TrustStore.new(
      [
        { node_id: "seed-node", public_key: identity.public_key_pem, label: "bootstrap" }
      ]
    )

    discovered_identity = Igniter::Cluster::Identity::NodeIdentity.generate(node_id: "edge-node")
    discovered_manifest = Igniter::Cluster::Identity::Manifest.build(
      identity: discovered_identity,
      peer_name: "edge-node",
      url: "http://edge:4567",
      capabilities: [:speech_io],
      tags: [:edge],
      metadata: { region: "local" },
      contracts: []
    )

    Igniter::Cluster::Mesh.configure do |c|
      c.peer_name = "seed-node"
      c.identity = identity
      c.trust_store = trust_store
      attributes = Igniter::Cluster::Mesh::PeerIdentityEnvelope.build(
        source: discovered_manifest.to_h,
        trust_store: trust_store
      )
      c.peer_registry.register(
        Igniter::Cluster::Mesh::Peer.new(
          name: attributes[:name],
          url: attributes[:url],
          capabilities: attributes[:capabilities],
          tags: attributes[:tags],
          metadata: attributes[:metadata]
        )
      )
    end

    plan = Igniter::Cluster::Mesh.trust_admission_plan("edge-node", label: "lab-admitted")
    expect(plan.summary).to include(status: :pending_approval, peer_name: "edge-node", node_id: "edge-node")
    expect(plan.actions).to contain_exactly(
      include(
        action: :admit_trusted_peer,
        requires_approval: true,
        params: include(peer_name: "edge-node", node_id: "edge-node", label: "lab-admitted")
      )
    )

    blocked = Igniter::Cluster::Mesh.admit_trusted_peer!("edge-node")
    expect(blocked).to be_blocked
    expect(Igniter::Cluster::Mesh.config.trust_store.known?("edge-node")).to be(false)

    applied = Igniter::Cluster::Mesh.admit_trusted_peer!("edge-node", approve: true, label: "lab-admitted")
    expect(applied).to be_applied
    expect(Igniter::Cluster::Mesh.config.trust_store.known?("edge-node")).to be(true)
    expect(Igniter::Cluster::Mesh.config.peer_registry.peer_named("edge-node").metadata.dig(:mesh_trust, :status)).to eq(:trusted)
    expect(Igniter::Cluster::Mesh.config.peer_registry.peer_named("edge-node").metadata.dig(:mesh_capabilities, :trust, :status)).to eq(:trusted)
  ensure
    Igniter::Cluster::Mesh.reset!
  end

  it "executes admit_trusted_peer routing plans through the mesh executor" do
    Igniter::Cluster::Mesh.reset!
    trust_store = Igniter::Cluster::Trust::TrustStore.new(
      [
        { node_id: "seed-node", public_key: identity.public_key_pem, label: "bootstrap" }
      ]
    )

    discovered_identity = Igniter::Cluster::Identity::NodeIdentity.generate(node_id: "edge-node")
    discovered_manifest = Igniter::Cluster::Identity::Manifest.build(
      identity: discovered_identity,
      peer_name: "edge-node",
      url: "http://edge:4567",
      capabilities: [:speech_io],
      tags: [:edge],
      metadata: { region: "local" },
      contracts: []
    )

    Igniter::Cluster::Mesh.configure do |c|
      c.peer_name = "seed-node"
      c.identity = identity
      c.trust_store = trust_store
      attributes = Igniter::Cluster::Mesh::PeerIdentityEnvelope.build(
        source: discovered_manifest.to_h,
        trust_store: trust_store
      )
      c.peer_registry.register(
        Igniter::Cluster::Mesh::Peer.new(
          name: attributes[:name],
          url: attributes[:url],
          capabilities: attributes[:capabilities],
          tags: attributes[:tags],
          metadata: attributes[:metadata]
        )
      )
    end

    routing_plan = {
      action: :admit_trusted_peer,
      scope: :routing_trust,
      automated: false,
      requires_approval: true,
      params: {
        trust_keys: %i[identity attestation],
        peer_candidates: ["edge-node"]
      }
    }

    blocked = Igniter::Cluster::Mesh.execute_routing_plan!(routing_plan)
    expect(blocked).to be_blocked
    expect(blocked.summary).to include(status: :blocked)

    applied = Igniter::Cluster::Mesh.execute_routing_plan!(routing_plan, approve: true, label: "routing-admitted")
    expect(applied).to be_applied
    expect(applied.summary).to include(source_plan_action: :admit_trusted_peer, candidate_peer: "edge-node")
    expect(Igniter::Cluster::Mesh.config.trust_store.entry_for("edge-node").label).to eq("routing-admitted")
    expect(Igniter::Cluster::Mesh.config.peer_registry.peer_named("edge-node").metadata.dig(:mesh_trust, :status)).to eq(:trusted)
    expect(Igniter::Cluster::Mesh.config.governance_trail.snapshot(limit: 10)).to include(
      total: 4,
      latest_type: :routing_plan_applied,
      by_type: include(
        trust_admission_blocked: 1,
        routing_plan_blocked: 1,
        trust_admission_applied: 1,
        routing_plan_applied: 1
      )
    )
  ensure
    Igniter::Cluster::Mesh.reset!
  end
end
