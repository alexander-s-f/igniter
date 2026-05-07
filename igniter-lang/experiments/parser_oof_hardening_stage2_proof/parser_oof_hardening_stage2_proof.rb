#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "pathname"

require_relative "../parser/igniter_lang_parser"

module ParserOOFHardeningStage2Proof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  FIXTURE_DIR = LANG_ROOT / "experiments/parser_oof_hardening_stage2_proof"
  SYNTAX_FIXTURE_DIR = FIXTURE_DIR / "fixtures"
  SUMMARY_PATH = FIXTURE_DIR / "parser_oof_hardening_stage2_proof.json"
  SOURCE_DIR = LANG_ROOT / "source"
  SOURCE_TO_SEMANTICIR_DIR = LANG_ROOT / "experiments/source_to_semanticir_fixture"
  SEMANTIC_GOLDEN_DIR = SOURCE_TO_SEMANTICIR_DIR / "golden"

  SYNTAX_OOF_CASES = [
    ["oof_p2_pipeline_inside_contract", "OOF-P2"],
    ["oof_dm3_decimal_without_scale", "OOF-DM3"],
    ["oof_pg1_empty_pipeline", "OOF-PG1"],
    ["oof_pg2_step_without_contract_ref", "OOF-PG2"],
    ["oof_pg3_scoped_by_on_compute", "OOF-PG3"],
    ["oof_pg5_tenant_free_on_compute", "OOF-PG5"]
  ].freeze

  SEMANTIC_OOF_CASES = [
    ["negative_unresolved_symbol", "OOF-P1"],
    ["negative_evidence_less_alert", "OOF-OS2"],
    ["negative_confidence_bool", "OOF-CE4"]
  ].freeze

  module_function

  def run
    syntax_rows = SYNTAX_OOF_CASES.map { |case_id, rule| syntax_row(case_id, rule) }
    semantic_rows = SEMANTIC_OOF_CASES.map { |case_id, rule| semantic_row(case_id, rule) }
    existing_rows = existing_parser_fixture_rows
    checks = fixture_checks(syntax_rows, semantic_rows, existing_rows)
    summary = {
      "kind" => "parser_oof_hardening_stage2_proof",
      "format_version" => "0.1.0",
      "track" => "parser-oof-hardening-stage2-proof-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "checks" => checks,
      "syntax_oof" => syntax_rows,
      "semantic_oof" => semantic_rows,
      "existing_parser_fixtures" => existing_rows,
      "ownership" => {
        "parser_owned" => SYNTAX_OOF_CASES.map(&:last).uniq,
        "later_pass_owned" => SEMANTIC_OOF_CASES.map(&:last).uniq
      }
    }
    File.write(SUMMARY_PATH, "#{JSON.pretty_generate(summary)}\n")
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def syntax_row(case_id, expected_rule)
    parsed = parse_file(SYNTAX_FIXTURE_DIR / "#{case_id}.ig")
    rules = parsed.fetch("parse_errors").map { |error| error.fetch("rule", nil) }.compact
    {
      "case_id" => case_id,
      "source_path" => relative_path(SYNTAX_FIXTURE_DIR / "#{case_id}.ig"),
      "expected_rule" => expected_rule,
      "parser_behavior" => parsed.fetch("parse_errors").empty? ? "accepts" : "rejects",
      "parse_errors" => parsed.fetch("parse_errors"),
      "matched" => rules.include?(expected_rule)
    }
  end

  def semantic_row(case_id, expected_rule)
    source_path = SOURCE_TO_SEMANTICIR_DIR / "#{case_id}.ig"
    parsed = parse_file(source_path)
    report = read_json(SEMANTIC_GOLDEN_DIR / "#{case_id}.compilation_report.json")
    diagnostic_rules = report.fetch("diagnostics").map { |diagnostic| diagnostic.fetch("rule") }
    {
      "case_id" => case_id,
      "source_path" => relative_path(source_path),
      "expected_rule" => expected_rule,
      "parser_behavior" => parsed.fetch("parse_errors").empty? ? "accepts" : "rejects",
      "parse_errors" => parsed.fetch("parse_errors"),
      "later_pass_behavior" => {
        "pass_result" => report.fetch("pass_result"),
        "semantic_ir_ref" => report.fetch("semantic_ir_ref"),
        "diagnostic_rules" => diagnostic_rules
      },
      "matched" => parsed.fetch("parse_errors").empty? &&
        report.fetch("pass_result") == "oof" &&
        report.fetch("semantic_ir_ref").nil? &&
        diagnostic_rules.include?(expected_rule)
    }
  end

  def existing_parser_fixture_rows
    SOURCE_DIR.glob("*.ig").sort.map do |path|
      parsed = parse_file(path)
      {
        "source_path" => relative_path(path),
        "parser_behavior" => parsed.fetch("parse_errors").empty? ? "accepts" : "rejects",
        "parse_errors" => parsed.fetch("parse_errors")
      }
    end
  end

  def fixture_checks(syntax_rows, semantic_rows, existing_rows)
    {
      "existing_parser_fixtures_green" => existing_rows.all? { |row| row.fetch("parser_behavior") == "accepts" },
      "syntax_oof_rejected_at_parser" => syntax_rows.all? { |row| row.fetch("parser_behavior") == "rejects" },
      "syntax_oof_rules_match" => syntax_rows.all? { |row| row.fetch("matched") == true },
      "semantic_oof_accepted_by_parser" => semantic_rows.all? { |row| row.fetch("parser_behavior") == "accepts" },
      "semantic_oof_blocked_later" => semantic_rows.all? { |row| row.fetch("matched") == true }
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
          "severity" => "error",
          "message" => "#{e.class}: #{e.message}",
          "line" => e.respond_to?(:line) ? e.line : nil,
          "col" => e.respond_to?(:col) ? e.col : nil
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
    puts "#{summary.fetch("status")} parser_oof_hardening_stage2_proof"
    summary.fetch("checks").each do |name, ok|
      puts "#{name}: #{ok ? "ok" : "FAIL"}"
    end
    summary.fetch("syntax_oof").each do |row|
      puts "#{row.fetch("case_id")}: parser=#{row.fetch("parser_behavior")} rule=#{row.fetch("expected_rule")}"
    end
    summary.fetch("semantic_oof").each do |row|
      puts "#{row.fetch("case_id")}: parser=#{row.fetch("parser_behavior")} later=#{row.dig("later_pass_behavior", "pass_result")}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = ParserOOFHardeningStage2Proof.run
exit(success ? 0 : 1)
