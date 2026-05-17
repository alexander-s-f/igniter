# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"

require_relative "../../lib/igniter_lang/compiler_profile_contract_validator"

ROOT = File.expand_path("../../..", __dir__)
OUT_DIR = File.join(__dir__, "out")
SUMMARY_PATH = File.join(OUT_DIR, "compiler_profile_contract_proof_summary.json")
TRACK = "prop038-library-validator-extraction-implementation-v0"
EXTENDS_TRACK = "prop038-proof-local-missing-after-implementation-v0"
VALIDATOR = IgniterLang::CompilerProfileContractValidator

PROFILE_SOURCE_PATH = File.join(
  ROOT,
  "igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out/compiler_profile_source.stage3_proof.json"
)
OBLIGATION_SUMMARY_PATH = File.join(
  ROOT,
  "igniter-lang/experiments/compiler_profile_obligation_coverage_proof/out/compiler_profile_obligation_coverage_summary.json"
)

LOADER_REPORT_TERMS = %w[absent_legacy present_verified mismatch malformed missing_required].freeze

DISCLAIMER = "SemanticIR profile-obligation checkpoint is a proposed future design position, not current implementation."

def read_json(path)
  JSON.parse(File.read(path))
end

def deep_copy(value)
  Marshal.load(Marshal.dump(value))
end

def stable_json(value)
  JSON.generate(normalize(value))
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

def sha256_ref(prefix, value)
  "#{prefix}/sha256:#{Digest::SHA256.hexdigest(stable_json(value))[0, 24]}"
end

def build_contract(profile_source)
  slot_assignments = profile_source.fetch("slot_assignments")
  strict_oof = [
    { "key" => "OOF-P1", "owner_slot" => "oof_registry", "rule_ref" => "oof_registry.unresolved_symbol.v0" },
    { "key" => "OOF-M1", "owner_slot" => "contract_modifiers", "rule_ref" => "contract_modifiers.oof_m1_pure_escape.v0" },
    { "key" => "OOF-A1", "owner_slot" => "assumptions", "rule_ref" => "assumptions.oof_a1_undeclared.v0" },
    { "key" => "OOF-PR1", "owner_slot" => "pipeline", "rule_ref" => "pipeline.progression.oof_pr1_descriptor_required.v0" }
  ]
  strict_fragment = [
    { "key" => "core", "owner_slot" => "core", "rule_ref" => "fragment_registry.core.v0" },
    { "key" => "escape", "owner_slot" => "escape_boundary", "rule_ref" => "fragment_registry.escape.v0" },
    { "key" => "temporal", "owner_slot" => "temporal", "rule_ref" => "fragment_registry.temporal.v0" },
    { "key" => "stream", "owner_slot" => "stream", "rule_ref" => "fragment_registry.stream.v0" },
    { "key" => "epistemic", "owner_slot" => "assumptions", "rule_ref" => "fragment_registry.epistemic.v0" }
  ]
  ordered_rules = [
    {
      "rule_id" => "parse.contract_modifiers",
      "stage" => "parse",
      "owner_slot" => "contract_modifiers",
      "before" => ["classify.contract_modifiers"],
      "after" => []
    },
    {
      "rule_id" => "classify.contract_modifiers",
      "stage" => "classify",
      "owner_slot" => "contract_modifiers",
      "before" => ["typecheck.oof_propagation"],
      "after" => ["parse.contract_modifiers"]
    },
    {
      "rule_id" => "typecheck.oof_propagation",
      "stage" => "typecheck",
      "owner_slot" => "oof_registry",
      "before" => ["emit.modifier_field"],
      "after" => ["classify.contract_modifiers"]
    },
    {
      "rule_id" => "emit.modifier_field",
      "stage" => "emit",
      "owner_slot" => "contract_modifiers",
      "before" => [],
      "after" => ["typecheck.oof_propagation"]
    }
  ]

  contract_without_digest = {
    "kind" => "compiler_profile_contract",
    "format_version" => "0.1.0",
    "profile_namespace" => profile_source.fetch("profile_namespace"),
    "profile_kind" => profile_source.fetch("profile_kind"),
    "compiler_profile_id" => profile_source.fetch("compiler_profile_id"),
    "descriptor_digest" => profile_source.fetch("descriptor_digest"),
    "finalization_payload_digest" => profile_source.fetch("finalization_payload_digest"),
    "required_slot_schema" => {
      "required_slots" => VALIDATOR::REQUIRED_SLOTS,
      "optional_slots" => VALIDATOR::OPTIONAL_SLOTS,
      "all_slots" => VALIDATOR::ALL_SLOTS,
      "cardinality" => VALIDATOR::REQUIRED_SLOTS.to_h { |slot| [slot, "exactly_one"] }
    },
    "slot_order" => profile_source.fetch("slot_order"),
    "slot_assignments" => slot_assignments,
    "strict_registries" => {
      "oof_descriptors" => strict_oof,
      "fragment_class_owners" => strict_fragment
    },
    "ordered_rule_graph" => {
      "rules" => ordered_rules
    },
    "non_authority" => {
      "runtime_authority_granted" => false,
      "dispatch_migration_authorized" => false,
      "compiler_understanding_only" => true
    }
  }

  contract_without_digest.merge(
    "contract_digest" => sha256_ref("compiler_profile_contract", contract_without_digest)
  )
