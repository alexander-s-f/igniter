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
| [PROP-022](PROP-022-history-type-constructor-v0.md) | accepted | History[T]/BiHistory[T]; temporal operations; Stage 2 experiment PASS (META-EXPERT-009.1); Stage 3 extensions: PROP-028, PROP-022A |
| [PROP-023](PROP-023-stream-input-surface-v0.md) | accepted | stream T; window; fold_stream; KPN grounding; Stage 2 experiment PASS (META-EXPERT-009.1) |
| [PROP-024](PROP-024-olap-point-primitive-v0.md) | accepted | OLAPPoint[T,Dims]; olap_point declaration; Stage 2 experiment PASS (META-EXPERT-009.1) |
| [PROP-025](PROP-025-invariant-severity-levels-v0.md) | accepted | invariant severity :error/:warn/:soft/:metric; Stage 2 experiment PASS (META-EXPERT-009.1); OOF-I1/I3/I5 deferred |
| [PROP-026](PROP-026-parser-oof-hardening-spec-v0.md) | accepted | Parser OOF hardening; PH-1..PH-8, PF-1..PF-4; Stage 2 experiment PASS (META-EXPERT-009.1) |
| [PROP-027](PROP-027-production-compiler-diagnostics-contract-v0.md) | accepted | Production compiler CLI + diagnostics contract; CL-1..CL-10; Stage 2 experiment PASS (META-EXPERT-009.1) |

---

## Stage 3 — Active

| File | Status | Summary |
|------|--------|---------|
| [PROP-028](PROP-028-temporal-fragment-class-v0.md) | implemented-proof | TEMPORAL fragment class; classifier/typechecker/SemanticIR/assembler/load-guard proven (S3-R2..R5); parser syntax + production runtime pending |
| [PROP-022A](PROP-022A-temporal-manifest-errata-v0.md) | experiment-pass | Errata to accepted/PROP-022A: TEMPORAL manifest contract_index + fragment_summary; assembler PASS (S3-R5-C1) |
| [PROP-029](PROP-029-entrypoint-section-surface-v0.md) | authored-pending-review | Entrypoint as named evaluation/run profile; section as grouping-only source organization; no parser implementation yet |
| [PROP-030](PROP-030-executor-approval-token-contract-v0.md) | authored-pending-review | ExecutorApprovalToken contract; explicit approval as Gate 3 prerequisite; no executor or Gate 3 authorization |
| [PROP-030A](PROP-030A-temporal-scope-exclusion-errata-v0.md) | authored-pending-review | Errata to PROP-030: canonical `runtime.temporal_scope_exclusion` refusal for out-of-scope TEMPORAL executor artifacts |
| [PROP-031](PROP-031-contract-modifiers-v0.md) | experiment-pass | Contract modifiers: optional `pure/observed/effect/privileged/irreversible` prefix, implicit pure default, OOF-M1 only; parser/classifier/typechecker/SemanticIR proof PASS; no Effect Surface/Profile/authority/runtime enforcement |
| [PROP-032](PROP-032-assumptions-block-v0.md) | implemented-proof | `assumptions {}` block + `uses assumptions NAME`; Phase 1/2/3/4 compiler proofs landed; experiment-pass governance decision still open |
| [PROP-036](PROP-036-compiler-profile-manifest-identity-v0.md) | accepted | `compiler_profile_id` manifest identity; accepted proposal-only by S3-R35-C3-A; separate implementation authorization required before code |

---

## Stage 2+ — Open Proposals (authored, not yet experiment-PASS)

These proposals were authored in Stage 2 but their experiments have not yet reached PASS.
They remain active intake. Verification requires Architect authorization.

| File | Status | Summary |
|------|--------|---------|
| [PROP-002](PROP-002-contract-composition-algebra-v0.md) | authored-pending-review | Typed port graph algebra: >>, \|\|, branch, over, embed; algebraic laws |
| [PROP-005](PROP-005-bridge-observation-envelope-v0.md) | authored-pending-review | Obs[kind,T] envelope; Identity/Provenance/Policy groups; ObsPacket |
| [PROP-005.1](PROP-005.1-obspacket-patch-lifecycle-verification-v0.md) | authored-pending-review | Patch document: ObsPacket v0.1 lifecycle field, :verification_observation, WF-10/11 |
| [PROP-007](PROP-007-conformance-verification-v0.md) | authored-pending-review | Verification protocol: 5 check suites, trust levels, agent trust decision |
| [PROP-008](PROP-008-tbackend-contract-v0.md) | implemented-proof | TBackend[T]: read, append, replay, snapshot, compact, subscribe; descriptor fixture PASS (Stage 2); live binding gated (Gate 3 closed) |
| [PROP-010](PROP-010-temporal-lifecycle-retention-semantics-v0.md) | authored-pending-review | 6 lifecycle classes, flush semantics, semantic GC roots, downgrade rules |
| [PROP-016](PROP-016-polymorphism-traits-contract-shapes-v0.md) | authored-pending-review | Generic contracts, traits, contract_shape, monomorphization |
| [PROP-017](PROP-017-schema-evolution-contract-migration-v0.md) | authored-pending-review | SemVer versioning, schema_fingerprint, MigrationDecl, OOF-S1..S5 |

