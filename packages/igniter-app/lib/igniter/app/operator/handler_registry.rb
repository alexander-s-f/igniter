# frozen_string_literal: true

module Igniter
  class App
    module Operator
      class HandlerRegistry
        class << self
          def register(kind, handler = nil, &block)
            resolved_handler = handler || block
            raise ArgumentError, "operator handler registration requires a callable handler" unless resolved_handler

            registry[normalize_kind(kind)] = resolved_handler
          end

          def fetch(kind)
            registry.fetch(normalize_kind(kind))
          end

          def registered?(kind)
            registry.key?(normalize_kind(kind))
          end

          def kinds
            registry.keys
          end

          private

          def registry
            @registry ||= {}
          end

          def normalize_kind(kind)
            kind.to_sym
          end
        end
      end
    end
  end
end
