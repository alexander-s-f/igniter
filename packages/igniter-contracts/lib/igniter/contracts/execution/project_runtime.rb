# frozen_string_literal: true

module Igniter
  module Contracts
    module Execution
      module ProjectRuntime
        module_function

        def handle_project(operation:, state:, **)
          from = operation.attributes.fetch(:from).to_sym
          key = operation.attributes.fetch(:key).to_sym
          source = state.fetch(from)

          if source.respond_to?(:key?) && source.key?(key)
            source.fetch(key)
          elsif source.respond_to?(:key?) && source.key?(key.to_s)
            source.fetch(key.to_s)
          else
            raise KeyError, "project key #{key} not present in #{from}"
          end
        end
      end
    end
  end
end
