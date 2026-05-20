#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

ROOT = Pathname.new(File.expand_path("../../..", __dir__))
OUT_DIR = ROOT.join("igniter-lang/experiments/oof_fragment_registry_policy_proof/out")

SHADOW_DESCRIPTOR_PATH = ROOT.join(
  "igniter-lang/experiments/oof_fragment_registry_shadow_proof/out/oof_descriptors.shadow_registry.json"
)
SHADOW_FRAGMENT_PATH = ROOT.join(
  "igniter-lang/experiments/oof_fragment_registry_shadow_proof/out/fragment_registry.shadow_registry.json"
)
SHADOW_SUMMARY_PATH = ROOT.join(
  "igniter-lang/experiments/oof_fragment_registry_shadow_proof/out/oof_fragment_registry_shadow_proof_summary.json"
)

TRACK = "oof-fragment-registry-policy-proof-v0"
EXCLUDED_PREFIXES = ["compiler_profile_contract.", "compiler_profile_contract_refusal."].freeze
GUARDED_NON_FRAGMENTS = %w[olap progression].freeze

def deep_copy(value)
  JSON.parse(JSON.generate(value))
end

def diagnostic(code, path, message)
  { "code" => code, "path" => path, "message" => message }
end

def check(name, details = nil)
  ok = yield
  { "name" => name, "status" => ok ? "PASS" : "FAIL", "details" => details }.compact
end

def validate_alias_policy(descriptors)
  diagnostics = []
  by_code = {}
  descriptors.each_with_index do |descriptor, index|
    code = descriptor.fetch("code", nil)
    if code.nil? || code.empty?
      diagnostics << diagnostic("oof_registry.code_missing", "descriptors[#{index}].code", "descriptor code is required")
      next
    end
    if by_code.key?(code)
      diagnostics << diagnostic("oof_registry.code_collision", "descriptors[#{index}].code", "descriptor code collides with an existing descriptor")
    else
      by_code[code] = descriptor
    end
  end

  alias_owner = {}
  descriptors.each_with_index do |descriptor, index|
    code = descriptor.fetch("code", nil)
    aliases = descriptor.fetch("aliases", [])
    aliases.each do |alias_code|
      if by_code.key?(alias_code) && by_code.fetch(alias_code).fetch("current_status", nil) != "compatibility_alias"
        diagnostics << diagnostic("oof_registry.alias_collides_with_current_code", "descriptors[#{index}].aliases", "#{alias_code} is already a current descriptor")
      end
      if alias_owner.key?(alias_code) && alias_owner.fetch(alias_code) != code
        diagnostics << diagnostic("oof_registry.alias_collision", "descriptors[#{index}].aliases", "#{alias_code} is claimed by multiple descriptors")
      end
      alias_owner[alias_code] = code
    end
  end

  descriptors.each_with_index do |descriptor, index|
    next unless descriptor.fetch("current_status", nil) == "compatibility_alias"

    replacement = descriptor.fetch("replacement_code", nil)
    replacement_descriptor = by_code[replacement]
    diagnostics << diagnostic("oof_registry.alias_missing_replacement", "descriptors[#{index}].replacement_code", "compatibility alias requires an existing replacement") if replacement_descriptor.nil?

    next if replacement_descriptor.nil?

    unless replacement_descriptor.fetch("current_status", nil) == "current"
      diagnostics << diagnostic("oof_registry.alias_replacement_not_current", "descriptors[#{index}].replacement_code", "compatibility alias replacement must be a current descriptor")
    end
  end

  diagnostics
end

def validate_exclusion_policy(descriptors)
  diagnostics = []
  descriptors.each_with_index do |descriptor, index|
    code = descriptor.fetch("code", "")
    aliases = descriptor.fetch("aliases", [])
    ([code] + aliases).each do |token|
      if EXCLUDED_PREFIXES.any? { |prefix| token.start_with?(prefix) }
        diagnostics << diagnostic("oof_registry.excluded_namespace", "descriptors[#{index}]", "#{token} is outside the OOF namespace")
      end
    end
  end
  diagnostics
end

