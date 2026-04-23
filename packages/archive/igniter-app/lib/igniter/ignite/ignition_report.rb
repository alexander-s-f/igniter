# frozen_string_literal: true

module Igniter
  module Ignite
    class IgnitionReport
      attr_reader :plan_id, :status, :strategy, :approval_mode, :entries, :events, :summary

      def initialize(plan_id:, status:, strategy:, approval_mode:, entries:, events:, summary:)
        @plan_id = plan_id.to_s
        @status = status.to_sym
        @strategy = strategy.to_sym
        @approval_mode = approval_mode.to_sym
        @entries = Array(entries).map { |entry| immutable(entry) }.freeze
        @events = Array(events).map { |event| immutable(event) }.freeze
        @summary = immutable(summary)
        freeze
      end

      def awaiting_approval?
        status == :awaiting_approval
      end

      def prepared?
        status == :prepared
      end

      def pending_remote?
        status == :pending_remote
      end

      def awaiting_join?
        status == :awaiting_join
      end

      def joined?
        status == :joined
      end

      def detached?
        status == :detached
      end

      def torn_down?
        status == :torn_down
      end

      def blocked?
        status == :blocked
      end

      def by_status
        summary.fetch(:by_status, {})
      end

      def by_join_status
        summary.fetch(:by_join_status, {})
      end

      def latest_event
        events.last
      end

      def by_event_type
        events.each_with_object(Hash.new(0)) do |event, counts|
          counts[event.fetch(:type)] += 1
        end
      end

      def recent_events(limit = 5)
        events.last(limit)
      end

      def target_timelines
        entry_index = entries.each_with_object({}) do |entry, result|
          result[entry.fetch(:target_id).to_s] = entry
        end

        grouped_events = events.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |event, result|
          target_id = event[:target_id]
          next unless target_id

          result[target_id.to_s] << event
        end

        entry_index.each_with_object({}) do |(target_id, entry), result|
          target_events = grouped_events[target_id]
          result[target_id] = {
            target_id: target_id,
            kind: entry[:kind],
            status: entry[:status],
            action: entry[:action],
            admission_status: entry.dig(:admission, :status),
            join_status: entry.dig(:join, :status),
            latest_event_type: target_events.last&.dig(:type),
            event_count: target_events.size,
            events: target_events
          }.freeze
        end
      end

      def timeline_for(target_id)
        target_timelines[target_id.to_s]
      end

      def progress
        {
          latest_event: latest_event,
          total_events: events.size,
          by_event_type: by_event_type.freeze,
          recent_events: recent_events.freeze,
          targets: target_timelines.freeze
        }
      end

      def to_h
        {
          plan_id: plan_id,
          status: status,
          strategy: strategy,
          approval_mode: approval_mode,
          entries: entries,
          events: events,
          summary: summary,
          progress: progress
        }
      end

      private

      def immutable(value)
        case value
        when Hash
          value.each_with_object({}) do |(key, nested), result|
            result[key.to_sym] = immutable(nested)
          end.freeze
        when Array
          value.map { |item| immutable(item) }.freeze
        else
          value
        end
      end
    end
  end
end
