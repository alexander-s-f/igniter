# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require "fileutils"
require "ostruct"
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
      workspace.app :main, path: "apps/main", klass: app_classes.fetch(:main), default: true
      workspace.app :dashboard, path: "apps/dashboard", klass: app_classes.fetch(:dashboard)
    end
  end

  it "loads root app and node defaults from stack.yml" do
    Dir.mktmpdir do |tmp|
      File.write(File.join(tmp, "stack.yml"), <<~YAML)
        stack:
          root_app: dashboard
          default_node: edge
          shared_lib_paths:
            - lib/shared
        nodes:
          edge:
            port: 4668
      YAML

      workspace = build_workspace(root: tmp)

      expect(workspace.root_app).to eq(:dashboard)
      expect(workspace.default_node).to eq(:edge)
      expect(workspace.node_profile(:edge).fetch("port")).to eq(4668)
      expect(workspace.stack_settings.dig("stack", "shared_lib_paths")).to eq(["lib/shared"])
    end
  end

  it "merges environment overlays into stack settings" do
    Dir.mktmpdir do |tmp|
      FileUtils.mkdir_p(File.join(tmp, "config", "environments"))
      File.write(File.join(tmp, "stack.yml"), <<~YAML)
        stack:
          root_app: main
        nodes:
          main:
            port: 4567
      YAML
      File.write(File.join(tmp, "config", "environments", "production.yml"), <<~YAML)
        stack:
          root_app: dashboard
        nodes:
          main:
            port: 5567
          edge:
            port: 5568
      YAML

      workspace = build_workspace(root: tmp, environment: "production")

      expect(workspace.root_app).to eq(:dashboard)
      expect(workspace.node_profile(:main).fetch("port")).to eq(5567)
      expect(workspace.node_profile(:edge).fetch("port")).to eq(5568)
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

  it "starts a named app directly when requested" do
    Dir.mktmpdir do |tmp|
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

      workspace.start(:dashboard)

      expect(started).to eq([:dashboard])
    end
  end

  it "starts a node from CLI args with env selection" do
    Dir.mktmpdir do |tmp|
      FileUtils.mkdir_p(File.join(tmp, "config", "environments"))
      File.write(File.join(tmp, "stack.yml"), <<~YAML)
        stack:
          root_app: main
          default_node: seed
        nodes:
          seed:
            port: 4667
          edge:
            port: 4668
      YAML
      File.write(File.join(tmp, "config", "environments", "production.yml"), <<~YAML)
        nodes:
          edge:
            port: 5668
      YAML

      started = []
      fake_host = double("host", start: nil, activate_transport!: nil)
      root_app = Class.new(Igniter::App) do
        define_singleton_method(:host_adapter) { fake_host }
        define_singleton_method(:send) do |method_name, *_args|
          case method_name
          when :build!
            started << :build
            OpenStruct.new(custom_routes: [], host_settings: {}, host: nil, port: nil, log_format: nil, drain_timeout: nil)
          when :start_scheduler
            nil
          else
            super(method_name)
          end
        end
      end

      workspace = build_workspace(root: tmp, environment: "production", app_classes: { main: root_app, dashboard: Class.new(Igniter::App) })
      workspace.start_cli(%w[--node edge])

      expect(workspace.environment).to eq("production")
      expect(workspace.node_profile(:edge).fetch("port")).to eq(5668)
      expect(started).to eq([:build])
    end
  end

  it "builds a deployment snapshot for registered apps and nodes" do
    Dir.mktmpdir do |tmp|
      File.write(File.join(tmp, "stack.yml"), <<~YAML)
        stack:
          name: demo_workspace
          root_app: dashboard
          default_node: edge
        server:
          host: 0.0.0.0
        nodes:
          edge:
            port: 4668
            role: edge
      YAML

      workspace = build_workspace(root: tmp)
      workspace.mount(:main, at: "/main")
      snapshot = workspace.deployment_snapshot

      expect(snapshot.dig("stack", "root_app")).to eq("dashboard")
      expect(snapshot.dig("stack", "default_node")).to eq("edge")
      expect(snapshot.dig("stack", "mounts")).to eq("main" => "/main")
      expect(snapshot.dig("apps", "main")).to include(
        "app" => "main",
        "root" => false
      )
      expect(snapshot.dig("apps", "dashboard")).to include(
        "app" => "dashboard",
        "root" => true
      )
      expect(snapshot.dig("nodes", "edge")).to include(
        "node" => "edge",
        "role" => "edge",
        "port" => 4668,
        "default" => true
      )
    end
  end

  it "generates a compose config from stack node settings" do
    Dir.mktmpdir do |tmp|
      File.write(File.join(tmp, "stack.yml"), <<~YAML)
        stack:
          name: companion
          root_app: main
          default_node: seed
        server:
          host: 0.0.0.0
        shared:
          environment:
            SHARED_FLAG: "1"
        deploy:
          compose:
            context: ../../../../
            dockerfile: examples/companion/config/deploy/Dockerfile
            working_dir: /app/examples/companion
            volume_name: companion_var
            volume_target: /app/examples/companion/var
            environment:
              APP_MODE: mesh
        nodes:
          seed:
            public: true
            port: 4567
            depends_on:
              - edge
            environment:
              NODE_KIND: seed
          edge:
            public: false
            port: 4568
      YAML

      workspace = build_workspace(root: tmp, environment: "production")
      compose = workspace.compose_config

      expect(compose.dig("services", "seed", "build")).to eq(
        "context" => "../../../../",
        "dockerfile" => "examples/companion/config/deploy/Dockerfile"
      )
      expect(compose.dig("services", "seed", "environment")).to include(
        "APP_MODE" => "mesh",
        "SHARED_FLAG" => "1",
        "IGNITER_NODE" => "seed",
        "IGNITER_ROOT_APP" => "main",
        "IGNITER_ENV" => "production",
        "PORT" => "4567",
        "NODE_KIND" => "seed"
      )
      expect(compose.dig("services", "seed", "ports")).to eq(["4567:4567"])
      expect(compose.dig("services", "seed", "depends_on")).to eq(["edge"])
      expect(compose.dig("services", "seed", "volumes")).to eq(
        ["companion_var:/app/examples/companion/var"]
      )
      expect(compose.fetch("volumes")).to include("companion_var" => {})
      expect(workspace.compose_yaml).to include("services:")
      expect(workspace.compose_yaml).to include("companion_var")
    end
  end

  it "writes generated compose yaml to the configured path" do
    Dir.mktmpdir do |tmp|
      File.write(File.join(tmp, "stack.yml"), <<~YAML)
        stack:
          name: write_test
        nodes:
          main:
            public: true
            port: 4567
      YAML

      workspace = build_workspace(root: tmp)
      path = workspace.write_compose

      expect(path).to eq(File.join(tmp, "config", "deploy", "compose.yml"))
      expect(File.read(path)).to include("services:")
      expect(File.read(path)).to include("main:")
    end
  end

  it "generates a Procfile.dev for local node-based development" do
    Dir.mktmpdir do |tmp|
      File.write(File.join(tmp, "stack.yml"), <<~YAML)
        stack:
          name: home_lab
          root_app: main
          default_node: seed
        shared:
          environment:
            SHARED_FLAG: "1"
        nodes:
          seed:
            port: 4567
          edge:
            command: bundle exec ruby stack.rb --node edge
            environment:
              EDGE_MODE: enabled
            port: 4569
      YAML

      workspace = build_workspace(root: tmp, environment: "development")
      procfile = workspace.procfile_dev

      expect(procfile).to include("seed:")
      expect(procfile).to include("edge:")
      expect(procfile).to include("RUBYOPT=")
      expect(procfile).to include("dev_output_sync")
      expect(procfile).to include("SHARED_FLAG=1")
      expect(procfile).to include("EDGE_MODE=enabled")
      expect(procfile).to include("IGNITER_NODE=edge")
      expect(procfile).to include("bundle exec ruby stack.rb --node edge")
    end
  end

  it "writes generated Procfile.dev to the configured path" do
    Dir.mktmpdir do |tmp|
      File.write(File.join(tmp, "stack.yml"), <<~YAML)
        nodes:
          main:
            port: 4567
      YAML

      workspace = build_workspace(root: tmp)
      path = workspace.write_procfile_dev

      expect(path).to eq(File.join(tmp, "config", "deploy", "Procfile.dev"))
      expect(File.read(path)).to include("main:")
    end
  end

  it "mounts apps behind the stack runtime" do
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
      File.write(File.join(tmp, "stack.yml"), <<~YAML)
        stack:
          root_app: main
      YAML

      workspace = build_workspace(
        root: tmp,
        app_classes: { main: root_app, dashboard: mounted_app }
      )
      workspace.mount(:dashboard, at: "/dashboard")

      rack_app = workspace.rack_app
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

  it "builds local node profiles from stack.yml" do
    Dir.mktmpdir do |tmp|
      File.write(File.join(tmp, "stack.yml"), <<~YAML)
        stack:
          root_app: main
          default_node: seed
        server:
          host: 0.0.0.0
        nodes:
          seed:
            port: 4667
            role: seed
            environment:
              NODE_KIND: seed
          edge:
            port: 4668
            role: edge
      YAML

      workspace = build_workspace(root: tmp)
      workspace.mount(:dashboard, at: "/dashboard")
      snapshot = workspace.deployment_snapshot
      procfile = workspace.procfile_dev

      expect(workspace.root_app).to eq(:main)
      expect(workspace.default_node).to eq(:seed)
      expect(workspace.node_names).to eq(%i[seed edge])
      expect(snapshot.dig("stack", "default_node")).to eq("seed")
      expect(snapshot.dig("nodes", "seed", "port")).to eq(4667)
      expect(snapshot.dig("nodes", "seed", "mounts")).to eq("dashboard" => "/dashboard")
      expect(procfile).to include("seed:")
      expect(procfile).to include("IGNITER_NODE=seed")
      expect(procfile).to include("bundle exec ruby stack.rb --node seed")
      expect(procfile).to include("NODE_KIND=seed")
    end
  end

  it "builds a console context with stack, app, node, and runtime helpers" do
    Dir.mktmpdir do |tmp|
      File.write(File.join(tmp, "stack.yml"), <<~YAML)
        stack:
          root_app: main
          default_node: edge
        nodes:
          edge:
            port: 4668
      YAML

      workspace = build_workspace(root: tmp)
      workspace.mount(:dashboard, at: "/dashboard")

      context = workspace.console_context(:dashboard, node: :edge)
      bind = workspace.console_binding(:dashboard, node: :edge)

      expect(context.stack_class).to eq(workspace)
      expect(context.root_app_name).to eq(:main)
      expect(context.app_name).to eq(:dashboard)
      expect(context.node_name).to eq(:edge)
      expect(context.node_profile).to include("port" => 4668)
      expect(context.deployment.dig("stack", "root_app")).to eq("main")
      expect(context.mounts).to eq(dashboard: "/dashboard")
      expect(bind.local_variable_get(:stack)).to eq(workspace)
      expect(bind.local_variable_get(:app_name)).to eq(:dashboard)
      expect(bind.local_variable_get(:node_name)).to eq(:edge)
      expect(bind.local_variable_get(:deployment).dig("stack", "default_node")).to eq("edge")
    end
  end

  it "routes CLI console mode into start_console" do
    Dir.mktmpdir do |tmp|
      File.write(File.join(tmp, "stack.yml"), <<~YAML)
        stack:
          root_app: main
          default_node: edge
        nodes:
          edge:
            port: 4668
      YAML

      workspace = build_workspace(root: tmp)

      expect(workspace).to receive(:start_console).with("dashboard", node: "edge", environment: "development", evaluate: nil)
      workspace.start_cli(%w[--console --node edge --env development dashboard])
    end
  end

  it "evaluates code inside the stack console and exits" do
    Dir.mktmpdir do |tmp|
      File.write(File.join(tmp, "stack.yml"), <<~YAML)
        stack:
          root_app: main
          default_node: seed
        nodes:
          seed:
            port: 4667
      YAML

      workspace = build_workspace(root: tmp)
      output = StringIO.new
      result = workspace.start_console(:dashboard, node: :seed, output: output, evaluate: "[app_name, node_name, root_app_name]")

      expect(result).to eq(%i[dashboard seed main])
      expect(output.string).to include("Igniter Console")
      expect(output.string).to include("=> [:dashboard, :seed, :main]")
    end
  end

  it "starts one mounted stack runtime in dev mode when nodes are absent" do
    Dir.mktmpdir do |tmp|
      File.write(File.join(tmp, "stack.yml"), <<~YAML)
        stack:
          root_app: main
      YAML

      workspace = build_workspace(root: tmp)
      workspace.mount(:dashboard, at: "/dashboard")

      expect(workspace.dev_services).to eq([
        {
          name: "main",
          command: "bundle exec ruby stack.rb",
          environment: { "IGNITER_ROOT_APP" => "main", "RUBYOPT" => workspace.send(:rubyopt_with_dev_output_sync) }
        }
      ])
    end
  end
end
