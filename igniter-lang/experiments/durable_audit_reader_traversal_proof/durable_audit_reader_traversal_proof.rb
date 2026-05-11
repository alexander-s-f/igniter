# frozen_string_literal: true

# =============================================================================
# S3-R34-C1-P — Durable Audit Reader / Traversal Proof (B-B)
# Track: durable-audit-reader-traversal-proof-v0
# Role:  implementation-agent
# Auth:  architect-supervisor://igniter-lang/gates/phase1-production-durable-audit/bounded-implementation-v0/2026-05-10
#
# This proof is PROOF-LOCAL ONLY.
#   production_durable_audit: false
#   gate3_authorized: false
#   ledger: false
#   RuntimeMachine binding: false
#
# Non-authorizations (explicit):
#   - No writes, replay, compact, or subscribe on AuditReader
#   - No Ledger / Phase 2 / BiHistory
#   - No stream / OLAP / production cache
#   - No HSM / KMS integration
#   - No broad RuntimeMachine scheduler binding
#   - No .igapp manifest changes
#   - No lib/ changes
#
# Answers: [D1] Full chain verification runs on ALL records; output filters apply
#          after verification. [D2] compliant_export true only when zero integrity
#          failures, zero posture mismatches, and at least one verified record.
#          [D3] Reader role is "phase1_audit_reader"; all mutating / authorizing
#          operations return audit.reader.unauthorized.
#          [D4] Posture-mismatch records are reported separately and excluded from
#          verified_records.
# =============================================================================

require "json"
require "digest"
require_relative "../production_durable_audit_bounded_implementation_proof/" \
                 "production_durable_audit_bounded_implementation_proof"

Impl   = ProductionDurableAuditBoundedImplementationProof
Schema = Impl::Phase1ProductionAuditRecordSchema
Store  = Impl::Phase1ProductionAuditStore

READER_PROOF_TIMESTAMP = "2026-05-11T00:00:00Z"
READER_AUTHORIZATION_REF =
  "architect-supervisor://igniter-lang/gates/phase1-production-durable-audit/" \
  "bounded-implementation-v0/2026-05-10"

# =============================================================================
# AuditReader — proof-local reader/traversal implementation
# =============================================================================

