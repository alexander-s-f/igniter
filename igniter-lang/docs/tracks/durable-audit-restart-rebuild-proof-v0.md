# Track: Durable Audit Restart Rebuild Proof v0

Card: S3-R33-C1-P
Agent: `[Igniter-Lang Implementation Agent]`
Role: `implementation-agent`
Track: `durable-audit-restart-rebuild-proof-v0`
Status: done
Date: 2026-05-11

---

## Purpose

Implement the bounded durable audit B-A: restart rebuild proof (surface 4 of
S3-R30-C1-A). Extends the R31 bounded implementation proof with a
`RestartRebuildEngine` that rebuilds the audit append cursor from stored records
and verifies the full chain, including the R32 compliance_posture mismatch check.

Answers the [Sharper Question] from S3-R32-X1-S:

> On mismatch, does rebuild stop at cursor or abort full scan?

---

## Authorization

```text
architect-supervisor://igniter-lang/gates/phase1-production-durable-audit/bounded-implementation-v0/2026-05-10
```

Source: `igniter-lang/docs/gates/phase1-production-durable-audit-implementation-authorization-decision-v0.md`

Design amendment: `durable-audit-hash-and-posture-design-amendment-v0.md` (S3-R32-C1-P)

---

## Source Design

- `igniter-lang/docs/tracks/phase1-production-durable-audit-v0.md`
  (R26 + R32 amendment — restart rebuild algorithm, compliance_posture model)
- `igniter-lang/docs/tracks/durable-audit-hash-and-posture-design-amendment-v0.md`
  (R32 D2/D3 — compliance_posture mismatch check requirements)
- `igniter-lang/docs/discussions/r32-durable-audit-prop032-and-compiler-profile-pressure-v0.md`
  (R32 pressure review — C-1 priority + [Sharper Question] answered)

---

## Scope

Proof-local only. The `RestartRebuildEngine` is a new module inside a standalone
proof script that `require_relative`s the R31 bounded implementation proof for
shared infrastructure (`Phase1ProductionAuditRecordSchema`, `ProofLocalSigner`,
`Phase1ProductionAuditStore`, `Fixtures`). No `lib/` changes.

Excluded surfaces (confirmed not present):
- No Ledger adapter / Ledger writes / replay / compact / subscribe
- No Phase 2, BiHistory, stream/OLAP production executors
- No production cache, broad RuntimeMachine binding
- No concrete HSM/KMS onboarding / production signing execution
- `gate3_authorized: false` in all outputs
- `production_durable_audit: false` in all proof-local outputs

---

## Implementation Decisions

### [D1] Cursor stops at first failure; full scan continues

**Decision:** The restart rebuild cursor is set to `first_failure_at`. The full
scan continues reading all records to build a complete error report. After a
failure, the store may not accept new appends until the issue is resolved.

**Details:**
- `cursor = first_failure_at` — not the end of the record list
- Full scan: all records are read and all errors are collected
- `verified_count = first_failure_at - 1` — count of records verified before first failure
- `total_scanned` = total records read (full scan always completes)
- Never auto-truncate, auto-compact, or auto-repair the stored audit log

**Rationale:** Stopping cursor at the first mismatch preserves the append-only
guarantee (no new appends past a known-bad record). Continuing the full scan
gives operators a complete error report — multiple failures in the same scan are
more actionable than a report that stops at the first one. The stored records are
never modified: the rebuild only reads, never repairs.

**This answers the [Sharper Question] from S3-R32-X1-S.**

**Proof coverage:** `rebuild.cursor_stops_at_first_failure` (5 records, r3 bad,
cursor=3, verified=2, scanned=5); `rebuild.full_scan_reports_multiple_posture_errors`
(4 records, r2+r4 bad, 2 errors, cursor=2, verified=1).

### [D2] compliance_posture mismatch detection follows R32 D2/D3 exactly

The rebuild engine re-derives `compliance_posture` for each record using
`Phase1ProductionAuditRecordSchema.derive_compliance_posture` with the record's
`storage_identity`, `signature`, `chain_seq`, and the constant `AUTHORIZATION_REF`.

If stored posture ≠ derived posture → `audit.record.compliance_posture_mismatch`.

