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

  def build_workspace(root:, environment: nil, app_classes: nil)
    app_classes ||= {
      main: Class.new(Igniter::Application),
      dashboard: Class.new(Igniter::Application)
    }

    Class.new(described_class).tap do |workspace|
      workspace.root_dir(root)
      workspace.environment(environment) if environment
      workspace.app :main, path: "apps/main", klass: app_classes.fetch(:main)
      workspace.app :dashboard, path: "apps/dashboard", klass: app_classes.fetch(:dashboard)
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

  it "starts an app by deployment role" do
    Dir.mktmpdir do |tmp|
      FileUtils.mkdir_p(File.join(tmp, "config"))
      File.write(File.join(tmp, "config", "topology.yml"), <<~YAML)
        topology:
          profile: local
        apps:
          main:
            role: api
          dashboard:
            role: admin
      YAML

      started = []
      main_app = Class.new(Igniter::Application) do
        define_singleton_method(:start) { started << :main }
      end
      dashboard_app = Class.new(Igniter::Application) do
        define_singleton_method(:start) { started << :dashboard }
      end

      workspace = build_workspace(
        root: tmp,
        app_classes: { main: main_app, dashboard: dashboard_app }
      )

      workspace.start(role: :admin)

      expect(started).to eq([:dashboard])
    end
  end

  it "starts from CLI args with env and role selection" do
    Dir.mktmpdir do |tmp|
      FileUtils.mkdir_p(File.join(tmp, "config", "environments"))
      File.write(File.join(tmp, "config", "topology.yml"), <<~YAML)
        topology:
          profile: local
        apps:
          main:
            role: api
          dashboard:
            role: admin
      YAML
      File.write(File.join(tmp, "config", "environments", "production.yml"), <<~YAML)
        workspace:
          default_app: dashboard
      YAML

      started = []
      main_app = Class.new(Igniter::Application) do
        define_singleton_method(:start) { started << :main }
      end
      dashboard_app = Class.new(Igniter::Application) do
        define_singleton_method(:start) { started << :dashboard }
      end

      workspace = build_workspace(
        root: tmp,
        app_classes: { main: main_app, dashboard: dashboard_app }
      )

      workspace.start_cli(%w[--env production --profile local --role admin])

      expect(workspace.environment).to eq("production")
      expect(workspace.default_app).to eq(:dashboard)
      expect(started).to eq([:dashboard])
    end
  end

  it "raises when requested profile does not match topology profile" do
    Dir.mktmpdir do |tmp|
      FileUtils.mkdir_p(File.join(tmp, "config"))
      File.write(File.join(tmp, "config", "topology.yml"), <<~YAML)
        topology:
          profile: local
      YAML

      workspace = build_workspace(root: tmp)

      expect do
        workspace.start(profile: "production")
      end.to raise_error(ArgumentError, /does not match topology profile/)
    end
  end

  it "builds a deployment snapshot for all registered apps" do
    Dir.mktmpdir do |tmp|
      FileUtils.mkdir_p(File.join(tmp, "config"))
      File.write(File.join(tmp, "workspace.yml"), <<~YAML)
        workspace:
          name: demo_workspace
          default_app: dashboard
      YAML
      File.write(File.join(tmp, "config", "topology.yml"), <<~YAML)
        topology:
          profile: local
        shared:
          persistence:
            data:
              adapter: sqlite
        apps:
          main:
            role: api
            replicas: 2
          dashboard:
            role: admin
            replicas: 1
      YAML

      workspace = build_workspace(root: tmp)
      snapshot = workspace.deployment_snapshot

      expect(snapshot.dig("workspace", "default_app")).to eq("dashboard")
      expect(snapshot.dig("workspace", "topology_profile")).to eq("local")
      expect(snapshot.dig("apps", "main")).to include(
        "app" => "main",
        "role" => "api",
        "replicas" => 2,
        "default" => false
      )
      expect(snapshot.dig("apps", "dashboard")).to include(
        "app" => "dashboard",
        "role" => "admin",
        "default" => true
      )
    end
  end

  it "generates a compose config from topology deploy settings" do
    Dir.mktmpdir do |tmp|
      FileUtils.mkdir_p(File.join(tmp, "config"))
      File.write(File.join(tmp, "workspace.yml"), <<~YAML)
        workspace:
          name: companion
      YAML
      File.write(File.join(tmp, "config", "topology.yml"), <<~YAML)
        topology:
          profile: local-compose
        deploy:
          compose:
            context: ../../../../
            dockerfile: examples/companion/config/deploy/Dockerfile
            working_dir: /app/examples/companion
            volume_name: companion_var
            volume_target: /app/examples/companion/var
        apps:
          main:
            role: api
            public: true
            command: bundle exec ruby workspace.rb main
            environment:
              APP_MODE: main
            http:
              port: 4567
            depends_on:
              - dashboard
          dashboard:
            role: admin
            public: true
            command: bundle exec ruby workspace.rb dashboard
            http:
              port: 4569
      YAML

      workspace = build_workspace(root: tmp, environment: "production")
      compose = workspace.compose_config

      expect(compose.dig("services", "main", "build")).to eq(
        "context" => "../../../../",
        "dockerfile" => "examples/companion/config/deploy/Dockerfile"
      )
      expect(compose.dig("services", "main", "environment")).to include(
        "APP_MODE" => "main",
        "IGNITER_APP" => "main",
        "IGNITER_ENV" => "production",
        "IGNITER_TOPOLOGY_PROFILE" => "local-compose",
        "PORT" => "4567"
      )
      expect(compose.dig("services", "main", "ports")).to eq(["4567:4567"])
      expect(compose.dig("services", "main", "depends_on")).to eq(["dashboard"])
      expect(compose.dig("services", "main", "volumes")).to eq(
        ["companion_var:/app/examples/companion/var"]
      )
      expect(compose.fetch("volumes")).to include("companion_var" => {})
      expect(workspace.compose_yaml).to include("services:")
      expect(workspace.compose_yaml).to include("companion_var")
    end
  end

  it "writes generated compose yaml to the configured path" do
    Dir.mktmpdir do |tmp|
      FileUtils.mkdir_p(File.join(tmp, "config"))
      File.write(File.join(tmp, "workspace.yml"), <<~YAML)
        workspace:
          name: write_test
      YAML
      File.write(File.join(tmp, "config", "topology.yml"), <<~YAML)
        topology:
          profile: local
        apps:
          main:
            role: api
            public: true
            http:
              port: 4567
      YAML

      workspace = build_workspace(root: tmp)
      path = workspace.write_compose

      expect(path).to eq(File.join(tmp, "config", "deploy", "compose.yml"))
      expect(File.read(path)).to include("services:")
      expect(File.read(path)).to include("main:")
    end
  end

  it "generates a Procfile.dev for local multi-app development" do
    Dir.mktmpdir do |tmp|
      FileUtils.mkdir_p(File.join(tmp, "config"))
      File.write(File.join(tmp, "workspace.yml"), <<~YAML)
        workspace:
          name: home_lab
      YAML
      File.write(File.join(tmp, "config", "topology.yml"), <<~YAML)
        topology:
          profile: development
        shared:
          environment:
            SHARED_FLAG: "1"
        apps:
          main:
            role: api
            http:
              port: 4567
          dashboard:
            role: admin
            command: bundle exec ruby workspace.rb dashboard
            environment:
              DASHBOARD_MODE: enabled
            http:
              port: 4569
      YAML

      workspace = build_workspace(root: tmp, environment: "development")
      procfile = workspace.procfile_dev

      expect(procfile).to include("main:")
      expect(procfile).to include("dashboard:")
      expect(procfile).to include("RUBYOPT=")
      expect(procfile).to include("dev_output_sync")
      expect(procfile).to include("SHARED_FLAG=1")
      expect(procfile).to include("DASHBOARD_MODE=enabled")
      expect(procfile).to include("bundle exec ruby workspace.rb dashboard")
    end
  end

  it "writes generated Procfile.dev to the configured path" do
    Dir.mktmpdir do |tmp|
      FileUtils.mkdir_p(File.join(tmp, "config"))
      File.write(File.join(tmp, "config", "topology.yml"), <<~YAML)
        apps:
          main:
            role: api
            http:
              port: 4567
      YAML

      workspace = build_workspace(root: tmp)
      path = workspace.write_procfile_dev

      expect(path).to eq(File.join(tmp, "config", "deploy", "Procfile.dev"))
      expect(File.read(path)).to include("main:")
    end
  end
end
