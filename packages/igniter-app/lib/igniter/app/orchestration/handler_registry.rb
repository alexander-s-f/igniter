# frozen_string_literal: true

module Igniter
  class App
    module Orchestration
      class HandlerRegistry
        class << self
          def register(action, handler = nil, queue: nil, &block)
            resolved_handler = handler || block
            raise ArgumentError, "orchestration handler registration requires a callable handler" unless resolved_handler

            registry[registry_key(action, queue: queue)] = resolved_handler
          end

          def fetch(action, queue: nil)
            if queue
              keyed = registry_key(action, queue: queue)
              return registry.fetch(keyed) if registry.key?(keyed)
            end

            registry.fetch(registry_key(action))
          end

          def registered?(action, queue: nil)
            registry.key?(registry_key(action, queue: queue))
          end

          def actions
            registry.keys.map { |key| key[:action] }.uniq
          end

          private

          def registry
            @registry ||= {}
          end

          def normalize_action(action)
            action.to_sym
          end

          def normalize_queue(queue)
            return nil if queue.nil?

            queue.to_s
          end

          def registry_key(action, queue: nil)
            {
              action: normalize_action(action),
              queue: normalize_queue(queue)
            }.freeze
          end
        end
      end
    end
  end
end
