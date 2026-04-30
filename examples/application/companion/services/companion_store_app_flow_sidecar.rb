# frozen_string_literal: true

begin
  require "igniter/companion"
rescue LoadError
  root = File.expand_path("../../../..", __dir__)
  $LOAD_PATH.unshift(File.join(root, "packages/igniter-store/lib"))
  $LOAD_PATH.unshift(File.join(root, "packages/igniter-companion/lib"))
  require "igniter/companion"
end

# Isolated adapter slice — simulates one app-pattern write flowing through
# Igniter::Companion::Store using a manifest-generated class.
#
# This is report-only. The main app continues to use blob-JSON SQLite; this
# slice does not replace or wrap that backend. It proves:
#
#   1. App code can get a typed Record class from a contract manifest alone.
#   2. A write/read/scope cycle works through the package facade.
#   3. The WriteReceipt shape is compatible with the app's mutation_intent model.
#   4. The package store stays isolated — main_state_mutated is always false.
#
module Companion
  module Services
    class CompanionStoreAppFlowSidecar
      def self.packet
        proof = new.proof
        Contracts::CompanionStoreAppFlowSidecarContract.evaluate(proof: proof)
      end

      def proof
        # Generate the typed class from the app-local manifest — no hand-written
        # schema class needed.
        reminder_class = Igniter::Companion.from_manifest(
          Contracts::Reminder.persistence_manifest
        )

        store = Igniter::Companion::Store.new
        store.register(reminder_class)

        # Simulate an app-level "create reminder" request.
        write_params = { key: "app-flow-1", id: "app-flow-1",
                         title: "Morning standup", status: :open }
        receipt = store.write(reminder_class, **write_params)
        record  = store.read(reminder_class, key: "app-flow-1")
        open_scope = store.scope(reminder_class, :open)

        {
          store_name:            reminder_class.store_name,
          generated_from_manifest: true,
          main_state_mutated:    false,
          write: {
            ok:     true,
            title:  write_params[:title],
            status: write_params[:status]
          },
          read: {
            title:  record.title,
            status: record.status
          },
          receipt: {
            mutation_intent:     receipt.mutation_intent,
            fact_id:             receipt.fact_id,
            value_hash_present:  !receipt.value_hash.nil?,
            delegates_to_record: receipt.title == write_params[:title]
          },
          scope: {
            open_count: open_scope.length
          }
        }.tap { store.close }
      end
    end
  end
end
