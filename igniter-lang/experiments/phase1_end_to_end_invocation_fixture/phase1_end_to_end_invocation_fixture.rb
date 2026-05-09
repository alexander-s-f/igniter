#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang/temporal_access_runtime"
require_relative "../../lib/igniter_lang/temporal_executor"

module Phase1EndToEndInvocationFixture
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  ADDENDUM_PATH = LANG_ROOT / "docs/gates/gate3-live-read-decision-addendum-v0.md"
  OUT_DIR = LANG_ROOT / "experiments/phase1_end_to_end_invocation_fixture/out"
  SUMMARY_PATH = OUT_DIR / "phase1_end_to_end_invocation_fixture_summary.json"

  AUTHORITY_REF = IgniterLang::TemporalExecutor::GATE3_AUTHORITY_REF
  SIGNED_STATUS = "signed-approved-restricted-phase1-live-read"
  DECISION_DOC_REF = ADDENDUM_PATH.relative_path_from(ROOT).to_s
  PROOF_AS_OF = "2026-05-09T12:00:00Z"

  module_function

  class ExplicitNonLedgerBackend
    attr_reader :read_attempts

    def initialize
      @read_attempts = 0
    end

    def phase1_backend_identity
      {
        "kind" => "proof_local_non_ledger_backend",
        "backend_family" => "proof_local",
        "phase1_allowed" => true,
        "ledger_backed" => false,
        "invokes_ledger_package" => false,
        "package_adapter" => false
      }
    end

    def read_as_of(subject, as_of)
      @read_attempts += 1
      [
        { "kind" => "some", "value" => "non-ledger:#{subject}@#{as_of}" },
        { "observation_id" => "obs/e2e/non_ledger/#{@read_attempts}" }
      ]
    end
  end

  class LedgerLikeBackend
    attr_reader :read_attempts

    def initialize
      @read_attempts = 0
    end

    def phase1_backend_identity
      {
        "kind" => "ledger_tbackend_adapter",
        "backend_family" => "ledger",
        "phase1_allowed" => true,
        "ledger_backed" => true,
        "invokes_ledger_package" => true,
        "package_adapter" => true
      }
    end

    def read_as_of(_subject, _as_of)
      @read_attempts += 1
      raise "Ledger-like backend must not be called"
    end
  end

  class AuditExporter
    attr_reader :exports

    def initialize
      @exports = []
    end

    def export(evaluation:, observations:, token:, invocation_evidence:, registry_check:)
      unless registry_check.fetch("status") == "ok" && signed_addendum_ref_valid?(invocation_evidence)
        return non_compliant(
          evaluation: evaluation,
          token: token,
          reason_code: "audit.signed_addendum_ref_missing"
        )
      end

      envelope = if evaluation.fetch("status") == "ok"
                   allowed_envelope(evaluation, observations.fetch(0), token, invocation_evidence, registry_check)
                 else
                   refusal_envelope(evaluation, token, invocation_evidence, registry_check)
                 end
      @exports << envelope
      envelope
    end

    def missing_export_non_compliant(evaluation:, token:)
      {
        "kind" => "audit_export_non_compliant",
        "format_version" => "0.1.0",
        "status" => "non_compliant",
        "reason_code" => "audit.export_missing",
        "compatibility_report_ref" => evaluation.fetch("compatibility_report_id"),
        "authority_ref" => token.fetch("authority_ref"),
        "storage" => storage_boundary
      }
    end

    private

    def signed_addendum_ref_valid?(invocation_evidence)
      invocation_evidence.is_a?(Hash) &&
        invocation_evidence.fetch("decision_doc_ref", nil) == DECISION_DOC_REF
    end

    def allowed_envelope(evaluation, observation, token, invocation_evidence, registry_check)
      {
        "kind" => "audit_ready_temporal_read_envelope",
        "format_version" => "0.1.0",
        "envelope_id" => envelope_id(observation, evaluation),
        "export_mode" => "explicit",
        "audit_state" => "audit_ready_not_persisted",
        "registry_check_ref" => registry_check.fetch("registry_check_id"),
        "temporal_live_read_observation" => observation,
        "compatibility_report_ref" => evaluation.fetch("compatibility_report_id"),
        "authority_ref" => token.fetch("authority_ref"),
        "signed_addendum_ref" => invocation_evidence.fetch("decision_doc_ref"),
        "backend_identity" => observation.fetch("backend_identity"),
        "result" => {
          "status" => "allowed",
          "reason_code" => IgniterLang::TemporalExecutor::ReasonCode::EVALUATION_READY,
          "result_present" => observation.fetch("result_present")
        },
        "storage" => storage_boundary
      }
    end

    def refusal_envelope(evaluation, token, invocation_evidence, registry_check)
      {
        "kind" => "audit_ready_temporal_refusal_envelope",
        "format_version" => "0.1.0",
        "envelope_id" => envelope_id({}, evaluation),
        "export_mode" => "explicit",
        "audit_state" => "audit_ready_not_persisted",
        "registry_check_ref" => registry_check.fetch("registry_check_id"),
        "temporal_live_read_observation" => nil,
        "compatibility_report_ref" => evaluation.fetch("compatibility_report_id"),
        "authority_ref" => token.fetch("authority_ref"),
        "signed_addendum_ref" => invocation_evidence.fetch("decision_doc_ref"),
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
      "kind" => "phase1_end_to_end_invocation_fixture_summary",
      "format_version" => "0.1.0",
      "card" => "S3-R22-C1-P",
      "track" => "phase1-end-to-end-invocation-fixture-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "addendum" => {
        "path" => DECISION_DOC_REF,
        "status" => addendum_status,
        "signed" => addendum_status == SIGNED_STATUS
      },
      "pipeline" => [
        "authority_registry_check",
        "caller_authorization",
        "phase1_executor",
        "audit_ready_export"
      ],
      "non_authorization" => {
        "ledger" => false,
        "production_storage" => false,
        "production_signing" => false,
        "durable_audit" => false,
        "phase2" => false
      },
      "cases" => cases,
      "checks" => checks
    }

    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def build_cases(addendum_status)
    memory_success = invoke(
      registry: active_registry,
      invocation_evidence: invocation_evidence,
      backend: memory_backend,
      addendum_status: addendum_status,
      export_audit: true
    )
    non_ledger_success = invoke(
      registry: active_registry,
      invocation_evidence: invocation_evidence,
      backend: ExplicitNonLedgerBackend.new,
      addendum_status: addendum_status,
      export_audit: true
    )
    revoked = invoke(
      registry: registry_with(registry_entry(status: "revoked", revoked_on: "2026-05-10")),
      invocation_evidence: invocation_evidence,
      backend: memory_backend,
      addendum_status: addendum_status,
      export_audit: false
    )
    missing_addendum = invoke(
      registry: active_registry,
      invocation_evidence: invocation_evidence(decision_doc_ref: nil),
      backend: memory_backend,
      addendum_status: addendum_status,
      export_audit: false
    )
    ledger_like = invoke(
      registry: active_registry,
      invocation_evidence: invocation_evidence,
      backend: LedgerLikeBackend.new,
      addendum_status: addendum_status,
      export_audit: true
    )
    missing_audit_export = invoke(
      registry: active_registry,
      invocation_evidence: invocation_evidence,
      backend: memory_backend,
      addendum_status: addendum_status,
      export_audit: false
    )

    {
      "memory_backend_end_to_end" => memory_success,
      "non_ledger_backend_end_to_end" => non_ledger_success,
      "revoked_registry_blocks_before_executor" => revoked,
      "missing_signed_addendum_blocks_before_executor" => missing_addendum,
      "ledger_like_backend_blocks_before_read" => ledger_like,
      "missing_audit_export_non_compliant" => missing_audit_export
    }
  end

  def invoke(registry:, invocation_evidence:, backend:, addendum_status:, export_audit:)
    registry_check = registry_check(registry, invocation_evidence)
    return blocked_before_executor(registry_check, audit_export: nil) unless registry_check.fetch("status") == "ok"

    executor = IgniterLang::TemporalExecutor::Phase1.new(
      backend: backend,
      gate3_authorized: registry_check.fetch("caller_may_pass_gate3_authorized")
    )
    evaluation = executor.evaluate(
      history_contract,
      token: valid_token,
      inputs: { "sku" => "prod-001" },
      as_of: PROOF_AS_OF
    )
    exporter = AuditExporter.new
    audit_export = if export_audit
                     exporter.export(
                       evaluation: evaluation,
                       observations: executor.observations,
                       token: valid_token,
                       invocation_evidence: invocation_evidence,
                       registry_check: registry_check
                     )
                   else
                     exporter.missing_export_non_compliant(evaluation: evaluation, token: valid_token)
                   end

    {
      "registry_check" => registry_check,
      "caller_authorization" => {
        "gate3_authorized" => registry_check.fetch("caller_may_pass_gate3_authorized"),
        "source" => "proof_local_authority_registry"
      },
      "executor_called" => true,
      "evaluate" => evaluation,
      "observations" => executor.observations,
      "read_attempts" => backend.respond_to?(:read_attempts) ? backend.read_attempts : nil,
      "audit_export" => audit_export,
      "storage" => audit_export.fetch("storage")
    }
  end

  def blocked_before_executor(registry_check, audit_export:)
    {
      "registry_check" => registry_check,
      "caller_authorization" => {
        "gate3_authorized" => false,
        "source" => "proof_local_authority_registry"
      },
      "executor_called" => false,
      "evaluate" => nil,
      "observations" => [],
      "read_attempts" => 0,
      "audit_export" => audit_export,
      "storage" => {
        "automatic_persistence" => false,
        "durable_persistence" => false,
        "ledger_write" => false,
        "production_storage" => false
      }
    }
  end

  def registry_check(registry, invocation)
    authority_ref = invocation.fetch("authority_ref")
    registry_entry = registry[authority_ref]
    return registry_block("authority_registry.entry_missing", "registry_entry") unless registry_entry

    case registry_entry.fetch("status")
    when "active"
      return registry_block("authority_registry.active_has_revocation", "registry_entry") if registry_entry["revoked_on"]
      return registry_block("authority_registry.active_has_supersession", "registry_entry") if registry_entry["superseded_by"]
    when "revoked"
      return registry_block("authority_registry.revoked", "registry_entry", "revoked_on" => registry_entry["revoked_on"])
    when "superseded"
      return registry_block("authority_registry.superseded", "registry_entry", "superseded_by" => registry_entry["superseded_by"])
    else
      return registry_block("authority_registry.status_unknown", "registry_entry", "status" => registry_entry["status"])
    end

    unless registry_entry.fetch("decision_doc_ref") == invocation["decision_doc_ref"]
      return registry_block("authority_registry.signed_addendum_evidence_missing", "decision_doc_ref")
    end
    unless registry_entry.fetch("required_capability") == invocation["required_capability"]
      return registry_block("authority_registry.required_capability_mismatch", "required_capability")
    end
    unless registry_entry.fetch("allowed_scope") == invocation.fetch("requested_scope")
      return registry_block("authority_registry.scope_mismatch", "allowed_scope")
    end

    allowed = read_addendum_status == SIGNED_STATUS
    {
      "status" => "ok",
      "registry_check_id" => registry_check_id(registry_entry, invocation),
      "caller_may_pass_gate3_authorized" => allowed,
      "gate3_authorized_value" => allowed,
      "reason_code" => "authority_registry.active_scope_allowed",
      "authority_ref" => authority_ref,
      "decision_doc_ref" => registry_entry.fetch("decision_doc_ref"),
      "production_signing" => false,
      "executor_called" => false
    }
  end

  def registry_block(reason_code, stage, extra = {})
    {
      "status" => "blocked",
      "registry_check_id" => "registry/check/#{Digest::SHA256.hexdigest(reason_code)[0, 12]}",
      "caller_may_pass_gate3_authorized" => false,
      "gate3_authorized_value" => false,
      "reason_code" => reason_code,
      "blocked_stage" => stage,
      "executor_called" => false,
      "production_signing" => false
    }.merge(extra)
  end

  def registry_check_id(registry_entry, invocation)
    Digest::SHA256.hexdigest(JSON.generate([registry_entry, invocation]))[0, 20].prepend("registry/check/")
  end

  def active_registry
    registry_with(registry_entry)
  end

  def registry_with(entry)
    { AUTHORITY_REF => entry }
  end

  def registry_entry(status: "active", revoked_on: nil, superseded_by: nil)
    {
      "authority_ref" => AUTHORITY_REF,
      "status" => status,
      "issued_on" => "2026-05-09",
      "revoked_on" => revoked_on,
      "superseded_by" => superseded_by,
      "allowed_scope" => allowed_scope,
      "required_capability" => "history_read",
      "decision_doc_ref" => DECISION_DOC_REF
    }
  end

  def invocation_evidence(decision_doc_ref: DECISION_DOC_REF)
    {
      "authority_ref" => AUTHORITY_REF,
      "decision_doc_ref" => decision_doc_ref,
      "requested_scope" => allowed_scope,
      "required_capability" => "history_read",
      "would_pass_gate3_authorized" => true
    }
  end

  def allowed_scope
    {
      "gate" => "gate3",
      "phase" => "phase1",
      "executor" => "IgniterLang::TemporalExecutor::Phase1",
      "operation" => "history_valid_time_read",
      "history_axis" => "valid_time",
      "backend_family" => "memory_or_explicit_non_ledger"
    }
  end

  def valid_token
    {
      "kind" => "executor_approval_token",
      "version" => "executor-approval-token-v1",
      "token_id" => "approval/e2e-fixture",
      "authority_ref" => AUTHORITY_REF,
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

  def read_addendum_status
    line = ADDENDUM_PATH.readlines.find { |candidate| candidate.start_with?("Status:") }
    line.to_s.split(":", 2).last.to_s.strip
  end

  def build_checks(cases, addendum_status)
    {
      "addendum.signed_status_detected" =>
        addendum_status == SIGNED_STATUS,
      "memory_backend.end_to_end_allowed" =>
        allowed_e2e?(cases.fetch("memory_backend_end_to_end"), "proof_local_memory_backend"),
      "non_ledger_backend.end_to_end_allowed" =>
        allowed_e2e?(cases.fetch("non_ledger_backend_end_to_end"), "proof_local_non_ledger_backend"),
      "revoked_registry.blocks_before_executor" =>
        blocks_before_executor?(cases.fetch("revoked_registry_blocks_before_executor"),
                                "authority_registry.revoked"),
      "missing_signed_addendum.blocks_before_executor" =>
        blocks_before_executor?(cases.fetch("missing_signed_addendum_blocks_before_executor"),
                                "authority_registry.signed_addendum_evidence_missing"),
      "ledger_like_backend.blocks_before_read" =>
        cases.dig("ledger_like_backend_blocks_before_read", "evaluate", "blocked_stage") == "backend_identity" &&
          cases.dig("ledger_like_backend_blocks_before_read", "read_attempts") == 0,
      "missing_audit_export.non_compliant_not_persisted" =>
        cases.dig("missing_audit_export_non_compliant", "audit_export", "status") == "non_compliant" &&
          cases.dig("missing_audit_export_non_compliant", "audit_export", "reason_code") == "audit.export_missing" &&
          no_storage?(cases.fetch("missing_audit_export_non_compliant")),
      "no_case_uses_production_signing" =>
        cases.values.all? { |result| result.dig("registry_check", "production_signing") == false },
      "no_case_uses_production_storage_or_ledger" =>
        cases.values.all? { |result| no_storage?(result) }
    }
  end

  def allowed_e2e?(result, expected_backend_kind)
    result.dig("registry_check", "status") == "ok" &&
      result.dig("caller_authorization", "gate3_authorized") == true &&
      result.fetch("executor_called") == true &&
      result.dig("evaluate", "status") == "ok" &&
      result.dig("observations", 0, "backend_identity", "kind") == expected_backend_kind &&
      result.dig("audit_export", "kind") == "audit_ready_temporal_read_envelope" &&
      result.dig("audit_export", "audit_state") == "audit_ready_not_persisted" &&
      result.dig("audit_export", "storage", "durable_persistence") == false
  end

  def blocks_before_executor?(result, reason_code)
    result.fetch("executor_called") == false &&
      result.dig("registry_check", "reason_code") == reason_code &&
      result.dig("caller_authorization", "gate3_authorized") == false &&
      result.fetch("observations").empty?
  end

  def no_storage?(result)
    storage = result.fetch("storage")
    storage.fetch("automatic_persistence") == false &&
      storage.fetch("durable_persistence") == false &&
      storage.fetch("ledger_write") == false &&
      storage.fetch("production_storage") == false
  end

  def write_json(path, value)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} phase1_end_to_end_invocation_fixture"
    summary.fetch("checks").each { |name, ok| puts "  #{name}: #{ok ? "ok" : "FAIL"}" }
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

if $PROGRAM_NAME == __FILE__
  success = Phase1EndToEndInvocationFixture.run
  exit(success ? 0 : 1)
end
