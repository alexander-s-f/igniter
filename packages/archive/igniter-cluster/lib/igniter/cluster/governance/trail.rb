# frozen_string_literal: true

require "securerandom"
require "time"

module Igniter
  module Cluster
    module Governance
      class Trail
        attr_reader :store, :compaction_history

        def initialize(store: nil, clock: -> { Time.now.utc.iso8601 })
          @store = store
          @clock = clock
          @events = Array(store&.load_events).map { |event| normalize_loaded_event(event).freeze }
          @compaction_history = []
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
          store&.append(event)
          prune_retained_events!
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
            persistence: persistence_metadata,
            events: events(limit: limit)
          }
        end

        def clear!
          @events.clear
          store&.clear!
          self
        end

        # Collapse old events into a signed Checkpoint, keeping only the most
        # recent `keep_last` events in memory and on disk.
        #
        # @param keep_last  [Integer]  how many recent events to retain
        # @param identity   [Identity, nil]  when provided, signs the checkpoint
        # @param peer_name  [String, nil]
        # @param previous   [Checkpoint, nil]  checkpoint to chain from
        # @return [CompactionRecord]
        def compact!(keep_last: 20, identity: nil, peer_name: nil, previous: nil)
          removed_count = [@events.size - keep_last, 0].max
          checkpoint = if identity
                         Checkpoint.build(
                           identity: identity,
                           peer_name: peer_name || "unknown",
                           trail: self,
                           limit: keep_last,
                           previous: previous
                         )
                       end

          @events = @events.last(keep_last)
          store.compact!(@events) if store.respond_to?(:compact!)

          kept_count = @events.size
          digest = checkpoint&.crest_digest

          record(:trail_compacted, source: :trail, payload: {
            removed_events: removed_count,
            kept_events:    kept_count,
            checkpoint_digest: digest
          })

          rec = CompactionRecord.new(
            checkpoint:        checkpoint,
            removed_events:    removed_count,
            kept_events:       kept_count,
            checkpoint_digest: digest
          )
          @compaction_history << rec
          rec
        end

        # All events recorded after the given Checkpoint's timestamp.
        # Returns all events when checkpoint is nil.
        #
        # @param checkpoint [Checkpoint, nil]
        # @return [Array<Hash>]
        def events_since(checkpoint)
          return @events.dup unless checkpoint

          since_ts = Time.parse(checkpoint.checkpointed_at.to_s) rescue nil
          return @events.dup unless since_ts

          @events.select do |e|
            ts = Time.parse(e[:timestamp].to_s) rescue nil
            ts && ts > since_ts
          end
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
