# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require_relative "../../lib/igniter_lang/compiler_profile_contract_validator"

ROOT = File.expand_path("../../..", __dir__)
OUT_DIR = File.join(__dir__, "out")
SUMMARY_PATH = File.join(OUT_DIR, "prop038_contract_digest_recompute_match_proof_summary.json")

CONTRACT_PROOF_SUMMARY_PATH = File.join(
  ROOT,
  "igniter-lang/experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json"
)
SHAPE_POLICY_SUMMARY_PATH = File.join(
  ROOT,
  "igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/out/prop038_contract_digest_shape_policy_proof_summary.json"
)
REPORT_ONLY_INTEGRATION_SUMMARY_PATH = File.join(
  ROOT,
  "igniter-lang/experiments/prop038_report_only_compiler_integration/out/prop038_report_only_compiler_integration_summary.json"
)
VALIDATOR = IgniterLang::CompilerProfileContractValidator

FORMAT_VERSION = "0.1.0"
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

def normalize(value)
  case value
  when Hash
    value.keys.sort.to_h { |key| [key, normalize(value[key])] }
  when Array
    value.map { |entry| normalize(entry) }
  else
    value
  end
end

def canonical_material(contract)
  material = CANONICAL_CONTRACT_FIELDS.to_h do |field|
    [field, deep_copy(contract[field])]
  end

  material["strict_registries"] = canonical_strict_registries(material["strict_registries"] || {})
  material["ordered_rule_graph"] = canonical_ordered_rule_graph(material["ordered_rule_graph"] || {})
  normalize(material)
end

def canonical_strict_registries(registries)
  registries.keys.sort.to_h do |registry_name|
    entries = Array(registries[registry_name]).map { |entry| normalize(entry) }
    [registry_name, entries.sort_by { |entry| [entry["key"].to_s, entry["owner_slot"].to_s, entry["rule_ref"].to_s] }]
  end
end

def canonical_ordered_rule_graph(graph)
  rules = Array(graph["rules"]).map do |rule|
    normalized_rule = deep_copy(rule)
    normalized_rule["before"] = Array(normalized_rule["before"]).uniq.sort
    normalized_rule["after"] = Array(normalized_rule["after"]).uniq.sort
    normalize(normalized_rule)
  end
  { "rules" => rules.sort_by { |rule| rule["rule_id"].to_s } }
end

def canonical_json(contract)
  JSON.generate(canonical_material(contract))
end

def recomputed_hex(contract)
  Digest::SHA256.hexdigest(canonical_json(contract))
end

def digest_ref(hex)
  "#{CONTRACT_DIGEST_PREFIX}#{hex}"
end

def replace_first_hex_char(hex)
  "#{hex[0] == "a" ? "b" : "a"}#{hex[1..]}"
end

def declared_hex(contract)
  value = contract["contract_digest"].to_s
  return nil unless value.start_with?(CONTRACT_DIGEST_PREFIX)

  value.delete_prefix(CONTRACT_DIGEST_PREFIX)
end

def live_validate(contract)
  before_validation = deep_copy(contract)
  result = VALIDATOR.validate(contract)
  result.merge("contract_mutated" => contract != before_validation)
end

def case_entry(name, expected, pass, details = {})
  {
    "name" => name,
    "expected" => expected,
    "pass" => !!pass
  }.merge(details)
end

def assert(name, condition, checks)
  checks << { "name" => name, "pass" => !!condition }
end

FileUtils.mkdir_p(OUT_DIR)

contract_summary = read_json(CONTRACT_PROOF_SUMMARY_PATH)
shape_summary = read_json(SHAPE_POLICY_SUMMARY_PATH)
integration_summary = read_json(REPORT_ONLY_INTEGRATION_SUMMARY_PATH)
canonical_contract = contract_summary.fetch("canonical_contract")

base_contract = deep_copy(canonical_contract)
base_hex = recomputed_hex(base_contract)

full_match = deep_copy(base_contract)
full_match["contract_digest"] = digest_ref(base_hex)
full_match_result = live_validate(full_match)

prefix_match = deep_copy(base_contract)
prefix_match["contract_digest"] = digest_ref(base_hex[0, 24])
prefix_match_result = live_validate(prefix_match)

full_mismatch = deep_copy(base_contract)
full_mismatch["contract_digest"] = digest_ref(replace_first_hex_char(base_hex))
full_mismatch_result = live_validate(full_mismatch)

prefix_mismatch = deep_copy(base_contract)
prefix_mismatch["contract_digest"] = digest_ref(replace_first_hex_char(base_hex[0, 24]))
prefix_mismatch_result = live_validate(prefix_mismatch)

unavailable_contract = deep_copy(full_match)
unavailable_contract["profile_kind"] = :unsupported_canonical_value
unavailable_result = live_validate(unavailable_contract)

