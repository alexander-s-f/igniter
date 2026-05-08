# Discussion: Stage 3 Round 8 Pre-Gate-3 Pressure

Card: S3-R8-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: stage3-round8-pre-gate3-pressure-v0
Date: 2026-05-08
Status: complete — routed

---

## Question

Are S3-R8 C1 and C2 sufficient as a pre-Gate-3 runtime boundary, or are there
silent risks in guard policy enforcement, capability flags, temporal cache
interaction, or the report/runtime consistency layer?

## Context: S3-R8 C1–C2 Summary

**C1** `runtime-smoke-post-switch-full-coverage-v0` closed the six-surface gap
from S3-R7-X1-S:

| Surface | Smoke result |
|---------|-------------|
| CORE Add/compute | PASS — RuntimeMachine evaluates 19+23→42, trusted |
| `stream_fold` | PASS — finite replay folds to 24 |
| `OLAPPoint` | PASS — synthetic facts aggregate to Decimal "20.00" |
| History[T] single-axis | PASS — loads for inspection; eval refuses structured |
| BiHistory[T] bitemporal | PASS — loads for inspection; eval refuses structured |
| invariant severity | PASS — typed fixture loads; error invariant satisfied, warn emits |
| C1 CompatibilityReport cross-check | PASS — History report: load accepted, eval blocked |

No uncovered surfaces.

**C2** `runtime-compatibility-report-executor-boundary-v0` closed the missing
positive-executor gap from S3-R7-X1-S by adding two runtime profiles to the
C1 (R7) proof:

| Profile | Evaluation readiness | Reason code |
|---------|---------------------|-------------|
| `missing_tbackend_capability` | blocked | `runtime.temporal_capability_missing` |
| `metadata_capability_no_executor` | blocked | `runtime.temporal_execution_unsupported` |
| `claimed_executor_live_binding` | blocked | `runtime.temporal_executor_approval_missing` |
| `approved_executor_placeholder` | blocked | `runtime.temporal_gate3_closed` |

`operation_check` fields confirm: no executor, TBackend, or Ledger call was
attempted in any profile. `report_only: true`, `runtime_enforced: false` for all.

---

## Evidence Base

```text
igniter-lang/docs/tracks/runtime-smoke-post-switch-full-coverage-v0.md
igniter-lang/docs/tracks/runtime-compatibility-report-executor-boundary-v0.md
igniter-lang/docs/agent-context.md
igniter-lang/docs/current-status.md
igniter-lang/docs/value-index.md
igniter-lang/docs/discussions/runtime-compatibility-and-typed-delta-pressure-v0.md
```

---

## [Agree]

**C1 smoke closes the six-surface regression baseline.**

All surfaces that `emit_typed` can lower now have a post-switch runtime
path confirmation. The smoke covers the full fragment class hierarchy:
CORE (Add), STREAM (stream_fold), OLAP (OLAPPoint), TEMPORAL History,
TEMPORAL BiHistory, and CORE-with-invariants. No uncovered surfaces remain.

This is the right baseline before Gate 3 is opened — it confirms the
production compiler switch did not regress any currently proven surface.

**C2 decision table is the correct shape for a future Gate 3 authorization.**

The four-level profile table (no capability → metadata only → claimed executor
→ approved but gate closed) proves a progression of increasing executor state
where evaluation remains blocked at every step. Each level has its own
structured reason code. This is the right contract to hand a Gate 3 designer:
here is what you must satisfy at each level before evaluation is permitted.

The `operation_check` negative contract (`temporal_executor_call_attempted:
false`, `live_tbackend_call_attempted: false`, `ledger_call_attempted: false`)
is especially valuable — it is machine-readable proof that the current proof
surface does not accidentally invoke any live operation, even under profiles
that claim executor and binding presence.

**value-index.md captures the right durable signals.**