class AuditReader
  ROLE = "phase1_audit_reader"

  # Refusal codes
  UNAUTHORIZED_OP   = "audit.reader.unauthorized"
  INTEGRITY_FAIL    = "audit.record.integrity_failure"
  POSTURE_MISMATCH  = "audit.record.compliance_posture_mismatch"

  def initialize(store)
    @store = store
    @role  = ROLE
  end

  attr_reader :role

  # -------------------------------------------------------------------------
  # traverse — main reader surface
  #
  # Performs full chain verification on ALL records in the store, then
  # filters the output by sequence_range and/or record_kind.
  # Posture is re-derived for every record (R32 D3).
  #
  # Returns:
  #   {
  #     role:                ROLE,
  #     total_scanned:       Integer,
  #     verified_records:    Array<Hash>,   # passed integrity + posture
  #     integrity_failures:  Array<Hash>,   # { sequence:, code:, detail: }
  #     posture_mismatches:  Array<Hash>,   # { sequence:, stored:, derived: }
  #     compliant_export:    Boolean,       # D2
  #     production_durable_audit: false,
  #     gate3_authorized:    false
  #   }
  # -------------------------------------------------------------------------
  def traverse(sequence_range: nil, record_kind: nil)
    all_records = @store.records

    verified       = []
    int_failures   = []
    pos_mismatches = []
    prior_record   = nil          # always updated to current record (matches rebuild pattern)
    first_storage_id = nil

    all_records.each_with_index do |record, idx|
      seq = record.dig("chain", "sequence") || (idx + 1)

      # --- Step 1: format_version + kind ----------------------------------------
      unless record["format_version"] == "1.0.0" &&
             record["kind"] == "phase1_production_audit_record"
        int_failures << { "sequence" => seq,
                          "code"     => INTEGRITY_FAIL,
                          "detail"   => "format_version or kind invalid" }
        prior_record = record
        next
      end

      # --- Step 2: storage_identity consistency ---------------------------------
      sid = record["storage_identity"] || {}
      sid_val = sid["storage_id"].to_s
      if first_storage_id.nil?
        first_storage_id = sid_val
      elsif sid_val != first_storage_id
        int_failures << { "sequence" => seq,
                          "code"     => INTEGRITY_FAIL,
                          "detail"   => "storage_identity mismatch: expected #{first_storage_id.inspect}, got #{sid_val.inspect}" }
        prior_record = record
        next
      end

      # --- Step 3: prev_hash chain continuity -----------------------------------
      # Genesis record: previous_record_hash must be "genesis"
      # All others: must match the stored record_hash of the prior record
      stored_prev   = record.dig("chain", "previous_record_hash").to_s
      expected_prev = idx.zero? ? "genesis"
                                : prior_record.dig("chain", "record_hash").to_s
      unless stored_prev == expected_prev
        int_failures << { "sequence" => seq,
                          "code"     => INTEGRITY_FAIL,
                          "detail"   => "prev_hash mismatch at sequence #{seq}: " \
                                        "expected #{expected_prev.inspect}, got #{stored_prev.inspect}" }
        prior_record = record
        next
      end

      # --- Step 4: record_hash recomputation ------------------------------------
      stored_hash  = record.dig("chain", "record_hash").to_s
      derived_hash = Schema.compute_record_hash(record)
      unless stored_hash == derived_hash
        int_failures << { "sequence" => seq,
                          "code"     => INTEGRITY_FAIL,
                          "detail"   => "record_hash mismatch at sequence #{seq}" }
        prior_record = record
        next
      end

      # --- Step 5: compliance_posture re-derivation (R32 D3) -------------------
      sig_field       = record["signature"] || {}
      derived_posture = Schema.derive_compliance_posture(
        storage_identity:  sid,
        signature:         sig_field,
        chain_seq:         seq,
        authorization_ref: READER_AUTHORIZATION_REF
      )
      stored_posture = record["compliance_posture"]

      if stored_posture != derived_posture
        pos_mismatches << { "sequence" => seq,
                            "stored"   => stored_posture,
                            "derived"  => derived_posture }
        prior_record = record  # posture mismatch does not break chain (D4)
        next
      end

      # --- Step 6: apply output filters -----------------------------------------
      in_range = sequence_range.nil? || sequence_range.include?(seq)
      kind_ok  = record_kind.nil? || record.dig("audit_subject", "kind") == record_kind
      verified << record if in_range && kind_ok
      prior_record = record
    end

    compliant = int_failures.empty? && pos_mismatches.empty? && !all_records.empty?

    {
      "role"                    => ROLE,
      "total_scanned"           => all_records.size,
      "verified_records"        => verified,
      "integrity_failures"      => int_failures,
      "posture_mismatches"      => pos_mismatches,
      "compliant_export"        => compliant,
      "production_durable_audit" => false,
      "gate3_authorized"        => false
    }
  end

  # -------------------------------------------------------------------------
  # Mutating / authorizing operations — explicit refusals (D3)
  # -------------------------------------------------------------------------
  def append(*)
    reader_refused("append")
  end

  def update(*)
    reader_refused("update")
  end

  def delete(*)
    reader_refused("delete")
  end

  def overwrite(*)
    reader_refused("overwrite")
  end

  def authorize_gate3(*)
    reader_refused("authorize_gate3")
  end

  def sign(*)
    reader_refused("sign")
  end

  private

  def reader_refused(operation)
    { "refused"   => true,
      "code"      => UNAUTHORIZED_OP,
      "role"      => ROLE,
      "operation" => operation,
      "detail"    => "AuditReader (#{ROLE}) does not permit #{operation}" }
  end
end

# =============================================================================
# Proof helpers
# =============================================================================

module ReaderFixtures
  VALID_SIGNER = Impl::Fixtures.valid_signer
  AUDIT_SUBJECT_KINDS = %w[model_evaluation assumption_usage policy_check].freeze

  def self.audit_subject(seq: 1, kind: "model_evaluation")
    { "kind"     => kind,
      "ref"      => "proof://subject/#{seq}",
      "metadata" => { "seq" => seq } }
  end

  def self.build_chain(count, signer: nil, store: nil, kinds: nil)
    signer ||= VALID_SIGNER
    store  ||= Store.new
    records = (1..count).map do |i|
      kind   = kinds ? kinds[(i - 1) % kinds.size] : "model_evaluation"
      result = store.append(
        audit_subject: audit_subject(seq: i, kind: kind),
        signer: signer,
        appended_at: READER_PROOF_TIMESTAMP
      )
      raise "build_chain failed at seq #{i}: #{result.inspect}" unless result[:appended]

      result[:record]
    end
    [records, store]
  end
