# frozen_string_literal: true

module Igniter
  class App
    module Orchestration
      class PolicyRegistry
        class << self
          def register(action, policy = nil, queue: nil, &block)
            resolved_policy = policy || block
            raise ArgumentError, "orchestration policy registration requires a policy object or builder" unless resolved_policy

            registry[registry_key(action, queue: queue)] = resolved_policy
          end

          def fetch(action, queue: nil)
            if queue
              keyed = registry_key(action, queue: queue)
              return resolve_policy(registry.fetch(keyed)) if registry.key?(keyed)
            end

            resolved = registry.fetch(registry_key(action))
            resolve_policy(resolved)
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

          def resolve_policy(resolved)
            resolved.respond_to?(:call) ? resolved.call : resolved
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
