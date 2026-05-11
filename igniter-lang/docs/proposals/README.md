# Igniter-Lang Proposals Index

Status: Stage 3 active intake
Maintainer: `[Igniter-Lang Compiler/Grammar Expert]`
Stage 1 closed: 2026-05-06 (META-EXPERT-007)
Stage 2 closed: 2026-05-07 (META-EXPERT-009.1)

---

## Accepted — Stage 1 Frozen

All Stage 1 PROPs are frozen and read-only.

→ See [proposals/accepted/](accepted/README.md) — 20 files.

Do not modify accepted PROPs. Errata may be added alongside originals.

---

## Stage 2 — Closed (2026-05-07)

Stage 2 PROPs are closed when their experiment reached PASS verdict in META-EXPERT-009.1.
Closed PROPs remain in `proposals/` for reference. They are not moved to `accepted/`
(that directory is Stage 1 only).

| File | Status | Summary |
|------|--------|---------|
| [PROP-022](PROP-022-history-type-constructor-v0.md) | closed | History[T]/BiHistory[T]; temporal operations; Stage 2 experiment PASS (META-EXPERT-009.1); Stage 3 extensions: PROP-028, PROP-022A |
| [PROP-023](PROP-023-stream-input-surface-v0.md) | closed | stream T; window; fold_stream; KPN grounding; Stage 2 experiment PASS (META-EXPERT-009.1) |
| [PROP-024](PROP-024-olap-point-primitive-v0.md) | closed | OLAPPoint[T,Dims]; olap_point declaration; Stage 2 experiment PASS (META-EXPERT-009.1) |
| [PROP-025](PROP-025-invariant-severity-levels-v0.md) | closed | invariant severity :error/:warn/:soft/:metric; Stage 2 experiment PASS (META-EXPERT-009.1) |
| [PROP-026](PROP-026-parser-oof-hardening-spec-v0.md) | closed | Parser OOF hardening; PH-1..PH-8, PF-1..PF-4; Stage 2 experiment PASS (META-EXPERT-009.1) |
| [PROP-027](PROP-027-production-compiler-diagnostics-contract-v0.md) | closed | Production compiler CLI + diagnostics contract; CL-1..CL-10; Stage 2 experiment PASS (META-EXPERT-009.1) |

---

## Stage 3 — Active

| File | Status | Summary |
|------|--------|---------|
| [PROP-028](PROP-028-temporal-fragment-class-v0.md) | implementation-partial | TEMPORAL fragment class; classifier/typechecker/SemanticIR/assembler/load-guard proven (S3-R2..R5); parser syntax + production runtime pending |
| [PROP-022A](PROP-022A-temporal-manifest-errata-v0.md) | experiment-pass | Errata to accepted/PROP-022A: TEMPORAL manifest contract_index + fragment_summary; assembler PASS (S3-R5-C1) |
| [PROP-029](PROP-029-entrypoint-section-surface-v0.md) | proposal | Entrypoint as named evaluation/run profile; section as grouping-only source organization; no parser implementation yet |
| [PROP-030](PROP-030-executor-approval-token-contract-v0.md) | proposal | ExecutorApprovalToken contract; explicit approval as Gate 3 prerequisite; no executor or Gate 3 authorization |
| [PROP-030A](PROP-030A-temporal-scope-exclusion-errata-v0.md) | proposal | Errata to PROP-030: canonical `runtime.temporal_scope_exclusion` refusal for out-of-scope TEMPORAL executor artifacts |
| [PROP-031](PROP-031-contract-modifiers-v0.md) | experiment-pass | Contract modifiers: optional `pure/observed/effect/privileged/irreversible` prefix, implicit pure default, OOF-M1 only; parser/classifier/typechecker/SemanticIR proof PASS; no Effect Surface/Profile/authority/runtime enforcement |
| [PROP-032](PROP-032-assumptions-block-v0.md) | proposal | `assumptions {}` block + `uses assumptions NAME` declaration; new `epistemic` fragment class; OOF-A1; evidence + receipt propagation; Covenant P22/P27/P28. GI-1 resolution: supersedes prior queue assignment of PROP-032 to `via profile binding` |
| [PROP-036](PROP-036-compiler-profile-manifest-identity-v0.md) | proposal | `compiler_profile_id` manifest identity; unified compiler profile id; legacy_optional/profile_required rollout; no `.igapp` mutation, loader/assembler/runtime binding, dispatch migration, or runtime execution authority |

---

## Stage 2+ — Open Proposals (authored, not yet experiment-PASS)

These proposals were authored in Stage 2 but their experiments have not yet reached PASS.
They remain active intake. Verification requires Architect authorization.

