# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :SetupHandoffExtractionSketchContract, outputs: %i[status descriptor placements maturity_ladder constraints next_action summary] do
      input :setup_handoff_packet_registry
      input :setup_handoff_supervision

      compute :descriptor do
        {
          schema_version: 1,
          kind: :setup_handoff_extraction_sketch,
          report_only: true,
          gates_runtime: false,
          grants_capabilities: false,
          package_promise: false,
          role: :landing_zone_sketch
        }
      end

      compute :placements, depends_on: [:setup_handoff_packet_registry] do |setup_handoff_packet_registry:|
        {
          companion_app_local: [
            :setup_handoff_packet_registry,
            *setup_handoff_packet_registry.fetch(:packets).map { |packet| packet.fetch(:name) }
          ],
          igniter_extensions_candidate: %i[
            persist_history_vocabulary
            store_history_relation_descriptors
            field_index_scope_command_metadata
            operation_intent_metadata
            report_only_diagnostics
          ],
          igniter_application_candidate: %i[
            packet_registry
            setup_readiness_surfaces
            explicit_app_boundary_writes
            materializer_review_flow
            adapter_host_binding
          ],
          future_igniter_persistence_candidate: %i[
            adapter_contract
            migration_change_plan_contract
            durable_capability_runtime_api
            relation_enforcement_policy
            persistence_test_kit
          ]
        }
      end

      compute :maturity_ladder do
        %i[
          companion_app_local_proof
          companion_internal_stabilization
          split_shaped_extraction_without_package_promise
          optional_shared_packs_after_repeated_pressure
          future_igniter_persistence_after_adapter_and_migration_stability
          lang_lowering_to_store_t_history_t_relation_t
        ]
      end

      compute :constraints do
        {
          current_scope: :companion_app_local,
          public_api_promise: false,
          package_split_now: false,
          dynamic_runtime_contracts: false,
          materializer_execution: false,
          capability_grants: false,
          forbidden_names: [:igniter_data],
          reserved_future_name: :igniter_persistence
        }
      end

      compute :status, depends_on: %i[setup_handoff_packet_registry setup_handoff_supervision] do |setup_handoff_packet_registry:, setup_handoff_supervision:|
        setup_handoff_packet_registry.fetch(:status) == :stable && setup_handoff_supervision.fetch(:descriptor).fetch(:grants_capabilities) == false ? :sketched : :needs_review
      end

      compute :next_action, depends_on: [:status] do |status:|
        status == :sketched ? :keep_companion_app_local : :review_extraction_pressure
      end

      compute :summary, depends_on: %i[status placements next_action] do |status:, placements:, next_action:|
        "#{status}: #{placements.fetch(:companion_app_local).length} app-local packets indexed, next=#{next_action}."
      end

      output :status
      output :descriptor
      output :placements
      output :maturity_ladder
      output :constraints
      output :next_action
      output :summary
    end
  end
end
