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

  def self.example(id, summary, expected_fragments:, timeout: 10, args: nil, autonomous: true, runnable: true, smoke: true, skip_reason: nil)
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
      expected_fragments: ["contracts_diagnostics_output=120.0", "contracts_diagnostics_sections=baseline_summary,execution_report"]
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
      expected_fragments: ["contracts_introspection_ok=true", "contracts_introspection_sections=baseline_summary,execution_report"]
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
    value = value.sub(/\.rb\z/, "")
    value
  end
end
