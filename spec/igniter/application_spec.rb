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
          expect(File.exist?("my_app/application.rb")).to be true
          expect(File.exist?("my_app/application.yml")).to be true
          expect(File.exist?("my_app/Gemfile")).to be true
          expect(File.exist?("my_app/config.ru")).to be true

          # bin/
          expect(File.exist?("my_app/bin/start")).to be true
          expect(File.exist?("my_app/bin/demo")).to be true

          # lib/
          expect(File.exist?("my_app/lib/.keep")).to be true

          # app/ example source files
          expect(File.exist?("my_app/app/executors/greeter.rb")).to be true
          expect(File.exist?("my_app/app/contracts/greet_contract.rb")).to be true
          expect(File.exist?("my_app/app/tools/greet_tool.rb")).to be true
          expect(File.exist?("my_app/app/agents/host_agent.rb")).to be true
          expect(File.exist?("my_app/app/skills/concierge_skill.rb")).to be true
        end
      end
    end

    it "generated application.rb uses app/ paths and on_boot" do
      Dir.mktmpdir do |tmp|
        Dir.chdir(tmp) do
          described_class.new("my_app").generate
          content = File.read("my_app/application.rb")
          expect(content).to include("executors_path")
          expect(content).to include("contracts_path")
          expect(content).to include("tools_path")
          expect(content).to include("agents_path")
          expect(content).to include("skills_path")
          expect(content).to include("on_boot")
        end
      end
    end

    it "generated example files reference correct Igniter base classes" do
      Dir.mktmpdir do |tmp|
        Dir.chdir(tmp) do
          described_class.new("my_app").generate
          expect(File.read("my_app/app/executors/greeter.rb")).to include("Igniter::Executor")
          expect(File.read("my_app/app/contracts/greet_contract.rb")).to include("Igniter::Contract")
          expect(File.read("my_app/app/tools/greet_tool.rb")).to include("Igniter::Tool")
          expect(File.read("my_app/app/agents/host_agent.rb")).to include("Igniter::Agent")
        end
      end
    end

    it "uses CamelCase module name derived from app name" do
      Dir.mktmpdir do |tmp|
        Dir.chdir(tmp) do
          described_class.new("my_cool_app").generate
          content = File.read("my_cool_app/application.rb")
          expect(content).to include("MyCoolApp")
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
  end
end
