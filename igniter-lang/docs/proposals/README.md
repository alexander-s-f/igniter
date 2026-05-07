# Igniter-Lang Proposals Index

Status: Stage 2 active intake
Maintainer: `[Igniter-Lang Compiler/Grammar Expert]`
Stage 1 closed: 2026-05-06 (META-EXPERT-007)

---

## Accepted — Stage 1 Frozen

All Stage 1 PROPs are frozen and read-only.

→ See [proposals/accepted/](accepted/README.md) — 20 files.

Do not modify accepted PROPs. Errata may be added alongside originals.

---

## Active Intake (Stage 2+)

These proposals are the baseline for Stage 2 implementation work.

| File | Status | Summary |
|------|--------|---------|
| [PROP-002](PROP-002-contract-composition-algebra-v0.md) | proposal | Typed port graph algebra: >>, \|\|, branch, over, embed; algebraic laws |
| [PROP-005](PROP-005-bridge-observation-envelope-v0.md) | proposal | Obs[kind,T] envelope; Identity/Provenance/Policy groups; ObsPacket |
| [PROP-005.1](PROP-005.1-obspacket-patch-lifecycle-verification-v0.md) | patch | ObsPacket v0.1: lifecycle field, :verification_observation, WF-10/11 |
| [PROP-007](PROP-007-conformance-verification-v0.md) | proposal | Verification protocol: 5 check suites, trust levels, agent trust decision |
| [PROP-008](PROP-008-tbackend-contract-v0.md) | proposal | TBackend[T]: read, append, replay, snapshot, compact, subscribe |
| [PROP-010](PROP-010-temporal-lifecycle-retention-semantics-v0.md) | proposal | 6 lifecycle classes, flush semantics, semantic GC roots, downgrade rules |
| [PROP-016](PROP-016-polymorphism-traits-contract-shapes-v0.md) | proposal | Generic contracts, traits, contract_shape, monomorphization |
| [PROP-017](PROP-017-schema-evolution-contract-migration-v0.md) | proposal | SemVer versioning, schema_fingerprint, MigrationDecl, OOF-S1..S5 |
| [PROP-022](PROP-022-history-type-constructor-v0.md) | proposal | **Stage 2**: History[T]/BiHistory[T]; temporal operations; OLAPPoint unification |
| [PROP-023](PROP-023-stream-input-surface-v0.md) | proposal | **Stage 2**: stream T ESCAPE input; window; fold_stream; KPN grounding |
| [PROP-024](PROP-024-olap-point-primitive-v0.md) | proposal | **Stage 2**: OLAPPoint[T,Dims]; olap_point declaration; cluster scatter-gather |
| [PROP-025](PROP-025-invariant-severity-levels-v0.md) | proposal | **Stage 2**: invariant severity :error/:warn/:soft/:metric |
| [PROP-026](PROP-026-parser-oof-hardening-spec-v0.md) | proposal | **Stage 2**: parser OOF ownership/hardening; syntax-owned OOF rules |

---

## Queued (not yet authored)

New Stage 2+ proposals start from **PROP-027**.

| ID | Title | Depends On | Stage | Priority |
|----|-------|------------|-------|----------|
| PROP-027 | Probabilistic types ~T (ProbLog subset) | PROP-022, PROP-025 | 2 | medium |
| PROP-028 | Deadline contracts + WCET analysis | PROP-003, PROP-016 | 3 | medium |
| PROP-029 | Full unit algebra (dimensional type checking) | PROP-004 errata E5 | 3 | medium |
| PROP-030 | Plastic Runtime Cells (ownership + migration) | PROP-006, PROP-012 | 3 | medium |
| PROP-031 | Rule synthesis via LP (goal-directed) | PROP-022, PROP-025 | 4 | low |

---

## Stage 2 Deferred Gaps (from Stage 1 close)

These are tracked here until a Stage 2 PROP is authored to address them:

```
production_compiler_assembly  Production CLI compiler package (not just proof experiments)
```

---

## Proposal Lifecycle

```
authored → proposal → verification (experiment) → approved → spec chapter → implementation
```

During Stage 2: `proposals/` is the active intake directory.
New proposals: start from PROP-027.
Accepted Stage 1 PROPs: see `accepted/` — read-only.
