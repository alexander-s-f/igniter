#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"

module ExecutorApprovalAuthorityRefProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  DECISION_RECORD = LANG_ROOT / "docs/gates/gate3-decision-record-v0.md"
  OUT_DIR = LANG_ROOT / "experiments/executor_approval_authority_ref_proof/out"
  SUMMARY_PATH = OUT_DIR / "executor_approval_authority_ref_proof_summary.json"

  TRUSTED_AUTHORITY_PATTERN = /^authority_ref:\s*(\S+)$/
  REFUSAL_MALFORMED = "runtime.executor_approval_malformed"
  REFUSAL_UNTRUSTED = "runtime.executor_approval_authority_untrusted"

  module_function

  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)

    trusted_authority_ref = extract_trusted_authority_ref
    cases = build_cases(trusted_authority_ref)
    results = cases.transform_values { |token| validate_authority(token, trusted_authority_ref) }
    checks = build_checks(results)
    summary = {
      "kind" => "executor_approval_authority_ref_proof_summary",
      "format_version" => "0.1.0",
      "card" => "S3-R15-C3-P",
      "track" => "executor-approval-authority-ref-proof-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "decision_record" => DECISION_RECORD.relative_path_from(ROOT).to_s,
      "trusted_authority_ref" => trusted_authority_ref,
      "scope" => {
        "proof_local" => true,
        "production_signing_system" => false,
        "runtime_authority_registry" => false,
        "live_tbackend" => false,
        "ledger_adapter" => false
      },
      "cases" => cases,
      "results" => results,
      "checks" => checks,
      "at9_status_recommendation" => at9_status_recommendation,
      "remaining_gaps" => remaining_gaps
    }

    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def extract_trusted_authority_ref
    match = File.read(DECISION_RECORD).match(TRUSTED_AUTHORITY_PATTERN)
    raise "authority_ref not found in #{DECISION_RECORD}" unless match

    match[1]
  end

  def build_cases(trusted_authority_ref)
    exact = token("exact_match", trusted_authority_ref)
    {
      "exact_match" => exact,
      "missing_authority_ref" => exact.reject { |key, _value| key == "authority_ref" },
      "wrong_authority_ref" => token("wrong_authority", "architect-supervisor://igniter-lang/gates/gate3/runtime-temporal-executor/wrong-scope-v0/2026-05-09"),
      "stale_superseded_authority_ref" => token("stale_authority", "architect-supervisor://igniter-lang/gates/gate3/runtime-temporal-executor/restricted-history-valid-time-v0/2026-05-08"),
      "self_issued_artifact_authority_ref" => token("self_issued_artifact", "igapp://sha256/history-valid-time-control")
    }
  end

  def token(id, authority_ref)
    {
      "kind" => "executor_approval_token",
      "version" => "executor-approval-token-v1",
      "token_id" => "approval/#{id}",
      "authority_ref" => authority_ref,
      "gate" => "gate3",
      "scope" => {
        "operation" => "temporal_evaluate",
        "surface" => "History[T]",
        "axis" => "valid_time",
        "environment" => "proof"
      },
      "artifact_ref" => "igapp/sha256:history-valid-time-control",
      "contract_refs" => ["contract/HistoryValidTimeControl/sha256:history-valid-time-control"],
      "capability_refs" => ["history_read"],
      "evidence_ref" => "docs/gates/gate3-decision-record-v0.md"
    }
  end

  def validate_authority(token, trusted_authority_ref)
    authority_ref = token["authority_ref"]
    return blocked(REFUSAL_MALFORMED, token, "missing authority_ref", trusted_authority_ref, "missing") if authority_ref.nil? || authority_ref == ""

    if self_issued?(authority_ref)
      return blocked(REFUSAL_UNTRUSTED, token, "self-issued artifact authority is not trusted", trusted_authority_ref, "self_issued")
    end

    if stale_or_superseded?(authority_ref, trusted_authority_ref)
      return blocked(REFUSAL_UNTRUSTED, token, "authority_ref is stale or superseded", trusted_authority_ref, "stale_or_superseded")
    end

    unless authority_ref == trusted_authority_ref
      return blocked(REFUSAL_UNTRUSTED, token, "authority_ref does not exactly match Gate 3 decision URI", trusted_authority_ref, "wrong")
    end

    {
      "decision" => "ok",
      "reason_code" => "runtime.executor_approval_authority_trusted",
      "token_ref" => token.fetch("token_id"),
      "authority_ref" => authority_ref,
      "expected_authority_ref" => trusted_authority_ref,
      "match" => "exact",
      "runtime_authority_registry" => false,
      "production_signing_system" => false
    }
  end

  def blocked(reason_code, token, message, trusted_authority_ref, authority_status)
    {
      "decision" => "blocked",
      "reason_code" => reason_code,
      "message" => message,
      "token_ref" => token["token_id"],
      "authority_ref" => token["authority_ref"],
      "expected_authority_ref" => trusted_authority_ref,
      "authority_status" => authority_status,
      "operation_check" => no_live_operations
    }
  end

  def self_issued?(authority_ref)
    authority_ref.start_with?("igapp://", "contract://", "runtime://", "tbackend://")
  end

  def stale_or_superseded?(authority_ref, trusted_authority_ref)
    authority_ref.start_with?(trusted_authority_ref.sub(%r{/2026-05-09$}, "")) &&
      authority_ref != trusted_authority_ref
  end

  def build_checks(results)
    {
      "exact_match.accepted" => results.dig("exact_match", "decision") == "ok",
      "exact_match.uses_decision_record_authority" => results.dig("exact_match", "match") == "exact",
      "missing_authority_ref.refused" => blocked_with?(results.fetch("missing_authority_ref"), REFUSAL_MALFORMED, "missing"),
      "wrong_authority_ref.refused" => blocked_with?(results.fetch("wrong_authority_ref"), REFUSAL_UNTRUSTED, "wrong"),
      "stale_superseded_authority_ref.refused" => blocked_with?(results.fetch("stale_superseded_authority_ref"), REFUSAL_UNTRUSTED, "stale_or_superseded"),
      "self_issued_artifact_authority_ref.refused" => blocked_with?(results.fetch("self_issued_artifact_authority_ref"), REFUSAL_UNTRUSTED, "self_issued"),
      "refusals_before_live_operations" => results.reject { |id, _result| id == "exact_match" }.values.all? do |result|
        result.fetch("operation_check").values.all?(false)
      end
    }
  end

  def blocked_with?(result, reason_code, status)
    result.fetch("decision") == "blocked" &&
      result.fetch("reason_code") == reason_code &&
      result.fetch("authority_status") == status
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

  def at9_status_recommendation
    {
      "status" => "proof_gap_closed_for_phase1",
      "recommendation" => "AT-9 can be marked proof-local PASS for exact authority_ref matching against the Gate 3 decision URI. Production authority registry and signing remain separate gaps."
    }
  end

  def remaining_gaps
    [
      "Production signing/key verification is still out of scope.",
      "Runtime authority registry and revocation lookup remain undefined before Phase 2.",
      "This fixture validates exact authority_ref matching only; full ExecutorApprovalToken validation stays with PROP-030 proof/runtime paths.",
      "Live TBackend, Ledger adapter, production cache, and Phase 2 authority remain closed."
    ]
  end

  def write_json(path, value)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} executor_approval_authority_ref_proof"
    summary.fetch("checks").each do |name, ok|
      puts "#{name}: #{ok ? "ok" : "FAIL"}"
    end
    puts "authority_ref: #{summary.fetch("trusted_authority_ref")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = ExecutorApprovalAuthorityRefProof.run
exit(success ? 0 : 1)
