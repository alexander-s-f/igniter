# Track: durable-audit-reader-traversal-proof-v0

Card: S3-R34-C1-P
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Mode: proof
Stage: bounded-proof
Track: durable-audit-reader-traversal-proof-v0
Date: 2026-05-11
Authorization: architect-supervisor://igniter-lang/gates/phase1-production-durable-audit/bounded-implementation-v0/2026-05-10

---

## Goal

Implement proof-local audit traversal / reader proof for production durable audit surface B-B (surface 6 of S3-R30-C1-A).

Answer: Does the reader re-derive compliance_posture for every returned record (R32 D3), and does it refuse all mutating / authorizing operations?

---

## Scope

### In scope
- Proof-local `AuditReader` class wrapping a `Phase1ProductionAuditStore`
- Full chain verification on ALL records before filtering output
- Re-derivation of compliance_posture for each record (R32 D3)
- Detection of posture mismatch without mutating records
- Reader-only role boundary: explicit refusals for append / update / delete / overwrite / authorize_gate3 / sign
- Filtered traversal (sequence_range, record_kind)
- compliant_export gate: true only when no integrity failures, no posture mismatches, total_scanned > 0

### Explicitly out of scope (non-authorization)
- Production storage, Ledger, BiHistory, stream/OLAP
- HSM / KMS integration
- RuntimeMachine scheduler binding
- Writes, replay, compact, subscribe on AuditReader
- `.igapp` manifest changes
- `lib/` changes

---

## Decisions

### [D1] Full chain verification on ALL records; output filters apply after

The reader scans ALL records in the store regardless of sequence_range or record_kind filters. Filters are applied to the output (`verified_records`) only after the full verification pass. This ensures `compliant_export`, `integrity_failures`, and `posture_mismatches` reflect the entire store, not just the requested window.

### [D2] compliant_export true only when no failures, no mismatches, total_scanned > 0

`compliant_export` is a boolean indicator that the full store traversal found no integrity failures, no posture mismatches, and had at least one record to scan. An empty store is NOT compliant_export true.

### [D3] Reader role is "phase1_audit_reader"; all mutating/authorizing operations refused

`AuditReader#role` returns `"phase1_audit_reader"`. The following methods return a structured refusal hash with `code: "audit.reader.unauthorized"` and do not touch the store: `append`, `update`, `delete`, `overwrite`, `authorize_gate3`, `sign`. Refusal responses do NOT contain an `authorized` key.

### [D4] Posture-mismatch records excluded from verified_records; reported in posture_mismatches

A record that passes all integrity checks (format, storage_identity, prev_hash, record_hash) but whose stored `compliance_posture` does not match the re-derived posture is reported in `posture_mismatches` and excluded from `verified_records`. Importantly, a posture mismatch does NOT break chain continuity: `prior_record` is updated to the current record even on posture mismatch, so subsequent records can still be verified.

### [D5] prior_record tracking matches restart_rebuild pattern

Following the pattern established in S3-R33-C1-P, `prior_record` is updated to the current record at every exit point — both on failure (before `next`) and on success. This means integrity failures in the middle of the chain propagate naturally: the next record's expected `previous_record_hash` is the stored hash of the failed record, not a reset-to-nil value. This is consistent with how `RestartRebuildEngine` tracks the chain.

---

## Verification Algorithm

```
traverse(sequence_range:, record_kind:)
  prior_record ← nil
  first_storage_id ← nil
  verified ← []
  integrity_failures ← []
  posture_mismatches ← []

  for each record at index idx:
    seq ← record.chain.sequence

    STEP 1: format_version must be "1.0.0"; kind must be "phase1_production_audit_record"
      → on fail: integrity_failures << { sequence, code: INTEGRITY_FAIL }
                 prior_record ← record; next

    STEP 2: storage_identity.storage_id must be consistent across all records
      → on fail: integrity_failures << { sequence, code: INTEGRITY_FAIL }
                 prior_record ← record; next

    STEP 3: previous_record_hash continuity
      → genesis (idx == 0): must equal "genesis"
      → others:             must equal prior_record.chain.record_hash
      → on fail: integrity_failures << { sequence, code: INTEGRITY_FAIL }
                 prior_record ← record; next

    STEP 4: record_hash recomputation
      → derived ← Schema.compute_record_hash(record)
      → stored must equal derived
      → on fail: integrity_failures << { sequence, code: INTEGRITY_FAIL }
                 prior_record ← record; next

    STEP 5: compliance_posture re-derivation (R32 D3)
      → derived ← Schema.derive_compliance_posture(storage_identity:, signature:, chain_seq:, authorization_ref:)
      → stored must equal derived
      → on mismatch: posture_mismatches << { sequence, stored, derived }
                     prior_record ← record; next  # chain continues (D4)

    STEP 6: apply output filters
      → add record to verified if in sequence_range AND matches record_kind
      → prior_record ← record

  compliant_export ← integrity_failures.empty? && posture_mismatches.empty? && total_scanned > 0
```

---

## Proof Case Matrix

### Surface 1 — Clean traversal (4/4 PASS)

| Case | Description | Result |
|------|-------------|--------|
| BB-S1-C1 | Empty store: verified_records=[], compliant_export=false | PASS |
| BB-S1-C2 | Single-record store traverses cleanly | PASS |
| BB-S1-C3 | 5-record chain: all 5 in verified_records | PASS |
| BB-S1-C4 | verified_records returned in sequence order | PASS |

### Surface 2 — Integrity failure detection (4/4 PASS)

