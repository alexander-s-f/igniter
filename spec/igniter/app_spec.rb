# frozen_string_literal: true

require "spec_helper"
require "igniter/server"
require "igniter/app"
require "igniter/agent"
require "igniter/cluster"
require "igniter/app/scaffold_pack"
require "tmpdir"

RSpec.describe Igniter::App do
  # Minimal contract for registration tests
  let(:sample_contract_class) do
    Class.new(Igniter::Contract) do
      define do
        input :x
        output :x
      end
    end
  end

  # Helper: define a fresh App subclass per example
  def fresh_app(&block)
    app = Class.new(Igniter::App)
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
      app1 = fresh_app { configure { |c| c.app_host.port = 9999 } }
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

    it "does not leak host adapters between subclasses" do
      fake_host = Object.new
      app1 = fresh_app { host_adapter fake_host }
      app2 = fresh_app

      expect(app1.host_adapter).to be(fake_host)
      expect(app2.host_adapter).to be_a(Igniter::App::AppHost)
    end

    it "does not leak selected hosts between subclasses" do
      app1 = fresh_app { host :cluster_app }
      app2 = fresh_app

      expect(app1.host).to eq(:cluster_app)
      expect(app2.host).to eq(:app)
    end

    it "does not leak selected schedulers between subclasses" do
      app1 = fresh_app { scheduler :custom }
      app2 = fresh_app

      expect(app1.scheduler).to eq(:custom)
      expect(app2.scheduler).to eq(:threaded)
    end

    it "does not leak selected loaders between subclasses" do
      app1 = fresh_app { loader :custom }
      app2 = fresh_app

      expect(app1.loader).to eq(:custom)
      expect(app2.loader).to eq(:filesystem)
    end

    it "does not leak custom routes between subclasses" do
      app1 = fresh_app { route "POST", "/webhook" do { ok: true } end }
      app2 = fresh_app

      expect(app1.instance_variable_get(:@custom_routes).length).to eq(1)
      expect(app2.instance_variable_get(:@custom_routes)).to be_empty
    end

    it "does not leak request hooks between subclasses" do
      app1 = fresh_app do
        before_request {}
        after_request {}
        around_request { |request:, &inner| inner.call }
      end
      app2 = fresh_app

      expect(app1.instance_variable_get(:@before_request_hooks).length).to eq(1)
      expect(app1.instance_variable_get(:@after_request_hooks).length).to eq(1)
      expect(app1.instance_variable_get(:@around_request_hooks).length).to eq(1)
      expect(app2.instance_variable_get(:@before_request_hooks)).to be_empty
      expect(app2.instance_variable_get(:@after_request_hooks)).to be_empty
      expect(app2.instance_variable_get(:@around_request_hooks)).to be_empty
    end
  end

  # ─── AppConfig ────────────────────────────────────────────────────────────

  describe Igniter::App::AppConfig do
    subject(:cfg) { described_class.new }

    it "provides sane defaults" do
      expect(cfg.app_host.port).to eq(4567)
      expect(cfg.app_host.host).to eq("0.0.0.0")
      expect(cfg.app_host.log_format).to eq(:text)
      expect(cfg.app_host.drain_timeout).to eq(30)
      expect(cfg.cluster_app_host.local_capabilities).to eq([])
      expect(cfg.cluster_app_host.start_discovery).to be false
      expect(cfg.metrics_collector).to be_nil
    end

    it "exposes host settings through app_host and cluster_app_host objects" do
      cfg.app_host.port = 9000
      cfg.app_host.host = "127.0.0.1"
      cfg.app_host.log_format = :json
      cfg.app_host.drain_timeout = 60

      expect(cfg.app_host.port).to eq(9000)
      expect(cfg.app_host.host).to eq("127.0.0.1")
      expect(cfg.app_host.log_format).to eq(:json)
      expect(cfg.app_host.drain_timeout).to eq(60)
    end

    describe "#to_host_config" do
      it "copies server-host settings into host-specific runtime intent" do
        cfg.app_host.host = "127.0.0.1"
        cfg.app_host.port = 9000
        host_config = cfg.to_host_config
        expect(host_config.host_settings_for(:app)).to include(
          host: "127.0.0.1",
          port: 9000
        )
      end

      it "copies cluster-host settings into host-specific runtime intent" do
        cfg.cluster_app_host.peer_name = "orders-node"
        cfg.cluster_app_host.local_capabilities = [:orders]
        cfg.cluster_app_host.seeds = ["http://seed:4567"]
        cfg.cluster_app_host.start_discovery = true

        host_config = cfg.to_host_config

        expect(host_config.host_settings_for(:cluster_app)).to include(
          peer_name: "orders-node",
          local_capabilities: [:orders],
          seeds: ["http://seed:4567"],
          start_discovery: true
        )
      end

      it "keeps store nil until a concrete host decides on defaults" do
        cfg.store = nil
        host_config = cfg.to_host_config
        expect(host_config.store).to be_nil
      end

      it "copies store when set" do
        custom_store = Igniter::Runtime::Stores::MemoryStore.new
        cfg.store    = custom_store
        host_config = cfg.to_host_config
        expect(host_config.store).to be(custom_store)
      end

      it "copies metrics_collector" do
        collector = Object.new
        cfg.metrics_collector = collector
        expect(cfg.to_host_config.metrics_collector).to be(collector)
      end

      it "copies custom_routes" do
        route = { method: "POST", path: "/webhook", handler: ->(**) { { ok: true } } }
        cfg.custom_routes = [route]

        expect(cfg.to_host_config.custom_routes).to eq([route])
      end

      it "copies request hooks" do
        before_hook = ->(request:) { request[:body] = { "ok" => true } }
        after_hook = ->(request:, response:) { response[:status] = 201 }
        around_hook = ->(request:, &inner) { inner.call }
        cfg.before_request_hooks = [before_hook]
        cfg.after_request_hooks = [after_hook]
        cfg.around_request_hooks = [around_hook]

        host_config = cfg.to_host_config
        expect(host_config.before_request_hooks).to eq([before_hook])
        expect(host_config.after_request_hooks).to eq([after_hook])
        expect(host_config.around_request_hooks).to eq([around_hook])
      end
    end
  end

  describe Igniter::App::HostConfig do
    subject(:config) { described_class.new }

    it "tracks contract registrations independently from host adapters" do
      klass = sample_contract_class

      config.register("SampleContract", klass)

      expect(config.registrations).to eq("SampleContract" => klass)
    end

    it "tracks host-specific settings separately from neutral hosting intent" do
      config.configure_host(:app, host: "127.0.0.1", port: 7000)

      expect(config.host_settings_for(:app)).to eq(host: "127.0.0.1", port: 7000)
    end
  end

  describe Igniter::App::HostRegistry do
    it "ships with the canonical built-in host profiles" do
      expect(described_class.names).to include(:app, :cluster_app)
    end

    it "allows registering a custom host profile" do
      host_name = :"custom_#{object_id}"
      fake_host = Object.new
      captured_app = nil

      app = fresh_app do
        register_host(host_name) do |application_class|
          captured_app = application_class
          fake_host
        end

        host host_name
      end

      expect(app.host_adapter).to be(fake_host)
      expect(captured_app).to be(app)
      expect(described_class.registered?(host_name)).to be true
    end
  end

  describe Igniter::App::SchedulerRegistry do
    it "ships with the canonical threaded scheduler profile" do
      expect(described_class.names).to include(:threaded)
    end

    it "allows registering a custom scheduler profile" do
      scheduler_name = :"custom_#{object_id}"
      fake_adapter = Object.new
      captured_app = nil

      app = fresh_app do
        register_scheduler(scheduler_name) do |application_class|
          captured_app = application_class
          fake_adapter
        end

        scheduler scheduler_name
      end

      expect(app.scheduler_adapter).to be(fake_adapter)
      expect(captured_app).to be(app)
      expect(described_class.registered?(scheduler_name)).to be true
    end
  end

  describe Igniter::App::LoaderRegistry do
    it "ships with the canonical filesystem loader profile" do
      expect(described_class.names).to include(:filesystem)
    end

    it "allows registering a custom loader profile" do
      loader_name = :"custom_#{object_id}"
      fake_adapter = Object.new
      captured_app = nil

      app = fresh_app do
        register_loader(loader_name) do |application_class|
          captured_app = application_class
          fake_adapter
        end

        loader loader_name
      end

      expect(app.loader_adapter).to be(fake_adapter)
      expect(captured_app).to be(app)
      expect(described_class.registered?(loader_name)).to be true
    end
  end

  describe Igniter::App::ClusterAppHostConfig do
    subject(:config) { described_class.new }

    it "tracks static peers and cluster settings" do
      config.peer_name = "api-node"
      config.local_capabilities = [:api]
      config.add_peer("orders-node", url: "http://orders:4567", capabilities: [:orders])

      expect(config.to_h).to include(
        peer_name: "api-node",
        local_capabilities: [:api]
      )
      expect(config.to_h[:peers]).to eq([
        {
          name: "orders-node",
          url: "http://orders:4567",
          capabilities: [:orders],
          tags: [],
          metadata: {}
        }
      ])
    end
  end

  describe Igniter::App::ClusterAppHost do
    after { Igniter::Cluster::Mesh.reset! }

    it "configures server and mesh settings from cluster host config" do
      host_config = Igniter::App::HostConfig.new
      host_config.configure_host(:app, host: "0.0.0.0", port: 4567, log_format: :text, drain_timeout: 30)
      host_config.configure_host(
        :cluster_app,
        peer_name: "orders-node",
        local_capabilities: [:orders],
        seeds: ["http://seed:4567"],
        discovery_interval: 15,
        auto_announce: false,
        local_url: "http://orders:4567",
        gossip_fanout: 5,
        start_discovery: false,
        peers: [{ name: "audit-node", url: "http://audit:4567", capabilities: [:audit] }]
      )

      server_config = described_class.new.build_config(host_config)

      expect(server_config.peer_name).to eq("orders-node")
      expect(server_config.peer_capabilities).to eq([:orders])
      expect(Igniter::Cluster::Mesh.config.peer_name).to eq("orders-node")
      expect(Igniter::Cluster::Mesh.config.local_capabilities).to eq([:orders])
      expect(Igniter::Cluster::Mesh.config.seeds).to eq(["http://seed:4567"])
      expect(Igniter::Cluster::Mesh.config.discovery_interval).to eq(15)
      expect(Igniter::Cluster::Mesh.config.auto_announce).to be false
      expect(Igniter::Cluster::Mesh.config.local_url).to eq("http://orders:4567")
      expect(Igniter::Cluster::Mesh.config.gossip_fanout).to eq(5)
      expect(Igniter::Cluster::Mesh.config.peer_named("audit-node")&.url).to eq("http://audit:4567")
    end

    it "activates the cluster remote adapter" do
      previous_adapter = Igniter::Runtime.remote_adapter

      described_class.new.activate_transport!

      expect(Igniter::Runtime.remote_adapter).to be_a(Igniter::Cluster::RemoteAdapter)
    ensure
      Igniter::Runtime.remote_adapter = previous_adapter
    end
  end

  # ─── YmlLoader ────────────────────────────────────────────────────────────

  describe Igniter::App::YmlLoader do
    let(:cfg) { Igniter::App::AppConfig.new }

    def write_yml(dir, content)
      path = File.join(dir, "app.yml")
      File.write(path, content)
      path
    end

    it "returns empty hash for non-existent path" do
      expect(described_class.load("/no/such/file.yml")).to eq({})
    end

    it "applies port and host from app_host YAML" do
      Dir.mktmpdir do |dir|
        path = write_yml(dir, "app_host:\n  port: 9999\n  host: \"127.0.0.1\"\n")
        yml  = described_class.load(path)
        described_class.apply(cfg, yml)
        expect(cfg.app_host.port).to eq(9999)
        expect(cfg.app_host.host).to eq("127.0.0.1")
      end
    end

    it "applies log_format as symbol" do
      Dir.mktmpdir do |dir|
        path = write_yml(dir, "app_host:\n  log_format: json\n")
        yml  = described_class.load(path)
        described_class.apply(cfg, yml)
        expect(cfg.app_host.log_format).to eq(:json)
      end
    end

    it "applies drain_timeout" do
      Dir.mktmpdir do |dir|
        path = write_yml(dir, "app_host:\n  drain_timeout: 60\n")
        yml  = described_class.load(path)
        described_class.apply(cfg, yml)
        expect(cfg.app_host.drain_timeout).to eq(60)
      end
    end

    it "ignores unknown keys" do
      Dir.mktmpdir do |dir|
        path = write_yml(dir, "app_host:\n  port: 5678\nfoo: bar\n")
        yml  = described_class.load(path)
        expect { described_class.apply(cfg, yml) }.not_to raise_error
        expect(cfg.app_host.port).to eq(5678)
      end
    end
  end

  # ─── Scheduler ────────────────────────────────────────────────────────────

  describe Igniter::App::Scheduler do
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

  describe Igniter::App::ThreadedSchedulerAdapter do
    it "builds the underlying scheduler once from declared jobs" do
      adapter = described_class.new
      logger = Object.new
      config = Struct.new(:logger).new(logger)
      calls = []

      fake_scheduler = Object.new
      fake_scheduler.define_singleton_method(:add) do |name, every:, at:, &block|
        calls << [:add, name, every, at, block.call]
      end
      fake_scheduler.define_singleton_method(:start) { calls << :start }
      fake_scheduler.define_singleton_method(:stop) { calls << :stop }

      allow(Igniter::App::Scheduler).to receive(:new).with(logger: logger).and_return(fake_scheduler)

      jobs = [
        { name: :tick, every: "1h", at: nil, block: -> { :ok } }
      ]

      adapter.start(config: config, jobs: jobs)
      adapter.start(config: config, jobs: jobs)
      adapter.stop

      expect(calls).to eq([
        [:add, :tick, "1h", nil, :ok],
        :start,
        :start,
        :stop
      ])
    end
  end

  describe Igniter::App::FilesystemLoaderAdapter do
    it "loads path groups through the underlying autoloader in canonical order" do
      adapter = described_class.new
      calls = []
      fake_loader = Object.new

      fake_loader.define_singleton_method(:load_path) do |path|
        calls << path
      end

      allow(Igniter::App::Autoloader).to receive(:new).with(base_dir: "/tmp/app").and_return(fake_loader)

      adapter.load!(
        base_dir: "/tmp/app",
        paths: {
          tools: ["app/tools"],
          contracts: ["app/contracts"],
          executors: ["app/executors"],
          skills: ["app/skills"],
          agents: ["app/agents"]
        }
      )

      expect(calls).to eq([
        "app/executors",
        "app/contracts",
        "app/tools",
        "app/agents",
        "app/skills"
      ])
    end
  end

  # ─── Generator ────────────────────────────────────────────────────────────

  describe Igniter::App::Generator do
    it "raises when name is blank" do
      expect { described_class.new("") }.to raise_error(ArgumentError, /blank/)
    end

    it "creates expected scaffold files and directories" do
      Dir.mktmpdir do |tmp|
        Dir.chdir(tmp) do
          described_class.new("my_app").generate

          # Root files
          expect(File.exist?("my_app/stack.rb")).to be true
          expect(File.exist?("my_app/stack.yml")).to be true
          expect(File.exist?("my_app/README.md")).to be true
          expect(File.exist?("my_app/config/deploy/.keep")).to be true
          expect(File.exist?("my_app/Gemfile")).to be true
          expect(File.exist?("my_app/config.ru")).to be true

          # bin/
          expect(File.exist?("my_app/bin/start")).to be true
          expect(File.exist?("my_app/bin/dev")).to be true
          expect(File.exist?("my_app/bin/console")).to be true
          expect(File.exist?("my_app/bin/demo")).to be true

          # stack structure
          expect(File.exist?("my_app/lib/my_app/shared/.keep")).to be true
          expect(File.exist?("my_app/spec/spec_helper.rb")).to be true
          expect(File.exist?("my_app/spec/stack_spec.rb")).to be true
          expect(File.exist?("my_app/apps/main/app.rb")).to be true
          expect(File.exist?("my_app/apps/main/app.yml")).to be true
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

    it "generated stack and main app files use apps/main and on_boot" do
      Dir.mktmpdir do |tmp|
        Dir.chdir(tmp) do
          described_class.new("my_app").generate
          stack = File.read("my_app/stack.rb")
          main_app  = File.read("my_app/apps/main/app.rb")
          bin_start = File.read("my_app/bin/start")
          bin_dev   = File.read("my_app/bin/dev")
          bin_console = File.read("my_app/bin/console")

          expect(stack).to include("Igniter::Stack")
          expect(stack).to include('require "igniter/stack"')
          expect(stack).to include("app :main")
          expect(stack).to include("start_cli(ARGV)")
          expect(File.read("my_app/stack.yml")).to include("root_app: main")
          expect(File.read("my_app/stack.yml")).to include("default_node: main")
          expect(File.read("my_app/stack.yml")).to include("port: 4567")
          expect(File.read("my_app/README.md")).to include("The intended reading order is simple:")
          expect(File.read("my_app/README.md")).to include("bin/console --node main")
          expect(File.read("my_app/README.md")).to include("var/log/dev/*.log")
          expect(File.read("my_app/Gemfile")).to include("gem \"sqlite3\"")
          expect(bin_start).to include("exec bundle exec ruby stack.rb \"$@\"")
          expect(bin_dev).to include("exec bundle exec ruby stack.rb --dev \"$@\"")
          expect(bin_console).to include("exec bundle exec ruby stack.rb --console \"$@\"")
          expect(File.read("my_app/config.ru")).to include("rack_node")
          expect(main_app).to include('require "igniter/app"')
          expect(main_app).to include("root_dir __dir__")
          expect(main_app).to include("executors_path")
          expect(main_app).to include("contracts_path")
          expect(main_app).to include("tools_path")
          expect(main_app).to include("agents_path")
          expect(main_app).to include("skills_path")
          expect(main_app).to include("on_boot")
          expect(File.read("my_app/spec/spec_helper.rb")).to include("require_relative \"../stack\"")
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
          content = File.read("my_cool_app/stack.rb")
          expect(content).to include("MyCoolApp")
          expect(File.read("my_cool_app/apps/main/app.rb")).to include("MyCoolApp")
        end
      end
    end

    it "derives module and shared lib names from the final path segment" do
      Dir.mktmpdir do |tmp|
        Dir.chdir(tmp) do
          described_class.new("examples/companion").generate

          expect(File.exist?("examples/companion/lib/companion/shared/.keep")).to be true
          expect(File.read("examples/companion/stack.rb")).to include("module Companion")
          expect(File.read("examples/companion/stack.yml")).to include("default_node: main")
          expect(File.read("examples/companion/apps/main/app.rb")).to include("module Companion")
          expect(File.read("examples/companion/apps/main/spec/spec_helper.rb")).to include("Companion::MainApp.send(:build!)")
        end
      end
    end

    it "makes bin/start, bin/dev, bin/console, and bin/demo executable" do
      Dir.mktmpdir do |tmp|
        Dir.chdir(tmp) do
          described_class.new("exectest").generate
          expect(File.executable?("exectest/bin/start")).to be true
          expect(File.executable?("exectest/bin/dev")).to be true
          expect(File.executable?("exectest/bin/console")).to be true
          expect(File.executable?("exectest/bin/demo")).to be true
        end
      end
    end
  end

  # ─── Application build pipeline ───────────────────────────────────────────

  describe "build pipeline" do
    it "applies configure block to config" do
      app = fresh_app do
        configure { |c| c.app_host.port = 8888 }
      end

      sc = app.send(:build!)
      expect(sc.port).to eq(8888)
    end

    it "applies YAML then configure block (block wins)" do
      Dir.mktmpdir do |tmp|
        yml = File.join(tmp, "app.yml")
        File.write(yml, "app_host:\n  port: 6000\n")

        app = fresh_app do
          configure { |c| c.app_host.port = 7000 }
        end
        app.config_file(yml)

        sc = app.send(:build!)
        expect(sc.port).to eq(7000)
      end
    end

    it "registers contracts on the built host config" do
      klass = sample_contract_class
      app   = fresh_app { register "SampleContract", klass }

      sc = app.send(:build!)
      expect(sc.registry.registered?("SampleContract")).to be true
    end

    it "passes custom routes to the built host config" do
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

    it "passes request hooks to the built host config" do
      before_hook = ->(request:) { request[:body] = { "before" => true } }
      after_hook = ->(request:, response:) { response[:headers]["X-After"] = "1" }
      around_hook = ->(request:, &inner) { inner.call }

      app = fresh_app do
        before_request(with: before_hook)
        after_request(with: after_hook)
        around_request(with: around_hook)
      end

      sc = app.send(:build!)
      expect(sc.before_request_hooks).to eq([before_hook])
      expect(sc.after_request_hooks).to eq([after_hook])
      expect(sc.around_request_hooks).to eq([around_hook])
    end

    it "delegates code loading to the configured loader adapter before on_boot" do
      events = []
      fake_loader = Object.new

      fake_loader.define_singleton_method(:load!) do |base_dir:, paths:|
        events << [:load, base_dir, paths]
      end

      app = fresh_app do
        root_dir "/tmp/loader-app"
        executors_path "app/executors"
        contracts_path "app/contracts"
        tools_path "app/tools"
        agents_path "app/agents"
        skills_path "app/skills"
        loader_adapter fake_loader
        on_boot { events << :boot }
      end

      app.send(:build!)

      expect(events).to eq([
        [
          :load,
          "/tmp/loader-app",
          {
            executors: ["app/executors"],
            contracts: ["app/contracts"],
            tools: ["app/tools"],
            agents: ["app/agents"],
            skills: ["app/skills"]
          }
        ],
        :boot
      ])
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
        File.write(File.join(tmp, "app.yml"), "app_host:\n  port: 6123\n")

        app = fresh_app do
          root_dir tmp
          config_file "app.yml"
          contracts_path "app/contracts"
          on_boot { register "RootScopedContract", RootScopedContract }
        end

        sc = app.send(:build!)
        expect(sc.port).to eq(6123)
        expect(sc.registry.registered?("RootScopedContract")).to be true
      end
    end

    it "exposes app diagnostics through the contributor layer" do
      pure_executor = Class.new(Igniter::Executor) do
        pure

        def call(x:) = x
      end

      database_executor = Class.new(Igniter::Executor) do
        capabilities :database

        def call(x:) = x + 1
      end

      filesystem_executor = Class.new(Igniter::Executor) do
        capabilities :filesystem

        def call(x:) = x + 2
      end

      network_executor = Class.new(Igniter::Executor) do
        capabilities :network

        def call(x:) = x + 3
      end

      klass = Class.new(Igniter::Contract) do
        define do
          input :x
          compute :pure_value, depends_on: :x, call: pure_executor
          compute :db_value, depends_on: :x, call: database_executor
          compute :file_value, depends_on: :x, call: filesystem_executor
          compute :net_value, depends_on: :x, call: network_executor
          output :pure_value
        end
      end
      metrics_collector = Object.new
      app = stub_const("SpecDiagnosticsApp", Class.new(Igniter::App))

      app.class_eval do
        root_dir "/tmp/spec-diagnostics-app"
        executors_path "app/executors"
        contracts_path "app/contracts"
        tools_path "app/tools"
        use :data, :tools
        register "SampleContract", klass
        schedule :cleanup, every: "1h" do
          :ok
        end
        route "GET", "/health" do |**|
          { status: 200, body: { ok: true } }
        end
        before_request {}
        after_request {}
        around_request { |request:, &inner| inner.call }
        configure do |c|
          c.metrics_collector = metrics_collector
          c.store = Igniter::Runtime::Stores::MemoryStore.new
        end
      end

      app.send(:build!)
      contract = klass.new(x: 10)

      report = contract.diagnostics.to_h
      text = contract.diagnostics_text
      markdown = contract.diagnostics_markdown

      expect(report[:app]).to include(
        app_name: "SpecDiagnosticsApp",
        host: :app,
        loader: :filesystem,
        scheduler: :threaded,
        registration_count: 1,
        registrations: ["SampleContract"],
        routes: 1
      )
      expect(report[:app][:hooks]).to eq(
        before_request: 1,
        after_request: 1,
        around_request: 1
      )
      expect(report[:app][:metrics]).to include(
        configured: true,
        collector_class: "Object"
      )
      expect(report[:app][:store]).to include(
        configured: true,
        store_class: "Igniter::Runtime::Stores::MemoryStore"
      )
      expect(report[:app_host]).to include(
        host: "0.0.0.0",
        port: 4567,
        log_format: :text,
        drain_timeout: 30,
        routes: 1
      )
      expect(report[:app_loader]).to include(
        mode: :filesystem,
        adapter_class: "Igniter::App::FilesystemLoaderAdapter",
        root_dir: "/tmp/spec-diagnostics-app",
        path_groups: %i[agents contracts executors skills tools],
        total_paths: 3
      )
      expect(report[:app_loader][:code_paths]).to include(
        executors: ["app/executors"],
        contracts: ["app/contracts"],
        tools: ["app/tools"],
        agents: [],
        skills: []
      )
      expect(report[:app_scheduler]).to include(
        mode: :threaded,
        job_count: 1
      )
      expect(report[:app_scheduler][:jobs]).to contain_exactly(
        include(name: :cleanup, every: "1h", at: nil)
      )
      expect(report[:app_sdk]).to include(
        requested_capabilities: %i[data tools],
        activated_capabilities: %i[data tools]
      )
      expect(report[:app_sdk][:requested_details]).to contain_exactly(
        include(name: :data, entrypoint: "igniter/sdk/data", allowed_layers: include(:core, :app, :server, :cluster), provides_capabilities: %i[cache database]),
        include(name: :tools, entrypoint: "igniter/sdk/tools", allowed_layers: include(:app, :server, :cluster), provides_capabilities: [:filesystem])
      )
      expect(report[:app_sdk][:coverage]).to include(
        required_capabilities: %i[database filesystem network pure],
        covered_capabilities: %i[database filesystem],
        uncovered_capabilities: [:network],
        intrinsic_capabilities: [:pure]
      )
      expect(report[:app_sdk][:coverage][:entries]).to contain_exactly(
        include(capability: :database, status: :covered, providers: [:data]),
        include(capability: :filesystem, status: :covered, providers: [:tools]),
        include(capability: :network, status: :uncovered, providers: [], suggested_sdk_capabilities: %i[ai channels]),
        include(capability: :pure, status: :intrinsic, providers: [])
      )
      expect(report[:app_sdk][:coverage][:remediation]).to contain_exactly(
        include(
          code: :activate_sdk_capability,
          capability: :network,
          suggested_sdk_capabilities: %i[ai channels],
          plan: include(
            action: :activate_sdk_capability,
            scope: :app_sdk,
            automated: false,
            requires_approval: true,
            params: include(capability: :network, sdk_capabilities: %i[ai channels])
          )
        )
      )
      expect(report[:app_sdk][:coverage][:facets]).to include(
        by_status: { covered: 2, uncovered: 1, intrinsic: 1 },
        by_remediation_code: { activate_sdk_capability: 1 },
        by_plan_action: { activate_sdk_capability: 1 }
      )
      expect(report[:app_sdk][:coverage][:plans]).to contain_exactly(
        include(
          action: :activate_sdk_capability,
          scope: :app_sdk,
          automated: false,
          requires_approval: true,
          params: include(capability: :network, sdk_capabilities: %i[ai channels]),
          sources: contain_exactly(
            include(capability: :network, suggested_sdk_capabilities: %i[ai channels])
          )
        )
      )
      expect(report[:app_sdk][:packs]).to include(
        hosts: include(:app, :cluster_app),
        loaders: include(:filesystem),
        schedulers: include(:threaded)
      )
      expect(report[:app_evolution]).to include(
        total: 0,
        latest_type: nil,
        latest_at: nil,
        by_type: {},
        persistence: include(enabled: false)
      )
      expect(text).to include("App: runtime=SpecDiagnosticsApp")
      expect(text).to include("App Evolution: total=0, latest=none, persisted=false, retain=all, archived=0")
      expect(text).to include("App Host: host=0.0.0.0, port=4567, log_format=text, routes=1")
      expect(text).to include("Loader: mode=filesystem, paths=3")
      expect(text).to include("Scheduler: mode=threaded, jobs=1, names=cleanup")
      expect(text).to include("SDK: requested=2, activated=2")
      expect(text).to include("coverage=required=database, filesystem, network, pure, covered=database, filesystem, uncovered=network, intrinsic=pure")
      expect(text).to include("remediation=network->ai, channels")
      expect(text).to include("plans=activate_sdk_capability(ai, channels)")
      expect(text).to include("contracts=1")
      expect(markdown).to include("## App")
      expect(markdown).to include("## App Host")
      expect(markdown).to include("## Loader")
      expect(markdown).to include("## Scheduler")
      expect(markdown).to include("## SDK")
      expect(markdown).to include("## App Evolution")
      expect(markdown).to include("- Runtime: `SpecDiagnosticsApp` host=`app` loader=`filesystem` scheduler=`threaded`")
      expect(markdown).to include("- Contracts: total=1, names=SampleContract")
      expect(markdown).to include("- `contracts`: app/contracts")
      expect(markdown).to include("- `cleanup` every=1h")
      expect(markdown).to include("- Requested: total=2, names=data, tools")
      expect(markdown).to include("- Coverage: required=database, filesystem, network, pure, covered=database, filesystem, uncovered=network, intrinsic=pure")
      expect(markdown).to include("- Executor Capability `network` status=uncovered providers=none suggestions=ai, channels")
      expect(markdown).to include("- Executor Capability `database` status=covered providers=data")
      expect(markdown).to include("- Coverage Remediation: network->ai, channels")
      expect(markdown).to include("- Coverage Plans: activate_sdk_capability(ai, channels)")
      expect(markdown).to include("- Packs: hosts=")
      expect(markdown).to include("cluster_app")
      expect(markdown).to include("filesystem")
      expect(markdown).to include("threaded")
    end

    it "exposes cluster host diagnostics through a dedicated contributor" do
      klass = sample_contract_class
      app = stub_const("SpecClusterDiagnosticsApp", Class.new(Igniter::App))

      app.class_eval do
        host :cluster_app
        register "SampleContract", klass
        configure do |c|
          c.app_host.host = "127.0.0.1"
          c.app_host.port = 5678
          c.cluster_app_host.peer_name = "orders-node"
          c.cluster_app_host.local_capabilities = %i[shell_exec orders]
          c.cluster_app_host.local_tags = %i[linux gpu]
          c.cluster_app_host.local_metadata = {
            region: "eu-central",
            trust: { score: 0.95 }
          }
          c.cluster_app_host.seeds = ["http://seed:4567"]
          c.cluster_app_host.discovery_interval = 15
          c.cluster_app_host.auto_announce = false
          c.cluster_app_host.local_url = "http://orders-node:5678"
          c.cluster_app_host.gossip_fanout = 5
          c.cluster_app_host.start_discovery = true
          c.cluster_app_host.add_peer(
            "seed-a",
            url: "http://seed-a:4567",
            capabilities: [:orders],
            tags: [:linux],
            metadata: { region: "eu-central" }
          )
        end
      end

      app.send(:build!)
      contract = klass.new(x: 10)

      report = contract.diagnostics.to_h
      text = contract.diagnostics_text
      markdown = contract.diagnostics_markdown

      expect(report[:app]).to include(
        app_name: "SpecClusterDiagnosticsApp",
        host: :cluster_app
      )
      expect(report[:cluster_app_host]).to include(
        peer_name: "orders-node",
        local_capabilities: %i[orders shell_exec],
        local_tags: %i[gpu linux],
        local_metadata_keys: %w[region trust],
        seeds: ["http://seed:4567"],
        seed_count: 1,
        static_peer_count: 1,
        discovery_interval: 15,
        auto_announce: false,
        local_url: "http://orders-node:5678",
        gossip_fanout: 5,
        start_discovery: true
      )
      expect(report[:cluster_app_host][:server]).to include(
        host: "127.0.0.1",
        port: 5678,
        log_format: :text,
        drain_timeout: 30
      )
      expect(report[:cluster_app_host][:static_peers]).to contain_exactly(
        include(
          name: "seed-a",
          url: "http://seed-a:4567",
          capabilities: [:orders],
          tags: [:linux],
          metadata_keys: ["region"]
        )
      )
      expect(text).to include("Cluster Host: peer=orders-node, capabilities=2, tags=2, seeds=1, static_peers=1")
      expect(markdown).to include("## Cluster App Host")
      expect(markdown).to include("- Peer: name=`orders-node` local_url=`http://orders-node:5678`")
      expect(markdown).to include("- Server: host=`127.0.0.1` port=`5678` log_format=`text`")
    end

    it "builds and applies app SDK evolution plans from coverage gaps" do
      network_executor = Class.new(Igniter::Executor) do
        capabilities :network

        def call(x:) = x + 1
      end

      klass = Class.new(Igniter::Contract) do
        define do
          input :x
          compute :net_value, depends_on: :x, call: network_executor
          output :net_value
        end
      end

      app = stub_const("SpecEvolutionApp", Class.new(Igniter::App))

      Dir.mktmpdir do |dir|
        app.class_eval do
          root_dir dir
          evolution_log "var/evolution.jsonl"
          use :data
          register "NetworkContract", klass
        end

        app.send(:build!)
        contract = klass.new(x: 10)

        plan = app.evolution_plan(contract)
        approval_request = app.evolution_approval(plan)

        expect(plan).to be_a(Igniter::App::Evolution::Plan)
        expect(plan.summary).to include(
          total: 1,
          automated: 0,
          approval_required: 1,
          constrained: 1,
          uncovered_capabilities: [:network],
          by_action: { activate_sdk_capability: 1 }
        )
        expect(plan.actions).to contain_exactly(
          include(
            id: "app_sdk:activate_sdk_capability:network",
            action: :activate_sdk_capability,
            scope: :app_sdk,
            automated: false,
            requires_approval: true,
            constraints: [:selection_required],
            params: include(capability: :network, sdk_capabilities: %i[ai channels])
          )
        )
        expect(approval_request).to be_a(Igniter::App::Evolution::ApprovalRequest)
        expect(approval_request.summary).to include(
          total: 1,
          constrained: 1,
          by_action: { activate_sdk_capability: 1 }
        )
        expect(approval_request.actions).to contain_exactly(
          include(
            id: "app_sdk:activate_sdk_capability:network",
            action: :activate_sdk_capability,
            capability: :network,
            candidates: %i[ai channels],
            constraints: [:selection_required],
            requires_approval: true
          )
        )
        expect(app.evolution_trail.snapshot(limit: 10)).to include(
          total: 2,
          latest_type: :evolution_approval_requested,
          by_type: {
            evolution_plan_built: 1,
            evolution_approval_requested: 1
          },
          persistence: include(enabled: true, path: File.join(dir, "var/evolution.jsonl"), archived_events: 0)
        )

        blocked = app.apply_evolution!(plan)

        expect(blocked.status).to eq(:blocked)
        expect(blocked.applied).to eq([])
        expect(blocked.blocked).to contain_exactly(
          include(
            action: :activate_sdk_capability,
            status: :blocked,
            reason: :approval_required,
            params: include(capability: :network, sdk_capabilities: %i[ai channels])
          )
        )
        expect(app.sdk_capabilities).to eq([:data])

        approval_decision = Igniter::App::Evolution::ApprovalDecision.build(
          approved_action_ids: approval_request.action_ids,
          selections: { network: :ai },
          metadata: { actor: "operator" }
        )

        denied = app.apply_evolution!(
          plan,
          approval: approval_decision.to_h.merge(denied_action_ids: approval_request.action_ids)
        )

        expect(denied.status).to eq(:blocked)
        expect(denied.blocked).to contain_exactly(
          include(
            action: :activate_sdk_capability,
            status: :blocked,
            reason: :approval_denied
          )
        )

        applied = app.apply_evolution!(plan, approval: approval_decision)

        expect(applied.status).to eq(:applied)
        expect(applied.blocked).to eq([])
        expect(applied.applied).to contain_exactly(
          include(
            action: :activate_sdk_capability,
            status: :applied,
            capability: :network,
            applied_sdk_capabilities: [:ai]
          )
        )
        expect(app.sdk_capabilities).to contain_exactly(:ai, :data)
        expect(contract.diagnostics.to_h.dig(:app_sdk, :requested_capabilities)).to contain_exactly(:ai, :data)
        expect(contract.diagnostics.to_h.dig(:app_sdk, :coverage, :covered_capabilities)).to include(:network)
        expect(contract.diagnostics.to_h.dig(:app_sdk, :coverage, :uncovered_capabilities)).to eq([])
        expect(contract.diagnostics.to_h[:app_evolution]).to include(
          total: 7,
          latest_type: :evolution_applied,
          by_type: {
            evolution_plan_built: 1,
            evolution_approval_requested: 1,
            evolution_blocked: 2,
            evolution_approval_recorded: 2,
            evolution_applied: 1
          },
          persistence: include(enabled: true, path: File.join(dir, "var/evolution.jsonl"), archived_events: 0)
        )
        expect(contract.diagnostics_text).to include("App Evolution: total=7, latest=evolution_applied, persisted=true, retain=all, archived=0")
        expect(contract.diagnostics_markdown).to include("Persistence: enabled=true")
        expect(contract.diagnostics_markdown).to include("`evolution_applied`")

        reloaded = app.reload_evolution_trail!

        expect(reloaded.snapshot(limit: 10)).to include(
          total: 7,
          latest_type: :evolution_applied,
          by_type: {
            evolution_plan_built: 1,
            evolution_approval_requested: 1,
            evolution_blocked: 2,
            evolution_approval_recorded: 2,
            evolution_applied: 1
          },
          persistence: include(enabled: true, path: File.join(dir, "var/evolution.jsonl"), archived_events: 0)
        )
      end
    end

    it "rotates persisted evolution events and retains only the live crest" do
      app = stub_const("SpecEvolutionRetentionApp", Class.new(Igniter::App))

      Dir.mktmpdir do |dir|
        app.class_eval do
          root_dir dir
          evolution_log "var/evolution.jsonl", retain_events: 3, archive: "var/evolution.archive.jsonl"
        end

        trail = app.evolution_trail
        5.times do |index|
          trail.record(:evolution_tick, source: :test, payload: { step: index + 1 })
        end

        snapshot = trail.snapshot(limit: 10)
        expect(snapshot).to include(
          total: 3,
          latest_type: :evolution_tick,
          by_type: { evolution_tick: 3 },
          persistence: include(
            enabled: true,
            path: File.join(dir, "var/evolution.jsonl"),
            max_events: 3,
            archive_path: File.join(dir, "var/evolution.archive.jsonl"),
            archived_events: 2
          )
        )
        expect(snapshot[:events].map { |event| event.dig(:payload, :step) }).to eq([3, 4, 5])

        reloaded = app.reload_evolution_trail!
        reloaded_snapshot = reloaded.snapshot(limit: 10)
        expect(reloaded_snapshot[:events].map { |event| event.dig(:payload, :step) }).to eq([3, 4, 5])
        expect(reloaded_snapshot[:persistence]).to include(
          max_events: 3,
          archived_events: 2
        )
      end
    end

    it "retains the latest evolution crest per event class policy" do
      app = stub_const("SpecEvolutionPolicyApp", Class.new(Igniter::App))

      Dir.mktmpdir do |dir|
        app.class_eval do
          root_dir dir
          evolution_log(
            "var/evolution.jsonl",
            archive: "var/evolution.archive.jsonl",
            retention_policy: {
              planning: 1,
              approval: 1,
              blocked: 2,
              applied: 1,
              default: 1
            }
          )
        end

        trail = app.evolution_trail
        trail.record(:evolution_plan_built, source: :test, payload: { step: 1 })
        trail.record(:evolution_plan_built, source: :test, payload: { step: 2 })
        trail.record(:evolution_approval_requested, source: :test, payload: { step: 3 })
        trail.record(:evolution_approval_recorded, source: :test, payload: { step: 4 })
        trail.record(:evolution_blocked, source: :test, payload: { step: 5 })
        trail.record(:evolution_blocked, source: :test, payload: { step: 6 })
        trail.record(:evolution_blocked, source: :test, payload: { step: 7 })
        trail.record(:evolution_applied, source: :test, payload: { step: 8 })
        trail.record(:evolution_applied, source: :test, payload: { step: 9 })
        trail.record(:evolution_tick, source: :test, payload: { step: 10 })
        trail.record(:evolution_tick, source: :test, payload: { step: 11 })

        snapshot = trail.snapshot(limit: 20)
        expect(snapshot).to include(
          total: 6,
          latest_type: :evolution_tick,
          by_type: {
            evolution_plan_built: 1,
            evolution_approval_recorded: 1,
            evolution_blocked: 2,
            evolution_applied: 1,
            evolution_tick: 1
          },
          persistence: include(
            enabled: true,
            path: File.join(dir, "var/evolution.jsonl"),
            archive_path: File.join(dir, "var/evolution.archive.jsonl"),
            archived_events: 5,
            retention_policy: {
              planning: 1,
              approval: 1,
              blocked: 2,
              applied: 1,
              default: 1
            },
            retained_by_class: {
              planning: 1,
              approval: 1,
              blocked: 2,
              applied: 1,
              other: 1
            },
            archived_by_class: {
              planning: 1,
              approval: 1,
              blocked: 1,
              applied: 1,
              other: 1
            }
          )
        )
        expect(snapshot[:events].map { |event| event.dig(:payload, :step) }).to eq([2, 4, 6, 7, 9, 11])

        reloaded = app.reload_evolution_trail!
        reloaded_snapshot = reloaded.snapshot(limit: 20)
        expect(reloaded_snapshot[:events].map { |event| event.dig(:payload, :step) }).to eq([2, 4, 6, 7, 9, 11])
        expect(reloaded_snapshot[:persistence]).to include(
          archived_events: 5,
          retained_by_class: {
            planning: 1,
            approval: 1,
            blocked: 2,
            applied: 1,
            other: 1
          }
        )
      end
    end

    it "builds app orchestration plans and surfaces follow-ups in diagnostics" do
      previous_adapter = Igniter::Runtime.agent_adapter
      Igniter::Runtime.activate_agent_adapter!
      Igniter::Registry.clear
      writer_ref = nil
      reviewer_ref = nil

      writer_class = Class.new(Igniter::Agent) do
        on :summarize do |payload:, **|
          raise Igniter::PendingDependencyError.new("continue", token: "writer-session", source_node: :summary)
        end
      end

      reviewer_class = Class.new(Igniter::Agent) do
        on :review do |payload:, **|
          raise Igniter::PendingDependencyError.new("wait", token: "review-session", source_node: :approval)
        end
      end

      writer_ref = writer_class.start(name: :writer)
      reviewer_ref = reviewer_class.start(name: :reviewer)

      klass = Class.new(Igniter::Contract) do
        define do
          input :name

          agent :interactive_summary,
                via: :writer,
                message: :summarize,
                reply: :stream,
                inputs: { name: :name }

          agent :manual_summary,
                via: :writer,
                message: :summarize,
                reply: :stream,
                session_policy: :manual,
                finalizer: :events,
                inputs: { name: :name }

          agent :approval,
                via: :reviewer,
                message: :review,
                inputs: { name: :name }

          output :interactive_summary
          output :manual_summary
          output :approval
        end
      end

      app = stub_const("SpecOrchestrationApp", Class.new(Igniter::App))

      app.class_eval do
        register "AgentContract", klass
      end

      app.send(:build!)
      app.reset_orchestration_inbox!
      contract = klass.new(name: "Alice")

      plan = app.orchestration_plan(contract)
      followup = app.orchestration_followup(plan)
      opened = app.open_orchestration_followups(contract)
      reopened = app.open_orchestration_followups(contract)
      acknowledged = app.acknowledge_orchestration_item("agent_orchestration:open_interactive_session:interactive_summary", note: "picked up")
      resolved = app.resolve_orchestration_item("agent_orchestration:require_manual_completion:manual_summary", note: "done")
      dismissed = app.dismiss_orchestration_item("agent_orchestration:await_deferred_reply:approval", note: "not needed")
      reopened_after_close = app.open_orchestration_followups(contract)
      report = contract.diagnostics.to_h
      text = contract.diagnostics_text
      markdown = contract.diagnostics_markdown

      expect(plan).to be_a(Igniter::App::Orchestration::Plan)
      expect(plan.summary).to include(
        total: 3,
        attention_required: 3,
        manual_completion: 1,
        deferred_replies: 1,
        interactive_sessions: 1,
        single_turn_sessions: 0,
        attention_nodes: %i[interactive_summary manual_summary approval],
        by_action: {
          open_interactive_session: 1,
          require_manual_completion: 1,
          await_deferred_reply: 1
        },
        by_policy: {
          interactive_session: 1,
          manual_completion: 1,
          deferred_reply: 1
        },
        by_lane: {
          interactive_sessions: 1,
          manual_completions: 1,
          deferred_replies: 1
        },
        by_queue: {
          "interactive-sessions" => 1,
          "manual-completions" => 1,
          "deferred-replies" => 1
        },
        by_channel: {
          "inbox://interactive-sessions" => 1,
          "inbox://manual-completions" => 1,
          "inbox://deferred-replies" => 1
        }
      )
      expect(plan.actions).to contain_exactly(
        include(action: :open_interactive_session, node: :interactive_summary, interaction: :interactive_session, attention_required: true, lane: include(name: :interactive_sessions, queue: "interactive-sessions", channel: "inbox://interactive-sessions"), policy: include(name: :interactive_session, default_operation: :wake, allowed_operations: %i[wake handoff complete dismiss]), routing: include(queue: "interactive-sessions", channel: "inbox://interactive-sessions")),
        include(action: :require_manual_completion, node: :manual_summary, interaction: :manual_session, attention_required: true, lane: include(name: :manual_completions, queue: "manual-completions", channel: "inbox://manual-completions"), policy: include(name: :manual_completion, default_operation: :approve, allowed_operations: %i[approve handoff dismiss]), routing: include(queue: "manual-completions", channel: "inbox://manual-completions")),
        include(action: :await_deferred_reply, node: :approval, interaction: :deferred_call, attention_required: true, lane: include(name: :deferred_replies, queue: "deferred-replies", channel: "inbox://deferred-replies"), policy: include(name: :deferred_reply, default_operation: :reply, allowed_operations: %i[reply handoff dismiss]), routing: include(queue: "deferred-replies", channel: "inbox://deferred-replies"))
      )

      expect(followup).to be_a(Igniter::App::Orchestration::FollowupRequest)
      expect(followup.summary).to include(
        total: 3,
        manual_completion: 1,
        deferred_replies: 1,
        interactive_sessions: 1,
        by_action: {
          open_interactive_session: 1,
          require_manual_completion: 1,
          await_deferred_reply: 1
        },
        by_policy: {
          interactive_session: 1,
          manual_completion: 1,
          deferred_reply: 1
        },
        by_lane: {
          interactive_sessions: 1,
          manual_completions: 1,
          deferred_replies: 1
        },
        by_queue: {
          "interactive-sessions" => 1,
          "manual-completions" => 1,
          "deferred-replies" => 1
        },
        by_channel: {
          "inbox://interactive-sessions" => 1,
          "inbox://manual-completions" => 1,
          "inbox://deferred-replies" => 1
        }
      )
      expect(followup.action_ids).to contain_exactly(
        "agent_orchestration:open_interactive_session:interactive_summary",
        "agent_orchestration:require_manual_completion:manual_summary",
        "agent_orchestration:await_deferred_reply:approval"
      )
      expect(opened.status).to eq(:opened)
      expect(opened.opened).to contain_exactly(
        include(action: :open_interactive_session, node: :interactive_summary, graph: "AnonymousContract", status: :open, lane: include(name: :interactive_sessions), policy: include(name: :interactive_session), routing: include(queue: "interactive-sessions", channel: "inbox://interactive-sessions"), queue: "interactive-sessions", channel: "inbox://interactive-sessions"),
        include(action: :require_manual_completion, node: :manual_summary, graph: "AnonymousContract", status: :open, lane: include(name: :manual_completions), policy: include(name: :manual_completion), routing: include(queue: "manual-completions", channel: "inbox://manual-completions"), queue: "manual-completions", channel: "inbox://manual-completions"),
        include(action: :await_deferred_reply, node: :approval, graph: "AnonymousContract", status: :open, lane: include(name: :deferred_replies), policy: include(name: :deferred_reply), routing: include(queue: "deferred-replies", channel: "inbox://deferred-replies"), queue: "deferred-replies", channel: "inbox://deferred-replies")
      )
      expect(reopened.status).to eq(:existing)
      expect(reopened.existing).to contain_exactly(
        include(id: "agent_orchestration:open_interactive_session:interactive_summary", status: :existing),
        include(id: "agent_orchestration:require_manual_completion:manual_summary", status: :existing),
        include(id: "agent_orchestration:await_deferred_reply:approval", status: :existing)
      )
      expect(acknowledged).to include(
        id: "agent_orchestration:open_interactive_session:interactive_summary",
        status: :acknowledged,
        note: "picked up"
      )
      expect(acknowledged[:action_history]).to include(
        include(event: :opened, status: :open, source: :agent_orchestration),
        include(event: :acknowledged, status: :acknowledged, note: "picked up")
      )
      expect(resolved).to include(
        id: "agent_orchestration:require_manual_completion:manual_summary",
        status: :resolved,
        note: "done"
      )
      expect(resolved[:action_history].last).to include(
        event: :resolved,
        status: :resolved,
        note: "done"
      )
      expect(dismissed).to include(
        id: "agent_orchestration:await_deferred_reply:approval",
        status: :dismissed,
        note: "not needed"
      )
      expect(dismissed[:action_history].last).to include(
        event: :dismissed,
        status: :dismissed,
        note: "not needed"
      )
      expect(reopened_after_close.status).to eq(:partial)
      expect(reopened_after_close.opened).to contain_exactly(
        include(id: "agent_orchestration:require_manual_completion:manual_summary", status: :open),
        include(id: "agent_orchestration:await_deferred_reply:approval", status: :open)
      )
      expect(reopened_after_close.existing).to contain_exactly(
        include(id: "agent_orchestration:open_interactive_session:interactive_summary", status: :existing)
      )
      expect(app.orchestration_inbox.snapshot).to include(
        total: 5,
        open: 2,
        acknowledged: 1,
        resolved: 1,
        dismissed: 1,
        actionable: 3,
        by_status: {
          acknowledged: 1,
          resolved: 1,
          dismissed: 1,
          open: 2
        },
        latest_action: :await_deferred_reply,
        latest_node: :approval,
        latest_policy: :deferred_reply,
        latest_lane: :deferred_replies,
        latest_queue: "deferred-replies",
        latest_channel: "inbox://deferred-replies",
        latest_status: :open,
        latest_action_event: include(event: :opened, status: :open, source: :agent_orchestration),
        by_action: {
          open_interactive_session: 1,
          require_manual_completion: 2,
          await_deferred_reply: 2
        },
        by_policy: {
          interactive_session: 1,
          manual_completion: 2,
          deferred_reply: 2
        },
        by_lane: {
          interactive_sessions: 1,
          manual_completions: 2,
          deferred_replies: 2
        },
        by_queue: {
          "interactive-sessions" => 1,
          "manual-completions" => 2,
          "deferred-replies" => 2
        },
        by_channel: {
          "inbox://interactive-sessions" => 1,
          "inbox://manual-completions" => 2,
          "inbox://deferred-replies" => 2
        }
      )

      expect(report[:app_orchestration]).to include(
        app: "SpecOrchestrationApp",
        source: :agent_orchestration,
        summary: include(
          total: 3,
          attention_required: 3,
          manual_completion: 1,
          deferred_replies: 1,
          interactive_sessions: 1,
          by_policy: {
            interactive_session: 1,
            manual_completion: 1,
            deferred_reply: 1
          },
          by_lane: {
            interactive_sessions: 1,
            manual_completions: 1,
            deferred_replies: 1
          },
          by_queue: {
            "interactive-sessions" => 1,
            "manual-completions" => 1,
            "deferred-replies" => 1
          },
          by_channel: {
            "inbox://interactive-sessions" => 1,
            "inbox://manual-completions" => 1,
            "inbox://deferred-replies" => 1
          }
        ),
        followup: include(
          summary: include(
            total: 3,
            manual_completion: 1,
            deferred_replies: 1,
            interactive_sessions: 1,
            by_policy: {
              interactive_session: 1,
              manual_completion: 1,
              deferred_reply: 1
            },
            by_lane: {
              interactive_sessions: 1,
              manual_completions: 1,
              deferred_replies: 1
            },
            by_queue: {
              "interactive-sessions" => 1,
              "manual-completions" => 1,
              "deferred-replies" => 1
            },
            by_channel: {
              "inbox://interactive-sessions" => 1,
              "inbox://manual-completions" => 1,
              "inbox://deferred-replies" => 1
            }
          )
        ),
        inbox: include(
          total: 5,
          open: 2,
          acknowledged: 1,
          resolved: 1,
          dismissed: 1,
          actionable: 3,
          latest_action: :await_deferred_reply,
          latest_node: :approval,
          latest_policy: :deferred_reply,
          latest_queue: "deferred-replies",
          latest_channel: "inbox://deferred-replies",
          latest_status: :open,
          by_action: {
            open_interactive_session: 1,
            require_manual_completion: 2,
            await_deferred_reply: 2
          },
          by_policy: {
            interactive_session: 1,
            manual_completion: 2,
            deferred_reply: 2
          },
          by_queue: {
            "interactive-sessions" => 1,
            "manual-completions" => 2,
            "deferred-replies" => 2
          },
          by_channel: {
            "inbox://interactive-sessions" => 1,
            "inbox://manual-completions" => 2,
            "inbox://deferred-replies" => 2
          },
          by_status: {
            acknowledged: 1,
            resolved: 1,
            dismissed: 1,
            open: 2
          }
        )
      )
      expect(report[:app_orchestration][:actions]).to contain_exactly(
        include(action: :open_interactive_session, node: :interactive_summary, policy: include(name: :interactive_session), routing: include(queue: "interactive-sessions", channel: "inbox://interactive-sessions")),
        include(action: :require_manual_completion, node: :manual_summary, policy: include(name: :manual_completion), routing: include(queue: "manual-completions", channel: "inbox://manual-completions")),
        include(action: :await_deferred_reply, node: :approval, policy: include(name: :deferred_reply), routing: include(queue: "deferred-replies", channel: "inbox://deferred-replies"))
      )
      expect(report[:app_operator]).to include(
        app: "SpecOrchestrationApp",
        summary: include(
          total: 5,
          live_sessions: 3,
          inbox_items: 5,
          joined_records: 3,
          session_only: 0,
          inbox_only: 2,
          handed_off: 0,
          by_combined_state: {
            joined: 3,
            inbox_only: 2
          }
        )
      )
      expect(report[:app_operator][:records]).to include(
        include(node: :interactive_summary, combined_state: :joined, status: :acknowledged, phase: :streaming),
        include(node: :manual_summary, combined_state: :inbox_only, status: :resolved, phase: :streaming),
        include(node: :approval, combined_state: :inbox_only, status: :dismissed, phase: :waiting),
        include(node: :manual_summary, combined_state: :joined, status: :open, phase: :streaming),
        include(node: :approval, combined_state: :joined, status: :open, phase: :waiting)
      )
      expect(text).to include("App Orchestration: total=3, attention_required=3, manual_completion=1, deferred_replies=1, interactive_sessions=1, single_turn_sessions=0, followups=3")
      expect(text).to include("by_policy=deferred_reply=1, interactive_session=1, manual_completion=1")
      expect(text).to include("by_lane=deferred_replies=1, interactive_sessions=1, manual_completions=1")
      expect(text).to include("by_queue=deferred-replies=1, interactive-sessions=1, manual-completions=1")
      expect(text).to include("App Orchestration Inbox: total=5, open=2, acknowledged=1, resolved=1, dismissed=1, actionable=3, latest_action=await_deferred_reply, latest_node=approval, latest_policy=deferred_reply, latest_lane=deferred_replies, latest_assignee=none, latest_queue=deferred-replies, latest_channel=inbox://deferred-replies, latest_status=open")
      expect(text).to include("App Operator: total=5, live_sessions=3, inbox_items=5, joined=3, session_only=0, inbox_only=2")
      expect(markdown).to include("## App Orchestration")
      expect(markdown).to include("## App Operator")
      expect(markdown).to include("- Follow-up: total=3, manual_completion=1, deferred_replies=1, interactive_sessions=1, by_policy=deferred_reply=1, interactive_session=1, manual_completion=1, by_lane=deferred_replies=1, interactive_sessions=1, manual_completions=1, by_queue=deferred-replies=1, interactive-sessions=1, manual-completions=1")
      expect(markdown).to include("- Inbox: total=5, open=2, acknowledged=1, resolved=1, dismissed=1, actionable=3, latest_action=await_deferred_reply, latest_node=approval, latest_policy=deferred_reply, latest_lane=deferred_replies, latest_assignee=none, latest_queue=deferred-replies, latest_channel=inbox://deferred-replies, latest_status=open")
      expect(markdown).to include("state=`joined`")
      expect(markdown).to include("state=`inbox_only`")
      expect(markdown).to include("`manual_summary` `require_manual_completion`")
      expect(markdown).to include("policy=`manual_completion`")
      expect(markdown).to include("lane=`manual_completions`")
      expect(markdown).to include("default=`approve`")
      expect(markdown).to include("queue=`manual-completions`")
      expect(markdown).to include("`approval` `await_deferred_reply`")
    ensure
      writer_ref&.stop
      reviewer_ref&.stop
      Igniter::Registry.clear
      Igniter::Runtime.agent_adapter = previous_adapter
    end

    it "can resolve orchestration items by resuming the underlying agent session" do
      previous_adapter = Igniter::Runtime.agent_adapter
      Igniter::Runtime.activate_agent_adapter!
      Igniter::Registry.clear
      writer_ref = nil
      reviewer_ref = nil

      writer_class = Class.new(Igniter::Agent) do
        on :summarize do |payload:, **|
          raise Igniter::PendingDependencyError.new("continue", token: "writer-session", source_node: :summary)
        end
      end

      reviewer_class = Class.new(Igniter::Agent) do
        on :review do |payload:, **|
          raise Igniter::PendingDependencyError.new("wait", token: "review-session", source_node: :approval)
        end
      end

      writer_ref = writer_class.start(name: :writer)
      reviewer_ref = reviewer_class.start(name: :reviewer)

      klass = Class.new(Igniter::Contract) do
        define do
          input :name

          agent :interactive_summary,
                via: :writer,
                message: :summarize,
                reply: :stream,
                inputs: { name: :name }

          agent :manual_summary,
                via: :writer,
                message: :summarize,
                reply: :stream,
                session_policy: :manual,
                finalizer: :events,
                inputs: { name: :name }

          agent :approval,
                via: :reviewer,
                message: :review,
                inputs: { name: :name }

          output :interactive_summary
          output :manual_summary
          output :approval
        end
      end

      app = stub_const("SpecOrchestrationResumeApp", Class.new(Igniter::App))
      app.class_eval { register "AgentContract", klass }

      app.send(:build!)
      app.reset_orchestration_inbox!
      contract = klass.new(name: "Alice")

      app.open_orchestration_followups(contract)

      resolved_manual = app.resolve_orchestration_item(
        "agent_orchestration:require_manual_completion:manual_summary",
        target: contract,
        value: [{ kind: :manual, value: "done" }],
        note: "completed in app"
      )
      resolved_approval = app.resolve_orchestration_item(
        "agent_orchestration:await_deferred_reply:approval",
        target: contract,
        value: "approved",
        note: "reply received"
      )

      expect(resolved_manual).to include(
        id: "agent_orchestration:require_manual_completion:manual_summary",
        status: :resolved,
        runtime_resumed: true,
        resolved_graph: "AnonymousContract",
        note: "completed in app"
      )
      expect(resolved_approval).to include(
        id: "agent_orchestration:await_deferred_reply:approval",
        status: :resolved,
        runtime_resumed: true,
        resolved_graph: "AnonymousContract",
        note: "reply received"
      )

      expect(contract.execution.cache.fetch(:manual_summary)).to be_succeeded
      expect(contract.execution.cache.fetch(:approval)).to be_succeeded
      expect(contract.execution.cache.fetch(:interactive_summary)).to be_pending
      expect(contract.result.manual_summary).to eq([{ kind: :manual, value: "done" }])
      expect(contract.result.approval).to eq("approved")

      expect(app.orchestration_inbox.snapshot).to include(
        total: 3,
        open: 1,
        resolved: 2,
        actionable: 1,
        by_status: {
          open: 1,
          resolved: 2
        }
      )

      reopened = app.open_orchestration_followups(contract)
      expect(reopened.status).to eq(:existing)
      expect(reopened.opened).to eq([])
      expect(reopened.existing).to contain_exactly(
        include(id: "agent_orchestration:open_interactive_session:interactive_summary", status: :existing)
      )
    ensure
      writer_ref&.stop
      reviewer_ref&.stop
      Igniter::Registry.clear
      Igniter::Runtime.agent_adapter = previous_adapter
    end

    it "handles orchestration items through built-in handlers" do
      previous_adapter = Igniter::Runtime.agent_adapter
      Igniter::Runtime.activate_agent_adapter!
      Igniter::Registry.clear
      writer_ref = nil
      reviewer_ref = nil

      writer_class = Class.new(Igniter::Agent) do
        on :summarize do |payload:, **|
          raise Igniter::PendingDependencyError.new("continue", token: "writer-session", source_node: :summary)
        end
      end

      reviewer_class = Class.new(Igniter::Agent) do
        on :review do |payload:, **|
          raise Igniter::PendingDependencyError.new("wait", token: "review-session", source_node: :approval)
        end
      end

      writer_ref = writer_class.start(name: :writer)
      reviewer_ref = reviewer_class.start(name: :reviewer)

      klass = Class.new(Igniter::Contract) do
        define do
          input :name

          agent :interactive_summary,
                via: :writer,
                message: :summarize,
                reply: :stream,
                inputs: { name: :name }

          agent :manual_summary,
                via: :writer,
                message: :summarize,
                reply: :stream,
                session_policy: :manual,
                finalizer: :events,
                inputs: { name: :name }

          agent :approval,
                via: :reviewer,
                message: :review,
                inputs: { name: :name }

          output :interactive_summary
          output :manual_summary
          output :approval
        end
      end

      app = stub_const("SpecOrchestrationHandlersApp", Class.new(Igniter::App))
      app.class_eval { register "AgentContract", klass }

      app.send(:build!)
      app.reset_orchestration_inbox!
      contract = klass.new(name: "Alice")

      app.open_orchestration_followups(contract)

      acknowledged = app.handle_orchestration_item(
        "agent_orchestration:open_interactive_session:interactive_summary",
        note: "picked up"
      )
      resolved_manual = app.handle_orchestration_item(
        "agent_orchestration:require_manual_completion:manual_summary",
        target: contract,
        value: [{ kind: :manual, value: "done" }],
        note: "completed in app"
      )
      dismissed_approval = app.handle_orchestration_item(
        "agent_orchestration:await_deferred_reply:approval",
        operation: :dismiss,
        note: "ignored for now"
      )

      expect(acknowledged).to include(
        id: "agent_orchestration:open_interactive_session:interactive_summary",
        status: :acknowledged,
        handled_action: :open_interactive_session,
        handled_policy: :interactive_session,
        handled_operation: :wake,
        handled_lifecycle_operation: :acknowledge,
        note: "picked up"
      )
      expect(resolved_manual).to include(
        id: "agent_orchestration:require_manual_completion:manual_summary",
        status: :resolved,
        handled_action: :require_manual_completion,
        handled_policy: :manual_completion,
        handled_operation: :approve,
        handled_lifecycle_operation: :resolve,
        runtime_resumed: true,
        note: "completed in app"
      )
      expect(dismissed_approval).to include(
        id: "agent_orchestration:await_deferred_reply:approval",
        status: :dismissed,
        handled_action: :await_deferred_reply,
        handled_policy: :deferred_reply,
        handled_operation: :dismiss,
        handled_lifecycle_operation: :dismiss,
        note: "ignored for now"
      )

      expect(contract.execution.cache.fetch(:interactive_summary)).to be_pending
      expect(contract.execution.cache.fetch(:manual_summary)).to be_succeeded
      expect(contract.execution.cache.fetch(:approval)).to be_pending
      expect(contract.result.manual_summary).to eq([{ kind: :manual, value: "done" }])

      expect(app.orchestration_inbox.snapshot).to include(
        total: 3,
        acknowledged: 1,
        resolved: 1,
        dismissed: 1,
        actionable: 1,
        by_status: {
          acknowledged: 1,
          resolved: 1,
          dismissed: 1
        }
      )
    ensure
      writer_ref&.stop
      reviewer_ref&.stop
      Igniter::Registry.clear
      Igniter::Runtime.agent_adapter = previous_adapter
    end

    it "handles resumable orchestration items through the execution store when no live target is provided" do
      previous_store = Igniter.execution_store
      Igniter.execution_store = Igniter::Runtime::Stores::MemoryStore.new

      trace = {
        adapter: :queue,
        mode: :call,
        via: :reviewer,
        message: :review,
        outcome: :deferred,
        reason: :awaiting_review
      }

      agent_adapter = Class.new do
        define_method(:call) do |node:, **|
          {
            status: :pending,
            payload: { queue: :review },
            agent_trace: trace,
            session: {
              node_name: node.name,
              node_path: node.path,
              agent_name: node.agent_name,
              message_name: node.message_name,
              mode: node.mode,
              waiting_on: node.name,
              source_node: node.name,
              trace: trace
            }
          }
        end

        define_method(:cast) do |**|
          raise "unexpected cast"
        end
      end.new

      klass = Class.new(Igniter::Contract) do
        run_with runner: :store, agent_adapter: agent_adapter

        define do
          input :name
          agent :approval, via: :reviewer, message: :review, inputs: { name: :name }
          compute :final_answer, depends_on: :approval do |approval:|
            "approved: #{approval}"
          end
          output :final_answer
        end
      end

      app = stub_const("SpecDurableOrchestrationHandlersApp", Class.new(Igniter::App))
      app.class_eval { register "AgentContract", klass }

      app.send(:build!)
      app.reset_orchestration_inbox!
      contract = klass.new(name: "Alice")
      execution_id = contract.execution.events.execution_id

      app.open_orchestration_followups(contract)

      resolved = app.handle_orchestration_item(
        "agent_orchestration:await_deferred_reply:approval",
        value: "ok",
        note: "resumed from store"
      )

      expect(resolved).to include(
        id: "agent_orchestration:await_deferred_reply:approval",
        status: :resolved,
        handled_action: :await_deferred_reply,
        handled_policy: :deferred_reply,
        handled_operation: :reply,
        handled_lifecycle_operation: :resolve,
        runtime_resumed: true,
        runtime_resume_mode: :store,
        resolved_execution_id: execution_id,
        resolved_graph: "AnonymousContract",
        resumed_node: :approval,
        note: "resumed from store"
      )
      expect(Igniter.execution_store.exist?(execution_id)).to eq(false)
    ensure
      Igniter.execution_store = previous_store
    end

    it "supports domain orchestration operations and convenience helpers" do
      previous_adapter = Igniter::Runtime.agent_adapter
      Igniter::Runtime.activate_agent_adapter!
      Igniter::Registry.clear
      writer_ref = nil
      reviewer_ref = nil

      writer_class = Class.new(Igniter::Agent) do
        on :summarize do |payload:, **|
          raise Igniter::PendingDependencyError.new("continue", token: "writer-session", source_node: :summary)
        end
      end

      reviewer_class = Class.new(Igniter::Agent) do
        on :review do |payload:, **|
          raise Igniter::PendingDependencyError.new("wait", token: "review-session", source_node: :approval)
        end
      end

      writer_ref = writer_class.start(name: :writer)
      reviewer_ref = reviewer_class.start(name: :reviewer)

      klass = Class.new(Igniter::Contract) do
        define do
          input :name

          agent :interactive_summary,
                via: :writer,
                message: :summarize,
                reply: :stream,
                inputs: { name: :name }

          agent :manual_summary,
                via: :writer,
                message: :summarize,
                reply: :stream,
                session_policy: :manual,
                finalizer: :events,
                inputs: { name: :name }

          agent :approval,
                via: :reviewer,
                message: :review,
                inputs: { name: :name }

          output :interactive_summary
          output :manual_summary
          output :approval
        end
      end

      app = stub_const("SpecOrchestrationDomainOpsApp", Class.new(Igniter::App))
      app.class_eval { register "AgentContract", klass }

      app.send(:build!)
      app.reset_orchestration_inbox!
      contract = klass.new(name: "Alice")

      app.open_orchestration_followups(contract)

      woken = app.wake_orchestration_item(
        "agent_orchestration:open_interactive_session:interactive_summary",
        note: "operator pinged"
      )
      handed_off = app.handle_orchestration_item(
        "agent_orchestration:open_interactive_session:interactive_summary",
        operation: :handoff,
        assignee: "ops:alice",
        queue: "manual-review",
        channel: "slack://ops/review",
        note: "routed to reviewer",
        audit: {
          actor: "alice",
          origin: :operator_console,
          actor_channel: "/operator"
        }
      )
      approved = app.approve_orchestration_item(
        "agent_orchestration:require_manual_completion:manual_summary",
        target: contract,
        value: [{ kind: :manual, value: "approved" }],
        note: "operator approved"
      )
      replied = app.reply_to_orchestration_item(
        "agent_orchestration:await_deferred_reply:approval",
        target: contract,
        value: "approved",
        note: "reply delivered"
      )

      expect(woken).to include(
        handled_policy: :interactive_session,
        handled_operation: :wake,
        handled_lifecycle_operation: :acknowledge,
        status: :acknowledged
      )
      expect(handed_off).to include(
        handled_policy: :interactive_session,
        handled_operation: :handoff,
        handled_lifecycle_operation: :acknowledge,
        handled_audit_source: :orchestration_handler,
        handled_assignee: "ops:alice",
        handled_queue: "manual-review",
        handled_channel: "slack://ops/review",
        assignee: "ops:alice",
        queue: "manual-review",
        channel: "slack://ops/review",
        handoff_count: 1,
        status: :acknowledged
      )
      expect(approved).to include(
        handled_policy: :manual_completion,
        handled_operation: :approve,
        handled_lifecycle_operation: :resolve,
        runtime_resumed: true,
        status: :resolved
      )
      expect(replied).to include(
        handled_policy: :deferred_reply,
        handled_operation: :reply,
        handled_lifecycle_operation: :resolve,
        runtime_resumed: true,
        status: :resolved
      )
      expect(app.orchestration_inbox.find("agent_orchestration:open_interactive_session:interactive_summary")).to include(
        assignee: "ops:alice",
        queue: "manual-review",
        channel: "slack://ops/review",
        handoff_count: 1
      )
      expect(app.orchestration_inbox.find("agent_orchestration:open_interactive_session:interactive_summary")[:handoff_history]).to contain_exactly(
        include(
          assignee: "ops:alice",
          queue: "manual-review",
          channel: "slack://ops/review",
          note: "routed to reviewer"
        )
      )
      expect(app.orchestration_inbox.find("agent_orchestration:open_interactive_session:interactive_summary")[:action_history].last).to include(
        event: :handoff,
        status: :acknowledged,
        source: :orchestration_handler,
        actor: "alice",
        origin: :operator_console,
        actor_channel: "/operator",
        requested_operation: :handoff,
        lifecycle_operation: :acknowledge,
        assignee: "ops:alice",
        queue: "manual-review",
        channel: "slack://ops/review"
      )
      expect(app.orchestration_inbox.snapshot).to include(
        by_assignee: { "ops:alice" => 1 },
        by_queue: {
          "manual-review" => 1,
          "manual-completions" => 1,
          "deferred-replies" => 1
        },
        by_channel: {
          "slack://ops/review" => 1,
          "inbox://manual-completions" => 1,
          "inbox://deferred-replies" => 1
        }
      )
      expect(contract.result.manual_summary).to eq([{ kind: :manual, value: "approved" }])
      expect(contract.result.approval).to eq("approved")
    ensure
      writer_ref&.stop
      reviewer_ref&.stop
      Igniter::Registry.clear
      Igniter::Runtime.agent_adapter = previous_adapter
    end

    it "allows app-level orchestration routing overrides" do
      previous_adapter = Igniter::Runtime.agent_adapter
      Igniter::Runtime.activate_agent_adapter!
      Igniter::Registry.clear
      reviewer_ref = nil

      reviewer_class = Class.new(Igniter::Agent) do
        on :review do |payload:, **|
          raise Igniter::PendingDependencyError.new("wait", token: "review-session", source_node: :approval)
        end
      end

      reviewer_ref = reviewer_class.start(name: :reviewer)

      klass = Class.new(Igniter::Contract) do
        define do
          input :name
          agent :approval, via: :reviewer, message: :review, inputs: { name: :name }
          output :approval
        end
      end

      app = stub_const("SpecOrchestrationRoutingOverrideApp", Class.new(Igniter::App))
      app.class_eval do
        register "AgentContract", klass
        register_orchestration_routing(
          :await_deferred_reply,
          queue: "ops-review",
          channel: "pager://ops-review"
        )
      end

      app.send(:build!)
      app.reset_orchestration_inbox!
      contract = klass.new(name: "Alice")

      plan = app.orchestration_plan(contract)
      opened = app.open_orchestration_followups(contract)

      expect(plan.actions).to contain_exactly(
        include(
          action: :await_deferred_reply,
          routing: include(queue: "ops-review", channel: "pager://ops-review")
        )
      )
      expect(opened.opened).to contain_exactly(
        include(
          action: :await_deferred_reply,
          queue: "ops-review",
          channel: "pager://ops-review",
          routing: include(queue: "ops-review", channel: "pager://ops-review")
        )
      )
    ensure
      reviewer_ref&.stop
      Igniter::Registry.clear
      Igniter::Runtime.agent_adapter = previous_adapter
    end

    it "resolves queue-specific orchestration policies before action defaults" do
      previous_adapter = Igniter::Runtime.agent_adapter
      Igniter::Runtime.activate_agent_adapter!
      Igniter::Registry.clear
      writer_ref = nil

      writer_class = Class.new(Igniter::Agent) do
        on :summarize do |payload:, **|
          raise Igniter::PendingDependencyError.new("continue", token: "writer-session", source_node: :interactive_summary)
        end
      end

      writer_ref = writer_class.start(name: :writer)

      klass = Class.new(Igniter::Contract) do
        define do
          input :name

          agent :interactive_summary,
                via: :writer,
                message: :summarize,
                reply: :stream,
                inputs: { name: :name }

          output :interactive_summary
        end
      end

      app = stub_const("SpecQueueAwarePolicyApp", Class.new(Igniter::App))
      app.class_eval do
        register "AgentContract", klass
        register_orchestration_routing(
          :open_interactive_session,
          queue: "auto-interactive",
          channel: "queue://auto-interactive"
        )
        register_orchestration_policy(
          :open_interactive_session,
          Igniter::App::Orchestration::Policies::InteractiveSessionPolicy.new.with(
            name: :auto_interactive_session,
            default_operation: :complete,
            allowed_operations: %i[complete dismiss],
            description: "auto-complete lane for interactive sessions",
            default_routing: {
              queue: "auto-interactive",
              channel: "queue://auto-interactive"
            }
          ),
          queue: "auto-interactive"
        )
      end

      app.send(:build!)
      app.reset_orchestration_inbox!
      contract = klass.new(name: "Alice")

      plan = app.orchestration_plan(contract)
      opened = app.open_orchestration_followups(contract)
      handled = app.handle_orchestration_item(
        "agent_orchestration:open_interactive_session:interactive_summary",
        target: contract,
        value: "auto complete",
        note: "lane policy"
      )

      expect(plan.actions).to contain_exactly(
        include(
          action: :open_interactive_session,
          routing: include(queue: "auto-interactive", channel: "queue://auto-interactive"),
          policy: include(
            name: :auto_interactive_session,
            default_operation: :complete,
            allowed_operations: %i[complete dismiss],
            default_routing: include(queue: "auto-interactive", channel: "queue://auto-interactive")
          )
        )
      )
      expect(opened.opened).to contain_exactly(
        include(
          action: :open_interactive_session,
          queue: "auto-interactive",
          channel: "queue://auto-interactive",
          policy: include(name: :auto_interactive_session, default_operation: :complete)
        )
      )
      expect(handled).to include(
        handled_policy: :auto_interactive_session,
        handled_operation: :complete,
        handled_lifecycle_operation: :resolve,
        handled_queue: "auto-interactive",
        runtime_resumed: true,
        status: :resolved
      )
      expect(contract.result.interactive_summary).to eq("auto complete")
    ensure
      writer_ref&.stop
      Igniter::Registry.clear
      Igniter::Runtime.agent_adapter = previous_adapter
    end

    it "resolves queue-specific orchestration handlers before action defaults" do
      previous_adapter = Igniter::Runtime.agent_adapter
      Igniter::Runtime.activate_agent_adapter!
      Igniter::Registry.clear
      reviewer_ref = nil

      reviewer_class = Class.new(Igniter::Agent) do
        on :review do |payload:, **|
          raise Igniter::PendingDependencyError.new("wait", token: "review-session", source_node: :approval)
        end
      end

      reviewer_ref = reviewer_class.start(name: :reviewer)

      klass = Class.new(Igniter::Contract) do
        define do
          input :name
          agent :approval, via: :reviewer, message: :review, inputs: { name: :name }
          output :approval
        end
      end

      queue_handler = Class.new do
        def initialize
          @fallback = Igniter::App::Orchestration::Handlers::CompletionHandler.new
        end

        def call(app_class:, item:, operation: nil, target: nil, value: Igniter::Runtime::Execution::UNDEFINED_RESUME_VALUE, assignee: nil, queue: nil, channel: nil, note: nil)
          updated = @fallback.call(
            app_class: app_class,
            item: item,
            operation: operation,
            target: target,
            value: value,
            assignee: assignee,
            queue: queue,
            channel: channel,
            note: note
          )
          updated.merge(
            handled_by_queue_override: true,
            handled_queue_handler: item[:queue]
          )
        end
      end.new

      app = stub_const("SpecQueueAwareHandlerApp", Class.new(Igniter::App))
      app.class_eval do
        register "AgentContract", klass
        register_orchestration_routing(
          :await_deferred_reply,
          queue: "ops-review",
          channel: "pager://ops-review"
        )
        register_orchestration_handler(
          :await_deferred_reply,
          queue_handler,
          queue: "ops-review"
        )
      end

      app.send(:build!)
      app.reset_orchestration_inbox!
      contract = klass.new(name: "Alice")

      app.open_orchestration_followups(contract)

      handled = app.handle_orchestration_item(
        "agent_orchestration:await_deferred_reply:approval",
        target: contract,
        value: "approved",
        note: "queue override"
      )

      expect(handled).to include(
        handled_by_queue_override: true,
        handled_queue_handler: "ops-review",
        handled_policy: :deferred_reply,
        handled_operation: :reply,
        handled_lifecycle_operation: :resolve,
        handled_queue: "ops-review",
        runtime_resumed: true,
        status: :resolved
      )
      expect(contract.result.approval).to eq("approved")
    ensure
      reviewer_ref&.stop
      Igniter::Registry.clear
      Igniter::Runtime.agent_adapter = previous_adapter
    end

    it "registers orchestration lanes as bundled routing, policy, and handler semantics" do
      previous_adapter = Igniter::Runtime.agent_adapter
      Igniter::Runtime.activate_agent_adapter!
      Igniter::Registry.clear
      reviewer_ref = nil

      reviewer_class = Class.new(Igniter::Agent) do
        on :review do |payload:, **|
          raise Igniter::PendingDependencyError.new("wait", token: "review-session", source_node: :approval)
        end
      end

      reviewer_ref = reviewer_class.start(name: :reviewer)

      klass = Class.new(Igniter::Contract) do
        define do
          input :name
          agent :approval, via: :reviewer, message: :review, inputs: { name: :name }
          output :approval
        end
      end

      lane_handler = Class.new do
        def initialize
          @fallback = Igniter::App::Orchestration::Handlers::CompletionHandler.new
        end

        def call(app_class:, item:, operation: nil, target: nil, value: Igniter::Runtime::Execution::UNDEFINED_RESUME_VALUE, assignee: nil, queue: nil, channel: nil, note: nil)
          updated = @fallback.call(
            app_class: app_class,
            item: item,
            operation: operation,
            target: target,
            value: value,
            assignee: assignee,
            queue: queue,
            channel: channel,
            note: note
          )
          updated.merge(
            handled_by_lane_bundle: true
          )
        end
      end.new

      app = stub_const("SpecOrchestrationLaneBundleApp", Class.new(Igniter::App))
      app.class_eval do
        register "AgentContract", klass
        register_orchestration_lane(
          :await_deferred_reply,
          lane: :ops_review,
          queue: "ops-review",
          channel: "pager://ops-review",
          policy: Igniter::App::Orchestration::Policies::DeferredReplyPolicy.new.with(
            name: :ops_review_reply,
            description: "ops review lane"
          ),
          handler: lane_handler,
          description: "ops review lane",
          default: true
        )
      end

      app.send(:build!)
      app.reset_orchestration_inbox!
      contract = klass.new(name: "Alice")

      plan = app.orchestration_plan(contract)
      opened = app.open_orchestration_followups(contract)
      handled = app.handle_orchestration_item(
        "agent_orchestration:await_deferred_reply:approval",
        target: contract,
        value: "approved",
        note: "lane bundle"
      )

      expect(plan.actions).to contain_exactly(
        include(
          action: :await_deferred_reply,
          lane: include(name: :ops_review, queue: "ops-review", channel: "pager://ops-review"),
          policy: include(name: :ops_review_reply, default_operation: :reply),
          routing: include(queue: "ops-review", channel: "pager://ops-review")
        )
      )
      expect(opened.opened).to contain_exactly(
        include(
          action: :await_deferred_reply,
          lane: include(name: :ops_review),
          queue: "ops-review",
          channel: "pager://ops-review"
        )
      )
      expect(handled).to include(
        handled_by_lane_bundle: true,
        handled_lane: :ops_review,
        handled_policy: :ops_review_reply,
        handled_operation: :reply,
        handled_lifecycle_operation: :resolve,
        handled_queue: "ops-review",
        runtime_resumed: true,
        status: :resolved
      )
      expect(contract.result.approval).to eq("approved")
    ensure
      reviewer_ref&.stop
      Igniter::Registry.clear
      Igniter::Runtime.agent_adapter = previous_adapter
    end

    it "supports operator queries over orchestration inbox state" do
      previous_adapter = Igniter::Runtime.agent_adapter
      Igniter::Runtime.activate_agent_adapter!
      Igniter::Registry.clear
      writer_ref = nil
      reviewer_ref = nil

      writer_class = Class.new(Igniter::Agent) do
        on :summarize do |payload:, **|
          raise Igniter::PendingDependencyError.new("continue", token: "writer-session", source_node: :summary)
        end
      end

      reviewer_class = Class.new(Igniter::Agent) do
        on :review do |payload:, **|
          raise Igniter::PendingDependencyError.new("wait", token: "review-session", source_node: :approval)
        end
      end

      writer_ref = writer_class.start(name: :writer)
      reviewer_ref = reviewer_class.start(name: :reviewer)

      klass = Class.new(Igniter::Contract) do
        define do
          input :name

          agent :interactive_summary,
                via: :writer,
                message: :summarize,
                reply: :stream,
                inputs: { name: :name }

          agent :manual_summary,
                via: :writer,
                message: :summarize,
                reply: :stream,
                session_policy: :manual,
                finalizer: :events,
                inputs: { name: :name }

          agent :approval,
                via: :reviewer,
                message: :review,
                inputs: { name: :name }

          output :interactive_summary
          output :manual_summary
          output :approval
        end
      end

      app = stub_const("SpecOrchestrationInboxQueryApp", Class.new(Igniter::App))
      app.class_eval { register "AgentContract", klass }

      app.send(:build!)
      app.reset_orchestration_inbox!
      contract = klass.new(name: "Alice")

      app.open_orchestration_followups(contract)
      app.handoff_orchestration_item(
        "agent_orchestration:open_interactive_session:interactive_summary",
        assignee: "ops:alice",
        queue: "manual-review",
        channel: "slack://ops/review",
        note: "routed to reviewer",
        audit: {
          source: :orchestration_handler,
          actor: "ops:alice",
          origin: "review_lane",
          actor_channel: "slack://ops/review"
        }
      )
      app.approve_orchestration_item(
        "agent_orchestration:require_manual_completion:manual_summary",
        target: contract,
        value: [{ kind: :manual, value: "approved" }],
        note: "approved",
        audit: {
          actor: "ops:manual",
          origin: "manual_console",
          actor_channel: "/ops/manual"
        }
      )
      app.dismiss_orchestration_item(
        "agent_orchestration:await_deferred_reply:approval",
        note: "ignored",
        audit: {
          source: :orchestration_handler,
          actor: "ops:triage",
          origin: "triage_console",
          actor_channel: "/ops/triage"
        }
      )

      query = app.orchestration_query

      expect(query).to be_a(Igniter::App::Orchestration::InboxQuery)
      expect(query.count).to eq(3)
      expect(query.lane(:manual_completions).to_a).to contain_exactly(
        include(
          id: "agent_orchestration:require_manual_completion:manual_summary",
          status: :resolved
        )
      )
      expect(query.actionable.action(:open_interactive_session).assignee("ops:alice").queue("manual-review").channel("slack://ops/review").to_a).to contain_exactly(
        include(
          id: "agent_orchestration:open_interactive_session:interactive_summary",
          status: :acknowledged,
          queue: "manual-review",
          channel: "slack://ops/review"
        )
      )
      expect(query.resolved.policy(:manual_completion).to_a).to contain_exactly(
        include(
          id: "agent_orchestration:require_manual_completion:manual_summary",
          status: :resolved
        )
      )
      expect(query.dismissed.interaction(:deferred_call).to_a).to contain_exactly(
        include(
          id: "agent_orchestration:await_deferred_reply:approval",
          status: :dismissed
        )
      )
      expect(query.handed_off.channel("slack://ops/review").to_a).to contain_exactly(
        include(
          id: "agent_orchestration:open_interactive_session:interactive_summary",
          handoff_count: 1
        )
      )
      expect(query.facet(:status)).to eq(acknowledged: 1, resolved: 1, dismissed: 1)
      expect(query.facet(:lane)).to include(manual_completions: 1)
      expect(query.facet(:lane).values.sum).to eq(2)
      expect(query.facets(:queue, :assignee)).to include(
        assignee: { "ops:alice" => 1 }
      )
      expect(query.facets(:queue, :assignee)[:queue]).to include(
        "manual-review" => 1,
        "manual-completions" => 1
      )
      expect(query.facets(:queue, :assignee)[:queue].values.sum).to eq(3)
      expect(query.summary).to include(
        total: 3,
        actionable: 1,
        handed_off: 1,
        by_status: { acknowledged: 1, resolved: 1, dismissed: 1 },
        by_assignee: { "ops:alice" => 1 }
      )
      expect(query.summary[:by_lane]).to include(manual_completions: 1)
      expect(query.summary[:by_lane].values.sum).to eq(2)
      expect(app.orchestration_summary).to include(total: 3, handed_off: 1)
      expect(query.order_by(:action, direction: :asc).first[:action]).to eq(:await_deferred_reply)
      expect(query.limit(2).to_a.size).to eq(2)
      expect(query.explain).to include("InboxQuery(3 candidates)")
    ensure
      writer_ref&.stop
      reviewer_ref&.stop
      Igniter::Registry.clear
      Igniter::Runtime.agent_adapter = previous_adapter
    end

    it "supports a unified operator query over live sessions and inbox state" do
      previous_adapter = Igniter::Runtime.agent_adapter
      Igniter::Runtime.activate_agent_adapter!
      Igniter::Registry.clear
      writer_ref = nil
      reviewer_ref = nil

      writer_class = Class.new(Igniter::Agent) do
        on :summarize do |payload:, **|
          raise Igniter::PendingDependencyError.new("continue", token: "writer-session", source_node: :summary)
        end
      end

      reviewer_class = Class.new(Igniter::Agent) do
        on :review do |payload:, **|
          raise Igniter::PendingDependencyError.new("wait", token: "review-session", source_node: :approval)
        end
      end

      writer_ref = writer_class.start(name: :writer)
      reviewer_ref = reviewer_class.start(name: :reviewer)

      klass = Class.new(Igniter::Contract) do
        define do
          input :name

          agent :interactive_summary,
                via: :writer,
                message: :summarize,
                reply: :stream,
                inputs: { name: :name }

          agent :manual_summary,
                via: :writer,
                message: :summarize,
                reply: :stream,
                session_policy: :manual,
                finalizer: :events,
                inputs: { name: :name }

          agent :approval,
                via: :reviewer,
                message: :review,
                inputs: { name: :name }

          output :interactive_summary
          output :manual_summary
          output :approval
        end
      end

      app = stub_const("SpecUnifiedOperatorQueryApp", Class.new(Igniter::App))
      app.class_eval { register "AgentContract", klass }

      app.send(:build!)
      app.reset_orchestration_inbox!
      contract = klass.new(name: "Alice")

      app.open_orchestration_followups(contract)
      app.handoff_orchestration_item(
        "agent_orchestration:open_interactive_session:interactive_summary",
        assignee: "ops:alice",
        queue: "manual-review",
        channel: "slack://ops/review",
        note: "routed to reviewer",
        audit: {
          source: :orchestration_handler,
          actor: "ops:alice",
          origin: "review_lane",
          actor_channel: "slack://ops/review"
        }
      )
      app.approve_orchestration_item(
        "agent_orchestration:require_manual_completion:manual_summary",
        target: contract,
        value: [{ kind: :manual, value: "approved" }],
        note: "approved",
        audit: {
          actor: "ops:manual",
          origin: "manual_console",
          actor_channel: "/ops/manual"
        }
      )
      app.dismiss_orchestration_item(
        "agent_orchestration:await_deferred_reply:approval",
        note: "ignored",
        audit: {
          source: :orchestration_handler,
          actor: "ops:triage",
          origin: "triage_console",
          actor_channel: "/ops/triage"
        }
      )

      query = app.operator_query(contract)

      expect(query).to be_a(Igniter::App::Orchestration::OperatorQuery)
      expect(query.count).to eq(3)
      expect(query.joined.node(:interactive_summary).to_a).to contain_exactly(
        include(
          id: "agent_orchestration:open_interactive_session:interactive_summary",
          combined_state: :joined,
          status: :acknowledged,
          phase: :streaming,
          reply_mode: :stream,
          queue: "manual-review",
          channel: "slack://ops/review",
          assignee: "ops:alice",
          has_session: true,
          has_inbox_item: true
        )
      )
      expect(query.joined.node(:approval).to_a).to contain_exactly(
        include(
          id: "agent_orchestration:await_deferred_reply:approval",
          combined_state: :joined,
          status: :dismissed,
          phase: :waiting,
          reply_mode: :deferred,
          has_session: true,
          has_inbox_item: true
        )
      )
      expect(query.inbox_only.node(:manual_summary).resolved.to_a).to contain_exactly(
        include(
          id: "agent_orchestration:require_manual_completion:manual_summary",
          combined_state: :inbox_only,
          status: :resolved,
          has_session: false,
          has_inbox_item: true
        )
      )
      expect(query.with_session.phase(:streaming, :waiting).to_a.map { |entry| entry[:node] }).to contain_exactly(:interactive_summary, :approval)
      expect(query.latest_action_actor("ops:alice").to_a).to contain_exactly(
        include(node: :interactive_summary, latest_action_actor: "ops:alice")
      )
      expect(query.latest_action_origin("manual_console").to_a).to contain_exactly(
        include(node: :manual_summary, latest_action_origin: "manual_console")
      )
      expect(query.latest_action_source("orchestration_handler").to_a.map { |entry| entry[:node] }).to contain_exactly(
        :interactive_summary,
        :manual_summary,
        :approval
      )
      expect(query.facet(:combined_state)).to eq(joined: 2, inbox_only: 1)
      expect(query.facets(:lane, :phase, :latest_action_actor)).to eq(
        lane: {
          manual_completions: 1,
          ops_review: 1
        },
        phase: {
          streaming: 2,
          waiting: 1
        },
        latest_action_actor: {
          "ops:alice" => 1,
          "ops:manual" => 1,
          "ops:triage" => 1
        }
      )
      expect(query.summary).to include(
        total: 3,
        live_sessions: 2,
        inbox_items: 3,
        joined_records: 2,
        inbox_only: 1,
        session_only: 0,
        handed_off: 1,
        by_combined_state: {
          joined: 2,
          inbox_only: 1
        },
        by_latest_action_actor: {
          "ops:alice" => 1,
          "ops:manual" => 1,
          "ops:triage" => 1
        },
        by_latest_action_origin: {
          "manual_console" => 1,
          "review_lane" => 1,
          "triage_console" => 1
        },
        by_latest_action_source: {
          orchestration_handler: 3
        }
      )
      expect(query.summary[:by_phase]).to eq(streaming: 2, waiting: 1)
      expect(query.order_by(:latest_action_actor, direction: :asc).first[:node]).to eq(:interactive_summary)
      expect(app.operator_summary(contract)).to include(total: 3, joined_records: 2)
      expect(app.operator_overview(contract)).to include(
        app: "SpecUnifiedOperatorQueryApp",
        query: include(limit: 20),
        summary: include(total: 3, joined_records: 2, inbox_only: 1)
      )
      expect(app.operator_overview(contract)[:records]).to include(
        include(node: :interactive_summary, combined_state: :joined),
        include(node: :manual_summary, combined_state: :inbox_only),
        include(node: :approval, combined_state: :joined)
      )
      expect(
        app.operator_overview(
          contract,
          filters: {
            status: :acknowledged,
            queue: "manual-review",
            assignee: "ops:alice",
            latest_action_actor: "ops:alice"
          },
          order_by: :assignee,
          direction: :desc,
          limit: 5
        )
      ).to include(
        query: {
          filters: {
            status: :acknowledged,
            queue: "manual-review",
            assignee: "ops:alice",
            latest_action_actor: "ops:alice"
          },
          order_by: :assignee,
          direction: :desc,
          limit: 5
        },
        summary: include(total: 1, joined_records: 1)
      )
      expect(
        app.operator_overview(
          contract,
          filters: {
            status: :acknowledged,
            queue: "manual-review",
            assignee: "ops:alice",
            latest_action_actor: "ops:alice"
          }
        )[:records]
      ).to contain_exactly(
        include(
          node: :interactive_summary,
          assignee: "ops:alice",
          queue: "manual-review",
          latest_action_actor: "ops:alice"
        )
      )
      expect(query.order_by(:phase, direction: :asc).first[:node]).to eq(:interactive_summary)
      expect(query.limit(2).to_a.size).to eq(2)
      expect(query.explain).to include("OperatorQuery(3 candidates)")
    ensure
      writer_ref&.stop
      reviewer_ref&.stop
      Igniter::Registry.clear
      Igniter::Runtime.agent_adapter = previous_adapter
    end

    it "restores operator overviews for stored executions and exposes a reusable overview handler" do
      previous_store = Igniter.execution_store
      Igniter.execution_store = Igniter::Runtime::Stores::MemoryStore.new

      agent_adapter = Class.new do
        def call(node:, **)
          raise Igniter::PendingDependencyError.new("wait", token: "review-session", source_node: node.name)
        end

        def cast(**)
          raise "unexpected cast"
        end
      end.new

      klass = Class.new(Igniter::Contract) do
        run_with runner: :store, agent_adapter: agent_adapter

        define do
          input :name

          agent :approval,
                via: :reviewer,
                message: :review,
                inputs: { name: :name }

          output :approval
        end
      end

      app = stub_const("SpecOperatorOverviewHandlerApp", Class.new(Igniter::App))
      app.class_eval do
        register "AgentContract", klass

        configure do |c|
          c.store = Igniter.execution_store
        end

        route "GET",
              "/api/operator",
              with: Igniter::App::Observability::OperatorOverviewHandler.new(app_class: self)
      end

      config = app.send(:build!)
      app.reset_orchestration_inbox!

      contract = klass.new(name: "Alice")
      execution_id = contract.execution.events.execution_id

      app.open_orchestration_followups(contract)

      overview = app.operator_overview_for_execution(
        graph: "AnonymousContract",
        execution_id: execution_id
      )

      expect(overview).to include(
        app: "SpecOperatorOverviewHandlerApp",
        scope: {
          mode: :execution,
          graph: "AnonymousContract",
          execution_id: execution_id
        },
        summary: include(
          total: 1,
          live_sessions: 1,
          inbox_items: 1,
          joined_records: 1
        )
      )
      expect(overview[:records]).to contain_exactly(
        include(
          id: "agent_orchestration:await_deferred_reply:approval",
          node: :approval,
          combined_state: :joined,
          status: :open,
          phase: :waiting,
          reply_mode: :deferred
        )
      )

      router = Igniter::Server::Router.new(config)
      response = router.call(
        "GET",
        "/api/operator?graph=AnonymousContract&execution_id=#{execution_id}&limit=1",
        ""
      )

      expect(response[:status]).to eq(200)
      expect(response[:headers]["Content-Type"]).to include("application/json")
      expect(JSON.parse(response[:body])).to include(
        "app" => "SpecOperatorOverviewHandlerApp",
        "scope" => {
          "mode" => "execution",
          "graph" => "AnonymousContract",
          "execution_id" => execution_id
        },
        "query" => include(
          "limit" => 1
        ),
        "summary" => include(
          "total" => 1,
          "live_sessions" => 1,
          "inbox_items" => 1,
          "joined_records" => 1
        )
      )

      app_wide_response = router.call("GET", "/api/operator?limit=5", "")
      expect(app_wide_response[:status]).to eq(200)
      expect(JSON.parse(app_wide_response[:body])).to include(
        "app" => "SpecOperatorOverviewHandlerApp",
        "scope" => { "mode" => "app" }
      )

      bad_request = router.call("GET", "/api/operator?graph=AnonymousContract", "")
      expect(bad_request[:status]).to eq(400)
      expect(JSON.parse(bad_request[:body])).to include(
        "error" => "graph and execution_id must be provided together"
      )
    ensure
      Igniter.execution_store = previous_store
    end

    it "supports operator api filters and ordering through query params" do
      previous_adapter = Igniter::Runtime.agent_adapter
      Igniter::Runtime.activate_agent_adapter!
      Igniter::Registry.clear
      writer_ref = nil
      reviewer_ref = nil

      writer_class = Class.new(Igniter::Agent) do
        on :summarize do |payload:, **|
          raise Igniter::PendingDependencyError.new("continue", token: "writer-session", source_node: payload[:node] || :interactive_summary)
        end
      end

      reviewer_class = Class.new(Igniter::Agent) do
        on :review do |payload:, **|
          raise Igniter::PendingDependencyError.new("continue", token: "review-session", source_node: :approval)
        end
      end

      writer_ref = writer_class.start(name: :writer)
      reviewer_ref = reviewer_class.start(name: :reviewer)

      klass = Class.new(Igniter::Contract) do
        define do
          input :name

          agent :interactive_summary,
                via: :writer,
                message: :summarize,
                reply: :stream,
                inputs: { name: :name }

          agent :approval,
                via: :reviewer,
                message: :review,
                inputs: { name: :name }

          output :interactive_summary
          output :approval
        end
      end

      app = stub_const("SpecFilteredOperatorOverviewApp", Class.new(Igniter::App))
      app.class_eval do
        register "AgentContract", klass
        mount_operator_surface(path: "/operator", api_path: "/api/operator", title: "Operations Console")
      end

      config = app.send(:build!)
      app.reset_orchestration_inbox!

      contract = klass.new(name: "Alice")
      app.open_orchestration_followups(contract)
      app.handoff_orchestration_item(
        "agent_orchestration:open_interactive_session:interactive_summary",
        assignee: "ops:alice",
        queue: "manual-review",
        channel: "slack://ops/review",
        note: "routed to reviewer",
        audit: {
          source: :orchestration_handler,
          actor: "ops:alice",
          origin: "review_lane",
          actor_channel: "slack://ops/review"
        }
      )
      app.dismiss_orchestration_item(
        "agent_orchestration:await_deferred_reply:approval",
        note: "ignored",
        audit: {
          source: :orchestration_handler,
          actor: "ops:triage",
          origin: "triage_console",
          actor_channel: "/ops/triage"
        }
      )

      router = Igniter::Server::Router.new(config)
      api = router.call(
        "GET",
        "/api/operator?status=acknowledged&queue=manual-review&assignee=ops:alice&latest_action_actor=ops:alice&latest_action_origin=review_lane&latest_action_source=orchestration_handler&order_by=latest_action_actor&direction=desc",
        ""
      )

      expect(api[:status]).to eq(200)
      expect(JSON.parse(api[:body])).to include(
        "app" => "SpecFilteredOperatorOverviewApp",
        "scope" => { "mode" => "app" },
        "query" => {
          "filters" => {
            "status" => ["acknowledged"],
            "queue" => ["manual-review"],
            "assignee" => ["ops:alice"],
            "latest_action_actor" => ["ops:alice"],
            "latest_action_origin" => ["review_lane"],
            "latest_action_source" => ["orchestration_handler"]
          },
          "order_by" => "latest_action_actor",
          "direction" => "desc",
          "limit" => 20
        },
        "summary" => include(
          "total" => 1,
          "by_status" => { "acknowledged" => 1 },
          "by_latest_action_actor" => { "ops:alice" => 1 },
          "by_latest_action_origin" => { "review_lane" => 1 },
          "by_latest_action_source" => { "orchestration_handler" => 1 }
        ),
        "records" => [
          include(
            "node" => "interactive_summary",
            "status" => "acknowledged",
            "queue" => "manual-review",
            "assignee" => "ops:alice",
            "latest_action_actor" => "ops:alice",
            "latest_action_origin" => "review_lane",
            "latest_action_source" => "orchestration_handler"
          )
        ]
      )

      page = router.call(
        "GET",
        "/operator?graph=AnonymousContract&execution_id=#{contract.execution.events.execution_id}&status=acknowledged&queue=manual-review&assignee=ops:alice&latest_action_actor=ops:alice&latest_action_origin=review_lane&latest_action_source=orchestration_handler&node=interactive_summary",
        ""
      )

      expect(page[:status]).to eq(200)
      expect(page[:body]).to include('name="status"')
      expect(page[:body]).to include('value="acknowledged"')
      expect(page[:body]).to include('name="queue"')
      expect(page[:body]).to include('value="manual-review"')
      expect(page[:body]).to include('name="assignee"')
      expect(page[:body]).to include('value="ops:alice"')
      expect(page[:body]).to include('name="latest_action_actor"')
      expect(page[:body]).to include('value="ops:alice"')
      expect(page[:body]).to include('name="latest_action_origin"')
      expect(page[:body]).to include('value="review_lane"')
      expect(page[:body]).to include('name="latest_action_source"')
      expect(page[:body]).to include('value="orchestration_handler"')
      expect(page[:body]).to include('name="action_actor"')
      expect(page[:body]).to include('value="operator-console"')
      expect(page[:body]).to include("Open JSON API")
      expect(page[:body]).to include("Inspect")
    ensure
      writer_ref&.stop
      reviewer_ref&.stop
      Igniter::Registry.clear
      Igniter::Runtime.agent_adapter = previous_adapter
    end

    it "mounts the operator overview endpoint through a declarative observability pack" do
      previous_store = Igniter.execution_store
      Igniter.execution_store = Igniter::Runtime::Stores::MemoryStore.new

      agent_adapter = Class.new do
        def call(node:, **)
          raise Igniter::PendingDependencyError.new("wait", token: "review-session", source_node: node.name)
        end

        def cast(**)
          raise "unexpected cast"
        end
      end.new

      klass = Class.new(Igniter::Contract) do
        run_with runner: :store, agent_adapter: agent_adapter

        define do
          input :name

          agent :approval,
                via: :reviewer,
                message: :review,
                inputs: { name: :name }

          output :approval
        end
      end

      app = stub_const("SpecMountedOperatorOverviewApp", Class.new(Igniter::App))
      app.class_eval do
        register "AgentContract", klass

        configure do |c|
          c.store = Igniter.execution_store
        end

        mount_operator_overview(path: "/api/operator", limit: 3)
      end

      config = app.send(:build!)
      app.reset_orchestration_inbox!

      contract = klass.new(name: "Alice")
      execution_id = contract.execution.events.execution_id
      app.open_orchestration_followups(contract)

      mounted_route = config.custom_routes.find { |route| route[:method] == "GET" && route[:path] == "/api/operator" }
      expect(mounted_route).not_to be_nil
      expect(mounted_route[:handler]).to be_a(Igniter::App::Observability::OperatorOverviewHandler)

      router = Igniter::Server::Router.new(config)
      response = router.call(
        "GET",
        "/api/operator?graph=AnonymousContract&execution_id=#{execution_id}",
        ""
      )

      expect(response[:status]).to eq(200)
      expect(JSON.parse(response[:body])).to include(
        "app" => "SpecMountedOperatorOverviewApp",
        "scope" => {
          "mode" => "execution",
          "graph" => "AnonymousContract",
          "execution_id" => execution_id
        },
        "summary" => include(
          "total" => 1,
          "joined_records" => 1
        )
      )

      app.class_eval do
        mount_operator_observability(path: "/ops/operator", limit: 2)
      end

      remounted_config = app.send(:build!)
      remounted_paths = remounted_config.custom_routes.select { |route| route[:handler].is_a?(Igniter::App::Observability::OperatorOverviewHandler) }
                                              .map { |route| route[:path] }
      expect(remounted_paths).to contain_exactly("/api/operator", "/ops/operator")
    ensure
      Igniter.execution_store = previous_store
    end

    it "mounts an operator console surface with paired html and api routes" do
      previous_store = Igniter.execution_store
      Igniter.execution_store = Igniter::Runtime::Stores::MemoryStore.new

      app = stub_const("SpecMountedOperatorConsoleApp", Class.new(Igniter::App))
      app.class_eval do
        configure do |c|
          c.store = Igniter.execution_store
        end

        mount_operator_surface(path: "/operator", api_path: "/api/operator", title: "Operations Console")
      end

      config = app.send(:build!)
      routes = config.custom_routes.select { |route| route[:method] == "GET" }
      action_route = config.custom_routes.find { |route| route[:method] == "POST" && route[:path] == "/api/operator/actions" }

      expect(routes.map { |route| route[:path] }).to include("/operator", "/api/operator")
      expect(routes.find { |route| route[:path] == "/operator" }[:handler]).to be_a(Igniter::App::Observability::OperatorConsoleHandler)
      expect(routes.find { |route| route[:path] == "/api/operator" }[:handler]).to be_a(Igniter::App::Observability::OperatorOverviewHandler)
      expect(action_route).not_to be_nil
      expect(action_route[:handler]).to be_a(Igniter::App::Observability::OperatorActionHandler)

      router = Igniter::Server::Router.new(config)

      page = router.call("GET", "/operator", "")
      expect(page[:status]).to eq(200)
      expect(page[:headers]["Content-Type"]).to include("text/html")
      expect(page[:body]).to include("Operations Console")
      expect(page[:body]).to include("/api/operator")
      expect(page[:body]).to include("/api/operator/actions")
      expect(page[:body]).to include("Load Overview")

      api = router.call("GET", "/api/operator", "")
      expect(api[:status]).to eq(200)
      expect(JSON.parse(api[:body])).to include(
        "app" => "SpecMountedOperatorConsoleApp",
        "scope" => { "mode" => "app" }
      )
    ensure
      Igniter.execution_store = previous_store
    end

    it "handles operator actions through a mounted observability action endpoint" do
      previous_store = Igniter.execution_store
      Igniter.execution_store = Igniter::Runtime::Stores::MemoryStore.new

      writer_trace = {
        adapter: :queue,
        mode: :call,
        via: :writer,
        message: :summarize,
        outcome: :streaming
      }

      reviewer_trace = {
        adapter: :queue,
        mode: :call,
        via: :reviewer,
        message: :review,
        outcome: :deferred
      }

      agent_adapter = Class.new do
        define_method(:call) do |node:, **|
          trace = node.name == :interactive_summary ? writer_trace : reviewer_trace
          {
            status: :pending,
            payload: { queue: :review },
            agent_trace: trace,
            session: {
              node_name: node.name,
              node_path: node.path,
              agent_name: node.agent_name,
              message_name: node.message_name,
              mode: node.mode,
              waiting_on: node.name,
              source_node: node.name,
              reply_mode: node.reply_mode,
              trace: trace
            }
          }
        end

        define_method(:cast) do |**|
          raise "unexpected cast"
        end
      end.new

      klass = Class.new(Igniter::Contract) do
        run_with runner: :store, agent_adapter: agent_adapter

        define do
          input :name

          agent :interactive_summary,
                via: :writer,
                message: :summarize,
                reply: :stream,
                inputs: { name: :name }

          agent :approval,
                via: :reviewer,
                message: :review,
                inputs: { name: :name }

          output :interactive_summary
          output :approval
        end
      end

      app = stub_const("SpecOperatorActionHandlerApp", Class.new(Igniter::App))
      app.class_eval do
        register "AgentContract", klass

        configure do |c|
          c.store = Igniter.execution_store
        end

        register_orchestration_routing(
          :open_interactive_session,
          queue: "spec-operator-interactive",
          channel: "inbox://spec-operator-interactive"
        )
        register_orchestration_routing(
          :await_deferred_reply,
          queue: "spec-operator-deferred",
          channel: "inbox://spec-operator-deferred"
        )

        mount_operator_surface(path: "/operator", api_path: "/api/operator", action_path: "/api/operator/actions", title: "Operations Console")
      end

      config = app.send(:build!)
      app.reset_orchestration_inbox!
      contract = klass.new(name: "Alice")
      execution_id = contract.execution.events.execution_id
      app.open_orchestration_followups(contract)

      router = Igniter::Server::Router.new(config)

      handoff = router.call(
        "POST",
        "/api/operator/actions",
        JSON.generate(
          id: "agent_orchestration:open_interactive_session:interactive_summary",
          operation: :handoff,
          actor: "alex",
          origin: "dashboard_ui",
          actor_channel: "/operator",
          assignee: "ops:alice",
          queue: "manual-review",
          channel: "slack://ops/review",
          note: "routed from console"
        ),
        headers: { "Content-Type" => "application/json" }
      )

      expect(handoff[:status]).to eq(200)
      expect(JSON.parse(handoff[:body])).to include(
        "app" => "SpecOperatorActionHandlerApp",
        "scope" => {
          "mode" => "execution",
          "graph" => "AnonymousContract",
          "execution_id" => execution_id
        },
        "action" => include(
          "id" => "agent_orchestration:open_interactive_session:interactive_summary",
          "handled_operation" => "handoff",
          "handled_lifecycle_operation" => "acknowledge",
          "handled_audit_source" => "operator_action_api",
          "handled_assignee" => "ops:alice",
          "handled_queue" => "manual-review",
          "handled_channel" => "slack://ops/review",
          "status" => "acknowledged",
          "action_history" => include(
            include("event" => "opened", "status" => "open"),
            include(
              "event" => "handoff",
              "status" => "acknowledged",
              "source" => "operator_action_api",
              "actor" => "alex",
              "origin" => "dashboard_ui",
              "actor_channel" => "/operator",
              "requested_operation" => "handoff",
              "lifecycle_operation" => "acknowledge"
            )
          )
        ),
        "record" => include(
          "id" => "agent_orchestration:open_interactive_session:interactive_summary",
          "status" => "acknowledged",
          "assignee" => "ops:alice",
          "queue" => "manual-review",
          "channel" => "slack://ops/review",
          "action_history_count" => 2,
          "latest_action_actor" => "alex",
          "latest_action_origin" => "dashboard_ui",
          "latest_action_source" => "operator_action_api",
          "latest_action_event" => include(
            "event" => "handoff",
            "source" => "operator_action_api",
            "actor" => "alex",
            "origin" => "dashboard_ui"
          )
        )
      )

      reply = router.call(
        "POST",
        "/api/operator/actions",
        JSON.generate(
          id: "agent_orchestration:await_deferred_reply:approval",
          operation: :reply,
          actor: "alex",
          origin: "dashboard_ui",
          actor_channel: "/operator",
          value: "approved",
          note: "completed from console"
        ),
        headers: { "Content-Type" => "application/json" }
      )

      expect(reply[:status]).to eq(200)
      expect(JSON.parse(reply[:body])).to include(
        "app" => "SpecOperatorActionHandlerApp",
        "scope" => {
          "mode" => "execution",
          "graph" => "AnonymousContract",
          "execution_id" => execution_id
        },
        "action" => include(
          "id" => "agent_orchestration:await_deferred_reply:approval",
          "handled_operation" => "reply",
          "handled_lifecycle_operation" => "resolve",
          "handled_audit_source" => "operator_action_api",
          "runtime_resumed" => true,
          "status" => "resolved",
          "resolved_execution_id" => execution_id,
          "action_history" => include(
            include(
              "event" => "resolved",
              "status" => "resolved",
              "source" => "operator_action_api",
              "actor" => "alex",
              "origin" => "dashboard_ui",
              "actor_channel" => "/operator",
              "requested_operation" => "reply",
              "lifecycle_operation" => "resolve"
            )
          )
        ),
        "record" => include(
          "id" => "agent_orchestration:await_deferred_reply:approval",
          "status" => "resolved",
          "combined_state" => "inbox_only",
          "latest_action_actor" => "alex",
          "latest_action_origin" => "dashboard_ui",
          "latest_action_source" => "operator_action_api",
          "latest_action_event" => include(
            "event" => "resolved",
            "source" => "operator_action_api",
            "actor" => "alex",
            "origin" => "dashboard_ui"
          )
        )
      )
    ensure
      Igniter.execution_store = previous_store
    end

    it "rejects orchestration operations that violate the action policy" do
      previous_adapter = Igniter::Runtime.agent_adapter
      Igniter::Runtime.activate_agent_adapter!
      Igniter::Registry.clear
      writer_ref = nil

      writer_class = Class.new(Igniter::Agent) do
        on :summarize do |payload:, **|
          raise Igniter::PendingDependencyError.new("continue", token: "writer-session", source_node: :summary)
        end
      end

      writer_ref = writer_class.start(name: :writer)

      klass = Class.new(Igniter::Contract) do
        define do
          input :name

          agent :single_turn_summary,
                via: :writer,
                message: :summarize,
                reply: :stream,
                session_policy: :single_turn,
                inputs: { name: :name }

          output :single_turn_summary
        end
      end

      app = stub_const("SpecOrchestrationPolicyApp", Class.new(Igniter::App))
      app.class_eval { register "AgentContract", klass }

      app.send(:build!)
      app.reset_orchestration_inbox!
      contract = klass.new(name: "Alice")

      action = app.orchestration_plan(contract).actions.find { |entry| entry[:action] == :await_single_turn_completion }
      app.orchestration_inbox.open(action, source: :agent_orchestration, graph: "AnonymousContract")

      expect {
        app.handle_orchestration_item(
          "agent_orchestration:await_single_turn_completion:single_turn_summary",
          operation: :wake
        )
      }.to raise_error(
        ArgumentError,
        /operation :wake is not allowed for orchestration item "agent_orchestration:await_single_turn_completion:single_turn_summary"/
      )
    ensure
      writer_ref&.stop
      Igniter::Registry.clear
      Igniter::Runtime.agent_adapter = previous_adapter
    end
  end

  describe "hosting" do
    let(:host_config_class) do
      Struct.new(:logger, :registered) do
        def initialize(...)
          super
          self.registered ||= {}
        end

        def register(name, klass)
          registered[name] = klass
        end
      end
    end

    it "uses the server host adapter by default" do
      app = fresh_app

      expect(app.host).to eq(:app)
      expect(app.host_adapter).to be_a(Igniter::App::AppHost)
      expect(app.scheduler).to eq(:threaded)
    end

    it "builds the cluster host adapter declaratively" do
      app = fresh_app { host :cluster_app }

      expect(app.host).to eq(:cluster_app)
      expect(app.host_adapter).to be_a(Igniter::App::ClusterAppHost)
    end

    it "raises a helpful error for an unknown host" do
      app = fresh_app { host :edge }

      expect { app.host_adapter }.to raise_error(ArgumentError) do |error|
        expect(error.message).to include("unknown app host :edge")
        expect(error.message).to include("app")
        expect(error.message).to include("cluster_app")
      end
    end

    it "raises a helpful error for an unknown scheduler" do
      app = fresh_app { scheduler :edge }

      expect { app.scheduler_adapter }.to raise_error(ArgumentError) do |error|
        expect(error.message).to include("unknown app scheduler :edge")
        expect(error.message).to include("threaded")
      end
    end

    it "raises a helpful error for an unknown loader" do
      app = fresh_app { loader :edge }

      expect { app.loader_adapter }.to raise_error(ArgumentError) do |error|
        expect(error.message).to include("unknown app loader :edge")
        expect(error.message).to include("filesystem")
      end
    end

    it "lets the default server host provide server-specific defaults" do
      app = fresh_app

      built = app.send(:build!)

      expect(built).to be_a(Igniter::Server::Config)
      expect(built.store).not_to be_nil
    end

    it "builds host config through the configured host adapter" do
      built_from = nil
      fake_config = host_config_class.new(nil, {})
      fake_host = Object.new

      fake_host.define_singleton_method(:build_config) do |host_config|
        built_from = host_config
        fake_config
      end

      app = fresh_app do
        host :cluster_app
        configure { |c| c.app_host.port = 7777 }
        host_adapter fake_host
      end

      built = app.send(:build!)

      expect(built).to be(fake_config)
      expect(app.host).to eq(:cluster_app)
      expect(built_from).to be_a(Igniter::App::HostConfig)
      expect(built_from.host_settings_for(:app)).to include(port: 7777)
    end

    it "delegates start to the configured host adapter" do
      events = []
      klass = sample_contract_class
      fake_config = host_config_class.new(nil, {})
      fake_host = Object.new
      fake_scheduler = Object.new

      fake_host.define_singleton_method(:build_config) do |host_config|
        events << [:build_config, host_config]
        fake_config
      end
      fake_host.define_singleton_method(:activate_transport!) { events << :activate_transport }
      fake_host.define_singleton_method(:start) do |config:|
        events << [:start, config]
        :started
      end
      fake_scheduler.define_singleton_method(:start) do |config:, jobs:|
        events << [:scheduler_start, config, jobs.map { |job| job[:name] }]
      end
      fake_scheduler.define_singleton_method(:stop) { events << :scheduler_stop }

      app = fresh_app do
        register "SampleContract", klass
        schedule :tick, every: "1h" do
          :ok
        end
        host_adapter fake_host
        loader_adapter Object.new.tap { |loader| loader.define_singleton_method(:load!) { |**| } }
        scheduler_adapter fake_scheduler
      end

      expect(app.start).to eq(:started)
      expect(events[0]).to eq(:activate_transport)
      expect(events[1].first).to eq(:build_config)
      expect(events[1].last).to be_a(Igniter::App::HostConfig)
      expect(events[1].last.registrations["SampleContract"]).to be(klass)
      expect(events[2..]).to eq([
        [:scheduler_start, fake_config, [:tick]],
        [:start, fake_config]
      ])
    end

    it "delegates rack_app to the configured host adapter" do
      events = []
      klass = sample_contract_class
      fake_config = host_config_class.new(nil, {})
      fake_host = Object.new
      fake_scheduler = Object.new

      fake_host.define_singleton_method(:build_config) do |host_config|
        events << [:build_config, host_config]
        fake_config
      end
      fake_host.define_singleton_method(:activate_transport!) { events << :activate_transport }
      fake_host.define_singleton_method(:rack_app) do |config:|
        events << [:rack_app, config]
        :rack_app
      end
      fake_scheduler.define_singleton_method(:start) do |config:, jobs:|
        events << [:scheduler_start, config, jobs.map { |job| job[:name] }]
      end

      app = fresh_app do
        register "SampleContract", klass
        schedule :tick, every: "1h" do
          :ok
        end
        host_adapter fake_host
        loader_adapter Object.new.tap { |loader| loader.define_singleton_method(:load!) { |**| } }
        scheduler_adapter fake_scheduler
      end

      expect(app.rack_app).to eq(:rack_app)
      expect(events[0]).to eq(:activate_transport)
      expect(events[1].first).to eq(:build_config)
      expect(events[1].last).to be_a(Igniter::App::HostConfig)
      expect(events[1].last.registrations["SampleContract"]).to be(klass)
      expect(events[2..]).to eq([
        [:scheduler_start, fake_config, [:tick]],
        [:rack_app, fake_config]
      ])
    end
  end
