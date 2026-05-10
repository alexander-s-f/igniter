#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang/temporal_executor"

module Gate3AuthorityRegistryV1ReceiptsShapeProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  ADDENDUM_PATH = LANG_ROOT / "docs/gates/gate3-live-read-decision-addendum-v0.md"
  DOCUMENT_PATH = "igniter-lang/docs/gates/gate3-live-read-decision-addendum-v0.md"
  OUT_DIR = LANG_ROOT / "experiments/gate3_authority_registry_v1_receipts_shape/out"
  SUMMARY_PATH = OUT_DIR / "gate3_authority_registry_v1_receipts_shape_summary.json"

  AUTHORITY_REF = IgniterLang::TemporalExecutor::GATE3_AUTHORITY_REF
  SUPERSEDING_AUTHORITY_REF =
    "architect-supervisor://igniter-lang/gates/gate3/runtime-temporal-executor/restricted-history-valid-time-v1/2026-05-10"

  module_function

  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)

    issued = issue(empty_registry, authority_entry)
    revoked = revoke(issued.fetch("registry"), AUTHORITY_REF, transition_decision_ref("revocation"))
    superseded = supersede(
      revoked.fetch("registry"),
      AUTHORITY_REF,
      SUPERSEDING_AUTHORITY_REF,
      transition_decision_ref("supersession")
    )

    cases = {
      "issuance_active" => issued,
      "revocation_blocks_authority" => revoked,
      "supersession_blocks_authority" => superseded,
      "issuance_without_content_ref_blocks" => issue(empty_registry, authority_entry(decision_ref: nil)),
      "revocation_from_missing_entry_blocks" => revoke(empty_registry, AUTHORITY_REF, transition_decision_ref("revocation")),
      "supersession_without_decision_ref_blocks" => supersede(
        revoked.fetch("registry"),
        AUTHORITY_REF,
        SUPERSEDING_AUTHORITY_REF,
        nil
      )
    }
    checks = build_checks(cases)
    summary = {
      "kind" => "gate3_authority_registry_v1_receipts_shape_summary",
      "format_version" => "0.1.0",
      "card" => "S3-R23-C2-P",
      "track" => "gate3-authority-registry-v1-receipts-shape-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "registry_entry_schema" => registry_entry_schema,
      "receipt_schema" => receipt_schema,
      "transition_chain" => {
        "issue" => issued.fetch("receipt"),
        "revoke" => revoked.fetch("receipt"),
        "supersede" => superseded.fetch("receipt")
      },
      "final_entry" => superseded.fetch("registry").fetch(AUTHORITY_REF),
      "cases" => cases,
      "checks" => checks,
      "non_authorization" => {
        "proof_local" => true,
        "production_signing" => false,
        "production_key_management" => false,
        "temporal_executor_called" => false,
        "phase2_ledger_adapter" => false
      }
    }

    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def empty_registry
    {}
  end

  def authority_entry(decision_ref: signed_addendum_ref)
    {
      "authority_ref" => AUTHORITY_REF,
      "registry_version" => "gate3_authority_registry.v1",
      "status" => "draft",
      "issued_on" => nil,
      "revoked_on" => nil,
      "superseded_on" => nil,
      "superseded_by" => nil,
      "allowed_scope" => allowed_scope,
      "required_capability" => "history_read",
      "decision_ref" => decision_ref,
      "receipt_refs" => {
        "issuance" => nil,
        "revocation" => nil,
        "supersession" => nil
      }
    }
  end

  def issue(registry, entry)
    return blocked("registry_v1.decision_ref_missing", "issuance") unless content_ref?(entry["decision_ref"])

    next_entry = entry.merge(
      "status" => "active",
      "issued_on" => "2026-05-09"
    )
    receipt = receipt(
      transition: "issuance",
      authority_ref: next_entry.fetch("authority_ref"),
      from_status: nil,
      to_status: "active",
      occurred_on: "2026-05-09",
      decision_ref: next_entry.fetch("decision_ref")
    )
    next_entry = attach_receipt(next_entry, "issuance", receipt)
    {
      "status" => "ok",
      "registry" => registry.merge(next_entry.fetch("authority_ref") => next_entry),
      "entry" => next_entry,
      "receipt" => receipt,
      "caller_may_pass_gate3_authorized" => true,
      "executor_called" => false
    }
  end

  def revoke(registry, authority_ref, decision_ref)
    entry = registry[authority_ref]
    return blocked("registry_v1.entry_missing", "revocation") unless entry
    return blocked("registry_v1.revocation_requires_active", "revocation", "from_status" => entry["status"]) unless entry["status"] == "active"
    return blocked("registry_v1.decision_ref_missing", "revocation") unless content_ref?(decision_ref)

    next_entry = entry.merge(
      "status" => "revoked",
      "revoked_on" => "2026-05-10"
    )
    receipt = receipt(
      transition: "revocation",
      authority_ref: authority_ref,
      from_status: "active",
      to_status: "revoked",
      occurred_on: "2026-05-10",
      decision_ref: decision_ref,
      caused_by_ref: entry.dig("receipt_refs", "issuance")
    )
    next_entry = attach_receipt(next_entry, "revocation", receipt)
    {
      "status" => "ok",
      "registry" => registry.merge(authority_ref => next_entry),
      "entry" => next_entry,
      "receipt" => receipt,
      "caller_may_pass_gate3_authorized" => false,
      "reason_code" => "authority_registry.revoked",
      "executor_called" => false
    }
  end

  def supersede(registry, authority_ref, superseded_by, decision_ref)
    entry = registry[authority_ref]
    return blocked("registry_v1.entry_missing", "supersession") unless entry
    return blocked("registry_v1.supersession_requires_revoked", "supersession", "from_status" => entry["status"]) unless entry["status"] == "revoked"
    return blocked("registry_v1.decision_ref_missing", "supersession") unless content_ref?(decision_ref)

    next_entry = entry.merge(
      "status" => "superseded",
      "superseded_on" => "2026-05-10",
      "superseded_by" => superseded_by
    )
    receipt = receipt(
      transition: "supersession",
      authority_ref: authority_ref,
      from_status: "revoked",
      to_status: "superseded",
      occurred_on: "2026-05-10",
      decision_ref: decision_ref,
      caused_by_ref: entry.dig("receipt_refs", "revocation"),
      superseded_by: superseded_by
    )
    next_entry = attach_receipt(next_entry, "supersession", receipt)
    {
      "status" => "ok",
      "registry" => registry.merge(authority_ref => next_entry),
      "entry" => next_entry,
      "receipt" => receipt,
      "caller_may_pass_gate3_authorized" => false,
      "reason_code" => "authority_registry.superseded",
      "executor_called" => false
    }
  end

  def receipt(transition:, authority_ref:, from_status:, to_status:, occurred_on:, decision_ref:, caused_by_ref: nil, superseded_by: nil)
    body = {
      "kind" => "gate3_authority_registry_transition_receipt",
      "receipt_version" => "0.1.0",
      "transition" => transition,
      "authority_ref" => authority_ref,
      "from_status" => from_status,
      "to_status" => to_status,
      "occurred_on" => occurred_on,
      "decision_ref" => decision_ref,
      "caused_by_ref" => caused_by_ref,
      "superseded_by" => superseded_by,
      "production_signing" => false,
      "production_key_management" => false
    }
    body.merge("receipt_id" => "receipt/gate3-authority/#{short_hash(body)}")
  end

  def attach_receipt(entry, slot, receipt)
    refs = entry.fetch("receipt_refs").merge(slot => receipt.fetch("receipt_id"))
    entry.merge("receipt_refs" => refs)
  end

  def signed_addendum_ref
    {
      "document_path" => DOCUMENT_PATH,
      "git_commit" => ENV.fetch("GIT_COMMIT", "workspace-current"),
      "content_sha256" => content_sha256(ADDENDUM_PATH),
      "status" => "signed-approved-restricted-phase1-live-read",
      "signed_on" => "2026-05-09",
      "authority_ref" => AUTHORITY_REF
    }
  end

  def transition_decision_ref(name)
    payload = {
      "kind" => "proof_local_gate3_authority_registry_transition_decision",
      "name" => name,
      "authority_ref" => AUTHORITY_REF,
      "date" => "2026-05-10"
    }
    {
      "document_path" => "proof-local://gate3-authority-registry-v1/#{name}",
      "git_commit" => ENV.fetch("GIT_COMMIT", "workspace-current"),
      "content_sha256" => "sha256:#{Digest::SHA256.hexdigest(JSON.generate(canonical(payload)))}",
      "status" => "proof-local",
      "signed_on" => nil,
      "authority_ref" => AUTHORITY_REF
    }
  end

  def content_ref?(value)
    value.is_a?(Hash) &&
      value["document_path"].to_s != "" &&
      value["git_commit"].to_s != "" &&
      value["content_sha256"].to_s.start_with?("sha256:") &&
      value["authority_ref"] == AUTHORITY_REF
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

  def registry_entry_schema
    {
      "authority_ref" => "string",
      "registry_version" => "gate3_authority_registry.v1",
      "status" => "draft|active|revoked|superseded",
      "issued_on" => "YYYY-MM-DD|null",
      "revoked_on" => "YYYY-MM-DD|null",
      "superseded_on" => "YYYY-MM-DD|null",
      "superseded_by" => "authority_ref|null",
      "allowed_scope" => allowed_scope,
      "required_capability" => "history_read",
      "decision_ref" => "content-addressed signed addendum or transition decision ref",
      "receipt_refs" => {
        "issuance" => "receipt id|null",
        "revocation" => "receipt id|null",
        "supersession" => "receipt id|null"
      }
    }
  end

  def receipt_schema
    {
      "kind" => "gate3_authority_registry_transition_receipt",
      "receipt_version" => "0.1.0",
      "transition" => "issuance|revocation|supersession",
      "authority_ref" => "string",
      "from_status" => "status|null",
      "to_status" => "status",
      "occurred_on" => "YYYY-MM-DD",
      "decision_ref" => "content-addressed ref",
      "caused_by_ref" => "prior receipt id|null",
      "superseded_by" => "authority_ref|null",
      "receipt_id" => "content-derived receipt id",
      "production_signing" => false,
      "production_key_management" => false
    }
  end

  def build_checks(cases)
    issued = cases.fetch("issuance_active")
    revoked = cases.fetch("revocation_blocks_authority")
    superseded = cases.fetch("supersession_blocks_authority")
    {
      "issuance.active" =>
        issued.dig("entry", "status") == "active" &&
          issued.dig("receipt", "transition") == "issuance",
      "issuance.has_content_addressed_decision_ref" =>
        content_ref?(issued.dig("receipt", "decision_ref")),
      "revocation.revoked" =>
        revoked.dig("entry", "status") == "revoked" &&
          revoked.dig("caller_may_pass_gate3_authorized") == false,
      "revocation.receipt_links_issuance" =>
        revoked.dig("receipt", "caused_by_ref") == issued.dig("receipt", "receipt_id"),
      "supersession.superseded" =>
        superseded.dig("entry", "status") == "superseded" &&
          superseded.dig("entry", "superseded_by") == SUPERSEDING_AUTHORITY_REF,
      "supersession.receipt_links_revocation" =>
        superseded.dig("receipt", "caused_by_ref") == revoked.dig("receipt", "receipt_id"),
      "issuance_without_content_ref.blocks" =>
        cases.dig("issuance_without_content_ref_blocks", "reason_code") == "registry_v1.decision_ref_missing",
      "revocation_from_missing_entry.blocks" =>
        cases.dig("revocation_from_missing_entry_blocks", "reason_code") == "registry_v1.entry_missing",
      "supersession_without_decision_ref.blocks" =>
        cases.dig("supersession_without_decision_ref_blocks", "reason_code") == "registry_v1.decision_ref_missing",
      "no_case_uses_production_signing_or_keys" =>
        cases.values.all? { |result| receipts(result).all? { |r| r["production_signing"] == false && r["production_key_management"] == false } },
      "no_case_calls_executor" =>
        cases.values.all? { |result| result.fetch("executor_called", false) == false }
    }
  end

  def receipts(result)
    [result["receipt"]].compact
  end

  def blocked(reason_code, stage, extra = {})
    {
      "status" => "blocked",
      "reason_code" => reason_code,
      "blocked_stage" => stage,
      "caller_may_pass_gate3_authorized" => false,
      "executor_called" => false,
      "production_signing" => false,
      "production_key_management" => false
    }.merge(extra)
  end

  def content_sha256(path)
    "sha256:#{Digest::SHA256.file(path).hexdigest}"
  end

  def short_hash(value)
    Digest::SHA256.hexdigest(JSON.generate(canonical(value)))[0, 16]
  end

  def canonical(value)
    case value
    when Hash
      value.keys.sort_by(&:to_s).each_with_object({}) { |key, out| out[key.to_s] = canonical(value[key]) }
    when Array
      value.map { |item| canonical(item) }
    else
      value
    end
  end

  def write_json(path, value)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} gate3_authority_registry_v1_receipts_shape"
    summary.fetch("checks").each { |name, ok| puts "  #{name}: #{ok ? "ok" : "FAIL"}" }
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

if $PROGRAM_NAME == __FILE__
  success = Gate3AuthorityRegistryV1ReceiptsShapeProof.run
  exit(success ? 0 : 1)
end
