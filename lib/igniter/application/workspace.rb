# frozen_string_literal: true

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
      end

      def shared_lib_path(path)
        @shared_lib_paths << path
      end

      def app(name, path:, klass:, default: false)
        definition = AppDefinition.new(
          name: name.to_sym,
          path: path.to_s,
          klass: klass,
          default: default
        )

        @apps[definition.name] = definition
        @default_app = definition.name if default || @default_app.nil?
      end

      def app_names
        @apps.keys
      end

      def default_app
        @default_app
      end

      def app_definition(name = nil)
        requested = normalize_app_name(name || @default_app)
        @apps.fetch(requested) do
          available = @apps.keys.map(&:inspect).join(", ")
          raise ArgumentError, "Unknown workspace app #{requested.inspect} (available: #{available})"
        end
      end

      def application(name = nil)
        setup_load_paths!
        app_definition(name).klass
      end

      def start(name = nil)
        application(name).start
      end

      def rack_app(name = nil)
        application(name).rack_app
      end

      def setup_load_paths!
        @shared_lib_paths.each do |path|
          full = File.expand_path(path, @root_dir || Dir.pwd)
          $LOAD_PATH.unshift(full) unless $LOAD_PATH.include?(full)
        end
      end

      def inherited(subclass)
        super
        subclass.instance_variable_set(:@root_dir, Dir.pwd)
        subclass.instance_variable_set(:@shared_lib_paths, [])
        subclass.instance_variable_set(:@apps, {})
        subclass.instance_variable_set(:@default_app, nil)
      end

      private

      def normalize_app_name(name)
        name.to_sym
      end
    end
  end
end