end

def source_projection(contract)
  {
    "kind" => "compiler_profile_id_source",
    "format_version" => contract.fetch("format_version"),
    "status" => "finalized",
    "profile_namespace" => contract.fetch("profile_namespace"),
    "compiler_profile_id" => contract.fetch("compiler_profile_id"),
    "descriptor_digest" => contract.fetch("descriptor_digest"),
    "finalization_payload_digest" => contract.fetch("finalization_payload_digest"),
    "profile_kind" => contract.fetch("profile_kind"),
    "slot_order" => contract.fetch("slot_order"),
    "slot_assignments" => contract.fetch("slot_assignments"),
    "dispatch_migration_authorized" => contract.fetch("non_authority").fetch("dispatch_migration_authorized"),
    "runtime_authority_granted" => contract.fetch("non_authority").fetch("runtime_authority_granted")
  }
end

def case_result(name, contract)
  validation = VALIDATOR.validate(contract)
  {
    "name" => name,
    "valid" => validation.fetch("valid"),
    "diagnostics" => validation.fetch("diagnostics"),
    "diagnostic_codes" => validation.fetch("diagnostic_codes")
  }
end

def assert(name, condition, checks)
  checks << { "name" => name, "pass" => !!condition }
end

def case_by_name(cases, name)
  cases.find { |entry| entry.fetch("name") == name } || raise("missing case #{name}")
end

def codes_for(cases, name)
  case_by_name(cases, name).fetch("diagnostic_codes")
end

def profile_not_supplied_required_slots(obligation_summary)
  report = Array(obligation_summary["reports"]).find do |entry|
    entry["case"] == "profile_not_supplied.core_add" || entry["status"] == "profile_not_supplied"
  end
  return [] unless report

  artifacts = Array(report["artifacts"])
  artifacts.flat_map { |artifact| Array(artifact["required_slots"]) }.uniq.sort
end

FileUtils.mkdir_p(OUT_DIR)

profile_source = read_json(PROFILE_SOURCE_PATH)
obligation_summary = read_json(OBLIGATION_SUMMARY_PATH)
valid_contract = build_contract(profile_source)

missing_required_slot_contract = deep_copy(valid_contract)
missing_required_slot_contract["slot_order"] = missing_required_slot_contract.fetch("slot_order").reject { |slot| slot == "oof_registry" }
missing_required_slot_contract["slot_assignments"].delete("oof_registry")

duplicate_strict_key_contract = deep_copy(valid_contract)
duplicate_strict_key_contract["strict_registries"]["oof_descriptors"] << {
  "key" => "OOF-M1",
  "owner_slot" => "assumptions",
  "rule_ref" => "assumptions.accidental_duplicate_oof_m1.v0"
}

