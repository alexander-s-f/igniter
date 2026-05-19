# frozen_string_literal: true

require "fileutils"
require "json"

require_relative "../../lib/igniter_lang/compiler_profile_contract_validator"

ROOT = File.expand_path("../../..", __dir__)
OUT_DIR = File.join(__dir__, "out")
SUMMARY_PATH = File.join(OUT_DIR, "prop038_strict_mode_refusal_trigger_proof_summary.json")
CONTRACT_SUMMARY_PATH = File.join(
  ROOT,
  "igniter-lang/experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json"
)

FORMAT_VERSION = "0.1.0"
TRACK = "prop038-strict-mode-refusal-trigger-proof-local-v0"
VALIDATOR = IgniterLang::CompilerProfileContractValidator
MISMATCH_CODE = "compiler_profile_contract.contract_digest_mismatch"
INVALID_CODE = "compiler_profile_contract.contract_digest_invalid"
UNSUPPORTED_POLICY_CODE = "compiler_profile_contract.contract_digest_policy_unsupported"
RECOMPUTE_UNAVAILABLE_CODE = "compiler_profile_contract.contract_digest_recompute_unavailable"
WRAPPER_MISMATCH_CODE = "compiler_profile_contract_refusal.contract_digest_mismatch"

STRICT_REQUIREMENT = {
  "kind" => "compiler_profile_contract_strict_requirement",
  "format_version" => FORMAT_VERSION,
  "mode" => "strict_contract_digest",
  "source" => "proof_local_gate",
  "refusal_candidates" => [
    MISMATCH_CODE
  ],
  "recompute_unavailable_policy" => "fail_open_report_only",
  "compile_refusal_authorized" => false
}.freeze

EXPECTED_PUBLIC_RESULT = {
  "status" => "ok",
  "artifact" => "compiled_program/add"
}.freeze

EXPECTED_BASE_REPORT = {
  "kind" => "compilation_report",
  "format_version" => FORMAT_VERSION,
  "pass_result" => "ok",
  "stages" => {
    "parse" => "ok",
    "classify" => "ok",
    "typecheck" => "ok",
    "emit" => "ok"
  },
  "diagnostics" => [],
  "semantic_ir_ref" => "semantic_ir/add"
}.freeze

EXPECTED_MANIFEST = {
  "kind" => "igapp_manifest",
  "format_version" => FORMAT_VERSION,
  "semantic_ir_ref" => "semantic_ir/add",
  "compiler_profile_id" => "compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7"
}.freeze

def read_json(path)
  JSON.parse(File.read(path))
end

def deep_copy(value)
  Marshal.load(Marshal.dump(value))
end

def baseline_compile
  {
    "status" => "ok",
    "result" => {
      "status" => "ok",
      "igapp_path" => "/proof-local/out/add.igapp",
      "artifact" => "compiled_program/add"
    },
    "public_result" => deep_copy(EXPECTED_PUBLIC_RESULT),
    "report" => deep_copy(EXPECTED_BASE_REPORT),
    "manifest" => deep_copy(EXPECTED_MANIFEST),
    "assembler_executed" => true,
    "refusal_report_written" => false,
    "compiler_result_changed" => false,
    "igapp_mutated" => false,
    "loader_report_touched" => false,
    "compatibility_report_touched" => false,
    "runtime_touched" => false,
    "production_touched" => false
  }
end

def same_outcome?(baseline, run)
  run.fetch("status") == baseline.fetch("status") &&
    run.fetch("public_result") == baseline.fetch("public_result") &&
    run.fetch("manifest") == baseline.fetch("manifest") &&
    run.fetch("report").fetch("pass_result") == baseline.fetch("report").fetch("pass_result") &&
    run.fetch("report").fetch("stages") == baseline.fetch("report").fetch("stages") &&
    run.fetch("report").fetch("diagnostics") == baseline.fetch("report").fetch("diagnostics") &&
    run.fetch("assembler_executed") == baseline.fetch("assembler_executed") &&
    run.fetch("refusal_report_written") == false &&
    run.fetch("compiler_result_changed") == false &&
    run.fetch("igapp_mutated") == false &&
    run.fetch("loader_report_touched") == false &&
    run.fetch("compatibility_report_touched") == false &&
    run.fetch("runtime_touched") == false &&
    run.fetch("production_touched") == false
