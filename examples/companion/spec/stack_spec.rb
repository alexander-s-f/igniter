# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Companion::Stack do
  it "registers apps, mounts, and local node profiles for the cluster-next sandbox" do
    expect(described_class.root_app).to eq(:main)
    expect(described_class.default_node).to eq(:seed)
    expect(described_class.app(:main)).to be(Companion::MainApp)
    expect(described_class.app(:dashboard)).to be(Companion::DashboardApp)
    expect(described_class.mounts).to eq(dashboard: "/dashboard")
    expect(described_class.node_names).to eq(%i[seed edge analyst])
    expect(described_class.node_profile(:edge).fetch("port")).to eq(4668)
  end

  it "exposes notes_api from MainApp and satisfies dashboard access_to declaration" do
    expect(described_class.interface(:notes_api)).to be(Companion::Shared::NoteStore)
    expect(described_class.interfaces).to include(notes_api: Companion::Shared::NoteStore)
  end

  it "raises KeyError when requesting an unknown interface" do
    expect { described_class.interface(:nonexistent) }.to raise_error(KeyError, /nonexistent/)
  end

  context "access_to validation" do
    let(:stub_callable) { Module.new }

    it "raises ArgumentError at build time when a declared access_to interface is missing" do
      stack = Class.new(Igniter::Stack) do
        app :provider, path: "apps/main", klass: Class.new(Igniter::App), default: true
        app :consumer, path: "apps/dashboard", klass: Class.new(Igniter::App), access_to: [:missing_api]
        mount :consumer, at: "/consumer"
      end

      expect { stack.send(:build_stack_runtime) }.to raise_error(ArgumentError, /missing_api/)
    end

    it "passes validation when all access_to interfaces are satisfied" do
      provider_klass = Class.new(Igniter::App) do
        expose :my_api, Module.new
      end

      consumer_klass = Class.new(Igniter::App)

      stack = Class.new(Igniter::Stack) do
        app :provider, path: "apps/main", klass: provider_klass, default: true
        app :consumer, path: "apps/dashboard", klass: consumer_klass, access_to: [:my_api]
      end

      expect { stack.send(:validate_interface_access!) }.not_to raise_error
    end
  end
end
