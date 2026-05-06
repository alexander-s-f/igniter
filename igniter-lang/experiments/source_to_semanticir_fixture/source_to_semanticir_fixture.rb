#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"

require_relative "../parser/igniter_lang_parser"

module SourceToSemanticIRFixture
  ROOT = File.expand_path("../../..", __dir__)
  FIXTURE_DIR = __dir__
  GOLDEN_DIR = File.join(FIXTURE_DIR, "golden")
  AXIOM_VERSION = "1.0.0"

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

  class TinyCompiler
    def compile(parsed_program, sample_input:)
      @types = type_shapes(parsed_program)
      semantic_contracts = parsed_program.fetch("contracts").map do |contract|
        compile_contract(parsed_program, contract, sample_input)
      end

      {
        "kind" => "semantic_ir",
        "program_id" => program_id(parsed_program),
        "axiom_version" => AXIOM_VERSION,
        "grammar_version" => parsed_program.fetch("grammar_version"),
        "source_hash" => parsed_program.fetch("source_hash"),
        "contracts" => semantic_contracts,
        "oof_log" => semantic_contracts.flat_map { |contract| contract.fetch("oof_log") }
      }
    end

    private

    def program_id(parsed_program)
      seed = [
        parsed_program.fetch("source_path"),
        parsed_program.fetch("grammar_version"),
        parsed_program.fetch("source_hash")
      ].join("|")
      "source_to_semanticir/#{Digest::SHA256.hexdigest(seed)[0, 16]}"
    end

    def type_shapes(parsed_program)
      parsed_program.fetch("types").each_with_object({}) do |type, shapes|
        fields = type.fetch("fields", []).each_with_object({}) do |field, index|
          index[field.fetch("name")] = normalize_type(field.fetch("type_annotation"))
        end
        shapes[type.fetch("name")] = fields
      end
    end

    def compile_contract(parsed_program, contract, sample_input)
      diagnostics = []
      type_env = {}
      value_env = sample_input.dup
      inputs = []
      outputs = []
      nodes = []

      contract.fetch("body").each do |node|
        case node.fetch("kind")
        when "input"
          type = normalize_type(node.fetch("type_annotation"))
          type_env[node.fetch("name")] = type
          inputs << { "name" => node.fetch("name"), "type_tag" => type, "lifecycle" => "local" }
        when "compute"
          lowered = lower_expr(node.fetch("expr"), type_env, diagnostics, node.fetch("name"))
          type_env[node.fetch("name")] = lowered.fetch("type")
          value_env[node.fetch("name")] = eval_expr(node.fetch("expr"), value_env)
          nodes << {
            "node_id" => node_id(node.fetch("name")),
            "name" => node.fetch("name"),
            "type_tag" => lowered.fetch("type"),
            "lifecycle" => "session",
            "expression" => lowered.fetch("expr"),
            "deps" => lowered.fetch("deps").uniq,
            "fragment" => "core"
          }
        when "output"
          name = node.fetch("name")
          expected = normalize_type(node.fetch("type_annotation"))
          actual = type_env[name]
          if actual.nil?
            diagnostics << oof("OOF-P1", "Unresolved output source: #{name}", name)
          elsif actual != expected
            diagnostics << type_mismatch_oof(expected, actual, name)
          end
          outputs << {
            "name" => name,
            "type_tag" => expected,
            "lifecycle" => node.fetch("lifecycle", "session")
          }
        end
      end

      diagnostics.concat(evidence_gate_oofs(contract, sample_input, value_env))
      contract_id = contract_id(parsed_program, contract)

      {
        "contract_id" => contract_id,
        "name" => contract.fetch("name"),
        "fragment_class" => diagnostics.empty? ? "core" : "oof",
        "escape_set" => [],
        "input_ports" => inputs,
        "compute_nodes" => nodes.map { |node| node.reject { |key, _value| key == "deps" || key == "fragment" } },
        "output_ports" => outputs,
        "dependency_graph" => dependency_graph(inputs, nodes, outputs),
        "evaluation_targets" => evaluation_targets(contract_id, outputs),
        "temporal_requirements" => temporal_requirements,
        "lifecycle_requirements" => lifecycle_requirements,
        "capability_requirements" => capability_requirements,
        "effect_declarations" => [],
        "ffi_requirements" => [],
        "projection_descriptors" => [],
        "boundary_descriptors" => [],
        "escape_boundaries" => [],
        "oof_log" => diagnostics
      }
    end

    def contract_id(parsed_program, contract)
      [parsed_program.fetch("module"), contract.fetch("name")].compact.join(".")
    end

    def node_id(name)
      "node_#{name}"
    end

    def dependency_graph(inputs, nodes, outputs)
      input_names = inputs.map { |input| input.fetch("name") }
      compute_names = nodes.to_h { |node| [node.fetch("name"), node.fetch("node_id")] }
      graph_nodes = inputs.map { |input| "input:#{input.fetch("name")}" } +
                    nodes.map { |node| node.fetch("node_id") } +
                    outputs.map { |output| "output:#{output.fetch("name")}" }

      edges = nodes.flat_map do |node|
        node.fetch("deps").filter_map do |dep|
          from = if input_names.include?(dep)
                   "input:#{dep}"
                 elsif compute_names.key?(dep)
                   compute_names.fetch(dep)
                 end
          { "from" => from, "to" => node.fetch("node_id"), "kind" => "data" } if from
        end
      end
      edges.concat(outputs.filter_map do |output|
        from = compute_names[output.fetch("name")]
        { "from" => from, "to" => "output:#{output.fetch("name")}", "kind" => "data" } if from
      end)

      { "nodes" => graph_nodes, "edges" => edges }
    end

    def evaluation_targets(contract_id, outputs)
      outputs.map do |output|
        {
          "name" => output.fetch("name"),
          "contract_id" => contract_id,
          "output_ports" => [output.fetch("name")],
          "as_projection" => nil
        }
      end
    end

    def temporal_requirements
      {
        "requires_as_of" => true,
        "requires_replay" => false,
        "requires_snapshot" => false,
        "min_consistency" => "strong",
        "windows" => [],
        "slices" => []
      }
    end

    def lifecycle_requirements
      { "min_lifecycle" => "local", "has_audit" => false, "has_window" => false }
    end

    def capability_requirements
      { "required_caps" => [], "effect_kinds" => [] }
    end

    def lower_expr(expr, type_env, diagnostics, node_name)
      case expr.fetch("kind")
      when "literal"
        type = normalize_type(expr.fetch("type_tag"))
        { "expr" => { "kind" => "literal", "value" => expr.fetch("value"), "type_tag" => type },
          "type" => type,
          "deps" => [] }
      when "ref"
        name = expr.fetch("name")
        type = type_env[name]
        unless type
          diagnostics << oof("OOF-P1", "Unresolved symbol: #{name}", node_name)
          type = "Unknown"
        end
        { "expr" => { "kind" => "ref", "name" => name, "type_tag" => type },
          "type" => type,
          "deps" => [name] }
      when "field_access"
        object = lower_expr(expr.fetch("object"), type_env, diagnostics, node_name)
        field = expr.fetch("field")
        field_type = @types.fetch(object.fetch("type"), {})[field]
        unless field_type
          diagnostics << oof("OOF-P1", "Unresolved field: #{object.fetch("type")}.#{field}", node_name)
          field_type = "Unknown"
        end
        { "expr" => {
            "kind" => "field_access",
            "object" => object.fetch("expr"),
            "field" => field,
            "type_tag" => field_type
          },
          "type" => field_type,
          "deps" => object.fetch("deps") }
      when "binary_op"
        lower_binary(expr, type_env, diagnostics, node_name)
      when "call"
        fn = expr.fetch("fn")
        diagnostics << oof("OOF-P1", "Unresolved function: #{fn}", node_name)
        { "expr" => { "kind" => "apply", "operator" => fn, "operands" => [], "type_tag" => "Unknown" },
          "type" => "Unknown",
          "deps" => [] }
      else
        diagnostics << oof("OOF-P0", "Unsupported expression kind: #{expr.fetch("kind")}", node_name)
        { "expr" => { "kind" => "unsupported", "source_kind" => expr.fetch("kind") },
          "type" => "Unknown",
          "deps" => [] }
      end
    end

    def lower_binary(expr, type_env, diagnostics, node_name)
      left = lower_expr(expr.fetch("left"), type_env, diagnostics, node_name)
      right = lower_expr(expr.fetch("right"), type_env, diagnostics, node_name)
      op = expr.fetch("op")
      operator, result_type = operator_for(op, left.fetch("type"), right.fetch("type"), diagnostics, node_name)

      {
        "expr" => {
          "kind" => "apply",
          "operator" => operator,
          "operands" => [left.fetch("expr"), right.fetch("expr")],
          "type_tag" => result_type
        },
        "type" => result_type,
        "deps" => left.fetch("deps") + right.fetch("deps")
      }
    end

    def operator_for(op, left_type, right_type, diagnostics, node_name)
      case op
      when "+"
        unless unknown_type?(left_type, right_type) || (left_type == "Integer" && right_type == "Integer")
          diagnostics << oof("OOF-TY0", "Integer add requires Integer operands", node_name)
        end
        ["stdlib.integer.add", "Integer"]
      when ">"
        unless unknown_type?(left_type, right_type) || (left_type == "Integer" && right_type == "Integer")
          diagnostics << oof("OOF-TY0", "Integer comparison requires Integer operands", node_name)
        end
        ["stdlib.integer.gt", "Bool"]
      when "&&"
        unless unknown_type?(left_type, right_type) || (left_type == "Bool" && right_type == "Bool")
          diagnostics << oof("OOF-TY0", "Boolean and requires Bool operands", node_name)
        end
        ["stdlib.bool.and", "Bool"]
      else
        diagnostics << oof("OOF-P0", "Unsupported operator: #{op}", node_name)
        ["stdlib.unsupported.#{op}", "Unknown"]
      end
    end

    def unknown_type?(*types)
      types.any? { |type| type == "Unknown" }
    end

    def eval_expr(expr, env)
      case expr.fetch("kind")
      when "literal"
        expr.fetch("value")
      when "ref"
        env[expr.fetch("name")]
      when "field_access"
        object = eval_expr(expr.fetch("object"), env)
        object&.fetch(expr.fetch("field"), nil)
      when "binary_op"
        left = eval_expr(expr.fetch("left"), env)
        right = eval_expr(expr.fetch("right"), env)
        return nil if left.nil? || right.nil?

        case expr.fetch("op")
        when "+" then left + right
        when ">" then left > right
        when "&&" then left && right
        else nil
        end
      else
        nil
      end
    end

    def evidence_gate_oofs(contract, sample_input, value_env)
      return [] unless contract.fetch("name").include?("EvidenceLinkedAlert") ||
                       contract.fetch("name").include?("EvidenceLessAlert")

      alert = sample_input.fetch("alert", {})
      diagnostics = []
      if alert.fetch("signal_count", 0) < 1 || alert.fetch("claim_count", 0) < 1
        diagnostics << oof(
          "OOF-OS2",
          "EvidenceLinkedAlert requires non-empty signal_refs and claim_refs",
          contract.fetch("name")
        )
      end
      if alert.fetch("valid_until", "").to_s.empty?
        diagnostics << oof("OOF-OS4", "EvidenceLinkedAlert requires valid_until", contract.fetch("name"))
      end
      if value_env.key?("allowed") && value_env.fetch("allowed") != true && diagnostics.empty?
        diagnostics << oof("OOF-OS2", "EvidenceLinkedAlert gate did not pass", contract.fetch("name"))
      end
      diagnostics
    end

    def type_mismatch_oof(expected, actual, node_name)
      if expected == "Bool" && actual == "ConfidenceLabel"
        oof("OOF-CE4", "ConfidenceLabel cannot be used as Bool", node_name)
      else
        oof("OOF-TY0", "Type mismatch: expected #{expected}, got #{actual}", node_name)
      end
    end

    def normalize_type(type)
      type.is_a?(Hash) ? type.fetch("name") : type.to_s
    end

    def oof(rule, message, node_name)
      { "rule" => rule, "message" => message, "node" => node_name, "line" => nil }
    end
  end

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
    compiler = TinyCompiler.new
    CASES.each_with_object({}) do |(case_id, config), outputs|
      parsed = parse_case(config.fetch(:source))
      semantic_ir = compiler.compile(parsed, sample_input: config.fetch(:sample_input))
      outputs[case_id] = { parsed: parsed, semantic_ir: semantic_ir, config: config }
    end
  end

  def write_outputs(outputs, summary)
    outputs.each do |case_id, result|
      write_json(File.join(GOLDEN_DIR, "#{case_id}.parsed_ast.json"), result.fetch(:parsed))
      write_json(File.join(GOLDEN_DIR, "#{case_id}.semantic_ir.json"), result.fetch(:semantic_ir))
    end
    write_json(File.join(GOLDEN_DIR, "summary.json"), summary)
  end

  def build_summary
    {
      "kind" => "source_to_semanticir_fixture_summary",
      "canonical_envelope" => {
        "kind" => "semantic_ir",
        "axiom_version" => AXIOM_VERSION,
        "contract_keys" => %w[
          contract_id name fragment_class escape_set input_ports compute_nodes
          output_ports dependency_graph evaluation_targets temporal_requirements
          lifecycle_requirements capability_requirements effect_declarations
          ffi_requirements projection_descriptors boundary_descriptors
        ]
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
      "semanticir.add" => contract_ok?(outputs, "add", "Add", "stdlib.integer.add", "Integer"),
      "parse.claim_evidence" => parsed_ok?(outputs, "claim_evidence"),
      "semanticir.envelope.claim_evidence" => canonical_program?(outputs.fetch("claim_evidence").fetch(:semantic_ir)),
      "semanticir.claim_evidence" => contract_ok?(outputs, "claim_evidence", "ClaimEvidenceBundle", nil, "String"),
      "parse.evidence_linked_alert" => parsed_ok?(outputs, "evidence_linked_alert"),
      "semanticir.envelope.evidence_linked_alert" => canonical_program?(outputs.fetch("evidence_linked_alert").fetch(:semantic_ir)),
      "semanticir.evidence_linked_alert" => alert_gate_ok?(outputs),
      "negative.unresolved_symbol" => rule_present?(outputs, "negative_unresolved_symbol", "OOF-P1"),
      "negative.evidence_less_alert" => rule_present?(outputs, "negative_evidence_less_alert", "OOF-OS2"),
      "negative.confidence_bool" => rule_present?(outputs, "negative_confidence_bool", "OOF-CE4"),
      "golden.ast_outputs" => golden_count(".parsed_ast.json", 6),
      "golden.semanticir_outputs" => golden_count(".semantic_ir.json", 6)
    }
  end

  def parsed_ok?(outputs, case_id)
    outputs.fetch(case_id).fetch(:parsed).fetch("parse_errors").empty?
  end

  def contract_ok?(outputs, case_id, contract_name, required_operator, output_type)
    contract = only_contract(outputs, case_id)
    return false unless contract.fetch("name") == contract_name
    return false unless contract.fetch("fragment_class") == "core"
    return false unless contract.fetch("oof_log").empty?
    return false unless contract.fetch("output_ports").any? { |out| out.fetch("type_tag") == output_type }

    return true unless required_operator

    contract.fetch("compute_nodes").any? { |node| node.fetch("expression").fetch("operator", nil) == required_operator }
  end

  def alert_gate_ok?(outputs)
    contract = only_contract(outputs, "evidence_linked_alert")
    operators = contract.fetch("compute_nodes").map { |node| node.fetch("expression").fetch("operator", nil) }
    contract.fetch("fragment_class") == "core" &&
      contract.fetch("oof_log").empty? &&
      operators.include?("stdlib.integer.gt") &&
      operators.include?("stdlib.bool.and")
  end

  def build_golden_checks(outputs, summary)
    semantic_equal = outputs.all? do |case_id, result|
      golden_equal?(File.join(GOLDEN_DIR, "#{case_id}.semantic_ir.json"), result.fetch(:semantic_ir))
    end
    ast_equal = outputs.all? do |case_id, result|
      golden_equal?(File.join(GOLDEN_DIR, "#{case_id}.parsed_ast.json"), result.fetch(:parsed))
    end

    {
      "check.golden_semanticir_equal" => semantic_equal,
      "check.golden_ast_equal" => ast_equal,
      "check.summary_equal" => golden_equal?(File.join(GOLDEN_DIR, "summary.json"), summary),
      "check.canonical_all" => outputs.values.all? { |result| canonical_program?(result.fetch(:semantic_ir)) },
      "check.deterministic_generation" => deterministic_outputs?
    }
  end

  def canonical_program?(program)
    return false unless program.fetch("kind") == "semantic_ir"
    return false unless program.fetch("axiom_version") == AXIOM_VERSION
    return false unless program.fetch("program_id").is_a?(String)
    return false unless program.fetch("grammar_version").is_a?(String)
    return false unless program.fetch("source_hash").start_with?("sha256:")
    return false unless program.fetch("contracts").is_a?(Array)
    return false if program.key?("source_path") || program.key?("module")

    program.fetch("contracts").all? { |contract| canonical_contract?(contract) }
  rescue KeyError
    false
  end

  def canonical_contract?(contract)
    required = %w[
      contract_id name fragment_class escape_set input_ports compute_nodes
      output_ports dependency_graph evaluation_targets temporal_requirements
      lifecycle_requirements capability_requirements effect_declarations
      ffi_requirements projection_descriptors boundary_descriptors
      escape_boundaries oof_log
    ]
    return false unless required.all? { |key| contract.key?(key) }
    return false if %w[kind contract_ref contract_name inputs outputs nodes].any? { |key| contract.key?(key) }
    return false unless contract.fetch("input_ports").all? { |port| port.key?("name") && port.key?("type_tag") }
    return false unless contract.fetch("output_ports").all? { |port| port.key?("name") && port.key?("type_tag") }
    return false unless contract.fetch("compute_nodes").all? { |node| canonical_compute_node?(node) }

    graph = contract.fetch("dependency_graph")
    graph.key?("nodes") && graph.key?("edges")
  rescue KeyError
    false
  end

  def canonical_compute_node?(node)
    required = %w[node_id name type_tag lifecycle expression]
    return false unless required.all? { |key| node.key?(key) }
    return false if %w[kind expr type deps fragment].any? { |key| node.key?(key) }

    %w[apply field_access ref literal unsupported].include?(node.fetch("expression").fetch("kind"))
  rescue KeyError
    false
  end

  def deterministic_outputs?
    first = build_outputs
    second = build_outputs
    CASES.keys.all? do |case_id|
      render_json(first.fetch(case_id).fetch(:semantic_ir)) == render_json(second.fetch(case_id).fetch(:semantic_ir)) &&
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

require "fileutils"
require "pathname"

if $PROGRAM_NAME == __FILE__
  mode = ARGV.include?("--check-golden") ? :check_golden : :write
  SourceToSemanticIRFixture.run(mode: mode)
end
