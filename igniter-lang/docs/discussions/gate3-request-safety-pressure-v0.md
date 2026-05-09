# Discussion: Gate 3 Request Safety Pressure

Card: S3-R11-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: gate3-request-safety-pressure-v0
Date: 2026-05-09
Status: complete — routed

---

## Question

Is the Gate 3 opening request (`runtime-temporal-executor-gate3-request-v0`) safe
to route to Architect Supervisor for decision as written, or does it contain
ambiguity that could authorize more than intended, underspecify an enforcement
requirement, or allow the gate to open without key safety conditions in place?

## Context: S3-R11 C1–C4 Summary

**C1** `runtime-temporal-executor-gate3-request-v0`

Formal gate request. Scope: live TEMPORAL `History[T]` valid_time evaluation
only. BiHistory excluded. Production cache deferred. Ledger write excluded. Six
Architect-decision questions (Q1–Q6). Eleven production acceptance conditions
(AT-1..AT-11). Recommendation: approve restricted, with conditions; hold if
authority_ref cannot be recorded before implementation starts.

**C2** `gate3-acceptance-condition-matrix-v0`

12-row proof-evidence matrix. No hard contradiction found across S3-R7 through
S3-R10. Seven missing production items identified: RuntimeMachine binding,
authority/revocation registry, production signature verification,
CompatibilityReport persistence/audit, unified report composition, physical
TBackend serving proof, and runtime cache enforcement.

**C3** `gate3-ledger-tbackend-scope-and-bihistory-exclusion-v0`

Recommends Option B (History[T] only). Documents that Option A (BiHistory
included) requires physical `at(vt:, tt:)` data-plane proof, two-axis fixture,
replay fidelity, and separate RefusalCases — none of which exist. Provides
verbatim exclusion language for the request.

**C4** `gate3-request-spec-consistency-check-v0`

Validates request shape against PROP-028/PROP-030/Ch6/Ch7. No semantic
contradiction found. Notes Ch7 does not yet list the PROP-030 approval-token
refusal matrix. Identifies 10-item required-request checklist and routes a
later `spec-ch7-gate3-approval-sync` if the request is accepted.

---

## [Agree]

**The restricted scope is correctly drawn.**

History[T] valid_time only is the right first scope. BiHistory exclusion is
explicit (AT-7 requires the executor to refuse `BiHistory[T]` artifacts at
runtime, not just to omit them from the authorize list). The Option B language
from C3 is incorporated. The request cannot accidentally authorize BiHistory
because AT-7 creates a production refusal obligation, not just a scope gap.

**The check ordering is the proof-local specification, correctly carried.**

`capabilities → approval token → Gate 3 → TEMPORAL cache key → artifact guard`
is sourced directly from the GuardedRuntimeMachine proof (S3-R10-C2). It appears
in the Require table and is embedded in AT-3 through AT-6. An implementer
reading only the request document can derive the full check chain without
archaeology into the proof tracks.

**Token independence from Gate 3 state is explicit.**

AT-5 states: "A valid token with Gate 3 closed must still refuse with
`runtime.temporal_gate3_closed`." This is the key behavioral invariant that
prevents approval tokens from becoming a Gate 3 bypass, and it is a named
production acceptance condition, not a comment.

**Production cache is correctly deferred.**

Deferring the production cache is the right call. The L-T5 cache key proof
exists (S3-R9-C3), but no production cache store is implemented and cache
invalidation on TBackend state change is unproven. Opening Gate 3 without
production cache enabled is strictly safer — it removes one class of silent
staleness risk from the initial live path.

**Self-issued tokens are unambiguously excluded.**

Section III exclusion: "Tokens not backed by Architect recorded decision are
invalid; authority registry must be Architect-controlled." AT-9 restates this
as a production acceptance condition. No implementation path allows
proof-local deterministic hashes in production.

---

## [Challenge]

### C-1. Authority ref recording is a condition on the decision record, not a precondition of approval

Section VI recommendation condition 1 reads:

> Architect records the trusted authority ref for `ExecutorApprovalToken` in
> `docs/gates/gate3-decision-record-v0.md`.

