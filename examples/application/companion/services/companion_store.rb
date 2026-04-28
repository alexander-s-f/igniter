# frozen_string_literal: true

require "time"

require_relative "companion_persistence"
require_relative "companion_state"

module Companion
  module Services
    class CompanionStore
      CommandResult = Struct.new(:kind, :feedback_code, :subject_id, :action, keyword_init: true) do
        def success?
          kind == :success
        end
      end
      Snapshot = Struct.new(
        :reminders, :trackers, :countdowns, :open_reminders, :tracker_logs_today,
        :countdown_count, :live_ready, :credential_status, :daily_summary,
        :body_battery, :daily_plan, :daily_focus_title, :live_summary, :action_count, :recent_events,
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
            daily_plan: daily_plan.dup,
            daily_focus_title: daily_focus_title,
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
        today = Date.today.iso8601
        tracker_read_model = persistence.tracker_read_model_for(today)
        activity_feed = persistence.activity_feed_for(recent_limit)
        payload = @state.base_payload(
          live_ready: credential_status.fetch(:configured),
          tracker_read_model: tracker_read_model
        )
        summary = Contracts::DailySummaryContract.evaluate(
          open_reminders: payload.fetch(:open_reminders),
          tracker_logs_today: payload.fetch(:tracker_logs_today),
          live_ready: payload.fetch(:live_ready)
        )
        body_battery = Contracts::BodyBatteryContract.evaluate(
          sleep_hours_today: payload.fetch(:sleep_hours_today),
          training_minutes_today: payload.fetch(:training_minutes_today)
        )
        daily_plan = Contracts::DailyPlanContract.evaluate(
          daily_focus_title: payload.fetch(:daily_focus_title),
          next_reminder_title: payload.fetch(:next_reminder_title),
          body_battery: body_battery
        )

        Snapshot.new(
          reminders: persistence.reminders.all,
          trackers: tracker_read_model.fetch(:tracker_snapshots),
          countdowns: @state.countdowns.map(&:dup).freeze,
          open_reminders: payload.fetch(:open_reminders),
          tracker_logs_today: payload.fetch(:tracker_logs_today),
          countdown_count: @state.countdowns.length,
          live_ready: payload.fetch(:live_ready),
          credential_status: credential_status,
          daily_summary: summary,
          body_battery: body_battery,
          daily_plan: daily_plan,
          daily_focus_title: persistence.daily_focus_title_for(today),
          live_summary: @state.live_summary&.dup,
          action_count: activity_feed.fetch(:action_count),
          recent_events: activity_feed.fetch(:recent_events)
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
          @state.live_summary = {
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
        outcome = Contracts::ReminderContract.evaluate(
          operation: :create,
          id: nil,
          title: title,
          reminders: persistence.reminders.all
        )
        apply_reminder_mutation(outcome.fetch(:mutation))
        action = record_contract_action(outcome.fetch(:result))
        persist!
        command_result_from_contract(outcome.fetch(:result), action: action)
      end

      def update_daily_focus(title)
        normalized = title.to_s.strip
        if normalized.empty?
          action = record_action(kind: :daily_focus_refused, subject_id: :daily_focus, status: :refused)
          return command_result(:failure, feedback_code: :blank_daily_focus, subject_id: :daily_focus, action: action)
        end

        persistence.daily_focuses.save(date: Date.today.iso8601, title: normalized)
        action = record_action(kind: :daily_focus_set, subject_id: :daily_focus, status: :ready)
        persist!
        command_result(:success, feedback_code: :daily_focus_set, subject_id: :daily_focus, action: action)
      end

      def complete_reminder(id)
        outcome = Contracts::ReminderContract.evaluate(
          operation: :complete,
          id: id,
          title: nil,
          reminders: persistence.reminders.all
        )
        apply_reminder_mutation(outcome.fetch(:mutation))
        action = record_contract_action(outcome.fetch(:result))
        persist!
        command_result_from_contract(outcome.fetch(:result), action: action)
      end

      def log_tracker(id, value)
        outcome = Contracts::TrackerLogContract.evaluate(
          tracker_id: id,
          value: value,
          date: Date.today.iso8601,
          trackers: persistence.trackers.all
        )
        apply_tracker_log_mutation(outcome.fetch(:mutation))
        action = record_contract_action(outcome.fetch(:result))
        persist!
        command_result_from_contract(outcome.fetch(:result), action: action)
      end

      def events_read_model
        snapshot = self.snapshot
        recent = snapshot.recent_events.map do |event|
          "#{event.fetch(:kind)}:#{event.fetch(:subject_id) || "-"}:#{event.fetch(:status)}"
        end
        "live=#{snapshot.live_ready} reminders=#{snapshot.open_reminders} tracker_logs=#{snapshot.tracker_logs_today} recent=#{recent.join("|")}"
      end

      private

      attr_reader :persistence

      def restore_or_seed
        state = @backend.load_state
        if state
          @state = CompanionState.from_h(state)
        else
          @state = CompanionState.seeded
          persist!
        end
        @persistence = CompanionPersistence.new(state: @state)
      end

      def persist!
        @backend.save_state(@state.to_h)
      end

      def apply_reminder_mutation(mutation)
        case mutation.fetch(:operation)
        when :append
          persistence.reminders.save(mutation.fetch(:record))
        when :update
          persistence.reminders.update(mutation.fetch(:id), mutation.fetch(:changes))
        end
      end

      def apply_tracker_log_mutation(mutation)
        return unless mutation.fetch(:operation) == :append_log

        persistence.tracker_logs.append(mutation.fetch(:entry).merge(tracker_id: mutation.fetch(:tracker_id)))
      end

      def record_contract_action(result)
        record_action(
          kind: result.fetch(:action_kind),
          subject_id: result.fetch(:subject_id),
          status: result.fetch(:action_status)
        )
      end

      def record_action(kind:, subject_id:, status:)
        persistence.actions.append(
          index: @state.next_action_index,
          kind: kind,
          subject_id: subject_id,
          status: status
        )
      end

      def credential_status
        @credentials.status(:openai_api_key)
      end

      def command_result_from_contract(result, action:)
        command_result(
          result.fetch(:kind),
          feedback_code: result.fetch(:feedback_code),
          subject_id: result.fetch(:subject_id),
          action: action
        )
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
    end
  end
end
