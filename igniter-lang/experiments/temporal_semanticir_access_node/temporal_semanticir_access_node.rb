#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "fileutils"
require "pathname"

require_relative "../../lib/igniter_lang/semanticir_emitter"
require_relative "../../lib/igniter_lang/typechecker"

module TemporalSemanticIRAccessNodeProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  OUT_DIR = ROOT / "igniter-lang/experiments/temporal_semanticir_access_node"
  GOLDEN_DIR = OUT_DIR / "golden"
  SUMMARY_PATH = OUT_DIR / "summary.json"
  TYPECHECKER_CLASSIFIED_DIR = ROOT / "igniter-lang/experiments/typechecker_proof/classified"

  CASES = [
    {
      "id" => "history_valid",
      "classified" => "history_valid.classified.json",
      "expected_contract" => "HistoryAxesTest",
      "expected_capability" => "history_read",
      "expected_axis" => "valid_time",
      "expected_input" => "price_history",
      "expected_access" => "price_at",
      "expected_coordinates" => { "as_of" => "as_of" },
      "expected_store_ref" => "sku/{sku}/price"
    },
    {
      "id" => "bihistory_valid",
      "classified" => "bihistory_valid.classified.json",
      "expected_contract" => "BiHistoryAxesTest",
      "expected_capability" => "bihistory_read",
      "expected_axis" => "bitemporal",
      "expected_input" => "avail_history",
      "expected_access" => "avail_at",
      "expected_coordinates" => {
        "valid_time" => "valid_time",
        "transaction_time" => "transaction_time"
      },
      "expected_store_ref" => "t/{technician_id}/avail"
    }
  ].freeze

  module_function

  def run(mode: :write)
    FileUtils.mkdir_p(GOLDEN_DIR)
    outputs = CASES.to_h do |config|
      [config.fetch("id"), emit_case(config)]
    end
    write_outputs(outputs)
    checks = build_checks(outputs)
    checks = checks.merge(golden_checks(outputs)) if mode == :check_golden
    summary = {
      "kind" => "temporal_semanticir_access_node_proof",
      "format_version" => "0.1.0",
      "track" => "temporal-semanticir-access-node-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "cases" => outputs,
      "checks" => checks,
      "manifest_assembler_questions" => manifest_assembler_questions,
      "remaining_prop_028_gaps" => remaining_prop_028_gaps
    }
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def emit_case(config)
    classified = read_json(TYPECHECKER_CLASSIFIED_DIR / config.fetch("classified"))
    typed = IgniterLang::TypeChecker.new.typecheck(classified)
    emitted = IgniterLang::SemanticIREmitter.new.emit_typed(typed)
    {
      "id" => config.fetch("id"),
      "classified_source" => (TYPECHECKER_CLASSIFIED_DIR / config.fetch("classified")).relative_path_from(ROOT).to_s,
      "typed_program" => typed,
      "semantic_ir" => emitted.fetch("semantic_ir"),
      "compilation_report" => emitted.fetch("compilation_report")
    }
  end

  def build_checks(outputs)
    CASES.each_with_object({}) do |config, checks|
      output = outputs.fetch(config.fetch("id"))
      semantic_ir = output.fetch("semantic_ir")
      report = output.fetch("compilation_report")
      contract = semantic_ir.fetch("contracts").first
      nodes = contract.fetch("nodes")
      input_node = nodes.find { |node| node.fetch("kind") == "temporal_input_node" && node.fetch("name") == config.fetch("expected_input") }
      access_node = nodes.find { |node| node.fetch("kind") == "temporal_access_node" && node.fetch("name") == config.fetch("expected_access") }
      prefix = config.fetch("id")

      checks["#{prefix}.report_ok"] = report.fetch("pass_result") == "ok"
      checks["#{prefix}.contract_fragment_temporal"] = contract.fetch("fragment_class") == "temporal"
      checks["#{prefix}.escape_boundary_capability"] = contract.fetch("escape_boundaries").any? do |boundary|
        boundary.fetch("required_caps", []).include?(config.fetch("expected_capability"))
      end
      checks["#{prefix}.temporal_input_node"] = input_node &&
        input_node.fetch("node_fragment_class") == "temporal" &&
        input_node.fetch("value_fragment_class") == "core" &&
        input_node.fetch("required_capability") == config.fetch("expected_capability") &&
        input_node.fetch("axis") == config.fetch("expected_axis") &&
        input_node.fetch("store_ref") == config.fetch("expected_store_ref")
      checks["#{prefix}.temporal_access_node"] = access_node &&
        access_node.fetch("node_fragment_class") == "temporal" &&
        access_node.fetch("value_fragment_class") == "core" &&
        access_node.fetch("required_capability") == config.fetch("expected_capability") &&
        access_node.fetch("temporal_axis") == config.fetch("expected_axis")
      checks["#{prefix}.coordinate_refs"] = access_node &&
        access_node.fetch("coordinate_refs") == config.fetch("expected_coordinates")
      checks["#{prefix}.no_runtime_cache_metadata"] = !JSON.generate(semantic_ir).include?("cache_key") &&
        !JSON.generate(semantic_ir).include?("memo")
    end
  end

  def golden_checks(outputs)
    outputs.each_with_object({}) do |(id, output), checks|
      checks["golden.#{id}.semantic_ir"] = read_json(GOLDEN_DIR / "#{id}.semantic_ir.json") == output.fetch("semantic_ir")
      checks["golden.#{id}.compilation_report"] = read_json(GOLDEN_DIR / "#{id}.compilation_report.json") == output.fetch("compilation_report")
    end
  end

  def write_outputs(outputs)
    outputs.each do |id, output|
      write_json(GOLDEN_DIR / "#{id}.semantic_ir.json", output.fetch("semantic_ir"))
      write_json(GOLDEN_DIR / "#{id}.compilation_report.json", output.fetch("compilation_report"))
    end
  end

  def manifest_assembler_questions
    [
      {
        "id" => "assembler_temporal_node_contract_file",
        "question" => "Assembler#contract_file currently assumes executable compute nodes with expr/type; should temporal_input_node and temporal_access_node be copied as capability nodes, or split into requirements plus non-compute nodes?"
      },
      {
        "id" => "manifest_fragment_vocabulary",
        "question" => "Manifest/contract fragment vocabularies currently accept core/escape/oof in older paths; should Stage 3 manifests accept temporal as a first-class fragment before RuntimeMachine temporal memoization?"
      },
      {
        "id" => "requirements_source_of_truth",
        "question" => "Should required temporal capabilities be derived from SemanticIR escape_boundaries, node.required_caps, or a separate requirements.json builder pass?"
      }
    ]
  end

  def remaining_prop_028_gaps
    [
      "Parser syntax for explicit History/BiHistory coordinate reads remains unimplemented.",
      "RuntimeMachine load/evaluate support for SemanticIR temporal_access_node remains proof-local.",
      "RuntimeMachine memoization/cache key implementation remains out of scope.",
      "OOF-TM2 ambient-time misuse is not implemented.",
      "OOF-TM7 temporal read inside CORE-required lambda/body is not implemented.",
      "OOF-TM8 production TBackend capability check remains report/fixture-backed.",
      "OOF-TM9 CORE cache key misuse is proven as a runtime-cache design bug but not enforced by RuntimeMachine."
    ]
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} temporal_semanticir_access_node"
    summary.fetch("checks").each do |name, ok|
      puts "#{name}: #{ok ? "ok" : "FAIL"}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

mode = ARGV.include?("--check-golden") ? :check_golden : :write
success = TemporalSemanticIRAccessNodeProof.run(mode: mode)
exit(success ? 0 : 1)
