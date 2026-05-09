#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "pathname"

require_relative "../compatibility_report_composition/compatibility_report_composition"

module RuntimeReportEnforcementPreflight
  CARD = "S3-R14-C4-P"
  TRACK = "runtime-report-enforcement-preflight-v0"
  SUMMARY_PATH = Pathname(__dir__) / "runtime_report_enforcement_preflight_summary.json"

  module_function

  def preflight(report)
    trace = []

    compatibility = check_compatibility_report(report)
    trace << compatibility.fetch("stage")
    return blocked(compatibility, trace) unless compatibility.fetch("status") == "ok"

    token = check_approval_token(report)
    trace << token.fetch("stage")
    return blocked(token, trace) unless token.fetch("status") == "ok"

    gate = check_gate_state(report)
    trace << gate.fetch("stage")
    return blocked(gate, trace) unless gate.fetch("status") == "ok"

    scope = check_scope(report)
    trace << scope.fetch("stage")
    return blocked(scope, trace) unless scope.fetch("status") == "ok"

    cache_key = check_cache_key(report)
    trace << cache_key.fetch("stage")
    return blocked(cache_key, trace) unless cache_key.fetch("status") == "ok"

    executor_backend = check_executor_backend(report)
    trace << executor_backend.fetch("stage")
    return blocked(executor_backend, trace) unless executor_backend.fetch("status") == "ok"

    ready(executor_backend, trace)
  end

  def check_compatibility_report(report)
    return diagnostic("compatibility_report", "blocked", "compatibility_report.missing") unless report.is_a?(Hash)
    return diagnostic("compatibility_report", "blocked", "compatibility_report.kind_invalid") unless report["kind"] == "compatibility_report"

    composition = report["composition"] || {}
    return diagnostic("compatibility_report", "blocked", "compatibility_report.split_report_rejected") unless composition["mode"] == "single_report"
    return diagnostic("compatibility_report", "blocked", "compatibility_report.split_report_rejected") unless composition["split_fragments_allowed"] == false

    diagnostics = report["composition_diagnostics"] || {}
    return diagnostic("compatibility_report", "blocked", diagnostics.fetch("problems", ["compatibility_report.composition_blocked"]).first) unless diagnostics["status"] == "ok"

    backend = check_backend_descriptor(report)
    return diagnostic("compatibility_report", "blocked", backend.fetch("reason_code"), "substage" => backend.fetch("stage")) unless backend["status"] == "ok"

    diagnostic("compatibility_report", "ok", "compatibility_report.composed")
  end

  def check_backend_descriptor(report)
    backend = report["backend_check"] || {}
    return diagnostic("backend_descriptor", "blocked", "runtime.backend_descriptor_not_trusted") unless backend["decision"] == "trusted_metadata"

    descriptor = backend["temporal_backend_descriptor"] || {}
    required = %w[descriptor_hash descriptor_registry_hash capabilities history_axes cursor_policy]
    missing = required.reject { |field| present?(descriptor[field]) }
    return diagnostic("backend_descriptor", "blocked", "runtime.backend_descriptor_malformed", "missing" => missing) unless missing.empty?

    diagnostic("backend_descriptor", "ok", "runtime.backend_descriptor_trusted")
  end

  def check_gate_state(report)
    gate = report["runtime_gate_check"] || {}
    return diagnostic("gate_state", "blocked", gate.fetch("reason_code", "runtime.temporal_gate3_closed")) unless gate["decision"] == "open"

    diagnostic("gate_state", "ok", "runtime.temporal_gate3_open")
  end

  def check_approval_token(report)
    approval = report["executor_approval_check"] || {}
    return diagnostic("approval_token", "blocked", approval.fetch("reason_code", "runtime.executor_approval_missing")) unless approval["decision"] == "ok"

    diagnostic("approval_token", "ok", "runtime.executor_approval_token_valid")
  end

  def check_scope(report)
    return diagnostic("scope", "blocked", "runtime.temporal_scope_excluded") unless report["fragment_class"] == "TEMPORAL"

    executor = report["executor_readiness"] || {}
    operation = executor["operation"]
    return diagnostic("scope", "blocked", "runtime.temporal_scope_excluded") unless operation == "history_valid_time_read"

    descriptor = report.fetch("backend_check").fetch("temporal_backend_descriptor")
    capabilities = Array(descriptor["capabilities"])
    axes = Array(descriptor["history_axes"])
    return diagnostic("scope", "blocked", "runtime.history_read_capability_missing") unless capabilities.include?("history_read")
    return diagnostic("scope", "blocked", "runtime.valid_time_axis_missing") unless axes.include?("valid_time")

    diagnostic("scope", "ok", "runtime.history_valid_time_scope_ok")
  end

  def check_cache_key(report)
    cache = report["cache_key_check"] || {}
    return diagnostic("cache_key", "blocked", cache.fetch("reason_code", "runtime.temporal_cache_schema_mismatch")) unless cache["decision"] == "ok"
    return diagnostic("cache_key", "blocked", "runtime.temporal_cache_schema_mismatch") unless cache["fragment"] == "TEMPORAL"
    return diagnostic("cache_key", "blocked", "runtime.temporal_cache_coordinate_missing") unless Array(cache["required_coordinates"]).include?("valid_time")

    diagnostic("cache_key", "ok", "runtime.temporal_cache_key_valid")
  end

  def check_executor_backend(report)
    readiness = report["evaluation_readiness"] || {}
    return diagnostic("executor_backend", "blocked", readiness.fetch("reason_code", "runtime.evaluation_not_ready")) unless readiness["decision"] == "ready"
    return diagnostic("executor_backend", "blocked", "compatibility_report.report_only_not_runtime_authority") unless report["runtime_enforced"] == true
    return diagnostic("executor_backend", "blocked", "compatibility_report.report_only_not_runtime_authority") unless report["report_only"] == false

    executor = report["executor_readiness"] || {}
    return diagnostic("executor_backend", "blocked", executor.fetch("reason_code", "runtime.temporal_executor_missing")) unless executor["decision"] == "ok"

    diagnostic("executor_backend", "ok", "runtime.preflight_ready_no_call_attempted")
  end

  def diagnostic(stage, status, reason_code, extra = {})
    {
      "stage" => stage,
      "status" => status,
      "reason_code" => reason_code
    }.merge(extra)
  end

  def blocked(diagnostic, trace)
    {
      "status" => "blocked",
      "reason_code" => diagnostic.fetch("reason_code"),
      "blocked_stage" => diagnostic.fetch("stage"),
      "stage_trace" => trace,
      "blocks_before_executor" => true,
      "operation_check" => no_live_operations
    }
  end

  def ready(diagnostic, trace)
    {
      "status" => "ready",
      "reason_code" => diagnostic.fetch("reason_code"),
      "blocked_stage" => nil,
      "stage_trace" => trace,
      "blocks_before_executor" => false,
      "operation_check" => no_live_operations
    }
  end

  def no_live_operations
    {
      "temporal_executor_call_attempted" => false,
      "cache_call_attempted" => false,
      "live_tbackend_call_attempted" => false,
      "ledger_call_attempted" => false,
      "temporal_read_attempted" => false
    }
  end

  def present?(value)
    !value.nil? && value != "" && value != [] && value != {}
  end

  def composed_report(input_overrides = {})
    base = CompatibilityReportComposition.base_inputs.merge(
      "requested_report_mode" => "runtime_enforced",
      "runtime_gate_check" => CompatibilityReportComposition.runtime_gate_check(open: true)
    )
    CompatibilityReportComposition.compose(base.merge(input_overrides))
  end

  def report_only_all_checks_ok
    base = CompatibilityReportComposition.base_inputs.merge(
      "runtime_gate_check" => CompatibilityReportComposition.runtime_gate_check(open: true)
    )
    CompatibilityReportComposition.compose(base)
  end

  def with_report_mutation(report)
    copy = JSON.parse(JSON.generate(report))
    yield copy
    copy
  end

  def assert(label)
    raise "FAIL #{label}" unless yield

    puts "PASS #{label}"
  end

  def write_summary(summary)
    SUMMARY_PATH.write("#{JSON.pretty_generate(summary)}\n")
    SUMMARY_PATH
  end
