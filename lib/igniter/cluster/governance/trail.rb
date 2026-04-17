# frozen_string_literal: true

require "securerandom"
require "time"

module Igniter
  module Cluster
    module Governance
      class Trail
        def initialize(clock: -> { Time.now.utc.iso8601 })
          @clock = clock
          @events = []
        end

        def record(type, source:, payload: {})
          event = {
            event_id: SecureRandom.uuid,
            type: type.to_sym,
            source: source.to_sym,
            timestamp: @clock.call,
            payload: deep_dup(payload)
          }.freeze

          @events << event
          event
        end

        def events(limit: nil)
          selected = limit ? @events.last(limit) : @events
          selected.map(&:dup)
        end

        def snapshot(limit: 10)
          {
            total: @events.size,
            latest_type: @events.last&.dig(:type),
            latest_at: @events.last&.dig(:timestamp),
            by_type: @events.each_with_object(Hash.new(0)) { |event, memo| memo[event[:type]] += 1 },
            events: events(limit: limit)
          }
        end

        def clear!
          @events.clear
          self
        end

        private

        def deep_dup(value)
          case value
          when Hash
            value.each_with_object({}) do |(key, nested), memo|
              memo[key] = deep_dup(nested)
            end
          when Array
            value.map { |item| deep_dup(item) }
          else
            value
          end
        end
      end
    end
  end
end
