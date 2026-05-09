# Track: Runtime Temporal Executor Lib Boundary Spec Sync v0

Card: S3-R16-C3-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `runtime-temporal-executor-lib-boundary-spec-sync-v0`
Status: blocked / no-op
Date: 2026-05-09
Depends on: S3-R16-C1-P

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Bridge Agent]`

---

## Goal

Sync runtime docs only if S3-R16-C1-P introduces a stable lib boundary name or
public runtime component for the Phase 1 temporal executor path.

---

## Dependency Check

[D] S3-R16-C1-P is not landed in the current workspace.

Searches performed:

```text
rg -n "S3-R16-C1|runtime-temporal-executor-lib-prep|Phase1TemporalExecutor|TemporalExecutor|runtime temporal executor|lib boundary|live reads|live-read" igniter-lang/docs igniter-lang/lib igniter-lang/experiments
rg --files igniter-lang/docs/tracks igniter-lang/lib igniter-lang/experiments | rg 'lib-prep|temporal.*executor|runtime.*temporal|phase1'
rg -n "S3-R16|runtime-temporal-executor-lib-boundary|runtime-temporal-executor-lib-prep|lib-prep" igniter-lang/docs/tracks igniter-lang/docs/current-status.md igniter-lang/docs/agent-context.md igniter-lang/docs/gates igniter-lang/docs/spec/ch7-runtime.md
```

Observed state:

```text
S3-R16-C1-P track: not found
runtime-temporal-executor-lib-prep-v0 track: not found
Phase1TemporalExecutor remains experiments-local in existing preflight tracks
S3-R16-C2-P regression track is blocked because C1 is not landed
```

The current `lib/` runtime temporal surface is still the earlier
`IgniterLang::TemporalAccessRuntime::RuntimeMachineHook` / evaluator boundary
from S2 runtime hook work. It is not a newly introduced S3-R16-C1 Phase 1
executor boundary.

---

## Spec Decision

[D] No Ch7 Runtime spec edit is made in this slice.

Reason:

```text
No C1 deliverable exists to name a stable Phase 1 executor lib component.
No new public runtime component can be documented as an implementation boundary.
Ch7 already preserves the approved-restricted Phase 1 state and live-read block.
```

[D] This no-op preserves the live-read block exactly as-is:

```text
Phase 1 implementation-prep may proceed, but live reads remain blocked until a
prepared boundary proves the same AT/report/scope constraints and a later route
explicitly authorizes live-read enablement.
```

[D] No parser, syntax, SemanticIR, runtime executor, Ledger, BiHistory,
stream/OLAP executor, or production cache semantics are changed.

---

## Remaining Spec-Lag Notes

[R] After S3-R16-C1-P lands, rerun this card against the actual C1 deliverables.

[R] If C1 introduces a named lib component, Ch7 should document it narrowly as
an implementation boundary, not a language semantic:

```text
component name
allowed Phase 1 scope: History[T] valid_time only
required composed CompatibilityReport input
approval-token-before-gate ordering
authority_ref exact-match requirement
runtime.temporal_scope_exclusion refusal for closed scopes
temporal_read_observation requirement for any later authorized live read
live-read block remains unless separately authorized
```

[R] If C1 remains proof-local or unnamed, keep Ch7 unchanged and record another
no-op.

---

## Handoff

```text
Card: S3-R16-C3-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: runtime-temporal-executor-lib-boundary-spec-sync-v0
Status: blocked / no-op

[D] Decisions
- S3-R16-C1-P is not landed in the current workspace.
- No stable C1 lib boundary name or public runtime component is available.
- Ch7 Runtime stays unchanged; live-read block is preserved.

[S] Shipped / Signals
- Added this no-op track to prevent speculative Ch7 drift.
- Confirmed existing lib temporal hook is pre-C1 and not a new S3-R16 executor
  boundary.

[T] Tests / Proofs
- Docs-only no-op.
- No runtime/proof commands were run because the dependency is absent.

[R] Risks / Recommendations
- HOLD spec sync until C1 lands.
- When C1 lands, update Ch7 only if it names a stable implementation boundary.

[Next]
- S3-R16-C1-P runtime-temporal-executor-lib-prep-v0, then rerun C3.
```
