# frozen_string_literal: true

require "spec_helper"
require "igniter/server"
require "igniter/application"
require "tmpdir"

RSpec.describe Igniter::Application do
  # Minimal contract for registration tests
  let(:sample_contract_class) do
    Class.new(Igniter::Contract) do
      define do
        input :x
        output :x
      end
    end
  end

  # Helper: define a fresh Application subclass per example
  def fresh_app(&block)
    app = Class.new(Igniter::Application)
    app.class_eval(&block) if block
    app
  end

  # ─── DSL isolation ────────────────────────────────────────────────────────

  describe "class-level DSL isolation" do
    it "does not leak root_dir between subclasses" do
      app1 = fresh_app { root_dir "/tmp/app_one" }
      app2 = fresh_app

      expect(app1.root_dir).to eq(File.expand_path("/tmp/app_one"))
      expect(app2.root_dir).to eq(Dir.pwd)
    end

    it "does not leak registered contracts between subclasses" do
      klass = sample_contract_class

      app1 = fresh_app { register "C1", klass }
      app2 = fresh_app

      expect(app1.instance_variable_get(:@registered)).to include("C1")
      expect(app2.instance_variable_get(:@registered)).not_to include("C1")
    end

    it "does not leak configure blocks between subclasses" do
      app1 = fresh_app { configure { |c| c.port = 9999 } }
      app2 = fresh_app

      expect(app1.instance_variable_get(:@configure_blocks).length).to eq(1)
      expect(app2.instance_variable_get(:@configure_blocks)).to be_empty
    end

    it "does not leak scheduled jobs between subclasses" do
      app1 = fresh_app { schedule(:tick, every: "1h") {} }
      app2 = fresh_app

      expect(app1.instance_variable_get(:@scheduled_jobs).length).to eq(1)
      expect(app2.instance_variable_get(:@scheduled_jobs)).to be_empty
    end

    it "does not leak agents_paths between subclasses" do
      app1 = fresh_app { agents_path "agents" }
      app2 = fresh_app

      expect(app1.instance_variable_get(:@agents_paths)).to eq(["agents"])
      expect(app2.instance_variable_get(:@agents_paths)).to be_empty
    end

    it "does not leak tools_paths between subclasses" do
      app1 = fresh_app { tools_path "app/tools" }
      app2 = fresh_app

      expect(app1.instance_variable_get(:@tools_paths)).to eq(["app/tools"])
      expect(app2.instance_variable_get(:@tools_paths)).to be_empty
    end

    it "does not leak skills_paths between subclasses" do
      app1 = fresh_app { skills_path "app/skills" }
      app2 = fresh_app

      expect(app1.instance_variable_get(:@skills_paths)).to eq(["app/skills"])
      expect(app2.instance_variable_get(:@skills_paths)).to be_empty
    end

    it "does not leak on_boot blocks between subclasses" do
      app1 = fresh_app { on_boot {} }
      app2 = fresh_app

      expect(app1.instance_variable_get(:@boot_blocks).length).to eq(1)
      expect(app2.instance_variable_get(:@boot_blocks)).to be_empty
    end

    it "does not leak custom routes between subclasses" do
      app1 = fresh_app { route "POST", "/webhook" do { ok: true } end }
      app2 = fresh_app

      expect(app1.instance_variable_get(:@custom_routes).length).to eq(1)
      expect(app2.instance_variable_get(:@custom_routes)).to be_empty
    end
  end

  # ─── AppConfig ────────────────────────────────────────────────────────────

  describe Igniter::Application::AppConfig do
    subject(:cfg) { described_class.new }

    it "provides sane defaults" do
      expect(cfg.port).to eq(4567)
      expect(cfg.host).to eq("0.0.0.0")
      expect(cfg.log_format).to eq(:text)
      expect(cfg.drain_timeout).to eq(30)
      expect(cfg.metrics_collector).to be_nil
    end

    describe "#to_server_config" do
      it "copies host and port" do
        cfg.host = "127.0.0.1"
        cfg.port = 9000
        sc = cfg.to_server_config
        expect(sc.host).to eq("127.0.0.1")
        expect(sc.port).to eq(9000)
      end

      it "does not override store when nil" do
        cfg.store = nil
        sc = cfg.to_server_config
        # Server::Config provides its own default store
        expect(sc.store).not_to be_nil
      end

      it "copies store when set" do
        custom_store = Igniter::Runtime::Stores::MemoryStore.new
        cfg.store    = custom_store
        sc           = cfg.to_server_config
        expect(sc.store).to be(custom_store)
      end

      it "copies metrics_collector" do
        collector = Object.new
        cfg.metrics_collector = collector
        expect(cfg.to_server_config.metrics_collector).to be(collector)
      end

      it "copies custom_routes" do
        route = { method: "POST", path: "/webhook", handler: ->(**) { { ok: true } } }
        cfg.custom_routes = [route]

        expect(cfg.to_server_config.custom_routes).to eq([route])
      end
    end
  end

  # ─── YmlLoader ────────────────────────────────────────────────────────────

  describe Igniter::Application::YmlLoader do
    let(:cfg) { Igniter::Application::AppConfig.new }

    def write_yml(dir, content)
      path = File.join(dir, "application.yml")
      File.write(path, content)
      path
    end

    it "returns empty hash for non-existent path" do
      expect(described_class.load("/no/such/file.yml")).to eq({})
    end

    it "applies port and host from YAML" do
      Dir.mktmpdir do |dir|
        path = write_yml(dir, "server:\n  port: 9999\n  host: \"127.0.0.1\"\n")
        yml  = described_class.load(path)
        described_class.apply(cfg, yml)
        expect(cfg.port).to eq(9999)
        expect(cfg.host).to eq("127.0.0.1")
      end
    end

    it "applies log_format as symbol" do
      Dir.mktmpdir do |dir|
        path = write_yml(dir, "server:\n  log_format: json\n")
        yml  = described_class.load(path)
        described_class.apply(cfg, yml)
        expect(cfg.log_format).to eq(:json)
      end
    end

    it "applies drain_timeout" do
      Dir.mktmpdir do |dir|
        path = write_yml(dir, "server:\n  drain_timeout: 60\n")
        yml  = described_class.load(path)
        described_class.apply(cfg, yml)
        expect(cfg.drain_timeout).to eq(60)
      end
    end

    it "ignores unknown keys" do
      Dir.mktmpdir do |dir|
        path = write_yml(dir, "server:\n  port: 5678\nfoo: bar\n")
        yml  = described_class.load(path)
        expect { described_class.apply(cfg, yml) }.not_to raise_error
        expect(cfg.port).to eq(5678)
      end
    end
  end

  # ─── Scheduler ────────────────────────────────────────────────────────────

  describe Igniter::Application::Scheduler do
    subject(:scheduler) { described_class.new }

    describe "#add + #job_names" do
      it "registers job names" do
        scheduler.add(:sync,   every: "1h") {}
        scheduler.add(:report, every: "1d") {}
        expect(scheduler.job_names).to eq(%i[sync report])
      end
    end

    describe "interval parsing" do
      def interval_for(val)
        s = described_class.new
        s.add(:t, every: val) {}
        s.instance_variable_get(:@jobs).first.interval
      end

      it "accepts Integer seconds" do
        expect(interval_for(120)).to eq(120.0)
      end

      it "parses Xs strings" do
        expect(interval_for("30s")).to eq(30.0)
      end

      it "parses Xm strings" do
        expect(interval_for("5m")).to eq(300.0)
      end

      it "parses Xh strings" do
        expect(interval_for("2h")).to eq(7200.0)
      end

      it "parses Xd strings" do
        expect(interval_for("1d")).to eq(86_400.0)
      end

      it "parses Hash intervals" do
        expect(interval_for({ hours: 1, minutes: 30 })).to eq(5400)
      end

      it "raises on unknown string format" do
        expect { interval_for("forever") }.to raise_error(ArgumentError, /Unknown interval/)
      end
    end

    describe "#start / #stop" do
      it "runs a job and can be stopped" do
        counter = 0
        scheduler.add(:tick, every: 0.01) { counter += 1 }
        scheduler.start
        sleep 0.05
        scheduler.stop
        expect(counter).to be >= 1
      end

      it "captures job errors without crashing" do
        scheduler.add(:boom, every: 0.01) { raise "oops" }
        expect do
          scheduler.start
          sleep 0.05
          scheduler.stop
        end.not_to raise_error
      end
    end
  end

  # ─── Generator ────────────────────────────────────────────────────────────

  describe Igniter::Application::Generator do
    it "raises when name is blank" do
      expect { described_class.new("") }.to raise_error(ArgumentError, /blank/)
    end

    it "creates expected scaffold files and directories" do
      Dir.mktmpdir do |tmp|
        Dir.chdir(tmp) do
          described_class.new("my_app").generate

          # Root files
          expect(File.exist?("my_app/workspace.rb")).to be true
          expect(File.exist?("my_app/workspace.yml")).to be true
          expect(File.exist?("my_app/config/topology.yml")).to be true
          expect(File.exist?("my_app/config/environments/development.yml")).to be true
          expect(File.exist?("my_app/config/environments/production.yml")).to be true
          expect(File.exist?("my_app/config/deploy/.keep")).to be true
          expect(File.exist?("my_app/Gemfile")).to be true
          expect(File.exist?("my_app/config.ru")).to be true

          # bin/
          expect(File.exist?("my_app/bin/start")).to be true
          expect(File.exist?("my_app/bin/demo")).to be true

          # workspace structure
          expect(File.exist?("my_app/lib/my_app/shared/.keep")).to be true
          expect(File.exist?("my_app/spec/spec_helper.rb")).to be true
          expect(File.exist?("my_app/spec/workspace_spec.rb")).to be true
          expect(File.exist?("my_app/apps/main/application.rb")).to be true
          expect(File.exist?("my_app/apps/main/application.yml")).to be true
          expect(File.exist?("my_app/apps/main/spec/spec_helper.rb")).to be true

          # apps/main example source files
          expect(File.exist?("my_app/apps/main/spec/main_app_spec.rb")).to be true
          expect(File.exist?("my_app/apps/main/app/executors/greeter.rb")).to be true
          expect(File.exist?("my_app/apps/main/app/contracts/greet_contract.rb")).to be true
          expect(File.exist?("my_app/apps/main/app/tools/greet_tool.rb")).to be true
          expect(File.exist?("my_app/apps/main/app/agents/host_agent.rb")).to be true
          expect(File.exist?("my_app/apps/main/app/skills/concierge_skill.rb")).to be true
        end
      end
    end

    it "generated workspace and main app files use apps/main and on_boot" do
      Dir.mktmpdir do |tmp|
        Dir.chdir(tmp) do
          described_class.new("my_app").generate
          workspace = File.read("my_app/workspace.rb")
          main_app  = File.read("my_app/apps/main/application.rb")
          bin_start = File.read("my_app/bin/start")

          expect(workspace).to include("Igniter::Workspace")
          expect(workspace).to include("app :main")
          expect(workspace).to include("start_cli(ARGV)")
          expect(File.read("my_app/config/topology.yml")).to include("role: api")
          expect(File.read("my_app/config/environments/production.yml")).to include("replicas: 2")
          expect(bin_start).to include("exec bundle exec ruby workspace.rb \"$@\"")
          expect(main_app).to include("root_dir __dir__")
          expect(main_app).to include("executors_path")
          expect(main_app).to include("contracts_path")
          expect(main_app).to include("tools_path")
          expect(main_app).to include("agents_path")
          expect(main_app).to include("skills_path")
          expect(main_app).to include("on_boot")
          expect(File.read("my_app/spec/spec_helper.rb")).to include("require_relative \"../workspace\"")
          expect(File.read("my_app/apps/main/spec/spec_helper.rb")).to include("MainApp.send(:build!)")
        end
      end
    end

    it "generated example files reference correct Igniter base classes" do
      Dir.mktmpdir do |tmp|
        Dir.chdir(tmp) do
          described_class.new("my_app").generate
          expect(File.read("my_app/apps/main/app/executors/greeter.rb")).to include("Igniter::Executor")
          expect(File.read("my_app/apps/main/app/contracts/greet_contract.rb")).to include("Igniter::Contract")
          expect(File.read("my_app/apps/main/app/tools/greet_tool.rb")).to include("Igniter::Tool")
          expect(File.read("my_app/apps/main/app/agents/host_agent.rb")).to include("Igniter::Agent")
        end
      end
    end

    it "uses CamelCase module name derived from app name" do
      Dir.mktmpdir do |tmp|
        Dir.chdir(tmp) do
          described_class.new("my_cool_app").generate
          content = File.read("my_cool_app/workspace.rb")
          expect(content).to include("MyCoolApp")
          expect(File.read("my_cool_app/apps/main/application.rb")).to include("MyCoolApp")
        end
      end
    end

    it "derives module and shared lib names from the final path segment" do
      Dir.mktmpdir do |tmp|
        Dir.chdir(tmp) do
          described_class.new("examples/companion").generate

          expect(File.exist?("examples/companion/lib/companion/shared/.keep")).to be true
          expect(File.read("examples/companion/workspace.rb")).to include("module Companion")
          expect(File.read("examples/companion/apps/main/application.rb")).to include("module Companion")
          expect(File.read("examples/companion/apps/main/spec/spec_helper.rb")).to include("Companion::MainApp.send(:build!)")
        end
      end
    end

    it "makes bin/start and bin/demo executable" do
      Dir.mktmpdir do |tmp|
        Dir.chdir(tmp) do
          described_class.new("exectest").generate
          expect(File.executable?("exectest/bin/start")).to be true
          expect(File.executable?("exectest/bin/demo")).to be true
        end
      end
    end
  end

  # ─── Application build pipeline ───────────────────────────────────────────

  describe "build pipeline" do
    it "applies configure block to config" do
      app = fresh_app do
        configure { |c| c.port = 8888 }
      end

      sc = app.send(:build!)
      expect(sc.port).to eq(8888)
    end

    it "applies YAML then configure block (block wins)" do
      Dir.mktmpdir do |tmp|
        yml = File.join(tmp, "application.yml")
        File.write(yml, "server:\n  port: 6000\n")

        app = fresh_app do
          configure { |c| c.port = 7000 }
        end
        app.config_file(yml)

        sc = app.send(:build!)
        expect(sc.port).to eq(7000)
      end
    end

    it "registers contracts on the Server::Config" do
      klass = sample_contract_class
      app   = fresh_app { register "SampleContract", klass }

      sc = app.send(:build!)
      expect(sc.registry.registered?("SampleContract")).to be true
    end

    it "passes custom routes to the Server::Config" do
      app = fresh_app do
        route "POST", "/webhook" do |params:, body:, **|
          { status: 200, body: { ok: true, size: body.size }, headers: { "Content-Type" => "application/json" } }
        end
      end

      sc = app.send(:build!)
      expect(sc.custom_routes.length).to eq(1)
      expect(sc.custom_routes.first[:method]).to eq("POST")
      expect(sc.custom_routes.first[:path]).to eq("/webhook")
    end

    it "on_boot block runs during build! (after autoload_paths!)" do
      called = []
      app = fresh_app { on_boot { called << :booted } }
      app.send(:build!)
      expect(called).to eq([:booted])
    end

    it "on_boot block can register constants defined inline" do
      klass = sample_contract_class
      app   = fresh_app { on_boot { register "LazyContract", klass } }

      sc = app.send(:build!)
      expect(sc.registry.registered?("LazyContract")).to be true
    end

    it "resolves config_file and autoload paths relative to root_dir" do
      Dir.mktmpdir do |tmp|
        FileUtils.mkdir_p(File.join(tmp, "app/contracts"))
        File.write(
          File.join(tmp, "app/contracts/root_scoped_contract.rb"),
          <<~RUBY
            class RootScopedContract < Igniter::Contract
              define do
                input :value
                output :value
              end
            end
          RUBY
        )
        File.write(File.join(tmp, "application.yml"), "server:\n  port: 6123\n")

        app = fresh_app do
          root_dir tmp
          config_file "application.yml"
          contracts_path "app/contracts"
          on_boot { register "RootScopedContract", RootScopedContract }
        end

        sc = app.send(:build!)
        expect(sc.port).to eq(6123)
        expect(sc.registry.registered?("RootScopedContract")).to be true
      end
    end
  end
