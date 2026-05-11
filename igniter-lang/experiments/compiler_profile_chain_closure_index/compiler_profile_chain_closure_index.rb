#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "pathname"
require "rbconfig"

module CompilerProfileChainClosureIndex
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = LANG_ROOT / "experiments/compiler_profile_chain_closure_index/out"
  SUMMARY_PATH = OUT_DIR / "compiler_profile_chain_closure_index_summary.json"

  FORMAT_VERSION = "0.1.0"
  TRACK = "compiler-profile-chain-closure-index-v0"

  CHAIN = [
    {
      "id" => "compiler_pack_shadow_profile_proof",
      "phase" => "shadow_baseline",
      "claim" => "Current monolithic compiler can be described as a deterministic shadow CompilerProfile.",
      "command" => "igniter-lang/experiments/compiler_pack_shadow_profile_proof/compiler_pack_shadow_profile_proof.rb",
      "summary_path" => "igniter-lang/experiments/compiler_pack_shadow_profile_proof/out/compiler_pack_shadow_profile_proof_summary.json",
      "track_doc" => "igniter-lang/docs/tracks/compiler-pack-shadow-profile-proof-v0.md"
    },
    {
      "id" => "contract_modifiers_pack_native_boundary",
      "phase" => "first_pack_candidate",
      "claim" => "ContractModifiersPack is a first native optional capability-owned pack candidate.",
      "command" => "igniter-lang/experiments/contract_modifiers_pack_native_boundary/contract_modifiers_pack_native_boundary.rb",
      "summary_path" => "igniter-lang/experiments/contract_modifiers_pack_native_boundary/out/contract_modifiers_pack_native_boundary_summary.json",
      "track_doc" => "igniter-lang/docs/tracks/contract-modifiers-pack-native-boundary-v0.md"
    },
    {
      "id" => "compiler_kernel_pack_registry_spike",
      "phase" => "kernel_registry",
      "claim" => "Pack install/finalize/fingerprint registry model is proofable without dispatch changes.",
      "command" => "igniter-lang/experiments/compiler_kernel_pack_registry_spike/compiler_kernel_pack_registry_spike.rb",
      "summary_path" => "igniter-lang/experiments/compiler_kernel_pack_registry_spike/out/compiler_kernel_pack_registry_spike_summary.json",
      "track_doc" => "igniter-lang/docs/tracks/compiler-kernel-pack-registry-spike-v0.md"
    },
    {
      "id" => "compiler_kernel_ordered_rule_precedence",
      "phase" => "ordered_rules",
      "claim" => "Parser/classifier/typechecker rules need deterministic before/after/priority ordering.",
      "command" => "igniter-lang/experiments/compiler_kernel_ordered_rule_precedence/compiler_kernel_ordered_rule_precedence.rb",
      "summary_path" => "igniter-lang/experiments/compiler_kernel_ordered_rule_precedence/out/compiler_kernel_ordered_rule_precedence_summary.json",
      "track_doc" => "igniter-lang/docs/tracks/compiler-kernel-ordered-rule-precedence-v0.md"
    },
    {
      "id" => "compiler_profile_id_manifest_boundary",
      "phase" => "manifest_plan",
      "claim" => "compiler_profile_id belongs before artifact hash/signature, but manifest changes are not authorized.",
      "command" => "igniter-lang/experiments/compiler_profile_id_manifest_boundary/compiler_profile_id_manifest_boundary.rb",
      "summary_path" => "igniter-lang/experiments/compiler_profile_id_manifest_boundary/out/compiler_profile_id_manifest_boundary_summary.json",
      "track_doc" => "igniter-lang/docs/tracks/compiler-profile-id-manifest-boundary-plan-v0.md"
    },
    {
      "id" => "compiler_profile_slots_model",
      "phase" => "profile_slots",
      "claim" => "Profile-of-profile slots reject over-splitting and support competing implementation variants.",
      "command" => "igniter-lang/experiments/compiler_profile_slots_model/compiler_profile_slots_model.rb",
      "summary_path" => "igniter-lang/experiments/compiler_profile_slots_model/out/compiler_profile_slots_model_summary.json",
      "track_doc" => "igniter-lang/docs/tracks/compiler-profile-slots-model-v0.md"
    },
    {
      "id" => "compiler_profile_spec_and_rule_unification",
      "phase" => "unified_profile",
      "claim" => "Slots plus ordered/strict registries form one fingerprinted profile identity.",
      "command" => "igniter-lang/experiments/compiler_profile_spec_and_rule_unification/compiler_profile_spec_and_rule_unification.rb",
      "summary_path" => "igniter-lang/experiments/compiler_profile_spec_and_rule_unification/out/compiler_profile_spec_and_rule_unification_summary.json",
      "track_doc" => "igniter-lang/docs/tracks/compiler-profile-spec-and-rule-profile-unification-v0.md"
    },
    {
      "id" => "compiler_profile_authority_boundary",
      "phase" => "authority",
      "claim" => "CompilerProfile proves understanding authority, not runtime execution authority.",
      "command" => "igniter-lang/experiments/compiler_profile_authority_boundary/compiler_profile_authority_boundary.rb",
      "summary_path" => "igniter-lang/experiments/compiler_profile_authority_boundary/out/compiler_profile_authority_boundary_summary.json",
      "track_doc" => "igniter-lang/docs/tracks/compiler-profile-authority-boundary-v0.md"
    },
    {
      "id" => "compiler_profile_compatibility_report_fields",
      "phase" => "report_fields",
      "claim" => "CompatibilityReport should separate compiler_profile_status from runtime_evaluation_readiness.",
      "command" => "igniter-lang/experiments/compiler_profile_compatibility_report_fields/compiler_profile_compatibility_report_fields.rb",
      "summary_path" => "igniter-lang/experiments/compiler_profile_compatibility_report_fields/out/compiler_profile_compatibility_report_fields_summary.json",
      "track_doc" => "igniter-lang/docs/tracks/compiler-profile-compatibility-report-fields-v0.md"
    },
    {
      "id" => "compiler_profile_preflight_chain_index",
      "phase" => "preflight_index",
      "claim" => "The profile/pack foundation can be checked as one proof chain.",
      "command" => "igniter-lang/experiments/compiler_profile_preflight_chain_index/compiler_profile_preflight_chain_index.rb",
      "summary_path" => "igniter-lang/experiments/compiler_profile_preflight_chain_index/out/compiler_profile_preflight_chain_index_summary.json",
      "track_doc" => "igniter-lang/docs/tracks/compiler-profile-preflight-chain-index-v0.md"
    },
    {
      "id" => "compiler_profile_auditable_build_receipt",
      "phase" => "build_receipt",
      "claim" => "CompilationReceipt can explain source/profile/stages/packs/diagnostics/requirements/artifacts.",
      "command" => "igniter-lang/experiments/compiler_profile_auditable_build_receipt/compiler_profile_auditable_build_receipt.rb",
      "summary_path" => "igniter-lang/experiments/compiler_profile_auditable_build_receipt/out/compiler_profile_auditable_build_receipt_summary.json",
      "track_doc" => "igniter-lang/docs/tracks/compiler-profile-auditable-build-receipt-v0.md"
    },
    {
      "id" => "compilation_receipt_authority_and_storage",
      "phase" => "receipt_storage",
      "claim" => "Receipt storage has embedded, signed-bundle, and .ilk lineage levels with distinct authority.",
      "command" => "igniter-lang/experiments/compilation_receipt_authority_and_storage/compilation_receipt_authority_and_storage.rb",
      "summary_path" => "igniter-lang/experiments/compilation_receipt_authority_and_storage/out/compilation_receipt_authority_and_storage_summary.json",
      "track_doc" => "igniter-lang/docs/tracks/compilation-receipt-authority-and-storage-v0.md"
    },
    {
      "id" => "igniter_lang_self_assembly_profile_sketch",
      "phase" => "self_assembly",
      "claim" => "Igniter-Lang can describe its future compiler profile without claiming self-hosted implementation.",
      "command" => "igniter-lang/experiments/igniter_lang_self_assembly_profile_sketch/igniter_lang_self_assembly_profile_sketch.rb",
      "summary_path" => "igniter-lang/experiments/igniter_lang_self_assembly_profile_sketch/out/igniter_lang_self_assembly_profile_sketch_summary.json",
      "track_doc" => "igniter-lang/docs/tracks/igniter-lang-self-assembly-profile-sketch-v0.md"
    },
    {
      "id" => "bootstrap_descriptor_kernel",
      "phase" => "bootstrap_seed",
      "claim" => "BootstrapDescriptorKernel is an explicit seed for descriptor validation and profile fingerprinting.",
      "command" => "igniter-lang/experiments/bootstrap_descriptor_kernel/bootstrap_descriptor_kernel.rb",
      "summary_path" => "igniter-lang/experiments/bootstrap_descriptor_kernel/out/bootstrap_descriptor_kernel_summary.json",
      "track_doc" => "igniter-lang/docs/tracks/bootstrap-descriptor-kernel-v0.md"
    },
    {
      "id" => "compiler_profile_descriptor_schema",
      "phase" => "descriptor_schema",
      "claim" => "Profile/pack descriptors have a machine-readable schema, canonicalization, and error taxonomy.",
      "command" => "igniter-lang/experiments/compiler_profile_descriptor_schema/compiler_profile_descriptor_schema.rb",
      "summary_path" => "igniter-lang/experiments/compiler_profile_descriptor_schema/out/compiler_profile_descriptor_schema_summary.json",
      "track_doc" => "igniter-lang/docs/tracks/compiler-profile-descriptor-schema-v0.md"
    },
    {
      "id" => "profile_source_lowering_target",
      "phase" => "future_syntax_target",
      "claim" => "Future profile syntax should lower into compiler_profile_descriptor without parser authorization yet.",
      "command" => "igniter-lang/experiments/profile_source_lowering_target/profile_source_lowering_target.rb",
      "summary_path" => "igniter-lang/experiments/profile_source_lowering_target/out/profile_source_lowering_target_summary.json",
      "track_doc" => "igniter-lang/docs/tracks/profile-source-lowering-target-v0.md"
    },
    {
      "id" => "compiler_profile_manifest_prop_draft",
      "phase" => "manifest_prop_draft",
      "claim" => "compiler_profile_id manifest field draft composes manifest boundary, report fields, and receipt storage evidence.",
      "command" => "igniter-lang/experiments/compiler_profile_manifest_prop_draft/compiler_profile_manifest_prop_draft.rb",
      "summary_path" => "igniter-lang/experiments/compiler_profile_manifest_prop_draft/out/compiler_profile_manifest_prop_draft_summary.json",
      "track_doc" => "igniter-lang/docs/tracks/compiler-profile-manifest-prop-draft-v0.md"
    },
    {
      "id" => "profile_source_syntax_pressure",
      "phase" => "syntax_pressure",
      "claim" => "Profile source syntax remains pressure-only; descriptor-first is preferred before parser work.",
      "command" => "igniter-lang/experiments/profile_source_syntax_pressure/profile_source_syntax_pressure.rb",
      "summary_path" => "igniter-lang/experiments/profile_source_syntax_pressure/out/profile_source_syntax_pressure_summary.json",
      "track_doc" => "igniter-lang/docs/tracks/profile-source-syntax-pressure-v0.md"
    },
    {
      "id" => "compiler_profile_manifest_prop_review_ready",
      "phase" => "manifest_prop_review_ready",
      "claim" => "Manifest PROP draft is Architect-review-ready with authority firewall, slot invariants, and bootstrap traceability locked.",
      "command" => "igniter-lang/experiments/compiler_profile_manifest_prop_review_ready/compiler_profile_manifest_prop_review_ready.rb",
      "summary_path" => "igniter-lang/experiments/compiler_profile_manifest_prop_review_ready/out/compiler_profile_manifest_prop_review_ready_summary.json",
      "track_doc" => "igniter-lang/docs/tracks/compiler-profile-manifest-prop-review-ready-v0.md"
    },
    {
      "id" => "compiler_profile_manifest_prop_promotion",
      "phase" => "manifest_prop_promotion",
      "claim" => "Manifest PROP review packet is ready for Architect numbering/routing without claiming a number or mutating proposal index.",
      "command" => "igniter-lang/experiments/compiler_profile_manifest_prop_promotion/compiler_profile_manifest_prop_promotion.rb",
      "summary_path" => "igniter-lang/experiments/compiler_profile_manifest_prop_promotion/out/compiler_profile_manifest_prop_promotion_summary.json",
      "track_doc" => "igniter-lang/docs/tracks/compiler-profile-manifest-prop-promotion-v0.md"
    },
    {
      "id" => "compiler_profile_prop_numbering_decision",
      "phase" => "prop_numbering_decision_request",
      "claim" => "Compiler profile manifest PROP has an Architect-owned numbering decision request without assigning a number.",
      "command" => "igniter-lang/experiments/compiler_profile_prop_numbering_decision/compiler_profile_prop_numbering_decision.rb",
      "summary_path" => "igniter-lang/experiments/compiler_profile_prop_numbering_decision/out/compiler_profile_prop_numbering_decision_summary.json",
      "track_doc" => "igniter-lang/docs/tracks/compiler-profile-prop-numbering-decision-v0.md"
    },
    {
      "id" => "compiler_profile_descriptor_error_taxonomy_sharpening",
      "phase" => "descriptor_error_taxonomy",
      "claim" => "Descriptor diagnostics have a first-failure precedence model for shape, slots, pack semantics, and registry ordering.",
      "command" => "igniter-lang/experiments/compiler_profile_descriptor_error_taxonomy_sharpening/compiler_profile_descriptor_error_taxonomy_sharpening.rb",
      "summary_path" => "igniter-lang/experiments/compiler_profile_descriptor_error_taxonomy_sharpening/out/compiler_profile_descriptor_error_taxonomy_sharpening_summary.json",
      "track_doc" => "igniter-lang/docs/tracks/compiler-profile-descriptor-error-taxonomy-sharpening-v0.md"
    },
    {
      "id" => "profile_source_syntax_compiler_review",
      "phase" => "profile_syntax_compiler_review",
      "claim" => "Profile source syntax has a research baseline and Compiler/Grammar review packet without syntax authorization.",
      "command" => "igniter-lang/experiments/profile_source_syntax_compiler_review/profile_source_syntax_compiler_review.rb",
      "summary_path" => "igniter-lang/experiments/profile_source_syntax_compiler_review/out/profile_source_syntax_compiler_review_summary.json",
      "track_doc" => "igniter-lang/docs/tracks/profile-source-syntax-compiler-review-v0.md"
    },
    {
      "id" => "profile_source_syntax_grammar_boundary",
      "phase" => "profile_syntax_grammar_boundary",
      "claim" => "Profile source syntax has a Compiler/Grammar-owned decision boundary without grammar acceptance or parser work.",
      "command" => "igniter-lang/experiments/profile_source_syntax_grammar_boundary/profile_source_syntax_grammar_boundary.rb",
      "summary_path" => "igniter-lang/experiments/profile_source_syntax_grammar_boundary/out/profile_source_syntax_grammar_boundary_summary.json",
      "track_doc" => "igniter-lang/docs/tracks/profile-source-syntax-grammar-boundary-v0.md"
    }
  ].freeze

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    entries = CHAIN.map { |item| run_entry(item) }
    checks = build_checks(entries)
    summary = {
      "kind" => "compiler_profile_chain_closure_index_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "chain" => entries,
      "checks" => checks,
      "what_this_index_authorizes" => [
        "Use this as the current proof map for background compiler profile architecture.",
        "Continue foundation research from descriptor schema or lowering target."
      ],
      "what_this_index_does_not_authorize" => [
        "No production CompilerKernel or CompilerPack implementation.",
        "No compiler dispatch rewrite.",
        "No profile source parser syntax.",
        "No .igapp/.ilk format change.",
        "No runtime execution authority."
      ],
      "recommended_next" => [
        "compiler-profile-validator-implementation-plan-v0",
        "compiler-profile-manifest-prop-architect-routing-v0",
        "profile-source-syntax-grammar-boundary-review-v0"
      ]
    }
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def run_entry(item)
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, item.fetch("command"), chdir: ROOT.to_s)
    summary = read_json(ROOT / item.fetch("summary_path"))
    item.merge(
      "exit_status" => status.exitstatus,
      "proof_status" => summary.fetch("status", "UNKNOWN"),
      "stdout_first_line" => stdout.lines.first.to_s.strip,
      "stderr" => stderr.strip,
      "check_count" => summary.fetch("checks", {}).length
    )
  end

  def build_checks(entries)
    phases = entries.map { |entry| entry.fetch("phase") }
    {
      "chain.starts_with_shadow_profile" => entries.first.fetch("id") == "compiler_pack_shadow_profile_proof",
      "chain.includes_profile_source_lowering_target" => entries.any? { |entry| entry.fetch("id") == "profile_source_lowering_target" },
      "chain.includes_manifest_prop_draft" => entries.any? { |entry| entry.fetch("id") == "compiler_profile_manifest_prop_draft" },
      "chain.includes_syntax_pressure" => entries.any? { |entry| entry.fetch("id") == "profile_source_syntax_pressure" },
      "chain.includes_manifest_prop_review_ready" => entries.any? { |entry| entry.fetch("id") == "compiler_profile_manifest_prop_review_ready" },
      "chain.includes_manifest_prop_promotion" => entries.any? { |entry| entry.fetch("id") == "compiler_profile_manifest_prop_promotion" },
      "chain.includes_prop_numbering_decision_request" => entries.any? { |entry| entry.fetch("id") == "compiler_profile_prop_numbering_decision" },
      "chain.includes_descriptor_error_taxonomy" => entries.any? { |entry| entry.fetch("id") == "compiler_profile_descriptor_error_taxonomy_sharpening" },
      "chain.includes_profile_syntax_compiler_review" => entries.any? { |entry| entry.fetch("id") == "profile_source_syntax_compiler_review" },
      "chain.ends_with_profile_syntax_grammar_boundary" => entries.last.fetch("id") == "profile_source_syntax_grammar_boundary",
      "chain.all_commands_exited_zero" => entries.all? { |entry| entry.fetch("exit_status").zero? },
      "chain.all_summaries_pass" => entries.all? { |entry| entry.fetch("proof_status") == "PASS" },
      "chain.has_expected_phase_count" => phases.length == 24,
      "chain.has_receipt_and_storage_phases" => phases.include?("build_receipt") && phases.include?("receipt_storage"),
      "chain.has_self_assembly_and_bootstrap_phases" => phases.include?("self_assembly") && phases.include?("bootstrap_seed"),
      "chain.has_descriptor_and_lowering_phases" => phases.include?("descriptor_schema") && phases.include?("future_syntax_target"),
      "chain.has_manifest_prop_draft_phase" => phases.include?("manifest_prop_draft"),
      "chain.has_syntax_pressure_phase" => phases.include?("syntax_pressure"),
      "chain.has_manifest_review_ready_phase" => phases.include?("manifest_prop_review_ready"),
      "chain.has_manifest_promotion_phase" => phases.include?("manifest_prop_promotion"),
      "chain.has_prop_numbering_decision_request_phase" => phases.include?("prop_numbering_decision_request"),
      "chain.has_descriptor_error_taxonomy_phase" => phases.include?("descriptor_error_taxonomy"),
      "chain.has_profile_syntax_compiler_review_phase" => phases.include?("profile_syntax_compiler_review"),
      "chain.has_profile_syntax_grammar_boundary_phase" => phases.include?("profile_syntax_grammar_boundary"),
      "scope.no_runtime_authority_phase" => entries.none? { |entry| entry.fetch("phase").include?("runtime_authority") }
    }
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} compiler_profile_chain_closure_index"
    summary.fetch("chain").each_with_index do |entry, index|
      puts "#{index + 1}. #{entry.fetch("id")}: #{entry.fetch("proof_status")} #{entry.fetch("phase")}"
    end
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = CompilerProfileChainClosureIndex.run
exit(success ? 0 : 1)
