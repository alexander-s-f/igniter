Card: S3-R24-C3-P
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: igniter-lang/phase1-observation-tamper-evidence-shape-v0
Status: done
Date: 2026-05-10

---

# Track: Phase 1 Observation Tamper-Evidence Shape v0

## Purpose

Extend the proof-local observation persistence shape (S3-R23-C1-P) with a
`tamper_evidence` block that enables gap detection, reorder detection, and
content-integrity verification across a sequence of appended records — without
a Ledger, signing infrastructure, or production storage.

---

## Source Signals

- `docs/tracks/phase1-durable-observation-persistence-shape-v0.md` (S3-R23-C1-P)
- `experiments/phase1_durable_observation_persistence_shape/phase1_durable_observation_persistence_shape.rb`
- S3-R23-C1-P recommendation: "A production durable audit follow-up should be a
  separate track with storage identity, retention, tamper evidence, replay semantics,
  and compliance language."

---

## Decisions

### [D] Tamper-evidence fields added as a nested block, not as flat fields

The `tamper_evidence` block is embedded inside `phase1_observation_persistence_record`
alongside the existing S3-R23-C1-P fields. This is non-breaking: the six required
fields from S3-R23-C1-P are preserved unchanged. `format_version` is bumped from
`0.1.0` to `0.2.0` to signal the addition.

### [D] Five fields in tamper_evidence block

| Field | Type | Purpose |
|-------|------|---------|
| `sequence` | Integer (0-based) | Monotonic counter; gap detection |
| `previous_record_hash` | String | SHA256 of preceding record body; `"genesis"` for first; reorder detection |
| `record_hash` | String | SHA256 of this record body (with `record_hash=nil`); content integrity |
| `storage_identity` | String | UUID fixed at store construction; cross-log mixing detection |
| `created_at` | String (ISO8601) | Explicit proof timestamp |

### [D] Hash algorithm: SHA256 over canonical JSON (recursively sorted keys)

`record_hash` is `SHA256(JSON.generate(canonical_sort(record_body_with_record_hash_nil)))`.
Sorting ensures the hash is deterministic regardless of Ruby Hash insertion order.
This is proof-local verification, not a cryptographic commitment — the source code is
readable and any caller can construct a passing hash. See production recommendation below.

### [D] Chain state is in-memory only

`@sequence` and `@last_record_hash` are held in the store instance. They are not
re-derived from the JSONL file on restart. Consistent with proof-local use; a
production store would rebuild chain state from the persisted log on startup.

### [D] Receipt surfaces tamper-evidence fields

The `persist` return value exposes `sequence`, `previous_record_hash`, `record_hash`,
and `storage_identity` so callers can verify linkage without re-reading the file.

### [D] Existing exclusions unchanged

Ledger adapter, write, replay, compact, and subscribe remain blocked. All five
blocked-case checks pass. The caveat block from S3-R23-C1-P is preserved unchanged:
`audit_ready: true, production_durable_audit: false`.

---

## Record Shape (format_version 0.2.0)

```json
{
  "kind": "phase1_observation_persistence_record",
  "format_version": "0.2.0",
  "record_id": "phase1/obs/<sha256[0,20]>",
  "persistence_mode": "proof_local_file",
  "persisted_at": "<ISO8601>",
  "source_envelope_kind": "audit_ready_temporal_read_envelope",
  "source_envelope_id": "<sha256[0,20]>",
  "temporal_live_read_observation": { ... },
  "compatibility_report_ref": "compat/phase1/<hash>",
  "authority_ref": "architect-supervisor://igniter-lang/gates/gate3/...",
  "signed_addendum_ref": "igniter-lang/docs/gates/gate3-live-read-decision-addendum-v0.md",
  "backend_identity": { ... },
  "result": { "status": "allowed", "reason_code": "...", "result_present": true },
  "caveat": {
    "audit_ready": true,
    "production_durable_audit": false,
    "production_compliance_claim": false,
    "ledger": false
  },
  "tamper_evidence": {
    "sequence": 0,
    "previous_record_hash": "genesis",
    "record_hash": "<sha256-64-hex>",
    "storage_identity": "<uuid>",
    "created_at": "<ISO8601>"
  }
}
```

---

## Shipped

- `experiments/phase1_observation_tamper_evidence_shape/phase1_observation_tamper_evidence_shape.rb`
  — `TamperEvidentObservationStore` class + 23-check proof harness (two-record chain)
- `experiments/phase1_observation_tamper_evidence_shape/out/phase1_tamper_evident_store.jsonl`
  — proof-local JSONL with 2 chained records

---

## Proof Results

```bash
ruby igniter-lang/experiments/phase1_observation_tamper_evidence_shape/phase1_observation_tamper_evidence_shape.rb
```

