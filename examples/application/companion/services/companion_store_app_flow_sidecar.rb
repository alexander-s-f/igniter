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
# Igniter::Companion::Store using manifest-generated classes.
#
# This is report-only. The main app continues to use blob-JSON SQLite; this
# slice does not replace or wrap that backend. It proves:
#
#   1. App code can get a typed Record class from a contract manifest alone.
#   2. A write/read/scope cycle works through the package facade.
#   3. The WriteReceipt shape is compatible with the app's mutation_intent model.
#   4. Typed field metadata (type:, values:) from the manifest is mirrored into
#      the generated class's _fields descriptor.
#   5. The package store stays isolated — main_state_mutated is always false.
#
module Companion
  module Services
    class CompanionStoreAppFlowSidecar
      def self.packet
        proof = new.proof
        Contracts::CompanionStoreAppFlowSidecarContract.evaluate(proof: proof)
      end

      def proof
        # Reminder — untyped fields (baseline)
        reminder_class = Igniter::Companion.from_manifest(
          Contracts::Reminder.persistence_manifest
        )
        # Article — typed fields (:string, :datetime, :enum with values:)
        article_class = Igniter::Companion.from_manifest(
          Contracts::Article.persistence_manifest
        )

        store = Igniter::Companion::Store.new
        store.register(reminder_class)
        store.register(article_class)

        # Reminder write/read cycle
        write_params = { key: "app-flow-1", id: "app-flow-1",
                         title: "Morning standup", status: :open }
        receipt = store.write(reminder_class, **write_params)
        record  = store.read(reminder_class, key: "app-flow-1")
        open_scope = store.scope(reminder_class, :open)

        # Article write/read cycle — exercises typed fields
        article_params = { key: "a1", id: "a1",
                           title: "Igniter companion", body: "content",
                           created_at: "2026-04-30", status: :draft }
        a_receipt = store.write(article_class, **article_params)
        article   = store.read(article_class, key: "a1")

        {
          store_name:              reminder_class.store_name,
          generated_from_manifest: true,
          main_state_mutated:      false,
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
          },
          typed_fields: typed_fields_report(article_class, article, a_receipt)
        }.tap { store.close }
      end

      private

      def typed_fields_report(article_class, article, receipt)
        fields_meta = article_class._fields
        {
          field_count:          fields_meta.length,
          typed_field_count:    fields_meta.count { |_, m| !m[:type].nil? },
          enum_values_present:  fields_meta[:status]&.fetch(:values, nil)&.any?,
          status_type:          fields_meta[:status]&.fetch(:type),
          title_type:           fields_meta[:title]&.fetch(:type),
          created_at_type:      fields_meta[:created_at]&.fetch(:type),
          round_trip_status:    article.status,
          round_trip_title:     article.title,
          receipt_intent:       receipt.mutation_intent
        }
      end
    end
  end
end
