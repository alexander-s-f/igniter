#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "pathname"
require "rbconfig"

module ProfileSourceSyntaxGrammarBoundary
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = LANG_ROOT / "experiments/profile_source_syntax_grammar_boundary/out"
  BOUNDARY_PACKET_PATH = OUT_DIR / "profile_source_syntax_grammar_boundary_packet.json"
  SUMMARY_PATH = OUT_DIR / "profile_source_syntax_grammar_boundary_summary.json"

  REVIEW_RUNNER = LANG_ROOT / "experiments/profile_source_syntax_compiler_review/profile_source_syntax_compiler_review.rb"
  REVIEW_PACKET = LANG_ROOT / "experiments/profile_source_syntax_compiler_review/out/profile_source_syntax_compiler_review_packet.json"
  REVIEW_SUMMARY = LANG_ROOT / "experiments/profile_source_syntax_compiler_review/out/profile_source_syntax_compiler_review_summary.json"

  FORMAT_VERSION = "0.1.0"
  TRACK = "profile-source-syntax-grammar-boundary-v0"

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    review_run = run_review
    review_packet = read_json(REVIEW_PACKET)
    review_summary = read_json(REVIEW_SUMMARY)
    boundary_packet = build_boundary_packet(review_packet)
    checks = build_checks(boundary_packet, review_run, review_summary)
    summary = {
      "kind" => "profile_source_syntax_grammar_boundary_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "boundary_packet_path" => BOUNDARY_PACKET_PATH.relative_path_from(ROOT).to_s,
      "checks" => checks,
      "non_goals" => [
        "No grammar acceptance.",
        "No parser implementation.",
        "No profile source syntax authorization.",
        "No spec edit.",
        "No profile syntax golden fixture.",
        "No .igapp/.ilk or runtime authority change."
      ]
    }

    write_json(BOUNDARY_PACKET_PATH, boundary_packet)
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def run_review
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, REVIEW_RUNNER.to_s, chdir: ROOT.to_s)
    {
      "command" => "ruby #{REVIEW_RUNNER.relative_path_from(ROOT)}",
      "exit_status" => status.exitstatus,
      "stdout_first_line" => stdout.lines.first.to_s.strip,
      "stderr" => stderr.strip
    }
  end

  def build_boundary_packet(review_packet)
    {
      "kind" => "profile_source_syntax_grammar_boundary_packet",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => "compiler_grammar_boundary_ready",
      "role_boundary" => {
        "prepared_by" => "[Igniter-Lang Research Agent]",
        "decision_owner" => "[Igniter-Lang Compiler/Grammar Expert]",
        "architect_authorization_required_before_parser_work" => true,
        "research_agent_may_accept_syntax" => false,
        "syntax_accepted_by_this_packet" => false
      },
      "baseline_refs" => {
        "review_packet" => REVIEW_PACKET.relative_path_from(ROOT).to_s,
        "review_status" => review_packet.fetch("status"),
        "recommended_track" => review_packet.dig("handoff_recommendation", "recommended_track")
      },
      "fixed_research_constraints" => {
        "descriptor_first_now" => true,
        "human_syntax_pressure_only" => true,
        "lowering_target" => review_packet.dig("baseline_invariants", "lowering_target"),
        "surface_slot_order_authoritative" => review_packet.dig(
          "baseline_invariants", "surface_slot_order_authoritative"
        ),
        "canonical_slot_order_source" => review_packet.dig("baseline_invariants", "canonical_slot_order_source"),
        "parser_implementation_authorized" => false,
        "profile_source_syntax_authorized" => false,
        "runtime_authority_claims_allowed" => false,
        "inline_pack_bodies_allowed" => false,
        "implicit_capability_ownership_allowed" => false
      },
      "compiler_grammar_verdict_options" => {
        "accept_baseline_only" => {
          "meaning" => "Accept descriptor-first research baseline and keep human syntax pressure-only.",
          "unblocks" => ["descriptor-based profile validation planning"],
          "does_not_unblock" => ["parser implementation", "profile syntax goldens"]
        },
        "narrow_block_syntax_pressure" => {
          "meaning" => "Keep human syntax alive but narrow allowed grammar shape before a proposal.",
          "must_decide" => %w[
            profile_header_grammar
            slot_declaration_grammar
            implementation_id_lexical_shape
            registry_entry_separator_policy
            pre_lowering_diagnostic_codes
          ]
        },
        "reject_human_syntax_for_now" => {
          "meaning" => "Use descriptor data only and close human syntax pressure until a later stage.",
          "still_preserves" => ["compiler_profile_descriptor", "CompilerProfileSpec.slot_order"]
        },
        "defer_for_architect_digest_policy" => {
          "meaning" => "Defer syntax decision until source digest authority is decided.",
          "blocked_on" => ["source_text_vs_lowered_ast_digest_policy"]
        }
      },
      "minimum_acceptance_conditions_for_future_syntax" => [
        "Must lower into compiler_profile_descriptor.",
        "Must preserve CompilerProfileSpec.slot_order as canonical descriptor/future dispatch order.",
        "Must reject runtime authority claims.",
        "Must reject inline pack implementation bodies.",
        "Must require explicit capability ownership.",
        "Must reuse descriptor diagnostic taxonomy after lowering.",
        "Must have pre-lowering syntax diagnostic machine codes.",
        "Must have explicit source digest policy before golden fixtures."
      ],
      "grammar_questions_to_answer" => review_packet.fetch("compiler_grammar_questions"),
      "recommended_research_verdict" => {
        "verdict" => "accept_baseline_only",
        "reason" => "Descriptor-first path is already proofable; human syntax lacks grammar and digest decisions.",
        "next_compiler_grammar_artifact" => "profile-source-syntax-grammar-boundary-review-v0"
      },
      "non_authorizations" => review_packet.fetch("non_authorizations") + [
        "No grammar acceptance by Research Agent.",
        "No profile syntax proposal is created by this packet.",
        "No parser implementation card is opened by this packet."
      ]
    }
  end

  def build_checks(boundary_packet, review_run, review_summary)
    {
      "input.compiler_review_passed" => review_run.fetch("exit_status").zero? && review_summary.fetch("status") == "PASS",
      "role.decision_owner_is_compiler_grammar" => boundary_packet.dig(
        "role_boundary", "decision_owner"
      ) == "[Igniter-Lang Compiler/Grammar Expert]",
      "role.research_does_not_accept_syntax" => boundary_packet.dig(
        "role_boundary", "research_agent_may_accept_syntax"
      ) == false && boundary_packet.dig("role_boundary", "syntax_accepted_by_this_packet") == false,
      "authority.parser_work_still_requires_architect" => boundary_packet.dig(
        "role_boundary", "architect_authorization_required_before_parser_work"
      ) == true,
      "constraints.lowering_target_descriptor" => boundary_packet.dig(
        "fixed_research_constraints", "lowering_target"
      ) == "compiler_profile_descriptor",
      "constraints.surface_order_not_authoritative" => boundary_packet.dig(
        "fixed_research_constraints", "surface_slot_order_authoritative"
      ) == false && boundary_packet.dig(
        "fixed_research_constraints", "canonical_slot_order_source"
      ) == "CompilerProfileSpec.slot_order",
      "constraints.no_runtime_or_inline_pack_bodies" => boundary_packet.dig(
        "fixed_research_constraints", "runtime_authority_claims_allowed"
      ) == false && boundary_packet.dig("fixed_research_constraints", "inline_pack_bodies_allowed") == false,
      "verdict_options.include_accept_narrow_reject_defer" => %w[
        accept_baseline_only
        narrow_block_syntax_pressure
        reject_human_syntax_for_now
        defer_for_architect_digest_policy
      ].all? { |key| boundary_packet.fetch("compiler_grammar_verdict_options").key?(key) },
      "future_conditions.include_digest_and_diagnostics" => boundary_packet.fetch(
        "minimum_acceptance_conditions_for_future_syntax"
      ).include?("Must have explicit source digest policy before golden fixtures.") &&
        boundary_packet.fetch("minimum_acceptance_conditions_for_future_syntax").include?(
          "Must have pre-lowering syntax diagnostic machine codes."
        ),
      "recommendation.accept_baseline_only" => boundary_packet.dig(
        "recommended_research_verdict", "verdict"
      ) == "accept_baseline_only",
      "scope.no_parser_card_opened" => boundary_packet.fetch("non_authorizations").include?(
        "No parser implementation card is opened by this packet."
      )
    }
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} profile_source_syntax_grammar_boundary"
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "boundary_packet: #{summary.fetch("boundary_packet_path")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = ProfileSourceSyntaxGrammarBoundary.run
exit(success ? 0 : 1)
