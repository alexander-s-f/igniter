# frozen_string_literal: true

module Igniter
  module Contracts
    module Execution
      class EffectInvocation
        attr_reader :payload, :context, :profile

        def initialize(payload:, context:, profile:)
          @payload = payload
          @context = context.is_a?(NamedValues) ? context : NamedValues.new(context)
          @profile = profile
          freeze
        end
      end
    end
  end
end
