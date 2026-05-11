# Track: Durable Audit Post-Implementation Regression Matrix v0

Card: S3-R35-C1-P
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: durable-audit-post-implementation-regression-matrix-v0
Status: done
Date: 2026-05-11

Authorization ref:
`architect-supervisor://igniter-lang/gates/phase1-production-durable-audit/bounded-implementation-v0/2026-05-10`

---

## Purpose

Close B-D: post-implementation full regression matrix for the bounded Phase 1
production durable audit implementation.

This card verifies the bounded implementation, restart rebuild, reader
traversal, and appender/reader role-boundary proofs together after B-A, B-B,
B-C, and P-43 landed.

This card does not open production deployment. It does not implement a Ledger
adapter, production storage, concrete HSM/KMS onboarding, production signing
execution, Phase 2, BiHistory, stream/OLAP production execution, production
cache, or broad RuntimeMachine binding.

---

## Source Inputs

- `igniter-lang/docs/gates/phase1-production-durable-audit-implementation-authorization-decision-v0.md`
  (repository path:
  `igniter-lang/docs/gates/phase1-production-durable-audit-implementation-authorization-decision-v0.md`)
- `igniter-lang/docs/tracks/phase1-production-durable-audit-bounded-implementation-v0.md`
- `igniter-lang/docs/tracks/durable-audit-restart-rebuild-proof-v0.md`
- `igniter-lang/docs/tracks/durable-audit-reader-traversal-proof-v0.md`
- `igniter-lang/docs/tracks/durable-audit-append-reader-role-boundary-proof-v0.md`
- `igniter-lang/docs/discussions/r34-audit-assumptions-profile-progression-pressure-v0.md`

Note: the authorization decision file exists in the repository with the
`phase1-` prefix.

---

## Command Matrix

All commands were run from repository root: `/Users/alex/dev/projects/igniter`.

| # | Command | Result | Observed proof result |
|---|---------|--------|-----------------------|
| 1 | `ruby igniter-lang/experiments/volatile_fields_lint/volatile_fields_lint.rb` | PASS | `volatile_fields_lint: PASS` with 5 artifacts carrying `_volatile_fields` |
| 2 | `ruby igniter-lang/experiments/startup_freshness_override_proof/startup_freshness_override_proof.rb` | PASS | `28/28 cases`; no production gate authority, Ledger, Phase 2, online lookup, or production signing required |
| 3 | `ruby igniter-lang/experiments/contract_modifiers_proof/contract_modifiers_proof.rb` | PASS | `PASS contract_modifiers_proof` |
| 4 | `ruby igniter-lang/experiments/production_durable_audit_compliance_posture_proof/production_durable_audit_compliance_posture_proof.rb` | PASS | `14/14 PASS` |
| 5 | `ruby igniter-lang/experiments/production_durable_audit_signer_validation_proof/production_durable_audit_signer_validation_proof.rb` | PASS | `18/18 PASS` |
| 6 | `ruby igniter-lang/experiments/production_durable_audit_bounded_implementation_proof/production_durable_audit_bounded_implementation_proof.rb` | PASS | `29/29 cases`; schema, signer abstraction, append-only store, excluded-surface guards |
| 7 | `ruby igniter-lang/experiments/durable_audit_restart_rebuild_proof/durable_audit_restart_rebuild_proof.rb` | PASS | `21/21 cases`; `6/6` invariant checks |
| 8 | `ruby igniter-lang/experiments/durable_audit_reader_traversal_proof/durable_audit_reader_traversal_proof.rb` | PASS | `26/26 cases`; `4/4` invariant checks |
| 9 | `ruby igniter-lang/experiments/durable_audit_append_reader_role_boundary_proof/durable_audit_append_reader_role_boundary_proof.rb` | PASS | `21/21 cases`; `6/6` invariant checks; `2/2` regression checks |

Matrix result: **9/9 commands PASS**.

Durable audit implementation/rebuild/reader/role-boundary result:
**97/97 proof cases PASS** across the four post-implementation durable audit
scripts.

---

## Required Confirmations

### P-43 rebuild-clean append gate

Status: **PASS / remains enforced**.

Source proof:
`durable_audit_append_reader_role_boundary_proof`.

