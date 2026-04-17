# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require "fileutils"
require "igniter/stack"
require "igniter/app"

RSpec.describe Igniter::Stack do
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
      main: Class.new(Igniter::App),
      dashboard: Class.new(Igniter::App)
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
      File.write(File.join(tmp, "stack.yml"), <<~YAML)
        stack:
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
      File.write(File.join(tmp, "stack.yml"), <<~YAML)
        stack:
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
        stack:
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
      expect(workspace.stack_settings.dig("stack", "shared_lib_paths")).to eq(["lib/prod_shared"])
      expect(workspace.deployment(:main)).to include("role" => "api", "replicas" => 3)
    end
  end

  it "adds shared lib paths from both DSL and stack.yml" do
    Dir.mktmpdir do |tmp|
      FileUtils.mkdir_p(File.join(tmp, "dsl_shared"))
      FileUtils.mkdir_p(File.join(tmp, "lib", "shared"))
      File.write(File.join(tmp, "stack.yml"), <<~YAML)
        stack:
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
      main_app = Class.new(Igniter::App) do
        define_singleton_method(:start) { started << :main }
      end
      dashboard_app = Class.new(Igniter::App) do
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
        stack:
          default_app: dashboard
      YAML

      started = []
      main_app = Class.new(Igniter::App) do
        define_singleton_method(:start) { started << :main }
      end
      dashboard_app = Class.new(Igniter::App) do
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
      File.write(File.join(tmp, "stack.yml"), <<~YAML)
        stack:
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

      expect(snapshot.dig("stack", "default_app")).to eq("dashboard")
      expect(snapshot.dig("stack", "topology_profile")).to eq("local")
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
      File.write(File.join(tmp, "stack.yml"), <<~YAML)
        stack:
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
            command: bundle exec ruby stack.rb main
            environment:
              APP_MODE: main
            http:
              port: 4567
            depends_on:
              - dashboard
          dashboard:
            role: admin
            public: true
            command: bundle exec ruby stack.rb dashboard
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
      File.write(File.join(tmp, "stack.yml"), <<~YAML)
        stack:
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
      File.write(File.join(tmp, "stack.yml"), <<~YAML)
        stack:
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
            command: bundle exec ruby stack.rb dashboard
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
      expect(procfile).to include("bundle exec ruby stack.rb dashboard")
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

  it "builds service snapshots from topology services" do
    Dir.mktmpdir do |tmp|
      FileUtils.mkdir_p(File.join(tmp, "config"))
      File.write(File.join(tmp, "stack.yml"), <<~YAML)
        stack:
          default_app: main
          default_service: core
      YAML
      File.write(File.join(tmp, "config", "topology.yml"), <<~YAML)
        services:
          core:
            role: api
            apps:
              - main
              - dashboard
            root_app: main
            http:
              port: 4567
      YAML

      workspace = build_workspace(root: tmp)
      snapshot = workspace.deployment_snapshot

      expect(workspace.service_names).to eq([:core])
      expect(workspace.default_service).to eq(:core)
      expect(workspace.service_for_role(:api)).to eq(:core)
      expect(snapshot.dig("services", "core")).to include(
        "service" => "core",
        "role" => "api",
        "apps" => %w[main dashboard],
        "root_app" => "main",
        "default" => true
      )
    end
  end

  it "mounts multiple apps behind one rack service" do
    root_app = Class.new(Igniter::App) do
      route "GET", "/hello" do
        { source: "main" }
      end
    end

    mounted_app = Class.new(Igniter::App) do
      route "GET", "/hello" do
        { source: "dashboard" }
      end
    end

    Dir.mktmpdir do |tmp|
      FileUtils.mkdir_p(File.join(tmp, "config"))
      File.write(File.join(tmp, "stack.yml"), <<~YAML)
        stack:
          default_service: core
      YAML
      File.write(File.join(tmp, "config", "topology.yml"), <<~YAML)
        services:
          core:
            role: api
            apps:
              - main
              - dashboard
            root_app: main
            mounts:
              dashboard: /dashboard
            http:
              port: 4567
      YAML

      workspace = build_workspace(
        root: tmp,
        app_classes: { main: root_app, dashboard: mounted_app }
      )

      rack_app = workspace.rack_service(:core)
      root_status, _root_headers, root_body = rack_app.call(
        "REQUEST_METHOD" => "GET",
        "PATH_INFO" => "/hello",
        "rack.input" => StringIO.new("")
      )
      mounted_status, _mounted_headers, mounted_body = rack_app.call(
        "REQUEST_METHOD" => "GET",
        "PATH_INFO" => "/dashboard/hello",
        "rack.input" => StringIO.new("")
      )

      expect(root_status).to eq(200)
      expect(root_body.join).to include("\"source\":\"main\"")
      expect(mounted_status).to eq(200)
      expect(mounted_body.join).to include("\"source\":\"dashboard\"")
    end
  end

  it "generates compose and dev commands from topology services" do
    Dir.mktmpdir do |tmp|
      FileUtils.mkdir_p(File.join(tmp, "config"))
      File.write(File.join(tmp, "stack.yml"), <<~YAML)
        stack:
          name: service_stack
          default_service: core
      YAML
      File.write(File.join(tmp, "config", "topology.yml"), <<~YAML)
        topology:
          profile: local
        shared:
          environment:
            SHARED_FLAG: "1"
        services:
          core:
            role: api
            apps:
              - main
              - dashboard
            root_app: main
            public: true
            http:
              port: 4567
            environment:
              SERVICE_MODE: unified
      YAML

      workspace = build_workspace(root: tmp, environment: "development")
      compose = workspace.compose_config
      procfile = workspace.procfile_dev

      expect(compose.dig("services", "core", "command")).to eq("bundle exec ruby stack.rb --service core")
      expect(compose.dig("services", "core", "environment")).to include(
        "IGNITER_SERVICE" => "core",
        "IGNITER_APP" => "main",
        "PORT" => "4567",
        "SERVICE_MODE" => "unified",
        "SHARED_FLAG" => "1",
        "IGNITER_ENV" => "development",
        "IGNITER_TOPOLOGY_PROFILE" => "local"
      )
      expect(compose.dig("services", "core", "ports")).to eq(["4567:4567"])
      expect(procfile).to include("core:")
      expect(procfile).to include("bundle exec ruby stack.rb --service core")
    end
  end
end
