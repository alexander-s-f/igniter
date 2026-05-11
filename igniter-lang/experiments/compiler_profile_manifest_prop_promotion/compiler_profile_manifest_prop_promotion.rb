#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "pathname"
require "rbconfig"

module CompilerProfileManifestPropPromotion
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = LANG_ROOT / "experiments/compiler_profile_manifest_prop_promotion/out"
  PROMOTION_PACKET_PATH = OUT_DIR / "compiler_profile_manifest_prop_promotion_packet.json"
  SUMMARY_PATH = OUT_DIR / "compiler_profile_manifest_prop_promotion_summary.json"

  REVIEW_READY_RUNNER = LANG_ROOT / "experiments/compiler_profile_manifest_prop_review_ready/compiler_profile_manifest_prop_review_ready.rb"
  REVIEW_PACKET = LANG_ROOT / "experiments/compiler_profile_manifest_prop_review_ready/out/compiler_profile_manifest_architect_review_packet.json"
  REVIEW_SUMMARY = LANG_ROOT / "experiments/compiler_profile_manifest_prop_review_ready/out/compiler_profile_manifest_prop_review_ready_summary.json"
  PROPOSALS_INDEX = LANG_ROOT / "docs/proposals/README.md"

  FORMAT_VERSION = "0.1.0"
  TRACK = "compiler-profile-manifest-prop-promotion-v0"

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    review_run = run_review_ready
    review_packet = read_json(REVIEW_PACKET)
    review_summary = read_json(REVIEW_SUMMARY)
    proposals_index = File.read(PROPOSALS_INDEX)
    promotion_packet = build_promotion_packet(review_packet, proposals_index)
    checks = build_checks(promotion_packet, review_packet, review_summary, review_run, proposals_index)
    summary = {
      "kind" => "compiler_profile_manifest_prop_promotion_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "promotion_packet_path" => PROMOTION_PACKET_PATH.relative_path_from(ROOT).to_s,
      "checks" => checks,
      "non_goals" => [
        "No official PROP number claimed.",
        "No proposal file created.",
        "No proposals index mutation.",
        "No assembler or loader implementation.",
        "No .igapp/.ilk format change.",
        "No runtime execution authority."
      ]
    }

    write_json(PROMOTION_PACKET_PATH, promotion_packet)
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def run_review_ready
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, REVIEW_READY_RUNNER.to_s, chdir: ROOT.to_s)
    {
      "command" => "ruby #{REVIEW_READY_RUNNER.relative_path_from(ROOT)}",
      "exit_status" => status.exitstatus,
      "stdout_first_line" => stdout.lines.first.to_s.strip,
      "stderr" => stderr.strip
    }
  end

  def build_promotion_packet(review_packet, proposals_index)
    {
      "kind" => "compiler_profile_manifest_prop_promotion_packet",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => "ready_for_architect_numbering",
      "proposal_identity" => {
        "suggested_title" => "compiler_profile_id manifest semantics",
        "official_prop_number_claimed" => false,
        "official_prop_file_created" => false,
        "prop033_queue_occupied" => prop_033_queued?(proposals_index),
        "safe_numbering_options" => [
          "Architect assigns next free PROP number after queued PROP-033..PROP-035, likely PROP-036 if queue is unchanged.",
          "Architect requeues via-profile-binding and assigns this draft to PROP-033.",
          "Compiler/Grammar Expert promotes as a non-numbered draft until proposal queue is reconciled."
        ]
      },
      "promotion_inputs" => {
        "review_packet_ref" => REVIEW_PACKET.relative_path_from(ROOT).to_s,
        "review_status" => review_packet.fetch("status"),
        "proposals_index_ref" => PROPOSALS_INDEX.relative_path_from(ROOT).to_s
      },
      "proposed_prop_sections" => proposed_prop_sections(review_packet),
      "must_preserve_invariants" => {
        "authority_firewall" => review_packet.fetch("compatibility_firewall"),
        "receipt_profile_lane_split" => review_packet.fetch("receipt_lane"),
        "slot_invariants" => review_packet.fetch("slot_invariants"),
        "bootstrap_traceability" => review_packet.fetch("bootstrap_traceability")
      },
      "promotion_decision_needed" => [
        "Assign official PROP number.",
        "Choose compiler_profile_id profile id source: ordered-rule profile or unified compiler profile.",
        "Approve legacy_optional rollout policy.",
        "Approve artifact hash/signature ordering.",
        "Choose expanded profile material storage surface.",
        "Open implementation cards only after PROP approval."
      ],
      "blocked_until_decision" => [
        "assembler-compiler-profile-id-field-v0",
        "loader-compiler-profile-status-report-v0",
        "artifact-hash-profile-id-golden-migration-v0",
        "compilation-receipt-manifest-link-v0"
      ],
      "non_authorizations" => review_packet.fetch("non_authorizations") + [
        "No official PROP number is claimed by this promotion packet.",
        "No proposal queue mutation is performed by this promotion packet."
      ]
    }
  end

  def proposed_prop_sections(review_packet)
    {
      "status" => "draft_for_architect_review",
      "problem" => "Artifacts need to record which compiler profile was allowed to understand and assemble them.",
      "field_shape" => review_packet.fetch("manifest_field"),
      "hash_and_signature_policy" => review_packet.fetch("hash_and_signature_policy"),
      "loader_policy" => review_packet.fetch("loader_policy"),
      "compatibility_report_policy" => review_packet.fetch("compatibility_firewall"),
      "compilation_receipt_relationship" => review_packet.fetch("receipt_lane"),
      "slot_order_and_profile_identity" => review_packet.fetch("slot_invariants"),
      "bootstrap_and_audit_traceability" => review_packet.fetch("bootstrap_traceability"),
      "migration_order" => [
        "Approve PROP.",
        "Add report-only loader states.",
        "Add assembler field under legacy_optional.",
        "Regenerate hashes/goldens intentionally.",
        "Link CompilationReceipt after manifest ordering is stable.",
        "Consider profile_required only after migration evidence."
      ],
      "implementation_cards" => review_packet.fetch("implementation_cards")
    }
  end

  def build_checks(promotion_packet, review_packet, review_summary, review_run, proposals_index)
    {
      "input.review_ready_passed" => review_run.fetch("exit_status").zero? && review_summary.fetch("status") == "PASS",
      "queue.prop033_detected_as_occupied" => promotion_packet.dig("proposal_identity", "prop033_queue_occupied") == true,
      "promotion.no_official_number_claimed" => promotion_packet.dig("proposal_identity", "official_prop_number_claimed") == false,
      "promotion.no_prop_file_created" => promotion_packet.dig("proposal_identity", "official_prop_file_created") == false,
      "firewall.present_verified_not_runtime_ready" => promotion_packet.dig(
        "must_preserve_invariants", "authority_firewall", "present_verified_implies_runtime_ready"
      ) == false,
      "lanes.receipt_and_profile_no_runtime_authority" => promotion_packet.dig(
        "must_preserve_invariants", "receipt_profile_lane_split", "receipt_runtime_execution_authority"
      ) == false && promotion_packet.dig(
        "must_preserve_invariants", "receipt_profile_lane_split", "profile_runtime_execution_authority"
      ) == false,
      "slots.required_exactly_one_preserved" => promotion_packet.dig(
        "must_preserve_invariants", "slot_invariants", "required_exactly_one_slots"
      ) == %w[core oof_registry fragment_registry escape_boundary],
      "slots.slot_order_drives_future_dispatch" => promotion_packet.dig(
        "must_preserve_invariants", "slot_invariants", "future_dispatch_order_source"
      ) == "CompilerProfileSpec.slot_order",
      "bootstrap.seed_traceability_preserved" => promotion_packet.dig(
        "must_preserve_invariants", "bootstrap_traceability", "explicit_seed_required"
      ) == true,
      "sections.include_manifest_and_receipt_policies" => promotion_packet.dig("proposed_prop_sections", "field_shape").fetch("name") == "compiler_profile_id" &&
        promotion_packet.dig("proposed_prop_sections", "compilation_receipt_relationship").fetch("receipt_explains_build") == true,
      "blocked_cards_remain_blocked" => promotion_packet.fetch("blocked_until_decision").include?("assembler-compiler-profile-id-field-v0"),
      "scope.no_proposal_index_mutation" => proposals_index.include?("PROP-033 | `via profile binding`") &&
        promotion_packet.fetch("non_authorizations").include?("No proposal queue mutation is performed by this promotion packet.")
    }
  end

  def prop_033_queued?(proposals_index)
    proposals_index.include?("PROP-033 | `via profile binding`")
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} compiler_profile_manifest_prop_promotion"
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "promotion_packet: #{summary.fetch("promotion_packet_path")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = CompilerProfileManifestPropPromotion.run
exit(success ? 0 : 1)
