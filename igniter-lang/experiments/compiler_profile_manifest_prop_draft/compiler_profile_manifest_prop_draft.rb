#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "pathname"
require "rbconfig"

module CompilerProfileManifestPropDraft
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = LANG_ROOT / "experiments/compiler_profile_manifest_prop_draft/out"
  DRAFT_PATH = OUT_DIR / "compiler_profile_manifest_prop_draft.json"
  SUMMARY_PATH = OUT_DIR / "compiler_profile_manifest_prop_draft_summary.json"

  MANIFEST_BOUNDARY_RUNNER = LANG_ROOT / "experiments/compiler_profile_id_manifest_boundary/compiler_profile_id_manifest_boundary.rb"
  MANIFEST_BOUNDARY_SUMMARY = LANG_ROOT / "experiments/compiler_profile_id_manifest_boundary/out/compiler_profile_id_manifest_boundary_summary.json"
  COMPAT_REPORT_RUNNER = LANG_ROOT / "experiments/compiler_profile_compatibility_report_fields/compiler_profile_compatibility_report_fields.rb"
  COMPAT_REPORT_SUMMARY = LANG_ROOT / "experiments/compiler_profile_compatibility_report_fields/out/compiler_profile_compatibility_report_fields_summary.json"
  RECEIPT_STORAGE_RUNNER = LANG_ROOT / "experiments/compilation_receipt_authority_and_storage/compilation_receipt_authority_and_storage.rb"
  RECEIPT_STORAGE_SUMMARY = LANG_ROOT / "experiments/compilation_receipt_authority_and_storage/out/compilation_receipt_authority_and_storage_summary.json"

  FORMAT_VERSION = "0.1.0"
  TRACK = "compiler-profile-manifest-prop-draft-v0"

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    manifest_run = run_command(MANIFEST_BOUNDARY_RUNNER)
    report_run = run_command(COMPAT_REPORT_RUNNER)
    receipt_run = run_command(RECEIPT_STORAGE_RUNNER)

    manifest_summary = read_json(MANIFEST_BOUNDARY_SUMMARY)
    report_summary = read_json(COMPAT_REPORT_SUMMARY)
    receipt_summary = read_json(RECEIPT_STORAGE_SUMMARY)
    draft = build_draft(manifest_summary, report_summary, receipt_summary)
    checks = build_checks(draft, manifest_summary, report_summary, receipt_summary, manifest_run, report_run, receipt_run)
    summary = {
      "kind" => "compiler_profile_manifest_prop_draft_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "draft_path" => DRAFT_PATH.relative_path_from(ROOT).to_s,
      "checks" => checks,
      "non_goals" => [
        "No official PROP number claimed.",
        "No assembler implementation.",
        "No .igapp fixture update.",
        "No RuntimeMachine enforcement change.",
        "No signed artifact implementation."
      ]
    }

    write_json(DRAFT_PATH, draft)
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def run_command(path)
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, path.to_s, chdir: ROOT.to_s)
    {
      "command" => "ruby #{path.relative_path_from(ROOT)}",
      "exit_status" => status.exitstatus,
      "stdout_first_line" => stdout.lines.first.to_s.strip,
      "stderr" => stderr.strip
    }
  end

  def build_draft(manifest_summary, report_summary, receipt_summary)
    profile_id = manifest_summary.dig("model", "profile_id") ||
      manifest_summary.dig("model", "profile_source", "profile_id") ||
      manifest_summary.dig("model", "field_shape", "compiler_profile_id")
    {
      "kind" => "compiler_profile_manifest_prop_draft_candidate",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => "draft_candidate",
      "source_evidence" => {
        "manifest_boundary" => MANIFEST_BOUNDARY_SUMMARY.relative_path_from(ROOT).to_s,
        "compatibility_report_fields" => COMPAT_REPORT_SUMMARY.relative_path_from(ROOT).to_s,
        "receipt_storage_policy" => RECEIPT_STORAGE_SUMMARY.relative_path_from(ROOT).to_s
      },
      "proposed_manifest_field" => {
        "name" => "compiler_profile_id",
        "type" => "string",
        "example" => profile_id || "compiler_profile_unified/sha256:<digest>",
        "placement" => "top_level_manifest_field",
        "required_policy_initial" => "legacy_optional",
        "required_policy_future" => "profile_required",
        "authority" => "compiler_understanding_only",
        "runtime_execution_authority" => false
      },
      "artifact_hash_and_signature_policy" => {
        "compiler_profile_id_participates_in_artifact_hash" => true,
        "add_before_artifact_hash" => true,
        "add_before_signing" => true,
        "post_signing_annotation_allowed" => false,
        "profile_body_inline_initially_allowed" => false,
        "expanded_profile_sidecar_future" => true
      },
      "loader_policy" => {
        "legacy_optional" => {
          "absent" => "accept_absent_legacy",
          "match" => "accept_profile_match",
          "mismatch" => "refuse_profile_mismatch",
          "malformed" => "refuse_malformed_profile_id"
        },
        "profile_required" => {
          "absent" => "refuse_missing_compiler_profile_id",
          "match" => "accept_profile_match",
          "mismatch" => "refuse_profile_mismatch",
          "malformed" => "refuse_malformed_profile_id"
        }
      },
      "compatibility_report_fields" => {
        "compiler_profile_status" => report_summary.dig("report_schema", "compiler_profile_status", "status_values"),
        "runtime_evaluation_readiness" => report_summary.dig("report_schema", "runtime_evaluation_readiness", "status_values"),
        "invariant" => report_summary.dig("report_schema", "invariant")
      },
      "compilation_receipt_relationship" => {
        "receipt_may_reference_compiler_profile_id" => true,
        "receipt_may_reference_manifest_digest" => true,
        "receipt_signature_does_not_authorize_runtime" => true,
        "storage_policy_ref" => receipt_summary.fetch("policy_path")
      },
      "migration_order" => [
        "Finalize PROP for compiler_profile_id field and compatibility policies.",
        "Add report-only loader support for absent_legacy/mismatch/malformed/missing_required.",
        "Add assembler support behind legacy_optional policy and update proof fixtures.",
        "Regenerate artifact hashes/goldens intentionally.",
        "Add CompilationReceipt references after manifest hash ordering is stable.",
        "Consider profile_required only after profiled artifacts are normal."
      ],
      "implementation_cards" => [
        "assembler-compiler-profile-id-field-v0",
        "loader-compiler-profile-status-report-v0",
        "artifact-hash-profile-id-golden-migration-v0",
        "compilation-receipt-manifest-link-v0"
      ]
    }
  end

  def build_checks(draft, manifest_summary, report_summary, receipt_summary, manifest_run, report_run, receipt_run)
    {
      "input.manifest_boundary_passed" => manifest_run.fetch("exit_status").zero? && manifest_summary.fetch("status") == "PASS",
      "input.report_fields_passed" => report_run.fetch("exit_status").zero? && report_summary.fetch("status") == "PASS",
      "input.receipt_storage_passed" => receipt_run.fetch("exit_status").zero? && receipt_summary.fetch("status") == "PASS",
      "field.compiler_profile_id_top_level" => draft.dig("proposed_manifest_field", "name") == "compiler_profile_id" &&
        draft.dig("proposed_manifest_field", "placement") == "top_level_manifest_field",
      "authority.no_runtime_execution_authority" => draft.dig("proposed_manifest_field", "runtime_execution_authority") == false &&
        draft.dig("compilation_receipt_relationship", "receipt_signature_does_not_authorize_runtime") == true,
      "hash.before_hash_and_signing" => draft.dig("artifact_hash_and_signature_policy", "add_before_artifact_hash") == true &&
        draft.dig("artifact_hash_and_signature_policy", "add_before_signing") == true,
      "hash.no_post_signing_annotation" => draft.dig("artifact_hash_and_signature_policy", "post_signing_annotation_allowed") == false,
      "policy.has_legacy_and_required_modes" => draft.fetch("loader_policy").key?("legacy_optional") &&
        draft.fetch("loader_policy").key?("profile_required"),
      "report.separates_profile_and_runtime_fields" => draft.dig("compatibility_report_fields", "compiler_profile_status").include?("present_verified") &&
        draft.dig("compatibility_report_fields", "runtime_evaluation_readiness").include?("blocked"),
      "migration.has_ordered_implementation_cards" => draft.fetch("migration_order").length >= 5 &&
        draft.fetch("implementation_cards").length >= 4
    }
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} compiler_profile_manifest_prop_draft"
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "draft: #{summary.fetch("draft_path")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = CompilerProfileManifestPropDraft.run
exit(success ? 0 : 1)