end

def annotate_report_only(baseline, validation)
  run = deep_copy(baseline)
  return run unless validation

  run["report"] = run.fetch("report").merge(
    "compiler_profile_contract_validation" => validation.merge("report_only" => true)
  )
  run
end

def replace_first_hex_char(ref)
  ref.sub(/sha256:([0-9a-f])/) do
    first = Regexp.last_match(1)
    "sha256:#{first == "a" ? "b" : "a"}"
  end
end

def validate_contract(contract, policy: :prop038_24_plus, validator_error: false)
  raise "synthetic validator failure" if validator_error
  return nil unless contract.is_a?(Hash)

  VALIDATOR.validate(contract, digest_reference_policy: policy)
rescue
  nil
end

def trigger_evaluation(validation:, strict_requirement:)
  return not_evaluated_evaluation unless strict_requirement

  unless strict_requirement.fetch("source", nil) == "proof_local_gate"
    return configuration_error_evaluation(
      "unsupported strict validation source",
      "strict_validation_source"
    )
  end

  unless strict_requirement.fetch("mode", nil) == "strict_contract_digest"
    return configuration_error_evaluation(
      "unsupported strict validation mode",
      "mode"
    )
  end

  return not_evaluated_evaluation unless validation

  codes = Array(validation["diagnostic_codes"])
  candidates = Array(strict_requirement["refusal_candidates"])

  if codes.include?(MISMATCH_CODE) && candidates.include?(MISMATCH_CODE)
    return {
      "kind" => "compiler_profile_contract_refusal_trigger_evaluation",
      "format_version" => FORMAT_VERSION,
      "mode" => "strict_contract_digest",
      "strict_validation_requested" => true,
      "strict_validation_source" => "proof_local_gate",
      "refusal_candidate_diagnostics" => [MISMATCH_CODE],
      "compiler_refusal_decision" => "would_refuse",
      "compiler_refusal_authorized" => false,
      "wrapper_evidence" => [
        {
          "code" => WRAPPER_MISMATCH_CODE,
          "evidence_diagnostic" => MISMATCH_CODE,
          "message" => "would_refuse: #{WRAPPER_MISMATCH_CODE} evidence=#{MISMATCH_CODE}"
        }
      ]
    }
  end

  if codes.include?(UNSUPPORTED_POLICY_CODE)
    return configuration_error_evaluation(
      "strict contract digest policy is unsupported",
      "digest_reference_policy",
      [UNSUPPORTED_POLICY_CODE]
    )
  end

  held_controls = []
  held_controls << INVALID_CODE if codes.include?(INVALID_CODE)
  held_controls << RECOMPUTE_UNAVAILABLE_CODE if codes.include?(RECOMPUTE_UNAVAILABLE_CODE)

  allow_evaluation(
    refusal_candidate_diagnostics: [],
    held_controls: held_controls,
    fail_open_report_only: codes.include?(RECOMPUTE_UNAVAILABLE_CODE)
  )
end

def not_evaluated_evaluation
  {
    "kind" => "compiler_profile_contract_refusal_trigger_evaluation",
    "format_version" => FORMAT_VERSION,
    "mode" => "report_only",
    "strict_validation_requested" => false,
    "strict_validation_source" => nil,
    "refusal_candidate_diagnostics" => [],
    "compiler_refusal_decision" => "not_evaluated",
    "compiler_refusal_authorized" => false,
    "wrapper_evidence" => []
  }
