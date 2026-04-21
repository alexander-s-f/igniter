# frozen_string_literal: true

require "securerandom"
require "time"

module Igniter
  class App
    module Credentials
      class Trail
        attr_reader :store

        def initialize(store: nil, clock: -> { Time.now.utc.iso8601 })
          @store = store
          @clock = clock
          @events = Array(store&.load_events).map { |event| normalize_loaded_event(event).freeze }
        end

        def record(event = nil, **attributes)
          canonical_event =
            if event
              normalize_event(event)
            else
              build_event(attributes)
            end

          payload = canonical_event.to_h.merge(event_id: SecureRandom.uuid).freeze

          @events << payload
          store&.append(payload)
          prune_retained_events!
          payload
        end

        def events(limit: nil)
          selected = limit ? @events.last(limit) : @events
          selected.map(&:dup)
        end

        def latest_event
          @events.last&.dup
        end

        def snapshot(limit: 10)
          selected = events(limit: limit)

          {
            total: @events.size,
            latest_type: @events.last&.dig(:event),
            latest_status: @events.last&.dig(:status),
            latest_at: @events.last&.dig(:timestamp),
            by_event: @events.each_with_object(Hash.new(0)) { |event, memo| memo[event[:event]] += 1 },
            by_status: @events.each_with_object(Hash.new(0)) { |event, memo| memo[event[:status]] += 1 },
            by_policy: counts_for(:policy_name),
            by_credential: counts_for(:credential_key),
            by_target_node: counts_for(:target_node),
            persistence: persistence_metadata,
            events: selected
          }
        end

        def clear!
          @events.clear
          store&.clear!
          self
        end

        private

        def build_event(attributes)
          Events::CredentialEvent.new(
            timestamp: @clock.call,
            **attributes
          )
        end

        def normalize_event(value)
          case value
          when Events::CredentialEvent
            value
          when Hash
            Events::CredentialEvent.from_h(value)
          else
            raise ArgumentError, "event must be a CredentialEvent or Hash"
          end
        end

        def normalize_loaded_event(event)
          canonical = normalize_event(event).to_h.each_with_object({}) do |(key, value), memo|
            memo[key] = value
          end
          event_id = event[:event_id] || event["event_id"]
          canonical[:event_id] = event_id if event_id
          canonical
        end

        def counts_for(key)
          @events.each_with_object(Hash.new(0)) do |event, memo|
            value = event[key]
            next if value.nil?

            memo[value] += 1
          end
        end

        def persistence_metadata
          return { enabled: false } unless store

          return store.persistence_metadata if store.respond_to?(:persistence_metadata)

          {
            enabled: true,
            store_class: store.class.name,
            path: store.respond_to?(:path) ? store.path : nil
          }.compact
        end

        def prune_retained_events!
          if store&.respond_to?(:prune_events)
            @events = store.prune_events(@events).map(&:freeze)
            return
          end

          limit = store&.respond_to?(:retained_limit) ? store.retained_limit : nil
          return unless limit && limit.positive?
          return if @events.size <= limit

          @events.shift(@events.size - limit)
        end
      end
    end
  end
end