| File | Status | Summary |
|------|--------|---------|
| [PROP-002](PROP-002-contract-composition-algebra-v0.md) | proposal | Typed port graph algebra: >>, \|\|, branch, over, embed; algebraic laws |
| [PROP-005](PROP-005-bridge-observation-envelope-v0.md) | proposal | Obs[kind,T] envelope; Identity/Provenance/Policy groups; ObsPacket |
| [PROP-005.1](PROP-005.1-obspacket-patch-lifecycle-verification-v0.md) | patch | ObsPacket v0.1: lifecycle field, :verification_observation, WF-10/11 |
| [PROP-007](PROP-007-conformance-verification-v0.md) | proposal | Verification protocol: 5 check suites, trust levels, agent trust decision |
| [PROP-008](PROP-008-tbackend-contract-v0.md) | proposal | TBackend[T]: read, append, replay, snapshot, compact, subscribe; descriptor fixture PASS (Stage 2); live binding gated (Gate 3 closed) |
| [PROP-010](PROP-010-temporal-lifecycle-retention-semantics-v0.md) | proposal | 6 lifecycle classes, flush semantics, semantic GC roots, downgrade rules |
| [PROP-016](PROP-016-polymorphism-traits-contract-shapes-v0.md) | proposal | Generic contracts, traits, contract_shape, monomorphization |
| [PROP-017](PROP-017-schema-evolution-contract-migration-v0.md) | proposal | SemVer versioning, schema_fingerprint, MigrationDecl, OOF-S1..S5 |

---

## Queued (not yet authored)

PROP-032 is authored (assumptions block). New Stage 3+ proposal IDs should start from **PROP-033**.

**Queue renumbering (GI-1 resolution, S3-R30-C6-P):** PROP-032 was previously assigned to
`via profile binding`. It is now PROP-032 = `assumptions {}` block. All downstream IDs shift +1.

**PROP-036 assignment (S3-R33-C3-A, authored S3-R34-C5-P):** PROP-036 is assigned
to and authored for `compiler_profile_id` manifest identity. It remains proposal
only: no implementation, `.igapp` mutation, loader/assembler/runtime binding,
dispatch migration, or runtime execution authority. Managed recursion / service
loop placeholders must use PROP-037+ or later until formally assigned.

| ID | Title | Depends On | Stage | Priority |
|----|-------|------------|-------|----------|
| PROP-033 | `via profile binding` | PROP-031 | 3 | high |
| PROP-034 | `output evidence syntax` | PROP-031, PROP-032 | 3 | high |
| PROP-035 | profile declarations / authority resolution | PROP-031, PROP-033 | 3 | medium |
| PROP-037+ | managed recursion / service loops placeholder | future routing decision; PROP-036 unavailable | 4+ | unassigned |
| TBD | Effect Surface | PROP-031 | 3 | medium |
| TBD | Prior queued ideas need renumbering/requeue | — | 3+ | medium |

---

## Deferred Gaps Register

```
Stage 1 deferred gap:
  production_compiler_assembly  → RESOLVED in Stage 2 (PROP-027 + S2-R13 compiler package PASS)

Stage 2 deferred gaps (carried to Stage 3 — see current-status.md §Deferred Gaps):
  production_tbackend_adapter_binding  — Gate 3 closed; live Ledger reads not yet authorized
  olap_distributed_execution           — OLAP scatter/gather, rollup: not yet authorized
  invariant_persistence                — runtime violation observation persistence: open (S3 Runtime lane)
  deferred_invariant_oofs             — OOF-I1 (@bitemporal), OOF-I3 (~T), OOF-I5: deferred
  gem_release_readiness                — publish not yet attempted; release gate PASS (S3-R3-C4)
```

---

## Proposal Lifecycle

```
authored → proposal → experiment (verification) → experiment-pass → closed
                                                ↓
                                       implementation-partial
                                       (partial implementation in progress)
```

Status vocabulary for this directory:

```
proposal              authored; not yet experiment-verified
patch                 errata patch on an existing proposal
experiment-pass       experiment PASS; not yet formally closed (errata and partial-scope PROPs)
implementation-partial experiment PASS + partial implementation proven; open items remain
closed                all authorized scope experiment-PASS; META-EXPERT decision recorded
```

Stage 1 PROPs: see `accepted/` — frozen read-only.
Stage 2 closed PROPs: in `proposals/` with `Status: closed`.
New Stage 3 proposal IDs must consult the queued table above. PROP-033 through
PROP-035 are reserved there; PROP-036 is authored for compiler profile manifest
identity; managed recursion / service loops use PROP-037+ as placeholder only
until formal assignment.
