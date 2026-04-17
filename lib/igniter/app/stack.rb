# frozen_string_literal: true

require "fileutils"
require "optparse"
require "shellwords"
require "stringio"
require "yaml"

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
    AppDefinition = Struct.new(:name, :path, :klass, :root, keyword_init: true)
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

      def procfile_dev_file(path = nil)
        return @procfile_dev_path unless path

        @procfile_dev_path = path
      end

      def app(name = nil, path: nil, klass: nil, default: false)
        if path || klass
          raise ArgumentError, "stack app registration requires both path: and klass:" unless path && klass

          definition = AppDefinition.new(
            name: name.to_sym,
            path: path.to_s,
            klass: klass,
            root: default
          )

          @apps[definition.name] = definition
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

      def root_app
        normalize_optional_name(stack_settings.dig("stack", "root_app")) ||
          @root_app ||
          @apps.keys.first
      end

      def default_node
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

        if options[:node]
          start_node(options[:node], environment: options[:environment])
        else
          start(target, environment: options[:environment])
        end
      end

      def stack_settings(reload: false)
        @stack_settings = nil if reload
        @stack_settings ||= deep_merge(
          load_yaml(resolve_path(@stack_yml_path)),
          environment_settings
        )
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
          "nodes" => runtime_units_snapshot
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
          pid = Process.spawn(
            service.fetch(:environment),
            service.fetch(:command),
            chdir: @root_dir,
            out: writer,
            err: writer
          )
          writer.close

          processes[pid] = { name: service.fetch(:name), pid: pid }
          readers << Thread.new(reader, service.fetch(:name)) do |io, name|
            io.each_line do |line|
              $stdout.print("[#{name}] #{line}")
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
      end

      private

      def parse_cli_options(argv)
        options = {}

        parser = OptionParser.new do |opts|
          opts.on("--app NAME", "Start a specific app by name") do |value|
            options[:target] = value
          end

          opts.on("--node NAME", "Start a named local node profile") do |value|
            options[:node] = value
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

          opts.on("--dev", "Start stack nodes locally with prefixed logs") do
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
          root_name = root_app.to_s
          {
            root_name => standalone_runtime_deployment(root_name).merge(
              "node" => root_name,
              "default" => true
            )
          }
        end
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
        selected_node = nodes_defined? ? resolve_node_name(node_name) : nil
        root_app_name = root_app
        root_app_class = app_class(root_app_name)
        mounted_apps = mounted_stack_apps(selected_node)
        root_app_class.host_adapter.activate_transport!
        root_config = root_app_class.send(:build!)
        apply_http_settings!(root_config, stack_http_settings(selected_node))
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

      def stringify_hash(hash)
        hash.each_with_object({}) do |(key, value), result|
          result[key.to_s] = value.to_s
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
        settings["port"] = settings["port"].to_i if settings["port"]
        settings
      end

      def default_runtime_command(name)
        if nodes_defined?
          "bundle exec ruby stack.rb --node #{name}"
        else
          "bundle exec ruby stack.rb"
        end
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
      end
    end
  end
end
