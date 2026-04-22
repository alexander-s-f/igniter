# frozen_string_literal: true

module Igniter
  module Contracts
    module Execution
      module InlineExecutor
        module_function

        def call(compiled_graph:, inputs:, profile:, runtime:)
          runtime.execute(compiled_graph, inputs: inputs, profile: profile)
        end
      end
    end
  end
end
