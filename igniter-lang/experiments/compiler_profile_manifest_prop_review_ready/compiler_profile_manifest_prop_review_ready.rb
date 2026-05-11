#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "pathname"
require "rbconfig"

module CompilerProfileManifestPropReviewReady
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = LANG_ROOT / "experiments/compiler_profile_manifest_prop_review_ready/out"
  REVIEW_PACKET_PATH = OUT_DIR / "compiler_profile_manifest_architect_review_packet.json"
  SUMMARY_PATH = OUT_DIR / "compiler_profile_manifest_prop_review_ready_summary.json"

  MANIFEST_DRAFT_RUNNER = LANG_ROOT / "experiments/compiler_profile_manifest_prop_draft/compiler_profile_manifest_prop_draft.rb"
  MANIFEST_DRAFT = LANG_ROOT / "experiments/compiler_profile_manifest_prop_draft/out/compiler_profile_manifest_prop_draft.json"
  MANIFEST_DRAFT_SUMMARY = LANG_ROOT / "experiments/compiler_profile_manifest_prop_draft/out/compiler_profile_manifest_prop_draft_summary.json"
  SLOTS_SUMMARY = LANG_ROOT / "experiments/compiler_profile_slots_model/out/compiler_profile_slots_model_summary.json"
  UNIFIED_SUMMARY = LANG_ROOT / "experiments/compiler_profile_spec_and_rule_unification/out/compiler_profile_spec_and_rule_unification_summary.json"
  REPORT_FIELDS_SUMMARY = LANG_ROOT / "experiments/compiler_profile_compatibility_report_fields/out/compiler_profile_compatibility_report_fields_summary.json"
  RECEIPT_STORAGE_SUMMARY = LANG_ROOT / "experiments/compilation_receipt_authority_and_storage/out/compilation_receipt_authority_and_storage_summary.json"
  BOOTSTRAP_SUMMARY = LANG_ROOT / "experiments/bootstrap_descriptor_kernel/out/bootstrap_descriptor_kernel_summary.json"
  SYNTAX_PRESSURE_RUNNER = LANG_ROOT / "experiments/profile_source_syntax_pressure/profile_source_syntax_pressure.rb"
  SYNTAX_PRESSURE_SUMMARY = LANG_ROOT / "experiments/profile_source_syntax_pressure/out/profile_source_syntax_pressure_summary.json"

  FORMAT_VERSION = "0.1.0"
  TRACK = "compiler-profile-manifest-prop-review-ready-v0"

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    manifest_run = run_command(MANIFEST_DRAFT_RUNNER)
    syntax_run = run_command(SYNTAX_PRESSURE_RUNNER)
    draft = read_json(MANIFEST_DRAFT)
    manifest_summary = read_json(MANIFEST_DRAFT_SUMMARY)
    slots = read_json(SLOTS_SUMMARY)
    unified = read_json(UNIFIED_SUMMARY)
    report_fields = read_json(REPORT_FIELDS_SUMMARY)
    receipt_storage = read_json(RECEIPT_STORAGE_SUMMARY)
    bootstrap = read_json(BOOTSTRAP_SUMMARY)
    syntax_pressure = read_json(SYNTAX_PRESSURE_SUMMARY)

    packet = build_packet(draft, slots, unified, report_fields, receipt_storage, bootstrap, syntax_pressure)
    checks = build_checks(packet, manifest_summary, syntax_pressure, manifest_run, syntax_run)
    summary = {
      "kind" => "compiler_profile_manifest_prop_review_ready_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "review_packet_path" => REVIEW_PACKET_PATH.relative_path_from(ROOT).to_s,
      "checks" => checks,
      "non_goals" => [
        "No official PROP number claimed.",
        "No proposal index mutation.",
        "No assembler implementation.",
        "No .igapp/.ilk format change.",
        "No runtime execution authority."
      ]
    }

    write_json(REVIEW_PACKET_PATH, packet)
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

  def build_packet(draft, slots, unified, report_fields, receipt_storage, bootstrap, syntax_pressure)
    slot_order = slots.fetch("profile_spec").fetch("slot_order")
    {
      "kind" => "compiler_profile_manifest_architect_review_packet",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => "architect_review_ready_candidate",
      "promotion_note" => {
        "official_prop_number_claimed" => false,
        "reason" => "PROP-033 is already queued for via profile binding; Architect/Compiler-Expert should assign or requeue."
      },
      "manifest_field" => draft.fetch("proposed_manifest_field"),
      "hash_and_signature_policy" => draft.fetch("artifact_hash_and_signature_policy"),
      "loader_policy" => draft.fetch("loader_policy"),
      "compatibility_firewall" => {
        "compiler_profile_status_values" => draft.dig("compatibility_report_fields", "compiler_profile_status"),
        "runtime_evaluation_readiness_values" => draft.dig("compatibility_report_fields", "runtime_evaluation_readiness"),
        "invariant" => draft.dig("compatibility_report_fields", "invariant"),
        "present_verified_implies_runtime_ready" => false
      },
      "receipt_lane" => {
        "receipt_explains_build" => true,
        "profile_identifies_compiler" => true,
        "receipt_runtime_execution_authority" => false,
        "profile_runtime_execution_authority" => false,
        "storage_policy_ref" => receipt_storage.fetch("policy_path")
      },
      "slot_invariants" => {
        "canonical_slot_order" => slot_order,
        "future_dispatch_order_source" => "CompilerProfileSpec.slot_order",
        "surface_slot_order_authoritative" => false,
        "syntax_pressure_ref" => SYNTAX_PRESSURE_SUMMARY.relative_path_from(ROOT).to_s,
        "required_exactly_one_slots" => required_exactly_one_slots(slots),
        "implementation_id_changes_profile_id" => unified.dig("checks", "fingerprint.slot_implementation_change_changes_profile")
      },
      "bootstrap_traceability" => {
        "bootstrap_summary_ref" => BOOTSTRAP_SUMMARY.relative_path_from(ROOT).to_s,
        "explicit_seed_required" => true,
        "bootstrap_profile_id" => bootstrap.fetch("profile_id"),
        "runtime_execution_authority" => false
      },
      "architect_review_questions" => [
        "Which official PROP number should carry compiler_profile_id manifest semantics?",
        "Should compiler_profile_id use ordered_rule_profile id first or unified compiler_profile id first?",
        "When does legacy_optional move to profile_required?",
        "Should expanded profile material live in a sidecar, receipt bundle, .ilk, or all three?",
        "Which implementation card owns artifact hash/golden migration?"
      ],
      "implementation_cards" => draft.fetch("implementation_cards"),
      "source_evidence" => draft.fetch("source_evidence").merge(
        "slots_model" => SLOTS_SUMMARY.relative_path_from(ROOT).to_s,
        "unified_profile" => UNIFIED_SUMMARY.relative_path_from(ROOT).to_s,
        "bootstrap_descriptor_kernel" => BOOTSTRAP_SUMMARY.relative_path_from(ROOT).to_s,
        "syntax_pressure" => SYNTAX_PRESSURE_SUMMARY.relative_path_from(ROOT).to_s
      ),
      "non_authorizations" => [
        "No runtime execution authority.",
        "No parser syntax authorization.",
        "No assembler or loader implementation.",
        "No .igapp/.ilk format mutation before PROP approval.",
        "No production dispatch rewrite."
      ]
    }
  end

  def required_exactly_one_slots(slots)
    slots.fetch("profile_spec").fetch("slots").filter_map do |slot, spec|
      slot if spec.fetch("cardinality") == "exactly_one"
    end
  end

  def build_checks(packet, manifest_summary, syntax_pressure, manifest_run, syntax_run)
    {
      "input.manifest_draft_passed" => manifest_run.fetch("exit_status").zero? && manifest_summary.fetch("status") == "PASS",
      "input.syntax_pressure_passed" => syntax_run.fetch("exit_status").zero? && syntax_pressure.fetch("status") == "PASS",
      "promotion.no_official_prop_number_claimed" => packet.dig("promotion_note", "official_prop_number_claimed") == false,
      "firewall.present_verified_not_runtime_ready" => packet.dig("compatibility_firewall", "present_verified_implies_runtime_ready") == false &&
        packet.dig("compatibility_firewall", "invariant").to_s.include?("must not imply"),
      "lanes.receipt_and_profile_no_runtime_authority" => packet.dig("receipt_lane", "receipt_runtime_execution_authority") == false &&
        packet.dig("receipt_lane", "profile_runtime_execution_authority") == false,
      "slots.required_exactly_one_nonremovable" => packet.dig("slot_invariants", "required_exactly_one_slots") == %w[
        core
        oof_registry
        fragment_registry
        escape_boundary
      ],
      "slots.contract_modifiers_before_temporal" => slot_index(packet, "contract_modifiers") < slot_index(packet, "temporal"),
      "slots.assumptions_after_contract_modifiers" => slot_index(packet, "assumptions") > slot_index(packet, "contract_modifiers"),
      "slots.surface_order_not_authoritative" => packet.dig("slot_invariants", "surface_slot_order_authoritative") == false &&
        packet.dig("slot_invariants", "future_dispatch_order_source") == "CompilerProfileSpec.slot_order",
      "slots.implementation_id_changes_profile" => packet.dig("slot_invariants", "implementation_id_changes_profile_id") == true,
      "bootstrap.explicit_seed_traceable" => packet.dig("bootstrap_traceability", "explicit_seed_required") == true &&
        packet.dig("bootstrap_traceability", "runtime_execution_authority") == false,
      "scope.non_authorizations_include_format_and_dispatch" => packet.fetch("non_authorizations").include?("No .igapp/.ilk format mutation before PROP approval.") &&
        packet.fetch("non_authorizations").include?("No production dispatch rewrite.")
    }
  end

  def slot_index(packet, slot)
    packet.dig("slot_invariants", "canonical_slot_order").index(slot)
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} compiler_profile_manifest_prop_review_ready"
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "review_packet: #{summary.fetch("review_packet_path")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = CompilerProfileManifestPropReviewReady.run
exit(success ? 0 : 1)
