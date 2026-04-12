# frozen_string_literal: true

require "spec_helper"
require "igniter/cluster"

RSpec.describe Igniter::Cluster::Replication::NodeRole do
  describe "#initialize" do
    it "sets name as symbol" do
      role = described_class.new(name: "worker")
      expect(role.name).to eq(:worker)
    end

    it "freezes contracts as strings" do
      role = described_class.new(name: :worker, contracts: [:ComputeContract])
      expect(role.contracts).to eq(["ComputeContract"])
      expect(role.contracts).to be_frozen
    end

    it "freezes capabilities as symbols" do
      role = described_class.new(name: :worker, capabilities: ["compute", "store"])
      expect(role.capabilities).to eq(%i[compute store])
      expect(role.capabilities).to be_frozen
    end

    it "stringifies env_overrides keys and freezes" do
      role = described_class.new(name: :worker, env_overrides: { POOL: "4" })
      expect(role.env_overrides).to eq({ "POOL" => "4" })
      expect(role.env_overrides).to be_frozen
    end

    it "freezes tags as symbols" do
      role = described_class.new(name: :worker, tags: ["cpu_heavy"])
      expect(role.tags).to eq([:cpu_heavy])
      expect(role.tags).to be_frozen
    end

    it "is itself frozen" do
      role = described_class.new(name: :worker)
      expect(role).to be_frozen
    end

    it "uses empty defaults for all optional fields" do
      role = described_class.new(name: :minimal)
      expect(role.contracts).to eq([])
      expect(role.capabilities).to eq([])
      expect(role.env_overrides).to eq({})
      expect(role.tags).to eq([])
    end
  end

  describe "#to_h" do
    it "returns a Hash with all fields" do
      role = described_class.new(
        name:          :coordinator,
        contracts:     ["HealthContract"],
        capabilities:  [:leader],
        env_overrides: { "MODE" => "raft" },
        tags:          [:stateful]
      )
      expect(role.to_h).to eq(
        name:          :coordinator,
        contracts:     ["HealthContract"],
        capabilities:  [:leader],
        env_overrides: { "MODE" => "raft" },
        tags:          [:stateful]
      )
    end
  end
end
