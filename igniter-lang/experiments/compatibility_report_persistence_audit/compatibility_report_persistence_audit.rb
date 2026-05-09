#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang/temporal_access_runtime"
require_relative "../../lib/igniter_lang/temporal_executor"

module CompatibilityReportPersistenceAuditProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  ADDENDUM_PATH = LANG_ROOT / "docs/gates/gate3-live-read-decision-addendum-v0.md"
  OUT_DIR = LANG_ROOT / "experiments/compatibility_report_persistence_audit/out"
  SUMMARY_PATH = OUT_DIR / "compatibility_report_persistence_audit_summary.json"
  PROOF_AS_OF = "2026-05-09T12:00:00Z"
  SIGNED_STATUS = "signed-approved-restricted-phase1-live-read"

  module_function

  class AuditEnvelopeExporter
    attr_reader :exports

    def initialize
      @exports = []
    end

    def export(evaluation:, observations:, token:, invocation_evidence:, addendum_status:)
      unless signed_addendum_ref_valid?(invocation_evidence, addendum_status)
        return non_compliant(
          evaluation: evaluation,
          token: token,
          reason_code: "audit.signed_addendum_ref_missing"
        )
      end

      envelope = if evaluation.fetch("status") == "ok"
                   allowed_read_envelope(evaluation, observations.fetch(0), token, invocation_evidence)
                 else
                   refusal_envelope(evaluation, token, invocation_evidence)
                 end
      @exports << envelope
      envelope
    end

    private

    def signed_addendum_ref_valid?(invocation_evidence, addendum_status)
      invocation_evidence.is_a?(Hash) &&
        invocation_evidence.fetch("signed_addendum_ref", nil) == ADDENDUM_PATH.relative_path_from(ROOT).to_s &&
        addendum_status == SIGNED_STATUS
    end

    def allowed_read_envelope(evaluation, observation, token, invocation_evidence)
      {
        "kind" => "audit_ready_temporal_read_envelope",
        "format_version" => "0.1.0",
        "envelope_id" => envelope_id(observation, evaluation),
        "export_mode" => "explicit",
        "audit_state" => "audit_ready_not_persisted",
        "temporal_live_read_observation" => observation,
        "compatibility_report_ref" => evaluation.fetch("compatibility_report_id"),
        "authority_ref" => token.fetch("authority_ref"),
        "signed_addendum_ref" => invocation_evidence.fetch("signed_addendum_ref"),
        "backend_identity" => observation.fetch("backend_identity"),
        "result" => {
          "status" => "allowed",
          "reason_code" => IgniterLang::TemporalExecutor::ReasonCode::EVALUATION_READY,
          "result_present" => observation.fetch("result_present")
        },
        "storage" => storage_boundary
      }
    end

    def refusal_envelope(evaluation, token, invocation_evidence)
      {
        "kind" => "audit_ready_temporal_refusal_envelope",
        "format_version" => "0.1.0",
        "envelope_id" => envelope_id({}, evaluation),
        "export_mode" => "explicit",
        "audit_state" => "audit_ready_not_persisted",
        "temporal_live_read_observation" => nil,
        "compatibility_report_ref" => evaluation.fetch("compatibility_report_id"),
        "authority_ref" => token.fetch("authority_ref"),
        "signed_addendum_ref" => invocation_evidence.fetch("signed_addendum_ref"),
        "backend_identity" => nil,
        "result" => {
          "status" => "refused",
          "reason_code" => evaluation.fetch("reason_code"),
          "blocked_stage" => evaluation.fetch("blocked_stage")
        },
        "storage" => storage_boundary
      }
    end

    def non_compliant(evaluation:, token:, reason_code:)
      {
        "kind" => "audit_export_non_compliant",
        "format_version" => "0.1.0",
        "status" => "non_compliant",
        "reason_code" => reason_code,
        "compatibility_report_ref" => evaluation["compatibility_report_id"],
        "authority_ref" => token.fetch("authority_ref"),
        "signed_addendum_ref" => nil,
        "storage" => storage_boundary
      }
    end

    def storage_boundary
      {
        "automatic_persistence" => false,
        "durable_persistence" => false,
        "ledger_write" => false,
        "production_storage" => false
      }
    end

    def envelope_id(observation, evaluation)
      Digest::SHA256.hexdigest(JSON.generate([observation, evaluation.fetch("compatibility_report_id")]))[0, 20]
    end
  end

  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)

    addendum_status = read_addendum_status
    cases = build_cases(addendum_status)
    checks = build_checks(cases, addendum_status)
    summary = {
      "kind" => "compatibility_report_persistence_audit_summary",
      "format_version" => "0.1.0",
      "card" => "S3-R21-C1-P",
      "track" => "compatibility-report-persistence-audit-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "addendum" => {
        "path" => ADDENDUM_PATH.relative_path_from(ROOT).to_s,
        "status" => addendum_status,
        "signed" => addendum_status == SIGNED_STATUS
      },
      "boundary" => {
        "observation_source" => "IgniterLang::TemporalExecutor::Phase1#observations",
        "export" => "explicit proof-local audit-ready envelope",
        "automatic_persistence" => false,
        "durable_audit" => false,
        "ledger" => false,
        "authority_registry" => false
      },
      "cases" => cases,
      "checks" => checks
    }

    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def build_cases(addendum_status)
    authorized = evaluate_authorized_read(addendum_status)
    refusal = evaluate_gate_closed_refusal
    exporter = AuditEnvelopeExporter.new
    explicit_before_count = exporter.exports.length
    authorized_envelope = exporter.export(
      evaluation: authorized.fetch("evaluate"),
      observations: authorized.fetch("observations"),
      token: valid_token,
      invocation_evidence: signed_invocation_evidence,
      addendum_status: addendum_status
    )
    explicit_after_count = exporter.exports.length
    refusal_envelope = exporter.export(
      evaluation: refusal.fetch("evaluate"),
      observations: refusal.fetch("observations"),
      token: valid_token,
      invocation_evidence: signed_invocation_evidence,
      addendum_status: addendum_status
    )
    missing_addendum_export = exporter.export(
      evaluation: authorized.fetch("evaluate"),
      observations: authorized.fetch("observations"),
      token: valid_token,
      invocation_evidence: {},
      addendum_status: addendum_status
    )

    {
      "authorized_read" => authorized,
      "explicit_export_boundary" => {
        "exports_before_explicit_call" => explicit_before_count,
        "exports_after_authorized_export" => explicit_after_count,
        "automatic_persistence" => false,
        "summary_file_is_proof_artifact" => true
      },
      "authorized_audit_ready_envelope" => authorized_envelope,
      "refusal_audit_ready_envelope" => refusal_envelope,
      "missing_signed_addendum_ref" => missing_addendum_export
    }
  end

  def evaluate_authorized_read(addendum_status)
    executor = IgniterLang::TemporalExecutor::Phase1.new(
      backend: memory_backend,
      gate3_authorized: caller_may_pass_gate3_authorized?(
        addendum_status: addendum_status,
        invocation_evidence: signed_invocation_evidence
      )
    )
    result = executor.evaluate(history_contract, token: valid_token, inputs: { "sku" => "prod-001" }, as_of: PROOF_AS_OF)
    { "evaluate" => result, "observations" => executor.observations }
  end

  def evaluate_gate_closed_refusal
    executor = IgniterLang::TemporalExecutor::Phase1.new(
      backend: memory_backend,
      gate3_authorized: false
    )
    result = executor.evaluate(history_contract, token: valid_token, inputs: { "sku" => "prod-001" }, as_of: PROOF_AS_OF)
    { "evaluate" => result, "observations" => executor.observations }
  end

  def build_checks(cases, addendum_status)
    {
      "addendum.signed_status_detected" =>
        addendum_status == SIGNED_STATUS,
      "authorized_read.observation_emitted" =>
        cases.dig("authorized_read", "evaluate", "status") == "ok" &&
          cases.dig("authorized_read", "observations", 0, "kind") == "temporal_live_read_observation",
      "authorized_envelope.minimum_fields_present" =>
        audit_envelope_has_minimum_fields?(cases.fetch("authorized_audit_ready_envelope")),
      "authorized_envelope.compatibility_report_ref_present" =>
        cases.dig("authorized_audit_ready_envelope", "compatibility_report_ref").to_s.start_with?("compat/phase1/"),
      "authorized_envelope.backend_identity_present" =>
        cases.dig("authorized_audit_ready_envelope", "backend_identity", "kind") == "proof_local_memory_backend",
      "authorized_envelope.result_allowed" =>
        cases.dig("authorized_audit_ready_envelope", "result", "status") == "allowed",
      "refusal_envelope.reason_present" =>
        cases.dig("refusal_audit_ready_envelope", "result", "status") == "refused" &&
          cases.dig("refusal_audit_ready_envelope", "result", "reason_code") ==
            IgniterLang::TemporalExecutor::ReasonCode::GATE3_CLOSED,
      "export.explicit_not_automatic" =>
        cases.dig("explicit_export_boundary", "exports_before_explicit_call").zero? &&
          cases.dig("explicit_export_boundary", "exports_after_authorized_export") == 1 &&
          cases.dig("authorized_audit_ready_envelope", "storage", "automatic_persistence") == false,
      "missing_signed_addendum_ref.non_compliant" =>
        cases.dig("missing_signed_addendum_ref", "status") == "non_compliant" &&
          cases.dig("missing_signed_addendum_ref", "reason_code") == "audit.signed_addendum_ref_missing",
      "no_production_storage_or_ledger" =>
        no_production_storage_or_ledger?(cases)
    }
  end

  def audit_envelope_has_minimum_fields?(envelope)
    %w[
      temporal_live_read_observation
      compatibility_report_ref
      authority_ref
      signed_addendum_ref
      backend_identity
      result
    ].all? { |key| envelope.key?(key) && !envelope[key].nil? }
  end

  def no_production_storage_or_ledger?(cases)
    %w[authorized_audit_ready_envelope refusal_audit_ready_envelope missing_signed_addendum_ref].all? do |name|
      storage = cases.fetch(name).fetch("storage")
      storage.fetch("durable_persistence") == false &&
        storage.fetch("ledger_write") == false &&
        storage.fetch("production_storage") == false
    end
  end

  def caller_may_pass_gate3_authorized?(addendum_status:, invocation_evidence:)
    addendum_status == SIGNED_STATUS &&
      invocation_evidence.is_a?(Hash) &&
      invocation_evidence.fetch("signed_addendum_ref", nil) == ADDENDUM_PATH.relative_path_from(ROOT).to_s
  end

  def read_addendum_status
    line = ADDENDUM_PATH.readlines.find { |candidate| candidate.start_with?("Status:") }
    line.to_s.split(":", 2).last.to_s.strip
  end

  def signed_invocation_evidence
    {
      "kind" => "gate3_invocation_evidence",
      "signed_addendum_ref" => ADDENDUM_PATH.relative_path_from(ROOT).to_s,
      "policy_effect" => "caller_may_pass_gate3_authorized_true"
    }
  end

  def valid_token
    {
      "kind" => "executor_approval_token",
      "version" => "executor-approval-token-v1",
      "token_id" => "approval/persistence-audit-proof",
      "authority_ref" => IgniterLang::TemporalExecutor::GATE3_AUTHORITY_REF,
      "gate" => "tbackend_gate3"
    }
  end

  def memory_backend
    backend = IgniterLang::TemporalAccessRuntime::MemoryBackend.new
    backend.seed_append_observations([
      { "subject" => "sku/prod-001/price", "valid_from" => "2026-01-01T00:00:00Z",
        "value" => "99.00", "value_type" => "String" }
    ])
    backend
  end

  def history_contract
    {
      "contract_id" => "HistoryAxesTest",
      "fragment_class" => "temporal",
      "temporal_nodes" => [
        { "kind" => "temporal_input_node", "name" => "price_history",
          "store_ref" => "sku/{sku}/price" },
        { "kind" => "temporal_access_node", "name" => "price_at",
          "source_ref" => "price_history", "axis" => "valid_time",
          "as_of_ref" => "as_of" }
      ]
    }
  end

  def write_json(path, value)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} compatibility_report_persistence_audit"
    summary.fetch("checks").each { |name, ok| puts "  #{name}: #{ok ? "ok" : "FAIL"}" }
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

if $PROGRAM_NAME == __FILE__
  success = CompatibilityReportPersistenceAuditProof.run
  exit(success ? 0 : 1)
end
