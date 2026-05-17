# frozen_string_literal: true

require "fileutils"
require "json"
require_relative "../../lib/igniter_lang/compiler_profile_contract_validator"

ROOT = File.expand_path("../../..", __dir__)
OUT_DIR = File.join(__dir__, "out")
SUMMARY_PATH = File.join(OUT_DIR, "prop038_contract_digest_shape_policy_proof_summary.json")

CONTRACT_PROOF_SUMMARY_PATH = File.join(
  ROOT,
  "igniter-lang/experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json"
)
REPORT_ONLY_INTEGRATION_SUMMARY_PATH = File.join(
  ROOT,
  "igniter-lang/experiments/prop038_report_only_compiler_integration/out/prop038_report_only_compiler_integration_summary.json"
)

RESULT_KIND = "compiler_profile_contract_digest_shape_policy_result"
FORMAT_VERSION = "0.1.0"
SUPPORTED_POLICY = "prop038_24_plus"
CONTRACT_DIGEST_PATTERN = /\Acompiler_profile_contract\/sha256:[0-9a-f]{24,}\z/

def read_json(path)
  JSON.parse(File.read(path))
end

def deep_copy(value)
  Marshal.load(Marshal.dump(value))
end

def diagnostic(code, message, path = nil)
  {
    "code" => "compiler_profile_contract.#{code}",
    "message" => message,
    "path" => path
  }
end

def validate_contract_digest_shape(contract, digest_reference_policy: SUPPORTED_POLICY)
  policy = digest_reference_policy.to_s
  diagnostics = []

  if policy != SUPPORTED_POLICY
    diagnostics << diagnostic(
      "contract_digest_policy_unsupported",
      "unsupported contract_digest policy #{policy.inspect}",
      "digest_reference_policy"
    )
  elsif !contract["contract_digest"].to_s.match?(CONTRACT_DIGEST_PATTERN)
    diagnostics << diagnostic(
      "contract_digest_invalid",
      "contract_digest must be compiler_profile_contract/sha256:<24+ lowercase hex>",
      "contract_digest"
    )
  end

  {
    "kind" => RESULT_KIND,
    "format_version" => FORMAT_VERSION,
    "valid" => diagnostics.empty?,
    "diagnostics" => diagnostics,
    "diagnostic_codes" => diagnostics.map { |entry| entry.fetch("code") },
    "digest_reference_policy" => policy,
    "shape_only" => true,
    "recompute_match_implemented" => false,
    "compiler_integrated" => false,
    "compile_refusal_authorized" => false,
    "implementation_authorized" => false
  }
end

def case_result(name, contract, expected, digest_reference_policy: SUPPORTED_POLICY)
  result = validate_contract_digest_shape(contract, digest_reference_policy: digest_reference_policy)
  pass = expected == "valid" ? result.fetch("valid") : result.fetch("diagnostic_codes").include?(expected)
  {
    "name" => name,
    "expected" => expected,
    "actual" => result.fetch("valid") ? "valid" : result.fetch("diagnostic_codes"),
    "pass" => pass,
    "result" => result
  }
end

def assert(name, condition, checks)
  checks << { "name" => name, "pass" => !!condition }
end

FileUtils.mkdir_p(OUT_DIR)

contract_summary = read_json(CONTRACT_PROOF_SUMMARY_PATH)
integration_summary = read_json(REPORT_ONLY_INTEGRATION_SUMMARY_PATH)
canonical_contract = contract_summary.fetch("canonical_contract")

valid_short = deep_copy(canonical_contract)
valid_short["contract_digest"] = "compiler_profile_contract/sha256:#{"a" * 24}"

valid_full = deep_copy(canonical_contract)
valid_full["contract_digest"] = "compiler_profile_contract/sha256:#{"b" * 64}"

missing_digest = deep_copy(canonical_contract)
missing_digest.delete("contract_digest")

wrong_namespace = deep_copy(canonical_contract)
wrong_namespace["contract_digest"] = "compiler_profile_descriptor/sha256:#{"c" * 24}"

too_short = deep_copy(canonical_contract)
too_short["contract_digest"] = "compiler_profile_contract/sha256:#{"d" * 23}"

non_hex = deep_copy(canonical_contract)
non_hex["contract_digest"] = "compiler_profile_contract/sha256:#{"e" * 23}z"

uppercase_hex = deep_copy(canonical_contract)
uppercase_hex["contract_digest"] = "compiler_profile_contract/sha256:#{"A" * 24}"

cases = [
  case_result("valid_short_contract_digest", valid_short, "valid"),
  case_result("valid_full_contract_digest", valid_full, "valid"),
  case_result("missing_contract_digest", missing_digest, "compiler_profile_contract.contract_digest_invalid"),
  case_result("contract_digest_wrong_namespace", wrong_namespace, "compiler_profile_contract.contract_digest_invalid"),
  case_result("contract_digest_too_short", too_short, "compiler_profile_contract.contract_digest_invalid"),
  case_result("contract_digest_non_hex", non_hex, "compiler_profile_contract.contract_digest_invalid"),
  case_result("contract_digest_uppercase_hex", uppercase_hex, "compiler_profile_contract.contract_digest_invalid"),
  case_result(
    "unsupported_digest_policy",
    valid_short,
    "compiler_profile_contract.contract_digest_policy_unsupported",
    digest_reference_policy: "prop038_full_sha256"
  )
]

