# frozen_string_literal: true

begin
  require "igniter/companion"
rescue LoadError
  root = File.expand_path("../../../..", __dir__)
  $LOAD_PATH.unshift(File.join(root, "packages/igniter-store/lib"))
  $LOAD_PATH.unshift(File.join(root, "packages/igniter-companion/lib"))
  require "igniter/companion"
end

module Companion
  module Services
    class StoreConvergenceSidecar
      class ReminderRecord
        include Igniter::Companion::Record

        store_name :reminders

        field :id
        field :title
        field :due
        field :status, default: :open

        scope :open, filters: { status: :open }
      end

      class TrackerLogEvent
        include Igniter::Companion::History

        history_name :tracker_logs
        partition_key :tracker_id

        field :tracker_id
        field :date
        field :value
      end

      def self.packet
        proof = new.proof
        Contracts::StoreConvergenceSidecarContract.evaluate(proof: proof)
      end

      def proof
        store = Igniter::Companion::Store.new
        store.register(ReminderRecord)

        notifications = []
        store.on_scope(ReminderRecord, :open) { |store_name, scope| notifications << [store_name, scope] }

        write_receipt = store.write(ReminderRecord, key: "morning-water", id: "morning-water", title: "Drink water", due: "morning", status: :open)
        read = store.read(ReminderRecord, key: "morning-water")
        open_before = store.scope(ReminderRecord, :open)
        sleep 0.001
        checkpoint = Process.clock_gettime(Process::CLOCK_REALTIME)
        sleep 0.001
        store.write(ReminderRecord, key: "morning-water", id: "morning-water", title: "Drink water", due: "morning", status: :done)
        current = store.read(ReminderRecord, key: "morning-water")
        past = store.read(ReminderRecord, key: "morning-water", as_of: checkpoint)
        open_after = store.scope(ReminderRecord, :open)

        first_receipt  = store.append(TrackerLogEvent, tracker_id: "sleep",     date: "2026-04-30", value: 7.0)
        second_receipt = store.append(TrackerLogEvent, tracker_id: "training",  date: "2026-04-30", value: 42.0)
        third_receipt  = store.append(TrackerLogEvent, tracker_id: "sleep",     date: "2026-05-01", value: 8.5)
        replay_all     = store.replay(TrackerLogEvent)
        replay_sleep   = store.replay(TrackerLogEvent, partition: "sleep")

        {
          schema_version: 1,
          package_facade: :"igniter-companion",
          substrate: :"igniter-store",
          backend: :memory,
          main_state_mutated: false,
          record: record_report(store, read, current, past, open_before, open_after, notifications, write_receipt),
          history: history_report([first_receipt, second_receipt, third_receipt], replay_all, replay_sleep),
          pressure: pressure_report
        }.tap { store.close }
      end

      private

      def record_report(store, read, current, past, open_before, open_after, notifications, write_receipt)
        manifest = Contracts::Reminder.persistence_manifest
        {
          contract: :Reminder,
          package_class: self.class::ReminderRecord.name,
          manifest_storage: manifest.fetch(:storage),
          manifest_fields: manifest.fetch(:fields).map { |field| field.fetch(:name) },
          manifest_scopes: manifest.fetch(:scopes).map { |scope| scope.fetch(:name) },
          read_title: read.title,
          current_status: current.status,
          past_status: past.status,
          open_before_count: open_before.length,
          open_after_count: open_after.length,
          causation_count: store.causation_chain(ReminderRecord, key: "morning-water").length,
          invalidation_notifications: notifications,
          write_receipt_intent: write_receipt.mutation_intent,
          write_receipt_fact_id_present: !write_receipt.fact_id.nil?,
          write_receipt_delegates: write_receipt.title == "Drink water"
        }
      end

      def history_report(receipts, replay_all, replay_sleep)
        manifest = Contracts::TrackerLog.persistence_manifest
        {
          contract: :TrackerLog,
          package_class: self.class::TrackerLogEvent.name,
          manifest_storage: manifest.fetch(:storage),
          manifest_fields: manifest.fetch(:fields).map { |field| field.fetch(:name) },
          partition_key_declared: manifest.fetch(:history).fetch(:key),
          partition_query_supported: true,
          replay_count: replay_all.length,
          values: replay_sleep.map(&:value),
          event_fact_ids: receipts.map { |r| !r.fact_id.nil? },
          event_timestamps: receipts.map { |r| !r.timestamp.nil? },
          append_receipt_intent: receipts.first.mutation_intent,
          partition_replay_count: replay_sleep.length,
          partition_replay_values: replay_sleep.map(&:value)
        }
      end

      def pressure_report
        {
          next_question: :manifest_generated_record_history_classes,
          adapter_slice: :sidecar_only,
          app_backend_migration: false,
          asks: %i[
            manifest_generated_record_history_classes
            normalized_store_receipts_v2
          ]
        }
      end
    end
  end
end
