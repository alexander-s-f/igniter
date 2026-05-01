# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :StoreConvergenceSidecarContract,
              outputs: %i[schema_version descriptor status checks record history relation pressure summary] do
      input :proof

      compute :schema_version do
        1
      end

      compute :descriptor do
        {
          schema_version: 1,
          kind: :store_convergence_sidecar,
          report_only: true,
          gates_runtime: false,
          grants_capabilities: false,
          replaces_app_backend: false,
          mutates_main_state: false,
          package_facade: :"igniter-companion",
          substrate: :"igniter-store",
          role: :tiny_convergence_proof,
          preserves: {
            persist: :store_t,
            history: :history_t,
            command: :mutation_intent
          }
        }
      end

      compute :record, depends_on: [:proof] do |proof:|
        proof.fetch(:record)
      end

      compute :history, depends_on: [:proof] do |proof:|
        proof.fetch(:history)
      end

      compute :relation, depends_on: [:proof] do |proof:|
        proof.fetch(:relation)
      end

      compute :pressure, depends_on: [:proof] do |proof:|
        proof.fetch(:pressure)
      end

      compute :checks, depends_on: %i[descriptor record history relation proof] do |descriptor:, record:, history:, relation:, proof:|
        [
          Companion::Contracts.check(:report_only,                  descriptor.fetch(:report_only)),
          Companion::Contracts.check(:no_runtime_gate,              descriptor.fetch(:gates_runtime) == false),
          Companion::Contracts.check(:no_capability_grants,         descriptor.fetch(:grants_capabilities) == false),
          Companion::Contracts.check(:no_app_backend_replacement,   descriptor.fetch(:replaces_app_backend) == false),
          Companion::Contracts.check(:no_main_state_mutation,       proof.fetch(:main_state_mutated) == false),
          Companion::Contracts.check(:package_facade_present,       proof.fetch(:package_facade) == :"igniter-companion"),
          Companion::Contracts.check(:substrate_present,            proof.fetch(:substrate) == :"igniter-store"),
          Companion::Contracts.check(:record_manifest_generated,     record.fetch(:generated_from_manifest) == true),
          Companion::Contracts.check(:history_manifest_generated,    history.fetch(:generated_from_manifest) == true),
          Companion::Contracts.check(:store_name_in_manifest,        record.fetch(:manifest_store_name_present) &&
                                                                     history.fetch(:manifest_store_name_present)),
          Companion::Contracts.check(:record_index_metadata,         record.fetch(:manifest_indexes).include?(:status) &&
                                                                     record.fetch(:generated_index_names).include?(:status)),
          Companion::Contracts.check(:record_command_metadata,       record.fetch(:manifest_commands).include?(:complete) &&
                                                                     record.fetch(:generated_command_names).include?(:complete)),
          Companion::Contracts.check(:record_effect_metadata,        record.fetch(:generated_effect_names).include?(:complete) &&
                                                                     record.fetch(:generated_effect_store_ops).include?(:store_write)),
          Companion::Contracts.check(:record_relation_metadata,      relation.fetch(:manifest_relations).include?(:comments_by_article) &&
                                                                     relation.fetch(:generated_relation_names).include?(:comments_by_article) &&
                                                                     relation.fetch(:comments_relation_to) == :comments &&
                                                                     relation.fetch(:store_side_join_execution) == false),
          Companion::Contracts.check(:record_round_trip,            record.fetch(:current_status) == :done),
          Companion::Contracts.check(:record_scope_works,           record.fetch(:open_before_count) == 1 && record.fetch(:open_after_count).zero?),
          Companion::Contracts.check(:record_time_travel_works,     record.fetch(:past_status) == :open),
          Companion::Contracts.check(:record_causation_chain,       record.fetch(:causation_count) == 2),
          Companion::Contracts.check(:write_receipt_present,        record.fetch(:write_receipt_intent) == :record_write &&
                                                                    record.fetch(:write_receipt_fact_id_present) &&
                                                                    record.fetch(:write_receipt_delegates)),
          Companion::Contracts.check(:history_append_replay,        history.fetch(:replay_count) == 3),
          Companion::Contracts.check(:history_fact_receipts,        history.fetch(:event_fact_ids).all?),
          Companion::Contracts.check(:history_float_round_trip,     history.fetch(:values) == [7.0, 8.5]),
          Companion::Contracts.check(:append_receipt_present,       history.fetch(:append_receipt_intent) == :history_append),
          Companion::Contracts.check(:history_partition_query,      history.fetch(:partition_query_supported) &&
                                                                    history.fetch(:partition_replay_count) == 2 &&
                                                                    history.fetch(:partition_replay_values) == [7.0, 8.5])
        ]
      end

      compute :status, depends_on: [:checks] do |checks:|
        checks.all? { |check| check.fetch(:present) } ? :stable : :review
      end

      compute :summary, depends_on: %i[status checks record history pressure] do |status:, checks:, record:, history:, pressure:|
        "#{status}: #{checks.length} sidecar checks, record=#{record.fetch(:current_status)}, history=#{history.fetch(:replay_count)}, pressure=#{pressure.fetch(:next_question)}."
      end

      output :schema_version
      output :descriptor
      output :status
      output :checks
      output :record
      output :history
      output :relation
      output :pressure
      output :summary
    end
  end
end
