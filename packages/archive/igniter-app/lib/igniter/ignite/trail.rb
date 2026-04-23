# frozen_string_literal: true

require "securerandom"
require "set"
require "time"

module Igniter
  module Ignite
    class Trail
      attr_reader :store

      def initialize(store: nil, clock: -> { Time.now.utc.iso8601 })
        @store = store
        @clock = clock
        @events = Array(store&.load_events).map { |event| normalize_loaded_event(event).freeze }
        @report_signatures = Set.new
        seed_report_signatures!
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

      def ingest_report(report, source:)
        Array(report.events).each do |event|
          signature = report_signature(report.plan_id, event)
          next if @report_signatures.include?(signature)

          record(
            event.fetch(:type),
            source: source,
            payload: event.merge(
              plan_id: report.plan_id,
              report_status: report.status,
              report_strategy: report.strategy,
              report_approval_mode: report.approval_mode,
              report_signature: signature
            )
          )
          @report_signatures << signature
        end

        Array(report.entries).each do |entry|
          signature = target_snapshot_signature(report.plan_id, entry, report.status)
          next if @report_signatures.include?(signature)

          record(
            :ignition_target_snapshot,
            source: source,
            payload: entry.merge(
              plan_id: report.plan_id,
              report_status: report.status,
              report_strategy: report.strategy,
              report_approval_mode: report.approval_mode,
              report_signature: signature
            )
          )
          @report_signatures << signature
        end

        record(
          :ignition_report_snapshot,
          source: source,
          payload: {
            plan_id: report.plan_id,
            report_status: report.status,
            report: deep_dup(report.to_h),
            summary: deep_dup(report.summary),
            total_report_events: report.events.size
          }
        )
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
          by_target: counts_by_target,
          persistence: persistence_metadata,
          events: selected
        }
      end

      def clear!
        @events.clear
        @report_signatures.clear
        store&.clear!
        self
      end

      def latest_report
        payload = @events.reverse_each.lazy
                         .filter_map { |event| event.dig(:payload, :report) if event[:type] == :ignition_report_snapshot }
                         .first
        return nil unless payload

        IgnitionReport.new(
          plan_id: payload.fetch(:plan_id),
          status: payload.fetch(:status),
          strategy: payload.fetch(:strategy),
          approval_mode: payload.fetch(:approval_mode),
          entries: payload.fetch(:entries),
          events: payload.fetch(:events),
          summary: payload.fetch(:summary)
        )
      end

      private

      def report_signature(plan_id, event)
        [
          plan_id.to_s,
          event[:type].to_s,
          event[:target_id].to_s,
          event[:intent_id].to_s,
          event[:timestamp].to_s
        ].join("|")
      end

      def target_snapshot_signature(plan_id, entry, report_status)
        [
          "target_snapshot",
          plan_id.to_s,
          entry[:target_id].to_s,
          entry[:status].to_s,
          entry[:action].to_s,
          entry.dig(:admission, :status).to_s,
          entry.dig(:join, :status).to_s,
          report_status.to_s
        ].join("|")
      end

      def seed_report_signatures!
        @events.each do |event|
          signature = event.dig(:payload, :report_signature)
          @report_signatures << signature if signature
        end
      end

      def counts_by_target
        @events.each_with_object(Hash.new(0)) do |event, memo|
          target_id = event.dig(:payload, :target_id)
          next unless target_id

          memo[target_id] += 1
        end
      end

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
