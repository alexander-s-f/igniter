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
    class CompanionReceiptProjectionSidecar
      def self.packet
        proof = new.proof
        Contracts::CompanionReceiptProjectionSidecarContract.evaluate(proof: proof)
      end

      def proof
        reminder_class = Igniter::Companion.from_manifest(Contracts::Reminder.persistence_manifest)
        store = Igniter::Companion::Store.new
        store.register(reminder_class)

        receipt = store.write(
          reminder_class,
          key: "receipt-projection-1",
          id: "receipt-projection-1",
          title: "Receipt projection",
          status: :open
        )

        app_receipt = app_receipt_for(receipt, target: :reminders, subject_id: "receipt-projection-1")
        mutation = Companion::Contracts.history_append(:actions, action_event_for(app_receipt, index: 0))
        isolated_state = CompanionState.seeded
        appended_action = isolated_state.append_action_event(mutation.fetch(:event))
        activity_feed = Contracts::ActivityFeedContract.evaluate(
          actions: isolated_state.action_entries,
          recent_limit: 3
        )

        {
          main_state_mutated: false,
          isolated_action_history_mutated: true,
          package_receipt: package_receipt_evidence(receipt),
          projection: {
            strategy: :small_app_receipt,
            app_receipt: app_receipt
          },
          mutation: mutation,
          appended_action: appended_action,
          activity_feed: activity_feed
        }.tap { store.close }
      end

      private

      def package_receipt_evidence(receipt)
        {
          mutation_intent: receipt.mutation_intent,
          fact_id_present: !receipt.fact_id.nil?,
          value_hash_present: !receipt.value_hash.nil?,
          delegates_to_record: receipt.title == "Receipt projection"
        }
      end

      def app_receipt_for(receipt, target:, subject_id:)
        {
          kind: :store_write_receipt,
          source: :igniter_companion_store,
          target: target,
          subject_id: subject_id,
          status: :recorded,
          mutation_intent: receipt.mutation_intent,
          store_fact_exposed: false,
          value_hash_exposed: false
        }
      end

      def action_event_for(app_receipt, index:)
        {
          index: index,
          kind: app_receipt.fetch(:kind),
          subject_id: app_receipt.fetch(:subject_id),
          status: app_receipt.fetch(:status)
        }
      end
    end
  end
end
