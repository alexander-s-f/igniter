# Track: Runtime Temporal Scope Exclusion Reason Alias v0

Card: S3-R18-C3-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `runtime-temporal-scope-exclusion-reason-alias-v0`
Status: done
Date: 2026-05-09

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Bridge Agent]`, runtime/safety pressure lane

---

## Goal

Reconcile proof-local `IgniterLang::TemporalExecutor::Phase1` reason codes with
the canonical PROP-030A refusal:

```text
runtime.temporal_scope_exclusion
```

---

## Inputs Read

- `docs/proposals/PROP-030A-temporal-scope-exclusion-errata-v0.md`
- `docs/tracks/temporal-scope-exclusion-runtime-fixture-v0.md`
- `lib/igniter_lang/temporal_executor.rb`
- `docs/spec/ch7-runtime.md`

Neighbor awareness after validation:

- `docs/tracks/temporal-executor-proof-local-docstring-amendment-v0.md` was
  present as an untracked neighbor track and was left untouched. It records the
  adjacent proof-local warning/comment amendment lane.

---

## Decision

[D] Consolidate new lib emissions to the canonical reason code.

Reason: PROP-030A and the S3-R14 runtime fixture both define
`runtime.temporal_scope_exclusion` as the canonical refusal for CORE,
BiHistory, STREAM, OLAP, Ledger, and unknown surfaces that reach a TEMPORAL
executor outside the approved Phase 1 scope.

[D] Keep the old narrow strings as legacy diagnostic aliases only:

| Legacy/narrow code | Canonical code |
| --- | --- |
| `runtime.non_temporal_not_covered` | `runtime.temporal_scope_exclusion` |
| `runtime.temporal_executor_bihistory_excluded` | `runtime.temporal_scope_exclusion` |
| `runtime.temporal_executor_core_refusal` | `runtime.temporal_scope_exclusion` |

[D] Cache mismatch, approval-token failures, and gate-closed failures remain
separate reason families. This slice does not collapse them into scope
exclusion.

---

## Shipped

[S] Updated `lib/igniter_lang/temporal_executor.rb`:

- added `ReasonCode::SCOPE_EXCLUSION`;
- made `NON_TEMPORAL`, `BIHISTORY_EXCLUDED`, and `CORE_REFUSAL` emit the
  canonical value;
- added `ReasonCode::LEGACY_ALIASES`;
- added minimal `context` fields for non-temporal and BiHistory scope refusals.

[S] Updated `docs/spec/ch7-runtime.md` with the legacy alias table.

---

## Non-Authorization

[X] No live reads.

[X] No parser/syntax changes.

[X] No SemanticIR changes.

[X] No Ledger, BiHistory, stream/OLAP executor, or production cache expansion.

---

## Remaining Diagnostic Gaps

[R] The proof-local lib boundary now canonicalizes emitted reason codes, but
full PROP-030A diagnostic envelope fields are still partial in lib:
`artifact_ref` and `contract_ref` are not available because `Phase1` currently
accepts a pre-loaded contract hash, not an `.igapp/` artifact envelope.

[R] Kernel-level refusals should eventually carry the same `operation_check`
shape as preflight refusals. Current proof behavior remains safe, but the
envelope shape is not fully uniform.

[R] STREAM/OLAP/Ledger unknown-surface cases are proven by the
`temporal_scope_exclusion_runtime_fixture`; `Phase1` currently handles only the
surfaces that can reach its narrow contract-hash API.

---

## Validation

```text
ruby -c igniter-lang/lib/igniter_lang/temporal_executor.rb -> Syntax OK
ruby igniter-lang/experiments/temporal_executor_lib_prep/temporal_executor_lib_prep.rb -> PASS (17/17)
ruby igniter-lang/experiments/temporal_scope_exclusion_runtime_fixture/temporal_scope_exclusion_runtime_fixture.rb -> PASS
git diff --check -- igniter-lang/lib/igniter_lang/temporal_executor.rb igniter-lang/docs/spec/ch7-runtime.md igniter-lang/docs/tracks/runtime-temporal-scope-exclusion-reason-alias-v0.md -> PASS
```

---

## Handoff

```text
Card: S3-R18-C3-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: runtime-temporal-scope-exclusion-reason-alias-v0
Status: done

[D] Decisions
- Consolidated lib out-of-scope emissions to
  runtime.temporal_scope_exclusion.
- Kept old narrow strings as legacy aliases only.
- Approval, gate-closed, and cache-schema diagnostics remain separate.

[S] Shipped / Signals
- Updated TemporalExecutor reason constants and context.
- Updated Ch7 alias table.
- Added this track.

[T] Tests / Proofs
- ruby -c igniter-lang/lib/igniter_lang/temporal_executor.rb
- ruby igniter-lang/experiments/temporal_executor_lib_prep/temporal_executor_lib_prep.rb
- ruby igniter-lang/experiments/temporal_scope_exclusion_runtime_fixture/temporal_scope_exclusion_runtime_fixture.rb
- git diff --check

[R] Risks / Recommendations
- Full PROP-030A artifact_ref/contract_ref envelope needs loaded-artifact
  context in a later runtime wiring slice.
- Kernel refusals should eventually expose uniform operation_check metadata.

[Next]
- Post-C1 regression rerun should include the updated lib-prep summary.
- Runtime safety pressure can now treat scope-exclusion code drift as closed.
```