end

# =============================================================================
# Proof runner
# =============================================================================

CASES  = []
PASSED = []
FAILED = []

def proof_case(id, surface:, description:, &block)
  CASES << { id: id, surface: surface, description: description }
  begin
    block.call
    PASSED << id
    puts "[PASS] #{id} — #{description}"
  rescue => e
    FAILED << id
    puts "[FAIL] #{id} — #{description}"
    puts "       #{e.class}: #{e.message}"
    puts e.backtrace.first(3).map { |l| "         #{l}" }.join("\n")
  end
end

def assert(condition, msg = "assertion failed")
  raise msg unless condition
end

def assert_eq(a, b, msg = nil)
  return if a == b

  raise (msg || "expected #{b.inspect} but got #{a.inspect}")
end

def mutable_copy(record)
  JSON.parse(JSON.generate(record))
end

# =============================================================================
# Surface 1 — Clean traversal
# =============================================================================

proof_case "BB-S1-C1", surface: 1, description: "empty store returns empty verified_records, compliant_export false" do
  store  = Store.new
  reader = AuditReader.new(store)
  result = reader.traverse
  assert_eq result["total_scanned"],  0
  assert_eq result["verified_records"], []
  assert_eq result["integrity_failures"], []
  assert_eq result["posture_mismatches"], []
  assert_eq result["compliant_export"], false, "empty store must not be compliant_export true"
  assert_eq result["role"], AuditReader::ROLE
end

proof_case "BB-S1-C2", surface: 1, description: "single-record store traverses cleanly" do
  _records, store = ReaderFixtures.build_chain(1)
  reader = AuditReader.new(store)
  result = reader.traverse
  assert_eq result["total_scanned"],  1
  assert_eq result["verified_records"].size, 1
  assert_eq result["integrity_failures"], []
  assert_eq result["posture_mismatches"], []
  assert_eq result["compliant_export"], true
end

proof_case "BB-S1-C3", surface: 1, description: "5-record chain traverses cleanly; all records in verified_records" do
  _records, store = ReaderFixtures.build_chain(5)
  reader = AuditReader.new(store)
  result = reader.traverse
  assert_eq result["total_scanned"],  5
  assert_eq result["verified_records"].size, 5
  assert_eq result["integrity_failures"], []
  assert_eq result["posture_mismatches"], []
  assert_eq result["compliant_export"], true
end

proof_case "BB-S1-C4", surface: 1, description: "verified_records are returned in append order (sequence ascending)" do
  _records, store = ReaderFixtures.build_chain(4)
  reader = AuditReader.new(store)
  result = reader.traverse
  seqs = result["verified_records"].map { |r| r.dig("chain", "sequence") }
  assert_eq seqs, [1, 2, 3, 4], "records must be in sequence order"
end

# =============================================================================
# Surface 2 — Integrity failure detection
# =============================================================================

proof_case "BB-S2-C1", surface: 2, description: "tampered record_hash detected as integrity failure" do
  records, store = ReaderFixtures.build_chain(3)
  # Tamper record 2: inject a bad record_hash via internal store access.
  # Note: because prior_record tracks the tampered stored hash, record 3's
  # prev_hash (pointing to the original hash) will also fail the chain check.
  bad = mutable_copy(records[1])
  bad["chain"]["record_hash"] = "sha256:" + "f" * 64
  store.instance_variable_get(:@records)[1] = bad

  reader = AuditReader.new(store)
  result = reader.traverse
  failure_seqs = result["integrity_failures"].map { |f| f["sequence"] }
  assert failure_seqs.include?(2), "sequence 2 must be in integrity_failures"
  assert result["integrity_failures"].size >= 1
  assert result["integrity_failures"].all? { |f| f["code"] == AuditReader::INTEGRITY_FAIL }
  assert result["compliant_export"] == false
end

