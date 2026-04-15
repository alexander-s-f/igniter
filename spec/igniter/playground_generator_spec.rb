# frozen_string_literal: true

require "spec_helper"
require "igniter/app/scaffold_pack"
require "tmpdir"
require "yaml"

RSpec.describe Igniter::App::Generators::Playground do
  it "layers a playground profile on top of the base scaffold" do
    Dir.mktmpdir do |tmp|
      Dir.chdir(tmp) do
        described_class.new("my_lab").generate

        expect(File.exist?("my_lab/apps/dashboard/app.rb")).to be true
        expect(File.exist?("my_lab/apps/dashboard/app.yml")).to be true
        expect(File.exist?("my_lab/apps/dashboard/spec/dashboard_app_spec.rb")).to be true
        expect(File.exist?("my_lab/lib/my_lab/shared/stack_overview.rb")).to be true
        expect(File.exist?("my_lab/lib/my_lab/main/status_handler.rb")).to be true
        expect(File.exist?("my_lab/lib/my_lab/dashboard/home_handler.rb")).to be true
        expect(File.exist?("my_lab/lib/my_lab/dashboard/overview_handler.rb")).to be true
        expect(File.exist?("my_lab/lib/my_lab/dashboard/views/home_page.rb")).to be true

        stack = File.read("my_lab/stack.rb")
        topology_data = YAML.load_file("my_lab/config/topology.yml")
        procfile = File.read("my_lab/config/deploy/Procfile.dev")
        readme = File.read("my_lab/README.md")

        expect(stack).to include('require_relative "apps/dashboard/app"')
        expect(stack).to include('app :dashboard, path: "apps/dashboard", klass: MyLab::DashboardApp')
        expect(topology_data.fetch("apps").keys).to contain_exactly("main", "dashboard")
        expect(topology_data.dig("apps", "dashboard", "role")).to eq("admin")
        expect(procfile).to include("dashboard: IGNITER_APP=dashboard PORT=4569 bundle exec ruby stack.rb dashboard")
        expect(readme).to include("generated with the `playground` profile")
      end
    end
  end

  it "uses a local monorepo path dependency for playground scaffolds inside the repo" do
    Dir.mktmpdir do |tmp|
      Dir.chdir(tmp) do
        FileUtils.mkdir_p("lib/igniter")

        described_class.new("playgrounds/home-lab").generate

        expect(File.read("playgrounds/home-lab/Gemfile")).to include('gem "igniter", path: "../.."')
      end
    end
  end
end