end

RSpec.describe Igniter::Stack do
  let(:leaf_app) { Class.new(Igniter::App) }

  def fresh_stack(&block)
    stack = Class.new(Igniter::Stack)
    stack.class_eval(&block) if block
    stack
  end

  describe "class-level DSL isolation" do
    it "does not leak apps between subclasses" do
      app_class = leaf_app
      stack1 = fresh_stack { app :main, path: "apps/main", klass: app_class }
      stack2 = fresh_stack

      expect(stack1.app_names).to eq([:main])
      expect(stack2.app_names).to eq([])
    end
  end

  describe "app registry" do
    it "returns the default app class" do
      app_class = leaf_app
      stack = fresh_stack do
        app :main, path: "apps/main", klass: app_class
      end

      expect(stack.app).to be(app_class)
      expect(stack.root_app).to eq(:main)
    end

    it "starts a named app" do
      started = []
      app_class = Class.new(Igniter::App) do
        define_singleton_method(:start) { started << :main }
      end

      stack = fresh_stack do
        app :main, path: "apps/main", klass: app_class
      end

      stack.start(:main)
      expect(started).to eq([:main])
    end

    it "adds shared lib paths relative to root_dir" do
      Dir.mktmpdir do |tmp|
        app_class = leaf_app
        stack = fresh_stack do
          root_dir tmp
          shared_lib_path "lib"
          app :main, path: "apps/main", klass: app_class
        end

        shared_lib = File.join(tmp, "lib")
        FileUtils.mkdir_p(shared_lib)
        $LOAD_PATH.delete(shared_lib)

        stack.setup_load_paths!
        expect($LOAD_PATH).to include(shared_lib)
      ensure
        $LOAD_PATH.delete(shared_lib)
      end
    end

    it "raises on unknown app" do
      app_class = leaf_app
      stack = fresh_stack do
        app :main, path: "apps/main", klass: app_class
      end

      expect { stack.app(:inference) }.to raise_error(ArgumentError, /Unknown stack app/)
    end
  end
end
