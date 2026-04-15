# frozen_string_literal: true

require "pathname"
require "yaml"

module Companion
  module Boot
    module_function

    def root
      @root ||= File.expand_path("../..", __dir__)
    end

    def repo_root
      @repo_root ||= File.expand_path("../..", root)
    end

    def setup_load_path!
      [File.join(repo_root, "lib"), File.join(root, "lib")].each do |path|
        $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
      end
    end

    def configure_ai!
      require "igniter/sdk/ai"

      Igniter::AI.configure do |config|
        config.default_provider = :ollama
        config.ollama.base_url = ENV.fetch("OLLAMA_URL", "http://localhost:11434")
      end
    end

    def configure_persistence!(app_name: default_app_name)
      require "igniter"
      require "igniter/sdk/data"

      Igniter::Data.default_store = default_data_store(app_name: app_name)
      Igniter.execution_store = default_execution_store(app_name: app_name)
    end

    def default_data_store(app_name: default_app_name)
      require "igniter/sdk/data"

      @default_data_stores ||= {}
      key = app_name.to_sym
      @default_data_stores[key] ||= build_data_store(app_name: key)
    end

    def default_execution_store(app_name: default_app_name)
      require "igniter"

      @default_execution_stores ||= {}
      key = app_name.to_sym
      @default_execution_stores[key] ||= build_execution_store(app_name: key)
    end

    def reset_persistence!
      @stack_settings = nil
      @app_settings = {}
      @default_data_stores = {}
      @default_execution_stores = {}
      Igniter::Data.reset! if defined?(Igniter::Data)
      Igniter.execution_store = Igniter::Runtime::Stores::MemoryStore.new if defined?(Igniter::Runtime)
    end

    def load_main_sections(*sections)
      sections.each { |section| require_glob("apps/main/app/#{section}/**/*.rb") }
    end

    def load_inference_sections(*sections)
      sections.each { |section| require_glob("apps/inference/app/#{section}/**/*.rb") }
    end

    def load_main!
      load_main_sections("tools", "skills", "executors", "contracts", "agents")
    end

    def load_inference!
      load_inference_sections("executors", "contracts")
    end

    def load_demo!(real_llm: false)
      load_main_sections("tools", "skills")

      if real_llm
        configure_ai!
        load_main_sections("executors")
        load_inference_sections("executors")
      else
        activate_mock_executors!
      end

      load_main_sections("contracts", "agents")
      load_inference_sections("contracts")
      require_path("lib/companion/demo/local_pipeline_contract.rb")
    end

    def require_glob(pattern)
      Dir[File.join(root, pattern)].sort.each { |file| require file }
    end

    def require_path(relative_path)
      require File.join(root, relative_path)
    end

    def activate_mock_executors!
      require_path("lib/companion/demo/mock_executors.rb")

      {
        WhisperExecutor: MockWhisperExecutor,
        PiperExecutor: MockPiperExecutor,
        IntentExecutor: MockIntentExecutor,
        ChatExecutor: MockChatExecutor
      }.each do |name, executor|
        Companion.const_set(name, executor) unless Companion.const_defined?(name, false)
      end
    end

    def resolve_storage_path(path)
      return path if path.nil? || path.empty? || Pathname.new(path).absolute?

      File.expand_path(path, root)
    end

    def default_app_name
      name = stack_settings.dig("stack", "default_app").to_s.strip
      name.empty? ? :main : name.to_sym
    end

    def stack_settings
      @stack_settings ||= load_yaml(File.join(root, "stack.yml"))
    end

    def app_settings(app_name)
      @app_settings ||= {}
      key = app_name.to_sym
      @app_settings[key] ||= load_yaml(File.join(root, "apps", key.to_s, "app.yml"))
    end

    def persistence_settings(app_name)
      deep_merge(
        stack_settings.fetch("persistence", {}),
        app_settings(app_name).fetch("persistence", {})
      )
    end

    def build_data_store(app_name:)
      settings = persistence_settings(app_name)
      config = settings.fetch("data", {})
      adapter = resolve_data_adapter(config)

      case adapter
      when "memory"
        Igniter::Data::Stores::InMemory.new
      when "sqlite"
        path = presence(ENV["COMPANION_DATA_DB"]) || config["path"] || "var/companion_data.sqlite3"
        Igniter::Data::Stores::SQLite.new(path: resolve_storage_path(path))
      else
        raise ArgumentError, "Unsupported companion data adapter: #{adapter.inspect}"
      end
    rescue Igniter::Data::ConfigurationError => e
      warn "[companion] #{e.message} Falling back to in-memory data store."
      Igniter::Data::Stores::InMemory.new
    end

    def build_execution_store(app_name:)
      settings = persistence_settings(app_name)
      config = settings.fetch("execution", {})
      adapter = resolve_execution_adapter(config)

      case adapter
      when "memory"
        Igniter::Runtime::Stores::MemoryStore.new
      when "sqlite"
        path = presence(ENV["COMPANION_EXECUTION_DB"]) || config["path"] || "var/#{app_name}_executions.sqlite3"
        Igniter::Runtime::Stores::SQLiteStore.new(path: resolve_storage_path(path))
      when "redis"
        require "redis"

        url = presence(ENV["REDIS_URL"]) || config["url"] || config["redis_url"]
        namespace = config["namespace"] || "companion:executions"
        Igniter::Runtime::Stores::RedisStore.new(
          redis: Redis.new(url: url),
          namespace: namespace
        )
      else
        raise ArgumentError, "Unsupported companion execution adapter: #{adapter.inspect}"
      end
    rescue Igniter::Runtime::ConfigurationError => e
      warn "[companion] #{e.message} Falling back to in-memory execution store."
      Igniter::Runtime::Stores::MemoryStore.new
    rescue LoadError => e
      warn "[companion] #{e.message} Falling back to in-memory execution store."
      Igniter::Runtime::Stores::MemoryStore.new
    end

    def resolve_data_adapter(config)
      explicit = presence(ENV["COMPANION_DATA_ADAPTER"])
      return explicit if explicit

      return "sqlite" if presence(ENV["COMPANION_DATA_DB"])

      presence(config["adapter"]) || "memory"
    end

    def resolve_execution_adapter(config)
      explicit = presence(ENV["COMPANION_EXECUTION_ADAPTER"])
      return explicit if explicit

      return "sqlite" if presence(ENV["COMPANION_EXECUTION_DB"])
      return "redis" if presence(ENV["REDIS_URL"])

      presence(config["adapter"]) || "memory"
    end

    def load_yaml(path)
      return {} unless File.exist?(path)

      YAML.safe_load(File.read(path)) || {}
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

    def presence(value)
      stripped = value.to_s.strip
      stripped.empty? ? nil : stripped
    end
  end
end
