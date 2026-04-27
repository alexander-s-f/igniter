# frozen_string_literal: true

require "date"
require "time"

module Companion
  module Services
    class CompanionStore
      Reminder = Struct.new(:id, :title, :due, :status, keyword_init: true)
      Tracker = Struct.new(:id, :name, :template, :unit, :log_entries, keyword_init: true) do
        def to_h
          super.merge(entries: log_entries)
        end
      end
      Countdown = Struct.new(:id, :title, :target_date, keyword_init: true)
      Action = Struct.new(:index, :kind, :subject_id, :status, keyword_init: true)
      CommandResult = Struct.new(:kind, :feedback_code, :subject_id, :action, keyword_init: true) do
        def success?
          kind == :success
        end
      end
      Snapshot = Struct.new(
        :reminders, :trackers, :countdowns, :open_reminders, :tracker_logs_today,
        :countdown_count, :live_ready, :credential_status, :daily_summary,
        :body_battery, :live_summary, :action_count, :recent_events,
        keyword_init: true
      ) do
        def to_h
          {
            reminders: reminders.map(&:to_h),
            trackers: trackers.map { |tracker| tracker.to_h.merge(entries: tracker.log_entries.map(&:dup)) },
            countdowns: countdowns.map(&:to_h),
            open_reminders: open_reminders,
            tracker_logs_today: tracker_logs_today,
            countdown_count: countdown_count,
            live_ready: live_ready,
            credential_status: credential_status.dup,
            daily_summary: daily_summary.dup,
            body_battery: body_battery.dup,
            live_summary: live_summary&.dup,
            action_count: action_count,
            recent_events: recent_events.map(&:dup)
          }
        end
      end

      def initialize(credentials:, backend:, assistant: nil)
        @credentials = credentials
        @backend = backend
        @assistant = assistant
        restore_or_seed
      end

      def snapshot(recent_limit: 6)
        payload = base_payload
        summary = Contracts::DailySummaryContract.evaluate(snapshot: payload)
        body_battery = Contracts::BodyBatteryContract.evaluate(snapshot: payload)

        Snapshot.new(
          reminders: @reminders.map(&:dup).freeze,
          trackers: @trackers.map { |tracker| tracker.dup.tap { |copy| copy.log_entries = tracker.log_entries.map(&:dup).freeze } }.freeze,
          countdowns: @countdowns.map(&:dup).freeze,
          open_reminders: payload.fetch(:open_reminders),
          tracker_logs_today: payload.fetch(:tracker_logs_today),
          countdown_count: @countdowns.length,
          live_ready: payload.fetch(:live_ready),
          credential_status: credential_status,
          daily_summary: summary,
          body_battery: body_battery,
          live_summary: @live_summary&.dup,
          action_count: @actions.length,
          recent_events: @actions.last(recent_limit).map { |action| action.to_h.freeze }.freeze
        ).freeze
      end

      def generate_live_summary
        unless credential_status.fetch(:configured)
          action = record_action(kind: :live_summary_refused, subject_id: :daily_summary, status: :refused)
          persist!
          return command_result(:failure, feedback_code: :openai_key_missing, subject_id: :daily_summary, action: action)
        end

        unless @assistant
          action = record_action(kind: :live_summary_refused, subject_id: :daily_summary, status: :refused)
          persist!
          return command_result(:failure, feedback_code: :live_assistant_missing, subject_id: :daily_summary, action: action)
        end

        run = @assistant.run(
          input: daily_summary_prompt(snapshot.to_h),
          context: { feature: :daily_summary },
          metadata: { feature: :daily_summary }
        )
        if run.success?
          response = run.turns.first.response
          @live_summary = {
            text: response.text,
            provider: response.metadata.fetch(:provider, :unknown),
            agent_run_id: run.id,
            generated_at: Time.now.utc.iso8601
          }
          action = record_action(kind: :live_summary_generated, subject_id: :daily_summary, status: :ready)
          persist!
          command_result(:success, feedback_code: :live_summary_generated, subject_id: :daily_summary, action: action)
        else
          action = record_action(kind: :live_summary_failed, subject_id: :daily_summary, status: :error)
          persist!
          command_result(:failure, feedback_code: :live_summary_failed, subject_id: run.error, action: action)
        end
      end

      def create_reminder(title)
        normalized = title.to_s.strip
        if normalized.empty?
          action = record_action(kind: :reminder_create_refused, subject_id: nil, status: :refused)
          return command_result(:failure, feedback_code: :blank_reminder, subject_id: nil, action: action)
        end

        reminder = Reminder.new(id: next_id_for(normalized, @reminders), title: normalized, due: "today", status: :open)
        @reminders << reminder
        action = record_action(kind: :reminder_created, subject_id: reminder.id, status: :open)
        persist!
        command_result(:success, feedback_code: :reminder_created, subject_id: reminder.id, action: action)
      end

      def complete_reminder(id)
        reminder = @reminders.find { |entry| entry.id == id.to_s }
        unless reminder
          action = record_action(kind: :reminder_complete_refused, subject_id: id.to_s, status: :refused)
          return command_result(:failure, feedback_code: :reminder_not_found, subject_id: id.to_s, action: action)
        end

        reminder.status = :done
        action = record_action(kind: :reminder_completed, subject_id: reminder.id, status: :done)
        persist!
        command_result(:success, feedback_code: :reminder_completed, subject_id: reminder.id, action: action)
      end

      def log_tracker(id, value)
        tracker = @trackers.find { |entry| entry.id == id.to_s }
        unless tracker
          action = record_action(kind: :tracker_log_refused, subject_id: id.to_s, status: :refused)
          return command_result(:failure, feedback_code: :tracker_not_found, subject_id: id.to_s, action: action)
        end

        normalized = value.to_s.strip
        if normalized.empty?
          action = record_action(kind: :tracker_log_refused, subject_id: tracker.id, status: :refused)
          return command_result(:failure, feedback_code: :blank_tracker_value, subject_id: tracker.id, action: action)
        end

        tracker.log_entries << { date: Date.today.iso8601, value: normalized }
        action = record_action(kind: :tracker_logged, subject_id: tracker.id, status: :logged)
        persist!
        command_result(:success, feedback_code: :tracker_logged, subject_id: tracker.id, action: action)
      end

      def events_read_model
        snapshot = self.snapshot
        recent = snapshot.recent_events.map do |event|
          "#{event.fetch(:kind)}:#{event.fetch(:subject_id) || "-"}:#{event.fetch(:status)}"
        end
        "live=#{snapshot.live_ready} reminders=#{snapshot.open_reminders} tracker_logs=#{snapshot.tracker_logs_today} recent=#{recent.join("|")}"
      end

      private

      def restore_or_seed
        state = @backend.load_state
        if state
          restore_state(state)
        else
          @actions = []
          @next_action_index = 0
          @reminders = []
          @trackers = []
          @countdowns = []
          @live_summary = nil
          seed
          persist!
        end
      end

      def seed
        @reminders << Reminder.new(id: "morning-water", title: "Drink water after wake-up", due: "morning", status: :open)
        @reminders << Reminder.new(id: "evening-review", title: "Review the day", due: "evening", status: :open)
        @trackers << Tracker.new(id: "sleep", name: "Sleep", template: :sleep, unit: "hours", log_entries: [])
        @trackers << Tracker.new(id: "training", name: "Training", template: :workout, unit: "minutes", log_entries: [])
        @countdowns << Countdown.new(id: "new-year", title: "New Year", target_date: "#{Date.today.year + 1}-01-01")
        record_action(kind: :companion_seeded, subject_id: :companion, status: :ready)
      end

      def restore_state(state)
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
        @live_summary = state[:live_summary]
        @next_action_index = state.fetch(:next_action_index)
      end

      def persist!
        @backend.save_state(
          reminders: @reminders.map(&:to_h),
          trackers: @trackers.map { |tracker| tracker.to_h.merge(entries: tracker.log_entries.map(&:dup)) },
          countdowns: @countdowns.map(&:to_h),
          actions: @actions.map(&:to_h),
          live_summary: @live_summary,
          next_action_index: @next_action_index
        )
      end

      def base_payload
        {
          open_reminders: @reminders.count { |reminder| reminder.status == :open },
          tracker_logs_today: @trackers.sum do |tracker|
            tracker.log_entries.count { |entry| entry.fetch(:date) == Date.today.iso8601 }
          end,
          sleep_hours_today: tracker_value_today("sleep"),
          training_minutes_today: tracker_value_today("training"),
          live_ready: credential_status.fetch(:configured)
        }
      end

      def tracker_value_today(id)
        tracker = @trackers.find { |entry| entry.id == id.to_s }
        return 0 unless tracker

        tracker.log_entries.select { |entry| entry.fetch(:date) == Date.today.iso8601 }.sum do |entry|
          Float(entry.fetch(:value))
        rescue ArgumentError, TypeError
          0
        end
      end

      def credential_status
        @credentials.status(:openai_api_key)
      end

      def record_action(kind:, subject_id:, status:)
        action = Action.new(index: @next_action_index, kind: kind.to_sym, subject_id: subject_id, status: status.to_sym)
        @actions << action
        @next_action_index += 1
        action
      end

      def symbolize(value)
        value.transform_keys(&:to_sym)
      end

      def command_result(kind, feedback_code:, subject_id:, action:)
        CommandResult.new(kind: kind.to_sym, feedback_code: feedback_code.to_sym, subject_id: subject_id, action: action)
      end

      def daily_summary_prompt(snapshot)
        <<~PROMPT
          Current companion state:
          - open reminders: #{snapshot.fetch(:open_reminders)}
          - tracker logs today: #{snapshot.fetch(:tracker_logs_today)}
          - countdowns: #{snapshot.fetch(:countdown_count)}
          - deterministic recommendation: #{snapshot.fetch(:daily_summary).fetch(:recommendation)}

          Return one short paragraph and one next action.
        PROMPT
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
    end
  end
end
