#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang/assembler"
require_relative "../runtime_machine_memory_proof/compiled_program"

module TemporalRuntimeLoadGuardProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  GOLDEN_DIR = ROOT / "igniter-lang/experiments/temporal_semanticir_access_node/golden"
  OUT_DIR = ROOT / "igniter-lang/experiments/temporal_runtime_load_guard/out"
  ASSEMBLED_DIR = OUT_DIR / "assembled"
  VARIANT_DIR = OUT_DIR / "variants"
  SUMMARY_PATH = OUT_DIR / "temporal_runtime_load_guard_summary.json"
  PROOF_AS_OF = "2026-05-08T00:00:00Z"

  CASES = [
    {
      "id" => "history_valid",
      "contract_id" => "HistoryAxesTest",
      "capability" => "history_read"
    },
    {
      "id" => "bihistory_valid",
      "contract_id" => "BiHistoryAxesTest",
      "capability" => "bihistory_read"
    }
  ].freeze

  class GuardedRuntimeMachine
    def initialize(temporal_runtime_supported:, temporal_capabilities:)
      @temporal_runtime_supported = temporal_runtime_supported
      @temporal_capabilities = temporal_capabilities
      @loaded_program = nil
      @loaded_metadata = nil
    end

    def load_igapp(path)
      program = RuntimeMachineMemoryProof::CompiledProgram.load_igapp(path)
      program.validate!
      metadata = read_json(Pathname.new(path) / "compatibility_metadata.json")
      refusal = validate_temporal_contract_index(program)
      return refusal if refusal

      @loaded_program = program
      @loaded_metadata = metadata
      {
        "status" => "loaded",
        "program_id" => program.program_id,
        "temporal_contracts" => temporal_contracts(program).map { |contract| contract.fetch("contract_id") },
        "runtime_execution" => metadata.fetch("runtime_execution", {})
      }
    rescue RuntimeMachineMemoryProof::ValidationError, ArgumentError, KeyError, JSON::ParserError => e
      load_refusal(
        gate: "artifact_validation",
        reason: "artifact validation failed",
        program_id: nil,
        context: { "error" => "#{e.class}: #{e.message}" }
      )
    end

    def evaluate_contract(contract_id, inputs:, as_of:)
      _inputs = inputs
      return blocked("runtime.no_program", "no program loaded", contract_id: contract_id, as_of: as_of) unless @loaded_program

      contract = @loaded_program.contracts.fetch(contract_id)
      return blocked("runtime.non_temporal_not_covered", "proof fixture only covers temporal contracts", contract_id: contract_id, as_of: as_of) unless temporal_contract?(contract)

      required = temporal_required_capabilities(contract)
      guard = @loaded_metadata.fetch("runtime_execution", {})
      unless @temporal_runtime_supported
        return blocked(
          guard.dig("evaluate", "reason_code") || "runtime.temporal_execution_unsupported",
          "temporal runtime execution is not supported by this RuntimeMachine",
          contract_id: contract_id,
          as_of: as_of,
          context: {
            "guard_policy" => guard.fetch("guard_policy", nil),
            "guard_at" => guard.fetch("guard_at", nil),
            "required_capabilities" => required
          }
        )
      end

      missing = required - @temporal_capabilities
      unless missing.empty?
        return blocked(
          "runtime.temporal_capability_missing",
          "temporal RuntimeMachine is missing required capability",
          contract_id: contract_id,
          as_of: as_of,
          context: {
            "missing_capabilities" => missing,
            "available_capabilities" => @temporal_capabilities
          }
        )
      end

      blocked(
        "runtime.temporal_execution_not_implemented",
        "temporal execution remains out of scope for this proof",
        contract_id: contract_id,
        as_of: as_of,
        context: { "required_capabilities" => required }
      )
    end

    private

    def validate_temporal_contract_index(program)
      contracts = temporal_contracts(program)
      return nil if contracts.empty?

      index = program.manifest.fetch("contract_index", nil)
      unless index.is_a?(Hash)
        return load_refusal(
          gate: "L-T1",
          reason: "TEMPORAL artifact requires manifest.contract_index object",
          program_id: program.program_id
        )
      end

      contracts.each do |contract|
        contract_id = contract.fetch("contract_id")
        entry = index.fetch(contract_id, nil)
        unless entry.is_a?(Hash)
          return load_refusal(
            gate: "L-T1",
            reason: "TEMPORAL contract is missing manifest.contract_index entry",
            program_id: program.program_id,
            contract_id: contract_id
          )
        end
        refusal = validate_temporal_entry(program, contract, entry)
        return refusal if refusal
      end
      nil
    end

    def validate_temporal_entry(program, contract, entry)
      contract_id = contract.fetch("contract_id")
      unless entry.fetch("fragment_class", nil) == "temporal" && contract.fetch("fragment_class") == "temporal"
        return load_refusal(
          gate: "L-T2",
          reason: "manifest.contract_index temporal fragment disagrees with contract file",
          program_id: program.program_id,
          contract_id: contract_id
        )
      end

      temporal = entry.fetch("temporal", nil)
      unless temporal.is_a?(Hash)
        return load_refusal(
          gate: "L-T3",
          reason: "TEMPORAL contract_index entry is missing temporal metadata",
          program_id: program.program_id,
          contract_id: contract_id
        )
      end

      expected_axes = temporal_axes(contract)
      unless Array(temporal.fetch("axes", nil)).sort == expected_axes.sort
        return load_refusal(
          gate: "L-T3",
          reason: "TEMPORAL manifest axes do not match temporal access coordinates",
          program_id: program.program_id,
          contract_id: contract_id
        )
      end

      expected_caps = temporal_required_capabilities(contract)
      unless Array(temporal.fetch("required_capabilities", nil)).sort == expected_caps.sort
        return load_refusal(
          gate: "L-T4",
          reason: "TEMPORAL required capabilities do not match ContractIR",
          program_id: program.program_id,
          contract_id: contract_id
        )
      end

      hint = temporal.fetch("cache_key_schema_hint", {})
      unless hint.fetch("schema", nil) == "runtime-cache-key-v1" && hint.fetch("fragment", nil) == "TEMPORAL"
        return load_refusal(
          gate: "L-T5",
          reason: "TEMPORAL contract cannot use CORE or unknown cache key schema",
          program_id: program.program_id,
          contract_id: contract_id
        )
      end

      coordinates = Array(temporal.fetch("coordinates", nil))
      coordinate_names = coordinates.map { |coord| coord.fetch("name", nil) }.compact.sort
      unless !coordinates.empty? && Array(hint.fetch("coordinate_names", nil)).sort == coordinate_names
        return load_refusal(
          gate: "L-T6",
          reason: "TEMPORAL contract_index entry is missing temporal coordinates",
          program_id: program.program_id,
          contract_id: contract_id
        )
      end

      nil
    end

    def temporal_contracts(program)
      program.contracts.values.select { |contract| temporal_contract?(contract) }
    end

    def temporal_contract?(contract)
      contract.fetch("fragment_class", nil) == "temporal"
    end

    def temporal_required_capabilities(contract)
      (
        contract.fetch("escape_set", []).flat_map { |boundary| boundary.fetch("required_caps", []) } +
          contract.fetch("temporal_nodes", []).flat_map { |node| node.fetch("required_caps", []) }
      ).uniq.sort
    end

    def temporal_axes(contract)
      contract.fetch("temporal_nodes", [])
        .select { |node| node.fetch("kind") == "temporal_access_node" }
        .flat_map { |node| node.fetch("coordinate_refs", {}).keys }
        .map { |axis| axis == "as_of" ? "valid_time" : axis }
        .uniq
        .sort
    end

    def load_refusal(gate:, reason:, program_id:, contract_id: nil, context: {})
      {
        "kind" => "load_refusal",
        "status" => "refused",
        "gate" => gate,
        "reason" => reason,
        "program_id" => program_id,
        "contract_id" => contract_id,
        "context" => context
      }
    end

    def blocked(reason_code, message, contract_id:, as_of:, context: {})
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
    assemble_temporal_artifacts
    variants = build_variants
    cases = proof_cases(variants)
    checks = build_checks(cases)
    summary = {
      "kind" => "temporal_runtime_load_guard_proof",
      "format_version" => "0.1.0",
      "track" => "temporal-runtime-load-guard-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "policy" => {
        "guard_policy" => "load_accept_evaluate_refuse",
        "load" => "validate manifest.contract_index and accept temporal artifacts for inspection only",
        "evaluate" => "refuse temporal contracts unless a future runtime adapter/executor is explicitly implemented",
        "production_execution" => false,
        "ledger_binding" => false,
        "cache_enabled" => false
      },
      "cases" => cases,
      "checks" => checks
    }
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def assemble_temporal_artifacts
    assembler = IgniterLang::Assembler.new(golden_dir: GOLDEN_DIR, out_dir: ASSEMBLED_DIR)
    CASES.each { |config| assembler.assemble_case(config.fetch("id")) }
  end

  def proof_cases(variants)
    CASES.each_with_object({}) do |config, out|
      id = config.fetch("id")
      contract_id = config.fetch("contract_id")
      capability = config.fetch("capability")
      igapp_path = ASSEMBLED_DIR / "#{id}.igapp"

      unsupported_machine = GuardedRuntimeMachine.new(temporal_runtime_supported: false, temporal_capabilities: [])
      load = unsupported_machine.load_igapp(igapp_path)
      unsupported_eval = unsupported_machine.evaluate_contract(contract_id, inputs: {}, as_of: PROOF_AS_OF)

      missing_cap_machine = GuardedRuntimeMachine.new(temporal_runtime_supported: true, temporal_capabilities: [])
      missing_cap_machine.load_igapp(igapp_path)
      missing_cap_eval = missing_cap_machine.evaluate_contract(contract_id, inputs: {}, as_of: PROOF_AS_OF)

      out[id] = {
        "artifact_path" => igapp_path.relative_path_from(ROOT).to_s,
        "required_capability" => capability,
        "load_for_inspection" => load,
        "unsupported_runtime_evaluate" => unsupported_eval,
        "missing_capability_evaluate" => missing_cap_eval
      }
    end.merge(
      "missing_contract_index" => {
        "artifact_path" => variants.fetch("missing_contract_index").relative_path_from(ROOT).to_s,
        "load" => GuardedRuntimeMachine.new(temporal_runtime_supported: false, temporal_capabilities: [])
          .load_igapp(variants.fetch("missing_contract_index"))
      },
      "malformed_contract_index" => {
        "artifact_path" => variants.fetch("malformed_contract_index").relative_path_from(ROOT).to_s,
        "load" => GuardedRuntimeMachine.new(temporal_runtime_supported: false, temporal_capabilities: [])
          .load_igapp(variants.fetch("malformed_contract_index"))
      },
      "core_cache_hint_for_temporal" => {
        "artifact_path" => variants.fetch("core_cache_hint").relative_path_from(ROOT).to_s,
        "load" => GuardedRuntimeMachine.new(temporal_runtime_supported: false, temporal_capabilities: [])
          .load_igapp(variants.fetch("core_cache_hint"))
      }
    )
  end

  def build_checks(cases)
    case_checks = CASES.each_with_object({}) do |config, checks|
      id = config.fetch("id")
      result = cases.fetch(id)
      checks["#{id}.load_accepts_for_inspection"] = result.dig("load_for_inspection", "status") == "loaded" &&
        result.dig("load_for_inspection", "runtime_execution", "guard_policy") == "load_accept_evaluate_refuse"
      checks["#{id}.evaluate_refuses_unsupported_runtime"] =
        result.dig("unsupported_runtime_evaluate", "status") == "blocked" &&
          result.dig("unsupported_runtime_evaluate", "reason_code") == "runtime.temporal_execution_unsupported"
      checks["#{id}.evaluate_refuses_missing_capability"] =
        result.dig("missing_capability_evaluate", "status") == "blocked" &&
          result.dig("missing_capability_evaluate", "reason_code") == "runtime.temporal_capability_missing" &&
          result.dig("missing_capability_evaluate", "context", "missing_capabilities").include?(config.fetch("capability"))
    end

    case_checks.merge(
      "missing_contract_index.load_refused" => cases.dig("missing_contract_index", "load", "status") == "refused" &&
        cases.dig("missing_contract_index", "load", "gate") == "L-T1",
      "malformed_contract_index.load_refused" => cases.dig("malformed_contract_index", "load", "status") == "refused" &&
        cases.dig("malformed_contract_index", "load", "gate") == "L-T1",
      "core_cache_hint_for_temporal.load_refused" => cases.dig("core_cache_hint_for_temporal", "load", "status") == "refused" &&
        cases.dig("core_cache_hint_for_temporal", "load", "gate") == "L-T5"
    )
  end

  def build_variants
    FileUtils.rm_rf(VARIANT_DIR)
    FileUtils.mkdir_p(VARIANT_DIR)
    source = ASSEMBLED_DIR / "history_valid.igapp"
    variants = {
      "missing_contract_index" => VARIANT_DIR / "history_missing_contract_index.igapp",
      "malformed_contract_index" => VARIANT_DIR / "history_malformed_contract_index.igapp",
      "core_cache_hint" => VARIANT_DIR / "history_core_cache_hint.igapp"
    }
    variants.each_value { |target| FileUtils.cp_r(source, target) }

    mutate_manifest(variants.fetch("missing_contract_index")) do |manifest|
      manifest.delete("contract_index")
    end
    mutate_manifest(variants.fetch("malformed_contract_index")) do |manifest|
      manifest["contract_index"] = []
    end
    mutate_manifest(variants.fetch("core_cache_hint")) do |manifest|
      manifest.fetch("contract_index")
        .fetch("HistoryAxesTest")
        .fetch("temporal")
        .fetch("cache_key_schema_hint")["fragment"] = "CORE"
    end
    variants
  end

  def mutate_manifest(path)
    manifest_path = path / "manifest.json"
    manifest = read_json(manifest_path)
    yield manifest
    write_json(manifest_path, manifest)
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} temporal_runtime_load_guard"
    summary.fetch("checks").each do |name, ok|
      puts "#{name}: #{ok ? "ok" : "FAIL"}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

if $PROGRAM_NAME == __FILE__
  success = TemporalRuntimeLoadGuardProof.run
  exit(success ? 0 : 1)
end
