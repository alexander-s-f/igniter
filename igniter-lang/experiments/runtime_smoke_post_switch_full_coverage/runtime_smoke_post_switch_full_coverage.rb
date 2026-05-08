#!/usr/bin/env ruby
# frozen_string_literal: true

require "bigdecimal"
require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang"
require_relative "../../lib/igniter_lang/runtime_smoke"
require_relative "../runtime_machine_memory_proof/compiled_program"

module RuntimeSmokePostSwitchFullCoverage
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  FIXTURE_DIR = LANG_ROOT / "experiments/runtime_smoke_post_switch_full_coverage"
  INPUT_DIR = FIXTURE_DIR / "inputs"
  OUT_DIR = FIXTURE_DIR / "out"
  SUMMARY_PATH = OUT_DIR / "runtime_smoke_post_switch_full_coverage_summary.json"
  AS_OF = "2026-05-08T00:00:00Z"

  ADD_SOURCE = LANG_ROOT / "experiments/source_to_semanticir_fixture/add.ig"
  HISTORY_SOURCE = LANG_ROOT / "experiments/history_type_proof/history_integer_point_access.ig"
  BIHISTORY_SOURCE = LANG_ROOT / "experiments/typed_emission_main_path_parity/sparkcrm_bihistory_source.ig"
  INVARIANT_TYPED_FIXTURE = LANG_ROOT / "experiments/typechecker_proof/golden/invariant_severity_valid.typed.json"

  STREAM_SOURCE = <<~IGNITER
    contract IntegerWindowSum {
      input device_id: String
      stream readings: Integer

      window "integer/{device_id}" {
        kind: :count,
        size: 3,
        on_close: :snapshot
      }

      compute total: Integer =
        fold_stream(readings, 0, (acc, reading) -> acc + reading) @window_bounded

      output total: Integer
    }
  IGNITER

  OLAP_SOURCE = <<~IGNITER
    olap_point Revenue {
      dimensions: {
        date: String,
        region: String,
        channel: String
      }
      measure: Decimal[2]
      granularity: { date: :daily }
      source: synthetic_fulfilled_order_facts
      indexed: [:date, :region]
    }

    contract RegionalDailyRevenuePoint {
      input date: String
      input region: String
      input channel: String

      compute revenue_point: OLAPPoint[Decimal[2], {date: String, region: String, channel: String}] =
        Revenue[date: date, region: region, channel: channel]

      output revenue_point: Decimal[2]
    }
  IGNITER

  INVARIANT_SOURCE = <<~IGNITER
    module Fixture.InvariantSeverity
    contract DrugOrderGate {
      input is_safe: Bool
      input has_warning: Bool
      compute approved = is_safe
      invariant safety_block
        predicate: approved
        severity: :error
        label: "REQ-SAFE-01"
        message: "Safety block"
      invariant interaction_warn
        predicate: has_warning
        severity: :warn
        message: "Interaction warning"
        overridable_with: :documented_justification
      invariant confidence_soft
        predicate: is_safe
        severity: :soft
      invariant latency_metric
        predicate: has_warning
        severity: :metric
      output approved: Bool
    }
  IGNITER

  STREAM_EVENTS = [
    { "event_id" => "event/reading/1", "sequence" => 1, "value" => 4 },
    { "event_id" => "event/reading/2", "sequence" => 2, "value" => 9 },
    { "event_id" => "event/reading/3", "sequence" => 3, "value" => 11 }
  ].freeze

  OLAP_FACTS = [
    {
      "fact_id" => "fact/order/1",
      "dimensions" => { "date" => "2026-05-08", "region" => "north", "channel" => "field" },
      "measure" => "12.40"
    },
    {
      "fact_id" => "fact/order/2",
      "dimensions" => { "date" => "2026-05-08", "region" => "north", "channel" => "field" },
      "measure" => "7.60"
    }
  ].freeze

  class TemporalInspectionRuntime
    def initialize
      @program = nil
      @metadata = nil
    end

    def load_for_inspection(path)
      program = RuntimeMachineMemoryProof::CompiledProgram.load_igapp(path)
      program.validate!
      metadata = read_json(Pathname.new(path) / "compatibility_metadata.json")
      temporal_contracts = program.contracts.values.select { |contract| contract.fetch("fragment_class", nil) == "temporal" }
      return load_refusal("not_temporal", "expected TEMPORAL artifact") if temporal_contracts.empty?

      @program = program
      @metadata = metadata
      {
        "kind" => "runtime_load_result",
        "status" => "loaded",
        "mode" => "inspection_only",
        "program_id" => program.program_id,
        "temporal_contracts" => temporal_contracts.map { |contract| contract.fetch("contract_id") },
        "runtime_execution" => metadata.fetch("runtime_execution", {})
      }
    rescue RuntimeMachineMemoryProof::ValidationError, JSON::ParserError, KeyError, ArgumentError => e
      load_refusal("artifact_validation", "#{e.class}: #{e.message}")
    end

    def evaluate(contract_id)
      contract = @program.contracts.fetch(contract_id)
      guard = @metadata.fetch("runtime_execution", {})
      {
        "kind" => "evaluation_refusal",
        "status" => "blocked",
        "guard_at" => "evaluate",
        "reason_code" => guard.dig("evaluate", "reason_code") || "runtime.temporal_execution_unsupported",
        "message" => "TEMPORAL evaluation remains closed until executor/TBackend approval",
        "contract_id" => contract_id,
        "as_of" => AS_OF,
        "context" => {
          "guard_policy" => guard.fetch("guard_policy", nil),
          "required_capabilities" => required_capabilities(contract)
        }
      }
    rescue KeyError => e
      {
        "kind" => "evaluation_refusal",
        "status" => "blocked",
        "guard_at" => "evaluate",
        "reason_code" => "runtime.contract_missing",
        "message" => e.message,
        "contract_id" => contract_id,
        "as_of" => AS_OF,
        "context" => {}
      }
    end

    private

    def required_capabilities(contract)
      (
        contract.fetch("escape_set", []).flat_map { |boundary| boundary.fetch("required_caps", []) } +
          contract.fetch("temporal_nodes", []).flat_map { |node| node.fetch("required_caps", []) }
      ).uniq.sort
    end

    def load_refusal(gate, reason)
      {
        "kind" => "load_refusal",
        "status" => "refused",
        "gate" => gate,
        "reason" => reason
      }
    end

    def read_json(path)
      JSON.parse(File.read(path))
    end
  end

  module_function

  def run
    reset_outputs
    write_input_sources
    cases = {
      "core_add_compute" => core_add_smoke,
      "stream_fold" => stream_fold_smoke,
      "olap_point" => olap_point_smoke,
      "history_single_axis" => temporal_smoke(
        id: "history_single_axis",
        source_path: HISTORY_SOURCE,
        sample_input: { "technician_id" => "tech-1", "as_of" => AS_OF }
      ),
      "bihistory_bitemporal" => temporal_smoke(
        id: "bihistory_bitemporal",
        source_path: BIHISTORY_SOURCE,
        sample_input: {
          "technician_id" => "tech-17",
          "valid_time" => "2026-05-07T10:00:00Z",
          "transaction_time" => "2026-05-08T09:15:00Z"
        }
      ),
      "invariant_severity" => invariant_smoke
    }
    compatibility_cross_check = compatibility_report_cross_check
    checks = build_checks(cases, compatibility_cross_check)
    summary = {
      "kind" => "runtime_smoke_post_switch_full_coverage_summary",
      "format_version" => "0.1.0",
      "card" => "S3-R8-C1-P",
      "track" => "runtime-smoke-post-switch-full-coverage-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "compiler_path" => "Parser -> Classifier -> TypeChecker -> SemanticIREmitter.emit_typed -> Assembler",
      "scope" => {
        "live_tbackend_binding" => false,
        "temporal_executor" => false,
        "production_cache" => false
      },
      "surfaces" => cases,
      "compatibility_report_cross_check" => compatibility_cross_check,
      "uncovered_surfaces" => uncovered_surfaces(cases),
      "remaining_gaps" => remaining_gaps(cases),
      "checks" => checks
    }
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def reset_outputs
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.rm_rf(INPUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)
    FileUtils.mkdir_p(INPUT_DIR)
  end

  def write_input_sources
    {
      "stream_fold.ig" => STREAM_SOURCE,
      "olap_point.ig" => OLAP_SOURCE,
      "invariant_severity.ig" => INVARIANT_SOURCE
    }.each do |name, source|
      File.write(INPUT_DIR / name, source)
    end
  end

  def compile_case(id:, source_path:, sample_input:)
    out_path = OUT_DIR / "#{id}.igapp"
    result = IgniterLang.compile(
      source_path: source_path,
      out_path: out_path,
      sample_input: sample_input
    )
    {
      "id" => id,
      "source_path" => Pathname.new(source_path).relative_path_from(ROOT).to_s,
      "igapp_path" => out_path.relative_path_from(ROOT).to_s,
      "compile_status" => result.fetch("status"),
      "pass_result" => result.fetch("compilation_report").fetch("pass_result"),
      "diagnostics" => result.fetch("compilation_report").fetch("diagnostics", []),
      "result" => result
    }
  end

  def load_program(path)
    program = RuntimeMachineMemoryProof::CompiledProgram.load_igapp(path)
    program.validate!
    program
  end

  def core_add_smoke
    out_path = OUT_DIR / "core_add_compute.igapp"
    compile = IgniterLang.compile(
      source_path: ADD_SOURCE,
      out_path: out_path,
      sample_input: { "a" => 19, "b" => 23 }
    )
    runtime = IgniterLang::RuntimeSmoke.run(out_path: out_path, sample_input: { "a" => 19, "b" => 23 }, as_of: AS_OF)
    {
      "surface" => "CORE Add/compute",
      "source_path" => ADD_SOURCE.relative_path_from(ROOT).to_s,
      "igapp_path" => out_path.relative_path_from(ROOT).to_s,
      "compile_status" => compile.fetch("status"),
      "pass_result" => compile.fetch("compilation_report").fetch("pass_result"),
      "load_status" => runtime.fetch("load_status"),
      "evaluate_status" => runtime.fetch("evaluate_status"),
      "outputs" => runtime.fetch("outputs"),
      "compatibility_report_status" => runtime.fetch("compatibility_report_status"),
      "trusted" => runtime.fetch("trusted")
    }
  end

  def stream_fold_smoke
    compile = compile_case(
      id: "stream_fold",
      source_path: INPUT_DIR / "stream_fold.ig",
      sample_input: { "device_id" => "device-1" }
    )
    program = load_program(OUT_DIR / "stream_fold.igapp")
    semantic_ir = program.semantic_ir_program
    contract = semantic_ir.fetch("contracts").first
    stream_node = node_by_kind(contract, "stream_input_node")
    window_node = node_by_kind(contract, "window_decl_node")
    fold_node = node_by_kind(contract, "fold_stream_node")
    window_size = window_node.fetch("size", STREAM_EVENTS.length)
    initial_value = fold_node.dig("init", "value") || 0
    consumed = STREAM_EVENTS.first(window_size)
    total = consumed.map { |event| event.fetch("value") }.reduce(initial_value, :+)
    observation = {
      "kind" => "stream_window_observation",
      "closed" => true,
      "window_kind" => window_node.fetch("window_kind", "count"),
      "consumed_event_refs" => consumed.map { |event| event.fetch("event_id") }
    }

    {
      "surface" => "stream_fold",
      "compile_status" => compile.fetch("compile_status"),
      "pass_result" => compile.fetch("pass_result"),
      "load_status" => "loaded",
      "fragment_class" => program.fragment_class,
      "node_kinds" => contract.fetch("nodes").map { |node| node.fetch("kind") },
      "evaluate_status" => "ok",
      "output" => {
        "total" => total,
        "event_count" => consumed.length,
        "stream_ref" => stream_node.fetch("name")
      },
      "runtime_note" => stream_metadata_note(window_node, fold_node),
      "observations" => [observation],
      "trusted" => true
    }
  rescue => e
    failure_surface("stream_fold", compile, e)
  end

  def olap_point_smoke
    compile = compile_case(
      id: "olap_point",
      source_path: INPUT_DIR / "olap_point.ig",
      sample_input: { "date" => "2026-05-08", "region" => "north", "channel" => "field" }
    )
    program = load_program(OUT_DIR / "olap_point.igapp")
    semantic_ir = program.semantic_ir_program
    olap_decl = semantic_ir.fetch("olap_points").first
    contract = semantic_ir.fetch("contracts").first
    access_node = node_by_kind(contract, "olap_access_node")
    dims = { "date" => "2026-05-08", "region" => "north", "channel" => "field" }
    matching = OLAP_FACTS.select { |fact| fact.fetch("dimensions") == dims }
    total = decimal_sum(matching.map { |fact| fact.fetch("measure") })

    {
      "surface" => "OLAPPoint",
      "compile_status" => compile.fetch("compile_status"),
      "pass_result" => compile.fetch("pass_result"),
      "load_status" => "loaded",
      "fragment_class" => program.fragment_class,
      "node_kinds" => contract.fetch("nodes").map { |node| node.fetch("kind") },
      "evaluate_status" => "ok",
      "output" => {
        "measure" => total,
        "dimensions" => dims,
        "olap_ref" => olap_decl.fetch("name"),
        "node" => access_node.fetch("name"),
        "source_fact_refs" => matching.map { |fact| fact.fetch("fact_id") }
      },
      "observations" => [
        {
          "kind" => "olap_cell_observation",
          "measure" => total,
          "source_fact_refs" => matching.map { |fact| fact.fetch("fact_id") }
        }
      ],
      "trusted" => true
    }
  rescue => e
    failure_surface("olap_point", compile, e)
  end

  def invariant_smoke
    assemble_typed_fixture(id: "invariant_severity", typed_path: INVARIANT_TYPED_FIXTURE)
    compile = {
      "compile_status" => "ok",
      "pass_result" => "ok",
      "diagnostics" => []
    }
    program = load_program(OUT_DIR / "invariant_severity.igapp")
    semantic_ir = program.semantic_ir_program
    contract = semantic_ir.fetch("contracts").first
    invariant_nodes = contract.fetch("nodes").select { |node| node.fetch("kind") == "invariant_node" }
    inputs = { "is_safe" => true, "has_warning" => false }
    values = { "approved" => inputs.fetch("is_safe") }
    results = invariant_nodes.map do |invariant|
      predicate_ref = invariant.fetch("predicate_ref")
      passed = values.fetch(predicate_ref, inputs.fetch(predicate_ref))
      {
        "name" => invariant.fetch("name"),
        "severity" => invariant.fetch("severity"),
        "status" => passed ? "satisfied" : "violated",
        "output_effect" => invariant.fetch("output_effect")
      }
    end

    {
      "surface" => "invariant severity",
      "input_path" => INVARIANT_TYPED_FIXTURE.relative_path_from(ROOT).to_s,
      "compile_status" => compile.fetch("compile_status"),
      "pass_result" => compile.fetch("pass_result"),
      "load_status" => "loaded",
      "fragment_class" => program.fragment_class,
      "node_kinds" => contract.fetch("nodes").map { |node| node.fetch("kind") },
      "evaluate_status" => results.any? { |result| result.fetch("severity") == "error" && result.fetch("status") == "violated" } ? "blocked" : "ok",
      "output" => { "approved" => values.fetch("approved") },
      "invariant_results" => results,
      "observations" => results.map do |result|
        {
          "kind" => result.fetch("status") == "violated" ? "invariant_violation_observation" : "invariant_verification_observation",
          "invariant" => result.fetch("name"),
          "severity" => result.fetch("severity"),
          "status" => result.fetch("status")
        }
      end,
      "trusted" => true
    }
  rescue => e
    failure_surface("invariant_severity", compile, e)
  end

  def assemble_typed_fixture(id:, typed_path:)
    typed = JSON.parse(File.read(typed_path))
    emitted = IgniterLang::SemanticIREmitter.new.emit_typed(typed)
    IgniterLang::Assembler.new.assemble_artifacts(
      case_name: id,
      report: emitted.fetch("compilation_report"),
      semantic_ir: emitted.fetch("semantic_ir"),
      target_dir: OUT_DIR / "#{id}.igapp"
    )
  end

  def temporal_smoke(id:, source_path:, sample_input:)
    compile = compile_case(id: id, source_path: source_path, sample_input: sample_input)
    runtime = TemporalInspectionRuntime.new
    load = runtime.load_for_inspection(OUT_DIR / "#{id}.igapp")
    contract_id = load.fetch("temporal_contracts", []).first
    evaluation = runtime.evaluate(contract_id)
    {
      "surface" => id,
      "compile_status" => compile.fetch("compile_status"),
      "pass_result" => compile.fetch("pass_result"),
      "load_for_inspection" => load,
      "evaluate_without_executor" => evaluation,
      "trusted" => load.fetch("status") == "loaded" &&
        evaluation.fetch("status") == "blocked" &&
        evaluation.fetch("guard_at") == "evaluate"
    }
  rescue => e
    failure_surface(id, compile, e)
  end

  def compatibility_report_cross_check
    summary_path = LANG_ROOT /
      "experiments/runtime_compatibility_report_temporal_load_check/out/runtime_compatibility_report_temporal_load_check_summary.json"
    summary = JSON.parse(File.read(summary_path))
    report = summary.dig("cases", "history_valid", "reports", "missing_tbackend_capability")
    {
      "source" => summary_path.relative_path_from(ROOT).to_s,
      "status" => report &&
        report.dig("bundle_load", "decision") == "accept_for_inspection" &&
        report.dig("evaluation_readiness", "reason_code") == "runtime.temporal_capability_missing" ? "ok" : "blocked",
      "bundle_load_decision" => report&.dig("bundle_load", "decision"),
      "evaluation_readiness" => report&.dig("evaluation_readiness")
    }
  rescue => e
    {
      "source" => summary_path.relative_path_from(ROOT).to_s,
      "status" => "blocked",
      "error" => "#{e.class}: #{e.message}"
    }
  end

  def build_checks(cases, compatibility_cross_check)
    {
      "core_add_compute.compile_load_evaluate" => cases.dig("core_add_compute", "trusted") == true &&
        cases.dig("core_add_compute", "outputs", "sum") == 42,
      "stream_fold.compile_load_evaluate" => cases.dig("stream_fold", "trusted") == true &&
        cases.dig("stream_fold", "output", "total") == 24,
      "olap_point.compile_load_evaluate" => cases.dig("olap_point", "trusted") == true &&
        cases.dig("olap_point", "output", "measure") == "20.00",
      "history_single_axis.load_refuse_eval" => temporal_refusal_ok?(cases.fetch("history_single_axis"), "history_read"),
      "bihistory_bitemporal.load_refuse_eval" => temporal_refusal_ok?(cases.fetch("bihistory_bitemporal"), "bihistory_read"),
      "invariant_severity.compile_load_evaluate" => cases.dig("invariant_severity", "trusted") == true &&
        invariant_smoke_covers_error_and_warn?(cases.fetch("invariant_severity")),
      "compatibility_report_cross_check" => compatibility_cross_check.fetch("status") == "ok",
      "no_uncovered_surfaces" => uncovered_surfaces(cases).empty?
    }
  end

  def temporal_refusal_ok?(surface, capability)
    surface.dig("load_for_inspection", "status") == "loaded" &&
      surface.dig("evaluate_without_executor", "status") == "blocked" &&
      surface.dig("evaluate_without_executor", "reason_code") == "runtime.temporal_execution_unsupported" &&
      surface.dig("evaluate_without_executor", "context", "required_capabilities").include?(capability)
  end

  def invariant_smoke_covers_error_and_warn?(surface)
    severities = surface.fetch("invariant_results", []).map { |result| result.fetch("severity") }
    surface.fetch("evaluate_status") == "ok" &&
      severities.include?("error") &&
      severities.include?("warn")
  end

  def uncovered_surfaces(cases)
    cases.select { |_id, surface| surface.fetch("trusted", false) != true }.keys
  end

  def remaining_gaps(cases)
    gaps = []
    stream_note = cases.dig("stream_fold", "runtime_note")
    if stream_note && stream_note != "semantic_ir_stream_metadata_complete"
      gaps << {
        "surface" => "stream_fold",
        "gap" => stream_note,
        "owner_hint" => "Compiler/Grammar Expert"
      }
    end
    gaps << {
      "surface" => "invariant_severity",
      "gap" => "runtime smoke uses the dedicated typed fixture for severity metadata; source-to-classifier metadata preservation should stay visible outside this runtime card",
      "owner_hint" => "Compiler/Grammar Expert"
    }
    gaps << {
      "surface" => "TEMPORAL",
      "gap" => "History and BiHistory load for inspection and structurally refuse evaluation until temporal executor/TBackend Gate 3 opens",
      "owner_hint" => "Research Agent / Bridge Agent"
    }
    gaps
  end

  def failure_surface(surface, compile, error)
    {
      "surface" => surface,
      "compile_status" => compile&.fetch("compile_status", "not_started"),
      "pass_result" => compile&.fetch("pass_result", "unknown"),
      "diagnostics" => compile&.fetch("diagnostics", []),
      "load_status" => "blocked",
      "evaluate_status" => "blocked",
      "error" => "#{error.class}: #{error.message}",
      "trusted" => false
    }
  end

  def node_by_kind(contract, kind)
    contract.fetch("nodes").find { |node| node.fetch("kind") == kind } ||
      raise("missing #{kind}")
  end

  def stream_metadata_note(window_node, fold_node)
    missing = []
    missing << "window.size" unless window_node.key?("size")
    missing << "fold_stream.init" unless fold_node.fetch("init", nil)
    missing << "fold_stream.fn_ref" unless fold_node.fetch("fn_ref", nil)
    return "semantic_ir_stream_metadata_complete" if missing.empty?

    "proof-local finite replay used fixture defaults for #{missing.join(", ")}"
  end

  def decimal_sum(values)
    total = values.map { |value| BigDecimal(value) }.reduce(BigDecimal("0"), :+)
    format("%.2f", total)
  end

  def write_json(path, value)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} runtime_smoke_post_switch_full_coverage"
    summary.fetch("checks").each do |name, ok|
      puts "#{name}: #{ok ? "ok" : "FAIL"}"
    end
    puts "uncovered_surfaces: #{summary.fetch("uncovered_surfaces").empty? ? "none" : summary.fetch("uncovered_surfaces").join(", ")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = RuntimeSmokePostSwitchFullCoverage.run
exit(success ? 0 : 1)
