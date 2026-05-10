#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"
require "time"

require_relative "../../lib/igniter_lang/temporal_executor"

module Phase1DurableRegistryStorageSemanticsProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  ADDENDUM_PATH = LANG_ROOT / "docs/gates/gate3-live-read-decision-addendum-v0.md"
  DOCUMENT_PATH = "igniter-lang/docs/gates/gate3-live-read-decision-addendum-v0.md"
  OUT_DIR = LANG_ROOT / "experiments/phase1_durable_registry_storage_semantics/out"
  SUMMARY_PATH = OUT_DIR / "phase1_durable_registry_storage_semantics_summary.json"

  AUTHORITY_REF = IgniterLang::TemporalExecutor::GATE3_AUTHORITY_REF
  SUPERSEDING_AUTHORITY_REF =
    "architect-supervisor://igniter-lang/gates/gate3/runtime-temporal-executor/restricted-history-valid-time-v1/2026-05-11"

  module_function

  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)

    store = new_store
    issued = issue(store, authority_entry, effective_at: "2026-05-09T00:00:00Z")
    active_query = query(store, AUTHORITY_REF, at: "2026-05-09T12:00:00Z")
    revoked = revoke(store, AUTHORITY_REF, decision_ref("revocation"), effective_at: "2026-05-10T00:00:00Z")
    revoked_query = query(store, AUTHORITY_REF, at: "2026-05-10T12:00:00Z")
    superseded = supersede(store, AUTHORITY_REF, SUPERSEDING_AUTHORITY_REF, decision_ref("supersession"), effective_at: "2026-05-11T00:00:00Z")
    superseded_query = query(store, AUTHORITY_REF, at: "2026-05-11T12:00:00Z")
    chain = verify_receipt_chain(store, AUTHORITY_REF)

    direct_store = new_store
    issue(direct_store, authority_entry, effective_at: "2026-05-09T00:00:00Z")
    direct_supersede = supersede(direct_store, AUTHORITY_REF, SUPERSEDING_AUTHORITY_REF, decision_ref("supersession"), effective_at: "2026-05-10T00:00:00Z")

    mismatch_store = new_store
    seed_mismatched_content_ref_entry(mismatch_store)
    mismatch_chain = verify_receipt_chain(mismatch_store, AUTHORITY_REF)

    cases = {
      "storage_identity" => store_identity_check(store),
      "query_active_by_authority_ref" => active_query,
      "query_revoked_after_effective_time" => revoked_query,
      "query_superseded_after_effective_time" => superseded_query,
      "receipt_chain_verified" => chain,
      "content_address_mismatch_blocks_verification" => mismatch_chain,
      "direct_active_to_superseded_blocked" => direct_supersede,
      "missing_authority_ref_query_blocks" => query(store, "missing-authority", at: "2026-05-09T12:00:00Z"),
      "transition_results" => {
        "issuance" => issued,
        "revocation" => revoked,
        "supersession" => superseded
      }
    }
    checks = build_checks(cases)
    summary = {
      "kind" => "phase1_durable_registry_storage_semantics_summary",
      "format_version" => "0.1.0",
      "card" => "S3-R24-C2-P",
      "track" => "phase1-durable-registry-storage-semantics-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "durable_registry_service_semantics" => service_semantics,
      "state_machine" => state_machine,
      "storage_schema" => storage_schema,
      "cases" => cases,
      "checks" => checks,
      "non_authorization" => {
        "proof_local_only" => true,
        "production_signing" => false,
        "production_key_management" => false,
        "ledger_binding" => false,
        "temporal_executor_called" => false
      }
    }

    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def new_store
    {
      "storage_identity" => {
        "kind" => "proof_local_gate3_authority_registry_store",
        "storage_id" => "registry/gate3/phase1/proof-local",
        "schema_version" => "gate3_authority_registry_storage.v0",
        "durability_model" => "proof_local_file_backed_fixture",
        "production_signing" => false,
        "ledger_binding" => false
      },
      "entries" => {},
      "receipts" => {}
    }
  end

  def authority_entry(decision_ref: signed_addendum_ref)
    {
      "authority_ref" => AUTHORITY_REF,
      "registry_version" => "gate3_authority_registry.v1",
      "status" => "draft",
      "issued_at" => nil,
      "revoked_at" => nil,
      "superseded_at" => nil,
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

  def issue(store, entry, effective_at:)
    return blocked("storage.content_address_decision_ref_invalid", "issuance") unless content_ref_valid?(entry["decision_ref"])

    receipt = transition_receipt(
      transition: "issuance",
      authority_ref: entry.fetch("authority_ref"),
      from_status: nil,
      to_status: "active",
      effective_at: effective_at,
      decision_ref: entry.fetch("decision_ref")
    )
    next_entry = entry.merge(
      "status" => "active",
      "issued_at" => effective_at,
      "receipt_refs" => entry.fetch("receipt_refs").merge("issuance" => receipt.fetch("receipt_id"))
    )
    store.fetch("entries")[entry.fetch("authority_ref")] = next_entry
    store.fetch("receipts")[receipt.fetch("receipt_id")] = receipt
    ok_transition(next_entry, receipt)
  end

  def revoke(store, authority_ref, decision_ref, effective_at:)
    entry = store.fetch("entries")[authority_ref]
    return blocked("storage.authority_ref_missing", "revocation") unless entry
    return blocked("storage.revocation_requires_active", "revocation", "from_status" => entry["status"]) unless status_at(entry, effective_at) == "active"
    return blocked("storage.content_address_decision_ref_invalid", "revocation") unless content_ref_valid?(decision_ref)

    receipt = transition_receipt(
      transition: "revocation",
      authority_ref: authority_ref,
      from_status: "active",
      to_status: "revoked",
      effective_at: effective_at,
      decision_ref: decision_ref,
      caused_by_ref: entry.dig("receipt_refs", "issuance")
    )
    next_entry = entry.merge(
      "status" => "revoked",
      "revoked_at" => effective_at,
      "receipt_refs" => entry.fetch("receipt_refs").merge("revocation" => receipt.fetch("receipt_id"))
    )
    store.fetch("entries")[authority_ref] = next_entry
    store.fetch("receipts")[receipt.fetch("receipt_id")] = receipt
    ok_transition(next_entry, receipt, caller_may_pass: false, reason_code: "authority_registry.revoked")
  end

  def supersede(store, authority_ref, superseded_by, decision_ref, effective_at:)
    entry = store.fetch("entries")[authority_ref]
    return blocked("storage.authority_ref_missing", "supersession") unless entry
    return blocked("storage.supersession_requires_revoked", "supersession", "from_status" => entry["status"]) unless status_at(entry, effective_at) == "revoked"
    return blocked("storage.content_address_decision_ref_invalid", "supersession") unless content_ref_valid?(decision_ref)

    receipt = transition_receipt(
      transition: "supersession",
      authority_ref: authority_ref,
      from_status: "revoked",
      to_status: "superseded",
      effective_at: effective_at,
      decision_ref: decision_ref,
      caused_by_ref: entry.dig("receipt_refs", "revocation"),
      superseded_by: superseded_by
    )
    next_entry = entry.merge(
      "status" => "superseded",
      "superseded_at" => effective_at,
      "superseded_by" => superseded_by,
      "receipt_refs" => entry.fetch("receipt_refs").merge("supersession" => receipt.fetch("receipt_id"))
    )
    store.fetch("entries")[authority_ref] = next_entry
    store.fetch("receipts")[receipt.fetch("receipt_id")] = receipt
    ok_transition(next_entry, receipt, caller_may_pass: false, reason_code: "authority_registry.superseded")
  end

  def query(store, authority_ref, at:)
    entry = store.fetch("entries")[authority_ref]
    return blocked("storage.authority_ref_missing", "query") unless entry

    status = status_at(entry, at)
    {
      "status" => "ok",
      "authority_ref" => authority_ref,
      "query_at" => at,
      "lookup_status" => status,
      "caller_may_pass_gate3_authorized" => status == "active",
      "effective_times" => {
        "issued_at" => entry["issued_at"],
        "revoked_at" => entry["revoked_at"],
        "superseded_at" => entry["superseded_at"]
      },
      "receipt_refs" => entry.fetch("receipt_refs"),
      "executor_called" => false
    }
  end

  def verify_receipt_chain(store, authority_ref)
    entry = store.fetch("entries")[authority_ref]
    return blocked("storage.authority_ref_missing", "verify_receipt_chain") unless entry
    return blocked("storage.content_address_decision_ref_invalid", "verify_receipt_chain") unless content_ref_valid?(entry["decision_ref"])

    refs = entry.fetch("receipt_refs")
    issuance = store.fetch("receipts")[refs["issuance"]]
    revocation = store.fetch("receipts")[refs["revocation"]]
    supersession = store.fetch("receipts")[refs["supersession"]]
    return blocked("storage.issuance_receipt_missing", "verify_receipt_chain") unless issuance
    return blocked("storage.revocation_receipt_missing", "verify_receipt_chain") if entry["revoked_at"] && !revocation
    return blocked("storage.supersession_receipt_missing", "verify_receipt_chain") if entry["superseded_at"] && !supersession
    return blocked("storage.receipt_chain_broken", "verify_receipt_chain") if revocation && revocation["caused_by_ref"] != issuance["receipt_id"]
    return blocked("storage.receipt_chain_broken", "verify_receipt_chain") if supersession && supersession["caused_by_ref"] != revocation["receipt_id"]

    receipts = [issuance, revocation, supersession].compact
    invalid_ref = receipts.find { |receipt| !content_ref_valid?(receipt["decision_ref"]) }
    return blocked("storage.receipt_decision_ref_invalid", "verify_receipt_chain", "receipt_id" => invalid_ref["receipt_id"]) if invalid_ref

    {
      "status" => "ok",
      "authority_ref" => authority_ref,
      "verified" => true,
      "receipt_count" => receipts.length,
      "receipt_ids" => receipts.map { |receipt| receipt.fetch("receipt_id") },
      "content_addressed_decision_refs_verified" => true,
      "executor_called" => false
    }
  end

  def status_at(entry, timestamp)
    t = Time.iso8601(timestamp)
    return "superseded" if entry["superseded_at"] && Time.iso8601(entry["superseded_at"]) <= t
    return "revoked" if entry["revoked_at"] && Time.iso8601(entry["revoked_at"]) <= t
    return "active" if entry["issued_at"] && Time.iso8601(entry["issued_at"]) <= t

    "draft"
  end

  def ok_transition(entry, receipt, caller_may_pass: true, reason_code: "authority_registry.active")
    {
      "status" => "ok",
      "entry" => entry,
      "receipt" => receipt,
      "caller_may_pass_gate3_authorized" => caller_may_pass,
      "reason_code" => reason_code,
      "executor_called" => false
    }
  end

  def transition_receipt(transition:, authority_ref:, from_status:, to_status:, effective_at:, decision_ref:, caused_by_ref: nil, superseded_by: nil)
    body = {
      "kind" => "gate3_authority_registry_storage_transition_receipt",
      "receipt_version" => "0.1.0",
      "transition" => transition,
      "authority_ref" => authority_ref,
      "from_status" => from_status,
      "to_status" => to_status,
      "effective_at" => effective_at,
      "decision_ref" => decision_ref,
      "caused_by_ref" => caused_by_ref,
      "superseded_by" => superseded_by,
      "production_signing" => false,
      "production_key_management" => false,
      "ledger_binding" => false
    }
    body.merge("receipt_id" => "receipt/gate3-registry-storage/#{short_hash(body)}")
  end

  def seed_mismatched_content_ref_entry(store)
    bad_ref = signed_addendum_ref.merge("content_sha256" => "sha256:#{'0' * 64}")
    entry = authority_entry(decision_ref: bad_ref).merge(
      "status" => "active",
      "issued_at" => "2026-05-09T00:00:00Z"
    )
    receipt = transition_receipt(
      transition: "issuance",
      authority_ref: AUTHORITY_REF,
      from_status: nil,
      to_status: "active",
      effective_at: "2026-05-09T00:00:00Z",
      decision_ref: bad_ref
    )
    store.fetch("entries")[AUTHORITY_REF] = entry.merge(
      "receipt_refs" => entry.fetch("receipt_refs").merge("issuance" => receipt.fetch("receipt_id"))
    )
    store.fetch("receipts")[receipt.fetch("receipt_id")] = receipt
  end

  def store_identity_check(store)
    identity = store.fetch("storage_identity")
    {
      "status" => "ok",
      "storage_id" => identity.fetch("storage_id"),
      "schema_version" => identity.fetch("schema_version"),
      "queryable_by_authority_ref" => true,
      "durable_semantics" => "proof_local_file_backed_fixture",
      "production_signing" => identity.fetch("production_signing"),
      "ledger_binding" => identity.fetch("ledger_binding")
    }
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

  def decision_ref(name)
    payload = {
      "kind" => "proof_local_gate3_registry_storage_transition_decision",
      "name" => name,
      "authority_ref" => AUTHORITY_REF,
      "date" => "2026-05-10"
    }
    {
      "document_path" => "proof-local://gate3-registry-storage/#{name}",
      "git_commit" => ENV.fetch("GIT_COMMIT", "workspace-current"),
      "content_sha256" => "sha256:#{Digest::SHA256.hexdigest(JSON.generate(canonical(payload)))}",
      "status" => "proof-local",
      "signed_on" => nil,
      "authority_ref" => AUTHORITY_REF
    }
  end

  def content_ref_valid?(value)
    return false unless value.is_a?(Hash)
    return false unless value["document_path"].to_s != ""
    return false unless value["git_commit"].to_s != ""
    return false unless value["content_sha256"].to_s.start_with?("sha256:")
    return false unless value["authority_ref"] == AUTHORITY_REF
    return false if value["document_path"] == DOCUMENT_PATH && value["content_sha256"] != content_sha256(ADDENDUM_PATH)

    true
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

  def service_semantics
    {
      "storage_identity_required" => true,
      "query_by_authority_ref" => true,
      "effective_time_lookup" => true,
      "receipt_chain_verification" => true,
      "content_addressed_decision_ref_verification" => true,
      "active_to_superseded_direct_transition_allowed" => false,
      "supersession_requires_revocation_first" => true
    }
  end

  def state_machine
    {
      "draft" => ["active"],
      "active" => ["revoked"],
      "revoked" => ["superseded"],
      "superseded" => []
    }
  end

  def storage_schema
    {
      "storage_identity" => {
        "kind" => "proof_local_gate3_authority_registry_store",
        "storage_id" => "stable store identifier",
        "schema_version" => "gate3_authority_registry_storage.v0",
        "durability_model" => "proof_local|production_later"
      },
      "entries" => {
        "<authority_ref>" => "registry v1 entry with issued_at/revoked_at/superseded_at"
      },
      "receipts" => {
        "<receipt_id>" => "transition receipt"
      }
    }
  end

  def build_checks(cases)
    {
      "storage_identity.present" =>
        cases.dig("storage_identity", "storage_id") == "registry/gate3/phase1/proof-local" &&
          cases.dig("storage_identity", "queryable_by_authority_ref") == true,
      "query.active_by_authority_ref" =>
        cases.dig("query_active_by_authority_ref", "lookup_status") == "active" &&
          cases.dig("query_active_by_authority_ref", "caller_may_pass_gate3_authorized") == true,
      "query.revoked_after_effective_time" =>
        cases.dig("query_revoked_after_effective_time", "lookup_status") == "revoked" &&
          cases.dig("query_revoked_after_effective_time", "caller_may_pass_gate3_authorized") == false,
      "query.superseded_after_effective_time" =>
        cases.dig("query_superseded_after_effective_time", "lookup_status") == "superseded" &&
          cases.dig("query_superseded_after_effective_time", "caller_may_pass_gate3_authorized") == false,
      "receipt_chain.verified" =>
        cases.dig("receipt_chain_verified", "verified") == true &&
          cases.dig("receipt_chain_verified", "receipt_count") == 3,
      "content_address_mismatch.blocks" =>
        cases.dig("content_address_mismatch_blocks_verification", "reason_code") == "storage.content_address_decision_ref_invalid",
      "direct_active_to_superseded.blocked" =>
        cases.dig("direct_active_to_superseded_blocked", "reason_code") == "storage.supersession_requires_revoked",
      "missing_authority_ref.blocks" =>
        cases.dig("missing_authority_ref_query_blocks", "reason_code") == "storage.authority_ref_missing",
      "no_case_uses_signing_or_ledger" =>
        cases.values.all? { |result| no_signing_or_ledger?(result) },
      "no_case_calls_executor" =>
        cases.values.all? { |result| no_executor_call?(result) }
    }
  end

  def no_signing_or_ledger?(value)
    case value
    when Hash
      return false if value["production_signing"] == true || value["production_key_management"] == true || value["ledger_binding"] == true

      value.values.all? { |child| no_signing_or_ledger?(child) }
    when Array
      value.all? { |child| no_signing_or_ledger?(child) }
    else
      true
    end
  end

  def no_executor_call?(value)
    case value
    when Hash
      return false if value["executor_called"] == true

      value.values.all? { |child| no_executor_call?(child) }
    when Array
      value.all? { |child| no_executor_call?(child) }
    else
      true
    end
  end

  def blocked(reason_code, stage, extra = {})
    {
      "status" => "blocked",
      "reason_code" => reason_code,
      "blocked_stage" => stage,
      "caller_may_pass_gate3_authorized" => false,
      "executor_called" => false,
      "production_signing" => false,
      "production_key_management" => false,
      "ledger_binding" => false
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
    puts "#{summary.fetch("status")} phase1_durable_registry_storage_semantics"
    summary.fetch("checks").each { |name, ok| puts "  #{name}: #{ok ? "ok" : "FAIL"}" }
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

if $PROGRAM_NAME == __FILE__
  success = Phase1DurableRegistryStorageSemanticsProof.run
  exit(success ? 0 : 1)
end
