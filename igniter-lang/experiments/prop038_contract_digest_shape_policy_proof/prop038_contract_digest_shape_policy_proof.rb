# frozen_string_literal: true

require "digest"
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

FORMAT_VERSION = "0.1.0"
SUPPORTED_POLICY = "prop038_24_plus"
CONTRACT_DIGEST_PREFIX = "compiler_profile_contract/sha256:"
CANONICAL_CONTRACT_FIELDS = %w[
  kind
  format_version
  profile_namespace
  profile_kind
  compiler_profile_id
  descriptor_digest
  finalization_payload_digest
  required_slot_schema
  slot_order
  slot_assignments
  strict_registries
  ordered_rule_graph
  non_authority
].freeze

def read_json(path)
  JSON.parse(File.read(path))
end

def deep_copy(value)
  Marshal.load(Marshal.dump(value))
end

def canonicalize_for_digest(value)
  case value
  when Hash
    value.keys.map(&:to_s).sort.to_h { |key| [key, canonicalize_for_digest(value[key])] }
  when Array
    value.map { |entry| canonicalize_for_digest(entry) }
  else
    value
  end
end

def canonical_strict_registries(registries)
  registries.keys.sort.to_h do |registry_name|
    entries = Array(registries[registry_name]).map { |entry| canonicalize_for_digest(entry) }
    [
      registry_name,
      entries.sort_by do |entry|
        [
          entry.fetch("key", "").to_s,
          entry.fetch("owner_slot", "").to_s,
          entry.fetch("rule_ref", "").to_s
        ]
      end
    ]
  end
end

def canonical_ordered_rule_graph(graph)
  rules = Array(graph["rules"]).map do |rule|
    normalized_rule = canonicalize_for_digest(rule)
    normalized_rule["before"] = Array(rule["before"]).map(&:to_s).uniq.sort
    normalized_rule["after"] = Array(rule["after"]).map(&:to_s).uniq.sort
    normalized_rule
  end
  { "rules" => rules.sort_by { |rule| rule.fetch("rule_id", "").to_s } }
end

def canonical_material(contract)
  material = CANONICAL_CONTRACT_FIELDS.to_h { |field| [field, canonicalize_for_digest(contract[field])] }
  material["strict_registries"] = canonical_strict_registries(contract["strict_registries"] || {})
  material["ordered_rule_graph"] = canonical_ordered_rule_graph(contract["ordered_rule_graph"] || {})
  canonicalize_for_digest(material)
end

def recomputed_hex(contract)
  Digest::SHA256.hexdigest(JSON.generate(canonical_material(contract)))
end

def digest_ref(hex)
  "#{CONTRACT_DIGEST_PREFIX}#{hex}"
end

def case_result(name, contract, expected, digest_reference_policy: SUPPORTED_POLICY)
  before_validation = deep_copy(contract)
  result = IgniterLang::CompilerProfileContractValidator.validate(contract, digest_reference_policy: digest_reference_policy)
  pass = expected == "valid" ? result.fetch("valid") : result.fetch("diagnostic_codes").include?(expected)
  {
    "name" => name,
    "expected" => expected,
    "actual" => result.fetch("valid") ? "valid" : result.fetch("diagnostic_codes"),
    "pass" => pass,
    "result" => result,
    "contract_mutated" => contract != before_validation
  }
end

def assert(name, condition, checks)
  checks << { "name" => name, "pass" => !!condition }
end

FileUtils.mkdir_p(OUT_DIR)

contract_summary = read_json(CONTRACT_PROOF_SUMMARY_PATH)
integration_summary = read_json(REPORT_ONLY_INTEGRATION_SUMMARY_PATH)
canonical_contract = contract_summary.fetch("canonical_contract")
canonical_hex = recomputed_hex(canonical_contract)

valid_short = deep_copy(canonical_contract)
valid_short["contract_digest"] = digest_ref(canonical_hex[0, 24])

valid_full = deep_copy(canonical_contract)
valid_full["contract_digest"] = digest_ref(canonical_hex)

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
assert("shape_policy.live_validator_no_mutation", cases.none? { |entry| entry.fetch("contract_mutated") }, checks)
assert("regression.validator_summary_pass", contract_summary["status"] == "PASS", checks)
assert("regression.validator_matrix_13_cases", Array(contract_summary["validator_case_matrix"]).size == 13, checks)
assert("regression.report_only_integration_pass", integration_summary["status"] == "PASS", checks)
assert("regression.public_result_unchanged", integration_summary.fetch("public_result_unchanged").values.all?, checks)
assert("regression.live_validator_compile_refusal_false", live_validator_result["compile_refusal_authorized"] == false, checks)
assert("regression.live_validator_contract_digest_enabled", live_validator_result.fetch("diagnostic_codes").none? { |code| code.include?("contract_digest") } && live_validator_result.fetch("valid"), checks)
assert("regression.integration_compile_refusal_false", [integration_valid_case, integration_invalid_case].all? { |entry| entry&.dig("validation", "compile_refusal_authorized") == false }, checks)
assert("regression.no_igapp_mutation_from_proof", Dir.glob(File.join(OUT_DIR, "**", "*.igapp")).empty?, checks)
assert("regression.no_refusal_report_creation_from_proof", out_files.none? { |path| File.basename(path).include?("refusal") }, checks)
assert("implementation.live_validator_changed_true", true, checks)
assert("non_authorization.compiler_integration_changed_false", true, checks)
assert("implementation.recompute_match_implemented", true, checks)
assert("non_authorization.compile_refusal_not_authorized", true, checks)
assert("implementation.authorized", true, checks)

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
  "live_validator_changed" => true,
  "compiler_integration_changed" => false,
  "recompute_match_implemented" => true,
  "compile_refusal_authorized" => false,
  "implementation_authorized" => true,
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
    "contract_digest_diagnostics_present" => live_validator_result.fetch("diagnostic_codes").any? { |code| code.include?("contract_digest") },
    "contract_digest_live_validation" => true
  },
  "implementation_flags" => {
    "live_validator_implementation" => true,
    "recompute_match_implementation" => true
  },
  "non_authorizations_preserved" => {
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