proof_case "BB-S2-C2", surface: 2, description: "broken prev_hash chain detected as integrity failure" do
  records, store = ReaderFixtures.build_chain(4)
  # Tamper record 3: wrong prev_hash
  bad = mutable_copy(records[2])
  bad["chain"]["previous_record_hash"] = "sha256:" + "a" * 64
  # Also zero the record_hash so it matches the tampered content
  bad["chain"]["record_hash"] = Schema.compute_record_hash(bad)
  store.instance_variable_get(:@records)[2] = bad

  reader = AuditReader.new(store)
  result = reader.traverse
  # record 3 should fail on prev_hash check
  seqs = result["integrity_failures"].map { |f| f["sequence"] }
  assert seqs.include?(3), "sequence 3 must fail on broken prev_hash"
  assert result["compliant_export"] == false
end

proof_case "BB-S2-C3", surface: 2, description: "storage_identity mismatch detected; other records unaffected" do
  records, store = ReaderFixtures.build_chain(3)
  bad = mutable_copy(records[1])
  bad["storage_identity"]["storage_id"] = "proof://other-store"
  # Recompute record_hash to match tampered content (so hash check passes, sid check fails)
  bad["chain"]["record_hash"] = Schema.compute_record_hash(bad)
  store.instance_variable_get(:@records)[1] = bad

  reader = AuditReader.new(store)
  result = reader.traverse
  seqs = result["integrity_failures"].map { |f| f["sequence"] }
  assert seqs.include?(2), "sequence 2 must fail storage_identity"
  assert result["compliant_export"] == false
end

proof_case "BB-S2-C4", surface: 2, description: "records before tampered record verified; tampered record detected" do
  records, store = ReaderFixtures.build_chain(5)
  # Tamper record 3 record_hash only. Records 1+2 (before the tamper) must still verify.
  # Records 4+5 will also fail chain check because prior_record tracks the tampered stored
  # hash of record 3, which does not match what record 4 has as its prev_hash.
  bad = mutable_copy(records[2])
  bad["chain"]["record_hash"] = "sha256:" + "d" * 64
  store.instance_variable_get(:@records)[2] = bad

  reader = AuditReader.new(store)
  result = reader.traverse
  verified_seqs = result["verified_records"].map { |r| r.dig("chain", "sequence") }
  assert verified_seqs.include?(1), "seq 1 must be verified"
  assert verified_seqs.include?(2), "seq 2 must be verified"
  assert result["integrity_failures"].map { |f| f["sequence"] }.include?(3), "seq 3 must fail"
  assert result["compliant_export"] == false
end

# =============================================================================
# Surface 3 — Compliance posture re-derivation (R32 D3)
# =============================================================================

proof_case "BB-S3-C1", surface: 3, description: "re-derived posture matches stored posture for clean record" do
  _records, store = ReaderFixtures.build_chain(2)
  reader = AuditReader.new(store)
  result = reader.traverse
  assert_eq result["posture_mismatches"], []
  assert_eq result["compliant_export"], true
  # Each verified record has a compliance_posture that matches re-derivation
  result["verified_records"].each do |record|
    sig_field = record["signature"] || {}
    sid       = record["storage_identity"] || {}
    seq       = record.dig("chain", "sequence")
    derived   = Schema.derive_compliance_posture(
      storage_identity:  sid,
      signature:         sig_field,
      chain_seq:         seq,
      authorization_ref: READER_AUTHORIZATION_REF
    )
    stored = record["compliance_posture"]
    assert derived == stored, "posture mismatch for seq #{seq}"
  end
end

proof_case "BB-S3-C2", surface: 3, description: "tampered compliance_posture detected; record excluded from verified_records" do
  records, store = ReaderFixtures.build_chain(3)
  # Tamper record 2's stored compliance_posture (but keep record_hash intact by recomputing)
  bad = mutable_copy(records[1])
  bad["compliance_posture"]["status"] = "NON_COMPLIANT"
  bad["compliance_posture"]["posture_code"] = "TAMPERED"
  # Recompute record_hash on tampered record so hash check passes (posture excluded from hash)
  bad["chain"]["record_hash"] = Schema.compute_record_hash(bad)
  # Also fix prev_hash for record 3: it depends on record 2's stored hash
  # record 3's prev_hash in store points to original hash of record 2
  # After our tampering, record 2's hash changes, so record 3's prev_hash will mismatch
  # To isolate posture-only test, we need to update record 3's prev_hash too
  rec3 = mutable_copy(records[2])
  rec3["chain"]["previous_record_hash"] = bad["chain"]["record_hash"]
  rec3["chain"]["record_hash"] = Schema.compute_record_hash(rec3)
  store.instance_variable_get(:@records)[1] = bad
  store.instance_variable_get(:@records)[2] = rec3

  reader = AuditReader.new(store)
  result = reader.traverse

  assert_eq result["posture_mismatches"].size, 1
  pm = result["posture_mismatches"].first
  assert_eq pm["sequence"], 2
  # record 2 excluded from verified_records
  verified_seqs = result["verified_records"].map { |r| r.dig("chain", "sequence") }
  assert !verified_seqs.include?(2), "posture-mismatch record must not appear in verified_records"
  assert result["compliant_export"] == false