end

def allow_evaluation(refusal_candidate_diagnostics:, held_controls: [], fail_open_report_only: false)
  {
    "kind" => "compiler_profile_contract_refusal_trigger_evaluation",
    "format_version" => FORMAT_VERSION,
    "mode" => "strict_contract_digest",
    "strict_validation_requested" => true,
    "strict_validation_source" => "proof_local_gate",
    "refusal_candidate_diagnostics" => refusal_candidate_diagnostics,
    "compiler_refusal_decision" => "allow",
    "compiler_refusal_authorized" => false,
    "wrapper_evidence" => [],
    "held_control_diagnostics" => held_controls,
    "recompute_unavailable_policy" => fail_open_report_only ? "fail_open_report_only" : nil
  }
end

def configuration_error_evaluation(message, path, evidence = [])
  {
    "kind" => "compiler_profile_contract_refusal_trigger_evaluation",
    "format_version" => FORMAT_VERSION,
    "mode" => "strict_contract_digest",
    "strict_validation_requested" => true,
    "strict_validation_source" => "proof_local_gate",
    "refusal_candidate_diagnostics" => [],
    "compiler_refusal_decision" => "configuration_error",
    "compiler_refusal_authorized" => false,
    "wrapper_evidence" => [],
    "configuration_error" => {
      "message" => message,
      "path" => path,
      "evidence_diagnostics" => evidence
    }
  }
end

def case_entry(name:, baseline:, validation:, strict_requirement:, expected_decision:)
  run = annotate_report_only(baseline, validation)
  evaluation = trigger_evaluation(
    validation: validation,
    strict_requirement: strict_requirement
  )
  {
    "name" => name,
    "validation_present" => !validation.nil?,
    "validation_diagnostic_codes" => validation ? validation.fetch("diagnostic_codes") : [],
    "report_has_validation_field" => run.fetch("report").key?("compiler_profile_contract_validation"),
    "top_level_diagnostics" => run.fetch("report").fetch("diagnostics"),
    "compiler_refusal_decision" => evaluation.fetch("compiler_refusal_decision"),
    "expected_decision" => expected_decision,
    "trigger_evaluation" => evaluation,
    "outcome_unchanged" => same_outcome?(baseline, run),
    "pass" => evaluation.fetch("compiler_refusal_decision") == expected_decision && same_outcome?(baseline, run)
  }
end

def assert(name, condition, checks)
  checks << { "name" => name, "pass" => !!condition }
end

FileUtils.mkdir_p(OUT_DIR)

contract_summary = read_json(CONTRACT_SUMMARY_PATH)
canonical_contract = contract_summary.fetch("canonical_contract")
baseline = baseline_compile

valid_validation = validate_contract(canonical_contract)

mismatch_contract = deep_copy(canonical_contract)
mismatch_contract["contract_digest"] = replace_first_hex_char(mismatch_contract.fetch("contract_digest"))
mismatch_validation = validate_contract(mismatch_contract)

invalid_digest_contract = deep_copy(canonical_contract)
invalid_digest_contract["contract_digest"] = "compiler_profile_contract/sha256:ABC"
invalid_digest_validation = validate_contract(invalid_digest_contract)

unsupported_policy_validation = validate_contract(canonical_contract, policy: :prop038_full_sha256)

recompute_unavailable_contract = deep_copy(canonical_contract)
recompute_unavailable_contract["profile_kind"] = :unsupported_canonical_value
recompute_unavailable_validation = validate_contract(recompute_unavailable_contract)

nil_validation = validate_contract(nil)
non_hash_validation = validate_contract("not a contract hash")
provider_error_validation = nil
validator_error_validation = validate_contract(canonical_contract, validator_error: true)

