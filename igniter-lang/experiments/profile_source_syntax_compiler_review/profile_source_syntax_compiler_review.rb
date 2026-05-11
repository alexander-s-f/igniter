#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "pathname"
require "rbconfig"

module ProfileSourceSyntaxCompilerReview
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = LANG_ROOT / "experiments/profile_source_syntax_compiler_review/out"
  REVIEW_PACKET_PATH = OUT_DIR / "profile_source_syntax_compiler_review_packet.json"
  SUMMARY_PATH = OUT_DIR / "profile_source_syntax_compiler_review_summary.json"

  PRESSURE_RUNNER = LANG_ROOT / "experiments/profile_source_syntax_pressure/profile_source_syntax_pressure.rb"
  TAXONOMY_RUNNER = LANG_ROOT / "experiments/compiler_profile_descriptor_error_taxonomy_sharpening/compiler_profile_descriptor_error_taxonomy_sharpening.rb"

  PRESSURE_MODEL = LANG_ROOT / "experiments/profile_source_syntax_pressure/out/profile_source_syntax_pressure_model.json"
  PRESSURE_SUMMARY = LANG_ROOT / "experiments/profile_source_syntax_pressure/out/profile_source_syntax_pressure_summary.json"
  LOWERING_MODEL = LANG_ROOT / "experiments/profile_source_lowering_target/out/profile_source_lowering_model.json"
  TAXONOMY_PATH = LANG_ROOT / "experiments/compiler_profile_descriptor_error_taxonomy_sharpening/out/compiler_profile_descriptor_error_taxonomy.json"
  TAXONOMY_SUMMARY = LANG_ROOT / "experiments/compiler_profile_descriptor_error_taxonomy_sharpening/out/compiler_profile_descriptor_error_taxonomy_sharpening_summary.json"

  FORMAT_VERSION = "0.1.0"
  TRACK = "profile-source-syntax-compiler-review-v0"

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    pressure_run = run_child(PRESSURE_RUNNER)
    taxonomy_run = run_child(TAXONOMY_RUNNER)
    pressure_model = read_json(PRESSURE_MODEL)
    pressure_summary = read_json(PRESSURE_SUMMARY)
    lowering_model = read_json(LOWERING_MODEL)
    taxonomy = read_json(TAXONOMY_PATH)
    taxonomy_summary = read_json(TAXONOMY_SUMMARY)
    review_packet = build_review_packet(pressure_model, lowering_model, taxonomy)
    checks = build_checks(review_packet, pressure_run, taxonomy_run, pressure_summary, taxonomy_summary)
    summary = {
      "kind" => "profile_source_syntax_compiler_review_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "review_packet_path" => REVIEW_PACKET_PATH.relative_path_from(ROOT).to_s,
      "checks" => checks,
      "non_goals" => [
        "No parser implementation.",
        "No profile source syntax authorization.",
        "No grammar/spec edits.",
        "No production lowering code.",
        "No CompilerKernel dispatch changes.",
        "No .igapp/.ilk change."
      ]
    }

    write_json(REVIEW_PACKET_PATH, review_packet)
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def run_child(runner)
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, runner.to_s, chdir: ROOT.to_s)
    {
      "command" => "ruby #{runner.relative_path_from(ROOT)}",
      "exit_status" => status.exitstatus,
      "stdout_first_line" => stdout.lines.first.to_s.strip,
      "stderr" => stderr.strip
    }
  end

  def build_review_packet(pressure_model, lowering_model, taxonomy)
    {
      "kind" => "profile_source_syntax_compiler_review_packet",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => "research_baseline_for_compiler_grammar_review",
      "review_scope" => {
        "question" => "Should Igniter-Lang ever gain human profile source syntax, and if so what must it lower into?",
        "current_recommendation" => "descriptor_first_now; human syntax remains pressure_only",
        "parser_implementation_authorized" => false,
        "profile_source_syntax_authorized" => false,
        "compiler_grammar_review_required" => true
      },
      "baseline_invariants" => {
        "lowering_target" => "compiler_profile_descriptor",
        "descriptor_first" => lowering_model.dig("source_status", "descriptor_first"),
        "surface_slot_order_authoritative" => pressure_model.dig(
          "slot_order_invariant", "surface_slot_order_is_authoritative"
        ),
        "canonical_slot_order_source" => pressure_model.dig("slot_order_invariant", "canonical_source"),
        "future_dispatch_order" => pressure_model.dig("slot_order_invariant", "future_dispatch_order"),
        "runtime_authority_claims_allowed" => false,
        "inline_pack_bodies_allowed" => false,
        "implicit_capability_ownership_allowed" => false
      },
      "candidate_review" => {
        "descriptor_data_style" => {
          "recommendation" => "accept_as_research_baseline",
          "status" => pressure_model.dig("candidate_forms", "descriptor_data_style", "status"),
          "reason" => "Matches descriptor schema and avoids parser churn."
        },
        "block_style" => {
          "recommendation" => "keep_as_pressure_specimen",
          "status" => pressure_model.dig("candidate_forms", "block_style", "status"),
          "review_required_for" => %w[
            header_grammar
            implementation_id_token_shape
            registry_list_boundaries
            source_digest_policy
            diagnostics_mapping
          ]
        },
        "inline_pack_body_style" => {
          "recommendation" => "reject",
          "status" => pressure_model.dig("candidate_forms", "inline_pack_body_style", "status"),
          "reason" => pressure_model.dig("candidate_forms", "inline_pack_body_style", "reason")
        }
      },
      "compiler_grammar_questions" => compiler_grammar_questions(pressure_model),
      "diagnostic_baseline" => {
        "source" => TAXONOMY_PATH.relative_path_from(ROOT).to_s,
        "first_failure_order" => taxonomy.fetch("diagnostic_precedence").map { |entry| entry.fetch("phase") },
        "profile_syntax_diagnostics_should_reuse_descriptor_codes" => true,
        "syntax_specific_codes_allowed_only_before_lowering" => true,
        "human_text_may_vary_machine_codes_must_not" => true
      },
      "accept_reject_narrowing_matrix" => {
        "accept_now" => [
          "descriptor data/profile descriptor as the research baseline",
          "lowering target = compiler_profile_descriptor",
          "surface slot order is non-authoritative"
        ],
        "keep_pressure_only" => [
          "human block-style profile syntax",
          "source text digest policy",
          "profile syntax golden fixtures"
        ],
        "reject_now" => [
          "inline pack implementation bodies",
          "runtime authority clauses",
          "implicit capability ownership",
          "parser implementation work"
        ],
        "requires_compiler_grammar_decision" => [
          "profile header grammar",
          "slot declaration grammar",
          "implementation id lexical grammar",
          "registry entry separators and block termination",
          "source diagnostic shape before descriptor lowering"
        ]
      },
      "handoff_recommendation" => {
        "to" => "[Igniter-Lang Compiler/Grammar Expert]",
        "recommended_track" => "profile-source-syntax-grammar-boundary-v0",
        "recommended_verdict" => "accept_descriptor_first_and_keep_block_syntax_pressure_only",
        "do_not_start_parser_until" => [
          "Architect authorizes syntax work.",
          "Compiler/Grammar accepts a grammar boundary.",
          "Digest policy is decided.",
          "Descriptor diagnostics mapping is accepted."
        ]
      },
      "non_authorizations" => [
        "No parser implementation.",
        "No profile source syntax authorization.",
        "No production lowering implementation.",
        "No CompilerKernel dispatch change.",
        "No runtime execution authority.",
        "No .igapp/.ilk format mutation."
      ]
    }
  end

  def compiler_grammar_questions(pressure_model)
    pressure_model.fetch("ambiguity_pressure").map do |entry|
      {
        "id" => entry.fetch("id"),
        "question" => entry.fetch("risk"),
        "route" => entry.fetch("route"),
        "research_baseline" => "must preserve descriptor-first lowering"
      }
    end + [
      {
        "id" => "syntax_diagnostics_pre_lowering",
        "question" => "Which syntax errors should exist before descriptor validation runs?",
        "route" => "Compiler/Grammar",
        "research_baseline" => "descriptor taxonomy remains first-failure model after lowering"
      },
      {
        "id" => "surface_order_vs_profile_spec_order",
        "question" => "Should source order be accepted when it differs from CompilerProfileSpec.slot_order?",
        "route" => "Compiler/Grammar",
        "research_baseline" => "source order may vary, but lowered descriptor order must follow CompilerProfileSpec.slot_order"
      }
    ]
  end

  def build_checks(review_packet, pressure_run, taxonomy_run, pressure_summary, taxonomy_summary)
    {
      "input.syntax_pressure_passed" => pressure_run.fetch("exit_status").zero? && pressure_summary.fetch("status") == "PASS",
      "input.taxonomy_passed" => taxonomy_run.fetch("exit_status").zero? && taxonomy_summary.fetch("status") == "PASS",
      "scope.research_baseline_status" => review_packet.fetch("status") == "research_baseline_for_compiler_grammar_review",
      "authority.syntax_not_authorized" => review_packet.dig("review_scope", "parser_implementation_authorized") == false &&
        review_packet.dig("review_scope", "profile_source_syntax_authorized") == false,
      "baseline.lowering_target_descriptor" => review_packet.dig("baseline_invariants", "lowering_target") == "compiler_profile_descriptor",
      "baseline.surface_order_not_authoritative" => review_packet.dig(
        "baseline_invariants", "surface_slot_order_authoritative"
      ) == false && review_packet.dig("baseline_invariants", "canonical_slot_order_source") == "CompilerProfileSpec.slot_order",
      "candidate.descriptor_data_accepted_as_baseline" => review_packet.dig(
        "candidate_review", "descriptor_data_style", "recommendation"
      ) == "accept_as_research_baseline",
      "candidate.block_style_pressure_only" => review_packet.dig(
        "candidate_review", "block_style", "recommendation"
      ) == "keep_as_pressure_specimen",
      "candidate.inline_pack_body_rejected" => review_packet.dig(
        "candidate_review", "inline_pack_body_style", "recommendation"
      ) == "reject",
      "diagnostics.reuses_descriptor_taxonomy" => review_packet.dig(
        "diagnostic_baseline", "profile_syntax_diagnostics_should_reuse_descriptor_codes"
      ) == true,
      "matrix.rejects_parser_work_now" => review_packet.dig(
        "accept_reject_narrowing_matrix", "reject_now"
      ).include?("parser implementation work"),
      "handoff.names_compiler_grammar_target" => review_packet.dig(
        "handoff_recommendation", "to"
      ) == "[Igniter-Lang Compiler/Grammar Expert]",
      "scope.no_runtime_or_format_authority" => review_packet.fetch("non_authorizations").include?("No runtime execution authority.") &&
        review_packet.fetch("non_authorizations").include?("No .igapp/.ilk format mutation.")
    }
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} profile_source_syntax_compiler_review"
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "review_packet: #{summary.fetch("review_packet_path")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = ProfileSourceSyntaxCompilerReview.run
exit(success ? 0 : 1)