end

proof_case "BB-S3-C3", surface: 3, description: "posture mismatch does not block chain verification of subsequent records" do
  records, store = ReaderFixtures.build_chain(4)
  # Tamper record 2 posture only, propagate hashes forward
  bad2 = mutable_copy(records[1])
  bad2["compliance_posture"]["status"] = "NON_COMPLIANT"
  bad2["compliance_posture"]["posture_code"] = "TAMPERED"
  bad2["chain"]["record_hash"] = Schema.compute_record_hash(bad2)

  bad3 = mutable_copy(records[2])
  bad3["chain"]["previous_record_hash"] = bad2["chain"]["record_hash"]
  bad3["chain"]["record_hash"] = Schema.compute_record_hash(bad3)

  bad4 = mutable_copy(records[3])
  bad4["chain"]["previous_record_hash"] = bad3["chain"]["record_hash"]
  bad4["chain"]["record_hash"] = Schema.compute_record_hash(bad4)

  store.instance_variable_get(:@records)[1] = bad2
  store.instance_variable_get(:@records)[2] = bad3
  store.instance_variable_get(:@records)[3] = bad4

  reader = AuditReader.new(store)
  result = reader.traverse

  # records 3+4 should still verify (chain is intact; posture mismatch only on record 2)
  verified_seqs = result["verified_records"].map { |r| r.dig("chain", "sequence") }
  assert verified_seqs.include?(1), "seq 1 verified"
  assert verified_seqs.include?(3), "seq 3 verified despite seq 2 posture mismatch"
  assert verified_seqs.include?(4), "seq 4 verified"
  assert !verified_seqs.include?(2), "seq 2 excluded due to posture mismatch"
  assert_eq result["posture_mismatches"].size, 1
  assert result["compliant_export"] == false
end

# =============================================================================
# Surface 4 — Role boundary: reader refuses writes and gate authorization
# =============================================================================

proof_case "BB-S4-C1", surface: 4, description: "AuditReader#append refused with audit.reader.unauthorized" do
  _records, store = ReaderFixtures.build_chain(1)
  reader = AuditReader.new(store)
  result = reader.append(audit_subject: {}, signer: nil, appended_at: READER_PROOF_TIMESTAMP)
  assert_eq result["refused"], true
  assert_eq result["code"], AuditReader::UNAUTHORIZED_OP
  assert_eq result["operation"], "append"
  assert_eq result["role"], AuditReader::ROLE
end

proof_case "BB-S4-C2", surface: 4, description: "AuditReader#update refused with audit.reader.unauthorized" do
  _records, store = ReaderFixtures.build_chain(1)
  reader = AuditReader.new(store)
  result = reader.update(sequence: 1, field: "kind", value: "tamper")
  assert_eq result["refused"], true
  assert_eq result["code"], AuditReader::UNAUTHORIZED_OP
  assert_eq result["operation"], "update"
end

proof_case "BB-S4-C3", surface: 4, description: "AuditReader#delete refused with audit.reader.unauthorized" do
  _records, store = ReaderFixtures.build_chain(1)
  reader = AuditReader.new(store)
  result = reader.delete(sequence: 1)
  assert_eq result["refused"], true
  assert_eq result["code"], AuditReader::UNAUTHORIZED_OP
  assert_eq result["operation"], "delete"
end

proof_case "BB-S4-C4", surface: 4, description: "AuditReader#authorize_gate3 refused with audit.reader.unauthorized" do
  _records, store = ReaderFixtures.build_chain(1)
  reader = AuditReader.new(store)
  result = reader.authorize_gate3
  assert_eq result["refused"], true
  assert_eq result["code"], AuditReader::UNAUTHORIZED_OP
  assert_eq result["operation"], "authorize_gate3"
