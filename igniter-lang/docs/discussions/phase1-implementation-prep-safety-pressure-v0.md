# Discussion: Phase 1 Implementation Prep Safety Pressure

Card: S3-R14-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: phase1-implementation-prep-safety-pressure-v0
Date: 2026-05-09
Status: complete — routed

---

## Question

Did the S3-R14 Phase 1 implementation prep tracks (C2 executor preflight, C3
scope exclusion fixture, C4 report enforcement preflight) remain correctly
scoped — no live eval, no Ledger path, no BiHistory leak, no production cache —
and do the refusal orderings across tracks agree with the established canonical
check chain?

## Context: S3-R14 C2–C4 (with S3-R13 C3–C4 as pre-live-condition inputs)

**S3-R13-C3** `prop-005-temporal-read-observation-v0`

Defines `temporal_read_observation` as the minimum AT-10 observation kind.
Required paths include contract_ref, store_ref, as_of, approval_ref, gate_ref,
token_ref, result status/value. Persistence is proof-local. BiHistory shape
excluded. No live TBackend eval.

**S3-R13-C4** `compatibility-report-composition-v0`

Proves a single composed CompatibilityReport shape. Eight blocking cases all
preserve `operation_check` flags false. `runtime_enforced: true` is valid only
on the composed report when all readiness dimensions pass. Split-fragment
rejection proved. No live operations.

**S3-R14-C2** `runtime-temporal-executor-phase1-preflight-v0`

Implements proof-local `Phase1TemporalExecutor` with a 9-case harness. Guard
chain: `capability → token (AT-4) → gate3 (AT-5) → cache key (AT-6) →
[kernel: AT-12 fragment_class, AT-7 BiHistory]`. AT coverage: AT-1,3–8,10–12
covered; AT-2 deferred (inline partial report); AT-9 partial (proof-local hash).
Uses `gate3_authorized: true` proof-local boolean; explicitly labeled not-production.

**S3-R14-C3** `temporal-scope-exclusion-runtime-fixture-v0`

Proves `runtime.temporal_scope_exclusion` for CORE, STREAM, OLAP, BiHistory,
Ledger write, Ledger replay, and unknown surfaces. All 7 refusal cases prove
`executor_evaluation_attempted: false`, `cache_lookup_attempted: false`,
`tbackend_call_attempted: false`, `ledger_call_attempted: false`,
`live_adapter_call_attempted: false`. Control case (History valid-time) is
`runtime.temporal_scope_accepted`.

**S3-R14-C4** `runtime-report-enforcement-preflight-v0`

Maps RuntimeMachine preflight onto the composed CompatibilityReport shape
from S3-R13-C4. Preflight order: `CompatibilityReport → gate_state →
approval_token → scope → cache_key → executor_backend`. 10-case acceptance
matrix; all blocked cases preserve all operation-attempt flags false.

---

## Live-Eval Closure Check

| Surface | C2 executor | C3 scope fixture | C4 report preflight | Verdict |
|---------|-------------|-----------------|--------------------|---------| 
| Ledger adapter | `MemoryBackend` only; AT-8 confirmed | `ledger_call_attempted: false` all cases | `ledger_call_attempted: false` all blocked | ✅ Closed |
| BiHistory | AT-7 refusal; `bihistory_scope_excluded` case | Proved with `runtime.temporal_scope_exclusion` | `bihistory_scope_excluded_before_cache` case | ✅ Closed |
| Stream | Not in C2 (executor only handles TEMPORAL) | `stream.refused_scope_exclusion` PASS | Not tested (CompatibilityReport layer) | ✅ C3 covers it |
| OLAP | Same | `olap.refused_scope_exclusion` PASS | Not tested | ✅ C3 covers it |
| Ledger write/replay | AT-8; MemoryBackend has no write API | `ledger_write.refused` / `ledger_replay.refused` | Not tested (gate layer) | ✅ C3 covers it |
| Production cache | Not implemented; no cache store | `cache_lookup_attempted: false` | `cache_call_attempted: false` | ✅ Closed |
| Live TBackend call | `live_tbackend_call_attempted: false` in output | `tbackend_call_attempted: false` | `live_tbackend_call_attempted: false` | ✅ Closed |
| Temporal read | Proof-local `read_as_of` only against MemoryBackend | `tbackend_call_attempted: false` | `temporal_read_attempted: false` | ✅ Proof-local only |

No live-eval or Ledger leak found across C2, C3, and C4.

---

## [Agree]

**The scope exclusion proof (C3) is the strongest safety artifact in this round.**

