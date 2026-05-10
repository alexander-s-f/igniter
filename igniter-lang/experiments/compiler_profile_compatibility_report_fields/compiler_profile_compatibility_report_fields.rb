#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"

module CompilerProfileCompatibilityReportFields
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  AUTHORITY_SUMMARY = ROOT / "igniter-lang/experiments/compiler_profile_authority_boundary/out/compiler_profile_authority_boundary_summary.json"
  OUT_DIR = ROOT / "igniter-lang/experiments/compiler_profile_compatibility_report_fields/out"
  SUMMARY_PATH = OUT_DIR / "compiler_profile_compatibility_report_fields_summary.json"

  FORMAT_VERSION = "0.1.0"
  TRACK = "compiler-profile-compatibility-report-fields-v0"

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    authority = read_json(AUTHORITY_SUMMARY)
    reports = build_reports(authority.fetch("model").fetch("decision_table"))
    checks = build_checks(reports)
    summary = {
      "kind" => "compiler_profile_compatibility_report_fields_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "report_schema" => report_schema,
      "reports" => reports,
      "checks" => checks,
      "non_goals" => [
        "No runtime enforcement changes.",
        "No .igapp manifest changes.",
        "No production CompatibilityReport implementation changes."
      ]
    }
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def report_schema
    {
      "kind" => "proof_local_compatibility_report_schema",
      "compiler_profile_status" => {
        "status_values" => %w[absent_legacy present_verified mismatch malformed missing_required],
        "authority" => "compiler_understanding_only"
      },
      "runtime_evaluation_readiness" => {
        "status_values" => %w[ready blocked not_reached],
        "authority" => "runtime_execution_gate"
      },
      "invariant" => "compiler_profile_status.present_verified must not imply runtime_evaluation_readiness.ready"
    }
  end

  def build_reports(decision_table)
    decision_table.to_h do |case_id, entry|
      [case_id, report_for(case_id, entry)]
    end
  end

  def report_for(case_id, entry)
    compiler = entry.fetch("compiler_decision")
    runtime = entry.fetch("runtime_decision")
    {
      "kind" => "proof_local_compatibility_report",
      "format_version" => FORMAT_VERSION,
      "case" => case_id,
      "artifact" => {
        "artifact_id" => entry.fetch("artifact").fetch("artifact_id"),
        "fragment_class" => entry.fetch("artifact").fetch("fragment_class"),
        "guard_policy" => entry.fetch("artifact").fetch("guard_policy")
      },
      "compiler_profile_status" => compiler_profile_status(entry),
      "runtime_evaluation_readiness" => runtime_readiness(runtime),
      "authority_separation" => {
        "compiler_profile_can_authorize_runtime" => false,
        "runtime_authorized_by_compiler_profile_id" => runtime.fetch("authorized_by_compiler_profile_id"),
        "live_operation_attempted" => runtime.fetch("live_operation_attempted", false)
      }
    }
  end

  def compiler_profile_status(entry)
    compiler = entry.fetch("compiler_decision")
    artifact = entry.fetch("artifact")
    status = case compiler.fetch("decision")
             when "accept_profile_match" then "present_verified"
             when "accept_absent_legacy" then "absent_legacy"
             when "refuse_profile_mismatch" then "mismatch"
             when "refuse_missing_compiler_profile_id" then "missing_required"
             when "refuse_malformed_profile_id" then "malformed"
             else "malformed"
             end
    {
      "status" => status,
      "policy" => compiler.fetch("policy"),
      "manifest_compiler_profile_id" => artifact.fetch("compiler_profile_id", nil),
      "expected_compiler_profile_id" => entry.fetch("compiler_profile").fetch("profile_id"),
      "decision" => compiler.fetch("decision"),
      "understanding_authority" => compiler.fetch("understanding_authority"),
      "runtime_authority" => compiler.fetch("runtime_authority")
    }
  end

  def runtime_readiness(runtime)
    status = case runtime.fetch("decision")
             when "core_evaluation_policy_available", "would_continue_to_cache_policy_check"
               "ready"
             when "not_reached"
               "not_reached"
             else
               "blocked"
             end
    {
      "status" => status,
      "decision" => runtime.fetch("decision"),
      "reason_code" => runtime.fetch("reason_code"),
      "authorized_by_compiler_profile_id" => runtime.fetch("authorized_by_compiler_profile_id"),
      "live_operation_attempted" => runtime.fetch("live_operation_attempted", false)
    }
  end

  def build_checks(reports)
    {
      "schema.has_separate_compiler_profile_status" => reports.values.all? { |report| report.key?("compiler_profile_status") },
      "schema.has_separate_runtime_readiness" => reports.values.all? { |report| report.key?("runtime_evaluation_readiness") },
      "compiler.present_verified_not_runtime_authority" => reports.values.all? do |report|
        next true unless report.dig("compiler_profile_status", "status") == "present_verified"

        report.dig("compiler_profile_status", "runtime_authority") == false
      end,
      "runtime.verified_temporal_metadata_only_still_blocked" => reports.dig(
        "temporal_metadata_only_profile", "compiler_profile_status", "status"
      ) == "present_verified" && reports.dig(
        "temporal_metadata_only_profile", "runtime_evaluation_readiness", "status"
      ) == "blocked",
      "runtime.ledger_backed_no_approval_still_blocked" => reports.dig(
        "temporal_ledger_backed_no_approval", "compiler_profile_status", "status"
      ) == "present_verified" && reports.dig(
        "temporal_ledger_backed_no_approval", "runtime_evaluation_readiness", "reason_code"
      ) == "runtime.executor_approval_missing",
      "runtime.ledger_backed_gate3_closed_still_blocked" => reports.dig(
        "temporal_ledger_backed_gate3_closed", "compiler_profile_status", "status"
      ) == "present_verified" && reports.dig(
        "temporal_ledger_backed_gate3_closed", "runtime_evaluation_readiness", "reason_code"
      ) == "runtime.temporal_gate3_closed",
      "compiler.mismatch_runtime_not_reached" => reports.dig(
        "mismatched_profile", "compiler_profile_status", "status"
      ) == "mismatch" && reports.dig(
        "mismatched_profile", "runtime_evaluation_readiness", "status"
      ) == "not_reached",
      "legacy.absent_profile_status_not_runtime_authority" => reports.dig(
        "legacy_absent_profile", "compiler_profile_status", "status"
      ) == "absent_legacy" && reports.dig(
        "legacy_absent_profile", "authority_separation", "runtime_authorized_by_compiler_profile_id"
      ) == false,
      "authority.no_report_claims_profile_runtime_authority" => reports.values.all? do |report|
        report.dig("authority_separation", "compiler_profile_can_authorize_runtime") == false &&
          report.dig("authority_separation", "runtime_authorized_by_compiler_profile_id") == false
      end,
      "operation.no_live_operations_attempted" => reports.values.all? do |report|
        report.dig("authority_separation", "live_operation_attempted") == false
      end
    }
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} compiler_profile_compatibility_report_fields"
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = CompilerProfileCompatibilityReportFields.run
exit(success ? 0 : 1)
