#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"
require "time"

require_relative "../../lib/igniter_lang"

module ExecutorApprovalTokenReportProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = LANG_ROOT / "experiments/executor_approval_token_report_proof/out"
  SUMMARY_PATH = OUT_DIR / "executor_approval_token_report_proof_summary.json"
  HISTORY_SOURCE = LANG_ROOT / "experiments/history_type_proof/history_integer_point_access.ig"

  NOW = Time.utc(2026, 5, 8, 12, 0, 0)
  TOKEN_VERSION = "executor-approval-token-v1"
  TRUSTED_AUTHORITIES = ["architect-supervisor/proof-authority"].freeze
  EVIDENCE_REGISTRY = ["decision/gate3/record/proof-001"].freeze
  GATE3_OPEN = false

  module Canonical
    module_function

    def normalize(value)
      case value
      when Hash
        value.keys.sort_by(&:to_s).each_with_object({}) { |key, out| out[key.to_s] = normalize(value.fetch(key)) }
      when Array
        value.map { |item| normalize(item) }
      else
        value
      end
    end

    def json(value)
      JSON.generate(normalize(value))
    end

    def hash(value)
      "sha256:#{Digest::SHA256.hexdigest(json(value))}"
    end

    def short_hash(value)
      hash(value).delete_prefix("sha256:")[0, 16]
    end
  end

  class ExecutorApprovalValidator
    REQUIRED_FIELDS = %w[
      kind version token_id authority_ref gate scope artifact_ref contract_refs
      capability_refs issued_at expires_at revocation evidence_ref token_hash signature
    ].freeze

    def initialize(context:)
      @context = context
    end

    def compatibility_report(case_id:, token:)
      approval = validate(token)
      evaluation = evaluation_readiness(approval)
      {
        "kind" => "compatibility_report",
        "format_version" => "0.1.0",
        "track" => "executor-approval-token-report-proof-v0",
        "case_id" => case_id,
        "report_only" => true,
        "runtime_enforced" => false,
        "overall" => evaluation.fetch("decision"),
        "executor_approval_check" => approval,
        "evaluation_readiness" => evaluation,
        "operation_check" => {
          "temporal_executor_call_attempted" => false,
          "live_tbackend_call_attempted" => false,
          "ledger_call_attempted" => false,
          "cache_call_attempted" => false
        },
        "non_authorization" => {
          "gate3_open" => GATE3_OPEN,
          "executor_authorized" => false,
          "live_tbackend_binding" => false,
          "ledger_reads" => false,
          "ledger_writes" => false,
          "ledger_replay" => false
        }
      }
    end

    private

    def validate(token)
      return blocked("runtime.executor_approval_missing", nil, "ExecutorApprovalToken is missing") if token.nil?
      unless token.is_a?(Hash)
        return blocked("runtime.executor_approval_malformed", nil, "ExecutorApprovalToken must be an object")
      end

      missing = REQUIRED_FIELDS.reject { |field| token.key?(field) }
      return blocked("runtime.executor_approval_malformed", token, "missing fields: #{missing.join(", ")}") unless missing.empty?
      return blocked("runtime.executor_approval_malformed", token, "kind/version mismatch") unless token.fetch("kind") == "executor_approval_token" && token.fetch("version") == TOKEN_VERSION
      return blocked("runtime.executor_approval_signature_invalid", token, "token_hash does not match canonical token body") unless valid_hash?(token)
      return blocked("runtime.executor_approval_signature_invalid", token, "signature does not match token_hash and authority") unless valid_signature?(token)
      return blocked("runtime.executor_approval_authority_untrusted", token, "authority_ref is not trusted") unless TRUSTED_AUTHORITIES.include?(token.fetch("authority_ref"))
      return blocked("runtime.executor_approval_expired", token, "token expired") if Time.iso8601(token.fetch("expires_at")) <= NOW
      return blocked("runtime.executor_approval_revoked", token, "token revoked") unless token.dig("revocation", "status") == "active"
      return blocked("runtime.executor_approval_wrong_gate", token, "token gate is not tbackend_gate3") unless token.fetch("gate") == "tbackend_gate3"
      return blocked("runtime.executor_approval_wrong_scope", token, "token scope does not authorize temporal_evaluate TEMPORAL") unless valid_scope?(token.fetch("scope"))
      return blocked("runtime.executor_approval_artifact_mismatch", token, "token artifact_ref does not match loaded artifact") unless token.fetch("artifact_ref") == @context.fetch("artifact_ref")
      return blocked("runtime.executor_approval_contract_mismatch", token, "token contract_refs do not cover target contract") unless covers_all?(token.fetch("contract_refs"), [@context.fetch("contract_ref")])
      return blocked("runtime.executor_approval_capability_mismatch", token, "token capability_refs do not cover required capabilities") unless covers_all?(token.fetch("capability_refs"), @context.fetch("required_capabilities"))
      return blocked("runtime.executor_approval_evidence_missing", token, "evidence_ref not found") unless EVIDENCE_REGISTRY.include?(token.fetch("evidence_ref"))

      ok(token)
    rescue ArgumentError
      blocked("runtime.executor_approval_malformed", token, "invalid timestamp")
    end

    def blocked(reason_code, token, message)
      {
        "decision" => "blocked",
        "reason_code" => reason_code,
        "message" => message,
        "token_ref" => token.is_a?(Hash) ? token["token_id"] : nil,
        "runtime_enforced" => false
      }
    end

    def ok(token)
      {
        "decision" => "ok",
        "reason_code" => "runtime.executor_approval_token_valid",
        "token_ref" => token.fetch("token_id"),
        "authority_ref" => token.fetch("authority_ref"),
        "evidence_ref" => token.fetch("evidence_ref"),
        "runtime_enforced" => false
      }
    end

    def evaluation_readiness(approval)
      unless approval.fetch("decision") == "ok"
        return {
          "decision" => "blocked",
          "reason_code" => approval.fetch("reason_code"),
          "blocks_before_executor" => true,
          "gate3_open" => GATE3_OPEN
        }
      end

      unless GATE3_OPEN
        return {
          "decision" => "blocked",
          "reason_code" => "runtime.temporal_gate3_closed",
          "blocks_before_executor" => true,
          "gate3_open" => false
        }
      end

      {
        "decision" => "ok",
        "reason_code" => "runtime.temporal_executor_ready",
        "blocks_before_executor" => false,
        "gate3_open" => true
      }
    end

    def valid_scope?(scope)
      scope.is_a?(Hash) &&
        scope.fetch("operation", nil) == "temporal_evaluate" &&
        scope.fetch("environment", nil) == "proof" &&
        scope.fetch("max_fragment_class", nil) == "TEMPORAL"
    end

    def covers_all?(provided, required)
      (required - Array(provided)).empty?
    end

    def valid_hash?(token)
      token.fetch("token_hash") == token_hash(token)
    end

    def valid_signature?(token)
      signature = token.fetch("signature")
      signature.is_a?(Hash) &&
        signature.fetch("alg", nil) == "recorded-decision-hash" &&
        signature.fetch("key_ref", nil) == token.fetch("authority_ref") &&
        signature.fetch("value", nil) == signature_value(token.fetch("token_hash"), token.fetch("authority_ref"))
    end

    def token_hash(token)
      Canonical.hash(token_body(token))
    end

    def token_body(token)
      token.reject { |key, _value| %w[token_hash signature].include?(key) }
    end

    def signature_value(token_hash, authority_ref)
      "sig:#{Canonical.short_hash("token_hash" => token_hash, "authority_ref" => authority_ref)}"
    end
  end

  module_function

  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)
    context = proof_context
    validator = ExecutorApprovalValidator.new(context: context)
    cases = build_cases(context)
    reports = cases.to_h do |case_id, token|
      [case_id, validator.compatibility_report(case_id: case_id, token: token)]
    end
    checks = build_checks(reports)
    summary = {
      "kind" => "executor_approval_token_report_proof_summary",
      "format_version" => "0.1.0",
      "card" => "S3-R10-C1-P",
      "track" => "executor-approval-token-report-proof-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "scope" => {
        "live_executor" => false,
        "live_tbackend" => false,
        "ledger_binding" => false,
        "production_cache" => false,
        "gate3_open" => GATE3_OPEN
      },
      "context" => context,
      "reports" => reports,
      "checks" => checks,
      "remaining_gate3_gaps" => remaining_gate3_gaps
    }
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def proof_context
    artifact = compile_temporal_artifact
    manifest = read_json(Pathname.new(artifact.fetch("igapp_path")) / "manifest.json")
    contract_id = manifest.fetch("contracts").first
    index_entry = manifest.fetch("contract_index").fetch(contract_id)
    temporal = index_entry.fetch("temporal")
    {
      "artifact_path" => artifact.fetch("igapp_path"),
      "artifact_ref" => "igapp/#{manifest.fetch("artifact_hash")}",
      "contract_id" => contract_id,
      "contract_ref" => index_entry.fetch("contract_ref"),
      "required_capabilities" => temporal.fetch("required_capabilities"),
      "required_gate" => "tbackend_gate3",
      "required_operation" => "temporal_evaluate",
      "max_fragment_class" => "TEMPORAL"
    }
  end

  def compile_temporal_artifact
    igapp_path = OUT_DIR / "history_single_axis.igapp"
    result = IgniterLang.compile(
      source_path: HISTORY_SOURCE,
      out_path: igapp_path,
      sample_input: { "technician_id" => "tech-1", "as_of" => "2026-05-08T12:00:00Z" }
    )
    {
      "igapp_path" => igapp_path,
      "compile_status" => result.fetch("status"),
      "pass_result" => result.fetch("compilation_report").fetch("pass_result")
    }
  end

  def build_cases(context)
    valid = valid_token(context)
    {
      "missing" => nil,
      "malformed" => { "kind" => "executor_approval_token" },
      "invalid_hash" => valid.merge("token_hash" => "sha256:invalid"),
      "invalid_signature" => valid.merge("signature" => valid.fetch("signature").merge("value" => "sig:invalid")),
      "untrusted_authority" => resign(valid.merge("authority_ref" => "architect-supervisor/untrusted")),
      "expired" => resign(valid.merge("expires_at" => "2026-05-08T11:59:59Z")),
      "revoked" => resign(valid.merge("revocation" => { "status" => "revoked", "revocation_ref" => "decision/gate3/revocation/001" })),
      "wrong_gate" => resign(valid.merge("gate" => "gate2_descriptor_metadata")),
      "wrong_scope" => resign(valid.merge("scope" => valid.fetch("scope").merge("operation" => "cache_probe"))),
      "wrong_artifact" => resign(valid.merge("artifact_ref" => "igapp/sha256:wrong-artifact")),
      "wrong_contract" => resign(valid.merge("contract_refs" => ["contract/Wrong/sha256:wrong"])),
      "wrong_capability" => resign(valid.merge("capability_refs" => ["bihistory_read"])),
      "missing_evidence" => resign(valid.merge("evidence_ref" => "decision/gate3/record/missing")),
      "valid_token_gate3_closed" => valid
    }
  end

  def valid_token(context)
    token = {
      "kind" => "executor_approval_token",
      "version" => TOKEN_VERSION,
      "token_id" => "approval/2026-05-08/gate3/proof-001",
      "authority_ref" => TRUSTED_AUTHORITIES.first,
      "gate" => "tbackend_gate3",
      "scope" => {
        "operation" => "temporal_evaluate",
        "environment" => "proof",
        "max_fragment_class" => "TEMPORAL"
      },
      "artifact_ref" => context.fetch("artifact_ref"),
      "contract_refs" => [context.fetch("contract_ref")],
      "capability_refs" => context.fetch("required_capabilities"),
      "issued_at" => "2026-05-08T12:00:00Z",
      "expires_at" => "2026-05-15T12:00:00Z",
      "revocation" => {
        "status" => "active",
        "revocation_ref" => nil
      },
      "evidence_ref" => EVIDENCE_REGISTRY.first
    }
    resign(token)
  end

  def resign(token)
    body = token.reject { |key, _value| %w[token_hash signature].include?(key) }
    token_hash = Canonical.hash(body)
    token.merge(
      "token_hash" => token_hash,
      "signature" => {
        "alg" => "recorded-decision-hash",
        "key_ref" => token.fetch("authority_ref"),
        "value" => "sig:#{Canonical.short_hash("token_hash" => token_hash, "authority_ref" => token.fetch("authority_ref"))}"
      }
    )
  end

  def build_checks(reports)
    expected = {
      "missing" => "runtime.executor_approval_missing",
      "malformed" => "runtime.executor_approval_malformed",
      "invalid_hash" => "runtime.executor_approval_signature_invalid",
      "invalid_signature" => "runtime.executor_approval_signature_invalid",
      "untrusted_authority" => "runtime.executor_approval_authority_untrusted",
      "expired" => "runtime.executor_approval_expired",
      "revoked" => "runtime.executor_approval_revoked",
      "wrong_gate" => "runtime.executor_approval_wrong_gate",
      "wrong_scope" => "runtime.executor_approval_wrong_scope",
      "wrong_artifact" => "runtime.executor_approval_artifact_mismatch",
      "wrong_contract" => "runtime.executor_approval_contract_mismatch",
      "wrong_capability" => "runtime.executor_approval_capability_mismatch",
      "missing_evidence" => "runtime.executor_approval_evidence_missing",
      "valid_token_gate3_closed" => "runtime.temporal_gate3_closed"
    }
    expected.transform_keys { |case_id| "#{case_id}.reason_code" }.transform_values.with_index do |reason, index|
      case_id = expected.keys.fetch(index)
      reports.dig(case_id, "evaluation_readiness", "reason_code") == reason
    end.merge(
      "all_reports_block_before_executor" => reports.values.all? do |report|
        report.dig("evaluation_readiness", "decision") == "blocked" &&
          report.dig("evaluation_readiness", "blocks_before_executor") == true
      end,
      "no_live_operation_attempted" => reports.values.all? do |report|
        operation = report.fetch("operation_check")
        operation.values.all?(false)
      end,
      "all_reports_remain_report_only" => reports.values.all? do |report|
        report.fetch("report_only") == true && report.fetch("runtime_enforced") == false
      end,
      "valid_token_approval_ok_but_gate3_closed" => begin
        report = reports.fetch("valid_token_gate3_closed")
        report.dig("executor_approval_check", "decision") == "ok" &&
          report.dig("evaluation_readiness", "reason_code") == "runtime.temporal_gate3_closed"
      end
    )
  end

  def remaining_gate3_gaps
    [
      "RuntimeMachine must enforce this same approval decision before evaluator/cache/TBackend entry.",
      "Gate 3 opening record must define trusted authorities and revocation registry.",
      "Production signature verification must replace proof-local deterministic recorded-decision hash.",
      "CompatibilityReport persistence/audit receipts remain unimplemented.",
      "Executor cache-key boundary must remain ordered before cache lookup or TBackend access."
    ]
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} executor_approval_token_report_proof"
    summary.fetch("checks").each do |name, ok|
      puts "#{name}: #{ok ? "ok" : "FAIL"}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = ExecutorApprovalTokenReportProof.run
exit(success ? 0 : 1)
