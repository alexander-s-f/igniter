# frozen_string_literal: true

module Igniter
  class App
    module Orchestration
      class LaneRegistry
        class << self
          def register(action, lane:, queue: nil, channel: nil, routing: nil, policy: nil, handler: nil, description: nil)
            normalized_routing = normalize_routing(routing || {})
            normalized_queue = queue || normalized_routing[:queue]
            normalized_channel = channel || normalized_routing[:channel]

            registry[registry_key(action, lane: lane)] = {
              action: normalize_action(action),
              name: normalize_lane(lane),
              queue: normalize_queue(normalized_queue),
              channel: normalized_channel,
              routing: normalized_routing.merge(
                queue: normalize_queue(normalized_queue),
                channel: normalized_channel
              ).compact.freeze,
              policy: normalize_policy(policy),
              handler: normalize_handler(handler),
              description: description&.to_s
            }.freeze
          end

          def fetch(action, lane: nil, queue: nil)
            entry = find(action, lane: lane, queue: queue)
            raise KeyError, "orchestration lane not registered for #{action.inspect}#{lane ? " lane=#{lane.inspect}" : ""}#{queue ? " queue=#{queue.inspect}" : ""}" unless entry

            entry
          end

          def find(action, lane: nil, queue: nil)
            if lane
              keyed = registry_key(action, lane: lane)
              return registry[keyed] if registry.key?(keyed)
            end

            normalized_queue = normalize_queue(queue)
            return nil unless normalized_queue

            lanes(action).find { |entry| entry[:queue] == normalized_queue }
          end

          def lanes(action)
            normalized_action = normalize_action(action)
            registry.values.select { |entry| entry[:action] == normalized_action }
          end

          private

          def registry
            @registry ||= {}
          end

          def normalize_action(action)
            action.to_sym
          end

          def normalize_lane(lane)
            lane.to_sym
          end

          def normalize_queue(queue)
            return nil if queue.nil?

            queue.to_s
          end

          def normalize_routing(routing)
            routing.each_with_object({}) do |(key, value), memo|
              memo[key.to_sym] = value
            end.freeze
          end

          def normalize_policy(policy)
            return nil unless policy

            policy.respond_to?(:name) ? policy.name.to_sym : policy
          end

          def normalize_handler(handler)
            return nil unless handler

            handler.class.name || handler.class.to_s
          end

          def registry_key(action, lane:)
            {
              action: normalize_action(action),
              lane: normalize_lane(lane)
            }.freeze
          end
        end
      end
    end
  end
end