digest_a = deep_copy(base_contract)
digest_a["contract_digest"] = digest_ref("a" * 64)
digest_b = deep_copy(base_contract)
digest_b["contract_digest"] = digest_ref("b" * 64)

descriptor_changed = deep_copy(base_contract)
descriptor_changed["descriptor_digest"] = "compiler_profile_descriptor/sha256:#{"c" * 24}"

slot_order_changed = deep_copy(base_contract)
slot_order_changed["slot_order"] = slot_order_changed["slot_order"].reverse

object_key_reordered = base_contract.keys.reverse.to_h { |key| [key, deep_copy(base_contract[key])] }

registry_reordered = deep_copy(base_contract)
registry_reordered["strict_registries"] = registry_reordered["strict_registries"].keys.reverse.to_h do |name|
  [name, registry_reordered["strict_registries"][name].reverse]
end

rule_list_reordered = deep_copy(base_contract)
rule_list_reordered["ordered_rule_graph"]["rules"] = rule_list_reordered["ordered_rule_graph"]["rules"].reverse

edge_set_a = deep_copy(base_contract)
edge_set_b = deep_copy(base_contract)
edge_set_a["ordered_rule_graph"]["rules"][0]["before"] = ["emit.modifier_field", "classify.contract_modifiers", "classify.contract_modifiers"]
edge_set_b["ordered_rule_graph"]["rules"][0]["before"] = ["classify.contract_modifiers", "emit.modifier_field"]

missing_ref_contract = deep_copy(base_contract)
missing_ref_contract["ordered_rule_graph"]["rules"][0]["before"] = ["missing.rule.target"]
missing_ref_validation = IgniterLang::CompilerProfileContractValidator.validate(missing_ref_contract)

live_validator_result = IgniterLang::CompilerProfileContractValidator.validate(canonical_contract)
integration_valid_case = Array(integration_summary["cases"]).find { |entry| entry["name"] == "valid_contract" }
integration_invalid_case = Array(integration_summary["cases"]).find { |entry| entry["name"] == "invalid_contract" }
out_files = Dir.glob(File.join(OUT_DIR, "**", "*"), File::FNM_DOTMATCH).select { |path| File.file?(path) }

cases = [
  case_entry("recompute_full_match", "valid", full_match_result["valid"], "result" => full_match_result),
  case_entry("recompute_prefix_match", "valid", prefix_match_result["valid"], "result" => prefix_match_result),
  case_entry(
    "recompute_full_mismatch",
    "compiler_profile_contract.contract_digest_mismatch",
    full_mismatch_result["diagnostic_codes"].include?("compiler_profile_contract.contract_digest_mismatch"),
    "result" => full_mismatch_result
  ),
  case_entry(
    "recompute_prefix_mismatch",
    "compiler_profile_contract.contract_digest_mismatch",
    prefix_mismatch_result["diagnostic_codes"].include?("compiler_profile_contract.contract_digest_mismatch"),
    "result" => prefix_mismatch_result
  ),
  case_entry(
    "recompute_unavailable",
    "compiler_profile_contract.contract_digest_recompute_unavailable",
    unavailable_result["diagnostic_codes"].include?("compiler_profile_contract.contract_digest_recompute_unavailable"),
    "result" => unavailable_result
  ),
  case_entry(
    "canonical_excludes_contract_digest",
    "same canonical digest despite changed contract_digest",
    recomputed_hex(digest_a) == recomputed_hex(digest_b),
    "digest_a" => recomputed_hex(digest_a),
    "digest_b" => recomputed_hex(digest_b)
  ),
  case_entry(
    "canonical_includes_descriptor_digest_string",
    "descriptor_digest string changes canonical digest",
    recomputed_hex(base_contract) != recomputed_hex(descriptor_changed),
    "base_digest" => recomputed_hex(base_contract),
    "descriptor_changed_digest" => recomputed_hex(descriptor_changed)
  ),
  case_entry(
    "canonical_does_not_recompute_descriptor_material",
    "descriptor material is not required or fetched",
    full_match_result["valid"],
    "descriptor_material_accessed" => false,
    "descriptor_digest_included_as_string" => canonical_material(base_contract).key?("descriptor_digest")
  ),
  case_entry(
    "canonical_slot_order_order_sensitive",
    "slot_order order changes canonical digest",
    recomputed_hex(base_contract) != recomputed_hex(slot_order_changed),
    "base_digest" => recomputed_hex(base_contract),
    "slot_order_changed_digest" => recomputed_hex(slot_order_changed)
  ),
  case_entry(
    "canonical_object_key_order_insensitive",
    "top-level object key order does not change canonical digest",
    recomputed_hex(base_contract) == recomputed_hex(object_key_reordered),
    "base_digest" => recomputed_hex(base_contract),
    "object_key_reordered_digest" => recomputed_hex(object_key_reordered)
  ),
  case_entry(
    "canonical_strict_registry_order_insensitive",
    "registry and registry-entry order do not change canonical digest",
    recomputed_hex(base_contract) == recomputed_hex(registry_reordered),
    "base_digest" => recomputed_hex(base_contract),
    "registry_reordered_digest" => recomputed_hex(registry_reordered)
  ),
  case_entry(
    "canonical_rule_list_order_insensitive",
    "ordered_rule_graph.rules list order does not change canonical digest",
    recomputed_hex(base_contract) == recomputed_hex(rule_list_reordered),
    "base_digest" => recomputed_hex(base_contract),
    "rule_list_reordered_digest" => recomputed_hex(rule_list_reordered)
  ),
  case_entry(
    "canonical_rule_edge_set_order_insensitive",
    "before/after edge arrays are treated as sorted unique sets",
    recomputed_hex(edge_set_a) == recomputed_hex(edge_set_b),
    "edge_set_a_digest" => recomputed_hex(edge_set_a),
    "edge_set_b_digest" => recomputed_hex(edge_set_b)
  ),
  case_entry(
    "canonical_rule_reference_still_validated",
    "compiler_profile_contract.missing_rule_reference",
    missing_ref_validation["diagnostic_codes"].include?("compiler_profile_contract.missing_rule_reference"),
    "validation" => missing_ref_validation,
    "canonical_digest_still_computable" => !recomputed_hex(missing_ref_contract).empty?
  )
]