Confirmed cases:

| Case | Result |
|------|--------|
| `p43.appender_clean_rebuild_allowed` | PASS |
| `p43.appender_failed_rebuild_refused` | PASS |
| `p43.appender_recovery_after_rebuild` | PASS |
| `p43.rebuild_not_clean_code_deterministic` | PASS |
| `invariant.p43_rebuild_gate_code_is_rebuild_not_clean` | PASS |

Required refusal code remains:

```text
audit.writer.rebuild_not_clean
```

Production implication remains unchanged: a production audit append surface must
gate append on clean rebuild status before deployment review can consider it.

### B-B and B-C cumulative state

Status: **closed**.

| Blocker | Closing evidence | Result |
|---------|------------------|--------|
| B-B reader traversal | `durable_audit_reader_traversal_proof` | PASS `26/26`; reader verifies full chain before filters, re-derives posture, refuses mutating/authorizing operations |
| B-C appender/reader role boundary | `durable_audit_append_reader_role_boundary_proof` | PASS `21/21`; appender/reader roles separated, P-43 clean rebuild gate enforced |

Earlier R31/R33 summary files still contain their historical remaining-blocker
lists. This B-D matrix uses the cumulative state: B-A is closed by R33, and
B-B/B-C are closed by R34 proof results rerun above.

### Excluded-surface regression

Status: **PASS / no widening detected**.

The durable audit summary artifacts still report the following excluded surfaces
as false/absent across the rerun matrix:

- Ledger adapter / Ledger writes / replay / compact / subscribe
- Phase 2
- BiHistory
- stream/OLAP production executor
- production cache
- broad RuntimeMachine binding
- production deployment
- concrete HSM/KMS onboarding
- production signing execution
- Gate 3 authorization widening

Reader traversal additionally reports no RuntimeMachine methods exposed by the
reader proof surface, and the role-boundary proof reports no Ledger, Phase 2, or
HSM/KMS access in invariants.

---

## Summary Artifacts

No B-D-owned summary artifact was authored in this card. The matrix reran the
existing proof-owned scripts and regenerated only their own summary artifacts.
Those artifacts remain owned by their respective proof tracks.

Existing summary artifacts consulted:

- `igniter-lang/experiments/production_durable_audit_bounded_implementation_proof/out/production_durable_audit_bounded_implementation_proof_summary.json`
- `igniter-lang/experiments/durable_audit_restart_rebuild_proof/out/durable_audit_restart_rebuild_proof_summary.json`
- `igniter-lang/experiments/durable_audit_reader_traversal_proof/out/durable_audit_reader_traversal_proof_summary.json`
- `igniter-lang/experiments/durable_audit_append_reader_role_boundary_proof/out/durable_audit_append_reader_role_boundary_proof_summary.json`

---

## Recommendation

Recommendation: **ready for B-E Architect deployment review**.

Meaning: B-D is closed and the Architect may open the next review card. This is
not deployment authorization. Production deployment, production signing,
concrete HSM/KMS onboarding, production storage, Ledger binding, Phase 2,
BiHistory, stream/OLAP production execution, production cache, and broad
RuntimeMachine binding remain closed until a later explicit Architect decision.

---

## Handoff

```text
Card: S3-R35-C1-P
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: durable-audit-post-implementation-regression-matrix-v0
Status: done

[D] Decisions
- D1: B-D is a command-matrix closure over existing proof-owned scripts, not a
  new implementation surface.
- D2: No B-D-owned summary artifact was authored; existing proof-owned summaries
  remain the summary source.

[S] Shipped / Signals
- Added this B-D track document with exact command matrix and cumulative
  blocker interpretation.
- Confirmed P-43 clean rebuild append gate remains enforced by
  audit.writer.rebuild_not_clean.
- Confirmed B-B and B-C cumulative state is closed.
- Confirmed no excluded-surface widening.

[T] Tests / Proofs
- 9/9 commands PASS.
- Durable audit post-implementation proof scripts: 97/97 cases PASS.

[R] Risks / Recommendations
- Ready for B-E Architect deployment review.
- Do not treat this as deployment approval.

[Q] Open questions
- None for B-D.
```
