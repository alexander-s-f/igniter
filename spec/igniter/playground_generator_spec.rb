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
        expect(File.exist?("my_lab/lib/my_lab/shared/note_store.rb")).to be true
        expect(File.exist?("my_lab/lib/my_lab/main/status_handler.rb")).to be true
        expect(File.exist?("my_lab/lib/my_lab/main/notes_list_handler.rb")).to be true
        expect(File.exist?("my_lab/lib/my_lab/main/notes_create_handler.rb")).to be true
        expect(File.exist?("my_lab/lib/my_lab/dashboard/home_handler.rb")).to be true
        expect(File.exist?("my_lab/lib/my_lab/dashboard/notes_create_handler.rb")).to be true
        expect(File.exist?("my_lab/lib/my_lab/dashboard/overview_handler.rb")).to be true
        expect(File.exist?("my_lab/lib/my_lab/dashboard/views/home_page.rb")).to be true

        stack = File.read("my_lab/stack.rb")
        topology_data = YAML.load_file("my_lab/config/topology.yml")
        procfile = File.read("my_lab/config/deploy/Procfile.dev")
        readme = File.read("my_lab/README.md")
        main_app = File.read("my_lab/apps/main/app.rb")
        dashboard_app = File.read("my_lab/apps/dashboard/app.rb")
        dashboard_page = File.read("my_lab/lib/my_lab/dashboard/views/home_page.rb")

        expect(stack).to include('require_relative "apps/dashboard/app"')
        expect(stack).to include('app :dashboard, path: "apps/dashboard", klass: MyLab::DashboardApp')
        expect(topology_data.dig("stack", "default_service")).to eq("main")
        expect(topology_data.fetch("services").keys).to contain_exactly("main")
        expect(topology_data.dig("services", "main", "apps")).to eq(%w[main dashboard])
        expect(topology_data.dig("services", "main", "mounts", "dashboard")).to eq("/dashboard")
        expect(procfile).to include("main: IGNITER_SERVICE=main IGNITER_APP=main PORT=4567 bundle exec ruby stack.rb --service main")
        expect(readme).to include("generated with the `playground` profile")
        expect(readme).to include("shared notes flow")
        expect(readme).to include("http://127.0.0.1:4567/dashboard")
        expect(main_app).to include('route "POST", "/v1/notes"')
        expect(dashboard_app).to include('route "POST", "/notes"')
        expect(dashboard_page).to include('action: route("/notes")')
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
