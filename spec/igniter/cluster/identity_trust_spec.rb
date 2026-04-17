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
end
