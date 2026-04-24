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
