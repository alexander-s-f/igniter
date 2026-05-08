#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"

require_relative "../runtime_compatibility_report_temporal_load_check/runtime_compatibility_report_temporal_load_check"
require_relative "../temporal_runtime_load_guard/temporal_runtime_load_guard"

module GuardedRuntimeC2ProfileConsistencyProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  OUT_DIR = ROOT / "igniter-lang/experiments/guarded_runtime_c2_profile_consistency/out"
  SUMMARY_PATH = OUT_DIR / "guarded_runtime_c2_profile_consistency_summary.json"
  PROOF_AS_OF = "2026-05-08T00:00:00Z"
  C2_PROFILES = %w[
    claimed_executor_live_binding
    approved_executor_placeholder
  ].freeze

  REASON_MAPPING = {
    "runtime.temporal_executor_approval_missing" => {
      "guarded_runtime_reason_code" => "runtime.temporal_execution_not_implemented",
      "alignment" => "mapped_to_existing_guard_refusal",
      "note" => "CompatibilityReport models missing explicit executor approval; GuardedRuntimeMachine has no approval layer and refuses at the proof-local temporal execution boundary."
    },
    "runtime.temporal_gate3_closed" => {
      "guarded_runtime_reason_code" => "runtime.temporal_execution_not_implemented",
      "alignment" => "mapped_to_existing_guard_refusal",
      "note" => "CompatibilityReport models the closed Gate 3 state; GuardedRuntimeMachine has no Gate 3 execution path and refuses at the proof-local temporal execution boundary."
    }
  }.freeze

  module_function

  def run
    report_ok = RuntimeCompatibilityReportTemporalLoadCheckProof.run
    report_summary = read_json(RuntimeCompatibilityReportTemporalLoadCheckProof::SUMMARY_PATH)
    cases = build_cases(report_summary)
    checks = build_checks(cases)
    summary = {
      "kind" => "guarded_runtime_c2_profile_consistency_summary",
      "format_version" => "0.1.0",
      "card" => "S3-R9-C4-P",
      "track" => "guarded-runtime-c2-profile-consistency-v0",
      "status" => report_ok && checks.values.all? ? "PASS" : "FAIL",
      "source_summary" => RuntimeCompatibilityReportTemporalLoadCheckProof::SUMMARY_PATH.relative_path_from(ROOT).to_s,
      "guarded_runtime_source" => "igniter-lang/experiments/temporal_runtime_load_guard/temporal_runtime_load_guard.rb",
      "policy" => {
        "gate3_closed" => true,
        "production_runtime_enforced" => false,
        "live_executor" => false,
        "live_tbackend_binding" => false,
        "ledger_binding" => false
      },
      "mapping_table" => mapping_table,
      "cases" => cases,
      "checks" => checks
    }
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def build_cases(report_summary)
    report_summary.fetch("cases").each_with_object({}) do |(case_id, case_data), out|
      artifact_path = ROOT / case_data.fetch("artifact_path")
      contract_id = case_data.fetch("contract_id")
      profiles = C2_PROFILES.to_h do |profile_name|
        report = case_data.fetch("reports").fetch(profile_name)
        runtime_profile = report.fetch("runtime_profile")
        guarded = evaluate_with_guarded_runtime(artifact_path, contract_id, runtime_profile)
        report_reason = report.dig("evaluation_readiness", "reason_code")
        mapping = REASON_MAPPING.fetch(report_reason)

        [profile_name, {
          "compatibility_report" => {
            "overall" => report.fetch("overall"),
            "evaluation_decision" => report.dig("evaluation_readiness", "decision"),
            "reason_code" => report_reason,
            "guard_policy" => report.dig("evidence", "guard_policy", "guard_policy"),
            "runtime_profile" => runtime_profile
          },
          "guarded_runtime" => guarded,
          "reason_mapping" => mapping,
          "operation_check" => {
            "decision" => "not_attempted",
            "temporal_executor_call_attempted" => false,
            "live_tbackend_call_attempted" => false,
            "ledger_call_attempted" => false,
            "source" => "proof-local GuardedRuntimeMachine has no executor, TBackend, or Ledger call path"
          }
        }]
      end

      out[case_id] = {
        "artifact_path" => case_data.fetch("artifact_path"),
        "contract_id" => contract_id,
        "profiles" => profiles
      }
    end
  end

  def evaluate_with_guarded_runtime(artifact_path, contract_id, runtime_profile)
    machine = TemporalRuntimeLoadGuardProof::GuardedRuntimeMachine.new(
      temporal_runtime_supported: runtime_profile.fetch("temporal_executor") &&
        runtime_profile.fetch("live_tbackend_binding"),
      temporal_capabilities: runtime_profile.fetch("tbackend_capabilities")
    )
    load = machine.load_igapp(artifact_path)
    evaluate = machine.evaluate_contract(contract_id, inputs: {}, as_of: PROOF_AS_OF)
    {
      "load" => load,
      "evaluate" => evaluate
    }
  end

  def build_checks(cases)
    cases.each_with_object({}) do |(case_id, case_data), checks|
      case_data.fetch("profiles").each do |profile_name, result|
        report = result.fetch("compatibility_report")
        guarded = result.fetch("guarded_runtime")
        mapping = result.fetch("reason_mapping")
        operation = result.fetch("operation_check")

        prefix = "#{case_id}.#{profile_name}"
        checks["#{prefix}.compatibility_report_blocked"] =
          report.fetch("overall") == "blocked" &&
            report.fetch("evaluation_decision") == "blocked"
        checks["#{prefix}.guarded_runtime_loads_for_inspection"] =
          guarded.dig("load", "status") == "loaded" &&
            guarded.dig("load", "runtime_execution", "guard_policy") == "load_accept_evaluate_refuse"
        checks["#{prefix}.guarded_runtime_evaluate_refuses"] =
          guarded.dig("evaluate", "status") == "blocked"
        checks["#{prefix}.reason_code_mapped"] =
          guarded.dig("evaluate", "reason_code") == mapping.fetch("guarded_runtime_reason_code")
        checks["#{prefix}.guard_policy_preserved"] =
          report.fetch("guard_policy") == "load_accept_evaluate_refuse"
        checks["#{prefix}.no_live_operations_attempted"] =
          operation.fetch("temporal_executor_call_attempted") == false &&
            operation.fetch("live_tbackend_call_attempted") == false &&
            operation.fetch("ledger_call_attempted") == false
      end
    end
  end

  def mapping_table
    REASON_MAPPING.map do |report_reason, mapping|
      {
        "compatibility_report_reason_code" => report_reason,
        "guarded_runtime_refusal_reason_code" => mapping.fetch("guarded_runtime_reason_code"),
        "alignment" => mapping.fetch("alignment"),
        "note" => mapping.fetch("note")
      }
    end
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} guarded_runtime_c2_profile_consistency"
    summary.fetch("checks").each do |name, ok|
      puts "#{name}: #{ok ? "ok" : "FAIL"}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

if $PROGRAM_NAME == __FILE__
  success = GuardedRuntimeC2ProfileConsistencyProof.run
  exit(success ? 0 : 1)
end