end

if $PROGRAM_NAME == __FILE__
  include RuntimeReportEnforcementPreflight

  ready_report = RuntimeReportEnforcementPreflight.composed_report
  cases = {
    "ready_preflight" => RuntimeReportEnforcementPreflight.preflight(ready_report),
    "split_report_blocks_at_compatibility_report" => RuntimeReportEnforcementPreflight.preflight(
      RuntimeReportEnforcementPreflight.composed_report("composition_mode" => "split_report_and_enforcement")
    ),
    "report_only_blocks_before_executor_backend" => RuntimeReportEnforcementPreflight.preflight(
      RuntimeReportEnforcementPreflight.report_only_all_checks_ok
    ),
    "backend_descriptor_blocked" => RuntimeReportEnforcementPreflight.preflight(
      RuntimeReportEnforcementPreflight.composed_report("backend_check" => CompatibilityReportComposition.backend_check("blocked"))
    ),
    "gate_closed_after_token_check" => RuntimeReportEnforcementPreflight.preflight(
      RuntimeReportEnforcementPreflight.composed_report("runtime_gate_check" => CompatibilityReportComposition.runtime_gate_check(open: false))
    ),
    "approval_missing_blocks_before_gate" => RuntimeReportEnforcementPreflight.preflight(
      RuntimeReportEnforcementPreflight.composed_report("executor_approval_check" => CompatibilityReportComposition.approval_check("blocked"))
    ),
    "approval_missing_with_gate_closed_blocks_before_gate" => RuntimeReportEnforcementPreflight.preflight(
      RuntimeReportEnforcementPreflight.composed_report(
        "executor_approval_check" => CompatibilityReportComposition.approval_check("blocked"),
        "runtime_gate_check" => CompatibilityReportComposition.runtime_gate_check(open: false)
      )
    ),
    "bihistory_scope_excluded_before_cache" => RuntimeReportEnforcementPreflight.preflight(
      RuntimeReportEnforcementPreflight.composed_report("executor_readiness" => CompatibilityReportComposition.executor_readiness("ok").merge("operation" => "bihistory_at"))
    ),
    "cache_key_blocks_before_executor_backend" => RuntimeReportEnforcementPreflight.preflight(
      RuntimeReportEnforcementPreflight.composed_report("cache_key_check" => CompatibilityReportComposition.cache_key_check("blocked"))
    ),
    "executor_missing_blocks_before_backend_call" => RuntimeReportEnforcementPreflight.preflight(
      RuntimeReportEnforcementPreflight.composed_report("executor_readiness" => CompatibilityReportComposition.executor_readiness("blocked"))
    ),
    "missing_descriptor_hash_blocks_before_gate" => RuntimeReportEnforcementPreflight.preflight(
      RuntimeReportEnforcementPreflight.with_report_mutation(ready_report) do |report|
        report.dig("backend_check", "temporal_backend_descriptor").delete("descriptor_hash")
      end
    )
  }

  summary = {
    "kind" => "runtime_report_enforcement_preflight_summary",
    "card" => CARD,
    "track" => TRACK,
    "status" => "PASS",
    "ordering" => %w[
      compatibility_report
      approval_token
      gate_state
      scope
      cache_key
      executor_backend
    ],
    "scope" => {
      "ledger_binding" => false,
      "live_reads" => false,
      "cache_calls" => false,
      "proof_local_preflight_only" => true
    },
    "cases" => cases
  }

  RuntimeReportEnforcementPreflight.assert("ready preflight reaches executor/backend without calls") do
    result = cases.fetch("ready_preflight")
    result.fetch("status") == "ready" &&
      result.fetch("stage_trace") == summary.fetch("ordering") &&
      result.fetch("operation_check").values.all? { |value| value == false }
  end
  {
    "split_report_blocks_at_compatibility_report" => "compatibility_report",
    "backend_descriptor_blocked" => "compatibility_report",
    "gate_closed_after_token_check" => "gate_state",
    "approval_missing_blocks_before_gate" => "approval_token",
    "approval_missing_with_gate_closed_blocks_before_gate" => "approval_token",
    "bihistory_scope_excluded_before_cache" => "scope",
    "cache_key_blocks_before_executor_backend" => "cache_key",
    "executor_missing_blocks_before_backend_call" => "executor_backend",
    "missing_descriptor_hash_blocks_before_gate" => "compatibility_report"
  }.each do |case_name, stage|
    RuntimeReportEnforcementPreflight.assert("#{case_name} stops at #{stage}") do
      cases.fetch(case_name).fetch("status") == "blocked" &&
        cases.fetch(case_name).fetch("blocked_stage") == stage
    end
  end
  RuntimeReportEnforcementPreflight.assert("report-only remains distinct from runtime_enforced") do
    result = cases.fetch("report_only_blocks_before_executor_backend")
    result.fetch("status") == "blocked" &&
      result.fetch("blocked_stage") == "executor_backend" &&
      result.fetch("reason_code") == "compatibility_report.report_only_not_runtime_authority"
  end
  RuntimeReportEnforcementPreflight.assert("blocked cases perform no executor/cache/tbackend/ledger/read calls") do
    cases.values.all? do |result|
      result.fetch("operation_check").values.all? { |value| value == false }
    end
  end

  out_path = RuntimeReportEnforcementPreflight.write_summary(summary)
  puts "PASS summary written #{out_path.relative_path_from(Pathname(Dir.pwd))}"
end
