#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"

require_relative "diagnostics"
require_relative "../parser/igniter_lang_parser"
require_relative "../source_to_semanticir_fixture/source_to_semanticir_fixture"
require_relative "../igapp_assembler_proof/igapp_assembler_proof"

module ProductionCompilerCLI
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  PROOF_AS_OF = RuntimeMachineMemoryProof::PROOF_AS_OF
  FORMAT_VERSION = SourceToSemanticIRFixture::FORMAT_VERSION

  module JSONIO
    module_function

    def write(path, value)
      FileUtils.mkdir_p(Pathname.new(path).dirname)
      File.write(path, "#{JSON.pretty_generate(value)}\n")
    end
  end

  class Compiler
    def compile(source_path:, out_path:)
      source = File.read(source_path)
      parsed = IgniterLang::ParsedProgram.parse(source, source_path: source_path.to_s).to_h
      return parse_failure(parsed, source_path, out_path) unless parsed.fetch("parse_errors").empty?

      sample_input = sample_input_for(parsed)
      compilation = SourceToSemanticIRFixture::TinyCompiler.new.compile(parsed, sample_input: sample_input)
      report = enrich_report(compilation.fetch("compilation_report"), parsed)
      semantic_ir = compilation.fetch("semantic_ir")

      return refusal(report, source_path, out_path) unless report.fetch("pass_result") == "ok"

      assembled = IgappAssemblerProof::Assembler.new.assemble_artifacts(
        case_name: case_name_for(source_path, parsed),
        report: report,
        semantic_ir: semantic_ir,
        target_dir: out_path
      )
      smoke = RuntimeSmoke.run(out_path: out_path, sample_input: sample_input)

      unless smoke.fetch("trusted")
        smoke_report = smoke_failure_report(report, smoke, source_path)
        return refusal(smoke_report, source_path, out_path, status: "runtime_smoke_failed")
      end

      {
        "kind" => "compiler_result",
        "format_version" => FORMAT_VERSION,
        "status" => "ok",
        "program_id" => semantic_ir.fetch("program_id"),
        "source_path" => source_path.to_s,
        "source_hash" => report.fetch("source_hash"),
        "grammar_version" => report.fetch("grammar_version"),
        "stages" => report_stages(report, assemble: "ok"),
        "igapp_path" => out_path.to_s,
        "compilation_report_ref" => report.fetch("program_id"),
        "semantic_ir_ref" => report.fetch("semantic_ir_ref"),
        "contracts" => assembled.fetch("contracts"),
        "diagnostics" => [],
        "warnings" => Diagnostics.warnings(report.fetch("diagnostics", [])),
        "runtime_smoke" => smoke,
        "report" => report
      }
    rescue IgappAssemblerProof::AssemblyRefused => e
      report = internal_error_report(source_path, "assembler_refused", e)
      refusal(report, source_path, out_path, status: "assembler_refused")
    rescue => e
      report = internal_error_report(source_path, "compiler_error", e)
      refusal(report, source_path, out_path, status: "error")
    end

    private

    def parse_failure(parsed, source_path, out_path)
      report = {
        "kind" => "compilation_report",
        "format_version" => FORMAT_VERSION,
        "program_id" => "compilation_report/parse_error",
        "grammar_version" => parsed.fetch("grammar_version"),
        "source_hash" => parsed.fetch("source_hash"),
        "source_path" => source_path.to_s,
        "pass_result" => "error",
        "stages" => {
          "parse" => "error",
          "classify" => "skipped",
          "typecheck" => "skipped",
          "emit" => "skipped"
        },
        "diagnostics" => Diagnostics.from_parse_errors(parsed.fetch("parse_errors")),
        "semantic_ir_ref" => nil
      }
      refusal(report, source_path, out_path, status: "error")
    end

    def refusal(report, source_path, out_path, status: "oof")
      report_path = report_path_for(out_path)
      JSONIO.write(report_path, report)
      diagnostics = report.fetch("diagnostics", [])
      {
        "kind" => "compiler_result",
        "format_version" => FORMAT_VERSION,
        "status" => status,
        "program_id" => report.fetch("semantic_ir_ref", nil),
        "source_path" => source_path.to_s,
        "source_hash" => report.fetch("source_hash", nil),
        "grammar_version" => report.fetch("grammar_version", nil),
        "stages" => report_stages(report, assemble: "skipped"),
        "igapp_path" => nil,
        "contracts" => [],
        "compilation_report_path" => report_path.to_s,
        "diagnostics" => Diagnostics.errors(diagnostics),
        "warnings" => Diagnostics.warnings(diagnostics),
        "report" => report
      }
    end

    def report_path_for(out_path)
      raw = out_path.to_s
      if raw.end_with?(".igapp")
        Pathname.new(raw.delete_suffix(".igapp") + ".compilation_report.json")
      else
        Pathname.new("#{raw}.compilation_report.json")
      end
    end

    def sample_input_for(parsed)
      contract = parsed.fetch("contracts").fetch(0, {})
      case contract.fetch("name", nil)
      when "Add"
        { "a" => 2, "b" => 3 }
      when "BadUnresolvedSymbol"
        { "a" => 1 }
      when "ClaimEvidenceBundle"
        SourceToSemanticIRFixture::CASES.fetch("claim_evidence").fetch(:sample_input)
      when "EvidenceLinkedAlertGate"
        SourceToSemanticIRFixture::CASES.fetch("evidence_linked_alert").fetch(:sample_input)
      when "BadEvidenceLessAlertGate"
        SourceToSemanticIRFixture::CASES.fetch("negative_evidence_less_alert").fetch(:sample_input)
      when "BadConfidenceBool"
        SourceToSemanticIRFixture::CASES.fetch("negative_confidence_bool").fetch(:sample_input)
      else
        default_sample_input(contract)
      end
    end

    def default_sample_input(contract)
      contract.fetch("body", []).each_with_object({}) do |node, inputs|
        next unless node.fetch("kind") == "input"

        inputs[node.fetch("name")] = sample_value_for(node.fetch("type_annotation"))
      end
    end

    def sample_value_for(type_annotation)
      type_name = if type_annotation.is_a?(Hash)
                    type_annotation.fetch("name", "Unknown")
                  else
                    type_annotation.to_s
                  end
      case type_name
      when "Integer" then 1
      when "Float" then 1.0
      when "Bool" then true
      when "String" then "synthetic"
      else {}
      end
    end

    def case_name_for(source_path, parsed)
      basename = File.basename(source_path.to_s, ".ig")
      return basename unless basename.empty?

      parsed.fetch("contracts").fetch(0).fetch("name").downcase
    end

    def smoke_failure_report(report, smoke, source_path)
      report.merge(
        "pass_result" => "error",
        "source_path" => source_path.to_s,
        "diagnostics" => report.fetch("diagnostics", []) + Diagnostics.from_runtime_smoke(smoke)
      )
    end

    def internal_error_report(source_path, rule, error)
      {
        "kind" => "compilation_report",
        "format_version" => FORMAT_VERSION,
        "program_id" => "compilation_report/#{rule}",
        "grammar_version" => "unknown",
        "source_hash" => nil,
        "source_path" => source_path.to_s,
        "pass_result" => "error",
        "stages" => {
          "parse" => "unknown",
          "classify" => "unknown",
          "typecheck" => "unknown",
          "emit" => "unknown"
        },
        "diagnostics" => if rule == "assembler_refused"
                           Diagnostics.from_assembler_refusal(error)
                         else
                           Diagnostics.enrich(
                             [
                               {
                                 "rule" => rule,
                                 "severity" => "error",
                                 "message" => "#{error.class}: #{error.message}"
                               }
                             ],
                             category: "emitter_error"
                           )
                         end,
        "semantic_ir_ref" => nil
      }
    end

    def enrich_report(report, parsed)
      contract_name = parsed.fetch("contracts", []).fetch(0, {}).fetch("name", nil)
      category = diagnostic_category_for(report)
      report.merge(
        "diagnostics" => Diagnostics.enrich(
          report.fetch("diagnostics", []),
          category: category,
          contract: contract_name
        )
      )
    end

    def diagnostic_category_for(report)
      stages = report.fetch("stages", {})
      return "typechecker_oof" if stages.fetch("typecheck", nil) == "oof"
      return "emitter_error" if stages.fetch("emit", nil) == "error"

      "classifier_oof"
    end

    def report_stages(report, assemble:)
      report.fetch("stages").merge("assemble" => assemble)
    end
  end

  module RuntimeSmoke
    module_function

    def run(out_path:, sample_input:)
      program = RuntimeMachineMemoryProof::CompiledProgram.load_igapp(out_path)
      program.validate!
      contract_id = program.contracts.keys.fetch(0)
      backend = RuntimeMachineMemoryProof::MemoryTBackend.new
      machine = RuntimeMachineMemoryProof::RuntimeMachine.new(
        machine_id: "runtime-machine/production-compiler-cli",
        session_id: "session/production-compiler-cli",
        backend: backend
      )
      machine.boot
      load = machine.load_program(program)
      evaluation = machine.evaluate_program(contract_id, eval_input_for(contract_id, sample_input), as_of: PROOF_AS_OF)
      checkpoint = machine.checkpoint(horizon: { as_of: PROOF_AS_OF, rule_version: "production-compiler-cli-wrapper-v0" })
      resume = machine.resume(image: checkpoint.fetch(:semantic_image), requested_as_of: PROOF_AS_OF)

      {
        "load_status" => load.fetch(:status),
        "contract_id" => contract_id,
        "evaluate_status" => evaluation.fetch(:status),
        "outputs" => evaluation.fetch(:outputs),
        "compatibility_report_status" => resume.fetch(:status),
        "trusted" => load.fetch(:status) == "loaded" &&
          evaluation.fetch(:status) == "ok" &&
          resume.fetch(:status) == "trusted"
      }
    rescue => e
      {
        "load_status" => "blocked",
        "error" => "#{e.class}: #{e.message}",
        "trusted" => false
      }
    end

    def eval_input_for(contract_id, sample_input)
      return { "a" => 19, "b" => 23 } if contract_id == "Add"

      sample_input
    end
  end

  module CLI
    module_function

    def run(argv)
      command = argv.shift
      unless command == "compile"
        warn "Usage: igniter-lang compile SOURCE --out OUT.igapp"
        return false
      end

      source_path, out_path = parse_compile_args(argv)
      result = Compiler.new.compile(source_path: source_path, out_path: out_path)
      puts JSON.pretty_generate(public_result(result))
      result.fetch("status") == "ok"
    rescue ArgumentError => e
      warn e.message
      false
    end

    def parse_compile_args(argv)
      source = argv.shift
      raise ArgumentError, "Usage: igniter-lang compile SOURCE --out OUT.igapp" unless source

      out_flag = argv.shift
      out = argv.shift
      raise ArgumentError, "Usage: igniter-lang compile SOURCE --out OUT.igapp" unless out_flag == "--out" && out

      [Pathname.new(source), Pathname.new(out)]
    end

    def public_result(result)
      result.reject { |key, _value| key == "report" }
    end
  end
end

if $PROGRAM_NAME == __FILE__
  success = ProductionCompilerCLI::CLI.run(ARGV)
  exit(success ? 0 : 1)
end