duplicate_fragment_owner_contract = deep_copy(valid_contract)
duplicate_fragment_owner_contract["strict_registries"]["fragment_class_owners"] << {
  "key" => "temporal",
  "owner_slot" => "stream",
  "rule_ref" => "fragment_registry.accidental_duplicate_temporal.v0"
}

rule_cycle_contract = deep_copy(valid_contract)
rule_cycle_contract["ordered_rule_graph"]["rules"][0]["after"] = ["emit.modifier_field"]

missing_rule_reference_contract = deep_copy(valid_contract)
missing_rule_reference_contract["ordered_rule_graph"]["rules"][3]["before"] = ["emit.nonexistent_rule"]

missing_after_rule_reference_contract = deep_copy(valid_contract)
missing_after_rule_reference_contract["ordered_rule_graph"]["rules"][0]["after"] = ["parse.nonexistent_rule"]

wrong_kind_contract = deep_copy(valid_contract)
wrong_kind_contract["kind"] = "compiler_profile_source"

unsupported_format_version_contract = deep_copy(valid_contract)
unsupported_format_version_contract["format_version"] = "9.9.9"

descriptor_digest_invalid_contract = deep_copy(valid_contract)
descriptor_digest_invalid_contract["descriptor_digest"] = "sha256:not-a-compiler-profile-descriptor"

finalization_payload_digest_invalid_contract = deep_copy(valid_contract)
finalization_payload_digest_invalid_contract["finalization_payload_digest"] = "sha256:not64hex"

runtime_authority_contract = deep_copy(valid_contract)
runtime_authority_contract["non_authority"]["runtime_authority_granted"] = true

dispatch_migration_contract = deep_copy(valid_contract)
dispatch_migration_contract["non_authority"]["dispatch_migration_authorized"] = true

cases = [
  case_result("valid_contract", valid_contract),
  case_result("missing_required_slot", missing_required_slot_contract),
  case_result("duplicate_strict_key", duplicate_strict_key_contract),
  case_result("duplicate_fragment_class_owner", duplicate_fragment_owner_contract),
  case_result("rule_cycle", rule_cycle_contract),
  case_result("missing_rule_reference", missing_rule_reference_contract),
  case_result("missing_after_rule_reference", missing_after_rule_reference_contract),
  case_result("wrong_kind", wrong_kind_contract),
  case_result("unsupported_format_version", unsupported_format_version_contract),
  case_result("descriptor_digest_invalid", descriptor_digest_invalid_contract),
  case_result("finalization_payload_digest_invalid", finalization_payload_digest_invalid_contract),
  case_result("runtime_authority_forbidden", runtime_authority_contract),
  case_result("dispatch_migration_forbidden", dispatch_migration_contract)
]
validator_result = VALIDATOR.validate(valid_contract)

all_contract_diagnostics = cases.flat_map { |entry| entry.fetch("diagnostic_codes") }
expected_case_diagnostics = {
  "valid_contract" => nil,
  "missing_required_slot" => "compiler_profile_contract.missing_required_slot",
  "duplicate_strict_key" => "compiler_profile_contract.duplicate_strict_key",
  "duplicate_fragment_class_owner" => "compiler_profile_contract.duplicate_strict_key",
  "rule_cycle" => "compiler_profile_contract.rule_cycle",
  "missing_rule_reference" => "compiler_profile_contract.missing_rule_reference",
  "missing_after_rule_reference" => "compiler_profile_contract.missing_rule_reference",
  "wrong_kind" => "compiler_profile_contract.wrong_kind",
  "unsupported_format_version" => "compiler_profile_contract.unsupported_format_version",
  "descriptor_digest_invalid" => "compiler_profile_contract.descriptor_digest_invalid",
  "finalization_payload_digest_invalid" => "compiler_profile_contract.finalization_payload_digest_invalid",
  "runtime_authority_forbidden" => "compiler_profile_contract.runtime_authority_forbidden",
  "dispatch_migration_forbidden" => "compiler_profile_contract.dispatch_migration_forbidden"
}
validator_case_matrix = cases.map do |entry|
  expected = expected_case_diagnostics.fetch(entry.fetch("name"))
  pass = expected.nil? ? entry.fetch("valid") : entry.fetch("diagnostic_codes").include?(expected)
  {
    "case" => entry.fetch("name"),
    "expected" => expected || "valid",
    "actual" => entry.fetch("valid") ? "valid" : entry.fetch("diagnostic_codes"),
    "pass" => pass
  }
