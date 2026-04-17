# frozen_string_literal: true

require_relative "app/runtime"
require_relative "app/diagnostics"
require_relative "app/evolution"
require_relative "stack"

module Igniter
  # Base class for Igniter apps.
  #
  # Provides a unified DSL for configuration, contract registration,
  # scheduled jobs, and server startup — replacing the raw
  # Igniter::Server.configure boilerplate.
  #
  # == Minimal example
  #
  #   require "igniter/app"
  #
  #   class MyApp < Igniter::App
  #     config_file "app.yml"        # optional YAML base config
  #
  #     configure do |c|
  #       c.app_host.port = 4567
  #       c.store         = Igniter::Runtime::Stores::MemoryStore.new
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
  # == YAML config (app.yml)
  #
  #   app_host:
  #     port: 4567
  #     host: "0.0.0.0"
  #     log_format: json    # text (default) or json
  #     drain_timeout: 30
  #
  # Values from the YAML file are applied first; the Ruby `configure` block
  # runs afterwards and always wins.
  class App
    class << self
      # ─── DSL ─────────────────────────────────────────────────────────────────

      def host(name = nil)
        return (@host_name ||= :app) unless name

        @host_name = normalize_host_name(name)
        @host_adapter = nil
        self
      end

      def register_host(name, builder = nil, &block)
        HostRegistry.register(name, builder, &block)
      end

      def loader(name = nil)
        return (@loader_name ||= :filesystem) unless name

        @loader_name = normalize_loader_name(name)
        @loader_adapter = nil
        self
      end

      def register_loader(name, builder = nil, &block)
        LoaderRegistry.register(name, builder, &block)
      end

      def scheduler(name = nil)
        return (@scheduler_name ||= :threaded) unless name

        @scheduler_name = normalize_scheduler_name(name)
        @scheduler_adapter = nil
        self
      end

      def register_scheduler(name, builder = nil, &block)
        SchedulerRegistry.register(name, builder, &block)
      end

      def use(*names)
        resolved_names = names.flatten.map(&:to_sym)
        Igniter::SDK.activate!(*resolved_names, layer: :app)
        @sdk_capabilities |= resolved_names
        self
      end

      def sdk_capabilities
        @sdk_capabilities ||= []
      end

      def host_adapter(adapter = nil)
        return (@host_adapter ||= build_host_adapter(host)) unless adapter

        @host_adapter = adapter
      end

      def loader_adapter(adapter = nil)
        return (@loader_adapter ||= build_loader_adapter(loader)) unless adapter

        @loader_adapter = adapter
      end

      def scheduler_adapter(adapter = nil)
        return (@scheduler_adapter ||= build_scheduler_adapter(scheduler)) unless adapter

        @scheduler_adapter = adapter
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
      # Schedules background jobs and delegates runtime hosting to the
      # configured host adapter.
      def start
        host  = host_adapter
        host.activate_transport!
        config = build!
        scheduler = start_scheduler(config)
        at_exit { stop_scheduler(scheduler) }
        host.start(config: config)
      end

      # Return a Rack-compatible application (for Puma / Unicorn / etc.)
      # through the configured host adapter.
      def rack_app
        host = host_adapter
        host.activate_transport!
        config = build!
        start_scheduler(config)
        host.rack_app(config: config)
      end

      def evolution_plan(target)
        Evolution::Planner.new(app_class: self).plan(target)
      end

      def apply_evolution!(target, approve: false, selections: {})
        plan = target.is_a?(Evolution::Plan) ? target : evolution_plan(target)
        Evolution::Runner.new(app_class: self).run(plan, approve: approve, selections: selections)
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
        subclass.instance_variable_set(:@sdk_capabilities, [])
        subclass.instance_variable_set(:@host_name,        nil)
        subclass.instance_variable_set(:@host_adapter,     nil)
        subclass.instance_variable_set(:@loader_name,      nil)
        subclass.instance_variable_set(:@loader_adapter,   nil)
        subclass.instance_variable_set(:@scheduler_name,   nil)
        subclass.instance_variable_set(:@scheduler_adapter, nil)
      end

      private

      def normalize_host_name(name)
        name.to_sym
      end

      def normalize_scheduler_name(name)
        name.to_sym
      end

      def normalize_loader_name(name)
        name.to_sym
      end

      def build_host_adapter(name)
        builder = host_registry.fetch(normalize_host_name(name))

        build_registered_host(builder)
      rescue KeyError
        raise ArgumentError, "unknown app host #{name.inspect}; expected one of: #{host_registry.names.join(', ')}"
      end

      def build_registered_host(builder)
        builder.arity == 0 ? builder.call : builder.call(self)
      end

      def build_loader_adapter(name)
        builder = loader_registry.fetch(normalize_loader_name(name))

        build_registered_loader(builder)
      rescue KeyError
        raise ArgumentError, "unknown app loader #{name.inspect}; expected one of: #{loader_registry.names.join(', ')}"
      end

      def build_registered_loader(builder)
        builder.arity == 0 ? builder.call : builder.call(self)
      end

      def build_scheduler_adapter(name)
        builder = scheduler_registry.fetch(normalize_scheduler_name(name))

        build_registered_scheduler(builder)
      rescue KeyError
        raise ArgumentError, "unknown app scheduler #{name.inspect}; expected one of: #{scheduler_registry.names.join(', ')}"
      end

      def build_registered_scheduler(builder)
        builder.arity == 0 ? builder.call : builder.call(self)
      end

      def host_registry
        HostRegistry
      end

      def loader_registry
        LoaderRegistry
      end

      def scheduler_registry
        SchedulerRegistry
      end

      # Build and return a ready host-specific config object.
      def build!
        cfg = @app_config
        apply_yml!(cfg)
        resolved_loader_adapter = load_application_code!
        @boot_blocks.each(&:call)
        @configure_blocks.each { |b| b.call(cfg) }
        cfg.custom_routes = @custom_routes.dup
        cfg.before_request_hooks = @before_request_hooks.dup
        cfg.after_request_hooks = @after_request_hooks.dup
        cfg.around_request_hooks = @around_request_hooks.dup

        host_config = cfg.to_host_config
        @registered.each { |name, klass| host_config.register(name, klass) }
        RuntimeContext.capture(
          app_class: self,
          host_config: host_config,
          host_name: host,
          loader_name: loader,
          scheduler_name: scheduler,
          sdk_capabilities: sdk_capabilities,
          loader_adapter: resolved_loader_adapter,
          scheduled_jobs: @scheduled_jobs,
          code_paths: code_paths_snapshot
        )
        host_adapter.build_config(host_config)
      end

      def apply_yml!(cfg)
        return unless @yml_path

        yml = YmlLoader.load(resolve_path(@yml_path))
        YmlLoader.apply(cfg, yml)
      end

      def load_application_code!
        adapter = loader_adapter
        adapter.load!(
          base_dir: @root_dir || Dir.pwd,
          paths: code_paths_snapshot
        )
        adapter
      end

      def code_paths_snapshot
        {
          executors: @executors_paths.dup,
          contracts: @contracts_paths.dup,
          tools: @tools_paths.dup,
          agents: @agents_paths.dup,
          skills: @skills_paths.dup
        }
      end

      def resolve_path(path)
        return path if path.nil? || File.absolute_path(path) == path

        File.expand_path(path, @root_dir || Dir.pwd)
      end

      def start_scheduler(config)
        return nil if @scheduled_jobs.empty?

        adapter = scheduler_adapter
        adapter.start(config: config, jobs: @scheduled_jobs)
        adapter
      end

      def stop_scheduler(adapter)
        adapter&.stop
      end

      def normalize_request_hook!(callable, block, name)
        raise ArgumentError, "#{name} requires a callable `with:` or a block" unless callable || block
        raise ArgumentError, "#{name} cannot use both `with:` and a block" if callable && block

        callable || block
      end
    end
  end
end
