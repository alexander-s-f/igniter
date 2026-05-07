#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang/assembler"
require_relative "../runtime_machine_memory_proof/compiled_program"

module IgappAssemblerProof
  ROOT = Pathname.new(File.expand_path("../..", __dir__))
  GOLDEN_DIR = ROOT / "experiments/source_to_semanticir_fixture/golden"
  OUT_DIR = ROOT / "experiments/igapp_assembler_proof/out"
  PROOF_AS_OF = RuntimeMachineMemoryProof::PROOF_AS_OF
  POSITIVE_CASES = %w[add claim_evidence evidence_linked_alert].freeze
  NEGATIVE_CASES = %w[negative_unresolved_symbol negative_evidence_less_alert negative_confidence_bool].freeze
  RUNTIME_EVAL_CASES = {
    "add" => {
      "path" => OUT_DIR / "add.igapp",
      "contract_id" => "Add",
      "inputs" => { "a" => 19, "b" => 23 },
      "output_name" => "sum",
      "expected_output" => 42
    },
    "claim_evidence" => {
      "path" => OUT_DIR / "claim_evidence.igapp",
      "contract_id" => "ClaimEvidenceBundle",
      "inputs" => {
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
      },
      "output_name" => "linked_claim_ref",
      "expected_output" => "claim/synthetic/vendor-status"
    },
    "evidence_linked_alert" => {
      "path" => OUT_DIR / "evidence_linked_alert.igapp",
      "contract_id" => "EvidenceLinkedAlertGate",
      "inputs" => {
        "alert" => {
          "signal_count" => 1,
          "claim_count" => 1,
          "valid_until" => "2026-05-06T12:00:00Z",
          "confidence_label" => "medium"
        }
      },
      "output_name" => "allowed",
      "expected_output" => true
    }
  }.freeze

  AssemblyRefused = IgniterLang::AssemblyRefused
  Assembler = IgniterLang::Assembler
  Canonical = IgniterLang::Assembler::Canonical

  module RuntimeProof
    module_function

    def load_evaluate_checkpoint_resume(config)
      path = config.fetch("path")
      program = RuntimeMachineMemoryProof::CompiledProgram.load_igapp(path)
      program.validate!
      backend = RuntimeMachineMemoryProof::MemoryTBackend.new
      machine = RuntimeMachineMemoryProof::RuntimeMachine.new(
        machine_id: "runtime-machine/igapp-assembler-proof/#{config.fetch("contract_id")}",
        session_id: "session/igapp-assembler-proof/#{config.fetch("contract_id")}",
        backend: backend
      )
      machine.boot
      load = machine.load_program(program)
      eval = machine.evaluate_program(config.fetch("contract_id"), config.fetch("inputs"), as_of: PROOF_AS_OF)
      checkpoint = machine.checkpoint(horizon: { as_of: PROOF_AS_OF, rule_version: "igapp-assembler-proof-stage1-v0" })
      resume = machine.resume(image: checkpoint.fetch(:semantic_image), requested_as_of: PROOF_AS_OF)
      schema_check = resume.fetch(:report).fetch("checks").find { |check| check.fetch("dimension") == "schema" }
      output_name = config.fetch("output_name")

      {
        "load_status" => load.fetch(:status),
        "loaded_semantic_ir_program" => !program.semantic_ir_program.nil?,
        "legacy_semantic_ir_json_present" => File.exist?(File.join(path, "semantic_ir.json")),
        "evaluate_status" => eval.fetch(:status),
        "output_name" => output_name,
        "output_value" => eval.fetch(:outputs).fetch(output_name),
        "expected_output" => config.fetch("expected_output"),
        "checkpoint_status" => checkpoint.fetch(:status),
        "compatibility_report_status" => resume.fetch(:status),
        "schema_decision" => schema_check.fetch("decision")
      }
    rescue => e
      {
        "load_status" => "blocked",
        "error" => "#{e.class}: #{e.message}"
      }
    end

    def all_cases
      RUNTIME_EVAL_CASES.transform_values { |config| load_evaluate_checkpoint_resume(config) }
    end

    def operator_rejection_cases
      {
        "legacy_add" => operator_rejected?("add"),
        "stdlib_numeric_add" => operator_rejected?("stdlib.numeric.add"),
        "unknown_stdlib_operator" => operator_rejected?("stdlib.integer.mystery")
      }
    end

    def operator_rejected?(operator)
      config = RUNTIME_EVAL_CASES.fetch("add")
      program = RuntimeMachineMemoryProof::CompiledProgram.load_igapp(config.fetch("path"))
      expression = program.contracts.fetch(config.fetch("contract_id"))
        .fetch("compute_nodes")
        .fetch(0)
        .fetch("expression")
      expression["operator"] = operator

      backend = RuntimeMachineMemoryProof::MemoryTBackend.new
      machine = RuntimeMachineMemoryProof::RuntimeMachine.new(
        machine_id: "runtime-machine/igapp-assembler-proof/operator-boundary/#{operator}",
        session_id: "session/igapp-assembler-proof/operator-boundary/#{operator}",
        backend: backend
      )
      machine.boot
      machine.load_program(program)
      machine.evaluate_program(config.fetch("contract_id"), config.fetch("inputs"), as_of: PROOF_AS_OF)
      false
    rescue ArgumentError
      true
    end
  end

  module CLI
    module_function

    def run(_argv)
      assembler = Assembler.new(golden_dir: GOLDEN_DIR, out_dir: OUT_DIR)
      FileUtils.mkdir_p(OUT_DIR)

      positive = POSITIVE_CASES.map { |case_name| assembler.assemble_case(case_name) }
      negative = NEGATIVE_CASES.map { |case_name| assembler.refuse_case(case_name) }
      deterministic = deterministic?(assembler)
      runtime = RuntimeProof.all_cases
      operator_rejections = RuntimeProof.operator_rejection_cases
      checks = checks(positive, negative, deterministic, runtime, operator_rejections)
      summary = {
        "proof" => "igapp-assembler-proof-stage1-v0",
        "status" => checks.all? { |check| check.fetch("ok") } ? "PASS" : "FAIL",
        "positive" => positive,
        "negative" => negative,
        "runtime" => runtime,
        "runtime_operator_rejections" => operator_rejections,
        "deterministic_output" => deterministic,
        "checks" => checks
      }
      File.write(OUT_DIR / "result_summary.json", Canonical.json(summary))
      print_summary(summary)
      summary.fetch("status") == "PASS"
    end

    def deterministic?(assembler)
      before = directory_hashes(OUT_DIR)
      POSITIVE_CASES.each { |case_name| assembler.assemble_case(case_name) }
      after = directory_hashes(OUT_DIR)
      before == after
    end

    def directory_hashes(dir)
      return {} unless dir.exist?

      dir.find.select(&:file?).reject { |path| path.basename.to_s == "result_summary.json" }.to_h do |path|
        [path.relative_path_from(dir).to_s, Digest::SHA256.hexdigest(File.read(path))]
      end
    end

    def checks(positive, negative, deterministic, runtime, operator_rejections)
      [
        check("assembler.positive.add", positive.any? { |item| item.fetch("case") == "add" && item.fetch("status") == "assembled" }),
        check("assembler.positive.claim_evidence", positive.any? { |item| item.fetch("case") == "claim_evidence" && item.fetch("status") == "assembled" }),
        check("assembler.positive.evidence_linked_alert", positive.any? { |item| item.fetch("case") == "evidence_linked_alert" && item.fetch("status") == "assembled" }),
        check("assembler.negative.unresolved_symbol_refused", refused?(negative, "negative_unresolved_symbol")),
        check("assembler.negative.evidence_less_alert_refused", refused?(negative, "negative_evidence_less_alert")),
        check("assembler.negative.confidence_bool_refused", refused?(negative, "negative_confidence_bool")),
        check("assembler.deterministic_output", deterministic),
        check("assembler.no_legacy_semantic_ir_json", positive.all? { |item| !item.fetch("files").include?("semantic_ir.json") }),
        check("runtime.load_direct_prop0191", runtime.values.all? { |result| direct_prop0191_loaded?(result) }),
        check("runtime.load_assembled_add", runtime_loaded?(runtime, "add")),
        check("runtime.evaluate_assembled_add", runtime_output?(runtime, "add")),
        check("runtime.evaluate_assembled_claim_evidence", runtime_output?(runtime, "claim_evidence")),
        check("runtime.evaluate_assembled_evidence_linked_alert", runtime_output?(runtime, "evidence_linked_alert")),
        check("runtime.compatibility_report_trusted", runtime.values.all? { |result| result.fetch("compatibility_report_status", nil) == "trusted" }),
        check("runtime.rejects_legacy_add", operator_rejections.fetch("legacy_add") == true),
        check("runtime.rejects_stdlib_numeric_add", operator_rejections.fetch("stdlib_numeric_add") == true),
        check("runtime.rejects_unknown_stdlib_operator", operator_rejections.fetch("unknown_stdlib_operator") == true)
      ]
    end

    def direct_prop0191_loaded?(result)
      result.fetch("loaded_semantic_ir_program", false) == true &&
        result.fetch("legacy_semantic_ir_json_present", true) == false
    end

    def runtime_loaded?(runtime, case_id)
      runtime.fetch(case_id).fetch("load_status") == "loaded"
    end

    def runtime_output?(runtime, case_id)
      result = runtime.fetch(case_id)
      result.fetch("evaluate_status", nil) == "ok" &&
        result.fetch("output_value", :missing) == result.fetch("expected_output", :expected_missing)
    end

    def refused?(negative, case_name)
      negative.any? do |item|
        item.fetch("case") == case_name &&
          item.fetch("status") == "refused" &&
          item.fetch("wrote_igapp") == false
      end
    end

    def check(name, ok)
      { "name" => name, "ok" => ok }
    end

    def print_summary(summary)
      puts "#{summary.fetch("status")} igapp_assembler_proof"
      summary.fetch("checks").each do |check|
        puts "#{check.fetch("name")}: #{check.fetch("ok") ? "ok" : "FAIL"}"
      end
      summary.fetch("runtime").each do |case_id, result|
        puts "runtime.#{case_id}.load_status: #{result.fetch("load_status", "missing")}"
        puts "runtime.#{case_id}.output_value: #{result.fetch("output_value", "missing")}"
        puts "runtime.#{case_id}.compatibility_report_status: #{result.fetch("compatibility_report_status", "not_available")}"
      end
      puts "out: #{OUT_DIR.relative_path_from(ROOT)}"
    end
  end
end

if $PROGRAM_NAME == __FILE__
  success = IgappAssemblerProof::CLI.run(ARGV)
  exit(success ? 0 : 1)
end