This check occurs AFTER hash verification (step 5), so a tampered record_hash
still fires `audit.chain.record_hash_mismatch` first. A tampered posture (without
changing the record_hash) fires `audit.record.compliance_posture_mismatch`.

### [D3] Storage identity anchored to first record

The first record's `storage_identity.storage_id` anchors the chain. All
subsequent records must have the same `storage_id`. If a record has a different
`storage_id` → `audit.record.storage_identity_mismatch`.

Storage identity check occurs BEFORE hash check (step 3 vs step 5). A tampered
`storage_id` is detected without reaching hash recomputation.

---

## Rebuild Algorithm (step order)

```
For each record at index idx (expected_seq = idx + 1):

1. format_version recognized?          → audit.record.format_version_missing
                                        | audit.record.format_version_unrecognized
2. kind correct?                       → audit.record.kind_unrecognized
3. chain.sequence == expected_seq?     → audit.chain.sequence_gap
   (detects gaps, duplicates, out-of-order)
4. storage_identity.storage_id matches anchor?
                                       → audit.record.storage_identity_mismatch
5. chain.previous_record_hash correct?
   (idx=0: must be "genesis"; idx>0: must match prior record_hash)
                                       → audit.chain.previous_hash_mismatch
6. recompute record_hash, compare to stored?
                                       → audit.chain.record_hash_mismatch
7. re-derive compliance_posture, compare to stored?
                                       → audit.record.compliance_posture_mismatch

On all failures: record error, set first_failure if not set, continue scan.
cursor = first_failure_at (or last_verified + 1 on clean rebuild).
```

---

## Proof Matrix (21/21 PASS)

```
ruby igniter-lang/experiments/durable_audit_restart_rebuild_proof/durable_audit_restart_rebuild_proof.rb
```

### Surface 1: Clean rebuild (4 cases)

| # | Case | Result | cursor | verified |
|---|------|--------|--------|---------|
| 1 | `rebuild.empty_store` | success | 1 | 0 |
| 2 | `rebuild.single_record` | success | 2 | 1 |
| 3 | `rebuild.two_records` | success | 3 | 2 |
| 4 | `rebuild.five_records` | success | 6 | 5 |

### Surface 2: Hash chain integrity failures (4 cases)

| # | Case | Error code | first_failure_at |
|---|------|-----------|-----------------|
| 5 | `rebuild.tampered_record_hash` | `audit.chain.record_hash_mismatch` | 2 |
| 6 | `rebuild.tampered_previous_hash` | `audit.chain.previous_hash_mismatch` | 2 |
| 7 | `rebuild.sequence_gap` | `audit.chain.sequence_gap` | 2 |
| 8 | `rebuild.out_of_order` | `audit.chain.sequence_gap` | 1 |

### Surface 3: compliance_posture mismatch (R32 D2/D3) (3 cases)

| # | Case | Error code | Detail |
|---|------|-----------|--------|
| 9 | `rebuild.compliance_posture_mismatch` | `audit.record.compliance_posture_mismatch` | r3 posture tampered |
| 10 | `rebuild.full_scan_reports_multiple_posture_errors` | `audit.record.compliance_posture_mismatch` | 2 errors, cursor=2, verified=1 |
| 11 | `rebuild.cursor_stops_at_first_failure` **[D1]** | `audit.record.compliance_posture_mismatch` | 5 records, r3 bad, cursor=3, scanned=5 |

### Surface 4: Schema / format failures (3 cases)

| # | Case | Error code | first_failure_at |
|---|------|-----------|-----------------|
| 12 | `rebuild.wrong_format_version` | `audit.record.format_version_unrecognized` | 2 |
| 13 | `rebuild.wrong_kind` | `audit.record.kind_unrecognized` | 2 |
| 14 | `rebuild.storage_identity_mismatch` **[D3]** | `audit.record.storage_identity_mismatch` | 2 |

### Surface 5: Edge cases (2 cases)

| # | Case | Result |
|---|------|--------|
| 15 | `rebuild.first_record_wrong_prev_hash` | `audit.chain.previous_hash_mismatch` at seq=1 (not genesis) |
| 16 | `rebuild.signed_payload_hash_consistent` | clean rebuild + signed_payload_hash == record_hash for all records |

