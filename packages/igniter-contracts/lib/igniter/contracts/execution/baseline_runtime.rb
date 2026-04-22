# frozen_string_literal: true

module Igniter
  module Contracts
    module Execution
      module BaselineRuntime
        module_function

        def handle_input(operation:, inputs:, **)
          inputs.fetch(operation.name)
        end

        def handle_compute(operation:, state:, **)
          callable = operation.attributes[:callable]
          dependencies = Array(operation.attributes[:depends_on])
          kwargs = dependencies.each_with_object({}) do |dependency, memo|
            memo[dependency.to_sym] = state.fetch(dependency.to_sym)
          end
          callable.call(**kwargs)
        end

        def handle_output(operation:, state:, **)
          state.fetch(operation.name)
        end

        def unsupported(kind)
          lambda do |**|
            raise NotImplementedError, "#{kind} runtime handler is not implemented in the baseline runtime yet"
          end
        end
      end
    end
  end
end
