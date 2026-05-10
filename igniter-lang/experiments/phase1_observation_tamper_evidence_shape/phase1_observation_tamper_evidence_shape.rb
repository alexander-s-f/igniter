#!/usr/bin/env ruby
# frozen_string_literal: true

# Card: S3-R24-C3-P
# Track: phase1-observation-tamper-evidence-shape-v0
#
# Extends the proof-local observation persistence shape (S3-R23-C1-P) with a
# tamper_evidence block containing:
#
#   sequence             — monotonic append counter (0-based)
#   previous_record_hash — SHA256 of the preceding record body; "genesis" for first
#   record_hash          — SHA256 of this record body (excluding record_hash itself)
#   storage_identity     — deterministic proof-local ID; binds records to one log
#   created_at           — ISO8601 proof timestamp
#
# The chain enables gap detection, reorder detection, and content-integrity
# verification without a Ledger, signing infrastructure, or production storage.
#
# Scope:
#   - proof-local file-backed JSONL only
#   - NOT production durable audit
#   - NOT Ledger, writes, replay, compact, subscribe
#   - NOT a compliance claim

require "digest"
require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang/temporal_access_runtime"
require_relative "../../lib/igniter_lang/temporal_executor"

module Phase1ObservationTamperEvidenceShape
  ROOT         = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT    = ROOT / "igniter-lang"
  ADDENDUM_PATH = LANG_ROOT / "docs/gates/gate3-live-read-decision-addendum-v0.md"
  OUT_DIR      = LANG_ROOT / "experiments/phase1_observation_tamper_evidence_shape/out"
  STORE_PATH   = OUT_DIR / "phase1_tamper_evident_store.jsonl"
  SUMMARY_PATH = OUT_DIR / "phase1_observation_tamper_evidence_shape_summary.json"

  AUTHORITY_REF    = IgniterLang::TemporalExecutor::GATE3_AUTHORITY_REF
  PROOF_AS_OF      = "2026-05-10T00:00:00Z"
  GENESIS_HASH     = "genesis"
  FORMAT_VERSION   = "0.2.0"
  ALLOWED_OPERATION = "append_observation_record"
  # Deterministic proof-local store identity — replaces SecureRandom.uuid so that
  # the JSONL artifact (including hash chain) is stable across reruns.
  # Production stores must use a runtime-generated UUID or infrastructure-bound identity.
  PROOF_STORAGE_IDENTITY = "proof-local/phase1-tamper-evidence-shape/#{PROOF_AS_OF}"

  # Extends ProofLocalObservationStore with a hash-linked tamper_evidence block.
  # Each appended record carries:
  #   - sequence / previous_record_hash / record_hash / storage_identity / created_at
  # Chain state (@sequence, @last_record_hash) is maintained in memory only —
  # consistent with proof-local use; not durable across process restarts.
  class TamperEvidentObservationStore
    attr_reader :storage_identity, :path

    def initialize(path, created_at:)
      @path             = path
      @created_at       = created_at
      @storage_identity = PROOF_STORAGE_IDENTITY
      @sequence         = 0
      @last_record_hash = GENESIS_HASH
      FileUtils.mkdir_p(path.dirname)
      File.write(path, "")
    end

    def persist(envelope, operation:, adapter_family:)
      return blocked("persistence.ledger_adapter_excluded",      operation, adapter_family) if adapter_family == "ledger"
      return blocked("persistence.phase1_operation_excluded",    operation, adapter_family) unless operation == ALLOWED_OPERATION

      missing = required_envelope_fields.reject { |f| envelope.key?(f) && !envelope[f].nil? }
      return blocked("persistence.envelope_missing_required_fields", operation, adapter_family, "missing" => missing) unless missing.empty?

      record        = build_record(envelope)
      emitted_hash  = record.dig("tamper_evidence", "record_hash")

      File.open(path, "a") { |f| f.write("#{JSON.generate(record)}\n") }

      @last_record_hash = emitted_hash
      @sequence         += 1

      {
        "status"               => "persisted",
        "kind"                 => "phase1_observation_persistence_receipt",
        "record_id"            => record.fetch("record_id"),
        "sequence"             => record.dig("tamper_evidence", "sequence"),
        "previous_record_hash" => record.dig("tamper_evidence", "previous_record_hash"),
        "record_hash"          => emitted_hash,
        "storage_identity"     => @storage_identity,
        "store_ref"            => path.basename.to_s,
        "operation"            => operation,
        "adapter_family"       => adapter_family,
        "production_durable_audit" => false,
        "ledger_write"         => false
      }
    end

    def line_count
      return 0 unless path.exist?

      path.readlines.size
    end

    def read_records
      return [] unless path.exist?

      path.readlines.map { |line| JSON.parse(line) }
    end

    private

    def required_envelope_fields
      %w[
        temporal_live_read_observation
        compatibility_report_ref
        authority_ref
        signed_addendum_ref
        backend_identity
        result
      ]
    end

    def build_record(envelope)
      # Build record body with tamper_evidence.record_hash = nil, compute hash, then fill it in.
      partial_te = {
        "sequence"             => @sequence,
        "previous_record_hash" => @last_record_hash,
        "record_hash"          => nil,
        "storage_identity"     => @storage_identity,
        "created_at"           => @created_at
      }
      partial = base_record(envelope).merge("tamper_evidence" => partial_te)
      hash    = record_hash(partial)
      partial.merge("tamper_evidence" => partial_te.merge("record_hash" => hash))
    end

    def base_record(envelope)
      {
        "kind"                           => "phase1_observation_persistence_record",
        "format_version"                 => FORMAT_VERSION,
        "record_id"                      => record_id(envelope),
        "persistence_mode"               => "proof_local_file",
        "persisted_at"                   => @created_at,
        "source_envelope_kind"           => envelope.fetch("kind"),
        "source_envelope_id"             => envelope.fetch("envelope_id"),
        "temporal_live_read_observation" => envelope.fetch("temporal_live_read_observation"),
        "compatibility_report_ref"       => envelope.fetch("compatibility_report_ref"),
        "authority_ref"                  => envelope.fetch("authority_ref"),
        "signed_addendum_ref"            => envelope.fetch("signed_addendum_ref"),
        "backend_identity"               => envelope.fetch("backend_identity"),
        "result"                         => envelope.fetch("result"),
        "caveat"                         => {
          "audit_ready"                 => true,
          "production_durable_audit"    => false,
          "production_compliance_claim" => false,
          "ledger"                      => false
        }
      }
    end

    # SHA256 of canonically sorted record body.
    # Sorting ensures the hash is deterministic regardless of Ruby Hash insertion order.
    def record_hash(record)
      Digest::SHA256.hexdigest(JSON.generate(canonical_sort(record)))
    end

    def canonical_sort(value)
      case value
      when Hash  then value.keys.sort.each_with_object({}) { |k, h| h[k] = canonical_sort(value[k]) }
      when Array then value.map { |v| canonical_sort(v) }
      else            value
      end
    end

    def record_id(envelope)
      "phase1/obs/#{Digest::SHA256.hexdigest(JSON.generate(envelope))[0, 20]}"
    end

    def blocked(reason_code, operation, adapter_family, extra = {})
      { "status"                 => "blocked",
        "kind"                   => "phase1_observation_persistence_refusal",
        "reason_code"            => reason_code,
        "operation"              => operation,
        "adapter_family"         => adapter_family,
        "production_durable_audit" => false,
        "ledger_write"           => false }.merge(extra)
    end
  end

  module_function

  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)

    executor = build_executor
    eval1    = executor.evaluate(history_contract, token: valid_token,
                                  inputs: { "sku" => "prod-001" }, as_of: PROOF_AS_OF)
    eval2    = executor.evaluate(history_contract, token: valid_token,
                                  inputs: { "sku" => "prod-002" }, as_of: PROOF_AS_OF)

    obs1 = executor.observations[0]
    obs2 = executor.observations[1]

    envelope1 = build_envelope(obs1, eval1)
    envelope2 = build_envelope(obs2, eval2)

    store    = TamperEvidentObservationStore.new(STORE_PATH, created_at: PROOF_AS_OF)
    receipt1 = store.persist(envelope1, operation: ALLOWED_OPERATION, adapter_family: "proof_local_file")
    receipt2 = store.persist(envelope2, operation: ALLOWED_OPERATION, adapter_family: "proof_local_file")

    blocked_cases = {
      "ledger"    => store.persist(envelope1, operation: ALLOWED_OPERATION, adapter_family: "ledger"),
      "write"     => store.persist(envelope1, operation: "write",     adapter_family: "proof_local_file"),
      "replay"    => store.persist(envelope1, operation: "replay",    adapter_family: "proof_local_file"),
      "compact"   => store.persist(envelope1, operation: "compact",   adapter_family: "proof_local_file"),
      "subscribe" => store.persist(envelope1, operation: "subscribe", adapter_family: "proof_local_file")
    }

    records = store.read_records
    checks  = build_checks(receipt1, receipt2, records, store, blocked_cases)
    status  = checks.values.all? ? "PASS" : "FAIL"

    summary = {
      "kind"           => "phase1_observation_tamper_evidence_shape_summary",
      "format_version" => "0.1.0",
      "card"           => "S3-R24-C3-P",
      "track"          => "phase1-observation-tamper-evidence-shape-v0",
      "status"         => status,
      "tamper_evidence_shape" => tamper_evidence_shape_descriptor,
      "checks"         => checks,
      "production_durable_audit_recommendation" => production_durable_audit_recommendation,
      "store"          => {
        "path"                    => STORE_PATH.relative_path_from(ROOT).to_s,
        "mode"                    => "proof_local_file",
        "production_durable_audit" => false,
        "production_compliance_claim" => false,
        "ledger"                  => false
      }
    }

    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    status == "PASS"
  end

  def build_checks(receipt1, receipt2, records, store, blocked_cases)
    r1  = records[0]
    r2  = records[1]
    te1 = r1&.fetch("tamper_evidence", nil)
    te2 = r2&.fetch("tamper_evidence", nil)

    {
      # Shape: tamper_evidence block has all five fields
      "shape.sequence_present"        => te1&.key?("sequence"),
      "shape.previous_hash_present"   => te1&.key?("previous_record_hash"),
      "shape.record_hash_present"     => te1&.key?("record_hash"),
      "shape.storage_identity_present" => te1&.key?("storage_identity"),
      "shape.created_at_present"      => te1&.key?("created_at"),

      # Chain: first record starts from genesis
      "chain.first_sequence_zero"     => te1&.fetch("sequence", nil) == 0,
      "chain.first_previous_genesis"  => te1&.fetch("previous_record_hash", nil) == GENESIS_HASH,

      # Chain: second record links to first
      "chain.second_sequence_one"     => te2&.fetch("sequence", nil) == 1,
      "chain.second_links_to_first"   => te2&.fetch("previous_record_hash", nil) ==
                                           te1&.fetch("record_hash", nil),

      # Storage identity is consistent across both records
      "chain.storage_identity_consistent" => te1&.fetch("storage_identity", nil) ==
                                               te2&.fetch("storage_identity", nil),

      # Receipt surfaces tamper-evidence fields
      "receipt.sequence_zero"         => receipt1.fetch("sequence", nil) == 0,
      "receipt.previous_genesis"      => receipt1.fetch("previous_record_hash", nil) == GENESIS_HASH,
      "receipt.record_hash_present"   => receipt1.fetch("record_hash", nil).is_a?(String) &&
                                           receipt1.fetch("record_hash").length == 64,

      # Content integrity: stored hash matches independently computed hash
      "integrity.r1_hash_verifiable"  => verify_record_hash(r1),
      "integrity.r2_hash_verifiable"  => verify_record_hash(r2),

      # Caveat preserved from S3-R23-C1-P shape
      "caveat.audit_ready"            => r1&.dig("caveat", "audit_ready") == true,
      "caveat.not_production_audit"   => r1&.dig("caveat", "production_durable_audit") == false,

      # Existing exclusions still enforced
      "excluded.ledger_blocked"       => blocked_cases["ledger"]["status"] == "blocked",
      "excluded.write_blocked"        => blocked_cases["write"]["status"] == "blocked",
      "excluded.replay_blocked"       => blocked_cases["replay"]["status"] == "blocked",
      "excluded.compact_blocked"      => blocked_cases["compact"]["status"] == "blocked",
      "excluded.subscribe_blocked"    => blocked_cases["subscribe"]["status"] == "blocked",

      # Only 2 records appended (excluded ops did not mutate the log)
      "chain.only_allowed_appended"   => store.line_count == 2
    }
  end

  # Recompute the record_hash independently to prove the stored value is correct.
  def verify_record_hash(record)
    return false unless record

    stored_hash = record.dig("tamper_evidence", "record_hash")
    return false unless stored_hash.is_a?(String)

    # Replace record_hash with nil, re-sort, re-hash
    partial = deep_merge(record, { "tamper_evidence" => { "record_hash" => nil } })
    expected = Digest::SHA256.hexdigest(JSON.generate(canonical_sort(partial)))
    stored_hash == expected
  end

  def deep_merge(base, override)
    base.merge(override) do |_k, old_v, new_v|
      old_v.is_a?(Hash) && new_v.is_a?(Hash) ? deep_merge(old_v, new_v) : new_v
    end
  end

  def canonical_sort(value)
    case value
    when Hash  then value.keys.sort.each_with_object({}) { |k, h| h[k] = canonical_sort(value[k]) }
    when Array then value.map { |v| canonical_sort(v) }
    else            value
    end
  end

  def build_executor
    backend = IgniterLang::TemporalAccessRuntime::MemoryBackend.new
    backend.seed_append_observations([
      { "subject" => "sku/prod-001/price", "valid_from" => "2026-01-01T00:00:00Z",
        "value" => "99.00", "value_type" => "String" },
      { "subject" => "sku/prod-002/price", "valid_from" => "2026-01-01T00:00:00Z",
        "value" => "49.00", "value_type" => "String" }
    ])
    IgniterLang::TemporalExecutor::Phase1.new(backend: backend, gate3_authorized: true)
  end

  def build_envelope(observation, evaluation)
    addendum_ref = ADDENDUM_PATH.relative_path_from(ROOT).to_s
    {
      "kind"                           => "audit_ready_temporal_read_envelope",
      "format_version"                 => "0.1.0",
      "envelope_id"                    => envelope_id(observation, evaluation),
      "export_mode"                    => "explicit",
      "audit_state"                    => "audit_ready_not_persisted",
      "temporal_live_read_observation" => observation,
      "compatibility_report_ref"       => evaluation.fetch("compatibility_report_id"),
      "authority_ref"                  => AUTHORITY_REF,
      "signed_addendum_ref"            => addendum_ref,
      "backend_identity"               => observation.fetch("backend_identity"),
      "result"                         => {
        "status"         => "allowed",
        "reason_code"    => IgniterLang::TemporalExecutor::ReasonCode::EVALUATION_READY,
        "result_present" => observation.fetch("result_present")
      },
      "storage" => {
        "automatic_persistence" => false,
        "durable_persistence"   => false,
        "ledger_write"          => false,
        "production_storage"    => false
      }
    }
  end

  def envelope_id(observation, evaluation)
    Digest::SHA256.hexdigest(
      JSON.generate([observation, evaluation.fetch("compatibility_report_id")])
    )[0, 20]
  end

  def valid_token
    { "kind"          => "executor_approval_token",
      "version"       => "executor-approval-token-v1",
      "token_id"      => "approval/tamper-evidence-shape",
      "authority_ref" => AUTHORITY_REF,
      "gate"          => "tbackend_gate3" }
  end

  def history_contract
    { "contract_id"    => "HistoryAxesTest",
      "fragment_class" => "temporal",
      "temporal_nodes" => [
        { "kind" => "temporal_input_node", "name" => "price_history",
          "store_ref" => "sku/{sku}/price" },
        { "kind" => "temporal_access_node", "name" => "price_at",
          "source_ref" => "price_history", "axis" => "valid_time",
          "as_of_ref" => "as_of" }
      ] }
  end

  def tamper_evidence_shape_descriptor
    {
      "block_name"      => "tamper_evidence",
      "format_version"  => FORMAT_VERSION,
      "fields"          => {
        "sequence"             => "Integer — 0-based append counter; gap detection",
        "previous_record_hash" => "String — SHA256 of previous record body; 'genesis' for first",
        "record_hash"          => "String — SHA256 of this record body (with record_hash=nil); content integrity",
        "storage_identity"     => "String — UUID fixed at store init; cross-log mixing detection",
        "created_at"           => "String — ISO8601 proof timestamp"
      },
      "hash_algorithm"  => "SHA256",
      "canonical_form"  => "JSON with recursively sorted keys (Ruby Hash#sort)",
      "chain_start"     => "previous_record_hash == 'genesis' for sequence 0",
      "scope"           => "proof-local file-backed JSONL only",
      "not_production"  => "not a cryptographic commitment; not production durable audit"
    }
  end

  def production_durable_audit_recommendation
    {
      "recommended_track" => "phase1-production-durable-audit-v0",
      "required_additions" => [
        "HSM or KMS signing key per record (replaces SHA256-only chain)",
        "retention policy and TTL specification",
        "replay semantics: ordered replay, idempotent re-read",
        "storage identity tied to infrastructure (not in-memory UUID)",
        "compliance language: GDPR/SOC2/PCI scope if applicable",
        "separate audit role: read-only audit accessor distinct from executor",
        "off-process persistence: not file-backed; dedicated audit store",
        "tamper detection alerting: gap/reorder detection wired to alerting surface"
      ],
      "pre_conditions" => [
        "gate3-live-read-decision-addendum-v0 issued and live reads unblocked",
        "phase1-backend-identity-guard-v0 closed (C-1)",
        "AT-10 persistence gap (R3) resolved with production store binding"
      ],
      "not_this_track" => [
        "production signing infrastructure",
        "Ledger integration",
        "write/replay/compact/subscribe operations",
        "compliance claims"
      ]
    }
  end

  def write_json(path, data)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "#{JSON.pretty_generate(data)}\n")
  end

  def print_summary(summary)
    status  = summary.fetch("status")
    checks  = summary.fetch("checks")
    total   = checks.size
    passed  = checks.values.count { |v| v }

    puts "#{status} phase1_observation_tamper_evidence_shape"
    checks.each { |name, ok| puts "  #{name}: #{ok ? 'ok' : 'FAIL'}" }
    puts "#{passed}/#{total} #{status}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

exit Phase1ObservationTamperEvidenceShape.run ? 0 : 1 if $PROGRAM_NAME == __FILE__
