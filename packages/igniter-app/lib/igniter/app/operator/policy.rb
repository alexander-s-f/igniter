# frozen_string_literal: true

module Igniter
  class App
    module Operator
      class Policy
        attr_reader :name, :default_operation, :allowed_operations, :runtime_completion,
                    :description, :lifecycle_operations, :operation_aliases,
                    :default_routing, :operation_lifecycle, :execution_operations

        def initialize(name:, default_operation:, allowed_operations:, runtime_completion:,
                       description:, lifecycle_operations:, operation_aliases: {},
                       default_routing: {}, operation_lifecycle: nil, execution_operations: nil)
          @name = name.to_sym
          @default_operation = default_operation.to_sym
          @allowed_operations = Array(allowed_operations).map(&:to_sym).freeze
          @runtime_completion = runtime_completion.to_sym
          @description = description.to_s
          @lifecycle_operations = Array(lifecycle_operations).map(&:to_sym).freeze
          @operation_aliases = normalize_aliases(operation_aliases)
          @default_routing = normalize_routing(default_routing)
          @operation_lifecycle = normalize_map(operation_lifecycle)
          @execution_operations = normalize_map(execution_operations)
          freeze
        end

        def self.from_h(policy_hash)
          normalized = policy_hash.each_with_object({}) do |(key, value), memo|
            memo[key.to_sym] = value
          end

          new(
            name: normalized.fetch(:name),
            default_operation: normalized.fetch(:default_operation),
            allowed_operations: normalized.fetch(:allowed_operations),
            runtime_completion: normalized.fetch(:runtime_completion),
            description: normalized.fetch(:description),
            lifecycle_operations: normalized.fetch(:lifecycle_operations),
            operation_aliases: normalized.fetch(:operation_aliases, {}),
            default_routing: normalized.fetch(:default_routing, {}),
            operation_lifecycle: normalized.fetch(:operation_lifecycle, nil),
            execution_operations: normalized.fetch(:execution_operations, nil)
          )
        end

        def allows_operation?(operation)
          normalized = operation.to_sym
          canonical = canonical_operation_for(normalized)
          allowed_operations.include?(normalized) ||
            allowed_operations.include?(canonical) ||
            lifecycle_operations.include?(normalized) ||
            lifecycle_operations.include?(canonical)
        end

        def canonical_operation_for(operation)
          operation_aliases.fetch(operation.to_sym, operation.to_sym)
        end

        def lifecycle_operation_for(operation)
          normalized = operation.to_sym
          canonical = canonical_operation_for(normalized)
          operation_lifecycle.fetch(canonical, operation_lifecycle.fetch(normalized, canonical))
        end

        def execution_operation_for(operation)
          normalized = operation.to_sym
          canonical = canonical_operation_for(normalized)
          execution_operations.fetch(canonical, execution_operations.fetch(normalized, canonical))
        end

        def default_lifecycle_operation
          lifecycle_operation_for(default_operation)
        end

        def default_execution_operation
          execution_operation_for(default_operation)
        end

        def with(**overrides)
          merged_operation_aliases =
            if overrides.key?(:operation_aliases)
              operation_aliases.merge(normalize_aliases(overrides[:operation_aliases]))
            else
              operation_aliases
            end

          merged_default_routing =
            if overrides.key?(:default_routing)
              default_routing.merge(normalize_routing(overrides[:default_routing]))
            else
              default_routing
            end

          merged_operation_lifecycle =
            if overrides.key?(:operation_lifecycle)
              operation_lifecycle.merge(normalize_map(overrides[:operation_lifecycle]))
            else
              operation_lifecycle
            end

          merged_execution_operations =
            if overrides.key?(:execution_operations)
              execution_operations.merge(normalize_map(overrides[:execution_operations]))
            else
              execution_operations
            end

          Policy.new(
            name: overrides.fetch(:name, name),
            default_operation: overrides.fetch(:default_operation, default_operation),
            allowed_operations: overrides.fetch(:allowed_operations, allowed_operations),
            lifecycle_operations: overrides.fetch(:lifecycle_operations, lifecycle_operations),
            operation_aliases: merged_operation_aliases,
            default_routing: merged_default_routing,
            operation_lifecycle: merged_operation_lifecycle,
            execution_operations: merged_execution_operations,
            runtime_completion: overrides.fetch(:runtime_completion, runtime_completion),
            description: overrides.fetch(:description, description)
          )
        end

        def to_h
          {
            name: name,
            default_operation: default_operation,
            allowed_operations: allowed_operations,
            lifecycle_operations: lifecycle_operations,
            operation_aliases: operation_aliases,
            operation_lifecycle: operation_lifecycle,
            execution_operations: execution_operations,
            default_routing: default_routing,
            runtime_completion: runtime_completion,
            description: description
          }.freeze
        end

        private

        def normalize_aliases(operation_aliases)
          normalize_map(operation_aliases)
        end

        def normalize_routing(routing)
          routing.each_with_object({}) do |(key, value), memo|
            memo[key.to_sym] = value
          end.freeze
        end

        def normalize_map(mapping)
          (mapping || {}).each_with_object({}) do |(key, value), memo|
            memo[key.to_sym] = value.to_sym
          end.freeze
        end
      end
    end
  end
end