C3 proves SEVEN out-of-scope surfaces refuse before every live path with a
single canonical reason code (`runtime.temporal_scope_exclusion`) and a
structured diagnostic envelope carrying `expected_scope`, `actual_fragment`,
`actual_surface`, and `actual_axis`. An operator seeing this refusal code has
machine-readable information to diagnose why their surface is excluded.

The control case (`valid_history_scope_not_excluded`) is equally important:
it proves the scope gate is narrow (refuses excluded surfaces only, not all
TEMPORAL evaluation). This prevents the scope exclusion check from becoming a
blanket TEMPORAL refusal.

**The composition track (S3-R13-C4) satisfies pre-live condition 1 of the
decision record.**

The composed CompatibilityReport shape is now proved: one report, all
readiness dimensions, `split_fragments_allowed: false`. The `report_only_all_checks_ok`
case proves the critical invariant — all metadata checks passing does not imply
`runtime_enforced: true`. The report cannot silently graduate from analysis to
enforcement.

**The observation track (S3-R13-C3) satisfies pre-live condition 2.**

`temporal_read_observation` is now a concrete proofable shape, not an informal
"structured observation." Required fields are enumerated and tested negative
(rejection proof). Option encoding is canonical. This turns AT-10 from a
behavioral obligation into a shape contract.

**The executor guard chain in C2 is fail-fast at the right layer.**

The `Phase1TemporalExecutor` runs its entire guard chain before
`run_execution_kernel`, which is before any MemoryBackend read. The 9-case
harness proves each AT fires at the correct position and returns the correct
reason code:

- AT-4 fires before AT-5 (token before gate state) — matching canonical ordering
- AT-5 fires before AT-6 (gate state before cache key) — matching canonical ordering
- AT-12/AT-7 fire inside `run_execution_kernel` as defense-in-depth — correctly named as defense-in-depth rather than the primary gate

**C4 preflight fixture correctly imports the composed report shape.**

C4 does not redefine the composition shape — it imports from the C4-P fixture.
This creates a traceable dependency: C4 is provably consistent with S3-R13-C4-P.
A change to the composition shape would break the C4 proof, which is the right
behavior for a regression harness.

**All C2 gaps are explicitly documented and none are hidden.**

The AT coverage table names AT-2 as deferred, AT-9 as partial, and lists G1–G6
as known runtime gaps. The risks section explicitly warns: "Phase1TemporalExecutor
is experiments-local only. It must not be promoted to `lib/` until Gate 3 is
ratified." The implementation is correctly self-limiting.

---

## [Challenge]

### C-1. C4 preflight order reverses the canonical token → gate3 ordering

The established canonical check ordering — confirmed in S3-R10-C2
(GuardedRuntimeMachine), PROP-030, the Gate 3 request, and all three prior
External Pressure Reviews — is:

```text
capabilities → approval token → Gate 3 → cache key schema → artifact guard
```

C4's preflight order is:

```text
CompatibilityReport → gate_state → approval_token → scope → cache_key → executor_backend
```

Specifically: C4 checks `gate_state` **before** `approval_token`. The canonical
ordering checks `approval_token` before `Gate 3`.

The acceptance matrix case `gate_closed_blocks_before_token` (C4) actively
asserts this reversal — gate state blocks before token validation runs.

The safety consequence is not a live-eval leak: both orderings refuse before
executor/cache/backend calls. But the diagnostic consequence is material:

- **Canonical ordering**: with Gate 3 closed and a missing token, the operator
  sees `executor_approval_missing`. This tells them: "you need a valid token,
  regardless of gate state." Correct behavior for a system where tokens must
  be issued through the Architect authority process.

- **C4 ordering**: with Gate 3 closed and a missing token, the operator sees
  `gate3_closed`. This masks the token validation failure. If Gate 3 ever
  reopens but the token was never fixed, the next evaluation fails with
  `executor_approval_missing` — a new error that was hidden before.

The canonical ordering ensures every token error is visible regardless of gate
state. C4 breaks this property.

C4 does not acknowledge the deviation from the established ordering. It does
not explain why gate state should precede token validation. The GuardedRuntimeMachine
ordering was established precisely because the gate and the token are independent
checks — a valid token does not imply Gate 3 is open, and Gate 3 being open does
not imply a valid token. Checking gate state first blurs this independence.

**Severity**: medium. Not a Phase 1 live-eval blocker — the proofs are correct
in what they refuse. But C4 is titled "RuntimeMachine Notes" and gives the
preflight order as implementation guidance for the Implementation Agent. If the
production RuntimeMachine follows C4's order, the canonical ordering is broken.

**Required**: C4 should either adopt the canonical ordering (approval_token
before gate_state) or provide an explicit justification for the reversal and
route a PROP-030 errata to update the canonical definition.

