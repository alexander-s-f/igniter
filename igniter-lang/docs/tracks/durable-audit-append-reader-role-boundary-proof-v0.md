# Track: Durable Audit Append/Reader Role Boundary Proof v0

Card: S3-R34-C2-P
Agent: `[Igniter-Lang Implementation Agent]`
Role: `implementation-agent`
Track: `durable-audit-append-reader-role-boundary-proof-v0`
Status: done
Date: 2026-05-11

Authorization ref:
`architect-supervisor://igniter-lang/gates/phase1-production-durable-audit/bounded-implementation-v0/2026-05-10`

---

## Purpose

Prove the appender / reader role boundary for the Phase 1 production durable
audit system. This is B-C (surface 7 of S3-R30-C1-A).

Proves:

- `phase1_audit_appender` role may append valid audit records; is denied
  reader/traversal operations.
- `phase1_audit_reader` role may traverse and verify the audit chain; is denied
  append.
- Rebuild failure state gates new appends (P-43 answer, [D1]).
- Unknown/nil role produces deterministic refusal diagnostics.
- Role violations emit exactly `audit.writer.unauthorized` or
  `audit.reader.unauthorized`.

---

## Source Inputs

- `docs/gates/phase1-production-durable-audit-implementation-authorization-decision-v0.md`
  (S3-R30-C1-A)
- `docs/tracks/phase1-production-durable-audit-v0.md` (S3-R26-C1-P + R32 amendment)
- `docs/tracks/durable-audit-hash-and-posture-design-amendment-v0.md` (S3-R32-C1-P)
- `docs/discussions/r33-rebuild-prop032-profile-and-progression-pressure-v0.md`
  (R33 pressure — P-43 open, B-C routing)

---

## Design Decisions

### [D1] P-43 Answer: Production Append Must Gate on Clean Rebuild Status

**Question (P-43):** Must a production audit store refuse new appends when
rebuild status is not clean?

**Answer:** YES. The `RoleGatedStore` model proves the gate explicitly.

Rules:

1. Before any append is accepted, `rebuild_status` must equal `"clean"`.
2. A failed rebuild state (`rebuild_status = "failed"`) causes all append
   attempts to be refused with code `audit.writer.rebuild_not_clean`.
3. Recovery path: once a rebuild completes successfully and `rebuild_status`
   is set to `"clean"`, appends are permitted again.
4. The gate is independent of the role check — role is checked first, then
   rebuild status.

Refusal code for rebuild gate:

```text
audit.writer.rebuild_not_clean
```

**Note:** The proof-local `RestartRebuildEngine` (S3-R33-C1-P / C1-P) did not
implement this gate in the proof-local store — that was an acknowledged gap
noted as Q1 in C1-P. This card closes P-43 by modelling the gate explicitly.
A production store MUST implement this gate before B-D / deployment
authorization review opens.

---

## RoleGatedStore Model

The `RoleGatedStore` wraps `Phase1ProductionAuditStore` with role and rebuild
enforcement.

```text
RoleGatedStore
  role:           phase1_audit_appender | phase1_audit_reader | <other>
  rebuild_status: "clean" | "failed" | <other>

append(audit_subject:, signer:)
  -> if role != phase1_audit_appender: refuse(audit.writer.unauthorized)
  -> if rebuild_status != "clean":     refuse(audit.writer.rebuild_not_clean)
  -> else: delegate to Phase1ProductionAuditStore#append

traverse()
  -> if role != phase1_audit_reader: refuse(audit.reader.unauthorized)
  -> else: return store.records.dup

verify_chain()
  -> if role != phase1_audit_reader: refuse(audit.reader.unauthorized)
  -> else: return store.verify_chain
```

---

## Proof Cases

21 cases across 6 surfaces.

### Surface 1: Appender Role (3 cases)

| Case | Result |
|------|--------|
| `role.appender_can_append_clean_rebuild` | PASS |
| `role.appender_traverse_refused` | PASS |
| `role.appender_multi_append` | PASS |

### Surface 2: Reader Role (3 cases)

| Case | Result |
|------|--------|
| `role.reader_can_traverse` | PASS |
| `role.reader_append_refused` | PASS |
| `role.reader_can_verify_chain` | PASS |

### Surface 3: Rebuild Gate — P-43 (4 cases)