end
future_profile_not_supplied = {
  "case" => "future_profile_not_supplied_design",
  "status" => "profile_not_supplied",
  "required_slots" => profile_not_supplied_required_slots(obligation_summary),
  "missing_slots" => []
}

execution_order = [
  "compiler_profile_contract_validated",
  "finalizes_to_compiler_profile_id_source",
  "source_transported_and_validated_by_compiler_profile_source",
  "semantic_ir_emitted",
  "semanticir_profile_obligation_checkpoint",
  "manifest_report_interpretation_later"
]

checks = []
assert("valid_contract.accepted", case_by_name(cases, "valid_contract").fetch("valid"), checks)
assert("validator_result.kind", validator_result.fetch("kind") == "compiler_profile_contract_validation_result", checks)
assert("validator_result.digest_reference_policy", validator_result.fetch("digest_reference_policy") == "prop038_24_plus", checks)
assert("validator_result.compiler_integrated_false", validator_result.fetch("compiler_integrated") == false, checks)
assert("validator_result.compile_refusal_authorized_false", validator_result.fetch("compile_refusal_authorized") == false, checks)
assert("source_projection.matches_profile_source", source_projection(valid_contract) == profile_source, checks)
assert("missing_required_slot.diagnostic", codes_for(cases, "missing_required_slot").include?("compiler_profile_contract.missing_required_slot"), checks)
assert("duplicate_strict_key.diagnostic", codes_for(cases, "duplicate_strict_key").include?("compiler_profile_contract.duplicate_strict_key"), checks)
assert("duplicate_fragment_class_owner.diagnostic", codes_for(cases, "duplicate_fragment_class_owner").include?("compiler_profile_contract.duplicate_strict_key"), checks)
assert("rule_cycle.diagnostic", codes_for(cases, "rule_cycle").include?("compiler_profile_contract.rule_cycle"), checks)
assert("missing_rule_reference.diagnostic", codes_for(cases, "missing_rule_reference").include?("compiler_profile_contract.missing_rule_reference"), checks)
assert("missing_after_rule_reference.diagnostic", codes_for(cases, "missing_after_rule_reference").include?("compiler_profile_contract.missing_rule_reference"), checks)
assert("wrong_kind.diagnostic", codes_for(cases, "wrong_kind").include?("compiler_profile_contract.wrong_kind"), checks)
assert("unsupported_format_version.diagnostic", codes_for(cases, "unsupported_format_version").include?("compiler_profile_contract.unsupported_format_version"), checks)
assert("descriptor_digest_invalid.diagnostic", codes_for(cases, "descriptor_digest_invalid").include?("compiler_profile_contract.descriptor_digest_invalid"), checks)
assert("finalization_payload_digest_invalid.diagnostic", codes_for(cases, "finalization_payload_digest_invalid").include?("compiler_profile_contract.finalization_payload_digest_invalid"), checks)
assert("runtime_authority.diagnostic", codes_for(cases, "runtime_authority_forbidden").include?("compiler_profile_contract.runtime_authority_forbidden"), checks)
assert("dispatch_migration.diagnostic", codes_for(cases, "dispatch_migration_forbidden").include?("compiler_profile_contract.dispatch_migration_forbidden"), checks)
assert("separation.obligation_missing_slot_present", obligation_summary.dig("report_statuses", "missing_slot.temporal_removed") == "missing_slot", checks)
assert("separation.contract_missing_required_slot_distinct", !all_contract_diagnostics.include?("compiler_profile_obligation.missing_slot"), checks)
assert("separation.loader_terms_absent", (all_contract_diagnostics & LOADER_REPORT_TERMS).empty?, checks)
assert("separation.source_terms_absent", all_contract_diagnostics.none? { |code| code.start_with?("compiler_profile_source.") }, checks)
assert("future_profile_not_supplied.required_slots_populated", !future_profile_not_supplied.fetch("required_slots").empty?, checks)
assert("future_profile_not_supplied.missing_slots_empty", future_profile_not_supplied.fetch("missing_slots").empty?, checks)
assert("ordering.contract_before_source", execution_order.index("compiler_profile_contract_validated") < execution_order.index("finalizes_to_compiler_profile_id_source"), checks)
assert("ordering.obligation_after_semanticir", execution_order.index("semantic_ir_emitted") < execution_order.index("semanticir_profile_obligation_checkpoint"), checks)
assert("disclaimer.present", DISCLAIMER.include?("not current implementation"), checks)