```text
PASS phase1_observation_tamper_evidence_shape
  shape.sequence_present:            ok
  shape.previous_hash_present:       ok
  shape.record_hash_present:         ok
  shape.storage_identity_present:    ok
  shape.created_at_present:          ok
  chain.first_sequence_zero:         ok
  chain.first_previous_genesis:      ok
  chain.second_sequence_one:         ok
  chain.second_links_to_first:       ok
  chain.storage_identity_consistent: ok
  receipt.sequence_zero:             ok
  receipt.previous_genesis:          ok
  receipt.record_hash_present:       ok
  integrity.r1_hash_verifiable:      ok
  integrity.r2_hash_verifiable:      ok
  caveat.audit_ready:                ok
  caveat.not_production_audit:       ok
  excluded.ledger_blocked:           ok
  excluded.write_blocked:            ok
  excluded.replay_blocked:           ok
  excluded.compact_blocked:          ok
  excluded.subscribe_blocked:        ok
  chain.only_allowed_appended:       ok

23/23 PASS
```

---

## What This Proves / What It Does Not Prove

### Proved

- The five tamper-evidence fields are present and typed correctly
- The first record starts from `"genesis"` at `sequence=0`
- The second record's `previous_record_hash` equals the first record's `record_hash`
- `storage_identity` is consistent across both records in the same store
- `record_hash` is reproducible: independently re-computed hash matches stored hash
- Receipt surfaces all four tamper-evidence identifiers to callers
- All five excluded operations still do not append to the log

### Not Proved / Not Claimed

- **Not cryptographic authorization**: any caller who reads the source can construct
  a token that passes. `record_hash` is a content integrity check, not a signed commitment.
- **Not production durable audit**: chain state is in-memory; not rebuilt from JSONL on restart.
- **Not tamper-detection alerting**: gap/reorder detection requires a reader that
  inspects the chain; none is implemented here.
- **Not production signing**: no HSM, KMS, or signing key involved.
- **Not compliance**: no GDPR/SOC2/PCI language. `production_compliance_claim: false`.

---

## Recommendation for Production Durable Audit Track

Suggested future track: `phase1-production-durable-audit-v0`

Required additions beyond this proof-local shape:

| Addition | Reason |
|----------|--------|
| HSM/KMS signing per record | Replaces SHA256-only chain; makes hash commitments unforgeable |
| Retention policy and TTL | Required for compliance scopes |
| Replay semantics | Ordered replay, idempotent re-read; `compact` and `subscribe` gated separately |
| Infrastructure storage identity | Not an in-memory UUID; tied to deploy/shard identity |
| Compliance language | GDPR/SOC2/PCI scope must be named if applicable |
| Separate audit reader role | Read-only audit accessor distinct from executor; no write path |
| Off-process persistence | Not file-backed; dedicated audit store with durability guarantees |
| Gap/reorder alerting | Chain verification wired to monitoring/alerting surface |

Pre-conditions before that track can be routed:

1. `gate3-live-read-decision-addendum-v0` issued (R1) — live reads unblocked
2. `phase1-backend-identity-guard-v0` closed (C-1) — backend class constraint
3. AT-10 persistence gap (R3) resolved with production store binding

---

## Non-Authorization

This track does not authorize:

- Production durable audit
- Ledger adapter or package binding
- Live reads (gate3 status unchanged)
- Production signing or compliance claims
- Write, replay, compact, or subscribe operations

---

## Handoff

```text
Card: S3-R24-C3-P
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: igniter-lang/phase1-observation-tamper-evidence-shape-v0
Status: done

[D] Decisions
- tamper_evidence block added nested in phase1_observation_persistence_record (non-breaking)
- Five fields: sequence, previous_record_hash, record_hash, storage_identity, created_at
- record_hash = SHA256(canonical JSON with record_hash=nil); canonical = recursively sorted keys
- Chain state (@sequence, @last_record_hash) in-memory only; consistent with proof-local scope
- Receipt surfaces all four tamper-evidence identifiers
- format_version bumped 0.1.0 → 0.2.0
- Existing S3-R23-C1-P exclusions unchanged

[S] Shipped
- experiments/phase1_observation_tamper_evidence_shape/phase1_observation_tamper_evidence_shape.rb
- experiments/phase1_observation_tamper_evidence_shape/out/phase1_tamper_evident_store.jsonl

[T] Tests / Proofs
- command: ruby igniter-lang/experiments/phase1_observation_tamper_evidence_shape/phase1_observation_tamper_evidence_shape.rb
- result: PASS (23/23)

[R] Risks
- SHA256-only hash is source-readable; not a cryptographic commitment — production requires HSM/KMS signing
- Chain state is in-memory; log replay from JSONL not implemented — production requires rebuild-on-restart
- No tamper-detection alerting wired — gap/reorder detection is verifiable but not monitored

[Q] Open questions
- Q1: Should format_version 0.2.0 be enforced by the store guard (reject 0.1.0 records)?
  Currently not enforced; versioning is informational only.

[Next] Suggested next slice
- gate3-live-read-decision-addendum-v0 (R1 — Architect decision for non-proof live reads)
- phase1-production-durable-audit-v0 (after R1, C-1, and R3 are resolved)
- phase1-backend-identity-guard-v0 (C-1 — backend class constraint, pre-Phase-2)
```