def validate_oof_projection_policy(fragment)
  diagnostics = []
  unless fragment.fetch("name", nil) == "oof"
    diagnostics << diagnostic("fragment_registry.oof_projection_missing", "fragment.name", "expected oof fragment projection row")
    return diagnostics
  end

  unless fragment.fetch("primary_semantics", nil) == "status"
    diagnostics << diagnostic("fragment_registry.oof_projection_not_status_primary", "fragment.primary_semantics", "oof must be status-primary")
  end

  guard = fragment.fetch("projection_guard", {})
  diagnostics << diagnostic("fragment_registry.oof_projection_not_blocked", "fragment.projection_guard.blocked", "oof projection must be blocked") unless guard.fetch("blocked", false)
  diagnostics << diagnostic("fragment_registry.oof_projection_loadable", "fragment.projection_guard.loadable", "oof projection must be non-loadable") if guard.fetch("loadable", true)
  diagnostics << diagnostic("fragment_registry.oof_projection_not_status_only", "fragment.projection_guard.status_only", "oof projection must be status-only") unless guard.fetch("status_only", false)
  diagnostics << diagnostic("fragment_registry.oof_projection_capability", "fragment.projection_guard.capability", "oof projection must not grant capabilities") if guard.fetch("capability", false)
  diagnostics
end

def validate_guarded_non_fragment_policy(fragments)
  diagnostics = []
  guarded = fragments.select { |fragment| GUARDED_NON_FRAGMENTS.include?(fragment.fetch("name", nil)) }
  missing = GUARDED_NON_FRAGMENTS - guarded.map { |fragment| fragment.fetch("name") }
  missing.each do |name|
    diagnostics << diagnostic("fragment_registry.guarded_non_fragment_missing", "fragments.#{name}", "#{name} guarded non-fragment row is required")
  end

  guarded.each do |fragment|
    name = fragment.fetch("name")
    unless fragment.fetch("classification_kind", nil) == "not_fragment_class"
      diagnostics << diagnostic("fragment_registry.guarded_non_fragment_promoted", "fragments.#{name}.classification_kind", "#{name} must not be promoted to fragment class")
    end
    unless fragment.fetch("precedence_candidate", nil).nil?
      diagnostics << diagnostic("fragment_registry.guarded_non_fragment_precedence", "fragments.#{name}.precedence_candidate", "#{name} must not receive fragment precedence")
    end
    if fragment.fetch("loadable", false)
      diagnostics << diagnostic("fragment_registry.guarded_non_fragment_loadable", "fragments.#{name}.loadable", "#{name} must not be loadable")
    end
  end
  diagnostics
end

shadow_summary = JSON.parse(File.read(SHADOW_SUMMARY_PATH))
descriptor_payload = JSON.parse(File.read(SHADOW_DESCRIPTOR_PATH))
fragment_payload = JSON.parse(File.read(SHADOW_FRAGMENT_PATH))

base_descriptors = descriptor_payload.fetch("descriptors")
base_fragments = fragment_payload.fetch("fragments")
oof_fragment = base_fragments.find { |fragment| fragment.fetch("name") == "oof" }
policy_oof_fragment = oof_fragment.merge(
  "primary_semantics" => "status",
  "secondary_projection" => "fragment",
  "projection_guard" => {
    "blocked" => true,
    "loadable" => false,
    "status_only" => true,
    "capability" => false
  }
)

policy_fragments = base_fragments.map do |fragment|
  next policy_oof_fragment if fragment.fetch("name") == "oof"
  next fragment.merge("loadable" => false) if GUARDED_NON_FRAGMENTS.include?(fragment.fetch("name"))

  fragment
end

cases = []
cases << {
  "name" => "alias_policy.valid_shadow_descriptors",
  "expected" => "accepted",
  "diagnostics" => validate_alias_policy(base_descriptors)
}

duplicate_code = deep_copy(base_descriptors)
duplicate_code << duplicate_code.first.merge("family" => "synthetic_collision")
cases << {
  "name" => "alias_policy.duplicate_code_rejected",
  "expected" => "rejected",
  "diagnostics" => validate_alias_policy(duplicate_code)
}

alias_collision = deep_copy(base_descriptors)
alias_collision.find { |descriptor| descriptor.fetch("code") == "OOF-P1" }.fetch("aliases") << "OOF-TM1"
cases << {
  "name" => "alias_policy.alias_claimed_by_multiple_codes_rejected",
  "expected" => "rejected",
  "diagnostics" => validate_alias_policy(alias_collision)
}

alias_missing_replacement = deep_copy(base_descriptors)
alias_missing_replacement.find { |descriptor| descriptor.fetch("code") == "OOF-TM1" }["replacement_code"] = "OOF-NOT-REAL"
cases << {
  "name" => "alias_policy.missing_replacement_rejected",
  "expected" => "rejected",
  "diagnostics" => validate_alias_policy(alias_missing_replacement)
}

alias_replacement_candidate = deep_copy(base_descriptors)
alias_replacement_candidate.find { |descriptor| descriptor.fetch("code") == "OOF-TM1" }["replacement_code"] = "OOF-H2"
cases << {
  "name" => "alias_policy.candidate_replacement_rejected",
  "expected" => "rejected",
  "diagnostics" => validate_alias_policy(alias_replacement_candidate)
}