### C-2. AT-2 is deferred in C2 but the composition track exists

AT-2 requires: "CompatibilityReport is composed as a single production report,
not as two separate report-only and enforcement objects."

The pre-live condition 1 from the Gate 3 decision record:

> `compatibility-report-composition-v0` lands and defines a single composed
> production CompatibilityReport path.

That track has landed (S3-R13-C4-P). Pre-live condition 1 is satisfied for
track landing.

But C2's AT coverage marks AT-2 as "deferred — no composed CompatibilityReport;
gap listed below." C2 builds its report inline as a partial structure, not by
consuming the composition shape. Gap G1 says the composition track is needed.

This creates a precision gap in the gate decision's pre-live condition: the
condition says the track must "land" — it does not say the executor must "use"
the composition shape. The composition track proving a shape and the executor
using that shape are two different things.

For Phase 1 proof-local use, this is acceptable: C2 is an executor, not a
report producer. But for production Phase 1 where `runtime_enforced: true` is
required, the executor must consume the composed CompatibilityReport rather than
building an inline partial. An implementer who promotes C2's executor to `lib/`
would have `runtime_enforced: true` with an AT-2-incompatible partial report.

**Severity**: medium. Named and documented in C2, not hidden. Not a live-eval
risk for Phase 1 proof-local use. Becomes a blocker before production Phase 1
live reads — the executor must be updated to consume the composition shape before
`runtime_enforced: true` is used in production.

### C-3. C2 gap analysis is stale relative to the gate decision record

C2's runtime gaps table and open questions predate the Gate 3 decision record:

| Gap | C2 says | Actual state |
|-----|---------|-------------|
| G2: authority_ref | "Architect-recorded authority_ref in gate decision (Q1)" | Recorded in decision record: `architect-supervisor://igniter-lang/gates/gate3/...` |
| G3: Gate 3 decision record | "Gate 3 request on HOLD" | Gate 3 is approved-restricted-phase1 |
| Q1: authority_ref value | "What is the authority_ref?" | Answered in gate decision record |

These gaps are described as open when they are resolved. A future implementer
reading C2 without the gate decision record would believe G2/G3/Q1 are still
blocking. This is documentation staleness, not a safety risk — the implementation
itself is correct. But the gap list misleads about current project state.

**Severity**: low for safety; medium for documentation. C2 should be amended
with a note: "G2, G3, Q1 are resolved by the Gate 3 decision record
(S3-R13-C1-A); see `docs/gates/gate3-decision-record-v0.md`."

### C-4. AT-9 partial: `gate3_authorized: true` boolean is not connected to the authority_ref URI

AT-9 requires: "The trusted authority for ExecutorApprovalToken is recorded in
the Architect decision document. Proof-local deterministic hash signatures must
not be used in production token validation."

C2's AT-9 coverage is "partial — proof-local hash only; no external authority
registry." The executor uses a proof-local boolean `gate3_authorized: true`
rather than validating the token's `authority_ref` field against the URI in
the gate decision record.

The correct Phase 1 check (for non-proof-local use) would be:

```text
token.authority_ref == "architect-supervisor://igniter-lang/gates/gate3/
  runtime-temporal-executor/restricted-history-valid-time-v0/2026-05-09"
```

This check is possible — the URI is recorded. The C2 proof doesn't demonstrate
it, and the gap between "proof-local boolean" and "URI string comparison" is
not bridged in any current track.

**Severity**: low for proof-local Phase 1. Becomes a blocker before production
Phase 1 live reads — AT-9 compliance requires URI comparison, not a boolean
flag. The Implementation Agent should be aware that promoting C2 to `lib/`
requires replacing the boolean with the URI check against the decision record.

---

## [Missing]

### M-1. C4's ordering reversal is not acknowledged in the track

C4 gives the preflight order as implementation guidance without acknowledging
that it differs from the PROP-030 / GuardedRuntimeMachine ordering. A track
that changes an established canonical ordering should note the deviation and
its rationale. If C4's ordering is intentional (e.g., gate state is a
faster/cheaper first check, token validation is more expensive), that reasoning
should be explicit.

Without acknowledgment, two consistent-looking but conflicting orderings exist
in the proof record. A future implementer will have to decide which one is
canonical without any guidance.

### M-2. No track bridges C2's inline partial report to the composition shape

The composition track defines the shape. The enforcement preflight track uses
it. The executor (C2) defers it. There is no track that shows C2's executor
consuming the composition shape to produce a report that satisfies AT-2. This
bridge track is the gap that sits between Phase 1 proof-local and Phase 1
production.

