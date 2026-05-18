# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require_relative "../../lib/igniter_lang/compiler_profile_contract_validator"

ROOT = File.expand_path("../../..", __dir__)
OUT_DIR = File.join(__dir__, "out")
SUMMARY_PATH = File.join(OUT_DIR, "prop038_contract_digest_report_only_integration_proof_summary.json")

CONTRACT_SUMMARY_PATH = File.join(
  ROOT,
  "igniter-lang/experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json"
)
SHAPE_SUMMARY_PATH = File.join(
  ROOT,
  "igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/out/prop038_contract_digest_shape_policy_proof_summary.json"
)
RECOMPUTE_SUMMARY_PATH = File.join(
  ROOT,
  "igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/out/prop038_contract_digest_recompute_match_proof_summary.json"
)
R67_INTEGRATION_SUMMARY_PATH = File.join(
  ROOT,
  "igniter-lang/experiments/prop038_report_only_compiler_integration/out/prop038_report_only_compiler_integration_summary.json"
)

FORMAT_VERSION = "0.1.0"
SUPPORTED_POLICY = "prop038_24_plus"
CONTRACT_DIGEST_PREFIX = "compiler_profile_contract/sha256:"
CONTRACT_DIGEST_PATTERN = /\Acompiler_profile_contract\/sha256:[0-9a-f]{24,}\z/
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

def diagnostic(code, message, path = nil)
  {
    "code" => "compiler_profile_contract.#{code}",
    "message" => message,
    "path" => path
  }
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
  material = CANONICAL_CONTRACT_FIELDS.to_h { |field| [field, deep_copy(contract[field])] }
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

def recomputed_hex(contract)
  Digest::SHA256.hexdigest(JSON.generate(canonical_material(contract)))
end

def digest_ref(hex)
  "#{CONTRACT_DIGEST_PREFIX}#{hex}"
end

def replace_first_hex_char(hex)
  "#{hex[0] == "a" ? "b" : "a"}#{hex[1..]}"
end

def declared_hex(contract)
  contract["contract_digest"].to_s.delete_prefix(CONTRACT_DIGEST_PREFIX)
end

def digest_validation(contract, policy: SUPPORTED_POLICY, recompute: true)
  diagnostics = []
  if policy != SUPPORTED_POLICY
    diagnostics << diagnostic("contract_digest_policy_unsupported", "unsupported contract_digest policy #{policy.inspect}", "digest_reference_policy")
  elsif !contract["contract_digest"].to_s.match?(CONTRACT_DIGEST_PATTERN)
    diagnostics << diagnostic("contract_digest_invalid", "contract_digest must be compiler_profile_contract/sha256:<24+ lowercase hex>", "contract_digest")
  elsif recompute == :unavailable
    diagnostics << diagnostic("contract_digest_recompute_unavailable", "contract digest recompute requested but canonicalization is unavailable", "contract_digest")
  elsif recompute
    computed = recomputed_hex(contract)
    diagnostics << diagnostic("contract_digest_mismatch", "declared contract_digest does not match recomputed canonical contract digest", "contract_digest") unless computed.start_with?(declared_hex(contract))
  end

  {
    "kind" => "compiler_profile_contract_validation_result",
    "format_version" => FORMAT_VERSION,
    "valid" => diagnostics.empty?,
    "diagnostics" => diagnostics,
    "diagnostic_codes" => diagnostics.map { |entry| entry.fetch("code") },
    "digest_reference_policy" => policy,
    "compiler_integrated" => false,
    "compile_refusal_authorized" => false,
    "report_only" => true,
    "shape_policy_model" => true,
    "recompute_match_model" => !!recompute && recompute != :unavailable,
    "digest_report_only_live_implemented" => false
  }
end

def baseline_compile
  {
    "status" => "ok",
    "result" => {
      "status" => "ok",
      "igapp_path" => "/proof-local/out/add.igapp",
      "artifact" => "compiled_program/add"
    },
    "public_result" => {
      "status" => "ok",
      "artifact" => "compiled_program/add"
    },
    "report" => {
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
    },
    "manifest" => {
      "kind" => "igapp_manifest",
      "format_version" => FORMAT_VERSION,
      "semantic_ir_ref" => "semantic_ir/add",
      "compiler_profile_id" => "compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7"
    },
    "assembler_executed" => true,
    "refusal_report_written" => false
  }
end