cases << {
  "name" => "oof_projection.valid_blocked_non_loadable_status_only",
  "expected" => "accepted",
  "diagnostics" => validate_oof_projection_policy(policy_oof_fragment)
}

loadable_oof = deep_copy(policy_oof_fragment)
loadable_oof["projection_guard"]["loadable"] = true
cases << {
  "name" => "oof_projection.loadable_rejected",
  "expected" => "rejected",
  "diagnostics" => validate_oof_projection_policy(loadable_oof)
}

capability_oof = deep_copy(policy_oof_fragment)
capability_oof["projection_guard"]["capability"] = true
cases << {
  "name" => "oof_projection.capability_rejected",
  "expected" => "rejected",
  "diagnostics" => validate_oof_projection_policy(capability_oof)
}

not_status_oof = deep_copy(policy_oof_fragment)
not_status_oof["primary_semantics"] = "fragment"
cases << {
  "name" => "oof_projection.not_status_primary_rejected",
  "expected" => "rejected",
  "diagnostics" => validate_oof_projection_policy(not_status_oof)
}

cases << {
  "name" => "guarded_non_fragment.valid_olap_progression",
  "expected" => "accepted",
  "diagnostics" => validate_guarded_non_fragment_policy(policy_fragments)
}

promoted_olap = deep_copy(policy_fragments)
promoted_olap.find { |fragment| fragment.fetch("name") == "olap" }["classification_kind"] = "language_fragment"
cases << {
  "name" => "guarded_non_fragment.olap_promotion_rejected",
  "expected" => "rejected",
  "diagnostics" => validate_guarded_non_fragment_policy(promoted_olap)
}

progression_precedence = deep_copy(policy_fragments)
progression_precedence.find { |fragment| fragment.fetch("name") == "progression" }["precedence_candidate"] = 50
cases << {
  "name" => "guarded_non_fragment.progression_precedence_rejected",
  "expected" => "rejected",
  "diagnostics" => validate_guarded_non_fragment_policy(progression_precedence)
}

olap_loadable = deep_copy(policy_fragments)
olap_loadable.find { |fragment| fragment.fetch("name") == "olap" }["loadable"] = true
cases << {
  "name" => "guarded_non_fragment.olap_loadable_rejected",
  "expected" => "rejected",
  "diagnostics" => validate_guarded_non_fragment_policy(olap_loadable)
}

cases << {
  "name" => "exclusion.valid_shadow_descriptors",
  "expected" => "accepted",
  "diagnostics" => validate_exclusion_policy(base_descriptors)
}

excluded_code = deep_copy(base_descriptors)
excluded_code << base_descriptors.first.merge("code" => "compiler_profile_contract.contract_digest_mismatch")
cases << {
  "name" => "exclusion.compiler_profile_contract_descriptor_rejected",
  "expected" => "rejected",
  "diagnostics" => validate_exclusion_policy(excluded_code)
}

excluded_refusal_alias = deep_copy(base_descriptors)
excluded_refusal_alias.first.fetch("aliases") << "compiler_profile_contract_refusal.contract_digest_mismatch"
cases << {
  "name" => "exclusion.compiler_profile_refusal_alias_rejected",
  "expected" => "rejected",
  "diagnostics" => validate_exclusion_policy(excluded_refusal_alias)
}

case_results = cases.map do |entry|
  accepted = entry.fetch("diagnostics").empty?
  expected_accepted = entry.fetch("expected") == "accepted"
  entry.merge(
    "status" => accepted == expected_accepted ? "PASS" : "FAIL",
    "accepted" => accepted
  )
end

checks = []
checks << check("source_shadow_proof.pass_evidence") { shadow_summary.fetch("status") == "PASS" }
checks << check("case_matrix.all_expected_results") { case_results.all? { |entry| entry.fetch("status") == "PASS" } }
checks << check("alias_policy.accepts_valid_shadow_descriptors") do
  case_results.find { |entry| entry.fetch("name") == "alias_policy.valid_shadow_descriptors" }.fetch("accepted")
end
checks << check("alias_policy.rejects_collisions") do
  %w[
    alias_policy.duplicate_code_rejected
    alias_policy.alias_claimed_by_multiple_codes_rejected
    alias_policy.missing_replacement_rejected
    alias_policy.candidate_replacement_rejected
  ].all? { |name| !case_results.find { |entry| entry.fetch("name") == name }.fetch("accepted") }
end
checks << check("oof_projection.blocks_loadability_and_capability") do
  %w[
    oof_projection.valid_blocked_non_loadable_status_only
    oof_projection.loadable_rejected
    oof_projection.capability_rejected
    oof_projection.not_status_primary_rejected
  ].all? { |name| case_results.find { |entry| entry.fetch("name") == name }.fetch("status") == "PASS" }
