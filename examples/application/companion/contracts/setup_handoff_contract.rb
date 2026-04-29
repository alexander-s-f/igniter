# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :SetupHandoffContract, outputs: %i[status descriptor reading_order document_rotation architecture_constraints current_state next_scope next_action summary] do
      input :setup_health
      input :manifest_summary
      input :materializer_status

      compute :descriptor, depends_on: [:setup_health] do |setup_health:|
        {
          schema_version: 1,
          kind: :setup_handoff,
          report_only: true,
          gates_runtime: false,
          grants_capabilities: false,
          source: :setup_health,
          setup_health_kind: setup_health.fetch(:descriptor).fetch(:kind),
          purpose: :context_rotation
        }
      end

      compute :status, depends_on: [:setup_health] do |setup_health:|
        setup_health.fetch(:status)
      end

      compute :reading_order do
        [
          "/setup/health.json",
          "/setup/manifest/glossary-health.json",
          "/setup/materializer.json",
          "/setup/materializer/descriptor-health.json"
        ]
      end

      compute :document_rotation do
        {
          public: [
            "docs/research/companion-current-status-summary.md",
            "docs/research/companion-persistence-manifest-glossary.md",
            "docs/research/companion-persistence-app-status.md"
          ],
          private: [
            "playgrounds/docs/dev/tracks/contract-persistence-capability-track.md"
          ],
          policy: :compact_current_state_first,
          stale_history_policy: :prefer_handoff_over_long_thread
        }
      end

      compute :architecture_constraints do
        {
          scope: :app_local_companion_proof,
          public_api_promise: false,
          dynamic_runtime_contracts: false,
          materializer_execution: false,
          relation_enforcement: :report_only,
          approval_grants_capabilities: false,
          lowerings: {
            persist: :store_t,
            history: :history_t,
            relation: :relation_store_history
          },
          mutation_boundary: :app_store_boundary
        }
      end

      compute :current_state, depends_on: %i[setup_health manifest_summary materializer_status] do |setup_health:, manifest_summary:, materializer_status:|
        {
          setup_status: setup_health.fetch(:status),
          review_count: setup_health.fetch(:review_count),
          capabilities: manifest_summary.fetch(:capability_count),
          records: manifest_summary.fetch(:record_count),
          histories: manifest_summary.fetch(:history_count),
          relations: manifest_summary.fetch(:relation_count),
          materializer_phase: materializer_status.fetch(:phase),
          materializer_next_action: materializer_status.fetch(:next_action),
          materializer_grants_capabilities: materializer_status.fetch(:descriptor).fetch(:grants_capabilities)
        }
      end

      compute :next_scope do
        {
          policy: :small_reversible_app_local_slice,
          recommended: :record_blocked_materializer_attempt,
          candidates: [
            {
              name: :record_blocked_materializer_attempt,
              kind: :app_boundary_receipt,
              endpoint: "POST /setup/materializer-attempts/record",
              reason: :advance_review_lifecycle_without_execution
            },
            {
              name: :inspect_relation_warning_flow,
              kind: :diagnostic_projection,
              endpoint: "/setup/relation-health.json",
              reason: :keep_relations_report_only
            },
            {
              name: :extract_capability_descriptor_sketch,
              kind: :documentation_slice,
              endpoint: "/setup/handoff.json",
              reason: :prepare_future_package_boundary_without_public_api
            }
          ],
          forbidden: %i[
            materializer_execution
            approval_capability_grants
            public_api_promotion
            relation_enforcement
          ]
        }
      end

      compute :next_action, depends_on: %i[setup_health materializer_status] do |setup_health:, materializer_status:|
        if setup_health.fetch(:review_count).positive?
          :review_setup_health_items
        else
          materializer_status.fetch(:next_action)
        end
      end

      compute :summary, depends_on: %i[status current_state next_action] do |status:, current_state:, next_action:|
        "#{status}: #{current_state.fetch(:capabilities)} capabilities, #{current_state.fetch(:review_count)} review items, next=#{next_action}."
      end

      output :status
      output :descriptor
      output :reading_order
      output :document_rotation
      output :architecture_constraints
      output :current_state
      output :next_scope
      output :next_action
      output :summary
    end
  end
end