summary = {
  "kind" => "compiler_profile_contract_proof_summary",
  "format_version" => "0.1.0",
  "track" => TRACK,
  "extends_track" => EXTENDS_TRACK,
  "status" => checks.all? { |check| check.fetch("pass") } ? "PASS" : "FAIL",
  "canonical_contract" => valid_contract,
  "validator_result_shape" => {
    "kind" => validator_result.fetch("kind"),
    "format_version" => validator_result.fetch("format_version"),
    "digest_reference_policy" => validator_result.fetch("digest_reference_policy"),
    "compiler_integrated" => validator_result.fetch("compiler_integrated"),
    "compile_refusal_authorized" => validator_result.fetch("compile_refusal_authorized")
  },
  "source_projection_matches_profile_source" => source_projection(valid_contract) == profile_source,
  "cases" => cases,
  "validator_case_matrix" => validator_case_matrix,
  "diagnostic_separation" => {
    "contract_missing_required_slot" => "compiler_profile_contract.missing_required_slot",
    "obligation_missing_slot_status" => "compiler_profile_obligation.missing_slot",
    "distinct" => !all_contract_diagnostics.include?("compiler_profile_obligation.missing_slot"),
    "loader_report_terms_absent_as_contract_diagnostics" => (all_contract_diagnostics & LOADER_REPORT_TERMS).empty?,
    "compiler_profile_source_terms_absent_as_contract_diagnostics" => all_contract_diagnostics.none? { |code| code.start_with?("compiler_profile_source.") }
  },
  "future_profile_not_supplied_design" => future_profile_not_supplied,
  "execution_order" => execution_order,
  "disclaimer" => DISCLAIMER,
  "non_authorizations_preserved" => {
    "live_compiler_dispatch" => false,
    "compiler_integrated" => validator_result.fetch("compiler_integrated"),
    "compile_refusal_authorized" => validator_result.fetch("compile_refusal_authorized"),
    "igapp_artifacts" => false,
    "goldens" => false,
    "cli_api" => false,
    "loader_report" => false,
    "compatibility_report" => false,
    "runtime_machine" => false,
    "gate3" => false,
    "ledger_tbackend" => false,
    "bihistory" => false,
    "stream_olap_production" => false,
    "cache" => false,
    "production_behavior" => false
  },
  "checks" => checks,
  "remaining_blockers_before_compiler_integration" => [
    "contract input ownership without public API or CLI widening",
    "report/output location if validation stops being proof-local",
    "orchestrator insertion point after contract input ownership is resolved",
    "fixture/golden policy for any persisted artifact or report mutation",
    "descriptor_digest input material and canonicalization for integrated or persisted behavior",
    "contract_digest format and mismatch diagnostics if the contract digest becomes enforced",
    "dedicated gate for report-only compiler integration or compile refusal"
  ]
}

File.write(SUMMARY_PATH, JSON.pretty_generate(summary) + "\n")

if summary.fetch("status") == "PASS"
  puts "PASS compiler_profile_contract_proof"
else
  warn JSON.pretty_generate(checks.reject { |check| check.fetch("pass") })
  exit 1
end
