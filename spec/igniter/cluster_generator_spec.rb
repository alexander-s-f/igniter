# frozen_string_literal: true

require "spec_helper"
require "igniter/app/scaffold_pack"
require "tmpdir"
require "yaml"

RSpec.describe Igniter::App::Generators::Cluster do
  it "layers a cluster-ready sandbox on top of the base scaffold" do
    Dir.mktmpdir do |tmp|
      Dir.chdir(tmp) do
        described_class.new("mesh_lab").generate

        expect(File.exist?("mesh_lab/apps/dashboard/app.rb")).to be true
        expect(File.exist?("mesh_lab/apps/dashboard/spec/dashboard_app_spec.rb")).to be true
        expect(File.exist?("mesh_lab/lib/mesh_lab/shared/node_identity_catalog.rb")).to be true
        expect(File.exist?("mesh_lab/lib/mesh_lab/shared/capability_profile.rb")).to be true
        expect(File.exist?("mesh_lab/lib/mesh_lab/shared/stack_overview.rb")).to be true
        expect(File.exist?("mesh_lab/lib/mesh_lab/shared/routing_demo.rb")).to be true
        expect(File.exist?("mesh_lab/lib/mesh_lab/main/status_handler.rb")).to be true
        expect(File.exist?("mesh_lab/lib/mesh_lab/dashboard/overview_handler.rb")).to be true
        expect(File.exist?("mesh_lab/lib/mesh_lab/dashboard/self_heal_demo_handler.rb")).to be true

        stack = File.read("mesh_lab/stack.rb")
        stack_data = YAML.load_file("mesh_lab/stack.yml")
        readme = File.read("mesh_lab/README.md")
        main_app = File.read("mesh_lab/apps/main/app.rb")
        dashboard_app = File.read("mesh_lab/apps/dashboard/app.rb")

        expect(stack).to include('mount :dashboard, at: "/dashboard"')
        expect(stack_data.dig("stack", "default_node")).to eq("seed")
        expect(stack_data.fetch("nodes").keys).to contain_exactly("seed", "edge", "analyst")
        expect(stack_data.dig("nodes", "edge", "environment", "MESH_LAB_MOCK_CAPABILITIES")).to eq("piper_tts,whisper_asr")
        expect(readme).to include("generated with the `cluster` scaffold profile")
        expect(readme).to include("bin/console --node seed")
        expect(main_app).to include("host :cluster_app")
        expect(main_app).to include("CapabilityProfile.configure_cluster!")
        expect(dashboard_app).to include("mount_operator_surface")
        expect(dashboard_app).to include('route "POST", "/demo/self-heal"')
      end
    end
  end
end