| Case | Result |
|------|--------|
| `p43.appender_clean_rebuild_allowed` | PASS |
| `p43.appender_failed_rebuild_refused` | PASS |
| `p43.appender_recovery_after_rebuild` | PASS |
| `p43.rebuild_not_clean_code_deterministic` | PASS |

Surface 3 directly closes P-43. [D1] is recorded here.

### Surface 4: Unknown / Nil Role (3 cases)

| Case | Result |
|------|--------|
| `role.nil_role_append_refused` | PASS |
| `role.nil_role_traverse_refused` | PASS |
| `role.unknown_role_append_refused` | PASS |

### Surface 5: Cross-Role Isolation (3 cases)

| Case | Result |
|------|--------|
| `isolation.reader_append_code_deterministic` | PASS |
| `isolation.appender_traverse_code_deterministic` | PASS |
| `isolation.refused_appends_do_not_mutate_store` | PASS |

### Surface 6: Excluded-Surface Guards (5 checks)

| Check | Result |
|-------|--------|
| `excluded.no_production_durable_audit_in_proof_local` | PASS |
| `excluded.no_ledger_access` | PASS |
| `excluded.no_phase2_access` | PASS |
| `excluded.no_hsm_kms` | PASS |
| `excluded.gate3_authorized_not_widened` | PASS |

---

## Invariant Checks (6 checks)

| Check | Result |
|-------|--------|
| `invariant.all_refusals_have_deterministic_code` | PASS |
| `invariant.reader_append_always_writer_unauthorized` | PASS |
| `invariant.appender_traverse_always_reader_unauthorized` | PASS |
| `invariant.p43_rebuild_gate_code_is_rebuild_not_clean` | PASS |
| `invariant.no_ledger_access` | PASS |
| `invariant.no_phase2_or_hsm_kms` | PASS |

---

## Regression Checks

| Check | Result |
|-------|--------|
| `regression.r31_bounded_impl_append_ok` | PASS |
| `regression.r33_restart_rebuild_clean_ok` | PASS |

---

## Excluded Surfaces

All confirmed absent from this proof:

| Surface | Status |
|---------|--------|
| Ledger adapter / Ledger writes / replay / compact / subscribe | ABSENT |
| Phase 2 | ABSENT |
| BiHistory | ABSENT |
| Stream / OLAP production executors | ABSENT |
| Production cache | ABSENT |
| Concrete HSM/KMS onboarding | ABSENT |
| Broad RuntimeMachine binding | ABSENT |
| `.igapp` manifest migration | ABSENT |
| Production deployment | ABSENT |
| `gate3_authorized: true` | ABSENT |

---

## Refusal Code Table

| Code | Trigger |
|------|---------|
| `audit.writer.unauthorized` | Caller role is not `phase1_audit_appender` |
| `audit.reader.unauthorized` | Caller role is not `phase1_audit_reader` |
| `audit.writer.rebuild_not_clean` | `rebuild_status != "clean"` — P-43 gate |

---

## Pre-Production Checklist Update

| Item | Status | Closed by |
|------|--------|-----------|
| P-43: Production store append must gate on clean rebuild status | ✅ **closed** | S3-R34-C2-P (this card) — [D1] above |

---

## Open Blockers After This Card

| Blocker | Description |
|---------|-------------|
| B-B | Audit traversal / reader proof (surface 6 of S3-R30-C1-A). Must re-derive `compliance_posture` for every returned record per R32 D3. |
| B-D | Post-implementation full regression matrix (surface 9 of S3-R30-C1-A). Requires B-B and B-C both done. P-43 is now closed; may proceed when B-B completes. |
| B-E | Follow-up Architect production deployment review. Requires B-B, B-C, B-D all closed. |

B-C is now closed by this card. P-43 is now closed by this card.

---

## Proof Artifacts

```
experiments/durable_audit_append_reader_role_boundary_proof/
  durable_audit_append_reader_role_boundary_proof.rb   — proof script
  out/
    durable_audit_append_reader_role_boundary_proof_summary.json
```

---

## Summary

21/21 cases PASS. 6/6 invariant checks PASS. 2/2 regression checks PASS.

B-C is done. P-43 is closed.

The `audit.writer.rebuild_not_clean` gate is the required production
implementation guard. Deployment authorization (B-E) remains blocked until
B-B and B-D complete.