end

proof_case "BB-S4-C5", surface: 4, description: "AuditReader#role returns phase1_audit_reader" do
  reader = AuditReader.new(Store.new)
  assert_eq reader.role, "phase1_audit_reader"
end

proof_case "BB-S4-C6", surface: 4, description: "AuditReader#sign refused with audit.reader.unauthorized" do
  reader = AuditReader.new(Store.new)
  result = reader.sign(record: {})
  assert_eq result["refused"], true
  assert_eq result["code"], AuditReader::UNAUTHORIZED_OP
  assert_eq result["operation"], "sign"
end

# =============================================================================
# Surface 5 — Filtered traversal
# =============================================================================

proof_case "BB-S5-C1", surface: 5, description: "sequence_range filter returns only records in range" do
  _records, store = ReaderFixtures.build_chain(5)
  reader = AuditReader.new(store)
  result = reader.traverse(sequence_range: (2..4))
  # total_scanned still 5; verified_records filtered to 2..4
  assert_eq result["total_scanned"], 5
  seqs = result["verified_records"].map { |r| r.dig("chain", "sequence") }
  assert_eq seqs.sort, [2, 3, 4]
  # chain verification ran on all 5, so compliant_export still true
  assert_eq result["compliant_export"], true
end

proof_case "BB-S5-C2", surface: 5, description: "record_kind filter returns only records matching kind" do
  kinds = %w[model_evaluation assumption_usage model_evaluation assumption_usage model_evaluation]
  _records, store = ReaderFixtures.build_chain(5, kinds: kinds)
  reader = AuditReader.new(store)
  result = reader.traverse(record_kind: "assumption_usage")
  seqs = result["verified_records"].map { |r| r.dig("chain", "sequence") }
  assert_eq seqs.sort, [2, 4], "only assumption_usage records should be returned"
  assert_eq result["total_scanned"], 5
  assert_eq result["compliant_export"], true
end

proof_case "BB-S5-C3", surface: 5, description: "combined sequence_range + record_kind filter" do
  kinds = %w[model_evaluation assumption_usage policy_check model_evaluation assumption_usage]
  _records, store = ReaderFixtures.build_chain(5, kinds: kinds)
  reader = AuditReader.new(store)
  result = reader.traverse(sequence_range: (2..5), record_kind: "model_evaluation")
  seqs = result["verified_records"].map { |r| r.dig("chain", "sequence") }
  assert_eq seqs.sort, [4], "only seq 4 matches both range 2..5 and model_evaluation"
  assert_eq result["total_scanned"], 5
end

proof_case "BB-S5-C4", surface: 5, description: "integrity failure in range still detected; chain failure affects compliant_export" do
  records, store = ReaderFixtures.build_chain(5)
  # Tamper record 3
  bad = mutable_copy(records[2])
  bad["chain"]["record_hash"] = "sha256:" + "e" * 64
  store.instance_variable_get(:@records)[2] = bad

  reader = AuditReader.new(store)
  result = reader.traverse(sequence_range: (1..2))
  # Records 1+2 verified, filter shows them; record 3 fails (out of filter but still scanned)
  assert_eq result["total_scanned"], 5
  verified_seqs = result["verified_records"].map { |r| r.dig("chain", "sequence") }
  assert_eq verified_seqs.sort, [1, 2]
  assert result["integrity_failures"].map { |f| f["sequence"] }.include?(3)
  assert result["compliant_export"] == false, "integrity failure outside filter still marks non-compliant"
end

# =============================================================================
# Surface 6 — Excluded surfaces guard
# =============================================================================

proof_case "BB-S6-C1", surface: 6, description: "excluded surface: production_durable_audit always false" do
  _records, store = ReaderFixtures.build_chain(2)
  result = AuditReader.new(store).traverse
  assert_eq result["production_durable_audit"], false
end

proof_case "BB-S6-C2", surface: 6, description: "excluded surface: gate3_authorized always false" do
  _records, store = ReaderFixtures.build_chain(2)
  result = AuditReader.new(store).traverse
  assert_eq result["gate3_authorized"], false
end

