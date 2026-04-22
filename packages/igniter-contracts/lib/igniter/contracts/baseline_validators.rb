# frozen_string_literal: true

module Igniter
  module Contracts
    module BaselineValidators
      module_function

      UNSUPPORTED_BASELINE_RUNTIME_KINDS = %i[composition branch collection].freeze

      def validate_uniqueness(operations:, profile: nil) # rubocop:disable Lint/UnusedMethodArgument
        names = operations.reject { |operation| operation.fetch(:kind) == :output }.map { |operation| operation.fetch(:name) }
        duplicates = names.group_by(&:itself).select { |_name, entries| entries.length > 1 }.keys
        return if duplicates.empty?

        raise ValidationError, "duplicate node names: #{duplicates.map(&:to_s).join(', ')}"
      end

      def validate_outputs(operations:, profile: nil) # rubocop:disable Lint/UnusedMethodArgument
        available = operations.reject { |operation| operation.fetch(:kind) == :output }.map { |operation| operation.fetch(:name) }
        missing = operations.select { |operation| operation.fetch(:kind) == :output }
                            .map { |operation| operation.fetch(:name) }
                            .reject { |name| available.include?(name) }
        return if missing.empty?

        raise ValidationError, "output targets are not defined: #{missing.map(&:to_s).join(', ')}"
      end

      def validate_dependencies(operations:, profile: nil) # rubocop:disable Lint/UnusedMethodArgument
        available = operations.reject { |operation| operation.fetch(:kind) == :output }.map { |operation| operation.fetch(:name) }
        missing = operations.select { |operation| operation.fetch(:kind) == :compute }
                            .flat_map { |operation| Array(operation.dig(:attributes, :depends_on)) }
                            .map(&:to_sym)
                            .reject { |name| available.include?(name) }
                            .uniq
        return if missing.empty?

        raise ValidationError, "compute dependencies are not defined: #{missing.map(&:to_s).join(', ')}"
      end

      def validate_callables(operations:, profile: nil) # rubocop:disable Lint/UnusedMethodArgument
        missing = operations.select { |operation| operation.fetch(:kind) == :compute }
                            .reject { |operation| operation.dig(:attributes, :callable).respond_to?(:call) }
                            .map { |operation| operation.fetch(:name) }
        return if missing.empty?

        raise ValidationError, "compute nodes require a callable: #{missing.map(&:to_s).join(', ')}"
      end

      def validate_types(operations:, profile: nil) # rubocop:disable Lint/UnusedMethodArgument
        operations
      end

      def validate_supported_baseline_runtime(operations:, profile: nil) # rubocop:disable Lint/UnusedMethodArgument
        unsupported = operations.select { |operation| UNSUPPORTED_BASELINE_RUNTIME_KINDS.include?(operation.fetch(:kind)) }
                                .map { |operation| operation.fetch(:kind) }
                                .uniq
        return if unsupported.empty?

        raise ValidationError,
              "baseline runtime does not support node kinds yet: #{unsupported.map(&:to_s).join(', ')}"
      end
    end
  end
end
