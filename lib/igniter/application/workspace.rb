# frozen_string_literal: true

require "optparse"
require "yaml"

module Igniter
  # Root coordinator for multi-app Igniter workspaces.
  #
  # A workspace owns:
  # - shared load paths (for repo-level support code under lib/)
  # - a registry of named apps under apps/<name>
  # - convenience lifecycle methods for starting a specific app
  #
  # Each registered app is still a regular Igniter::Application subclass.
  class Workspace
    AppDefinition = Struct.new(:name, :path, :klass, :default, keyword_init: true)

    class << self
      def root_dir(path = nil)
        return @root_dir unless path

        @root_dir = File.expand_path(path)
        reset_workspace_state!
      end

      def shared_lib_path(path)
        @shared_lib_paths << path
      end

      def workspace_file(path = nil)
        return @workspace_yml_path unless path

        @workspace_yml_path = path
        reset_workspace_state!
      end

      def config_file(path = nil)
        workspace_file(path)
      end

      def topology_file(path = nil)
        return @topology_yml_path unless path

        @topology_yml_path = path
        reset_workspace_state!
      end

      def environment(name = nil)
        return resolved_environment unless name

        @environment_name = name.to_s
        reset_workspace_state!
      end

      def environment_file(path = nil)
        return @environment_yml_path unless path

        @environment_yml_path = path
        reset_workspace_state!
      end

      def app(name, path:, klass:, default: false)
        definition = AppDefinition.new(
          name: name.to_sym,
          path: path.to_s,
          klass: klass,
          default: default
        )

        @apps[definition.name] = definition
        @default_app = definition.name if default
      end

      def app_names
        @apps.keys
      end

      def default_app
        @default_app ||
          normalize_optional_name(workspace_settings.dig("workspace", "default_app")) ||
          @apps.keys.first
      end

      def app_definition(name = nil)
        requested = normalize_app_name(name || default_app)
        @apps.fetch(requested) do
          available = @apps.keys.map(&:inspect).join(", ")
          raise ArgumentError, "Unknown workspace app #{requested.inspect} (available: #{available})"
        end
      end

      def application(name = nil)
        setup_load_paths!
        app_definition(resolve_app_name(name)).klass
      end

      def start(name = nil, role: nil, environment: nil, profile: nil)
        environment(environment) if environment
        validate_profile!(profile) if profile
        application(resolve_app_name(name, role: role)).start
      end

      def rack_app(name = nil, role: nil, environment: nil, profile: nil)
        environment(environment) if environment
        validate_profile!(profile) if profile
        application(resolve_app_name(name, role: role)).rack_app
      end

      def start_cli(argv = ARGV)
        options = parse_cli_options(argv.dup)
        target = options.delete(:target)

        start(
          target,
          role: options[:role],
          environment: options[:environment],
          profile: options[:profile]
        )
      end

      def workspace_settings(reload: false)
        @workspace_settings = nil if reload
        @workspace_settings ||= deep_merge(
          load_yaml(resolve_path(@workspace_yml_path)),
          workspace_environment_overrides
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
        configured_paths = Array(workspace_settings.dig("workspace", "shared_lib_paths"))
        (@shared_lib_paths + configured_paths).uniq.each do |path|
          full = File.expand_path(path, @root_dir || Dir.pwd)
          $LOAD_PATH.unshift(full) unless $LOAD_PATH.include?(full)
        end
      end

      def inherited(subclass)
        super
        subclass.instance_variable_set(:@root_dir, Dir.pwd)
        subclass.instance_variable_set(:@workspace_yml_path, "workspace.yml")
        subclass.instance_variable_set(:@topology_yml_path, "config/topology.yml")
        subclass.instance_variable_set(:@environment_name, nil)
        subclass.instance_variable_set(:@environment_yml_path, nil)
        subclass.instance_variable_set(:@shared_lib_paths, [])
        subclass.instance_variable_set(:@apps, {})
        subclass.instance_variable_set(:@default_app, nil)
        subclass.instance_variable_set(:@workspace_settings, nil)
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

          opts.on("--role NAME", "Start the first app matching a deployment role") do |value|
            options[:role] = value
          end

          opts.on("--env NAME", "Use config/environments/<NAME>.yml overlay") do |value|
            options[:environment] = value
          end

          opts.on("--profile NAME", "Require topology profile to match NAME") do |value|
            options[:profile] = value
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

      def normalize_app_name(name)
        name.to_sym
      end

      def normalize_optional_name(name)
        value = name.to_s.strip
        value.empty? ? nil : value.to_sym
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

      def workspace_environment_overrides
        environment_settings.reject { |key, _value| key.to_s == "topology" }
      end

      def validate_profile!(profile)
        expected = profile.to_s.strip
        actual = topology_profile.to_s.strip
        return if expected.empty? || actual.empty? || expected == actual

        raise ArgumentError, "Requested profile #{expected.inspect} does not match topology profile #{actual.inspect}"
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

      def reset_workspace_state!
        @workspace_settings = nil
        @topology_settings = nil
        @environment_settings = nil
      end
    end
  end
end
