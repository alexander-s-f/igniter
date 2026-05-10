#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

module CompilerProfileSpecAndRuleUnification
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  SLOTS_SUMMARY = ROOT / "igniter-lang/experiments/compiler_profile_slots_model/out/compiler_profile_slots_model_summary.json"
  ORDERED_SUMMARY = ROOT / "igniter-lang/experiments/compiler_kernel_ordered_rule_precedence/out/compiler_kernel_ordered_rule_precedence_summary.json"
  OUT_DIR = ROOT / "igniter-lang/experiments/compiler_profile_spec_and_rule_unification/out"
  SUMMARY_PATH = OUT_DIR / "compiler_profile_spec_and_rule_unification_summary.json"

  FORMAT_VERSION = "0.1.0"
  TRACK = "compiler-profile-spec-and-rule-profile-unification-v0"

  RULE_PREFIX_TO_SLOT = {
    "core" => "core",
    "escape" => "escape_boundary",
    "contract_modifiers" => "contract_modifiers",
    "temporal" => "temporal",
    "stream" => "stream",
    "olap" => "olap",
    "invariant" => "invariant",
    "assumptions" => "assumptions",
    "evidence_observation" => "evidence_observation",
    "pipeline" => "pipeline"
  }.freeze

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    slots = read_json(SLOTS_SUMMARY)
    ordered = read_json(ORDERED_SUMMARY)
    positive_profile = unified_profile(
      slots.fetch("positive_profile"),
      ordered.fetch("positive_profile"),
      profile_spec: slots.fetch("profile_spec")
    )
    temporal_variant_profile = unified_profile(
      slots.fetch("temporal_variant_profile"),
      ordered.fetch("positive_profile"),
      profile_spec: slots.fetch("profile_spec")
    )
    rule_variant_profile = unified_profile(
      slots.fetch("positive_profile"),
      mutate_ordered_rules(ordered.fetch("positive_profile")),
      profile_spec: slots.fetch("profile_spec")
    )
    invalid_owner_profile = unified_profile(
      slots.fetch("positive_profile"),
      mutate_ordered_rules_with_unknown_owner(ordered.fetch("positive_profile")),
      profile_spec: slots.fetch("profile_spec")
    )
    checks = build_checks(positive_profile, temporal_variant_profile, rule_variant_profile, invalid_owner_profile)
    summary = {
      "kind" => "compiler_profile_spec_and_rule_unification_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "positive_profile" => positive_profile,
      "temporal_variant_profile" => {
        "profile_id" => temporal_variant_profile.fetch("profile_id"),
        "changed_slot" => "temporal"
      },
      "rule_variant_profile" => {
        "profile_id" => rule_variant_profile.fetch("profile_id"),
        "changed_registry" => "classifier_rules"
      },
      "invalid_owner_profile" => {
        "profile_id" => invalid_owner_profile.fetch("profile_id"),
        "validation_errors" => invalid_owner_profile.fetch("validation_errors")
      },
      "checks" => checks,
      "non_goals" => [
        "No compiler pass dispatch.",
        "No production CompilerProfile implementation.",
        "No .igapp manifest changes."
      ]
    }
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def unified_profile(slot_profile, ordered_profile, profile_spec:)
    profile = {
      "kind" => "compiler_profile_unified",
      "format_version" => FORMAT_VERSION,
      "profile_spec_name" => profile_spec.fetch("name"),
      "profile_spec_digest" => digest(profile_spec),
      "slot_assignments" => slot_profile.fetch("slot_assignments"),
      "ordered_registries" => ordered_profile.fetch("ordered_registries"),
      "strict_registries" => ordered_profile.fetch("strict_registries"),
      "source_profile_ids" => {
        "slot_profile_id" => slot_profile.fetch("profile_id"),
        "ordered_rule_profile_id" => ordered_profile.fetch("profile_id")
      },
      "dispatch_mode" => "unified_profile_only_no_compiler_dispatch",
      "igapp_manifest_changes" => []
    }
    profile["validation_errors"] = validation_errors(profile)
    profile.merge("profile_id" => profile_id(profile))
  end

  def validation_errors(profile)
    errors = []
    slot_assignments = profile.fetch("slot_assignments")
    slot_pack_names = slot_assignments.values.map { |assignment| assignment.fetch("pack_name") }

    profile.fetch("strict_registries").each do |registry_name, entries|
      entries.each do |key, owner_pack|
        next if slot_pack_names.include?(owner_pack)

        errors << {
          "kind" => "strict_owner_missing_slot",
          "registry" => registry_name,
          "key" => key,
          "owner_pack" => owner_pack
        }
      end
    end

    profile.fetch("ordered_registries").each do |registry_name, rule_ids|
      rule_ids.each do |rule_id|
        prefix = rule_id.split(".").first
        slot_id = RULE_PREFIX_TO_SLOT[prefix]
        if slot_id.nil?
          errors << {
            "kind" => "unknown_rule_prefix",
            "registry" => registry_name,
            "rule_id" => rule_id,
            "prefix" => prefix
          }
        elsif !slot_assignments.key?(slot_id)
          errors << {
            "kind" => "ordered_rule_missing_slot",
            "registry" => registry_name,
            "rule_id" => rule_id,
            "required_slot" => slot_id
          }
        end
      end
    end

    errors
  end

  def mutate_ordered_rules(ordered_profile)
    copy = deep_copy(ordered_profile)
    rules = copy.fetch("ordered_registries").fetch("classifier_rules")
    insert_at = rules.index("temporal.temporal_precedence") || rules.length
    rules.insert(insert_at, "temporal.audit_temporal_precedence_inputs")
    copy["profile_id"] = profile_id_for_ordered(copy)
    copy
  end

  def mutate_ordered_rules_with_unknown_owner(ordered_profile)
    copy = deep_copy(ordered_profile)
    copy.fetch("ordered_registries").fetch("parser_rules") << "parser_helpers.normalize_tokens"
    copy["profile_id"] = profile_id_for_ordered(copy)
    copy
  end

  def build_checks(positive_profile, temporal_variant_profile, rule_variant_profile, invalid_owner_profile)
    {
      "positive.profile_kind" => positive_profile.fetch("kind") == "compiler_profile_unified",
      "positive.no_validation_errors" => positive_profile.fetch("validation_errors").empty?,
      "positive.dispatch_unified_profile_only" => positive_profile.fetch("dispatch_mode") == "unified_profile_only_no_compiler_dispatch",
      "positive.no_igapp_manifest_changes" => positive_profile.fetch("igapp_manifest_changes").empty?,
      "positive.strict_owners_have_slots" => strict_owners_have_slots?(positive_profile),
      "positive.ordered_rules_have_slots" => ordered_rules_have_slots?(positive_profile),
      "fingerprint.slot_implementation_change_changes_profile" => positive_profile.fetch("profile_id") != temporal_variant_profile.fetch("profile_id"),
      "fingerprint.ordered_rule_graph_change_changes_profile" => positive_profile.fetch("profile_id") != rule_variant_profile.fetch("profile_id"),
      "negative.unknown_rule_owner_rejected_by_validation" => invalid_owner_profile.fetch("validation_errors").any? do |error|
        error.fetch("kind") == "unknown_rule_prefix"
      end,
      "lineage.source_profile_ids_recorded" => positive_profile.fetch("source_profile_ids").key?("slot_profile_id") &&
        positive_profile.fetch("source_profile_ids").key?("ordered_rule_profile_id")
    }
  end

  def strict_owners_have_slots?(profile)
    !profile.fetch("validation_errors").any? { |error| error.fetch("kind") == "strict_owner_missing_slot" }
  end

  def ordered_rules_have_slots?(profile)
    !profile.fetch("validation_errors").any? do |error|
      %w[unknown_rule_prefix ordered_rule_missing_slot].include?(error.fetch("kind"))
    end
  end

  def profile_id(profile)
    stable = profile.reject { |key, _value| key == "profile_id" }
    "compiler_profile_unified/sha256:#{Digest::SHA256.hexdigest(canonical_json(stable))[0, 24]}"
  end

  def profile_id_for_ordered(profile)
    stable = profile.reject { |key, _value| key == "profile_id" }
    "ordered_rule_profile/sha256:#{Digest::SHA256.hexdigest(canonical_json(stable))[0, 24]}"
  end

  def digest(value)
    "sha256:#{Digest::SHA256.hexdigest(canonical_json(value))[0, 24]}"
  end

  def deep_copy(value)
    JSON.parse(JSON.generate(value))
  end

  def canonical_json(value)
    JSON.generate(sort_value(value))
  end

  def sort_value(value)
    case value
    when Hash
      value.keys.sort.each_with_object({}) { |key, result| result[key] = sort_value(value.fetch(key)) }
    when Array
      value.map { |item| sort_value(item) }
    else
      value
    end
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} compiler_profile_spec_and_rule_unification"
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "profile_id: #{summary.fetch("positive_profile").fetch("profile_id")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = CompilerProfileSpecAndRuleUnification.run
exit(success ? 0 : 1)
