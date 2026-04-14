# frozen_string_literal: true

require_relative "sdk"
require_relative "server"
require_relative "application/app_config"
require_relative "application/yml_loader"
require_relative "application/autoloader"
require_relative "application/scheduler"
require_relative "application/workspace"
require_relative "application/generator"

module Igniter
  # Base class for Igniter applications.
  #
  # Provides a unified DSL for configuration, contract registration,
  # scheduled jobs, and server startup — replacing the raw
  # Igniter::Server.configure boilerplate.
  #
  # == Minimal example
  #
  #   require "igniter/application"
  #
  #   class MyApp < Igniter::Application
  #     config_file "application.yml"        # optional YAML base config
  #
  #     configure do |c|
  #       c.port  = 4567
  #       c.store = Igniter::Runtime::Stores::MemoryStore.new
  #     end
  #
  #     register "OrderContract", OrderContract
  #
  #     schedule :cleanup, every: "1h" do
  #       puts "running cleanup..."
  #     end
  #   end
  #
  #   MyApp.start       # blocking built-in HTTP server
  #   MyApp.rack_app    # Rack-compatible app (Puma / Unicorn)
  #
  # == YAML config (application.yml)
  #
  #   server:
  #     port: 4567
  #     host: "0.0.0.0"
  #     log_format: json    # text (default) or json
  #     drain_timeout: 30
  #
  # Values from the YAML file are applied first; the Ruby `configure` block
  # runs afterwards and always wins.
  class Application
    class << self
      # ─── DSL ─────────────────────────────────────────────────────────────────

      def use(*names)
        resolved_names = names.flatten.map(&:to_sym)
        Igniter::SDK.activate!(*resolved_names, layer: :application)
        @sdk_capabilities |= resolved_names
        self
      end

      def sdk_capabilities
        @sdk_capabilities ||= []
      end

      # Root directory for this application.
      # Relative config and autoload paths are resolved from here.
      def root_dir(path = nil)
        return @root_dir unless path

        @root_dir = File.expand_path(path)
      end

      # Path to an optional YAML configuration file.
      # Loaded before the configure block — configure values override YAML.
      def config_file(path)
        @yml_path = path
      end

      # Configure the application. Block receives an AppConfig instance.
      # May be called multiple times; blocks are applied in order.
      def configure(&block)
        @configure_blocks << block
      end

      # Declare a directory whose .rb files are eagerly required at startup
      # (before contracts are registered).
      def executors_path(path)
        @executors_paths << path
      end

      # Declare a directory whose .rb files are eagerly required at startup.
      def contracts_path(path)
        @contracts_paths << path
      end

      # Declare a directory whose .rb files are eagerly required at startup
      # (agents, supervisors, and other actor-system components).
      def agents_path(path)
        @agents_paths << path
      end

      # Declare a directory whose .rb files are eagerly required at startup
      # (Tool subclasses — LLM-callable function wrappers).
      def tools_path(path)
        @tools_paths << path
      end

      # Declare a directory whose .rb files are eagerly required at startup
      # (Skill subclasses — LLM reasoning loops with their own tool sets).
      def skills_path(path)
        @skills_paths << path
      end

      # Register a custom HTTP route handled by this application.
      #
      #   route "POST", "/telegram/webhook", with: TelegramWebhook
      #   route "GET", %r{\A/internal/ping\z} do |params:, body:, headers:, env:, raw_body:, config:|
      #     { ok: true }
      #   end
      def route(method, path, with: nil, &block)
        raise ArgumentError, "route requires a callable `with:` or a block" unless with || block
        raise ArgumentError, "route cannot use both `with:` and a block" if with && block

        handler = with || block
        @custom_routes << {
          method: method.to_s.upcase,
          path: path,
          handler: handler
        }
      end

      # Register a hook to run before every custom application route.
      # Hook receives a mutable request hash:
      #
      #   before_request do |request:|
      #     request[:headers]["X-Trace"] ||= "demo"
      #   end
      def before_request(with: nil, &block)
        @before_request_hooks << normalize_request_hook!(with, block, :before_request)
      end

      # Register a hook to run after every custom application route.
      # Hook receives the request hash and the normalized response hash.
      def after_request(with: nil, &block)
        @after_request_hooks << normalize_request_hook!(with, block, :after_request)
      end

      # Register a hook to wrap custom application route handling.
      # Hook receives the request hash and a block that continues the pipeline.
      def around_request(with: nil, &block)
        @around_request_hooks << normalize_request_hook!(with, block, :around_request)
      end

      # Register a contract class under a name for HTTP dispatch.
      def register(name, contract_class)
        @registered[name.to_s] = contract_class
      end

      # Register a block to run after all paths are autoloaded but before the
      # server starts. Use this for registrations that reference autoloaded
      # constants, e.g.:
      #
      #   on_boot { register "MyContract", MyContract }
      #
      def on_boot(&block)
        @boot_blocks << block
      end

      # Define a recurring background job.
      #
      #   schedule :report, every: "1d", at: "09:00" do
      #     DailyReportContract.new.resolve_all(...)
      #   end
      #
      # Interval formats: Integer (seconds), "30s", "5m", "2h", "1d",
      # or Hash { hours: 1, minutes: 30 }.
      def schedule(name, every:, at: nil, &block)
        @scheduled_jobs << { name: name, every: every, at: at, block: block }
      end

      # ─── Lifecycle ───────────────────────────────────────────────────────────

      # Start the built-in HTTP server (blocking).
      # Schedules background jobs and registers an at_exit cleanup.
      def start
        Igniter::Server.activate_remote_adapter!
        sc    = build!
        sched = build_scheduler(sc)
        sched&.start
        at_exit { sched&.stop }
        Igniter::Server::HttpServer.new(sc).start
      end

      # Return a Rack-compatible application (for Puma / Unicorn / etc.).
      def rack_app
        Igniter::Server.activate_remote_adapter!
        sc = build!
        build_scheduler(sc)&.start
        Igniter::Server::RackApp.new(sc)
      end

      # Expose the AppConfig (populated after the first build!).
      def config = @app_config

      # ─── Inheritance isolation ────────────────────────────────────────────────

      def inherited(subclass)
        super
        subclass.instance_variable_set(:@root_dir,         Dir.pwd)
        subclass.instance_variable_set(:@yml_path,         nil)
        subclass.instance_variable_set(:@configure_blocks, [])
        subclass.instance_variable_set(:@executors_paths,  [])
        subclass.instance_variable_set(:@contracts_paths,  [])
        subclass.instance_variable_set(:@agents_paths,     [])
        subclass.instance_variable_set(:@tools_paths,      [])
        subclass.instance_variable_set(:@skills_paths,     [])
        subclass.instance_variable_set(:@custom_routes,    [])
        subclass.instance_variable_set(:@before_request_hooks, [])
        subclass.instance_variable_set(:@after_request_hooks,  [])
        subclass.instance_variable_set(:@around_request_hooks, [])
        subclass.instance_variable_set(:@boot_blocks,      [])
        subclass.instance_variable_set(:@registered,       {})
        subclass.instance_variable_set(:@scheduled_jobs,   [])
        subclass.instance_variable_set(:@app_config,       AppConfig.new)
        subclass.instance_variable_set(:@build_scheduler,  nil)
        subclass.instance_variable_set(:@sdk_capabilities, [])
      end

      private

      # Build and return a ready Server::Config.
      def build!
        cfg = @app_config
        apply_yml!(cfg)
        autoload_paths!
        @boot_blocks.each(&:call)
        @configure_blocks.each { |b| b.call(cfg) }
        sc = cfg.to_server_config
        sc.custom_routes = @custom_routes.dup
        sc.before_request_hooks = @before_request_hooks.dup
        sc.after_request_hooks = @after_request_hooks.dup
        sc.around_request_hooks = @around_request_hooks.dup
        @registered.each { |name, klass| sc.register(name, klass) }
        sc
      end

      def apply_yml!(cfg)
        return unless @yml_path

        yml = YmlLoader.load(resolve_path(@yml_path))
        YmlLoader.apply(cfg, yml)
      end

      def autoload_paths!
        loader = Autoloader.new(base_dir: @root_dir || Dir.pwd)
        @executors_paths.each { |p| loader.load_path(p) }
        @contracts_paths.each { |p| loader.load_path(p) }
        @tools_paths.each     { |p| loader.load_path(p) }
        @agents_paths.each    { |p| loader.load_path(p) }
        @skills_paths.each    { |p| loader.load_path(p) }
      end

      def resolve_path(path)
        return path if path.nil? || File.absolute_path(path) == path

        File.expand_path(path, @root_dir || Dir.pwd)
      end

      def build_scheduler(server_config)
        return nil if @scheduled_jobs.empty?

        @build_scheduler ||= begin
          sched = Scheduler.new(logger: server_config.logger)
          @scheduled_jobs.each { |j| sched.add(j[:name], every: j[:every], at: j[:at], &j[:block]) }
          sched
        end
      end

      def normalize_request_hook!(callable, block, name)
        raise ArgumentError, "#{name} requires a callable `with:` or a block" unless callable || block
        raise ArgumentError, "#{name} cannot use both `with:` and a block" if callable && block

        callable || block
      end
    end
  end
end