def annotate_report_only(baseline, validation)
  run = deep_copy(baseline)
  run["report"] = run.fetch("report").merge("compiler_profile_contract_validation" => validation)
  run
end

def provider_nil_run(baseline)
  deep_copy(baseline)
end

def provider_exception_run(baseline)
  deep_copy(baseline).merge("provider_exception_swallowed" => true)
end

def same_outcome?(baseline, run)
  run.fetch("status") == baseline.fetch("status") &&
    run.fetch("public_result") == baseline.fetch("public_result") &&
    run.fetch("manifest") == baseline.fetch("manifest") &&
    run.fetch("report").fetch("pass_result") == baseline.fetch("report").fetch("pass_result") &&
    run.fetch("report").fetch("stages") == baseline.fetch("report").fetch("stages") &&
    run.fetch("report").fetch("diagnostics") == baseline.fetch("report").fetch("diagnostics") &&
    run.fetch("assembler_executed") == baseline.fetch("assembler_executed") &&
    run.fetch("refusal_report_written") == false
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

contract_summary = read_json(CONTRACT_SUMMARY_PATH)
shape_summary = read_json(SHAPE_SUMMARY_PATH)
recompute_summary = read_json(RECOMPUTE_SUMMARY_PATH)
integration_summary = read_json(R67_INTEGRATION_SUMMARY_PATH)
canonical_contract = contract_summary.fetch("canonical_contract")
canonical_hex = recomputed_hex(canonical_contract)

valid_contract = deep_copy(canonical_contract)
valid_contract["contract_digest"] = digest_ref(canonical_hex)

shape_invalid_contract = deep_copy(canonical_contract)
shape_invalid_contract["contract_digest"] = "compiler_profile_contract/sha256:abc"

unsupported_policy_contract = deep_copy(valid_contract)

mismatch_contract = deep_copy(canonical_contract)
mismatch_contract["contract_digest"] = digest_ref(replace_first_hex_char(canonical_hex))

unavailable_contract = deep_copy(valid_contract)

combined_contract = deep_copy(shape_invalid_contract)

valid_validation = digest_validation(valid_contract)
shape_invalid_validation = digest_validation(shape_invalid_contract)
unsupported_policy_validation = digest_validation(unsupported_policy_contract, policy: "prop038_full_sha256")
mismatch_validation = digest_validation(mismatch_contract)
unavailable_validation = digest_validation(unavailable_contract, recompute: :unavailable)
combined_shape_validation = digest_validation(combined_contract)
combined_recompute_validation = digest_validation(unavailable_contract, recompute: :unavailable)
combined_validation = combined_shape_validation.merge(
  "valid" => false,
  "diagnostics" => combined_shape_validation.fetch("diagnostics") + combined_recompute_validation.fetch("diagnostics"),
  "diagnostic_codes" => combined_shape_validation.fetch("diagnostic_codes") + combined_recompute_validation.fetch("diagnostic_codes")
)

baseline = baseline_compile
valid_run = annotate_report_only(baseline, valid_validation)
shape_invalid_run = annotate_report_only(baseline, shape_invalid_validation)
unsupported_policy_run = annotate_report_only(baseline, unsupported_policy_validation)
mismatch_run = annotate_report_only(baseline, mismatch_validation)
unavailable_run = annotate_report_only(baseline, unavailable_validation)
combined_run = annotate_report_only(baseline, combined_validation)
nil_run = provider_nil_run(baseline)
exception_run = provider_exception_run(baseline)

live_invalid_digest_contract = deep_copy(canonical_contract)
live_invalid_digest_contract["contract_digest"] = "compiler_profile_contract/sha256:ABC"
live_validator_result = IgniterLang::CompilerProfileContractValidator.validate(live_invalid_digest_contract)

integration_valid_case = Array(integration_summary["cases"]).find { |entry| entry["name"] == "valid_contract" }
integration_invalid_case = Array(integration_summary["cases"]).find { |entry| entry["name"] == "invalid_contract" }
out_files = Dir.glob(File.join(OUT_DIR, "**", "*"), File::FNM_DOTMATCH).select { |path| File.file?(path) }