This is framed as something the Architect does when writing the decision record.
It is not framed as a precondition that must be satisfied before the decision
record is authored. The hold condition says:

> Hold if Architect cannot record the authority ref before executor
> implementation starts.

The gap: the decision record is written when the gate is opened. If the
authority ref is recorded in the same document that opens the gate, there is no
window between gate-open and authority-present — which is correct. But the
request does not say this explicitly. A decision record could be authored that
opens Gate 3 and defers the authority ref to a subsequent PROP-030 errata
document.

If Gate 3 is opened without an authority ref present, AT-9 ("Proof-local
deterministic hash signatures must not be used in production token validation")
creates an unresolvable compliance state: tokens cannot be validated in
production because there is no authority, but the gate is open.

**Severity**: HIGH — not a blocker to writing the request, but requires a
single wording change. The request must say:

> Authority ref must be recorded in the gate decision document. Gate 3 is not
> open until that record exists.

### C-2. AT-10 is conditional on Q5 resolution

AT-10 reads:

> Every authorized live read emits a structured observation record (if Q5 is
> approved).

The `(if Q5 is approved)` clause makes AT-10 optional. Section VI recommends
"Q5 = yes (audit observation required)" but Q5 remains an open Architect
decision. If the Architect decides Q5 = not required for first Gate 3, AT-10
disappears entirely, and live reads can proceed with no trace.

The production consequence: a live `read_as_of` call succeeds, the TBackend
returns data, the result is used in contract evaluation, and no record exists
that the call happened. For a time-travel read, where the result depends on
coordinates that may not be recoverable, this is a correctness risk beyond audit
compliance — debugging a wrong result requires knowing what `as_of` was used.

**Severity**: HIGH — the qualifier must be removed. Either:
- Make Q5 resolution a precondition of gate opening (Architect must answer it in
  the decision record, then AT-10 becomes unconditional), or
- Make AT-10 unconditionally required and close Q5 by asserting the answer.

The request should not leave production live-read traceability as an open
question.

### C-3. "Ledger-backed TBackend" exclusion conflicts with Q3

Section III excludes:

> Ledger-backed TBackend (real Ledger reads) — Gate 3 has never authorized
> Ledger write operations; read binding against real Ledger requires Architect
> decision on audit trail and observation persistence.

But Q3 is asking which TBackend adapter scope to authorize:

> Option B: real external TBackend adapter for target store (maximum)

The primary production use of Gate 3 is temporal reads from Igniter-Ledger.
The exclusion says "Ledger-backed TBackend requires a separate Architect
decision." Q3 Option B says that decision could be this gate. These conflict.

The resolution requires making the distinction explicit:

- **Authorized**: `history_read` reads via the **abstract** TBackend interface,
  regardless of backing store, provided all AT conditions pass.
- **Default Q3 answer**: Option C (proof-local MemoryBackend first; real adapter
  requires a second Architect approval step within Gate 3, not a new gate).
- **Excluded**: Ledger **write**, append, replay, compact — these are independent
  of Q3 and always excluded.

As written, an implementer could read the Section III exclusion as blocking all
Ledger-backed adapters under Gate 3, making Gate 3 useless for production
Igniter-Ledger reads.

**Severity**: medium — the ambiguity is resolvable with one clarifying sentence.

### C-4. AT-2 (unified CompatibilityReport composition) is an acceptance condition with no proof anchor

AT-2 requires:

> CompatibilityReport is composed as a single production report, not as two
> separate report-only and enforcement objects.

S3-R11-C2 lists "Unified CompatibilityReport composition" as a required missing
production item. No track, fixture, or spec section currently defines what the
unified composed shape looks like. The current evidence is seven separate
proof-local report dimensions (load/eval split, executor profiles 1-2,
executor profiles 3-4, token validation, descriptor backend_check, cache
schema, GuardedRM enforcement — per the S3-R10-X1-S review).

An implementer who must satisfy AT-2 has no reference shape to build against.
They will compose seven dimensions into one report in whatever way seems
reasonable, and AT-2 as written cannot be falsified because it only says "single
report, not two objects."

**Severity**: medium — not a blocker before approval, but the request should
add a requirement for a composition track before any live eval proceeds. AT-2
needs a named reference or a named pending track that supplies it.

### C-5. AT-11 regression surface is underspecified

AT-11 requires:

> Stage 1 regression PASS. Stage 2 regression PASS. All existing proofs pass
> after executor implementation lands.

"All existing proofs" is correct but informal. The Stage 3 proof chain from
S3-R7 through S3-R10 (10+ separate proof scripts) is the primary regression
surface for Gate 3 correctness. Stage 1 and Stage 2 cover unrelated surfaces.
An implementer focused on Stage 1/2 regression could pass AT-11 while
inadvertently breaking the `GuardedRuntimeMachine`, `executor-boundary-cache-key`
proof, or the `executor-approval-token-report-proof` — the exact proofs that
form the Gate 3 prerequisite chain.

**Severity**: low-medium — the request should name the S3-R7 through S3-R10
proof chain explicitly as the Gate 3 regression surface, not rely on
"all existing proofs" to include it.

### C-6. Q6 should be an acceptance condition, not a question

Q6 asks:

> If a CORE contract reaches the executor with Gate 3 open, does the executor
> check `fragment_class` and refuse?

The request says "Expected answer: yes" and asks for confirmation. This is the
L-T5 / `temporal_cache_schema_mismatch` refusal at a different level — the
executor refusing a CORE artifact, not a CORE cache key shape.

If the answer is "yes" as expected, then Q6 should become AT-12 rather than
remaining a question. A question that has an expected answer is an unresolved
acceptance condition, not an open design decision. Leaving it as Q6 creates a
path where the Architect answers "confirmed" in the decision record but the
acceptance matrix never includes it, and an implementer could skip the check.

**Severity**: low — but the request should either close Q6 as an acceptance
condition or escalate it to a design question if there is genuine doubt about
the expected answer.

---

## [Missing]

### M-1. Explicit "scope does not expand on approval" statement

The request's exclusions list is comprehensive, but it does not include a
statement binding the exclusions to the gate state. Something like:

> Gate 3 approval authorizes only the items listed in Section III Authorize.
> All excluded items remain closed. A separate gate request is required for
> each excluded surface; this approval does not create a precedent for adjacent
> scope.

Without this, "Gate 3 is open" can be read by implementers as "TEMPORAL
evaluation is live — related things are probably okay to wire up too." The
exclusions list needs to bind to the approval, not just to the request.

### M-2. Phase delineation for Q3 Option C

The request recommends Q3 = Option C as default: proof-local first, then
Architect approval before real adapter. But the request does not describe what
the two phases look like or who approves the phase transition.

For safe implementation:
- Phase 1: `runtime_enforced: true` with proof-local `MemoryBackend`. Satisfies
  AT-1 through AT-11 on the proof surface.
- Phase 2: real adapter binding. Requires a named Architect sign-off (could be
  a short addendum to the gate decision record rather than a new gate).

Without naming the phases, Q3 Option C creates a phased gate that lacks a
defined transition, and an implementer might wire the real adapter in Phase 1
because "Gate 3 is open."

### M-3. Ch7 sync routing is confirmed in C4 but not named in C1

C4 recommends a `spec-ch7-gate3-approval-sync` if the request is accepted. C1
(the request) does not reference this. After gate opening, the spec-lag between
Ch7 (which reflects baseline `load_accept_evaluate_refuse`) and the approved
Gate 3 enforcement semantics (PROP-030 ordering, AT conditions) will be active.
The request should route this sync explicitly so it lands as a known post-gate
obligation, not as organic drift.

---

## [Sharper Question]

Not: "Does the request correctly describe what Gate 3 should do?"

It does. The scope is right, the ordering is right, the exclusions are right,
the BiHistory exclusion is correct, and the acceptance conditions are mostly
complete.

The sharper question is:

> **If the Architect approves Gate 3 today using this document, can a developer
> begin live evaluation without creating a safety gap?**

The answer is: **not quite**, because of C-1 and C-2. With Gate 3 open and no
authority ref recorded, AT-9 is immediately in violation. With AT-10
conditional on Q5, live reads can run with no trace if Q5 is deferred. Both of
these are wording issues in the request, not design problems. Two targeted edits
to the request resolve both.

Every other challenge above (C-3 through C-6, M-1 through M-3) is a medium or
low risk that should be addressed before the decision record is authored, but
none creates a live-safety gap on the scale of C-1 or C-2.

---

## [Route]

→ **HOLD — two required edits before Architect review.**

The request is not unsafe in intent. It is unsafe in two specific clauses that
could leave Gate 3 open without an authority source or without a live-read audit
trace. Both are wording edits, not design changes:

**Edit 1** (C-1): Replace the Section VI condition 1 wording with:

> Authority ref must be present in the gate decision record. Gate 3 is not open
> until the decision record exists and includes the authority ref format,
> issuance process, and revocation mechanism.

**Edit 2** (C-2): Remove the `(if Q5 is approved)` qualifier from AT-10. Either
close Q5 by asserting "audit observation is required for every live read" as a
non-negotiable, or elevate Q5 to a gate-opening precondition that the Architect
must answer before approving.

→ After those two edits: **PROCEED to Architect review with approve-restricted
recommendation intact.**

The remaining items (C-3 through C-6, M-1 through M-3) should be addressed in
the same editing pass:
- C-3: add a clarifying sentence distinguishing abstract TBackend interface
  authorization from Ledger-backed adapter scope.
- C-4: add a named pending track reference for CompatibilityReport composition.
- C-5: name the S3-R7 through S3-R10 proof chain as Gate 3 regression surface.
- C-6: close Q6 as AT-12 or escalate it as a genuine design question.
- M-1: add the scope-does-not-expand statement to Section III or VII.
- M-2: add a two-phase description for Q3 Option C.
- M-3: add a post-gate `spec-ch7-gate3-approval-sync` routing in Section VI or
  the Handoff.

→ **PROP (edits to C1 request)** → Meta Expert: apply the above edits to
`runtime-temporal-executor-gate3-request-v0.md` before routing to Architect.

→ **backlog** (post-gate, not blocking):
  - `runtime-report-enforcement-preflight-v0` (production RuntimeMachine
    preflight binding — C2 missing item 1)
  - CompatibilityReport composition track (AT-2 reference shape)
  - `spec-ch7-gate3-approval-sync` (Ch7 approval-semantics sync)
  - `compatibility-report-persistence-audit-v0` (AT-10 backing)

---

## Risk Table

| Risk | Severity | Blocker before approval? | Required inside request? | Post-gate impl backlog |
|------|----------|--------------------------|--------------------------|------------------------|
| Authority ref may be deferred after gate opening (C-1) | HIGH | **YES — edit required** | — | — |
| AT-10 conditional on Q5 — live reads could run untraceable (C-2) | HIGH | **YES — edit required** | — | — |
| Ledger-backed TBackend exclusion vs. Q3 ambiguity (C-3) | Medium | No | Yes — clarifying sentence | — |
| AT-2 unified report has no proof anchor or reference shape (C-4) | Medium | No | Yes — named track reference | CompatibilityReport composition |
| AT-11 regression surface omits S3-R7..R10 chain (C-5) | Low-Medium | No | Yes — explicit naming | — |
| Q6 is an expected-answer question, not a named AT condition (C-6) | Low | No | Yes — close as AT-12 | — |
| No scope-not-expanded statement (M-1) | Medium | No | Yes | — |
| Q3 Option C phase boundary undefined (M-2) | Medium | No | Yes | — |
| Ch7 sync gap unrouted in the request (M-3) | Low | No | Yes — add routing | spec-ch7-gate3-approval-sync |
| Production RuntimeMachine binding is proof-local only | High | No | Yes — AT-3 names it | runtime-report-enforcement-preflight-v0 |
| CompatibilityReport persistence/audit missing | Low | No | AT-10 names it | compatibility-report-persistence-audit-v0 |
| BiHistory accidentally included via executor scope | Low | No | AT-7 covers it | — |

**Overall: HOLD for two targeted edits, then PROCEED. The request is
structurally sound; two clauses need hardening before the Architect can safely
open Gate 3 on the basis of this document.**
