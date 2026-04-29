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
          manifest_glossary: snapshot.manifest_glossary_health
        }.inspect)
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
