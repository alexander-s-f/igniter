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
      def self.packet
        proof = new.proof
        Contracts::StoreConvergenceSidecarContract.evaluate(proof: proof)
      end

      def proof
        reminder_record = Igniter::Companion.from_manifest(Contracts::Reminder.persistence_manifest)
        article_record = Igniter::Companion.from_manifest(Contracts::Article.persistence_manifest)
        tracker_log_event = Igniter::Companion.from_manifest(Contracts::TrackerLog.persistence_manifest)

        store = Igniter::Companion::Store.new
        store.register(reminder_record)

        notifications = []
        store.on_scope(reminder_record, :open) { |store_name, scope| notifications << [store_name, scope] }

        write_receipt = store.write(reminder_record, key: "morning-water", id: "morning-water", title: "Drink water", due: "morning", status: :open)
        read = store.read(reminder_record, key: "morning-water")
        open_before = store.scope(reminder_record, :open)
        sleep 0.001
        checkpoint = Process.clock_gettime(Process::CLOCK_REALTIME)
        sleep 0.001
        store.write(reminder_record, key: "morning-water", id: "morning-water", title: "Drink water", due: "morning", status: :done)
        current = store.read(reminder_record, key: "morning-water")
        past = store.read(reminder_record, key: "morning-water", as_of: checkpoint)
        open_after = store.scope(reminder_record, :open)

        first_receipt  = store.append(tracker_log_event, tracker_id: "sleep",     date: "2026-04-30", value: 7.0)
        second_receipt = store.append(tracker_log_event, tracker_id: "training",  date: "2026-04-30", value: 42.0)
        third_receipt  = store.append(tracker_log_event, tracker_id: "sleep",     date: "2026-05-01", value: 8.5)
        replay_all     = store.replay(tracker_log_event)
        replay_sleep   = store.replay(tracker_log_event, partition: "sleep")

        {
          schema_version: 1,
          package_facade: :"igniter-companion",
          substrate: :"igniter-store",
          backend: :memory,
          main_state_mutated: false,
          record: record_report(store, reminder_record, read, current, past, open_before, open_after, notifications, write_receipt),
          history: history_report(tracker_log_event, [first_receipt, second_receipt, third_receipt], replay_all, replay_sleep),
          relation: relation_report(article_record),
          pressure: pressure_report
        }.tap { store.close }
      end

      private

      def record_report(store, record_class, read, current, past, open_before, open_after, notifications, write_receipt)
        manifest = Contracts::Reminder.persistence_manifest
        {
          contract: :Reminder,
          package_class: record_class.name,
          generated_from_manifest: true,
          manifest_storage: manifest.fetch(:storage),
          manifest_store_name_present: !manifest.dig(:storage, :name).nil?,
          manifest_fields: manifest.fetch(:fields).map { |field| field.fetch(:name) },
          manifest_scopes: manifest.fetch(:scopes).map { |scope| scope.fetch(:name) },
          manifest_indexes: manifest.fetch(:indexes).map { |index| index.fetch(:name) },
          manifest_commands: manifest.fetch(:commands).map { |command| command.fetch(:name) },
          generated_index_names: record_class.respond_to?(:_indexes) ? record_class._indexes.keys : [],
          generated_command_names: record_class.respond_to?(:_commands) ? record_class._commands.keys : [],
          generated_effect_names: record_class.respond_to?(:_effects) ? record_class._effects.keys : [],
          generated_effect_store_ops: record_class.respond_to?(:_effects) ? record_class._effects.values.map { |effect| effect.fetch(:store_op) } : [],
          read_title: read.title,
          current_status: current.status,
          past_status: past.status,
          open_before_count: open_before.length,
          open_after_count: open_after.length,
          causation_count: store.causation_chain(record_class, key: "morning-water").length,
          invalidation_notifications: notifications,
          write_receipt_intent: write_receipt.mutation_intent,
          write_receipt_fact_id_present: !write_receipt.fact_id.nil?,
          write_receipt_delegates: write_receipt.title == "Drink water"
        }
      end

      def history_report(history_class, receipts, replay_all, replay_sleep)
        manifest = Contracts::TrackerLog.persistence_manifest
        {
          contract: :TrackerLog,
          package_class: history_class.name,
          generated_from_manifest: true,
          manifest_storage: manifest.fetch(:storage),
          manifest_store_name_present: !manifest.dig(:storage, :name).nil?,
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

      def relation_report(record_class)
        manifest = Contracts::Article.persistence_manifest
        generated_relations = record_class.respond_to?(:_relations) ? record_class._relations : {}
        relation = generated_relations.fetch(:comments_by_article, {})

        {
          contract: :Article,
          package_class: record_class.name,
          generated_from_manifest: true,
          manifest_relations: manifest.fetch(:relations).map { |entry| entry.fetch(:name) },
          generated_relation_names: generated_relations.keys,
          comments_relation_to: relation.fetch(:to, nil),
          comments_relation_kind: relation.fetch(:kind, nil),
          comments_relation_cardinality: relation.fetch(:cardinality, nil),
          store_side_join_execution: false
        }
      end

      def pressure_report
        {
          next_question: :companion_typed_resolve,
          adapter_slice: :sidecar_only,
          app_backend_migration: false,
          resolved: %i[
            manifest_generated_record_history_classes
            normalized_store_receipts_v2
            history_partition_key
            store_name_in_manifest
            companion_store_backed_app_flow
            portable_field_types
            mutation_intent_to_app_boundary
            index_metadata
            command_metadata
            effect_metadata
            relation_metadata
            app_projection_metadata_shape
            store_schema_graph_metadata_snapshot
            projection_descriptor_mirroring
            reactive_derivation
            scatter_derivation
            relation_rule_dsl
            companion_relation_auto_wire
          ],
          facade_input_ready: %i[
            storage_shape
            storage_name
            fields
            field_types
            field_defaults
            enum_values
            scopes
            indexes
            commands
            effects
            relations
            projections
            schema_graph_metadata_snapshot
            history_partition_key
            derivation_rules
            scatter_rules
            relation_rules
            typed_resolve
          ],
          asks: %i[
            companion_typed_resolve
          ],
          recommended_order: %i[
            companion_typed_resolve
          ]
        }
      end
    end
  end
end
