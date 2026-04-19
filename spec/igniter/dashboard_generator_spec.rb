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
        expect(File.exist?("my_hub/apps/dashboard/support/stack_overview.rb")).to be true
        expect(File.exist?("my_hub/apps/dashboard/web/handlers/home_handler.rb")).to be true
        expect(File.exist?("my_hub/apps/dashboard/web/views/home_page.rb")).to be true

        stack = File.read("my_hub/stack.rb")
        stack_data = YAML.load_file("my_hub/stack.yml")
        readme = File.read("my_hub/README.md")
        dashboard_app = File.read("my_hub/apps/dashboard/app.rb")
        dashboard_handler = File.read("my_hub/apps/dashboard/web/handlers/home_handler.rb")
        dashboard_support = File.read("my_hub/apps/dashboard/support/stack_overview.rb")
        dashboard_view = File.read("my_hub/apps/dashboard/web/views/home_page.rb")

        expect(stack).to include('require_relative "apps/dashboard/app"')
        expect(stack).to include('mount :dashboard, at: "/dashboard"')
        expect(stack_data.dig("stack", "default_node")).to eq("main")
        expect(stack_data.fetch("nodes").keys).to contain_exactly("main")
        expect(readme).to include("generated with the `dashboard` scaffold profile")
        expect(readme).to include("http://127.0.0.1:4567/dashboard")
        expect(dashboard_app).to include('route "GET", "/", with: MyHub::Dashboard::HomeHandler')
        expect(dashboard_app).to include("mount_operator_surface")
        expect(dashboard_app).to include('require_relative "web/handlers/home_handler"')
        expect(dashboard_handler).to include("Igniter::Frontend::Response.html")
        expect(dashboard_handler).to include('require_relative "../../support/stack_overview"')
        expect(dashboard_handler).to include('require_relative "../views/home_page"')
        expect(dashboard_handler).to include("Views::HomePage.render")
        expect(dashboard_handler).not_to include("<!doctype html>")
        expect(dashboard_support).to include("module Dashboard")
        expect(dashboard_support).not_to include("module Shared")
        expect(dashboard_view).to include("Igniter::Frontend::Page")
        expect(dashboard_view).to include('render_document(view, title: "MyHub Dashboard")')
        expect(dashboard_view).to include("Mounted Apps")
        expect(dashboard_view).to include("Operator Console")
        expect(dashboard_view).to include("Operator API")
      end
    end
  end
end
