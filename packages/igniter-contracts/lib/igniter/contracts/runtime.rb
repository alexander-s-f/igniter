# frozen_string_literal: true

module Igniter
  module Contracts
    class Runtime
      class << self
        def execute(compiled_graph, inputs:, profile:)
          validate_profile!(compiled_graph, profile: profile)

          state = {}
          outputs = {}

          compiled_graph.operations.each do |operation|
            handler = profile.runtime_handler(operation.fetch(:kind))
            value = handler.call(operation: operation, state: state, outputs: outputs, inputs: inputs, profile: profile)
            state[operation.fetch(:name)] = value unless operation.fetch(:kind) == :output
            outputs[operation.fetch(:name)] = value if operation.fetch(:kind) == :output
          end

          ExecutionResult.new(
            state: state,
            outputs: outputs,
            profile_fingerprint: profile.fingerprint
          )
        end

        private

        def validate_profile!(compiled_graph, profile:)
          return if compiled_graph.profile_fingerprint == profile.fingerprint

          raise ProfileMismatchError,
                "compiled graph fingerprint #{compiled_graph.profile_fingerprint} does not match profile #{profile.fingerprint}"
        end
      end
    end
  end
end
