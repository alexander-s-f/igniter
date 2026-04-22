# frozen_string_literal: true

module Igniter
  module Contracts
    module Execution
      module BaselineValidators
        module_function

        UNSUPPORTED_BASELINE_RUNTIME_KINDS = %i[composition branch collection].freeze

        def validate_uniqueness(operations:, profile: nil) # rubocop:disable Lint/UnusedMethodArgument
          names = operations.reject(&:output?).map(&:name)
          duplicates = names.group_by(&:itself).select { |_name, entries| entries.length > 1 }.keys
          return if duplicates.empty?

          raise ValidationError, "duplicate node names: #{duplicates.map(&:to_s).join(', ')}"
        end

        def validate_outputs(operations:, profile: nil) # rubocop:disable Lint/UnusedMethodArgument
          available = operations.reject(&:output?).map(&:name)
          missing = operations.select(&:output?)
                              .map(&:name)
                              .reject { |name| available.include?(name) }
          return if missing.empty?

          raise ValidationError, "output targets are not defined: #{missing.map(&:to_s).join(', ')}"
        end

        def validate_dependencies(operations:, profile: nil) # rubocop:disable Lint/UnusedMethodArgument
          available = operations.reject(&:output?).map(&:name)
          missing = operations.select { |operation| operation.kind == :compute }
                              .flat_map { |operation| Array(operation.attributes[:depends_on]) }
                              .map(&:to_sym)
                              .reject { |name| available.include?(name) }
                              .uniq
          return if missing.empty?

          raise ValidationError, "compute dependencies are not defined: #{missing.map(&:to_s).join(', ')}"
        end

        def validate_callables(operations:, profile: nil) # rubocop:disable Lint/UnusedMethodArgument
          missing = operations.select { |operation| operation.kind == :compute }
                              .reject { |operation| operation.attributes[:callable].respond_to?(:call) }
                              .map(&:name)
          return if missing.empty?

          raise ValidationError, "compute nodes require a callable: #{missing.map(&:to_s).join(', ')}"
        end

        def validate_types(operations:, profile: nil) # rubocop:disable Lint/UnusedMethodArgument
          operations
        end

        def validate_supported_baseline_runtime(operations:, profile: nil) # rubocop:disable Lint/UnusedMethodArgument
          unsupported = operations.select { |operation| UNSUPPORTED_BASELINE_RUNTIME_KINDS.include?(operation.kind) }
                                  .map(&:kind)
                                  .uniq
          return if unsupported.empty?

          raise ValidationError,
                "baseline runtime does not support node kinds yet: #{unsupported.map(&:to_s).join(', ')}"
        end
      end
    end
  end
end
