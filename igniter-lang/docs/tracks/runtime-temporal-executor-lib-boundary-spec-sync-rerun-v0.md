# Track: Runtime Temporal Executor Lib Boundary Spec Sync Rerun v0

Card: S3-R17-C2-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `runtime-temporal-executor-lib-boundary-spec-sync-rerun-v0`
Status: done
Date: 2026-05-09
Depends on: S3-R16-C1-P

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Bridge Agent]`, `[Igniter-Lang Status Curator]`

---

## Goal

Rerun the Ch7/runtime spec sync after S3-R16-C1-P landed
`IgniterLang::TemporalExecutor::Phase1` in `lib/`.

---

## Inputs Read

- `docs/tracks/stage3-round16-status-curation-v0.md`
- `docs/tracks/runtime-temporal-executor-lib-prep-v0.md`
- `docs/tracks/runtime-temporal-executor-lib-boundary-spec-sync-v0.md`
- `lib/igniter_lang/temporal_executor.rb`
- `docs/spec/ch7-runtime.md`

---

## Decisions

[D] `IgniterLang::TemporalExecutor::Phase1` is stable enough to name in Ch7 as
a proof-local implementation boundary.

[D] The boundary is not a language semantic. It does not add parser syntax,
SemanticIR node kinds, Ledger binding, production cache, stream/OLAP execution,
or a general temporal executor contract.

[D] Ch7 now records the required construction default:

```text
gate3_authorized: false
```

The default preserves the live-read block.

[D] Ch7 now records the lib boundary guard order:

```text
approval_token -> gate_state -> scope -> TEMPORAL cache-key schema -> execution kernel
```

[D] Ch7 now records that the boundary must build or attach one composed
CompatibilityReport-shaped result for every evaluation path, validate the
ExecutorApprovalToken before the gate check, and require exact
`authority_ref` match against the Gate 3 decision authority.

---

## Spec Sync

[S] Updated `docs/spec/ch7-runtime.md`:

- status/evidence now includes S3-R16 proof-local lib boundary;
- §7.3 clarifies that `Phase1` exists but live reads remain blocked;
- §7.8 adds `Phase 1 Lib Boundary`;
- proof evidence includes `temporal_executor_lib_prep`;
- evidence references include `runtime-temporal-executor-lib-prep-v0.md`.

---

## Non-Authorization

[X] No live-read authorization.

[X] No parser/syntax changes.

[X] No SemanticIR changes.

[X] No Ledger, BiHistory, stream/OLAP executor, or production cache expansion.

---

## Remaining Spec-Lag Notes

[R] `phase1-lib-prep-regression-chain-v0` still needs a post-C1 rerun before
safety/addendum routing.

[R] No R16 lib-prep safety-pressure verdict was discovered. Run
`runtime-temporal-executor-lib-prep-safety-pressure-v0` before any live-read
decision addendum.

[R] Ch7 keeps `runtime.temporal_scope_exclusion` as the canonical closed-scope
reason. The current lib class also exposes proof-local narrower reason codes
such as `runtime.non_temporal_not_covered` and
`runtime.temporal_executor_bihistory_excluded`; reconcile canonical aliases
before any production/live-read route.

[R] `temporal_live_read_observation` is in-memory/proof-local. Durable
observation persistence remains separate future work.

---

## Validation

```text
git diff --check -- docs/spec/ch7-runtime.md docs/tracks/runtime-temporal-executor-lib-boundary-spec-sync-rerun-v0.md
ruby experiments/temporal_executor_lib_prep/temporal_executor_lib_prep.rb
```

Result:

```text
PASS temporal_executor_lib_prep
17/17 checks PASS
```

---

## Handoff

```text
Card: S3-R17-C2-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: runtime-temporal-executor-lib-boundary-spec-sync-rerun-v0
Status: done

[D] Decisions
- `IgniterLang::TemporalExecutor::Phase1` is stable enough to name in Ch7.
- It is documented as a proof-local implementation boundary, not language
  semantics.
- `gate3_authorized: false` remains the required default and live-read block.

[S] Shipped / Signals
- Updated Ch7 Runtime with the Phase1 lib boundary, guard order, composed report
  requirement, token-before-gate rule, and exact authority_ref match.
- Added this rerun track.

[T] Tests / Proofs
- git diff --check -> PASS.
- ruby igniter-lang/experiments/temporal_executor_lib_prep/temporal_executor_lib_prep.rb -> PASS (17/17).

[R] Risks / Recommendations
- Run post-C1 regression and lib-prep safety pressure before any live-read
  addendum.
- Reconcile proof-local reason-code aliases with canonical
  runtime.temporal_scope_exclusion before production/live use.

[Next]
- phase1-lib-prep-regression-chain-v0 rerun against landed C1.
- runtime-temporal-executor-lib-prep-safety-pressure-v0.
```
