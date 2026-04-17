# frozen_string_literal: true

require "fileutils"
require "optparse"
require "shellwords"
require "stringio"
require "yaml"

module Igniter
  # Root coordinator for multi-app Igniter stacks.
  #
  # A stack owns:
  # - shared load paths (for repo-level support code under lib/)
  # - a registry of named apps under apps/<name>
  # - convenience lifecycle methods for starting a specific app
  #
  # Each registered app is still a regular Igniter::App subclass.
  class Stack
    AppDefinition = Struct.new(:name, :path, :klass, :default, keyword_init: true)
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

      def topology_file(path = nil)
        return @topology_yml_path unless path

        @topology_yml_path = path
        reset_stack_state!
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
            default: default
          )

          @apps[definition.name] = definition
          @default_app = definition.name if default
          return definition.klass
        end

        app_class(name)
      end

      def app_names
        @apps.keys
      end

      def default_app
        @default_app ||
          normalize_optional_name(stack_settings.dig("stack", "default_app")) ||
          @apps.keys.first
      end

      def app_definition(name = nil)
        requested = normalize_app_name(name || default_app)
        @apps.fetch(requested) do
          available = @apps.keys.map(&:inspect).join(", ")
          raise ArgumentError, "Unknown stack app #{requested.inspect} (available: #{available})"
        end
      end

      def app_class(name = nil)
        setup_load_paths!
        app_definition(resolve_app_name(name)).klass
      end

      def start(name = nil, role: nil, environment: nil, profile: nil)
        environment(environment) if environment
        validate_profile!(profile) if profile
        app_class(resolve_app_name(name, role: role)).start
      end

      def rack_app(name = nil, role: nil, environment: nil, profile: nil)
        environment(environment) if environment
        validate_profile!(profile) if profile
        app_class(resolve_app_name(name, role: role)).rack_app
      end

      def service_names
        return topology.fetch("services", {}).keys.map { |service_name| normalize_app_name(service_name) } if services_defined?

        app_names
      end

      def default_service
        configured = normalize_optional_name(stack_settings.dig("stack", "default_service"))
        return configured if configured && service_names.include?(configured)

        fallback = default_app
        return fallback if service_names.include?(fallback)

        service_names.first
      end

      def service_for_role(role)
        desired = role.to_s

        if services_defined?
          topology.fetch("services", {}).each do |name, config|
            return normalize_app_name(name) if config["role"].to_s == desired
          end

          return nil
        end

        app_for_role(role)
      end

      def start_service(name = nil, role: nil, environment: nil, profile: nil)
        environment(environment) if environment
        validate_profile!(profile) if profile

        runtime = build_service_runtime(resolve_service_name(name, role: role))
        schedulers = start_service_schedulers(runtime)
        at_exit { stop_service_schedulers(schedulers) }
        runtime.fetch(:root_app_class).host_adapter.start(config: runtime.fetch(:root_config))
      end

      def rack_service(name = nil, role: nil, environment: nil, profile: nil)
        environment(environment) if environment
        validate_profile!(profile) if profile

        runtime = build_service_runtime(resolve_service_name(name, role: role))
        start_service_schedulers(runtime)
        runtime.fetch(:root_app_class).host_adapter.rack_app(config: runtime.fetch(:root_config))
      end

      def start_cli(argv = ARGV)
        options = parse_cli_options(argv.dup)
        target = options.delete(:target)

        if options[:print_procfile_dev]
          environment(options[:environment]) if options[:environment]
          validate_profile!(options[:profile]) if options[:profile]
          puts procfile_dev
          return
        end

        if options[:write_procfile_dev]
          environment(options[:environment]) if options[:environment]
          validate_profile!(options[:profile]) if options[:profile]
          write_procfile_dev(options[:write_procfile_dev] == true ? nil : options[:write_procfile_dev])
          return
        end

        if options[:dev]
          start_dev(
            environment: options[:environment],
            profile: options[:profile]
          )
          return
        end

        if options[:print_compose]
          environment(options[:environment]) if options[:environment]
          validate_profile!(options[:profile]) if options[:profile]
          puts compose_yaml
          return
        end

        if options[:write_compose]
          environment(options[:environment]) if options[:environment]
          validate_profile!(options[:profile]) if options[:profile]
          write_compose(options[:write_compose] == true ? nil : options[:write_compose])
          return
        end

        if options[:service] || (services_defined? && options[:role])
          start_service(
            options[:service] || target,
            role: options[:role],
            environment: options[:environment],
            profile: options[:profile]
          )
        else
          start(
            target,
            role: options[:role],
            environment: options[:environment],
            profile: options[:profile]
          )
        end
      end

      def stack_settings(reload: false)
        @stack_settings = nil if reload
        @stack_settings ||= deep_merge(
          load_yaml(resolve_path(@stack_yml_path)),
          stack_environment_overrides
        )
      end

      def topology(reload: false)
        @topology_settings = nil if reload
        @topology_settings ||= deep_merge(
          load_yaml(resolve_path(@topology_yml_path)),
          environment_settings.fetch("topology", {})
        )
      end

      def deployment(name = nil)
        app_name = normalize_app_name(name || default_app)
        shared = topology.fetch("shared", {})
        app = topology.fetch("apps", {}).fetch(app_name.to_s, {})
        deep_merge(shared, app)
      end

      def deployment_snapshot
        snapshot = {
          "stack" => {
            "root_dir" => @root_dir,
            "environment" => resolved_environment,
            "default_app" => default_app.to_s,
            "default_service" => default_service.to_s,
            "topology_profile" => topology_profile.to_s
          },
          "apps" => app_names.each_with_object({}) do |app_name, result|
            definition = app_definition(app_name)
            result[app_name.to_s] = deployment(app_name).merge(
              "app" => app_name.to_s,
              "path" => definition.path,
              "class_name" => definition.klass.name || definition.klass.inspect,
              "default" => (app_name == default_app)
            )
          end
        }

        snapshot["services"] = service_names.each_with_object({}) do |service_name, result|
          result[service_name.to_s] = service_deployment(service_name).merge(
            "service" => service_name.to_s,
            "default" => (service_name == default_service)
          )
        end

        snapshot
      end

      def compose_config
        snapshot = deployment_snapshot
        compose = topology.dig("deploy", "compose") || {}
        volume_name = compose["volume_name"] || "#{stack_slug}_var"
        working_dir = compose["working_dir"]
        build = compose["build"]
        dockerfile = compose["dockerfile"]
        build_context = compose["context"]
        shared_env = stringify_hash(compose["environment"] || {})
        volume_target = compose["volume_target"]

        services = snapshot.fetch("services").each_with_object({}) do |(service_name, service_config), result|
          service = {}
          service["build"] = build_config(build_context, dockerfile) if build_context || dockerfile || build
          service["image"] = build if build.is_a?(String)
          service["command"] = service_config["command"] || "bundle exec ruby stack.rb --service #{service_name}"
          service["working_dir"] = working_dir if present?(working_dir)

          env = shared_env.merge(compose_environment_for(service_name, service_config))
          service["environment"] = env unless env.empty?

          port = service_config.dig("http", "port")
          if service_config["public"] && port
            service["ports"] = ["#{port}:#{port}"]
          end

          depends_on = Array(service_config["depends_on"]).map(&:to_s)
          service["depends_on"] = depends_on unless depends_on.empty?

          if volume_target
            service["volumes"] = ["#{volume_name}:#{volume_target}"]
          end

          result[service_name] = service
        end

        compose_config = { "services" => services }
        compose_config["volumes"] = { volume_name => {} } if volume_target
        compose_config
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
        snapshot = deployment_snapshot

        service_names.map do |service_name|
          service_config = snapshot.fetch("services").fetch(service_name.to_s)
          {
            name: service_name.to_s,
            command: service_config["dev_command"] || service_config["command"] || "bundle exec ruby stack.rb --service #{service_name}",
            environment: dev_runtime_environment_for(service_name, service_config)
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

      def start_dev(environment: nil, profile: nil) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        environment(environment) if environment
        validate_profile!(profile) if profile

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

          if status.exitstatus.to_i != 0 && exit_status.zero?
            exit_status = status.exitstatus
          end

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

      def apps_for_role(role)
        desired = role.to_s
        topology.fetch("apps", {}).filter_map do |name, config|
          normalize_app_name(name) if config["role"].to_s == desired
        end
      end

      def app_for_role(role)
        apps_for_role(role).first
      end

      def topology_profile
        topology.dig("topology", "profile")
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
        subclass.instance_variable_set(:@topology_yml_path, "config/topology.yml")
        subclass.instance_variable_set(:@environment_name, nil)
        subclass.instance_variable_set(:@environment_yml_path, nil)
        subclass.instance_variable_set(:@compose_yml_path, "config/deploy/compose.yml")
        subclass.instance_variable_set(:@procfile_dev_path, "config/deploy/Procfile.dev")
        subclass.instance_variable_set(:@shared_lib_paths, [])
        subclass.instance_variable_set(:@apps, {})
        subclass.instance_variable_set(:@default_app, nil)
        subclass.instance_variable_set(:@stack_settings, nil)
        subclass.instance_variable_set(:@topology_settings, nil)
        subclass.instance_variable_set(:@environment_settings, nil)
      end

      private

      def parse_cli_options(argv)
        options = {}

        parser = OptionParser.new do |opts|
          opts.on("--app NAME", "Start a specific app by name") do |value|
            options[:target] = value
          end

          opts.on("--role NAME", "Start the first app or service matching a deployment role") do |value|
            options[:role] = value
          end

          opts.on("--service NAME", "Start a named runtime service") do |value|
            options[:service] = value
          end

          opts.on("--env NAME", "Use config/environments/<NAME>.yml overlay") do |value|
            options[:environment] = value
          end

          opts.on("--profile NAME", "Require topology profile to match NAME") do |value|
            options[:profile] = value
          end

          opts.on("--print-compose", "Print a Docker Compose config generated from topology.yml") do
            options[:print_compose] = true
          end

          opts.on("--write-compose [PATH]", "Write a Docker Compose config generated from topology.yml") do |value|
            options[:write_compose] = value || true
          end

          opts.on("--dev", "Start all stack services locally with prefixed logs") do
            options[:dev] = true
          end

          opts.on("--print-procfile-dev", "Print a Procfile.dev generated from topology.yml") do
            options[:print_procfile_dev] = true
          end

          opts.on("--write-procfile-dev [PATH]", "Write a Procfile.dev generated from topology.yml") do |value|
            options[:write_procfile_dev] = value || true
          end
        end

        parser.parse!(argv)
        options[:target] ||= argv.shift
        options
      end

      def resolve_app_name(name = nil, role: nil)
        return normalize_app_name(name) if name && app_names.include?(normalize_app_name(name))

        if role
          app_name = app_for_role(role)
          return app_name if app_name

          raise ArgumentError, "Unknown deployment role #{role.inspect}"
        end

        if name
          role_match = app_for_role(name)
          return role_match if role_match
        end

        normalize_app_name(name || default_app)
      end

      def resolve_service_name(name = nil, role: nil)
        return normalize_app_name(name) if name && service_names.include?(normalize_app_name(name))

        if role
          service_name = service_for_role(role)
          return service_name if service_name

          raise ArgumentError, "Unknown deployment role #{role.inspect}"
        end

        if name
          role_match = service_for_role(name)
          return role_match if role_match
        end

        normalize_app_name(name || default_service)
      end

      def normalize_app_name(name)
        name.to_sym
      end

      def normalize_optional_name(name)
        value = name.to_s.strip
        value.empty? ? nil : value.to_sym
      end

      def services_defined?
        !topology.fetch("services", {}).empty?
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

      def stack_environment_overrides
        environment_settings.reject { |key, _value| key.to_s == "topology" }
      end

      def validate_profile!(profile)
        expected = profile.to_s.strip
        actual = topology_profile.to_s.strip
        return if expected.empty? || actual.empty? || expected == actual

        raise ArgumentError, "Requested profile #{expected.inspect} does not match topology profile #{actual.inspect}"
      end

      def service_deployment(name = nil)
        service_name = normalize_app_name(name || default_service)

        unless services_defined?
          config = deployment(service_name)
          config["apps"] = [service_name.to_s]
          config["root_app"] = service_name.to_s
          config["service"] = service_name.to_s
          config["mounts"] = {}
          return config
        end

        shared = topology.fetch("shared", {})
        service = topology.fetch("services", {}).fetch(service_name.to_s) do
          available = service_names.map(&:inspect).join(", ")
          raise ArgumentError, "Unknown stack service #{service_name.inspect} (available: #{available})"
        end

        config = deep_merge(shared, service)
        apps = Array(config["apps"] || config["app"]).map { |app| normalize_app_name(app).to_s }
        raise ArgumentError, "Service #{service_name.inspect} must declare at least one app" if apps.empty?

        apps.each { |app_name| app_definition(app_name) }

        config["apps"] = apps
        config["root_app"] = normalize_app_name(config["root_app"] || apps.first).to_s
        config["mounts"] = stringify_hash(config.fetch("mounts", {}))
        config["service"] = service_name.to_s
        config
      end

      def build_service_runtime(name)
        service_name = normalize_app_name(name)
        service_config = service_deployment(service_name)
        app_names_for_service = Array(service_config.fetch("apps")).map { |app_name| normalize_app_name(app_name) }
        root_app_name = normalize_app_name(service_config.fetch("root_app"))
        root_app_class = app_class(root_app_name)

        mounted_apps = app_names_for_service.reject { |app_name| app_name == root_app_name }.map do |app_name|
          build_mounted_service_app(
            service_config: service_config,
            app_name: app_name
          )
        end

        root_app_class.host_adapter.activate_transport!
        root_config = root_app_class.send(:build!)
        apply_service_http_settings!(root_config, service_config.fetch("http", {}))
        root_config.custom_routes = mounted_apps.flat_map { |app| app.fetch(:routes) } + Array(root_config.custom_routes)

        {
          service_name: service_name,
          service_config: service_config,
          root_app_name: root_app_name,
          root_app_class: root_app_class,
          root_config: root_config,
          mounted_apps: mounted_apps
        }
      end

      def build_mounted_service_app(service_config:, app_name:)
        klass = app_class(app_name)
        mount_path = normalize_mount_path(
          service_config.fetch("mounts", {}).fetch(app_name.to_s, "/apps/#{app_name}")
        )

        klass.host_adapter.activate_transport!
        config = klass.send(:build!)
        rack_app = klass.host_adapter.rack_app(config: config)

        {
          app_name: app_name,
          app_class: klass,
          config: config,
          rack_app: rack_app,
          mount_path: mount_path,
          routes: mounted_service_routes(mount_path, rack_app)
        }
      end

      def mounted_service_routes(mount_path, rack_app)
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

      def apply_service_http_settings!(config, http_settings)
        return config unless http_settings.is_a?(Hash)

        config.host = http_settings["host"].to_s if present?(http_settings["host"])
        config.port = Integer(http_settings["port"]) if http_settings.key?("port") && !http_settings["port"].nil?
        config.log_format = http_settings["log_format"].to_sym if present?(http_settings["log_format"])
        config.drain_timeout = Integer(http_settings["drain_timeout"]) if http_settings.key?("drain_timeout") && !http_settings["drain_timeout"].nil?
        config
      end

      def start_service_schedulers(runtime)
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

      def stop_service_schedulers(schedulers)
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

      def compose_environment_for(app_name, app_config)
        env = stringify_hash(topology.dig("deploy", "compose", "environment") || {})
        env.merge!(runtime_environment_for(app_name, app_config))
        env.reject { |_key, value| !present?(value) }
      end

      def runtime_environment_for(app_name, app_config)
        env = stringify_hash(topology.fetch("shared", {}).fetch("environment", {}))
        env.merge!(stringify_hash(app_config.fetch("environment", {})))
        env.merge!(
          {
            "IGNITER_APP" => Array(app_config["apps"]).one? ? app_name.to_s : app_config["root_app"].to_s,
            "IGNITER_SERVICE" => app_name.to_s,
            "PORT" => app_config.dig("http", "port").to_s
          }
        )
        env["IGNITER_ENV"] = resolved_environment unless resolved_environment.empty?
        env["IGNITER_TOPOLOGY_PROFILE"] = topology_profile.to_s unless topology_profile.to_s.empty?
        env.reject { |_key, value| !present?(value) }
      end

      def dev_runtime_environment_for(app_name, app_config)
        runtime_environment_for(app_name, app_config).merge("RUBYOPT" => rubyopt_with_dev_output_sync)
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

      def stack_slug
        name = stack_settings.dig("stack", "name")
        candidate = present?(name) ? name : File.basename(@root_dir.to_s)
        candidate.to_s.strip.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/\A_+|_+\z/, "")
      end

      def present?(value)
        !value.to_s.strip.empty?
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
        @topology_settings = nil
        @environment_settings = nil
      end
    end
  end
end
