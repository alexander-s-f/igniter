# frozen_string_literal: true

require "date"

module Companion
  module Services
    class CompanionState
      Reminder = Struct.new(:id, :title, :due, :status, keyword_init: true)
      Tracker = Struct.new(:id, :name, :template, :unit, :log_entries, keyword_init: true) do
        def to_h
          super.merge(entries: log_entries)
        end
      end
      Countdown = Struct.new(:id, :title, :target_date, keyword_init: true)
      Action = Struct.new(:index, :kind, :subject_id, :status, keyword_init: true)

      attr_accessor :daily_focus_title, :live_summary
      attr_reader :reminders, :trackers, :countdowns, :actions, :next_action_index

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
        @countdowns = []
        @daily_focus_title = nil
        @live_summary = nil
      end

      def seed
        reminders << Reminder.new(id: "morning-water", title: "Drink water after wake-up", due: "morning", status: :open)
        reminders << Reminder.new(id: "evening-review", title: "Review the day", due: "evening", status: :open)
        trackers << Tracker.new(id: "sleep", name: "Sleep", template: :sleep, unit: "hours", log_entries: [])
        trackers << Tracker.new(id: "training", name: "Training", template: :workout, unit: "minutes", log_entries: [])
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
        @trackers = Array(state.fetch(:trackers)).map do |entry|
          payload = symbolize(entry)
          Tracker.new(
            id: payload.fetch(:id),
            name: payload.fetch(:name),
            template: payload.fetch(:template).to_sym,
            unit: payload.fetch(:unit),
            log_entries: Array(payload.fetch(:entries)).map { |tracker_entry| symbolize(tracker_entry) }
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
        @daily_focus_title = state[:daily_focus_title]
        @live_summary = state[:live_summary]
        @next_action_index = state.fetch(:next_action_index)
      end

      def to_h
        {
          reminders: reminders.map(&:to_h),
          trackers: trackers.map { |tracker| tracker.to_h.merge(entries: tracker.log_entries.map(&:dup)) },
          countdowns: countdowns.map(&:to_h),
          actions: actions.map(&:to_h),
          daily_focus_title: daily_focus_title,
          live_summary: live_summary,
          next_action_index: next_action_index
        }
      end

      def base_payload(live_ready:)
        {
          open_reminders: open_reminders_count,
          tracker_logs_today: tracker_logs_today_count,
          next_reminder_title: next_reminder_title,
          daily_focus_title: daily_focus_title,
          sleep_hours_today: tracker_value_today("sleep"),
          training_minutes_today: tracker_value_today("training"),
          live_ready: live_ready
        }
      end

      def open_reminders_count
        reminders.count { |reminder| reminder.status == :open }
      end

      def tracker_logs_today_count
        trackers.sum do |tracker|
          tracker.log_entries.count { |entry| entry.fetch(:date) == Date.today.iso8601 }
        end
      end

      def next_reminder_title
        reminders.find { |reminder| reminder.status == :open }&.title
      end

      def tracker_value_today(id)
        tracker = trackers.find { |entry| entry.id == id.to_s }
        return 0 unless tracker

        tracker.log_entries.select { |entry| entry.fetch(:date) == Date.today.iso8601 }.sum do |entry|
          Float(entry.fetch(:value))
        rescue ArgumentError, TypeError
          0
        end
      end

      def record_action(kind:, subject_id:, status:)
        action = Action.new(index: next_action_index, kind: kind.to_sym, subject_id: subject_id, status: status.to_sym)
        actions << action
        @next_action_index += 1
        action
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

      def symbolize(value)
        value.transform_keys(&:to_sym)
      end
    end
  end
end
