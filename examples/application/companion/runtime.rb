# frozen_string_literal: true

require "fileutils"
require "json"
require "stringio"
require "tmpdir"
require "uri"

require_relative "app"

module Companion
  module Runtime
    module_function

    def call(argv, env: ENV, out: $stdout)
      return server(env: env, out: out) if argv.first == "server"

      env.delete("OPENAI_API_KEY") unless env["COMPANION_LIVE"] == "1"
      db_path = File.join(Dir.tmpdir, "igniter_companion_poc_#{Process.pid}.sqlite3")
      FileUtils.rm_f(db_path)
      hub = build_local_hub_fixture
      config = Companion.default_configuration(store_path: db_path)
      config.hub(catalog_path: hub.fetch(:catalog_path), install_root: hub.fetch(:install_root))
      app = Companion.build(config: config)
      run_smoke(app, config: config, db_path: db_path, out: out)
    end

    def server(env:, out:)
      require "webrick"

      app = Companion.build(
        config: Companion.default_configuration(
          store_path: env.fetch("COMPANION_DB", File.join(Companion::APP_ROOT, "tmp", "companion.sqlite3"))
        )
      )
      server = WEBrick::HTTPServer.new(
        Port: Integer(env.fetch("PORT", "9298")),
        BindAddress: "127.0.0.1",
        AccessLog: [],
        Logger: WEBrick::Log.new(File::NULL)
      )
      server.mount_proc("/") do |request, response|
        status, headers, body = app.call(
          "REQUEST_METHOD" => request.request_method,
          "PATH_INFO" => request.path,
          "QUERY_STRING" => request.query_string.to_s,
          "rack.input" => StringIO.new(request.body.to_s)
        )
        response.status = status
        headers.each { |key, value| response[key] = value }
        response.body = body.join
      end
      trap("INT") { server.shutdown }
      out.puts "companion_poc_url=http://127.0.0.1:#{server.config[:Port]}/"
      server.start
    end

    def run_smoke(app, config:, db_path:, out:)
      store = app.service(:companion)
      initial = store.snapshot

      create_status, create_headers = post(app, "/reminders/create", title: "Stretch for five minutes")
      created_status = get_status(app, create_headers.fetch("location"))
      blank_reminder_status, blank_reminder_headers = post(app, "/reminders/create", title: " ")
      blank_reminder_result_status = get_status(app, blank_reminder_headers.fetch("location"))
      log_status, log_headers = post(app, "/trackers/sleep/log", value: "7.5")
      logged_status = get_status(app, log_headers.fetch("location"))
      blank_tracker_status, blank_tracker_headers = post(app, "/trackers/sleep/log", value: " ")
      blank_tracker_result_status = get_status(app, blank_tracker_headers.fetch("location"))
      focus_status, focus_headers = post(app, "/today/focus", title: "Draft the launch note")
      focused_status = get_status(app, focus_headers.fetch("location"))
      countdown_status, countdown_headers = post(app, "/countdowns/create", title: "Launch day", target_date: "2026-05-15")
      countdown_created_status = get_status(app, countdown_headers.fetch("location"))
      blank_countdown_status, blank_countdown_headers = post(app, "/countdowns/create", title: " ", target_date: " ")
      blank_countdown_result_status = get_status(app, blank_countdown_headers.fetch("location"))
      complete_status, complete_headers = post(app, "/reminders/morning-water/complete")
      completed_status = get_status(app, complete_headers.fetch("location"))

      events_status, _events_headers, events_body = app.call(rack_env("GET", "/events"))
      setup_status, _setup_headers, setup_body = app.call(rack_env("GET", "/setup"))
      setup_handoff_status, _setup_handoff_headers, setup_handoff_body = app.call(rack_env("GET", "/setup/handoff"))
      setup_handoff_json_status, _setup_handoff_json_headers, setup_handoff_json_body = app.call(rack_env("GET", "/setup/handoff.json"))
      setup_handoff_digest_status, _setup_handoff_digest_headers, setup_handoff_digest_body = app.call(rack_env("GET", "/setup/handoff/digest"))
      setup_handoff_digest_json_status, _setup_handoff_digest_json_headers, setup_handoff_digest_json_body = app.call(rack_env("GET", "/setup/handoff/digest.json"))
      setup_handoff_digest_text_status, _setup_handoff_digest_text_headers, setup_handoff_digest_text_body = app.call(rack_env("GET", "/setup/handoff/digest.txt"))
      setup_handoff_next_scope_status, _setup_handoff_next_scope_headers, setup_handoff_next_scope_body = app.call(rack_env("GET", "/setup/handoff/next-scope"))
      setup_handoff_next_scope_json_status, _setup_handoff_next_scope_json_headers, setup_handoff_next_scope_json_body = app.call(rack_env("GET", "/setup/handoff/next-scope.json"))
      setup_handoff_next_scope_health_status, _setup_handoff_next_scope_health_headers, setup_handoff_next_scope_health_body = app.call(rack_env("GET", "/setup/handoff/next-scope-health"))
      setup_handoff_next_scope_health_json_status, _setup_handoff_next_scope_health_json_headers, setup_handoff_next_scope_health_json_body = app.call(rack_env("GET", "/setup/handoff/next-scope-health.json"))
      setup_handoff_promotion_readiness_status, _setup_handoff_promotion_readiness_headers, setup_handoff_promotion_readiness_body = app.call(rack_env("GET", "/setup/handoff/promotion-readiness"))
      setup_handoff_promotion_readiness_json_status, _setup_handoff_promotion_readiness_json_headers, setup_handoff_promotion_readiness_json_body = app.call(rack_env("GET", "/setup/handoff/promotion-readiness.json"))
      setup_handoff_extraction_sketch_status, _setup_handoff_extraction_sketch_headers, setup_handoff_extraction_sketch_body = app.call(rack_env("GET", "/setup/handoff/extraction-sketch"))
      setup_handoff_extraction_sketch_json_status, _setup_handoff_extraction_sketch_json_headers, setup_handoff_extraction_sketch_json_body = app.call(rack_env("GET", "/setup/handoff/extraction-sketch.json"))
      setup_handoff_packet_registry_status, _setup_handoff_packet_registry_headers, setup_handoff_packet_registry_body = app.call(rack_env("GET", "/setup/handoff/packet-registry"))
      setup_handoff_packet_registry_json_status, _setup_handoff_packet_registry_json_headers, setup_handoff_packet_registry_json_body = app.call(rack_env("GET", "/setup/handoff/packet-registry.json"))
      setup_handoff_supervision_status, _setup_handoff_supervision_headers, setup_handoff_supervision_body = app.call(rack_env("GET", "/setup/handoff/supervision"))
      setup_handoff_supervision_json_status, _setup_handoff_supervision_json_headers, setup_handoff_supervision_json_body = app.call(rack_env("GET", "/setup/handoff/supervision.json"))
      setup_handoff_acceptance_status, _setup_handoff_acceptance_headers, setup_handoff_acceptance_body = app.call(rack_env("GET", "/setup/handoff/acceptance"))
      setup_handoff_acceptance_json_status, _setup_handoff_acceptance_json_headers, setup_handoff_acceptance_json_body = app.call(rack_env("GET", "/setup/handoff/acceptance.json"))
      setup_handoff_lifecycle_status, _setup_handoff_lifecycle_headers, setup_handoff_lifecycle_body = app.call(rack_env("GET", "/setup/handoff/lifecycle"))
      setup_handoff_lifecycle_json_status, _setup_handoff_lifecycle_json_headers, setup_handoff_lifecycle_json_body = app.call(rack_env("GET", "/setup/handoff/lifecycle.json"))
      setup_handoff_lifecycle_health_status, _setup_handoff_lifecycle_health_headers, setup_handoff_lifecycle_health_body = app.call(rack_env("GET", "/setup/handoff/lifecycle-health"))
      setup_handoff_lifecycle_health_json_status, _setup_handoff_lifecycle_health_json_headers, setup_handoff_lifecycle_health_json_body = app.call(rack_env("GET", "/setup/handoff/lifecycle-health.json"))
      setup_handoff_approval_acceptance_status, _setup_handoff_approval_acceptance_headers, setup_handoff_approval_acceptance_body = app.call(rack_env("GET", "/setup/handoff/approval-acceptance"))
      setup_handoff_approval_acceptance_json_status, _setup_handoff_approval_acceptance_json_headers, setup_handoff_approval_acceptance_json_body = app.call(rack_env("GET", "/setup/handoff/approval-acceptance.json"))
      setup_health_status, _setup_health_headers, setup_health_body = app.call(rack_env("GET", "/setup/health"))
      setup_health_json_status, _setup_health_json_headers, setup_health_json_body = app.call(rack_env("GET", "/setup/health.json"))
      manifest_status, _manifest_headers, manifest_body = app.call(rack_env("GET", "/setup/manifest"))
      manifest_glossary_status, _manifest_glossary_headers, manifest_glossary_body = app.call(rack_env("GET", "/setup/manifest/glossary-health"))
      manifest_glossary_json_status, _manifest_glossary_json_headers, manifest_glossary_json_body = app.call(rack_env("GET", "/setup/manifest/glossary-health.json"))
      storage_plan_status, _storage_plan_headers, storage_plan_body = app.call(rack_env("GET", "/setup/storage-plan"))
      storage_plan_json_status, _storage_plan_json_headers, storage_plan_json_body = app.call(rack_env("GET", "/setup/storage-plan.json"))
      storage_plan_health_status, _storage_plan_health_headers, storage_plan_health_body = app.call(rack_env("GET", "/setup/storage-plan-health"))
      storage_plan_health_json_status, _storage_plan_health_json_headers, storage_plan_health_json_body = app.call(rack_env("GET", "/setup/storage-plan-health.json"))
      storage_migration_plan_status, _storage_migration_plan_headers, storage_migration_plan_body = app.call(rack_env("GET", "/setup/storage-migration-plan"))
      storage_migration_plan_json_status, _storage_migration_plan_json_headers, storage_migration_plan_json_body = app.call(rack_env("GET", "/setup/storage-migration-plan.json"))
      storage_migration_plan_health_status, _storage_migration_plan_health_headers, storage_migration_plan_health_body = app.call(rack_env("GET", "/setup/storage-migration-plan-health"))
      storage_migration_plan_health_json_status, _storage_migration_plan_health_json_headers, storage_migration_plan_health_json_body = app.call(rack_env("GET", "/setup/storage-migration-plan-health.json"))
      field_type_plan_status, _field_type_plan_headers, field_type_plan_body = app.call(rack_env("GET", "/setup/field-type-plan"))
      field_type_plan_json_status, _field_type_plan_json_headers, field_type_plan_json_body = app.call(rack_env("GET", "/setup/field-type-plan.json"))
      field_type_health_status, _field_type_health_headers, field_type_health_body = app.call(rack_env("GET", "/setup/field-type-health"))
      field_type_health_json_status, _field_type_health_json_headers, field_type_health_json_body = app.call(rack_env("GET", "/setup/field-type-health.json"))
      relation_type_plan_status, _relation_type_plan_headers, relation_type_plan_body = app.call(rack_env("GET", "/setup/relation-type-plan"))
      relation_type_plan_json_status, _relation_type_plan_json_headers, relation_type_plan_json_body = app.call(rack_env("GET", "/setup/relation-type-plan.json"))
      relation_type_health_status, _relation_type_health_headers, relation_type_health_body = app.call(rack_env("GET", "/setup/relation-type-health"))
      relation_type_health_json_status, _relation_type_health_json_headers, relation_type_health_json_body = app.call(rack_env("GET", "/setup/relation-type-health.json"))
      access_path_plan_status, _access_path_plan_headers, access_path_plan_body = app.call(rack_env("GET", "/setup/access-path-plan"))
      access_path_plan_json_status, _access_path_plan_json_headers, access_path_plan_json_body = app.call(rack_env("GET", "/setup/access-path-plan.json"))
      access_path_health_status, _access_path_health_headers, access_path_health_body = app.call(rack_env("GET", "/setup/access-path-health"))
      access_path_health_json_status, _access_path_health_json_headers, access_path_health_json_body = app.call(rack_env("GET", "/setup/access-path-health.json"))
      effect_intent_plan_status, _effect_intent_plan_headers, effect_intent_plan_body = app.call(rack_env("GET", "/setup/effect-intent-plan"))
      effect_intent_plan_json_status, _effect_intent_plan_json_headers, effect_intent_plan_json_body = app.call(rack_env("GET", "/setup/effect-intent-plan.json"))
      effect_intent_health_status, _effect_intent_health_headers, effect_intent_health_body = app.call(rack_env("GET", "/setup/effect-intent-health"))
      effect_intent_health_json_status, _effect_intent_health_json_headers, effect_intent_health_json_body = app.call(rack_env("GET", "/setup/effect-intent-health.json"))
      store_convergence_status, _store_convergence_headers, store_convergence_body = app.call(rack_env("GET", "/setup/store-convergence-sidecar"))
      store_convergence_json_status, _store_convergence_json_headers, store_convergence_json_body = app.call(rack_env("GET", "/setup/store-convergence-sidecar.json"))
      relation_health_status, _relation_health_headers, relation_health_body = app.call(rack_env("GET", "/setup/relation-health"))
      relation_health_json_status, _relation_health_json_headers, relation_health_json_body = app.call(rack_env("GET", "/setup/relation-health.json"))
      materialization_status, _materialization_headers, materialization_body = app.call(rack_env("GET", "/setup/materialization-plan"))
      materialization_json_status, _materialization_json_headers, materialization_json_body = app.call(rack_env("GET", "/setup/materialization-plan.json"))
      parity_status, _parity_headers, parity_body = app.call(rack_env("GET", "/setup/materialization-parity"))
      parity_json_status, _parity_json_headers, parity_json_body = app.call(rack_env("GET", "/setup/materialization-parity.json"))
      wizard_spec_status, _wizard_spec_headers, wizard_spec_body = app.call(rack_env("GET", "/setup/wizard-type-specs"))
      wizard_spec_json_status, _wizard_spec_json_headers, wizard_spec_json_body = app.call(rack_env("GET", "/setup/wizard-type-specs.json"))
      wizard_export_status, _wizard_export_headers, wizard_export_body = app.call(rack_env("GET", "/setup/wizard-type-spec-export"))
      wizard_export_json_status, _wizard_export_json_headers, wizard_export_json_body = app.call(rack_env("GET", "/setup/wizard-type-spec-export.json"))
      wizard_migration_status, _wizard_migration_headers, wizard_migration_body = app.call(rack_env("GET", "/setup/wizard-type-spec-migration-plan"))
      wizard_migration_json_status, _wizard_migration_json_headers, wizard_migration_json_body = app.call(rack_env("GET", "/setup/wizard-type-spec-migration-plan.json"))
      loop_health_status, _loop_health_headers, loop_health_body = app.call(rack_env("GET", "/setup/infrastructure-loop-health"))
      loop_health_json_status, _loop_health_json_headers, loop_health_json_body = app.call(rack_env("GET", "/setup/infrastructure-loop-health.json"))
      materializer_status, _materializer_headers, materializer_body = app.call(rack_env("GET", "/setup/materializer"))
      materializer_json_status, _materializer_json_headers, materializer_json_body = app.call(rack_env("GET", "/setup/materializer.json"))
      materializer_descriptor_health_status, _materializer_descriptor_health_headers, materializer_descriptor_health_body = app.call(rack_env("GET", "/setup/materializer/descriptor-health"))
      materializer_descriptor_health_json_status, _materializer_descriptor_health_json_headers, materializer_descriptor_health_json_body = app.call(rack_env("GET", "/setup/materializer/descriptor-health.json"))
      materializer_gate_status, _materializer_gate_headers, materializer_gate_body = app.call(rack_env("GET", "/setup/materializer-gate"))
      materializer_gate_json_status, _materializer_gate_json_headers, materializer_gate_json_body = app.call(rack_env("GET", "/setup/materializer-gate.json"))
      materializer_preflight_status, _materializer_preflight_headers, materializer_preflight_body = app.call(rack_env("GET", "/setup/materializer-preflight"))
      materializer_preflight_json_status, _materializer_preflight_json_headers, materializer_preflight_json_body = app.call(rack_env("GET", "/setup/materializer-preflight.json"))
      materializer_runbook_status, _materializer_runbook_headers, materializer_runbook_body = app.call(rack_env("GET", "/setup/materializer-runbook"))
      materializer_runbook_json_status, _materializer_runbook_json_headers, materializer_runbook_json_body = app.call(rack_env("GET", "/setup/materializer-runbook.json"))
      materializer_receipt_status, _materializer_receipt_headers, materializer_receipt_body = app.call(rack_env("GET", "/setup/materializer-receipt"))
      materializer_receipt_json_status, _materializer_receipt_json_headers, materializer_receipt_json_body = app.call(rack_env("GET", "/setup/materializer-receipt.json"))
      materializer_attempt_command_status, _materializer_attempt_command_headers, materializer_attempt_command_body = app.call(rack_env("GET", "/setup/materializer-attempt-command"))
      materializer_attempt_command_json_status, _materializer_attempt_command_json_headers, materializer_attempt_command_json_body = app.call(rack_env("GET", "/setup/materializer-attempt-command.json"))
      materializer_audit_status, _materializer_audit_headers, materializer_audit_body = app.call(rack_env("GET", "/setup/materializer-audit-trail"))
      materializer_audit_json_status, _materializer_audit_json_headers, materializer_audit_json_body = app.call(rack_env("GET", "/setup/materializer-audit-trail.json"))
      materializer_supervision_status, _materializer_supervision_headers, materializer_supervision_body = app.call(rack_env("GET", "/setup/materializer-supervision"))
      materializer_supervision_json_status, _materializer_supervision_json_headers, materializer_supervision_json_body = app.call(rack_env("GET", "/setup/materializer-supervision.json"))
      materializer_approval_status, _materializer_approval_headers, materializer_approval_body = app.call(rack_env("GET", "/setup/materializer-approval-policy"))
      materializer_approval_json_status, _materializer_approval_json_headers, materializer_approval_json_body = app.call(rack_env("GET", "/setup/materializer-approval-policy.json"))
      materializer_approval_receipt_status, _materializer_approval_receipt_headers, materializer_approval_receipt_body = app.call(rack_env("GET", "/setup/materializer-approval-receipt"))
      materializer_approval_receipt_json_status, _materializer_approval_receipt_json_headers, materializer_approval_receipt_json_body = app.call(rack_env("GET", "/setup/materializer-approval-receipt.json"))
      materializer_approval_command_status, _materializer_approval_command_headers, materializer_approval_command_body = app.call(rack_env("GET", "/setup/materializer-approval-command"))
      materializer_approval_command_json_status, _materializer_approval_command_json_headers, materializer_approval_command_json_body = app.call(rack_env("GET", "/setup/materializer-approval-command.json"))
      materializer_approvals_status, _materializer_approvals_headers, materializer_approvals_body = app.call(rack_env("GET", "/setup/materializer-approvals"))
      materializer_approvals_json_status, _materializer_approvals_json_headers, materializer_approvals_json_body = app.call(rack_env("GET", "/setup/materializer-approvals.json"))
      materializer_approval_audit_status, _materializer_approval_audit_headers, materializer_approval_audit_body = app.call(rack_env("GET", "/setup/materializer-approval-audit-trail"))
      materializer_approval_audit_json_status, _materializer_approval_audit_json_headers, materializer_approval_audit_json_body = app.call(rack_env("GET", "/setup/materializer-approval-audit-trail.json"))
      hub_status, _hub_headers, hub_body = app.call(rack_env("GET", "/hub"))
      html_status, _html_headers, html_body = app.call(rack_env("GET", "/"))
      hub_install_status, hub_install_headers = post(app, "/hub/horoscope/install")
      hub_installed_status = get_status(app, hub_install_headers.fetch("location"))
      hub_installed_file = File.exist?(File.join(config.hub_install_root, "horoscope", "contracts", "daily_horoscope.rb"))
      _installed_html_status, _installed_html_headers, installed_html_body = app.call(rack_env("GET", "/"))
      final = store.snapshot
      persisted = Companion.build(config: config).service(:companion).snapshot
      html = html_body.join
      events = events_body.join
      setup = setup_body.join
      setup_handoff = setup_handoff_body.join
      setup_handoff_json = setup_handoff_json_body.join
      setup_handoff_digest = setup_handoff_digest_body.join
      setup_handoff_digest_json = setup_handoff_digest_json_body.join
      setup_handoff_digest_text = setup_handoff_digest_text_body.join
      setup_handoff_next_scope = setup_handoff_next_scope_body.join
      setup_handoff_next_scope_json = setup_handoff_next_scope_json_body.join
      setup_handoff_next_scope_health = setup_handoff_next_scope_health_body.join
      setup_handoff_next_scope_health_json = setup_handoff_next_scope_health_json_body.join
      setup_handoff_promotion_readiness = setup_handoff_promotion_readiness_body.join
      setup_handoff_promotion_readiness_json = setup_handoff_promotion_readiness_json_body.join
      setup_handoff_extraction_sketch = setup_handoff_extraction_sketch_body.join
      setup_handoff_extraction_sketch_json = setup_handoff_extraction_sketch_json_body.join
      setup_handoff_packet_registry = setup_handoff_packet_registry_body.join
      setup_handoff_packet_registry_json = setup_handoff_packet_registry_json_body.join
      setup_handoff_supervision = setup_handoff_supervision_body.join
      setup_handoff_supervision_json = setup_handoff_supervision_json_body.join
      setup_handoff_acceptance = setup_handoff_acceptance_body.join
      setup_handoff_acceptance_json = setup_handoff_acceptance_json_body.join
      setup_handoff_lifecycle = setup_handoff_lifecycle_body.join
      setup_handoff_lifecycle_json = setup_handoff_lifecycle_json_body.join
      setup_handoff_lifecycle_health = setup_handoff_lifecycle_health_body.join
      setup_handoff_lifecycle_health_json = setup_handoff_lifecycle_health_json_body.join
      setup_handoff_approval_acceptance = setup_handoff_approval_acceptance_body.join
      setup_handoff_approval_acceptance_json = setup_handoff_approval_acceptance_json_body.join
      setup_health = setup_health_body.join
      setup_health_json = setup_health_json_body.join
      manifest = manifest_body.join
      manifest_glossary = manifest_glossary_body.join
      manifest_glossary_json = manifest_glossary_json_body.join
      storage_plan = storage_plan_body.join
      storage_plan_json = storage_plan_json_body.join
      storage_plan_health = storage_plan_health_body.join
      storage_plan_health_json = storage_plan_health_json_body.join
      storage_migration_plan = storage_migration_plan_body.join
      storage_migration_plan_json = storage_migration_plan_json_body.join
      storage_migration_plan_health = storage_migration_plan_health_body.join
      storage_migration_plan_health_json = storage_migration_plan_health_json_body.join
      field_type_plan = field_type_plan_body.join
      field_type_plan_json = field_type_plan_json_body.join
      field_type_health = field_type_health_body.join
      field_type_health_json = field_type_health_json_body.join
      relation_type_plan = relation_type_plan_body.join
      relation_type_plan_json = relation_type_plan_json_body.join
      relation_type_health = relation_type_health_body.join
      relation_type_health_json = relation_type_health_json_body.join
      access_path_plan = access_path_plan_body.join
      access_path_plan_json = access_path_plan_json_body.join
      access_path_health = access_path_health_body.join
      access_path_health_json = access_path_health_json_body.join
      effect_intent_plan = effect_intent_plan_body.join
      effect_intent_plan_json = effect_intent_plan_json_body.join
      effect_intent_health = effect_intent_health_body.join
      effect_intent_health_json = effect_intent_health_json_body.join
      store_convergence = store_convergence_body.join
      store_convergence_json = store_convergence_json_body.join
      relation_health = relation_health_body.join
      relation_health_json = relation_health_json_body.join
      materialization = materialization_body.join
      materialization_json = materialization_json_body.join
      parity = parity_body.join
      parity_json = parity_json_body.join
      wizard_specs = wizard_spec_body.join
      wizard_specs_json = wizard_spec_json_body.join
      wizard_export = wizard_export_body.join
      wizard_export_json = wizard_export_json_body.join
      wizard_migration = wizard_migration_body.join
      wizard_migration_json = wizard_migration_json_body.join
      loop_health = loop_health_body.join
      loop_health_json = loop_health_json_body.join
      materializer = materializer_body.join
      materializer_json = materializer_json_body.join
      materializer_descriptor_health = materializer_descriptor_health_body.join
      materializer_descriptor_health_json = materializer_descriptor_health_json_body.join
      materializer_gate = materializer_gate_body.join
      materializer_gate_json = materializer_gate_json_body.join
      materializer_preflight = materializer_preflight_body.join
      materializer_preflight_json = materializer_preflight_json_body.join
      materializer_runbook = materializer_runbook_body.join
      materializer_runbook_json = materializer_runbook_json_body.join
      materializer_receipt = materializer_receipt_body.join
      materializer_receipt_json = materializer_receipt_json_body.join
      materializer_attempt_command = materializer_attempt_command_body.join
      materializer_attempt_command_json = materializer_attempt_command_json_body.join
      materializer_audit = materializer_audit_body.join
      materializer_audit_json = materializer_audit_json_body.join
      materializer_supervision = materializer_supervision_body.join
      materializer_supervision_json = materializer_supervision_json_body.join
      materializer_approval = materializer_approval_body.join
      materializer_approval_json = materializer_approval_json_body.join
      materializer_approval_receipt = materializer_approval_receipt_body.join
      materializer_approval_receipt_json = materializer_approval_receipt_json_body.join
      materializer_approval_command = materializer_approval_command_body.join
      materializer_approval_command_json = materializer_approval_command_json_body.join
      materializer_approvals = materializer_approvals_body.join
      materializer_approvals_json = materializer_approvals_json_body.join
      materializer_approval_audit = materializer_approval_audit_body.join
      materializer_approval_audit_json = materializer_approval_audit_json_body.join
      hub_catalog = hub_body.join
      installed_html = installed_html_body.join

      out.puts "companion_poc_live_ready=#{initial.live_ready}"
      out.puts "companion_poc_open_reminders=#{final.open_reminders}"
      out.puts "companion_poc_tracker_logs=#{final.tracker_logs_today}"
      out.puts "companion_poc_countdowns=#{final.countdown_count}"
      out.puts "companion_poc_body_battery=#{final.body_battery.fetch(:score).positive?}"
      out.puts "companion_poc_daily_plan=#{final.daily_plan.fetch(:block_minutes).positive?}"
      out.puts "companion_poc_store_backend=#{config.store_backend}"
      out.puts "companion_poc_store_file=#{File.exist?(db_path)}"
      out.puts "companion_poc_sqlite_persisted=#{persisted.tracker_logs_today == final.tracker_logs_today}"
      out.puts "companion_poc_summary=#{final.daily_summary.fetch(:summary).include?("tracker logs")}"
      out.puts "companion_poc_create_status=#{create_status}"
      out.puts "companion_poc_created_status=#{created_status}"
      out.puts "companion_poc_blank_reminder_status=#{blank_reminder_status}"
      out.puts "companion_poc_blank_reminder_result_status=#{blank_reminder_result_status}"
      out.puts "companion_poc_log_status=#{log_status}"
      out.puts "companion_poc_logged_status=#{logged_status}"
      out.puts "companion_poc_blank_tracker_status=#{blank_tracker_status}"
      out.puts "companion_poc_blank_tracker_result_status=#{blank_tracker_result_status}"
      out.puts "companion_poc_focus_status=#{focus_status}"
      out.puts "companion_poc_focused_status=#{focused_status}"
      out.puts "companion_poc_countdown_status=#{countdown_status}"
      out.puts "companion_poc_countdown_created_status=#{countdown_created_status}"
      out.puts "companion_poc_blank_countdown_status=#{blank_countdown_status}"
      out.puts "companion_poc_blank_countdown_result_status=#{blank_countdown_result_status}"
      out.puts "companion_poc_complete_status=#{complete_status}"
      out.puts "companion_poc_completed_status=#{completed_status}"
      out.puts "companion_poc_events_status=#{events_status}"
      out.puts "companion_poc_setup_status=#{setup_status}"
      out.puts "companion_poc_setup_handoff_status=#{setup_handoff_status}"
      out.puts "companion_poc_setup_handoff_json_status=#{setup_handoff_json_status}"
      out.puts "companion_poc_setup_handoff_digest_status=#{setup_handoff_digest_status}"
      out.puts "companion_poc_setup_handoff_digest_json_status=#{setup_handoff_digest_json_status}"
      out.puts "companion_poc_setup_handoff_digest_text_status=#{setup_handoff_digest_text_status}"
      out.puts "companion_poc_setup_handoff_next_scope_status=#{setup_handoff_next_scope_status}"
      out.puts "companion_poc_setup_handoff_next_scope_json_status=#{setup_handoff_next_scope_json_status}"
      out.puts "companion_poc_setup_handoff_next_scope_health_status=#{setup_handoff_next_scope_health_status}"
      out.puts "companion_poc_setup_handoff_next_scope_health_json_status=#{setup_handoff_next_scope_health_json_status}"
      out.puts "companion_poc_setup_handoff_promotion_readiness_status=#{setup_handoff_promotion_readiness_status}"
      out.puts "companion_poc_setup_handoff_promotion_readiness_json_status=#{setup_handoff_promotion_readiness_json_status}"
      out.puts "companion_poc_setup_handoff_extraction_sketch_status=#{setup_handoff_extraction_sketch_status}"
      out.puts "companion_poc_setup_handoff_extraction_sketch_json_status=#{setup_handoff_extraction_sketch_json_status}"
      out.puts "companion_poc_setup_handoff_packet_registry_status=#{setup_handoff_packet_registry_status}"
      out.puts "companion_poc_setup_handoff_packet_registry_json_status=#{setup_handoff_packet_registry_json_status}"
      out.puts "companion_poc_setup_handoff_supervision_status=#{setup_handoff_supervision_status}"
      out.puts "companion_poc_setup_handoff_supervision_json_status=#{setup_handoff_supervision_json_status}"
      out.puts "companion_poc_setup_handoff_acceptance_status=#{setup_handoff_acceptance_status}"
      out.puts "companion_poc_setup_handoff_acceptance_json_status=#{setup_handoff_acceptance_json_status}"
      out.puts "companion_poc_setup_handoff_lifecycle_status=#{setup_handoff_lifecycle_status}"
      out.puts "companion_poc_setup_handoff_lifecycle_json_status=#{setup_handoff_lifecycle_json_status}"
      out.puts "companion_poc_setup_handoff_lifecycle_health_status=#{setup_handoff_lifecycle_health_status}"
      out.puts "companion_poc_setup_handoff_lifecycle_health_json_status=#{setup_handoff_lifecycle_health_json_status}"
      out.puts "companion_poc_setup_handoff_approval_acceptance_status=#{setup_handoff_approval_acceptance_status}"
      out.puts "companion_poc_setup_handoff_approval_acceptance_json_status=#{setup_handoff_approval_acceptance_json_status}"
      out.puts "companion_poc_setup_health_status=#{setup_health_status}"
      out.puts "companion_poc_setup_health_json_status=#{setup_health_json_status}"
      out.puts "companion_poc_setup_manifest_status=#{manifest_status}"
      out.puts "companion_poc_setup_manifest_glossary_status=#{manifest_glossary_status}"
      out.puts "companion_poc_setup_manifest_glossary_json_status=#{manifest_glossary_json_status}"
      out.puts "companion_poc_setup_storage_plan_status=#{storage_plan_status}"
      out.puts "companion_poc_setup_storage_plan_json_status=#{storage_plan_json_status}"
      out.puts "companion_poc_setup_storage_plan_health_status=#{storage_plan_health_status}"
      out.puts "companion_poc_setup_storage_plan_health_json_status=#{storage_plan_health_json_status}"
      out.puts "companion_poc_setup_storage_migration_plan_status=#{storage_migration_plan_status}"
      out.puts "companion_poc_setup_storage_migration_plan_json_status=#{storage_migration_plan_json_status}"
      out.puts "companion_poc_setup_storage_migration_plan_health_status=#{storage_migration_plan_health_status}"
      out.puts "companion_poc_setup_storage_migration_plan_health_json_status=#{storage_migration_plan_health_json_status}"
      out.puts "companion_poc_setup_field_type_plan_status=#{field_type_plan_status}"
      out.puts "companion_poc_setup_field_type_plan_json_status=#{field_type_plan_json_status}"
      out.puts "companion_poc_setup_field_type_health_status=#{field_type_health_status}"
      out.puts "companion_poc_setup_field_type_health_json_status=#{field_type_health_json_status}"
      out.puts "companion_poc_setup_relation_type_plan_status=#{relation_type_plan_status}"
      out.puts "companion_poc_setup_relation_type_plan_json_status=#{relation_type_plan_json_status}"
      out.puts "companion_poc_setup_relation_type_health_status=#{relation_type_health_status}"
      out.puts "companion_poc_setup_relation_type_health_json_status=#{relation_type_health_json_status}"
      out.puts "companion_poc_setup_access_path_plan_status=#{access_path_plan_status}"
      out.puts "companion_poc_setup_access_path_plan_json_status=#{access_path_plan_json_status}"
      out.puts "companion_poc_setup_access_path_health_status=#{access_path_health_status}"
      out.puts "companion_poc_setup_access_path_health_json_status=#{access_path_health_json_status}"
      out.puts "companion_poc_setup_effect_intent_plan_status=#{effect_intent_plan_status}"
      out.puts "companion_poc_setup_effect_intent_plan_json_status=#{effect_intent_plan_json_status}"
      out.puts "companion_poc_setup_effect_intent_health_status=#{effect_intent_health_status}"
      out.puts "companion_poc_setup_effect_intent_health_json_status=#{effect_intent_health_json_status}"
      out.puts "companion_poc_setup_store_convergence_sidecar_status=#{store_convergence_status}"
      out.puts "companion_poc_setup_store_convergence_sidecar_json_status=#{store_convergence_json_status}"
      out.puts "companion_poc_setup_relation_health_status=#{relation_health_status}"
      out.puts "companion_poc_setup_relation_health_json_status=#{relation_health_json_status}"
      out.puts "companion_poc_setup_materialization_status=#{materialization_status}"
      out.puts "companion_poc_setup_materialization_json_status=#{materialization_json_status}"
      out.puts "companion_poc_setup_materialization_parity_status=#{parity_status}"
      out.puts "companion_poc_setup_materialization_parity_json_status=#{parity_json_status}"
      out.puts "companion_poc_setup_wizard_type_specs_status=#{wizard_spec_status}"
      out.puts "companion_poc_setup_wizard_type_specs_json_status=#{wizard_spec_json_status}"
      out.puts "companion_poc_setup_wizard_type_spec_export_status=#{wizard_export_status}"
      out.puts "companion_poc_setup_wizard_type_spec_export_json_status=#{wizard_export_json_status}"
      out.puts "companion_poc_setup_wizard_type_spec_migration_status=#{wizard_migration_status}"
      out.puts "companion_poc_setup_wizard_type_spec_migration_json_status=#{wizard_migration_json_status}"
      out.puts "companion_poc_setup_infrastructure_loop_health_status=#{loop_health_status}"
      out.puts "companion_poc_setup_infrastructure_loop_health_json_status=#{loop_health_json_status}"
      out.puts "companion_poc_setup_materializer_status=#{materializer_status}"
      out.puts "companion_poc_setup_materializer_json_status=#{materializer_json_status}"
      out.puts "companion_poc_setup_materializer_descriptor_health_status=#{materializer_descriptor_health_status}"
      out.puts "companion_poc_setup_materializer_descriptor_health_json_status=#{materializer_descriptor_health_json_status}"
      out.puts "companion_poc_setup_materializer_gate_status=#{materializer_gate_status}"
      out.puts "companion_poc_setup_materializer_gate_json_status=#{materializer_gate_json_status}"
      out.puts "companion_poc_setup_materializer_preflight_status=#{materializer_preflight_status}"
      out.puts "companion_poc_setup_materializer_preflight_json_status=#{materializer_preflight_json_status}"
      out.puts "companion_poc_setup_materializer_runbook_status=#{materializer_runbook_status}"
      out.puts "companion_poc_setup_materializer_runbook_json_status=#{materializer_runbook_json_status}"
      out.puts "companion_poc_setup_materializer_receipt_status=#{materializer_receipt_status}"
      out.puts "companion_poc_setup_materializer_receipt_json_status=#{materializer_receipt_json_status}"
      out.puts "companion_poc_setup_materializer_attempt_command_status=#{materializer_attempt_command_status}"
      out.puts "companion_poc_setup_materializer_attempt_command_json_status=#{materializer_attempt_command_json_status}"
      out.puts "companion_poc_setup_materializer_audit_status=#{materializer_audit_status}"
      out.puts "companion_poc_setup_materializer_audit_json_status=#{materializer_audit_json_status}"
      out.puts "companion_poc_setup_materializer_supervision_status=#{materializer_supervision_status}"
      out.puts "companion_poc_setup_materializer_supervision_json_status=#{materializer_supervision_json_status}"
      out.puts "companion_poc_setup_materializer_approval_status=#{materializer_approval_status}"
      out.puts "companion_poc_setup_materializer_approval_json_status=#{materializer_approval_json_status}"
      out.puts "companion_poc_setup_materializer_approval_receipt_status=#{materializer_approval_receipt_status}"
      out.puts "companion_poc_setup_materializer_approval_receipt_json_status=#{materializer_approval_receipt_json_status}"
      out.puts "companion_poc_setup_materializer_approval_command_status=#{materializer_approval_command_status}"
      out.puts "companion_poc_setup_materializer_approval_command_json_status=#{materializer_approval_command_json_status}"
      out.puts "companion_poc_setup_materializer_approvals_status=#{materializer_approvals_status}"
      out.puts "companion_poc_setup_materializer_approvals_json_status=#{materializer_approvals_json_status}"
      out.puts "companion_poc_setup_materializer_approval_audit_status=#{materializer_approval_audit_status}"
      out.puts "companion_poc_setup_materializer_approval_audit_json_status=#{materializer_approval_audit_json_status}"
      out.puts "companion_poc_hub_status=#{hub_status}"
      out.puts "companion_poc_html_status=#{html_status}"
      out.puts "companion_poc_hub_install_status=#{hub_install_status}"
      out.puts "companion_poc_hub_installed_status=#{hub_installed_status}"
      out.puts "companion_poc_setup_redacted=#{setup.include?("openai_api_key") && !setup.include?("sk-")}"
      out.puts "companion_poc_setup_persistence_readiness=#{setup.include?("persistence") && setup.include?("ready")}"
      out.puts "companion_poc_setup_handoff_summary=#{setup_handoff_summary?(setup)}"
      out.puts "companion_poc_setup_handoff_endpoint=#{setup_handoff_endpoint?(setup_handoff)}"
      out.puts "companion_poc_setup_handoff_json_endpoint=#{setup_handoff_json_endpoint?(setup_handoff_json)}"
      out.puts "companion_poc_setup_handoff_digest_endpoint=#{setup_handoff_digest_endpoint?(setup_handoff_digest)}"
      out.puts "companion_poc_setup_handoff_digest_json_endpoint=#{setup_handoff_digest_json_endpoint?(setup_handoff_digest_json)}"
      out.puts "companion_poc_setup_handoff_digest_text_endpoint=#{setup_handoff_digest_text_endpoint?(setup_handoff_digest_text)}"
      out.puts "companion_poc_setup_handoff_next_scope_endpoint=#{setup_handoff_next_scope_endpoint?(setup_handoff_next_scope)}"
      out.puts "companion_poc_setup_handoff_next_scope_json_endpoint=#{setup_handoff_next_scope_json_endpoint?(setup_handoff_next_scope_json)}"
      out.puts "companion_poc_setup_handoff_next_scope_health_endpoint=#{setup_handoff_next_scope_health_endpoint?(setup_handoff_next_scope_health)}"
      out.puts "companion_poc_setup_handoff_next_scope_health_json_endpoint=#{setup_handoff_next_scope_health_json_endpoint?(setup_handoff_next_scope_health_json)}"
      out.puts "companion_poc_setup_handoff_promotion_readiness_endpoint=#{setup_handoff_promotion_readiness_endpoint?(setup_handoff_promotion_readiness)}"
      out.puts "companion_poc_setup_handoff_promotion_readiness_json_endpoint=#{setup_handoff_promotion_readiness_json_endpoint?(setup_handoff_promotion_readiness_json)}"
      out.puts "companion_poc_setup_handoff_extraction_sketch_endpoint=#{setup_handoff_extraction_sketch_endpoint?(setup_handoff_extraction_sketch)}"
      out.puts "companion_poc_setup_handoff_extraction_sketch_json_endpoint=#{setup_handoff_extraction_sketch_json_endpoint?(setup_handoff_extraction_sketch_json)}"
      out.puts "companion_poc_setup_handoff_packet_registry_endpoint=#{setup_handoff_packet_registry_endpoint?(setup_handoff_packet_registry)}"
      out.puts "companion_poc_setup_handoff_packet_registry_json_endpoint=#{setup_handoff_packet_registry_json_endpoint?(setup_handoff_packet_registry_json)}"
      out.puts "companion_poc_setup_handoff_supervision_endpoint=#{setup_handoff_supervision_endpoint?(setup_handoff_supervision)}"
      out.puts "companion_poc_setup_handoff_supervision_json_endpoint=#{setup_handoff_supervision_json_endpoint?(setup_handoff_supervision_json)}"
      out.puts "companion_poc_setup_handoff_acceptance_endpoint=#{setup_handoff_acceptance_endpoint?(setup_handoff_acceptance)}"
      out.puts "companion_poc_setup_handoff_acceptance_json_endpoint=#{setup_handoff_acceptance_json_endpoint?(setup_handoff_acceptance_json)}"
      out.puts "companion_poc_setup_handoff_lifecycle_endpoint=#{setup_handoff_lifecycle_endpoint?(setup_handoff_lifecycle)}"
      out.puts "companion_poc_setup_handoff_lifecycle_json_endpoint=#{setup_handoff_lifecycle_json_endpoint?(setup_handoff_lifecycle_json)}"
      out.puts "companion_poc_setup_handoff_lifecycle_health_endpoint=#{setup_handoff_lifecycle_health_endpoint?(setup_handoff_lifecycle_health)}"
      out.puts "companion_poc_setup_handoff_lifecycle_health_json_endpoint=#{setup_handoff_lifecycle_health_json_endpoint?(setup_handoff_lifecycle_health_json)}"
      out.puts "companion_poc_setup_handoff_approval_acceptance_endpoint=#{setup_handoff_approval_acceptance_endpoint?(setup_handoff_approval_acceptance)}"
      out.puts "companion_poc_setup_handoff_approval_acceptance_json_endpoint=#{setup_handoff_approval_acceptance_json_endpoint?(setup_handoff_approval_acceptance_json)}"
      out.puts "companion_poc_setup_health_summary=#{setup_health_summary?(setup)}"
      out.puts "companion_poc_setup_health_endpoint=#{setup_health_endpoint?(setup_health)}"
      out.puts "companion_poc_setup_health_json_endpoint=#{setup_health_json_endpoint?(setup_health_json)}"
      out.puts "companion_poc_setup_manifest_glossary_summary=#{setup_manifest_glossary_summary?(setup)}"
      out.puts "companion_poc_setup_relation_health=#{setup.include?("relation_health") && setup.include?("clear")}"
      out.puts "companion_poc_setup_manifest_glossary_endpoint=#{setup_manifest_glossary_endpoint?(manifest_glossary)}"
      out.puts "companion_poc_setup_manifest_glossary_json_endpoint=#{setup_manifest_glossary_json_endpoint?(manifest_glossary_json)}"
      out.puts "companion_poc_setup_storage_plan_endpoint=#{setup_storage_plan_endpoint?(storage_plan)}"
      out.puts "companion_poc_setup_storage_plan_json_endpoint=#{setup_storage_plan_json_endpoint?(storage_plan_json)}"
      out.puts "companion_poc_setup_storage_plan_health_endpoint=#{setup_storage_plan_health_endpoint?(storage_plan_health)}"
      out.puts "companion_poc_setup_storage_plan_health_json_endpoint=#{setup_storage_plan_health_json_endpoint?(storage_plan_health_json)}"
      out.puts "companion_poc_setup_storage_migration_plan_endpoint=#{setup_storage_migration_plan_endpoint?(storage_migration_plan)}"
      out.puts "companion_poc_setup_storage_migration_plan_json_endpoint=#{setup_storage_migration_plan_json_endpoint?(storage_migration_plan_json)}"
      out.puts "companion_poc_setup_storage_migration_plan_health_endpoint=#{setup_storage_migration_plan_health_endpoint?(storage_migration_plan_health)}"
      out.puts "companion_poc_setup_storage_migration_plan_health_json_endpoint=#{setup_storage_migration_plan_health_json_endpoint?(storage_migration_plan_health_json)}"
      out.puts "companion_poc_setup_field_type_plan_endpoint=#{setup_field_type_plan_endpoint?(field_type_plan)}"
      out.puts "companion_poc_setup_field_type_plan_json_endpoint=#{setup_field_type_plan_json_endpoint?(field_type_plan_json)}"
      out.puts "companion_poc_setup_field_type_health_endpoint=#{setup_field_type_health_endpoint?(field_type_health)}"
      out.puts "companion_poc_setup_field_type_health_json_endpoint=#{setup_field_type_health_json_endpoint?(field_type_health_json)}"
      out.puts "companion_poc_setup_relation_type_plan_endpoint=#{setup_relation_type_plan_endpoint?(relation_type_plan)}"
      out.puts "companion_poc_setup_relation_type_plan_json_endpoint=#{setup_relation_type_plan_json_endpoint?(relation_type_plan_json)}"
      out.puts "companion_poc_setup_relation_type_health_endpoint=#{setup_relation_type_health_endpoint?(relation_type_health)}"
      out.puts "companion_poc_setup_relation_type_health_json_endpoint=#{setup_relation_type_health_json_endpoint?(relation_type_health_json)}"
      out.puts "companion_poc_setup_access_path_plan_endpoint=#{setup_access_path_plan_endpoint?(access_path_plan)}"
      out.puts "companion_poc_setup_access_path_plan_json_endpoint=#{setup_access_path_plan_json_endpoint?(access_path_plan_json)}"
      out.puts "companion_poc_setup_access_path_health_endpoint=#{setup_access_path_health_endpoint?(access_path_health)}"
      out.puts "companion_poc_setup_access_path_health_json_endpoint=#{setup_access_path_health_json_endpoint?(access_path_health_json)}"
      out.puts "companion_poc_setup_effect_intent_plan_endpoint=#{setup_effect_intent_plan_endpoint?(effect_intent_plan)}"
      out.puts "companion_poc_setup_effect_intent_plan_json_endpoint=#{setup_effect_intent_plan_json_endpoint?(effect_intent_plan_json)}"
      out.puts "companion_poc_setup_effect_intent_health_endpoint=#{setup_effect_intent_health_endpoint?(effect_intent_health)}"
      out.puts "companion_poc_setup_effect_intent_health_json_endpoint=#{setup_effect_intent_health_json_endpoint?(effect_intent_health_json)}"
      out.puts "companion_poc_setup_store_convergence_sidecar_endpoint=#{setup_store_convergence_sidecar_endpoint?(store_convergence)}"
      out.puts "companion_poc_setup_store_convergence_sidecar_json_endpoint=#{setup_store_convergence_sidecar_json_endpoint?(store_convergence_json)}"
      out.puts "companion_poc_setup_relation_health_endpoint=#{setup_relation_health_endpoint?(relation_health)}"
      out.puts "companion_poc_setup_relation_health_json_endpoint=#{setup_relation_health_json_endpoint?(relation_health_json)}"
      out.puts "companion_poc_setup_materialization_endpoint=#{setup_materialization_endpoint?(materialization)}"
      out.puts "companion_poc_setup_materialization_json_endpoint=#{setup_materialization_json_endpoint?(materialization_json)}"
      out.puts "companion_poc_setup_materialization_parity_endpoint=#{setup_materialization_parity_endpoint?(parity)}"
      out.puts "companion_poc_setup_materialization_parity_json_endpoint=#{setup_materialization_parity_json_endpoint?(parity_json)}"
      out.puts "companion_poc_setup_wizard_type_specs_endpoint=#{setup_wizard_type_specs_endpoint?(wizard_specs)}"
      out.puts "companion_poc_setup_wizard_type_specs_json_endpoint=#{setup_wizard_type_specs_json_endpoint?(wizard_specs_json)}"
      out.puts "companion_poc_setup_wizard_type_spec_export_endpoint=#{setup_wizard_type_spec_export_endpoint?(wizard_export)}"
      out.puts "companion_poc_setup_wizard_type_spec_export_json_endpoint=#{setup_wizard_type_spec_export_json_endpoint?(wizard_export_json)}"
      out.puts "companion_poc_setup_wizard_type_spec_migration_endpoint=#{setup_wizard_type_spec_migration_endpoint?(wizard_migration)}"
      out.puts "companion_poc_setup_wizard_type_spec_migration_json_endpoint=#{setup_wizard_type_spec_migration_json_endpoint?(wizard_migration_json)}"
      out.puts "companion_poc_setup_infrastructure_loop_health_endpoint=#{setup_infrastructure_loop_health_endpoint?(loop_health)}"
      out.puts "companion_poc_setup_infrastructure_loop_health_json_endpoint=#{setup_infrastructure_loop_health_json_endpoint?(loop_health_json)}"
      out.puts "companion_poc_setup_materializer_endpoint=#{setup_materializer_endpoint?(materializer)}"
      out.puts "companion_poc_setup_materializer_json_endpoint=#{setup_materializer_json_endpoint?(materializer_json)}"
      out.puts "companion_poc_setup_materializer_descriptor_health_endpoint=#{setup_materializer_descriptor_health_endpoint?(materializer_descriptor_health)}"
      out.puts "companion_poc_setup_materializer_descriptor_health_json_endpoint=#{setup_materializer_descriptor_health_json_endpoint?(materializer_descriptor_health_json)}"
      out.puts "companion_poc_setup_materializer_gate_endpoint=#{setup_materializer_gate_endpoint?(materializer_gate)}"
      out.puts "companion_poc_setup_materializer_gate_json_endpoint=#{setup_materializer_gate_json_endpoint?(materializer_gate_json)}"
      out.puts "companion_poc_setup_materializer_preflight_endpoint=#{setup_materializer_preflight_endpoint?(materializer_preflight)}"
      out.puts "companion_poc_setup_materializer_preflight_json_endpoint=#{setup_materializer_preflight_json_endpoint?(materializer_preflight_json)}"
      out.puts "companion_poc_setup_materializer_runbook_endpoint=#{setup_materializer_runbook_endpoint?(materializer_runbook)}"
      out.puts "companion_poc_setup_materializer_runbook_json_endpoint=#{setup_materializer_runbook_json_endpoint?(materializer_runbook_json)}"
      out.puts "companion_poc_setup_materializer_receipt_endpoint=#{setup_materializer_receipt_endpoint?(materializer_receipt)}"
      out.puts "companion_poc_setup_materializer_receipt_json_endpoint=#{setup_materializer_receipt_json_endpoint?(materializer_receipt_json)}"
      out.puts "companion_poc_setup_materializer_attempt_command_endpoint=#{setup_materializer_attempt_command_endpoint?(materializer_attempt_command)}"
      out.puts "companion_poc_setup_materializer_attempt_command_json_endpoint=#{setup_materializer_attempt_command_json_endpoint?(materializer_attempt_command_json)}"
      out.puts "companion_poc_setup_materializer_audit_endpoint=#{setup_materializer_audit_endpoint?(materializer_audit)}"
      out.puts "companion_poc_setup_materializer_audit_json_endpoint=#{setup_materializer_audit_json_endpoint?(materializer_audit_json)}"
      out.puts "companion_poc_setup_materializer_supervision_endpoint=#{setup_materializer_supervision_endpoint?(materializer_supervision)}"
      out.puts "companion_poc_setup_materializer_supervision_json_endpoint=#{setup_materializer_supervision_json_endpoint?(materializer_supervision_json)}"
      out.puts "companion_poc_setup_materializer_approval_endpoint=#{setup_materializer_approval_endpoint?(materializer_approval)}"
      out.puts "companion_poc_setup_materializer_approval_json_endpoint=#{setup_materializer_approval_json_endpoint?(materializer_approval_json)}"
      out.puts "companion_poc_setup_materializer_approval_receipt_endpoint=#{setup_materializer_approval_receipt_endpoint?(materializer_approval_receipt)}"
      out.puts "companion_poc_setup_materializer_approval_receipt_json_endpoint=#{setup_materializer_approval_receipt_json_endpoint?(materializer_approval_receipt_json)}"
      out.puts "companion_poc_setup_materializer_approval_command_endpoint=#{setup_materializer_approval_command_endpoint?(materializer_approval_command)}"
      out.puts "companion_poc_setup_materializer_approval_command_json_endpoint=#{setup_materializer_approval_command_json_endpoint?(materializer_approval_command_json)}"
      out.puts "companion_poc_setup_materializer_approvals_endpoint=#{setup_materializer_approvals_endpoint?(materializer_approvals)}"
      out.puts "companion_poc_setup_materializer_approvals_json_endpoint=#{setup_materializer_approvals_json_endpoint?(materializer_approvals_json)}"
      out.puts "companion_poc_setup_materializer_approval_audit_endpoint=#{setup_materializer_approval_audit_endpoint?(materializer_approval_audit)}"
      out.puts "companion_poc_setup_materializer_approval_audit_json_endpoint=#{setup_materializer_approval_audit_json_endpoint?(materializer_approval_audit_json)}"
      out.puts "companion_poc_web_surface=#{html.include?('data-ig-poc-surface="companion_dashboard"')}"
      out.puts "companion_poc_relation_health_dashboard=#{relation_health_dashboard?(html)}"
      out.puts "companion_poc_today_surface=#{html.include?('data-companion-today="true"') && html.include?('data-today-next-action="true"')}"
      out.puts "companion_poc_today_signal=#{daily_plan_signal? && html.include?("data-today-signal=")}"
      out.puts "companion_poc_today_quick_action=#{daily_plan_quick_action? && html.include?("data-today-quick-action=")}"
      out.puts "companion_poc_today_quick_action_command=#{daily_plan_quick_action_command? && html.include?("data-today-command=")}"
      out.puts "companion_poc_today_quick_action_route=#{today_quick_action_route? && html.include?('action="/today/quick-action"')}"
      out.puts "companion_poc_daily_focus=#{final.daily_plan.fetch(:focus_title) == "Draft the launch note"}"
      out.puts "companion_poc_daily_focus_persisted=#{persisted.daily_focus_title == final.daily_focus_title}"
      out.puts "companion_poc_daily_focus_persistence_manifest=#{daily_focus_persistence_manifest?}"
      out.puts "companion_poc_daily_focus_generated_api=#{daily_focus_generated_api?}"
      out.puts "companion_poc_daily_focus_first_class_record=#{daily_focus_first_class_record?(config)}"
      out.puts "companion_poc_countdown_persistence_manifest=#{countdown_persistence_manifest?}"
      out.puts "companion_poc_countdown_generated_api=#{countdown_generated_api?}"
      out.puts "companion_poc_countdown_contract_refusal=#{blank_countdown_headers.fetch("location").include?("blank_countdown")}"
      out.puts "companion_poc_countdown_created=#{final.countdowns.any? { |countdown| countdown.id == "launch-day" }}"
      out.puts "companion_poc_countdown_persisted=#{persisted.countdowns.any? { |countdown| countdown.id == "launch-day" }}"
      out.puts "companion_poc_countdown_projection_contract=#{countdown_projection_contract?}"
      out.puts "companion_poc_countdown_days_surface=#{html.include?("data-countdown-days=")}"
      out.puts "companion_poc_reminder_contract_refusal=#{blank_reminder_headers.fetch("location").include?("blank_reminder")}"
      out.puts "companion_poc_tracker_log_contract_refusal=#{blank_tracker_headers.fetch("location").include?("blank_tracker_value")}"
      out.puts "companion_poc_reminder_persistence_manifest=#{reminder_persistence_manifest?}"
      out.puts "companion_poc_reminder_generated_api=#{reminder_generated_api?}"
      out.puts "companion_poc_reminder_scope_api=#{reminder_scope_api?}"
      out.puts "companion_poc_reminder_command_metadata_api=#{reminder_command_metadata_api?}"
      out.puts "companion_poc_tracker_persistence_manifest=#{tracker_persistence_manifest?}"
      out.puts "companion_poc_tracker_generated_api=#{tracker_generated_api?}"
      out.puts "companion_poc_tracker_projection_composes_history=#{tracker_projection_composes_history?(final)}"
      out.puts "companion_poc_tracker_projection_contract=#{tracker_projection_contract?}"
      out.puts "companion_poc_tracker_log_history_manifest=#{tracker_log_history_manifest?}"
      out.puts "companion_poc_tracker_log_history_api=#{tracker_log_history_api?}"
      out.puts "companion_poc_tracker_log_first_class_history=#{tracker_log_first_class_history?(config)}"
      out.puts "companion_poc_action_history_manifest=#{action_history_manifest?}"
      out.puts "companion_poc_action_history_api=#{action_history_api?}"
      out.puts "companion_poc_activity_feed_contract=#{activity_feed_contract?}"
      out.puts "companion_poc_persistence_registry=#{persistence_registry?}"
      out.puts "companion_poc_persistence_registry_valid=#{persistence_registry_valid?}"
      out.puts "companion_poc_persistence_readiness_contract=#{persistence_readiness_contract?}"
      out.puts "companion_poc_persistence_relation_health_contract=#{persistence_relation_health_contract?}"
      out.puts "companion_poc_relation_health_reports=#{relation_health_reports?}"
      out.puts "companion_poc_relation_health_structured_warnings=#{relation_health_structured_warnings?}"
      out.puts "companion_poc_relation_health_repair_suggestions=#{relation_health_repair_suggestions?}"
      out.puts "companion_poc_persistence_operation_model=#{persistence_operation_model?}"
      out.puts "companion_poc_persistence_manifest_contract=#{persistence_manifest_contract?}"
      out.puts "companion_poc_persistence_manifest_glossary_contract=#{persistence_manifest_glossary_contract?}"
      out.puts "companion_poc_persistence_storage_plan_sketch_contract=#{persistence_storage_plan_sketch_contract?}"
      out.puts "companion_poc_persistence_storage_plan_health_contract=#{persistence_storage_plan_health_contract?}"
      out.puts "companion_poc_persistence_storage_migration_plan_contract=#{persistence_storage_migration_plan_contract?}"
      out.puts "companion_poc_persistence_storage_migration_plan_health_contract=#{persistence_storage_migration_plan_health_contract?}"
      out.puts "companion_poc_persistence_field_type_plan_contract=#{persistence_field_type_plan_contract?}"
      out.puts "companion_poc_persistence_field_type_health_contract=#{persistence_field_type_health_contract?}"
      out.puts "companion_poc_persistence_relation_type_plan_contract=#{persistence_relation_type_plan_contract?}"
      out.puts "companion_poc_persistence_relation_type_health_contract=#{persistence_relation_type_health_contract?}"
      out.puts "companion_poc_persistence_access_path_plan_contract=#{persistence_access_path_plan_contract?}"
      out.puts "companion_poc_persistence_access_path_health_contract=#{persistence_access_path_health_contract?}"
      out.puts "companion_poc_persistence_effect_intent_plan_contract=#{persistence_effect_intent_plan_contract?}"
      out.puts "companion_poc_persistence_effect_intent_health_contract=#{persistence_effect_intent_health_contract?}"
      out.puts "companion_poc_store_convergence_sidecar_contract=#{store_convergence_sidecar_contract?}"
      out.puts "companion_poc_setup_handoff_contract=#{setup_handoff_contract?}"
      out.puts "companion_poc_setup_handoff_acceptance_contract=#{setup_handoff_acceptance_contract?}"
      out.puts "companion_poc_setup_handoff_approval_acceptance_contract=#{setup_handoff_approval_acceptance_contract?}"
      out.puts "companion_poc_setup_handoff_lifecycle_contract=#{setup_handoff_lifecycle_contract?}"
      out.puts "companion_poc_setup_handoff_lifecycle_health_contract=#{setup_handoff_lifecycle_health_contract?}"
      out.puts "companion_poc_setup_handoff_supervision_contract=#{setup_handoff_supervision_contract?}"
      out.puts "companion_poc_setup_handoff_packet_registry_contract=#{setup_handoff_packet_registry_contract?}"
      out.puts "companion_poc_setup_handoff_next_scope_contract=#{setup_handoff_next_scope_contract?}"
      out.puts "companion_poc_setup_handoff_next_scope_health_contract=#{setup_handoff_next_scope_health_contract?}"
      out.puts "companion_poc_setup_handoff_extraction_sketch_contract=#{setup_handoff_extraction_sketch_contract?}"
      out.puts "companion_poc_setup_handoff_promotion_readiness_contract=#{setup_handoff_promotion_readiness_contract?}"
      out.puts "companion_poc_setup_handoff_digest_contract=#{setup_handoff_digest_contract?}"
      out.puts "companion_poc_setup_health_contract=#{setup_health_contract?}"
      out.puts "companion_poc_persistence_metadata_manifest=#{persistence_metadata_manifest?}"
      out.puts "companion_poc_user_defined_article_contract=#{user_defined_article_contract?}"
      out.puts "companion_poc_wizard_type_spec_store=#{wizard_type_spec_store?}"
      out.puts "companion_poc_wizard_type_spec_history=#{wizard_type_spec_history?}"
      out.puts "companion_poc_wizard_type_spec_export=#{wizard_type_spec_export?}"
      out.puts "companion_poc_wizard_type_spec_canonical=#{wizard_type_spec_canonical?}"
      out.puts "companion_poc_wizard_type_spec_migration_plan=#{wizard_type_spec_migration_plan?}"
      out.puts "companion_poc_infrastructure_loop_health=#{infrastructure_loop_health?}"
      out.puts "companion_poc_materializer_gate=#{materializer_gate?}"
      out.puts "companion_poc_materializer_preflight=#{materializer_preflight?}"
      out.puts "companion_poc_materializer_runbook=#{materializer_runbook?}"
      out.puts "companion_poc_materializer_receipt=#{materializer_receipt?}"
      out.puts "companion_poc_materializer_attempt_history=#{materializer_attempt_history?}"
      out.puts "companion_poc_materializer_attempt_command=#{materializer_attempt_command?}"
      out.puts "companion_poc_materializer_attempt_record_route=#{materializer_attempt_record_route?}"
      out.puts "companion_poc_materializer_audit_trail=#{materializer_audit_trail?}"
      out.puts "companion_poc_materializer_supervision=#{materializer_supervision?}"
      out.puts "companion_poc_materializer_status_packet=#{materializer_status_packet?}"
      out.puts "companion_poc_materializer_status_descriptor_health=#{materializer_status_descriptor_health?}"
      out.puts "companion_poc_materializer_approval_policy=#{materializer_approval_policy?}"
      out.puts "companion_poc_materializer_approval_receipt=#{materializer_approval_receipt?}"
      out.puts "companion_poc_materializer_approval_history=#{materializer_approval_history?}"
      out.puts "companion_poc_materializer_approval_command=#{materializer_approval_command?}"
      out.puts "companion_poc_materializer_approval_record_route=#{materializer_approval_record_route?}"
      out.puts "companion_poc_materializer_approval_audit_trail=#{materializer_approval_audit_trail?}"
      out.puts "companion_poc_static_materialization_plan=#{static_materialization_plan?}"
      out.puts "companion_poc_static_materialization_parity=#{static_materialization_parity?}"
      out.puts "companion_poc_persistence_relation_manifest=#{persistence_relation_manifest?}"
      out.puts "companion_poc_projection_relation_manifest=#{projection_relation_manifest?}"
      out.puts "companion_poc_relation_health_warning=#{relation_health_warning?}"
      out.puts "companion_poc_setup_manifest=#{setup_manifest?(manifest)}"
      out.puts "companion_poc_capsules=#{%w[reminders trackers countdowns body-battery daily-plan daily-summary materializer].all? { |name| html.include?("data-capsule=\"#{name}\"") }}"
      out.puts "companion_poc_body_battery_surface=#{html.include?("data-body-battery-score=")}"
      out.puts "companion_poc_daily_plan_surface=#{html.include?("data-daily-plan-block=")}"
      out.puts "companion_poc_materializer_dashboard=#{materializer_dashboard?(html)}"
      out.puts "companion_poc_hub_surface=#{html.include?('data-capsule="hub"') && html.include?('data-action="install-hub-capsule"')}"
      out.puts "companion_poc_events_parity=#{events.include?("tracker_logs=#{final.tracker_logs_today}")}"
      out.puts "companion_poc_agent_capability=#{app.environment.agent_names.include?(:daily_companion)}"
      out.puts "companion_poc_hub_catalog=#{hub_catalog}"
      out.puts "companion_poc_hub_install=installed"
      out.puts "companion_poc_hub_receipt=#{hub_installed_file}"
      out.puts "companion_poc_hub_installed_file=#{hub_installed_file}"
      out.puts "companion_poc_hub_registry=#{app.service(:hub).installed?(:horoscope)}"
      out.puts "companion_poc_hub_history=#{app.service(:hub).registry.history(:horoscope).length}"
      out.puts "companion_poc_hub_installed_surface=#{installed_html.include?('data-hub-installed="true"')}"
    end

    def build_local_hub_fixture
      root = Dir.mktmpdir("igniter-companion-hub")
      capsule_root = File.join(root, "horoscope_source")
      bundle_path = File.join(root, "bundles", "horoscope")
      install_root = File.join(root, "installed")
      catalog_path = File.join(root, "catalog.json")

      FileUtils.mkdir_p(File.join(capsule_root, "contracts"))
      FileUtils.mkdir_p(File.join(capsule_root, "services"))
      FileUtils.mkdir_p(File.join(capsule_root, "spec"))
      File.write(File.join(capsule_root, "contracts/daily_horoscope.rb"), "# deterministic horoscope contract\n")
      File.write(File.join(capsule_root, "services/horoscope_service.rb"), "# deterministic horoscope service\n")
      File.write(File.join(capsule_root, "igniter.rb"), "# horoscope capsule config\n")

      capsule = Igniter::Application.capsule(:horoscope, root: capsule_root, env: :test) do
        layout :capsule
        groups :contracts, :services
        contract "Contracts::DailyHoroscope"
        service :horoscope_service
        export :daily_horoscope, kind: :service, target: "Services::HoroscopeService"
      end
      readiness = Igniter::Application.transfer_readiness(
        handoff_manifest: Igniter::Application.handoff_manifest(
          subject: :horoscope_bundle,
          capsules: [capsule]
        ),
        transfer_inventory: Igniter::Application.transfer_inventory(capsule)
      )
      bundle_plan = Igniter::Application.transfer_bundle_plan(transfer_readiness: readiness)
      Igniter::Application.write_transfer_bundle(bundle_plan, output: bundle_path, create_parent: true)

      File.write(
        catalog_path,
        JSON.pretty_generate(
          entries: [
            {
              name: :horoscope,
              title: "Daily Horoscope",
              version: "0.1.0",
              description: "Deterministic horoscope capsule for Companion.",
              bundle_path: File.join("bundles", "horoscope"),
              capabilities: %i[daily_horoscope]
            }
          ]
        )
      )

      {
        catalog_path: catalog_path,
        install_root: install_root
      }
    end

    def reminder_persistence_manifest?
      manifest = Contracts::Reminder.persistence_manifest
      persist = manifest.fetch(:persist)
      fields = manifest.fetch(:fields).map { |field| field.fetch(:name) }
      persist.fetch(:key) == :id &&
        persist.fetch(:adapter) == :sqlite &&
        fields == %i[id title due status]
    end

    def reminder_generated_api?
      records = Services::ContractRecordSet.new(
        contract_class: Contracts::Reminder,
        collection: [],
        record_class: Services::CompanionState::Reminder
      )
      created = records.save(id: "contract-api", title: "Generated API", due: "today")
      defaulted = created.status == :open
      records.update("contract-api", status: :done)

      records.api_manifest.fetch(:operations) == %i[all find save update delete clear scope command] &&
        defaulted &&
        records.find("contract-api").status == :done &&
        records.all.length == 1
    end

    def reminder_scope_api?
      records = Services::ContractRecordSet.new(
        contract_class: Contracts::Reminder,
        collection: [],
        record_class: Services::CompanionState::Reminder
      )
      records.save(id: "open-reminder", title: "Open", due: "today")
      records.save(id: "done-reminder", title: "Done", due: "today", status: :done)
      open = records.scope(:open)

      open.length == 1 &&
        open.first.id == "open-reminder" &&
        records.api_manifest.fetch(:scopes).any? { |scope| scope.fetch(:name) == :open }
    end

    def reminder_command_metadata_api?
      records = Services::ContractRecordSet.new(
        contract_class: Contracts::Reminder,
        collection: [],
        record_class: Services::CompanionState::Reminder
      )
      command = records.command(:complete)
      mutation = Contracts::ReminderContract.evaluate(
        operation: :complete,
        id: "morning-water",
        title: nil,
        reminders: [Services::CompanionState::Reminder.new(id: "morning-water", title: "Water", due: "morning", status: :open)]
      ).fetch(:mutation)

      command.fetch(:attributes).fetch(:operation) == :record_update &&
        command.fetch(:attributes).fetch(:changes) == { status: :done } &&
        mutation.fetch(:operation) == :record_update &&
        mutation.fetch(:target) == :reminders
    end

    def daily_focus_persistence_manifest?
      manifest = Contracts::DailyFocus.persistence_manifest
      persist = manifest.fetch(:persist)
      fields = manifest.fetch(:fields).map { |field| field.fetch(:name) }
      persist.fetch(:key) == :date &&
        persist.fetch(:adapter) == :sqlite &&
        fields == %i[date title]
    end

    def daily_focus_generated_api?
      records = Services::ContractRecordSet.new(
        contract_class: Contracts::DailyFocus,
        collection: [],
        record_class: Services::CompanionState::DailyFocus
      )
      records.save(date: "2026-04-28", title: "Focus")
      records.update("2026-04-28", title: "Updated focus")

      records.api_manifest.fetch(:operations) == %i[all find save update delete clear scope command] &&
        records.find("2026-04-28").title == "Updated focus" &&
        records.all.length == 1
    end

    def daily_focus_first_class_record?(config)
      state = config.store_adapter.load_state
      focuses = Array(state.fetch(:daily_focuses))
      focuses.length == 1 &&
        focuses.first.fetch(:date) == Date.today.iso8601 &&
        focuses.first.fetch(:title) == "Draft the launch note"
    end

    def countdown_persistence_manifest?
      manifest = Contracts::Countdown.persistence_manifest
      persist = manifest.fetch(:persist)
      fields = manifest.fetch(:fields).map { |field| field.fetch(:name) }
      persist.fetch(:key) == :id &&
        persist.fetch(:adapter) == :sqlite &&
        fields == %i[id title target_date]
    end

    def countdown_generated_api?
      records = Services::ContractRecordSet.new(
        contract_class: Contracts::Countdown,
        collection: [],
        record_class: Services::CompanionState::Countdown
      )
      records.save(id: "launch", title: "Launch", target_date: "2026-05-01")
      records.update("launch", title: "Public launch")

      records.api_manifest.fetch(:operations) == %i[all find save update delete clear scope command] &&
        records.find("launch").title == "Public launch" &&
        records.all.length == 1
    end

    def countdown_projection_contract?
      projection = Contracts::CountdownReadModelContract.evaluate(
        countdowns: [
          Services::CompanionState::Countdown.new(id: "launch", title: "Launch", target_date: "2026-05-01")
        ],
        date: "2026-04-29"
      )
      snapshot = projection.fetch(:countdown_snapshots).first

      snapshot.id == "launch" &&
        snapshot.days_remaining == 2
    end

    def tracker_persistence_manifest?
      manifest = Contracts::Tracker.persistence_manifest
      persist = manifest.fetch(:persist)
      fields = manifest.fetch(:fields).map { |field| field.fetch(:name) }
      persist.fetch(:key) == :id &&
        persist.fetch(:adapter) == :sqlite &&
        fields == %i[id name template unit]
    end

    def tracker_generated_api?
      records = Services::ContractRecordSet.new(
        contract_class: Contracts::Tracker,
        collection: [],
        record_class: Services::CompanionState::Tracker
      )
      records.save(id: "mood", name: "Mood", template: :scale, unit: "score")
      records.update("mood", unit: "points")

      records.api_manifest.fetch(:operations) == %i[all find save update delete clear scope command] &&
        records.find("mood").unit == "points" &&
        records.all.length == 1
    end

    def tracker_projection_composes_history?(snapshot)
      sleep = snapshot.trackers.find { |tracker| tracker.id == "sleep" }
      sleep&.log_entries&.length == 1 &&
        sleep.log_entries.first.fetch(:value) == "7.5"
    end

    def tracker_projection_contract?
      projection = Contracts::TrackerReadModelContract.evaluate(
        trackers: [
          Services::CompanionState::Tracker.new(id: "sleep", name: "Sleep", template: :sleep, unit: "hours"),
          Services::CompanionState::Tracker.new(id: "training", name: "Training", template: :workout, unit: "minutes")
        ],
        tracker_logs: [
          { tracker_id: "sleep", date: "2026-04-28", value: "7.5" },
          { tracker_id: "training", date: "2026-04-28", value: "20" }
        ],
        date: "2026-04-28"
      )
      sleep = projection.fetch(:tracker_snapshots).find { |tracker| tracker.id == "sleep" }

      projection.fetch(:logs_today) == 2 &&
        projection.fetch(:sleep_hours_today).between?(7.49, 7.51) &&
        projection.fetch(:training_minutes_today).between?(19.99, 20.01) &&
        sleep.log_entries.first.fetch(:value) == "7.5"
    end

    def tracker_log_history_manifest?
      manifest = Contracts::TrackerLog.persistence_manifest
      history = manifest.fetch(:history)
      fields = manifest.fetch(:fields).map { |field| field.fetch(:name) }
      history.fetch(:key) == :tracker_id &&
        history.fetch(:adapter) == :sqlite &&
        fields == %i[tracker_id date value]
    end

    def tracker_log_history_api?
      entries = []
      history = Services::ContractHistory.new(
        contract_class: Contracts::TrackerLog,
        entries: -> { entries },
        append: ->(event) { entries << event }
      )
      history.append(tracker_id: "sleep", date: "2026-04-28", value: "7.5")

      history.api_manifest.fetch(:operations) == %i[append all where count] &&
        history.count(tracker_id: "sleep") == 1 &&
        history.where(date: "2026-04-28").first.fetch(:value) == "7.5"
    end

    def tracker_log_first_class_history?(config)
      state = config.store_adapter.load_state
      logs = Array(state.fetch(:tracker_logs))
      nested_logs = Array(state.fetch(:trackers)).flat_map { |tracker| Array(tracker.fetch(:entries, [])) }
      logs.length == 1 &&
        logs.first.fetch(:tracker_id) == "sleep" &&
        nested_logs.empty?
    end

    def action_history_manifest?
      manifest = Contracts::CompanionAction.persistence_manifest
      history = manifest.fetch(:history)
      fields = manifest.fetch(:fields).map { |field| field.fetch(:name) }
      history.fetch(:key) == :index &&
        history.fetch(:adapter) == :sqlite &&
        fields == %i[index kind subject_id status]
    end

    def action_history_api?
      actions = []
      history = Services::ContractHistory.new(
        contract_class: Contracts::CompanionAction,
        entries: -> { actions },
        append: ->(event) { actions << event }
      )
      history.append(index: 0, kind: :smoke, subject_id: :companion, status: :ready)

      history.api_manifest.fetch(:operations) == %i[append all where count] &&
        history.count(status: :ready) == 1 &&
        history.where(kind: :smoke).first.fetch(:subject_id) == :companion
    end

    def activity_feed_contract?
      feed = Contracts::ActivityFeedContract.evaluate(
        actions: [
          { index: 1, kind: :second, subject_id: :companion, status: :ready },
          { index: 0, kind: :first, subject_id: :companion, status: :ready },
          { index: 2, kind: :third, subject_id: :companion, status: :ready }
        ],
        recent_limit: 2
      )

      feed.fetch(:action_count) == 3 &&
        feed.fetch(:recent_events).map { |event| event.fetch(:kind) } == %i[second third]
    end

    def daily_plan_signal?
      log_tracker = Contracts::DailyPlanContract.evaluate(
        daily_focus_title: nil,
        next_reminder_id: nil,
        next_reminder_title: nil,
        suggested_tracker_id: "sleep",
        body_battery: { status: "steady" },
        open_reminders: 0,
        tracker_logs_today: 0,
        urgent_countdown_id: nil,
        urgent_countdown_title: nil
      )
      close_reminder = Contracts::DailyPlanContract.evaluate(
        daily_focus_title: "Write note",
        next_reminder_id: "morning-water",
        next_reminder_title: "Drink water",
        suggested_tracker_id: "sleep",
        body_battery: { status: "charged" },
        open_reminders: 1,
        tracker_logs_today: 1,
        urgent_countdown_id: nil,
        urgent_countdown_title: nil
      )

      log_tracker.fetch(:signal) == :log_tracker &&
        log_tracker.fetch(:next_action).include?("tracker") &&
        close_reminder.fetch(:signal) == :close_reminder &&
        close_reminder.fetch(:next_action).include?("Drink water")
    end

    def daily_plan_quick_action?
      log_tracker = Contracts::DailyPlanContract.evaluate(
        daily_focus_title: nil,
        next_reminder_id: nil,
        next_reminder_title: nil,
        suggested_tracker_id: "sleep",
        body_battery: { status: "steady" },
        open_reminders: 0,
        tracker_logs_today: 0,
        urgent_countdown_id: nil,
        urgent_countdown_title: nil
      ).fetch(:quick_action)
      close_reminder = Contracts::DailyPlanContract.evaluate(
        daily_focus_title: "Write note",
        next_reminder_id: "morning-water",
        next_reminder_title: "Drink water",
        suggested_tracker_id: "sleep",
        body_battery: { status: "charged" },
        open_reminders: 1,
        tracker_logs_today: 1,
        urgent_countdown_id: nil,
        urgent_countdown_title: nil
      ).fetch(:quick_action)

      log_tracker.fetch(:kind) == :tracker_log &&
        log_tracker.fetch(:subject_id) == "sleep" &&
        close_reminder.fetch(:kind) == :complete_reminder &&
        close_reminder.fetch(:subject_id) == "morning-water"
    end

    def daily_plan_quick_action_command?
      log_tracker = Contracts::DailyPlanContract.evaluate(
        daily_focus_title: nil,
        next_reminder_id: nil,
        next_reminder_title: nil,
        suggested_tracker_id: "sleep",
        body_battery: { status: "steady" },
        open_reminders: 0,
        tracker_logs_today: 0,
        urgent_countdown_id: nil,
        urgent_countdown_title: nil
      ).fetch(:quick_action).fetch(:command)
      close_reminder = Contracts::DailyPlanContract.evaluate(
        daily_focus_title: "Write note",
        next_reminder_id: "morning-water",
        next_reminder_title: "Drink water",
        suggested_tracker_id: "sleep",
        body_battery: { status: "charged" },
        open_reminders: 1,
        tracker_logs_today: 1,
        urgent_countdown_id: nil,
        urgent_countdown_title: nil
      ).fetch(:quick_action).fetch(:command)

      log_tracker.fetch(:name) == :log_tracker &&
        log_tracker.fetch(:arguments).fetch(:id) == "sleep" &&
        log_tracker.fetch(:arguments).fetch(:value) == :input_value &&
        close_reminder.fetch(:name) == :complete_reminder &&
        close_reminder.fetch(:arguments).fetch(:id) == "morning-water"
    end

    def today_quick_action_route?
      db_path = File.join(Dir.mktmpdir("igniter-companion-today-action"), "companion.sqlite3")
      config = Companion.default_configuration(store_path: db_path)
      app = Companion.build(config: config)
      store = app.service(:companion)
      initial = store.snapshot
      initial_action = initial.daily_plan.fetch(:quick_action)
      first_status, first_headers = post(app, "/today/quick-action", value: "8")
      first_result_status = get_status(app, first_headers.fetch("location"))
      after_log = store.snapshot
      after_log_action = after_log.daily_plan.fetch(:quick_action)
      second_status, second_headers = post(app, "/today/quick-action")
      second_result_status = get_status(app, second_headers.fetch("location"))
      after_done = store.snapshot

      first_status == 303 &&
        first_result_status == 200 &&
        second_status == 303 &&
        second_result_status == 200 &&
        initial_action.fetch(:kind) == :tracker_log &&
        after_log.tracker_logs_today == initial.tracker_logs_today + 1 &&
        after_log_action.fetch(:kind) == :complete_reminder &&
        after_done.open_reminders == initial.open_reminders - 1
    end

    def persistence_registry?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      manifest = persistence.capability_manifest
      persistence.capability_names == %i[
        reminders trackers daily_focuses countdowns articles wizard_type_specs tracker_logs actions comments
        wizard_type_spec_changes materializer_attempts materializer_approvals tracker_read_model
        countdown_read_model activity_feed materializer_audit_trail materializer_approval_audit_trail
      ] &&
        manifest.fetch(:reminders).fetch(:kind) == :record &&
        manifest.fetch(:countdowns).fetch(:kind) == :record &&
        manifest.fetch(:articles).fetch(:kind) == :record &&
        manifest.fetch(:wizard_type_specs).fetch(:kind) == :record &&
        manifest.fetch(:comments).fetch(:kind) == :history &&
        manifest.fetch(:wizard_type_spec_changes).fetch(:kind) == :history &&
        manifest.fetch(:materializer_attempts).fetch(:kind) == :history &&
        manifest.fetch(:materializer_approvals).fetch(:kind) == :history &&
        manifest.fetch(:countdown_read_model).fetch(:kind) == :projection &&
        manifest.fetch(:tracker_logs).fetch(:kind) == :history &&
        manifest.fetch(:activity_feed).fetch(:kind) == :projection &&
        manifest.fetch(:materializer_audit_trail).fetch(:kind) == :projection &&
        manifest.fetch(:materializer_approval_audit_trail).fetch(:kind) == :projection
    end

    def persistence_registry_valid?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      persistence.valid? && persistence.validation_errors.empty?
    end

    def persistence_readiness_contract?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      readiness = persistence.readiness
      readiness.fetch(:ready) &&
        readiness.fetch(:status) == :ready &&
        readiness.fetch(:capability_count) == 17 &&
        readiness.fetch(:record_count) == 6 &&
        readiness.fetch(:history_count) == 6 &&
        readiness.fetch(:projection_count) == 5 &&
        readiness.fetch(:relation_count) == 2 &&
        readiness.fetch(:warning_count).zero?
    end

    def persistence_relation_health_contract?
      clean = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).relation_health
      warning = Contracts::PersistenceRelationHealthContract.evaluate(
        relation_manifest: { tracker_logs_by_tracker: {} },
        relation_warnings: {
          tracker_logs_by_tracker: [
            {
              kind: :missing_source,
              from: :trackers,
              to: :tracker_logs,
              values: ["ghost-tracker"],
              message: "tracker_logs references missing trackers ghost-tracker"
            }
          ]
        }
      )
      warning_entry = warning.fetch(:warnings).first

      clean.fetch(:status) == :clear &&
        clean.fetch(:warning_count).zero? &&
        clean.fetch(:repair_suggestions).empty? &&
        clean.fetch(:relation_reports).fetch(:tracker_logs_by_tracker).fetch(:status) == :clear &&
        warning.fetch(:status) == :warning &&
        warning.fetch(:warning_count) == 1 &&
        warning.fetch(:relation_reports).fetch(:tracker_logs_by_tracker).fetch(:status) == :warning &&
        warning_entry.fetch(:relation) == :tracker_logs_by_tracker &&
        warning_entry.fetch(:kind) == :missing_source &&
        warning_entry.fetch(:values) == ["ghost-tracker"] &&
        warning.fetch(:summary).include?("1 warnings")
    end

    def relation_health_reports?
      health = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).relation_health
      report = health.fetch(:relation_reports).fetch(:tracker_logs_by_tracker)
      article_report = health.fetch(:relation_reports).fetch(:comments_by_article)

      report.fetch(:status) == :clear &&
        report.fetch(:warning_count).zero? &&
        report.fetch(:warnings).empty? &&
        report.fetch(:repair_suggestions).empty? &&
        article_report.fetch(:status) == :clear
    end

    def relation_health_structured_warnings?
      orphaned_state = Services::CompanionState.seeded
      orphaned_state.tracker_logs << Services::CompanionState::TrackerLog.new(
        tracker_id: "ghost-tracker",
        date: Date.today.iso8601,
        value: "7"
      )
      warning = Services::CompanionPersistence
                .new(state: orphaned_state)
                .relation_health
                .fetch(:warnings)
                .first

      warning.fetch(:relation) == :tracker_logs_by_tracker &&
        warning.fetch(:kind) == :missing_source &&
        warning.fetch(:from) == :trackers &&
        warning.fetch(:to) == :tracker_logs &&
        warning.fetch(:values) == ["ghost-tracker"] &&
        warning.fetch(:message).include?("ghost-tracker")
    end

    def relation_health_repair_suggestions?
      orphaned_state = Services::CompanionState.seeded
      orphaned_state.tracker_logs << Services::CompanionState::TrackerLog.new(
        tracker_id: "ghost-tracker",
        date: Date.today.iso8601,
        value: "7"
      )
      health = Services::CompanionPersistence.new(state: orphaned_state).relation_health
      suggestion = health.fetch(:repair_suggestions).first
      report_suggestion = health.fetch(:relation_reports)
                                .fetch(:tracker_logs_by_tracker)
                                .fetch(:repair_suggestions)
                                .first

      suggestion.fetch(:relation) == :tracker_logs_by_tracker &&
        suggestion.fetch(:kind) == :review_missing_source &&
        suggestion.fetch(:command).fetch(:name) == :review_relation_warning &&
        suggestion.fetch(:command).fetch(:arguments).fetch(:values) == ["ghost-tracker"] &&
        report_suggestion.fetch(:command).fetch(:arguments).fetch(:relation) == :tracker_logs_by_tracker
    end

    def setup_relation_health_endpoint?(relation_health)
      relation_health.include?("relation_reports") &&
        relation_health.include?("tracker_logs_by_tracker") &&
        relation_health.include?("repair_suggestions") &&
        relation_health.include?("status=>:clear")
    end

    def setup_relation_health_json_endpoint?(relation_health_json)
      payload = JSON.parse(relation_health_json)
      report = payload.fetch("relation_reports").fetch("tracker_logs_by_tracker")

      payload.fetch("status") == "clear" &&
        payload.fetch("warning_count").zero? &&
        payload.fetch("repair_suggestions").empty? &&
        report.fetch("status") == "clear" &&
        report.fetch("repair_suggestions").empty?
    end

    def setup_materialization_endpoint?(materialization)
      materialization.include?("ready_for_static_materialization") &&
        materialization.include?("comments_by_article") &&
        materialization.include?("write")
    end

    def setup_materialization_json_endpoint?(materialization_json)
      payload = JSON.parse(materialization_json)

      record = payload.fetch("record_contract")
      history = payload.fetch("history_contracts").first
      payload.fetch("status") == "ready_for_static_materialization" &&
        payload.fetch("schema_version") == 1 &&
        payload.fetch("static_required") &&
        record.fetch("storage").fetch("shape") == "store" &&
        history.fetch("storage").fetch("shape") == "history" &&
        payload.fetch("relations").key?("comments_by_article") &&
        payload.fetch("required_capabilities") == %w[write git test restart]
    end

    def setup_materialization_parity_endpoint?(parity)
      parity.include?("matched") &&
        parity.include?("comments_by_article") &&
        parity.include?("Static materialization matches")
    end

    def setup_materialization_parity_json_endpoint?(parity_json)
      payload = JSON.parse(parity_json)

      payload.fetch("schema_version") == 1 &&
        payload.fetch("status") == "matched" &&
        payload.fetch("mismatches").empty? &&
        payload.fetch("checked_capabilities").include?("comments_by_article")
    end

    def setup_wizard_type_specs_endpoint?(wizard_specs)
      wizard_specs.include?("article-comment") &&
        wizard_specs.include?("Article") &&
        wizard_specs.include?("comments_by_article")
    end

    def setup_wizard_type_specs_json_endpoint?(wizard_specs_json)
      payload = JSON.parse(wizard_specs_json)
      spec = payload.find { |entry| entry.fetch("id") == "article-comment" }.fetch("spec")

      spec.fetch("schema_version") == 1 &&
        spec.fetch("storage").fetch("shape") == "store" &&
        spec.fetch("histories").first.fetch("storage").fetch("shape") == "history" &&
        spec.fetch("name") == "Article" &&
        spec.fetch("fields").any? { |field| field.fetch("name") == "status" && field.fetch("type") == "enum" } &&
        spec.fetch("histories").first.fetch("relation").fetch("name") == "comments_by_article"
    end

    def setup_wizard_type_spec_export_endpoint?(wizard_export)
      wizard_export.include?("dev_config") &&
        wizard_export.include?("prod_config") &&
        wizard_export.include?("latest-only")
    end

    def setup_wizard_type_spec_export_json_endpoint?(wizard_export_json)
      payload = JSON.parse(wizard_export_json)

      payload.fetch("schema_versions") == [1] &&
        payload.fetch("dev_config").fetch("history").any? &&
        payload.fetch("prod_config").fetch("history").empty? &&
        payload.fetch("prod_config").fetch("compressed")
    end

    def setup_wizard_type_spec_migration_endpoint?(wizard_migration)
      wizard_migration.include?("review-only migration candidates") &&
        wizard_migration.include?("article-comment") &&
        wizard_migration.include?("status=>:stable")
    end

    def setup_wizard_type_spec_migration_json_endpoint?(wizard_migration_json)
      payload = JSON.parse(wizard_migration_json)
      report = payload.fetch("reports").find { |entry| entry.fetch("spec_id") == "article-comment" }

      payload.fetch("status") == "stable" &&
        payload.fetch("candidate_count").zero? &&
        report.fetch("status") == "stable"
    end

    def setup_infrastructure_loop_health_endpoint?(loop_health)
      loop_health.include?("self_supporting") &&
        loop_health.include?("no write capability requested")
    end

    def setup_infrastructure_loop_health_json_endpoint?(loop_health_json)
      payload = JSON.parse(loop_health_json)
      loop_state = payload.fetch("loop_state")
      signals = payload.fetch("signals")

      payload.fetch("status") == "self_supporting" &&
        signals.fetch("parity_matched") &&
        signals.fetch("migration_review_only") &&
        loop_state.fetch("write_capability_requested") == false
    end

    def setup_materializer_gate_endpoint?(materializer_gate)
      materializer_gate.include?("status=>:blocked") &&
        materializer_gate.include?("human_approval_required") &&
        materializer_gate.include?("write")
    end

    def setup_materializer_gate_json_endpoint?(materializer_gate_json)
      payload = JSON.parse(materializer_gate_json)

      payload.fetch("status") == "blocked" &&
        payload.fetch("approved_capabilities").empty? &&
        payload.fetch("blocked_capabilities") == %w[write git test restart] &&
        payload.fetch("reasons") == ["human_approval_required"] &&
        payload.fetch("approval_request").fetch("kind") == "materializer_capability_request" &&
        payload.fetch("approval_request").fetch("review_only")
    end

    def setup_materializer_preflight_endpoint?(materializer_preflight)
      materializer_preflight.include?("blocked_until_approval") &&
        materializer_preflight.include?("materializer_capability_request") &&
        materializer_preflight.include?("review-only")
    end

    def setup_materializer_preflight_json_endpoint?(materializer_preflight_json)
      payload = JSON.parse(materializer_preflight_json)
      checklist = payload.fetch("checklist")

      payload.fetch("status") == "blocked_until_approval" &&
        checklist.values.all? &&
        payload.fetch("evidence").fetch("blocked_capabilities") == %w[write git test restart] &&
        payload.fetch("evidence").fetch("reasons") == ["human_approval_required"] &&
        payload.fetch("approval_request").fetch("kind") == "materializer_capability_request" &&
        payload.fetch("approval_request").fetch("review_only")
    end

    def setup_materializer_runbook_endpoint?(materializer_runbook)
      materializer_runbook.include?("blocked_until_approval") &&
        materializer_runbook.include?("write_static_contracts") &&
        materializer_runbook.include?("run_focused_tests") &&
        materializer_runbook.include?("review-only")
    end

    def setup_materializer_runbook_json_endpoint?(materializer_runbook_json)
      payload = JSON.parse(materializer_runbook_json)
      steps = payload.fetch("steps")

      payload.fetch("status") == "blocked_until_approval" &&
        payload.fetch("blocked_capabilities") == %w[write git test restart] &&
        payload.fetch("approval_request").fetch("kind") == "materializer_capability_request" &&
        steps.length == 4 &&
        steps.all? { |step| step.fetch("status") == "blocked" && step.fetch("review_only") } &&
        steps.map { |step| step.fetch("capability") }.sort == %w[git restart test write]
    end

    def setup_materializer_receipt_endpoint?(materializer_receipt)
      materializer_receipt.include?("materializer_runbook_receipt") &&
        materializer_receipt.include?("materializer_step_blocked") &&
        materializer_receipt.include?("without execution")
    end

    def setup_materializer_receipt_json_endpoint?(materializer_receipt_json)
      payload = JSON.parse(materializer_receipt_json)
      receipt = payload.fetch("receipt")

      payload.fetch("status") == "blocked" &&
        receipt.fetch("kind") == "materializer_runbook_receipt" &&
        receipt.fetch("executed") == false &&
        receipt.fetch("review_only") &&
        receipt.fetch("blocked_step_count") == 4 &&
        payload.fetch("events").length == 4 &&
        payload.fetch("events").all? { |event| event.fetch("kind") == "materializer_step_blocked" && event.fetch("executed") == false }
    end

    def setup_materializer_attempt_command_endpoint?(materializer_attempt_command)
      materializer_attempt_command.include?("operation=>:history_append") &&
        materializer_attempt_command.include?("target=>:materializer_attempts") &&
        materializer_attempt_command.include?("materializer_attempt_recordable")
    end

    def setup_materializer_attempt_command_json_endpoint?(materializer_attempt_command_json)
      payload = JSON.parse(materializer_attempt_command_json)
      result = payload.fetch("result")
      mutation = payload.fetch("mutation")
      event = mutation.fetch("event")

      result.fetch("success") &&
        result.fetch("feedback_code") == "materializer_attempt_recordable" &&
        mutation.fetch("operation") == "history_append" &&
        mutation.fetch("target") == "materializer_attempts" &&
        event.fetch("executed") == false &&
        event.fetch("review_only") &&
        event.fetch("blocked_step_count") == 4
    end

    def setup_materializer_audit_endpoint?(materializer_audit)
      materializer_audit.include?("attempt_count=>0") &&
        materializer_audit.include?("blocked_count=>0") &&
        materializer_audit.include?("materializer attempts")
    end

    def setup_materializer_audit_json_endpoint?(materializer_audit_json)
      payload = JSON.parse(materializer_audit_json)

      payload.fetch("attempt_count").zero? &&
        payload.fetch("blocked_count").zero? &&
        payload.fetch("executed_count").zero? &&
        payload.fetch("blocked_capabilities").empty? &&
        payload.fetch("last_attempt").nil?
    end

    def setup_materializer_supervision_endpoint?(materializer_supervision)
      materializer_supervision.include?("status=>:blocked") &&
        materializer_supervision.include?("awaiting_explicit_attempt_record") &&
        materializer_supervision.include?("record_blocked_attempt")
    end

    def setup_materializer_supervision_json_endpoint?(materializer_supervision_json)
      payload = JSON.parse(materializer_supervision_json)
      signals = payload.fetch("signals")
      command_intent = payload.fetch("command_intent")
      approval_command_intent = payload.fetch("approval_command_intent")
      approval_audit = payload.fetch("approval_audit")
      descriptor = payload.fetch("descriptor")

      payload.fetch("status") == "blocked" &&
        payload.fetch("phase") == "awaiting_explicit_attempt_record" &&
        descriptor.fetch("schema_version") == 1 &&
        descriptor.fetch("kind") == "materializer_status" &&
        descriptor.fetch("review_only") &&
        descriptor.fetch("grants_capabilities") == false &&
        descriptor.fetch("execution_allowed") == false &&
        descriptor.fetch("histories").fetch("attempts") == "materializer_attempts" &&
        descriptor.fetch("histories").fetch("approvals") == "materializer_approvals" &&
        signals.fetch("gate_blocked") &&
        signals.fetch("attempt_command_ready") &&
        signals.fetch("approval_command_ready") &&
        signals.fetch("approval_application_absent") &&
        command_intent.fetch("operation") == "history_append" &&
        command_intent.fetch("target") == "materializer_attempts" &&
        approval_command_intent.fetch("target") == "materializer_approvals" &&
        approval_command_intent.fetch("applies_capabilities") == false &&
        approval_audit.fetch("approval_count").zero? &&
        payload.fetch("next_action") == "record_blocked_attempt"
    end

    def setup_materializer_endpoint?(materializer)
      materializer.include?("status=>:blocked") &&
        materializer.include?("kind=>:materializer_status") &&
        materializer.include?("grants_capabilities=>false") &&
        materializer.include?("approval_audit") &&
        materializer.include?("record_blocked_attempt")
    end

    def setup_materializer_json_endpoint?(materializer_json)
      setup_materializer_supervision_json_endpoint?(materializer_json)
    end

    def setup_materializer_descriptor_health_endpoint?(materializer_descriptor_health)
      materializer_descriptor_health.include?("status=>:stable") &&
        materializer_descriptor_health.include?("check_count=>10") &&
        materializer_descriptor_health.include?("materializer status descriptor terms stable")
    end

    def setup_materializer_descriptor_health_json_endpoint?(materializer_descriptor_health_json)
      payload = JSON.parse(materializer_descriptor_health_json)

      payload.fetch("status") == "stable" &&
        payload.fetch("check_count") == 10 &&
        payload.fetch("missing_terms").empty? &&
        payload.fetch("checks").all? { |check| check.fetch("present") }
    end

    def setup_materializer_approval_endpoint?(materializer_approval)
      materializer_approval.include?("status=>:pending") &&
        materializer_approval.include?("human_approval_missing") &&
        materializer_approval.include?("applies_capabilities=>false")
    end

    def setup_materializer_approval_json_endpoint?(materializer_approval_json)
      payload = JSON.parse(materializer_approval_json)
      decision = payload.fetch("decision")

      payload.fetch("status") == "pending" &&
        payload.fetch("approved") == false &&
        payload.fetch("granted_capabilities").empty? &&
        payload.fetch("rejected_capabilities") == %w[write git test restart] &&
        payload.fetch("reasons").include?("human_approval_missing") &&
        decision.fetch("kind") == "materializer_approval_decision" &&
        decision.fetch("applies_capabilities") == false
    end

    def setup_materializer_approval_receipt_endpoint?(materializer_approval_receipt)
      materializer_approval_receipt.include?("materializer_approval_receipt") &&
        materializer_approval_receipt.include?("status=>:pending") &&
        materializer_approval_receipt.include?("applies_capabilities=>false")
    end

    def setup_materializer_approval_receipt_json_endpoint?(materializer_approval_receipt_json)
      payload = JSON.parse(materializer_approval_receipt_json)
      receipt = payload.fetch("receipt")

      payload.fetch("status") == "pending" &&
        receipt.fetch("kind") == "materializer_approval_receipt" &&
        receipt.fetch("approved") == false &&
        receipt.fetch("review_only") &&
        receipt.fetch("applies_capabilities") == false &&
        receipt.fetch("rejected_capabilities") == %w[write git test restart]
    end

    def setup_materializer_approval_command_endpoint?(materializer_approval_command)
      materializer_approval_command.include?("operation=>:history_append") &&
        materializer_approval_command.include?("target=>:materializer_approvals") &&
        materializer_approval_command.include?("materializer_approval_recordable")
    end

    def setup_materializer_approval_command_json_endpoint?(materializer_approval_command_json)
      payload = JSON.parse(materializer_approval_command_json)
      result = payload.fetch("result")
      mutation = payload.fetch("mutation")
      event = mutation.fetch("event")

      result.fetch("success") &&
        result.fetch("feedback_code") == "materializer_approval_recordable" &&
        mutation.fetch("operation") == "history_append" &&
        mutation.fetch("target") == "materializer_approvals" &&
        event.fetch("applies_capabilities") == false &&
        event.fetch("review_only") &&
        event.fetch("rejected_capabilities") == %w[write git test restart]
    end

    def setup_materializer_approvals_endpoint?(materializer_approvals)
      materializer_approvals == "[]"
    end

    def setup_materializer_approvals_json_endpoint?(materializer_approvals_json)
      JSON.parse(materializer_approvals_json).empty?
    end

    def setup_materializer_approval_audit_endpoint?(materializer_approval_audit)
      materializer_approval_audit.include?("approval_count=>0") &&
        materializer_approval_audit.include?("pending_count=>0") &&
        materializer_approval_audit.include?("materializer approvals")
    end

    def setup_materializer_approval_audit_json_endpoint?(materializer_approval_audit_json)
      payload = JSON.parse(materializer_approval_audit_json)

      payload.fetch("approval_count").zero? &&
        payload.fetch("pending_count").zero? &&
        payload.fetch("approved_count").zero? &&
        payload.fetch("applied_count").zero? &&
        payload.fetch("granted_capabilities").empty? &&
        payload.fetch("rejected_capabilities").empty? &&
        payload.fetch("last_approval").nil?
    end

    def persistence_operation_model?
      reminder_create = Contracts::ReminderContract.evaluate(
        operation: :create,
        id: nil,
        title: "Operation model",
        reminders: []
      ).fetch(:mutation)
      reminder_complete = Contracts::ReminderContract.evaluate(
        operation: :complete,
        id: "morning-water",
        title: nil,
        reminders: [Services::CompanionState::Reminder.new(id: "morning-water", title: "Water", due: "morning", status: :open)]
      ).fetch(:mutation)
      materializer_attempt = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).materializer_attempt_command.fetch(:mutation)
      materializer_approval = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).materializer_approval_command.fetch(:mutation)
      tracker_log = Contracts::TrackerLogContract.evaluate(
        tracker_id: "sleep",
        value: "7",
        date: "2026-04-29",
        trackers: [Services::CompanionState::Tracker.new(id: "sleep", name: "Sleep", template: :sleep, unit: "hours")]
      ).fetch(:mutation)
      refused = Contracts::CountdownContract.evaluate(
        title: " ",
        target_date: " ",
        countdowns: []
      ).fetch(:mutation)
      manifest = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).manifest_snapshot
      reminder_operation = manifest.fetch(:records).fetch(:reminders).fetch(:operation_descriptors).find { |entry| entry.fetch(:name) == :save }
      tracker_log_operation = manifest.fetch(:histories).fetch(:tracker_logs).fetch(:operation_descriptors).find { |entry| entry.fetch(:name) == :append }
      materializer_operation = manifest.fetch(:commands).fetch(:materializer_attempt_commands).fetch(:operation_descriptors).find do |entry|
        entry.fetch(:name) == :history_append
      end
      refusal_operation = manifest.fetch(:commands).fetch(:countdown_commands).fetch(:operation_descriptors).find { |entry| entry.fetch(:name) == :none }

      reminder_create.fetch(:operation) == :record_append &&
        reminder_create.fetch(:target) == :reminders &&
        reminder_complete.fetch(:operation) == :record_update &&
        tracker_log.fetch(:operation) == :history_append &&
        tracker_log.fetch(:target) == :tracker_logs &&
        materializer_attempt.fetch(:operation) == :history_append &&
        materializer_attempt.fetch(:target) == :materializer_attempts &&
        materializer_approval.fetch(:operation) == :history_append &&
        materializer_approval.fetch(:target) == :materializer_approvals &&
        refused.fetch(:operation) == :none &&
        reminder_operation.fetch(:target_shape) == :store &&
        reminder_operation.fetch(:mutates) &&
        tracker_log_operation.fetch(:target_shape) == :history &&
        tracker_log_operation.fetch(:mutates) &&
        materializer_operation.fetch(:target_shape) == :history &&
        materializer_operation.fetch(:boundary) == :app &&
        refusal_operation.fetch(:mutates) == false &&
        refusal_operation.fetch(:target_shape) == :none
    end

    def persistence_manifest_contract?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      manifest = persistence.manifest_snapshot
      summary = manifest.fetch(:summary)

      manifest.fetch(:schema_version) == 1 &&
        summary.fetch(:schema_version) == 1 &&
        summary.fetch(:record_count) == 6 &&
        summary.fetch(:history_count) == 6 &&
        summary.fetch(:projection_count) == 5 &&
        summary.fetch(:command_count) == 5 &&
        summary.fetch(:relation_count) == 2 &&
        manifest.fetch(:records).fetch(:reminders).fetch(:storage) == { shape: :store, key: :id, adapter: :sqlite } &&
        manifest.fetch(:records).fetch(:reminders).fetch(:persist) == { key: :id, adapter: :sqlite } &&
        manifest.fetch(:histories).fetch(:tracker_logs).fetch(:storage) == { shape: :history, key: :tracker_id, adapter: :sqlite } &&
        manifest.fetch(:histories).fetch(:tracker_logs).fetch(:history) == { key: :tracker_id, adapter: :sqlite } &&
        manifest.fetch(:records).fetch(:reminders).fetch(:operation_descriptors).any? { |entry| entry.fetch(:name) == :save && entry.fetch(:target_shape) == :store } &&
        manifest.fetch(:histories).fetch(:tracker_logs).fetch(:operation_descriptors).any? { |entry| entry.fetch(:name) == :append && entry.fetch(:target_shape) == :history } &&
        manifest.fetch(:commands).fetch(:reminder_commands).fetch(:operation_descriptors).any? { |entry| entry.fetch(:name) == :record_update && entry.fetch(:target_shape) == :store } &&
        manifest.fetch(:commands).fetch(:tracker_log_commands).fetch(:operation_descriptors).any? { |entry| entry.fetch(:name) == :history_append && entry.fetch(:target_shape) == :history } &&
        manifest.fetch(:records).fetch(:articles).fetch(:fields).include?(:status) &&
        manifest.fetch(:records).fetch(:wizard_type_specs).fetch(:fields).include?(:spec) &&
        manifest.fetch(:histories).fetch(:comments).fetch(:fields).include?(:article_id) &&
        manifest.fetch(:histories).fetch(:wizard_type_spec_changes).fetch(:fields).include?(:change_kind) &&
        manifest.fetch(:histories).fetch(:materializer_attempts).fetch(:fields).include?(:approval_request) &&
        manifest.fetch(:histories).fetch(:materializer_approvals).fetch(:fields).include?(:granted_capabilities) &&
        manifest.fetch(:records).fetch(:reminders).fetch(:operations) == %i[all find save update delete clear scope command] &&
        manifest.fetch(:histories).fetch(:tracker_logs).fetch(:operations) == %i[append all where count] &&
        manifest.fetch(:projections).fetch(:tracker_read_model).fetch(:relations) == %i[tracker_logs_by_tracker] &&
        manifest.fetch(:projections).fetch(:materializer_audit_trail).fetch(:reads) == %i[materializer_attempts] &&
        manifest.fetch(:projections).fetch(:materializer_approval_audit_trail).fetch(:reads) == %i[materializer_approvals] &&
        manifest.fetch(:relations).fetch(:tracker_logs_by_tracker).fetch(:join) == { id: :tracker_id } &&
        manifest.fetch(:relations).fetch(:tracker_logs_by_tracker).fetch(:descriptor).fetch(:from).fetch(:storage_shape) == :store &&
        manifest.fetch(:relations).fetch(:tracker_logs_by_tracker).fetch(:descriptor).fetch(:to).fetch(:storage_shape) == :history &&
        manifest.fetch(:relations).fetch(:tracker_logs_by_tracker).fetch(:descriptor).fetch(:enforcement).fetch(:mode) == :report_only &&
        manifest.fetch(:commands).fetch(:tracker_log_commands).fetch(:operations).include?(:history_append) &&
        manifest.fetch(:commands).fetch(:materializer_attempt_commands).fetch(:operations).include?(:history_append) &&
        manifest.fetch(:commands).fetch(:materializer_approval_commands).fetch(:operations).include?(:history_append)
    end

    def persistence_manifest_glossary_contract?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      stable = persistence.manifest_glossary_health
      manifest = persistence.manifest_snapshot
      drift_manifest = manifest.merge(
        records: {
          reminders: manifest.fetch(:records).fetch(:reminders).reject { |key, _value| key == :storage }
        }
      )
      drift = Contracts::PersistenceManifestGlossaryContract.evaluate(manifest: drift_manifest)

      stable.fetch(:status) == :stable &&
        stable.fetch(:check_count) == 9 &&
        stable.fetch(:missing_terms).empty? &&
        stable.fetch(:checks).all? { |check| check.fetch(:present) } &&
        drift.fetch(:status) == :drift &&
        drift.fetch(:missing_terms).include?(:record_storage)
    end

    def persistence_storage_plan_sketch_contract?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      plan = persistence.storage_plan_sketch
      reminders = plan.fetch(:records).fetch(:reminders)
      wizard_specs = plan.fetch(:records).fetch(:wizard_type_specs)
      tracker_logs = plan.fetch(:histories).fetch(:tracker_logs)

      plan.fetch(:schema_version) == 1 &&
        plan.fetch(:descriptor).fetch(:kind) == :persistence_storage_plan_sketch &&
        plan.fetch(:descriptor).fetch(:report_only) &&
        plan.fetch(:descriptor).fetch(:gates_runtime) == false &&
        plan.fetch(:descriptor).fetch(:grants_capabilities) == false &&
        plan.fetch(:descriptor).fetch(:schema_changes_allowed) == false &&
        plan.fetch(:descriptor).fetch(:sql_generation_allowed) == false &&
        plan.fetch(:summary).fetch(:status) == :sketched &&
        plan.fetch(:summary).fetch(:record_plan_count) == 6 &&
        plan.fetch(:summary).fetch(:history_plan_count) == 6 &&
        reminders.fetch(:store_lowering) == :store_t &&
        reminders.fetch(:primary_key_candidate) == :id &&
        reminders.fetch(:indexes).any? { |index| index.fetch(:name) == :status && index.fetch(:fields) == [:status] } &&
        reminders.fetch(:scopes).any? { |scope| scope.fetch(:name) == :open && scope.fetch(:where) == { status: :open } } &&
        wizard_specs.fetch(:columns).any? { |column| column.fetch(:name) == :spec && column.fetch(:portable_type) == :json && column.fetch(:adapter_type_candidate) == :json_document } &&
        tracker_logs.fetch(:history_lowering) == :history_t &&
        tracker_logs.fetch(:append_only) &&
        tracker_logs.fetch(:partition_key_candidate) == :tracker_id
    end

    def persistence_storage_plan_health_contract?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      stable = persistence.storage_plan_health
      drift_plan = persistence.storage_plan_sketch.merge(
        descriptor: persistence.storage_plan_sketch.fetch(:descriptor).merge(schema_changes_allowed: true)
      )
      drift = Contracts::PersistenceStoragePlanHealthContract.evaluate(storage_plan: drift_plan)

      stable.fetch(:status) == :stable &&
        stable.fetch(:check_count) == 17 &&
        stable.fetch(:descriptor).fetch(:kind) == :persistence_storage_plan_health &&
        stable.fetch(:descriptor).fetch(:validates) == :persistence_storage_plan_sketch &&
        stable.fetch(:descriptor).fetch(:gates_runtime) == false &&
        stable.fetch(:descriptor).fetch(:grants_capabilities) == false &&
        stable.fetch(:missing_terms).empty? &&
        stable.fetch(:checks).all? { |check| check.fetch(:present) } &&
        drift.fetch(:status) == :drift &&
        drift.fetch(:missing_terms).include?(:no_schema_changes)
    end

    def persistence_storage_migration_plan_contract?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      current = persistence.storage_migration_plan
      storage_plan = persistence.storage_plan_sketch
      previous_plan = Marshal.load(Marshal.dump(storage_plan))
      previous_article = previous_plan.fetch(:records).fetch(:articles)
      previous_article[:columns] = previous_article.fetch(:columns).reject { |column| column.fetch(:name) == :body }
      synthetic = Contracts::PersistenceStorageMigrationPlanContract.evaluate(
        storage_plan: storage_plan,
        previous_storage_plan: previous_plan
      )
      article_report = synthetic.fetch(:reports).find { |report| report.fetch(:capability) == :articles }
      candidate = article_report.fetch(:candidates).first

      current.fetch(:status) == :stable &&
        current.fetch(:report_count) == 12 &&
        current.fetch(:candidate_count).zero? &&
        current.fetch(:descriptor).fetch(:kind) == :persistence_storage_migration_plan &&
        current.fetch(:descriptor).fetch(:migration_execution_allowed) == false &&
        current.fetch(:descriptor).fetch(:sql_generation_allowed) == false &&
        synthetic.fetch(:status) == :review_required &&
        synthetic.fetch(:candidate_count) == 1 &&
        article_report.fetch(:status) == :additive &&
        candidate.fetch(:kind) == :additive &&
        candidate.fetch(:review_only) &&
        candidate.fetch(:migration_execution_allowed) == false &&
        candidate.fetch(:sql_generation_allowed) == false &&
        candidate.fetch(:added_columns) == [:body]
    end

    def persistence_storage_migration_plan_health_contract?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      stable = persistence.storage_migration_plan_health
      drift_plan = persistence.storage_migration_plan.merge(
        descriptor: persistence.storage_migration_plan.fetch(:descriptor).merge(migration_execution_allowed: true)
      )
      drift = Contracts::PersistenceStorageMigrationPlanHealthContract.evaluate(storage_migration_plan: drift_plan)

      stable.fetch(:status) == :stable &&
        stable.fetch(:check_count) == 15 &&
        stable.fetch(:descriptor).fetch(:kind) == :persistence_storage_migration_plan_health &&
        stable.fetch(:descriptor).fetch(:validates) == :persistence_storage_migration_plan &&
        stable.fetch(:descriptor).fetch(:gates_runtime) == false &&
        stable.fetch(:descriptor).fetch(:grants_capabilities) == false &&
        stable.fetch(:missing_terms).empty? &&
        stable.fetch(:checks).all? { |check| check.fetch(:present) } &&
        drift.fetch(:status) == :drift &&
        drift.fetch(:missing_terms).include?(:no_migration_execution)
    end

    def persistence_field_type_plan_contract?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      plan = persistence.field_type_plan
      articles = plan.fetch(:records).fetch(:articles)
      wizard_specs = plan.fetch(:records).fetch(:wizard_type_specs)
      comments = plan.fetch(:histories).fetch(:comments)
      article_status = articles.fetch(:fields).find { |field| field.fetch(:name) == :status }
      wizard_spec = wizard_specs.fetch(:fields).find { |field| field.fetch(:name) == :spec }

      plan.fetch(:schema_version) == 1 &&
        plan.fetch(:descriptor).fetch(:kind) == :persistence_field_type_plan &&
        plan.fetch(:descriptor).fetch(:report_only) &&
        plan.fetch(:descriptor).fetch(:gates_runtime) == false &&
        plan.fetch(:descriptor).fetch(:grants_capabilities) == false &&
        plan.fetch(:descriptor).fetch(:schema_changes_allowed) == false &&
        plan.fetch(:descriptor).fetch(:sql_generation_allowed) == false &&
        plan.fetch(:descriptor).fetch(:materializer_execution_allowed) == false &&
        plan.fetch(:descriptor).fetch(:preserves) == { persist: :store_t, history: :history_t } &&
        plan.fetch(:status) == :stable &&
        plan.fetch(:issue_count).zero? &&
        plan.fetch(:summary).fetch(:record_shape_count) == 6 &&
        plan.fetch(:summary).fetch(:history_shape_count) == 6 &&
        articles.fetch(:lowering) == :store_t &&
        comments.fetch(:lowering) == :history_t &&
        article_status.fetch(:declared_type) == :enum &&
        article_status.fetch(:enum_values) == %i[draft published archived] &&
        wizard_spec.fetch(:declared_type) == :json &&
        wizard_spec.fetch(:sample_count).positive?
    end

    def persistence_field_type_health_contract?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      stable = persistence.field_type_health
      drift_plan = persistence.field_type_plan.merge(
        descriptor: persistence.field_type_plan.fetch(:descriptor).merge(sql_generation_allowed: true)
      )
      drift = Contracts::PersistenceFieldTypeHealthContract.evaluate(field_type_plan: drift_plan)

      stable.fetch(:status) == :stable &&
        stable.fetch(:check_count) == 18 &&
        stable.fetch(:descriptor).fetch(:kind) == :persistence_field_type_health &&
        stable.fetch(:descriptor).fetch(:validates) == :persistence_field_type_plan &&
        stable.fetch(:descriptor).fetch(:gates_runtime) == false &&
        stable.fetch(:descriptor).fetch(:grants_capabilities) == false &&
        stable.fetch(:missing_terms).empty? &&
        stable.fetch(:checks).all? { |check| check.fetch(:present) } &&
        drift.fetch(:status) == :drift &&
        drift.fetch(:missing_terms).include?(:no_sql_generation)
    end

    def persistence_relation_type_plan_contract?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      plan = persistence.relation_type_plan
      tracker_relation = plan.fetch(:relations).fetch(:tracker_logs_by_tracker)
      comment_relation = plan.fetch(:relations).fetch(:comments_by_article)
      tracker_join = tracker_relation.fetch(:joins).first
      comment_join = comment_relation.fetch(:joins).first

      plan.fetch(:schema_version) == 1 &&
        plan.fetch(:descriptor).fetch(:kind) == :persistence_relation_type_plan &&
        plan.fetch(:descriptor).fetch(:report_only) &&
        plan.fetch(:descriptor).fetch(:gates_runtime) == false &&
        plan.fetch(:descriptor).fetch(:grants_capabilities) == false &&
        plan.fetch(:descriptor).fetch(:relation_enforcement_allowed) == false &&
        plan.fetch(:descriptor).fetch(:foreign_key_generation_allowed) == false &&
        plan.fetch(:descriptor).fetch(:source) == :persistence_field_type_plan &&
        plan.fetch(:descriptor).fetch(:preserves) == { relation: :relation_t, from: :store_t, to: :history_t } &&
        plan.fetch(:status) == :stable &&
        plan.fetch(:issue_count).zero? &&
        plan.fetch(:relation_count) == 2 &&
        tracker_relation.fetch(:lowering) == { shape: :relation, from: :store, to: :history } &&
        tracker_relation.fetch(:enforcement) == { enforced: false, mode: :report_only } &&
        tracker_join.fetch(:from_field) == :id &&
        tracker_join.fetch(:to_field) == :tracker_id &&
        tracker_join.fetch(:compatibility) == :inferred &&
        comment_join.fetch(:from_field) == :id &&
        comment_join.fetch(:to_field) == :article_id &&
        comment_join.fetch(:compatibility) == :inferred
    end

    def persistence_relation_type_health_contract?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      stable = persistence.relation_type_health
      drift_plan = persistence.relation_type_plan.merge(
        descriptor: persistence.relation_type_plan.fetch(:descriptor).merge(foreign_key_generation_allowed: true)
      )
      drift = Contracts::PersistenceRelationTypeHealthContract.evaluate(relation_type_plan: drift_plan)

      stable.fetch(:status) == :stable &&
        stable.fetch(:check_count) == 19 &&
        stable.fetch(:descriptor).fetch(:kind) == :persistence_relation_type_health &&
        stable.fetch(:descriptor).fetch(:validates) == :persistence_relation_type_plan &&
        stable.fetch(:descriptor).fetch(:gates_runtime) == false &&
        stable.fetch(:descriptor).fetch(:grants_capabilities) == false &&
        stable.fetch(:missing_terms).empty? &&
        stable.fetch(:checks).all? { |check| check.fetch(:present) } &&
        drift.fetch(:status) == :drift &&
        drift.fetch(:missing_terms).include?(:no_foreign_key_generation)
    end

    def persistence_access_path_plan_contract?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      plan = persistence.access_path_plan
      reminders = plan.fetch(:records).fetch(:reminders)
      tracker_logs = plan.fetch(:histories).fetch(:tracker_logs)
      tracker_relation = plan.fetch(:relations).fetch(:tracker_logs_by_tracker)
      tracker_projection = plan.fetch(:projections).fetch(:tracker_read_model)

      plan.fetch(:schema_version) == 1 &&
        plan.fetch(:descriptor).fetch(:kind) == :persistence_access_path_plan &&
        plan.fetch(:descriptor).fetch(:report_only) &&
        plan.fetch(:descriptor).fetch(:gates_runtime) == false &&
        plan.fetch(:descriptor).fetch(:grants_capabilities) == false &&
        plan.fetch(:descriptor).fetch(:store_read_node_allowed) == false &&
        plan.fetch(:descriptor).fetch(:runtime_planner_allowed) == false &&
        plan.fetch(:descriptor).fetch(:cache_execution_allowed) == false &&
        plan.fetch(:descriptor).fetch(:source) == { storage: :persistence_storage_plan_sketch, relation_types: :persistence_relation_type_plan } &&
        plan.fetch(:descriptor).fetch(:preserves) == { persist: :store_t, history: :history_t, relation: :relation_t } &&
        plan.fetch(:status) == :sketched &&
        plan.fetch(:path_count) == 43 &&
        reminders.fetch(:paths).any? { |path| path.fetch(:name) == :find && path.fetch(:lookup_kind) == :key && path.fetch(:key_binding) == { field: :id, source: :argument } } &&
        reminders.fetch(:paths).any? { |path| path.fetch(:name) == :scope_open && path.fetch(:lookup_kind) == :scope && path.fetch(:implemented) } &&
        reminders.fetch(:paths).any? { |path| path.fetch(:name) == :index_status && path.fetch(:lookup_kind) == :index && path.fetch(:implemented) == false } &&
        tracker_logs.fetch(:paths).any? { |path| path.fetch(:name) == :partition && path.fetch(:lookup_kind) == :partition && path.fetch(:key_binding) == { field: :tracker_id, source: :criteria } } &&
        tracker_relation.fetch(:paths).first.fetch(:lookup_kind) == :join &&
        tracker_projection.fetch(:reads) == %i[trackers tracker_logs] &&
        tracker_projection.fetch(:reactive_consumer_hint)
    end

    def persistence_access_path_health_contract?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      stable = persistence.access_path_health
      drift_plan = persistence.access_path_plan.merge(
        descriptor: persistence.access_path_plan.fetch(:descriptor).merge(store_read_node_allowed: true)
      )
      drift = Contracts::PersistenceAccessPathHealthContract.evaluate(access_path_plan: drift_plan)

      stable.fetch(:status) == :stable &&
        stable.fetch(:check_count) == 22 &&
        stable.fetch(:descriptor).fetch(:kind) == :persistence_access_path_health &&
        stable.fetch(:descriptor).fetch(:validates) == :persistence_access_path_plan &&
        stable.fetch(:descriptor).fetch(:gates_runtime) == false &&
        stable.fetch(:descriptor).fetch(:grants_capabilities) == false &&
        stable.fetch(:missing_terms).empty? &&
        stable.fetch(:checks).all? { |check| check.fetch(:present) } &&
        drift.fetch(:status) == :drift &&
        drift.fetch(:missing_terms).include?(:no_store_read_node)
    end

    def persistence_effect_intent_plan_contract?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      plan = persistence.effect_intent_plan
      reminder = plan.fetch(:commands).fetch(:reminder_commands)
      tracker_log = plan.fetch(:commands).fetch(:tracker_log_commands)
      reminder_update = reminder.fetch(:intents).find { |intent| intent.fetch(:operation) == :record_update }
      tracker_append = tracker_log.fetch(:intents).find { |intent| intent.fetch(:operation) == :history_append }

      plan.fetch(:schema_version) == 1 &&
        plan.fetch(:descriptor).fetch(:kind) == :persistence_effect_intent_plan &&
        plan.fetch(:descriptor).fetch(:report_only) &&
        plan.fetch(:descriptor).fetch(:gates_runtime) == false &&
        plan.fetch(:descriptor).fetch(:grants_capabilities) == false &&
        plan.fetch(:descriptor).fetch(:store_write_node_allowed) == false &&
        plan.fetch(:descriptor).fetch(:store_append_node_allowed) == false &&
        plan.fetch(:descriptor).fetch(:saga_execution_allowed) == false &&
        plan.fetch(:descriptor).fetch(:app_boundary_required) &&
        plan.fetch(:descriptor).fetch(:source) == { commands: :operation_manifest, access_paths: :persistence_access_path_plan } &&
        plan.fetch(:descriptor).fetch(:preserves) == { persist: :store_t, history: :history_t, command: :mutation_intent } &&
        plan.fetch(:status) == :sketched &&
        plan.fetch(:intent_count) == 11 &&
        reminder.fetch(:target) == :reminders &&
        reminder_update.fetch(:effect) == :store_write &&
        reminder_update.fetch(:write_kind) == :update &&
        reminder_update.fetch(:lowering) == :store_t &&
        reminder_update.fetch(:command_still_lowers_to) == :mutation_intent &&
        reminder_update.fetch(:access_path_source).fetch(:present) &&
        tracker_append.fetch(:effect) == :store_append &&
        tracker_append.fetch(:write_kind) == :append &&
        tracker_append.fetch(:lowering) == :history_t &&
        tracker_append.fetch(:access_path_source).fetch(:present)
    end

    def persistence_effect_intent_health_contract?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      stable = persistence.effect_intent_health
      drift_plan = persistence.effect_intent_plan.merge(
        descriptor: persistence.effect_intent_plan.fetch(:descriptor).merge(store_write_node_allowed: true)
      )
      drift = Contracts::PersistenceEffectIntentHealthContract.evaluate(effect_intent_plan: drift_plan)

      stable.fetch(:status) == :stable &&
        stable.fetch(:check_count) == 24 &&
        stable.fetch(:descriptor).fetch(:kind) == :persistence_effect_intent_health &&
        stable.fetch(:descriptor).fetch(:validates) == :persistence_effect_intent_plan &&
        stable.fetch(:descriptor).fetch(:gates_runtime) == false &&
        stable.fetch(:descriptor).fetch(:grants_capabilities) == false &&
        stable.fetch(:missing_terms).empty? &&
        stable.fetch(:checks).all? { |check| check.fetch(:present) } &&
        drift.fetch(:status) == :drift &&
        drift.fetch(:missing_terms).include?(:no_store_write_node)
    end

    def store_convergence_sidecar_contract?
      packet = Services::StoreConvergenceSidecar.packet
      descriptor = packet.fetch(:descriptor)
      record = packet.fetch(:record)
      history = packet.fetch(:history)
      pressure = packet.fetch(:pressure)

      packet.fetch(:schema_version) == 1 &&
        descriptor.fetch(:kind) == :store_convergence_sidecar &&
        descriptor.fetch(:report_only) &&
        descriptor.fetch(:gates_runtime) == false &&
        descriptor.fetch(:grants_capabilities) == false &&
        descriptor.fetch(:replaces_app_backend) == false &&
        descriptor.fetch(:mutates_main_state) == false &&
        descriptor.fetch(:package_facade) == :"igniter-companion" &&
        descriptor.fetch(:substrate) == :"igniter-store" &&
        descriptor.fetch(:preserves) == { persist: :store_t, history: :history_t, command: :mutation_intent } &&
        packet.fetch(:status) == :stable &&
        packet.fetch(:checks).length == 19 &&
        packet.fetch(:checks).all? { |check| check.fetch(:present) } &&
        record.fetch(:generated_from_manifest) &&
        history.fetch(:generated_from_manifest) &&
        record.fetch(:current_status) == :done &&
        record.fetch(:past_status) == :open &&
        record.fetch(:open_before_count) == 1 &&
        record.fetch(:open_after_count).zero? &&
        record.fetch(:causation_count) == 2 &&
        record.fetch(:write_receipt_intent) == :record_write &&
        record.fetch(:write_receipt_fact_id_present) &&
        record.fetch(:write_receipt_delegates) &&
        history.fetch(:replay_count) == 3 &&
        history.fetch(:values) == [7.0, 8.5] &&
        history.fetch(:event_fact_ids).all? &&
        history.fetch(:partition_key_declared) == :tracker_id &&
        history.fetch(:append_receipt_intent) == :history_append &&
        history.fetch(:partition_query_supported) &&
        history.fetch(:partition_replay_count) == 2 &&
        history.fetch(:partition_replay_values) == [7.0, 8.5] &&
        pressure.fetch(:next_question) == :manifest_generated_record_history_classes
    end

    def persistence_relation_manifest?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      manifest = persistence.manifest_snapshot
      relation = manifest.fetch(:relations).fetch(:tracker_logs_by_tracker)
      article_relation = manifest.fetch(:relations).fetch(:comments_by_article)
      descriptor = relation.fetch(:descriptor)
      article_descriptor = article_relation.fetch(:descriptor)

      persistence.valid? &&
        relation.fetch(:schema_version) == 1 &&
        relation.fetch(:kind) == :event_owner &&
        relation.fetch(:from) == :trackers &&
        relation.fetch(:to) == :tracker_logs &&
        relation.fetch(:join) == { id: :tracker_id } &&
        relation.fetch(:cardinality) == :one_to_many &&
        relation.fetch(:projection) == :tracker_read_model &&
        relation.fetch(:enforced) == false &&
        descriptor.fetch(:kind) == :relation &&
        descriptor.fetch(:edge) == :event_owner &&
        descriptor.fetch(:from) == { capability: :trackers, storage_shape: :store } &&
        descriptor.fetch(:to) == { capability: :tracker_logs, storage_shape: :history } &&
        descriptor.fetch(:enforcement) == { enforced: false, mode: :report_only } &&
        descriptor.fetch(:lowering) == { shape: :relation, from: :store, to: :history } &&
        article_relation.fetch(:from) == :articles &&
        article_relation.fetch(:to) == :comments &&
        article_relation.fetch(:join) == { id: :article_id } &&
        article_relation.fetch(:enforced) == false &&
        article_descriptor.fetch(:from).fetch(:storage_shape) == :store &&
        article_descriptor.fetch(:to).fetch(:storage_shape) == :history &&
        article_descriptor.fetch(:enforcement).fetch(:mode) == :report_only
    end

    def projection_relation_manifest?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      projection = persistence.manifest_snapshot.fetch(:projections).fetch(:tracker_read_model)

      persistence.valid? &&
        projection.fetch(:reads) == %i[trackers tracker_logs] &&
        projection.fetch(:relations) == %i[tracker_logs_by_tracker]
    end

    def relation_health_warning?
      clean = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      orphaned_state = Services::CompanionState.seeded
      orphaned_state.tracker_logs << Services::CompanionState::TrackerLog.new(
        tracker_id: "ghost-tracker",
        date: Date.today.iso8601,
        value: "7"
      )
      orphaned = Services::CompanionPersistence.new(state: orphaned_state)
      readiness = orphaned.readiness
      warning = readiness.fetch(:warnings).first

      clean.relation_warnings.fetch(:tracker_logs_by_tracker).empty? &&
        orphaned.relation_health.fetch(:status) == :warning &&
        orphaned.relation_health.fetch(:relation_reports).fetch(:tracker_logs_by_tracker).fetch(:warning_count) == 1 &&
        readiness.fetch(:ready) &&
        readiness.fetch(:warning_count) == 1 &&
        warning.fetch(:relation) == :tracker_logs_by_tracker &&
        warning.fetch(:kind) == :missing_source &&
        warning.fetch(:values) == ["ghost-tracker"]
    end

    def setup_health_contract?
      clean = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      orphaned_state = Services::CompanionState.seeded
      orphaned_state.tracker_logs << Services::CompanionState::TrackerLog.new(
        tracker_id: "ghost-tracker",
        date: Date.today.iso8601,
        value: "7"
      )
      warning = Services::CompanionPersistence.new(state: orphaned_state).setup_health
      stable = clean.setup_health

      stable.fetch(:status) == :stable &&
        stable.fetch(:descriptor).fetch(:schema_version) == 1 &&
        stable.fetch(:descriptor).fetch(:kind) == :setup_health &&
        stable.fetch(:descriptor).fetch(:report_only) &&
        stable.fetch(:descriptor).fetch(:gates_runtime) == false &&
        stable.fetch(:descriptor).fetch(:grants_capabilities) == false &&
        stable.fetch(:descriptor).fetch(:sources).include?(:materializer_status_descriptor_health) &&
        stable.fetch(:descriptor).fetch(:review_item_policy) == :diagnostic_only &&
        stable.fetch(:check_count) == 5 &&
        stable.fetch(:review_count).zero? &&
        stable.fetch(:checks).all? { |check| check.fetch(:present) } &&
        stable.fetch(:summary).include?("report-only") &&
        warning.fetch(:status) == :needs_review &&
        warning.fetch(:review_items).any? { |item| item.fetch(:kind) == :relation_warning && item.fetch(:count) == 1 }
    end

    def setup_handoff_contract?
      handoff = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).setup_handoff

      handoff.fetch(:status) == :stable &&
        handoff.fetch(:descriptor).fetch(:schema_version) == 1 &&
        handoff.fetch(:descriptor).fetch(:kind) == :setup_handoff &&
        handoff.fetch(:descriptor).fetch(:report_only) &&
        handoff.fetch(:descriptor).fetch(:gates_runtime) == false &&
        handoff.fetch(:descriptor).fetch(:grants_capabilities) == false &&
        handoff.fetch(:descriptor).fetch(:purpose) == :context_rotation &&
        handoff.fetch(:reading_order).include?("/setup/health.json") &&
        handoff.fetch(:reading_order).include?("/setup/handoff/digest.json") &&
        handoff.fetch(:reading_order).include?("/setup/handoff/digest.txt") &&
        handoff.fetch(:reading_order).include?("/setup/handoff/next-scope.json") &&
        handoff.fetch(:reading_order).include?("/setup/handoff/next-scope-health.json") &&
        handoff.fetch(:reading_order).include?("/setup/handoff/promotion-readiness.json") &&
        handoff.fetch(:reading_order).include?("/setup/handoff/extraction-sketch.json") &&
        handoff.fetch(:reading_order).include?("/setup/handoff/packet-registry.json") &&
        handoff.fetch(:reading_order).include?("/setup/handoff/supervision.json") &&
        handoff.fetch(:reading_order).include?("/setup/handoff/lifecycle.json") &&
        handoff.fetch(:reading_order).include?("/setup/handoff/lifecycle-health.json") &&
        handoff.fetch(:reading_order).include?("/setup/handoff/acceptance.json") &&
        handoff.fetch(:reading_order).include?("/setup/handoff/approval-acceptance.json") &&
        handoff.fetch(:document_rotation).fetch(:public).include?("docs/research/companion-current-status-summary.md") &&
        handoff.fetch(:document_rotation).fetch(:private).include?("playgrounds/docs/dev/tracks/contract-persistence-capability-track.md") &&
        handoff.fetch(:document_rotation).fetch(:policy) == :compact_current_state_first &&
        handoff.fetch(:architecture_constraints).fetch(:scope) == :app_local_companion_proof &&
        handoff.fetch(:architecture_constraints).fetch(:public_api_promise) == false &&
        handoff.fetch(:architecture_constraints).fetch(:materializer_execution) == false &&
        handoff.fetch(:architecture_constraints).fetch(:relation_enforcement) == :report_only &&
        handoff.fetch(:architecture_constraints).fetch(:lowerings).fetch(:persist) == :store_t &&
        handoff.fetch(:current_state).fetch(:capabilities) == 17 &&
        handoff.fetch(:current_state).fetch(:materializer_grants_capabilities) == false &&
        handoff.fetch(:next_scope).fetch(:policy) == :small_reversible_app_local_slice &&
        handoff.fetch(:next_scope).fetch(:recommended) == :record_blocked_materializer_attempt &&
        handoff.fetch(:next_scope).fetch(:forbidden).include?(:public_api_promotion) &&
        handoff.fetch(:acceptance_criteria).fetch(:recommended) == :record_blocked_materializer_attempt &&
        handoff.fetch(:acceptance_criteria).fetch(:expected_result) == :materializer_supervision_awaits_explicit_approval_record &&
        handoff.fetch(:acceptance_criteria).fetch(:proof_markers).include?(:companion_poc_materializer_attempt_record_route) &&
        handoff.fetch(:acceptance_criteria).fetch(:follow_up).fetch(:recommended) == :record_materializer_approval_receipt &&
        handoff.fetch(:acceptance_criteria).fetch(:non_goals).include?(:materializer_execution) &&
        handoff.fetch(:next_action) == :record_blocked_attempt
    end

    def setup_handoff_acceptance_contract?
      db_path = File.join(Dir.mktmpdir("igniter-companion-handoff-acceptance"), "companion.sqlite3")
      config = Companion.default_configuration(store_path: db_path)
      app = Companion.build(config: config)
      store = app.service(:companion)
      pending = store.setup_handoff_acceptance
      record_status, record_headers = post(app, "/setup/handoff/acceptance/record")
      recorded_status = get_status(app, record_headers.fetch("location"))
      satisfied = store.setup_handoff_acceptance

      pending.fetch(:status) == :pending &&
        pending.fetch(:descriptor).fetch(:kind) == :setup_handoff_acceptance &&
        pending.fetch(:missing_terms).include?(:explicit_attempt_recorded) &&
        pending.fetch(:missing_terms).include?(:expected_phase) &&
        record_status == 303 &&
        record_headers.fetch("location").start_with?("/setup/handoff/acceptance") &&
        recorded_status == 200 &&
        satisfied.fetch(:status) == :satisfied &&
        satisfied.fetch(:missing_terms).empty? &&
        satisfied.fetch(:checks).all? { |check| check.fetch(:present) } &&
        satisfied.fetch(:descriptor).fetch(:gates_runtime) == false &&
        satisfied.fetch(:descriptor).fetch(:grants_capabilities) == false
    end

    def setup_handoff_approval_acceptance_contract?
      db_path = File.join(Dir.mktmpdir("igniter-companion-handoff-approval-acceptance"), "companion.sqlite3")
      config = Companion.default_configuration(store_path: db_path)
      app = Companion.build(config: config)
      store = app.service(:companion)
      pending = store.setup_handoff_approval_acceptance
      attempt_status, _attempt_headers = post(app, "/setup/handoff/acceptance/record")
      after_attempt = store.setup_handoff_approval_acceptance
      approval_status, approval_headers = post(app, "/setup/handoff/approval-acceptance/record")
      recorded_status = get_status(app, approval_headers.fetch("location"))
      satisfied = store.setup_handoff_approval_acceptance

      pending.fetch(:status) == :pending &&
        pending.fetch(:descriptor).fetch(:kind) == :setup_handoff_approval_acceptance &&
        pending.fetch(:missing_terms).include?(:explicit_attempt_recorded) &&
        pending.fetch(:missing_terms).include?(:explicit_approval_recorded) &&
        attempt_status == 303 &&
        after_attempt.fetch(:missing_terms).include?(:explicit_approval_recorded) &&
        approval_status == 303 &&
        approval_headers.fetch("location").start_with?("/setup/handoff/approval-acceptance") &&
        recorded_status == 200 &&
        satisfied.fetch(:status) == :satisfied &&
        satisfied.fetch(:missing_terms).empty? &&
        satisfied.fetch(:checks).all? { |check| check.fetch(:present) } &&
        satisfied.fetch(:descriptor).fetch(:gates_runtime) == false &&
        satisfied.fetch(:descriptor).fetch(:grants_capabilities) == false
    end

    def setup_handoff_lifecycle_contract?
      db_path = File.join(Dir.mktmpdir("igniter-companion-handoff-lifecycle"), "companion.sqlite3")
      config = Companion.default_configuration(store_path: db_path)
      app = Companion.build(config: config)
      store = app.service(:companion)
      pending = store.setup_handoff_lifecycle
      attempt_status, _attempt_headers = post(app, "/setup/handoff/acceptance/record")
      after_attempt = store.setup_handoff_lifecycle
      approval_status, _approval_headers = post(app, "/setup/handoff/approval-acceptance/record")
      complete = store.setup_handoff_lifecycle

      pending.fetch(:status) == :pending &&
        pending.fetch(:descriptor).fetch(:kind) == :setup_handoff_lifecycle &&
        pending.fetch(:descriptor).fetch(:gates_runtime) == false &&
        pending.fetch(:descriptor).fetch(:grants_capabilities) == false &&
        pending.fetch(:current_stage) == :attempt_receipt &&
        pending.fetch(:next_action) == :record_blocked_attempt &&
        attempt_status == 303 &&
        after_attempt.fetch(:status) == :pending &&
        after_attempt.fetch(:current_stage) == :approval_receipt &&
        after_attempt.fetch(:next_action) == :record_approval_receipt &&
        approval_status == 303 &&
        complete.fetch(:status) == :complete &&
        complete.fetch(:current_stage) == :complete &&
        complete.fetch(:next_action) == :review_materializer_status &&
        complete.fetch(:stages).all? { |stage| stage.fetch(:complete) }
    end

    def setup_handoff_lifecycle_health_contract?
      db_path = File.join(Dir.mktmpdir("igniter-companion-handoff-lifecycle-health"), "companion.sqlite3")
      config = Companion.default_configuration(store_path: db_path)
      app = Companion.build(config: config)
      store = app.service(:companion)
      stable = store.setup_handoff_lifecycle_health
      post(app, "/setup/handoff/acceptance/record")
      after_attempt = store.setup_handoff_lifecycle_health
      post(app, "/setup/handoff/approval-acceptance/record")
      complete = store.setup_handoff_lifecycle_health

      stable.fetch(:status) == :stable &&
        stable.fetch(:check_count) == 11 &&
        stable.fetch(:descriptor).fetch(:kind) == :setup_handoff_lifecycle_health &&
        stable.fetch(:descriptor).fetch(:gates_runtime) == false &&
        stable.fetch(:descriptor).fetch(:grants_capabilities) == false &&
        stable.fetch(:missing_terms).empty? &&
        after_attempt.fetch(:status) == :stable &&
        complete.fetch(:status) == :stable &&
        complete.fetch(:checks).all? { |check| check.fetch(:present) }
    end

    def setup_handoff_supervision_contract?
      db_path = File.join(Dir.mktmpdir("igniter-companion-handoff-supervision"), "companion.sqlite3")
      config = Companion.default_configuration(store_path: db_path)
      app = Companion.build(config: config)
      store = app.service(:companion)
      pending = store.setup_handoff_supervision
      post(app, "/setup/handoff/acceptance/record")
      after_attempt = store.setup_handoff_supervision
      post(app, "/setup/handoff/approval-acceptance/record")
      complete = store.setup_handoff_supervision

      pending.fetch(:status) == :pending &&
        pending.fetch(:descriptor).fetch(:kind) == :setup_handoff_supervision &&
        pending.fetch(:descriptor).fetch(:gates_runtime) == false &&
        pending.fetch(:descriptor).fetch(:grants_capabilities) == false &&
        pending.fetch(:signals).fetch(:setup_stable) &&
        pending.fetch(:signals).fetch(:lifecycle_health_stable) &&
        pending.fetch(:signals).fetch(:materializer_grants_capabilities) == false &&
        pending.fetch(:signals).fetch(:materializer_execution_allowed) == false &&
        pending.fetch(:next_action) == :record_blocked_attempt &&
        after_attempt.fetch(:status) == :pending &&
        after_attempt.fetch(:next_action) == :record_approval_receipt &&
        complete.fetch(:status) == :complete &&
        complete.fetch(:next_action) == :review_materializer_status
    end

    def setup_handoff_packet_registry_contract?
      registry = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).setup_handoff_packet_registry

      registry.fetch(:status) == :stable &&
        registry.fetch(:descriptor).fetch(:kind) == :setup_handoff_packet_registry &&
        registry.fetch(:descriptor).fetch(:gates_runtime) == false &&
        registry.fetch(:descriptor).fetch(:grants_capabilities) == false &&
        registry.fetch(:packets).length == 10 &&
        registry.fetch(:packets).all? { |packet| packet.fetch(:report_only) && packet.fetch(:gates_runtime) == false && packet.fetch(:grants_capabilities) == false } &&
        registry.fetch(:read_order).include?("/setup/handoff/next-scope.json") &&
        registry.fetch(:read_order).include?("/setup/handoff/next-scope-health.json") &&
        registry.fetch(:read_order).include?("/setup/handoff/supervision.json") &&
        registry.fetch(:mutation_paths) == [
          "POST /setup/handoff/acceptance/record",
          "POST /setup/handoff/approval-acceptance/record"
        ] &&
        registry.fetch(:summary).include?("10 setup packets")
    end

    def setup_handoff_next_scope_contract?
      db_path = File.join(Dir.mktmpdir("igniter-companion-handoff-next-scope"), "companion.sqlite3")
      config = Companion.default_configuration(store_path: db_path)
      app = Companion.build(config: config)
      store = app.service(:companion)
      pending = store.setup_handoff_next_scope
      post(app, "/setup/handoff/acceptance/record")
      after_attempt = store.setup_handoff_next_scope
      post(app, "/setup/handoff/approval-acceptance/record")
      complete = store.setup_handoff_next_scope

      pending.fetch(:status) == :pending &&
        pending.fetch(:descriptor).fetch(:kind) == :setup_handoff_next_scope &&
        pending.fetch(:descriptor).fetch(:gates_runtime) == false &&
        pending.fetch(:descriptor).fetch(:grants_capabilities) == false &&
        pending.fetch(:recommended) == :record_blocked_materializer_attempt &&
        pending.fetch(:forbidden).include?(:public_api_promotion) &&
        pending.fetch(:acceptance_criteria).fetch(:recommended) == :record_blocked_materializer_attempt &&
        pending.fetch(:mutation_paths).include?("POST /setup/materializer-attempts/record") &&
        pending.fetch(:mutation_paths).include?("POST /setup/handoff/approval-acceptance/record") &&
        pending.fetch(:next_action) == :record_blocked_attempt &&
        after_attempt.fetch(:status) == :pending &&
        after_attempt.fetch(:next_action) == :record_approval_receipt &&
        complete.fetch(:status) == :complete &&
        complete.fetch(:next_action) == :review_materializer_status
    end

    def setup_handoff_next_scope_health_contract?
      db_path = File.join(Dir.mktmpdir("igniter-companion-handoff-next-scope-health"), "companion.sqlite3")
      config = Companion.default_configuration(store_path: db_path)
      app = Companion.build(config: config)
      store = app.service(:companion)
      stable = store.setup_handoff_next_scope_health
      post(app, "/setup/handoff/acceptance/record")
      after_attempt = store.setup_handoff_next_scope_health
      post(app, "/setup/handoff/approval-acceptance/record")
      complete = store.setup_handoff_next_scope_health

      stable.fetch(:status) == :stable &&
        stable.fetch(:check_count) == 15 &&
        stable.fetch(:descriptor).fetch(:kind) == :setup_handoff_next_scope_health &&
        stable.fetch(:descriptor).fetch(:validates) == :setup_handoff_next_scope &&
        stable.fetch(:descriptor).fetch(:gates_runtime) == false &&
        stable.fetch(:descriptor).fetch(:grants_capabilities) == false &&
        stable.fetch(:missing_terms).empty? &&
        after_attempt.fetch(:status) == :stable &&
        complete.fetch(:status) == :stable &&
        complete.fetch(:checks).all? { |check| check.fetch(:present) }
    end

    def setup_handoff_extraction_sketch_contract?
      sketch = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).setup_handoff_extraction_sketch

      sketch.fetch(:status) == :sketched &&
        sketch.fetch(:descriptor).fetch(:kind) == :setup_handoff_extraction_sketch &&
        sketch.fetch(:descriptor).fetch(:package_promise) == false &&
        sketch.fetch(:descriptor).fetch(:gates_runtime) == false &&
        sketch.fetch(:descriptor).fetch(:grants_capabilities) == false &&
        sketch.fetch(:placements).fetch(:companion_app_local).include?(:setup_handoff_packet_registry) &&
        sketch.fetch(:placements).fetch(:igniter_extensions_candidate).include?(:store_history_relation_descriptors) &&
        sketch.fetch(:placements).fetch(:igniter_application_candidate).include?(:explicit_app_boundary_writes) &&
        sketch.fetch(:placements).fetch(:future_igniter_persistence_candidate).include?(:adapter_contract) &&
        sketch.fetch(:constraints).fetch(:current_scope) == :companion_app_local &&
        sketch.fetch(:constraints).fetch(:package_split_now) == false &&
        sketch.fetch(:constraints).fetch(:forbidden_names).include?(:igniter_data) &&
        sketch.fetch(:constraints).fetch(:reserved_future_name) == :igniter_persistence &&
        sketch.fetch(:next_action) == :keep_companion_app_local
    end

    def setup_handoff_promotion_readiness_contract?
      readiness = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).setup_handoff_promotion_readiness

      readiness.fetch(:status) == :blocked &&
        readiness.fetch(:descriptor).fetch(:kind) == :setup_handoff_promotion_readiness &&
        readiness.fetch(:descriptor).fetch(:gates_runtime) == false &&
        readiness.fetch(:descriptor).fetch(:grants_capabilities) == false &&
        readiness.fetch(:blockers).include?(:single_app_pressure_only) &&
        readiness.fetch(:blockers).include?(:public_api_not_promised) &&
        readiness.fetch(:blockers).include?(:package_split_disabled) &&
        readiness.fetch(:blockers).include?(:packet_surface_report_only) &&
        readiness.fetch(:allowed_next_steps).include?(:keep_companion_app_local) &&
        readiness.fetch(:allowed_next_steps).include?(:repeat_pressure_in_another_app) &&
        readiness.fetch(:summary).include?("promotion blockers")
    end

    def setup_handoff_digest_contract?
      digest = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).setup_handoff_digest

      digest.fetch(:status) == :pending &&
        digest.fetch(:descriptor).fetch(:kind) == :setup_handoff_digest &&
        digest.fetch(:descriptor).fetch(:gates_runtime) == false &&
        digest.fetch(:descriptor).fetch(:grants_capabilities) == false &&
        digest.fetch(:highlights).fetch(:lifecycle_stage) == :attempt_receipt &&
        digest.fetch(:highlights).fetch(:next_action) == :record_blocked_attempt &&
        digest.fetch(:highlights).fetch(:promotion_status) == :blocked &&
        digest.fetch(:highlights).fetch(:package_promise) == false &&
        digest.fetch(:next_reads).include?("/setup/handoff/supervision.json") &&
        digest.fetch(:diagram).include?("Companion app-local proof") &&
        digest.fetch(:diagram).include?("promotion: blocked")
    end

    def relation_health_dashboard?(html)
      html.include?('data-relation-health-status="clear"') &&
        html.include?('data-relation-warning-count="0"') &&
        html.include?("relations clear")
    end

    def materializer_dashboard?(html)
      html.include?('data-capsule="materializer"') &&
        html.include?('data-materializer-status="blocked"') &&
        html.include?('data-materializer-phase="awaiting_explicit_attempt_record"') &&
        html.include?('data-materializer-next-action="record_blocked_attempt"') &&
        html.include?('data-materializer-applied-count="0"') &&
        html.include?('data-materializer-audit="true"') &&
        !html.include?('data-action="execute-materializer"')
    end

    def persistence_metadata_manifest?
      manifest = Contracts::Reminder.persistence_manifest
      api = Services::ContractRecordSet.new(
        contract_class: Contracts::Reminder,
        collection: [],
        record_class: Services::CompanionState::Reminder
      ).api_manifest
      command_mutation = Contracts::ReminderContract.evaluate(
        operation: :complete,
        id: "morning-water",
        title: nil,
        reminders: [Services::CompanionState::Reminder.new(id: "morning-water", title: "Water", due: "morning", status: :open)]
      ).fetch(:mutation)

      manifest.fetch(:indexes).any? { |index| index.fetch(:name) == :status } &&
        manifest.fetch(:scopes).any? { |scope| scope.fetch(:name) == :open && scope.fetch(:attributes).fetch(:where) == { status: :open } } &&
        manifest.fetch(:commands).any? { |command| command.fetch(:name) == :complete && command.fetch(:attributes).fetch(:operation) == :record_update } &&
        api.fetch(:indexes).any? { |index| index.fetch(:name) == :status } &&
        api.fetch(:scopes).any? { |scope| scope.fetch(:name) == :open } &&
        api.fetch(:commands).any? { |command| command.fetch(:name) == :complete } &&
        command_mutation.fetch(:operation) == :record_update
    end

    def user_defined_article_contract?
      article_manifest = Contracts::Article.persistence_manifest
      comment_manifest = Contracts::Comment.persistence_manifest
      api = Services::ContractRecordSet.new(
        contract_class: Contracts::Article,
        collection: [],
        record_class: Services::CompanionState::Article
      ).api_manifest
      comments = Services::ContractHistory.new(
        contract_class: Contracts::Comment,
        entries: -> { [] },
        append: ->(event) { event }
      ).api_manifest
      article = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).articles.find("welcome-note")

      article_manifest.fetch(:persist).fetch(:key) == :id &&
        article_manifest.fetch(:fields).any? { |field| field.fetch(:name) == :status && field.fetch(:attributes).fetch(:default) == :draft } &&
        article_manifest.fetch(:fields).any? { |field| field.fetch(:name) == :status && field.fetch(:attributes).fetch(:type) == :enum } &&
        article_manifest.fetch(:commands).any? { |command| command.fetch(:name) == :publish && command.fetch(:attributes).fetch(:changes) == { status: :published } } &&
        comment_manifest.fetch(:history).fetch(:key) == :index &&
        comment_manifest.fetch(:fields).any? { |field| field.fetch(:name) == :article_id } &&
        api.fetch(:scopes).any? { |scope| scope.fetch(:name) == :drafts } &&
        comments.fetch(:operations) == %i[append all where count] &&
        article.status == :draft
    end

    def wizard_type_spec_store?
      manifest = Contracts::WizardTypeSpec.persistence_manifest
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      record = persistence.wizard_type_specs.find("article-comment")
      api = persistence.manifest_snapshot.fetch(:records).fetch(:wizard_type_specs)

      manifest.fetch(:persist).fetch(:key) == :id &&
        manifest.fetch(:fields).any? { |field| field.fetch(:name) == :spec && field.fetch(:attributes).fetch(:type) == :json } &&
        api.fetch(:fields) == %i[id contract spec] &&
        record.contract == "Article" &&
        record.spec.fetch(:schema_version) == 1 &&
        record.spec.fetch(:id) == "article-comment" &&
        record.spec.fetch(:storage).fetch(:shape) == :store &&
        record.spec.fetch(:name) == :Article &&
        record.spec.fetch(:histories).first.fetch(:relation).fetch(:name) == :comments_by_article &&
        persistence.materialization_plan.fetch(:record_contract).fetch(:contract) == record.spec.fetch(:name)
    end

    def wizard_type_spec_history?
      manifest = Contracts::WizardTypeSpecChange.persistence_manifest
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      changes = persistence.wizard_type_spec_changes.all

      manifest.fetch(:history).fetch(:key) == :index &&
        manifest.fetch(:fields).any? { |field| field.fetch(:name) == :spec && field.fetch(:attributes).fetch(:type) == :json } &&
        changes.any? { |change| change.fetch(:spec_id) == "article-comment" && change.fetch(:change_kind) == :seeded_static_sync } &&
        changes.first.fetch(:spec).fetch(:schema_version) == 1 &&
        changes.first.fetch(:spec).fetch(:name) == :Article
    end

    def wizard_type_spec_export?
      export = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).wizard_type_spec_export

      export.fetch(:schema_versions) == [1] &&
        export.fetch(:dev_config).fetch(:compressed) == false &&
        export.fetch(:dev_config).fetch(:history).any? &&
        export.fetch(:prod_config).fetch(:compressed) &&
        export.fetch(:prod_config).fetch(:history).empty? &&
        export.fetch(:prod_config).fetch(:specs).length == export.fetch(:dev_config).fetch(:specs).length
    end

    def wizard_type_spec_migration_plan?
      current = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).wizard_type_spec_migration_plan
      current_spec = Services::CompanionState.article_comment_type_spec
      previous_spec = current_spec.merge(
        fields: current_spec.fetch(:fields).reject { |field| field.fetch(:name) == :body }
      )
      synthetic = Contracts::WizardTypeSpecMigrationPlanContract.evaluate(
        spec_history: [
          {
            index: 0,
            spec_id: "article-comment",
            contract: "Article",
            change_kind: :wizard_edit,
            spec: previous_spec,
            created_at: "2026-04-28"
          },
          {
            index: 1,
            spec_id: "article-comment",
            contract: "Article",
            change_kind: :wizard_edit,
            spec: current_spec,
            created_at: "2026-04-29"
          }
        ]
      )
      candidate = synthetic.fetch(:reports).first.fetch(:candidates).first

      current.fetch(:status) == :stable &&
        current.fetch(:candidate_count).zero? &&
        synthetic.fetch(:status) == :review_required &&
        candidate.fetch(:kind) == :additive &&
        candidate.fetch(:review_only) &&
        candidate.fetch(:added_fields) == [:body]
    end

    def infrastructure_loop_health?
      health = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).infrastructure_loop_health

      health.fetch(:status) == :self_supporting &&
        health.fetch(:signals).values.all? &&
        health.fetch(:loop_state).fetch(:schema_version) == 1 &&
        health.fetch(:loop_state).fetch(:checked_capabilities) == %i[articles comments comments_by_article] &&
        health.fetch(:loop_state).fetch(:write_capability_requested) == false &&
        health.fetch(:summary).include?("no write capability requested")
    end

    def materializer_gate?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      blocked = persistence.materializer_gate
      approved = persistence.materializer_gate(approved: true)

      blocked.fetch(:status) == :blocked &&
        blocked.fetch(:reasons) == %i[human_approval_required] &&
        blocked.fetch(:approved_capabilities).empty? &&
        blocked.fetch(:blocked_capabilities) == %i[write git test restart] &&
        blocked.fetch(:approval_request).fetch(:contract) == :Article &&
        blocked.fetch(:approval_request).fetch(:review_only) &&
        approved.fetch(:status) == :ready_to_request_capabilities &&
        approved.fetch(:approval_request).fetch(:requested_capabilities) == %i[write git test restart] &&
        approved.fetch(:approved_capabilities) == %i[write git test restart]
    end

    def materializer_preflight?
      preflight = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).materializer_preflight

      preflight.fetch(:status) == :blocked_until_approval &&
        preflight.fetch(:checklist).values.all? &&
        preflight.fetch(:evidence).fetch(:blocked_capabilities) == %i[write git test restart] &&
        preflight.fetch(:evidence).fetch(:reasons) == %i[human_approval_required] &&
        preflight.fetch(:approval_request).fetch(:kind) == :materializer_capability_request &&
        preflight.fetch(:summary).include?("review-only")
    end

    def materializer_runbook?
      runbook = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).materializer_runbook
      steps = runbook.fetch(:steps)

      runbook.fetch(:status) == :blocked_until_approval &&
        runbook.fetch(:blocked_capabilities) == %i[write git test restart] &&
        runbook.fetch(:approval_request).fetch(:kind) == :materializer_capability_request &&
        steps.length == 4 &&
        steps.all? { |step| step.fetch(:status) == :blocked && step.fetch(:review_only) } &&
        steps.map { |step| step.fetch(:capability) }.sort == %i[git restart test write]
    end

    def materializer_receipt?
      receipt = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).materializer_receipt
      body = receipt.fetch(:receipt)

      receipt.fetch(:status) == :blocked &&
        body.fetch(:kind) == :materializer_runbook_receipt &&
        body.fetch(:blocked_capabilities) == %i[write git test restart] &&
        body.fetch(:blocked_step_count) == 4 &&
        body.fetch(:executed) == false &&
        body.fetch(:review_only) &&
        receipt.fetch(:events).length == 4 &&
        receipt.fetch(:events).all? { |event| event.fetch(:kind) == :materializer_step_blocked && event.fetch(:executed) == false }
    end

    def materializer_attempt_history?
      manifest = Contracts::MaterializerAttempt.persistence_manifest
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      receipt = persistence.materializer_receipt.fetch(:receipt)
      attempts = persistence.materializer_attempts
      appended = attempts.append(
        index: 0,
        kind: receipt.fetch(:kind),
        status: receipt.fetch(:status),
        approval_request: receipt.fetch(:approval_request),
        blocked_capabilities: receipt.fetch(:blocked_capabilities),
        blocked_step_count: receipt.fetch(:blocked_step_count),
        executed: receipt.fetch(:executed),
        review_only: receipt.fetch(:review_only)
      )

      manifest.fetch(:history).fetch(:key) == :index &&
        manifest.fetch(:fields).any? { |field| field.fetch(:name) == :approval_request && field.fetch(:attributes).fetch(:type) == :json } &&
        manifest.fetch(:fields).any? { |field| field.fetch(:name) == :blocked_capabilities && field.fetch(:attributes).fetch(:type) == :json } &&
        appended.fetch(:index).zero? &&
        attempts.count(status: :blocked) == 1 &&
        attempts.where(kind: :materializer_runbook_receipt).first.fetch(:executed) == false
    end

    def materializer_attempt_command?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      command = persistence.materializer_attempt_command
      mutation = command.fetch(:mutation)
      event = mutation.fetch(:event)

      command.fetch(:result).fetch(:success) &&
        command.fetch(:result).fetch(:feedback_code) == :materializer_attempt_recordable &&
        mutation.fetch(:operation) == :history_append &&
        mutation.fetch(:target) == :materializer_attempts &&
        event.fetch(:kind) == :materializer_runbook_receipt &&
        event.fetch(:status) == :blocked &&
        event.fetch(:executed) == false &&
        event.fetch(:review_only)
    end

    def materializer_attempt_record_route?
      db_path = File.join(Dir.mktmpdir("igniter-companion-materializer-attempt"), "companion.sqlite3")
      config = Companion.default_configuration(store_path: db_path)
      app = Companion.build(config: config)
      store = app.service(:companion)
      _command_status, _command_headers, _command_body = app.call(rack_env("GET", "/setup/materializer-attempt-command.json"))
      before_count = store.materializer_attempts.length
      record_status, record_headers = post(app, "/setup/materializer-attempts/record")
      recorded_status = get_status(app, record_headers.fetch("location"))
      attempts = store.materializer_attempts
      persisted_attempts = Companion.build(config: config).service(:companion).materializer_attempts

      before_count.zero? &&
        record_status == 303 &&
        recorded_status == 200 &&
        attempts.length == 1 &&
        attempts.first.fetch(:kind) == :materializer_runbook_receipt &&
        attempts.first.fetch(:executed) == false &&
        persisted_attempts.length == 1
    end

    def materializer_audit_trail?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      empty = persistence.materializer_audit_trail
      command = persistence.materializer_attempt_command
      persistence.materializer_attempts.append(command.fetch(:mutation).fetch(:event).merge(index: 0))
      trail = persistence.materializer_audit_trail

      empty.fetch(:attempt_count).zero? &&
        empty.fetch(:last_attempt).nil? &&
        trail.fetch(:attempt_count) == 1 &&
        trail.fetch(:blocked_count) == 1 &&
        trail.fetch(:executed_count).zero? &&
        trail.fetch(:blocked_capabilities) == %i[git restart test write] &&
        trail.fetch(:last_attempt).fetch(:kind) == :materializer_runbook_receipt
    end

    def materializer_supervision?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      empty = persistence.materializer_supervision
      attempt_command = persistence.materializer_attempt_command
      persistence.materializer_attempts.append(attempt_command.fetch(:mutation).fetch(:event).merge(index: 0))
      attempt_recorded = persistence.materializer_supervision
      approval_command = persistence.materializer_approval_command
      persistence.materializer_approvals.append(approval_command.fetch(:mutation).fetch(:event).merge(index: 0))
      approval_recorded = persistence.materializer_supervision

      empty.fetch(:status) == :blocked &&
        empty.fetch(:phase) == :awaiting_explicit_attempt_record &&
        empty.fetch(:signals).fetch(:gate_blocked) &&
        empty.fetch(:signals).fetch(:attempt_command_ready) &&
        empty.fetch(:signals).fetch(:approval_command_ready) &&
        empty.fetch(:signals).fetch(:approval_application_absent) &&
        empty.fetch(:command_intent).fetch(:target) == :materializer_attempts &&
        empty.fetch(:approval_command_intent).fetch(:target) == :materializer_approvals &&
        empty.fetch(:approval_command_intent).fetch(:applies_capabilities) == false &&
        empty.fetch(:next_action) == :record_blocked_attempt &&
        attempt_recorded.fetch(:phase) == :awaiting_explicit_approval_record &&
        attempt_recorded.fetch(:audit).fetch(:attempt_count) == 1 &&
        attempt_recorded.fetch(:audit).fetch(:approval_count).zero? &&
        attempt_recorded.fetch(:next_action) == :record_approval_receipt &&
        approval_recorded.fetch(:phase) == :approval_receipt_recorded &&
        approval_recorded.fetch(:approval_audit).fetch(:approval_count) == 1 &&
        approval_recorded.fetch(:approval_audit).fetch(:applied_count).zero? &&
        approval_recorded.fetch(:next_action) == :review_materializer_execution_request
    end

    def materializer_status_packet?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      status = persistence.materializer_status
      supervision = persistence.materializer_supervision

      status == supervision &&
        status.fetch(:descriptor).fetch(:schema_version) == 1 &&
        status.fetch(:descriptor).fetch(:kind) == :materializer_status &&
        status.fetch(:descriptor).fetch(:review_only) &&
        status.fetch(:descriptor).fetch(:grants_capabilities) == false &&
        status.fetch(:descriptor).fetch(:execution_allowed) == false &&
        status.fetch(:descriptor).fetch(:app_boundary_required) &&
        status.fetch(:descriptor).fetch(:histories) == { attempts: :materializer_attempts, approvals: :materializer_approvals } &&
        status.fetch(:phase) == :awaiting_explicit_attempt_record &&
        status.fetch(:approval_command_intent).fetch(:target) == :materializer_approvals &&
        status.fetch(:approval_audit).fetch(:applied_count).zero?
    end

    def materializer_status_descriptor_health?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      stable = persistence.materializer_status_descriptor_health
      descriptor = persistence.materializer_status.fetch(:descriptor).merge(execution_allowed: true)
      drift = Contracts::MaterializerStatusDescriptorHealthContract.evaluate(
        materializer_status: persistence.materializer_status.merge(descriptor: descriptor)
      )

      stable.fetch(:status) == :stable &&
        stable.fetch(:check_count) == 10 &&
        stable.fetch(:missing_terms).empty? &&
        stable.fetch(:checks).all? { |check| check.fetch(:present) } &&
        drift.fetch(:status) == :drift &&
        drift.fetch(:missing_terms).include?(:no_execution)
    end

    def materializer_approval_policy?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      pending = persistence.materializer_approval_policy
      approved = persistence.materializer_approval_policy(
        approved_by: "architect",
        approved_capabilities: %i[write git test restart]
      )
      needs_review = persistence.materializer_approval_policy(
        approved_by: "architect",
        approved_capabilities: %i[write deploy]
      )

      pending.fetch(:status) == :pending &&
        pending.fetch(:approved) == false &&
        pending.fetch(:reasons).include?(:human_approval_missing) &&
        pending.fetch(:decision).fetch(:applies_capabilities) == false &&
        approved.fetch(:status) == :approved &&
        approved.fetch(:approved) &&
        approved.fetch(:granted_capabilities) == %i[write git test restart] &&
        approved.fetch(:decision).fetch(:applies_capabilities) == false &&
        needs_review.fetch(:status) == :needs_review &&
        needs_review.fetch(:unknown_capabilities) == %i[deploy]
    end

    def materializer_approval_receipt?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      pending = persistence.materializer_approval_receipt
      approved_policy = persistence.materializer_approval_policy(
        approved_by: "architect",
        approved_capabilities: %i[write git test restart]
      )
      approved = Contracts::MaterializerApprovalReceiptContract.evaluate(approval_policy: approved_policy)

      pending.fetch(:status) == :pending &&
        pending.fetch(:receipt).fetch(:kind) == :materializer_approval_receipt &&
        pending.fetch(:receipt).fetch(:approved) == false &&
        pending.fetch(:receipt).fetch(:applies_capabilities) == false &&
        pending.fetch(:receipt).fetch(:review_only) &&
        approved.fetch(:status) == :approved &&
        approved.fetch(:receipt).fetch(:granted_capabilities) == %i[write git test restart] &&
        approved.fetch(:receipt).fetch(:applies_capabilities) == false
    end

    def materializer_approval_history?
      manifest = Contracts::MaterializerApproval.persistence_manifest
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      receipt = persistence.materializer_approval_receipt.fetch(:receipt)
      approvals = persistence.materializer_approvals
      appended = approvals.append(receipt.merge(index: 0))

      manifest.fetch(:history).fetch(:key) == :index &&
        manifest.fetch(:fields).any? { |field| field.fetch(:name) == :granted_capabilities && field.fetch(:attributes).fetch(:type) == :json } &&
        manifest.fetch(:fields).any? { |field| field.fetch(:name) == :reasons && field.fetch(:attributes).fetch(:type) == :json } &&
        appended.fetch(:index).zero? &&
        appended.fetch(:kind) == :materializer_approval_receipt &&
        appended.fetch(:applies_capabilities) == false &&
        approvals.count(status: :pending) == 1 &&
        approvals.where(kind: :materializer_approval_receipt).first.fetch(:review_only)
    end

    def materializer_approval_command?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      command = persistence.materializer_approval_command
      mutation = command.fetch(:mutation)
      event = mutation.fetch(:event)

      command.fetch(:result).fetch(:success) &&
        command.fetch(:result).fetch(:feedback_code) == :materializer_approval_recordable &&
        mutation.fetch(:operation) == :history_append &&
        mutation.fetch(:target) == :materializer_approvals &&
        event.fetch(:kind) == :materializer_approval_receipt &&
        event.fetch(:status) == :pending &&
        event.fetch(:applies_capabilities) == false &&
        event.fetch(:review_only)
    end

    def materializer_approval_record_route?
      db_path = File.join(Dir.mktmpdir("igniter-companion-materializer-approval"), "companion.sqlite3")
      config = Companion.default_configuration(store_path: db_path)
      app = Companion.build(config: config)
      store = app.service(:companion)
      _command_status, _command_headers, _command_body = app.call(rack_env("GET", "/setup/materializer-approval-command.json"))
      before_count = store.materializer_approvals.length
      record_status, record_headers = post(app, "/setup/materializer-approvals/record")
      recorded_status = get_status(app, record_headers.fetch("location"))
      approvals = store.materializer_approvals
      persisted_approvals = Companion.build(config: config).service(:companion).materializer_approvals

      before_count.zero? &&
        record_status == 303 &&
        recorded_status == 200 &&
        approvals.length == 1 &&
        approvals.first.fetch(:kind) == :materializer_approval_receipt &&
        approvals.first.fetch(:applies_capabilities) == false &&
        persisted_approvals.length == 1
    end

    def materializer_approval_audit_trail?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      empty = persistence.materializer_approval_audit_trail
      command = persistence.materializer_approval_command
      persistence.materializer_approvals.append(command.fetch(:mutation).fetch(:event).merge(index: 0))
      trail = persistence.materializer_approval_audit_trail

      empty.fetch(:approval_count).zero? &&
        empty.fetch(:last_approval).nil? &&
        trail.fetch(:approval_count) == 1 &&
        trail.fetch(:pending_count) == 1 &&
        trail.fetch(:approved_count).zero? &&
        trail.fetch(:applied_count).zero? &&
        trail.fetch(:rejected_capabilities) == %i[git restart test write] &&
        trail.fetch(:last_approval).fetch(:kind) == :materializer_approval_receipt
    end

    def wizard_type_spec_canonical?
      spec = Services::CompanionState.article_comment_type_spec
      history = spec.fetch(:histories).first

      spec.fetch(:schema_version) == 1 &&
        spec.fetch(:kind) == :record &&
        spec.fetch(:storage) == { shape: :store, key: :id, adapter: :sqlite } &&
        spec.fetch(:persist) == { key: :id, adapter: :sqlite } &&
        history.fetch(:storage) == { shape: :history, key: :index, adapter: :sqlite } &&
        history.fetch(:history) == { key: :index, adapter: :sqlite } &&
        history.fetch(:relation).fetch(:enforced) == false
    end

    def static_materialization_plan?
      plan = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).materialization_plan
      record = plan.fetch(:record_contract)
      relation = plan.fetch(:relations).fetch(:comments_by_article)

      plan.fetch(:status) == :ready_for_static_materialization &&
        plan.fetch(:schema_version) == 1 &&
        plan.fetch(:static_required) &&
        record.fetch(:contract) == :Article &&
        record.fetch(:storage).fetch(:shape) == :store &&
        record.fetch(:fields).any? { |field| field.fetch(:name) == :status && field.fetch(:default, field.dig(:attributes, :default)) == :draft } &&
        plan.fetch(:history_contracts).any? { |history| history.fetch(:contract) == :Comment && history.fetch(:storage).fetch(:shape) == :history } &&
        relation.fetch(:from) == :articles &&
        relation.fetch(:to) == :comments &&
        relation.fetch(:enforced) == false &&
        plan.fetch(:required_capabilities) == %i[write git test restart] &&
        plan.fetch(:validation_errors).empty?
    end

    def static_materialization_parity?
      parity = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).materialization_parity

      parity.fetch(:status) == :matched &&
        parity.fetch(:schema_version) == 1 &&
        parity.fetch(:plan_status) == :ready_for_static_materialization &&
        parity.fetch(:static_required) &&
        parity.fetch(:checked_capabilities) == %i[articles comments comments_by_article] &&
        parity.fetch(:mismatches).empty? &&
        parity.fetch(:summary).include?("3 planned capabilities")
    end

    def setup_manifest?(manifest)
      manifest.include?("records") &&
        manifest.include?("histories") &&
        manifest.include?("projections") &&
        manifest.include?("commands") &&
        manifest.include?("relations") &&
        manifest.include?("schema_version") &&
        manifest.include?("storage") &&
        manifest.include?("descriptor") &&
        manifest.include?("report_only") &&
        manifest.include?("indexes") &&
        manifest.include?("scopes") &&
        manifest.include?("record_append") &&
        manifest.include?("history_append")
    end

    def setup_handoff_summary?(setup)
      setup.include?("setup_handoff") &&
        setup.include?("kind=>:setup_handoff") &&
        setup.include?("context_rotation")
    end

    def setup_handoff_endpoint?(setup_handoff)
      setup_handoff.include?("status=>:stable") &&
        setup_handoff.include?("kind=>:setup_handoff") &&
        setup_handoff.include?("gates_runtime=>false") &&
        setup_handoff.include?("/setup/health.json") &&
        setup_handoff.include?("/setup/handoff/digest.json") &&
        setup_handoff.include?("/setup/handoff/digest.txt") &&
        setup_handoff.include?("/setup/handoff/next-scope.json") &&
        setup_handoff.include?("/setup/handoff/next-scope-health.json") &&
        setup_handoff.include?("/setup/handoff/promotion-readiness.json") &&
        setup_handoff.include?("/setup/handoff/extraction-sketch.json") &&
        setup_handoff.include?("/setup/handoff/packet-registry.json") &&
        setup_handoff.include?("/setup/handoff/supervision.json") &&
        setup_handoff.include?("/setup/handoff/lifecycle.json") &&
        setup_handoff.include?("/setup/handoff/lifecycle-health.json") &&
        setup_handoff.include?("/setup/handoff/acceptance.json") &&
        setup_handoff.include?("/setup/handoff/approval-acceptance.json") &&
        setup_handoff.include?("companion-current-status-summary.md") &&
        setup_handoff.include?("contract-persistence-capability-track.md") &&
        setup_handoff.include?("app_local_companion_proof") &&
        setup_handoff.include?("public_api_promise=>false") &&
        setup_handoff.include?("relation_enforcement=>:report_only") &&
        setup_handoff.include?("small_reversible_app_local_slice") &&
        setup_handoff.include?("explicit_post_only") &&
        setup_handoff.include?("materializer_supervision_awaits_explicit_approval_record") &&
        setup_handoff.include?("approval_receipt_recorded_without_capability_grants") &&
        setup_handoff.include?("public_api_promotion") &&
        setup_handoff.include?("record_blocked_attempt")
    end

    def setup_handoff_json_endpoint?(setup_handoff_json)
      payload = JSON.parse(setup_handoff_json)

      payload.fetch("status") == "stable" &&
        payload.fetch("descriptor").fetch("schema_version") == 1 &&
        payload.fetch("descriptor").fetch("kind") == "setup_handoff" &&
        payload.fetch("descriptor").fetch("report_only") &&
        payload.fetch("descriptor").fetch("gates_runtime") == false &&
        payload.fetch("descriptor").fetch("grants_capabilities") == false &&
        payload.fetch("descriptor").fetch("purpose") == "context_rotation" &&
        payload.fetch("reading_order").include?("/setup/health.json") &&
        payload.fetch("reading_order").include?("/setup/handoff/digest.json") &&
        payload.fetch("reading_order").include?("/setup/handoff/digest.txt") &&
        payload.fetch("reading_order").include?("/setup/handoff/next-scope.json") &&
        payload.fetch("reading_order").include?("/setup/handoff/next-scope-health.json") &&
        payload.fetch("reading_order").include?("/setup/handoff/promotion-readiness.json") &&
        payload.fetch("reading_order").include?("/setup/handoff/extraction-sketch.json") &&
        payload.fetch("reading_order").include?("/setup/handoff/packet-registry.json") &&
        payload.fetch("reading_order").include?("/setup/handoff/supervision.json") &&
        payload.fetch("reading_order").include?("/setup/handoff/lifecycle.json") &&
        payload.fetch("reading_order").include?("/setup/handoff/lifecycle-health.json") &&
        payload.fetch("reading_order").include?("/setup/handoff/acceptance.json") &&
        payload.fetch("reading_order").include?("/setup/handoff/approval-acceptance.json") &&
        payload.fetch("document_rotation").fetch("public").include?("docs/research/companion-current-status-summary.md") &&
        payload.fetch("document_rotation").fetch("private").include?("playgrounds/docs/dev/tracks/contract-persistence-capability-track.md") &&
        payload.fetch("document_rotation").fetch("policy") == "compact_current_state_first" &&
        payload.fetch("architecture_constraints").fetch("scope") == "app_local_companion_proof" &&
        payload.fetch("architecture_constraints").fetch("public_api_promise") == false &&
        payload.fetch("architecture_constraints").fetch("materializer_execution") == false &&
        payload.fetch("architecture_constraints").fetch("relation_enforcement") == "report_only" &&
        payload.fetch("architecture_constraints").fetch("lowerings").fetch("persist") == "store_t" &&
        payload.fetch("current_state").fetch("capabilities") == 17 &&
        payload.fetch("current_state").fetch("materializer_grants_capabilities") == false &&
        payload.fetch("next_scope").fetch("policy") == "small_reversible_app_local_slice" &&
        payload.fetch("next_scope").fetch("recommended") == "record_blocked_materializer_attempt" &&
        payload.fetch("next_scope").fetch("forbidden").include?("public_api_promotion") &&
        payload.fetch("acceptance_criteria").fetch("recommended") == "record_blocked_materializer_attempt" &&
        payload.fetch("acceptance_criteria").fetch("expected_result") == "materializer_supervision_awaits_explicit_approval_record" &&
        payload.fetch("acceptance_criteria").fetch("proof_markers").include?("companion_poc_materializer_attempt_record_route") &&
        payload.fetch("acceptance_criteria").fetch("follow_up").fetch("recommended") == "record_materializer_approval_receipt" &&
        payload.fetch("acceptance_criteria").fetch("non_goals").include?("materializer_execution") &&
        payload.fetch("next_action") == "record_blocked_attempt"
    end

    def setup_handoff_acceptance_endpoint?(setup_handoff_acceptance)
      setup_handoff_acceptance.include?("status=>:pending") &&
        setup_handoff_acceptance.include?("kind=>:setup_handoff_acceptance") &&
        setup_handoff_acceptance.include?("explicit_attempt_recorded") &&
        setup_handoff_acceptance.include?("expected_phase") &&
        setup_handoff_acceptance.include?("gates_runtime=>false")
    end

    def setup_handoff_acceptance_json_endpoint?(setup_handoff_acceptance_json)
      payload = JSON.parse(setup_handoff_acceptance_json)

      payload.fetch("status") == "pending" &&
        payload.fetch("descriptor").fetch("schema_version") == 1 &&
        payload.fetch("descriptor").fetch("kind") == "setup_handoff_acceptance" &&
        payload.fetch("descriptor").fetch("report_only") &&
        payload.fetch("descriptor").fetch("gates_runtime") == false &&
        payload.fetch("descriptor").fetch("grants_capabilities") == false &&
        payload.fetch("missing_terms").include?("explicit_attempt_recorded") &&
        payload.fetch("missing_terms").include?("expected_phase") &&
        payload.fetch("checks").any? { |check| check.fetch("term") == "materializer_execution_blocked" && check.fetch("present") }
    end

    def setup_handoff_lifecycle_endpoint?(setup_handoff_lifecycle)
      setup_handoff_lifecycle.include?("status=>:pending") &&
        setup_handoff_lifecycle.include?("kind=>:setup_handoff_lifecycle") &&
        setup_handoff_lifecycle.include?("attempt_receipt") &&
        setup_handoff_lifecycle.include?("approval_receipt") &&
        setup_handoff_lifecycle.include?("record_blocked_attempt")
    end

    def setup_handoff_lifecycle_json_endpoint?(setup_handoff_lifecycle_json)
      payload = JSON.parse(setup_handoff_lifecycle_json)

      payload.fetch("status") == "pending" &&
        payload.fetch("descriptor").fetch("schema_version") == 1 &&
        payload.fetch("descriptor").fetch("kind") == "setup_handoff_lifecycle" &&
        payload.fetch("descriptor").fetch("report_only") &&
        payload.fetch("descriptor").fetch("gates_runtime") == false &&
        payload.fetch("descriptor").fetch("grants_capabilities") == false &&
        payload.fetch("current_stage") == "attempt_receipt" &&
        payload.fetch("next_action") == "record_blocked_attempt" &&
        payload.fetch("stages").any? { |stage| stage.fetch("name") == "approval_receipt" && stage.fetch("mutation") == "POST /setup/handoff/approval-acceptance/record" }
    end

    def setup_handoff_lifecycle_health_endpoint?(setup_handoff_lifecycle_health)
      setup_handoff_lifecycle_health.include?("status=>:stable") &&
        setup_handoff_lifecycle_health.include?("kind=>:setup_handoff_lifecycle_health") &&
        setup_handoff_lifecycle_health.include?("check_count=>11") &&
        setup_handoff_lifecycle_health.include?("setup handoff lifecycle terms stable")
    end

    def setup_handoff_lifecycle_health_json_endpoint?(setup_handoff_lifecycle_health_json)
      payload = JSON.parse(setup_handoff_lifecycle_health_json)

      payload.fetch("status") == "stable" &&
        payload.fetch("check_count") == 11 &&
        payload.fetch("descriptor").fetch("kind") == "setup_handoff_lifecycle_health" &&
        payload.fetch("descriptor").fetch("report_only") &&
        payload.fetch("descriptor").fetch("gates_runtime") == false &&
        payload.fetch("descriptor").fetch("grants_capabilities") == false &&
        payload.fetch("missing_terms").empty? &&
        payload.fetch("checks").any? { |check| check.fetch("term") == "stage_order" && check.fetch("present") } &&
        payload.fetch("checks").any? { |check| check.fetch("term") == "explicit_mutations" && check.fetch("present") }
    end

    def setup_handoff_supervision_endpoint?(setup_handoff_supervision)
      setup_handoff_supervision.include?("status=>:pending") &&
        setup_handoff_supervision.include?("kind=>:setup_handoff_supervision") &&
        setup_handoff_supervision.include?("agent_context_packet") &&
        setup_handoff_supervision.include?("record_blocked_attempt") &&
        setup_handoff_supervision.include?("grants_capabilities=>false")
    end

    def setup_handoff_supervision_json_endpoint?(setup_handoff_supervision_json)
      payload = JSON.parse(setup_handoff_supervision_json)

      payload.fetch("status") == "pending" &&
        payload.fetch("descriptor").fetch("schema_version") == 1 &&
        payload.fetch("descriptor").fetch("kind") == "setup_handoff_supervision" &&
        payload.fetch("descriptor").fetch("report_only") &&
        payload.fetch("descriptor").fetch("gates_runtime") == false &&
        payload.fetch("descriptor").fetch("grants_capabilities") == false &&
        payload.fetch("signals").fetch("setup_stable") &&
        payload.fetch("signals").fetch("lifecycle_health_stable") &&
        payload.fetch("signals").fetch("materializer_grants_capabilities") == false &&
        payload.fetch("signals").fetch("materializer_execution_allowed") == false &&
        payload.fetch("packet_refs").fetch("lifecycle_health") == "/setup/handoff/lifecycle-health.json" &&
        payload.fetch("next_action") == "record_blocked_attempt"
    end

    def setup_handoff_packet_registry_endpoint?(setup_handoff_packet_registry)
      setup_handoff_packet_registry.include?("status=>:stable") &&
        setup_handoff_packet_registry.include?("kind=>:setup_handoff_packet_registry") &&
        setup_handoff_packet_registry.include?("packet_index") &&
        setup_handoff_packet_registry.include?("/setup/handoff/next-scope.json") &&
        setup_handoff_packet_registry.include?("/setup/handoff/next-scope-health.json") &&
        setup_handoff_packet_registry.include?("/setup/handoff/supervision.json") &&
        setup_handoff_packet_registry.include?("POST /setup/handoff/approval-acceptance/record")
    end

    def setup_handoff_packet_registry_json_endpoint?(setup_handoff_packet_registry_json)
      payload = JSON.parse(setup_handoff_packet_registry_json)

      payload.fetch("status") == "stable" &&
        payload.fetch("descriptor").fetch("schema_version") == 1 &&
        payload.fetch("descriptor").fetch("kind") == "setup_handoff_packet_registry" &&
        payload.fetch("descriptor").fetch("report_only") &&
        payload.fetch("descriptor").fetch("gates_runtime") == false &&
        payload.fetch("descriptor").fetch("grants_capabilities") == false &&
        payload.fetch("packets").length == 10 &&
        payload.fetch("packets").all? { |packet| packet.fetch("report_only") && packet.fetch("gates_runtime") == false && packet.fetch("grants_capabilities") == false } &&
        payload.fetch("read_order").include?("/setup/handoff/next-scope.json") &&
        payload.fetch("read_order").include?("/setup/handoff/next-scope-health.json") &&
        payload.fetch("read_order").include?("/setup/handoff/supervision.json") &&
        payload.fetch("mutation_paths").include?("POST /setup/handoff/acceptance/record") &&
        payload.fetch("mutation_paths").include?("POST /setup/handoff/approval-acceptance/record")
    end

    def setup_handoff_next_scope_endpoint?(setup_handoff_next_scope)
      setup_handoff_next_scope.include?("status=>:pending") &&
        setup_handoff_next_scope.include?("kind=>:setup_handoff_next_scope") &&
        setup_handoff_next_scope.include?("supervised_next_scope") &&
        setup_handoff_next_scope.include?("record_blocked_materializer_attempt") &&
        setup_handoff_next_scope.include?("POST /setup/materializer-attempts/record") &&
        setup_handoff_next_scope.include?("public_api_promotion")
    end

    def setup_handoff_next_scope_json_endpoint?(setup_handoff_next_scope_json)
      payload = JSON.parse(setup_handoff_next_scope_json)

      payload.fetch("status") == "pending" &&
        payload.fetch("descriptor").fetch("schema_version") == 1 &&
        payload.fetch("descriptor").fetch("kind") == "setup_handoff_next_scope" &&
        payload.fetch("descriptor").fetch("report_only") &&
        payload.fetch("descriptor").fetch("gates_runtime") == false &&
        payload.fetch("descriptor").fetch("grants_capabilities") == false &&
        payload.fetch("recommended") == "record_blocked_materializer_attempt" &&
        payload.fetch("forbidden").include?("public_api_promotion") &&
        payload.fetch("acceptance_criteria").fetch("recommended") == "record_blocked_materializer_attempt" &&
        payload.fetch("mutation_paths").include?("POST /setup/materializer-attempts/record") &&
        payload.fetch("mutation_paths").include?("POST /setup/handoff/approval-acceptance/record") &&
        payload.fetch("next_action") == "record_blocked_attempt"
    end

    def setup_handoff_next_scope_health_endpoint?(setup_handoff_next_scope_health)
      setup_handoff_next_scope_health.include?("status=>:stable") &&
        setup_handoff_next_scope_health.include?("kind=>:setup_handoff_next_scope_health") &&
        setup_handoff_next_scope_health.include?("validates=>:setup_handoff_next_scope") &&
        setup_handoff_next_scope_health.include?("check_count=>15") &&
        setup_handoff_next_scope_health.include?("next-scope terms stable")
    end

    def setup_handoff_next_scope_health_json_endpoint?(setup_handoff_next_scope_health_json)
      payload = JSON.parse(setup_handoff_next_scope_health_json)

      payload.fetch("status") == "stable" &&
        payload.fetch("check_count") == 15 &&
        payload.fetch("descriptor").fetch("schema_version") == 1 &&
        payload.fetch("descriptor").fetch("kind") == "setup_handoff_next_scope_health" &&
        payload.fetch("descriptor").fetch("validates") == "setup_handoff_next_scope" &&
        payload.fetch("descriptor").fetch("report_only") &&
        payload.fetch("descriptor").fetch("gates_runtime") == false &&
        payload.fetch("descriptor").fetch("grants_capabilities") == false &&
        payload.fetch("missing_terms").empty? &&
        payload.fetch("checks").all? { |check| check.fetch("present") }
    end

    def setup_handoff_extraction_sketch_endpoint?(setup_handoff_extraction_sketch)
      setup_handoff_extraction_sketch.include?("status=>:sketched") &&
        setup_handoff_extraction_sketch.include?("kind=>:setup_handoff_extraction_sketch") &&
        setup_handoff_extraction_sketch.include?("package_promise=>false") &&
        setup_handoff_extraction_sketch.include?("igniter_extensions_candidate") &&
        setup_handoff_extraction_sketch.include?("igniter_application_candidate") &&
        setup_handoff_extraction_sketch.include?("reserved_future_name=>:igniter_persistence")
    end

    def setup_handoff_extraction_sketch_json_endpoint?(setup_handoff_extraction_sketch_json)
      payload = JSON.parse(setup_handoff_extraction_sketch_json)

      payload.fetch("status") == "sketched" &&
        payload.fetch("descriptor").fetch("schema_version") == 1 &&
        payload.fetch("descriptor").fetch("kind") == "setup_handoff_extraction_sketch" &&
        payload.fetch("descriptor").fetch("report_only") &&
        payload.fetch("descriptor").fetch("package_promise") == false &&
        payload.fetch("constraints").fetch("package_split_now") == false &&
        payload.fetch("constraints").fetch("reserved_future_name") == "igniter_persistence" &&
        payload.fetch("placements").fetch("igniter_extensions_candidate").include?("store_history_relation_descriptors") &&
        payload.fetch("placements").fetch("igniter_application_candidate").include?("explicit_app_boundary_writes") &&
        payload.fetch("placements").fetch("future_igniter_persistence_candidate").include?("adapter_contract") &&
        payload.fetch("next_action") == "keep_companion_app_local"
    end

    def setup_handoff_promotion_readiness_endpoint?(setup_handoff_promotion_readiness)
      setup_handoff_promotion_readiness.include?("status=>:blocked") &&
        setup_handoff_promotion_readiness.include?("kind=>:setup_handoff_promotion_readiness") &&
        setup_handoff_promotion_readiness.include?("package_promotion_readiness") &&
        setup_handoff_promotion_readiness.include?("single_app_pressure_only") &&
        setup_handoff_promotion_readiness.include?("keep_companion_app_local")
    end

    def setup_handoff_promotion_readiness_json_endpoint?(setup_handoff_promotion_readiness_json)
      payload = JSON.parse(setup_handoff_promotion_readiness_json)

      payload.fetch("status") == "blocked" &&
        payload.fetch("descriptor").fetch("schema_version") == 1 &&
        payload.fetch("descriptor").fetch("kind") == "setup_handoff_promotion_readiness" &&
        payload.fetch("descriptor").fetch("report_only") &&
        payload.fetch("descriptor").fetch("gates_runtime") == false &&
        payload.fetch("descriptor").fetch("grants_capabilities") == false &&
        payload.fetch("blockers").include?("single_app_pressure_only") &&
        payload.fetch("blockers").include?("public_api_not_promised") &&
        payload.fetch("blockers").include?("package_split_disabled") &&
        payload.fetch("blockers").include?("packet_surface_report_only") &&
        payload.fetch("allowed_next_steps").include?("keep_companion_app_local") &&
        payload.fetch("allowed_next_steps").include?("repeat_pressure_in_another_app")
    end

    def setup_handoff_digest_endpoint?(setup_handoff_digest)
      setup_handoff_digest.include?("status=>:pending") &&
        setup_handoff_digest.include?("kind=>:setup_handoff_digest") &&
        setup_handoff_digest.include?("compact_human_agent_summary") &&
        setup_handoff_digest.include?("Companion app-local proof") &&
        setup_handoff_digest.include?("promotion: blocked")
    end

    def setup_handoff_digest_json_endpoint?(setup_handoff_digest_json)
      payload = JSON.parse(setup_handoff_digest_json)

      payload.fetch("status") == "pending" &&
        payload.fetch("descriptor").fetch("schema_version") == 1 &&
        payload.fetch("descriptor").fetch("kind") == "setup_handoff_digest" &&
        payload.fetch("descriptor").fetch("report_only") &&
        payload.fetch("descriptor").fetch("gates_runtime") == false &&
        payload.fetch("descriptor").fetch("grants_capabilities") == false &&
        payload.fetch("highlights").fetch("lifecycle_stage") == "attempt_receipt" &&
        payload.fetch("highlights").fetch("promotion_status") == "blocked" &&
        payload.fetch("highlights").fetch("package_promise") == false &&
        payload.fetch("next_reads").include?("/setup/handoff/supervision.json") &&
        payload.fetch("diagram").include?("Companion app-local proof")
    end

    def setup_handoff_digest_text_endpoint?(setup_handoff_digest_text)
      setup_handoff_digest_text.include?("Companion app-local proof") &&
        setup_handoff_digest_text.include?("promotion: blocked") &&
        setup_handoff_digest_text.include?("next_reads:") &&
        setup_handoff_digest_text.include?("/setup/handoff/supervision.json") &&
        setup_handoff_digest_text.include?("/setup/handoff/promotion-readiness.json")
    end

    def setup_handoff_approval_acceptance_endpoint?(setup_handoff_approval_acceptance)
      setup_handoff_approval_acceptance.include?("status=>:pending") &&
        setup_handoff_approval_acceptance.include?("kind=>:setup_handoff_approval_acceptance") &&
        setup_handoff_approval_acceptance.include?("explicit_attempt_recorded") &&
        setup_handoff_approval_acceptance.include?("explicit_approval_recorded") &&
        setup_handoff_approval_acceptance.include?("capability_grants_blocked")
    end

    def setup_handoff_approval_acceptance_json_endpoint?(setup_handoff_approval_acceptance_json)
      payload = JSON.parse(setup_handoff_approval_acceptance_json)

      payload.fetch("status") == "pending" &&
        payload.fetch("descriptor").fetch("schema_version") == 1 &&
        payload.fetch("descriptor").fetch("kind") == "setup_handoff_approval_acceptance" &&
        payload.fetch("descriptor").fetch("report_only") &&
        payload.fetch("descriptor").fetch("gates_runtime") == false &&
        payload.fetch("descriptor").fetch("grants_capabilities") == false &&
        payload.fetch("missing_terms").include?("explicit_attempt_recorded") &&
        payload.fetch("missing_terms").include?("explicit_approval_recorded") &&
        payload.fetch("checks").any? { |check| check.fetch("term") == "approval_application_absent" && check.fetch("present") }
    end

    def setup_health_summary?(setup)
      setup.include?("setup_health") &&
        setup.include?("review_count=>0") &&
        setup.include?("report-only")
    end

    def setup_health_endpoint?(setup_health)
      setup_health.include?("status=>:stable") &&
        setup_health.include?("kind=>:setup_health") &&
        setup_health.include?("gates_runtime=>false") &&
        setup_health.include?("check_count=>5") &&
        setup_health.include?("review_count=>0") &&
        setup_health.include?("setup health checks")
    end

    def setup_health_json_endpoint?(setup_health_json)
      payload = JSON.parse(setup_health_json)

      payload.fetch("status") == "stable" &&
        payload.fetch("descriptor").fetch("schema_version") == 1 &&
        payload.fetch("descriptor").fetch("kind") == "setup_health" &&
        payload.fetch("descriptor").fetch("report_only") &&
        payload.fetch("descriptor").fetch("gates_runtime") == false &&
        payload.fetch("descriptor").fetch("grants_capabilities") == false &&
        payload.fetch("descriptor").fetch("sources").include?("materializer_status_descriptor_health") &&
        payload.fetch("descriptor").fetch("review_item_policy") == "diagnostic_only" &&
        payload.fetch("check_count") == 5 &&
        payload.fetch("review_count").zero? &&
        payload.fetch("review_items").empty? &&
        payload.fetch("checks").all? { |check| check.fetch("present") }
    end

    def setup_manifest_glossary_summary?(setup)
      setup.include?("manifest_glossary") &&
        setup.include?("materializer_descriptor_health") &&
        setup.include?("status=>:stable") &&
        setup.include?("check_count=>9") &&
        setup.include?("missing_terms=>[]")
    end

    def setup_manifest_glossary_endpoint?(manifest_glossary)
      manifest_glossary.include?("status=>:stable") &&
        manifest_glossary.include?("missing_terms=>[]") &&
        manifest_glossary.include?("manifest glossary terms stable")
    end

    def setup_manifest_glossary_json_endpoint?(manifest_glossary_json)
      payload = JSON.parse(manifest_glossary_json)

      payload.fetch("status") == "stable" &&
        payload.fetch("check_count") == 9 &&
        payload.fetch("missing_terms").empty? &&
        payload.fetch("checks").all? { |check| check.fetch("present") }
    end

    def setup_storage_plan_endpoint?(storage_plan)
      storage_plan.include?("kind=>:persistence_storage_plan_sketch") &&
        storage_plan.include?("schema_changes_allowed=>false") &&
        storage_plan.include?("sql_generation_allowed=>false") &&
        storage_plan.include?("store_lowering=>:store_t") &&
        storage_plan.include?("history_lowering=>:history_t") &&
        storage_plan.include?("adapter_type_candidate=>:json_document")
    end

    def setup_storage_plan_json_endpoint?(storage_plan_json)
      payload = JSON.parse(storage_plan_json)
      reminders = payload.fetch("records").fetch("reminders")
      wizard_specs = payload.fetch("records").fetch("wizard_type_specs")
      tracker_logs = payload.fetch("histories").fetch("tracker_logs")

      payload.fetch("schema_version") == 1 &&
        payload.fetch("descriptor").fetch("kind") == "persistence_storage_plan_sketch" &&
        payload.fetch("descriptor").fetch("report_only") &&
        payload.fetch("descriptor").fetch("gates_runtime") == false &&
        payload.fetch("descriptor").fetch("grants_capabilities") == false &&
        payload.fetch("descriptor").fetch("schema_changes_allowed") == false &&
        payload.fetch("descriptor").fetch("sql_generation_allowed") == false &&
        payload.fetch("summary").fetch("status") == "sketched" &&
        payload.fetch("summary").fetch("record_plan_count") == 6 &&
        payload.fetch("summary").fetch("history_plan_count") == 6 &&
        reminders.fetch("store_lowering") == "store_t" &&
        reminders.fetch("indexes").any? { |index| index.fetch("name") == "status" && index.fetch("fields") == ["status"] } &&
        reminders.fetch("scopes").any? { |scope| scope.fetch("name") == "open" && scope.fetch("where") == { "status" => "open" } } &&
        wizard_specs.fetch("columns").any? { |column| column.fetch("name") == "spec" && column.fetch("portable_type") == "json" && column.fetch("adapter_type_candidate") == "json_document" } &&
        tracker_logs.fetch("history_lowering") == "history_t" &&
        tracker_logs.fetch("append_only") &&
        tracker_logs.fetch("partition_key_candidate") == "tracker_id"
    end

    def setup_storage_plan_health_endpoint?(storage_plan_health)
      storage_plan_health.include?("status=>:stable") &&
        storage_plan_health.include?("kind=>:persistence_storage_plan_health") &&
        storage_plan_health.include?("validates=>:persistence_storage_plan_sketch") &&
        storage_plan_health.include?("check_count=>17") &&
        storage_plan_health.include?("storage plan terms stable")
    end

    def setup_storage_plan_health_json_endpoint?(storage_plan_health_json)
      payload = JSON.parse(storage_plan_health_json)

      payload.fetch("status") == "stable" &&
        payload.fetch("check_count") == 17 &&
        payload.fetch("descriptor").fetch("schema_version") == 1 &&
        payload.fetch("descriptor").fetch("kind") == "persistence_storage_plan_health" &&
        payload.fetch("descriptor").fetch("validates") == "persistence_storage_plan_sketch" &&
        payload.fetch("descriptor").fetch("report_only") &&
        payload.fetch("descriptor").fetch("gates_runtime") == false &&
        payload.fetch("descriptor").fetch("grants_capabilities") == false &&
        payload.fetch("missing_terms").empty? &&
        payload.fetch("checks").all? { |check| check.fetch("present") }
    end

    def setup_storage_migration_plan_endpoint?(storage_migration_plan)
      storage_migration_plan.include?("kind=>:persistence_storage_migration_plan") &&
        storage_migration_plan.include?("migration_execution_allowed=>false") &&
        storage_migration_plan.include?("sql_generation_allowed=>false") &&
        storage_migration_plan.include?("review-only storage migration candidates") &&
        storage_migration_plan.include?("status stable")
    end

    def setup_storage_migration_plan_json_endpoint?(storage_migration_plan_json)
      payload = JSON.parse(storage_migration_plan_json)

      payload.fetch("schema_version") == 1 &&
        payload.fetch("descriptor").fetch("kind") == "persistence_storage_migration_plan" &&
        payload.fetch("descriptor").fetch("report_only") &&
        payload.fetch("descriptor").fetch("gates_runtime") == false &&
        payload.fetch("descriptor").fetch("grants_capabilities") == false &&
        payload.fetch("descriptor").fetch("migration_execution_allowed") == false &&
        payload.fetch("descriptor").fetch("sql_generation_allowed") == false &&
        payload.fetch("status") == "stable" &&
        payload.fetch("report_count") == 12 &&
        payload.fetch("candidate_count").zero? &&
        payload.fetch("reports").all? { |report| report.fetch("candidates").empty? }
    end

    def setup_storage_migration_plan_health_endpoint?(storage_migration_plan_health)
      storage_migration_plan_health.include?("status=>:stable") &&
        storage_migration_plan_health.include?("kind=>:persistence_storage_migration_plan_health") &&
        storage_migration_plan_health.include?("validates=>:persistence_storage_migration_plan") &&
        storage_migration_plan_health.include?("check_count=>15") &&
        storage_migration_plan_health.include?("storage migration plan terms stable")
    end

    def setup_storage_migration_plan_health_json_endpoint?(storage_migration_plan_health_json)
      payload = JSON.parse(storage_migration_plan_health_json)

      payload.fetch("status") == "stable" &&
        payload.fetch("check_count") == 15 &&
        payload.fetch("descriptor").fetch("schema_version") == 1 &&
        payload.fetch("descriptor").fetch("kind") == "persistence_storage_migration_plan_health" &&
        payload.fetch("descriptor").fetch("validates") == "persistence_storage_migration_plan" &&
        payload.fetch("descriptor").fetch("report_only") &&
        payload.fetch("descriptor").fetch("gates_runtime") == false &&
        payload.fetch("descriptor").fetch("grants_capabilities") == false &&
        payload.fetch("missing_terms").empty? &&
        payload.fetch("checks").all? { |check| check.fetch("present") }
    end

    def setup_field_type_plan_endpoint?(field_type_plan)
      field_type_plan.include?("kind=>:persistence_field_type_plan") &&
        field_type_plan.include?("materializer_execution_allowed=>false") &&
        field_type_plan.include?("persist=>:store_t") &&
        field_type_plan.include?("history=>:history_t") &&
        field_type_plan.include?("declared_type=>:enum") &&
        field_type_plan.include?("declared_type=>:json")
    end

    def setup_field_type_plan_json_endpoint?(field_type_plan_json)
      payload = JSON.parse(field_type_plan_json)
      article_status = payload.fetch("records").fetch("articles").fetch("fields").find { |field| field.fetch("name") == "status" }
      wizard_spec = payload.fetch("records").fetch("wizard_type_specs").fetch("fields").find { |field| field.fetch("name") == "spec" }

      payload.fetch("schema_version") == 1 &&
        payload.fetch("descriptor").fetch("kind") == "persistence_field_type_plan" &&
        payload.fetch("descriptor").fetch("report_only") &&
        payload.fetch("descriptor").fetch("gates_runtime") == false &&
        payload.fetch("descriptor").fetch("grants_capabilities") == false &&
        payload.fetch("descriptor").fetch("schema_changes_allowed") == false &&
        payload.fetch("descriptor").fetch("sql_generation_allowed") == false &&
        payload.fetch("descriptor").fetch("materializer_execution_allowed") == false &&
        payload.fetch("descriptor").fetch("preserves") == { "persist" => "store_t", "history" => "history_t" } &&
        payload.fetch("status") == "stable" &&
        payload.fetch("issue_count").zero? &&
        payload.fetch("summary").fetch("record_shape_count") == 6 &&
        payload.fetch("summary").fetch("history_shape_count") == 6 &&
        article_status.fetch("declared_type") == "enum" &&
        article_status.fetch("enum_values") == %w[draft published archived] &&
        wizard_spec.fetch("declared_type") == "json" &&
        wizard_spec.fetch("sample_count").positive?
    end

    def setup_field_type_health_endpoint?(field_type_health)
      field_type_health.include?("status=>:stable") &&
        field_type_health.include?("kind=>:persistence_field_type_health") &&
        field_type_health.include?("validates=>:persistence_field_type_plan") &&
        field_type_health.include?("check_count=>18") &&
        field_type_health.include?("field type terms stable")
    end

    def setup_field_type_health_json_endpoint?(field_type_health_json)
      payload = JSON.parse(field_type_health_json)

      payload.fetch("status") == "stable" &&
        payload.fetch("check_count") == 18 &&
        payload.fetch("descriptor").fetch("schema_version") == 1 &&
        payload.fetch("descriptor").fetch("kind") == "persistence_field_type_health" &&
        payload.fetch("descriptor").fetch("validates") == "persistence_field_type_plan" &&
        payload.fetch("descriptor").fetch("report_only") &&
        payload.fetch("descriptor").fetch("gates_runtime") == false &&
        payload.fetch("descriptor").fetch("grants_capabilities") == false &&
        payload.fetch("missing_terms").empty? &&
        payload.fetch("checks").all? { |check| check.fetch("present") }
    end

    def setup_relation_type_plan_endpoint?(relation_type_plan)
      relation_type_plan.include?("kind=>:persistence_relation_type_plan") &&
        relation_type_plan.include?("relation_enforcement_allowed=>false") &&
        relation_type_plan.include?("foreign_key_generation_allowed=>false") &&
        relation_type_plan.include?("relation=>:relation_t") &&
        relation_type_plan.include?("compatibility=>:inferred") &&
        relation_type_plan.include?("comments_by_article")
    end

    def setup_relation_type_plan_json_endpoint?(relation_type_plan_json)
      payload = JSON.parse(relation_type_plan_json)
      tracker_relation = payload.fetch("relations").fetch("tracker_logs_by_tracker")
      comment_relation = payload.fetch("relations").fetch("comments_by_article")
      tracker_join = tracker_relation.fetch("joins").first
      comment_join = comment_relation.fetch("joins").first

      payload.fetch("schema_version") == 1 &&
        payload.fetch("descriptor").fetch("kind") == "persistence_relation_type_plan" &&
        payload.fetch("descriptor").fetch("report_only") &&
        payload.fetch("descriptor").fetch("gates_runtime") == false &&
        payload.fetch("descriptor").fetch("grants_capabilities") == false &&
        payload.fetch("descriptor").fetch("relation_enforcement_allowed") == false &&
        payload.fetch("descriptor").fetch("foreign_key_generation_allowed") == false &&
        payload.fetch("descriptor").fetch("source") == "persistence_field_type_plan" &&
        payload.fetch("descriptor").fetch("preserves") == { "relation" => "relation_t", "from" => "store_t", "to" => "history_t" } &&
        payload.fetch("status") == "stable" &&
        payload.fetch("issue_count").zero? &&
        payload.fetch("relation_count") == 2 &&
        tracker_relation.fetch("enforcement") == { "enforced" => false, "mode" => "report_only" } &&
        tracker_join.fetch("from_field") == "id" &&
        tracker_join.fetch("to_field") == "tracker_id" &&
        tracker_join.fetch("compatibility") == "inferred" &&
        comment_join.fetch("from_field") == "id" &&
        comment_join.fetch("to_field") == "article_id" &&
        comment_join.fetch("compatibility") == "inferred"
    end

    def setup_relation_type_health_endpoint?(relation_type_health)
      relation_type_health.include?("status=>:stable") &&
        relation_type_health.include?("kind=>:persistence_relation_type_health") &&
        relation_type_health.include?("validates=>:persistence_relation_type_plan") &&
        relation_type_health.include?("check_count=>19") &&
        relation_type_health.include?("relation type terms stable")
    end

    def setup_relation_type_health_json_endpoint?(relation_type_health_json)
      payload = JSON.parse(relation_type_health_json)

      payload.fetch("status") == "stable" &&
        payload.fetch("check_count") == 19 &&
        payload.fetch("descriptor").fetch("schema_version") == 1 &&
        payload.fetch("descriptor").fetch("kind") == "persistence_relation_type_health" &&
        payload.fetch("descriptor").fetch("validates") == "persistence_relation_type_plan" &&
        payload.fetch("descriptor").fetch("report_only") &&
        payload.fetch("descriptor").fetch("gates_runtime") == false &&
        payload.fetch("descriptor").fetch("grants_capabilities") == false &&
        payload.fetch("missing_terms").empty? &&
        payload.fetch("checks").all? { |check| check.fetch("present") }
    end

    def setup_access_path_plan_endpoint?(access_path_plan)
      access_path_plan.include?("kind=>:persistence_access_path_plan") &&
        access_path_plan.include?("store_read_node_allowed=>false") &&
        access_path_plan.include?("runtime_planner_allowed=>false") &&
        access_path_plan.include?("lookup_kind=>:key") &&
        access_path_plan.include?("lookup_kind=>:join") &&
        access_path_plan.include?("future_index_lookup")
    end

    def setup_access_path_plan_json_endpoint?(access_path_plan_json)
      payload = JSON.parse(access_path_plan_json)
      reminders = payload.fetch("records").fetch("reminders")
      tracker_logs = payload.fetch("histories").fetch("tracker_logs")
      tracker_relation = payload.fetch("relations").fetch("tracker_logs_by_tracker")
      tracker_projection = payload.fetch("projections").fetch("tracker_read_model")

      payload.fetch("schema_version") == 1 &&
        payload.fetch("descriptor").fetch("kind") == "persistence_access_path_plan" &&
        payload.fetch("descriptor").fetch("report_only") &&
        payload.fetch("descriptor").fetch("gates_runtime") == false &&
        payload.fetch("descriptor").fetch("grants_capabilities") == false &&
        payload.fetch("descriptor").fetch("store_read_node_allowed") == false &&
        payload.fetch("descriptor").fetch("runtime_planner_allowed") == false &&
        payload.fetch("descriptor").fetch("cache_execution_allowed") == false &&
        payload.fetch("descriptor").fetch("source") == { "storage" => "persistence_storage_plan_sketch", "relation_types" => "persistence_relation_type_plan" } &&
        payload.fetch("descriptor").fetch("preserves") == { "persist" => "store_t", "history" => "history_t", "relation" => "relation_t" } &&
        payload.fetch("status") == "sketched" &&
        payload.fetch("path_count") == 43 &&
        reminders.fetch("paths").any? { |path| path.fetch("name") == "find" && path.fetch("lookup_kind") == "key" && path.fetch("key_binding") == { "field" => "id", "source" => "argument" } } &&
        reminders.fetch("paths").any? { |path| path.fetch("name") == "scope_open" && path.fetch("lookup_kind") == "scope" && path.fetch("implemented") } &&
        reminders.fetch("paths").any? { |path| path.fetch("name") == "index_status" && path.fetch("lookup_kind") == "index" && path.fetch("implemented") == false } &&
        tracker_logs.fetch("paths").any? { |path| path.fetch("name") == "partition" && path.fetch("lookup_kind") == "partition" && path.fetch("key_binding") == { "field" => "tracker_id", "source" => "criteria" } } &&
        tracker_relation.fetch("paths").first.fetch("lookup_kind") == "join" &&
        tracker_projection.fetch("reads") == %w[trackers tracker_logs] &&
        tracker_projection.fetch("reactive_consumer_hint")
    end

    def setup_access_path_health_endpoint?(access_path_health)
      access_path_health.include?("status=>:stable") &&
        access_path_health.include?("kind=>:persistence_access_path_health") &&
        access_path_health.include?("validates=>:persistence_access_path_plan") &&
        access_path_health.include?("check_count=>22") &&
        access_path_health.include?("access path terms stable")
    end

    def setup_access_path_health_json_endpoint?(access_path_health_json)
      payload = JSON.parse(access_path_health_json)

      payload.fetch("status") == "stable" &&
        payload.fetch("check_count") == 22 &&
        payload.fetch("descriptor").fetch("schema_version") == 1 &&
        payload.fetch("descriptor").fetch("kind") == "persistence_access_path_health" &&
        payload.fetch("descriptor").fetch("validates") == "persistence_access_path_plan" &&
        payload.fetch("descriptor").fetch("report_only") &&
        payload.fetch("descriptor").fetch("gates_runtime") == false &&
        payload.fetch("descriptor").fetch("grants_capabilities") == false &&
        payload.fetch("missing_terms").empty? &&
        payload.fetch("checks").all? { |check| check.fetch("present") }
    end

    def setup_effect_intent_plan_endpoint?(effect_intent_plan)
      effect_intent_plan.include?("kind=>:persistence_effect_intent_plan") &&
        effect_intent_plan.include?("store_write_node_allowed=>false") &&
        effect_intent_plan.include?("store_append_node_allowed=>false") &&
        effect_intent_plan.include?("saga_execution_allowed=>false") &&
        effect_intent_plan.include?("effect=>:store_write") &&
        effect_intent_plan.include?("effect=>:store_append")
    end

    def setup_effect_intent_plan_json_endpoint?(effect_intent_plan_json)
      payload = JSON.parse(effect_intent_plan_json)
      reminder = payload.fetch("commands").fetch("reminder_commands")
      tracker_log = payload.fetch("commands").fetch("tracker_log_commands")
      reminder_update = reminder.fetch("intents").find { |intent| intent.fetch("operation") == "record_update" }
      tracker_append = tracker_log.fetch("intents").find { |intent| intent.fetch("operation") == "history_append" }

      payload.fetch("schema_version") == 1 &&
        payload.fetch("descriptor").fetch("kind") == "persistence_effect_intent_plan" &&
        payload.fetch("descriptor").fetch("report_only") &&
        payload.fetch("descriptor").fetch("gates_runtime") == false &&
        payload.fetch("descriptor").fetch("grants_capabilities") == false &&
        payload.fetch("descriptor").fetch("store_write_node_allowed") == false &&
        payload.fetch("descriptor").fetch("store_append_node_allowed") == false &&
        payload.fetch("descriptor").fetch("saga_execution_allowed") == false &&
        payload.fetch("descriptor").fetch("app_boundary_required") &&
        payload.fetch("descriptor").fetch("source") == { "commands" => "operation_manifest", "access_paths" => "persistence_access_path_plan" } &&
        payload.fetch("descriptor").fetch("preserves") == { "persist" => "store_t", "history" => "history_t", "command" => "mutation_intent" } &&
        payload.fetch("status") == "sketched" &&
        payload.fetch("intent_count") == 11 &&
        reminder.fetch("target") == "reminders" &&
        reminder_update.fetch("effect") == "store_write" &&
        reminder_update.fetch("write_kind") == "update" &&
        reminder_update.fetch("lowering") == "store_t" &&
        reminder_update.fetch("command_still_lowers_to") == "mutation_intent" &&
        reminder_update.fetch("access_path_source").fetch("present") &&
        tracker_append.fetch("effect") == "store_append" &&
        tracker_append.fetch("write_kind") == "append" &&
        tracker_append.fetch("lowering") == "history_t" &&
        tracker_append.fetch("access_path_source").fetch("present")
    end

    def setup_effect_intent_health_endpoint?(effect_intent_health)
      effect_intent_health.include?("status=>:stable") &&
        effect_intent_health.include?("kind=>:persistence_effect_intent_health") &&
        effect_intent_health.include?("validates=>:persistence_effect_intent_plan") &&
        effect_intent_health.include?("check_count=>24") &&
        effect_intent_health.include?("effect intent terms stable")
    end

    def setup_effect_intent_health_json_endpoint?(effect_intent_health_json)
      payload = JSON.parse(effect_intent_health_json)

      payload.fetch("status") == "stable" &&
        payload.fetch("check_count") == 24 &&
        payload.fetch("descriptor").fetch("schema_version") == 1 &&
        payload.fetch("descriptor").fetch("kind") == "persistence_effect_intent_health" &&
        payload.fetch("descriptor").fetch("validates") == "persistence_effect_intent_plan" &&
        payload.fetch("descriptor").fetch("report_only") &&
        payload.fetch("descriptor").fetch("gates_runtime") == false &&
        payload.fetch("descriptor").fetch("grants_capabilities") == false &&
        payload.fetch("missing_terms").empty? &&
        payload.fetch("checks").all? { |check| check.fetch("present") }
    end

    def setup_store_convergence_sidecar_endpoint?(store_convergence)
      store_convergence.include?("kind=>:store_convergence_sidecar") &&
        store_convergence.include?("package_facade=>:\"igniter-companion\"") &&
        store_convergence.include?("substrate=>:\"igniter-store\"") &&
        store_convergence.include?("current_status=>:done") &&
        store_convergence.include?("past_status=>:open") &&
        store_convergence.include?("partition_query_supported=>true") &&
        store_convergence.include?("next_question=>:manifest_generated_record_history_classes")
    end

    def setup_store_convergence_sidecar_json_endpoint?(store_convergence_json)
      payload = JSON.parse(store_convergence_json)
      descriptor = payload.fetch("descriptor")
      record = payload.fetch("record")
      history = payload.fetch("history")
      pressure = payload.fetch("pressure")

      payload.fetch("schema_version") == 1 &&
        descriptor.fetch("kind") == "store_convergence_sidecar" &&
        descriptor.fetch("report_only") &&
        descriptor.fetch("gates_runtime") == false &&
        descriptor.fetch("grants_capabilities") == false &&
        descriptor.fetch("replaces_app_backend") == false &&
        descriptor.fetch("mutates_main_state") == false &&
        descriptor.fetch("package_facade") == "igniter-companion" &&
        descriptor.fetch("substrate") == "igniter-store" &&
        descriptor.fetch("preserves") == { "persist" => "store_t", "history" => "history_t", "command" => "mutation_intent" } &&
        payload.fetch("status") == "stable" &&
        payload.fetch("checks").length == 19 &&
        payload.fetch("checks").all? { |check| check.fetch("present") } &&
        record.fetch("generated_from_manifest") &&
        history.fetch("generated_from_manifest") &&
        record.fetch("current_status") == "done" &&
        record.fetch("past_status") == "open" &&
        record.fetch("open_before_count") == 1 &&
        record.fetch("open_after_count").zero? &&
        record.fetch("causation_count") == 2 &&
        record.fetch("write_receipt_intent") == "record_write" &&
        record.fetch("write_receipt_fact_id_present") &&
        record.fetch("write_receipt_delegates") &&
        history.fetch("replay_count") == 3 &&
        history.fetch("values") == [7.0, 8.5] &&
        history.fetch("event_fact_ids").all? &&
        history.fetch("partition_key_declared") == "tracker_id" &&
        history.fetch("append_receipt_intent") == "history_append" &&
        history.fetch("partition_query_supported") &&
        history.fetch("partition_replay_count") == 2 &&
        history.fetch("partition_replay_values") == [7.0, 8.5] &&
        pressure.fetch("next_question") == "manifest_generated_record_history_classes"
    end

    def post(app, path, values = {})
      status, headers = app.call(rack_env("POST", path, form_body(values)))
      [status, headers]
    end

    def get_status(app, path)
      status, = app.call(rack_env("GET", path))
      status
    end

    def rack_env(method, path, body = "")
      path_info, query_string = path.split("?", 2)
      {
        "REQUEST_METHOD" => method,
        "PATH_INFO" => path_info,
        "QUERY_STRING" => query_string.to_s,
        "rack.input" => StringIO.new(body)
      }
    end

    def form_body(values)
      URI.encode_www_form(values)
    end
  end
end
