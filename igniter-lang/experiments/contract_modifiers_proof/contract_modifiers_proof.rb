#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang/parser"
require_relative "../../lib/igniter_lang/classifier"
require_relative "../../lib/igniter_lang/typechecker"
require_relative "../../lib/igniter_lang/semanticir_emitter"

module ContractModifiersProof
  ROOT       = File.expand_path("../../..", __dir__)
  FIXTURE_DIR = File.join(__dir__, "fixtures")
  GOLDEN_DIR  = File.join(__dir__, "golden")

  POSITIVE_CASES = {
    "pure_contract_implicit" => {
      source: "pure_contract_implicit.ig",
      expected_contracts: [{ name: "ScoreRisk", modifier: "pure", fragment_class: "core" }],
      sample_input: { "contradiction_count" => 3, "corroboration_count" => 1 }
    },
    "pure_contract_explicit" => {
      source: "pure_contract_explicit.ig",
      expected_contracts: [{ name: "ScoreRisk", modifier: "pure", fragment_class: "core" }],
      sample_input: { "contradiction_count" => 3, "corroboration_count" => 1 }
    },
    "observed_contract_basic" => {
      source: "observed_contract_basic.ig",
      expected_contracts: [{ name: "ReadSensor", modifier: "observed", fragment_class: "escape" }],
      sample_input: { "sensor_id" => "s-001" }
    },
    "modifier_variants" => {
      source: "modifier_variants.ig",
      expected_contracts: [
        { name: "NotifyUser",      modifier: "effect",      fragment_class: "escape" },
        { name: "ApproveExpense",  modifier: "privileged",  fragment_class: "escape" },
        { name: "ArchiveRecord",   modifier: "irreversible", fragment_class: "escape" }
      ],
      sample_input: { "user_id" => "u-001", "body" => "hi", "expense_id" => "e-001",
                      "amount" => 100, "record_id" => "r-001" }
    },
    "observed_temporal_precedence" => {
      json_source: "observed_temporal_precedence.parsed_ast.json",
      expected_contracts: [{ name: "ReadHistory", modifier: "observed", fragment_class: "temporal" }],
      sample_input: { "sku_id" => "sku-001", "as_of" => "2026-01-01T00:00:00Z" }
    }
  }.freeze

  NEGATIVE_CASES = {
    "oof_m1_pure_with_escape" => {
      source: "oof_m1_pure_with_escape.ig",
      expected_oof_code: "OOF-M1",
      expected_contract: "BrokenPure",
      sample_input: { "sensor_id" => "s-001" }
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
      puts mode == :check_golden ? "PASS contract_modifiers_proof_golden_check" : "PASS contract_modifiers_proof"
    else
      abort(mode == :check_golden ? "FAIL contract_modifiers_proof_golden_check" : "FAIL contract_modifiers_proof")
    end
  end

  def build_outputs
    classifier = IgniterLang::Classifier.new
    typechecker = IgniterLang::TypeChecker.new
    emitter = IgniterLang::SemanticIREmitter.new
    outputs = {}

    (POSITIVE_CASES.merge(NEGATIVE_CASES)).each do |case_id, config|
      parsed = if config[:json_source]
                 JSON.parse(File.read(File.join(FIXTURE_DIR, config.fetch(:json_source))))
               else
                 source_path = File.join(FIXTURE_DIR, config.fetch(:source))
                 source = File.read(source_path)
                 IgniterLang::ParsedProgram.parse(source, source_path: source_path).to_h
               end
      sample_input = config.fetch(:sample_input)
      classified = classifier.classify(parsed, sample_input: sample_input)
      typed = typechecker.typecheck(classified)
      semantic_result = emitter.emit_typed(typed)
      outputs[case_id] = {
        parsed: parsed,
        classified: classified,
        typed: typed,
        semantic_ir: semantic_result.fetch("semantic_ir"),
        compilation_report: semantic_result.fetch("compilation_report"),
        config: config
      }
    end

    outputs
  end

  def write_outputs(outputs)
    outputs.each do |case_id, result|
      write_json(File.join(GOLDEN_DIR, "#{case_id}.parsed.json"),      result.fetch(:parsed))
      write_json(File.join(GOLDEN_DIR, "#{case_id}.classified.json"),  result.fetch(:classified))
      write_json(File.join(GOLDEN_DIR, "#{case_id}.typed.json"),       result.fetch(:typed))
      if result.fetch(:semantic_ir)
        write_json(File.join(GOLDEN_DIR, "#{case_id}.semantic_ir.json"), result.fetch(:semantic_ir))
      else
        FileUtils.rm_f(File.join(GOLDEN_DIR, "#{case_id}.semantic_ir.json"))
      end
    end
  end

  def build_checks(outputs)
    checks = {}

    checks["parser.implicit_pure"]  = parser_modifier_ok?(outputs, "pure_contract_implicit",  "pure")
    checks["parser.explicit_pure"]  = parser_modifier_ok?(outputs, "pure_contract_explicit",  "pure")
    checks["parser.observed"]       = parser_modifier_ok?(outputs, "observed_contract_basic", "observed")
    checks["parser.effect_privileged_irreversible"] = parser_variants_ok?(outputs)

    checks["classifier.modifier_mapping.pure_implicit"]  = classifier_modifier_ok?(outputs, "pure_contract_implicit",  "pure",        "core")
    checks["classifier.modifier_mapping.pure_explicit"]  = classifier_modifier_ok?(outputs, "pure_contract_explicit",  "pure",        "core")
    checks["classifier.modifier_mapping.observed"]       = classifier_modifier_ok?(outputs, "observed_contract_basic", "observed",    "escape")
    checks["classifier.modifier_mapping.variants"]       = classifier_variants_ok?(outputs)

    checks["parser.observed_temporal"]                     = parser_modifier_ok?(outputs, "observed_temporal_precedence", "observed")
    checks["classifier.temporal_precedence_over_modifier"] = classifier_modifier_ok?(outputs, "observed_temporal_precedence", "observed", "temporal")
    checks["semanticir.modifier_field.observed_temporal"]  = semanticir_modifier_ok?(outputs, "observed_temporal_precedence", "observed", "temporal")

    checks["classifier.pure_normalization_equal"] = pure_normalization_equal?(outputs)

    checks["typechecker.oof_m1_pure_escape"] = oof_m1_fires?(outputs)
    checks["typechecker.positive_accepted"]  = positives_accepted?(outputs)

    checks["semanticir.modifier_field.pure_implicit"]  = semanticir_modifier_ok?(outputs, "pure_contract_implicit",  "pure",        "core")
    checks["semanticir.modifier_field.pure_explicit"]  = semanticir_modifier_ok?(outputs, "pure_contract_explicit",  "pure",        "core")
    checks["semanticir.modifier_field.observed"]       = semanticir_modifier_ok?(outputs, "observed_contract_basic", "observed",    "escape")
    checks["semanticir.modifier_field.variants"]       = semanticir_variants_ok?(outputs)
    checks["semanticir.oof_m1_no_semantic_ir"]         = oof_m1_no_semanticir?(outputs)

    checks["proof.modifier_always_present"] = modifier_always_present_in_semantic_ir?(outputs)

    checks
  end

  def build_golden_checks(outputs)
    {
      "check.golden_parsed_equal"     => goldens_equal?(outputs, :parsed,      ".parsed.json"),
      "check.golden_classified_equal" => goldens_equal?(outputs, :classified,  ".classified.json"),
      "check.golden_typed_equal"      => goldens_equal?(outputs, :typed,       ".typed.json"),
      "check.golden_semanticir_equal" => golden_semanticir_equal?(outputs),
      "check.deterministic_generation" => deterministic_outputs?
    }
  end

  # --- check helpers ---

  def parser_modifier_ok?(outputs, case_id, expected_modifier)
    contract = first_contract_parsed(outputs, case_id)
    contract&.fetch("modifier") == expected_modifier
  end

  def parser_variants_ok?(outputs)
    contracts = outputs.fetch("modifier_variants").fetch(:parsed).fetch("contracts")
    contracts.map { |c| c.fetch("modifier") } == %w[effect privileged irreversible]
  end

  def classifier_modifier_ok?(outputs, case_id, expected_modifier, expected_fragment)
    contract = first_contract_classified(outputs, case_id)
    contract&.fetch("modifier") == expected_modifier &&
      contract.fetch("fragment_class") == expected_fragment
  end

  def classifier_variants_ok?(outputs)
    contracts = outputs.fetch("modifier_variants").fetch(:classified).fetch("contracts")
    contracts.all? { |c| c.fetch("fragment_class") == "escape" } &&
      contracts.map { |c| c.fetch("modifier") } == %w[effect privileged irreversible]
  end

  def pure_normalization_equal?(outputs)
    implicit = first_contract_classified(outputs, "pure_contract_implicit")
    explicit = first_contract_classified(outputs, "pure_contract_explicit")
    implicit&.fetch("modifier") == "pure" &&
      explicit&.fetch("modifier") == "pure" &&
      implicit.fetch("fragment_class") == explicit.fetch("fragment_class")
  end

  def oof_m1_fires?(outputs)
    classified = outputs.fetch("oof_m1_pure_with_escape").fetch(:classified)
    oof_log = classified.fetch("contracts").first.fetch("oof_log")
    oof_log.any? { |entry| entry.fetch("rule") == "OOF-M1" } &&
      classified.fetch("contracts").first.fetch("fragment_class") == "oof"
  end

  def positives_accepted?(outputs)
    POSITIVE_CASES.keys.all? do |case_id|
      typed = outputs.fetch(case_id).fetch(:typed)
      typed.fetch("contracts").all? { |c| c.fetch("status") == "accepted" }
    end
  end

  def semanticir_modifier_ok?(outputs, case_id, expected_modifier, expected_fragment)
    semantic_ir = outputs.fetch(case_id).fetch(:semantic_ir)
    return false unless semantic_ir
    contract = semantic_ir.fetch("contracts").first
    contract.fetch("modifier") == expected_modifier &&
      contract.fetch("fragment_class") == expected_fragment
  end

  def semanticir_variants_ok?(outputs)
    semantic_ir = outputs.fetch("modifier_variants").fetch(:semantic_ir)
    return false unless semantic_ir
    contracts = semantic_ir.fetch("contracts")
    contracts.map { |c| c.fetch("modifier") } == %w[effect privileged irreversible] &&
      contracts.all? { |c| c.fetch("fragment_class") == "escape" }
  end

  def oof_m1_no_semanticir?(outputs)
    outputs.fetch("oof_m1_pure_with_escape").fetch(:semantic_ir).nil?
  end

  def modifier_always_present_in_semantic_ir?(outputs)
    POSITIVE_CASES.keys.all? do |case_id|
      semantic_ir = outputs.fetch(case_id).fetch(:semantic_ir)
      next false unless semantic_ir
      semantic_ir.fetch("contracts").all? { |c| c.key?("modifier") }
    end
  end

  # --- golden helpers ---

  def goldens_equal?(outputs, key, suffix)
    (POSITIVE_CASES.keys + NEGATIVE_CASES.keys).all? do |case_id|
      golden_path = File.join(GOLDEN_DIR, "#{case_id}#{suffix}")
      golden_equal?(golden_path, outputs.fetch(case_id).fetch(key))
    end
  end

  def golden_semanticir_equal?(outputs)
    POSITIVE_CASES.keys.all? do |case_id|
      golden_path = File.join(GOLDEN_DIR, "#{case_id}.semantic_ir.json")
      golden_equal?(golden_path, outputs.fetch(case_id).fetch(:semantic_ir))
    end && oof_m1_no_semanticir?(outputs)
  end

  def golden_equal?(path, expected)
    return false unless File.exist?(path)
    JSON.parse(File.read(path)) == expected
  end

  def deterministic_outputs?
    first = build_outputs
    second = build_outputs
    (POSITIVE_CASES.keys + NEGATIVE_CASES.keys).all? do |case_id|
      render_json(first.fetch(case_id).fetch(:classified)) == render_json(second.fetch(case_id).fetch(:classified))
    end
  end

  # --- pipeline helpers ---

  def first_contract_parsed(outputs, case_id)
    outputs.fetch(case_id).fetch(:parsed).fetch("contracts").first
  end

  def first_contract_classified(outputs, case_id)
    outputs.fetch(case_id).fetch(:classified).fetch("contracts").first
  end

  # --- I/O ---

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
  ContractModifiersProof.run(mode: mode)
end
