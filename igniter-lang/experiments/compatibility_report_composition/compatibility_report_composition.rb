#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"
require "pathname"

module CompatibilityReportComposition
  CARD = "S3-R13-C4-P"
  TRACK = "compatibility-report-composition-v0"
  SUMMARY_PATH = Pathname(__dir__) / "compatibility_report_composition_summary.json"

  module_function

  def base_inputs
    {
      "artifact_ref" => "igapp/sha256:history-valid-time-proof",
      "contract_ref" => "contract/HistoryValidTime/sha256:proof",
      "fragment_class" => "TEMPORAL",
      "composition_mode" => "single_report",
      "requested_report_mode" => "report_only",
      "backend_check" => backend_check("trusted_metadata"),
      "runtime_gate_check" => runtime_gate_check(open: false),
      "executor_approval_check" => approval_check("ok"),
      "executor_readiness" => executor_readiness("ok"),
      "cache_key_check" => cache_key_check("ok")
    }
  end

  def backend_check(decision)
    status = decision == "blocked" ? "blocked" : "report_only"
    {
      "decision" => decision,
      "status" => status,
      "report_only" => true,
      "runtime_enforced" => false,
      "temporal_backend_descriptor" => {
        "source" => "ratified_package_descriptor_metadata",
        "descriptor_hash" => "sha256:descriptor-proof",
        "descriptor_registry_hash" => "sha256:registry-proof",
        "capabilities" => %w[history_read],
        "history_axes" => %w[valid_time],
        "cursor_policy" => {
          "ordered" => "forward",
          "cursor_kinds" => %w[timestamp],
          "truncation_reported" => true,
          "tie_breaker" => "timestamp_then_fact_id_required"
        },
        "diagnostics" => {
          "package_descriptor" => {
            "status" => decision == "blocked" ? "blocked" : "ok",
            "missing_ops" => [],
            "missing_hook_methods" => [],
            "missing_capabilities" => decision == "blocked" ? ["history_read"] : [],
            "missing_axes" => [],
            "schema_fingerprint_match" => true
          }
        },
        "warnings" => [
          "descriptor bihistory_read is metadata evidence only; it does not prove physical BiHistory at(vt:, tt:) serving"
        ],
        "non_authorization" => {
          "runtime_binding" => false,
          "ledger_reads" => false,
          "ledger_writes" => false,
          "ledger_replay" => false
        }
      }
    }
  end

  def runtime_gate_check(open:)
    {
      "gate" => "tbackend_gate3",
      "decision" => open ? "open" : "closed",
      "reason_code" => open ? "runtime.temporal_gate3_open" : "runtime.temporal_gate3_closed",
      "authority_ref" => open ? "architect-supervisor/gate3-decision-proof" : nil
    }
  end

  def approval_check(decision)
    {
      "decision" => decision,
      "reason_code" => decision == "ok" ? "runtime.executor_approval_token_valid" : "runtime.executor_approval_missing",
      "token_ref" => decision == "ok" ? "approval/proof-local/history-valid-time" : nil,
      "authority_ref" => decision == "ok" ? "architect-supervisor/gate3-decision-proof" : nil
    }
  end

  def executor_readiness(decision)
    {
      "decision" => decision,
      "executor_kind" => "proof_local_memory_tbackend",
      "fragment_class" => "TEMPORAL",
      "operation" => "history_valid_time_read",
      "reason_code" => decision == "ok" ? "runtime.temporal_executor_ready" : "runtime.temporal_executor_missing"
    }
  end

  def cache_key_check(decision)
    {
      "decision" => decision,
      "schema" => "runtime-cache-key-v1",
      "fragment" => decision == "ok" ? "TEMPORAL" : "CORE",
      "required_coordinates" => %w[valid_time],
      "reason_code" => decision == "ok" ? "runtime.temporal_cache_key_valid" : "runtime.temporal_cache_schema_mismatch"
    }
  end

  def compose(inputs)
    diagnostics = composition_diagnostics(inputs)
    readiness = evaluation_readiness(inputs, diagnostics)
    report = {
      "kind" => "compatibility_report",
      "format_version" => "0.1.0",
      "card" => CARD,
      "track" => TRACK,
      "composition" => {
        "mode" => inputs.fetch("composition_mode"),
        "single_report_required" => true,
        "split_fragments_allowed" => false
      },
      "artifact_ref" => inputs.fetch("artifact_ref"),
      "contract_ref" => inputs.fetch("contract_ref"),
      "fragment_class" => inputs.fetch("fragment_class"),
      "report_only" => report_only?(inputs, readiness),
      "runtime_enforced" => runtime_enforced?(inputs, readiness),
      "schema_check" => {
        "decision" => "not_evaluated_here",
        "independent_from_backend_descriptor" => true
      },
      "backend_check" => inputs.fetch("backend_check"),
      "runtime_gate_check" => inputs.fetch("runtime_gate_check"),
      "executor_approval_check" => inputs.fetch("executor_approval_check"),
      "executor_readiness" => inputs.fetch("executor_readiness"),
      "cache_key_check" => inputs.fetch("cache_key_check"),
      "composition_diagnostics" => diagnostics,
      "evaluation_readiness" => readiness,
      "operation_check" => no_live_operation_check
    }
    report.merge("report_id" => "compat/composed/#{short_hash(report)}")
  end

  def composition_diagnostics(inputs)
    problems = []
    problems << "compatibility_report.split_report_rejected" unless inputs.fetch("composition_mode") == "single_report"
    problems << "compatibility_report.fragment_class_not_temporal" unless inputs.fetch("fragment_class") == "TEMPORAL"
    problems << "compatibility_report.backend_check_missing" unless inputs["backend_check"].is_a?(Hash)
    problems << "compatibility_report.gate_check_missing" unless inputs["runtime_gate_check"].is_a?(Hash)
    problems << "compatibility_report.approval_check_missing" unless inputs["executor_approval_check"].is_a?(Hash)
    problems << "compatibility_report.executor_readiness_missing" unless inputs["executor_readiness"].is_a?(Hash)
    problems << "compatibility_report.cache_key_check_missing" unless inputs["cache_key_check"].is_a?(Hash)

    {
      "kind" => "compatibility_report_composition_diagnostic",
      "status" => problems.empty? ? "ok" : "blocked",
      "problems" => problems
    }
  end

  def evaluation_readiness(inputs, diagnostics)
    blockers = []
    blockers << "compatibility_report.composition_blocked" unless diagnostics.fetch("status") == "ok"
    blockers << "runtime.backend_descriptor_not_trusted" unless inputs.fetch("backend_check").fetch("decision") == "trusted_metadata"
    blockers << inputs.fetch("runtime_gate_check").fetch("reason_code") unless inputs.fetch("runtime_gate_check").fetch("decision") == "open"
    blockers << inputs.fetch("executor_approval_check").fetch("reason_code") unless inputs.fetch("executor_approval_check").fetch("decision") == "ok"
    blockers << inputs.fetch("executor_readiness").fetch("reason_code") unless inputs.fetch("executor_readiness").fetch("decision") == "ok"
    blockers << inputs.fetch("cache_key_check").fetch("reason_code") unless inputs.fetch("cache_key_check").fetch("decision") == "ok"

    if inputs.fetch("requested_report_mode") == "runtime_enforced" && blockers.empty?
      {
        "decision" => "ready",
        "reason_code" => "runtime.temporal_evaluation_ready",
        "blocks_before_executor" => false,
        "blockers" => []
      }
    elsif inputs.fetch("requested_report_mode") == "runtime_enforced"
      {
        "decision" => "blocked",
        "reason_code" => blockers.first,
        "blocks_before_executor" => true,
        "blockers" => blockers.uniq
      }
    else
      {
        "decision" => blockers.empty? ? "report_only_ready" : "blocked",
        "reason_code" => blockers.empty? ? "compatibility_report.report_only_not_runtime_authority" : blockers.first,
        "blocks_before_executor" => true,
        "blockers" => blockers.uniq
      }
    end
  end

  def report_only?(inputs, readiness)
    return true unless inputs.fetch("requested_report_mode") == "runtime_enforced"

    readiness.fetch("decision") != "ready"
  end

  def runtime_enforced?(inputs, readiness)
    inputs.fetch("requested_report_mode") == "runtime_enforced" && readiness.fetch("decision") == "ready"
  end

  def no_live_operation_check
    {
      "temporal_executor_call_attempted" => false,
      "live_tbackend_call_attempted" => false,
      "ledger_call_attempted" => false,
      "temporal_read_attempted" => false,
      "cache_call_attempted" => false
    }
  end

  def short_hash(value)
    Digest::SHA256.hexdigest(JSON.generate(canonical(value)))[0, 16]
  end

  def canonical(value)
    case value
    when Hash
      value.keys.sort_by(&:to_s).to_h { |key| [key.to_s, canonical(value.fetch(key))] }
    when Array
      value.map { |entry| canonical(entry) }
    else
      value
    end
  end

  def write_summary(summary)
    SUMMARY_PATH.write("#{JSON.pretty_generate(summary)}\n")
    SUMMARY_PATH
  end

  def assert(label)
    raise "FAIL #{label}" unless yield

    puts "PASS #{label}"
  end
