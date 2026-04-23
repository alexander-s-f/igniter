# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Companion::Shared::RuntimeProfile do
  around do |example|
    previous_env = ENV.to_h.slice("COMPANION_DEV_CLUSTER", "IGNITER_ENV", "IGNITER_NODE")
    ENV.delete("COMPANION_DEV_CLUSTER")
    ENV.delete("IGNITER_ENV")
    ENV.delete("IGNITER_NODE")
    example.run
  ensure
    ENV.delete("COMPANION_DEV_CLUSTER")
    ENV.delete("IGNITER_ENV")
    ENV.delete("IGNITER_NODE")
    previous_env.each { |key, value| ENV[key] = value }
  end

  it "uses the shared var root in single-node mode" do
    expect(described_class.cluster_mode?).to eq(false)
    expect(described_class.node_name).to eq("main")
    expect(described_class.execution_store_path(:main)).to end_with("/examples/companion/var/main_executions.sqlite3")
    expect(described_class.note_store_path).to end_with("/examples/companion/var/notes.json")
  end

  it "uses a node-specific storage root in dev-cluster mode" do
    ENV["COMPANION_DEV_CLUSTER"] = "true"
    ENV["IGNITER_ENV"] = "dev-cluster"
    ENV["IGNITER_NODE"] = "replica-1"

    expect(described_class.cluster_mode?).to eq(true)
    expect(described_class.node_name).to eq("replica-1")
    expect(described_class.execution_store_path(:dashboard)).to end_with("/examples/companion/var/dev-cluster/nodes/replica_1/dashboard_executions.sqlite3")
    expect(described_class.note_store_path).to end_with("/examples/companion/var/dev-cluster/nodes/replica_1/notes.json")
    expect(described_class.stack_data_path).to end_with("/examples/companion/var/dev-cluster/nodes/replica_1/companion_data.sqlite3")
  end
end
