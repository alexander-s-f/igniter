#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "pathname"
require "rbconfig"

module ProfileSourceSyntaxPressure
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = LANG_ROOT / "experiments/profile_source_syntax_pressure/out"
  MODEL_PATH = OUT_DIR / "profile_source_syntax_pressure_model.json"
  SUMMARY_PATH = OUT_DIR / "profile_source_syntax_pressure_summary.json"

  LOWERING_RUNNER = LANG_ROOT / "experiments/profile_source_lowering_target/profile_source_lowering_target.rb"
  LOWERING_SUMMARY = LANG_ROOT / "experiments/profile_source_lowering_target/out/profile_source_lowering_target_summary.json"
  LOWERING_MODEL = LANG_ROOT / "experiments/profile_source_lowering_target/out/profile_source_lowering_model.json"

  FORMAT_VERSION = "0.1.0"
  TRACK = "profile-source-syntax-pressure-v0"

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    lowering_run = run_lowering
    lowering_summary = read_json(LOWERING_SUMMARY)
    lowering_model = read_json(LOWERING_MODEL)
    model = build_model(lowering_model)
    checks = build_checks(model, lowering_run, lowering_summary)
    summary = {
      "kind" => "profile_source_syntax_pressure_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "model_path" => MODEL_PATH.relative_path_from(ROOT).to_s,
      "recommendation" => model.fetch("recommendation"),
      "checks" => checks,
      "non_goals" => [
        "No parser implementation.",
        "No profile syntax authorization.",
        "No grammar/spec edits.",
        "No production lowering code.",
        "No CompilerKernel dispatch changes."
      ]
    }

    write_json(MODEL_PATH, model)
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def run_lowering
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, LOWERING_RUNNER.to_s, chdir: ROOT.to_s)
    {
      "command" => "ruby #{LOWERING_RUNNER.relative_path_from(ROOT)}",
      "exit_status" => status.exitstatus,
      "stdout_first_line" => stdout.lines.first.to_s.strip,
      "stderr" => stderr.strip
    }
  end

  def build_model(lowering_model)
    {
      "kind" => "profile_source_syntax_pressure_model",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "lowering_target_ref" => LOWERING_MODEL.relative_path_from(ROOT).to_s,
      "syntax_authority" => {
        "parser_implementation_authorized" => false,
        "profile_source_syntax_authorized" => false,
        "compiler_grammar_review_required" => true
      },
      "lowering_contract" => lowering_model.fetch("lowering_rules"),
      "slot_order_invariant" => {
        "surface_slot_order_is_authoritative" => false,
        "canonical_source" => "CompilerProfileSpec.slot_order",
        "descriptor_slot_order" => "must_equal CompilerProfileSpec.slot_order",
        "future_dispatch_order" => "must_equal descriptor_slot_order",
        "invariant" => "surface slot order = parsed sugar only; descriptor slot order = canonical dispatch order"
      },
      "candidate_forms" => candidate_forms,
      "ambiguity_pressure" => ambiguity_pressure,
      "forbidden_constructs" => lowering_model.fetch("forbidden_constructs").merge(
        "pack_body" => "syntax.pack_body_out_of_scope",
        "implicit_capability_ownership" => "syntax.implicit_capability_ownership_rejected",
        "runtime_approval" => "syntax.runtime_approval_rejected"
      ),
      "decision_matrix" => decision_matrix,
      "recommendation" => {
        "primary_path" => "descriptor_first_json_or_data_surface",
        "human_syntax_status" => "pressure_only_compiler_grammar_review_required",
        "reason" => "Descriptor-first avoids parser churn while preserving future lowering target."
      }
    }
  end

  def candidate_forms
    {
      "block_style" => {
        "status" => "pressure_only",
        "sample" => [
          "profile IgniterLang.Stage3SelfAssemblyProfile uses IgniterLangSelfAssemblyProfileSpec {",
          "  slot core: CoreLanguagePack implementation core_language.self_assembly.v0",
          "    owns core_language",
          "    registry parser_rules: core.contract, core.input, core.output, core.compute",
          "",
          "  slot temporal: TemporalPack implementation temporal.metadata_only.self_assembly.v0",
          "    owns temporal",
          "    requires core, fragment_registry, escape_boundary",
          "    registry semanticir_handlers: temporal.temporal_access_node",
          "}"
        ],
        "strengths" => [
          "Readable for humans.",
          "Maps directly to slot declarations and registry blocks.",
          "Keeps implementation selection separate from implementation body."
        ],
        "risks" => [
          "New grammar surface.",
          "Indent/block ambiguity must be decided.",
          "Commas/newlines and registry entry parsing need formal rules."
        ]
      },
      "descriptor_data_style" => {
        "status" => "preferred_before_parser_work",
        "sample_kind" => "compiler_profile_descriptor",
        "strengths" => [
          "Already matches descriptor schema.",
          "Avoids source parser churn.",
          "Canonicalization and digest rules are already modeled."
        ],
        "risks" => [
          "Less ergonomic for humans.",
          "May need editor/tooling support.",
          "Could drift from eventual human syntax if not kept as lowering target."
        ]
      },
      "inline_pack_body_style" => {
        "status" => "rejected",
        "reason" => "Profile source may select implementation ids, not define pack implementations inline."
      }
    }
  end

  def ambiguity_pressure
    [
      {
        "id" => "slot_header_vs_contract_header",
        "risk" => "profile slot declarations must not parse like contract declarations",
        "route" => "Compiler/Grammar"
      },
      {
        "id" => "implementation_id_token_shape",
        "risk" => "implementation ids contain dots and versions; lexer/token policy must be explicit",
        "route" => "Compiler/Grammar"
      },
      {
        "id" => "registry_entry_list_boundaries",
        "risk" => "comma/newline/block termination must be deterministic",
        "route" => "Compiler/Grammar"
      },
      {
        "id" => "profile_source_digest",
        "risk" => "digest policy must decide source text vs lowered AST",
        "route" => "Architect + Compiler/Grammar"
      }
    ]
  end

  def decision_matrix
    {
      "allow_now" => [
        "descriptor_data_style as proof-local input",
        "block_style as pressure specimen only"
      ],
      "reject_now" => [
        "inline pack implementation bodies",
        "runtime authority or approval clauses",
        "implicit capability ownership",
        "parser implementation work"
      ],
      "requires_future_authorization" => [
        "profile source grammar",
        "profile source diagnostics",
        "profile source digest policy",
        "profile syntax golden fixtures"
      ]
    }
  end

  def build_checks(model, lowering_run, lowering_summary)
    candidates = model.fetch("candidate_forms")
    forbidden = model.fetch("forbidden_constructs")
    {
      "input.lowering_target_passed" => lowering_run.fetch("exit_status").zero? && lowering_summary.fetch("status") == "PASS",
      "authority.syntax_not_authorized" => model.dig("syntax_authority", "parser_implementation_authorized") == false &&
        model.dig("syntax_authority", "profile_source_syntax_authorized") == false,
      "candidate.block_style_pressure_only" => candidates.dig("block_style", "status") == "pressure_only",
      "candidate.descriptor_data_preferred" => candidates.dig("descriptor_data_style", "status") == "preferred_before_parser_work",
      "candidate.inline_pack_body_rejected" => candidates.dig("inline_pack_body_style", "status") == "rejected",
      "slot_order.surface_order_not_authoritative" => model.dig("slot_order_invariant", "surface_slot_order_is_authoritative") == false &&
        model.dig("slot_order_invariant", "canonical_source") == "CompilerProfileSpec.slot_order" &&
        model.dig("slot_order_invariant", "future_dispatch_order") == "must_equal descriptor_slot_order",
      "forbidden.runtime_and_pack_body_rejected" => forbidden.fetch("runtime_approval") == "syntax.runtime_approval_rejected" &&
        forbidden.fetch("pack_body") == "syntax.pack_body_out_of_scope",
      "matrix.rejects_parser_implementation" => model.dig("decision_matrix", "reject_now").include?("parser implementation work"),
      "matrix.requires_future_grammar_authorization" => model.dig("decision_matrix", "requires_future_authorization").include?("profile source grammar"),
      "ambiguity.pressure_has_compiler_grammar_routes" => model.fetch("ambiguity_pressure").all? do |entry|
        entry.fetch("route").include?("Compiler/Grammar")
      end,
      "recommendation.descriptor_first" => model.dig("recommendation", "primary_path") == "descriptor_first_json_or_data_surface"
    }
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} profile_source_syntax_pressure"
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "model: #{summary.fetch("model_path")}"
    puts "recommendation: #{summary.dig("recommendation", "primary_path")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = ProfileSourceSyntaxPressure.run
exit(success ? 0 : 1)
