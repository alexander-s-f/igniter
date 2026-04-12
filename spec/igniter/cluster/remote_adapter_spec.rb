# frozen_string_literal: true

require "spec_helper"
require "igniter/cluster"

RSpec.describe Igniter::Cluster::RemoteAdapter do
  it "registers itself as the runtime remote adapter when cluster is loaded" do
    expect(Igniter::Runtime.remote_adapter).to be_a(described_class)
  end
end
