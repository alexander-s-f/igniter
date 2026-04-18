# frozen_string_literal: true

require "securerandom"
require "time"

module Igniter
  class App
    module Evolution
      class Trail
        attr_reader :app_class, :store

        def initialize(app_class:, store: nil, clock: -> { Time.now.utc.iso8601 })
          @app_class = app_class
          @store = store
          @clock = clock
          @events = Array(store&.load_events).map { |event| normalize_loaded_event(event).freeze }
        end

        def record(type, source:, payload: {})
          event = {
            event_id: SecureRandom.uuid,
            type: type.to_sym,
            source: source.to_sym,
            app: app_class.name,
            timestamp: @clock.call,
            payload: deep_dup(payload)
          }.freeze

          @events << event
          store&.append(event)
          prune_retained_events!
          event
        end

        def events(limit: nil)
          selected = limit ? @events.last(limit) : @events
          selected.map(&:dup)
        end

        def snapshot(limit: 10)
          selected = events(limit: limit)

          {
            total: @events.size,
            latest_type: @events.last&.dig(:type),
            latest_at: @events.last&.dig(:timestamp),
            by_type: @events.each_with_object(Hash.new(0)) { |event, memo| memo[event[:type]] += 1 },
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

        def normalize_loaded_event(event)
          loaded = deep_dup(event)
          loaded[:type] = loaded[:type]&.to_sym
          loaded[:source] = loaded[:source]&.to_sym
          loaded
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
