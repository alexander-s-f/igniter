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

New Stage 3+ proposals start from **PROP-029**.

| ID | Title | Depends On | Stage | Priority |
|----|-------|------------|-------|----------|
| PROP-029 | Probabilistic types ~T (ProbLog subset) | PROP-022 (closed), PROP-025 (closed) | 3 | medium |
| PROP-030 | Deadline contracts + WCET analysis | PROP-003 (accepted), PROP-016 | 3 | medium |
| PROP-031 | Full unit algebra (dimensional type checking) | PROP-004 errata E5 | 3 | medium |
| PROP-032 | Plastic Runtime Cells (ownership + migration) | PROP-006 (accepted), PROP-012 (accepted) | 3 | medium |
| PROP-033 | Rule synthesis via LP (goal-directed) | PROP-022 (closed), PROP-025 (closed) | 4 | low |

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
New Stage 3 proposals: start from PROP-029.
