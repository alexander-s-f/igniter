# frozen_string_literal: true

module Igniter
  module Contracts
    module Assembly
      module HookResultPolicies
        module_function

        def operations_array(result)
          return "must return an Array of operations" unless result.is_a?(Array)

          result.each_with_index do |operation, index|
            message = validate_operation(operation)
            return "must return an Array of operations; element #{index} #{message}" if message
          end

          nil
        end

        def validate_operation(operation)
          return "is not a Hash" unless operation.is_a?(Hash)
          return "must include :kind" unless operation.key?(:kind)
          return "must include :name" unless operation.key?(:name)
          return "must include :attributes" unless operation.key?(:attributes)
          return "must use Symbol :kind" unless operation[:kind].is_a?(Symbol)
          return "must use Symbol :name" unless operation[:name].is_a?(Symbol)
          return "must use Hash :attributes" unless operation[:attributes].is_a?(Hash)

          nil
        end
      end
    end
  end
end
