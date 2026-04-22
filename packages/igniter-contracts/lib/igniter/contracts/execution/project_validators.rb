# frozen_string_literal: true

module Igniter
  module Contracts
    module Execution
      module ProjectValidators
        module_function

        def validate_project_sources(operations:, profile: nil) # rubocop:disable Lint/UnusedMethodArgument
          available = operations.reject(&:output?).map(&:name)
          missing = operations.select { |operation| operation.kind == :project }
                              .map { |operation| operation.attributes.fetch(:from).to_sym }
                              .reject { |name| available.include?(name) }
                              .uniq
          return if missing.empty?

          raise ValidationError.new(
            findings: [ValidationFinding.new(
              code: :missing_project_sources,
              message: "project sources are not defined: #{missing.map(&:to_s).join(', ')}",
              subjects: missing
            )]
          )
        end
      end
    end
  end
end
