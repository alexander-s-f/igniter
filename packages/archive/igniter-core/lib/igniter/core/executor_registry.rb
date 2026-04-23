# frozen_string_literal: true

require_relative "legacy"
Igniter::Core::Legacy.require!("igniter/core/executor_registry")
module Igniter
  class ExecutorRegistry
    Definition = Struct.new(:key, :executor_class, :metadata, keyword_init: true)

    def initialize
      @definitions = {}
    end

    def register(key, executor_class, **metadata)
      normalized_key = key.to_s
      raise CompileError, "executor registry key cannot be empty" if normalized_key.empty?

      unless executor_class.is_a?(Class) && executor_class <= Igniter::Executor
        raise CompileError, "Executor registry key '#{normalized_key}' must reference an Igniter::Executor subclass"
      end

      @definitions[normalized_key] = Definition.new(
        key: normalized_key,
        executor_class: executor_class,
        metadata: executor_class.executor_metadata.merge(metadata).merge(key: normalized_key)
      )
    end

    def fetch(key)
      @definitions.fetch(key.to_s)
    rescue KeyError
      raise CompileError, "Unknown executor registry key: #{key}"
    end

    def registered?(key)
      @definitions.key?(key.to_s)
    end

    def definitions
      @definitions.values.sort_by(&:key)
    end

    def clear
      @definitions.clear
    end
  end
end
