# frozen_string_literal: true

module Igniter
  class App
    module Orchestration
      class HandlerRegistry
        class << self
          def register(action, handler = nil, &block)
            resolved_handler = handler || block
            raise ArgumentError, "orchestration handler registration requires a callable handler" unless resolved_handler

            registry[normalize_action(action)] = resolved_handler
          end

          def fetch(action)
            registry.fetch(normalize_action(action))
          end

          def registered?(action)
            registry.key?(normalize_action(action))
          end

          def actions
            registry.keys
          end

          private

          def registry
            @registry ||= {}
          end

          def normalize_action(action)
            action.to_sym
          end
        end
      end
    end
  end
end
