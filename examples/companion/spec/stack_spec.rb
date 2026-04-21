# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Companion::Stack do
  it "registers main and dashboard apps with a mounted stack runtime" do
    expect(described_class.root_app).to eq(:main)
    expect(described_class.default_node).to eq(:main)
    expect(described_class.app(:main)).to be(Companion::MainApp)
    expect(described_class.app(:dashboard)).to be(Companion::DashboardApp)
    expect(described_class.app_definition(:dashboard).access_to).to eq([:notes_api, :playground_ops_api])
    expect(described_class.mounts).to eq(dashboard: "/dashboard")
    expect(described_class.node_names).to eq([])
  end
end
