# frozen_string_literal: true

module Igniter
  module Contracts
    module Execution
      module ProjectValidators
        module_function

        def validate_project_sources(operations:, profile: nil) # rubocop:disable Lint/UnusedMethodArgument
          available = operations.reject { |operation| operation.fetch(:kind) == :output }.map { |operation| operation.fetch(:name) }
          missing = operations.select { |operation| operation.fetch(:kind) == :project }
                              .map { |operation| operation.dig(:attributes, :from).to_sym }
                              .reject { |name| available.include?(name) }
                              .uniq
          return if missing.empty?

          raise ValidationError, "project sources are not defined: #{missing.map(&:to_s).join(', ')}"
        end
      end
    end
  end
end