end

RSpec.describe Igniter::Workspace do
  let(:leaf_app) { Class.new(Igniter::Application) }

  def fresh_workspace(&block)
    workspace = Class.new(Igniter::Workspace)
    workspace.class_eval(&block) if block
    workspace
  end

  describe "class-level DSL isolation" do
    it "does not leak apps between subclasses" do
      app_class = leaf_app
      workspace1 = fresh_workspace { app :main, path: "apps/main", klass: app_class }
      workspace2 = fresh_workspace

      expect(workspace1.app_names).to eq([:main])
      expect(workspace2.app_names).to eq([])
    end
  end

  describe "app registry" do
    it "returns the default app class" do
      app_class = leaf_app
      workspace = fresh_workspace do
        app :main, path: "apps/main", klass: app_class
      end

      expect(workspace.application).to be(app_class)
      expect(workspace.default_app).to eq(:main)
    end

    it "starts a named app" do
      started = []
      app_class = Class.new(Igniter::Application) do
        define_singleton_method(:start) { started << :main }
      end

      workspace = fresh_workspace do
        app :main, path: "apps/main", klass: app_class
      end

      workspace.start(:main)
      expect(started).to eq([:main])
    end

    it "adds shared lib paths relative to root_dir" do
      Dir.mktmpdir do |tmp|
        app_class = leaf_app
        workspace = fresh_workspace do
          root_dir tmp
          shared_lib_path "lib"
          app :main, path: "apps/main", klass: app_class
        end

        shared_lib = File.join(tmp, "lib")
        FileUtils.mkdir_p(shared_lib)
        $LOAD_PATH.delete(shared_lib)

        workspace.setup_load_paths!
        expect($LOAD_PATH).to include(shared_lib)
      ensure
        $LOAD_PATH.delete(shared_lib)
      end
    end

    it "raises on unknown app" do
      app_class = leaf_app
      workspace = fresh_workspace do
        app :main, path: "apps/main", klass: app_class
      end

      expect { workspace.application(:inference) }.to raise_error(ArgumentError, /Unknown workspace app/)
    end
  end
end
