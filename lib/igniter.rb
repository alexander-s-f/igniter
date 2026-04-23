# frozen_string_literal: true

require_relative "igniter/monorepo_packages"
require_relative "igniter/version"

require "igniter/core/errors"
require "igniter/core/type_system"
require "igniter/core/executor"
require "igniter/core/executor_registry"
require "igniter/core/effect"
require "igniter/core/effect_registry"
require "igniter/core/model"
require "igniter/core/compiler"
require "igniter/core/events"
require "igniter/runtime"
require "igniter/core/dsl"
require "igniter/core/extensions"
require "igniter/diagnostics"
require "igniter/contract"

module Igniter
  class << self
    def use(*names)
      require "igniter/sdk"

      @sdk_capabilities ||= []
      resolved_names = names.flatten.map(&:to_sym)
      SDK.activate!(*resolved_names, layer: :core)
      @sdk_capabilities |= resolved_names
      self
    end

    def sdk_capabilities
      @sdk_capabilities ||= []
    end

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
      require "igniter/core/node_cache"
      Igniter::NodeCache.cache = cache
    end

    # When true, auto-creates a CoalescingLock alongside the configured node cache.
    def node_coalescing=(enabled)
      require "igniter/core/node_cache"
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
