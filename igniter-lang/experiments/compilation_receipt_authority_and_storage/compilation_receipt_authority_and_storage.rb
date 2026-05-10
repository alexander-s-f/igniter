#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "open3"
require "pathname"
require "rbconfig"

module CompilationReceiptAuthorityAndStorage
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = LANG_ROOT / "experiments/compilation_receipt_authority_and_storage/out"
  POLICY_PATH = OUT_DIR / "compilation_receipt_storage_policy.json"
  SUMMARY_PATH = OUT_DIR / "compilation_receipt_authority_and_storage_summary.json"

  RECEIPT_RUNNER = LANG_ROOT / "experiments/compiler_profile_auditable_build_receipt/compiler_profile_auditable_build_receipt.rb"
  RECEIPT_PATH = LANG_ROOT / "experiments/compiler_profile_auditable_build_receipt/out/compilation_receipt.add.json"
  RECEIPT_SUMMARY = LANG_ROOT / "experiments/compiler_profile_auditable_build_receipt/out/compiler_profile_auditable_build_receipt_summary.json"

  FORMAT_VERSION = "0.1.0"
  TRACK = "compilation-receipt-authority-and-storage-v0"

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    receipt_run = run_receipt_proof
    receipt = read_json(RECEIPT_PATH)
    receipt_summary = read_json(RECEIPT_SUMMARY)
    policy = build_policy(receipt, receipt_summary)
    checks = build_checks(policy, receipt, receipt_summary, receipt_run)
    summary = {
      "kind" => "compilation_receipt_authority_and_storage_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "policy_path" => POLICY_PATH.relative_path_from(ROOT).to_s,
      "policy_digest" => digest(policy),
      "checks" => checks,
      "storage_surfaces" => policy.fetch("storage_surfaces").keys,
      "recommended_progression" => policy.fetch("recommended_progression"),
      "non_goals" => [
        "No production receipt storage implementation.",
        "No .igapp file layout change.",
        "No signing or key-management implementation.",
        "No CompatibilityReport production change.",
        "No runtime execution authority."
      ]
    }

    write_json(POLICY_PATH, policy)
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def run_receipt_proof
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, RECEIPT_RUNNER.to_s, chdir: ROOT.to_s)
    {
      "command" => "ruby #{RECEIPT_RUNNER.relative_path_from(ROOT)}",
      "exit_status" => status.exitstatus,
      "stdout_first_line" => stdout.lines.first.to_s.strip,
      "stderr" => stderr.strip
    }
  end

  def build_policy(receipt, receipt_summary)
    public_receipt = public_receipt_view(receipt)
    signed_payload = signed_receipt_payload(receipt, public_receipt, receipt_summary)
    {
      "kind" => "proof_local_compilation_receipt_storage_policy",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "receipt_ref" => RECEIPT_PATH.relative_path_from(ROOT).to_s,
      "receipt_digest" => receipt_summary.fetch("receipt_digest"),
      "storage_surfaces" => storage_surfaces(receipt, public_receipt, signed_payload),
      "redaction_policy" => redaction_policy,
      "public_receipt_view" => public_receipt,
      "signed_receipt_payload_candidate" => signed_payload,
      "compatibility_report_link" => compatibility_report_link(receipt),
      "authority_invariant" => {
        "receipt_can_explain_build" => true,
        "receipt_can_prove_compiler_understanding" => true,
        "receipt_can_authorize_runtime_execution" => false,
        "runtime_authority_remains_compatibility_report_and_runtime_guard" => true
      },
      "recommended_progression" => [
        "Keep proof-local receipts outside .igapp while the manifest PROP is open.",
        "Add optional embedded .igapp/compilation_receipt.json only after artifact hash ordering is specified.",
        "Add external signed receipt bundle before claiming production audit authority.",
        "Let .ilk index receipt digests and lineage, not replace signed receipts."
      ]
    }
  end

  def storage_surfaces(receipt, public_receipt, signed_payload)
    {
      "embedded_igapp_receipt" => {
        "candidate_path" => ".igapp/compilation_receipt.json",
        "authority_level" => "co_located_build_explanation",
        "stores" => "public_receipt_view",
        "digest" => digest(public_receipt),
        "signed" => false,
        "production_audit_authority" => false,
        "runtime_execution_authority" => false,
        "artifact_hash_requirement" => "must_be_defined_before_embedding_in_signed_surface",
        "use_when" => "local inspection, deterministic rebuild explanation, developer support"
      },
      "external_signed_receipt_bundle" => {
        "candidate_path" => "<artifact>.compilation_receipt.bundle.json",
        "authority_level" => "signed_build_attestation_candidate",
        "stores" => "signed_receipt_payload_candidate",
        "digest" => digest(signed_payload),
        "signed" => true,
        "production_audit_authority" => "only_after_key_management_and_retention_policy",
        "runtime_execution_authority" => false,
        "signature_surface" => signed_payload.keys,
        "use_when" => "release audit, accountable compilation, external verification"
      },
      "ilk_metadata_index" => {
        "candidate_path" => ".ilk/compilation_receipts/<receipt_digest>.json",
        "authority_level" => "lineage_index",
        "stores" => "receipt refs, digests, artifact refs, profile ids, compatibility report refs",
        "digest" => digest(ilk_index_entry(receipt)),
        "signed" => false,
        "production_audit_authority" => false,
        "runtime_execution_authority" => false,
        "use_when" => "query, lineage, retention index, cross-artifact navigation"
      }
    }
  end

  def redaction_policy
    {
      "public_fields" => [
        "kind",
        "format_version",
        "program_id",
        "source.source_hash",
        "compiler_profile_id",
        "compiler_profile_preflight",
        "stages",
        "packs_and_rules",
        "diagnostics",
        "warnings",
        "requirements",
        "artifact",
        "authority",
        "receipt_policy"
      ],
      "restricted_fields" => [
        "source.path",
        "compile_command.cli",
        "compile_command.direct_api",
        "compatibility.runtime_smoke.outputs"
      ],
      "rules" => [
        "Public receipts may expose digests and refs, not local absolute paths.",
        "Commands are retained in restricted receipt data unless explicitly approved for support bundles.",
        "Runtime smoke outputs are evidence, not runtime authority; expose summaries before values.",
        "Signed payloads should sign digests and policy claims, not every local machine detail."
      ]
    }
  end

  def public_receipt_view(receipt)
    {
      "kind" => receipt.fetch("kind"),
      "format_version" => receipt.fetch("format_version"),
      "program_id" => receipt.fetch("program_id"),
      "source" => {
        "source_hash" => receipt.dig("source", "source_hash")
      },
      "compiler_profile_id" => receipt.fetch("compiler_profile_id"),
      "compiler_profile_preflight" => receipt.fetch("compiler_profile_preflight"),
      "stages" => receipt.fetch("stages").map do |stage|
        stage.reject { |key, _| key == "authority_note" }
      end,
      "packs_and_rules" => receipt.fetch("packs_and_rules"),
      "diagnostics" => receipt.fetch("diagnostics"),
      "warnings" => receipt.fetch("warnings"),
      "requirements" => receipt.fetch("requirements"),
      "artifact" => receipt.fetch("artifact"),
      "authority" => receipt.fetch("authority"),
      "receipt_policy" => receipt.fetch("receipt_policy").merge("redacted_view" => true)
    }
  end

  def signed_receipt_payload(receipt, public_receipt, receipt_summary)
    {
      "kind" => "signed_compilation_receipt_payload_candidate",
      "format_version" => FORMAT_VERSION,
      "receipt_digest" => receipt_summary.fetch("receipt_digest"),
      "public_receipt_digest" => digest(public_receipt),
      "artifact_hash" => receipt.dig("artifact", "artifact_hash"),
      "manifest_digest" => receipt.dig("artifact", "manifest_digest"),
      "source_hash" => receipt.dig("source", "source_hash"),
      "compiler_profile_id" => receipt.fetch("compiler_profile_id"),
      "program_id" => receipt.fetch("program_id"),
      "authority" => {
        "build_attestation" => true,
        "runtime_execution_authority" => false
      },
      "signature_policy" => {
        "algorithm" => "TBD",
        "key_management" => "TBD",
        "canonical_json" => "required",
        "timestamp_authority" => "TBD",
        "revocation_policy" => "TBD"
      }
    }
  end

  def compatibility_report_link(receipt)
    {
      "compatibility_metadata_present" => receipt.dig("compatibility", "metadata").is_a?(Hash),
      "runtime_smoke_present" => receipt.dig("compatibility", "runtime_smoke").is_a?(Hash),
      "receipt_should_be_report_input" => true,
      "report_should_not_treat_receipt_as_runtime_authority" => true,
      "future_fields" => [
        "compilation_receipt_status",
        "compilation_receipt_digest",
        "signed_receipt_status",
        "receipt_redaction_policy"
      ]
    }
  end

  def ilk_index_entry(receipt)
    {
      "program_id" => receipt.fetch("program_id"),
      "compiler_profile_id" => receipt.fetch("compiler_profile_id"),
      "artifact_hash" => receipt.dig("artifact", "artifact_hash"),
      "manifest_digest" => receipt.dig("artifact", "manifest_digest"),
      "source_hash" => receipt.dig("source", "source_hash")
    }
  end

  def build_checks(policy, receipt, receipt_summary, receipt_run)
    surfaces = policy.fetch("storage_surfaces")
    public_view = policy.fetch("public_receipt_view")
    signed_payload = policy.fetch("signed_receipt_payload_candidate")
    {
      "input.receipt_proof_passed" => receipt_run.fetch("exit_status").zero? &&
        receipt_summary.fetch("status") == "PASS",
      "policy.has_three_storage_surfaces" => %w[
        embedded_igapp_receipt
        external_signed_receipt_bundle
        ilk_metadata_index
      ].all? { |key| surfaces.key?(key) },
      "authority.no_surface_grants_runtime_execution" => surfaces.values.all? do |surface|
        surface.fetch("runtime_execution_authority") == false
      end && policy.dig("authority_invariant", "receipt_can_authorize_runtime_execution") == false,
      "embedded.requires_hash_ordering_before_signed_surface" => surfaces.dig(
        "embedded_igapp_receipt", "artifact_hash_requirement"
      ) == "must_be_defined_before_embedding_in_signed_surface",
      "signed_payload_uses_digests_not_local_paths" => !JSON.generate(signed_payload).include?(ROOT.to_s) &&
        signed_payload.key?("receipt_digest") &&
        signed_payload.key?("public_receipt_digest"),
      "public_view_redacts_local_paths_and_commands" => !JSON.generate(public_view).include?(ROOT.to_s) &&
        !public_view.key?("compile_command"),
      "redaction.restricted_fields_named" => %w[
        source.path
        compile_command.cli
        compile_command.direct_api
        compatibility.runtime_smoke.outputs
      ].all? { |field| policy.dig("redaction_policy", "restricted_fields").include?(field) },
      "compatibility_report_link_present_without_authority_leak" => policy.dig(
        "compatibility_report_link", "receipt_should_be_report_input"
      ) == true && policy.dig(
        "compatibility_report_link", "report_should_not_treat_receipt_as_runtime_authority"
      ) == true,
      "receipt_digest_preserved" => policy.fetch("receipt_digest") == receipt_summary.fetch("receipt_digest"),
      "source_receipt_remains_non_production_audit" => receipt.dig("authority", "is_production_audit_trail") == false
    }
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def digest(value)
    "sha256:#{Digest::SHA256.hexdigest(JSON.generate(sort_value(value)))}"
  end

  def sort_value(value)
    case value
    when Hash
      value.keys.sort.to_h { |key| [key, sort_value(value.fetch(key))] }
    when Array
      value.map { |entry| sort_value(entry) }
    else
      value
    end
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} compilation_receipt_authority_and_storage"
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "policy: #{summary.fetch("policy_path")}"
    puts "policy_digest: #{summary.fetch("policy_digest")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = CompilationReceiptAuthorityAndStorage.run
exit(success ? 0 : 1)