proof_case "BB-S6-C3", surface: 6, description: "excluded surface: AuditReader does not expose Ledger methods" do
  reader = AuditReader.new(Store.new)
  assert !reader.respond_to?(:ledger_append), "must not expose ledger_append"
  assert !reader.respond_to?(:ledger_read),   "must not expose ledger_read"
  assert !reader.respond_to?(:subscribe),     "must not expose subscribe"
  assert !reader.respond_to?(:compact),       "must not expose compact"
  assert !reader.respond_to?(:replay),        "must not expose replay"
end

proof_case "BB-S6-C4", surface: 6, description: "excluded surface: AuditReader does not expose RuntimeMachine methods" do
  reader = AuditReader.new(Store.new)
  assert !reader.respond_to?(:bind_runtime),    "must not bind_runtime"
  assert !reader.respond_to?(:schedule),        "must not expose schedule"
  assert !reader.respond_to?(:executor_pool),   "must not expose executor_pool"
end

proof_case "BB-S6-C5", surface: 6, description: "excluded surface: refusal responses do not contain authorization grant" do
  reader = AuditReader.new(Store.new)
  ops = %i[append update delete authorize_gate3 sign]
  ops.each do |op|
    result = reader.public_send(op)
    assert result["refused"] == true,   "#{op} must be refused"
    assert result.key?("code"),         "#{op} refusal must have code"
    assert !result.key?("authorized"),  "#{op} refusal must not contain authorized key"
  end
end

# =============================================================================
# Invariant checks
# =============================================================================

puts "\n--- Invariant Checks ---"

inv_pass = []
inv_fail = []

# INV-1: compliant_export iff no integrity_failures, no posture_mismatches, total_scanned > 0
begin
  # verified: 3-record clean chain
  _, s = ReaderFixtures.build_chain(3)
  r = AuditReader.new(s).traverse
  ok = r["compliant_export"] == true &&
       r["integrity_failures"].empty? &&
       r["posture_mismatches"].empty? &&
       r["total_scanned"] > 0
  raise "INV-1a: clean chain must be compliant_export true" unless ok

  # unverified: empty store
  r2 = AuditReader.new(Store.new).traverse
  raise "INV-1b: empty store must be compliant_export false" unless r2["compliant_export"] == false

  inv_pass << "INV-1: compliant_export consistency"
  puts "[PASS] INV-1: compliant_export consistency"
rescue => e
  inv_fail << "INV-1"
  puts "[FAIL] INV-1: #{e.message}"
end

# INV-2: posture_mismatch records never appear in verified_records
begin
  records, store = ReaderFixtures.build_chain(3)
  bad = mutable_copy(records[1])
  bad["compliance_posture"]["status"] = "NON_COMPLIANT"
  bad["compliance_posture"]["posture_code"] = "TAMPERED"
  bad["chain"]["record_hash"] = Schema.compute_record_hash(bad)
  bad3 = mutable_copy(records[2])
  bad3["chain"]["previous_record_hash"] = bad["chain"]["record_hash"]
  bad3["chain"]["record_hash"] = Schema.compute_record_hash(bad3)
  store.instance_variable_get(:@records)[1] = bad
  store.instance_variable_get(:@records)[2] = bad3

  r = AuditReader.new(store).traverse
  mismatch_seqs = r["posture_mismatches"].map { |m| m["sequence"] }
  verified_seqs = r["verified_records"].map { |rec| rec.dig("chain", "sequence") }
  overlap = mismatch_seqs & verified_seqs
  raise "INV-2: posture mismatch seqs #{mismatch_seqs} overlap verified #{verified_seqs}" unless overlap.empty?

  inv_pass << "INV-2: posture_mismatch ∩ verified_records = ∅"
  puts "[PASS] INV-2: posture_mismatch ∩ verified_records = ∅"
rescue => e
  inv_fail << "INV-2"
  puts "[FAIL] INV-2: #{e.message}"
end

# INV-3: total_scanned equals store.records.size regardless of filter
begin
  _, store = ReaderFixtures.build_chain(6)
  r = AuditReader.new(store).traverse(sequence_range: (2..4))
  raise "INV-3: total_scanned #{r["total_scanned"]} != store size 6" unless r["total_scanned"] == 6

  inv_pass << "INV-3: total_scanned = store.records.size"
  puts "[PASS] INV-3: total_scanned = store.records.size"
