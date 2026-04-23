# frozen_string_literal: true

require "fileutils"
require "irb"
require "optparse"
require "securerandom"
require "shellwords"
require "stringio"
require "time"
require "yaml"
require "igniter/ignite"

module Igniter
  # Root coordinator for mounted multi-app stacks.
  #
  # A stack owns:
  # - shared load paths for repo-level support code
  # - a registry of named apps under apps/<name>
  # - a single mounted runtime rooted in stack.rb + stack.yml
  # - optional local node profiles for multi-instance boot
  #
  # Apps are pluggable mounted packages. Nodes are launch profiles of the same
  # stack. The stack itself owns the server/runtime boundary.
  class Stack
    UNDEFINED_IGNITION_STORE = Object.new
    UNDEFINED_CREDENTIAL_STORE = Object.new
    AppDefinition = Struct.new(:name, :path, :klass, :root, :access_to, keyword_init: true)
    ConsoleContext = Struct.new(
      :stack_class,
      :root_app_name,
      :root_app_class,
      :app_name,
      :app_class,
      :node_name,
      :node_profile,
      :deployment,
      :runtime,
      :mounts,
      :stack_settings,
      :mesh,
      keyword_init: true
    )
    SERVICE_MOUNT_METHODS = %w[GET POST PUT PATCH DELETE OPTIONS HEAD].freeze

    class << self
      def root_dir(path = nil)
        return @root_dir unless path

        @root_dir = File.expand_path(path)
        reset_stack_state!
      end

      def shared_lib_path(path)
        @shared_lib_paths << path
      end

      def stack_file(path = nil)
        return @stack_yml_path unless path

        @stack_yml_path = path
        reset_stack_state!
      end

      def config_file(path = nil)
        stack_file(path)
      end

      def environment(name = nil)
        return resolved_environment unless name

        @environment_name = name.to_s
        reset_stack_state!
      end

      def environment_file(path = nil)
        return @environment_yml_path unless path

        @environment_yml_path = path
        reset_stack_state!
      end

      def compose_file(path = nil)
        return @compose_yml_path unless path

        @compose_yml_path = path
      end

      def ignition_store(store = UNDEFINED_IGNITION_STORE)
        return (@ignition_store ||= default_ignition_store) if store.equal?(UNDEFINED_IGNITION_STORE)

        @ignition_store = store
        reload_ignition_trail!
      end

      def ignition_log(path, retain_events: nil, archive: nil)
        ignition_store(
          Igniter::Ignite::Stores::FileStore.new(
            path: resolve_path(path),
            max_events: retain_events,
            archive_path: archive ? resolve_path(archive) : nil
          )
        )
      end

      def credential_store(store = UNDEFINED_CREDENTIAL_STORE)
        return (@credential_store ||= default_credential_store) if store.equal?(UNDEFINED_CREDENTIAL_STORE)

        @credential_store = store
        reload_credential_trail!
      end

      def credential_log(path, retain_events: nil, archive: nil)
        credential_store(
          Igniter::App::Credentials::Stores::FileStore.new(
            path: resolve_path(path),
            max_events: retain_events,
            archive_path: archive ? resolve_path(archive) : nil
          )
        )
      end

      def procfile_dev_file(path = nil)
        return @procfile_dev_path unless path

        @procfile_dev_path = path
      end

      def app(name = nil, path: nil, klass: nil, default: false, access_to: [])
        if path || klass
          raise ArgumentError, "stack app registration requires both path: and klass:" unless path && klass

          definition = AppDefinition.new(
            name: name.to_sym,
            path: path.to_s,
            klass: klass,
            root: default,
            access_to: Array(access_to).map(&:to_sym)
          )

          @apps[definition.name] = definition
          definition.klass.bind_stack_context(
            stack_class: self,
            app_name: definition.name,
            access_to: definition.access_to
          ) if definition.klass.respond_to?(:bind_stack_context)
          @root_app = definition.name if default
          return definition.klass
        end

        app_class(name)
      end

      def mount(name, at:)
        app_definition(name)
        @mounts[normalize_app_name(name)] = normalize_mount_path(at)
      end

      def mounts
        @mounts.each_with_object({}) do |(name, path), result|
          result[name] = path.dup
        end
      end

      def app_names
        @apps.keys
      end

      def interface(name)
        @apps.each_value do |definition|
          callable = definition.klass.exposed_interfaces[name.to_sym]
          return callable if callable
        end
        raise KeyError, "No registered app exposes interface #{name.inspect}"
      end

      def interfaces
        @apps.each_value.each_with_object({}) do |definition, hash|
          definition.klass.exposed_interfaces.each { |iface_name, callable| hash[iface_name] = callable }
        end
      end

      def root_app
        normalize_optional_name(stack_settings.dig("stack", "root_app")) ||
          @root_app ||
          @apps.keys.first
      end

      def default_node
        return root_app unless nodes_defined?

        configured = normalize_optional_name(stack_settings.dig("stack", "default_node"))
        return configured if configured && node_names.include?(configured)

        fallback = normalize_optional_name(ENV["IGNITER_NODE"])
        return fallback if fallback && node_names.include?(fallback)

        node_names.first
      end

      def app_definition(name = nil)
        requested = normalize_app_name(name || root_app)
        @apps.fetch(requested) do
          available = @apps.keys.map(&:inspect).join(", ")
          raise ArgumentError, "Unknown stack app #{requested.inspect} (available: #{available})"
        end
      end

      def app_class(name = nil)
        setup_load_paths!
        app_definition(resolve_app_name(name)).klass
      end

      def start(name = nil, environment: nil)
        self.environment(environment) if environment
        return start_node(default_node) if use_stack_runtime_by_default?(name)

        app_class(resolve_app_name(name)).start
      end

      def rack_app(name = nil, environment: nil)
        self.environment(environment) if environment
        return rack_node(default_node) if use_stack_runtime_by_default?(name)

        app_class(resolve_app_name(name)).rack_app
      end

      def node_names
        stack_settings.fetch("nodes", {}).keys.map { |node_name| normalize_app_name(node_name) }
      end

      def node_profile(name = nil)
        node_name = normalize_app_name(name || default_node)
        stack_settings.fetch("nodes", {}).fetch(node_name.to_s) do
          available = node_names.map(&:inspect).join(", ")
          raise ArgumentError, "Unknown stack node #{node_name.inspect} (available: #{available})"
        end
      end

      def start_node(name = nil, environment: nil)
        self.environment(environment) if environment

        runtime = build_stack_runtime(nodes_defined? ? resolve_node_name(name) : nil)
        schedulers = start_stack_schedulers(runtime)
        at_exit { stop_stack_schedulers(schedulers) }
        runtime.fetch(:root_app_class).host_adapter.start(config: runtime.fetch(:root_config))
      end

      def rack_node(name = nil, environment: nil)
        self.environment(environment) if environment

        runtime = build_stack_runtime(nodes_defined? ? resolve_node_name(name) : nil)
        start_stack_schedulers(runtime)
        runtime.fetch(:root_app_class).host_adapter.rack_app(config: runtime.fetch(:root_config))
      end

      def console_context(name = nil, node: nil, environment: nil)
        self.environment(environment) if environment

        selected_app_name = resolve_app_name(name)
        selected_node_name = nodes_defined? ? resolve_node_name(node) : nil
        selected_runtime = build_stack_runtime(selected_node_name)

        ConsoleContext.new(
          stack_class: self,
          root_app_name: root_app,
          root_app_class: app_class(root_app),
          app_name: selected_app_name,
          app_class: app_class(selected_app_name),
          node_name: selected_node_name,
          node_profile: selected_node_name ? node_profile(selected_node_name) : nil,
          deployment: deployment_snapshot,
          runtime: selected_runtime,
          mounts: mounts,
          stack_settings: stack_settings,
          mesh: defined?(Igniter::Cluster::Mesh) ? Igniter::Cluster::Mesh : nil
        )
      end

      def console_binding(name = nil, node: nil, environment: nil)
        context = console_context(name, node: node, environment: environment)
        console_locals_binding(context)
      end

      def start_console(name = nil, node: nil, environment: nil, output: $stdout, evaluate: nil)
        context = console_context(name, node: node, environment: environment)
        output.puts(console_banner(context))
        bind = console_locals_binding(context)
        return evaluate_console(bind, evaluate, output) if evaluate

        bind.irb
      end

      def start_cli(argv = ARGV)
        options = parse_cli_options(argv.dup)
        target = options.delete(:target)

        if options[:print_procfile_dev]
          self.environment(options[:environment]) if options[:environment]
          puts procfile_dev
          return
        end

        if options[:write_procfile_dev]
          self.environment(options[:environment]) if options[:environment]
          write_procfile_dev(options[:write_procfile_dev] == true ? nil : options[:write_procfile_dev])
          return
        end

        if options[:dev]
          start_dev(environment: options[:environment])
          return
        end

        if options[:print_compose]
          self.environment(options[:environment]) if options[:environment]
          puts compose_yaml
          return
        end

        if options[:write_compose]
          self.environment(options[:environment]) if options[:environment]
          write_compose(options[:write_compose] == true ? nil : options[:write_compose])
          return
        end

        if options[:console]
          start_console(
            target,
            node: options[:node],
            environment: options[:environment],
            evaluate: options[:evaluate]
          )
          return
        end

        if options[:node]
          start_node(options[:node], environment: options[:environment])
        else
          start(target, environment: options[:environment])
        end
      end

      def stack_settings(reload: false)
        @stack_settings = nil if reload
        @ignition_plan = nil if reload
        @stack_settings ||= deep_merge(
          load_yaml(resolve_path(@stack_yml_path)),
          environment_settings
        )
      end

      def ignite_settings
        stack_settings.fetch("ignite", {})
      end

      def ignition_plan(reload: false)
        @ignition_plan = nil if reload
        @ignition_plan ||= build_ignition_plan
      end

      def ignite(plan: ignition_plan, approved: false, timeout: 5, mesh: nil, request_admission: false, approve_pending_admission: false, bootstrap_remote: false, bootstrap_timeout: 30, session_factory: nil, bootstrapper_factory: nil, await_join: nil, join_timeout: 5, join_poll_interval: 0.1, persist: true)
        agent = Igniter::Ignite::IgnitionAgent.start
        report = agent.call(
          :execute,
          {
            plan: plan,
            runtime_units: runtime_units_snapshot,
            approved: approved,
            mesh: mesh,
            request_admission: request_admission,
            approve_pending_admission: approve_pending_admission,
            bootstrap_remote: bootstrap_remote,
            bootstrap_timeout: bootstrap_timeout,
            session_factory: session_factory,
            bootstrapper_factory: bootstrapper_factory,
            root_dir: @root_dir
          },
          timeout: timeout
        )
        unless should_await_ignite_join?(report, mesh: mesh, await_join: await_join, bootstrap_remote: bootstrap_remote)
          persist_ignition_report!(report, source: :ignite) if persist
          return report
        end

        report = await_ignite_join(
          report: report,
          mesh: mesh,
          timeout: join_timeout,
          poll_interval: join_poll_interval
        )
        persist_ignition_report!(report, source: :ignite) if persist
        report
      ensure
        agent&.stop(timeout: 1)
      end

      def ignition_report(**options)
        ignite(**options, persist: false)
      end

      def confirm_ignite_join(report:, target_id:, url:, mesh: nil, metadata: {}, timeout: 5, persist: true)
        agent = Igniter::Ignite::IgnitionAgent.start
        updated = agent.call(
          :confirm_join,
          {
            report: report,
            target_id: target_id,
            url: url,
            mesh: mesh,
            metadata: metadata
          },
          timeout: timeout
        )
        persist_ignition_report!(updated, source: :confirm_join) if persist
        updated
      ensure
        agent&.stop(timeout: 1)
      end

      def reconcile_ignite(report:, mesh:, timeout: 5, persist: true)
        agent = Igniter::Ignite::IgnitionAgent.start
        updated = agent.call(
          :reconcile,
          {
            report: report,
            mesh: mesh
          },
          timeout: timeout
        )
        persist_ignition_report!(updated, source: :reconcile) if persist
        updated
      ensure
        agent&.stop(timeout: 1)
      end

      def detach_ignite_target(report:, target_id:, mesh: nil, metadata: {}, timeout: 5, persist: true, session_factory: nil, decommission_timeout: 30)
        agent = Igniter::Ignite::IgnitionAgent.start
        updated = agent.call(
          :detach,
          {
            report: report,
            target_id: target_id,
            mesh: mesh,
            metadata: metadata,
            root_dir: @root_dir,
            session_factory: session_factory,
            decommission_timeout: decommission_timeout
          },
          timeout: timeout
        )
        persist_ignition_report!(updated, source: :detach) if persist
        updated
      ensure
        agent&.stop(timeout: 1)
      end

      def teardown_ignite_target(report:, target_id:, mesh: nil, metadata: {}, timeout: 5, persist: true, session_factory: nil, decommission_timeout: 30)
        agent = Igniter::Ignite::IgnitionAgent.start
        updated = agent.call(
          :teardown,
          {
            report: report,
            target_id: target_id,
            mesh: mesh,
            metadata: metadata,
            root_dir: @root_dir,
            session_factory: session_factory,
            decommission_timeout: decommission_timeout
          },
          timeout: timeout
        )
        persist_ignition_report!(updated, source: :teardown) if persist
        updated
      ensure
        agent&.stop(timeout: 1)
      end

      def reignite_target(target_id:, timeout: 5, persist: true, **options)
        plan = ignition_plan_for_target(target_id, mode: :expand)
        ignite(plan: plan, timeout: timeout, persist: persist, **options)
      end

      def ignition_trail
        @ignition_trail ||= Igniter::Ignite::Trail.new(store: ignition_store)
      end

      def ignition_history(limit: 10)
        ignition_trail.snapshot(limit: limit)
      end

      def latest_ignition_report
        ignition_trail.latest_report
      end

      def credential_trail
        @credential_trail ||= Igniter::App::Credentials::Trail.new(store: credential_store)
      end

      def credential_history(limit: 10, filters: nil, order_by: nil, direction: :asc)
        credential_trail.snapshot(limit: limit, filters: filters, order_by: order_by, direction: direction)
      end

      def credential_request_history(limit: 10, filters: nil, order_by: nil, direction: :asc)
        credential_trail.lease_request_snapshot(
          limit: limit,
          filters: filters,
          order_by: order_by,
          direction: direction
        )
      end

      def build_credential_lease_request(credential:, target_node:, request_id: nil, requested_scope: :remote, node: nil,
                                         actor: nil, origin: nil, source:, reason: nil,
                                         lease_id: nil, requested_at: Time.now.utc.iso8601, metadata: {})
        Igniter::App::Credentials::LeaseRequest.new(
          credential: credential,
          request_id: request_id || SecureRandom.uuid,
          requested_scope: requested_scope,
          node: node,
          target_node: target_node,
          actor: actor,
          origin: origin,
          source: source,
          reason: reason,
          lease_id: lease_id,
          requested_at: requested_at,
          metadata: metadata
        )
      end

      def request_credential_lease(credential:, target_node:, request_id: nil, requested_scope: :remote, node: nil,
                                   actor: nil, origin: nil, source:, reason: nil, lease_id: nil,
                                   requested_at: Time.now.utc.iso8601, metadata: {})
        request = build_credential_lease_request(
          credential: credential,
          request_id: request_id,
          requested_scope: requested_scope,
          node: node,
          target_node: target_node,
          actor: actor,
          origin: origin,
          source: source,
          reason: reason,
          lease_id: lease_id,
          requested_at: requested_at,
          metadata: metadata
        )

        {
          request: request.to_h,
          policy_allowed: request.policy_allows_request?,
          next_operation: request.policy_allows_request? ? :issue_or_deny : :deny,
          event: record_credential_event(request.request_event)
        }.freeze
      end

      def issue_credential_lease(request, lease_id: SecureRandom.uuid, actor: nil, origin: nil, source: nil, metadata: {}, timestamp: Time.now.utc.iso8601)
        canonical_request = normalize_credential_lease_request(request).with(lease_id: lease_id)

        {
          request: canonical_request.to_h,
          policy_allowed: canonical_request.policy_allows_request?,
          event: record_credential_event(
            canonical_request.issue_event(
              lease_id: lease_id,
              actor: actor,
              origin: origin,
              source: source,
              metadata: metadata,
              timestamp: timestamp
            )
          )
        }.freeze
      end

      def deny_credential_lease(request, reason:, actor: nil, origin: nil, source: nil, metadata: {}, timestamp: Time.now.utc.iso8601)
        canonical_request = normalize_credential_lease_request(request).with(reason: reason)

        {
          request: canonical_request.to_h,
          policy_allowed: canonical_request.policy_allows_request?,
          event: record_credential_event(
            canonical_request.deny_event(
              reason: reason,
              actor: actor,
              origin: origin,
              source: source,
              metadata: metadata,
              timestamp: timestamp
            )
          )
        }.freeze
      end

      def revoke_credential_lease(request, lease_id: nil, reason: nil, actor: nil, origin: nil, source: nil, metadata: {}, timestamp: Time.now.utc.iso8601)
        canonical_request = normalize_credential_lease_request(request)
        resolved_lease_id = lease_id || canonical_request.lease_id

        {
          request: canonical_request.with(lease_id: resolved_lease_id, reason: reason || canonical_request.reason).to_h,
          policy_allowed: canonical_request.policy_allows_request?,
          event: record_credential_event(
            canonical_request.revoke_event(
              lease_id: resolved_lease_id,
              reason: reason,
              actor: actor,
              origin: origin,
              source: source,
              metadata: metadata,
              timestamp: timestamp
            )
          )
        }.freeze
      end

      def record_credential_event(event = nil, **attributes)
        credential_trail.record(event, **attributes)
      end

      def reset_credential_trail!
        credential_trail.clear!
      end

      def reload_credential_trail!
        @credential_trail = Igniter::App::Credentials::Trail.new(store: credential_store)
      end

      def reset_ignition_trail!
        ignition_trail.clear!
      end

      def reload_ignition_trail!
        @ignition_trail = Igniter::Ignite::Trail.new(store: ignition_store)
      end

      def deployment_snapshot
        {
          "stack" => {
            "root_dir" => @root_dir,
            "environment" => resolved_environment,
            "root_app" => root_app.to_s,
            "default_node" => default_node&.to_s,
            "mounts" => stringify_hash(mounts)
          },
          "apps" => app_names.each_with_object({}) do |app_name, result|
            definition = app_definition(app_name)
            app_config = app_deployment(app_name)
            result[app_name.to_s] = app_config.merge(
              "app" => app_name.to_s,
              "path" => definition.path,
              "class_name" => definition.klass.name || definition.klass.inspect,
              "root" => (app_name == root_app)
            )
          end,
          "nodes" => runtime_units_snapshot,
          "ignite" => stringify_nested_keys(ignition_plan.to_h)
        }
      end

      def compose_config
        compose = stack_settings.dig("deploy", "compose") || {}
        volume_name = compose["volume_name"] || "#{stack_slug}_var"
        working_dir = compose["working_dir"]
        build = compose["build"]
        dockerfile = compose["dockerfile"]
        build_context = compose["context"]
        shared_env = stringify_hash(compose["environment"] || {})
        volume_target = compose["volume_target"]

        services = runtime_units_snapshot.each_with_object({}) do |(unit_name, unit_config), result|
          service = {}
          service["build"] = build_config(build_context, dockerfile) if build_context || dockerfile || build
          service["image"] = build if build.is_a?(String)
          service["command"] = unit_config["command"] || default_runtime_command(unit_name)
          service["working_dir"] = working_dir if present?(working_dir)

          env = shared_env.merge(runtime_environment_for_unit(unit_name, unit_config))
          service["environment"] = env unless env.empty?

          port = unit_config["port"]
          service["ports"] = ["#{port}:#{port}"] if unit_config["public"] && port

          depends_on = Array(unit_config["depends_on"]).map(&:to_s)
          service["depends_on"] = depends_on unless depends_on.empty?

          service["volumes"] = ["#{volume_name}:#{volume_target}"] if volume_target
          result[unit_name] = service
        end

        config = { "services" => services }
        config["volumes"] = { volume_name => {} } if volume_target
        config
      end

      def compose_yaml
        YAML.dump(compose_config)
      end

      def write_compose(path = nil)
        target = resolve_path(path || @compose_yml_path)
        FileUtils.mkdir_p(File.dirname(target))
        File.write(target, compose_yaml)
        target
      end

      def dev_services
        runtime_units_snapshot.map do |unit_name, unit_config|
          {
            name: unit_name.to_s,
            command: unit_config["dev_command"] || unit_config["command"] || default_runtime_command(unit_name),
            environment: dev_runtime_environment_for_unit(unit_name, unit_config)
          }
        end
      end

      def procfile_dev
        dev_services.map do |service|
          "#{service.fetch(:name)}: #{shell_command_with_env(service.fetch(:command), service.fetch(:environment))}"
        end.join("\n") + "\n"
      end

      def write_procfile_dev(path = nil)
        target = resolve_path(path || @procfile_dev_path)
        FileUtils.mkdir_p(File.dirname(target))
        File.write(target, procfile_dev)
        target
      end

      def start_dev(environment: nil) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        self.environment(environment) if environment

        services = dev_services
        raise ArgumentError, "No apps registered for stack dev mode" if services.empty?

        log_dir = resolve_dev_log_dir
        FileUtils.mkdir_p(log_dir)
        $stdout.puts("[stack:dev] writing logs to #{relative_to_root(log_dir)}")

        processes = {}
        readers = []
        stopping = false
        exit_status = 0

        stop_all = lambda do |signal|
          next if stopping

          stopping = true
          processes.each_value do |process|
            begin
              Process.kill(signal, process.fetch(:pid))
            rescue Errno::ESRCH
              nil
            end
          end
        end

        previous_int = trap("INT") { stop_all.call("TERM") }
        previous_term = trap("TERM") { stop_all.call("TERM") }

        services.each do |service|
          reader, writer = IO.pipe
          log_path = dev_log_path_for(service.fetch(:name), dir: log_dir)
          pid = Process.spawn(
            service.fetch(:environment),
            service.fetch(:command),
            chdir: @root_dir,
            out: writer,
            err: writer
          )
          writer.close

          processes[pid] = { name: service.fetch(:name), pid: pid, log_path: log_path }
          readers << Thread.new(reader, service.fetch(:name), log_path) do |io, name, path|
            FileUtils.mkdir_p(File.dirname(path))
            File.open(path, "w") do |log|
              log.sync = true
              log.puts("# igniter dev log")
              log.puts("# service=#{name}")
              log.puts("# started_at=#{Time.now.utc.iso8601}")
              log.puts

              io.each_line do |line|
                prefixed = "[#{name}] #{line}"
                $stdout.print(prefixed)
                log.print(prefixed)
              end
            end
          ensure
            io.close unless io.closed?
          end
        end

        until processes.empty?
          pid, status = Process.wait2
          process = processes.delete(pid)
          next unless process

          exit_status = status.exitstatus if status.exitstatus.to_i != 0 && exit_status.zero?

          unless stopping
            warn "[stack:dev] #{process.fetch(:name)} exited with status #{status.exitstatus || "unknown"}"
            stop_all.call("TERM")
          end
        end
      ensure
        processes&.each_value do |process|
          begin
            Process.kill("KILL", process.fetch(:pid))
          rescue Errno::ESRCH
            nil
          end
        end
        readers&.each(&:join)
        trap("INT", previous_int) if previous_int
        trap("TERM", previous_term) if previous_term
        raise SystemExit, exit_status unless exit_status.to_i.zero?
      end

      def setup_load_paths!
        configured_paths = Array(stack_settings.dig("stack", "shared_lib_paths"))
        (@shared_lib_paths + configured_paths).uniq.each do |path|
          full = File.expand_path(path, @root_dir || Dir.pwd)
          $LOAD_PATH.unshift(full) unless $LOAD_PATH.include?(full)
        end
      end

      def inherited(subclass)
        super
        subclass.instance_variable_set(:@root_dir, Dir.pwd)
        subclass.instance_variable_set(:@stack_yml_path, "stack.yml")
        subclass.instance_variable_set(:@environment_name, nil)
        subclass.instance_variable_set(:@environment_yml_path, nil)
        subclass.instance_variable_set(:@compose_yml_path, "config/deploy/compose.yml")
        subclass.instance_variable_set(:@procfile_dev_path, "config/deploy/Procfile.dev")
        subclass.instance_variable_set(:@shared_lib_paths, [])
        subclass.instance_variable_set(:@apps, {})
        subclass.instance_variable_set(:@mounts, {})
        subclass.instance_variable_set(:@root_app, nil)
        subclass.instance_variable_set(:@stack_settings, nil)
        subclass.instance_variable_set(:@environment_settings, nil)
        subclass.instance_variable_set(:@ignition_store, nil)
        subclass.instance_variable_set(:@ignition_trail, nil)
        subclass.instance_variable_set(:@credential_store, nil)
        subclass.instance_variable_set(:@credential_trail, nil)
      end

      private

      def normalize_credential_lease_request(value)
        case value
        when Igniter::App::Credentials::LeaseRequest
          value
        when Hash
          Igniter::App::Credentials::LeaseRequest.from_h(value)
        else
          raise ArgumentError, "request must be a LeaseRequest or Hash"
        end
      end

      def validate_interface_access!
        exposed = interfaces
        @apps.each_value do |definition|
          definition.access_to.each do |required|
            next if exposed.key?(required)

            raise ArgumentError,
              "App #{definition.name.inspect} declares access_to #{required.inspect} " \
              "but no registered app exposes it. Known interfaces: #{exposed.keys.inspect}"
          end
        end
      end

      def parse_cli_options(argv)
        options = {}

        parser = OptionParser.new do |opts|
          opts.banner = <<~TEXT
            Usage: stack.rb [app] [options]

            Stack-first runtime surface:
              stack.rb                 Start the mounted stack runtime
              stack.rb dashboard       Start one app directly

            Canonical wrappers:
              bin/start                Start the mounted stack runtime
              bin/console              Open the igniter console
              bin/dev                  Start all local node profiles
          TEXT

          opts.separator("")
          opts.separator("Common flows:")
          opts.separator("    --node NAME       Boot one named node profile")
          opts.separator("    --console         Open the igniter console")
          opts.separator("    --dev             Start all local node profiles with prefixed logs (+ var/log/dev/*.log)")
          opts.separator("    --print-compose   Render compose config from stack nodes")
          opts.separator("    --print-procfile-dev  Render Procfile.dev from stack nodes")
          opts.separator("")
          opts.separator("Examples:")
          opts.separator("    stack.rb")
          opts.separator("    stack.rb dashboard")
          opts.separator("    stack.rb --node seed")
          opts.separator("    stack.rb --console --node seed")
          opts.separator("    stack.rb --console --node seed --eval 'context.node_name'")
          opts.separator("    stack.rb --dev")
          opts.separator("")

          opts.on("--app NAME", "Start a specific app by name") do |value|
            options[:target] = value
          end

          opts.on("--node NAME", "Start a named local node profile") do |value|
            options[:node] = value
          end

          opts.on("--console", "Start an interactive stack console (same surface as bin/console)") do
            options[:console] = true
          end

          opts.on("-e", "--eval CODE", "Evaluate Ruby inside the stack console and exit") do |value|
            options[:evaluate] = value
          end

          opts.on("--env NAME", "Use config/environments/<NAME>.yml overlay") do |value|
            options[:environment] = value
          end

          opts.on("--print-compose", "Print a Docker Compose config generated from stack nodes") do
            options[:print_compose] = true
          end

          opts.on("--write-compose [PATH]", "Write a Docker Compose config generated from stack nodes") do |value|
            options[:write_compose] = value || true
          end

          opts.on("--dev", "Start stack nodes locally with prefixed logs and file logs") do
            options[:dev] = true
          end

          opts.on("--print-procfile-dev", "Print a Procfile.dev generated from stack nodes") do
            options[:print_procfile_dev] = true
          end

          opts.on("--write-procfile-dev [PATH]", "Write a Procfile.dev generated from stack nodes") do |value|
            options[:write_procfile_dev] = value || true
          end
        end

        parser.parse!(argv)
        options[:target] ||= argv.shift
        options
      end

      def resolve_app_name(name = nil)
        return normalize_app_name(name) if name && app_names.include?(normalize_app_name(name))

        normalize_app_name(name || root_app)
      end

      def resolve_node_name(name = nil)
        raise ArgumentError, "No stack nodes configured" unless nodes_defined?

        desired = normalize_app_name(name || default_node)
        return desired if node_names.include?(desired)

        available = node_names.map(&:inspect).join(", ")
        raise ArgumentError, "Unknown stack node #{desired.inspect} (available: #{available})"
      end

      def normalize_app_name(name)
        name.to_sym
      end

      def normalize_optional_name(name)
        value = name.to_s.strip
        value.empty? ? nil : value.to_sym
      end

      def nodes_defined?
        !stack_settings.fetch("nodes", {}).empty?
      end

      def mounts_defined?
        !@mounts.empty?
      end

      def resolved_environment
        configured = @environment_name.to_s.strip
        return configured unless configured.empty?

        ENV["IGNITER_ENV"].to_s.strip
      end

      def environment_settings
        @environment_settings ||= begin
          env_name = resolved_environment
          return {} if env_name.empty?

          path = @environment_yml_path || File.join("config", "environments", "#{env_name}.yml")
          load_yaml(resolve_path(path))
        end
      end

      def app_deployment(name = nil)
        app_name = normalize_app_name(name || root_app)
        shared = stack_settings.fetch("shared", {})
        app = stack_settings.fetch("apps", {}).fetch(app_name.to_s, {})
        deep_merge(shared, app)
      end

      def runtime_units_snapshot
        if nodes_defined?
          node_names.each_with_object({}) do |node_name, result|
            result[node_name.to_s] = node_deployment(node_name).merge(
              "node" => node_name.to_s,
              "default" => (node_name == default_node)
            )
          end
        else
          standalone_runtime_units_snapshot
        end
      end

      def standalone_runtime_units_snapshot
        root_name = root_app.to_s
        units = {
          root_name => standalone_runtime_deployment(root_name).merge(
            "node" => root_name,
            "default" => true
          )
        }

        ignition_plan.local_replica_intents.each do |intent|
          target = intent.target
          units[target.id] = local_replica_runtime_deployment(target, intent).merge(
            "node" => target.id,
            "default" => false
          )
        end

        units
      end

      def standalone_runtime_deployment(name)
        {
          "apps" => app_names.map(&:to_s),
          "root_app" => root_app.to_s,
          "mounts" => stringify_hash(mounts),
          "host" => stack_settings.dig("server", "host"),
          "port" => stack_settings.dig("server", "port"),
          "public" => true,
          "command" => "bundle exec ruby stack.rb",
          "role" => name.to_s,
          "environment" => shared_runtime_environment
        }
      end

      def local_replica_runtime_deployment(target, intent)
        base = standalone_runtime_deployment(root_app.to_s)
        server_settings = target.server_settings

        base.merge(
          "host" => server_settings["host"] || base["host"],
          "port" => server_settings["port"] || base["port"],
          "environment" => base.fetch("environment", {}).merge(
            "IGNITER_NODE" => target.id,
            "IGNITER_IGNITE_REPLICA" => "true",
            "IGNITER_IGNITE_TARGET" => target.id,
            "IGNITER_IGNITE_INTENT" => intent.id
          ),
          "ignite" => {
            "intent_id" => intent.id,
            "target_id" => target.id,
            "kind" => target.kind.to_s
          }
        )
      end

      def node_deployment(name = nil)
        node_name = normalize_app_name(name || default_node)
        profile = deep_merge(stack_settings.fetch("shared", {}), node_profile(node_name))
        configured_mounts = stringify_hash(profile.fetch("mounts", {}))

        {
          "apps" => app_names.map(&:to_s),
          "root_app" => root_app.to_s,
          "mounts" => configured_mounts.empty? ? stringify_hash(mounts) : configured_mounts,
          "host" => profile["host"] || stack_settings.dig("server", "host"),
          "port" => profile["port"] || profile.dig("http", "port") || stack_settings.dig("server", "port"),
          "public" => profile.key?("public") ? profile["public"] : true,
          "command" => profile["command"] || "bundle exec ruby stack.rb --node #{node_name}",
          "role" => profile["role"] || node_name.to_s,
          "depends_on" => Array(profile["depends_on"]).map(&:to_s),
          "environment" => shared_runtime_environment.merge(stringify_hash(profile.fetch("environment", {})))
        }
      end

      def build_stack_runtime(node_name = nil)
        validate_interface_access!
        selected_node = nodes_defined? ? resolve_node_name(node_name) : nil
        root_app_name = root_app
        root_app_class = app_class(root_app_name)
        mounted_apps = mounted_stack_apps(selected_node)
        root_app_class.host_adapter.activate_transport!
        root_config = root_app_class.send(:build!)
        apply_http_settings!(root_config, stack_http_settings(selected_node))
        attach_ignite_runtime_hook!(root_config)
        root_config.custom_routes = mounted_apps.flat_map { |app| app.fetch(:routes) } + Array(root_config.custom_routes)

        {
          runtime_name: selected_node || root_app_name,
          root_app_name: root_app_name,
          root_app_class: root_app_class,
          root_config: root_config,
          mounted_apps: mounted_apps
        }
      end

      def mounted_stack_apps(node_name = nil)
        selected_mounts = if node_name && nodes_defined?
                            node_deployment(node_name).fetch("mounts", {})
                          else
                            stringify_hash(mounts)
                          end

        selected_mounts.map do |app_name, mount_path|
          build_mounted_app(app_name: app_name, mount_path: mount_path)
        end
      end

      def build_mounted_app(app_name:, mount_path:)
        normalized_app_name = normalize_app_name(app_name)
        klass = app_class(normalized_app_name)

        klass.host_adapter.activate_transport!
        config = klass.send(:build!)
        rack_app = klass.host_adapter.rack_app(config: config)

        {
          app_name: normalized_app_name,
          app_class: klass,
          config: config,
          rack_app: rack_app,
          mount_path: normalize_mount_path(mount_path),
          routes: mounted_app_routes(normalize_mount_path(mount_path), rack_app)
        }
      end

      def mounted_app_routes(mount_path, rack_app)
        pattern = %r{\A#{Regexp.escape(mount_path)}(?<rest>/.*)?\z}

        SERVICE_MOUNT_METHODS.map do |method|
          {
            method: method,
            path: pattern,
            handler: lambda do |params:, body:, headers:, env:, raw_body:, config:| # rubocop:disable Lint/UnusedBlockArgument
              forward_mounted_request(
                rack_app: rack_app,
                mount_path: mount_path,
                rest: params[:rest],
                env: env,
                raw_body: raw_body
              )
            end
          }
        end
      end

      def forward_mounted_request(rack_app:, mount_path:, rest:, env:, raw_body:)
        forwarded_env = env.to_h.merge(
          "SCRIPT_NAME" => mount_path,
          "PATH_INFO" => normalize_forwarded_path(rest),
          "rack.input" => StringIO.new(raw_body.to_s)
        )
        status, headers, body = rack_app.call(forwarded_env)
        response_body = +""
        body.each { |chunk| response_body << chunk.to_s }
        body.close if body.respond_to?(:close)

        {
          status: status.to_i,
          headers: headers,
          body: response_body
        }
      end

      def normalize_forwarded_path(rest)
        value = rest.to_s
        value.empty? ? "/" : value
      end

      def normalize_mount_path(path)
        value = path.to_s.strip
        value = "/#{value}" unless value.start_with?("/")
        value = value.sub(%r{/+\z}, "")
        value.empty? ? "/" : value
      end

      def apply_http_settings!(config, http_settings)
        return config unless http_settings.is_a?(Hash)

        config.host = http_settings["host"].to_s if present?(http_settings["host"])
        config.port = Integer(http_settings["port"]) if http_settings.key?("port") && !http_settings["port"].nil?
        config.log_format = http_settings["log_format"].to_sym if present?(http_settings["log_format"])
        config.drain_timeout = Integer(http_settings["drain_timeout"]) if http_settings.key?("drain_timeout") && !http_settings["drain_timeout"].nil?
        config
      end

      def attach_ignite_runtime_hook!(config)
        context = ignite_runtime_boot_context
        return config unless context
        return config unless config.respond_to?(:after_start_hooks)

        config.after_start_hooks << lambda do |config:, server:|
          complete_ignite_runtime_boot!(config: config, server: server, context: context)
        end
        config
      end

      def ignite_runtime_boot_context
        target_id = ENV["IGNITER_IGNITE_TARGET"].to_s.strip
        return nil if target_id.empty?

        {
          target_id: target_id,
          intent_id: ENV["IGNITER_IGNITE_INTENT"].to_s.strip,
          mode: ENV["IGNITER_IGNITE_MODE"].to_s.strip
        }
      end

      def complete_ignite_runtime_boot!(config:, server:, context:)
        mesh = defined?(Igniter::Cluster::Mesh) ? Igniter::Cluster::Mesh : nil
        url = ignite_runtime_join_url(config, mesh: mesh)
        return if url.nil?

        if mesh
          mesh.config.local_url = url if mesh.config.local_url.to_s.strip.empty?
          if mesh.config.seeds.any?
            Igniter::Cluster::Mesh::Announcer.new(mesh.config).announce_all
          elsif mesh.config.peer_name
            peer = Igniter::Cluster::Mesh::Peer.new(
              name: mesh.config.peer_name,
              url: url,
              capabilities: Array(mesh.config.local_capabilities),
              tags: Array(mesh.config.local_tags),
              metadata: Igniter::Cluster::Mesh::PeerMetadata.authoritative(
                mesh.config.local_metadata.merge(
                  mesh_ignite: {
                    target_id: context[:target_id],
                    intent_id: context[:intent_id],
                    mode: context[:mode],
                    joined_at: Time.now.utc.iso8601
                  }.compact
                ),
                origin: mesh.config.peer_name
              )
            )
            mesh.config.peer_registry.register(peer)
          end

          mesh.config.governance_trail&.record(
            :ignite_runtime_joined,
            source: :stack_runtime,
            payload: {
              target_id: context[:target_id],
              intent_id: context[:intent_id],
              mode: context[:mode],
              url: url,
              server: server.class.name
            }.compact
          )
        end

        { target_id: context[:target_id], url: url }
      end

      def ignite_runtime_join_url(config, mesh:)
        local_url = mesh&.config&.local_url.to_s.strip
        return local_url unless local_url.empty?

        host = config.host.to_s.strip
        host = "127.0.0.1" if host.empty? || host == "0.0.0.0"
        return nil if config.port.nil?

        "http://#{host}:#{config.port}"
      end

      def should_await_ignite_join?(report, mesh:, await_join:, bootstrap_remote:)
        enabled = await_join.nil? ? (mesh && bootstrap_remote) : await_join
        return false unless enabled
        return false unless mesh
        return false unless report.is_a?(Igniter::Ignite::IgnitionReport)

        report.awaiting_join? || report.by_status.fetch(:bootstrapped, 0).positive?
      end

      def await_ignite_join(report:, mesh:, timeout:, poll_interval:)
        deadline = Time.now + timeout.to_f
        current = report

        loop do
          current = reconcile_ignite(report: current, mesh: mesh, persist: false)
          return current unless current.awaiting_join? || current.by_status.fetch(:bootstrapped, 0).positive?
          break if Time.now >= deadline

          sleep poll_interval.to_f
        end

        current
      end

      def start_stack_schedulers(runtime)
        schedulers = []
        root_app_class = runtime.fetch(:root_app_class)
        root_config = runtime.fetch(:root_config)
        scheduler = root_app_class.send(:start_scheduler, root_config)
        schedulers << scheduler if scheduler

        runtime.fetch(:mounted_apps).each do |mounted|
          scheduler = mounted.fetch(:app_class).send(:start_scheduler, mounted.fetch(:config))
          schedulers << scheduler if scheduler
        end

        schedulers
      end

      def stop_stack_schedulers(schedulers)
        Array(schedulers).each do |scheduler|
          scheduler&.stop
        end
      end

      def build_config(context, dockerfile)
        config = {}
        config["context"] = context if present?(context)
        config["dockerfile"] = dockerfile if present?(dockerfile)
        config
      end

      def runtime_environment_for_unit(unit_name, unit_config)
        env = stringify_hash(unit_config.fetch("environment", {}))
        env["IGNITER_NODE"] = unit_name.to_s if nodes_defined?
        env["IGNITER_ROOT_APP"] = unit_config["root_app"].to_s
        env["PORT"] = unit_config["port"].to_s if unit_config["port"]
        env["IGNITER_ENV"] = resolved_environment unless resolved_environment.empty?
        env.reject { |_key, value| !present?(value) }
      end

      def dev_runtime_environment_for_unit(unit_name, unit_config)
        runtime_environment_for_unit(unit_name, unit_config).merge("RUBYOPT" => rubyopt_with_dev_output_sync)
      end

      def rubyopt_with_dev_output_sync
        helper = File.expand_path("dev_output_sync", __dir__)
        parts = []
        existing = ENV["RUBYOPT"].to_s.strip
        parts << existing unless existing.empty?
        parts << "-r#{Shellwords.escape(helper)}"
        parts.join(" ").strip
      end

      def shell_command_with_env(command, env)
        assignments = env.map do |key, value|
          "#{Shellwords.escape(key)}=#{Shellwords.escape(value)}"
        end
        (assignments + [command]).join(" ").strip
      end

      def console_banner(context)
        [
          "Igniter Console",
          "  stack=#{context.stack_class.name || "anonymous"}",
          "  root_app=#{context.root_app_name}",
          "  app=#{context.app_name}",
          "  node=#{context.node_name || "none"}",
          "  mounts=#{context.mounts.keys.map(&:to_s).join(", ")}",
          "  helpers: stack, context, app, root_app, node, deployment, runtime, mesh"
        ].join("\n")
      end

      def console_locals_binding(context)
        bind = Object.new.instance_eval { binding }
        {
          stack: context.stack_class,
          stack_class: context.stack_class,
          context: context,
          root_app: context.root_app_class,
          root_app_name: context.root_app_name,
          app: context.app_class,
          app_class: context.app_class,
          app_name: context.app_name,
          node: context.node_name,
          node_name: context.node_name,
          node_profile: context.node_profile,
          deployment: context.deployment,
          runtime: context.runtime,
          mounts: context.mounts,
          mesh: context.mesh,
          stack_settings: context.stack_settings
        }.each do |name, value|
          bind.local_variable_set(name, value)
        end
        bind
      end

      def evaluate_console(bind, code, output)
        result = bind.eval(code)
        output.puts("=> #{result.inspect}")
        result
      end

      def stringify_hash(hash)
        hash.each_with_object({}) do |(key, value), result|
          result[key.to_s] = value.to_s
        end
      end

      def stringify_nested_keys(value)
        case value
        when Hash
          value.each_with_object({}) do |(key, nested_value), result|
            result[key.to_s] = stringify_nested_keys(nested_value)
          end
        when Array
          value.map { |item| stringify_nested_keys(item) }
        else
          value
        end
      end

      def shared_runtime_environment
        stringify_hash(stack_settings.dig("shared", "environment") || {})
      end

      def stack_slug
        name = stack_settings.dig("stack", "name")
        candidate = present?(name) ? name : File.basename(@root_dir.to_s)
        candidate.to_s.strip.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/\A_+|_+\z/, "")
      end

      def present?(value)
        !value.to_s.strip.empty?
      end

      def use_stack_runtime_by_default?(name)
        name.nil? && mounts_defined?
      end

      def stack_http_settings(node_name = nil)
        settings = stringify_hash(stack_settings.fetch("server", {}))
        if node_name && nodes_defined?
          settings = settings.merge(stringify_hash(node_profile(node_name).slice("host", "port", "log_format", "drain_timeout")))
        end
        settings["port"] = ENV["PORT"] if present?(ENV["PORT"])
        settings["port"] = settings["port"].to_i if settings["port"]
        settings
      end

      def build_ignition_plan
        settings = ignite_settings
        mode = normalize_ignite_mode(settings["mode"])
        strategy = normalize_ignite_strategy(settings["strategy"])
        approval_mode = normalize_ignite_approval(settings["approval"])
        request_id = settings["request_id"] || "ignite-#{stack_slug}-#{resolved_environment.empty? ? "default" : resolved_environment}"
        requested_from = {
          "stack" => stack_slug,
          "environment" => resolved_environment,
          "root_app" => root_app.to_s
        }
        requested_by = {
          "kind" => "stack_config",
          "source" => "ignite"
        }
        seed_node = {
          "stack" => stack_slug,
          "root_app" => root_app.to_s,
          "host" => stack_settings.dig("server", "host"),
          "port" => stack_settings.dig("server", "port")
        }

        intents = []
        Array(settings["replicas"]).each_with_index do |replica, index|
          intents << build_local_replica_intent(
            config: replica,
            index: index + 1,
            request_id: request_id,
            mode: mode,
            strategy: strategy,
            approval_mode: approval_mode,
            requested_by: requested_by,
            requested_from: requested_from,
            seed_node: seed_node
          )
        end

        Array(settings["servers"]).each_with_index do |server, index|
          intents << build_remote_server_intent(
            config: server,
            index: index + 1,
            request_id: request_id,
            mode: mode,
            strategy: strategy,
            approval_mode: approval_mode,
            requested_by: requested_by,
            requested_from: requested_from,
            seed_node: seed_node
          )
        end

        Igniter::Ignite::IgnitionPlan.new(
          id: request_id,
          ignite_mode: mode,
          strategy: strategy,
          approval_mode: approval_mode,
          intents: intents,
          requested_by: requested_by,
          requested_from: requested_from,
          seed_node: seed_node,
          metadata: {}
        )
      end

      def build_local_replica_intent(config:, index:, request_id:, mode:, strategy:, approval_mode:, requested_by:, requested_from:, seed_node:)
        replica = Hash(config)
        replica_id = (replica["name"] || "replica-#{index}").to_s
        target = Igniter::Ignite::BootstrapTarget.new(
          id: replica_id,
          kind: :local_replica,
          locator: select_hash_keys(replica, %w[host port]),
          base_server: select_hash_keys(stack_settings.fetch("server", {}), %w[host port]),
          capability_intent: Array(replica["capabilities"]),
          bootstrap_requirements: Hash(replica["bootstrap"] || {}),
          metadata: reject_hash_keys(replica, %w[name host port capabilities bootstrap])
        )

        Igniter::Ignite::DeploymentIntent.new(
          id: "#{request_id}-#{replica_id}",
          ignite_mode: mode,
          strategy: strategy,
          approval_mode: approval_mode,
          target: target,
          requested_capabilities: target.capability_intent,
          requested_by: requested_by,
          requested_from: requested_from,
          seed_node: seed_node,
          join_policy: {
            "admission" => "required",
            "trust" => "cluster_default"
          },
          correlation: {
            "ignite_request_id" => request_id,
            "target_id" => replica_id
          },
          metadata: {}
        )
      end

      def build_remote_server_intent(config:, index:, request_id:, mode:, strategy:, approval_mode:, requested_by:, requested_from:, seed_node:)
        server = normalize_remote_server_config(config, index)
        server_id = server.fetch("id")
        target = Igniter::Ignite::BootstrapTarget.new(
          id: server_id,
          kind: :ssh_server,
          locator: { "config_path" => server.fetch("config_path") },
          base_server: select_hash_keys(stack_settings.fetch("server", {}), %w[host port]),
          capability_intent: Array(server["capabilities"]),
          bootstrap_requirements: Hash(server["bootstrap"] || {}),
          metadata: reject_hash_keys(server, %w[id config_path capabilities bootstrap])
        )

        Igniter::Ignite::DeploymentIntent.new(
          id: "#{request_id}-#{server_id}",
          ignite_mode: mode,
          strategy: strategy,
          approval_mode: approval_mode,
          target: target,
          requested_capabilities: target.capability_intent,
          requested_by: requested_by,
          requested_from: requested_from,
          seed_node: seed_node,
          join_policy: {
            "admission" => "required",
            "trust" => "cluster_default"
          },
          correlation: {
            "ignite_request_id" => request_id,
            "target_id" => server_id
          },
          metadata: {}
        )
      end

      def normalize_remote_server_config(config, index)
        case config
        when String
          {
            "id" => "server-#{index}",
            "config_path" => config
          }
        else
          hash = Hash(config)
          {
            "id" => (hash["name"] || hash["id"] || "server-#{index}").to_s,
            "config_path" => hash["target"] || hash.fetch("config_path"),
            "capabilities" => Array(hash["capabilities"]),
            "bootstrap" => Hash(hash["bootstrap"] || {})
          }.merge(reject_hash_keys(hash, %w[name id target config_path capabilities bootstrap]))
        end
      end

      def normalize_ignite_mode(value)
        (value || "cold_start").to_sym
      end

      def normalize_ignite_strategy(value)
        (value || "parallel").to_sym
      end

      def normalize_ignite_approval(value)
        (value || "required").to_sym
      end

      def select_hash_keys(hash, allowed_keys)
        Hash(hash).each_with_object({}) do |(key, value), result|
          result[key.to_s] = value if allowed_keys.include?(key.to_s)
        end
      end

      def reject_hash_keys(hash, rejected_keys)
        Hash(hash).each_with_object({}) do |(key, value), result|
          result[key.to_s] = value unless rejected_keys.include?(key.to_s)
        end
      end

      def default_runtime_command(name)
        if nodes_defined?
          "bundle exec ruby stack.rb --node #{name}"
        else
          "bundle exec ruby stack.rb"
        end
      end

      def resolve_dev_log_dir
        configured = stack_settings.dig("development", "log_dir") || stack_settings.dig("dev", "log_dir")
        resolve_path(configured || "var/log/dev")
      end

      def dev_log_path_for(name, dir: resolve_dev_log_dir)
        File.join(dir, "#{name}.log")
      end

      def relative_to_root(path)
        return path unless @root_dir && path.start_with?(@root_dir.to_s)

        path.delete_prefix(@root_dir.to_s).sub(%r{\A/}, "")
      end

      def load_yaml(path)
        return {} unless path && File.exist?(path)

        YAML.safe_load(File.read(path)) || {}
      end

      def resolve_path(path)
        return nil if path.nil?
        return path if File.absolute_path(path) == path

        File.expand_path(path, @root_dir || Dir.pwd)
      end

      def default_ignition_store
        Igniter::Ignite::Stores::FileStore.new(
          path: resolve_path(File.join("var", "ignite", "#{stack_slug}.ndjson")),
          archive_path: resolve_path(File.join("var", "ignite", "#{stack_slug}.archive.ndjson"))
        )
      end

      def default_credential_store
        Igniter::App::Credentials::Stores::FileStore.new(
          path: resolve_path(File.join("var", "credentials", "#{stack_slug}.ndjson")),
          archive_path: resolve_path(File.join("var", "credentials", "#{stack_slug}.archive.ndjson"))
        )
      end

      def ignition_plan_for_target(target_id, mode: :expand)
        target = target_id.to_s
        base_plan = ignition_plan
        intent = base_plan.intents.find { |candidate| candidate.target.id == target }
        raise KeyError, "Unknown ignition target #{target.inspect}" unless intent

        Igniter::Ignite::IgnitionPlan.new(
          id: "#{base_plan.id}:#{mode}:#{target}:#{Time.now.utc.strftime('%Y%m%d%H%M%S%6N')}",
          ignite_mode: mode,
          strategy: base_plan.strategy,
          approval_mode: base_plan.approval_mode,
          intents: [intent],
          requested_by: base_plan.requested_by,
          requested_from: base_plan.requested_from,
          seed_node: base_plan.seed_node,
          metadata: base_plan.metadata.merge("lifecycle_operation" => mode.to_s, "target_id" => target)
        )
      end

      def persist_ignition_report!(report, source:)
        ignition_trail.ingest_report(report, source: source)
      end

      def deep_merge(base, override)
        base.merge(override) do |_key, left, right|
          if left.is_a?(Hash) && right.is_a?(Hash)
            deep_merge(left, right)
          else
            right
          end
        end
      end

      def reset_stack_state!
        @stack_settings = nil
        @environment_settings = nil
        @ignition_plan = nil
        @ignition_trail = nil
        @credential_trail = nil
      end
    end
  end
end
