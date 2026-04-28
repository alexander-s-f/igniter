# frozen_string_literal: true

require "date"

module Companion
  module Services
    class CompanionState
      Reminder = Struct.new(:id, :title, :due, :status, keyword_init: true)
      Tracker = Struct.new(:id, :name, :template, :unit, keyword_init: true)
      TrackerSnapshot = Struct.new(:id, :name, :template, :unit, :log_entries, keyword_init: true) do
        def to_h
          super.merge(entries: log_entries)
        end
      end
      TrackerLog = Struct.new(:tracker_id, :date, :value, keyword_init: true)
      DailyFocus = Struct.new(:date, :title, keyword_init: true)
      Countdown = Struct.new(:id, :title, :target_date, keyword_init: true)
      Action = Struct.new(:index, :kind, :subject_id, :status, keyword_init: true)

      attr_accessor :live_summary
      attr_reader :reminders, :trackers, :tracker_logs, :daily_focuses, :countdowns, :actions, :next_action_index

      def self.seeded
        new.tap(&:seed)
      end

      def self.from_h(state)
        new.tap { |record| record.restore(state) }
      end

      def initialize
        @actions = []
        @next_action_index = 0
        @reminders = []
        @trackers = []
        @tracker_logs = []
        @daily_focuses = []
        @countdowns = []
        @live_summary = nil
      end

      def seed
        reminders << Reminder.new(id: "morning-water", title: "Drink water after wake-up", due: "morning", status: :open)
        reminders << Reminder.new(id: "evening-review", title: "Review the day", due: "evening", status: :open)
        trackers << Tracker.new(id: "sleep", name: "Sleep", template: :sleep, unit: "hours")
        trackers << Tracker.new(id: "training", name: "Training", template: :workout, unit: "minutes")
        countdowns << Countdown.new(id: "new-year", title: "New Year", target_date: "#{Date.today.year + 1}-01-01")
        record_action(kind: :companion_seeded, subject_id: :companion, status: :ready)
      end

      def restore(state)
        @reminders = Array(state.fetch(:reminders)).map do |entry|
          payload = symbolize(entry)
          Reminder.new(
            id: payload.fetch(:id),
            title: payload.fetch(:title),
            due: payload.fetch(:due),
            status: payload.fetch(:status).to_sym
          )
        end
        nested_logs = []
        @trackers = Array(state.fetch(:trackers)).map do |entry|
          payload = symbolize(entry)
          nested_logs.concat(
            Array(payload.fetch(:entries, [])).map do |tracker_entry|
              symbolize(tracker_entry).merge(tracker_id: payload.fetch(:id))
            end
          )
          Tracker.new(
            id: payload.fetch(:id),
            name: payload.fetch(:name),
            template: payload.fetch(:template).to_sym,
            unit: payload.fetch(:unit)
          )
        end
        @tracker_logs = Array(state.fetch(:tracker_logs, nested_logs)).map do |entry|
          payload = symbolize(entry)
          TrackerLog.new(
            tracker_id: payload.fetch(:tracker_id),
            date: payload.fetch(:date),
            value: payload.fetch(:value)
          )
        end
        @daily_focuses = Array(state.fetch(:daily_focuses, legacy_daily_focus(state))).map do |entry|
          payload = symbolize(entry)
          DailyFocus.new(
            date: payload.fetch(:date),
            title: payload.fetch(:title)
          )
        end
        @countdowns = Array(state.fetch(:countdowns)).map do |entry|
          Countdown.new(**symbolize(entry))
        end
        @actions = Array(state.fetch(:actions)).map do |entry|
          payload = symbolize(entry)
          Action.new(
            index: payload.fetch(:index),
            kind: payload.fetch(:kind).to_sym,
            subject_id: payload.fetch(:subject_id),
            status: payload.fetch(:status).to_sym
          )
        end
        @live_summary = state[:live_summary]
        @next_action_index = state.fetch(:next_action_index, actions.map(&:index).max.to_i + 1)
      end

      def to_h
        {
          reminders: reminders.map(&:to_h),
          trackers: trackers.map(&:to_h),
          tracker_logs: tracker_logs.map(&:to_h),
          daily_focuses: daily_focuses.map(&:to_h),
          countdowns: countdowns.map(&:to_h),
          actions: actions.map(&:to_h),
          daily_focus_title: daily_focus_title,
          live_summary: live_summary,
          next_action_index: next_action_index
        }
      end

      def base_payload(live_ready:, tracker_read_model:)
        {
          open_reminders: open_reminders_count,
          tracker_logs_today: tracker_read_model.fetch(:logs_today),
          next_reminder_title: next_reminder_title,
          daily_focus_title: daily_focus_title,
          sleep_hours_today: tracker_read_model.fetch(:sleep_hours_today),
          training_minutes_today: tracker_read_model.fetch(:training_minutes_today),
          live_ready: live_ready
        }
      end

      def open_reminders_count
        reminders.count { |reminder| reminder.status == :open }
      end

      def next_reminder_title
        reminders.find { |reminder| reminder.status == :open }&.title
      end

      def daily_focus_title(date = Date.today.iso8601)
        daily_focuses.find { |entry| entry.date == date.to_s }&.title
      end

      def tracker_log_entries
        tracker_logs.map(&:to_h)
      end

      def append_tracker_log(event)
        return nil unless trackers.any? { |tracker| tracker.id == event.fetch(:tracker_id).to_s }

        TrackerLog.new(
          tracker_id: event.fetch(:tracker_id).to_s,
          date: event.fetch(:date),
          value: event.fetch(:value)
        ).tap { |entry| tracker_logs << entry }
      end

      def record_action(kind:, subject_id:, status:)
        append_action_event(index: next_action_index, kind: kind, subject_id: subject_id, status: status)
      end

      def action_entries
        actions.map(&:to_h)
      end

      def append_action_event(event)
        action = Action.new(
          index: event.fetch(:index),
          kind: event.fetch(:kind).to_sym,
          subject_id: event.fetch(:subject_id),
          status: event.fetch(:status).to_sym
        )
        actions << action
        @next_action_index = [next_action_index, action.index + 1].max
        action.to_h
      end

      def next_id_for(title, collection)
        base = title.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-+\z/, "")
        base = "item" if base.empty?
        candidate = base
        suffix = 2
        while collection.any? { |entry| entry.id == candidate }
          candidate = "#{base}-#{suffix}"
          suffix += 1
        end
        candidate
      end

      private

      def legacy_daily_focus(state)
        title = state[:daily_focus_title]
        title.to_s.empty? ? [] : [{ date: Date.today.iso8601, title: title }]
      end

      def symbolize(value)
        value.transform_keys(&:to_sym)
      end
    end
  end
end
