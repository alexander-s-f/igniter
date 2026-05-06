#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

module ClassifierPassProof
  ROOT = File.expand_path("../../..", __dir__)
  FIXTURE_INPUT_DIR = File.expand_path("../source_to_semanticir_fixture", __dir__)
  PARSED_DIR = File.join(FIXTURE_INPUT_DIR, "golden")
  GOLDEN_DIR = File.join(__dir__, "golden")
  CLASSIFIER_VERSION = "classifier-pass-executable-proof-v0"

  CASES = {
    "add" => {
      parsed: "add.parsed_ast.json",
      expected_contract: "Add",
      expected_fragment: "core",
      expected_rules: [],
      sample_input: { "a" => 2, "b" => 3 }
    },
    "claim_evidence" => {
      parsed: "claim_evidence.parsed_ast.json",
      expected_contract: "ClaimEvidenceBundle",
      expected_fragment: "core",
      expected_rules: [],
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
      parsed: "evidence_linked_alert.parsed_ast.json",
      expected_contract: "EvidenceLinkedAlertGate",
      expected_fragment: "core",
      expected_rules: [],
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
      parsed: "negative_unresolved_symbol.parsed_ast.json",
      expected_contract: "BadUnresolvedSymbol",
      expected_fragment: "oof",
      expected_rules: ["OOF-P1"],
      sample_input: { "a" => 1 }
    },
    "negative_evidence_less_alert" => {
      parsed: "negative_evidence_less_alert.parsed_ast.json",
      expected_contract: "BadEvidenceLessAlertGate",
      expected_fragment: "oof",
      expected_rules: ["OOF-OS2"],
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
      parsed: "negative_confidence_bool.parsed_ast.json",
      expected_contract: "BadConfidenceAsBool",
      expected_fragment: "oof",
      expected_rules: ["OOF-CE4"],
      sample_input: {
        "confidence" => {
          "assessment_id" => "confidence/synthetic/direct",
          "confidence_label" => "high"
        }
      }
    }
  }.freeze

  class ClassifierPass
    def classify(parsed_program, sample_input:)
      contracts = parsed_program.fetch("contracts").map do |contract|
        classify_contract(parsed_program, contract, sample_input)
      end

      {
        "kind" => "classified_program",
        "classifier_version" => CLASSIFIER_VERSION,
        "program_id" => program_id(parsed_program),
        "source_path" => parsed_program.fetch("source_path"),
        "source_hash" => parsed_program.fetch("source_hash"),
        "grammar_version" => parsed_program.fetch("grammar_version"),
        "module" => parsed_program.fetch("module"),
        "contracts" => contracts,
        "oof_log" => contracts.flat_map { |contract| contract.fetch("oof_log") },
        "semantic_ir_ref" => nil
      }
    end

    private

    def program_id(parsed_program)
      seed = [
        parsed_program.fetch("source_path"),
        parsed_program.fetch("grammar_version"),
        parsed_program.fetch("source_hash"),
        CLASSIFIER_VERSION
      ].join("|")
      "classifier_pass/#{Digest::SHA256.hexdigest(seed)[0, 16]}"
    end

    def classify_contract(parsed_program, contract, sample_input)
      diagnostics = []
      declarations = []
      symbol_fragments = {}
      symbol_kinds = {}
      compute_exprs = {}

      contract.fetch("body").each do |node|
        case node.fetch("kind")
        when "input"
          symbol_fragments[node.fetch("name")] = "core"
          symbol_kinds[node.fetch("name")] = "input"
          declarations << classified_decl(node, "core", [], [])
        when "compute"
          deps = expr_refs(node.fetch("expr"))
          missing = deps.reject { |dep| symbol_fragments.key?(dep) }
          missing.each do |name|
            diagnostics << oof("OOF-P1", "Unresolved symbol: #{name}", node.fetch("name"))
          end
          upstream_oof = deps.any? { |dep| symbol_fragments[dep] == "oof" }
          fragment = missing.empty? && !upstream_oof ? "core" : "oof"
          symbol_fragments[node.fetch("name")] = fragment
          symbol_kinds[node.fetch("name")] = "compute"
          compute_exprs[node.fetch("name")] = node.fetch("expr")
          declarations << classified_decl(node, fragment, deps, missing)
        when "output"
          name = node.fetch("name")
          missing = symbol_fragments.key?(name) ? [] : [name]
          diagnostics << oof("OOF-P1", "Unresolved output source: #{name}", name) unless missing.empty?
          fragment = missing.empty? && symbol_fragments.fetch(name) == "core" ? "core" : "oof"
          confidence_oof = confidence_as_bool_oof(node, compute_exprs[name])
          diagnostics << confidence_oof if confidence_oof
          fragment = "oof" if confidence_oof
          declarations << classified_decl(node, fragment, [name], missing)
        end
      end

      diagnostics.concat(evidence_gate_oofs(contract, sample_input))
      contract_fragment = diagnostics.empty? && declarations.all? { |decl| decl.fetch("fragment_class") == "core" } ? "core" : "oof"

      {
        "kind" => "classified_contract",
        "contract_id" => contract_id(parsed_program, contract),
        "name" => contract.fetch("name"),
        "fragment_class" => contract_fragment,
        "symbols" => symbol_table(symbol_kinds, symbol_fragments),
        "declarations" => declarations,
        "dependency_graph" => dependency_graph(declarations),
        "oof_log" => diagnostics
      }
    end

    def contract_id(parsed_program, contract)
      [parsed_program.fetch("module"), contract.fetch("name")].compact.join(".")
    end

    def classified_decl(node, fragment, deps, missing)
      result = {
        "decl_id" => decl_id(node),
        "kind" => node.fetch("kind"),
        "name" => node.fetch("name"),
        "fragment_class" => fragment,
        "deps" => deps,
        "missing_refs" => missing
      }
      result["type_annotation"] = normalize_type(node["type_annotation"]) if node.key?("type_annotation")
      result["expr_kind"] = node.fetch("expr").fetch("kind") if node.key?("expr")
      result
    end

    def decl_id(node)
      "#{node.fetch("kind")}:#{node.fetch("name")}"
    end

    def symbol_table(symbol_kinds, symbol_fragments)
      symbol_kinds.keys.sort.map do |name|
        {
          "name" => name,
          "kind" => symbol_kinds.fetch(name),
          "fragment_class" => symbol_fragments.fetch(name)
        }
      end
    end

    def dependency_graph(declarations)
      declaration_ids = declarations.map { |decl| decl.fetch("decl_id") }
      symbol_producers = declarations.each_with_object({}) do |decl, index|
        next unless %w[input compute].include?(decl.fetch("kind"))

        index[decl.fetch("name")] = decl.fetch("decl_id")
      end
      edges = declarations.flat_map do |decl|
        decl.fetch("deps").filter_map do |dep|
          from = symbol_producers[dep]
          next unless from

          { "from" => from, "to" => decl.fetch("decl_id"), "kind" => "symbol" }
        end
      end
      { "nodes" => declaration_ids, "edges" => edges }
    end

    def expr_refs(expr)
      case expr.fetch("kind")
      when "ref"
        [expr.fetch("name")]
      when "field_access"
        expr_refs(expr.fetch("object"))
      when "binary_op"
        expr_refs(expr.fetch("left")) + expr_refs(expr.fetch("right"))
      when "call"
        [expr.fetch("fn")] + expr.fetch("args", []).flat_map { |arg| expr_refs(arg) }
      when "literal", "symbol"
        []
      else
        expr.values.flat_map { |value| value.is_a?(Hash) ? expr_refs(value) : [] }
      end.uniq
    end

    def confidence_as_bool_oof(output_node, expr)
      return nil unless normalize_type(output_node.fetch("type_annotation")) == "Bool"
      return nil unless confidence_label_expr?(expr)

      oof("OOF-CE4", "ConfidenceLabel cannot be used as Bool", output_node.fetch("name"))
    end

    def confidence_label_expr?(expr)
      return false unless expr
      return true if expr.fetch("kind") == "field_access" && expr.fetch("field") == "confidence_label"

      false
    end

    def evidence_gate_oofs(contract, sample_input)
      return [] unless evidence_alert_contract?(contract)

      alert = sample_input.fetch("alert", {})
      diagnostics = []
      if alert.fetch("signal_count", 0) < 1 || alert.fetch("claim_count", 0) < 1
        diagnostics << oof(
          "OOF-OS2",
          "EvidenceLinkedAlert requires non-empty signal_refs and claim_refs",
          contract.fetch("name")
        )
      end
      diagnostics
    end

    def evidence_alert_contract?(contract)
      contract.fetch("body").any? do |node|
        node.fetch("kind") == "input" &&
          normalize_type(node.fetch("type_annotation")) == "EvidenceLinkedAlertInput"
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
    write_outputs(outputs) if mode == :write

    checks = build_checks(outputs)
    checks = checks.merge(build_golden_checks(outputs)) if mode == :check_golden
    checks.each { |label, ok| puts "#{label}: #{ok ? "ok" : "FAIL"}" }
    puts "golden.dir: #{rel(GOLDEN_DIR)}"

    if checks.all? { |_label, ok| ok }
      puts mode == :check_golden ? "PASS classifier_pass_golden_check" : "PASS classifier_pass_proof"
    else
      abort(mode == :check_golden ? "FAIL classifier_pass_golden_check" : "FAIL classifier_pass_proof")
    end
  end

  def build_outputs
    classifier = ClassifierPass.new
    CASES.each_with_object({}) do |(case_id, config), outputs|
      parsed = read_json(File.join(PARSED_DIR, config.fetch(:parsed)))
      classified = classifier.classify(parsed, sample_input: config.fetch(:sample_input))
      outputs[case_id] = { parsed: parsed, classified: classified, config: config }
    end
  end

  def write_outputs(outputs)
    outputs.each do |case_id, result|
      write_json(File.join(GOLDEN_DIR, "#{case_id}.classified.json"), result.fetch(:classified))
    end
  end

  def build_checks(outputs)
    {
      "classified.add" => classified_ok?(outputs, "add"),
      "classified.claim_evidence" => classified_ok?(outputs, "claim_evidence"),
      "classified.evidence_linked_alert" => classified_ok?(outputs, "evidence_linked_alert"),
      "core.add_propagates" => core_propagates?(outputs, "add"),
      "core.claim_evidence_propagates" => core_propagates?(outputs, "claim_evidence"),
      "core.evidence_linked_alert_propagates" => core_propagates?(outputs, "evidence_linked_alert"),
      "negative.unresolved_symbol" => rules_match?(outputs, "negative_unresolved_symbol"),
      "negative.evidence_less_alert" => rules_match?(outputs, "negative_evidence_less_alert"),
      "negative.confidence_bool" => rules_match?(outputs, "negative_confidence_bool"),
      "semanticir.not_emitted" => outputs.values.all? { |result| result.fetch(:classified).fetch("semantic_ir_ref").nil? },
      "golden.classified_outputs" => Dir[File.join(GOLDEN_DIR, "*.classified.json")].length == CASES.length
    }
  end

  def classified_ok?(outputs, case_id)
    result = outputs.fetch(case_id)
    contract = only_contract(result)
    config = result.fetch(:config)
    result.fetch(:classified).fetch("kind") == "classified_program" &&
      contract.fetch("name") == config.fetch(:expected_contract) &&
      contract.fetch("fragment_class") == config.fetch(:expected_fragment)
  end

  def core_propagates?(outputs, case_id)
    contract = only_contract(outputs.fetch(case_id))
    contract.fetch("fragment_class") == "core" &&
      contract.fetch("declarations").all? { |decl| decl.fetch("fragment_class") == "core" } &&
      contract.fetch("oof_log").empty?
  end

  def rules_match?(outputs, case_id)
    result = outputs.fetch(case_id)
    actual = result.fetch(:classified).fetch("oof_log").map { |entry| entry.fetch("rule") }.uniq
    actual == result.fetch(:config).fetch(:expected_rules)
  end

  def build_golden_checks(outputs)
    {
      "check.golden_classified_equal" => outputs.all? do |case_id, result|
        golden_equal?(File.join(GOLDEN_DIR, "#{case_id}.classified.json"), result.fetch(:classified))
      end,
      "check.canonical_classified_all" => outputs.values.all? { |result| canonical_classified?(result.fetch(:classified)) },
      "check.deterministic_generation" => deterministic_outputs?
    }
  end

  def canonical_classified?(program)
    return false unless program.fetch("kind") == "classified_program"
    return false unless program.fetch("classifier_version") == CLASSIFIER_VERSION
    return false unless program.fetch("semantic_ir_ref").nil?

    program.fetch("contracts").all? do |contract|
      %w[kind contract_id name fragment_class symbols declarations dependency_graph oof_log].all? { |key| contract.key?(key) }
    end
  rescue KeyError
    false
  end

  def deterministic_outputs?
    first = build_outputs
    second = build_outputs
    CASES.keys.all? do |case_id|
      render_json(first.fetch(case_id).fetch(:classified)) == render_json(second.fetch(case_id).fetch(:classified))
    end
  end

  def only_contract(result)
    result.fetch(:classified).fetch("contracts").fetch(0)
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
  ClassifierPassProof.run(mode: mode)
end
