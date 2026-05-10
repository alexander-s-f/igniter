#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "open3"
require "pathname"
require "rbconfig"

module CompilerProfileAuditableBuildReceipt
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = LANG_ROOT / "experiments/compiler_profile_auditable_build_receipt/out"
  RECEIPT_PATH = OUT_DIR / "compilation_receipt.add.json"
  SUMMARY_PATH = OUT_DIR / "compiler_profile_auditable_build_receipt_summary.json"

  PRELIGHT_RUNNER = LANG_ROOT / "experiments/compiler_profile_preflight_chain_index/compiler_profile_preflight_chain_index.rb"
  PREFLIGHT_SUMMARY = LANG_ROOT / "experiments/compiler_profile_preflight_chain_index/out/compiler_profile_preflight_chain_index_summary.json"
  COMPILER_PROOF_RUNNER = LANG_ROOT / "experiments/production_compiler_cli/production_compiler_cli_proof.rb"
  COMPILER_SUMMARY = LANG_ROOT / "experiments/production_compiler_cli/production_compiler_cli_summary.json"
  IGAPP_DIR = LANG_ROOT / "experiments/production_compiler_cli/out/add.igapp"
  SOURCE_PATH = LANG_ROOT / "experiments/source_to_semanticir_fixture/add.ig"

  FORMAT_VERSION = "0.1.0"
  TRACK = "compiler-profile-auditable-build-receipt-v0"

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    preflight_run = run_command(PRELIGHT_RUNNER)
    compiler_run = run_command(COMPILER_PROOF_RUNNER)

    preflight = read_json(PREFLIGHT_SUMMARY)
    compiler = read_json(COMPILER_SUMMARY)
    receipt = build_receipt(preflight, compiler)
    checks = build_checks(receipt, preflight, compiler, preflight_run, compiler_run)
    summary = {
      "kind" => "compiler_profile_auditable_build_receipt_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "receipt_path" => RECEIPT_PATH.relative_path_from(ROOT).to_s,
      "receipt_digest" => digest(receipt),
      "checks" => checks,
      "receipt_preview" => {
        "kind" => receipt.fetch("kind"),
        "program_id" => receipt.fetch("program_id"),
        "compiler_profile_id" => receipt.fetch("compiler_profile_id"),
        "artifact_hash" => receipt.dig("artifact", "artifact_hash"),
        "stage_count" => receipt.fetch("stages").length,
        "diagnostic_count" => receipt.fetch("diagnostics").length
      },
      "non_goals" => [
        "No production CompilationReceipt implementation.",
        "No assembler output changes.",
        "No .igapp manifest changes.",
        "No signing, key management, Ledger, or runtime execution authority."
      ]
    }

    write_json(RECEIPT_PATH, receipt)
    write_json(SUMMARY_PATH, summary)
    print_summary(summary, checks)
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

  def build_receipt(preflight, compiler)
    manifest = read_json(IGAPP_DIR / "manifest.json")
    report = read_json(IGAPP_DIR / "compilation_report.json")
    diagnostics = read_json(IGAPP_DIR / "diagnostics.json").fetch("diagnostics")
    requirements = read_json(IGAPP_DIR / "requirements.json")
    compatibility = read_json(IGAPP_DIR / "compatibility_metadata.json")

    {
      "kind" => "proof_local_compilation_receipt",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "program_id" => manifest.fetch("program_id"),
      "source" => {
        "path" => manifest.fetch("source_path"),
        "source_hash" => manifest.fetch("source_hash"),
        "source_digest_recomputed" => file_digest(SOURCE_PATH)
      },
      "compiler_profile_id" => compiler_profile_id,
      "compiler_profile_preflight" => {
        "status" => preflight.fetch("status"),
        "summary_ref" => PREFLIGHT_SUMMARY.relative_path_from(ROOT).to_s,
        "indexed_proofs" => preflight.fetch("chain").map do |entry|
          entry.slice("id", "scope", "boundary", "proof_status", "summary_path")
        end
      },
      "compile_command" => {
        "cli" => compiler.dig("positive", "command"),
        "direct_api" => compiler.dig("direct_api", "command"),
        "facade_same_shape" => compiler.dig("checks", "package_boundary.cli_and_api_same_facade_shape")
      },
      "stages" => stages(report, compiler),
      "packs_and_rules" => packs_and_rules,
      "diagnostics" => diagnostics,
      "warnings" => manifest.fetch("warnings"),
      "requirements" => requirements,
      "artifact" => {
        "path" => IGAPP_DIR.relative_path_from(ROOT).to_s,
        "kind" => manifest.fetch("kind"),
        "format_version" => manifest.fetch("format_version"),
        "fragment_class" => manifest.fetch("fragment_class"),
        "artifact_hash" => manifest.fetch("artifact_hash"),
        "proof_local_manifest_payload_digest" => digest(manifest.reject { |key, _| key == "artifact_hash" }),
        "contract_index" => manifest.fetch("contract_index"),
        "manifest_ref" => (IGAPP_DIR / "manifest.json").relative_path_from(ROOT).to_s,
        "manifest_digest" => file_digest(IGAPP_DIR / "manifest.json"),
        "semantic_ir_ref" => manifest.fetch("semantic_ir_ref"),
        "compilation_report_ref" => manifest.fetch("compilation_report_ref")
      },
      "compatibility" => {
        "metadata" => compatibility,
        "runtime_smoke" => compiler.dig("positive", "json", "runtime_smoke")
      },
      "authority" => {
        "proves_compiler_understanding" => true,
        "authorizes_runtime_execution" => false,
        "is_signed_receipt" => false,
        "is_production_audit_trail" => false
      },
      "receipt_policy" => {
        "deterministic" => true,
        "machine_readable" => true,
        "hashable" => true,
        "safe_to_show" => true,
        "proof_local_only" => true
      }
    }
  end

  def stages(report, compiler)
    report.fetch("stages").map do |name, status|
      {
        "name" => name,
        "status" => status,
        "source" => "compilation_report"
      }
    end + [
      {
        "name" => "assemble",
        "status" => compiler.dig("positive", "json", "stages", "assemble"),
        "source" => "compiler_result"
      },
      {
        "name" => "runtime_smoke",
        "status" => compiler.dig("positive", "json", "runtime_smoke", "compatibility_report_status"),
        "source" => "compiler_result",
        "authority_note" => "smoke result is evidence only; receipt does not authorize runtime execution"
      }
    ]
  end

  def packs_and_rules
    unified = read_json(LANG_ROOT / "experiments/compiler_profile_spec_and_rule_unification/out/compiler_profile_spec_and_rule_unification_summary.json")
    profile = unified.fetch("positive_profile")
    {
      "profile_spec_name" => profile.fetch("profile_spec_name"),
      "profile_spec_digest" => profile.fetch("profile_spec_digest"),
      "slot_assignments" => profile.fetch("slot_assignments"),
      "ordered_registries" => profile.fetch("ordered_registries"),
      "strict_registries" => profile.fetch("strict_registries")
    }
  end

  def build_checks(receipt, preflight, compiler, preflight_run, compiler_run)
    {
      "inputs.preflight_command_passed" => preflight_run.fetch("exit_status").zero? && preflight.fetch("status") == "PASS",
      "inputs.compiler_proof_command_passed" => compiler_run.fetch("exit_status").zero? && compiler.fetch("status") == "PASS",
      "receipt.has_compiler_profile_id" => receipt.fetch("compiler_profile_id").start_with?("compiler_profile_unified/sha256:"),
      "receipt.source_digest_matches_manifest" => receipt.dig("source", "source_hash") == receipt.dig("source", "source_digest_recomputed"),
      "receipt.includes_parse_to_assemble_stages" => %w[parse classify typecheck emit assemble].all? do |stage|
        receipt.fetch("stages").any? { |entry| entry.fetch("name") == stage && entry.fetch("status") == "ok" }
      end,
      "receipt.includes_packs_rules_requirements_diagnostics" => receipt.key?("packs_and_rules") &&
        receipt.key?("requirements") &&
        receipt.key?("diagnostics"),
      "receipt.artifact_hash_declared_and_manifest_digest_present" => receipt.dig("artifact", "artifact_hash").to_s.start_with?("sha256:") &&
        receipt.dig("artifact", "manifest_digest").to_s.start_with?("sha256:") &&
        receipt.dig("artifact", "proof_local_manifest_payload_digest").to_s.start_with?("sha256:"),
      "receipt.authority_does_not_grant_runtime" => receipt.dig("authority", "proves_compiler_understanding") == true &&
        receipt.dig("authority", "authorizes_runtime_execution") == false,
      "receipt.policy_machine_readable_hashable_safe_to_show" => receipt.dig("receipt_policy", "machine_readable") &&
        receipt.dig("receipt_policy", "hashable") &&
        receipt.dig("receipt_policy", "safe_to_show"),
      "receipt.not_signed_or_production_audit" => receipt.dig("authority", "is_signed_receipt") == false &&
        receipt.dig("authority", "is_production_audit_trail") == false
    }
  end

  def compiler_profile_id
    read_json(LANG_ROOT / "experiments/compiler_profile_spec_and_rule_unification/out/compiler_profile_spec_and_rule_unification_summary.json")
      .fetch("positive_profile")
      .fetch("profile_id")
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

  def file_digest(path)
    "sha256:#{Digest::SHA256.file(path).hexdigest}"
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

  def print_summary(summary, checks)
    puts "#{summary.fetch("status")} compiler_profile_auditable_build_receipt"
    checks.each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "receipt: #{summary.fetch("receipt_path")}"
    puts "receipt_digest: #{summary.fetch("receipt_digest")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = CompilerProfileAuditableBuildReceipt.run
exit(success ? 0 : 1)
