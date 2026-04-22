# frozen_string_literal: true

module Igniter
  module Contracts
    module Execution
      module BaselineNormalizers
        module_function

        def normalize_operation_attributes(operations:, profile: nil) # rubocop:disable Lint/UnusedMethodArgument
          operations.map do |operation|
            attributes = operation.fetch(:attributes)
            normalized_attributes = attributes.dup

            if normalized_attributes.key?(:depends_on)
              normalized_attributes[:depends_on] = Array(normalized_attributes[:depends_on]).map(&:to_sym)
            end

            operation.merge(attributes: normalized_attributes.freeze).freeze
          end
        end
      end
    end
  end
end