It does not need to exist today. But it should be named as a required pre-live
track: before any executor code enters `lib/` and attempts `runtime_enforced: true`,
a track must exist that shows the composition shape consumed by the executor.

---

## [Sharper Question]

Not: "Are the Phase 1 tracks correctly scoped?"

They are. No live-eval, no Ledger, no BiHistory, no production cache. All
operation-attempt flags are false in all non-happy-path cases. The implementation
is correctly labeled proof-local.

The sharper question is:

> **If an Implementation Agent promotes C2's `Phase1TemporalExecutor` to `lib/`
> next round and wires it into RuntimeMachine — following C4's preflight order
> and using C2's inline partial report for `runtime_enforced: true` — does the
> result satisfy AT-1 through AT-12?**

The answer is **no, not yet**, for three specific conditions:

- AT-2: report is a partial inline structure, not the composed shape from C3-R13-C4
- AT-9: boolean flag, not URI comparison against the decision record authority_ref
- Check ordering: follows C4 (gate before token) rather than the canonical PROP-030 ordering (token before gate)

None of these are live-eval risks today. All are correct for proof-local use.
But all three would create compliance gaps if C2 were promoted without resolution.
The gate decision's pre-live conditions block live reads until AT-1 through AT-12
pass — which means these three conditions must be resolved before any live
History[T] read is executed.

---

## [Route]

→ **PROCEED.** Phase 1 prep is correctly scoped. No live-eval or exclusion
leak found. Phase 1 proof-local work may continue.

→ **AMEND** (non-blocking, required before production executor):
  C4 (`runtime-report-enforcement-preflight-v0`) should acknowledge the
  ordering deviation and either:
  - adopt the canonical PROP-030 ordering (approval_token before gate_state), or
  - provide explicit rationale for gate_state first and route a PROP-030 errata
    to update the canonical definition.

  Until this is resolved, the Implementation Agent must be notified that the
  production RuntimeMachine must use the canonical ordering
  (`token → gate3`, not `gate3 → token`), not C4's acceptance matrix order.

→ **track** (required before production Phase 1, not before proof-local work):
  A bridge track — call it `runtime-temporal-executor-composition-integration-v0`
  or similar — should show the Phase1TemporalExecutor consuming the composition
  shape from `compatibility-report-composition-v0`, producing a single composed
  report that satisfies AT-2. Must exist before executor code enters `lib/`.

→ **AMEND** (documentation, low urgency):
  C2 gap list (G2, G3, Q1) should be updated with a note that these are
  resolved by the Gate 3 decision record (S3-R13-C1-A).

→ **track** (required before production Phase 1):
  Show AT-9 URI comparison: `token.authority_ref` checked against the recorded
  URI from `gate3-decision-record-v0.md`. This can be a short addendum to C2 or
  a standalone proof. Must exist before the executor enters `lib/`.

→ **backlog** (Phase 2, not blocking Phase 1):
  C2 G4 (observation persistence), G5 (TBackend adapter production binding),
  G6 (BiHistory separate gate) remain correctly in the Phase 2 backlog.

---

## Risk Table

| Risk | Severity | Blocker for proof-local Phase 1? | Blocker for production Phase 1 live reads? | Blocker for Phase 2? |
|------|----------|----------------------------------|--------------------------------------------|----------------------|
| Live eval / Ledger / BiHistory / cache leak | — | **NONE FOUND ✅** | — | — |
| Scope exclusion (C3) all 7 surfaces | — | **PASS ✅** | — | — |
| C4 preflight reverses token → gate3 to gate3 → token | Medium | No — proof refusals are correct | Yes — production RuntimeMachine must use canonical ordering | Yes |
| AT-2 deferred in C2; executor uses inline partial report | Medium | No — correctly labeled proof-local | Yes — must consume composition shape before `runtime_enforced: true` in production | Yes |
| C2 gap list stale (G2/G3/Q1 reference pre-decision state) | Low | No — impl is correct | No — doc only | No |
| AT-9 partial: boolean not URI comparison | Low | No — proof-local acceptable | Yes — must use URI check against decision record before `lib/` | Yes |
| `Phase1TemporalExecutor` experiments-local label | — | **CONFIRMED CORRECT ✅** | Must not enter lib/ until resolved | — |
| Pre-live condition 1 (composition track): SATISFIED | — | **✅** | — | — |
| Pre-live condition 2 (observation track): SATISFIED | — | **✅** | — | — |
| Pre-live condition 3 (scope exclusion errata): SATISFIED | — | **✅** | — | — |

**Overall: PROCEED for proof-local Phase 1. Three conditions (C4 ordering, AT-2
composition integration, AT-9 URI check) must be resolved before any executor
code enters `lib/` or any production live read is attempted.**
