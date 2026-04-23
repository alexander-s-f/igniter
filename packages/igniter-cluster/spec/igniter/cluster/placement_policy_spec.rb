# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Igniter::Cluster::PlacementPolicy do
  let(:pricing_peer) do
    Igniter::Cluster::Peer.new(
      name: :pricing_node,
      capabilities: %i[compose pricing],
      transport: ->(_request) { nil }
    )
  end

  let(:fallback_peer) do
    Igniter::Cluster::Peer.new(
      name: :fallback_node,
      capabilities: [:compose],
      transport: ->(_request) { nil }
    )
  end

  it "honors preferred peer by default" do
    policy = described_class.direct
    query = Igniter::Cluster::CapabilityQuery.new(preferred_peer: :pricing_node)

    expect(policy.select_candidates(query: query, peers: [fallback_peer, pricing_peer])).to eq([pricing_peer])
    expect(policy.mode_for(query)).to eq(:pinned)
  end

  it "can filter candidates by requested capabilities" do
    policy = described_class.new(name: :targeted, filter_capabilities: true, candidate_limit: 1)
    query = Igniter::Cluster::CapabilityQuery.new(required_capabilities: [:pricing])

    expect(policy.select_candidates(query: query, peers: [fallback_peer, pricing_peer])).to eq([pricing_peer])
    expect(policy.mode_for(query)).to eq(:capability_filtered)
  end
end
