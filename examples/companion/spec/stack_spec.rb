# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Companion::Stack do
  it "registers main and dashboard apps with a mounted stack runtime" do
    expect(described_class.root_app).to eq(:main)
    expect(described_class.default_node).to eq(:main)
    expect(described_class.app(:main)).to be(Companion::MainApp)
    expect(described_class.app(:dashboard)).to be(Companion::DashboardApp)
    expect(described_class.app_definition(:dashboard).access_to).to eq([ :notes_api, :playground_ops_api ])
    expect(described_class.mounts).to eq(dashboard: "/dashboard")
    expect(described_class.node_names).to eq([])
  end

  it "builds a local dev-cluster deployment with replica runtime units" do
    described_class.environment("dev-cluster")
    described_class.stack_settings(reload: true)

    snapshot = described_class.deployment_snapshot

    expect(snapshot.dig("stack", "environment")).to eq("dev-cluster")
    expect(snapshot.dig("nodes", "main", "port")).to eq(4567)
    expect(snapshot.dig("nodes", "replica-1", "port")).to eq(4568)
    expect(snapshot.dig("nodes", "replica-2", "port")).to eq(4569)
    expect(snapshot.dig("nodes", "replica-1", "environment", "COMPANION_DEV_CLUSTER")).to eq("true")
    expect(snapshot.dig("nodes", "replica-1", "environment", "IGNITER_NODE")).to eq("replica-1")
    expect(snapshot.dig("nodes", "replica-2", "environment", "IGNITER_NODE")).to eq("replica-2")
  ensure
    described_class.instance_variable_set(:@environment_name, nil)
    described_class.send(:reset_stack_state!)
  end
end
