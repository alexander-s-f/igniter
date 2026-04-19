# frozen_string_literal: true

require_relative "app/runtime"
require_relative "app/diagnostics"
require_relative "app/evolution"
require_relative "app/orchestration"
require "igniter/stack"

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
  #   # app_host is optional. In stack-first projects, host/port often live
  #   # in stack.yml node/server config rather than in app-local YAML.
  #   app_host:
  #     port: 4567
  #     host: "0.0.0.0"
  #     log_format: json    # text (default) or json
  #     drain_timeout: 30
  #
  # Values from the YAML file are applied first; the Ruby `configure` block
  # runs afterwards and always wins.
  #
  # In Stack/App vNext, an app is primarily a code/runtime package boundary.
  # Deployment ports and process grouping belong to stack nodes.
  class App
    class << self
      UNDEFINED_EVOLUTION_STORE = Object.new
      UNDEFINED_ORCHESTRATION_INBOX = Object.new

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

      def expose(name, callable)
        @exposed_interfaces ||= {}
        @exposed_interfaces[name.to_sym] = callable
      end

      def exposed_interfaces
        @exposed_interfaces || {}
      end

      def evolution_store(store = UNDEFINED_EVOLUTION_STORE)
        return @evolution_store if store.equal?(UNDEFINED_EVOLUTION_STORE)

        @evolution_store = store
        reload_evolution_trail!
      end

      def evolution_log(path, retain_events: nil, archive: nil, retention_policy: nil)
        evolution_store(
          Evolution::Stores::FileStore.new(
            path: resolve_path(path),
            max_events: retain_events,
            archive_path: archive ? resolve_path(archive) : nil,
            retention_policy: retention_policy
          )
        )
      end

      def orchestration_inbox(inbox = UNDEFINED_ORCHESTRATION_INBOX)
        return (@orchestration_inbox ||= Orchestration::Inbox.new) if inbox.equal?(UNDEFINED_ORCHESTRATION_INBOX)

        @orchestration_inbox = inbox
      end

      def register_orchestration_handler(action, handler = nil, queue: nil, &block)
        Orchestration::HandlerRegistry.register(action, handler, queue: queue, &block)
      end

      def register_orchestration_lane(action, lane:, policy: nil, handler: nil, routing: nil, queue: nil, channel: nil, description: nil, default: false, &block)
        resolved_handler = handler || block
        lane_routing = (routing || {}).dup
        lane_routing[:queue] = queue if queue
        lane_routing[:channel] = channel if channel

        Orchestration::LaneRegistry.register(
          action,
          lane: lane,
          queue: lane_routing[:queue],
          channel: lane_routing[:channel],
          routing: lane_routing,
          policy: policy,
          handler: resolved_handler,
          description: description
        )

        register_orchestration_policy(action, policy, queue: lane_routing[:queue]) if policy
        register_orchestration_handler(action, resolved_handler, queue: lane_routing[:queue]) if resolved_handler
        register_orchestration_routing(action, lane_routing) if default && !lane_routing.empty?
      end

      def orchestration_handler(action_or_item)
        if action_or_item.is_a?(Hash)
          action = action_or_item.fetch(:action)
          queue = action_or_item[:queue] || action_or_item.dig(:routing, :queue)
          return Orchestration::HandlerRegistry.fetch(action, queue: queue)
        end

        Orchestration::HandlerRegistry.fetch(action_or_item)
      end

      def register_orchestration_policy(action, policy = nil, queue: nil, &block)
        Orchestration::PolicyRegistry.register(action, policy, queue: queue, &block)
      end

      def orchestration_policy(action_or_item, queue: nil)
        if action_or_item.is_a?(Hash)
          action = action_or_item.fetch(:action)
          resolved_queue = queue || action_or_item[:queue] || action_or_item.dig(:routing, :queue)
          return Orchestration::PolicyRegistry.fetch(action, queue: resolved_queue)
        end

        Orchestration::PolicyRegistry.fetch(action_or_item, queue: queue)
      end

      def orchestration_lane(action_or_item, lane: nil, queue: nil)
        if action_or_item.is_a?(Hash)
          action = action_or_item.fetch(:action)
          resolved_lane = lane || action_or_item.dig(:lane, :name)
          resolved_queue = queue || action_or_item[:queue] || action_or_item.dig(:routing, :queue)
          return Orchestration::LaneRegistry.find(action, lane: resolved_lane, queue: resolved_queue)
        end

        Orchestration::LaneRegistry.find(action_or_item, lane: lane, queue: queue)
      end

      def register_orchestration_routing(action, routing = nil, &block)
        Orchestration::RoutingRegistry.register(action, routing, &block)
      end

      def orchestration_routing(action_or_item, policy: nil)
        action =
          if action_or_item.is_a?(Hash)
            action_or_item.fetch(:action)
          else
            action_or_item
          end

        resolved_policy = policy || orchestration_policy(action)
        default_routing = resolved_policy.default_routing
        override_routing = Orchestration::RoutingRegistry.registered?(action) ? Orchestration::RoutingRegistry.fetch(action) : {}

        default_routing.merge(override_routing).freeze
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

      def registered_contracts
        @registered.dup
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
        plan = Evolution::Planner.new(app_class: self).plan(target)
        evolution_trail.record(
          :evolution_plan_built,
          source: plan.source,
          payload: {
            total_actions: plan.actions.size,
            approval_required: plan.approval_required?,
            action_ids: plan.actions.map { |action| action[:id] },
            uncovered_capabilities: plan.summary[:uncovered_capabilities]
          }
        )
        plan
      end

      def orchestration_plan(target)
        Orchestration::Planner.new(app_class: self).plan(target)
      end

      def orchestration_followup(target)
        plan = target.is_a?(Orchestration::Plan) ? target : orchestration_plan(target)
        plan.followup_request
      end

      def open_orchestration_followups(target)
        plan = target.is_a?(Orchestration::Plan) ? target : orchestration_plan(target)
        execution = orchestration_execution_for(target)
        if execution && !target.is_a?(Orchestration::Plan)
          materialize_orchestration_sessions(plan, execution)
          plan = orchestration_plan(target)
        end
        graph, execution_id = orchestration_runtime_identity_for(target)
        Orchestration::Runner.new(app_class: self).run(
          plan,
          graph: graph,
          execution_id: execution_id,
          execution: execution
        )
      end

      def acknowledge_orchestration_item(id, note: nil)
        orchestration_inbox.acknowledge(id, note: note)
      end

      def resolve_orchestration_item(id, target: nil, value: Igniter::Runtime::Execution::UNDEFINED_RESUME_VALUE, note: nil)
        item = orchestration_inbox.find(id)
        return nil unless item

        metadata = resume_orchestration_item_runtime(item, target: target, value: value)
        orchestration_inbox.resolve(id, note: note, metadata: metadata)
      end

      def dismiss_orchestration_item(id, note: nil)
        orchestration_inbox.dismiss(id, note: note)
      end

      def wake_orchestration_item(id, note: nil)
        handle_orchestration_item(id, operation: :wake, note: note)
      end

      def handoff_orchestration_item(id, assignee: nil, queue: nil, channel: nil, note: nil)
        orchestration_inbox.handoff(id, assignee: assignee, queue: queue, channel: channel, note: note)
      end

      def complete_orchestration_item(id, target: nil, value: Igniter::Runtime::Execution::UNDEFINED_RESUME_VALUE, note: nil)
        handle_orchestration_item(id, operation: :complete, target: target, value: value, note: note)
      end

      def approve_orchestration_item(id, target: nil, value: Igniter::Runtime::Execution::UNDEFINED_RESUME_VALUE, note: nil)
        handle_orchestration_item(id, operation: :approve, target: target, value: value, note: note)
      end

      def reply_to_orchestration_item(id, target: nil, value: Igniter::Runtime::Execution::UNDEFINED_RESUME_VALUE, note: nil)
        handle_orchestration_item(id, operation: :reply, target: target, value: value, note: note)
      end

      def handle_orchestration_item(id, operation: nil, target: nil, value: Igniter::Runtime::Execution::UNDEFINED_RESUME_VALUE, assignee: nil, queue: nil, channel: nil, note: nil)
        item = orchestration_inbox.find(id)
        return nil unless item

        orchestration_handler(item).call(
          app_class: self,
          item: item,
          operation: operation,
          target: target,
          value: value,
          assignee: assignee,
          queue: queue,
          channel: channel,
          note: note
        )
      end

      def evolution_approval(target)
        plan = target.is_a?(Evolution::Plan) ? target : evolution_plan(target)
        request = plan.approval_request
        evolution_trail.record(
          :evolution_approval_requested,
          source: plan.source,
          payload: {
            total_actions: request.summary[:total],
            action_ids: request.action_ids,
            constrained: request.summary[:constrained]
          }
        )
        request
      end

      def apply_evolution!(target, approval: nil, approve: false, selections: {})
        plan = target.is_a?(Evolution::Plan) ? target : evolution_plan(target)
        decision = Evolution::ApprovalDecision.normalize(approval.nil? ? approve : approval, selections: selections)
        if plan.approval_required? && decision
          evolution_trail.record(
            :evolution_approval_recorded,
            source: plan.source,
            payload: decision.to_h.merge(action_ids: plan.actions.map { |action| action[:id] })
          )
        end
        result = Evolution::Runner.new(app_class: self).run(
          plan,
          approval: decision,
          approve: approve,
          selections: selections
        )
        evolution_trail.record(
          :"evolution_#{result.status}",
          source: plan.source,
          payload: {
            applied_action_ids: result.applied.map { |entry| entry[:id] },
            blocked_action_ids: result.blocked.map { |entry| entry[:id] },
            blocked_reasons: result.blocked.map { |entry| entry[:reason] }.uniq
          }
        )
        result
      end

      def evolution_trail
        @evolution_trail ||= Evolution::Trail.new(app_class: self, store: evolution_store)
      end

      def reset_evolution_trail!
        evolution_trail.clear!
      end

      def reload_evolution_trail!
        @evolution_trail = Evolution::Trail.new(app_class: self, store: evolution_store)
      end

      def reset_orchestration_inbox!
        orchestration_inbox.clear!
      end

      def orchestration_query
        orchestration_inbox.query
      end

      def orchestration_inbox_query
        orchestration_query
      end

      def orchestration_summary
        orchestration_query.summary
      end

      def operator_query(target = nil)
        execution = orchestration_execution_for(target)
        Orchestration::OperatorQuery.new(operator_records_for(execution))
      end

      def orchestration_operator_query(target = nil)
        operator_query(target)
      end

      def operator_summary(target = nil)
        operator_query(target).summary
      end

      def operator_overview(target = nil, limit: 20)
        query = operator_query(target)

        {
          app: name,
          summary: query.summary,
          records: query.limit(limit).to_a
        }.freeze
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
        subclass.instance_variable_set(:@evolution_store, nil)
        subclass.instance_variable_set(:@evolution_trail, Evolution::Trail.new(app_class: subclass))
        subclass.instance_variable_set(:@orchestration_inbox, nil)
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

      def orchestration_runtime_identity_for(target)
        execution = orchestration_execution_for(target)

        return [nil, nil] unless execution

        [execution.compiled_graph.name, execution.events.execution_id]
      end

      def orchestration_execution_for(target)
        return nil if target.nil?
        return target if target.is_a?(Igniter::Runtime::Execution)
        return target.execution if target.respond_to?(:execution)
        return target.instance_variable_get(:@execution) if target.class.name == "Igniter::Diagnostics::Report"

        nil
      end

      def resume_orchestration_item_runtime(item, target:, value:)
        return {} if target.nil? && value.equal?(Igniter::Runtime::Execution::UNDEFINED_RESUME_VALUE)
        return resume_orchestration_item_from_store(item, value: value) if target.nil?
        raise ArgumentError, "orchestration item #{item[:id].inspect} does not carry a runtime token" unless item[:token]

        execution = orchestration_execution_for(target)
        raise ArgumentError, "target must provide an execution to resume orchestration item #{item[:id].inspect}" unless execution
        if item[:execution_id] && execution.events.execution_id != item[:execution_id]
          raise ArgumentError,
                "orchestration item #{item[:id].inspect} belongs to execution #{item[:execution_id].inspect}, got #{execution.events.execution_id.inspect}"
        end
        if item[:graph] && execution.compiled_graph.name != item[:graph]
          raise ArgumentError,
                "orchestration item #{item[:id].inspect} belongs to graph #{item[:graph].inspect}, got #{execution.compiled_graph.name.inspect}"
        end

        execution.resume_agent_session(item[:token], node_name: item[:node], value: value)
        {
          runtime_resumed: true,
          runtime_resume_mode: :live,
          resolved_execution_id: execution.events.execution_id,
          resolved_graph: execution.compiled_graph.name,
          resumed_token: item[:token]
        }
      end

      def materialize_orchestration_sessions(plan, execution)
        plan.followup_request.actions.map { |action| action[:node] }.uniq.each do |node_name|
          execution.resolve(node_name)
        end
      end

      def operator_records_for(execution)
        graph, execution_id =
          if execution
            [execution.compiled_graph.name, execution.events.execution_id]
          else
            [nil, nil]
          end

        items = orchestration_inbox.items
        items = items.select { |item| operator_item_matches_execution?(item, graph: graph, execution_id: execution_id) } if execution
        actions_by_node = operator_actions_by_node(execution)
        pending_sessions = execution ? execution.agent_sessions.dup : []
        records = []

        items.reverse_each do |item|
          session = consume_matching_operator_session!(pending_sessions, item)
          records << build_operator_record(item: item, session: session, action: actions_by_node[item[:node]&.to_sym])
        end

        pending_sessions.each do |session|
          records << build_operator_record(item: nil, session: session, action: actions_by_node[session.node_name.to_sym])
        end

        records.reverse.freeze
      end

      def operator_actions_by_node(execution)
        return {} unless execution

        Array(execution.orchestration_plan[:actions]).each_with_object({}) do |action, memo|
          memo[action[:node].to_sym] = action.freeze
        end
      end

      def operator_item_matches_execution?(item, graph:, execution_id:)
        return true if graph.nil? || execution_id.nil?

        item[:graph].to_s == graph.to_s && item[:execution_id].to_s == execution_id.to_s
      end

      def consume_matching_operator_session!(pending_sessions, item)
        index =
          pending_sessions.index do |session|
            session.node_name == item[:node]&.to_sym &&
              session.graph.to_s == item[:graph].to_s &&
              session.execution_id.to_s == item[:execution_id].to_s &&
              (!item[:token] || session.token.to_s == item[:token].to_s)
          end

        index ||= pending_sessions.index do |session|
          session.node_name == item[:node]&.to_sym &&
            session.graph.to_s == item[:graph].to_s &&
            session.execution_id.to_s == item[:execution_id].to_s
        end

        index ? pending_sessions.delete_at(index) : nil
      end

      def build_operator_record(item:, session:, action:)
        combined_state =
          if item && session
            :joined
          elsif session
            :session_only
          else
            :inbox_only
          end

        {
          id: item&.fetch(:id, nil) || "agent_session:#{session.node_name}:#{session.token}",
          item_id: item&.dig(:item_id),
          action: item&.dig(:action) || action&.dig(:action),
          node: item&.dig(:node) || session&.node_name || action&.dig(:node),
          interaction: item&.dig(:interaction) || action&.dig(:interaction),
          reason: item&.dig(:reason) || action&.dig(:reason),
          guidance: item&.dig(:guidance) || action&.dig(:guidance),
          attention_required: item&.key?(:attention_required) ? !!item[:attention_required] : !!action&.dig(:attention_required),
          resumable: item&.key?(:resumable) ? !!item[:resumable] : !!action&.dig(:resumable),
          status: item&.dig(:status) || (session ? :live_session : nil),
          policy: (item&.dig(:policy) || action&.dig(:policy))&.dup,
          lane: (item&.dig(:lane) || action&.dig(:lane))&.dup,
          routing: (item&.dig(:routing) || action&.dig(:routing))&.dup,
          assignee: item&.dig(:assignee),
          queue: item&.dig(:queue) || item&.dig(:routing, :queue) || action&.dig(:routing, :queue),
          channel: item&.dig(:channel) || item&.dig(:routing, :channel) || action&.dig(:routing, :channel),
          handoff_count: item&.fetch(:handoff_count, 0) || 0,
          handoff_history: Array(item&.dig(:handoff_history)).map(&:dup).freeze,
          token: session&.token || item&.dig(:token),
          phase: session&.phase || item&.dig(:phase),
          reply_mode: session&.reply_mode || item&.dig(:reply_mode),
          mode: session&.mode,
          waiting_on: session&.waiting_on || item&.dig(:waiting_on),
          source_node: session&.source_node || item&.dig(:source_node),
          turn: session&.turn || item&.dig(:turn),
          tool_loop_status: session&.tool_loop_status,
          graph: session&.graph || item&.dig(:graph),
          execution_id: session&.execution_id || item&.dig(:execution_id),
          source: item&.dig(:source),
          note: item&.dig(:note),
          combined_state: combined_state,
          has_session: !session.nil?,
          has_inbox_item: !item.nil?,
          session: session&.to_h,
          inbox_item: item&.dup
        }.freeze
      end

      def resume_orchestration_item_from_store(item, value:)
        raise ArgumentError, "orchestration item #{item[:id].inspect} does not carry a runtime token" unless item[:token]
        raise ArgumentError, "orchestration item #{item[:id].inspect} does not carry an execution id" unless item[:execution_id]
        raise ArgumentError, "orchestration item #{item[:id].inspect} does not carry a graph name" unless item[:graph]

        contract_class = registered_contract_class_for_graph(item[:graph])
        raise ArgumentError, "no registered contract class found for graph #{item[:graph].inspect}" unless contract_class

        resumed = contract_class.resume_agent_session_from_store(
          item[:execution_id],
          session: item[:token],
          node_name: item[:node],
          value: value,
          store: Igniter.execution_store
        )

        {
          runtime_resumed: true,
          runtime_resume_mode: :store,
          resolved_execution_id: item[:execution_id],
          resolved_graph: item[:graph],
          resumed_token: item[:token],
          resumed_node: item[:node]
        }
      end

      def registered_contract_class_for_graph(graph)
        registered_contracts.values.find do |contract_class|
          next true if contract_class.respond_to?(:compiled_graph) && contract_class.compiled_graph&.name == graph
          next true if contract_class.respond_to?(:graph) && contract_class.graph&.name == graph

          contract_class.respond_to?(:contract_name) && contract_class.contract_name == graph
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