cases = [
  case_entry("valid_digest_report_only_valid_true", "valid=true nested report-only validation", valid_validation["valid"] == true && same_outcome?(baseline, valid_run), "validation" => valid_validation),
  case_entry("shape_invalid_report_only_valid_false", "contract_digest_invalid nested", shape_invalid_validation["valid"] == false && shape_invalid_validation["diagnostic_codes"].include?("compiler_profile_contract.contract_digest_invalid") && same_outcome?(baseline, shape_invalid_run), "validation" => shape_invalid_validation),
  case_entry("unsupported_policy_report_only_valid_false", "contract_digest_policy_unsupported nested", unsupported_policy_validation["valid"] == false && unsupported_policy_validation["diagnostic_codes"].include?("compiler_profile_contract.contract_digest_policy_unsupported") && same_outcome?(baseline, unsupported_policy_run), "validation" => unsupported_policy_validation),
  case_entry("recompute_mismatch_report_only_valid_false", "contract_digest_mismatch nested", mismatch_validation["valid"] == false && mismatch_validation["diagnostic_codes"].include?("compiler_profile_contract.contract_digest_mismatch") && same_outcome?(baseline, mismatch_run), "validation" => mismatch_validation),
  case_entry("recompute_unavailable_report_only_valid_false", "contract_digest_recompute_unavailable nested", unavailable_validation["valid"] == false && unavailable_validation["diagnostic_codes"].include?("compiler_profile_contract.contract_digest_recompute_unavailable") && same_outcome?(baseline, unavailable_run), "validation" => unavailable_validation),
  case_entry("combined_shape_and_recompute_diagnostics_stay_nested", "digest diagnostics live only under compiler_profile_contract_validation.diagnostics", combined_run["report"]["compiler_profile_contract_validation"]["diagnostic_codes"].sort == %w[compiler_profile_contract.contract_digest_invalid compiler_profile_contract.contract_digest_recompute_unavailable].sort && combined_run["report"]["diagnostics"] == baseline["report"]["diagnostics"], "report" => combined_run["report"]),
  case_entry("mismatch_compile_status_ok", "status remains ok", mismatch_run["status"] == "ok"),
  case_entry("mismatch_public_result_unchanged", "public result unchanged", mismatch_run["public_result"] == baseline["public_result"]),
  case_entry("mismatch_igapp_manifest_unchanged", "manifest unchanged", mismatch_run["manifest"] == baseline["manifest"]),
  case_entry("mismatch_no_refusal_report_written", "no refusal report", mismatch_run["refusal_report_written"] == false),
  case_entry("provider_nil_preserves_legacy_behavior", "no validation report and baseline outcome", !nil_run["report"].key?("compiler_profile_contract_validation") && same_outcome?(baseline, nil_run)),
  case_entry("provider_exception_preserves_legacy_behavior", "no validation report and baseline outcome", exception_run["provider_exception_swallowed"] == true && !exception_run["report"].key?("compiler_profile_contract_validation") && same_outcome?(baseline, exception_run))
]

all_digest_codes = cases.flat_map do |entry|
  validation = entry["validation"] || entry.dig("report", "compiler_profile_contract_validation")
  Array(validation && validation["diagnostic_codes"])
end.uniq.sort
required_digest_codes = %w[
  compiler_profile_contract.contract_digest_invalid
  compiler_profile_contract.contract_digest_policy_unsupported
  compiler_profile_contract.contract_digest_mismatch
  compiler_profile_contract.contract_digest_recompute_unavailable
].sort

