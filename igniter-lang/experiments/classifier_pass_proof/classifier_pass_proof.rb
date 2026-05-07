#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang/classifier"

module ClassifierPassProof
  ROOT = File.expand_path("../../..", __dir__)
  FIXTURE_INPUT_DIR = File.expand_path("../source_to_semanticir_fixture", __dir__)
  PARSED_DIR = File.join(FIXTURE_INPUT_DIR, "golden")
  GOLDEN_DIR = File.join(__dir__, "golden")
  CLASSIFIER_VERSION = IgniterLang::Classifier::DEFAULT_VERSION

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
    },
    "stream_ingress_escape" => {
      parsed: "stream_ingress_escape.parsed_ast.json",
      expected_contract: "StreamIngressEscape",
      expected_fragment: "escape",
      expected_rules: [],
      sample_input: { "device_id" => "dev-001" }
    },
    "stream_fold_core" => {
      parsed: "stream_fold_core.parsed_ast.json",
      expected_contract: "StreamFoldCore",
      expected_fragment: "escape",
      expected_rules: [],
      sample_input: { "device_id" => "dev-001" }
    },
    "negative_stream_direct_use" => {
      parsed: "negative_stream_direct_use.parsed_ast.json",
      expected_contract: "StreamDirectUse",
      expected_fragment: "oof",
      expected_rules: ["OOF-S4"],
      sample_input: { "device_id" => "dev-001" }
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
      puts mode == :check_golden ? "PASS classifier_pass_golden_check" : "PASS classifier_pass_proof"
    else
      abort(mode == :check_golden ? "FAIL classifier_pass_golden_check" : "FAIL classifier_pass_proof")
    end
  end

  def build_outputs
    classifier = IgniterLang::Classifier.new(classifier_version: CLASSIFIER_VERSION)
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
      "classified.stream_ingress_escape" => classified_ok?(outputs, "stream_ingress_escape"),
      "classified.stream_fold_core" => classified_ok?(outputs, "stream_fold_core"),
      "core.add_propagates" => core_propagates?(outputs, "add"),
      "core.claim_evidence_propagates" => core_propagates?(outputs, "claim_evidence"),
      "core.evidence_linked_alert_propagates" => core_propagates?(outputs, "evidence_linked_alert"),
      "stream.sc1_ingress_escape" => stream_ingress_escape?(outputs),
      "stream.sc2_direct_use_oof_s4" => rules_match?(outputs, "negative_stream_direct_use"),
      "stream.sc3_fold_result_core" => stream_fold_result_core?(outputs),
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
    return false unless program.fetch("type_declarations").all? { |type| type.key?("name") && type.key?("fields") }

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

  def stream_ingress_escape?(outputs)
    contract = only_contract(outputs.fetch("stream_ingress_escape"))
    stream_decl = contract.fetch("declarations").find { |decl| decl.fetch("kind") == "stream" }
    stream_decl&.fetch("fragment_class") == "escape"
  end

  def stream_fold_result_core?(outputs)
    contract = only_contract(outputs.fetch("stream_fold_core"))
    fold_decl = contract.fetch("declarations").find { |decl| decl.fetch("kind") == "fold_stream" }
    fold_decl&.fetch("fragment_class") == "core"
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
