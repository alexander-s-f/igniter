# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :CompanionReceiptProjectionSidecarContract,
              outputs: %i[schema_version descriptor status checks projection mutation activity_feed summary] do
      input :proof

      compute :schema_version do
        1
      end

      compute :descriptor do
        {
          schema_version: 1,
          kind: :companion_receipt_projection_sidecar,
          report_only: true,
          gates_runtime: false,
          replaces_app_backend: false,
          mutates_main_state: false,
          source: :igniter_companion_write_receipt,
          target: :companion_action_history,
          projection_strategy: :small_app_receipt,
          direct_receipt_consumption: false,
          preserves: {
            command: :mutation_intent,
            app_boundary: :history_append,
            store_internals: :evidence_only
          }
        }
      end

      compute :projection, depends_on: [:proof] do |proof:|
        proof.fetch(:projection)
      end

      compute :mutation, depends_on: [:proof] do |proof:|
        proof.fetch(:mutation)
      end

      compute :activity_feed, depends_on: [:proof] do |proof:|
        proof.fetch(:activity_feed)
      end

      compute :checks, depends_on: %i[descriptor proof projection mutation activity_feed] do |descriptor:, proof:, projection:, mutation:, activity_feed:|
        package_receipt = proof.fetch(:package_receipt)
        app_receipt = projection.fetch(:app_receipt)
        event = mutation.fetch(:event)

        [
          Companion::Contracts.check(:report_only, descriptor.fetch(:report_only)),
          Companion::Contracts.check(:no_runtime_gate, descriptor.fetch(:gates_runtime) == false),
          Companion::Contracts.check(:no_backend_replacement, descriptor.fetch(:replaces_app_backend) == false),
          Companion::Contracts.check(:no_main_state_mutation, descriptor.fetch(:mutates_main_state) == false && proof.fetch(:main_state_mutated) == false),
          Companion::Contracts.check(:package_receipt_evidence, package_receipt.fetch(:mutation_intent) == :record_write &&
                                                                 package_receipt.fetch(:fact_id_present) &&
                                                                 package_receipt.fetch(:value_hash_present)),
          Companion::Contracts.check(:projection_layer_used, descriptor.fetch(:direct_receipt_consumption) == false &&
                                                             projection.fetch(:strategy) == :small_app_receipt),
          Companion::Contracts.check(:mutation_intent_preserved, app_receipt.fetch(:mutation_intent) == :record_write),
          Companion::Contracts.check(:store_internals_not_projected, app_receipt.fetch(:store_fact_exposed) == false &&
                                                                  app_receipt.fetch(:value_hash_exposed) == false &&
                                                                  !event.key?(:fact_id) &&
                                                                  !event.key?(:value_hash)),
          Companion::Contracts.check(:history_append_intent, mutation.fetch(:operation) == :history_append &&
                                                            mutation.fetch(:target) == :actions),
          Companion::Contracts.check(:action_event_shape, event.keys.sort == %i[index kind status subject_id] &&
                                                       event.fetch(:kind) == :store_write_receipt &&
                                                       event.fetch(:status) == :recorded),
          Companion::Contracts.check(:isolated_action_history_append, proof.fetch(:isolated_action_history_mutated) &&
                                                                  proof.fetch(:appended_action).fetch(:kind) == :store_write_receipt),
          Companion::Contracts.check(:activity_feed_projection, activity_feed.fetch(:action_count).positive? &&
                                                               activity_feed.fetch(:recent_events).last.fetch(:kind) == :store_write_receipt)
        ]
      end

      compute :status, depends_on: [:checks] do |checks:|
        checks.all? { |check| check.fetch(:present) } ? :stable : :review
      end

      compute :summary, depends_on: %i[status checks projection] do |status:, checks:, projection:|
        "#{status}: #{checks.length} receipt projection checks, " \
          "strategy=#{projection.fetch(:strategy)}, " \
          "intent=#{projection.fetch(:app_receipt).fetch(:mutation_intent)}."
      end

      output :schema_version
      output :descriptor
      output :status
      output :checks
      output :projection
      output :mutation
      output :activity_feed
      output :summary
    end
  end
end
