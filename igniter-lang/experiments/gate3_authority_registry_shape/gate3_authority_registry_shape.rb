#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang/temporal_executor"

module Gate3AuthorityRegistryShapeProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = LANG_ROOT / "experiments/gate3_authority_registry_shape/out"
  SUMMARY_PATH = OUT_DIR / "gate3_authority_registry_shape_summary.json"

  AUTHORITY_REF = IgniterLang::TemporalExecutor::GATE3_AUTHORITY_REF
  DECISION_DOC_REF = "igniter-lang/docs/gates/gate3-live-read-decision-addendum-v0.md"

  module_function

  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)

    cases = {
      "active_registry_allows_gate3_authorized" => registry_check(active_registry, invocation_evidence),
      "revoked_registry_blocks_before_caller_sets_true" => registry_check(
        registry_with(entry(status: "revoked", revoked_on: "2026-05-10")),
        invocation_evidence
      ),
      "superseded_registry_blocks_before_caller_sets_true" => registry_check(
        registry_with(entry(status: "superseded", superseded_by: "authority/ref/replacement")),
        invocation_evidence
      ),
      "missing_registry_entry_blocks" => registry_check({}, invocation_evidence),
      "missing_signed_addendum_evidence_blocks" => registry_check(
        active_registry,
        invocation_evidence(decision_doc_ref: nil)
      ),
      "wrong_scope_blocks" => registry_check(
        active_registry,
        invocation_evidence(scope: invocation_scope.merge("history_axis" => "bitemporal"))
      ),
      "wrong_required_capability_blocks" => registry_check(
        registry_with(entry(required_capability: "ledger_replay")),
        invocation_evidence
      ),
      "malformed_registry_entry_blocks" => registry_check(
        registry_with(entry.except("issued_on")),
        invocation_evidence
      )
    }
    checks = build_checks(cases)
    summary = {
      "kind" => "gate3_authority_registry_shape_summary",
      "format_version" => "0.1.0",
      "card" => "S3-R21-C2-P",
      "track" => "gate3-authority-registry-shape-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "registry_shape" => registry_shape,
      "source_code_parity_authority_ref" => AUTHORITY_REF,
      "production_signing" => false,
      "production_key_management" => false,
      "phase2_ledger_adapter" => false,
      "cases" => cases,
      "checks" => checks
    }

    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def registry_shape
    {
      "authority_ref" => "string",
      "status" => "active|revoked|superseded",
      "issued_on" => "YYYY-MM-DD",
      "revoked_on" => "YYYY-MM-DD|null",
      "superseded_by" => "authority_ref|null",
      "allowed_scope" => {
        "gate" => "gate3",
        "phase" => "phase1",
        "executor" => "IgniterLang::TemporalExecutor::Phase1",
        "operation" => "history_valid_time_read",
        "history_axis" => "valid_time",
        "backend_family" => "memory_or_explicit_non_ledger"
      },
      "required_capability" => "history_read",
      "decision_doc_ref" => DECISION_DOC_REF
    }
  end

  def active_registry
    registry_with(entry)
  end

  def registry_with(entry_value)
    { AUTHORITY_REF => entry_value }
  end

  def entry(status: "active", revoked_on: nil, superseded_by: nil, required_capability: "history_read")
    {
      "authority_ref" => AUTHORITY_REF,
      "status" => status,
      "issued_on" => "2026-05-09",
      "revoked_on" => revoked_on,
      "superseded_by" => superseded_by,
      "allowed_scope" => allowed_scope,
      "required_capability" => required_capability,
      "decision_doc_ref" => DECISION_DOC_REF
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

  def invocation_evidence(decision_doc_ref: DECISION_DOC_REF, scope: invocation_scope, capability: "history_read")
    {
      "authority_ref" => AUTHORITY_REF,
      "decision_doc_ref" => decision_doc_ref,
      "requested_scope" => scope,
      "required_capability" => capability,
      "would_pass_gate3_authorized" => true
    }
  end

  def invocation_scope
    allowed_scope
  end

  def registry_check(registry, invocation)
    authority_ref = invocation.fetch("authority_ref")
    registry_entry = registry[authority_ref]
    return blocked("authority_registry.entry_missing", "registry_entry") unless registry_entry

    malformed = malformed_fields(registry_entry)
    return blocked("authority_registry.entry_malformed", "registry_entry", "missing" => malformed) unless malformed.empty?

    case registry_entry.fetch("status")
    when "active"
      return blocked("authority_registry.active_has_revocation", "registry_entry") if registry_entry["revoked_on"]
      return blocked("authority_registry.active_has_supersession", "registry_entry") if registry_entry["superseded_by"]
    when "revoked"
      return blocked("authority_registry.revoked_on_missing", "registry_entry") if registry_entry["revoked_on"].to_s == ""
      return blocked("authority_registry.revoked", "registry_entry", "revoked_on" => registry_entry["revoked_on"])
    when "superseded"
      return blocked("authority_registry.superseded_by_missing", "registry_entry") if registry_entry["superseded_by"].to_s == ""
      return blocked("authority_registry.superseded", "registry_entry", "superseded_by" => registry_entry["superseded_by"])
    else
      return blocked("authority_registry.status_unknown", "registry_entry", "status" => registry_entry["status"])
    end

    unless registry_entry.fetch("decision_doc_ref") == invocation["decision_doc_ref"]
      return blocked("authority_registry.signed_addendum_evidence_missing", "decision_doc_ref")
    end

    unless registry_entry.fetch("required_capability") == invocation["required_capability"]
      return blocked("authority_registry.required_capability_mismatch", "required_capability")
    end

    unless registry_entry.fetch("required_capability") == "history_read"
      return blocked("authority_registry.required_capability_not_phase1", "required_capability")
    end

    unless scope_matches?(registry_entry.fetch("allowed_scope"), invocation.fetch("requested_scope"))
      return blocked("authority_registry.scope_mismatch", "allowed_scope")
    end

    {
      "status" => "ok",
      "caller_may_pass_gate3_authorized" => true,
      "gate3_authorized_value" => true,
      "reason_code" => "authority_registry.active_scope_allowed",
      "authority_ref" => authority_ref,
      "decision_doc_ref" => registry_entry.fetch("decision_doc_ref"),
      "source_code_parity_authority_ref_unchanged" => authority_ref == AUTHORITY_REF,
      "production_signing" => false,
      "executor_called" => false
    }
  end

  def malformed_fields(registry_entry)
    required = %w[
      authority_ref status issued_on revoked_on superseded_by allowed_scope
      required_capability decision_doc_ref
    ]
    required.reject { |field| registry_entry.key?(field) }
  end

  def scope_matches?(allowed, requested)
    allowed == requested
  end

  def blocked(reason_code, stage, extra = {})
    {
      "status" => "blocked",
      "caller_may_pass_gate3_authorized" => false,
      "gate3_authorized_value" => false,
      "reason_code" => reason_code,
      "blocked_stage" => stage,
      "executor_called" => false,
      "production_signing" => false
    }.merge(extra)
  end

  def build_checks(cases)
    {
      "active_registry.allows_gate3_authorized" =>
        cases.dig("active_registry_allows_gate3_authorized", "caller_may_pass_gate3_authorized") == true,
      "active_registry.source_code_parity_uri_unchanged" =>
        cases.dig("active_registry_allows_gate3_authorized", "source_code_parity_authority_ref_unchanged") == true,
      "revoked.blocks" =>
        cases.dig("revoked_registry_blocks_before_caller_sets_true", "reason_code") == "authority_registry.revoked",
      "superseded.blocks" =>
        cases.dig("superseded_registry_blocks_before_caller_sets_true", "reason_code") == "authority_registry.superseded",
      "missing_entry.blocks" =>
        cases.dig("missing_registry_entry_blocks", "reason_code") == "authority_registry.entry_missing",
      "missing_signed_addendum_evidence.blocks" =>
        cases.dig("missing_signed_addendum_evidence_blocks", "reason_code") == "authority_registry.signed_addendum_evidence_missing",
      "wrong_scope.blocks" =>
        cases.dig("wrong_scope_blocks", "reason_code") == "authority_registry.scope_mismatch",
      "wrong_required_capability.blocks" =>
        cases.dig("wrong_required_capability_blocks", "reason_code") == "authority_registry.required_capability_mismatch",
      "malformed_entry.blocks" =>
        cases.dig("malformed_registry_entry_blocks", "reason_code") == "authority_registry.entry_malformed",
      "no_case_uses_signing_or_keys" =>
        cases.values.all? { |result| result["production_signing"] == false },
      "no_case_calls_executor" =>
        cases.values.all? { |result| result["executor_called"] == false }
    }
  end

  def write_json(path, value)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} gate3_authority_registry_shape"
    summary.fetch("checks").each { |name, ok| puts "  #{name}: #{ok ? "ok" : "FAIL"}" }
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

if $PROGRAM_NAME == __FILE__
  success = Gate3AuthorityRegistryShapeProof.run
  exit(success ? 0 : 1)
end