### Surface 6: Excluded-surface guards (5 checks)

| # | Check | Result |
|---|-------|--------|
| 17 | `excluded.no_production_durable_audit_in_proof_local` | ok — all rebuild results have production_durable_audit: false |
| 18 | `excluded.no_ledger_access` | ok — no Ledger constant |
| 19 | `excluded.no_phase2_access` | ok — no Phase 2 reference |
| 20 | `excluded.no_hsm_kms` | ok — proof-local signer only |
| 21 | `excluded.gate3_authorized_not_widened` | ok — gate3_authorized: false everywhere |

### Cross-cutting invariant checks (6)

| Check | Result |
|-------|--------|
| `invariant.no_production_durable_audit_in_proof_local` | ok |
| `invariant.no_ledger_access` | ok |
| `invariant.no_phase2_access` | ok |
| `invariant.no_hsm_kms` | ok |
| `invariant.cursor_never_past_first_failure` | ok — all failure results: cursor == first_failure_at |
| `invariant.mismatch_code_used_for_posture_errors` | ok — `audit.record.compliance_posture_mismatch` fires correctly |

**Total: 21/21 cases PASS, 6/6 invariant checks PASS.**

---

## Failure Codes Used

| Code | Condition |
|------|-----------|
| `audit.record.format_version_missing` | `format_version` absent |
| `audit.record.format_version_unrecognized` | `format_version` not in `["1.0.0"]` |
| `audit.record.kind_unrecognized` | `kind` not `"phase1_production_audit_record"` |
| `audit.chain.sequence_gap` | sequence not contiguous (gap, duplicate, out-of-order) |
| `audit.record.storage_identity_mismatch` | `storage_id` differs from anchor |
| `audit.chain.previous_hash_mismatch` | previous_record_hash ≠ expected |
| `audit.chain.record_hash_mismatch` | recomputed hash ≠ stored |
| `audit.record.compliance_posture_mismatch` | stored posture ≠ derived posture (R32 D2/D3) |

---

## Sharper Question Answer

**Question (from S3-R32-X1-S):** When restart rebuild runs the mismatch-check
case, does it refuse cursor rebuild and preserve the stored record as-is
(append-only guarantee), or does it refuse the entire rebuild and mark the store
as corrupt?

**Answer [D1]:** Neither fully. The rebuild:

1. Continues reading all records (full scan — not aborted at first failure).
2. Collects all errors across the full scan.
3. Sets `cursor = first_failure_at` — the store may not accept new appends at
   or past this sequence.
4. Reports `verified_count = first_failure_at - 1` — only records before the
   first failure are confirmed valid.
5. Never modifies, truncates, or repairs stored records.

The store is not marked "globally corrupt" — the rebuild reports exactly which
sequence(s) failed and how many records were verified before the failure. Operator
or automated recovery tooling decides whether to halt all appends or take a more
targeted action. The proof-local store's `append` method does not check rebuild
status; a production implementation would gate new appends on clean rebuild.

---

## Regression

| Proof | Result |
|-------|--------|
| `durable_audit_restart_rebuild_proof` | **21/21 PASS** (new) |
| `volatile_fields_lint` | PASS — 6 artifacts with `_volatile_fields` (new summary has no `_volatile_fields` key — omitted correctly) |
| `startup_freshness_override_proof` | 28/28 PASS (unchanged) |
| `contract_modifiers_proof` | PASS (unchanged) |
| `production_durable_audit_compliance_posture_proof` | 14/14 PASS (unchanged) |
| `production_durable_audit_signer_validation_proof` | 18/18 PASS (unchanged) |
| `production_durable_audit_bounded_implementation_proof` | 29/29 PASS (unchanged) |

---

## Scope Boundaries

- No production audit writer created or modified in `lib/`.
- No production signing execution.
- No production registry.
- No Ledger or Phase 2 access.
- No online lookup.
- No HSM/KMS onboarding.
- All engine code lives inside the proof script.
- `gate3_authorized: false` in all outputs.
- `production_durable_audit: false` in all proof-local outputs.
- Stored records never modified during rebuild.

---

## Remaining Blockers Before Deployment Authorization

