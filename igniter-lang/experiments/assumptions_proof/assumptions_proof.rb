#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang/classifier"

module AssumptionsProof
  ROOT = File.expand_path("../../..", __dir__)
  FIXTURE_DIR = File.join(__dir__, "fixtures")
  GOLDEN_DIR = File.join(__dir__, "golden")
  CLASSIFIER_VERSION = IgniterLang::Classifier::DEFAULT_VERSION

  CASES = {
    "assumption_basic" => {
      expected_contract: "ScoreInteraction",
      expected_fragment: "escape",
      expected_refs: ["homophily"],
      expected_rules: []
    },
    "epistemic_only_pure" => {
      expected_contract: "PureEpistemicScore",
      expected_fragment: "epistemic",
      expected_refs: ["calibration_prior"],
      expected_rules: []
    },
    "oof_a1_undeclared_assumption" => {
      expected_contract: "BadAssumptionUse",
      expected_fragment: "oof",
      expected_refs: ["undeclared_heuristic"],
      expected_rules: ["OOF-A1"]
    }
  }.freeze

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
      puts mode == :check_golden ? "PASS assumptions_golden_check" : "PASS assumptions_proof"
    else
      abort(mode == :check_golden ? "FAIL assumptions_golden_check" : "FAIL assumptions_proof")
    end
  end

  def build_outputs
    classifier = IgniterLang::Classifier.new(classifier_version: CLASSIFIER_VERSION)
    CASES.each_with_object({}) do |(case_id, config), outputs|
      parsed = read_json(File.join(FIXTURE_DIR, "#{case_id}.parsed_ast.json"))
      classified = classifier.classify(parsed, sample_input: {})
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
      "classifier.assumption_basic_escape" => classified_ok?(outputs, "assumption_basic"),
      "classifier.epistemic_only_fragment" => classified_ok?(outputs, "epistemic_only_pure"),
      "classifier.oof_a1_fragment" => classified_ok?(outputs, "oof_a1_undeclared_assumption"),
      "registry.assumption_basic_shape" => registry_entry?(outputs, "assumption_basic", "homophily", "heuristic"),
      "registry.epistemic_only_shape" => registry_entry?(outputs, "epistemic_only_pure", "calibration_prior", "calibrated"),
      "uses.assumption_basic_node_epistemic" => uses_decl_epistemic?(outputs, "assumption_basic", "homophily", []),
      "uses.epistemic_only_node_epistemic" => uses_decl_epistemic?(outputs, "epistemic_only_pure", "calibration_prior", []),
      "uses.oof_a1_missing_ref_recorded" => uses_decl_epistemic?(outputs, "oof_a1_undeclared_assumption", "undeclared_heuristic", ["undeclared_heuristic"]),
      "refs.assumption_basic" => assumption_refs?(outputs, "assumption_basic"),
      "refs.epistemic_only" => assumption_refs?(outputs, "epistemic_only_pure"),
      "refs.oof_a1" => assumption_refs?(outputs, "oof_a1_undeclared_assumption"),
      "oof_a1.rule_only" => rules_match?(outputs, "oof_a1_undeclared_assumption"),
      "oof_a1.message" => oof_a1_message?(outputs),
      "prop033.evidence_list_not_validated" => evidence_list_not_validated?(outputs),
      "semanticir.not_emitted" => outputs.values.all? { |result| result.fetch(:classified).fetch("semantic_ir_ref").nil? },
      "golden.classified_outputs" => Dir[File.join(GOLDEN_DIR, "*.classified.json")].length == CASES.length
    }
  end

  def build_golden_checks(outputs)
    {
      "check.golden_classified_equal" => outputs.all? do |case_id, result|
        golden_equal?(File.join(GOLDEN_DIR, "#{case_id}.classified.json"), result.fetch(:classified))
      end,
      "check.deterministic_generation" => deterministic_outputs?
    }
  end

  def classified_ok?(outputs, case_id)
    contract = only_contract(outputs.fetch(case_id))
    config = outputs.fetch(case_id).fetch(:config)
    contract.fetch("name") == config.fetch(:expected_contract) &&
      contract.fetch("fragment_class") == config.fetch(:expected_fragment)
  end

  def registry_entry?(outputs, case_id, name, kind)
    entry = outputs.fetch(case_id).fetch(:classified).fetch("assumption_registry", [])
      .find { |candidate| candidate.fetch("name") == name }
    entry&.fetch("kind") == "assumption_entry" &&
      entry.fetch("declared_in_module") == outputs.fetch(case_id).fetch(:parsed).fetch("module") &&
      entry.fetch("fields").fetch("kind") == kind
  end

  def uses_decl_epistemic?(outputs, case_id, name, missing)
    decl = only_contract(outputs.fetch(case_id)).fetch("declarations")
      .find { |candidate| candidate.fetch("kind") == "uses_assumptions" && candidate.fetch("name") == name }
    decl&.fetch("fragment_class") == "epistemic" &&
      decl.fetch("deps") == [] &&
      decl.fetch("missing_refs") == missing
  end

  def assumption_refs?(outputs, case_id)
    contract = only_contract(outputs.fetch(case_id))
    contract.fetch("assumption_refs") == outputs.fetch(case_id).fetch(:config).fetch(:expected_refs)
  end

  def rules_match?(outputs, case_id)
    contract = only_contract(outputs.fetch(case_id))
    actual = contract.fetch("oof_log").map { |entry| entry.fetch("rule") }.uniq
    actual == outputs.fetch(case_id).fetch(:config).fetch(:expected_rules)
  end

  def oof_a1_message?(outputs)
    entry = only_contract(outputs.fetch("oof_a1_undeclared_assumption")).fetch("oof_log").first
    entry.fetch("rule") == "OOF-A1" &&
      entry.fetch("node") == "uses_assumptions:undeclared_heuristic" &&
      entry.fetch("message").include?("no assumption named 'undeclared_heuristic' is declared")
  end

  def evidence_list_not_validated?(outputs)
    contract = only_contract(outputs.fetch("epistemic_only_pure"))
    contract.fetch("oof_log").empty? &&
      rules_match?(outputs, "epistemic_only_pure")
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
  AssumptionsProof.run(mode: mode)
end
