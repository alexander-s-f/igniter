#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"

module TemporalScopeExclusionRuntimeFixture
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = LANG_ROOT / "experiments/temporal_scope_exclusion_runtime_fixture/out"
  SUMMARY_PATH = OUT_DIR / "temporal_scope_exclusion_runtime_fixture_summary.json"

  APPROVED_SCOPE = "history_valid_time"
  REFUSAL = "runtime.temporal_scope_exclusion"

  class ProofTemporalExecutor
    def evaluate(artifact)
      scope = classify_scope(artifact)
      return scope_exclusion(artifact, scope) unless scope.fetch("allowed")

      {
        "artifact_id" => artifact.fetch("artifact_id"),
        "decision" => "continue_to_cache_key_check",
        "reason_code" => "runtime.temporal_scope_accepted",
        "expected_scope" => APPROVED_SCOPE,
        "actual_fragment" => artifact.fetch("fragment_class"),
        "actual_surface" => scope.fetch("surface"),
        "actual_axis" => artifact.fetch("axis", nil),
        "operation_check" => no_live_operations
      }
    end

    private

    def classify_scope(artifact)
      operation = artifact.fetch("operation", "temporal_evaluate")
      fragment = artifact.fetch("fragment_class")
      surface = artifact.fetch("surface", fragment)
      axis = artifact.fetch("axis", nil)

      return excluded("ledger_write") if %w[write append compact].include?(operation)
      return excluded("ledger_replay") if operation == "replay"
      return excluded("core") if fragment == "core"
      return excluded("stream") if fragment == "stream" || artifact.fetch("stream_nodes", false)
      return excluded("olap") if surface == "olap" || artifact.fetch("olap_nodes", false)
      return excluded("bihistory") if surface == "bihistory" || axis == "bitemporal"

      if fragment == "temporal" &&
         surface == "history" &&
         axis == "valid_time" &&
         operation == "temporal_evaluate" &&
         artifact.fetch("capability", nil) == "history_read"
        return {
          "allowed" => true,
          "surface" => "history"
        }
      end

      excluded("unknown")
    end

    def excluded(surface)
      {
        "allowed" => false,
        "surface" => surface
      }
    end

    def scope_exclusion(artifact, scope)
      {
        "artifact_id" => artifact.fetch("artifact_id"),
        "decision" => "refused",
        "reason_code" => REFUSAL,
        "expected_scope" => APPROVED_SCOPE,
        "actual_fragment" => artifact.fetch("fragment_class", "unknown"),
        "actual_surface" => scope.fetch("surface"),
        "actual_axis" => artifact.fetch("axis", "unknown"),
        "actual_operation" => artifact.fetch("operation", "temporal_evaluate"),
        "artifact_ref" => artifact.fetch("artifact_ref"),
        "contract_ref" => artifact.fetch("contract_ref"),
        "operation_check" => no_live_operations
      }
    end

    def no_live_operations
      {
        "executor_evaluation_attempted" => false,
        "cache_lookup_attempted" => false,
        "tbackend_call_attempted" => false,
        "ledger_call_attempted" => false,
        "live_adapter_call_attempted" => false
      }
    end
  end

  module_function

  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)

    executor = ProofTemporalExecutor.new
    artifacts = artifact_matrix
    results = artifacts.transform_values { |artifact| executor.evaluate(artifact) }
    checks = build_checks(results)
    summary = {
      "kind" => "temporal_scope_exclusion_runtime_fixture_summary",
      "format_version" => "0.1.0",
      "card" => "S3-R14-C3-P",
      "track" => "temporal-scope-exclusion-runtime-fixture-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "scope" => {
        "proof_local" => true,
        "approved_scope" => APPROVED_SCOPE,
        "assumes_approval_token_valid" => true,
        "assumes_gate3_phase1_open" => true,
        "live_tbackend" => false,
        "ledger_adapter" => false,
        "production_cache" => false
      },
      "artifacts" => artifacts,
      "results" => results,
      "checks" => checks,
      "remaining_runtime_gaps" => remaining_runtime_gaps
    }

    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def artifact_matrix
    {
      "core_contract" => artifact(
        "core_contract",
        fragment_class: "core",
        surface: "core",
        axis: nil,
        capability: "core_compute"
      ),
      "stream_contract" => artifact(
        "stream_contract",
        fragment_class: "stream",
        surface: "stream",
        axis: nil,
        capability: "stream_replay",
        stream_nodes: true
      ),
      "olap_surface" => artifact(
        "olap_surface",
        fragment_class: "temporal",
        surface: "olap",
        axis: "multi_dimensional",
        capability: "olap_read",
        olap_nodes: true
      ),
      "bihistory_surface" => artifact(
        "bihistory_surface",
        fragment_class: "temporal",
        surface: "bihistory",
        axis: "bitemporal",
        capability: "bihistory_read"
      ),
      "ledger_write_surface" => artifact(
        "ledger_write_surface",
        fragment_class: "temporal",
        surface: "history",
        axis: "valid_time",
        capability: "history_write",
        operation: "write"
      ),
      "ledger_replay_surface" => artifact(
        "ledger_replay_surface",
        fragment_class: "temporal",
        surface: "history",
        axis: "valid_time",
        capability: "history_replay",
        operation: "replay"
      ),
      "unknown_temporal_surface" => artifact(
        "unknown_temporal_surface",
        fragment_class: "temporal",
        surface: "unknown",
        axis: "unknown",
        capability: "unknown"
      ),
      "history_valid_time_control" => artifact(
        "history_valid_time_control",
        fragment_class: "temporal",
        surface: "history",
        axis: "valid_time",
        capability: "history_read"
      )
    }
  end

  def artifact(id, fragment_class:, surface:, axis:, capability:, operation: "temporal_evaluate", **extra)
    {
      "artifact_id" => id,
      "artifact_ref" => "igapp/sha256:#{id}",
      "contract_ref" => "contract/#{camelize(id)}/sha256:#{id}",
      "fragment_class" => fragment_class,
      "surface" => surface,
      "axis" => axis,
      "capability" => capability,
      "operation" => operation
    }.merge(extra.transform_keys(&:to_s))
  end

  def build_checks(results)
    excluded_ids = results.keys - ["history_valid_time_control"]
    {
      "core.refused_scope_exclusion" => scope_exclusion?(results.fetch("core_contract"), "core"),
      "stream.refused_scope_exclusion" => scope_exclusion?(results.fetch("stream_contract"), "stream"),
      "olap.refused_scope_exclusion" => scope_exclusion?(results.fetch("olap_surface"), "olap"),
      "bihistory.refused_scope_exclusion" => scope_exclusion?(results.fetch("bihistory_surface"), "bihistory"),
      "ledger_write.refused_scope_exclusion" => scope_exclusion?(results.fetch("ledger_write_surface"), "ledger_write"),
      "ledger_replay.refused_scope_exclusion" => scope_exclusion?(results.fetch("ledger_replay_surface"), "ledger_replay"),
      "unknown.refused_scope_exclusion" => scope_exclusion?(results.fetch("unknown_temporal_surface"), "unknown"),
      "refusals_before_live_operations" => excluded_ids.all? { |id| no_live_operations?(results.fetch(id)) },
      "valid_history_scope_not_excluded" => results.dig("history_valid_time_control", "reason_code") == "runtime.temporal_scope_accepted",
      "control_does_not_call_live_paths" => no_live_operations?(results.fetch("history_valid_time_control"))
    }
  end

  def scope_exclusion?(result, surface)
    result.fetch("decision") == "refused" &&
      result.fetch("reason_code") == REFUSAL &&
      result.fetch("expected_scope") == APPROVED_SCOPE &&
      result.fetch("actual_surface") == surface
  end

  def no_live_operations?(result)
    result.fetch("operation_check").values.all?(false)
  end

  def remaining_runtime_gaps
    [
      "Production TemporalExecutor must run this scope check after approval/Gate checks and before cache/TBackend/Ledger calls.",
      "Production CompatibilityReport should surface the same runtime.temporal_scope_exclusion reason and diagnostic envelope.",
      "Phase 1 implementation still needs the approved History[T] valid_time executor path and AT-1..AT-12 regression proof.",
      "BiHistory, STREAM, OLAP, Ledger write/replay/compact/subscribe, and production cache remain outside Phase 1 scope."
    ]
  end

  def camelize(value)
    value.split("_").map(&:capitalize).join
  end

  def write_json(path, value)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} temporal_scope_exclusion_runtime_fixture"
    summary.fetch("checks").each do |name, ok|
      puts "#{name}: #{ok ? "ok" : "FAIL"}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = TemporalScopeExclusionRuntimeFixture.run
exit(success ? 0 : 1)