end

if $PROGRAM_NAME == __FILE__
  include CompatibilityReportComposition

  base = CompatibilityReportComposition.base_inputs
  cases = {
    "report_only_gate3_closed" => CompatibilityReportComposition.compose(base),
    "runtime_enforced_ready" => CompatibilityReportComposition.compose(
      base.merge(
        "requested_report_mode" => "runtime_enforced",
        "runtime_gate_check" => CompatibilityReportComposition.runtime_gate_check(open: true)
      )
    ),
    "split_report_rejected" => CompatibilityReportComposition.compose(
      base.merge(
        "requested_report_mode" => "runtime_enforced",
        "composition_mode" => "split_report_and_enforcement",
        "runtime_gate_check" => CompatibilityReportComposition.runtime_gate_check(open: true)
      )
    ),
    "descriptor_blocked" => CompatibilityReportComposition.compose(
      base.merge(
        "requested_report_mode" => "runtime_enforced",
        "runtime_gate_check" => CompatibilityReportComposition.runtime_gate_check(open: true),
        "backend_check" => CompatibilityReportComposition.backend_check("blocked")
      )
    ),
    "approval_missing" => CompatibilityReportComposition.compose(
      base.merge(
        "requested_report_mode" => "runtime_enforced",
        "runtime_gate_check" => CompatibilityReportComposition.runtime_gate_check(open: true),
        "executor_approval_check" => CompatibilityReportComposition.approval_check("blocked")
      )
    ),
    "executor_missing" => CompatibilityReportComposition.compose(
      base.merge(
        "requested_report_mode" => "runtime_enforced",
        "runtime_gate_check" => CompatibilityReportComposition.runtime_gate_check(open: true),
        "executor_readiness" => CompatibilityReportComposition.executor_readiness("blocked")
      )
    ),
    "cache_key_blocked" => CompatibilityReportComposition.compose(
      base.merge(
        "requested_report_mode" => "runtime_enforced",
        "runtime_gate_check" => CompatibilityReportComposition.runtime_gate_check(open: true),
        "cache_key_check" => CompatibilityReportComposition.cache_key_check("blocked")
      )
    ),
    "report_only_all_checks_ok" => CompatibilityReportComposition.compose(
      base.merge("runtime_gate_check" => CompatibilityReportComposition.runtime_gate_check(open: true))
    )
  }

  summary = {
    "kind" => "compatibility_report_composition_summary",
    "card" => CARD,
    "track" => TRACK,
    "status" => "PASS",
    "scope" => {
      "live_ledger_binding" => false,
      "live_tbackend_call" => false,
      "temporal_read" => false,
      "proof_local_only" => true
    },
    "cases" => cases.transform_values do |report|
      {
        "report_id" => report.fetch("report_id"),
        "report_only" => report.fetch("report_only"),
        "runtime_enforced" => report.fetch("runtime_enforced"),
        "evaluation_readiness" => report.fetch("evaluation_readiness"),
        "composition_diagnostics" => report.fetch("composition_diagnostics"),
        "operation_check" => report.fetch("operation_check")
      }
    end
  }

  CompatibilityReportComposition.assert("gate3 closed report remains report-only and blocked") do
    report = cases.fetch("report_only_gate3_closed")
    report.fetch("report_only") == true &&
      report.fetch("runtime_enforced") == false &&
      report.dig("evaluation_readiness", "reason_code") == "runtime.temporal_gate3_closed"
  end
  CompatibilityReportComposition.assert("runtime_enforced ready only on one composed report") do
    report = cases.fetch("runtime_enforced_ready")
    report.fetch("composition").fetch("mode") == "single_report" &&
      report.fetch("runtime_enforced") == true &&
      report.fetch("report_only") == false &&
      report.dig("evaluation_readiness", "decision") == "ready"
  end
  CompatibilityReportComposition.assert("split report is rejected") do
    report = cases.fetch("split_report_rejected")
    report.fetch("runtime_enforced") == false &&
      report.dig("composition_diagnostics", "problems").include?("compatibility_report.split_report_rejected")
  end
  %w[descriptor_blocked approval_missing executor_missing cache_key_blocked].each do |case_name|
    CompatibilityReportComposition.assert("#{case_name} blocks before executor") do
      report = cases.fetch(case_name)
      report.fetch("runtime_enforced") == false &&
        report.dig("evaluation_readiness", "decision") == "blocked" &&
        report.dig("evaluation_readiness", "blocks_before_executor") == true
    end
  end
  CompatibilityReportComposition.assert("report-only all checks ok does not become runtime authority") do
    report = cases.fetch("report_only_all_checks_ok")
    report.fetch("report_only") == true &&
      report.fetch("runtime_enforced") == false &&
      report.dig("evaluation_readiness", "reason_code") == "compatibility_report.report_only_not_runtime_authority"
  end
  CompatibilityReportComposition.assert("no case performs live operations") do
    cases.values.all? do |report|
      report.fetch("operation_check").values.all? { |value| value == false }
    end
  end

  out_path = CompatibilityReportComposition.write_summary(summary)
  puts "PASS summary written #{out_path.relative_path_from(Pathname(Dir.pwd))}"
end