rescue => e
  inv_fail << "INV-3"
  puts "[FAIL] INV-3: #{e.message}"
end

# INV-4: refusal operations do not mutate store
begin
  _, store = ReaderFixtures.build_chain(2)
  before_count = store.records.size
  reader = AuditReader.new(store)
  reader.append(audit_subject: {}, signer: nil, appended_at: "2026-01-01T00:00:00Z")
  reader.update(sequence: 1)
  reader.delete(sequence: 1)
  after_count = store.records.size
  raise "INV-4: store mutated by reader operations" unless before_count == after_count

  inv_pass << "INV-4: refusal operations do not mutate store"
  puts "[PASS] INV-4: refusal operations do not mutate store"
rescue => e
  inv_fail << "INV-4"
  puts "[FAIL] INV-4: #{e.message}"
end

# =============================================================================
# Summary
# =============================================================================

puts "\n" + ("=" * 72)
puts "S3-R34-C1-P — Durable Audit Reader / Traversal Proof (B-B)"
puts "=" * 72
total   = CASES.size
passed  = PASSED.size
failed  = FAILED.size
puts "Cases:    #{total}"
puts "Passed:   #{passed}"
puts "Failed:   #{failed}"
puts "Invariants: #{inv_pass.size}/#{inv_pass.size + inv_fail.size} PASS"

if failed > 0
  puts "\nFailed cases:"
  FAILED.each { |id| puts "  - #{id}" }
end
if inv_fail.any?
  puts "\nFailed invariants:"
  inv_fail.each { |id| puts "  - #{id}" }
end

overall = failed == 0 && inv_fail.empty? ? "PASS" : "FAIL"
puts "\nOverall: #{overall}"

# Per-surface summary
surfaces = CASES.group_by { |c| c[:surface] }
puts "\nSurface breakdown:"
surfaces.each do |surf, cases|
  surf_passed = cases.count { |c| PASSED.include?(c[:id]) }
  puts "  Surface #{surf}: #{surf_passed}/#{cases.size}"
end

# =============================================================================
# Artifact generation
# =============================================================================

require "fileutils"

out_dir = File.join(__dir__, "out")
FileUtils.mkdir_p(out_dir)

summary = {
  "proof_id"          => "S3-R34-C1-P",
  "track"             => "durable-audit-reader-traversal-proof-v0",
  "authorization_ref" => READER_AUTHORIZATION_REF,
  "proof_timestamp"   => READER_PROOF_TIMESTAMP,
  "status"            => overall,
  "total_cases"       => total,
  "passed"            => passed,
  "failed"            => failed,
  "invariants_passed" => inv_pass.size,
  "invariants_total"  => inv_pass.size + inv_fail.size,
  "surfaces"          => surfaces.map do |surf, cases|
    surf_passed = cases.count { |c| PASSED.include?(c[:id]) }
    {
      "surface"  => surf,
      "cases"    => cases.size,
      "passed"   => surf_passed,
      "status"   => surf_passed == cases.size ? "PASS" : "FAIL"
    }
  end,
  "decisions"         => {
    "D1" => "Full chain verification runs on ALL records; output filters applied after",
    "D2" => "compliant_export true only when integrity_failures=[], posture_mismatches=[], total_scanned>0",
    "D3" => "Reader role is phase1_audit_reader; all mutating/authorizing ops return audit.reader.unauthorized",
    "D4" => "Posture-mismatch records excluded from verified_records and reported in posture_mismatches"
  },
  "remaining_blockers" => {
    "B-C" => "Appender / reader role boundary proof (surface 7 of S3-R30-C1-A)",
    "B-D" => "Post-implementation full regression matrix; must include P-43 confirmation",
    "P-43" => "Production store append must gate on clean rebuild status (before deployment authorization)"
  },
  "non_authorization"  => {
    "production_durable_audit" => false,
    "gate3_authorized"         => false,
    "ledger"                   => false,
    "bihistory"                => false,
    "stream_olap"              => false,
    "hsm_kms"                  => false,
    "runtime_machine_binding"  => false,
    "lib_changes"              => false
  }
}

File.write(File.join(out_dir, "durable_audit_reader_traversal_proof_summary.json"),
           JSON.pretty_generate(summary))

puts "\nArtifact written to out/durable_audit_reader_traversal_proof_summary.json"

exit(overall == "PASS" ? 0 : 1)
