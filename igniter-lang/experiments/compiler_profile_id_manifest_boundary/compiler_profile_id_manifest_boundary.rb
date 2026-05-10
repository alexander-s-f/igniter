#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

module CompilerProfileIdManifestBoundary
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  CORE_MANIFEST = ROOT / "igniter-lang/experiments/igapp_assembler_proof/out/add.igapp/manifest.json"
  TEMPORAL_MANIFEST = ROOT / "igniter-lang/experiments/runtime_compatibility_report_temporal_load_check/out/assembled/history_valid.igapp/manifest.json"
  ORDERED_PROFILE_SUMMARY = ROOT / "igniter-lang/experiments/compiler_kernel_ordered_rule_precedence/out/compiler_kernel_ordered_rule_precedence_summary.json"
  OUT_DIR = ROOT / "igniter-lang/experiments/compiler_profile_id_manifest_boundary/out"
  SUMMARY_PATH = OUT_DIR / "compiler_profile_id_manifest_boundary_summary.json"

  FORMAT_VERSION = "0.1.0"
  TRACK = "compiler-profile-id-manifest-boundary-plan-v0"

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    model = build_model
    checks = build_checks(model)
    summary = {
      "kind" => "compiler_profile_id_manifest_boundary_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "model" => model,
      "checks" => checks,
      "recommendation" => recommendation,
      "non_goals" => [
        "No existing .igapp manifest files are edited.",
        "No assembler implementation changes.",
        "No RuntimeMachine enforcement changes.",
        "No signed artifact format changes."
      ]
    }
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def build_model
    profile = read_json(ORDERED_PROFILE_SUMMARY).fetch("positive_profile")
    core_manifest = read_json(CORE_MANIFEST)
    temporal_manifest = read_json(TEMPORAL_MANIFEST)
    profiled_core = with_profile(core_manifest, profile)
    profiled_temporal = with_profile(temporal_manifest, profile)
    mismatched = profiled_core.merge(
      "compiler_profile_id" => "ordered_rule_profile/sha256:000000000000000000000000"
    )
    malformed = profiled_core.merge("compiler_profile_id" => "not-a-profile-id")

    {
      "profile_source" => ORDERED_PROFILE_SUMMARY.relative_path_from(ROOT).to_s,
      "profile_id" => profile.fetch("profile_id"),
      "field_shape" => field_shape(profile),
      "policies" => policies,
      "legacy_core" => manifest_evidence(core_manifest),
      "legacy_temporal" => manifest_evidence(temporal_manifest),
      "profiled_core" => manifest_evidence(profiled_core),
      "profiled_temporal" => manifest_evidence(profiled_temporal),
      "mismatched_profile" => manifest_evidence(mismatched),
      "malformed_profile" => manifest_evidence(malformed),
      "compatibility_decisions" => {
        "legacy_absent_current_policy" => compatibility_decision(core_manifest, profile, policy: "legacy_optional"),
        "legacy_absent_future_required_policy" => compatibility_decision(core_manifest, profile, policy: "profile_required"),
        "profiled_core_current_policy" => compatibility_decision(profiled_core, profile, policy: "legacy_optional"),
        "profiled_temporal_current_policy" => compatibility_decision(profiled_temporal, profile, policy: "legacy_optional"),
        "mismatched_profile_current_policy" => compatibility_decision(mismatched, profile, policy: "legacy_optional"),
        "malformed_profile_current_policy" => compatibility_decision(malformed, profile, policy: "legacy_optional")
      },
      "artifact_hash_impact" => {
        "core_existing_hash" => core_manifest.fetch("artifact_hash"),
        "core_profiled_manifest_hash" => manifest_hash(profiled_core),
        "temporal_existing_hash" => temporal_manifest.fetch("artifact_hash"),
        "temporal_profiled_manifest_hash" => manifest_hash(profiled_temporal),
        "requires_reassembly_before_signing" => true
      },
      "signed_artifact_implications" => signed_artifact_implications(profile)
    }
  end

  def field_shape(profile)
    {
      "manifest_field" => "compiler_profile_id",
      "value" => profile.fetch("profile_id"),
      "optional_profile_summary" => {
        "field" => "compiler_profile",
        "status" => "deferred",
        "reason" => "manifest should carry stable id first; full profile summary may live in a sidecar after manifest PROP"
      },
      "profile_id_semantics" => [
        "Identifies the frozen compiler profile that assembled the artifact.",
        "Includes pack implementation identities through the profile fingerprint.",
        "Does not grant runtime execution authority."
      ]
    }
  end

  def policies
    {
      "legacy_optional" => {
        "absent" => "accept_with_profile_status_absent_legacy",
        "present_match" => "accept_profile_match",
        "present_mismatch" => "refuse_profile_mismatch",
        "malformed" => "refuse_malformed_profile_id"
      },
      "profile_required" => {
        "absent" => "refuse_missing_compiler_profile_id",
        "present_match" => "accept_profile_match",
        "present_mismatch" => "refuse_profile_mismatch",
        "malformed" => "refuse_malformed_profile_id"
      }
    }
  end

  def with_profile(manifest, profile)
    manifest.merge(
      "compiler_profile_id" => profile.fetch("profile_id"),
      "compiler_profile_policy" => "profile-id-v0"
    )
  end

  def manifest_evidence(manifest)
    {
      "program_id" => manifest.fetch("program_id"),
      "fragment_class" => manifest.fetch("fragment_class"),
      "has_compiler_profile_id" => manifest.key?("compiler_profile_id"),
      "compiler_profile_id" => manifest.fetch("compiler_profile_id", nil),
      "manifest_hash" => manifest_hash(manifest)
    }
  end

  def compatibility_decision(manifest, profile, policy:)
    id = manifest.fetch("compiler_profile_id", nil)
    decision = if id.nil?
                 policy == "profile_required" ? "refuse_missing_compiler_profile_id" : "accept_with_profile_status_absent_legacy"
               elsif !valid_profile_id?(id)
                 "refuse_malformed_profile_id"
               elsif id != profile.fetch("profile_id")
                 "refuse_profile_mismatch"
               else
                 "accept_profile_match"
               end
    {
      "policy" => policy,
      "decision" => decision,
      "profile_status" => profile_status(decision),
      "runtime_authority" => "unchanged_by_profile_id"
    }
  end

  def valid_profile_id?(id)
    id.match?(%r{\A[a-z_]+/sha256:[0-9a-f]{24}\z})
  end

  def profile_status(decision)
    case decision
    when "accept_profile_match" then "present_verified"
    when "accept_with_profile_status_absent_legacy" then "absent_legacy"
    else "invalid"
    end
  end

  def signed_artifact_implications(profile)
    {
      "signing_order" => [
        "finalize compiler profile",
        "assemble manifest with compiler_profile_id",
        "compute artifact_hash over profiled artifact material",
        "sign artifact_hash and compiler_profile_id together"
      ],
      "approval_token_claims" => {
        "artifact_ref" => "existing artifact hash or igapp ref",
        "compiler_profile_id" => profile.fetch("profile_id"),
        "effect" => "prevents reusing approval for same artifact hash under a different compiler profile once profile id is required"
      },
      "ilk_implication" => ".ilk/signed artifact metadata should include compiler_profile_id when manifest policy becomes profile_required"
    }
  end

  def build_checks(model)
    decisions = model.fetch("compatibility_decisions")
    {
      "legacy.current_policy_accepts_absent" => decisions.fetch("legacy_absent_current_policy").fetch("decision") == "accept_with_profile_status_absent_legacy",
      "legacy.future_policy_refuses_absent" => decisions.fetch("legacy_absent_future_required_policy").fetch("decision") == "refuse_missing_compiler_profile_id",
      "profiled.core_accepts_match" => decisions.fetch("profiled_core_current_policy").fetch("decision") == "accept_profile_match",
      "profiled.temporal_accepts_match" => decisions.fetch("profiled_temporal_current_policy").fetch("decision") == "accept_profile_match",
      "negative.mismatch_refused" => decisions.fetch("mismatched_profile_current_policy").fetch("decision") == "refuse_profile_mismatch",
      "negative.malformed_refused" => decisions.fetch("malformed_profile_current_policy").fetch("decision") == "refuse_malformed_profile_id",
      "field.profile_id_present_in_profiled_variants" => model.fetch("profiled_core").fetch("has_compiler_profile_id") &&
        model.fetch("profiled_temporal").fetch("has_compiler_profile_id"),
      "artifact_hash.profile_field_changes_manifest_hash" => model.fetch("artifact_hash_impact").fetch("core_existing_hash") !=
        model.fetch("artifact_hash_impact").fetch("core_profiled_manifest_hash"),
      "recommendation.reassembly_before_signing" => model.fetch("artifact_hash_impact").fetch("requires_reassembly_before_signing") == true,
      "runtime.profile_id_grants_no_authority" => decisions.values.all? do |decision|
        decision.fetch("runtime_authority") == "unchanged_by_profile_id"
      end
    }
  end

  def recommendation
    {
      "first_manifest_prop" => "PROP-compiler-profile-id-manifest-v0",
      "recommended_field" => "compiler_profile_id",
      "initial_policy" => "legacy_optional",
      "future_policy" => "profile_required after profiled assembler adoption",
      "do_not_add_yet" => [
        "Do not add compiler_profile_id to current assembler in this background slice.",
        "Do not make RuntimeMachine refuse legacy artifacts yet.",
        "Do not treat compiler_profile_id as runtime executor approval."
      ]
    }
  end

  def manifest_hash(manifest)
    "sha256:#{Digest::SHA256.hexdigest(canonical_json(manifest))}"
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
    puts "#{summary.fetch("status")} compiler_profile_id_manifest_boundary"
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "profile_id: #{summary.fetch("model").fetch("profile_id")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = CompilerProfileIdManifestBoundary.run
exit(success ? 0 : 1)
