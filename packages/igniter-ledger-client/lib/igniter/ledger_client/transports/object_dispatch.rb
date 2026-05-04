# frozen_string_literal: true

module Igniter
  module LedgerClient
    module Transports
      class ObjectDispatch
        def initialize(target)
          @target = target
        end

        def dispatch(envelope)
          if @target.respond_to?(:dispatch)
            @target.dispatch(envelope)
          elsif @target.respond_to?(:wire)
            @target.wire.dispatch(envelope)
          else
            raise ArgumentError, "object does not expose dispatch(envelope) or wire.dispatch(envelope)"
          end
        end

        def close
          @target.close if @target.respond_to?(:close)
        end
      end
    end
  end
end