| Blocker | Surface | Required Before |
|---------|---------|----------------|
| B-B | Audit traversal / reader proof (S3-R30-C1-A surface 6) | Deployment authorization |
| B-C | Appender / reader role boundary proof (S3-R30-C1-A surface 7) | Deployment authorization |
| B-D | Post-implementation full regression matrix (all new proofs + existing proofs PASS) | Deployment authorization |
| B-E | Production deployment, HSM/KMS, production signing remain closed until S3-R30-C1-A follow-up Architect review | Any production deployment |

---

## Pre-Production Checklist

| Item | Status |
|------|--------|
| P-28: Architect production durable audit implementation authorization | ✅ closed — S3-R30-C1-A |
| P-29: startup_time override proof-local validator | ✅ closed — S3-R30-C2-P 28/28 |
| P-31: Schema + signer + store + excluded-surface proofs | ✅ closed — S3-R31-C1-P 29/29 |
| P-37: Canonical hash excluded fields documented | ✅ closed — S3-R32-C1-P |
| P-38: compliance_posture storage model (stored+derived+mismatch-checked) | ✅ closed — S3-R32-C1-P |
| B-A: Restart rebuild proof | ✅ **closed** — S3-R33-C1-P 21/21 PASS |

---

## Handoff

```text
Card: S3-R33-C1-P
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: durable-audit-restart-rebuild-proof-v0
Status: done

[D] Decisions
- D1: Cursor stops at first_failure_at; full scan continues for complete error report.
  Answers [Sharper Question] from S3-R32-X1-S. Never auto-repair or overwrite stored records.
- D2: compliance_posture mismatch detection follows R32 D2/D3 exactly.
  Re-derives posture from record fields; compares to stored; fires
  audit.record.compliance_posture_mismatch on any difference.
- D3: Storage identity anchored to first record's storage_id.
  Check occurs before hash recomputation (step 3 before step 5).

[S] Shipped / Signals
- igniter-lang/experiments/durable_audit_restart_rebuild_proof/
    durable_audit_restart_rebuild_proof.rb
- igniter-lang/experiments/durable_audit_restart_rebuild_proof/
    out/durable_audit_restart_rebuild_proof_summary.json
- igniter-lang/docs/tracks/durable-audit-restart-rebuild-proof-v0.md

[T] Tests / Proofs
- ruby igniter-lang/experiments/durable_audit_restart_rebuild_proof/
    durable_audit_restart_rebuild_proof.rb
  → PASS 21/21 cases, 6/6 invariant checks
- volatile_fields_lint → PASS (7 artifacts, no violations)
- startup_freshness_override_proof → 28/28 PASS (no regression)
- contract_modifiers_proof → PASS (no regression)
- compliance_posture_proof → 14/14 PASS (no regression)
- signer_validation_proof → 18/18 PASS (no regression)
- bounded_implementation_proof → 29/29 PASS (no regression)

[R] Risks / Recommendations
- The proof-local rebuild does not gate new appends on clean rebuild status. A
  production store MUST refuse new appends if rebuild is not clean. This is an
  implementation requirement for the production store adapter, not a proof gap.
- The proof-local `derive_compliance_posture` always returns production_durable_audit:false
  for proof-local storage. In production, this function must use real storage identity
  verification. The proof makes this explicit.
- Storage identity is anchored to the first record's storage_id. If the first record
  is missing or corrupt, the anchor cannot be set. A production implementation should
  validate the first record's storage_id against a known expected value from configuration.

[Q] Open questions
- Q1: Should the production store's append method explicitly check rebuild status
  (i.e., refuse appends if last_rebuild_status != :clean)? The proof-local store does
  not implement this guard. The R32 design says "fail closed; do not append new records"
  after rebuild failure — worth confirming whether this is enforced at the store level
  or above it.

[Next] Suggested next slice
- B-B: Audit traversal / reader proof (surface 6 of S3-R30-C1-A)
  Note: reader must re-derive compliance_posture for every returned record (R32 D3).
- B-C: Appender / reader role boundary proof (surface 7 of S3-R30-C1-A)
  May run in parallel with B-B.
- B-D: Post-implementation full regression matrix (surface 9 of S3-R30-C1-A)
  Must pass before follow-up Architect production deployment review.
```
