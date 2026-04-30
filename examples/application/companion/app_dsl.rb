# frozen_string_literal: true

require "json"

module Companion
  module AppDSL
    def companion_credentials(config)
      config.credentials.each do |definition|
        credential(
          definition.fetch(:name),
          env: definition.fetch(:env),
          required: definition.fetch(:required),
          description: definition.fetch(:description)
        )
      end
    end

    def companion_ai(config)
      ai do
        provider :openai, credential: :openai_api_key, model: config.llm_model
      end

      agents do
        assistant :daily_companion,
                  ai: :openai,
                  instructions: "You are Igniter Companion. Write a concise, practical daily summary for a personal assistant app.",
                  capsule: :daily_summary
      end
    end

    def companion_store(config)
      service(:companion) do |environment|
        Services::CompanionStore.new(
          credentials: config.credential_store,
          backend: config.store_adapter,
          assistant: environment.credentials.configured?(:openai_api_key) ? environment.agent(:daily_companion) : nil
        )
      end

      service(:hub) do
        next Services::HubInstaller::Null.new unless config.hub_configured?

        Services::HubInstaller.new(
          catalog_path: config.hub_catalog_path,
          install_root: config.hub_install_root
        )
      end
    end

    def companion_dashboard
      mount_web(
        :companion_dashboard,
        Web.companion_dashboard_mount,
        at: "/",
        capabilities: %i[screen command],
        metadata: { ready_to_go: true, capsules: %i[reminders trackers countdowns daily_summary] }
      )
    end

    def companion_routes
      get "/events" do
        text service(:companion).events_read_model
      end

      get "/setup" do
        snapshot = service(:companion).snapshot
        text({
          credentials: snapshot.credential_status,
          persistence: snapshot.persistence_readiness,
          relation_health: snapshot.relation_health,
          manifest_glossary: snapshot.manifest_glossary_health,
          storage_plan_sketch: service(:companion).storage_plan_sketch,
          storage_plan_health: service(:companion).storage_plan_health,
          storage_migration_plan: service(:companion).storage_migration_plan,
          storage_migration_plan_health: service(:companion).storage_migration_plan_health,
          field_type_plan: service(:companion).field_type_plan,
          field_type_health: service(:companion).field_type_health,
          relation_type_plan: service(:companion).relation_type_plan,
          relation_type_health: service(:companion).relation_type_health,
          access_path_plan: service(:companion).access_path_plan,
          access_path_health: service(:companion).access_path_health,
          effect_intent_plan: service(:companion).effect_intent_plan,
          effect_intent_health: service(:companion).effect_intent_health,
          store_convergence_sidecar: service(:companion).store_convergence_sidecar,
          companion_store_app_flow_sidecar: service(:companion).companion_store_app_flow_sidecar,
          companion_index_metadata_sidecar: service(:companion).companion_index_metadata_sidecar,
          companion_receipt_projection_sidecar: service(:companion).companion_receipt_projection_sidecar,
          materializer_descriptor_health: snapshot.materializer_status_descriptor_health,
          setup_health: service(:companion).setup_health,
          setup_handoff: service(:companion).setup_handoff,
          setup_handoff_acceptance: service(:companion).setup_handoff_acceptance,
          setup_handoff_approval_acceptance: service(:companion).setup_handoff_approval_acceptance,
          setup_handoff_lifecycle: service(:companion).setup_handoff_lifecycle,
          setup_handoff_lifecycle_health: service(:companion).setup_handoff_lifecycle_health,
          setup_handoff_next_scope: service(:companion).setup_handoff_next_scope,
          setup_handoff_next_scope_health: service(:companion).setup_handoff_next_scope_health,
          setup_handoff_supervision: service(:companion).setup_handoff_supervision,
          setup_handoff_packet_registry: service(:companion).setup_handoff_packet_registry,
          setup_handoff_extraction_sketch: service(:companion).setup_handoff_extraction_sketch,
          setup_handoff_promotion_readiness: service(:companion).setup_handoff_promotion_readiness,
          setup_handoff_digest: service(:companion).setup_handoff_digest
        }.inspect)
      end

      get "/setup/handoff" do
        text service(:companion).setup_handoff.inspect
      end

      get "/setup/handoff.json" do
        text JSON.pretty_generate(service(:companion).setup_handoff)
      end

      get "/setup/handoff/digest" do
        text service(:companion).setup_handoff_digest.inspect
      end

      get "/setup/handoff/digest.json" do
        text JSON.pretty_generate(service(:companion).setup_handoff_digest)
      end

      get "/setup/handoff/digest.txt" do
        digest = service(:companion).setup_handoff_digest
        lines = [
          digest.fetch(:diagram),
          "",
          digest.fetch(:summary),
          "",
          "next_reads:",
          *digest.fetch(:next_reads).map { |path| "- #{path}" }
        ]

        text lines.join("\n")
      end

      get "/setup/handoff/acceptance" do
        text service(:companion).setup_handoff_acceptance.inspect
      end

      get "/setup/handoff/acceptance.json" do
        text JSON.pretty_generate(service(:companion).setup_handoff_acceptance)
      end

      post "/setup/handoff/acceptance/record" do
        result = service(:companion).record_materializer_attempt
        redirect "/setup/handoff/acceptance?#{URI.encode_www_form((result.success? ? :notice : :error) => result.feedback_code, subject: result.subject_id)}"
      end

      get "/setup/handoff/next-scope" do
        text service(:companion).setup_handoff_next_scope.inspect
      end

      get "/setup/handoff/next-scope.json" do
        text JSON.pretty_generate(service(:companion).setup_handoff_next_scope)
      end

      get "/setup/handoff/next-scope-health" do
        text service(:companion).setup_handoff_next_scope_health.inspect
      end

      get "/setup/handoff/next-scope-health.json" do
        text JSON.pretty_generate(service(:companion).setup_handoff_next_scope_health)
      end

      get "/setup/handoff/packet-registry" do
        text service(:companion).setup_handoff_packet_registry.inspect
      end

      get "/setup/handoff/packet-registry.json" do
        text JSON.pretty_generate(service(:companion).setup_handoff_packet_registry)
      end

      get "/setup/handoff/extraction-sketch" do
        text service(:companion).setup_handoff_extraction_sketch.inspect
      end

      get "/setup/handoff/extraction-sketch.json" do
        text JSON.pretty_generate(service(:companion).setup_handoff_extraction_sketch)
      end

      get "/setup/handoff/promotion-readiness" do
        text service(:companion).setup_handoff_promotion_readiness.inspect
      end

      get "/setup/handoff/promotion-readiness.json" do
        text JSON.pretty_generate(service(:companion).setup_handoff_promotion_readiness)
      end

      get "/setup/handoff/supervision" do
        text service(:companion).setup_handoff_supervision.inspect
      end

      get "/setup/handoff/supervision.json" do
        text JSON.pretty_generate(service(:companion).setup_handoff_supervision)
      end

      get "/setup/handoff/lifecycle" do
        text service(:companion).setup_handoff_lifecycle.inspect
      end

      get "/setup/handoff/lifecycle.json" do
        text JSON.pretty_generate(service(:companion).setup_handoff_lifecycle)
      end

      get "/setup/handoff/lifecycle-health" do
        text service(:companion).setup_handoff_lifecycle_health.inspect
      end

      get "/setup/handoff/lifecycle-health.json" do
        text JSON.pretty_generate(service(:companion).setup_handoff_lifecycle_health)
      end

      get "/setup/handoff/approval-acceptance" do
        text service(:companion).setup_handoff_approval_acceptance.inspect
      end

      get "/setup/handoff/approval-acceptance.json" do
        text JSON.pretty_generate(service(:companion).setup_handoff_approval_acceptance)
      end

      post "/setup/handoff/approval-acceptance/record" do
        result = service(:companion).record_materializer_approval
        redirect "/setup/handoff/approval-acceptance?#{URI.encode_www_form((result.success? ? :notice : :error) => result.feedback_code, subject: result.subject_id)}"
      end

      get "/setup/health" do
        text service(:companion).setup_health.inspect
      end

      get "/setup/health.json" do
        text JSON.pretty_generate(service(:companion).setup_health)
      end

      get "/setup/manifest" do
        text service(:companion).persistence_manifest.inspect
      end

      get "/setup/manifest/glossary-health" do
        text service(:companion).manifest_glossary_health.inspect
      end

      get "/setup/manifest/glossary-health.json" do
        text JSON.pretty_generate(service(:companion).manifest_glossary_health)
      end

      get "/setup/storage-plan" do
        text service(:companion).storage_plan_sketch.inspect
      end

      get "/setup/storage-plan.json" do
        text JSON.pretty_generate(service(:companion).storage_plan_sketch)
      end

      get "/setup/storage-plan-health" do
        text service(:companion).storage_plan_health.inspect
      end

      get "/setup/storage-plan-health.json" do
        text JSON.pretty_generate(service(:companion).storage_plan_health)
      end

      get "/setup/storage-migration-plan" do
        text service(:companion).storage_migration_plan.inspect
      end

      get "/setup/storage-migration-plan.json" do
        text JSON.pretty_generate(service(:companion).storage_migration_plan)
      end

      get "/setup/storage-migration-plan-health" do
        text service(:companion).storage_migration_plan_health.inspect
      end

      get "/setup/storage-migration-plan-health.json" do
        text JSON.pretty_generate(service(:companion).storage_migration_plan_health)
      end

      get "/setup/field-type-plan" do
        text service(:companion).field_type_plan.inspect
      end

      get "/setup/field-type-plan.json" do
        text JSON.pretty_generate(service(:companion).field_type_plan)
      end

      get "/setup/field-type-health" do
        text service(:companion).field_type_health.inspect
      end

      get "/setup/field-type-health.json" do
        text JSON.pretty_generate(service(:companion).field_type_health)
      end

      get "/setup/relation-type-plan" do
        text service(:companion).relation_type_plan.inspect
      end

      get "/setup/relation-type-plan.json" do
        text JSON.pretty_generate(service(:companion).relation_type_plan)
      end

      get "/setup/relation-type-health" do
        text service(:companion).relation_type_health.inspect
      end

      get "/setup/relation-type-health.json" do
        text JSON.pretty_generate(service(:companion).relation_type_health)
      end

      get "/setup/access-path-plan" do
        text service(:companion).access_path_plan.inspect
      end

      get "/setup/access-path-plan.json" do
        text JSON.pretty_generate(service(:companion).access_path_plan)
      end

      get "/setup/access-path-health" do
        text service(:companion).access_path_health.inspect
      end

      get "/setup/access-path-health.json" do
        text JSON.pretty_generate(service(:companion).access_path_health)
      end

      get "/setup/effect-intent-plan" do
        text service(:companion).effect_intent_plan.inspect
      end

      get "/setup/effect-intent-plan.json" do
        text JSON.pretty_generate(service(:companion).effect_intent_plan)
      end

      get "/setup/effect-intent-health" do
        text service(:companion).effect_intent_health.inspect
      end

      get "/setup/effect-intent-health.json" do
        text JSON.pretty_generate(service(:companion).effect_intent_health)
      end

      get "/setup/store-convergence-sidecar" do
        text service(:companion).store_convergence_sidecar.inspect
      end

      get "/setup/store-convergence-sidecar.json" do
        text JSON.pretty_generate(service(:companion).store_convergence_sidecar)
      end

      get "/setup/companion-store-app-flow-sidecar" do
        text service(:companion).companion_store_app_flow_sidecar.inspect
      end

      get "/setup/companion-store-app-flow-sidecar.json" do
        text JSON.pretty_generate(service(:companion).companion_store_app_flow_sidecar)
      end

      get "/setup/companion-index-metadata-sidecar" do
        text service(:companion).companion_index_metadata_sidecar.inspect
      end

      get "/setup/companion-index-metadata-sidecar.json" do
        text JSON.pretty_generate(service(:companion).companion_index_metadata_sidecar)
      end

      get "/setup/companion-receipt-projection-sidecar" do
        text service(:companion).companion_receipt_projection_sidecar.inspect
      end

      get "/setup/companion-receipt-projection-sidecar.json" do
        text JSON.pretty_generate(service(:companion).companion_receipt_projection_sidecar)
      end

      get "/setup/relation-health" do
        text service(:companion).snapshot.relation_health.inspect
      end

      get "/setup/relation-health.json" do
        text JSON.pretty_generate(service(:companion).snapshot.relation_health)
      end

      get "/setup/materialization-plan" do
        text service(:companion).materialization_plan.inspect
      end

      get "/setup/materialization-plan.json" do
        text JSON.pretty_generate(service(:companion).materialization_plan)
      end

      get "/setup/materialization-parity" do
        text service(:companion).materialization_parity.inspect
      end

      get "/setup/materialization-parity.json" do
        text JSON.pretty_generate(service(:companion).materialization_parity)
      end

      get "/setup/wizard-type-specs" do
        text service(:companion).wizard_type_specs.map(&:to_h).inspect
      end

      get "/setup/wizard-type-specs.json" do
        text JSON.pretty_generate(service(:companion).wizard_type_specs.map(&:to_h))
      end

      get "/setup/wizard-type-spec-export" do
        text service(:companion).wizard_type_spec_export.inspect
      end

      get "/setup/wizard-type-spec-export.json" do
        text JSON.pretty_generate(service(:companion).wizard_type_spec_export)
      end

      get "/setup/wizard-type-spec-migration-plan" do
        text service(:companion).wizard_type_spec_migration_plan.inspect
      end

      get "/setup/wizard-type-spec-migration-plan.json" do
        text JSON.pretty_generate(service(:companion).wizard_type_spec_migration_plan)
      end

      get "/setup/infrastructure-loop-health" do
        text service(:companion).infrastructure_loop_health.inspect
      end

      get "/setup/infrastructure-loop-health.json" do
        text JSON.pretty_generate(service(:companion).infrastructure_loop_health)
      end

      get "/setup/materializer" do
        text service(:companion).materializer_status.inspect
      end

      get "/setup/materializer.json" do
        text JSON.pretty_generate(service(:companion).materializer_status)
      end

      get "/setup/materializer/descriptor-health" do
        text service(:companion).materializer_status_descriptor_health.inspect
      end

      get "/setup/materializer/descriptor-health.json" do
        text JSON.pretty_generate(service(:companion).materializer_status_descriptor_health)
      end

      get "/setup/materializer-gate" do
        text service(:companion).materializer_gate.inspect
      end

      get "/setup/materializer-gate.json" do
        text JSON.pretty_generate(service(:companion).materializer_gate)
      end

      get "/setup/materializer-preflight" do
        text service(:companion).materializer_preflight.inspect
      end

      get "/setup/materializer-preflight.json" do
        text JSON.pretty_generate(service(:companion).materializer_preflight)
      end

      get "/setup/materializer-runbook" do
        text service(:companion).materializer_runbook.inspect
      end

      get "/setup/materializer-runbook.json" do
        text JSON.pretty_generate(service(:companion).materializer_runbook)
      end

      get "/setup/materializer-receipt" do
        text service(:companion).materializer_receipt.inspect
      end

      get "/setup/materializer-receipt.json" do
        text JSON.pretty_generate(service(:companion).materializer_receipt)
      end

      get "/setup/materializer-attempt-command" do
        text service(:companion).materializer_attempt_command.inspect
      end

      get "/setup/materializer-attempt-command.json" do
        text JSON.pretty_generate(service(:companion).materializer_attempt_command)
      end

      get "/setup/materializer-attempts" do
        text service(:companion).materializer_attempts.inspect
      end

      get "/setup/materializer-attempts.json" do
        text JSON.pretty_generate(service(:companion).materializer_attempts)
      end

      get "/setup/materializer-audit-trail" do
        text service(:companion).materializer_audit_trail.inspect
      end

      get "/setup/materializer-audit-trail.json" do
        text JSON.pretty_generate(service(:companion).materializer_audit_trail)
      end

      get "/setup/materializer-supervision" do
        text service(:companion).materializer_supervision.inspect
      end

      get "/setup/materializer-supervision.json" do
        text JSON.pretty_generate(service(:companion).materializer_supervision)
      end

      get "/setup/materializer-approval-policy" do
        text service(:companion).materializer_approval_policy.inspect
      end

      get "/setup/materializer-approval-policy.json" do
        text JSON.pretty_generate(service(:companion).materializer_approval_policy)
      end

      get "/setup/materializer-approval-receipt" do
        text service(:companion).materializer_approval_receipt.inspect
      end

      get "/setup/materializer-approval-receipt.json" do
        text JSON.pretty_generate(service(:companion).materializer_approval_receipt)
      end

      get "/setup/materializer-approval-command" do
        text service(:companion).materializer_approval_command.inspect
      end

      get "/setup/materializer-approval-command.json" do
        text JSON.pretty_generate(service(:companion).materializer_approval_command)
      end

      get "/setup/materializer-approvals" do
        text service(:companion).materializer_approvals.inspect
      end

      get "/setup/materializer-approvals.json" do
        text JSON.pretty_generate(service(:companion).materializer_approvals)
      end

      get "/setup/materializer-approval-audit-trail" do
        text service(:companion).materializer_approval_audit_trail.inspect
      end

      get "/setup/materializer-approval-audit-trail.json" do
        text JSON.pretty_generate(service(:companion).materializer_approval_audit_trail)
      end

      post "/setup/materializer-attempts/record" do
        result = service(:companion).record_materializer_attempt
        redirect Companion.feedback_path(
          (result.success? ? :notice : :error) => result.feedback_code,
          subject: result.subject_id
        )
      end

      post "/setup/materializer-approvals/record" do
        result = service(:companion).record_materializer_approval
        redirect Companion.feedback_path(
          (result.success? ? :notice : :error) => result.feedback_code,
          subject: result.subject_id
        )
      end

      get "/hub" do
        text service(:hub).entries.map(&:name).join(",")
      end

      post "/hub/:name/install" do |params|
        result = service(:hub).install(params.fetch("name", ""))
        redirect Companion.feedback_path(
          (result.success? ? :notice : :error) => (result.success? ? :hub_capsule_installed : :hub_capsule_blocked),
          subject: params.fetch("name", "")
        )
      rescue KeyError
        redirect Companion.feedback_path(error: :hub_capsule_unknown, subject: params.fetch("name", ""))
      end

      post "/summary/live" do
        result = service(:companion).generate_live_summary
        redirect Companion.feedback_path(
          (result.success? ? :notice : :error) => result.feedback_code,
          subject: result.subject_id
        )
      end

      post "/reminders/create" do |params|
        result = service(:companion).create_reminder(params.fetch("title", ""))
        redirect Companion.feedback_path(
          (result.success? ? :notice : :error) => result.feedback_code,
          subject: result.subject_id
        )
      end

      post "/today/focus" do |params|
        result = service(:companion).update_daily_focus(params.fetch("title", ""))
        redirect Companion.feedback_path(
          (result.success? ? :notice : :error) => result.feedback_code,
          subject: result.subject_id
        )
      end

      post "/today/quick-action" do |params|
        result = service(:companion).run_today_quick_action(value: params.fetch("value", ""))
        redirect Companion.feedback_path(
          (result.success? ? :notice : :error) => result.feedback_code,
          subject: result.subject_id
        )
      end

      post "/countdowns/create" do |params|
        result = service(:companion).create_countdown(params.fetch("title", ""), params.fetch("target_date", ""))
        redirect Companion.feedback_path(
          (result.success? ? :notice : :error) => result.feedback_code,
          subject: result.subject_id
        )
      end

      post "/reminders/:id/complete" do |params|
        result = service(:companion).complete_reminder(params.fetch("id", ""))
        redirect Companion.feedback_path(
          (result.success? ? :notice : :error) => result.feedback_code,
          subject: result.subject_id
        )
      end

      post "/trackers/:id/log" do |params|
        result = service(:companion).log_tracker(params.fetch("id", ""), params.fetch("value", ""))
        redirect Companion.feedback_path(
          (result.success? ? :notice : :error) => result.feedback_code,
          subject: result.subject_id
        )
      end
    end
  end
end
