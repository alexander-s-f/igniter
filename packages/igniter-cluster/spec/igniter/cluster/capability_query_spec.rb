# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Igniter::Cluster::CapabilityQuery do
  it "normalizes capabilities, peer, and metadata" do
    query = described_class.new(
      required_capabilities: ["pricing", :compose, :pricing],
      preferred_peer: "node_a",
      metadata: { region: "eu-west" }
    )

    expect(query.required_capabilities).to eq(%i[compose pricing])
    expect(query.preferred_peer).to eq(:node_a)
    expect(query).to be_pinned
    expect(query.routing_mode).to eq(:pinned)
    expect(query.to_h).to include(
      required_capabilities: %i[compose pricing],
      preferred_peer: :node_a,
      metadata: { region: "eu-west" }
    )
  end

  it "supports the legacy routing metadata shape" do
    query = described_class.from_routing(
      all_of: [:pricing],
      peer: :node_a,
      metadata: { source: :legacy }
    )

    expect(query.required_capabilities).to eq([:pricing])
    expect(query.preferred_peer).to eq(:node_a)
    expect(query.metadata).to eq(source: :legacy)
  end
end