cases = [
  case_entry(
    name: "report_only_valid_contract",
    baseline: baseline,
    validation: valid_validation,
    strict_requirement: nil,
    expected_decision: "not_evaluated"
  ),
  case_entry(
    name: "report_only_digest_mismatch_nested_only",
    baseline: baseline,
    validation: mismatch_validation,
    strict_requirement: nil,
    expected_decision: "not_evaluated"
  ),
  case_entry(
    name: "no_strict_source_not_evaluated",
    baseline: baseline,
    validation: mismatch_validation,
    strict_requirement: nil,
    expected_decision: "not_evaluated"
  ),
  case_entry(
    name: "strict_source_valid_contract_allow",
    baseline: baseline,
    validation: valid_validation,
    strict_requirement: STRICT_REQUIREMENT,
    expected_decision: "allow"
  ),
  case_entry(
    name: "strict_source_digest_mismatch_would_refuse",
    baseline: baseline,
    validation: mismatch_validation,
    strict_requirement: STRICT_REQUIREMENT,
    expected_decision: "would_refuse"
  ),
  case_entry(
    name: "strict_source_invalid_digest_held_control",
    baseline: baseline,
    validation: invalid_digest_validation,
    strict_requirement: STRICT_REQUIREMENT,
    expected_decision: "allow"
  ),
  case_entry(
    name: "strict_source_unsupported_policy_configuration_error",
    baseline: baseline,
    validation: unsupported_policy_validation,
    strict_requirement: STRICT_REQUIREMENT,
    expected_decision: "configuration_error"
  ),
  case_entry(
    name: "strict_source_recompute_unavailable_fail_open",
    baseline: baseline,
    validation: recompute_unavailable_validation,
    strict_requirement: STRICT_REQUIREMENT,
    expected_decision: "allow"
  ),
  case_entry(
    name: "nil_provider_no_field_no_refusal",
    baseline: baseline,
    validation: nil_validation,
    strict_requirement: STRICT_REQUIREMENT,
    expected_decision: "not_evaluated"
  ),
  case_entry(
    name: "non_hash_provider_no_field_no_refusal",
    baseline: baseline,
    validation: non_hash_validation,
    strict_requirement: STRICT_REQUIREMENT,
    expected_decision: "not_evaluated"
  ),
  case_entry(
    name: "provider_error_no_field_no_refusal",
    baseline: baseline,
    validation: provider_error_validation,
    strict_requirement: STRICT_REQUIREMENT,
    expected_decision: "not_evaluated"
  ),
  case_entry(
    name: "validator_error_no_field_no_refusal",
    baseline: baseline,
    validation: validator_error_validation,
    strict_requirement: STRICT_REQUIREMENT,
    expected_decision: "not_evaluated"
  )
]

case_by_name = cases.to_h { |entry| [entry.fetch("name"), entry] }
checks = []

