# frozen_string_literal: true

require "spec_helper"
require "igniter/app/scaffold_pack"
require "tmpdir"
require "yaml"

RSpec.describe Igniter::App::Generators::Dashboard do
  it "layers a mounted dashboard on top of the base scaffold" do
    Dir.mktmpdir do |tmp|
      Dir.chdir(tmp) do
        described_class.new("my_hub").generate

        expect(File.exist?("my_hub/apps/dashboard/app.rb")).to be true
        expect(File.exist?("my_hub/apps/dashboard/app.yml")).to be true
        expect(File.exist?("my_hub/apps/dashboard/spec/dashboard_app_spec.rb")).to be true
        expect(File.exist?("my_hub/lib/my_hub/shared/stack_overview.rb")).to be true
        expect(File.exist?("my_hub/lib/my_hub/dashboard/home_handler.rb")).to be true

        stack = File.read("my_hub/stack.rb")
        stack_data = YAML.load_file("my_hub/stack.yml")
        readme = File.read("my_hub/README.md")
        dashboard_app = File.read("my_hub/apps/dashboard/app.rb")
        dashboard_handler = File.read("my_hub/lib/my_hub/dashboard/home_handler.rb")

        expect(stack).to include('require_relative "apps/dashboard/app"')
        expect(stack).to include('mount :dashboard, at: "/dashboard"')
        expect(stack_data.dig("stack", "default_node")).to eq("main")
        expect(stack_data.fetch("nodes").keys).to contain_exactly("main")
        expect(readme).to include("generated with the `dashboard` scaffold profile")
        expect(readme).to include("http://127.0.0.1:4567/dashboard")
        expect(dashboard_app).to include('route "GET", "/", with: MyHub::Dashboard::HomeHandler')
        expect(dashboard_handler).to include("Mounted Apps")
        expect(dashboard_handler).to include("Igniter::Plugins::View::Response.html")
      end
    end
  end
end
