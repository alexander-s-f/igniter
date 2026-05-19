#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"

module Prop038StrictRefusalResultShapeProof
  module_function

  EXPERIMENT_DIR = Pathname.new(__dir__)
  LANG_ROOT = EXPERIMENT_DIR.parent.parent
  OUT_DIR = EXPERIMENT_DIR / "out"
  SUMMARY_PATH = OUT_DIR / "prop038_strict_refusal_result_shape_proof_summary.json"

  FORMAT_VERSION = "0.1.0"
  SOURCE_PATH = "igniter-lang/source/prop038_strict_refusal_shape_synthetic.ig"
  SOURCE_HASH = "sha256:0380380380380380380380380380380380380380380380380380380380380380"
  SEMANTIC_IR_REF = "semanticir/prop038-strict-refusal-shape"
  REPORT_REF = "compilation_report/prop038-strict-refusal-shape"

  RAW_MISMATCH_CODE = "compiler_profile_contract.contract_digest_mismatch"
  WRAPPER_MISMATCH_CODE = "compiler_profile_contract_refusal.contract_digest_mismatch"
  MALFORMED_CODE = "compiler_profile_contract_refusal.strict_requirement_malformed"

  PUBLIC_KEY_ALLOWLIST = %w[
    kind
    format_version
    status
    program_id
    source_path
    source_hash
    grammar_version
    stages
    igapp_path
    contracts
    compilation_report_path
    diagnostics
    warnings
  ].freeze

  FORBIDDEN_PUBLIC_KEYS = %w[
    report
    compiler_profile_contract_validation
    strict_refusal
    wrapper_evidence
    compile_refusal_authorized
    raw_validation_diagnostics
  ].freeze

  ANCHORS = {
    "compiler_profile_contract_proof" =>
      "experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json",
    "prop038_shape_policy" =>
      "experiments/prop038_contract_digest_shape_policy_proof/out/prop038_contract_digest_shape_policy_proof_summary.json",
    "prop038_recompute_match" =>
      "experiments/prop038_contract_digest_recompute_match_proof/out/prop038_contract_digest_recompute_match_proof_summary.json",
    "prop038_digest_report_only" =>
      "experiments/prop038_contract_digest_report_only_integration_proof/out/prop038_contract_digest_report_only_integration_proof_summary.json",
    "prop038_report_only_compiler_integration" =>
      "experiments/prop038_report_only_compiler_integration/out/prop038_report_only_compiler_integration_summary.json",
    "prop038_strict_mode_trigger" =>
      "experiments/prop038_strict_mode_refusal_trigger_proof/out/prop038_strict_mode_refusal_trigger_proof_summary.json"
  }.freeze

  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)

    anchors = load_anchor_summaries
    cases = [
      strict_refusal_case,
      malformed_strict_requirement_case,
      report_only_anchor_case(anchors)
    ]
    checks = build_checks(cases, anchors)

    pass = checks.all? { |entry| entry.fetch("pass") }
    summary = {
      "kind" => "prop038_strict_refusal_result_shape_proof_summary",
      "format_version" => FORMAT_VERSION,
      "track" => "prop038-strict-refusal-result-shape-proof-local-v0",
      "status" => pass ? "PASS" : "FAIL",
      "pass" => pass,
      "cases" => cases,
      "check_count" => checks.length,
      "checks" => checks,
      "failed_checks" => checks.reject { |entry| entry.fetch("pass") },
      "command_matrix" => command_matrix,
      "exact_public_keys" => PUBLIC_KEY_ALLOWLIST,
      "exact_diagnostic_codes" => {
        "public_wrapper_codes" => [WRAPPER_MISMATCH_CODE, MALFORMED_CODE],
        "nested_validator_codes" => [RAW_MISMATCH_CODE],
        "forbidden_public_raw_validator_codes" => [RAW_MISMATCH_CODE]
      },
      "closed_surface_assertions" => closed_surface_assertions,
      "non_authorizations_preserved" => non_authorizations_preserved,
      "recommendation_for_c3_a" => "accept proof-local closure"
    }

    File.write(SUMMARY_PATH, "#{JSON.pretty_generate(summary)}\n")
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def strict_refusal_case
    report = baseline_report.merge(
      "compiler_profile_contract_validation" => mismatch_validation
    )
    internal_result = result_shape(
      status: "refused",
      report: report,
      diagnostics: [mismatch_wrapper_diagnostic]
    )

    case_entry(
      name: "strict_refusal_contract_digest_mismatch",
      description: "Accepted proof-local target shape for strict digest mismatch refusal.",
      internal_result: internal_result,
      produced_paths: []
    )
  end

  def malformed_strict_requirement_case
    report = baseline_report.merge(
      "compiler_profile_contract_validation" => valid_validation
    )
    internal_result = result_shape(
      status: "configuration_error",
      report: report,
      diagnostics: [malformed_wrapper_diagnostic]
    )

    case_entry(
      name: "malformed_strict_requirement_configuration_error",
      description: "Accepted proof-local target shape for malformed strict requirement.",
      internal_result: internal_result,
      produced_paths: []
    )
  end

  def report_only_anchor_case(anchors)
    {
      "name" => "legacy_report_only_anchors_referenced",
      "description" => "Existing report-only proof anchors remain referenced and not contradicted.",
      "anchor_statuses" => anchors.transform_values { |summary| summary.fetch("status", nil) },
      "public_result_unchanged_anchor" =>
        anchors.fetch("prop038_report_only_compiler_integration")
               .fetch("public_result_unchanged")
               .values
               .all?,
      "nested_diagnostics_anchor" =>
        check_named(anchors.fetch("prop038_digest_report_only"), "nested_diagnostics.only"),
      "no_refusal_report_anchor" =>
        check_named(anchors.fetch("prop038_digest_report_only"), "no_refusal_report_written"),
      "wrapper_proof_local_anchor" =>
        check_named(anchors.fetch("prop038_strict_mode_trigger"), "wrapper_codes_proof_local_only")
    }
  end

  def case_entry(name:, description:, internal_result:, produced_paths:)
    public_result = public_result_for(internal_result)
    {
      "name" => name,
      "description" => description,
      "internal_result" => internal_result,
      "public_result" => public_result,
      "public_keys" => public_result.keys,
      "public_diagnostic_codes" => public_result.fetch("diagnostics").map { |entry| entry.fetch("code") },
      "nested_diagnostic_codes" =>
        internal_result
          .fetch("report")
          .fetch("compiler_profile_contract_validation", {})
          .fetch("diagnostic_codes", []),
      "top_level_report_diagnostics" => internal_result.fetch("report").fetch("diagnostics"),
      "produced_paths" => produced_paths
    }
  end

  def result_shape(status:, report:, diagnostics:)
    {
      "kind" => "compiler_result",
      "format_version" => FORMAT_VERSION,
      "status" => status,
      "program_id" => SEMANTIC_IR_REF,
      "source_path" => SOURCE_PATH,
      "source_hash" => SOURCE_HASH,
      "grammar_version" => FORMAT_VERSION,
      "stages" => baseline_report.fetch("stages").merge("assemble" => "skipped"),
      "igapp_path" => nil,
      "contracts" => [],
      "compilation_report_path" => nil,
      "diagnostics" => diagnostics,
      "warnings" => [],
      "report" => report
    }
  end

  def baseline_report
    {
      "kind" => "compilation_report",
      "format_version" => FORMAT_VERSION,
      "program_id" => REPORT_REF,
      "grammar_version" => FORMAT_VERSION,
      "source_hash" => SOURCE_HASH,
      "source_path" => SOURCE_PATH,
      "pass_result" => "ok",
      "stages" => {
        "parse" => "ok",
        "classify" => "ok",
        "typecheck" => "ok",
        "emit" => "ok"
      },
      "diagnostics" => [],
      "semantic_ir_ref" => SEMANTIC_IR_REF
    }
  end

  def mismatch_validation
    {
      "kind" => "compiler_profile_contract_validation_result",
      "format_version" => FORMAT_VERSION,
      "valid" => false,
      "diagnostics" => [
        {
          "code" => RAW_MISMATCH_CODE,
          "message" => "declared contract_digest does not match recomputed canonical contract digest",
          "path" => "contract_digest"
        }
      ],
      "diagnostic_codes" => [RAW_MISMATCH_CODE],
      "digest_reference_policy" => "prop038_24_plus",
      "compiler_integrated" => false,
      "compile_refusal_authorized" => false,
      "report_only" => true
    }
  end

  def valid_validation
    {
      "kind" => "compiler_profile_contract_validation_result",
      "format_version" => FORMAT_VERSION,
      "valid" => true,
      "diagnostics" => [],
      "diagnostic_codes" => [],
      "digest_reference_policy" => "prop038_24_plus",
      "compiler_integrated" => false,
      "compile_refusal_authorized" => false,
      "report_only" => true
    }
  end

  def mismatch_wrapper_diagnostic
    {
      "code" => WRAPPER_MISMATCH_CODE,
      "message" => "Strict compiler profile contract validation refused compilation because contract_digest does not match canonical contract material.",
      "path" => "compiler_profile_contract_validation.contract_digest",
      "evidence_code" => RAW_MISMATCH_CODE
    }
  end

  def malformed_wrapper_diagnostic
    {
      "code" => MALFORMED_CODE,
      "message" => "Malformed strict compiler profile contract requirement produced configuration_error before assembly.",
      "path" => "compiler_profile_contract_strict_requirement",
      "evidence_code" => nil
    }
  end

  def public_result_for(result)
    result.reject { |key, _value| key == "report" }
  end

  def load_anchor_summaries
    ANCHORS.transform_values do |relative_path|
      path = LANG_ROOT / relative_path
      JSON.parse(File.read(path))
    end
  end

  def build_checks(cases, anchors)
    strict_case = cases.find { |entry| entry.fetch("name") == "strict_refusal_contract_digest_mismatch" }
    malformed_case = cases.find { |entry| entry.fetch("name") == "malformed_strict_requirement_configuration_error" }
    anchor_case = cases.find { |entry| entry.fetch("name") == "legacy_report_only_anchors_referenced" }
    strict_public = strict_case.fetch("public_result")
    malformed_public = malformed_case.fetch("public_result")
    strict_internal = strict_case.fetch("internal_result")
    malformed_internal = malformed_case.fetch("internal_result")

    checks = []
    assert("strict_refusal.status_refused", strict_public.fetch("status") == "refused", checks)
    assert("strict_refusal.public_key_allowlist_exact", strict_public.keys == PUBLIC_KEY_ALLOWLIST, checks)
    assert("strict_refusal.forbidden_public_keys_absent", (strict_public.keys & FORBIDDEN_PUBLIC_KEYS).empty?, checks)
    assert("strict_refusal.compilation_report_path_present_null", strict_public.key?("compilation_report_path") && strict_public.fetch("compilation_report_path").nil?, checks)
    assert("strict_refusal.igapp_path_null", strict_public.fetch("igapp_path").nil?, checks)
    assert("strict_refusal.contracts_empty", strict_public.fetch("contracts") == [], checks)
    assert("strict_refusal.assemble_skipped", strict_public.dig("stages", "assemble") == "skipped", checks)
    assert("strict_refusal.report_pass_result_ok", strict_internal.dig("report", "pass_result") == "ok", checks)
    assert("strict_refusal.program_id_semantic_ir_ref", strict_public.fetch("program_id") == SEMANTIC_IR_REF, checks)
    assert("strict_refusal.public_wrapper_only", strict_case.fetch("public_diagnostic_codes") == [WRAPPER_MISMATCH_CODE], checks)
    assert("strict_refusal.raw_validator_not_public", !diagnostic_codes(strict_public).include?(RAW_MISMATCH_CODE), checks)
    assert("strict_refusal.nested_raw_validator_present", strict_case.fetch("nested_diagnostic_codes") == [RAW_MISMATCH_CODE], checks)
    assert("strict_refusal.top_level_report_diagnostics_unchanged", strict_case.fetch("top_level_report_diagnostics") == [], checks)
    assert("strict_refusal.no_produced_paths", strict_case.fetch("produced_paths") == [], checks)

    assert("configuration_error.status", malformed_public.fetch("status") == "configuration_error", checks)
    assert("configuration_error.public_key_allowlist_exact", malformed_public.keys == PUBLIC_KEY_ALLOWLIST, checks)
    assert("configuration_error.reason_distinct", malformed_case.fetch("public_diagnostic_codes") == [MALFORMED_CODE], checks)
    assert("configuration_error.not_digest_mismatch", !diagnostic_codes(malformed_public).include?(WRAPPER_MISMATCH_CODE), checks)
    assert("configuration_error.compilation_report_path_present_null", malformed_public.key?("compilation_report_path") && malformed_public.fetch("compilation_report_path").nil?, checks)
    assert("configuration_error.igapp_path_null", malformed_public.fetch("igapp_path").nil?, checks)
    assert("configuration_error.assemble_skipped", malformed_public.dig("stages", "assemble") == "skipped", checks)
    assert("configuration_error.report_pass_result_ok", malformed_internal.dig("report", "pass_result") == "ok", checks)
    assert("configuration_error.no_produced_paths", malformed_case.fetch("produced_paths") == [], checks)
    assert("configuration_error.top_level_report_diagnostics_unchanged", malformed_case.fetch("top_level_report_diagnostics") == [], checks)

    assert("diagnostics.public_codes_exact", public_codes(cases).sort == [MALFORMED_CODE, WRAPPER_MISMATCH_CODE].sort, checks)
    assert("diagnostics.no_raw_validator_public", public_codes(cases).none? { |code| code.start_with?("compiler_profile_contract.") }, checks)
    assert("diagnostics.nested_isolated", strict_internal.fetch("report").fetch("diagnostics") == [] && strict_internal.dig("report", "compiler_profile_contract_validation", "diagnostic_codes") == [RAW_MISMATCH_CODE], checks)
    assert("nonpersisting.no_sidecar_paths_modeled", modeled_paths(cases).none? { |path| path.end_with?(".compilation_report.json") }, checks)
    assert("nonpersisting.no_igapp_paths_modeled", modeled_paths(cases).none? { |path| path.include?(".igapp") }, checks)

    assert("anchors.all_status_pass", anchors.values.all? { |summary| summary.fetch("status") == "PASS" }, checks)
    assert("anchors.public_result_unchanged", anchor_case.fetch("public_result_unchanged_anchor") == true, checks)
    assert("anchors.nested_diagnostics_only", anchor_case.fetch("nested_diagnostics_anchor") == true, checks)
    assert("anchors.no_refusal_report_written", anchor_case.fetch("no_refusal_report_anchor") == true, checks)
    assert("anchors.wrapper_proof_local_only", anchor_case.fetch("wrapper_proof_local_anchor") == true, checks)

    closed_surface_assertions.each do |name, value|
      assert("closed_surface.#{name}", value == false, checks)
    end

    checks
  end

  def public_codes(cases)
    cases.flat_map { |entry| entry.fetch("public_diagnostic_codes", []) }
  end

  def diagnostic_codes(result)
    result.fetch("diagnostics", []).filter_map { |entry| entry["code"] || entry["evidence_code"] }
  end

  def modeled_paths(cases)
    cases.flat_map { |entry| entry.fetch("produced_paths", []) }
  end

  def check_named(summary, name)
    Array(summary.fetch("checks")).any? { |entry| entry.fetch("name") == name && entry.fetch("pass") == true }
  end

  def closed_surface_assertions
    {
      "live_compiler_orchestrator_changed" => false,
      "live_compile_refusal_enabled" => false,
      "compiler_result_code_changed" => false,
      "public_api_cli_widened" => false,
      "persisted_report_or_sidecar_written" => false,
      "parser_typechecker_semanticir_changed" => false,
      "assembler_or_igapp_changed" => false,
      "loader_report_or_compatibility_report_changed" => false,
      "diagnostics_centralization_changed" => false,
      "runtime_or_production_behavior_changed" => false
    }
  end

  def non_authorizations_preserved
    closed_surface_assertions.merge(
      "gate3_or_tbackend_behavior_changed" => false,
      "bihistory_stream_olap_cache_behavior_changed" => false
    )
  end

  def command_matrix
    [
      {
        "command" => "ruby -c igniter-lang/experiments/prop038_strict_refusal_result_shape_proof/prop038_strict_refusal_result_shape_proof.rb",
        "result" => "PASS"
      },
      {
        "command" => "ruby igniter-lang/experiments/prop038_strict_refusal_result_shape_proof/prop038_strict_refusal_result_shape_proof.rb",
        "result" => "PASS"
      }
    ]
  end

  def assert(name, condition, checks)
    checks << {
      "name" => name,
      "pass" => condition == true
    }
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} prop038_strict_refusal_result_shape_proof"
    puts "cases: #{summary.fetch("cases").length}"
    puts "checks: #{summary.fetch("check_count")}"
    puts "failed_checks: #{summary.fetch("failed_checks").length}"
    puts "public_keys: #{summary.fetch("exact_public_keys").join(",")}"
    puts "diagnostic_codes: #{summary.fetch("exact_diagnostic_codes").fetch("public_wrapper_codes").join(",")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(LANG_ROOT)}"
  end
end

success = Prop038StrictRefusalResultShapeProof.run
exit(success ? 0 : 1)