assert("cases_all_pass", cases.all? { |entry| entry.fetch("pass") }, checks)
assert("report_only_valid_contract.unchanged", case_by_name.fetch("report_only_valid_contract").fetch("outcome_unchanged"), checks)
assert("report_only_mismatch.nested_diagnostic_only", case_by_name.fetch("report_only_digest_mismatch_nested_only").fetch("validation_diagnostic_codes").include?(MISMATCH_CODE) && case_by_name.fetch("report_only_digest_mismatch_nested_only").fetch("top_level_diagnostics").empty?, checks)
assert("no_strict_source.not_evaluated", case_by_name.fetch("no_strict_source_not_evaluated").fetch("compiler_refusal_decision") == "not_evaluated", checks)
assert("strict_valid.allow", case_by_name.fetch("strict_source_valid_contract_allow").fetch("compiler_refusal_decision") == "allow", checks)
assert("strict_mismatch.would_refuse", case_by_name.fetch("strict_source_digest_mismatch_would_refuse").fetch("compiler_refusal_decision") == "would_refuse", checks)
assert("strict_mismatch.wrapper_evidence", case_by_name.fetch("strict_source_digest_mismatch_would_refuse").dig("trigger_evaluation", "wrapper_evidence", 0, "code") == WRAPPER_MISMATCH_CODE, checks)
assert("strict_invalid_digest.not_would_refuse", case_by_name.fetch("strict_source_invalid_digest_held_control").fetch("compiler_refusal_decision") != "would_refuse", checks)
assert("strict_unsupported_policy.configuration_error", case_by_name.fetch("strict_source_unsupported_policy_configuration_error").fetch("compiler_refusal_decision") == "configuration_error", checks)
assert("strict_recompute_unavailable.fail_open", case_by_name.fetch("strict_source_recompute_unavailable_fail_open").fetch("compiler_refusal_decision") == "allow" && case_by_name.fetch("strict_source_recompute_unavailable_fail_open").dig("trigger_evaluation", "recompute_unavailable_policy") == "fail_open_report_only", checks)
assert("legacy_paths.no_field_no_refusal", %w[nil_provider_no_field_no_refusal non_hash_provider_no_field_no_refusal provider_error_no_field_no_refusal validator_error_no_field_no_refusal].all? { |name| !case_by_name.fetch(name).fetch("report_has_validation_field") && case_by_name.fetch(name).fetch("compiler_refusal_decision") == "not_evaluated" }, checks)
assert("top_level_diagnostics_unchanged", cases.all? { |entry| entry.fetch("top_level_diagnostics").empty? }, checks)
assert("public_result_unchanged", cases.all? { |entry| entry.fetch("outcome_unchanged") }, checks)
assert("wrapper_codes_proof_local_only", cases.flat_map { |entry| entry.dig("trigger_evaluation", "wrapper_evidence") || [] }.all? { |entry| entry.fetch("code").start_with?("compiler_profile_contract_refusal.") }, checks)
assert("compile_refusal_authorized_false", cases.all? { |entry| entry.dig("trigger_evaluation", "compiler_refusal_authorized") == false }, checks)

failed_checks = checks.reject { |check| check.fetch("pass") }
summary = {
  "kind" => "prop038_strict_mode_refusal_trigger_proof_summary",
  "format_version" => FORMAT_VERSION,
  "track" => TRACK,
  "authority_ref" => "igniter-lang/docs/gates/prop038-strict-mode-refusal-trigger-design-decision-v0.md",
  "status" => failed_checks.empty? ? "PASS" : "FAIL",
  "strict_requirement" => STRICT_REQUIREMENT,
  "cases" => cases,
  "checks" => checks,
  "failed_checks" => failed_checks,
  "decision_vocabulary" => %w[not_evaluated allow would_refuse configuration_error],
  "wrapper_vocabulary" => [WRAPPER_MISMATCH_CODE],
  "report_only_invariants" => {
    "top_level_diagnostics_unchanged" => true,
    "public_result_unchanged" => true,
    "compiler_result_changed" => false,
    "igapp_mutated" => false,
    "loader_report_touched" => false,
    "compatibility_report_touched" => false,
    "runtime_touched" => false,
    "production_touched" => false
  },
  "non_authorizations_preserved" => {
    "live_compiler_orchestrator_behavior" => false,
    "live_compile_refusal" => false,
    "public_api_cli_widening" => false,
    "compiler_result_changes" => false,
    "persisted_reports_or_sidecars_outside_proof" => false,
    "parser_typechecker_semanticir_assembler_igapp" => false,
    "loader_report_or_compatibility_report" => false,
    "diagnostics_centralization" => false,
    "runtime_gate3_ledger_tbackend_bihistory_stream_olap_cache_production" => false
  },
  "recommendation_for_c3_a" => "accept"
}

File.write(SUMMARY_PATH, JSON.pretty_generate(summary) + "\n")

if summary.fetch("status") == "PASS"
  puts "PASS prop038_strict_mode_refusal_trigger_proof"
else
  warn JSON.pretty_generate(failed_checks)
  exit 1
end
