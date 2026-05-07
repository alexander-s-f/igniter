#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"
require_relative "../../lib/igniter_lang/typechecker"

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
    },
    "bihistory_valid" => {
      classified: "bihistory_valid.classified.json",
      expected_contract: "BiHistoryAxesTest",
      expected_status: "accepted",
      expected_rules: [],
      expected_outputs: { "avail_at" => "Option" }
    },
    "negative_bihistory_missing_vt" => {
      classified: "negative_bihistory_missing_vt.classified.json",
      expected_contract: "BiHistoryMissingVt",
      expected_status: "blocked",
      expected_rules: ["OOF-BT2"]
    },
    "negative_bihistory_missing_tt" => {
      classified: "negative_bihistory_missing_tt.classified.json",
      expected_contract: "BiHistoryMissingTt",
      expected_status: "blocked",
      expected_rules: ["OOF-BT3"]
    },
    "negative_bihistory_wrong_axis_type" => {
      classified: "negative_bihistory_wrong_axis_type.classified.json",
      expected_contract: "BiHistoryWrongAxisType",
      expected_status: "blocked",
      expected_rules: ["OOF-BT4"]
    },
    "negative_stream_escape_in_fold" => {
      classified: "negative_stream_escape_in_fold.classified.json",
      expected_contract: "StreamEscapeInFold",
      expected_status: "blocked",
      expected_rules: ["OOF-S3"]
    },
    "invariant_severity_valid" => {
      classified: "invariant_severity_valid.classified.json",
      expected_contract: "DrugOrderGate",
      expected_status: "accepted",
      expected_rules: [],
      expected_outputs: { "approved" => "Bool" }
    },
    "negative_invariant_non_bool_predicate" => {
      classified: "negative_invariant_non_bool_predicate.classified.json",
      expected_contract: "InvariantNonBoolPredicate",
      expected_status: "blocked",
      expected_rules: ["OOF-IV3"]
    },
    "negative_invariant_overridable_on_error" => {
      classified: "negative_invariant_overridable_on_error.classified.json",
      expected_contract: "InvariantOverridableOnError",
      expected_status: "blocked",
      expected_rules: ["OOF-I4"]
    }
  }.freeze

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
    typechecker = IgniterLang::TypeChecker.new
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
      "typed.bihistory_valid" => accepted_with_outputs?(outputs, "bihistory_valid"),
      "typed.accepted_no_unresolved_types" => accepted_no_unresolved_types?(outputs),
      "negative.unresolved_symbol_blocked" => blocked_with_rules?(outputs, "negative_unresolved_symbol"),
      "negative.evidence_less_alert_blocked" => blocked_with_rules?(outputs, "negative_evidence_less_alert"),
      "negative.confidence_bool_blocked" => blocked_with_rules?(outputs, "negative_confidence_bool"),
      "negative.bihistory_missing_vt" => blocked_with_rules?(outputs, "negative_bihistory_missing_vt"),
      "negative.bihistory_missing_tt" => blocked_with_rules?(outputs, "negative_bihistory_missing_tt"),
      "negative.bihistory_wrong_axis_type" => blocked_with_rules?(outputs, "negative_bihistory_wrong_axis_type"),
      "negative.stream_escape_in_fold_oof_s3" => blocked_with_rules?(outputs, "negative_stream_escape_in_fold"),
      "typed.invariant_severity_valid" => accepted_with_outputs?(outputs, "invariant_severity_valid"),
      "invariant.tinv1_output_has_warnings_from" => invariant_output_effect?(outputs, "invariant_severity_valid", "interaction_warn"),
      "negative.invariant_non_bool_predicate_oof_iv3" => blocked_with_rules?(outputs, "negative_invariant_non_bool_predicate"),
      "negative.invariant_overridable_on_error_oof_i4" => blocked_with_rules?(outputs, "negative_invariant_overridable_on_error"),
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

  # Checks that the named invariant appears in warnings_from on any output decl (TINV-4).
  def invariant_output_effect?(outputs, case_id, invariant_name)
    result = outputs.fetch(case_id)
    contract = only_contract(result)
    contract.fetch("declarations").any? do |decl|
      decl.fetch("kind") == "output" && Array(decl["warnings_from"]).include?(invariant_name)
    end
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
