#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "pathname"

require_relative "../parser/igniter_lang_parser"

module ParserOOFHardeningDecision
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  FIXTURE_DIR = LANG_ROOT / "experiments/parser_oof_hardening_decision"
  SOURCE_FIXTURE_DIR = LANG_ROOT / "experiments/source_to_semanticir_fixture"
  SEMANTIC_GOLDEN_DIR = SOURCE_FIXTURE_DIR / "golden"
  TYPECHECKER_GOLDEN_DIR = LANG_ROOT / "experiments/typechecker_proof/golden"
  SUMMARY_PATH = FIXTURE_DIR / "parser_oof_hardening_decision.json"

  SEMANTIC_OOF_CASES = [
    {
      "case_id" => "negative_unresolved_symbol",
      "construct" => "compute references missing symbol `missing_b`",
      "rule" => "OOF-P1",
      "source" => SOURCE_FIXTURE_DIR / "negative_unresolved_symbol.ig",
      "stage1_risk" => "low: unresolved symbol is semantic; classifier/typechecker block before SemanticIR"
    },
    {
      "case_id" => "negative_evidence_less_alert",
      "construct" => "EvidenceLinkedAlert gate has no admitted evidence signal/claim refs",
      "rule" => "OOF-OS2",
      "source" => SOURCE_FIXTURE_DIR / "negative_evidence_less_alert.ig",
      "stage1_risk" => "low: observation/evidence sufficiency is semantic; classifier blocks before SemanticIR"
    },
    {
      "case_id" => "negative_confidence_bool",
      "construct" => "ConfidenceLabel field is used as Bool output",
      "rule" => "OOF-CE4",
      "source" => SOURCE_FIXTURE_DIR / "negative_confidence_bool.ig",
      "stage1_risk" => "low: type/trust boundary violation is blocked before SemanticIR"
    }
  ].freeze

  module_function

  def run
    semantic_rows = SEMANTIC_OOF_CASES.map { |config| semantic_row(config) }
    syntax_row = syntax_invalid_row
    summary = {
      "kind" => "parser_oof_hardening_decision",
      "format_version" => "0.1.0",
      "track" => "parser-oof-hardening-decision-fixture-v0",
      "status" => status_for(semantic_rows, syntax_row),
      "matrix" => semantic_rows + [syntax_row],
      "fixture_checks" => fixture_checks(semantic_rows, syntax_row),
      "recommendation" => recommendation
    }
    File.write(SUMMARY_PATH, "#{JSON.pretty_generate(summary)}\n")
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def semantic_row(config)
    parsed = parse_file(config.fetch("source"))
    report = read_json(SEMANTIC_GOLDEN_DIR / "#{config.fetch("case_id")}.compilation_report.json")
    typed = read_json(TYPECHECKER_GOLDEN_DIR / "#{config.fetch("case_id")}.typed.json")
    typed_contract = typed.fetch("contracts").fetch(0)
    typed_rules = typed.fetch("type_errors").map { |entry| entry.fetch("rule") }.uniq

    {
      "case_id" => config.fetch("case_id"),
      "construct" => config.fetch("construct"),
      "expected_rule" => config.fetch("rule"),
      "parser_behavior" => parsed.fetch("parse_errors").empty? ? "accepts" : "rejects",
      "parser_errors" => parsed.fetch("parse_errors"),
      "later_pass_behavior" => {
        "compilation_report_pass_result" => report.fetch("pass_result"),
        "stages" => report.fetch("stages"),
        "diagnostic_rules" => report.fetch("diagnostics").map { |entry| entry.fetch("rule") },
        "typed_contract_status" => typed_contract.fetch("status"),
        "typed_rules" => typed_rules,
        "semantic_ir_ref" => report.fetch("semantic_ir_ref")
      },
      "stage1_risk" => config.fetch("stage1_risk"),
      "recommendation" => "safe_to_defer_to_grammar_hardening"
    }
  end

  def syntax_invalid_row
    parsed = parse_file(FIXTURE_DIR / "invalid_syntax.ig")
    {
      "case_id" => "invalid_syntax_missing_colon",
      "construct" => "input declaration missing ':' between name and type",
      "expected_rule" => nil,
      "parser_behavior" => parsed.fetch("parse_errors").empty? ? "accepts" : "rejects",
      "parser_errors" => parsed.fetch("parse_errors"),
      "later_pass_behavior" => "not_run",
      "stage1_risk" => "none: syntax-invalid input is rejected by parser",
      "recommendation" => "already_rejected_by_parser"
    }
  end

  def fixture_checks(semantic_rows, syntax_row)
    {
      "parse_accepts_but_later_oof" => semantic_rows.all? do |row|
        row.fetch("parser_behavior") == "accepts" &&
          row.dig("later_pass_behavior", "compilation_report_pass_result") == "oof" &&
          row.dig("later_pass_behavior", "semantic_ir_ref").nil?
      end,
      "parse_rejects_syntax_invalid" => syntax_row.fetch("parser_behavior") == "rejects",
      "classify_or_typecheck_blocks_semantic_oof" => semantic_rows.all? do |row|
        later = row.fetch("later_pass_behavior")
        later.fetch("diagnostic_rules").include?(row.fetch("expected_rule")) &&
          later.fetch("typed_contract_status") == "blocked" &&
          later.fetch("typed_rules").include?(row.fetch("expected_rule"))
      end
    }
  end

  def status_for(semantic_rows, syntax_row)
    checks = fixture_checks(semantic_rows, syntax_row)
    checks.values.all? ? "PASS" : "FAIL"
  end

  def recommendation
    {
      "must_fix_before_stage1_close" => [],
      "safe_to_defer_to_grammar_hardening" => [
        "OOF-P1 unresolved symbol",
        "OOF-OS2 evidence-linked alert without admitted evidence",
        "OOF-CE4 ConfidenceLabel used as Bool"
      ],
      "stage2_grammar_governance_item" => [
        "Decide whether parser should remain syntax-only or reject selected semantic OOF earlier for developer UX."
      ],
      "meta_expert_recommendation" => "Do not block Stage 1 close on these semantic OOF cases; they are already blocked before SemanticIR/.igapp/RuntimeMachine trust. Track parser OOF hardening as grammar governance, not a close blocker."
    }
  end

  def parse_file(path)
    IgniterLang::ParsedProgram.parse(File.read(path), source_path: relative_path(path)).to_h
  rescue => e
    {
      "kind" => "parsed_program",
      "source_path" => relative_path(path),
      "parse_errors" => [
        {
          "message" => "#{e.class}: #{e.message}",
          "line" => nil
        }
      ]
    }
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def relative_path(path)
    Pathname.new(path).relative_path_from(ROOT).to_s
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} parser_oof_hardening_decision"
    summary.fetch("fixture_checks").each do |name, ok|
      puts "#{name}: #{ok ? "ok" : "FAIL"}"
    end
    summary.fetch("matrix").each do |row|
      later = row.fetch("later_pass_behavior")
      later_status = later.is_a?(Hash) ? later.fetch("compilation_report_pass_result") : later
      puts "#{row.fetch("case_id")}: parser=#{row.fetch("parser_behavior")} later=#{later_status}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = ParserOOFHardeningDecision.run
exit(success ? 0 : 1)
