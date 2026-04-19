# frozen_string_literal: true

module Igniter
  class App
    module Orchestration
      class PolicyRegistry
        class << self
          def register(action, policy = nil, &block)
            resolved_policy = policy || block
            raise ArgumentError, "orchestration policy registration requires a policy object or builder" unless resolved_policy

            registry[normalize_action(action)] = resolved_policy
          end

          def fetch(action)
            resolved = registry.fetch(normalize_action(action))
            resolved.respond_to?(:call) ? resolved.call : resolved
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