---

## Queued (not yet authored)

PROP-032 is authored and partially implemented by proof (assumptions block). New Stage 3+
proposal IDs must consult this queue before claiming a number.

**Queue renumbering (GI-1 resolution, S3-R30-C6-P):** PROP-032 was previously assigned to
`via profile binding`. It is now PROP-032 = `assumptions {}` block. All downstream IDs shift +1.

**PROP-036 lifecycle:** S3-R33-C3-A assigns PROP-036 to `compiler_profile_id`
manifest identity, S3-R34-C5-P authors the proposal, and S3-R35-C3-A accepts it
as proposal-only. It still authorizes no implementation, `.igapp` mutation,
loader/assembler/runtime binding, dispatch migration, or runtime execution
authority.

**PROP-037 assignment (S3-R35-C4-A):** PROP-037 is assigned to external
progression and service liveness semantics. This is numbering-only: the proposal
is not authored or accepted yet, and no parser, TypeChecker, SemanticIR,
RuntimeMachine scheduler, Ledger/TBackend, durable queue, production execution,
ProgressionPack migration, or new fragment class is authorized. Managed local
recursion / loop-class extension placeholders must use PROP-038+ or later until
formally assigned.

| ID | Title | Depends On | Stage | Priority |
|----|-------|------------|-------|----------|
| PROP-033 | `via profile binding` | PROP-031 | 3 | high |
| PROP-034 | `output evidence syntax` | PROP-031, PROP-032 | 3 | high |
| PROP-035 | profile declarations / authority resolution | PROP-031, PROP-033 | 3 | medium |
| PROP-037 | external progression and service liveness semantics | PROP-023, Ch13 managed recursion, R34 progression scope draft | 3 | high |
| PROP-038+ | managed local recursion / loop-class extensions placeholder | future routing decision; PROP-037 owns progression/service liveness | 4+ | unassigned |
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

```text
draft -> authored-pending-review -> accepted / conditional-accepted
                                      |
                                      v
                              implemented-proof -> experiment-pass
                                      |
                                      v
                                  deferred
```

### Lifecycle Labels

Use these labels in the proposal index `Status` column. Track status is a separate
namespace: `Track: done` means the assigned card delivered its artifact; it does
not mean the proposal is accepted, implemented, or experiment-pass.

| Label | Meaning | Authority / evidence |
|-------|---------|----------------------|
| `draft` | Working text, scope packet, or proposal sketch exists, but no formal proposal file is indexed as the review target | Track evidence or discussion routing |
| `authored-pending-review` | Formal proposal file exists and is indexed; governance has not accepted or rejected it | Proposal file + track handoff |
| `accepted` | Governance accepted the proposal scope | Architect / Meta close decision; implementation may still require a separate card |
| `conditional-accepted` | Governance accepts direction with named blockers, exclusions, or required edits | Gate / decision record with explicit conditions |
| `implemented-proof` | Authorized implementation/proof landed for part or all of the proposal, but full experiment-pass or closure is still open | Track proof, golden, or matrix evidence |
| `experiment-pass` | Verification matrix for the accepted proposal scope passed; the proposal can be closed/frozen by the owning governance flow | PASS evidence + proposal/track reference |
| `deferred` | Proposal or sub-scope is intentionally postponed; not active implementation work | Stage close decision, gate, or explicit routing note |

Historical aliases:

- `proposal` in older docs means `authored-pending-review`.
- `implementation-partial` means `implemented-proof`.
- `closed` is a stage/archive map state; the proposal lifecycle label should name
  the evidence state (`accepted` or `experiment-pass`) instead.
- `patch` is a document type, not a lifecycle status.

Stage 1 PROPs: see `accepted/` — frozen read-only.
Stage 2 closed PROPs: in `proposals/` with lifecycle label `accepted`.
New Stage 3 proposal IDs must consult the queued table above. PROP-033 through
PROP-035 are reserved there; PROP-036 is accepted proposal-only for compiler
profile manifest identity; PROP-037 is assigned to external progression and
service liveness semantics; managed local recursion / loop-class extensions use
PROP-038+ as placeholder only until formal assignment.
