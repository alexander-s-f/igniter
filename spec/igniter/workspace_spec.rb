# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require "fileutils"
require "igniter/application"

RSpec.describe Igniter::Workspace do
  around do |example|
    original_load_path = $LOAD_PATH.dup
    original_env = ENV["IGNITER_ENV"]

    example.run
  ensure
    $LOAD_PATH.replace(original_load_path)
    ENV["IGNITER_ENV"] = original_env
  end

  def build_workspace(root:, environment: nil)
    Class.new(described_class).tap do |workspace|
      workspace.root_dir(root)
      workspace.environment(environment) if environment
      workspace.app :main, path: "apps/main", klass: Class.new(Igniter::Application)
      workspace.app :dashboard, path: "apps/dashboard", klass: Class.new(Igniter::Application)
    end
  end

  it "loads workspace defaults and topology data from standard config files" do
    Dir.mktmpdir do |tmp|
      FileUtils.mkdir_p(File.join(tmp, "config"))
      File.write(File.join(tmp, "workspace.yml"), <<~YAML)
        workspace:
          default_app: dashboard
          shared_lib_paths:
            - lib/shared
      YAML
      File.write(File.join(tmp, "config", "topology.yml"), <<~YAML)
        shared:
          persistence:
            data:
              adapter: sqlite
        apps:
          main:
            role: api
            replicas: 1
          dashboard:
            role: admin
            replicas: 1
      YAML

      workspace = build_workspace(root: tmp)

      expect(workspace.default_app).to eq(:dashboard)
      expect(workspace.app_for_role(:api)).to eq(:main)
      expect(workspace.apps_for_role(:admin)).to eq([:dashboard])
      expect(workspace.deployment(:main)).to include(
        "role" => "api",
        "replicas" => 1,
        "persistence" => { "data" => { "adapter" => "sqlite" } }
      )
    end
  end

  it "merges environment overlays into workspace settings and topology" do
    Dir.mktmpdir do |tmp|
      FileUtils.mkdir_p(File.join(tmp, "config", "environments"))
      File.write(File.join(tmp, "workspace.yml"), <<~YAML)
        workspace:
          default_app: main
          shared_lib_paths:
            - lib/shared
      YAML
      File.write(File.join(tmp, "config", "topology.yml"), <<~YAML)
        apps:
          main:
            role: api
            replicas: 1
      YAML
      File.write(File.join(tmp, "config", "environments", "production.yml"), <<~YAML)
        workspace:
          default_app: dashboard
          shared_lib_paths:
            - lib/prod_shared
        topology:
          apps:
            main:
              replicas: 3
      YAML

      workspace = build_workspace(root: tmp, environment: "production")

      expect(workspace.default_app).to eq(:dashboard)
      expect(workspace.workspace_settings.dig("workspace", "shared_lib_paths")).to eq(["lib/prod_shared"])
      expect(workspace.deployment(:main)).to include("role" => "api", "replicas" => 3)
    end
  end

  it "adds shared lib paths from both DSL and workspace.yml" do
    Dir.mktmpdir do |tmp|
      FileUtils.mkdir_p(File.join(tmp, "dsl_shared"))
      FileUtils.mkdir_p(File.join(tmp, "lib", "shared"))
      File.write(File.join(tmp, "workspace.yml"), <<~YAML)
        workspace:
          shared_lib_paths:
            - lib/shared
      YAML

      workspace = build_workspace(root: tmp)
      workspace.shared_lib_path("dsl_shared")
      workspace.setup_load_paths!

      expect($LOAD_PATH).to include(File.join(tmp, "dsl_shared"))
      expect($LOAD_PATH).to include(File.join(tmp, "lib", "shared"))
    end
  end
end
