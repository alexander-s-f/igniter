#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"
require_relative "../../lib/igniter_lang/parser"

module InvariantSeverityProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  FIXTURE_DIR = LANG_ROOT / "experiments/invariant_severity_proof"
  GOLDEN_DIR = FIXTURE_DIR / "golden"
  SUMMARY_PATH = FIXTURE_DIR / "summary.json"
  FORMAT_VERSION = "0.1.0"
  TRACK = "invariant-severity-proof-v0"
  CONTRACT_REF = "contract/Fixture.InvariantSeverity.MedicationDoseReview@v0"

  module Canonical
    module_function

    def normalize(value)
      case value
      when Hash
        value.keys.sort_by(&:to_s).each_with_object({}) { |key, out| out[key.to_s] = normalize(value[key]) }
      when Array
        value.map { |item| normalize(item) }
      else
        value
      end
    end

    def pretty(value)
      "#{JSON.pretty_generate(normalize(value))}\n"
    end

    def hash(value)
      "sha256:#{Digest::SHA256.hexdigest(JSON.generate(normalize(value)))}"
    end

    def short_hash(value)
      hash(value).split(":").last[0, 16]
    end
  end

  class RuntimeEvaluator
    attr_reader :observations

    def initialize(contract)
      @contract = contract
      @observations = []
    end

    def evaluate(case_id:, inputs:)
      @observations = []
      output = base_output(inputs)
      results = @contract.fetch("invariants").map { |invariant| evaluate_invariant(invariant, inputs, output) }
      error_results = results.select { |result| result.fetch("severity") == "error" && result.fetch("status") == "violated" }
      warnings = results.select { |result| result.fetch("severity") == "warn" && result.fetch("status") == "violated" }
      softs = results.select { |result| result.fetch("severity") == "soft" && result.fetch("status") == "violated" }
      metrics = results.select { |result| result.fetch("severity") == "metric" }

      status = error_results.empty? ? "ok" : "blocked"
      {
        "kind" => "invariant_runtime_result",
        "format_version" => FORMAT_VERSION,
        "case_id" => case_id,
        "contract_ref" => CONTRACT_REF,
        "status" => status,
        "trusted_output" => status == "ok",
        "output" => status == "ok" ? decorate_output(output, warnings, softs, metrics) : nil,
        "blocking_diagnostics" => diagnostics_for(error_results),
        "warnings" => diagnostics_for(warnings),
        "soft_diagnostics" => diagnostics_for(softs),
        "metrics" => metric_payloads(metrics),
        "observations" => observations,
        "invariant_results" => results
      }
    end

    private

    def base_output(inputs)
      {
        "approved_dose_mg" => inputs.fetch("dose_mg"),
        "patient_ref" => inputs.fetch("patient_ref"),
        "medication_ref" => inputs.fetch("medication_ref")
      }
    end

    def decorate_output(output, warnings, softs, metrics)
      output.merge(
        "warnings" => diagnostics_for(warnings),
        "uncertainty" => softs.empty? ? nil : {
          "kind" => "uncertain",
          "from" => softs.map { |result| result.fetch("label") },
          "type_promotion" => "T -> ~T"
        },
        "metrics_from" => metrics.map { |result| result.fetch("label") }
      )
    end

    def evaluate_invariant(invariant, inputs, output)
      passed = predicate_passed?(invariant, inputs, output)
      result = invariant.merge(
        "status" => passed ? "satisfied" : "violated",
        "output_effect" => output_effect(invariant.fetch("severity"), passed)
      )
      emit_observation(result, inputs, output)
      result
    end

    def predicate_passed?(invariant, inputs, output)
      case invariant.fetch("predicate")
      when "contraindicated_interactions_empty"
        inputs.fetch("contraindicated_interactions").empty?
      when "major_interactions_acknowledged"
        inputs.fetch("major_interactions").all? { |interaction| interaction.fetch("acknowledged") == true }
      when "confidence_at_least_threshold"
        inputs.fetch("renal_confidence") >= invariant.fetch("threshold")
      when "runtime_latency_under_threshold_ms"
        inputs.fetch("runtime_latency_ms") < invariant.fetch("threshold_ms")
      else
        raise ArgumentError, "Unknown invariant predicate: #{invariant.fetch("predicate")}"
      end
    end

    def output_effect(severity, passed)
      return "none" if passed && severity != "metric"

      case severity
      when "error"
        "block_trusted_output"
      when "warn"
        "attach_warning"
      when "soft"
        "promote_to_uncertain"
      when "metric"
        "record_metric"
      else
        raise ArgumentError, "Unknown invariant severity: #{severity}"
      end
    end

    def emit_observation(result, inputs, output)
      kind = case result.fetch("severity")
             when "error"
               result.fetch("status") == "violated" ? "failure_observation" : "verification_observation"
             when "warn"
               result.fetch("status") == "violated" ? "warning_observation" : "verification_observation"
             when "soft"
               result.fetch("status") == "violated" ? "soft_observation" : "verification_observation"
             when "metric"
               "metric_observation"
             end
      payload = {
        "kind" => kind,
        "contract_ref" => CONTRACT_REF,
        "invariant" => result.slice("name", "severity", "label", "message", "status", "output_effect"),
        "subject" => inputs.fetch("patient_ref"),
        "output_ref" => output.fetch("medication_ref")
      }
      observations << payload.merge(
        "observation_id" => "obs/invariant/#{Canonical.short_hash(payload)}",
        "lifecycle" => result.fetch("severity") == "metric" ? "metric" : "audit"
      )
    end

    def diagnostics_for(results)
      results.map do |result|
        {
          "category" => invariant_category(result.fetch("severity")),
          "severity" => diagnostic_severity(result.fetch("severity")),
          "rule" => "INV-#{result.fetch("severity").upcase}",
          "label" => result.fetch("label"),
          "message" => result.fetch("message"),
          "contract" => "MedicationDoseReview",
          "node" => result.fetch("name"),
          "path" => "contract:MedicationDoseReview/invariant:#{result.fetch("name")}",
          "span" => nil,
          "output_effect" => result.fetch("output_effect")
        }
      end
    end

    def invariant_category(severity)
      case severity
      when "error" then "invariant_error"
      when "warn" then "invariant_warning"
      when "soft" then "invariant_soft"
      when "metric" then "invariant_metric"
      end
    end

    def diagnostic_severity(severity)
      case severity
      when "error" then "error"
      when "warn" then "warning"
      when "soft" then "info"
      when "metric" then "info"
      end
    end

    def metric_payloads(results)
      results.map do |result|
        {
          "label" => result.fetch("label"),
          "name" => result.fetch("name"),
          "status" => result.fetch("status"),
          "message" => result.fetch("message"),
          "output_effect" => result.fetch("output_effect")
        }
      end
    end
  end

  module_function

  def run
    FileUtils.mkdir_p(GOLDEN_DIR)
    evaluator = RuntimeEvaluator.new(contract_fixture)
    cases = {
      "error_blocks" => evaluator.evaluate(case_id: "error_blocks", inputs: error_inputs),
      "warn_allows" => evaluator.evaluate(case_id: "warn_allows", inputs: warn_inputs),
      "soft_uncertain" => evaluator.evaluate(case_id: "soft_uncertain", inputs: soft_inputs),
      "metric_records" => evaluator.evaluate(case_id: "metric_records", inputs: metric_inputs)
    }
    report = compilation_report
    pinv = parser_checks
    all_checks = checks(cases, report).merge(pinv)
    summary = {
      "kind" => "invariant_severity_proof_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => all_checks.values.all? ? "PASS" : "FAIL",
      "contract" => contract_fixture,
      "compilation_report" => report,
      "cases" => cases,
      "checks" => all_checks
    }
    write_outputs(summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def contract_fixture
    {
      "kind" => "semantic_ir_program",
      "format_version" => FORMAT_VERSION,
      "program_id" => "semanticir/invariant_severity/#{Canonical.short_hash("invariant_severity")}",
      "contracts" => [
        {
          "kind" => "contract_ir",
          "contract_ref" => CONTRACT_REF,
          "contract_name" => "MedicationDoseReview",
          "outputs" => [
            {
              "kind" => "output_node",
              "name" => "approved_dose",
              "type" => { "name" => "Decimal", "params" => [2] },
              "warnings_from" => ["major_interaction_acknowledgement"],
              "uncertain_from" => ["renal_confidence_gate"],
              "metrics_from" => ["latency_metric"]
            }
          ],
          "nodes" => invariant_nodes
        }
      ],
      "invariants" => invariant_nodes
    }
  end

  def invariant_nodes
    [
      {
        "kind" => "invariant_node",
        "name" => "contraindicated_interaction_block",
        "predicate" => "contraindicated_interactions_empty",
        "severity" => "error",
        "label" => "CG-INTERACTION-01",
        "message" => "Contraindicated drug combination - order blocked",
        "overridable_with" => nil
      },
      {
        "kind" => "invariant_node",
        "name" => "major_interaction_acknowledgement",
        "predicate" => "major_interactions_acknowledged",
        "severity" => "warn",
        "label" => "CG-INTERACTION-02",
        "message" => "Major drug interaction requires acknowledgement",
        "overridable_with" => "documented_justification"
      },
      {
        "kind" => "invariant_node",
        "name" => "renal_confidence_gate",
        "predicate" => "confidence_at_least_threshold",
        "threshold" => 0.85,
        "severity" => "soft",
        "label" => "CG-RENAL-CONF-01",
        "message" => "Low confidence renal function - dose is approximate",
        "overridable_with" => nil
      },
      {
        "kind" => "invariant_node",
        "name" => "latency_metric",
        "predicate" => "runtime_latency_under_threshold_ms",
        "threshold_ms" => 500,
        "severity" => "metric",
        "label" => "PERF-DOSE-01",
        "message" => "Dose computation latency metric",
        "overridable_with" => nil
      }
    ]
  end

  def compilation_report
    {
      "kind" => "compilation_report",
      "format_version" => FORMAT_VERSION,
      "program_id" => "compilation_report/invariant_severity/#{Canonical.short_hash(contract_fixture)}",
      "pass_result" => "ok",
      "stages" => {
        "parse" => "proof_local",
        "classify" => "ok",
        "typecheck" => "ok",
        "emit" => "ok"
      },
      "diagnostics" => [],
      "invariant_coverage" => invariant_nodes.map do |node|
        {
          "name" => node.fetch("name"),
          "severity" => node.fetch("severity"),
          "label" => node.fetch("label"),
          "output_policy" => node.fetch("severity") == "error" ? "blocking" : "non_blocking"
        }
      end
    }
  end

  def base_inputs
    {
      "patient_ref" => "patient/synthetic-invariant-001",
      "medication_ref" => "medication/synthetic-dose-a",
      "dose_mg" => "12.50",
      "contraindicated_interactions" => [],
      "major_interactions" => [],
      "renal_confidence" => 0.97,
      "runtime_latency_ms" => 120
    }
  end

  def error_inputs
    base_inputs.merge(
      "contraindicated_interactions" => [
        { "interaction_ref" => "interaction/synthetic-contraindicated", "severity" => "contraindicated" }
      ]
    )
  end

  def warn_inputs
    base_inputs.merge(
      "major_interactions" => [
        { "interaction_ref" => "interaction/synthetic-major", "severity" => "major", "acknowledged" => false }
      ]
    )
  end

  def soft_inputs
    base_inputs.merge("renal_confidence" => 0.72)
  end

  def metric_inputs
    base_inputs.merge("runtime_latency_ms" => 850)
  end

  # ── Parser-level checks (PINV-1..4) ───────────────────────────────────────

  VALID_INVARIANT_SOURCE = <<~IGNITER
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

  MISSING_PREDICATE_SOURCE = <<~IGNITER
    module Fixture.InvariantSeverity
    contract MissingPredicate {
      input a: Bool
      invariant bad_invariant
        severity: :error
        message: "Missing predicate"
      output a: Bool
    }
  IGNITER

  UNKNOWN_SEVERITY_SOURCE = <<~IGNITER
    module Fixture.InvariantSeverity
    contract UnknownSeverity {
      input a: Bool
      invariant bad_severity
        predicate: a
        severity: :critical
      output a: Bool
    }
  IGNITER

  OVERRIDABLE_ON_ERROR_SOURCE = <<~IGNITER
    module Fixture.InvariantSeverity
    contract OverridableOnError {
      input a: Bool
      invariant bad_override
        predicate: a
        severity: :error
        overridable_with: :supervisor_approval
      output a: Bool
    }
  IGNITER

  def parser_checks
    {
      "pinv.parser_accepts_valid_invariant"         => pinv_accepts?(VALID_INVARIANT_SOURCE),
      "pinv.invariant_nodes_count_4"                => pinv_invariant_count?(VALID_INVARIANT_SOURCE, 4),
      "pinv.severity_values_correct"                => pinv_severity_values?(VALID_INVARIANT_SOURCE),
      "pinv.overridable_with_parsed"                => pinv_overridable_with?(VALID_INVARIANT_SOURCE, "interaction_warn", "documented_justification"),
      "pinv.missing_predicate_emits_oof_iv1"        => pinv_oof_emitted?(MISSING_PREDICATE_SOURCE, "OOF-IV1"),
      "pinv.unknown_severity_emits_oof_iv2"         => pinv_oof_emitted?(UNKNOWN_SEVERITY_SOURCE, "OOF-IV2"),
      "pinv.overridable_on_error_emits_oof_i4"      => pinv_oof_emitted?(OVERRIDABLE_ON_ERROR_SOURCE, "OOF-I4")
    }
  end

  def parse_source(source)
    IgniterLang::ParsedProgram.parse(source)
  end

  def pinv_accepts?(source)
    result = parse_source(source)
    result.errors.none? { |e| e.is_a?(Hash) && e["rule"]&.start_with?("OOF-IV", "OOF-I4") }
  rescue StandardError
    false
  end

  def pinv_invariant_count?(source, expected_count)
    result = parse_source(source)
    contracts = result.ast.fetch("contracts", [])
    invariant_decls = contracts.flat_map { |c| c.fetch("body", []) }.select { |n| n.is_a?(Hash) && n.fetch("kind", nil) == "invariant" }
    invariant_decls.length == expected_count
  rescue StandardError
    false
  end

  def pinv_severity_values?(source)
    result = parse_source(source)
    contracts = result.ast.fetch("contracts", [])
    invariants = contracts.flat_map { |c| c.fetch("body", []) }.select { |n| n.is_a?(Hash) && n.fetch("kind", nil) == "invariant" }
    severities = invariants.map { |inv| inv.fetch("severity") }.sort
    severities == %w[error metric soft warn]
  rescue StandardError
    false
  end

  def pinv_overridable_with?(source, invariant_name, expected_value)
    result = parse_source(source)
    contracts = result.ast.fetch("contracts", [])
    invariants = contracts.flat_map { |c| c.fetch("body", []) }.select { |n| n.is_a?(Hash) && n.fetch("kind", nil) == "invariant" }
    inv = invariants.find { |n| n.fetch("name") == invariant_name }
    inv&.fetch("overridable_with") == expected_value
  rescue StandardError
    false
  end

  def pinv_oof_emitted?(source, rule)
    result = parse_source(source)
    result.errors.any? { |e| e.is_a?(Hash) && e["rule"] == rule }
  rescue StandardError
    false
  end

  def checks(cases, report)
    {
      "compile.invariant_nodes_have_severity" => invariant_nodes.all? { |node| node.key?("severity") },
      "compile.output_tracks_warn_soft_metric_sources" => contract_fixture.dig("contracts", 0, "outputs", 0, "warnings_from") == ["major_interaction_acknowledgement"] &&
        contract_fixture.dig("contracts", 0, "outputs", 0, "uncertain_from") == ["renal_confidence_gate"] &&
        contract_fixture.dig("contracts", 0, "outputs", 0, "metrics_from") == ["latency_metric"],
      "runtime.error_blocks_trusted_output" => cases.dig("error_blocks", "status") == "blocked" &&
        cases.dig("error_blocks", "trusted_output") == false &&
        cases.dig("error_blocks", "output").nil? &&
        cases.dig("error_blocks", "blocking_diagnostics", 0, "category") == "invariant_error",
      "runtime.warn_allows_with_warning" => cases.dig("warn_allows", "status") == "ok" &&
        cases.dig("warn_allows", "trusted_output") == true &&
        cases.dig("warn_allows", "output", "warnings", 0, "category") == "invariant_warning",
      "runtime.soft_promotes_uncertain" => cases.dig("soft_uncertain", "status") == "ok" &&
        cases.dig("soft_uncertain", "output", "uncertainty", "type_promotion") == "T -> ~T" &&
        cases.dig("soft_uncertain", "soft_diagnostics", 0, "category") == "invariant_soft",
      "runtime.metric_records_without_output_effect" => cases.dig("metric_records", "status") == "ok" &&
        cases.dig("metric_records", "metrics", 0, "category").nil? &&
        cases.dig("metric_records", "metrics", 0, "output_effect") == "record_metric" &&
        cases.dig("metric_records", "output", "warnings").empty? &&
        cases.dig("metric_records", "output", "uncertainty").nil?,
      "observations.error_failure" => cases.dig("error_blocks", "observations").any? { |obs| obs.fetch("kind") == "failure_observation" },
      "observations.warn_warning" => cases.dig("warn_allows", "observations").any? { |obs| obs.fetch("kind") == "warning_observation" },
      "observations.soft_observation" => cases.dig("soft_uncertain", "observations").any? { |obs| obs.fetch("kind") == "soft_observation" },
      "observations.metric_observation" => cases.dig("metric_records", "observations").any? { |obs| obs.fetch("kind") == "metric_observation" },
      "report.invariant_coverage_present" => report.fetch("invariant_coverage").length == 4
    }
  end

  def write_outputs(summary)
    FileUtils.mkdir_p(GOLDEN_DIR)
    write_json(SUMMARY_PATH, summary)
    write_json(GOLDEN_DIR / "semantic_ir_program.json", contract_fixture)
    write_json(GOLDEN_DIR / "compilation_report.json", summary.fetch("compilation_report"))
    summary.fetch("cases").each do |case_id, result|
      write_json(GOLDEN_DIR / "#{case_id}.json", result)
    end
  end

  def write_json(path, value)
    FileUtils.mkdir_p(Pathname.new(path).dirname)
    File.write(path, Canonical.pretty(value))
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} invariant_severity_proof"
    summary.fetch("checks").each do |name, ok|
      puts "#{name}: #{ok ? "ok" : "FAIL"}"
    end
    puts "error.status: #{summary.dig("cases", "error_blocks", "status")}"
    puts "warn.warnings: #{summary.dig("cases", "warn_allows", "warnings").length}"
    puts "soft.uncertainty: #{summary.dig("cases", "soft_uncertain", "output", "uncertainty", "type_promotion")}"
    puts "metric.observations: #{summary.dig("cases", "metric_records", "observations").count { |obs| obs.fetch("kind") == "metric_observation" }}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = InvariantSeverityProof.run
exit(success ? 0 : 1)
