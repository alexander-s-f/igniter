#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "pathname"
require "rbconfig"

module CompilerProfilePreflightChainIndex
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  OUT_DIR = ROOT / "igniter-lang/experiments/compiler_profile_preflight_chain_index/out"
  SUMMARY_PATH = OUT_DIR / "compiler_profile_preflight_chain_index_summary.json"

  FORMAT_VERSION = "0.1.0"
  TRACK = "compiler-profile-preflight-chain-index-v0"

  PROOFS = [
    {
      "id" => "compiler_pack_shadow_profile_proof",
      "scope" => "shadow_profile",
      "boundary" => "monolith_described_as_profile",
      "path" => "igniter-lang/experiments/compiler_pack_shadow_profile_proof/compiler_pack_shadow_profile_proof.rb",
      "summary_path" => "igniter-lang/experiments/compiler_pack_shadow_profile_proof/out/compiler_pack_shadow_profile_proof_summary.json"
    },
    {
      "id" => "contract_modifiers_pack_native_boundary",
      "scope" => "pack_candidate",
      "boundary" => "first_optional_semantic_pack",
      "path" => "igniter-lang/experiments/contract_modifiers_pack_native_boundary/contract_modifiers_pack_native_boundary.rb",
      "summary_path" => "igniter-lang/experiments/contract_modifiers_pack_native_boundary/out/contract_modifiers_pack_native_boundary_summary.json"
    },
    {
      "id" => "compiler_kernel_pack_registry_spike",
      "scope" => "kernel_model",
      "boundary" => "pack_install_finalize_fingerprint",
      "path" => "igniter-lang/experiments/compiler_kernel_pack_registry_spike/compiler_kernel_pack_registry_spike.rb",
      "summary_path" => "igniter-lang/experiments/compiler_kernel_pack_registry_spike/out/compiler_kernel_pack_registry_spike_summary.json"
    },
    {
      "id" => "compiler_kernel_ordered_rule_precedence",
      "scope" => "ordering_model",
      "boundary" => "before_after_priority_cycle_detection",
      "path" => "igniter-lang/experiments/compiler_kernel_ordered_rule_precedence/compiler_kernel_ordered_rule_precedence.rb",
      "summary_path" => "igniter-lang/experiments/compiler_kernel_ordered_rule_precedence/out/compiler_kernel_ordered_rule_precedence_summary.json"
    },
    {
      "id" => "compiler_profile_id_manifest_boundary",
      "scope" => "manifest_plan",
      "boundary" => "compiler_profile_id_before_artifact_hash",
      "path" => "igniter-lang/experiments/compiler_profile_id_manifest_boundary/compiler_profile_id_manifest_boundary.rb",
      "summary_path" => "igniter-lang/experiments/compiler_profile_id_manifest_boundary/out/compiler_profile_id_manifest_boundary_summary.json"
    },
    {
      "id" => "compiler_profile_slots_model",
      "scope" => "profile_spec",
      "boundary" => "semantic_slots_and_pack_cardinality",
      "path" => "igniter-lang/experiments/compiler_profile_slots_model/compiler_profile_slots_model.rb",
      "summary_path" => "igniter-lang/experiments/compiler_profile_slots_model/out/compiler_profile_slots_model_summary.json"
    },
    {
      "id" => "compiler_profile_spec_and_rule_unification",
      "scope" => "unified_profile",
      "boundary" => "slots_plus_ordered_rules_fingerprint",
      "path" => "igniter-lang/experiments/compiler_profile_spec_and_rule_unification/compiler_profile_spec_and_rule_unification.rb",
      "summary_path" => "igniter-lang/experiments/compiler_profile_spec_and_rule_unification/out/compiler_profile_spec_and_rule_unification_summary.json"
    },
    {
      "id" => "compiler_profile_authority_boundary",
      "scope" => "authority_boundary",
      "boundary" => "understanding_authority_not_runtime_authority",
      "path" => "igniter-lang/experiments/compiler_profile_authority_boundary/compiler_profile_authority_boundary.rb",
      "summary_path" => "igniter-lang/experiments/compiler_profile_authority_boundary/out/compiler_profile_authority_boundary_summary.json"
    },
    {
      "id" => "compiler_profile_compatibility_report_fields",
      "scope" => "report_shape",
      "boundary" => "profile_status_separate_from_runtime_readiness",
      "path" => "igniter-lang/experiments/compiler_profile_compatibility_report_fields/compiler_profile_compatibility_report_fields.rb",
      "summary_path" => "igniter-lang/experiments/compiler_profile_compatibility_report_fields/out/compiler_profile_compatibility_report_fields_summary.json"
    }
  ].freeze

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    proof_results = PROOFS.map { |proof| run_proof(proof) }
    summaries = proof_results.to_h { |result| [result.fetch("id"), result.fetch("summary")] }
    checks = build_checks(proof_results, summaries)
    summary = {
      "kind" => "compiler_profile_preflight_chain_index_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "chain" => proof_results.map { |result| result.reject { |key, _| key == "summary" } },
      "checks" => checks,
      "migration_blockers" => migration_blockers,
      "non_goals" => [
        "No compiler dispatch changes.",
        "No production CompilerKernel or CompilerPack implementation.",
        "No .igapp manifest changes.",
        "No runtime authority changes."
      ]
    }
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def run_proof(proof)
    command = [RbConfig.ruby, proof.fetch("path")]
    stdout, stderr, status = Open3.capture3(*command, chdir: ROOT.to_s)
    summary = read_json(ROOT / proof.fetch("summary_path"))
    {
      "id" => proof.fetch("id"),
      "scope" => proof.fetch("scope"),
      "boundary" => proof.fetch("boundary"),
      "command" => command.join(" "),
      "summary_path" => proof.fetch("summary_path"),
      "exit_status" => status.exitstatus,
      "proof_status" => summary.fetch("status", "UNKNOWN"),
      "check_count" => summary.fetch("checks", {}).length,
      "stdout_first_line" => stdout.lines.first.to_s.strip,
      "stderr" => stderr.strip,
      "summary" => summary
    }
  end

  def build_checks(proof_results, summaries)
    authority = summaries.fetch("compiler_profile_authority_boundary")
    compatibility = summaries.fetch("compiler_profile_compatibility_report_fields")
    unified = summaries.fetch("compiler_profile_spec_and_rule_unification")
    manifest = summaries.fetch("compiler_profile_id_manifest_boundary")
    ordered = summaries.fetch("compiler_kernel_ordered_rule_precedence")

    {
      "chain.all_commands_exited_zero" => proof_results.all? { |result| result.fetch("exit_status").zero? },
      "chain.all_summaries_pass" => proof_results.all? { |result| result.fetch("proof_status") == "PASS" },
      "chain.required_boundaries_indexed" => required_boundaries_indexed?(proof_results),
      "profile.unified_id_reaches_authority_boundary" => unified.fetch("positive_profile").fetch("profile_id") ==
        authority.fetch("model").fetch("unified_profile_id"),
      "profile.manifest_plan_requires_reassembly_before_signing" => manifest.fetch("checks").fetch("recommendation.reassembly_before_signing"),
      "ordering.cycle_and_missing_reference_guards_present" => ordered.fetch("checks").fetch("negative.cycle_rejected") &&
        ordered.fetch("checks").fetch("negative.missing_reference_rejected"),
      "authority.compiler_profile_never_authorizes_runtime" => authority.fetch("checks").fetch("runtime.compiler_profile_never_authorizes_execution"),
      "report.profile_status_separate_from_runtime_readiness" => compatibility.fetch("checks").fetch("schema.has_separate_compiler_profile_status") &&
        compatibility.fetch("checks").fetch("schema.has_separate_runtime_readiness"),
      "report.verified_temporal_still_blocked" => compatibility.fetch("checks").fetch("runtime.verified_temporal_metadata_only_still_blocked"),
      "scope.shadow_and_pack_proofs_present" => proof_results.any? { |result| result.fetch("scope") == "shadow_profile" } &&
        proof_results.any? { |result| result.fetch("scope") == "pack_candidate" }
    }
  end

  def required_boundaries_indexed?(proof_results)
    indexed = proof_results.map { |result| result.fetch("boundary") }
    %w[
      monolith_described_as_profile
      first_optional_semantic_pack
      pack_install_finalize_fingerprint
      before_after_priority_cycle_detection
      compiler_profile_id_before_artifact_hash
      semantic_slots_and_pack_cardinality
      slots_plus_ordered_rules_fingerprint
      understanding_authority_not_runtime_authority
      profile_status_separate_from_runtime_readiness
    ].all? { |boundary| indexed.include?(boundary) }
  end

  def migration_blockers
    [
      {
        "id" => "manifest_prop_required",
        "status" => "blocked",
        "reason" => "compiler_profile_id is proof-local until a manifest PROP and assembler migration are approved."
      },
      {
        "id" => "dispatch_kernel_not_authorized",
        "status" => "blocked",
        "reason" => "Current compiler dispatch remains monolithic until post-POC migration authorization."
      },
      {
        "id" => "ordered_registry_contract_not_canonical",
        "status" => "open",
        "reason" => "before/after/priority semantics are proven, but not yet a production CompilerKernel API."
      },
      {
        "id" => "compatibility_report_field_names_not_production",
        "status" => "open",
        "reason" => "compiler_profile_status and runtime_evaluation_readiness are proof-local proposed fields."
      }
    ]
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} compiler_profile_preflight_chain_index"
    summary.fetch("chain").each do |entry|
      puts "#{entry.fetch("id")}: #{entry.fetch("proof_status")} #{entry.fetch("boundary")}"
    end
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = CompilerProfilePreflightChainIndex.run
exit(success ? 0 : 1)
