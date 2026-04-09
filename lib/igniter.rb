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
