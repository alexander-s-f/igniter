# frozen_string_literal: true

module IgniterExamples
  ROOT = File.expand_path("..", __dir__)

  Example = Struct.new(
    :id,
    :path,
    :summary,
    :smoke,
    :autonomous,
    :runnable,
    :timeout,
    :args,
    :expected_fragments,
    :skip_reason,
    keyword_init: true
  ) do
    def full_path
      File.expand_path(path, ROOT)
    end

    def command_args
      Array(args)
    end

    def smoke?
      smoke
    end

    def autonomous?
      autonomous
    end

    def runnable?
      runnable
    end

    def status
      return :smoke if smoke?
      return :manual if runnable?

      :unsupported
    end
  end

  def self.example(id, summary, expected_fragments:, timeout: 10, args: nil, autonomous: true, runnable: true,
                   smoke: true, skip_reason: nil)
    Example.new(
      id: id,
      path: "examples/#{id}.rb",
      summary: summary,
      smoke: smoke,
      autonomous: autonomous,
      runnable: runnable,
      timeout: timeout,
      args: args,
      expected_fragments: expected_fragments,
      skip_reason: skip_reason
    )
  end

  ALL = [
    example(
      "application/layout",
      "Application manifest and canonical user app layout shape.",
      expected_fragments: [
        "application_manifest_name=shop",
        "application_manifest_env=test",
        "application_layout_contracts=app/contracts",
        "application_layout_config=config/igniter.rb",
        "application_manifest_services=pricing_api",
        "application_manifest_contracts=PricingContract",
        "application_manifest_owner=commerce",
        "application_load_present=config,contracts,services",
        "application_load_missing=effects,packs,providers"
      ]
    ),
    example(
      "application/blueprint",
      "Application blueprint as the canonical pre-runtime app shape.",
      expected_fragments: [
        "application_blueprint_name=operator",
        "application_blueprint_env=test",
        "application_blueprint_web=operator_console,agent_chat",
        "application_blueprint_paths=contracts,providers,services,effects,packs,executors,tools,agents,skills,support,web,config,spec",
        "application_blueprint_manifest=true",
        "application_blueprint_owner=operations",
        "application_blueprint_profile_env=test",
        "application_blueprint_profile_web=operator_console,agent_chat",
        "application_blueprint_runtime=test"
      ]
    ),
    example(
      "application/structure_plan",
      "Explicit application structure planning and materialization from a blueprint.",
      expected_fragments: [
        "application_structure_name=operator",
        "application_structure_initial_missing=3",
        "application_structure_applied=3",
        "application_structure_complete_applied=10",
        "application_structure_config=true",
        "application_structure_web=true",
        "application_structure_contracts=true",
        "application_structure_final_present=3",
        "application_structure_final_missing=0",
        "application_structure_complete_present=13"
      ]
    ),
    example(
      "application/capsule_layout",
      "Compact app capsule layout profile with sparse materialization.",
      expected_fragments: [
        "application_capsule_name=pricing",
        "application_capsule_layout=capsule",
        "application_capsule_contracts_path=contracts",
        "application_capsule_config_path=igniter.rb",
        "application_capsule_active_groups=config,contracts,services,spec",
        "application_capsule_sparse_groups=config,contracts,services,spec",
        "application_capsule_applied=4",
        "application_capsule_config=true",
        "application_capsule_web=false",
        "application_capsule_profile_paths=config,contracts,services,spec"
      ]
    ),
    example(
      "application/capsule_manifest",
      "Portable capsule manifest metadata for exports and imports.",
      expected_fragments: [
        "application_capsule_manifest_name=operator",
        "application_capsule_manifest_layout=capsule",
        "application_capsule_manifest_groups=config,contracts,services,spec",
        "application_capsule_manifest_exports=cluster_status,resolve_incident",
        "application_capsule_manifest_imports=incident_runtime,audit_log",
        "application_capsule_manifest_required_imports=incident_runtime",
        "application_capsule_manifest_optional_imports=audit_log",
        "application_capsule_manifest_paths=config,contracts,services,spec"
      ]
    ),
    example(
      "application/flow_session",
      "Application-owned agent-native flow session snapshot and event envelope.",
      expected_fragments: [
        "application_flow_session_kind=flow",
        "application_flow_session_status=waiting_for_user",
        "application_flow_session_pending_inputs=clarification",
        "application_flow_session_pending_actions=approve_plan",
        "application_flow_session_pending_inputs_after=",
        "application_flow_session_pending_actions_after=",
        "application_flow_session_artifacts=draft_plan",
        "application_flow_session_events_before=0",
        "application_flow_session_events_after=2",
        "application_flow_session_event_type=user_reply",
        "application_flow_session_completed_status=completed",
        "application_flow_session_payload_keys=session_id,flow_name,status,current_step,pending_inputs,pending_actions,events,artifacts,metadata,created_at,updated_at"
      ]
    ),
    example(
      "application/feature_flow_report",
      "Application feature-slice report and app-owned flow declaration metadata.",
      expected_fragments: [
        "application_feature_flow_slices=incidents",
        "application_feature_flow_exports=resolve_incident",
        "application_feature_flow_imports=incident_runtime",
        "application_feature_flow_declarations=incident_review",
        "application_feature_flow_pending_inputs=clarification",
        "application_feature_flow_pending_actions=approve_plan",
        "application_feature_flow_status=waiting_for_user",
        "application_feature_flow_web_projection=aligned",
        "application_feature_flow_web_projection_inputs=clarification",
        "application_feature_flow_web_projection_actions=approve_plan",
        "application_feature_flow_surface_metadata=aligned",
        "application_feature_flow_surface_metadata_flows=incident_review"
      ]
    ),
    example(
      "application/capsule_inspection",
      "Application-owned capsule inspection report for non-web and web-capable capsules.",
      expected_fragments: [
        "application_capsule_report_name=operator",
        "application_capsule_report_non_web=true",
        "application_capsule_report_groups=config,contracts,services,spec,web",
        "application_capsule_report_sparse_paths=config,contracts,services,spec,web",
        "application_capsule_report_exports=resolve_incident",
        "application_capsule_report_imports=incident_runtime",
        "application_capsule_report_features=incidents",
        "application_capsule_report_flows=incident_review",
        "application_capsule_report_surfaces=operator_console",
        "application_capsule_report_web_projection=aligned",
        "application_capsule_report_web_projection_flows=incident_review"
      ]
    ),
    example(
      "application/capsule_authoring_dsl",
      "Human capsule authoring DSL that expands to ApplicationBlueprint.",
      expected_fragments: [
        "application_capsule_dsl_name=operator",
        "application_capsule_dsl_equivalent=true",
        "application_capsule_dsl_exports=resolve_incident",
        "application_capsule_dsl_imports=incident_runtime",
        "application_capsule_dsl_features=incidents",
        "application_capsule_dsl_flows=incident_review",
        "application_capsule_dsl_report=operator",
        "application_capsule_dsl_surface=operator_console",
        "application_capsule_dsl_web_projection=aligned"
      ]
    ),
    example(
      "application/capsule_composition",
      "Read-only capsule composition report for explicit exports and imports.",
      expected_fragments: [
        "application_capsule_composition_capsules=incident_core,operator,operator_client",
        "application_capsule_composition_exports=incident_runtime,resolve_incident,operator_console",
        "application_capsule_composition_satisfied=incident_runtime,operator_console",
        "application_capsule_composition_host_satisfied=audit_log",
        "application_capsule_composition_unresolved=",
        "application_capsule_composition_optional_missing=optional_notifier",
        "application_capsule_composition_ready=true",
        "application_capsule_composition_web_exports=operator_console",
        "application_capsule_composition_web_satisfied=operator_console"
      ]
    ),
    example(
      "application/capsule_assembly_plan",
      "Read-only capsule assembly plan over composition readiness and mount intents.",
      expected_fragments: [
        "application_capsule_assembly_capsules=incident_core,operator",
        "application_capsule_assembly_ready=true",
        "application_capsule_assembly_mounts=operator:web:/operator",
        "application_capsule_assembly_composition_ready=true",
        "application_capsule_assembly_unresolved=",
        "application_capsule_assembly_surfaces=operator_console",
        "application_capsule_assembly_surface_kind=web_surface",
        "application_capsule_assembly_web_mount=operator_console:/operator"
      ]
    ),
    example(
      "application/capsule_handoff_manifest",
      "Read-only handoff manifest for portable capsule transfer and wiring review.",
      expected_fragments: [
        "application_capsule_handoff_subject=operator_bundle",
        "application_capsule_handoff_capsules=incident_core,operator",
        "application_capsule_handoff_ready=true",
        "application_capsule_handoff_required=incident_runtime,audit_log",
        "application_capsule_handoff_unresolved=audit_log",
        "application_capsule_handoff_mounts=operator:web:/operator",
        "application_capsule_handoff_surfaces=operator_console",
        "application_capsule_handoff_surface_kind=web_surface",
        "application_capsule_handoff_web_mount=operator_console:/operator"
      ]
    ),
    example(
      "application/capsule_transfer_inventory",
      "Read-only dry-run inventory for declared capsule transfer material.",
      expected_fragments: [
        "application_capsule_transfer_inventory_capsules=operator",
        "application_capsule_transfer_inventory_expected=config,contracts,services,spec,web",
        "application_capsule_transfer_inventory_missing=config,spec,web",
        "application_capsule_transfer_inventory_files=2",
        "application_capsule_transfer_inventory_ready=false",
        "application_capsule_transfer_inventory_surfaces=operator_console",
        "application_capsule_transfer_inventory_surface_path=web",
        "application_capsule_transfer_inventory_web_screens=web/screens"
      ]
    ),
    example(
      "application/capsule_transfer_readiness",
      "Read-only transfer readiness report over handoff manifest and inventory.",
      expected_fragments: [
        "application_capsule_transfer_readiness_ready=false",
        "application_capsule_transfer_readiness_blockers=missing_expected_path,unresolved_required_import",
        "application_capsule_transfer_readiness_warnings=missing_optional_import",
        "application_capsule_transfer_readiness_sources=inventory:3,manifest:2",
        "application_capsule_transfer_readiness_manifest=false",
        "application_capsule_transfer_readiness_inventory=false",
        "application_capsule_transfer_readiness_surfaces=1"
      ]
    ),
    example(
      "application/capsule_transfer_bundle_plan",
      "Read-only transfer bundle plan over readiness and inventory artifacts.",
      expected_fragments: [
        "application_capsule_transfer_bundle_subject=operator_bundle",
        "application_capsule_transfer_bundle_allowed=false",
        "application_capsule_transfer_bundle_capsules=operator",
        "application_capsule_transfer_bundle_files=2",
        "application_capsule_transfer_bundle_blockers=missing_expected_path,unresolved_required_import",
        "application_capsule_transfer_bundle_warnings=missing_optional_import",
        "application_capsule_transfer_bundle_surfaces=1"
      ]
    ),
    example(
      "application/capsule_transfer_bundle_artifact",
      "Explicit transfer bundle artifact writer from an accepted bundle plan.",
      expected_fragments: [
        "application_capsule_transfer_artifact_written=true",
        "application_capsule_transfer_artifact_file=operator_bundle",
        "application_capsule_transfer_artifact_included=2",
        "application_capsule_transfer_artifact_metadata=igniter-transfer-bundle.json",
        "application_capsule_transfer_artifact_refusals=0",
        "application_capsule_transfer_artifact_surfaces=1"
      ]
    ),
    example(
      "application/capsule_transfer_bundle_verification",
      "Read-only verification of a written transfer bundle artifact.",
      expected_fragments: [
        "application_capsule_transfer_verify_valid=true",
        "application_capsule_transfer_verify_included=2",
        "application_capsule_transfer_verify_actual=2",
        "application_capsule_transfer_verify_missing=0",
        "application_capsule_transfer_verify_extra=0",
        "application_capsule_transfer_verify_surfaces=1"
      ]
    ),
    example(
      "application/capsule_transfer_intake_plan",
      "Read-only destination intake plan for a verified transfer bundle artifact.",
      expected_fragments: [
        "application_capsule_transfer_intake_ready=true",
        "application_capsule_transfer_intake_planned=2",
        "application_capsule_transfer_intake_conflicts=0",
        "application_capsule_transfer_intake_blockers=0",
        "application_capsule_transfer_intake_host_wiring=0",
        "application_capsule_transfer_intake_surfaces=1"
      ]
    ),
    example(
      "application/capsule_transfer_apply_plan",
      "Read-only apply operation plan over accepted transfer intake data.",
      expected_fragments: [
        "application_capsule_transfer_apply_executable=true",
        "application_capsule_transfer_apply_operations=4",
        "application_capsule_transfer_apply_blockers=0",
        "application_capsule_transfer_apply_warnings=0",
        "application_capsule_transfer_apply_surfaces=1"
      ]
    ),
    example(
      "application/capsule_transfer_apply_execution",
      "Dry-run-first transfer apply execution over reviewed apply plans.",
      expected_fragments: [
        "application_capsule_transfer_apply_dry_run_committed=false",
        "application_capsule_transfer_apply_commit_committed=true",
        "application_capsule_transfer_apply_applied=4",
        "application_capsule_transfer_apply_refusals=0",
        "application_capsule_transfer_apply_copied=true",
        "application_capsule_transfer_apply_execution_surfaces=1"
      ]
    ),
    example(
      "application/capsule_transfer_applied_verification",
      "Read-only post-apply verification for committed transfer results.",
      expected_fragments: [
        "application_capsule_transfer_applied_verify_valid=true",
        "application_capsule_transfer_applied_verify_committed=true",
        "application_capsule_transfer_applied_verify_verified=4",
        "application_capsule_transfer_applied_verify_findings=0",
        "application_capsule_transfer_applied_verify_refusals=0",
        "application_capsule_transfer_applied_verify_skipped=0",
        "application_capsule_transfer_applied_verify_surfaces=1"
      ]
    ),
    example(
      "application/capsule_transfer_receipt",
      "Read-only transfer receipt over explicit transfer reports.",
      expected_fragments: [
        "application_capsule_transfer_receipt_complete=true",
        "application_capsule_transfer_receipt_valid=true",
        "application_capsule_transfer_receipt_committed=true",
        "application_capsule_transfer_receipt_verified=4",
        "application_capsule_transfer_receipt_findings=0",
        "application_capsule_transfer_receipt_refusals=0",
        "application_capsule_transfer_receipt_skipped=0",
        "application_capsule_transfer_receipt_manual=0",
        "application_capsule_transfer_receipt_surfaces=1"
      ]
    ),
    example(
      "application/capsule_transfer_end_to_end",
      "Complete capsule transfer path from declaration to receipt.",
      expected_fragments: [
        "application_capsule_transfer_end_to_end_ready=true",
        "application_capsule_transfer_end_to_end_bundle_allowed=true",
        "application_capsule_transfer_end_to_end_bundle_verified=true",
        "application_capsule_transfer_end_to_end_intake_accepted=true",
        "application_capsule_transfer_end_to_end_apply_executable=true",
        "application_capsule_transfer_end_to_end_dry_run_committed=false",
        "application_capsule_transfer_end_to_end_committed=true",
        "application_capsule_transfer_end_to_end_applied_valid=true",
        "application_capsule_transfer_end_to_end_receipt_complete=true"
      ]
    ),
    example(
      "application/capsule_agent_transfer",
      "Agent-aware capsule transfer carrying assistant capability evidence.",
      expected_fragments: [
        "application_capsule_agent_transfer_ready=true",
        "application_capsule_agent_transfer_bundle_allowed=true",
        "application_capsule_agent_transfer_receipt_complete=true",
        "application_capsule_agent_transfer_agent=daily_companion",
        "application_capsule_agent_transfer_ai_provider=openai",
        "application_capsule_agent_transfer_tools=complete_reminder",
        "application_capsule_agent_transfer_export=agent"
      ]
    ),
    example(
      "application/capsule_host_activation_readiness",
      "Read-only host activation readiness over explicit host decisions.",
      expected_fragments: [
        "application_capsule_host_activation_ready=true",
        "application_capsule_host_activation_blockers=0",
        "application_capsule_host_activation_warnings=0",
        "application_capsule_host_activation_manual=0",
        "application_capsule_host_activation_mounts=1",
        "application_capsule_host_activation_surfaces=1"
      ]
    ),
    example(
      "application/capsule_host_activation_plan",
      "Read-only host activation review plan over accepted readiness.",
      expected_fragments: [
        "application_capsule_host_activation_plan_executable=true",
        "application_capsule_host_activation_plan_operations=6",
        "application_capsule_host_activation_plan_blockers=0",
        "application_capsule_host_activation_plan_warnings=0",
        "application_capsule_host_activation_plan_mounts=1",
        "application_capsule_host_activation_plan_surfaces=1",
        "application_capsule_host_activation_plan_types=confirm_host_export,confirm_load_path,confirm_provider,confirm_contract,confirm_lifecycle,review_mount_intent"
      ]
    ),
    example(
      "application/capsule_host_activation_plan_verification",
      "Read-only verification of host activation review plans.",
      expected_fragments: [
        "application_capsule_host_activation_plan_verify_valid=true",
        "application_capsule_host_activation_plan_verify_executable=true",
        "application_capsule_host_activation_plan_verify_operations=6",
        "application_capsule_host_activation_plan_verify_verified=6",
        "application_capsule_host_activation_plan_verify_findings=0",
        "application_capsule_host_activation_plan_verify_surfaces=1"
      ]
    ),
    example(
      "application/capsule_host_activation_dry_run",
      "Dry-run-only host activation report over verified plan data.",
      expected_fragments: [
        "application_capsule_host_activation_dry_run=true",
        "application_capsule_host_activation_committed=false",
        "application_capsule_host_activation_executable=true",
        "application_capsule_host_activation_would_apply=4",
        "application_capsule_host_activation_skipped=2",
        "application_capsule_host_activation_refusals=0",
        "application_capsule_host_activation_warnings=0",
        "application_capsule_host_activation_surfaces=1"
      ]
    ),
    example(
      "application/capsule_host_activation_commit_readiness",
      "Read-only host activation commit-readiness over dry-run and adapter evidence.",
      expected_fragments: [
        "application_capsule_host_activation_commit_ready=true",
        "application_capsule_host_activation_commit_allowed=true",
        "application_capsule_host_activation_commit_dry_run=true",
        "application_capsule_host_activation_commit_committed=false",
        "application_capsule_host_activation_commit_blockers=0",
        "application_capsule_host_activation_commit_warnings=0",
        "application_capsule_host_activation_commit_required=3",
        "application_capsule_host_activation_commit_provided=3",
        "application_capsule_host_activation_commit_would_apply=4",
        "application_capsule_host_activation_commit_skipped=2"
      ]
    ),
    example(
      "application/capsule_host_activation_ledger_adapter",
      "File-backed host activation ledger adapter for explicit confirmation acknowledgements.",
      expected_fragments: [
        "application_capsule_host_activation_ledger_committed=true",
        "application_capsule_host_activation_ledger_applied=4",
        "application_capsule_host_activation_ledger_skipped=2",
        "application_capsule_host_activation_ledger_refusals=0",
        "application_capsule_host_activation_ledger_receipts=4",
        "application_capsule_host_activation_ledger_files=4",
        "application_capsule_host_activation_ledger_duplicate=true",
        "application_capsule_host_activation_ledger_readback=4",
        "application_capsule_host_activation_ledger_conflict_committed=false",
        "application_capsule_host_activation_ledger_conflict_refusal=true",
        "application_capsule_host_activation_ledger_digest=true",
        "application_capsule_host_activation_ledger_adapter=file_backed_host_activation_ledger",
        "application_capsule_host_activation_ledger_verify_valid=true",
        "application_capsule_host_activation_ledger_verify_complete=true",
        "application_capsule_host_activation_ledger_verify_findings=0",
        "application_capsule_host_activation_ledger_verify_verified=4",
        "application_capsule_host_activation_receipt_complete=true",
        "application_capsule_host_activation_receipt_valid=true",
        "application_capsule_host_activation_receipt_committed=true",
        "application_capsule_host_activation_receipt_refs=4",
        "application_capsule_host_activation_receipt_host_leftovers=1",
        "application_capsule_host_activation_receipt_web_leftovers=1",
        "application_capsule_host_activation_receipt_separate=true"
      ]
    ),
    example(
      "application/interactive_web_poc",
      "Compact server-backed application/web POC with state-changing interaction.",
      expected_fragments: [
        "interactive_web_poc_initial_status=200",
        "interactive_web_poc_content_type=text/html",
        "interactive_web_poc_initial_open=true",
        "interactive_web_poc_create_form=true",
        "interactive_web_poc_blank_status=303",
        "interactive_web_poc_blank_location=true",
        "interactive_web_poc_blank_refused=true",
        "interactive_web_poc_blank_feedback=true",
        "interactive_web_poc_create_status=303",
        "interactive_web_poc_create_location=true",
        "interactive_web_poc_created_status=200",
        "interactive_web_poc_created_open=true",
        "interactive_web_poc_created_task=true",
        "interactive_web_poc_created_feedback=true",
        "interactive_web_poc_missing_status=303",
        "interactive_web_poc_missing_location=true",
        "interactive_web_poc_post_status=303",
        "interactive_web_poc_resolve_location=true",
        "interactive_web_poc_final_status=200",
        "interactive_web_poc_final_open=true",
        "interactive_web_poc_surface=true",
        "interactive_web_poc_resolve_feedback=true",
        "interactive_web_poc_activity_surface=true",
        "interactive_web_poc_activity_seeded=true",
        "interactive_web_poc_activity_refused=true",
        "interactive_web_poc_activity_created=true",
        "interactive_web_poc_activity_missing=true",
        "interactive_web_poc_activity_resolved=true",
        "interactive_web_poc_resolved=true",
        "interactive_web_poc_events_status=200",
        "interactive_web_poc_events=open=2",
        "interactive_web_poc_events_actions=true",
        "interactive_web_poc_events_seeded=true",
        "interactive_web_poc_events_refused=true",
        "interactive_web_poc_events_created=true",
        "interactive_web_poc_events_missing=true",
        "interactive_web_poc_events_resolved=true",
        "interactive_web_poc_service=operator_task_board"
      ]
    ),
    example(
      "application/signal_inbox_poc",
      "Second application/web POC with signal-specific commands and snapshot rendering.",
      expected_fragments: [
        "signal_inbox_poc_initial_status=200",
        "signal_inbox_poc_content_type=text/html",
        "signal_inbox_poc_initial_open=true",
        "signal_inbox_poc_initial_critical=true",
        "signal_inbox_poc_surface=true",
        "signal_inbox_poc_ack_form=true",
        "signal_inbox_poc_escalate_form=true",
        "signal_inbox_poc_blank_status=303",
        "signal_inbox_poc_blank_location=true",
        "signal_inbox_poc_blank_feedback=true",
        "signal_inbox_poc_missing_status=303",
        "signal_inbox_poc_missing_location=true",
        "signal_inbox_poc_ack_status=303",
        "signal_inbox_poc_ack_location=true",
        "signal_inbox_poc_acknowledged_status=200",
        "signal_inbox_poc_ack_feedback=true",
        "signal_inbox_poc_acknowledged_signal=true",
        "signal_inbox_poc_escalate_status=303",
        "signal_inbox_poc_escalate_location=true",
        "signal_inbox_poc_escalated_status=200",
        "signal_inbox_poc_escalate_feedback=true",
        "signal_inbox_poc_escalated_signal=true",
        "signal_inbox_poc_closed_status=303",
        "signal_inbox_poc_closed_location=true",
        "signal_inbox_poc_final_status=200",
        "signal_inbox_poc_final_open=true",
        "signal_inbox_poc_final_critical=true",
        "signal_inbox_poc_closed_feedback=true",
        "signal_inbox_poc_activity_surface=true",
        "signal_inbox_poc_activity_seeded=true",
        "signal_inbox_poc_activity_blank=true",
        "signal_inbox_poc_activity_missing=true",
        "signal_inbox_poc_activity_acknowledged=true",
        "signal_inbox_poc_activity_escalated=true",
        "signal_inbox_poc_acknowledged=true",
        "signal_inbox_poc_escalated=true",
        "signal_inbox_poc_events_status=200",
        "signal_inbox_poc_events=open=0",
        "signal_inbox_poc_events_actions=true",
        "signal_inbox_poc_events_seeded=true",
        "signal_inbox_poc_events_blank=true",
        "signal_inbox_poc_events_missing=true",
        "signal_inbox_poc_events_acknowledged=true",
        "signal_inbox_poc_events_escalated=true",
        "signal_inbox_poc_service=operator_signal_inbox"
      ]
    ),
    example(
      "application/companion_poc",
      "Ready-to-go Companion app shell with credentials setup state and assistant capsules.",
      expected_fragments: [
        "companion_poc_live_ready=false",
        "companion_poc_open_reminders=2",
        "companion_poc_tracker_logs=1",
        "companion_poc_countdowns=1",
        "companion_poc_store_backend=sqlite",
        "companion_poc_store_file=true",
        "companion_poc_sqlite_persisted=true",
        "companion_poc_summary=true",
        "companion_poc_create_status=303",
        "companion_poc_created_status=200",
        "companion_poc_log_status=303",
        "companion_poc_logged_status=200",
        "companion_poc_complete_status=303",
        "companion_poc_completed_status=200",
        "companion_poc_events_status=200",
        "companion_poc_setup_status=200",
        "companion_poc_hub_status=200",
        "companion_poc_html_status=200",
        "companion_poc_setup_redacted=true",
        "companion_poc_web_surface=true",
        "companion_poc_capsules=true",
        "companion_poc_events_parity=true",
        "companion_poc_agent_capability=true",
        "companion_poc_hub_catalog=horoscope",
        "companion_poc_hub_install=installed",
        "companion_poc_hub_receipt=true"
      ]
    ),
    example(
      "application/lense_poc",
      "One-process Lense codebase intelligence POC core with guided issue receipt.",
      expected_fragments: [
        "lense_poc_scan_id=true",
        "lense_poc_project=sample_shop",
        "lense_poc_ruby_files=2",
        "lense_poc_line_count=50",
        "lense_poc_health_score=68",
        "lense_poc_findings=3",
        "lense_poc_top_finding=complex_file",
        "lense_poc_top_evidence=file:app/services/payment_processor.rb",
        "lense_poc_session_started=session_started",
        "lense_poc_session_id=true",
        "lense_poc_step_done=step_marked_done",
        "lense_poc_note_added=note_added",
        "lense_poc_step_skipped=step_skipped",
        "lense_poc_blank_note=blank_note",
        "lense_poc_missing_finding=finding_not_found",
        "lense_poc_actions=7",
        "lense_poc_receipt_valid=true",
        "lense_poc_receipt_kind=lense_analysis_receipt",
        "lense_poc_receipt_refs=2",
        "lense_poc_receipt_skipped=3",
        "lense_poc_no_mutation=true",
        "lense_poc_service=lense_issue_sessions",
        "lense_poc_web_initial_status=200",
        "lense_poc_web_content_type=text/html",
        "lense_poc_web_surface=true",
        "lense_poc_web_scan_marker=true",
        "lense_poc_web_counts=true",
        "lense_poc_web_findings=true",
        "lense_poc_web_evidence=true",
        "lense_poc_web_report_marker=true",
        "lense_poc_web_refresh_status=303",
        "lense_poc_web_refresh_location=true",
        "lense_poc_web_refresh_feedback=true",
        "lense_poc_web_missing_status=303",
        "lense_poc_web_missing_location=true",
        "lense_poc_web_missing_feedback=true",
        "lense_poc_web_start_status=303",
        "lense_poc_web_start_location=true",
        "lense_poc_web_started_status=200",
        "lense_poc_web_started_feedback=true",
        "lense_poc_web_session=true",
        "lense_poc_web_session_step=true",
        "lense_poc_web_blank_status=303",
        "lense_poc_web_blank_location=true",
        "lense_poc_web_blank_feedback=true",
        "lense_poc_web_invalid_status=303",
        "lense_poc_web_invalid_location=true",
        "lense_poc_web_invalid_feedback=true",
        "lense_poc_web_done_status=303",
        "lense_poc_web_done_location=true",
        "lense_poc_web_done_feedback=true",
        "lense_poc_web_note_status=303",
        "lense_poc_web_note_location=true",
        "lense_poc_web_note_feedback=true",
        "lense_poc_web_skip_status=303",
        "lense_poc_web_skip_location=true",
        "lense_poc_web_final_status=200",
        "lense_poc_web_skip_feedback=true",
        "lense_poc_web_activity=true",
        "lense_poc_web_events_status=200",
        "lense_poc_web_events=scan=lense-scan:",
        "lense_poc_web_events_scan=true",
        "lense_poc_web_events_findings=true",
        "lense_poc_web_events_session=true",
        "lense_poc_web_events_actions=true",
        "lense_poc_web_events_parity=true",
        "lense_poc_web_report_status=200",
        "lense_poc_web_report_valid=true",
        "lense_poc_web_report_endpoint=true"
      ]
    ),
    example(
      "application/chronicle_poc",
      "One-process Chronicle decision compass POC with Web workbench, conflict, and receipt evidence.",
      expected_fragments: [
        "chronicle_poc_missing_proposal=chronicle_unknown_proposal",
        "chronicle_poc_scan=chronicle_scan_created",
        "chronicle_poc_session_id=true",
        "chronicle_poc_proposal=PR-001",
        "chronicle_poc_conflicts=3",
        "chronicle_poc_open_conflicts=2",
        "chronicle_poc_top_conflict=DR-041",
        "chronicle_poc_receipt_not_ready=chronicle_receipt_not_ready",
        "chronicle_poc_acknowledge=chronicle_conflict_acknowledged",
        "chronicle_poc_blank_signer=chronicle_blank_signer",
        "chronicle_poc_signoff=chronicle_signoff_recorded",
        "chronicle_poc_blank_reason=chronicle_blank_reason",
        "chronicle_poc_refusal=chronicle_signoff_refused",
        "chronicle_poc_status=blocked",
        "chronicle_poc_signed=platform",
        "chronicle_poc_refused=security",
        "chronicle_poc_receipt=chronicle_receipt_emitted",
        "chronicle_poc_receipt_id=chronicle-receipt:chronicle-session-pr-001",
        "chronicle_poc_receipt_valid=true",
        "chronicle_poc_events=proposal=PR-001",
        "chronicle_poc_action_count=12",
        "chronicle_poc_fixture_no_mutation=true",
        "chronicle_poc_runtime_sessions=1",
        "chronicle_poc_runtime_receipts=1",
        "chronicle_poc_web_initial_status=200",
        "chronicle_poc_web_content_type=text/html",
        "chronicle_poc_web_surface=true",
        "chronicle_poc_web_initial_proposal=true",
        "chronicle_poc_web_missing_status=303",
        "chronicle_poc_web_missing_location=true",
        "chronicle_poc_web_missing_feedback=true",
        "chronicle_poc_web_scan_status=303",
        "chronicle_poc_web_scan_location=true",
        "chronicle_poc_web_scanned_status=200",
        "chronicle_poc_web_scan_feedback=true",
        "chronicle_poc_web_session=true",
        "chronicle_poc_web_proposal=true",
        "chronicle_poc_web_conflicts=true",
        "chronicle_poc_web_top_conflict=true",
        "chronicle_poc_web_evidence=true",
        "chronicle_poc_web_related=true",
        "chronicle_poc_web_receipt_not_ready_status=303",
        "chronicle_poc_web_receipt_not_ready_location=true",
        "chronicle_poc_web_receipt_not_ready_feedback=true",
        "chronicle_poc_web_ack_status=303",
        "chronicle_poc_web_ack_location=true",
        "chronicle_poc_web_ack_feedback=true",
        "chronicle_poc_web_ack_marker=true",
        "chronicle_poc_web_blank_signer_status=303",
        "chronicle_poc_web_blank_signer_location=true",
        "chronicle_poc_web_blank_signer_feedback=true",
        "chronicle_poc_web_signoff_status=303",
        "chronicle_poc_web_signoff_location=true",
        "chronicle_poc_web_signoff_feedback=true",
        "chronicle_poc_web_signed_marker=true",
        "chronicle_poc_web_blank_reason_status=303",
        "chronicle_poc_web_blank_reason_location=true",
        "chronicle_poc_web_blank_reason_feedback=true",
        "chronicle_poc_web_refusal_status=303",
        "chronicle_poc_web_refusal_location=true",
        "chronicle_poc_web_refusal_feedback=true",
        "chronicle_poc_web_refused_marker=true",
        "chronicle_poc_web_receipt_status=303",
        "chronicle_poc_web_receipt_location=true",
        "chronicle_poc_web_final_status=200",
        "chronicle_poc_web_receipt_feedback=true",
        "chronicle_poc_web_receipt_marker=true",
        "chronicle_poc_web_activity=true",
        "chronicle_poc_web_events_status=200",
        "chronicle_poc_web_events=proposal=PR-001",
        "chronicle_poc_web_events_parity=true",
        "chronicle_poc_web_receipt_endpoint_status=200",
        "chronicle_poc_web_receipt_endpoint=true",
        "chronicle_poc_web_fixture_no_mutation=true",
        "chronicle_poc_web_runtime_sessions=1",
        "chronicle_poc_web_runtime_receipts=1"
      ]
    ),
    example(
      "application/scout_poc",
      "One-process Scout local-source research POC core with provenance receipt evidence.",
      expected_fragments: [
        "scout_poc_blank_topic=scout_blank_topic",
        "scout_poc_no_sources=scout_no_sources",
        "scout_poc_unknown_source=scout_unknown_source",
        "scout_poc_start=scout_session_started",
        "scout_poc_session_id=true",
        "scout_poc_topic=How should engineering teams adopt AI coding assistants?",
        "scout_poc_sources=4",
        "scout_poc_extract=scout_findings_extracted",
        "scout_poc_findings_initial=6",
        "scout_poc_contradictions_initial=1",
        "scout_poc_receipt_not_ready=scout_receipt_not_ready",
        "scout_poc_invalid_checkpoint=scout_invalid_checkpoint",
        "scout_poc_add_source=scout_local_source_added",
        "scout_poc_reextract=scout_findings_extracted",
        "scout_poc_checkpoint=scout_checkpoint_chosen",
        "scout_poc_checkpoint_choice=balanced",
        "scout_poc_status=complete",
        "scout_poc_findings=8",
        "scout_poc_contradictions=1",
        "scout_poc_top_finding=finding-1",
        "scout_poc_top_source=SRC-001#p1",
        "scout_poc_receipt=scout_receipt_emitted",
        "scout_poc_receipt_id=scout-receipt:scout-session-how-should-engineering-teams-adopt-ai-coding-assistants",
        "scout_poc_receipt_valid=true",
        "scout_poc_receipt_citation=true",
        "scout_poc_events=topic=How should engineering teams adopt AI coding assistants?",
        "scout_poc_action_count=16",
        "scout_poc_fixture_no_mutation=true",
        "scout_poc_runtime_sessions=1",
        "scout_poc_runtime_receipts=1",
        "scout_poc_web_initial_status=200",
        "scout_poc_web_content_type=text/html",
        "scout_poc_web_surface=true",
        "scout_poc_web_initial_session=true",
        "scout_poc_web_blank_status=303",
        "scout_poc_web_blank_location=true",
        "scout_poc_web_blank_feedback=true",
        "scout_poc_web_no_sources_status=303",
        "scout_poc_web_no_sources_location=true",
        "scout_poc_web_no_sources_feedback=true",
        "scout_poc_web_unknown_source_status=303",
        "scout_poc_web_unknown_source_location=true",
        "scout_poc_web_unknown_source_feedback=true",
        "scout_poc_web_start_status=303",
        "scout_poc_web_start_location=true",
        "scout_poc_web_started_status=200",
        "scout_poc_web_started_feedback=true",
        "scout_poc_web_session=true",
        "scout_poc_web_topic=true",
        "scout_poc_web_sources=true",
        "scout_poc_web_extract_status=303",
        "scout_poc_web_extract_location=true",
        "scout_poc_web_extracted_status=200",
        "scout_poc_web_extract_feedback=true",
        "scout_poc_web_findings=true",
        "scout_poc_web_provenance=true",
        "scout_poc_web_contradiction=true",
        "scout_poc_web_receipt_not_ready_status=303",
        "scout_poc_web_receipt_not_ready_location=true",
        "scout_poc_web_receipt_not_ready_feedback=true",
        "scout_poc_web_invalid_checkpoint_status=303",
        "scout_poc_web_invalid_checkpoint_location=true",
        "scout_poc_web_invalid_checkpoint_feedback=true",
        "scout_poc_web_add_source_status=303",
        "scout_poc_web_add_source_location=true",
        "scout_poc_web_add_source_feedback=true",
        "scout_poc_web_added_source=true",
        "scout_poc_web_reextract_status=303",
        "scout_poc_web_reextract_location=true",
        "scout_poc_web_reextracted_status=200",
        "scout_poc_web_reextracted_findings=true",
        "scout_poc_web_checkpoint_status=303",
        "scout_poc_web_checkpoint_location=true",
        "scout_poc_web_checkpoint_feedback=true",
        "scout_poc_web_checkpoint_marker=true",
        "scout_poc_web_receipt_status=303",
        "scout_poc_web_receipt_location=true",
        "scout_poc_web_final_status=200",
        "scout_poc_web_receipt_feedback=true",
        "scout_poc_web_receipt_marker=true",
        "scout_poc_web_activity=true",
        "scout_poc_web_events_status=200",
        "scout_poc_web_events=topic=How should engineering teams adopt AI coding assistants?",
        "scout_poc_web_events_parity=true",
        "scout_poc_web_receipt_endpoint_status=200",
        "scout_poc_web_receipt_endpoint=true",
        "scout_poc_web_fixture_no_mutation=true",
        "scout_poc_web_runtime_sessions=1",
        "scout_poc_web_runtime_receipts=1"
      ]
    ),
    example(
      "application/dispatch_poc",
      "One-process Dispatch incident command POC core with handoff receipt evidence.",
      expected_fragments: [
        "dispatch_poc_unknown_incident=dispatch_unknown_incident",
        "dispatch_poc_open=dispatch_incident_opened",
        "dispatch_poc_session_id=true",
        "dispatch_poc_incident=INC-001",
        "dispatch_poc_title=Checkout errors after payments deploy",
        "dispatch_poc_receipt_not_ready=dispatch_receipt_not_ready",
        "dispatch_poc_triage=dispatch_triage_completed",
        "dispatch_poc_severity=critical",
        "dispatch_poc_cause=migration",
        "dispatch_poc_events=4",
        "dispatch_poc_routes=payments-platform,database-oncall",
        "dispatch_poc_unknown_team=dispatch_unknown_team",
        "dispatch_poc_invalid_assignment=dispatch_invalid_assignment",
        "dispatch_poc_blank_escalation=dispatch_blank_escalation_reason",
        "dispatch_poc_assignment=dispatch_owner_assigned",
        "dispatch_poc_assigned_team=payments-platform",
        "dispatch_poc_handoff_ready=true",
        "dispatch_poc_status=complete",
        "dispatch_poc_receipt=dispatch_receipt_emitted",
        "dispatch_poc_receipt_id=dispatch-receipt:dispatch-session-inc-001",
        "dispatch_poc_receipt_valid=true",
        "dispatch_poc_receipt_citation=true",
        "dispatch_poc_receipt_deferred=true",
        "dispatch_poc_events_read=incident=INC-001",
        "dispatch_poc_action_count=15",
        "dispatch_poc_fixture_no_mutation=true",
        "dispatch_poc_runtime_sessions=1",
        "dispatch_poc_runtime_receipts=1",
        "dispatch_poc_web_initial_status=200",
        "dispatch_poc_web_content_type=text/html",
        "dispatch_poc_web_surface=true",
        "dispatch_poc_web_initial_incident=true",
        "dispatch_poc_web_unknown_incident_status=303",
        "dispatch_poc_web_unknown_incident_location=true",
        "dispatch_poc_web_unknown_incident_feedback=true",
        "dispatch_poc_web_open_status=303",
        "dispatch_poc_web_open_location=true",
        "dispatch_poc_web_opened_status=200",
        "dispatch_poc_web_open_feedback=true",
        "dispatch_poc_web_incident=true",
        "dispatch_poc_web_service=true",
        "dispatch_poc_web_receipt_not_ready_status=303",
        "dispatch_poc_web_receipt_not_ready_location=true",
        "dispatch_poc_web_receipt_not_ready_feedback=true",
        "dispatch_poc_web_triage_status=303",
        "dispatch_poc_web_triage_location=true",
        "dispatch_poc_web_triaged_status=200",
        "dispatch_poc_web_triage_feedback=true",
        "dispatch_poc_web_severity=true",
        "dispatch_poc_web_cause=true",
        "dispatch_poc_web_events=true",
        "dispatch_poc_web_event_marker=true",
        "dispatch_poc_web_citation=true",
        "dispatch_poc_web_route=true",
        "dispatch_poc_web_unknown_team_status=303",
        "dispatch_poc_web_unknown_team_location=true",
        "dispatch_poc_web_unknown_team_feedback=true",
        "dispatch_poc_web_invalid_assignment_status=303",
        "dispatch_poc_web_invalid_assignment_location=true",
        "dispatch_poc_web_invalid_assignment_feedback=true",
        "dispatch_poc_web_blank_escalation_status=303",
        "dispatch_poc_web_blank_escalation_location=true",
        "dispatch_poc_web_blank_escalation_feedback=true",
        "dispatch_poc_web_assignment_status=303",
        "dispatch_poc_web_assignment_location=true",
        "dispatch_poc_web_assigned_status=200",
        "dispatch_poc_web_assignment_feedback=true",
        "dispatch_poc_web_assigned_team=true",
        "dispatch_poc_web_handoff_ready=true",
        "dispatch_poc_web_receipt_status=303",
        "dispatch_poc_web_receipt_location=true",
        "dispatch_poc_web_final_status=200",
        "dispatch_poc_web_receipt_feedback=true",
        "dispatch_poc_web_receipt_marker=true",
        "dispatch_poc_web_receipt_valid=true",
        "dispatch_poc_web_activity=true",
        "dispatch_poc_web_events_status=200",
        "dispatch_poc_web_events=incident=INC-001",
        "dispatch_poc_web_events_parity=true",
        "dispatch_poc_web_receipt_endpoint_status=200",
        "dispatch_poc_web_receipt_endpoint=true",
        "dispatch_poc_web_fixture_no_mutation=true",
        "dispatch_poc_web_runtime_sessions=1",
        "dispatch_poc_web_runtime_receipts=1"
      ]
    ),
    example(
      "application/mounts",
      "Generic application mount registry for web, agent, and future interaction surfaces.",
      expected_fragments: [
        "application_mount_names=agent_bus,operator_console",
        "application_mount_web_kind=web",
        "application_mount_web_at=/operator",
        "application_mount_web_capabilities=screen,stream",
        "application_mount_web_target=OperatorConsole",
        "application_mount_manifest=agent_bus,operator_console",
        "application_mount_snapshot=agent,web"
      ]
    ),
    example(
      "application/web_mount",
      "Web-owned mount bound to a finalized application environment.",
      expected_fragments: [
        "application_web_mount_status=200",
        "application_web_mount_content_type=text/html",
        "application_web_mount_manifest=true",
        "application_web_mount_route=true",
        "application_web_mount_service=true",
        "application_web_mount_capabilities=true",
        "application_web_mount_registration=web",
        "application_web_mount_command=contract:Contracts::ResolveIncident",
        "application_web_mount_stream=projection:Projections::ClusterEvents",
        "application_web_mount_command_shape=contract",
        "application_web_mount_stream_shape=projection"
      ]
    ),
    example(
      "application/web_surface_structure",
      "Web-owned surface groups inside compact and expanded application capsules.",
      expected_fragments: [
        "application_web_surface_compact_root=web",
        "application_web_surface_expanded_root=app/web",
        "application_web_surface_compact_screens=web/screens",
        "application_web_surface_expanded_screens=app/web/screens",
        "application_web_surface_groups=screens,pages,components,projections,webhooks,assets",
        "application_web_surface_active_compact=config,spec,web",
        "application_web_surface_active_non_web=config,contracts,services,spec",
        "application_web_surface_non_web=false",
        "application_web_surface_projection_path=web/projections"
      ]
    ),
    example(
      "application/web_surface_manifest",
      "Web-owned surface manifest lifted into capsule export metadata.",
      expected_fragments: [
        "application_web_manifest_name=operator_console",
        "application_web_manifest_path=/operator",
        "application_web_manifest_capsule_export=web_surface:operator_console",
        "application_web_manifest_exports=page:/,screen:/execution,command:/incidents/:id/resolve,query:/status,stream:/events,screen:execution",
        "application_web_manifest_pending_inputs=review_note",
        "application_web_manifest_pending_actions=pause",
        "application_web_manifest_streams=events",
        "application_web_manifest_chats=Agents::ProjectLead",
        "application_web_manifest_contract=true",
        "application_web_manifest_service=true",
        "application_web_manifest_projection=true",
        "application_web_manifest_agent=true"
      ]
    ),
    example(
      "application/agent_native_plan_review",
      "Agent-native plan review flow using application sessions and web interaction metadata.",
      expected_fragments: [
        "agent_native_plan_review_session_kind=flow",
        "agent_native_plan_review_status=waiting_for_user",
        "agent_native_plan_review_pending_inputs=clarification",
        "agent_native_plan_review_pending_actions=approve_plan",
        "agent_native_plan_review_artifacts=draft_plan",
        "agent_native_plan_review_events_before=0",
        "agent_native_plan_review_events_after=1",
        "agent_native_plan_review_surface_imports=projection:Projections::PlanReviewEvents,agent:Agents::ProjectLead,contract:Contracts::ApprovePlan",
        "agent_native_plan_review_surface_exports=screen:/plan-review,screen:plan_review",
        "agent_native_plan_review_manifest_export=web_surface"
      ]
    ),
    example(
      "cluster/incidents",
      "Failover planning plus durable incident history and active incident state.",
      expected_fragments: [
        "cluster_incident_plan_targets=order-42",
        "cluster_incident_failed_status=failed",
        "cluster_incident_history=2",
        "cluster_incident_last_resolution=recovered",
        "cluster_active_incidents_after=0"
      ]
    ),
    example(
      "cluster/incident_workflow",
      "Operator workflow actions over durable active incidents.",
      expected_fragments: [
        "cluster_incident_workflow_before=silenced",
        "cluster_incident_workflow_actions=acknowledged,assigned,silenced,resolved",
        "cluster_incident_workflow_active_before=1",
        "cluster_incident_workflow_after=resolved",
        "cluster_incident_workflow_active_after=0"
      ]
    ),
    example(
      "cluster/mesh_diagnostics",
      "Mesh execution retry trace, projection report, and operator-facing diagnostics.",
      expected_fragments: [
        "cluster_mesh_plan_kind=ownership",
        "cluster_mesh_status=completed",
        "cluster_mesh_attempts=pricing_node_a:failed,pricing_node_b:completed",
        "cluster_mesh_projection_mode=mesh_candidates",
        "cluster_mesh_diagnostics_events=projection,mesh_attempt,mesh_attempt,mesh",
        "cluster_mesh_trace_id=mesh/ownership/pricing_node_a/1"
      ]
    ),
    example(
      "cluster/remediation",
      "Remediation planning and execution over active cluster incidents.",
      expected_fragments: [
        "cluster_remediation_mode=planned",
        "cluster_remediation_steps=1",
        "cluster_remediation_actions=retry_failover",
        "cluster_remediation_target=order-42",
        "cluster_remediation_status=completed"
      ]
    ),
    example(
      "cluster/routing",
      "Cluster routing and remote compose over application transport seams.",
      expected_fragments: [
        "cluster_compose_total=120.0",
        "cluster_route_peer=pricing_node",
        "cluster_route_mode=capability"
      ]
    ),
    example(
      "contracts/aggregates",
      "Lookup and aggregate packs lowered over the contracts kernel.",
      expected_fragments: ["aggregate_total_amount=60", "aggregate_average_amount=20.0"]
    ),
    example(
      "contracts/auditing",
      "Audit snapshots and diagnostics over explicit execution results.",
      expected_fragments: [
        "contracts_auditing_event_types=[:input_observed, :compute_observed, :output_observed]",
        "contracts_auditing_state={:status=>:succeeded, :value=>120.0}",
        "contracts_auditing_sections=baseline_summary,audit_summary"
      ]
    ),
    example(
      "contracts/branching",
      "Decision-style branch routing lowered into compute semantics.",
      expected_fragments: [
        "contracts_branch_case=international",
        "contracts_branch_value=priority_international",
        "contracts_branch_matcher=matches"
      ]
    ),
    example(
      "contracts/basic_pricing",
      "Smallest end-to-end pricing flow over igniter-contracts.",
      expected_fragments: ["contracts_basic_gross_total=120.0", "contracts_basic_updated_gross_total=180.0"]
    ),
    example(
      "contracts/class_pricing",
      "Human-facing contract class DSL with result readers and input updates.",
      expected_fragments: [
        "contracts_class_gross_total=120.0",
        "contracts_class_output=120.0",
        "contracts_class_updated_gross_total=180.0",
        "contracts_class_success=true"
      ]
    ),
    example(
      "contracts/class_callable",
      "Contract class DSL using call: to reuse a service object step.",
      expected_fragments: [
        "contracts_class_callable_subtotal=40",
        "contracts_class_callable_total=36.0",
        "contracts_class_callable_outputs=subtotal,total"
      ]
    ),
    example(
      "contracts/step_result",
      "Optional StepResultPack with visible step nodes and fail-fast trace.",
      expected_fragments: [
        "contracts_step_result_success=false",
        "contracts_step_result_failure_code=halted_dependency",
        "contracts_step_result_halted_dependency=market",
        "contracts_step_result_trace=validated_params:success,market:failed,business_window:failed"
      ]
    ),
    example(
      "contracts/lang_foundation",
      "Additive Igniter Lang Ruby backend wrapper and metadata descriptors.",
      expected_fragments: [
        "lang_foundation_latest_price=120.0",
        "lang_foundation_descriptor=history",
        "lang_foundation_report_ok=true",
        "lang_foundation_metadata_declared_not_enforced=true"
      ]
    ),
    example(
      "contracts/embed_class_registration",
      "Embed host registration for contract classes with explicit and inferred names.",
      expected_fragments: [
        "embed_class_explicit_total=120.0",
        "embed_class_inferred_total=180.0",
        "embed_class_registration_kind=class"
      ]
    ),
    example(
      "contracts/contractable_shadow",
      "Contractable shadow comparison and observed-service capture over generic services.",
      expected_fragments: [
        "contractable_primary_total=120.0",
        "contractable_shadow_match=false",
        "contractable_shadow_accepted=true",
        "contractable_shadow_policy=shape",
        "contractable_observed_mode=observe"
      ]
    ),
    example(
      "contracts/embed_human_sugar",
      "Embed human sugar DSL for host contracts, generated runners, adapters, events, and explicit capabilities.",
      expected_fragments: [
        "embed_sugar_primary_total=120.0",
        "embed_sugar_runner_names=price_quote",
        "embed_sugar_shadow_match=false",
        "embed_sugar_shadow_accepted=true",
        "embed_sugar_redacted_inputs=amount,customer_id",
        "embed_sugar_divergence_events=1",
        "embed_sugar_capabilities=logging:contract,reporting:callable_adapter",
        "embed_sugar_runner_accessor=contractable(:price_quote)"
      ]
    ),
    example(
      "contracts/build_effect_executor_pack",
      "Inline effect/executor pack authoring over the public contracts API.",
      expected_fragments: ["custom_executor_output=15", "custom_result_entries=1"]
    ),
    example(
      "contracts/build_your_own_pack",
      "Inline custom pack authoring over the public igniter-contracts API.",
      expected_fragments: ["custom_pack_slug=hello-igniter-contracts", "custom_pack_findings=missing_slug_sources"]
    ),
    example(
      "contracts/capabilities",
      "Capability declarations, graph requirements, and policy checks.",
      expected_fragments: [
        "contracts_capabilities_required={:fetched=>[:network, :database]}",
        "contracts_capabilities_invalid=true",
        "contracts_capabilities_violation_kinds=[:denied_capability]"
      ]
    ),
    example(
      "contracts/commerce",
      "Commerce preset built from contracts-native extension packs.",
      expected_fragments: ["commerce_grand_total=38.0", "execution_report_sections=baseline_summary,execution_report"]
    ),
    example(
      "contracts/collection",
      "Explicit keyed collection execution over Dataflow and Incremental sessions.",
      expected_fragments: [
        "contracts_collection_total=36.0",
        "contracts_collection_keys=a,b",
        "contracts_collection_summary={:mode=>:incremental, :total=>2"
      ]
    ),
    example(
      "contracts/compose_your_own_packs",
      "One custom pack depending on another through the public kernel API.",
      expected_fragments: ["composed_pack_has_slug=true", "composed_pack_url=https://docs.example.test/hello-pack-composition"]
    ),
    example(
      "contracts/composition",
      "Explicit nested contract invocation through ComposePack.",
      expected_fragments: [
        "contracts_compose_tax=20.0",
        "contracts_compose_total=120.0",
        "contracts_compose_nested_outputs=tax,total"
      ]
    ),
    example(
      "contracts/content_addressing",
      "Content-addressed pure callable reuse over explicit contracts execution.",
      expected_fragments: [
        "contracts_content_addressing_tax=20.0",
        "contracts_content_addressing_calls=1",
        "contracts_content_addressing_key=ca:",
        "contracts_content_addressing_stats={:size=>1, :hits=>1, :misses=>1}"
      ]
    ),
    example(
      "contracts/create_pack",
      "CreatorPack scaffold, audit, wizard, and writer workflow.",
      expected_fragments: [
        "creator_pack_constant=Acme::IgniterPacks::SlugPack",
        "creator_report_audit_ok=false",
        "creator_report_missing_nodes=draft_slug",
        "creator_workflow_stage=implement_pack",
        "creator_wizard_current_decision=scope",
        "creator_wizard_examples=examples/contracts/build_effect_executor_pack.rb,examples/contracts/journal.rb",
        "creator_writer_files_written=4"
      ]
    ),
    example(
      "contracts/dataflow",
      "Dataflow session built on top of IncrementalPack.",
      expected_fragments: [
        "contracts_dataflow_round1=added(3)",
        "contracts_dataflow_total=3",
        "contracts_dataflow_window_keys=s2,s3,s4"
      ]
    ),
    example(
      "contracts/debug",
      "DebugPack report over profile seams, execution, and provenance.",
      expected_fragments: [
        "contracts_debug_ok=true",
        "contracts_debug_output=40.0",
        "contracts_debug_sections=baseline_summary,execution_report,provenance,debug"
      ]
    ),
    example(
      "contracts/debug_pack_authoring",
      "DebugPack audit for an incomplete custom pack before finalize.",
      expected_fragments: [
        "contracts_pack_audit_ok=false",
        "contracts_pack_audit_missing_nodes=draft_slug",
        "contracts_pack_audit_finalize_error=true"
      ]
    ),
    example(
      "contracts/diagnostics",
      "Structured diagnostics report for contracts execution.",
      expected_fragments: ["contracts_diagnostics_output=120.0",
                           "contracts_diagnostics_sections=baseline_summary,execution_report"]
    ),
    example(
      "contracts/differential",
      "Differential comparison and explicit shadow execution.",
      expected_fragments: [
        "contracts_differential_match=false",
        "contracts_differential_diverged=[:tax, :total]",
        "contracts_differential_candidate_only=[:discount]",
        "contracts_differential_tax_tolerated=true",
        "contracts_shadow_match=false"
      ]
    ),
    example(
      "contracts/effects",
      "Baseline effect node plus effect adapter execution seams.",
      expected_fragments: [
        "contracts_effect_payload={:quote_total=>120, :event=>\"quote_requested_direct\"}",
        "contracts_graph_effect_output={:quote_total=>120, :event=>\"quote_requested\"}",
        "contracts_effect_entries=2",
        "contracts_effect_sections=baseline_summary"
      ]
    ),
    example(
      "contracts/incremental",
      "Incremental session flows over a compiled graph.",
      expected_fragments: [
        "contracts_incremental_output=89.6",
        "contracts_incremental_skipped=[:tier_discount, :adjusted_price]",
        "contracts_incremental_recomputed=1"
      ]
    ),
    example(
      "contracts/introspection",
      "Structured compilation, result, and diagnostics reports.",
      expected_fragments: ["contracts_introspection_ok=true",
                           "contracts_introspection_sections=baseline_summary,execution_report"]
    ),
    example(
      "contracts/invariants",
      "Explicit invariant suites and multi-case verification.",
      expected_fragments: [
        "contracts_invariants_valid=true",
        "contracts_invariants_cases_valid=false",
        "contracts_invariants_invalid_case_count=1"
      ]
    ),
    example(
      "contracts/journal",
      "Operational effect and executor pack over igniter-contracts.",
      expected_fragments: ["journal_execution_output=15", "journal_result_entries=1"]
    ),
    example(
      "contracts/mcp",
      "MCP tooling adapter over debug and creator surfaces.",
      expected_fragments: [
        "contracts_mcp_session_apply_args=session,updates",
        "contracts_mcp_wizard_decision=scope",
        "contracts_mcp_session_ready=true",
        "contracts_mcp_debug_output=12",
        "contracts_mcp_write_files=4"
      ]
    ),
    example(
      "contracts/mcp_host",
      "JSON-RPC host entrypoint over the MCP adapter package.",
      expected_fragments: [
        "contracts_mcp_host_protocol=2024-11-05",
        "contracts_mcp_host_tools=true",
        "contracts_mcp_host_decision=scope",
        "contracts_mcp_host_error=false",
        "contracts_mcp_host_invalid_code=-32602"
      ]
    ),
    example(
      "contracts/mcp_server",
      "Tool-catalog server wrapper over igniter-mcp-adapter.",
      expected_fragments: [
        "contracts_mcp_server_required=session,updates",
        "contracts_mcp_server_tool=creator_session_apply",
        "contracts_mcp_server_error=false",
        "contracts_mcp_server_decision=scope"
      ]
    ),
    example(
      "contracts/provenance",
      "Lineage and provenance reports over execution results.",
      expected_fragments: [
        "contracts_provenance_output=360.0",
        "contracts_provenance_path=[:grand_total, :subtotal, :base_price]",
        "contracts_provenance_sections=baseline_summary,provenance"
      ]
    ),
    example(
      "contracts/reactive",
      "Explicit subscriptions over execution and incremental change events.",
      expected_fragments: [
        "contracts_reactive_status=succeeded",
        "contracts_reactive_produced=[120.0, 180.0]",
        "contracts_reactive_event_types=[:execution_succeeded, :output_produced, :output_changed, :execution_exited]"
      ]
    ),
    example(
      "contracts/saga",
      "Explicit compensation registry and SagaPack execution.",
      expected_fragments: [
        "contracts_saga_success=false",
        "contracts_saga_failed_node=:charge_card",
        "contracts_saga_compensations=[:reserve_stock]",
        "contracts_saga_sections=baseline_summary,execution_report"
      ]
    )
  ].freeze

  def self.all
    ALL
  end

  def self.smoke
    ALL.select(&:smoke?)
  end

  def self.autonomous
    ALL.select(&:autonomous?)
  end

  def self.find(name)
    normalized = normalize(name)

    ALL.find do |example|
      normalize(example.id) == normalized ||
        normalize(example.path) == normalized ||
        normalize(example.path.sub(%r{\Aexamples/}, "")) == normalized
    end
  end

  def self.normalize(name)
    value = name.to_s
    value = value.sub(%r{\Aexamples/}, "")
    value = value.delete_prefix("./")
    value.sub(/\.rb\z/, "")
  end
end