"CompatibilityReport Is Report-Only Before Gate 3" and "Full Post-Switch Smoke
Is The Runtime Regression Baseline" are both hoisted into `value-index.md`.
Future agents will find these signals without archaeology. Combined with the
spec ch7 sync (S3-R6) and current-status Gate 3 entry ("CLOSED — no Ledger
read/write/replay/runtime binding"), the gate state is visible from multiple
reinforcing layers.

**Gate 3 boundary is now explicit from three independent angles:**

1. spec ch7 §7.8 (`load_accept_evaluate_refuse` policy)
2. CompatibilityReport shape (C1 R7 + C2 R8: `evaluation_readiness: blocked`)
3. Full smoke (C1 R8: structured refusal for all TEMPORAL surfaces)

---

## [Challenge]

### C-1. stream_fold smoke uses proof-local defaults, not assembled SemanticIR metadata

The C1 track acknowledges this explicitly:

> `stream_fold` compile/load works, but runtime smoke still uses proof-local
> defaults for `window.size`, `fold_stream.init`, and `fold_stream.fn_ref`
> because the assembled stream SemanticIR surface does not yet carry all
> runtime replay metadata.

What this means in production terms: a RuntimeMachine trying to evaluate a
`stream_fold` contract by reading the assembled `.igapp/` SemanticIR metadata
would fail or produce undefined behavior — the required runtime replay
metadata (`window.size`, `fold_stream.init`, `fn_ref`) is not in the assembled
artifact.

The smoke PASS for `stream_fold` reflects the current proof-local workaround,
not the full assembled-artifact path. A production evaluator reading the
`.igapp/` directly would need the missing fields. The smoke validates
compile + load correctly; it does not validate that the assembled stream
artifact is complete enough for a future stream executor.

**Severity**: medium for Gate 3 planning. stream_fold evaluation cannot
proceed until the assembled SemanticIR surface carries the full replay
metadata. This is not TEMPORAL-specific, but it is a surface that a future
production runtime would need to evaluate.

### C-2. invariant severity smoke uses a pre-baked typed fixture, not the full source pipeline

The C1 track also acknowledges this:

> Invariant severity runtime smoke uses the existing typed fixture for severity
> metadata. The source-to-classifier metadata preservation question stays with
> Compiler/Grammar; this runtime card does not repair compiler metadata.

In practice: the smoke for `invariant_severity` does not use the full
`.ig` source → Parser → Classifier → TypeChecker → emit_typed path. It uses
a manually authored typed fixture that has severity metadata already embedded.

If the production compiler path doesn't correctly preserve severity metadata
through the Classifier and TypeChecker, the full source-to-runtime path would
fail even though the smoke passes. The smoke confirms the runtime evaluates
severity metadata correctly — it does not confirm the metadata arrives there
from source compilation.

**Severity**: low-medium. A separate Compiler/Grammar slice should verify the
metadata preservation end-to-end. Until then, the invariant severity smoke is
a partial guarantee: runtime handles it correctly *if* the compiler delivers it.

### C-3. `approved_executor_placeholder` has no production definition

C2's fourth profile introduces "explicit executor approval" as a required
condition:

> Evaluation readiness is blocked unless all of the following are true:
> - explicit executor approval is present
> - Gate 3 is authorized

But neither C2 nor any other track defines what "explicit executor approval"
means in production. Is it:

- a field in the `.igapp/` artifact?
- a configuration entry in RuntimeMachine?
- a signed token from an authority?
- a Gate 3 opening record from Architect Supervisor?

The proof models approval as a placeholder flag. A production implementation
built from C2's report shape would need to decide the approval mechanism.
Without that definition, the proof proves a concept that has no implementation
path. The `DOC-DEBT-02` entry in current-status acknowledges "executor
approval token/field" as a follow-up — but it's listed alongside stream replay
metadata and invariant metadata, without distinguishing that the approval token
is a *blocking* design question for Gate 3, not just a doc debt.

**Severity**: medium. Characterizing the approval token as a design question
rather than a doc debt is important — it should be the *first* deliverable
in a Gate 3 request, not a follow-up.

### C-4. report-only enforcement is still fully unchecked in production

Both C1 (R7) and C2 (R8) carry `runtime_enforced: false`. This has been the
state since the first CompatibilityReport work. The three proof layers (C1
report shape, C2 decision table, C1 smoke) all rely on the assumption that
production code will read and honor the report.

Nothing currently enforces that a future RuntimeMachine implementation *must*
check `evaluation_readiness.decision` before calling the executor. The proof
proves the report says the right thing. It does not prove that the report is
consulted.

This is the fundamental design gap that must be closed at Gate 3: the production
RuntimeMachine must be designed to check `evaluation_readiness.decision == blocked`
before attempting any TEMPORAL execution, and to refuse if Gate 3 is closed
regardless of what capability flags are present.

**Severity**: medium at Gate 3 design time. Not a current bug. But if a Gate
3 executor is implemented without this check, the entire C1+C2 report proof
layer provides no runtime protection.

### C-5. No test for cache key construction at the executor boundary

The C2 proof confirms that no executor, TBackend, or Ledger call is attempted
in any profile. But none of the four C2 profiles test what happens to cache
key construction if an executor *is* eventually called.

Specifically: the PROP-028 / value-index "silent staleness" risk is that a
TEMPORAL contract evaluator might construct a CORE-shaped cache key
(`hash(contract_ref, inputs)`) instead of a TEMPORAL key
(`hash(contract_ref, inputs, as_of/Tt)`). The L-T5 gate in the assembler
catches this at assembly time. The CompatibilityReport has a
`cache_key_schema_hint` that carries the correct schema.

But neither C1 nor C2 has a case that says:

```text
if executor proceeds → cache key is TEMPORAL-shaped, not CORE-shaped
if executor constructs CORE key for TEMPORAL contract → L-T5 fault detected
```

The value-index explicitly labels "TEMPORAL Cache Key Must Include Time" as a
durable signal. But the executor boundary proof doesn't test the cache key
interaction. A future executor implementation reading C2 as its reference
would not see a test for this specific class of bug.

**Severity**: low now — no executor exists. HIGH before any executor
implementation begins. This is the exact silent bug class that PROP-028 was
written to prevent.

### C-6. C2 profiles not validated against GuardedRuntimeMachine

The C2 proof tests CompatibilityReport *shape* for four profiles. It confirms
the report says the right thing. But C2 does not pass these profiles through the
GuardedRuntimeMachine from S3-R5-C2 and confirm the two systems produce
consistent answers for the same artifact.

The cross-check in C1 smoke (`compatibility_report_cross_check`) verifies the
C1 (R7) report shape against an existing History summary — but it uses the
two-profile (missing_capability, metadata_only) versions, not the four-profile
(claimed_executor, approved_placeholder) versions added in C2.

This means: for profiles 3 and 4 (claimed executor, approved placeholder),
only the report shape is tested. The GuardedRuntimeMachine response for those
profiles is not tested.

**Severity**: low — the boundary is consistent by design. But the consistency
is architectural, not verified. A regression in GuardedRuntimeMachine that
allows a claimed-executor profile to proceed would not be caught by any current
test.

---

## [Missing]

### M-1. Executor approval token defined as a blocking Gate 3 design question

The current-status DOC-DEBT-02 lists "executor approval token/field" as a
follow-up alongside stream replay metadata and invariant metadata. These are
not equivalent:

- Stream replay metadata and invariant metadata are **implementation details**
  that can be filled in by Research Agent slices without Architect sign-off.
- Executor approval token is a **authorization mechanism** — it determines
  what proof of authority a RuntimeMachine requires before allowing live
  TEMPORAL execution. This decision cannot be made by Research Agent alone.

Needed: the executor approval token should be elevated from DOC-DEBT to a
**Gate 3 request prerequisite**: define the approval mechanism in the Gate 3
opening request before any executor implementation begins.

### M-2. stream_fold assembled replay metadata gap is blocking for stream evaluation

The C1 known gap (`proof-local defaults for window.size, fold_stream.init,
fold_stream.fn_ref`) should be tracked as a blocking dependency for any future
stream_fold production evaluation. Currently it is a `[R]` in the C1 track —
a recommendation, not a named open item.

Needed: route this as a Compiler/Grammar Expert spec-sync candidate:
"stream SemanticIR assembled surface must carry full runtime replay metadata."
Until then, no production evaluator can evaluate `stream_fold` from the
assembled artifact alone.

### M-3. Cache key construction test at executor boundary

Before any Gate 3 executor implementation is authorized, there should be a
proof case that:

1. Takes a TEMPORAL contract through the executor boundary
2. Reads the `cache_key_schema_hint` from `manifest.contract_index`
3. Confirms the executor would construct a TEMPORAL-shaped key
4. Confirms a CORE-shaped key construction is detected as an L-T5 fault

This does not require a live executor. It can be a proof-local case that
simulates executor key construction. The PROP-028 silent staleness risk (§4 of
the original proposal) has been modeled at the assembler level (L-T5 gate) and
at the cache key proof level (S3-R2-C3). It has not been modeled at the
executor boundary level.

### M-4. C2 profiles validated against GuardedRuntimeMachine

The `claimed_executor_live_binding` and `approved_executor_placeholder`
profiles from C2 should have corresponding GuardedRuntimeMachine cases. The
guard machine should confirm:

```text
claimed_executor_profile → GuardedRuntimeMachine.evaluate → evaluation_refusal
  reason: guard_policy=load_accept_evaluate_refuse + no approval token
approved_placeholder → GuardedRuntimeMachine.evaluate → evaluation_refusal
  reason: Gate 3 closed
```

This closes the consistency gap between the CompatibilityReport layer and the
GuardedRuntimeMachine layer for the two new profiles.

---

## [Sharper Question]

Not: "Are C1 and C2 correct?" They are correct and complete for their stated
scope.

The sharper question is:

> **Are the four remaining gaps (executor approval token undefined, stream
> replay metadata missing from assembled artifact, cache key construction
> untested at executor boundary, C2 profiles not validated against
> GuardedRuntimeMachine) individual follow-up tasks, or are they together
> a prerequisite package for a safe Gate 3 opening?**

Proposed answer: **they are a prerequisite package, not independent tasks.**

A Gate 3 opening that proceeds without:
- defining the executor approval token/mechanism
- ensuring stream replay metadata is in the assembled artifact
- testing cache key construction at the executor boundary

...has a realistic path to two classes of silent production bugs:

1. **Authorization gap**: executor runs without a verifiable approval token →
   Gate 3 policy bypassed by capability flags alone
2. **Silent staleness**: executor constructs CORE-shaped cache key for TEMPORAL
   contract → stale cached result returned for different `as_of` value

These are the bugs PROP-028 was written to prevent. The proof chain is sound
up to the executor boundary. The gap is at the point where execution would
actually happen.

---

## [Route]

→ **PROCEED** for S3-R8 close. C1 and C2 are correct and complete for the
stated scope. No production bug exists today. No hold required.

→ **PROP needed** (before Gate 3 opens): Executor approval token contract.
  This is not a track — it is a formal language/runtime proposal that defines
  what constitutes valid executor authorization. Route to Compiler/Grammar Expert
  to author a PROP-030+ candidate for executor approval token semantics, or
  include in an expanded PROP-028 runtime addendum.
  Priority: **BLOCKING for Gate 3 opening**.

→ **track** → Compiler/Grammar Expert: `stream-replay-metadata-emission-v0`
  Scope: specify what runtime replay metadata must be in assembled stream
  SemanticIR (`window.size`, `fold_stream.init`, `fn_ref` shape). Until this
  lands, stream_fold evaluation path is incomplete at the assembled artifact
  level.
  Priority: medium — not Gate 3 blocking, but should land before stream
  evaluation is attempted.

→ **track** → Research Agent: `executor-boundary-cache-key-contract-v0`
  Scope: add one proof case testing TEMPORAL cache key construction at
  executor boundary and L-T5 fault detection for CORE-shaped key.
  Can extend the existing `runtime_compatibility_report_temporal_load_check`
  proof. Priority: **HIGH before Gate 3 — closes the silent staleness gap at
  executor level**.

→ **track** → Research Agent: extend `runtime_compatibility_report_temporal_load_check`
  with GuardedRuntimeMachine cases for C2 profiles 3 and 4 (claimed executor,
  approved placeholder). Priority: medium — closes consistency validation gap.

→ **backlog**: invariant source/classifier metadata preservation. Not Gate 3
  blocking. Route to Compiler/Grammar Expert when the invariant-persistence
  boundary lane is opened.

---

## Compact Risks Table

| Risk | Tracks | Severity | Gate 3 blocking? | Action |
|------|--------|----------|-----------------|--------|
| stream_fold assembled artifact missing replay metadata | C1 R8 known gap | Medium | No (stream ≠ temporal exec) | route: `stream-replay-metadata-emission-v0` |
| invariant severity uses pre-baked fixture, not full source pipeline | C1 R8 known gap | Low-Medium | No | route: Compiler/Grammar invariant metadata preservation |
| Executor approval token undefined — placeholder only | C2 R8 remaining gap | **Medium → High at Gate 3** | **YES** | route: PROP-030+ executor approval contract |
| CompatibilityReport `runtime_enforced: false` — no production check | C1 R7, C2 R8 | Medium | **YES** | Gate 3 opening must bind report to RuntimeMachine |
| Cache key construction untested at executor boundary | not tested | **Medium → High** | **YES** | route: `executor-boundary-cache-key-contract-v0` |
| C2 profiles 3/4 not validated against GuardedRuntimeMachine | C2 R8 gap | Low | No | route: extend `runtime_compatibility_report_temporal_load_check` |
| BiHistory smoke uses single domain fixture (sparkcrm) | C1 R8 | Low | No | acceptable for current milestone |

**Overall: PROCEED on S3-R8.** Four items are Gate 3 prerequisites, not
S3-R8 blockers. The blocking prerequisite set — executor approval token PROP,
cache-key executor boundary test, and production RuntimeMachine report
enforcement — should be formally tracked before any Gate 3 opening request
is accepted by Architect Supervisor.
