# frozen_string_literal: true

require_relative "companion_state"
require_relative "contract_history"
require_relative "contract_record_set"

module Companion
  module Services
    class CompanionPersistence
      RECORD_BINDINGS = {
        reminders: {
          contract_class: Contracts::Reminder,
          collection: :reminders,
          record_class: CompanionState::Reminder
        },
        trackers: {
          contract_class: Contracts::Tracker,
          collection: :trackers,
          record_class: CompanionState::Tracker
        },
        daily_focuses: {
          contract_class: Contracts::DailyFocus,
          collection: :daily_focuses,
          record_class: CompanionState::DailyFocus
        }
      }.freeze

      HISTORY_BINDINGS = {
        tracker_logs: {
          contract_class: Contracts::TrackerLog,
          entries: :tracker_log_entries,
          append: :append_tracker_log
        },
        actions: {
          contract_class: Contracts::CompanionAction,
          entries: :action_entries,
          append: :append_action_event
        }
      }.freeze

      PROJECTION_BINDINGS = {
        tracker_read_model: Contracts::TrackerReadModelContract,
        activity_feed: Contracts::ActivityFeedContract
      }.freeze

      def initialize(state:)
        @state = state
      end

      def capability_names
        capability_manifest.keys
      end

      def capability_manifest
        record_manifest
          .merge(history_manifest)
          .merge(projection_manifest)
      end

      def reminders
        record(:reminders)
      end

      def trackers
        record(:trackers)
      end

      def daily_focuses
        record(:daily_focuses)
      end

      def daily_focus_title_for(date)
        daily_focuses.find(date)&.title
      end

      def tracker_logs
        history(:tracker_logs)
      end

      def actions
        history(:actions)
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

      def record(name)
        binding = RECORD_BINDINGS.fetch(name)
        ContractRecordSet.new(
          contract_class: binding.fetch(:contract_class),
          collection: state.public_send(binding.fetch(:collection)),
          record_class: binding.fetch(:record_class)
        )
      end

      def history(name)
        binding = HISTORY_BINDINGS.fetch(name)
        ContractHistory.new(
          contract_class: binding.fetch(:contract_class),
          entries: method(binding.fetch(:entries)),
          append: method(binding.fetch(:append))
        )
      end

      def record_manifest
        RECORD_BINDINGS.keys.to_h do |name|
          [name, { kind: :record, contract: RECORD_BINDINGS.fetch(name).fetch(:contract_class) }]
        end
      end

      def history_manifest
        HISTORY_BINDINGS.keys.to_h do |name|
          [name, { kind: :history, contract: HISTORY_BINDINGS.fetch(name).fetch(:contract_class) }]
        end
      end

      def projection_manifest
        PROJECTION_BINDINGS.keys.to_h do |name|
          [name, { kind: :projection, contract: PROJECTION_BINDINGS.fetch(name) }]
        end
      end

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
