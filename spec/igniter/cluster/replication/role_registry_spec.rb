# frozen_string_literal: true

require "spec_helper"
require "igniter/cluster"

RSpec.describe Igniter::Cluster::Replication::RoleRegistry do
  before { described_class.reset! }
  after  { described_class.reset! }

  describe ".define" do
    it "returns a NodeRole" do
      role = described_class.define(:worker)
      expect(role).to be_a(Igniter::Cluster::Replication::NodeRole)
    end

    it "stores the role under its symbolised name" do
      described_class.define("coordinator")
      expect(described_class.all).to have_key(:coordinator)
    end

    it "forwards all attributes to NodeRole" do
      role = described_class.define(:worker,
        contracts:     ["ComputeContract"],
        capabilities:  [:compute],
        env_overrides: { "POOL" => "4" },
        tags:          [:heavy]
      )
      expect(role.contracts).to eq(["ComputeContract"])
      expect(role.capabilities).to eq([:compute])
      expect(role.env_overrides).to eq({ "POOL" => "4" })
      expect(role.tags).to eq([:heavy])
    end
  end

  describe ".fetch" do
    before { described_class.define(:worker) }

    it "returns the role by symbol name" do
      expect(described_class.fetch(:worker)).to be_a(Igniter::Cluster::Replication::NodeRole)
    end

    it "accepts string names" do
      expect(described_class.fetch("worker").name).to eq(:worker)
    end

    it "raises ArgumentError for unknown roles" do
      expect { described_class.fetch(:unknown) }.to raise_error(ArgumentError, /Unknown role/)
    end

    it "includes available roles in the error message" do
      expect { described_class.fetch(:unknown) }
        .to raise_error(ArgumentError, /worker/)
    end
  end

  describe ".registered?" do
    it "returns true for a registered role" do
      described_class.define(:worker)
      expect(described_class.registered?(:worker)).to be true
    end

    it "returns false for an unknown role" do
      expect(described_class.registered?(:ghost)).to be false
    end

    it "accepts string names" do
      described_class.define(:worker)
      expect(described_class.registered?("worker")).to be true
    end
  end

  describe ".all" do
    it "returns a copy of all registered roles" do
      described_class.define(:a)
      described_class.define(:b)
      all = described_class.all
      expect(all.keys).to contain_exactly(:a, :b)
    end

    it "returns a dup so external mutation is safe" do
      described_class.define(:a)
      copy = described_class.all
      copy.delete(:a)
      expect(described_class.registered?(:a)).to be true
    end
  end

  describe ".reset!" do
    it "clears all roles" do
      described_class.define(:worker)
      described_class.reset!
      expect(described_class.all).to be_empty
    end
  end
end
