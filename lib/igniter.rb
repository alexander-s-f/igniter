# frozen_string_literal: true

require_relative "igniter/version"
require_relative "igniter/errors"
require_relative "igniter/type_system"
require_relative "igniter/executor"
require_relative "igniter/executor_registry"
require_relative "igniter/effect"
require_relative "igniter/effect_registry"
require_relative "igniter/model"
require_relative "igniter/compiler"
require_relative "igniter/events"
require_relative "igniter/runtime"
require_relative "igniter/dsl"
require_relative "igniter/extensions"
require_relative "igniter/diagnostics"
require_relative "igniter/contract"

module Igniter
  class << self
    def executor_registry
      @executor_registry ||= ExecutorRegistry.new
    end

    def execution_store
      @execution_store ||= Runtime::Stores::MemoryStore.new
    end

    def execution_store=(store)
      @execution_store = store
    end

    # TTL cache backend for compute nodes. nil = disabled (default).
    # Set to Igniter::NodeCache::Memory.new (or a Redis-backed equivalent).
    def node_cache
      defined?(Igniter::NodeCache) ? Igniter::NodeCache.cache : nil
    end

    def node_cache=(cache)
      require_relative "igniter/node_cache"
      Igniter::NodeCache.cache = cache
    end

    # When true, auto-creates a CoalescingLock alongside the configured node cache.
    def node_coalescing=(enabled)
      require_relative "igniter/node_cache"
      Igniter::NodeCache.coalescing_lock = enabled ? Igniter::NodeCache::CoalescingLock.new : nil
    end

    def register_executor(key, executor_class, **metadata)
      executor_registry.register(key, executor_class, **metadata)
    end

    def effect_registry
      @effect_registry ||= EffectRegistry.new
    end

    def register_effect(key, adapter_class, **metadata)
      effect_registry.register(key, adapter_class, **metadata)
    end

    def compile(&block)
      DSL::ContractBuilder.compile(&block)
    end

    def compile_schema(schema, name: nil)
      DSL::SchemaBuilder.compile(schema, name: name)
    end

    def configure
      yield self
    end
  end
end
