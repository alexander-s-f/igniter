#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

module TypecheckerProof
  ROOT = File.expand_path("../../..", __dir__)
  DEFAULT_CLASSIFIED_DIR = File.join(__dir__, "classified")
  GOLDEN_DIR = File.join(__dir__, "golden")
  TYPECHECKER_VERSION = "typed-pass-executable-proof-v0"

  CASES = {
    "add" => {
      classified: "add.classified.json",
      expected_contract: "Add",
      expected_status: "accepted",
      expected_rules: [],
      expected_outputs: { "sum" => "Integer" }
    },
    "claim_evidence" => {
      classified: "claim_evidence.classified.json",
      expected_contract: "ClaimEvidenceBundle",
      expected_status: "accepted",
      expected_rules: [],
      expected_outputs: { "linked_claim_ref" => "String" }
    },
    "evidence_linked_alert" => {
      classified: "evidence_linked_alert.classified.json",
      expected_contract: "EvidenceLinkedAlertGate",
      expected_status: "accepted",
      expected_rules: [],
      expected_outputs: { "allowed" => "Bool" }
    },
    "negative_unresolved_symbol" => {
      classified: "negative_unresolved_symbol.classified.json",
      expected_contract: "BadUnresolvedSymbol",
      expected_status: "blocked",
      expected_rules: ["OOF-P1"]
    },
    "negative_evidence_less_alert" => {
      classified: "negative_evidence_less_alert.classified.json",
      expected_contract: "BadEvidenceLessAlertGate",
      expected_status: "blocked",
      expected_rules: ["OOF-OS2"]
    },
    "negative_confidence_bool" => {
      classified: "negative_confidence_bool.classified.json",
      expected_contract: "BadConfidenceAsBool",
      expected_status: "blocked",
      expected_rules: ["OOF-CE4"]
    }
  }.freeze

  class TypecheckerPass
    def typecheck(classified_program)
      @type_shapes = type_shapes(classified_program)
      typed_contracts = classified_program.fetch("contracts").map do |contract|
        typecheck_contract(contract)
      end

      {
        "kind" => "typed_program",
        "typechecker_version" => TYPECHECKER_VERSION,
        "program_id" => program_id(classified_program),
        "classified_program_id" => classified_program.fetch("program_id"),
        "source_path" => classified_program.fetch("source_path"),
        "source_hash" => classified_program.fetch("source_hash"),
        "grammar_version" => classified_program.fetch("grammar_version"),
        "module" => classified_program.fetch("module"),
        "type_env" => @type_shapes,
        "contracts" => typed_contracts,
        "type_errors" => typed_contracts.flat_map { |contract| contract.fetch("type_errors") },
        "semantic_ir_ref" => nil
      }
    end

    private

    def program_id(classified_program)
      seed = [
        classified_program.fetch("program_id"),
        classified_program.fetch("source_hash"),
        TYPECHECKER_VERSION
      ].join("|")
      "typed_pass/#{Digest::SHA256.hexdigest(seed)[0, 16]}"
    end

    def type_shapes(classified_program)
      classified_program.fetch("type_declarations").each_with_object({}) do |type, shapes|
        shapes[type.fetch("name")] = type.fetch("fields", []).each_with_object({}) do |field, fields|
          fields[field.fetch("name")] = type_ir(normalize_type(field.fetch("type_annotation")))
        end
      end
    end

    def typecheck_contract(classified_contract)
      declared_oofs = classified_contract.fetch("oof_log")
      type_errors = declared_oofs.dup
      symbol_types = {}
      typed_decls = []

      classified_contract.fetch("declarations").each do |decl|
        case decl.fetch("kind")
        when "input"
          type = type_ir(decl.fetch("type_annotation"))
          symbol_types[decl.fetch("name")] = type
          typed_decls << typed_decl(decl, type, nil, [])
        when "compute"
          typed_expr = infer_expr(decl.fetch("expr"), symbol_types, type_errors, decl.fetch("name"))
          symbol_types[decl.fetch("name")] = typed_expr.fetch("resolved_type")
          typed_decls << typed_decl(decl, typed_expr.fetch("resolved_type"), typed_expr, typed_expr.fetch("deps"))
        when "output"
          expected = type_ir(decl.fetch("type_annotation"))
          actual = symbol_types.fetch(decl.fetch("name"), type_ir("Unknown"))
          if type_name(actual) != type_name(expected) && !blocking_rule_present?(type_errors)
            type_errors << type_mismatch(expected, actual, decl.fetch("name"))
          end
          typed_decls << typed_decl(decl, expected, nil, decl.fetch("deps"))
        end
      end

      status = type_errors.empty? ? "accepted" : "blocked"
      {
        "kind" => "typed_contract",
        "contract_id" => classified_contract.fetch("contract_id"),
        "name" => classified_contract.fetch("name"),
        "status" => status,
        "fragment_class" => classified_contract.fetch("fragment_class"),
        "symbols" => symbol_types.keys.sort.map do |name|
          { "name" => name, "type" => symbol_types.fetch(name), "resolved" => type_name(symbol_types.fetch(name)) != "Unknown" }
        end,
        "declarations" => typed_decls,
        "type_errors" => dedupe_errors(type_errors)
      }
    end

    def typed_decl(decl, type, expr, deps)
      result = {
        "decl_id" => decl.fetch("decl_id"),
        "kind" => decl.fetch("kind"),
        "name" => decl.fetch("name"),
        "fragment_class" => decl.fetch("fragment_class"),
        "type" => type,
        "deps" => deps
      }
      result["expr"] = expr if expr
      result
    end

    def infer_expr(expr, symbol_types, type_errors, node_name)
      case expr.fetch("kind")
      when "literal"
        type = type_ir(expr.fetch("type_tag"))
        typed_expr("literal", type, [], "value" => expr.fetch("value"), "literal_type" => literal_type(type_name(type)))
      when "ref"
        name = expr.fetch("name")
        type = symbol_types.fetch(name, type_ir("Unknown"))
        type_errors << oof("OOF-P1", "Unresolved symbol: #{name}", node_name) if type_name(type) == "Unknown" && !rule_present?(type_errors, "OOF-P1")
        typed_expr("ref", type, [name], "name" => name)
      when "field_access"
        object = infer_expr(expr.fetch("object"), symbol_types, type_errors, node_name)
        object_type = type_name(object.fetch("resolved_type"))
        field_type = @type_shapes.fetch(object_type, {})[expr.fetch("field")] || type_ir("Unknown")
        if type_name(field_type) == "Unknown"
          type_errors << oof("OOF-P1", "Unresolved field: #{object_type}.#{expr.fetch("field")}", node_name)
        end
        typed_expr(
          "field_access",
          field_type,
          object.fetch("deps"),
          "object" => object,
          "field" => expr.fetch("field")
        )
      when "binary_op"
        infer_binary(expr, symbol_types, type_errors, node_name)
      else
        type_errors << oof("OOF-TY0", "Unsupported expression kind: #{expr.fetch("kind")}", node_name)
        typed_expr("unsupported", type_ir("Unknown"), [], "source_kind" => expr.fetch("kind"))
      end
    end

    def infer_binary(expr, symbol_types, type_errors, node_name)
      left = infer_expr(expr.fetch("left"), symbol_types, type_errors, node_name)
      right = infer_expr(expr.fetch("right"), symbol_types, type_errors, node_name)
      operator, result_type = operator_type(expr.fetch("op"), left.fetch("resolved_type"), right.fetch("resolved_type"), type_errors, node_name)
      typed_expr(
        "call",
        result_type,
        left.fetch("deps") + right.fetch("deps"),
        "fn" => operator,
        "args" => [left, right]
      )
    end

    def operator_type(op, left, right, type_errors, node_name)
      left_name = type_name(left)
      right_name = type_name(right)
      case op
      when "+"
        type_errors << type_mismatch(type_ir("Integer"), type_ir("#{left_name}+#{right_name}"), node_name) unless unknown?(left, right) || left_name == "Integer" && right_name == "Integer"
        ["stdlib.integer.add", type_ir("Integer")]
      when ">"
        type_errors << type_mismatch(type_ir("Integer"), type_ir("#{left_name}+#{right_name}"), node_name) unless unknown?(left, right) || left_name == "Integer" && right_name == "Integer"
        ["stdlib.integer.gt", type_ir("Bool")]
      when "&&"
        type_errors << type_mismatch(type_ir("Bool"), type_ir("#{left_name}+#{right_name}"), node_name) unless unknown?(left, right) || left_name == "Bool" && right_name == "Bool"
        ["stdlib.bool.and", type_ir("Bool")]
      else
        type_errors << oof("OOF-TY0", "Unsupported operator: #{op}", node_name)
        ["stdlib.unsupported.#{op}", type_ir("Unknown")]
      end
    end

    def typed_expr(kind, type, deps, extra)
      { "kind" => kind }.merge(extra).merge("resolved_type" => type, "deps" => deps.uniq)
    end

    def type_ir(name)
      { "name" => normalize_type(name), "params" => [] }
    end

    def type_name(type)
      type.fetch("name")
    end

    def normalize_type(type)
      type.is_a?(Hash) ? type.fetch("name") : type.to_s
    end

    def literal_type(name)
      {
        "Integer" => "int",
        "Float" => "float",
        "String" => "string",
        "Bool" => "bool",
        "Nil" => "nil"
      }.fetch(name, name.downcase)
    end

    def unknown?(*types)
      types.any? { |type| type_name(type) == "Unknown" }
    end

    def type_mismatch(expected, actual, node)
      oof("OOF-TY0", "Type mismatch: expected #{type_name(expected)}, got #{type_name(actual)}", node)
    end

    def oof(rule, message, node_name)
      { "rule" => rule, "message" => message, "node" => node_name, "line" => nil }
    end

    def rule_present?(errors, rule)
      errors.any? { |entry| entry.fetch("rule") == rule }
    end

    def blocking_rule_present?(errors)
      %w[OOF-P1 OOF-CE4 OOF-OS2].any? { |rule| rule_present?(errors, rule) }
    end

    def dedupe_errors(errors)
      errors.uniq { |entry| [entry.fetch("rule"), entry.fetch("message"), entry.fetch("node"), entry.fetch("line")] }
    end
  end

  module_function

  def run(mode: :write, classified_dir: DEFAULT_CLASSIFIED_DIR)
    FileUtils.mkdir_p(GOLDEN_DIR)
    classified_dir = File.expand_path(classified_dir)
    outputs = build_outputs(classified_dir: classified_dir)
    write_outputs(outputs) if mode == :write

    checks = build_checks(outputs, classified_dir: classified_dir)
    checks = checks.merge(build_golden_checks(outputs, classified_dir: classified_dir)) if mode == :check_golden
    checks.each { |label, ok| puts "#{label}: #{ok ? "ok" : "FAIL"}" }
    puts "classified.dir: #{rel(classified_dir)}"
    puts "golden.dir: #{rel(GOLDEN_DIR)}"

    if checks.all? { |_label, ok| ok }
      puts mode == :check_golden ? "PASS typechecker_golden_check" : "PASS typechecker_proof"
    else
      abort(mode == :check_golden ? "FAIL typechecker_golden_check" : "FAIL typechecker_proof")
    end
  end

  def build_outputs(classified_dir:)
    typechecker = TypecheckerPass.new
    CASES.each_with_object({}) do |(case_id, config), outputs|
      classified = read_json(File.join(classified_dir, config.fetch(:classified)))
      typed = typechecker.typecheck(classified)
      outputs[case_id] = { classified: classified, typed: typed, config: config }
    end
  end

  def write_outputs(outputs)
    outputs.each do |case_id, result|
      write_json(File.join(GOLDEN_DIR, "#{case_id}.typed.json"), result.fetch(:typed))
    end
  end

  def build_checks(outputs, classified_dir:)
    {
      "typed.add" => accepted_with_outputs?(outputs, "add"),
      "typed.claim_evidence" => accepted_with_outputs?(outputs, "claim_evidence"),
      "typed.evidence_linked_alert" => accepted_with_outputs?(outputs, "evidence_linked_alert"),
      "typed.accepted_no_unresolved_types" => accepted_no_unresolved_types?(outputs),
      "negative.unresolved_symbol_blocked" => blocked_with_rules?(outputs, "negative_unresolved_symbol"),
      "negative.evidence_less_alert_blocked" => blocked_with_rules?(outputs, "negative_evidence_less_alert"),
      "negative.confidence_bool_blocked" => blocked_with_rules?(outputs, "negative_confidence_bool"),
      "semanticir.not_emitted" => outputs.values.all? { |result| result.fetch(:typed).fetch("semantic_ir_ref").nil? },
      "boundary.classified_inputs_present" => classified_inputs_present?(classified_dir),
      "boundary.classified_program_input_only" => classified_program_input_only?(outputs),
      "golden.typed_outputs" => Dir[File.join(GOLDEN_DIR, "*.typed.json")].length == CASES.length
    }
  end

  def accepted_with_outputs?(outputs, case_id)
    result = outputs.fetch(case_id)
    contract = only_contract(result)
    config = result.fetch(:config)
    return false unless contract.fetch("name") == config.fetch(:expected_contract)
    return false unless contract.fetch("status") == config.fetch(:expected_status)
    return false unless contract.fetch("type_errors").empty?

    config.fetch(:expected_outputs).all? do |name, type_name|
      output = contract.fetch("declarations").find { |decl| decl.fetch("kind") == "output" && decl.fetch("name") == name }
      output && output.fetch("type").fetch("name") == type_name
    end
  end

  def accepted_no_unresolved_types?(outputs)
    outputs.select { |_case_id, result| result.fetch(:config).fetch(:expected_status) == "accepted" }.all? do |_case_id, result|
      !JSON.generate(result.fetch(:typed)).include?("\"name\":\"Unknown\"")
    end
  end

  def blocked_with_rules?(outputs, case_id)
    result = outputs.fetch(case_id)
    contract = only_contract(result)
    actual_rules = result.fetch(:typed).fetch("type_errors").map { |entry| entry.fetch("rule") }.uniq
    contract.fetch("status") == "blocked" && actual_rules == result.fetch(:config).fetch(:expected_rules)
  end

  def build_golden_checks(outputs, classified_dir:)
    {
      "check.golden_typed_equal" => outputs.all? do |case_id, result|
        golden_equal?(File.join(GOLDEN_DIR, "#{case_id}.typed.json"), result.fetch(:typed))
      end,
      "check.canonical_typed_all" => outputs.values.all? { |result| canonical_typed?(result.fetch(:typed)) },
      "check.deterministic_generation" => deterministic_outputs?(classified_dir: classified_dir)
    }
  end

  def canonical_typed?(program)
    return false unless program.fetch("kind") == "typed_program"
    return false unless program.fetch("typechecker_version") == TYPECHECKER_VERSION
    return false unless program.fetch("semantic_ir_ref").nil?

    program.fetch("contracts").all? do |contract|
      %w[kind contract_id name status fragment_class symbols declarations type_errors].all? { |key| contract.key?(key) }
    end
  rescue KeyError
    false
  end

  def classified_inputs_present?(classified_dir)
    CASES.values.all? do |config|
      File.exist?(File.join(classified_dir, config.fetch(:classified)))
    end
  end

  def classified_program_input_only?(outputs)
    outputs.values.all? do |result|
      classified = result.fetch(:classified)
      classified.fetch("kind") == "classified_program" &&
        classified.key?("contracts") &&
        classified.key?("type_declarations")
    end
  end

  def deterministic_outputs?(classified_dir:)
    first = build_outputs(classified_dir: classified_dir)
    second = build_outputs(classified_dir: classified_dir)
    CASES.keys.all? do |case_id|
      render_json(first.fetch(case_id).fetch(:typed)) == render_json(second.fetch(case_id).fetch(:typed))
    end
  end

  def only_contract(result)
    result.fetch(:typed).fetch("contracts").fetch(0)
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, object)
    File.write(path, render_json(object))
  end

  def render_json(object)
    "#{JSON.pretty_generate(object)}\n"
  end

  def golden_equal?(path, expected)
    return false unless File.exist?(path)

    JSON.parse(File.read(path)) == expected
  end

  def rel(path)
    Pathname.new(path).relative_path_from(Pathname.new(ROOT)).to_s
  end
end

if $PROGRAM_NAME == __FILE__
  mode = ARGV.include?("--check-golden") ? :check_golden : :write
  classified_dir = TypecheckerProof::DEFAULT_CLASSIFIED_DIR
  if (index = ARGV.index("--classified-dir"))
    classified_dir = ARGV.fetch(index + 1) do
      abort("--classified-dir requires a path")
    end
  end
  TypecheckerProof.run(mode: mode, classified_dir: classified_dir)
end
