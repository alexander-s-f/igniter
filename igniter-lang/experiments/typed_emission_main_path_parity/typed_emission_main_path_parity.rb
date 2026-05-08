#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"
require "time"

require_relative "../../lib/igniter_lang"

module TypedEmissionMainPathParity
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  OUT_DIR = ROOT / "igniter-lang/experiments/typed_emission_main_path_parity"
  GOLDEN_DIR = OUT_DIR / "golden"
  SUMMARY_PATH = OUT_DIR / "typed_emission_main_path_parity.json"
  GOLDEN_REPORT_PATH = GOLDEN_DIR / "typed_emission_main_path_parity.golden.json"

  INVARIANT_VALID_SOURCE = <<~IGNITER
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

  SOURCE_CASES = [
    {
      "id" => "package_facade_add",
      "surface" => "package_facade",
      "source_path" => "igniter-lang/experiments/source_to_semanticir_fixture/add.ig",
      "sample_input" => { "a" => 1, "b" => 2 },
      "expect_typed_node_kinds" => ["compute"]
    },
    {
      "id" => "invariant_valid",
      "surface" => "invariant_runtime_observations",
      "source_path" => "igniter-lang/experiments/invariant_severity_proof/invariant_severity.ig",
      "source" => INVARIANT_VALID_SOURCE,
      "sample_input" => { "is_safe" => true, "has_warning" => false },
      "expect_typed_node_kinds" => ["compute", "invariant_node"]
    },
    {
      "id" => "olap_point",
      "surface" => "olap_point",
      "source_path" => "igniter-lang/experiments/olap_point_proof/revenue_point.ig",
      "source" => OLAP_SOURCE,
      "sample_input" => { "date" => "2026-05-08", "region" => "north", "channel" => "field" },
      "expect_typed_node_kinds" => ["olap_access_node"]
    },
    {
      "id" => "stream_fold",
      "surface" => "stream_fold",
      "source_path" => "igniter-lang/experiments/stream_t_proof/stream_integer_window.ig",
      "source" => STREAM_SOURCE,
      "sample_input" => { "device_id" => "device-1" },
      "expect_typed_node_kinds" => ["stream_input_node", "window_decl_node", "fold_stream_node"]
    },
    {
      "id" => "history_access",
      "surface" => "history_bihistory_temporal_access",
      "source_path" => "igniter-lang/experiments/history_type_proof/history_integer_point_access.ig",
      "sample_input" => { "technician_id" => "tech-1", "as_of" => "2026-05-08T00:00:00Z" },
      "expect_typed_node_kinds" => ["temporal_access_node"]
    }
  ].freeze

  PROOF_LOCAL_CASES = [
    {
      "id" => "sparkcrm_bihistory",
      "surface" => "history_bihistory_temporal_access",
      "source_path" => nil,
      "status" => "NOT_COMPARABLE",
      "reason" => "Stage 2 close uses a proof-local Ruby fixture; there is no .ig source fixture to run through parsed and typed emit paths."
    },
    {
      "id" => "ledger_tbackend_descriptor",
      "surface" => "ledger_tbackend_descriptor",
      "source_path" => nil,
      "status" => "NOT_COMPARABLE",
      "reason" => "Descriptor fixture is metadata-only TBackend evidence, not a SemanticIR emission source."
    }
  ].freeze

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    FileUtils.mkdir_p(GOLDEN_DIR)
    source_cases = SOURCE_CASES.map { |config| compare_source_case(config) }
    summary = build_summary(source_cases)
    write_summary(summary)
    write_golden(summary)
    print_summary(summary)
    true
  end

  def compare_source_case(config)
    source_path = Pathname.new(config.fetch("source_path"))
    source = config.fetch("source") { File.read(ROOT / source_path) }
    sample_input = config.fetch("sample_input")
    parsed_result = capture_step { IgniterLang::ParsedProgram.parse(source, source_path: source_path.to_s).to_h }

    unless parsed_result.fetch("status") == "ok"
      return config.merge(
        "status" => "FAIL",
        "parsed_path" => { "status" => "parse_error", "error" => parsed_result.fetch("error") },
        "typed_path" => { "status" => "parse_error", "error" => parsed_result.fetch("error") },
        "deltas" => [{ "kind" => "parse_exception", "summary" => parsed_result.fetch("error") }]
      )
    end

    parsed = parsed_result.fetch("value")
    if parsed.fetch("parse_errors").any?
      return config.merge(
        "status" => "FAIL",
        "parsed_path" => { "status" => "parse_error", "parse_errors" => parsed.fetch("parse_errors") },
        "typed_path" => { "status" => "skipped" },
        "deltas" => [{ "kind" => "parse_error", "summary" => "source did not parse" }]
      )
    end

    emitter = IgniterLang::SemanticIREmitter.new
    parsed_emission = capture_step { emitter.emit(parsed, sample_input: sample_input) }
    classified_result = capture_step { IgniterLang::Classifier.new.classify(parsed, sample_input: sample_input) }
    typed_result = if classified_result.fetch("status") == "ok"
                     capture_step { IgniterLang::TypeChecker.new.typecheck(classified_result.fetch("value")) }
                   else
                     classified_result.merge("stage" => "classify")
                   end
    typed_emission = if typed_result.fetch("status") == "ok"
                       capture_step { emitter.emit_typed(typed_result.fetch("value")) }
                     else
                       typed_result.merge("stage" => typed_result.fetch("stage", "typecheck"))
                     end

    parsed_summary = captured_emission_summary(parsed_emission)
    typed_summary = captured_emission_summary(typed_emission)
    deltas = captured_emission_deltas(parsed_emission, typed_emission)

    if typed_emission.fetch("status") == "ok"
      typed_missing = missing_expected_node_kinds(typed_summary, config.fetch("expect_typed_node_kinds", []))
      deltas << {
        "kind" => "typed_expected_nodes_missing",
        "missing" => typed_missing
      } unless typed_missing.empty?
    end

    config.merge(
      "status" => deltas.empty? ? "PASS" : "FAIL",
      "parsed_path" => parsed_summary,
      "typed_path" => typed_summary,
      "deltas" => deltas
    )
  rescue => e
    config.merge(
      "status" => "FAIL",
      "error" => "#{e.class}: #{e.message}",
      "deltas" => [{ "kind" => "exception", "summary" => e.message }]
    )
  end

  def capture_step
    { "status" => "ok", "value" => yield }
  rescue => e
    { "status" => "error", "error" => "#{e.class}: #{e.message}" }
  end

  def build_summary(source_cases)
    blocked = blocked_items(source_cases)
    typed_source_blocked = typed_source_blocked_items(source_cases)
    legacy_parity_deltas = legacy_parity_delta_items(source_cases)
    {
      "kind" => "typed_emission_main_path_parity",
      "format_version" => "0.1.0",
      "track" => "typed-emission-main-path-parity-v0",
      "status" => "PASS",
      "verdict" => blocked.empty? ? "parity_proven" : "blocked",
      "safe_to_switch_production_path" => blocked.empty?,
      "cases_run" => source_cases.length,
      "timestamp" => Time.now.utc.iso8601,
      "current_main_path" => "SemanticIREmitter#emit(parsed_program, sample_input:)",
      "candidate_main_path" => "SemanticIREmitter#emit_typed(typed_program)",
      "source_cases" => source_cases,
      "proof_local_cases" => PROOF_LOCAL_CASES,
      "blocked_items" => blocked,
      "typed_source_blocked_items" => typed_source_blocked,
      "legacy_parity_delta_items" => legacy_parity_deltas,
      "recommendation" => blocked.empty? ? "Switch CompilerOrchestrator narrowly to emit_typed." : "Do not switch CompilerOrchestrator yet; resolve blocked_items first."
    }
  end

  def emission_summary(emission)
    report = emission.fetch("compilation_report")
    semantic_ir = emission.fetch("semantic_ir")
    {
      "pass_result" => report.fetch("pass_result"),
      "semantic_ir_present" => !semantic_ir.nil?,
      "program_id" => semantic_ir&.fetch("program_id"),
      "semantic_ir_ref" => report.fetch("semantic_ir_ref", nil),
      "report_program_id" => report.fetch("program_id"),
      "report_keys" => report.keys.sort,
      "semantic_ir_keys" => semantic_ir ? semantic_ir.keys.sort : [],
      "contract_names" => semantic_ir ? semantic_ir.fetch("contracts").map { |contract| contract.fetch("contract_name") } : [],
      "node_kinds" => node_kinds(semantic_ir),
      "diagnostic_rules" => report.fetch("diagnostics", []).map { |diagnostic| diagnostic.fetch("rule", nil) }.compact,
      "shape_hash" => semantic_ir ? shape_hash(semantic_ir) : nil,
      "report_shape_hash" => shape_hash(report)
    }
  end

  def captured_emission_summary(captured)
    return { "status" => "error", "error" => captured.fetch("error") } unless captured.fetch("status") == "ok"

    emission_summary(captured.fetch("value")).merge("status" => "ok")
  end

  def captured_emission_deltas(parsed_emission, typed_emission)
    deltas = []
    unless parsed_emission.fetch("status") == "ok"
      deltas << {
        "kind" => "parsed_path_error",
        "summary" => parsed_emission.fetch("error")
      }
    end
    unless typed_emission.fetch("status") == "ok"
      deltas << {
        "kind" => "typed_path_error",
        "summary" => typed_emission.fetch("error")
      }
    end
    return deltas unless parsed_emission.fetch("status") == "ok" && typed_emission.fetch("status") == "ok"

    deltas + emission_deltas(parsed_emission.fetch("value"), typed_emission.fetch("value"))
  end

  def emission_deltas(parsed_emission, typed_emission)
    parsed_report = parsed_emission.fetch("compilation_report")
    typed_report = typed_emission.fetch("compilation_report")
    parsed_ir = parsed_emission.fetch("semantic_ir")
    typed_ir = typed_emission.fetch("semantic_ir")
    deltas = []

    deltas << value_delta("report.pass_result", parsed_report.fetch("pass_result"), typed_report.fetch("pass_result"))
    deltas << value_delta("semantic_ir.present", !parsed_ir.nil?, !typed_ir.nil?)
    deltas.compact!

    if parsed_ir && typed_ir
      normalized_parsed_ir = normalize_for_shape(parsed_ir)
      normalized_typed_ir = normalize_for_shape(typed_ir)
      ir_paths = diff_paths(normalized_parsed_ir, normalized_typed_ir, limit: 20)
      deltas << {
        "kind" => "semantic_ir_shape_delta",
        "summary" => "SemanticIR differs after identity fields are normalized.",
        "paths" => ir_paths
      } unless ir_paths.empty?
    end

    normalized_parsed_report = normalize_for_shape(parsed_report)
    normalized_typed_report = normalize_for_shape(typed_report)
    report_paths = diff_paths(normalized_parsed_report, normalized_typed_report, limit: 20)
    deltas << {
      "kind" => "report_shape_delta",
      "summary" => "CompilationReport differs after identity fields are normalized.",
      "paths" => report_paths
    } unless report_paths.empty?

    deltas
  end

  def value_delta(path, parsed, typed)
    return nil if parsed == typed

    {
      "kind" => "value_delta",
      "path" => path,
      "parsed" => parsed,
      "typed" => typed
    }
  end

  def missing_expected_node_kinds(summary, expected)
    actual = summary.fetch("node_kinds")
    expected.reject { |kind| actual.include?(kind) }
  end

  def node_kinds(semantic_ir)
    return [] unless semantic_ir

    semantic_ir.fetch("contracts", []).flat_map { |contract| contract.fetch("nodes", []) }
      .map { |node| node.fetch("kind") }
      .uniq
      .sort
  end

  def normalize_for_shape(value, key_name = nil)
    case value
    when Hash
      value.keys.sort.each_with_object({}) do |key, normalized|
        normalized[key] = identity_key?(key) ? "<identity>" : normalize_for_shape(value[key], key)
      end
    when Array
      value.map { |item| normalize_for_shape(item, key_name) }
    else
      key_name && identity_key?(key_name) ? "<identity>" : value
    end
  end

  def identity_key?(key)
    %w[program_id compilation_report_ref semantic_ir_ref contract_ref report_program_id].include?(key.to_s)
  end

  def diff_paths(left, right, path: "$", limit: 20)
    return [] if left == right
    return [{ "path" => path, "delta" => "class", "parsed" => left.class.name, "typed" => right.class.name }] unless left.class == right.class

    case left
    when Hash
      paths = []
      missing_in_typed = left.keys - right.keys
      missing_in_parsed = right.keys - left.keys
      missing_in_typed.each { |key| paths << { "path" => "#{path}.#{key}", "delta" => "missing_in_typed" } }
      missing_in_parsed.each { |key| paths << { "path" => "#{path}.#{key}", "delta" => "missing_in_parsed" } }
      (left.keys & right.keys).each do |key|
        break if paths.length >= limit

        paths.concat(diff_paths(left[key], right[key], path: "#{path}.#{key}", limit: limit - paths.length))
      end
      paths.first(limit)
    when Array
      paths = []
      paths << { "path" => path, "delta" => "length", "parsed" => left.length, "typed" => right.length } unless left.length == right.length
      [left.length, right.length].min.times do |index|
        break if paths.length >= limit

        paths.concat(diff_paths(left[index], right[index], path: "#{path}[#{index}]", limit: limit - paths.length))
      end
      paths.first(limit)
    else
      [{ "path" => path, "delta" => "value", "parsed" => left, "typed" => right }]
    end
  end

  def shape_hash(value)
    "sha256:#{Digest::SHA256.hexdigest(JSON.generate(normalize_for_shape(value)))}"
  end

  def blocked_items(source_cases)
    case_blocks = source_cases.flat_map do |source_case|
      next [] if source_case.fetch("status") == "PASS"

      source_case.fetch("deltas", []).map do |delta|
        {
          "case" => source_case.fetch("id"),
          "surface" => source_case.fetch("surface"),
          "kind" => delta.fetch("kind"),
          "summary" => delta.fetch("summary", delta.fetch("path", "shape delta")),
          "details" => delta
        }
      end
    end

    proof_local_blocks = PROOF_LOCAL_CASES.map do |entry|
      {
        "case" => entry.fetch("id"),
        "surface" => entry.fetch("surface"),
        "kind" => "not_source_comparable",
        "summary" => entry.fetch("reason")
      }
    end

    case_blocks + proof_local_blocks
  end

  def typed_source_blocked_items(source_cases)
    source_cases.flat_map do |source_case|
      source_case.fetch("deltas", []).filter_map do |delta|
        typed_source_blocking_delta?(delta) ? {
          "case" => source_case.fetch("id"),
          "surface" => source_case.fetch("surface"),
          "kind" => delta.fetch("kind"),
          "summary" => delta.fetch("summary", "typed source path is not ready"),
          "details" => delta
        } : nil
      end
    end
  end

  def typed_source_blocking_delta?(delta)
    return true if %w[parse_exception parse_error typed_path_error].include?(delta.fetch("kind"))

    delta.fetch("kind") == "typed_expected_nodes_missing"
  end

  def legacy_parity_delta_items(source_cases)
    source_cases.flat_map do |source_case|
      source_case.fetch("deltas", []).filter_map do |delta|
        next if typed_source_blocking_delta?(delta)

        {
          "case" => source_case.fetch("id"),
          "surface" => source_case.fetch("surface"),
          "kind" => delta.fetch("kind"),
          "summary" => delta.fetch("summary", delta.fetch("path", "legacy/typed parity delta")),
          "details" => delta
        }
      end
    end
  end

  def write_summary(summary)
    File.write(SUMMARY_PATH, "#{JSON.pretty_generate(summary)}\n")
  end

  def write_golden(summary)
    stable = summary.reject { |key, _value| key == "timestamp" }
    File.write(GOLDEN_REPORT_PATH, "#{JSON.pretty_generate(stable)}\n")
  end

  def print_summary(summary)
    puts "PASS typed_emission_main_path_parity"
    puts "verdict: #{summary.fetch("verdict")}"
    puts "safe_to_switch_production_path: #{summary.fetch("safe_to_switch_production_path")}"
    puts "cases_run: #{summary.fetch("cases_run")}"
    summary.fetch("source_cases").each do |source_case|
      puts "#{source_case.fetch("id")}: #{source_case.fetch("status")}"
    end
    summary.fetch("proof_local_cases").each do |entry|
      puts "#{entry.fetch("id")}: #{entry.fetch("status")}"
    end
    puts "blocked_items: #{summary.fetch("blocked_items").length}"
    puts "typed_source_blocked_items: #{summary.fetch("typed_source_blocked_items").length}"
    puts "legacy_parity_delta_items: #{summary.fetch("legacy_parity_delta_items").length}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
    puts "golden: #{GOLDEN_REPORT_PATH.relative_path_from(ROOT)}"
  end
end

TypedEmissionMainPathParity.run
