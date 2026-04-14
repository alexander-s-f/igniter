# frozen_string_literal: true

require "spec_helper"
require "igniter/cluster"

RSpec.describe Igniter::Cluster::RemoteAdapter do
  around do |example|
    previous_adapter = Igniter::Runtime.remote_adapter
    Igniter::Runtime.remote_adapter = Igniter::Runtime::RemoteAdapter.new
    example.run
    Igniter::Runtime.remote_adapter = previous_adapter
  end

  it "installs itself as the runtime remote adapter when explicitly activated" do
    expect(Igniter::Runtime.remote_adapter).to be_a(Igniter::Runtime::RemoteAdapter)

    Igniter::Cluster.activate_remote_adapter!

    expect(Igniter::Runtime.remote_adapter).to be_a(described_class)
  end
end
