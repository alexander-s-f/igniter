#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "pathname"
require "rbconfig"

module CompilerProfileManifestPropArchitectRouting
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = LANG_ROOT / "experiments/compiler_profile_manifest_prop_architect_routing/out"
  ROUTING_PACKET_PATH = OUT_DIR / "compiler_profile_manifest_prop_architect_routing_packet.json"
  SUMMARY_PATH = OUT_DIR / "compiler_profile_manifest_prop_architect_routing_summary.json"

  NUMBERING_RUNNER = LANG_ROOT / "experiments/compiler_profile_prop_numbering_decision/compiler_profile_prop_numbering_decision.rb"
  NUMBERING_PACKET = LANG_ROOT / "experiments/compiler_profile_prop_numbering_decision/out/compiler_profile_prop_numbering_decision_packet.json"
  NUMBERING_SUMMARY = LANG_ROOT / "experiments/compiler_profile_prop_numbering_decision/out/compiler_profile_prop_numbering_decision_summary.json"
  PROMOTION_PACKET = LANG_ROOT / "experiments/compiler_profile_manifest_prop_promotion/out/compiler_profile_manifest_prop_promotion_packet.json"
  PROPOSALS_INDEX = LANG_ROOT / "docs/proposals/README.md"

  FORMAT_VERSION = "0.1.0"
  TRACK = "compiler-profile-manifest-prop-architect-routing-v0"

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    proposals_before = File.read(PROPOSALS_INDEX)
    numbering_run = run_numbering
    numbering_packet = read_json(NUMBERING_PACKET)
    numbering_summary = read_json(NUMBERING_SUMMARY)
    promotion_packet = read_json(PROMOTION_PACKET)
    routing_packet = build_routing_packet(numbering_packet, promotion_packet)
    proposals_after = File.read(PROPOSALS_INDEX)
    checks = build_checks(routing_packet, numbering_run, numbering_summary, proposals_before, proposals_after)
    summary = {
      "kind" => "compiler_profile_manifest_prop_architect_routing_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "routing_packet_path" => ROUTING_PACKET_PATH.relative_path_from(ROOT).to_s,
      "checks" => checks,
      "non_goals" => [
        "No official PROP number assignment.",
        "No proposal file creation.",
        "No proposal index mutation.",
        "No assembler or loader implementation.",
        "No artifact hash/golden migration.",
        "No .igapp/.ilk format change.",
        "No runtime execution authority."
      ]
    }

    write_json(ROUTING_PACKET_PATH, routing_packet)
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def run_numbering
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, NUMBERING_RUNNER.to_s, chdir: ROOT.to_s)
    {
      "command" => "ruby #{NUMBERING_RUNNER.relative_path_from(ROOT)}",
      "exit_status" => status.exitstatus,
      "stdout_first_line" => stdout.lines.first.to_s.strip,
      "stderr" => stderr.strip
    }
  end

  def build_routing_packet(numbering_packet, promotion_packet)
    {
      "kind" => "compiler_profile_manifest_prop_architect_routing_packet",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => "ready_for_architect_routing",
      "routing_target" => {
        "primary_owner" => "[Architect Supervisor / Codex]",
        "secondary_review_owner" => "[Igniter-Lang Compiler/Grammar Expert]",
        "requested_action" => "assign_or_route_official_prop_number",
        "research_agent_decision_authority" => false
      },
      "source_packets" => {
        "numbering_decision_packet" => NUMBERING_PACKET.relative_path_from(ROOT).to_s,
        "promotion_packet" => PROMOTION_PACKET.relative_path_from(ROOT).to_s
      },
      "queue_state" => numbering_packet.fetch("proposal_queue_observation"),
      "recommended_route" => {
        "preferred" => "assign_next_free_id_if_queue_unchanged",
        "candidate_id" => numbering_packet.dig("recommended_decision_path", "candidate_id_if_queue_unchanged"),
        "do_not_reassign_without_architect" => numbering_packet.dig(
          "recommended_decision_path", "do_not_reassign_without_architect"
        ),
        "alternate_routes" => [
          "Requeue via profile binding and assign compiler_profile_id manifest semantics to PROP-033.",
          "Keep this as a non-numbered draft until proposal queue is reconciled."
        ]
      },
      "prop_payload_ready_for_review" => {
        "title" => promotion_packet.dig("proposal_identity", "suggested_title"),
        "sections" => promotion_packet.fetch("proposed_prop_sections").keys,
        "field" => promotion_packet.dig("proposed_prop_sections", "field_shape", "name"),
        "profile_id_source_recommendation" => numbering_packet.dig(
          "manifest_semantics_recommendation", "profile_id_source_recommendation"
        ),
        "initial_rollout" => numbering_packet.dig("manifest_semantics_recommendation", "initial_rollout"),
        "future_rollout" => numbering_packet.dig("manifest_semantics_recommendation", "future_rollout"),
        "hash_and_signature_ordering" => numbering_packet.dig(
          "manifest_semantics_recommendation", "hash_and_signature_ordering"
        )
      },
      "architect_decisions_requested" => [
        "Assign official PROP number or choose requeue path.",
        "Confirm unified_compiler_profile_id as manifest authority source.",
        "Approve legacy_optional -> profile_required migration policy.",
        "Approve hash/signature ordering.",
        "Choose expanded profile material storage surface.",
        "Decide whether implementation cards may open after proposal approval."
      ],
      "must_preserve" => {
        "authority_invariants" => numbering_packet.fetch("authority_invariants"),
        "blocked_until_numbering_decision" => numbering_packet.fetch("blocked_until_numbering_decision"),
        "present_verified_implies_runtime_ready" => numbering_packet.dig(
          "authority_invariants", "present_verified_implies_runtime_ready"
        ),
        "proposal_queue_mutation_allowed_by_this_packet" => false,
        "official_prop_number_assigned_by_this_packet" => false
      },
      "blocked_implementation_cards" => numbering_packet.fetch("blocked_until_numbering_decision"),
      "non_authorizations" => numbering_packet.fetch("non_authorizations") + [
        "This routing packet does not assign the official PROP number.",
        "This routing packet does not create or edit proposal files.",
        "This routing packet does not unblock implementation cards."
      ]
    }
  end

  def build_checks(routing_packet, numbering_run, numbering_summary, proposals_before, proposals_after)
    {
      "input.numbering_decision_passed" => numbering_run.fetch("exit_status").zero? && numbering_summary.fetch("status") == "PASS",
      "routing.ready_for_architect" => routing_packet.fetch("status") == "ready_for_architect_routing",
      "routing.primary_owner_architect" => routing_packet.dig(
        "routing_target", "primary_owner"
      ) == "[Architect Supervisor / Codex]",
      "routing.research_has_no_decision_authority" => routing_packet.dig(
        "routing_target", "research_agent_decision_authority"
      ) == false,
      "queue.prop033_occupied_and_candidate_prop036" => routing_packet.dig("queue_state", "prop033_occupied_by") == "`via profile binding`" &&
        routing_packet.dig("recommended_route", "candidate_id") == "PROP-036",
      "proposal.payload_has_compiler_profile_id_field" => routing_packet.dig(
        "prop_payload_ready_for_review", "field"
      ) == "compiler_profile_id",
      "proposal.recommends_unified_profile_id" => routing_packet.dig(
        "prop_payload_ready_for_review", "profile_id_source_recommendation"
      ) == "unified_compiler_profile_id",
      "firewall.present_verified_not_runtime_ready" => routing_packet.dig(
        "must_preserve", "present_verified_implies_runtime_ready"
      ) == false,
      "blocked.implementation_cards_remain_blocked" => routing_packet.fetch("blocked_implementation_cards").include?(
        "assembler-compiler-profile-id-field-v0"
      ) && routing_packet.fetch("non_authorizations").include?(
        "This routing packet does not unblock implementation cards."
      ),
      "scope.no_prop_number_assigned" => routing_packet.dig(
        "must_preserve", "official_prop_number_assigned_by_this_packet"
      ) == false,
      "scope.no_proposal_queue_mutation" => proposals_before == proposals_after &&
        routing_packet.dig("must_preserve", "proposal_queue_mutation_allowed_by_this_packet") == false,
      "scope.no_runtime_authority" => routing_packet.fetch("non_authorizations").include?("No runtime execution authority.")
    }
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} compiler_profile_manifest_prop_architect_routing"
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "routing_packet: #{summary.fetch("routing_packet_path")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = CompilerProfileManifestPropArchitectRouting.run
exit(success ? 0 : 1)
