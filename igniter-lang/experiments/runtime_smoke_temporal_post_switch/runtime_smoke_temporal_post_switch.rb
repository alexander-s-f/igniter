#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang"
require_relative "../../lib/igniter_lang/runtime_smoke"
require_relative "../runtime_machine_memory_proof/compiled_program"

module RuntimeSmokeTemporalPostSwitch
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = Pathname.new("/private/tmp/igniter_lang_runtime_smoke_temporal_post_switch")
  SUMMARY_PATH = LANG_ROOT / "experiments/runtime_smoke_temporal_post_switch/runtime_smoke_temporal_post_switch_summary.json"
  AS_OF = "2026-05-08T00:00:00Z"

  CORE_SOURCE = LANG_ROOT / "experiments/source_to_semanticir_fixture/add.ig"
  TEMPORAL_SOURCE = LANG_ROOT / "experiments/typed_emission_main_path_parity/sparkcrm_bihistory_source.ig"

  class GuardedTemporalRuntime
    def initialize(temporal_runtime_supported: false)
      @temporal_runtime_supported = temporal_runtime_supported
      @program = nil
      @metadata = nil
    end

    def load_for_inspection(path)
      program = RuntimeMachineMemoryProof::CompiledProgram.load_igapp(path)
      program.validate!
      metadata = read_json(Pathname.new(path) / "compatibility_metadata.json")
      temporal_contract_ids = temporal_contracts(program).map { |contract| contract.fetch("contract_id") }
      return load_refusal("not_temporal", "proof expected a TEMPORAL bundle", program.program_id) if temporal_contract_ids.empty?

      @program = program
      @metadata = metadata
      {
        "kind" => "runtime_load_result",
        "status" => "loaded",
        "mode" => "inspection_only",
        "program_id" => program.program_id,
        "temporal_contracts" => temporal_contract_ids,
        "runtime_execution" => metadata.fetch("runtime_execution", {})
      }
    rescue RuntimeMachineMemoryProof::ValidationError, JSON::ParserError, KeyError, ArgumentError => e
      load_refusal("artifact_validation", "#{e.class}: #{e.message}", nil)
    end

    def evaluate(contract_id, inputs:, as_of:)
      _inputs = inputs
      return evaluation_refusal("runtime.no_program", "no program loaded", contract_id, as_of, {}) unless @program

      contract = @program.contracts.fetch(contract_id)
      required_capabilities = temporal_required_capabilities(contract)
      guard = @metadata.fetch("runtime_execution", {})
      return unsupported_refusal(contract_id, as_of, required_capabilities, guard) unless @temporal_runtime_supported

      evaluation_refusal(
        "runtime.temporal_execution_not_implemented",
        "temporal executor/TBackend remains out of scope for this proof",
        contract_id,
        as_of,
        { "required_capabilities" => required_capabilities }
      )
    rescue KeyError => e
      evaluation_refusal("runtime.contract_missing", e.message, contract_id, as_of, {})
    end

    private

    def temporal_contracts(program)
      program.contracts.values.select { |contract| contract.fetch("fragment_class", nil) == "temporal" }
    end

    def temporal_required_capabilities(contract)
      (
        contract.fetch("escape_set", []).flat_map { |boundary| boundary.fetch("required_caps", []) } +
          contract.fetch("temporal_nodes", []).flat_map { |node| node.fetch("required_caps", []) }
      ).uniq.sort
    end

    def unsupported_refusal(contract_id, as_of, required_capabilities, guard)
      evaluation_refusal(
        guard.dig("evaluate", "reason_code") || "runtime.temporal_execution_unsupported",
        "temporal runtime execution is not supported by this RuntimeMachine",
        contract_id,
        as_of,
        {
          "guard_policy" => guard.fetch("guard_policy", nil),
          "guard_at" => guard.fetch("guard_at", nil),
          "required_capabilities" => required_capabilities
        }
      )
    end

    def load_refusal(gate, reason, program_id)
      {
        "kind" => "load_refusal",
        "status" => "refused",
        "gate" => gate,
        "reason" => reason,
        "program_id" => program_id
      }
    end

    def evaluation_refusal(reason_code, message, contract_id, as_of, context)
      {
        "kind" => "evaluation_refusal",
        "status" => "blocked",
        "guard_at" => "evaluate",
        "reason_code" => reason_code,
        "message" => message,
        "contract_id" => contract_id,
        "as_of" => as_of,
        "context" => context
      }
    end

    def read_json(path)
      JSON.parse(File.read(path))
    end
  end

  module_function

  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)
    FileUtils.mkdir_p(SUMMARY_PATH.dirname)

    core = core_smoke
    temporal = temporal_smoke
    checks = checks(core, temporal)
    summary = {
      "kind" => "runtime_smoke_temporal_post_switch",
      "format_version" => "0.1.0",
      "track" => "runtime-smoke-temporal-post-switch-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "compiler_path" => "Parser -> Classifier -> TypeChecker -> SemanticIREmitter.emit_typed -> Assembler",
      "scope" => {
        "temporal_executor_implemented" => false,
        "tbackend_binding_implemented" => false,
        "production_cache_implemented" => false
      },
      "core" => core,
      "temporal" => temporal,
      "checks" => checks
    }
    write_summary(summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def core_smoke
    out_path = OUT_DIR / "core_add.igapp"
    compile = IgniterLang.compile(
      source_path: CORE_SOURCE,
      out_path: out_path,
      sample_input: { "a" => 2, "b" => 3 }
    )
    runtime = IgniterLang::RuntimeSmoke.run(out_path: out_path, sample_input: { "a" => 2, "b" => 3 }, as_of: AS_OF)
    {
      "source_path" => CORE_SOURCE.relative_path_from(ROOT).to_s,
      "igapp_path" => out_path.to_s,
      "compile_status" => compile.fetch("status"),
      "pass_result" => compile.fetch("compilation_report").fetch("pass_result"),
      "runtime_smoke" => runtime
    }
  end

  def temporal_smoke
    out_path = OUT_DIR / "temporal_bihistory.igapp"
    compile = IgniterLang.compile(
      source_path: TEMPORAL_SOURCE,
      out_path: out_path,
      sample_input: {
        "technician_id" => "tech-17",
        "valid_time" => "2026-05-07T10:00:00Z",
        "transaction_time" => "2026-05-08T09:15:00Z"
      }
    )
    runtime = GuardedTemporalRuntime.new(temporal_runtime_supported: false)
    load = runtime.load_for_inspection(out_path)
    contract_id = load.fetch("temporal_contracts", []).first
    evaluation = runtime.evaluate(contract_id, inputs: {}, as_of: AS_OF)
    {
      "source_path" => TEMPORAL_SOURCE.relative_path_from(ROOT).to_s,
      "igapp_path" => out_path.to_s,
      "compile_status" => compile.fetch("status"),
      "pass_result" => compile.fetch("compilation_report").fetch("pass_result"),
      "load_for_inspection" => load,
      "evaluate_without_executor" => evaluation
    }
  end

  def checks(core, temporal)
    {
      "core.compile_ok" => core.fetch("compile_status") == "ok" && core.fetch("pass_result") == "ok",
      "core.runtime_loads_and_evaluates" => core.dig("runtime_smoke", "trusted") == true &&
        core.dig("runtime_smoke", "load_status") == "loaded" &&
        core.dig("runtime_smoke", "evaluate_status") == "ok" &&
        core.dig("runtime_smoke", "outputs", "sum") == 42,
      "temporal.compile_ok" => temporal.fetch("compile_status") == "ok" && temporal.fetch("pass_result") == "ok",
      "temporal.loads_for_inspection" => temporal.dig("load_for_inspection", "status") == "loaded" &&
        temporal.dig("load_for_inspection", "mode") == "inspection_only" &&
        temporal.dig("load_for_inspection", "runtime_execution", "guard_policy") == "load_accept_evaluate_refuse",
      "temporal.evaluate_refuses_structured" => temporal.dig("evaluate_without_executor", "kind") == "evaluation_refusal" &&
        temporal.dig("evaluate_without_executor", "status") == "blocked" &&
        temporal.dig("evaluate_without_executor", "guard_at") == "evaluate" &&
        temporal.dig("evaluate_without_executor", "reason_code") == "runtime.temporal_execution_unsupported"
    }
  end

  def write_summary(summary)
    File.write(SUMMARY_PATH, "#{JSON.pretty_generate(summary)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} runtime_smoke_temporal_post_switch"
    summary.fetch("checks").each do |name, ok|
      puts "#{name}: #{ok ? "ok" : "FAIL"}"
    end
    puts "core.sum: #{summary.dig("core", "runtime_smoke", "outputs", "sum")}"
    puts "temporal.load_status: #{summary.dig("temporal", "load_for_inspection", "status")}"
    puts "temporal.evaluate_reason: #{summary.dig("temporal", "evaluate_without_executor", "reason_code")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = RuntimeSmokeTemporalPostSwitch.run
exit(success ? 0 : 1)
