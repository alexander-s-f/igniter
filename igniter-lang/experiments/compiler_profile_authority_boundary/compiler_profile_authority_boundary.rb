#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

module CompilerProfileAuthorityBoundary
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  UNIFIED_PROFILE_SUMMARY = ROOT / "igniter-lang/experiments/compiler_profile_spec_and_rule_unification/out/compiler_profile_spec_and_rule_unification_summary.json"
  MANIFEST_BOUNDARY_SUMMARY = ROOT / "igniter-lang/experiments/compiler_profile_id_manifest_boundary/out/compiler_profile_id_manifest_boundary_summary.json"
  OUT_DIR = ROOT / "igniter-lang/experiments/compiler_profile_authority_boundary/out"
  SUMMARY_PATH = OUT_DIR / "compiler_profile_authority_boundary_summary.json"

  FORMAT_VERSION = "0.1.0"
  TRACK = "compiler-profile-authority-boundary-v0"

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    model = build_model
    checks = build_checks(model)
    summary = {
      "kind" => "compiler_profile_authority_boundary_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "model" => model,
      "checks" => checks,
      "non_goals" => [
        "No runtime executor implementation.",
        "No TBackend or Ledger calls.",
        "No .igapp manifest changes.",
        "No production CompilerProfile enforcement."
      ]
    }
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def build_model
    unified = read_json(UNIFIED_PROFILE_SUMMARY).fetch("positive_profile")
    manifest_policy = read_json(MANIFEST_BOUNDARY_SUMMARY).fetch("model").fetch("policies")
    ledger_profile = ledger_backed_profile(unified)
    mismatch_profile_id = "compiler_profile_unified/sha256:000000000000000000000000"

    cases = {
      "core_profile_match" => evaluate_case(
        artifact: core_artifact(unified.fetch("profile_id")),
        compiler_profile: unified,
        runtime_context: runtime_context("core_runtime")
      ),
      "legacy_absent_profile" => evaluate_case(
        artifact: core_artifact(nil),
        compiler_profile: unified,
        runtime_context: runtime_context("core_runtime"),
        profile_policy: "legacy_optional"
      ),
      "mismatched_profile" => evaluate_case(
        artifact: core_artifact(mismatch_profile_id),
        compiler_profile: unified,
        runtime_context: runtime_context("core_runtime")
      ),
      "temporal_metadata_only_profile" => evaluate_case(
        artifact: temporal_artifact(unified.fetch("profile_id")),
        compiler_profile: unified,
        runtime_context: runtime_context("metadata_only_temporal")
      ),
      "temporal_ledger_backed_no_approval" => evaluate_case(
        artifact: temporal_artifact(ledger_profile.fetch("profile_id")),
        compiler_profile: ledger_profile,
        runtime_context: runtime_context("claimed_executor_live_binding")
      ),
      "temporal_ledger_backed_gate3_closed" => evaluate_case(
        artifact: temporal_artifact(ledger_profile.fetch("profile_id")),
        compiler_profile: ledger_profile,
        runtime_context: runtime_context("approved_executor_gate3_closed")
      )
    }

    {
      "unified_profile_id" => unified.fetch("profile_id"),
      "ledger_backed_profile_id" => ledger_profile.fetch("profile_id"),
      "manifest_policy_reference" => manifest_policy,
      "authority_contract" => authority_contract,
      "decision_table" => cases,
      "operation_check" => {
        "compiler_profile_loaded_runtime_executor" => false,
        "compiler_profile_called_tbackend" => false,
        "compiler_profile_called_ledger" => false
      }
    }
  end

  def authority_contract
    {
      "compiler_profile_id_proves" => [
        "The artifact was assembled by a compiler profile with known slots and rule registries.",
        "The profile was allowed to understand the language capabilities present in the artifact.",
        "The compiler identity is fingerprinted and can be compared by loaders/reports."
      ],
      "compiler_profile_id_does_not_prove" => [
        "Runtime executor approval.",
        "Gate 3 authorization.",
        "Live TBackend binding.",
        "Ledger read/write/replay permission.",
        "Cache key policy safety.",
        "Artifact guard_policy permission."
      ],
      "runtime_authority_inputs" => [
        "artifact guard_policy",
        "runtime profile capabilities",
        "live backend binding",
        "executor approval token",
        "Gate 3 state",
        "cache key schema"
      ]
    }
  end

  def evaluate_case(artifact:, compiler_profile:, runtime_context:, profile_policy: "legacy_optional")
    compiler_decision = compiler_profile_decision(artifact, compiler_profile, profile_policy)
    runtime_decision = if compiler_decision.fetch("decision").start_with?("refuse")
                         {
                           "decision" => "not_reached",
                           "reason_code" => "compiler_profile_refused_before_runtime",
                           "authorized_by_compiler_profile_id" => false
                         }
                       else
                         runtime_authority_decision(artifact, compiler_profile, runtime_context)
                       end

    {
      "artifact" => artifact,
      "compiler_profile" => {
        "profile_id" => compiler_profile.fetch("profile_id"),
        "temporal_slot" => compiler_profile.dig("slot_assignments", "temporal")
      },
      "runtime_context" => runtime_context,
      "compiler_decision" => compiler_decision,
      "runtime_decision" => runtime_decision
    }
  end

  def compiler_profile_decision(artifact, compiler_profile, policy)
    id = artifact.fetch("compiler_profile_id", nil)
    decision = if id.nil?
                 policy == "profile_required" ? "refuse_missing_compiler_profile_id" : "accept_absent_legacy"
               elsif id != compiler_profile.fetch("profile_id")
                 "refuse_profile_mismatch"
               else
                 "accept_profile_match"
               end
    {
      "policy" => policy,
      "decision" => decision,
      "understanding_authority" => decision.start_with?("accept"),
      "runtime_authority" => false
    }
  end

  def runtime_authority_decision(artifact, compiler_profile, runtime_context)
    return core_runtime_decision(runtime_context) if artifact.fetch("fragment_class") == "core"

    temporal_impl = compiler_profile.dig("slot_assignments", "temporal", "implementation_id").to_s
    unless temporal_impl.include?("ledger")
      return refusal("runtime.temporal_execution_unsupported")
    end

    return refusal("runtime.temporal_execution_unsupported") unless runtime_context.fetch("temporal_executor")
    return refusal("runtime.temporal_tbackend_binding_missing") unless runtime_context.fetch("live_tbackend_binding")
    return refusal("runtime.executor_approval_missing") unless runtime_context.fetch("approval_token")
    return refusal("runtime.temporal_gate3_closed") unless runtime_context.fetch("gate3_open")
    return refusal("runtime.temporal_guard_policy_refuse") unless artifact.fetch("guard_policy") == "evaluate_allowed"

    {
      "decision" => "would_continue_to_cache_policy_check",
      "reason_code" => "runtime.temporal_authority_preconditions_met",
      "authorized_by_compiler_profile_id" => false,
      "live_operation_attempted" => false
    }
  end

  def core_runtime_decision(runtime_context)
    {
      "decision" => runtime_context.fetch("core_runtime") ? "core_evaluation_policy_available" : "core_runtime_missing",
      "reason_code" => runtime_context.fetch("core_runtime") ? "runtime.core_policy_available" : "runtime.core_runtime_missing",
      "authorized_by_compiler_profile_id" => false,
      "live_operation_attempted" => false
    }
  end

  def refusal(reason_code)
    {
      "decision" => "refuse",
      "reason_code" => reason_code,
      "authorized_by_compiler_profile_id" => false,
      "live_operation_attempted" => false
    }
  end

  def runtime_context(name)
    case name
    when "core_runtime"
      {
        "name" => name,
        "core_runtime" => true,
        "temporal_executor" => false,
        "live_tbackend_binding" => false,
        "approval_token" => false,
        "gate3_open" => false
      }
    when "metadata_only_temporal"
      {
        "name" => name,
        "core_runtime" => true,
        "temporal_executor" => false,
        "live_tbackend_binding" => false,
        "approval_token" => false,
        "gate3_open" => false
      }
    when "claimed_executor_live_binding"
      {
        "name" => name,
        "core_runtime" => true,
        "temporal_executor" => true,
        "live_tbackend_binding" => true,
        "approval_token" => false,
        "gate3_open" => false
      }
    when "approved_executor_gate3_closed"
      {
        "name" => name,
        "core_runtime" => true,
        "temporal_executor" => true,
        "live_tbackend_binding" => true,
        "approval_token" => true,
        "gate3_open" => false
      }
    end
  end

  def core_artifact(profile_id)
    {
      "artifact_id" => "core_add",
      "fragment_class" => "core",
      "compiler_profile_id" => profile_id,
      "guard_policy" => "evaluate_allowed"
    }.compact
  end

  def temporal_artifact(profile_id)
    {
      "artifact_id" => "history_valid",
      "fragment_class" => "temporal",
      "compiler_profile_id" => profile_id,
      "guard_policy" => "load_accept_evaluate_refuse"
    }
  end

  def ledger_backed_profile(profile)
    copy = deep_copy(profile)
    copy.fetch("slot_assignments").fetch("temporal")["pack_name"] = "TemporalPackLedgerBacked"
    copy.fetch("slot_assignments").fetch("temporal")["implementation_id"] = "temporal.ledger_tbackend_profile_slot_variant.v0"
    copy["profile_id"] = profile_id(copy)
    copy
  end

  def build_checks(model)
    table = model.fetch("decision_table")
    {
      "compiler.profile_match_grants_understanding_only" => table.fetch("core_profile_match").fetch("compiler_decision").fetch("understanding_authority") &&
        table.fetch("core_profile_match").fetch("compiler_decision").fetch("runtime_authority") == false,
      "compiler.absent_legacy_not_runtime_authority" => table.fetch("legacy_absent_profile").fetch("compiler_decision").fetch("decision") == "accept_absent_legacy" &&
        table.fetch("legacy_absent_profile").fetch("runtime_decision").fetch("authorized_by_compiler_profile_id") == false,
      "compiler.mismatch_refuses_before_runtime" => table.fetch("mismatched_profile").fetch("runtime_decision").fetch("reason_code") == "compiler_profile_refused_before_runtime",
      "temporal.metadata_only_refuses_execution" => table.fetch("temporal_metadata_only_profile").fetch("runtime_decision").fetch("reason_code") == "runtime.temporal_execution_unsupported",
      "temporal.ledger_backed_still_requires_approval" => table.fetch("temporal_ledger_backed_no_approval").fetch("runtime_decision").fetch("reason_code") == "runtime.executor_approval_missing",
      "temporal.ledger_backed_gate3_closed_refuses" => table.fetch("temporal_ledger_backed_gate3_closed").fetch("runtime_decision").fetch("reason_code") == "runtime.temporal_gate3_closed",
      "runtime.no_live_operations_attempted" => table.values.all? do |entry|
        entry.fetch("runtime_decision").fetch("live_operation_attempted", false) == false
      end,
      "runtime.compiler_profile_never_authorizes_execution" => table.values.all? do |entry|
        entry.fetch("runtime_decision").fetch("authorized_by_compiler_profile_id") == false
      end,
      "operation_check.no_backend_or_ledger_calls" => model.fetch("operation_check").values.all? { |value| value == false }
    }
  end

  def profile_id(profile)
    stable = profile.reject { |key, _value| key == "profile_id" }
    "compiler_profile_unified/sha256:#{Digest::SHA256.hexdigest(canonical_json(stable))[0, 24]}"
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
    puts "#{summary.fetch("status")} compiler_profile_authority_boundary"
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "profile_id: #{summary.fetch("model").fetch("unified_profile_id")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = CompilerProfileAuthorityBoundary.run
exit(success ? 0 : 1)