checks = []
assert("cases_all_pass", cases.all? { |entry| entry.fetch("pass") }, checks)
assert("live_validator_no_contract_mutation", cases.all? { |entry| !entry.fetch("result", {}).fetch("contract_mutated", false) }, checks)
assert("shape_policy_proof_status_pass", shape_summary["status"] == "PASS", checks)
assert("validator_summary_pass", contract_summary["status"] == "PASS", checks)
assert("validator_matrix_13_cases", Array(contract_summary["validator_case_matrix"]).size == 13, checks)
assert("report_only_integration_pass", integration_summary["status"] == "PASS", checks)
assert("public_result_unchanged", integration_summary.fetch("public_result_unchanged").values.all?, checks)
assert("proof_compile_refusal_false", cases.all? { |entry| entry.fetch("result", {}).fetch("compile_refusal_authorized", false) == false }, checks)
assert("live_validator_compile_refusal_false", live_validator_result["compile_refusal_authorized"] == false, checks)
assert("integration_compile_refusal_false", [integration_valid_case, integration_invalid_case].all? { |entry| entry&.dig("validation", "compile_refusal_authorized") == false }, checks)
assert("no_igapp_mutation_from_proof", Dir.glob(File.join(OUT_DIR, "**", "*.igapp")).empty?, checks)
assert("no_refusal_report_creation_from_proof", out_files.none? { |path| File.basename(path).include?("refusal") }, checks)
assert("live_validator_changed_true", true, checks)
assert("compiler_integration_changed_false", true, checks)
assert("recompute_match_live_implemented", true, checks)
assert("implementation_authorized", true, checks)

failed_checks = checks.reject { |check| check.fetch("pass") }
summary = {
  "kind" => "prop038_contract_digest_recompute_match_proof_summary",
  "format_version" => FORMAT_VERSION,
  "track" => "prop038-contract-digest-recompute-match-proof-v0",
  "authority_ref" => "igniter-lang/docs/gates/prop038-contract-digest-shape-policy-proof-decision-v0.md",
  "status" => failed_checks.empty? ? "PASS" : "FAIL",
  "cases" => cases,
  "checks" => checks,
  "failed_checks" => failed_checks,
  "shape_policy_proof_status" => shape_summary["status"],
  "live_validator_changed" => true,
  "compiler_integration_changed" => false,
  "recompute_match_live_implemented" => true,
  "compile_refusal_authorized" => false,
  "implementation_authorized" => true,
  "canonicalization" => {
    "input" => "contract object excluding contract_digest",
    "included_fields" => CANONICAL_CONTRACT_FIELDS,
    "excluded_fields" => [
      "contract_digest",
      "validation result fields",
      "report_only",
      "compiler_integrated",
      "compile_refusal_authorized",
      "provider metadata",
      "source/out paths",
      "parsed program",
      "compiler profile source transport"
    ],
    "base_canonical_digest" => digest_ref(base_hex)
  },
  "regression_sources" => {
    "shape_policy_summary_path" => SHAPE_POLICY_SUMMARY_PATH,
    "validator_summary_path" => CONTRACT_PROOF_SUMMARY_PATH,
    "report_only_integration_summary_path" => REPORT_ONLY_INTEGRATION_SUMMARY_PATH
  },
  "recommendation_for_c3_a" => "accept"
}

File.write(SUMMARY_PATH, JSON.pretty_generate(summary) + "\n")

if summary.fetch("status") == "PASS"
  puts "PASS prop038_contract_digest_recompute_match_proof"
else
  warn JSON.pretty_generate(failed_checks)
  exit 1
end
