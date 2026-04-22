# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Igniter::Contracts::PackManifest do
  it "normalizes node contracts to symbol kinds with required capabilities by default" do
    contract = described_class.node("project")

    expect(contract.kind).to eq(:project)
    expect(contract.requires_dsl).to be(true)
    expect(contract.requires_runtime).to be(true)
  end

  it "stores pack metadata as immutable capability declarations" do
    manifest = described_class.new(
      name: "project",
      node_contracts: [described_class.node(:project)],
      diagnostics: ["projection_summary"],
      metadata: { category: :data }
    )

    expect(manifest.name).to eq(:project)
    expect(manifest.diagnostics).to eq([:projection_summary])
    expect(manifest.metadata).to eq({ category: :data })
    expect(manifest).to be_frozen
  end
end
