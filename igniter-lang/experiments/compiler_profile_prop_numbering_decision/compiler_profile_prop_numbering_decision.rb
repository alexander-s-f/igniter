#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "pathname"
require "rbconfig"

module CompilerProfilePropNumberingDecision
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = LANG_ROOT / "experiments/compiler_profile_prop_numbering_decision/out"
  DECISION_PACKET_PATH = OUT_DIR / "compiler_profile_prop_numbering_decision_packet.json"
  SUMMARY_PATH = OUT_DIR / "compiler_profile_prop_numbering_decision_summary.json"

  PROMOTION_RUNNER = LANG_ROOT / "experiments/compiler_profile_manifest_prop_promotion/compiler_profile_manifest_prop_promotion.rb"
  PROMOTION_PACKET = LANG_ROOT / "experiments/compiler_profile_manifest_prop_promotion/out/compiler_profile_manifest_prop_promotion_packet.json"
  PROMOTION_SUMMARY = LANG_ROOT / "experiments/compiler_profile_manifest_prop_promotion/out/compiler_profile_manifest_prop_promotion_summary.json"
  PROPOSALS_INDEX = LANG_ROOT / "docs/proposals/README.md"

  FORMAT_VERSION = "0.1.0"
  TRACK = "compiler-profile-prop-numbering-decision-v0"

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    promotion_run = run_promotion
    promotion_packet = read_json(PROMOTION_PACKET)
    promotion_summary = read_json(PROMOTION_SUMMARY)
    proposals_index_before = File.read(PROPOSALS_INDEX)
    decision_packet = build_decision_packet(promotion_packet, proposals_index_before)
    proposals_index_after = File.read(PROPOSALS_INDEX)
    checks = build_checks(
      decision_packet,
      promotion_packet,
      promotion_summary,
      promotion_run,
      proposals_index_before,
      proposals_index_after
    )
    summary = {
      "kind" => "compiler_profile_prop_numbering_decision_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "decision_packet_path" => DECISION_PACKET_PATH.relative_path_from(ROOT).to_s,
      "checks" => checks,
      "non_goals" => [
        "No official PROP number assigned.",
        "No proposal file created.",
        "No proposal index mutation.",
        "No .igapp/.ilk format change.",
        "No compiler dispatch or assembler implementation.",
        "No runtime execution authority."
      ]
    }

    write_json(DECISION_PACKET_PATH, decision_packet)
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def run_promotion
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, PROMOTION_RUNNER.to_s, chdir: ROOT.to_s)
    {
      "command" => "ruby #{PROMOTION_RUNNER.relative_path_from(ROOT)}",
      "exit_status" => status.exitstatus,
      "stdout_first_line" => stdout.lines.first.to_s.strip,
      "stderr" => stderr.strip
    }
  end

  def build_decision_packet(promotion_packet, proposals_index)
    mentioned_ids = mentioned_prop_ids(proposals_index)
    next_free_id = format("PROP-%03d", mentioned_ids.max + 1)
    {
      "kind" => "compiler_profile_prop_numbering_decision_packet",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => "architect_decision_request_ready",
      "source_packet_ref" => PROMOTION_PACKET.relative_path_from(ROOT).to_s,
      "proposal_queue_observation" => {
        "prop033_occupied_by" => prop_033_title(proposals_index),
        "highest_explicit_prop_id_seen" => format("PROP-%03d", mentioned_ids.max),
        "next_free_id_if_queue_unchanged" => next_free_id,
        "official_prop_number_assigned_by_this_packet" => false
      },
      "recommended_decision_path" => {
        "route" => "architect_or_compiler_grammar_numbering_decision",
        "preferred_numbering_option" => "assign_next_free_id",
        "candidate_id_if_queue_unchanged" => next_free_id,
        "do_not_reassign_without_architect" => ["PROP-033", "PROP-034", "PROP-035"],
        "reason" => "PROP-033 is already queued for via profile binding, and the promotion packet intentionally does not mutate the queue."
      },
      "manifest_semantics_recommendation" => {
        "title" => promotion_packet.dig("proposal_identity", "suggested_title"),
        "field" => "compiler_profile_id",
        "profile_id_source_recommendation" => "unified_compiler_profile_id",
        "ordered_rule_profile_id_role" => "supporting evidence / transition diagnostic, not final manifest authority unless Architect chooses otherwise",
        "initial_rollout" => "legacy_optional",
        "future_rollout" => "profile_required_after_migration_evidence",
        "hash_and_signature_ordering" => "compiler_profile_id participates in artifact hash and must be added before signing",
        "expanded_profile_material_storage" => "sidecar_or_receipt_bundle_first; inline profile body not initial default"
      },
      "authority_invariants" => {
        "present_verified_implies_runtime_ready" => promotion_packet.dig(
          "must_preserve_invariants", "authority_firewall", "present_verified_implies_runtime_ready"
        ),
        "receipt_runtime_execution_authority" => promotion_packet.dig(
          "must_preserve_invariants", "receipt_profile_lane_split", "receipt_runtime_execution_authority"
        ),
        "profile_runtime_execution_authority" => promotion_packet.dig(
          "must_preserve_invariants", "receipt_profile_lane_split", "profile_runtime_execution_authority"
        ),
        "required_exactly_one_slots" => promotion_packet.dig(
          "must_preserve_invariants", "slot_invariants", "required_exactly_one_slots"
        ),
        "future_dispatch_order_source" => promotion_packet.dig(
          "must_preserve_invariants", "slot_invariants", "future_dispatch_order_source"
        ),
        "surface_slot_order_authoritative" => promotion_packet.dig(
          "must_preserve_invariants", "slot_invariants", "surface_slot_order_authoritative"
        ),
        "bootstrap_seed_explicit" => promotion_packet.dig(
          "must_preserve_invariants", "bootstrap_traceability", "explicit_seed_required"
        )
      },
      "blocked_until_numbering_decision" => promotion_packet.fetch("blocked_until_decision"),
      "decision_questions_for_architect" => [
        "Assign the official PROP number or requeue an existing placeholder.",
        "Approve or reject unified_compiler_profile_id as the manifest authority source.",
        "Confirm legacy_optional -> profile_required migration policy.",
        "Confirm hash/signature ordering before implementation cards open.",
        "Choose first storage surface for expanded profile material."
      ],
      "non_authorizations" => promotion_packet.fetch("non_authorizations") + [
        "This packet is a decision request, not the decision itself.",
        "No official proposal queue state is changed."
      ]
    }
  end

  def mentioned_prop_ids(proposals_index)
    proposals_index.scan(/PROP-(\d{3})/).flatten.map(&:to_i).uniq
  end

  def prop_033_title(proposals_index)
    line = proposals_index.lines.find { |candidate| candidate.include?("| PROP-033 |") }
    return "unknown" unless line

    line.split("|").map(&:strip)[2]
  end

  def build_checks(decision_packet, promotion_packet, promotion_summary, promotion_run, proposals_before, proposals_after)
    {
      "input.promotion_passed" => promotion_run.fetch("exit_status").zero? && promotion_summary.fetch("status") == "PASS",
      "queue.prop033_occupied" => decision_packet.dig("proposal_queue_observation", "prop033_occupied_by") == "`via profile binding`",
      "queue.next_free_candidate_is_prop036" => decision_packet.dig("proposal_queue_observation", "next_free_id_if_queue_unchanged") == "PROP-036",
      "decision.no_official_number_assigned" => decision_packet.dig(
        "proposal_queue_observation", "official_prop_number_assigned_by_this_packet"
      ) == false,
      "decision.route_is_architect_owned" => decision_packet.dig(
        "recommended_decision_path", "route"
      ) == "architect_or_compiler_grammar_numbering_decision",
      "manifest.recommends_unified_profile_id" => decision_packet.dig(
        "manifest_semantics_recommendation", "profile_id_source_recommendation"
      ) == "unified_compiler_profile_id",
      "firewall.present_verified_not_runtime_ready" => decision_packet.dig(
        "authority_invariants", "present_verified_implies_runtime_ready"
      ) == false,
      "lanes.no_runtime_authority" => decision_packet.dig(
        "authority_invariants", "receipt_runtime_execution_authority"
      ) == false && decision_packet.dig("authority_invariants", "profile_runtime_execution_authority") == false,
      "slots.required_exactly_one_preserved" => decision_packet.dig(
        "authority_invariants", "required_exactly_one_slots"
      ) == %w[core oof_registry fragment_registry escape_boundary],
      "slots.future_dispatch_order_preserved" => decision_packet.dig(
        "authority_invariants", "future_dispatch_order_source"
      ) == "CompilerProfileSpec.slot_order" && decision_packet.dig(
        "authority_invariants", "surface_slot_order_authoritative"
      ) == false,
      "bootstrap.explicit_seed_preserved" => decision_packet.dig("authority_invariants", "bootstrap_seed_explicit") == true,
      "blocked_cards_still_blocked" => decision_packet.fetch("blocked_until_numbering_decision") == promotion_packet.fetch("blocked_until_decision"),
      "scope.no_proposal_index_mutation" => proposals_before == proposals_after,
      "scope.no_decision_claimed" => decision_packet.fetch("non_authorizations").include?("This packet is a decision request, not the decision itself.")
    }
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} compiler_profile_prop_numbering_decision"
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "decision_packet: #{summary.fetch("decision_packet_path")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = CompilerProfilePropNumberingDecision.run
exit(success ? 0 : 1)
