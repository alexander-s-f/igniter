#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"

module Prop036LoaderStatusReportProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  EXPERIMENT_DIR = ROOT / "igniter-lang/experiments/prop036_loader_status_report_proof"
  OUT_DIR = EXPERIMENT_DIR / "out"
  SUMMARY_PATH = OUT_DIR / "prop036_loader_status_report_summary.json"
  MATRIX_PATH = OUT_DIR / "prop036_loader_status_report_matrix.json"

  EXPECTED_PROFILE_ID = "compiler_profile_unified/sha256:2944e573270aa56fca51cea3"
  OTHER_PROFILE_ID = "compiler_profile_unified/sha256:000000000000000000000000"
  PROFILE_ID_PATTERN = %r{\Acompiler_profile_unified/sha256:[0-9a-f]{24,}\z}.freeze

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    matrix = build_matrix
    summary = build_summary(matrix)
    write_json(MATRIX_PATH, matrix)
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def build_matrix
    cases = {
      "legacy_absent" => report_for(
        manifest: base_manifest,
        policy: "legacy_optional",
        model_scope: "current_initial_policy"
      ),
      "legacy_present_verified" => report_for(
        manifest: base_manifest.merge("compiler_profile_id" => EXPECTED_PROFILE_ID),
        policy: "legacy_optional",
        model_scope: "current_initial_policy"
      ),
      "legacy_mismatch" => report_for(
        manifest: base_manifest.merge("compiler_profile_id" => OTHER_PROFILE_ID),
        policy: "legacy_optional",
        model_scope: "current_initial_policy"
      ),
      "legacy_malformed" => report_for(
        manifest: base_manifest.merge("compiler_profile_id" => "not-a-profile-id"),
        policy: "legacy_optional",
        model_scope: "current_initial_policy"
      ),
      "future_missing_required" => report_for(
        manifest: base_manifest,
        policy: "profile_required",
        model_scope: "future_policy_model_only"
      )
    }

    {
      "kind" => "prop036_loader_status_report_matrix",
      "format_version" => "0.1.0",
      "card" => "S3-R36-C5-P",
      "track" => "prop036-loader-status-report-proof-v0",
      "proposal_ref" => "docs/proposals/PROP-036-compiler-profile-manifest-identity-v0.md",
      "acceptance_decision_ref" => "docs/gates/prop036-compiler-profile-id-acceptance-decision-v0.md",
      "expected_profile_id" => EXPECTED_PROFILE_ID,
      "initial_policy" => "legacy_optional",
      "profile_required_rollout_authorized" => false,
      "real_manifest_mutation" => false,
      "production_loader_implementation" => false,
      "cases" => cases
    }
  end

  def report_for(manifest:, policy:, model_scope:)
    compiler_profile = compiler_profile_status(manifest, policy)
    {
      "kind" => "prop036_loader_status_report",
      "format_version" => "0.1.0",
      "policy" => policy,
      "model_scope" => model_scope,
      "profile_required_rollout_authorized" => false,
      "manifest_ref" => manifest.fetch("manifest_ref"),
      "compiler_profile" => compiler_profile,
      "loader_decision" => loader_decision_for(compiler_profile),
      "runtime_evaluation_readiness" => runtime_readiness_for(compiler_profile),
      "non_authorizations" => non_authorizations
    }
  end

  def compiler_profile_status(manifest, policy)
    manifest_profile_id = manifest.fetch("compiler_profile_id", nil)
    status =
      if manifest_profile_id.nil?
        policy == "profile_required" ? "missing_required" : "absent_legacy"
      elsif !valid_profile_id?(manifest_profile_id)
        "malformed"
      elsif manifest_profile_id != EXPECTED_PROFILE_ID
        "mismatch"
      else
        "present_verified"
      end

    {
      "status" => status,
      "manifest_profile_id" => manifest_profile_id,
      "expected_profile_id" => EXPECTED_PROFILE_ID,
      "reason_code" => "compiler_profile.#{status}",
      "present_verified_implies_runtime_ready" => false
    }
  end

  def loader_decision_for(compiler_profile)
    status = compiler_profile.fetch("status")
    if %w[absent_legacy present_verified].include?(status)
      {
        "decision" => "accept_for_inspection",
        "loadable_for_inspection" => true,
        "refuse_reason" => nil
      }
    else
      {
        "decision" => "refuse_profile_status",
        "loadable_for_inspection" => false,
        "refuse_reason" => compiler_profile.fetch("reason_code")
      }
    end
  end

  def runtime_readiness_for(compiler_profile)
    if compiler_profile.fetch("status") == "present_verified"
      {
        "status" => "blocked",
        "ready" => false,
        "reason_code" => "runtime.readiness_not_granted_by_compiler_profile",
        "authority_source" => "runtime_policy_required"
      }
    else
      {
        "status" => "not_reached",
        "ready" => false,
        "reason_code" => "runtime.readiness_not_evaluated",
        "authority_source" => "none"
      }
    end
  end

  def build_summary(matrix)
    checks = checks_for(matrix)
    {
      "kind" => "prop036_loader_status_report_summary",
      "format_version" => "0.1.0",
      "card" => matrix.fetch("card"),
      "track" => matrix.fetch("track"),
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "matrix_ref" => MATRIX_PATH.relative_path_from(ROOT).to_s,
      "statuses_covered" => statuses(matrix),
      "initial_policy" => matrix.fetch("initial_policy"),
      "profile_required_rollout_authorized" => matrix.fetch("profile_required_rollout_authorized"),
      "real_manifest_mutation" => matrix.fetch("real_manifest_mutation"),
      "production_loader_implementation" => matrix.fetch("production_loader_implementation"),
      "implementation_blockers" => implementation_blockers,
      "checks" => checks
    }
  end

  def checks_for(matrix)
    cases = matrix.fetch("cases")
    {
      "status.absent_legacy" => case_status?(cases, "legacy_absent", "absent_legacy"),
      "status.present_verified" => case_status?(cases, "legacy_present_verified", "present_verified"),
      "status.mismatch" => case_status?(cases, "legacy_mismatch", "mismatch"),
      "status.malformed" => case_status?(cases, "legacy_malformed", "malformed"),
      "status.missing_required" => case_status?(cases, "future_missing_required", "missing_required"),
      "policy.initial_legacy_optional" => matrix.fetch("initial_policy") == "legacy_optional",
      "policy.no_profile_required_rollout" => matrix.fetch("profile_required_rollout_authorized") == false &&
        cases.fetch("future_missing_required").fetch("model_scope") == "future_policy_model_only",
      "runtime.present_verified_not_ready" =>
        cases.dig("legacy_present_verified", "runtime_evaluation_readiness", "ready") == false &&
        cases.dig("legacy_present_verified", "runtime_evaluation_readiness", "reason_code") ==
          "runtime.readiness_not_granted_by_compiler_profile",
      "loader.absent_legacy_accepts_inspection" =>
        cases.dig("legacy_absent", "loader_decision", "decision") == "accept_for_inspection",
      "loader.mismatch_refuses" =>
        cases.dig("legacy_mismatch", "loader_decision", "decision") == "refuse_profile_status",
      "loader.malformed_refuses" =>
        cases.dig("legacy_malformed", "loader_decision", "decision") == "refuse_profile_status",
      "loader.missing_required_refuses_future_only" =>
        cases.dig("future_missing_required", "loader_decision", "decision") == "refuse_profile_status" &&
        cases.fetch("future_missing_required").fetch("policy") == "profile_required",
      "scope.no_real_manifest_mutation" => matrix.fetch("real_manifest_mutation") == false,
      "scope.no_production_loader" => matrix.fetch("production_loader_implementation") == false,
      "scope.non_authorizations_preserved" => cases.values.all? do |report|
        report.fetch("non_authorizations").include?("RuntimeMachine execution authority") &&
          report.fetch("non_authorizations").include?(".igapp manifest mutation")
      end
    }
  end

  def case_status?(cases, case_name, status)
    cases.dig(case_name, "compiler_profile", "status") == status
  end

  def statuses(matrix)
    matrix.fetch("cases").values.map { |report| report.dig("compiler_profile", "status") }.sort
  end

  def valid_profile_id?(id)
    id.is_a?(String) && PROFILE_ID_PATTERN.match?(id)
  end

  def base_manifest
    {
      "kind" => "igapp_manifest",
      "manifest_ref" => "synthetic/prop036/manifest",
      "format_version" => "0.1.0",
      "artifact_hash" => "sha256:synthetic-not-real"
    }
  end

  def non_authorizations
    [
      ".igapp manifest mutation",
      ".ilk format mutation",
      "assembler implementation",
      "production loader implementation",
      "CompatibilityReport production change",
      "artifact hash/golden migration",
      "CompilationReceipt manifest link",
      "compiler dispatch migration",
      "RuntimeMachine binding",
      "RuntimeMachine execution authority",
      "profile_required rollout"
    ]
  end

  def implementation_blockers
    [
      "Separate Architect authorization for exactly one implementation surface",
      "Preserve present_verified != runtime readiness",
      "Keep legacy_optional as initial policy unless a later Architect decision changes it",
      "No profile_required rollout until migration evidence exists",
      "No .igapp/.ilk mutation in proof-local design cards",
      "Dedicated tests for absent_legacy, present_verified, mismatch, malformed, and missing_required",
      "Artifact hash/golden migration proof before assembler field adoption",
      "Stable manifest ordering before CompilationReceipt links"
    ]
  end

  def write_json(path, value)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} prop036_loader_status_report_proof"
    summary.fetch("checks").each do |name, passed|
      puts "#{name}: #{passed ? "ok" : "FAIL"}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = Prop036LoaderStatusReportProof.run
exit(success ? 0 : 1)
