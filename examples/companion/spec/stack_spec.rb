# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Companion::Stack do
  it "registers apps, mounts, and local node profiles for the cluster-next sandbox" do
    expect(described_class.default_app).to eq(:main)
    expect(described_class.default_node).to eq(:seed)
    expect(described_class.app(:main)).to be(Companion::MainApp)
    expect(described_class.app(:dashboard)).to be(Companion::DashboardApp)
    expect(described_class.mounts).to eq(dashboard: "/dashboard")
    expect(described_class.node_names).to eq(%i[seed edge analyst])
    expect(described_class.node_profile(:edge).fetch("port")).to eq(4668)
  end
end
