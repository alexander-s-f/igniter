# frozen_string_literal: true

require_relative "app/runtime"
require_relative "app/diagnostics"
require_relative "app/credentials"
require_relative "app/evolution"
require_relative "app/operator"
require_relative "app/observability"
require_relative "app/observability_pack"
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

      def provide(name, callable = nil, &block)
        resolved = callable || block
        raise ArgumentError, "provide requires a callable or block" unless resolved
        raise ArgumentError, "provide cannot use both a callable and a block" if callable && block

        expose(name, resolved)
      end

      def exposed_interfaces
        @exposed_interfaces || {}
      end

      def provided_interfaces
        exposed_interfaces
      end

      def bind_stack_context(stack_class:, app_name:, access_to: [])
        @stack_bindings ||= {}
        @stack_bindings[stack_class] = {
          app_name: app_name.to_sym,
          access_to: Array(access_to).map(&:to_sym).freeze
        }.freeze
        @preferred_stack_class = stack_class
        self
      end

      def stack_bindings
        (@stack_bindings || {}).dup
      end

      def stack_class(stack = nil)
        return stack if stack
        return @preferred_stack_class if defined?(@preferred_stack_class) && @preferred_stack_class

        bindings = @stack_bindings || {}
        return bindings.keys.first if bindings.size == 1

        nil
      end

      def app_name_in_stack(stack = nil)
        stack_binding_for!(stack).fetch(:app_name)
      end

      def declared_access_to(stack = nil)
        stack_binding_for!(stack).fetch(:access_to)
      end

      def can_access_interface?(name, stack: nil)
        declared_access_to(stack).include?(name.to_sym)
      rescue ArgumentError
        false
      end

      def interfaces(stack: nil)
        resolved_stack = stack_context_for!(stack)
        allowed = declared_access_to(resolved_stack)
        resolved_stack.interfaces.each_with_object({}) do |(name, callable), hash|
          hash[name] = callable if allowed.include?(name)
        end
      end

      def interface(name, stack: nil)
        iface_name = name.to_sym
        return exposed_interfaces.fetch(iface_name) if exposed_interfaces.key?(iface_name)

        resolved_stack = stack_context_for!(stack)
        allowed = declared_access_to(resolved_stack)
        unless allowed.include?(iface_name)
          raise KeyError,
                "App #{self} does not declare access_to #{iface_name.inspect} on #{resolved_stack}. " \
                "Declared interfaces: #{allowed.inspect}"
        end

        resolved_stack.interface(iface_name)
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

      def acknowledge_orchestration_item(id, note: nil, audit: nil)
        applied_audit = canonical_orchestration_audit(
          audit,
          requested_operation: :acknowledge,
          lifecycle_operation: :acknowledge,
          execution_operation: :acknowledge
        )
        item = orchestration_inbox.acknowledge(
          id,
          note: note,
          audit: applied_audit
        )
        augment_orchestration_action_result(
          item,
          requested_operation: :acknowledge,
          handled_operation: :acknowledge,
          handled_lifecycle_operation: :acknowledge,
          handled_execution_operation: :acknowledge,
          handled_policy: nil,
          note: note,
          audit: applied_audit
        )
      end

      def resolve_orchestration_item(id, target: nil, value: Igniter::Runtime::Execution::UNDEFINED_RESUME_VALUE, note: nil, audit: nil)
        item = orchestration_inbox.find(id)
        return nil unless item

        resume_result = resume_orchestration_item_runtime(item, target: target, value: value)
        applied_audit = canonical_orchestration_audit(
          audit,
          requested_operation: :resolve,
          lifecycle_operation: :resolve,
          execution_operation: :resolve
        )
        resolved_item = orchestration_inbox.resolve(
          id,
          note: note,
          metadata: resume_result[:metadata],
          audit: applied_audit
        )
        result = augment_orchestration_runtime_result(
          resolved_item,
          execution: resume_result[:execution]
        )
        augment_orchestration_action_result(
          result,
          requested_operation: :resolve,
          handled_operation: :resolve,
          handled_lifecycle_operation: :resolve,
          handled_execution_operation: :resolve,
          handled_policy: nil,
          note: note,
          audit: applied_audit
        )
      end

      def dismiss_orchestration_item(id, note: nil, audit: nil)
        applied_audit = canonical_orchestration_audit(
          audit,
          requested_operation: :dismiss,
          lifecycle_operation: :dismiss,
          execution_operation: :dismiss
        )
        item = orchestration_inbox.dismiss(
          id,
          note: note,
          audit: applied_audit
        )
        augment_orchestration_action_result(
          item,
          requested_operation: :dismiss,
          handled_operation: :dismiss,
          handled_lifecycle_operation: :dismiss,
          handled_execution_operation: :dismiss,
          handled_policy: nil,
          note: note,
          audit: applied_audit
        )
      end

      def wake_orchestration_item(id, note: nil, audit: nil)
        handle_orchestration_item(id, operation: :wake, note: note, audit: audit)
      end

      def handoff_orchestration_item(id, assignee: nil, queue: nil, channel: nil, note: nil, audit: nil)
        applied_audit = canonical_orchestration_audit(
          audit,
          requested_operation: :handoff,
          lifecycle_operation: :acknowledge,
          execution_operation: :handoff
        )
        item = orchestration_inbox.handoff(
          id,
          assignee: assignee,
          queue: queue,
          channel: channel,
          note: note,
          audit: applied_audit
        )
        augment_orchestration_action_result(
          item,
          requested_operation: :handoff,
          handled_operation: :handoff,
          handled_lifecycle_operation: :acknowledge,
          handled_execution_operation: :handoff,
          handled_policy: nil,
          note: note,
          audit: applied_audit,
          handled_queue: item[:queue],
          handled_channel: item[:channel],
          handled_assignee: item[:assignee]
        )
      end

      def complete_orchestration_item(id, target: nil, value: Igniter::Runtime::Execution::UNDEFINED_RESUME_VALUE, note: nil, audit: nil)
        handle_orchestration_item(id, operation: :complete, target: target, value: value, note: note, audit: audit)
      end

      def approve_orchestration_item(id, target: nil, value: Igniter::Runtime::Execution::UNDEFINED_RESUME_VALUE, note: nil, audit: nil)
        handle_orchestration_item(id, operation: :approve, target: target, value: value, note: note, audit: audit)
      end

      def reply_to_orchestration_item(id, target: nil, value: Igniter::Runtime::Execution::UNDEFINED_RESUME_VALUE, note: nil, audit: nil)
        handle_orchestration_item(id, operation: :reply, target: target, value: value, note: note, audit: audit)
      end

      def wake_operator_item(id, target: nil, note: nil, audit: nil)
        handle_operator_item(id, operation: :wake, target: target, note: note, audit: audit)
      end

      def handoff_operator_item(id, assignee: nil, queue: nil, channel: nil, note: nil, audit: nil)
        handle_operator_item(
          id,
          operation: :handoff,
          assignee: assignee,
          queue: queue,
          channel: channel,
          note: note,
          audit: audit
        )
      end

      def complete_operator_item(id, target: nil, value: Igniter::Runtime::Execution::UNDEFINED_RESUME_VALUE, note: nil, audit: nil)
        handle_operator_item(id, operation: :complete, target: target, value: value, note: note, audit: audit)
      end

      def approve_operator_item(id, target: nil, value: Igniter::Runtime::Execution::UNDEFINED_RESUME_VALUE, note: nil, audit: nil)
        handle_operator_item(id, operation: :approve, target: target, value: value, note: note, audit: audit)
      end

      def reply_to_operator_item(id, target: nil, value: Igniter::Runtime::Execution::UNDEFINED_RESUME_VALUE, note: nil, audit: nil)
        handle_operator_item(id, operation: :reply, target: target, value: value, note: note, audit: audit)
      end

      def dismiss_operator_item(id, note: nil, audit: nil)
        handle_operator_item(id, operation: :dismiss, note: note, audit: audit)
      end

      def retry_operator_item(id, note: nil, audit: nil)
        handle_operator_item(id, operation: :retry_bootstrap, note: note, audit: audit)
      end

      def detach_operator_item(id, note: nil, audit: nil)
        handle_operator_item(id, operation: :detach, note: note, audit: audit)
      end

      def reignite_operator_item(id, note: nil, audit: nil)
        handle_operator_item(id, operation: :reignite, note: note, audit: audit)
      end

      def teardown_operator_item(id, note: nil, audit: nil)
        handle_operator_item(id, operation: :teardown, note: note, audit: audit)
      end

      def reconcile_operator_item(id, note: nil, audit: nil)
        handle_operator_item(id, operation: :reconcile_join, note: note, audit: audit)
      end

      def handle_operator_item(id, operation: nil, target: nil, value: Igniter::Runtime::Execution::UNDEFINED_RESUME_VALUE, assignee: nil, queue: nil, channel: nil, note: nil, audit: nil)
        record = operator_query(target, filters: { id: id }).first
        return nil unless record

        operator_dispatcher.call(
          app_class: self,
          record: record,
          operation: operation,
          target: target,
          value: value,
          assignee: assignee,
          queue: queue,
          channel: channel,
          note: note,
          audit: audit
        )
      end

      def handle_orchestration_item(id, operation: nil, target: nil, value: Igniter::Runtime::Execution::UNDEFINED_RESUME_VALUE, assignee: nil, queue: nil, channel: nil, note: nil, audit: nil)
        item = orchestration_inbox.find(id)
        return nil unless item

        handler = orchestration_handler(item)
        kwargs = {
          app_class: self,
          item: item,
          operation: operation,
          target: target,
          value: value,
          assignee: assignee,
          queue: queue,
          channel: channel,
          note: note,
          audit: audit
        }
        kwargs.delete(:audit) unless callable_accepts_keyword?(handler, :audit)

        handler.call(**kwargs)
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

      def orchestration_runtime_overview(target = nil)
        execution = orchestration_execution_for(target)
        return nil unless execution

        merged_orchestration_runtime_overview(execution)
      end

      def orchestration_runtime_event_query(target = nil, filters: nil, order_by: nil, direction: :asc)
        overview = orchestration_runtime_overview(target)
        return nil unless overview

        query = Orchestration::RuntimeEventQuery.new(overview[:combined_timeline])
        apply_orchestration_runtime_event_query_options(
          query,
          filters: filters,
          order_by: order_by,
          direction: direction
        )
      end

      def orchestration_runtime_transition_query(target = nil, filters: nil, order_by: nil, direction: :asc)
        execution = orchestration_execution_for(target)
        return nil unless execution

        query = execution.orchestration_transition_query
        apply_orchestration_runtime_transition_query_options(
          query,
          filters: filters,
          order_by: order_by,
          direction: direction
        )
      end

      def orchestration_runtime_summary(target = nil)
        orchestration_runtime_overview(target)&.fetch(:summary, nil)
      end

      def orchestration_runtime_event_summary(target = nil, filters: nil, order_by: nil, direction: :asc)
        orchestration_runtime_event_query(
          target,
          filters: filters,
          order_by: order_by,
          direction: direction
        )&.summary
      end

      def orchestration_runtime_transition_summary(target = nil, filters: nil, order_by: nil, direction: :asc)
        orchestration_runtime_transition_query(
          target,
          filters: filters,
          order_by: order_by,
          direction: direction
        )&.summary
      end

      def orchestration_runtime_event_overview(target = nil, filters: nil, order_by: nil, direction: :asc, limit: 20)
        query = orchestration_runtime_event_query(
          target,
          filters: filters,
          order_by: order_by,
          direction: direction
        )
        return nil unless query

        Orchestration::RuntimeQueryOverviewBuilder.build(
          query: query,
          filters: compact_operator_filters(filters),
          order_by: order_by,
          direction: direction,
          limit: limit
        )
      end

      def orchestration_runtime_transition_overview(target = nil, filters: nil, order_by: nil, direction: :asc, limit: 20)
        query = orchestration_runtime_transition_query(
          target,
          filters: filters,
          order_by: order_by,
          direction: direction
        )
        return nil unless query

        Orchestration::RuntimeQueryOverviewBuilder.build(
          query: query,
          filters: compact_operator_filters(filters),
          order_by: order_by,
          direction: direction,
          limit: limit
        )
      end

      def orchestration_runtime_record_event_overview(target = nil, id: nil, node: nil, filters: nil, order_by: nil, direction: :asc, limit: 20)
        record = orchestration_runtime_record_for(target, id: id, node: node)
        return nil unless record

        query = Orchestration::RuntimeEventQuery.new(record[:combined_timeline])
        query = apply_orchestration_runtime_event_query_options(
          query,
          filters: filters,
          order_by: order_by,
          direction: direction
        )
        Orchestration::RuntimeQueryOverviewBuilder.build(
          query: query,
          filters: compact_operator_filters(filters),
          order_by: order_by,
          direction: direction,
          limit: limit
        ).merge(
          id: record[:id],
          node: record[:node]
        ).freeze
      end

      def orchestration_runtime_overview_for_execution(graph:, execution_id:, store: nil)
        target = operator_target_for_execution(graph: graph, execution_id: execution_id, store: store)
        merged_orchestration_runtime_overview(target.execution)
      end

      def orchestration_runtime_event_query_for_execution(graph:, execution_id:, store: nil, filters: nil, order_by: nil, direction: :asc)
        query = Orchestration::RuntimeEventQuery.new(
          orchestration_runtime_overview_for_execution(
            graph: graph,
            execution_id: execution_id,
            store: store
          )[:combined_timeline]
        )
        apply_orchestration_runtime_event_query_options(
          query,
          filters: filters,
          order_by: order_by,
          direction: direction
        )
      end

      def orchestration_runtime_transition_query_for_execution(graph:, execution_id:, store: nil, filters: nil, order_by: nil, direction: :asc)
        query = operator_target_for_execution(graph: graph, execution_id: execution_id, store: store).execution.orchestration_transition_query
        apply_orchestration_runtime_transition_query_options(
          query,
          filters: filters,
          order_by: order_by,
          direction: direction
        )
      end

      def orchestration_runtime_summary_for_execution(graph:, execution_id:, store: nil)
        orchestration_runtime_overview_for_execution(
          graph: graph,
          execution_id: execution_id,
          store: store
        ).fetch(:summary)
      end

      def orchestration_runtime_event_summary_for_execution(graph:, execution_id:, store: nil, filters: nil, order_by: nil, direction: :asc)
        orchestration_runtime_event_query_for_execution(
          graph: graph,
          execution_id: execution_id,
          store: store,
          filters: filters,
          order_by: order_by,
          direction: direction
        ).summary
      end

      def orchestration_runtime_transition_summary_for_execution(graph:, execution_id:, store: nil, filters: nil, order_by: nil, direction: :asc)
        orchestration_runtime_transition_query_for_execution(
          graph: graph,
          execution_id: execution_id,
          store: store,
          filters: filters,
          order_by: order_by,
          direction: direction
        ).summary
      end

      def orchestration_runtime_event_overview_for_execution(graph:, execution_id:, store: nil, filters: nil, order_by: nil, direction: :asc, limit: 20)
        query = orchestration_runtime_event_query_for_execution(
          graph: graph,
          execution_id: execution_id,
          store: store,
          filters: filters,
          order_by: order_by,
          direction: direction
        )
        Orchestration::RuntimeQueryOverviewBuilder.build(
          query: query,
          filters: compact_operator_filters(filters),
          order_by: order_by,
          direction: direction,
          limit: limit
        )
      end

      def orchestration_runtime_transition_overview_for_execution(graph:, execution_id:, store: nil, filters: nil, order_by: nil, direction: :asc, limit: 20)
        query = orchestration_runtime_transition_query_for_execution(
          graph: graph,
          execution_id: execution_id,
          store: store,
          filters: filters,
          order_by: order_by,
          direction: direction
        )
        Orchestration::RuntimeQueryOverviewBuilder.build(
          query: query,
          filters: compact_operator_filters(filters),
          order_by: order_by,
          direction: direction,
          limit: limit
        )
      end

      def orchestration_runtime_record_event_overview_for_execution(graph:, execution_id:, store: nil, id: nil, node: nil, filters: nil, order_by: nil, direction: :asc, limit: 20)
        target = operator_target_for_execution(graph: graph, execution_id: execution_id, store: store)
        orchestration_runtime_record_event_overview(
          target.execution,
          id: id,
          node: node,
          filters: filters,
          order_by: order_by,
          direction: direction,
          limit: limit
        )
      end

      def operator_query(target = nil, filters: nil, order_by: nil, direction: :asc)
        execution = orchestration_execution_for(target)
        query = Orchestration::OperatorQuery.new(operator_records_for(execution))
        apply_operator_query_options(query, filters: filters, order_by: order_by, direction: direction)
      end

      def orchestration_operator_query(target = nil, filters: nil, order_by: nil, direction: :asc)
        operator_query(target, filters: filters, order_by: order_by, direction: direction)
      end

      def operator_summary(target = nil, filters: nil, order_by: nil, direction: :asc)
        operator_query(target, filters: filters, order_by: order_by, direction: direction).summary
      end

      def request_credential_lease(...)
        resolved_stack = stack_class
        raise ArgumentError, "App #{self} is not bound to a stack" unless resolved_stack

        resolved_stack.request_credential_lease(...)
      end

      def issue_credential_lease(...)
        resolved_stack = stack_class
        raise ArgumentError, "App #{self} is not bound to a stack" unless resolved_stack

        resolved_stack.issue_credential_lease(...)
      end

      def deny_credential_lease(...)
        resolved_stack = stack_class
        raise ArgumentError, "App #{self} is not bound to a stack" unless resolved_stack

        resolved_stack.deny_credential_lease(...)
      end

      def revoke_credential_lease(...)
        resolved_stack = stack_class
        raise ArgumentError, "App #{self} is not bound to a stack" unless resolved_stack

        resolved_stack.revoke_credential_lease(...)
      end

      def credential_request_overview(limit: 20, filters: nil, order_by: nil, direction: :asc)
        resolved_stack = stack_class
        return nil unless resolved_stack

        resolved_stack.credential_request_history(
          limit: limit,
          filters: filters,
          order_by: order_by,
          direction: direction
        ).merge(
          app: name,
          stack: resolved_stack.name || "anonymous"
        ).freeze
      end

      def operator_overview(target = nil, limit: 20, filters: nil, order_by: nil, direction: :asc, event_filters: nil, event_order_by: nil, event_direction: :asc, event_limit: nil, credential_filters: nil, credential_order_by: nil, credential_direction: :asc, credential_limit: nil, credential_request_filters: nil, credential_request_order_by: nil, credential_request_direction: :asc, credential_request_limit: nil)
        query = operator_query(target, filters: filters, order_by: order_by, direction: direction)
        execution = orchestration_execution_for(target)
        orchestration_runtime = execution ? orchestration_runtime_overview(execution) : nil
        credential_audit = credential_audit_overview(
          limit: credential_limit || event_limit || limit,
          filters: credential_filters,
          order_by: credential_order_by,
          direction: credential_direction
        )
        credential_requests = credential_request_overview(
          limit: credential_request_limit || credential_limit || event_limit || limit,
          filters: credential_request_filters,
          order_by: credential_request_order_by,
          direction: credential_request_direction
        )
        orchestration_transitions =
          execution ? orchestration_runtime_transition_overview(
            execution,
            order_by: :timestamp,
            direction: :asc,
            limit: event_limit || limit
          ) : nil
        orchestration_events =
          execution ? orchestration_runtime_event_overview(
            execution,
            filters: event_filters,
            order_by: event_order_by,
            direction: event_direction,
            limit: event_limit || limit
          ) : nil
        record_events = operator_record_event_overview(
          execution,
          query: query,
          filters: filters,
          event_filters: event_filters,
          event_order_by: event_order_by,
          event_direction: event_direction,
          event_limit: event_limit || limit
        )

        {
          app: name,
          query: operator_query_metadata(filters: filters, order_by: order_by, direction: direction, limit: limit),
          summary: query.summary,
          runtime: operator_runtime_overview(query),
          credential_audit: credential_audit,
          credential_requests: credential_requests,
          orchestration_runtime: orchestration_runtime,
          orchestration_transitions: orchestration_transitions,
          orchestration_events: orchestration_events,
          record_events: record_events,
          records: query.limit(limit).to_a
        }.freeze
      end

      def operator_query_for_execution(graph:, execution_id:, store: nil, filters: nil, order_by: nil, direction: :asc)
        operator_query(
          operator_target_for_execution(graph: graph, execution_id: execution_id, store: store),
          filters: filters,
          order_by: order_by,
          direction: direction
        )
      end

      def operator_summary_for_execution(graph:, execution_id:, store: nil, filters: nil, order_by: nil, direction: :asc)
        operator_query_for_execution(
          graph: graph,
          execution_id: execution_id,
          store: store,
          filters: filters,
          order_by: order_by,
          direction: direction
        ).summary
      end

      def operator_overview_for_execution(graph:, execution_id:, limit: 20, store: nil, filters: nil, order_by: nil, direction: :asc, event_filters: nil, event_order_by: nil, event_direction: :asc, event_limit: nil, credential_filters: nil, credential_order_by: nil, credential_direction: :asc, credential_limit: nil, credential_request_filters: nil, credential_request_order_by: nil, credential_request_direction: :asc, credential_request_limit: nil)
        query = operator_query_for_execution(
          graph: graph,
          execution_id: execution_id,
          store: store,
          filters: filters,
          order_by: order_by,
          direction: direction
        )
        target = operator_target_for_execution(graph: graph, execution_id: execution_id, store: store)
        orchestration_runtime = orchestration_runtime_overview(target.execution)
        credential_audit = credential_audit_overview(
          limit: credential_limit || event_limit || limit,
          filters: credential_filters,
          order_by: credential_order_by,
          direction: credential_direction
        )
        credential_requests = credential_request_overview(
          limit: credential_request_limit || credential_limit || event_limit || limit,
          filters: credential_request_filters,
          order_by: credential_request_order_by,
          direction: credential_request_direction
        )
        orchestration_transitions = orchestration_runtime_transition_overview_for_execution(
          graph: graph,
          execution_id: execution_id,
          store: store,
          order_by: :timestamp,
          direction: :asc,
          limit: event_limit || limit
        )
        orchestration_events = orchestration_runtime_event_overview_for_execution(
          graph: graph,
          execution_id: execution_id,
          store: store,
          filters: event_filters,
          order_by: event_order_by,
          direction: event_direction,
          limit: event_limit || limit
        )
        record_events = operator_record_event_overview(
          target.execution,
          query: query,
          filters: filters,
          event_filters: event_filters,
          event_order_by: event_order_by,
          event_direction: event_direction,
          event_limit: event_limit || limit
        )

        {
          app: name,
          scope: {
            mode: :execution,
            graph: graph,
            execution_id: execution_id
          }.freeze,
          query: operator_query_metadata(filters: filters, order_by: order_by, direction: direction, limit: limit),
          summary: query.summary,
          runtime: operator_runtime_overview(query),
          credential_audit: credential_audit,
          credential_requests: credential_requests,
          orchestration_runtime: orchestration_runtime,
          orchestration_transitions: orchestration_transitions,
          orchestration_events: orchestration_events,
          record_events: record_events,
          records: query.limit(limit).to_a
        }.freeze
      end

      def mount_operator_overview(path: "/api/operator", limit: 20, store: nil)
        ObservabilityPack.install(
          self,
          path: path,
          limit: limit,
          store: store
        )
      end

      def mount_operator_observability(path: "/api/operator", limit: 20, store: nil)
        mount_operator_overview(path: path, limit: limit, store: store)
      end

      def mount_operator_actions(path: "/api/operator/actions", store: nil)
        ObservabilityPack.install_actions(
          self,
          path: path,
          store: store
        )
      end

      def mount_operator_surface(path: "/operator", api_path: "/api/operator", action_path: "/api/operator/actions", limit: 20, store: nil, title: nil)
        ObservabilityPack.install_surface(
          self,
          path: path,
          api_path: api_path,
          action_path: action_path,
          limit: limit,
          store: store,
          title: title
        )
      end

      def mount_operator_console(path: "/operator", api_path: "/api/operator", action_path: "/api/operator/actions", limit: 20, store: nil, title: nil)
        mount_operator_surface(path: path, api_path: api_path, action_path: action_path, limit: limit, store: store, title: title)
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
        subclass.instance_variable_set(:@stack_bindings, {})
        subclass.instance_variable_set(:@preferred_stack_class, nil)
      end

      private

      def stack_context_for!(stack = nil)
        resolved_stack = stack_class(stack)
        return resolved_stack if resolved_stack

        raise ArgumentError,
              "App #{self} is not bound to a stack context. Pass stack: explicitly or register it through Igniter::Stack.app."
      end

      def stack_binding_for!(stack = nil)
        resolved_stack = stack_context_for!(stack)
        binding = (@stack_bindings || {})[resolved_stack]
        return binding if binding

        raise ArgumentError, "App #{self} is not registered in stack #{resolved_stack}."
      end

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
        if target.nil? && value.equal?(Igniter::Runtime::Execution::UNDEFINED_RESUME_VALUE)
          return { metadata: {}, execution: nil }.freeze
        end
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
          metadata: {
            runtime_resumed: true,
            runtime_resume_mode: :live,
            resolved_execution_id: execution.events.execution_id,
            resolved_graph: execution.compiled_graph.name,
            resumed_token: item[:token]
          }.freeze,
          execution: execution
        }.freeze
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

        records = []
        records.concat(ignite_operator_records) unless execution

        items = orchestration_inbox.items
        items = items.select { |item| operator_item_matches_execution?(item, graph: graph, execution_id: execution_id) } if execution
        actions_by_node = operator_actions_by_node(execution)
        pending_sessions = execution ? execution.agent_sessions.dup : []

        items.reverse_each do |item|
          session = consume_matching_operator_session!(pending_sessions, item)
          records << build_operator_record(item: item, session: session, action: actions_by_node[item[:node]&.to_sym])
        end

        pending_sessions.each do |session|
          records << build_operator_record(item: nil, session: session, action: actions_by_node[session.node_name.to_sym])
        end

        records.reverse.freeze
      end

      def ignite_operator_records
        resolved_stack = stack_class
        return [] unless resolved_stack

        all_events = Array(resolved_stack.ignition_trail.events)
        target_events = all_events.select { |event| event[:type] == :ignition_target_snapshot }
        return [] if target_events.empty?

        latest_by_target = {}
        timelines = Hash.new { |hash, key| hash[key] = [] }

        all_events.each do |event|
          target_id = event.dig(:payload, :target_id).to_s
          next if target_id.empty?

          timelines[target_id] << event.dup
          latest_by_target[target_id] = event if event[:type] == :ignition_target_snapshot
        end

        latest_by_target.each_with_object([]) do |(target_id, event), records|
          records << build_ignite_operator_record(
            target_id: target_id,
            event: event,
            timeline: Array(timelines[target_id]).freeze
          )
        end
      end

      def operator_actions_by_node(execution)
        return {} unless execution

        Array(merged_orchestration_runtime_overview(execution)[:records]).each_with_object({}) do |action, memo|
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

        status = item&.dig(:status) || (session ? :live_session : nil)
        policy = (item&.dig(:policy) || action&.dig(:policy))&.dup
        action_history = Array(item&.dig(:action_history)).map(&:dup).freeze
        lifecycle = build_operator_lifecycle_contract(
          record_kind: :orchestration,
          status: status,
          combined_state: combined_state,
          policy: policy,
          attention_required: item&.key?(:attention_required) ? !!item[:attention_required] : !!action&.dig(:attention_required),
          resumable: item&.key?(:resumable) ? !!item[:resumable] : !!action&.dig(:resumable),
          has_inbox_item: !item.nil?,
          history_count: action_history.size
        )

        {
          record_kind: :orchestration,
          id: item&.fetch(:id, nil) || "agent_session:#{session.node_name}:#{session.token}",
          item_id: item&.dig(:item_id),
          action: item&.dig(:action) || action&.dig(:action),
          node: item&.dig(:node) || session&.node_name || action&.dig(:node),
          interaction: item&.dig(:interaction) || action&.dig(:interaction),
          reason: item&.dig(:reason) || action&.dig(:reason),
          guidance: item&.dig(:guidance) || action&.dig(:guidance),
          attention_required: lifecycle[:attention_required],
          resumable: lifecycle[:resumable],
          status: status,
          policy: policy,
          lane: (item&.dig(:lane) || action&.dig(:lane))&.dup,
          routing: (item&.dig(:routing) || action&.dig(:routing))&.dup,
          assignee: item&.dig(:assignee),
          queue: item&.dig(:queue) || item&.dig(:routing, :queue) || action&.dig(:routing, :queue),
          channel: item&.dig(:channel) || item&.dig(:routing, :channel) || action&.dig(:routing, :channel),
          handoff_count: item&.fetch(:handoff_count, 0) || 0,
          handoff_history: Array(item&.dig(:handoff_history)).map(&:dup).freeze,
          action_history_count: action_history.size,
          latest_action_source: item&.dig(:action_history)&.last&.dig(:source),
          latest_action_actor: item&.dig(:action_history)&.last&.dig(:actor),
          latest_action_origin: item&.dig(:action_history)&.last&.dig(:origin),
          latest_action_event: item&.dig(:action_history)&.last&.dup,
          action_history: action_history,
          token: session&.token || item&.dig(:token),
          orchestration_runtime_status: action&.dig(:runtime_status),
          orchestration_timeline: Array(action&.dig(:timeline)).map(&:dup).freeze,
          orchestration_combined_timeline: Array(action&.dig(:combined_timeline)).map(&:dup).freeze,
          orchestration_event_summary: action&.dig(:event_summary),
          orchestration_latest_event: action&.dig(:latest_event),
          orchestration_inbox_status: action&.dig(:inbox_status),
          phase: session&.phase || item&.dig(:phase),
          session_lifecycle_state: session&.lifecycle_state,
          reply_mode: session&.reply_mode || item&.dig(:reply_mode),
          mode: session&.mode,
          finalizer: session&.finalizer || item&.dig(:finalizer),
          session_policy: session&.session_policy || item&.dig(:session_policy),
          tool_loop_policy: session&.tool_loop_policy || item&.dig(:tool_loop_policy),
          routing_mode: session&.routing_mode || item&.dig(:routing_mode),
          agent_result_contract: session&.agent_result_contract&.to_h,
          interaction_contract: session&.interaction_contract&.to_h || item&.dig(:interaction_contract),
          tool_runtime: session&.tool_runtime,
          ownership: session&.ownership,
          owner_url: session&.owner_url,
          delivery_route: session&.delivery_route,
          interactive: session ? session.interactive? : false,
          terminal: session ? session.terminal? : false,
          continuable: session ? session.continuable? : false,
          routed: session ? session.routed? : false,
          waiting_on: session&.waiting_on || item&.dig(:waiting_on),
          source_node: session&.source_node || item&.dig(:source_node),
          turn: session&.turn || item&.dig(:turn),
          tool_loop_status: session&.tool_loop_status,
          graph: session&.graph || item&.dig(:graph),
          execution_id: session&.execution_id || item&.dig(:execution_id),
          source: item&.dig(:source),
          note: item&.dig(:note),
          combined_state: combined_state,
          lifecycle: lifecycle,
          has_session: !session.nil?,
          has_inbox_item: !item.nil?,
          session_lifecycle: session&.lifecycle,
          session: session&.to_h,
          inbox_item: item&.dup
        }.freeze
      end

      def build_ignite_operator_record(target_id:, event:, timeline:)
        payload = event.fetch(:payload)
        latest_timeline_event = timeline.last
        latest_action_event = timeline.reverse_each.find { |timeline_event| ignite_operator_event?(timeline_event) } || latest_timeline_event
        latest_action_payload = latest_action_event&.dig(:payload) || {}
        ignite_policy = ignite_policy_for(payload)
        ignite_routing = ignite_policy.default_routing
        lifecycle = build_operator_lifecycle_contract(
          record_kind: :ignition,
          status: payload[:status]&.to_sym,
          combined_state: :ignition,
          policy: ignite_policy.to_h,
          attention_required: ignite_attention_required?(payload),
          resumable: ignite_resumable?(payload),
          has_inbox_item: false,
          history_count: timeline.size
        )

        {
          record_kind: :ignition,
          id: "ignite:#{target_id}",
          item_id: nil,
          action: payload[:action]&.to_sym,
          node: target_id.to_sym,
          interaction: :ignite,
          reason: payload[:kind]&.to_sym || :ignite,
          guidance: ignite_guidance_for(payload),
          attention_required: lifecycle[:attention_required],
          resumable: lifecycle[:resumable],
          status: payload[:status]&.to_sym,
          policy: ignite_policy.to_h,
          lane: { name: :ignite, queue: ignite_routing[:queue], channel: ignite_routing[:channel] }.compact.freeze,
          routing: ignite_routing,
          assignee: nil,
          queue: ignite_routing[:queue],
          channel: ignite_routing[:channel],
          handoff_count: 0,
          handoff_history: [].freeze,
          action_history_count: timeline.size,
          latest_action_source: latest_action_event&.dig(:source),
          latest_action_actor: latest_action_payload[:actor],
          latest_action_origin: latest_action_payload[:origin],
          latest_action_event: latest_action_event&.dup,
          action_history: timeline.map(&:dup).freeze,
          token: nil,
          phase: payload.dig(:join, :status) || payload.dig(:admission, :status),
          reply_mode: nil,
          mode: payload[:kind]&.to_sym,
          waiting_on: ignite_waiting_on_for(payload),
          source_node: payload.dig(:join, :node_id),
          turn: nil,
          tool_loop_status: nil,
          graph: nil,
          execution_id: nil,
          source: :ignite,
          note: nil,
          combined_state: :ignition,
          lifecycle: lifecycle,
          has_session: false,
          has_inbox_item: false,
          session: nil,
          inbox_item: nil,
          ignition_target: payload.dup,
          ignition_timeline: timeline.map(&:dup).freeze
        }.freeze
      end

      def build_operator_lifecycle_contract(record_kind:, status:, combined_state:, policy:, attention_required:, resumable:, has_inbox_item:, history_count:)
        resolved_policy =
          if policy.is_a?(Igniter::App::Operator::Policy)
            policy
          elsif policy
            Igniter::App::Operator::Policy.from_h(policy)
          end

        actionable =
          if record_kind.to_sym == :orchestration
            has_inbox_item && !Igniter::App::Orchestration::Inbox::RESOLVED_STATUSES.include?(status&.to_sym)
          else
            resolved_policy && !Igniter::App::Operator::LifecycleContract::TERMINAL_STATUSES.include?(status&.to_sym)
          end

        Igniter::App::Operator::LifecycleContract.new(
          record_kind: record_kind,
          status: status,
          combined_state: combined_state,
          default_operation: resolved_policy&.default_operation,
          allowed_operations: resolved_policy&.allowed_operations || [],
          runtime_completion: resolved_policy&.runtime_completion,
          attention_required: attention_required,
          resumable: resumable,
          actionable: actionable,
          history_count: history_count
        ).to_h
      end

      def operator_runtime_overview(query)
        runtime_query = query.with_session
        records = runtime_query.to_a
        waiting_on = Hash.new(0)
        active_nodes = []

        records.each do |record|
          waiting_value = record[:waiting_on]
          waiting_on[waiting_value] += 1 if waiting_value
          active_nodes << {
            id: record[:id],
            node: record[:node],
            session_lifecycle_state: record[:session_lifecycle_state],
            ownership: record[:ownership],
            routing_mode: record[:routing_mode],
            session_policy: record[:session_policy],
            tool_loop_policy: record[:tool_loop_policy],
            finalizer: record[:finalizer],
            agent_result_contract: record[:agent_result_contract],
            interaction_contract: record[:interaction_contract],
            tool_loop_status: record[:tool_loop_status],
            tool_runtime: record[:tool_runtime],
            waiting_on: waiting_value,
            continuable: record[:continuable],
            routed: record[:routed]
          }.freeze
        end

        {
          total_sessions: records.size,
          interactive_sessions: runtime_query.interactive.count,
          terminal_sessions: runtime_query.terminal.count,
          continuable_sessions: runtime_query.continuable.count,
          routed_sessions: runtime_query.routed.count,
          by_ownership: runtime_query.facet(:ownership),
          by_routing_mode: runtime_query.facet(:routing_mode),
          by_session_lifecycle_state: runtime_query.facet(:session_lifecycle_state),
          by_session_policy: runtime_query.facet(:session_policy),
          by_tool_loop_policy: runtime_query.facet(:tool_loop_policy),
          by_finalizer: runtime_query.facet(:finalizer),
          by_tool_loop_status: runtime_query.facet(:tool_loop_status),
          tool_runtime_status: runtime_query.facet(:tool_loop_status),
          by_phase: runtime_query.facet(:phase),
          by_reply_mode: runtime_query.facet(:reply_mode),
          by_waiting_on: waiting_on.freeze,
          active_nodes: active_nodes.first(10).freeze
        }.freeze
      end

      def credential_audit_overview(limit: 20, filters: nil, order_by: nil, direction: :asc)
        resolved_stack = stack_class
        return nil unless resolved_stack

        resolved_stack.credential_history(
          limit: limit,
          filters: filters,
          order_by: order_by,
          direction: direction
        ).merge(
          app: name,
          stack: resolved_stack.name || "anonymous"
        ).freeze
      end

      def ignite_policy_for(payload)
        status = payload[:status]&.to_sym
        allowed_operations =
          case status
          when :awaiting_approval, :awaiting_admission_approval
            %i[approve dismiss]
          when :detached
            %i[retry teardown dismiss]
          when :torn_down
            %i[dismiss]
          when :bootstrapped, :awaiting_join, :joined
            %i[complete detach teardown dismiss]
          else
            %i[retry detach teardown dismiss]
          end

        operation_aliases =
          case status
          when :awaiting_approval, :awaiting_admission_approval
            {}.freeze
          when :detached
            { retry_bootstrap: :retry, reignite: :retry }.freeze
          when :bootstrapped, :awaiting_join, :joined
            { reconcile_join: :complete }.freeze
          else
            { retry_bootstrap: :retry }.freeze
          end

        operation_lifecycle =
          case status
          when :awaiting_approval, :awaiting_admission_approval
            { approve: :resolve, dismiss: :dismiss }.freeze
          when :detached
            { retry: :retry, teardown: :dismiss, dismiss: :dismiss }.freeze
          when :torn_down
            { dismiss: :dismiss }.freeze
          when :bootstrapped, :awaiting_join, :joined
            { complete: :resolve, detach: :dismiss, teardown: :dismiss, dismiss: :dismiss }.freeze
          else
            { retry: :retry, detach: :dismiss, teardown: :dismiss, dismiss: :dismiss }.freeze
          end

        execution_operations =
          case status
          when :awaiting_approval, :awaiting_admission_approval
            { approve: :approve, dismiss: :dismiss }.freeze
          when :detached
            { retry: :reignite, teardown: :teardown, dismiss: :dismiss }.freeze
          when :torn_down
            { dismiss: :dismiss }.freeze
          when :bootstrapped, :awaiting_join, :joined
            { complete: :reconcile_join, detach: :detach, teardown: :teardown, dismiss: :dismiss }.freeze
          else
            { retry: :retry_bootstrap, detach: :detach, teardown: :teardown, dismiss: :dismiss }.freeze
          end

        Igniter::App::Operator::Policy.new(
          name: ignite_policy_name_for(status),
          default_operation: allowed_operations.first,
          allowed_operations: allowed_operations.freeze,
          lifecycle_operations: operation_lifecycle.values.uniq.freeze,
          operation_aliases: operation_aliases,
          operation_lifecycle: operation_lifecycle,
          execution_operations: execution_operations,
          default_routing: { queue: "ignite" }.freeze,
          runtime_completion: ignite_runtime_completion_for(status),
          description: ignite_policy_description_for(status)
        )
      end

      def ignite_policy_name_for(status)
        case status
        when :awaiting_approval, :awaiting_admission_approval
          :ignite_approval
        when :detached
          :ignite_detached
        when :torn_down
          :ignite_torn_down
        when :bootstrapped, :awaiting_join, :joined
          :ignite_join
        else
          :ignite_bootstrap
        end
      end

      def ignite_runtime_completion_for(status)
        case status
        when :awaiting_approval, :awaiting_admission_approval
          :approval_required
        when :joined
          :complete
        when :torn_down
          :complete
        else
          :external
        end
      end

      def ignite_policy_description_for(status)
        case status
        when :awaiting_approval, :awaiting_admission_approval
          "ignite target is waiting for explicit approval before bootstrap can continue"
        when :detached
          "ignite target is detached from the active cluster and can be ignited again"
        when :torn_down
          "ignite target was intentionally torn down and remains as terminal lifecycle history"
        when :joined
          "ignite target completed bootstrap, joined the cluster, and may now be detached"
        when :bootstrapped, :awaiting_join
          "ignite target finished bootstrap, is waiting for runtime join confirmation, and may be detached"
        when :prepared, :admitted
          "ignite target is prepared for runtime start and join confirmation, and may be detached"
        when :deferred, :blocked, :failed
          "ignite target is in bootstrap lifecycle and may need retry or dismissal"
        else
          "ignite target lifecycle managed through the unified operator surface"
        end
      end

      def ignite_operator_event?(timeline_event)
        return false unless timeline_event

        type = timeline_event[:type]&.to_s
        return true if type&.start_with?("ignition_operator_")

        payload = timeline_event[:payload] || {}
        payload.key?(:actor) || payload.key?(:origin) || payload.key?(:operation)
      end

      def ignite_attention_required?(payload)
        %i[awaiting_approval awaiting_admission_approval blocked failed deferred awaiting_join bootstrapped].include?(payload[:status]&.to_sym)
      end

      def ignite_resumable?(payload)
        %i[awaiting_approval awaiting_admission_approval deferred awaiting_join bootstrapped prepared admitted detached].include?(payload[:status]&.to_sym)
      end

      def ignite_waiting_on_for(payload)
        join_status = payload.dig(:join, :status)&.to_sym
        admission_status = payload.dig(:admission, :status)&.to_sym

        return :join if %i[pending_bootstrap pending_runtime_boot awaiting_join].include?(join_status)
        return :admission if %i[awaiting_approval blocked_by_admission].include?(admission_status)

        nil
      end

      def ignite_guidance_for(payload)
        case payload[:status]&.to_sym
        when :awaiting_approval, :awaiting_admission_approval
          "Awaiting ignition approval"
        when :deferred
          "Remote bootstrap is pending"
        when :detached
          "Ignition target is detached and can be ignited again"
        when :torn_down
          "Ignition target was torn down"
        when :bootstrapped, :awaiting_join
          "Waiting for runtime join confirmation"
        when :joined
          "Ignited node joined the cluster"
        when :prepared, :admitted
          "Ignition target is prepared for runtime start"
        when :blocked
          "Ignition target is blocked"
        else
          "Ignition target lifecycle"
        end
      end

      def ignite_operator_options(payload, operation:)
        options = { approved: true }
        mesh = default_ignite_mesh
        admission_status = payload.dig(:admission, :status)&.to_sym
        admitted_statuses = %i[admitted implicit_local implicit_remote]

        if mesh && payload.dig(:admission, :required) && !admitted_statuses.include?(admission_status)
          options[:mesh] = mesh
          options[:request_admission] = true
          options[:approve_pending_admission] = true if operation == :approve
        end

        options[:bootstrap_remote] = true if payload[:kind]&.to_sym == :ssh_server
        options
      end

      def normalize_ignite_operator_audit(audit)
        payload = (audit || {}).dup
        payload[:source] = (payload[:source] || :operator_action_api).to_sym
        payload[:origin] = payload[:origin]&.to_sym if payload[:origin]
        payload
      end

      def operator_dispatcher
        @operator_dispatcher ||= Igniter::App::Operator::Dispatcher.new
      end

      def default_ignite_mesh
        return Igniter::Cluster::Mesh if defined?(Igniter::Cluster::Mesh)

        nil
      end

      def merged_orchestration_runtime_overview(execution)
        overview = orchestration_runtime_overview_builder(execution).overview

        {
          summary: overview[:summary],
          results: overview[:results],
          transitions: Orchestration::RuntimeQueryOverviewBuilder.build(
            query: overview[:transition_query],
            filters: {},
            order_by: :timestamp,
            direction: :asc,
            limit: 20
          ),
          events: Orchestration::RuntimeQueryOverviewBuilder.build(
            query: overview[:event_query],
            filters: {},
            order_by: nil,
            direction: :asc,
            limit: 20
          ),
          records: overview[:records],
          timeline: overview[:timeline],
          combined_timeline: overview[:combined_timeline]
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
          metadata: {
            runtime_resumed: true,
            runtime_resume_mode: :store,
            resolved_execution_id: item[:execution_id],
            resolved_graph: item[:graph],
            resumed_token: item[:token],
            resumed_node: item[:node]
          }.freeze,
          execution: resumed.execution
        }.freeze
      end

      def augment_orchestration_runtime_result(item, execution:)
        return item unless execution

        runtime_result = orchestration_runtime_result_for(item, execution)
        item.merge(runtime_result).freeze
      end

      def augment_orchestration_action_result(item, requested_operation:, handled_operation:,
                                             handled_lifecycle_operation:, handled_execution_operation:,
                                             handled_policy:, note:, audit:, handled_lane: nil,
                                             handled_queue: nil, handled_channel: nil,
                                             handled_handler_queue: nil, handled_assignee: nil)
        return item unless item

        action_result = Orchestration::ActionResultBuilder.build(
          item: item,
          requested_operation: requested_operation,
          handled_operation: handled_operation,
          handled_lifecycle_operation: handled_lifecycle_operation,
          handled_execution_operation: handled_execution_operation,
          handled_policy: handled_policy,
          handled_lane: handled_lane,
          handled_queue: handled_queue,
          handled_channel: handled_channel,
          handled_handler_queue: handled_handler_queue,
          handled_assignee: handled_assignee,
          note: note,
          audit: audit
        )

        item.merge(orchestration_action_result: action_result).freeze
      end

      def orchestration_runtime_result_for(item, execution)
        overview = merged_orchestration_runtime_overview(execution)
        record = Array(overview[:records]).find do |entry|
          entry[:id].to_s == item[:id].to_s || entry[:node].to_sym == item[:node].to_sym
        end
        record ||= orchestration_runtime_overview_builder(execution).fallback_record_for(item)

        Orchestration::RuntimeResultBuilder.build(
          summary: overview[:summary],
          record: record
        )
      end

      def orchestration_runtime_overview_builder(execution)
        graph = execution.compiled_graph.name
        execution_id = execution.events.execution_id
        inbox_items = orchestration_inbox.items.select do |item|
          operator_item_matches_execution?(item, graph: graph, execution_id: execution_id)
        end

        Orchestration::RuntimeOverviewBuilder.new(
          execution: execution,
          inbox_items: inbox_items
        )
      end

      def canonical_orchestration_audit(audit, requested_operation:, lifecycle_operation:, execution_operation:)
        payload = (audit || {}).dup
        payload[:requested_operation] ||= requested_operation
        payload[:lifecycle_operation] ||= lifecycle_operation
        payload[:execution_operation] ||= execution_operation
        payload
      end

      def operator_target_for_execution(graph:, execution_id:, store: nil)
        contract_class = registered_contract_class_for_graph(graph)
        raise ArgumentError, "no registered contract class found for graph #{graph.inspect}" unless contract_class

        contract_class.restore_from_store(execution_id, store: store || Igniter.execution_store)
      end

      def apply_operator_query_options(query, filters:, order_by:, direction:)
        applied = query

        filters.to_h.each do |key, value|
          next if blank_operator_filter_value?(value)

          applied =
            case key.to_sym
            when :actionable
              value ? applied.actionable : applied
            when :attention_required, :resumable, :with_session, :with_inbox_item,
                 :interactive, :terminal, :continuable, :routed
              applied.public_send(key.to_sym, value)
            when :with_token
              value ? applied.with_token : applied
            when :handed_off
              value ? applied.handed_off : applied
            when :id, :record_kind, :status, :action, :node, :combined_state, :interaction, :reason, :policy,
                 :lane, :queue, :channel, :assignee, :graph, :execution_id, :phase,
                 :reply_mode, :mode, :tool_loop_status, :ownership, :session_lifecycle_state, :latest_action_actor,
                 :latest_action_origin, :latest_action_source
              applied.public_send(key.to_sym, *Array(value))
            else
              raise ArgumentError, "unsupported operator filter #{key.inspect}"
            end
        end

        return applied if order_by.nil? || order_by.to_s.empty?

        applied.order_by(order_by.to_sym, direction: direction.to_sym)
      end

      def operator_query_metadata(filters:, order_by:, direction:, limit:)
        {
          filters: compact_operator_filters(filters),
          order_by: order_by&.to_sym,
          direction: direction&.to_sym,
          limit: limit
        }.freeze
      end

      def apply_orchestration_runtime_event_query_options(query, filters:, order_by:, direction:)
        applied = query

        filters.to_h.each do |key, value|
          next if blank_operator_filter_value?(value)

          applied =
            case key.to_sym
            when :terminal
              applied.terminal(value)
            when :node, :event, :event_class, :source, :status,
                 :actor, :origin, :requested_operation,
                 :lifecycle_operation, :execution_operation
              applied.public_send(key.to_sym, *Array(value))
            else
              raise ArgumentError, "unsupported orchestration runtime event filter #{key.inspect}"
            end
        end

        return applied if order_by.nil? || order_by.to_s.empty?

        applied.order_by(order_by.to_sym, direction: direction.to_sym)
      end

      def apply_orchestration_runtime_transition_query_options(query, filters:, order_by:, direction:)
        applied = query

        filters.to_h.each do |key, value|
          next if blank_operator_filter_value?(value)

          applied =
            case key.to_sym
            when :terminal
              applied.terminal(value)
            when :id, :node, :action, :interaction, :state, :state_class, :event, :status,
                 :phase, :waiting_on, :source_status
              applied.public_send(key.to_sym, *Array(value))
            else
              raise ArgumentError, "unsupported orchestration runtime transition filter #{key.inspect}"
            end
        end

        return applied if order_by.nil? || order_by.to_s.empty?

        applied.order_by(order_by.to_sym, direction: direction.to_sym)
      end

      def orchestration_runtime_record_for(target, id:, node:)
        overview = orchestration_runtime_overview(target)
        return nil unless overview

        records = Array(overview[:records])
        if id
          records.find { |record| record[:id].to_s == id.to_s }
        elsif node
          records.find { |record| record[:node].to_s == node.to_s }
        end
      end

      def operator_record_event_overview(execution, query:, filters:, event_filters:, event_order_by:, event_direction:, event_limit:)
        return nil unless execution

        selected_id = filters.to_h[:id]
        selected_node = filters.to_h[:node] if selected_id.nil?
        records = query.limit(2).to_a
        return nil unless records.size == 1

        record = records.first
        return nil unless record[:record_kind] == :orchestration

        orchestration_runtime_record_event_overview(
          execution,
          id: selected_id || record[:id],
          node: selected_node || record[:node],
          filters: event_filters,
          order_by: event_order_by,
          direction: event_direction,
          limit: event_limit
        )
      end

      def compact_operator_filters(filters)
        filters.to_h.each_with_object({}) do |(key, value), memo|
          next if blank_operator_filter_value?(value)

          memo[key.to_sym] = value
        end.freeze
      end

      def blank_operator_filter_value?(value)
        return true if value.nil?
        return value.empty? if value.respond_to?(:empty?)

        false
      end

      def callable_accepts_keyword?(callable, keyword)
        parameters =
          if callable.respond_to?(:parameters)
            callable.parameters
          elsif callable.respond_to?(:method)
            callable.method(:call).parameters
          else
            []
          end

        parameters.any? do |kind, name|
          kind == :keyrest || (kind == :key && name == keyword)
        end
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
