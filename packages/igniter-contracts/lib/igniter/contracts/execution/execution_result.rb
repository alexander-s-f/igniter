# frozen_string_literal: true

module Igniter
  module Contracts
    module Execution
      class ExecutionResult
        attr_reader :state, :outputs, :profile_fingerprint

        def initialize(state:, outputs:, profile_fingerprint:)
          @state = state
          @outputs = outputs
          @profile_fingerprint = profile_fingerprint
          freeze
        end

        def output(name)
          outputs.fetch(name.to_sym)
        end

        def to_h
          {
            state: state.to_h,
            outputs: outputs.to_h,
            profile_fingerprint: profile_fingerprint
          }
        end
      end
    end
  end
end
