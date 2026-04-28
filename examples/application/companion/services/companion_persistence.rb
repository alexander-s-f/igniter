# frozen_string_literal: true

require_relative "companion_state"
require_relative "contract_history"
require_relative "contract_record_set"

module Companion
  module Services
    class CompanionPersistence
      def initialize(state:)
        @state = state
      end

      def capability_names
        %i[
          reminders trackers daily_focuses tracker_logs actions
          tracker_read_model activity_feed
        ]
      end

      def reminders
        ContractRecordSet.new(
          contract_class: Contracts::Reminder,
          collection: state.reminders,
          record_class: CompanionState::Reminder
        )
      end

      def trackers
        ContractRecordSet.new(
          contract_class: Contracts::Tracker,
          collection: state.trackers,
          record_class: CompanionState::Tracker
        )
      end

      def daily_focuses
        ContractRecordSet.new(
          contract_class: Contracts::DailyFocus,
          collection: state.daily_focuses,
          record_class: CompanionState::DailyFocus
        )
      end

      def daily_focus_title_for(date)
        daily_focuses.find(date)&.title
      end

      def tracker_logs
        ContractHistory.new(
          contract_class: Contracts::TrackerLog,
          entries: method(:tracker_log_entries),
          append: method(:append_tracker_log)
        )
      end

      def actions
        ContractHistory.new(
          contract_class: Contracts::CompanionAction,
          entries: method(:action_entries),
          append: method(:append_action_event)
        )
      end

      def tracker_read_model_for(date)
        Contracts::TrackerReadModelContract.evaluate(
          trackers: trackers.all,
          tracker_logs: tracker_logs.all,
          date: date
        )
      end

      def activity_feed_for(recent_limit)
        Contracts::ActivityFeedContract.evaluate(
          actions: actions.all,
          recent_limit: recent_limit
        )
      end

      private

      attr_reader :state

      def tracker_log_entries
        state.tracker_log_entries
      end

      def append_tracker_log(event)
        state.append_tracker_log(event)
      end

      def action_entries
        state.action_entries
      end

      def append_action_event(event)
        state.append_action_event(event)
      end
    end
  end
end
