#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "pathname"

require_relative "diagnostics"
require_relative "../../lib/igniter_lang/compiler_orchestrator"
require_relative "../source_to_semanticir_fixture/source_to_semanticir_fixture"
require_relative "../runtime_machine_memory_proof/compiled_program"

module ProductionCompilerCLI
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  PROOF_AS_OF = RuntimeMachineMemoryProof::PROOF_AS_OF

  class Compiler
    def compile(source_path:, out_path:)
      orchestration = IgniterLang::CompilerOrchestrator.new.compile(
        source_path: source_path,
        out_path: out_path,
        sample_input_resolver: method(:sample_input_for),
        runtime_smoke: ->(out_path:, sample_input:) { RuntimeSmoke.run(out_path: out_path, sample_input: sample_input) }
      )
      orchestration.fetch("result")
    end

    private

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
      IgniterLang::CompilerResult.public_result(result)
    end
  end
end

if $PROGRAM_NAME == __FILE__
  success = ProductionCompilerCLI::CLI.run(ARGV)
  exit(success ? 0 : 1)
end
