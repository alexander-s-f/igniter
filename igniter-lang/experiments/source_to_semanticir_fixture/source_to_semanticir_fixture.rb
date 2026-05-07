#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "fileutils"
require "pathname"

require_relative "../parser/igniter_lang_parser"
require_relative "../../lib/igniter_lang/semanticir_emitter"

module SourceToSemanticIRFixture
  ROOT = File.expand_path("../../..", __dir__)
  LANG_ROOT = File.expand_path("../..", __dir__)
  FIXTURE_DIR = __dir__
  GOLDEN_DIR = File.join(FIXTURE_DIR, "golden")
  FORMAT_VERSION = IgniterLang::SemanticIREmitter::FORMAT_VERSION

  CASES = {
    "add" => {
      source: "add.ig",
      expected_contract: "Add",
      sample_input: { "a" => 2, "b" => 3 }
    },
    "claim_evidence" => {
      source: "claim_evidence.ig",
      expected_contract: "ClaimEvidenceBundle",
      sample_input: {
        "claim" => {
          "claim_id" => "claim/synthetic/vendor-status",
          "subject_ref" => "vendor/synthetic",
          "predicate" => "status",
          "object_value" => "degraded"
        },
        "evidence" => {
          "link_id" => "evidence-link/synthetic/direct-source",
          "source_ref" => "source-observation/synthetic/direct-online",
          "target_ref" => "claim/synthetic/vendor-status",
          "relation" => "supports",
          "strength" => "direct"
        }
      }
    },
    "evidence_linked_alert" => {
      source: "evidence_linked_alert.ig",
      expected_contract: "EvidenceLinkedAlertGate",
      sample_input: {
        "alert" => {
          "signal_count" => 1,
          "claim_count" => 1,
          "valid_until" => "2026-05-06T12:00:00Z",
          "confidence_label" => "medium"
        }
      }
    },
    "negative_unresolved_symbol" => {
      source: "negative_unresolved_symbol.ig",
      expected_rule: "OOF-P1",
      sample_input: { "a" => 1 }
    },
    "negative_evidence_less_alert" => {
      source: "negative_evidence_less_alert.ig",
      expected_rule: "OOF-OS2",
      sample_input: {
        "alert" => {
          "signal_count" => 0,
          "claim_count" => 1,
          "valid_until" => "2026-05-06T12:00:00Z",
          "confidence_label" => "medium"
        }
      }
    },
    "negative_confidence_bool" => {
      source: "negative_confidence_bool.ig",
      expected_rule: "OOF-CE4",
      sample_input: {
        "confidence" => {
          "assessment_id" => "confidence/synthetic/direct",
          "confidence_label" => "high"
        }
      }
    }
  }.freeze

  module_function

  def run(mode: :write)
    FileUtils.mkdir_p(GOLDEN_DIR)
    outputs = build_outputs
    summary = build_summary

    if mode == :write
      write_outputs(outputs, summary)
    end

    checks = build_checks(outputs)
    checks = checks.merge(build_golden_checks(outputs, summary)) if mode == :check_golden
    checks.each { |label, ok| puts "#{label}: #{ok ? "ok" : "FAIL"}" }
    puts "golden.dir: #{rel(GOLDEN_DIR)}"

    if checks.all? { |_label, ok| ok }
      puts mode == :check_golden ? "PASS source_to_semanticir_fixture_golden_check" : "PASS source_to_semanticir_fixture"
    else
      abort(mode == :check_golden ? "FAIL source_to_semanticir_fixture_golden_check" : "FAIL source_to_semanticir_fixture")
    end
  end

  def build_outputs
    emitter = IgniterLang::SemanticIREmitter.new
    CASES.each_with_object({}) do |(case_id, config), outputs|
      parsed = parse_case(config.fetch(:source))
      result = emitter.emit(parsed, sample_input: config.fetch(:sample_input))
      outputs[case_id] = {
        parsed: parsed,
        semantic_ir: result.fetch("semantic_ir"),
        compilation_report: result.fetch("compilation_report"),
        config: config
      }
    end
  end

  def write_outputs(outputs, summary)
    outputs.each do |case_id, result|
      write_json(File.join(GOLDEN_DIR, "#{case_id}.parsed_ast.json"), result.fetch(:parsed))
      semantic_ir_path = File.join(GOLDEN_DIR, "#{case_id}.semantic_ir.json")
      if result.fetch(:semantic_ir)
        write_json(semantic_ir_path, result.fetch(:semantic_ir))
      else
        FileUtils.rm_f(semantic_ir_path)
      end
      write_json(File.join(GOLDEN_DIR, "#{case_id}.compilation_report.json"), result.fetch(:compilation_report))
    end
    write_json(File.join(GOLDEN_DIR, "summary.json"), summary)
  end

  def build_summary
    {
      "kind" => "source_to_semanticir_fixture_summary",
      "prop0191_compliant" => true,
      "canonical_envelope" => {
        "kind" => "semantic_ir_program",
        "format_version" => FORMAT_VERSION,
        "contract_keys" => %w[
          kind contract_ref contract_name specialization_of type_args
          fragment_class inputs outputs nodes escape_boundaries
        ]
      },
      "compilation_report" => {
        "kind" => "compilation_report",
        "always_emitted" => true,
        "negative_semantic_ir_emitted" => false
      },
      "positive_contracts" => %w[Add ClaimEvidenceBundle EvidenceLinkedAlertGate],
      "negative_rules" => {
        "negative_unresolved_symbol" => "OOF-P1",
        "negative_evidence_less_alert" => "OOF-OS2",
        "negative_confidence_bool" => "OOF-CE4"
      },
      "checker_modes" => [
        "default writes regenerated golden output and runs semantic checks",
        "--check-golden verifies canonical shape and deterministic golden equality"
      ],
      "golden_dir" => rel(GOLDEN_DIR)
    }
  end

  def parse_case(source_file)
    path = File.join(FIXTURE_DIR, source_file)
    relative_path = rel(path)
    parsed = IgniterLang::ParsedProgram.parse(File.read(path), source_path: relative_path).to_h
    raise "Parse failed for #{source_file}: #{parsed.fetch("parse_errors").inspect}" unless parsed.fetch("parse_errors").empty?

    parsed
  end

  def build_checks(outputs)
    {
      "parse.add" => parsed_ok?(outputs, "add"),
      "semanticir.envelope.add" => canonical_program?(outputs.fetch("add").fetch(:semantic_ir)),
      "report.add" => compilation_report_ok?(outputs, "add", "ok"),
      "semanticir.add" => contract_ok?(outputs, "add", "Add", "stdlib.integer.add", "Integer"),
      "parse.claim_evidence" => parsed_ok?(outputs, "claim_evidence"),
      "semanticir.envelope.claim_evidence" => canonical_program?(outputs.fetch("claim_evidence").fetch(:semantic_ir)),
      "report.claim_evidence" => compilation_report_ok?(outputs, "claim_evidence", "ok"),
      "semanticir.claim_evidence" => contract_ok?(outputs, "claim_evidence", "ClaimEvidenceBundle", nil, "String"),
      "parse.evidence_linked_alert" => parsed_ok?(outputs, "evidence_linked_alert"),
      "semanticir.envelope.evidence_linked_alert" => canonical_program?(outputs.fetch("evidence_linked_alert").fetch(:semantic_ir)),
      "report.evidence_linked_alert" => compilation_report_ok?(outputs, "evidence_linked_alert", "ok"),
      "semanticir.evidence_linked_alert" => alert_gate_ok?(outputs),
      "negative.unresolved_symbol" => negative_report_only?(outputs, "negative_unresolved_symbol", "OOF-P1"),
      "negative.evidence_less_alert" => negative_report_only?(outputs, "negative_evidence_less_alert", "OOF-OS2"),
      "negative.confidence_bool" => negative_report_only?(outputs, "negative_confidence_bool", "OOF-CE4"),
      "stdlib.monomorphic_ops" => monomorphic_ops?(outputs),
      "golden.ast_outputs" => golden_count(".parsed_ast.json", 10),
      "golden.semanticir_outputs" => golden_count(".semantic_ir.json", 3),
      "golden.compilation_report_outputs" => golden_count(".compilation_report.json", 6)
    }
  end

  def parsed_ok?(outputs, case_id)
    outputs.fetch(case_id).fetch(:parsed).fetch("parse_errors").empty?
  end

  def contract_ok?(outputs, case_id, contract_name, required_operator, output_type)
    contract = only_contract(outputs, case_id)
    return false unless contract.fetch("contract_name") == contract_name
    return false unless contract.fetch("fragment_class") == "core"
    return false unless contract.fetch("outputs").any? { |out| out.fetch("type").fetch("name") == output_type }

    return true unless required_operator

    contract.fetch("nodes").any? { |node| node.fetch("expr").fetch("fn", nil) == required_operator }
  end

  def alert_gate_ok?(outputs)
    contract = only_contract(outputs, "evidence_linked_alert")
    operators = contract.fetch("nodes").map { |node| node.fetch("expr").fetch("fn", nil) }
    contract.fetch("fragment_class") == "core" &&
      operators.include?("stdlib.integer.gt") &&
      operators.include?("stdlib.bool.and")
  end

  def compilation_report_ok?(outputs, case_id, expected_result)
    report = outputs.fetch(case_id).fetch(:compilation_report)
    semantic_ir = outputs.fetch(case_id).fetch(:semantic_ir)
    report.fetch("kind") == "compilation_report" &&
      report.fetch("pass_result") == expected_result &&
      report.fetch("semantic_ir_ref") == semantic_ir&.fetch("program_id") &&
      report.fetch("stages").fetch("emit") == (expected_result == "ok" ? "ok" : "skipped")
  end

  def negative_report_only?(outputs, case_id, expected_rule)
    report = outputs.fetch(case_id).fetch(:compilation_report)
    outputs.fetch(case_id).fetch(:semantic_ir).nil? &&
      compilation_report_ok?(outputs, case_id, "oof") &&
      report.fetch("diagnostics").any? { |entry| entry.fetch("rule") == expected_rule }
  end

  def monomorphic_ops?(outputs)
    ops = outputs.values.filter_map { |result| result.fetch(:semantic_ir) }.flat_map do |program|
      program.fetch("contracts").flat_map do |contract|
        contract.fetch("nodes").flat_map { |node| expr_fns(node.fetch("expr")) }
      end
    end
    !ops.include?("stdlib.numeric.add") &&
      ops.all? { |op| !op.start_with?("stdlib.numeric.") }
  end

  def expr_fns(expr)
    case expr.fetch("kind")
    when "call"
      [expr.fetch("fn")] + expr.fetch("args").flat_map { |arg| expr_fns(arg) }
    when "field_access"
      expr_fns(expr.fetch("object"))
    else
      []
    end
  end

  def build_golden_checks(outputs, summary)
    semantic_equal = outputs.all? do |case_id, result|
      path = File.join(GOLDEN_DIR, "#{case_id}.semantic_ir.json")
      result.fetch(:semantic_ir) ? golden_equal?(path, result.fetch(:semantic_ir)) : !File.exist?(path)
    end
    reports_equal = outputs.all? do |case_id, result|
      golden_equal?(File.join(GOLDEN_DIR, "#{case_id}.compilation_report.json"), result.fetch(:compilation_report))
    end
    ast_equal = outputs.all? do |case_id, result|
      golden_equal?(File.join(GOLDEN_DIR, "#{case_id}.parsed_ast.json"), result.fetch(:parsed))
    end

    {
      "check.golden_semanticir_equal" => semantic_equal,
      "check.golden_compilation_report_equal" => reports_equal,
      "check.golden_ast_equal" => ast_equal,
      "check.summary_equal" => golden_equal?(File.join(GOLDEN_DIR, "summary.json"), summary),
      "check.canonical_all" => outputs.values.all? { |result|
        result.fetch(:semantic_ir).nil? || canonical_program?(result.fetch(:semantic_ir))
      },
      "check.compilation_reports_all" => outputs.values.all? { |result| canonical_report?(result.fetch(:compilation_report)) },
      "check.negative_semanticir_absent" => outputs.all? { |case_id, result|
        result.fetch(:semantic_ir) || !File.exist?(File.join(GOLDEN_DIR, "#{case_id}.semantic_ir.json"))
      },
      "check.deterministic_generation" => deterministic_outputs?
    }
  end

  def canonical_program?(program)
    return false unless program.fetch("kind") == "semantic_ir_program"
    return false unless program.fetch("format_version") == FORMAT_VERSION
    return false unless program.fetch("program_id") == "semanticir/#{program.fetch("source_hash").delete_prefix("sha256:")[0, 16]}"
    return false unless program.fetch("grammar_version").is_a?(String)
    return false unless program.fetch("source_hash").match?(/\Asha256:[0-9a-f]{64}\z/)
    return false if program.fetch("source_path").start_with?("igniter-lang/")
    return false unless program.key?("module")
    return false unless program.fetch("compilation_report_ref").match?(/\Acompilation_report\/[0-9a-f]{16}\z/)
    return false unless program.fetch("contracts").is_a?(Array)
    return false if program.key?("axiom_version")
    return false if program.key?("oof_log")

    program.fetch("contracts").all? { |contract| canonical_contract?(contract) }
  rescue KeyError
    false
  end

  def canonical_report?(report)
    return false unless report.fetch("kind") == "compilation_report"
    return false unless report.fetch("format_version") == FORMAT_VERSION
    return false unless report.fetch("program_id").match?(/\Acompilation_report\/[0-9a-f]{16}\z/)
    return false unless report.fetch("source_hash").match?(/\Asha256:[0-9a-f]{64}\z/)
    return false if report.fetch("source_path").start_with?("igniter-lang/")
    return false unless %w[ok oof error].include?(report.fetch("pass_result"))

    stages = report.fetch("stages")
    return false unless %w[parse classify typecheck emit].all? { |stage| stages.key?(stage) }
    return false unless report.fetch("diagnostics").all? { |diagnostic| canonical_diagnostic?(diagnostic) }

    if report.fetch("pass_result") == "ok"
      report.fetch("semantic_ir_ref").is_a?(String)
    else
      report.fetch("semantic_ir_ref").nil?
    end
  rescue KeyError
    false
  end

  def canonical_diagnostic?(diagnostic)
    %w[rule severity message node path line].all? { |key| diagnostic.key?(key) } &&
      diagnostic.fetch("severity") == "error"
  end

  def canonical_contract?(contract)
    required = %w[
      kind contract_ref contract_name specialization_of type_args fragment_class
      inputs outputs nodes escape_boundaries
    ]
    return false unless required.all? { |key| contract.key?(key) }
    return false unless contract.fetch("kind") == "contract_ir"
    return false unless contract.fetch("contract_ref").match?(/\Acontract\/#{Regexp.escape(contract.fetch("contract_name"))}\/sha256:[0-9a-f]{24}\z/)
    return false unless contract.fetch("type_args").is_a?(Hash)
    return false if %w[contract_id name escape_set input_ports compute_nodes output_ports dependency_graph oof_log diagnostics
                       evaluation_targets temporal_requirements lifecycle_requirements capability_requirements
                       effect_declarations ffi_requirements projection_descriptors boundary_descriptors].any? { |key| contract.key?(key) }
    return false unless contract.fetch("inputs").all? { |port| canonical_port?(port) }
    return false unless contract.fetch("outputs").all? { |port| canonical_port?(port) }
    return false unless contract.fetch("nodes").all? { |node| canonical_compute_node?(node) }

    true
  rescue KeyError
    false
  end

  def canonical_compute_node?(node)
    required = %w[kind name expr type deps fragment]
    return false unless required.all? { |key| node.key?(key) }
    return false unless node.fetch("kind") == "compute"
    return false unless canonical_type?(node.fetch("type"))
    return false unless node.fetch("deps").is_a?(Array)
    return false unless %w[core escape oof].include?(node.fetch("fragment"))

    canonical_expr?(node.fetch("expr"))
  rescue KeyError
    false
  end

  def canonical_port?(port)
    port.key?("name") &&
      port.key?("type") &&
      port.key?("lifecycle") &&
      canonical_type?(port.fetch("type"))
  end

  def canonical_type?(type)
    type.fetch("name").is_a?(String) && type.fetch("params").is_a?(Array)
  rescue KeyError
    false
  end

  def canonical_expr?(expr)
    return false unless expr.key?("kind")
    return false unless expr.key?("resolved_type")
    return false unless canonical_type?(expr.fetch("resolved_type"))

    case expr.fetch("kind")
    when "call"
      expr.key?("fn") && expr.fetch("args").all? { |arg| canonical_expr?(arg) }
    when "ref"
      expr.key?("name")
    when "literal"
      expr.key?("value") && expr.key?("type")
    when "field_access"
      expr.key?("field") && canonical_expr?(expr.fetch("object"))
    when "unsupported"
      expr.key?("source_kind")
    else
      false
    end
  rescue KeyError
    false
  end

  def deterministic_outputs?
    first = build_outputs
    second = build_outputs
    CASES.keys.all? do |case_id|
      render_json(first.fetch(case_id).fetch(:semantic_ir)) == render_json(second.fetch(case_id).fetch(:semantic_ir)) &&
        render_json(first.fetch(case_id).fetch(:compilation_report)) == render_json(second.fetch(case_id).fetch(:compilation_report)) &&
        render_json(first.fetch(case_id).fetch(:parsed)) == render_json(second.fetch(case_id).fetch(:parsed))
    end
  end

  def golden_equal?(path, expected)
    return false unless File.exist?(path)

    JSON.parse(File.read(path)) == expected
  end

  def rule_present?(outputs, case_id, rule)
    outputs.fetch(case_id)
           .fetch(:semantic_ir)
           .fetch("oof_log")
           .any? { |entry| entry.fetch("rule") == rule }
  end

  def only_contract(outputs, case_id)
    outputs.fetch(case_id).fetch(:semantic_ir).fetch("contracts").fetch(0)
  end

  def golden_count(suffix, expected)
    Dir[File.join(GOLDEN_DIR, "*#{suffix}")].length == expected
  end

  def write_json(path, object)
    File.write(path, render_json(object))
  end

  def render_json(object)
    "#{JSON.pretty_generate(object)}\n"
  end

  def rel(path)
    Pathname.new(path).relative_path_from(Pathname.new(ROOT)).to_s
  end
end

if $PROGRAM_NAME == __FILE__
  mode = ARGV.include?("--check-golden") ? :check_golden : :write
  SourceToSemanticIRFixture.run(mode: mode)
end