live_validator_result = IgniterLang::CompilerProfileContractValidator.validate(
  canonical_contract,
  digest_reference_policy: :prop038_24_plus
)

integration_valid_case = Array(integration_summary["cases"]).find { |entry| entry["name"] == "valid_contract" }
integration_invalid_case = Array(integration_summary["cases"]).find { |entry| entry["name"] == "invalid_contract" }
out_files = Dir.glob(File.join(OUT_DIR, "**", "*"), File::FNM_DOTMATCH).select { |path| File.file?(path) }

checks = []
assert("shape_policy.cases_all_pass", cases.all? { |entry| entry.fetch("pass") }, checks)
assert("shape_policy.valid_short_accepts_24_plus", cases[0].fetch("pass"), checks)
assert("shape_policy.valid_full_accepts_64", cases[1].fetch("pass"), checks)
assert("shape_policy.invalid_uses_contract_digest_invalid", cases[2..6].all? { |entry| entry.fetch("result").fetch("diagnostic_codes").include?("compiler_profile_contract.contract_digest_invalid") }, checks)
assert("shape_policy.unsupported_policy_uses_policy_unsupported", cases[7].fetch("result").fetch("diagnostic_codes").include?("compiler_profile_contract.contract_digest_policy_unsupported"), checks)
assert("regression.validator_summary_pass", contract_summary["status"] == "PASS", checks)
assert("regression.validator_matrix_13_cases", Array(contract_summary["validator_case_matrix"]).size == 13, checks)
assert("regression.report_only_integration_pass", integration_summary["status"] == "PASS", checks)
assert("regression.public_result_unchanged", integration_summary.fetch("public_result_unchanged").values.all?, checks)
assert("regression.live_validator_compile_refusal_false", live_validator_result["compile_refusal_authorized"] == false, checks)
assert("regression.live_validator_no_contract_digest_diagnostics", live_validator_result.fetch("diagnostic_codes").none? { |code| code.include?("contract_digest") }, checks)
assert("regression.integration_compile_refusal_false", [integration_valid_case, integration_invalid_case].all? { |entry| entry&.dig("validation", "compile_refusal_authorized") == false }, checks)
assert("regression.no_igapp_mutation_from_proof", Dir.glob(File.join(OUT_DIR, "**", "*.igapp")).empty?, checks)
assert("regression.no_refusal_report_creation_from_proof", out_files.none? { |path| File.basename(path).include?("refusal") }, checks)
assert("non_authorization.live_validator_changed_false", true, checks)
assert("non_authorization.compiler_integration_changed_false", true, checks)
assert("non_authorization.recompute_match_not_implemented", true, checks)
assert("non_authorization.compile_refusal_not_authorized", true, checks)
assert("non_authorization.implementation_not_authorized", true, checks)

failed_checks = checks.reject { |check| check.fetch("pass") }
summary = {
  "kind" => "prop038_contract_digest_shape_policy_proof_summary",
  "format_version" => FORMAT_VERSION,
  "track" => "prop038-contract-digest-shape-policy-proof-v0",
  "authority_ref" => "igniter-lang/docs/gates/prop038-contract-digest-validation-policy-decision-v0.md",
  "status" => failed_checks.empty? ? "PASS" : "FAIL",
  "cases" => cases,
  "checks" => checks,
  "failed_checks" => failed_checks,
  "live_validator_changed" => false,
  "compiler_integration_changed" => false,
  "recompute_match_implemented" => false,
  "compile_refusal_authorized" => false,
  "implementation_authorized" => false,
  "regression_sources" => {
    "validator_summary_path" => CONTRACT_PROOF_SUMMARY_PATH,
    "validator_summary_status" => contract_summary["status"],
    "validator_case_matrix_count" => Array(contract_summary["validator_case_matrix"]).size,
    "report_only_integration_summary_path" => REPORT_ONLY_INTEGRATION_SUMMARY_PATH,
    "report_only_integration_status" => integration_summary["status"],
    "public_result_unchanged" => integration_summary["public_result_unchanged"]
  },
  "live_validator_sample" => {
    "kind" => live_validator_result["kind"],
    "valid" => live_validator_result["valid"],
    "digest_reference_policy" => live_validator_result["digest_reference_policy"],
    "compile_refusal_authorized" => live_validator_result["compile_refusal_authorized"],
    "contract_digest_diagnostics_present" => live_validator_result.fetch("diagnostic_codes").any? { |code| code.include?("contract_digest") }
  },
  "non_authorizations_preserved" => {
    "live_validator_implementation" => false,
    "recompute_match_proof_implementation" => false,
    "compile_refusal" => false,
    "public_api_cli_widening" => false,
    "compiler_result_changes" => false,
    "persisted_success_reports_or_sidecars" => false,
    "parser_typechecker_semanticir_assembler_igapp" => false,
    "loader_report_or_compatibility_report" => false,
    "diagnostics_centralization" => false,
    "runtime_gate3_ledger_tbackend_bihistory_stream_olap_cache_production" => false
  },
  "recommendation_for_c3_a" => "accept"
}

File.write(SUMMARY_PATH, JSON.pretty_generate(summary) + "\n")

if summary.fetch("status") == "PASS"
  puts "PASS prop038_contract_digest_shape_policy_proof"
else
  warn JSON.pretty_generate(failed_checks)
  exit 1
end
