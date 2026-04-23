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

        def snapshot(limit: 10, filters: nil, order_by: nil, direction: :asc)
          selected = apply_query(filters: filters, order_by: order_by, direction: direction)
          limited = selected.first(limit)

          {
            query: {
              filters: compact_filters(filters),
              order_by: order_by&.to_sym,
              direction: direction&.to_sym,
              limit: limit
            }.freeze,
            total: selected.size,
            latest_type: selected.last&.dig(:event),
            latest_status: selected.last&.dig(:status),
            latest_at: selected.last&.dig(:timestamp),
            by_event: counts_for(:event, selected),
            by_status: counts_for(:status, selected),
            by_policy: counts_for(:policy_name, selected),
            by_credential: counts_for(:credential_key, selected),
            by_target_node: counts_for(:target_node, selected),
            persistence: persistence_metadata,
            events: limited.map(&:dup)
          }
        end

        def lease_request_snapshot(limit: 10, filters: nil, order_by: nil, direction: :asc)
          requests = apply_request_query(filters: filters, order_by: order_by, direction: direction)
          limited = requests.first(limit)

          {
            query: {
              filters: compact_filters(filters),
              order_by: order_by&.to_sym,
              direction: direction&.to_sym,
              limit: limit
            }.freeze,
            total: requests.size,
            latest_request_id: requests.last&.dig(:request_id),
            latest_event: requests.last&.dig(:latest_event),
            latest_status: requests.last&.dig(:status),
            latest_at: requests.last&.dig(:latest_at),
            by_event: counts_for(:latest_event, requests),
            by_status: counts_for(:status, requests),
            by_policy: counts_for(:policy_name, requests),
            by_credential: counts_for(:credential_key, requests),
            by_target_node: counts_for(:target_node, requests),
            persistence: persistence_metadata,
            requests: limited.map(&:dup)
          }.freeze
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

        def counts_for(key, events)
          Array(events).each_with_object(Hash.new(0)) do |event, memo|
            value = event[key]
            next if value.nil?

            memo[value] += 1
          end
        end

        def apply_query(filters:, order_by:, direction:)
          filtered = apply_filters(@events, filters)
          apply_order(filtered, order_by: order_by, direction: direction)
        end

        def apply_request_query(filters:, order_by:, direction:)
          filtered = apply_filters(lease_request_records, filters)
          apply_order(filtered, order_by: order_by, direction: direction)
        end

        def apply_filters(events, filters)
          return Array(events) if filters.nil? || filters.empty?

          filters.each_with_object(Array(events)) do |(key, value), memo|
            next if value.nil? || (value.respond_to?(:empty?) && value.empty?)

            allowed = Array(value)
            memo.select! do |event|
              event_value = event[key.to_sym]
              allowed.include?(event_value)
            end
          end
        end

        def apply_order(events, order_by:, direction:)
          return Array(events) if order_by.nil?

          sorted = Array(events).sort_by do |event|
            value = event[order_by.to_sym]
            value.is_a?(Symbol) ? value.to_s : value.to_s
          end
          direction.to_sym == :desc ? sorted.reverse : sorted
        end

        def compact_filters(filters)
          (filters || {}).each_with_object({}) do |(key, value), memo|
            next if value.nil? || (value.respond_to?(:empty?) && value.empty?)

            memo[key.to_sym] = Array(value)
          end.freeze
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

        def lease_request_records
          grouped = Hash.new { |hash, key| hash[key] = [] }

          @events.each do |event|
            next unless event[:event].to_s.start_with?("lease_")

            grouped[request_id_for(event)] << event
          end

          grouped.each_value.map do |events|
            build_request_record(events)
          end
        end

        def build_request_record(events)
          ordered_events = Array(events).sort_by { |event| event[:timestamp].to_s }
          latest = ordered_events.last || {}
          first = ordered_events.first || {}
          metadata = latest.fetch(:metadata, {})

          {
            request_id: request_id_for(latest),
            credential_key: latest[:credential_key],
            policy_name: latest[:policy_name],
            node: latest[:node] || first[:node],
            target_node: latest[:target_node] || first[:target_node],
            actor: latest[:actor],
            origin: latest[:origin],
            source: latest[:source],
            reason: latest[:reason],
            lease_id: latest[:lease_id],
            requested_scope: metadata[:requested_scope],
            credential_provider: metadata[:credential_provider],
            latest_event: latest[:event],
            status: latest[:status],
            latest_at: latest[:timestamp],
            requested_at: first[:timestamp],
            events_count: ordered_events.size,
            events: ordered_events.map(&:dup)
          }.compact.freeze
        end

        def request_id_for(event)
          metadata = event.fetch(:metadata, {})
          metadata[:request_id] || event[:lease_id] || "#{event[:timestamp]}:#{event[:credential_key]}:#{event[:target_node]}"
        end
      end
    end
  end
end
