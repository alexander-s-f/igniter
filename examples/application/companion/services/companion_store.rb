# frozen_string_literal: true

require "time"

require_relative "companion_persistence"
require_relative "companion_state"

module Companion
  module Services
    class CompanionStore
      TODAY_QUICK_ACTION_COMMANDS = {
        log_tracker: ->(store, arguments, input) { store.log_tracker(arguments.fetch(:id), input.fetch(:value)) },
        complete_reminder: ->(store, arguments, _input) { store.complete_reminder(arguments.fetch(:id)) }
      }.freeze

      CommandResult = Struct.new(:kind, :feedback_code, :subject_id, :action, keyword_init: true) do
        def success?
          kind == :success
        end
      end
      Snapshot = Struct.new(
        :reminders, :trackers, :countdowns, :open_reminders, :tracker_logs_today,
        :countdown_count, :live_ready, :credential_status, :daily_summary,
        :persistence_readiness, :body_battery, :daily_plan, :daily_focus_title,
        :relation_health, :manifest_glossary_health, :materializer_status, :materializer_status_descriptor_health,
        :live_summary, :action_count, :recent_events,
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
            persistence_readiness: persistence_readiness.dup,
            daily_summary: daily_summary.dup,
            body_battery: body_battery.dup,
            daily_plan: daily_plan.dup,
            daily_focus_title: daily_focus_title,
            relation_health: relation_health.dup,
            manifest_glossary_health: manifest_glossary_health.dup,
            materializer_status: materializer_status.dup,
            materializer_status_descriptor_health: materializer_status_descriptor_health.dup,
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
        reminders = persistence.reminders
        open_reminders = reminders.scope(:open)
        tracker_read_model = persistence.tracker_read_model_for(today)
        trackers = tracker_read_model.fetch(:tracker_snapshots)
        countdown_read_model = persistence.countdown_read_model_for(today)
        countdowns = countdown_read_model.fetch(:countdown_snapshots)
        urgent = urgent_countdown(countdowns)
        activity_feed = persistence.activity_feed_for(recent_limit)
        payload = @state.base_payload(
          live_ready: credential_status.fetch(:configured),
          tracker_read_model: tracker_read_model,
          open_reminders: open_reminders.length,
          next_reminder_title: open_reminders.first&.title
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
          next_reminder_id: open_reminders.first&.id,
          next_reminder_title: payload.fetch(:next_reminder_title),
          suggested_tracker_id: trackers.first&.id,
          body_battery: body_battery,
          open_reminders: payload.fetch(:open_reminders),
          tracker_logs_today: payload.fetch(:tracker_logs_today),
          urgent_countdown_id: urgent&.id,
          urgent_countdown_title: urgent&.title
        )

        Snapshot.new(
          reminders: reminders.all,
          trackers: trackers,
          countdowns: countdowns,
          open_reminders: payload.fetch(:open_reminders),
          tracker_logs_today: payload.fetch(:tracker_logs_today),
          countdown_count: countdowns.length,
          live_ready: payload.fetch(:live_ready),
          credential_status: credential_status,
          persistence_readiness: persistence.readiness,
          relation_health: persistence.relation_health,
          manifest_glossary_health: persistence.manifest_glossary_health,
          materializer_status_descriptor_health: persistence.materializer_status_descriptor_health,
          daily_summary: summary,
          body_battery: body_battery,
          daily_plan: daily_plan,
          daily_focus_title: persistence.daily_focus_title_for(today),
          live_summary: @state.live_summary&.dup,
          materializer_status: persistence.materializer_status,
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
        apply_persistence_mutation(outcome.fetch(:mutation))
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

      def create_countdown(title, target_date)
        outcome = Contracts::CountdownContract.evaluate(
          title: title,
          target_date: target_date,
          countdowns: persistence.countdowns.all
        )
        apply_persistence_mutation(outcome.fetch(:mutation))
        action = record_contract_action(outcome.fetch(:result))
        persist!
        command_result_from_contract(outcome.fetch(:result), action: action)
      end

      def complete_reminder(id)
        outcome = Contracts::ReminderContract.evaluate(
          operation: :complete,
          id: id,
          title: nil,
          reminders: persistence.reminders.all
        )
        apply_persistence_mutation(outcome.fetch(:mutation))
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
        apply_persistence_mutation(outcome.fetch(:mutation))
        action = record_contract_action(outcome.fetch(:result))
        persist!
        command_result_from_contract(outcome.fetch(:result), action: action)
      end

      def run_today_quick_action(value: nil)
        quick_action = snapshot.daily_plan.fetch(:quick_action)
        command = quick_action[:command]

        return unavailable_today_quick_action(quick_action.fetch(:kind)) unless command

        handler = TODAY_QUICK_ACTION_COMMANDS[command.fetch(:name)]
        return unavailable_today_quick_action(command.fetch(:name)) unless handler

        handler.call(self, command.fetch(:arguments), { value: value })
      end

      def events_read_model
        snapshot = self.snapshot
        recent = snapshot.recent_events.map do |event|
          "#{event.fetch(:kind)}:#{event.fetch(:subject_id) || "-"}:#{event.fetch(:status)}"
        end
        "live=#{snapshot.live_ready} reminders=#{snapshot.open_reminders} tracker_logs=#{snapshot.tracker_logs_today} recent=#{recent.join("|")}"
      end

      def persistence_manifest
        persistence.manifest_snapshot
      end

      def manifest_glossary_health
        persistence.manifest_glossary_health
      end

      def setup_health
        persistence.setup_health
      end

      def setup_handoff
        persistence.setup_handoff
      end

      def setup_handoff_acceptance
        persistence.setup_handoff_acceptance
      end

      def setup_handoff_approval_acceptance
        persistence.setup_handoff_approval_acceptance
      end

      def materialization_plan
        persistence.materialization_plan
      end

      def materialization_parity
        persistence.materialization_parity
      end

      def wizard_type_specs
        persistence.wizard_type_specs.all
      end

      def wizard_type_spec_export
        persistence.wizard_type_spec_export
      end

      def wizard_type_spec_migration_plan
        persistence.wizard_type_spec_migration_plan
      end

      def infrastructure_loop_health
        persistence.infrastructure_loop_health
      end

      def materializer_gate(approved: false)
        persistence.materializer_gate(approved: approved)
      end

      def materializer_preflight
        persistence.materializer_preflight
      end

      def materializer_runbook
        persistence.materializer_runbook
      end

      def materializer_receipt
        persistence.materializer_receipt
      end

      def materializer_attempt_command
        persistence.materializer_attempt_command
      end

      def materializer_attempts
        persistence.materializer_attempts.all
      end

      def materializer_approvals
        persistence.materializer_approvals.all
      end

      def materializer_audit_trail
        persistence.materializer_audit_trail
      end

      def materializer_approval_audit_trail
        persistence.materializer_approval_audit_trail
      end

      def materializer_supervision
        persistence.materializer_supervision
      end

      def materializer_status
        persistence.materializer_status
      end

      def materializer_status_descriptor_health
        persistence.materializer_status_descriptor_health
      end

      def materializer_approval_policy
        persistence.materializer_approval_policy
      end

      def materializer_approval_receipt
        persistence.materializer_approval_receipt
      end

      def materializer_approval_command
        persistence.materializer_approval_command
      end

      def record_materializer_attempt
        outcome = persistence.materializer_attempt_command
        apply_persistence_mutation(outcome.fetch(:mutation))
        action = record_contract_action(outcome.fetch(:result))
        persist!
        command_result_from_contract(outcome.fetch(:result), action: action)
      end

      def record_materializer_approval
        outcome = persistence.materializer_approval_command
        apply_persistence_mutation(outcome.fetch(:mutation))
        action = record_contract_action(outcome.fetch(:result))
        persist!
        command_result_from_contract(outcome.fetch(:result), action: action)
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

      def apply_persistence_mutation(mutation)
        case mutation.fetch(:operation)
        when :record_append
          persistence.public_send(mutation.fetch(:target)).save(mutation.fetch(:record))
        when :record_update
          persistence.public_send(mutation.fetch(:target)).update(mutation.fetch(:id), mutation.fetch(:changes))
        when :history_append
          persistence.public_send(mutation.fetch(:target)).append(mutation.fetch(:event))
        end
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

      def unavailable_today_quick_action(subject_id)
        action = record_action(kind: :today_quick_action_refused, subject_id: subject_id, status: :refused)
        persist!
        command_result(:failure, feedback_code: :today_quick_action_unavailable, subject_id: subject_id, action: action)
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

      def urgent_countdown(countdowns)
        countdowns
          .select { |entry| entry.days_remaining&.between?(0, 7) }
          .min_by(&:days_remaining)
      end
    end
  end
end