checks = []
assert("cases_all_pass", cases.all? { |entry| entry.fetch("pass") }, checks)
assert("diagnostic_coverage.all_four_codes", all_digest_codes == required_digest_codes, checks)
assert("nested_diagnostics.only", [shape_invalid_run, unsupported_policy_run, mismatch_run, unavailable_run, combined_run].all? { |run| run["report"].key?("compiler_profile_contract_validation") && run["report"]["diagnostics"] == baseline["report"]["diagnostics"] }, checks)
assert("top_level_diagnostics_unchanged", mismatch_run["report"]["diagnostics"] == baseline["report"]["diagnostics"], checks)
assert("pass_result_unchanged", mismatch_run["report"]["pass_result"] == baseline["report"]["pass_result"], checks)
assert("stages_unchanged", mismatch_run["report"]["stages"] == baseline["report"]["stages"], checks)
assert("compile_status_ok", mismatch_run["status"] == "ok", checks)
assert("public_result_unchanged", mismatch_run["public_result"] == baseline["public_result"], checks)
assert("assembler_execution_unchanged", mismatch_run["assembler_executed"] == baseline["assembler_executed"], checks)
assert("igapp_manifest_unchanged", mismatch_run["manifest"] == baseline["manifest"], checks)
assert("no_refusal_report_written", mismatch_run["refusal_report_written"] == false, checks)
assert("regression.recompute_match_proof_pass", recompute_summary["status"] == "PASS", checks)
assert("regression.shape_policy_proof_pass", shape_summary["status"] == "PASS", checks)
assert("regression.report_only_integration_pass", integration_summary["status"] == "PASS", checks)
assert("regression.validator_matrix_13_cases", Array(contract_summary["validator_case_matrix"]).size == 13 && contract_summary["status"] == "PASS", checks)
assert("regression.live_validator_no_contract_digest_behavior", live_validator_result["valid"] == true && live_validator_result["diagnostic_codes"].none? { |code| code.include?("contract_digest") }, checks)
assert("compile_refusal_false.proof_local", [valid_validation, shape_invalid_validation, unsupported_policy_validation, mismatch_validation, unavailable_validation, combined_validation].all? { |validation| validation["compile_refusal_authorized"] == false }, checks)
assert("compile_refusal_false.live_validator", live_validator_result["compile_refusal_authorized"] == false, checks)
assert("compile_refusal_false.r67_report_only", [integration_valid_case, integration_invalid_case].all? { |entry| entry&.dig("validation", "compile_refusal_authorized") == false }, checks)
assert("no_igapp_mutation_from_this_proof", Dir.glob(File.join(OUT_DIR, "**", "*.igapp")).empty?, checks)
assert("no_refusal_report_created_by_this_proof", out_files.none? { |path| File.basename(path).include?("refusal") }, checks)

failed_checks = checks.reject { |check| check.fetch("pass") }
non_authorizations_preserved = {
  "live_validator_implementation" => false,
  "compiler_orchestrator_integration" => false,
  "compile_refusal" => false,
  "public_api_cli_widening" => false,
  "compiler_result_changes" => false,
  "persisted_success_reports_or_sidecars" => false,
  "parser_typechecker_semanticir_assembler_igapp" => false,
  "loader_report_or_compatibility_report" => false,
  "diagnostics_centralization" => false,
  "runtime_gate3_ledger_tbackend_bihistory_stream_olap_cache_production" => false
}

summary = {
  "kind" => "prop038_contract_digest_report_only_integration_proof_summary",
  "format_version" => FORMAT_VERSION,
  "track" => "prop038-contract-digest-report-only-integration-proof-v0",
  "authority_ref" => "igniter-lang/docs/gates/prop038-contract-digest-recompute-match-proof-decision-v0.md",
  "status" => failed_checks.empty? ? "PASS" : "FAIL",
  "cases" => cases,
  "checks" => checks,
  "failed_checks" => failed_checks,
  "shape_policy_proof_status" => shape_summary["status"],
  "recompute_match_proof_status" => recompute_summary["status"],
  "report_only_integration_status" => integration_summary["status"],
  "live_validator_changed" => false,
  "compiler_integration_changed" => false,
  "digest_report_only_live_implemented" => false,
  "compile_refusal_authorized" => false,
  "implementation_authorized" => false,
  "diagnostic_coverage" => {
    "required_codes" => required_digest_codes,
    "observed_codes" => all_digest_codes
  },
  "report_only_invariants" => {
    "diagnostics_nested_under" => "compiler_profile_contract_validation.diagnostics",
    "top_level_report_diagnostics_unchanged" => true,
    "pass_result_unchanged" => true,
    "stages_unchanged" => true,
    "compile_status_ok_when_source_compiles" => true,
    "public_result_unchanged" => true,
    "assembler_execution_unchanged" => true,
    "igapp_manifest_unchanged" => true,
    "refusal_report_written" => false
  },
  "regression_sources" => {
    "recompute_match_summary_path" => RECOMPUTE_SUMMARY_PATH,
    "shape_policy_summary_path" => SHAPE_SUMMARY_PATH,
    "report_only_integration_summary_path" => R67_INTEGRATION_SUMMARY_PATH,
    "validator_summary_path" => CONTRACT_SUMMARY_PATH
  },
  "non_authorizations_preserved" => non_authorizations_preserved,
  "recommendation_for_c3_a" => "accept"
}

File.write(SUMMARY_PATH, JSON.pretty_generate(summary) + "\n")

if summary.fetch("status") == "PASS"
  puts "PASS prop038_contract_digest_report_only_integration_proof"
else
  warn JSON.pretty_generate(failed_checks)
  exit 1
end
