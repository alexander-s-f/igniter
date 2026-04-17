# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Companion::Stack do
  it "registers apps and local node services for the cluster-next sandbox" do
    expect(described_class.default_app).to eq(:main)
    expect(described_class.default_service).to eq(:seed)
    expect(described_class.app(:main)).to be(Companion::MainApp)
    expect(described_class.app(:dashboard)).to be(Companion::DashboardApp)
    expect(described_class.service_names).to eq(%i[seed edge analyst])
    expect(described_class.service_for_role(:seed)).to eq(:seed)
    expect(described_class.service_for_role(:edge)).to eq(:edge)
    expect(described_class.service_for_role(:analyst)).to eq(:analyst)
  end
end