| Case | Description | Result |
|------|-------------|--------|
| BB-S2-C1 | Tampered record_hash detected; sequence 2 in integrity_failures | PASS |
| BB-S2-C2 | Broken prev_hash chain detected at sequence 3 | PASS |
| BB-S2-C3 | storage_identity mismatch at sequence 2 detected | PASS |
| BB-S2-C4 | Records before tampered record verified; tampered record detected | PASS |

**Note on BB-S2-C1:** When record 2's stored hash is tampered, the prior_record tracking (D5) means record 3's expected prev_hash = the tampered stored hash of record 2 ≠ record 3's actual prev_hash (pointing to original hash). So tampering a stored hash causes ≥1 failure (the tampered record and any records whose prev_hash now mismatches). The test asserts sequence 2 is detected, not that exactly 1 record fails.

### Surface 3 — Compliance posture re-derivation (3/3 PASS)

| Case | Description | Result |
|------|-------------|--------|
| BB-S3-C1 | Re-derived posture matches stored for clean records | PASS |
| BB-S3-C2 | Tampered posture detected; record excluded from verified_records | PASS |
| BB-S3-C3 | Posture mismatch does not break chain for subsequent records | PASS |

### Surface 4 — Role boundary (6/6 PASS)

| Case | Description | Result |
|------|-------------|--------|
| BB-S4-C1 | AuditReader#append refused with audit.reader.unauthorized | PASS |
| BB-S4-C2 | AuditReader#update refused with audit.reader.unauthorized | PASS |
| BB-S4-C3 | AuditReader#delete refused with audit.reader.unauthorized | PASS |
| BB-S4-C4 | AuditReader#authorize_gate3 refused with audit.reader.unauthorized | PASS |
| BB-S4-C5 | AuditReader#role returns "phase1_audit_reader" | PASS |
| BB-S4-C6 | AuditReader#sign refused with audit.reader.unauthorized | PASS |

### Surface 5 — Filtered traversal (4/4 PASS)

| Case | Description | Result |
|------|-------------|--------|
| BB-S5-C1 | sequence_range filter: total_scanned=5, verified_records filtered to range | PASS |
| BB-S5-C2 | record_kind filter: only matching audit_subject.kind returned | PASS |
| BB-S5-C3 | Combined sequence_range + record_kind filter | PASS |
| BB-S5-C4 | Integrity failure outside filter range still marks compliant_export=false | PASS |

### Surface 6 — Excluded surfaces (5/5 PASS)

| Case | Description | Result |
|------|-------------|--------|
| BB-S6-C1 | production_durable_audit always false in traverse result | PASS |
| BB-S6-C2 | gate3_authorized always false in traverse result | PASS |
| BB-S6-C3 | AuditReader does not expose Ledger methods | PASS |
| BB-S6-C4 | AuditReader does not expose RuntimeMachine methods | PASS |
| BB-S6-C5 | Refusal responses do not contain authorized key | PASS |

### Invariants (4/4 PASS)

| Invariant | Check | Result |
|-----------|-------|--------|
| INV-1 | compliant_export true iff integrity_failures=[] AND posture_mismatches=[] AND total_scanned>0 | PASS |
| INV-2 | posture_mismatch sequences ∩ verified_record sequences = ∅ | PASS |
| INV-3 | total_scanned = store.records.size regardless of filter | PASS |
| INV-4 | Refusal operations do not mutate store | PASS |

**Total: 26/26 PASS, 4/4 invariants PASS**

---

## Failure Codes

| Code | Meaning |
|------|---------|
| `audit.record.integrity_failure` | format_version/kind/storage_identity/prev_hash/record_hash check failed |
| `audit.record.compliance_posture_mismatch` | stored posture ≠ re-derived posture |
| `audit.reader.unauthorized` | mutating/authorizing operation refused by reader role |

---

## Regression Table

| Proof | Status after S3-R34-C1-P |
|-------|--------------------------|
| S3-R31-C1-P (29 cases) | PASS |
| S3-R33-C1-P (21 cases) | PASS |
| S3-R34-C1-P (26 cases) | PASS |

---

## Non-Authorizations

The following surfaces remain closed and were not opened by this proof:

- Production durable audit deployment (`production_durable_audit: false` always)
- Gate 3 authorization (`gate3_authorized: false` always)
- Ledger integration
- BiHistory integration
- Stream / OLAP integration
- HSM / KMS integration
- RuntimeMachine scheduler binding
- `.igapp` manifest changes
- `lib/` changes

---

## Open Items

| Blocker | Description |
|---------|-------------|
| B-C | Appender / reader role boundary proof (surface 7 of S3-R30-C1-A) — may run in parallel with B-B per R33-X1-S Route |
| B-D | Post-implementation full regression matrix (surface 9 of S3-R30-C1-A) — must include P-43 confirmation |
| P-43 | Production store append must gate on clean rebuild status — required before deployment authorization (B-D / Architect review) |
| P-44 | Update `PROP-036+` → `PROP-037+` for managed recursion / loop classes in Covenant, heat map, spec-extension-gap-analysis |

---

## Artifacts

- `experiments/durable_audit_reader_traversal_proof/durable_audit_reader_traversal_proof.rb` — proof script
- `experiments/durable_audit_reader_traversal_proof/out/durable_audit_reader_traversal_proof_summary.json` — summary artifact
- `docs/tracks/durable-audit-reader-traversal-proof-v0.md` — this document

---

## Handoff

B-B is closed. The next card is B-C: Appender / reader role boundary proof (surface 7 of S3-R30-C1-A), which may run in parallel with B-B per R33-X1-S [Route] item 2. B-D (post-implementation full regression matrix) opens after both B-B and B-C are complete and must include P-43 confirmation before the follow-up Architect production deployment review.