end
checks << check("guarded_non_fragment.olap_progression_guarded") do
  %w[
    guarded_non_fragment.valid_olap_progression
    guarded_non_fragment.olap_promotion_rejected
    guarded_non_fragment.progression_precedence_rejected
    guarded_non_fragment.olap_loadable_rejected
  ].all? { |name| case_results.find { |entry| entry.fetch("name") == name }.fetch("status") == "PASS" }
end
checks << check("exclusion.profile_contract_namespaces_blocked") do
  %w[
    exclusion.valid_shadow_descriptors
    exclusion.compiler_profile_contract_descriptor_rejected
    exclusion.compiler_profile_refusal_alias_rejected
  ].all? { |name| case_results.find { |entry| entry.fetch("name") == name }.fetch("status") == "PASS" }
end

policy_model = {
  "kind" => "oof_fragment_registry_policy_model",
  "format_version" => "0.1.0",
  "track" => TRACK,
  "alias_collision_policy" => {
    "canonical_codes_unique" => true,
    "aliases_must_have_descriptors" => true,
    "aliases_must_point_to_current_replacement" => true,
    "aliases_must_not_collide_across_canonical_codes" => true
  },
  "oof_projection_guard" => {
    "primary_semantics" => "status",
    "secondary_projection" => "fragment",
    "blocked" => true,
    "loadable" => false,
    "status_only" => true,
    "capability" => false
  },
  "guarded_non_fragments" => {
    "names" => GUARDED_NON_FRAGMENTS,
    "classification_kind" => "not_fragment_class",
    "precedence_candidate" => nil,
    "loadable" => false
  },
  "excluded_namespaces" => EXCLUDED_PREFIXES,
  "non_authority" => {
    "canon_changed" => false,
    "compiler_runtime_changed" => false,
    "registry_implementation_authorized" => false,
    "dispatch_authorized" => false
  }
}

failed_checks = checks.select { |check_entry| check_entry.fetch("status") != "PASS" }
failed_cases = case_results.select { |case_entry| case_entry.fetch("status") != "PASS" }
status = failed_checks.empty? && failed_cases.empty? ? "PASS" : "FAIL"
recommendation = status == "PASS" ? "PASS_FOR_PROOF_ONLY_POLICY_MODEL_HOLD_IMPLEMENTATION" : "HOLD_POLICY_MODEL"
policy_id = "oof_fragment_policy/sha256:#{Digest::SHA256.hexdigest(JSON.generate(policy_model))[0, 24]}"

summary = {
  "kind" => "oof_fragment_registry_policy_proof_summary",
  "format_version" => "0.1.0",
  "track" => TRACK,
  "status" => status,
  "policy_id" => policy_id,
  "source_shadow_registry_status" => shadow_summary.fetch("status"),
  "cases" => case_results,
  "checks" => checks,
  "failed_cases" => failed_cases,
  "failed_checks" => failed_checks,
  "recommendation" => recommendation,
  "outputs" => {
    "summary" => "igniter-lang/experiments/oof_fragment_registry_policy_proof/out/oof_fragment_registry_policy_proof_summary.json",
    "policy_model" => "igniter-lang/experiments/oof_fragment_registry_policy_proof/out/oof_fragment_registry_policy_model.json"
  },
  "closed_surfaces" => {
    "specs_or_canon_changed" => false,
    "compiler_code_changed" => false,
    "runtime_code_changed" => false,
    "registry_implementation_authorized" => false,
    "dispatch_authorized" => false,
    "public_api_cli_widening_authorized" => false,
    "igapp_or_golden_mutation_authorized" => false
  },
  "implementation_authorized" => false
}

FileUtils.mkdir_p(OUT_DIR)
File.write(OUT_DIR.join("oof_fragment_registry_policy_model.json"), "#{JSON.pretty_generate(policy_model)}\n")
File.write(OUT_DIR.join("oof_fragment_registry_policy_proof_summary.json"), "#{JSON.pretty_generate(summary)}\n")

if status == "PASS"
  puts "PASS #{TRACK}"
  puts "cases: #{case_results.count { |entry| entry.fetch("status") == "PASS" }}/#{case_results.length}"
  puts "checks: #{checks.count { |entry| entry.fetch("status") == "PASS" }}/#{checks.length}"
  puts "recommendation: #{recommendation}"
else
  warn "FAIL #{TRACK}"
  (failed_checks + failed_cases).each { |entry| warn "- #{entry.fetch("name")}" }
  exit 1
end
