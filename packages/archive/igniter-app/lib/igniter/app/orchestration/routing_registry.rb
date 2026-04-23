# frozen_string_literal: true

module Igniter
  class App
    module Orchestration
      class RoutingRegistry
        class << self
          def register(action, routing = nil, &block)
            resolved_routing = routing || block
            raise ArgumentError, "orchestration routing registration requires a routing hash or builder" unless resolved_routing

            registry[normalize_action(action)] = resolved_routing
          end

          def fetch(action)
            resolved = registry.fetch(normalize_action(action))
            normalize_routing(resolved.respond_to?(:call) ? resolved.call : resolved)
          end

          def registered?(action)
            registry.key?(normalize_action(action))
          end

          private

          def registry
            @registry ||= {}
          end

          def normalize_action(action)
            action.to_sym
          end

          def normalize_routing(routing)
            routing.each_with_object({}) do |(key, value), memo|
              memo[key.to_sym] = value
            end.freeze
          end
        end
      end
    end
  end
end
