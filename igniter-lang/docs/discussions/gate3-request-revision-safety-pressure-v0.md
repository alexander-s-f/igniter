# Discussion: Gate 3 Request Revision Safety Pressure

Card: S3-R12-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: gate3-request-revision-safety-pressure-v0
Date: 2026-05-09
Status: complete — routed

---

## Question

Did the S3-R12-C1-S revision of the Gate 3 opening request close both S3-R11-X1
HOLD blockers cleanly, and did it introduce any new unsafe ambiguity in doing so?

## Context: S3-R12 C1–C4

**C1** `runtime-temporal-executor-gate3-request-revision-v0`

Applies all S3-R11-X1 HOLD fixes and medium/low clarity items to the Gate 3
request. Status on revision track: HOLD → FIXED. AT-12 added (CORE artifact
refusal). Q5 and Q6 closed. Phase 1/Phase 2 Q3 boundary defined. Scope Boundary
section added. Post-gate `spec-ch7-gate3-approval-sync` routing added.

**C2** `gate3-request-revision-spec-review-v0`

Spec consistency review of the revised request. Verdict: ready for Architect
review. Confirms no parser, SemanticIR node-kind, BiHistory, stream, or OLAP
authorization. Ch7 sync correctly routed as post-approval. No spec blocker found.

**C3** `gate3-regression-proof-chain-index-v0`

Compact index of the S3-R7..R10 proof scripts with commands, expected output,
risk covered, and boundary annotation. AT-11 regression surface is now concrete.
No new proof added.

**C4** `gate3-tbackend-adapter-phase-plan-v0`

Defines a Phase 0 / Phase 1 / Phase 2 / Future table for TBackend adapter
scope. Phase 1 = proof-local `MemoryBackend`, authorized on gate opening. Phase
2 = real Ledger-backed adapter, requires explicit Architect addendum naming
adapter identity and audit/observation plan. Resolves C-3 ambiguity from X1.

---

## HOLD Closure Verification

### C-1 (HIGH): Authority ref must be a gate-opening precondition

**Was**: Section VI framed authority ref recording as something the Architect
does when writing the decision record — no enforcement that it is concurrent.

**Revised text** (Section VI condition 1):

> Authority ref must be present in the gate decision record. Gate 3 is not open
> until the decision document exists and includes: the trusted authority ref for
> `ExecutorApprovalToken`, the authority format (key, hash, or config binding),
> the issuance process, and the revocation mechanism. A gate decision that defers
> the authority ref to a subsequent PROP-030 errata document does not open
> Gate 3.

**Verdict**: ✅ CLOSED. The text is unambiguous. The gate is not open without
the authority ref in the same document. No loophole for deferred errata.

### C-2 (HIGH): AT-10 audit trace must be unconditional

**Was**: `AT-10 ... (if Q5 is approved)` — an optional clause that could be
voided if Q5 was deferred or rejected.

**Revised AT-10** (Section V):

> Every authorized live History[T] read emits a structured observation record.
> Runtime does not silently consume TBackend reads. Observation emission is
> unconditional; it is not gated on any separate Architect decision. (Q5 is
> closed: audit observation is required for every live temporal read.
> Observation persistence is proof-local until the invariant persistence gap
> closes; persistence readiness does not affect the emission requirement.)

**Q5** (Section IV): closed explicitly — "This is not optional." Also confirmed
in the Require table row for audit observation, which now reads "unconditional."

**Verdict**: ✅ CLOSED. No qualifier survives in AT-10 or in Q5. The emission
is production-mandatory regardless of persistence state.

---

## [Agree]

**Both HIGH blockers are closed without residual loopholes.**

The authority ref language uses negative framing ("does not open Gate 3") that
is harder to misread than positive framing ("must be present when written"). An
Architect who writes a decision record and defers the authority ref cannot claim
the gate is open — the text says explicitly that that decision document does not
constitute gate opening.

The AT-10 unconditional wording correctly separates emission from persistence.
An implementer must emit an observation even if there is nowhere to persist it
durably yet. This is the right runtime-safety position for a time-travel read —
the observation exists at least transiently even if long-term storage is still
proof-local.

**The Scope Boundary section closes the scope-creep risk correctly.**

The new "Scope Boundary" subsection in Section III says:

> "Gate 3 is open" does not mean TEMPORAL evaluation as a whole is live — it
> means exactly the authorized items above are live, under exactly the
> conditions stated in Require and AT-1 through AT-12.

Combined with the explicit exclusion of each surface and the "addendum only
where explicitly permitted" qualifier, this binds the approval tightly. An
implementer cannot argue that an adjacent surface is "implied" by gate opening.

**BiHistory exclusion is layered correctly across four locations.**

Section III Authorize (omits BiHistory), Section III Exclude (states reason),
AT-7 (runtime refusal obligation), and Section VI condition 2 (Architect
decision required). C2 spec review independently confirms no BiHistory
authorization is present. Four independent layers make accidental inclusion
difficult.

**Q3 Phase 1/Phase 2 boundary is now machine-readable.**

C4 (TBackend adapter phase plan) provides a Phase 0/1/2/Future table that
an implementer can use as a decision tree. Phase 1 is authorized on gate
opening. Phase 2 requires a named addendum recording adapter identity and
audit/observation plan. The transition condition is explicit, not implicit.

**AT-12 closes the CORE-at-executor gap.**

Q6 is closed and the acceptance condition is now numbered. An implementer
reading only AT-1..AT-12 will find the CORE artifact refusal requirement
without needing to trace it back through discussions.

**AT-11 regression surface is now concrete.**

The S3-R7 through S3-R10 proof scripts are named in AT-11 and indexed in C3
with commands. A regression runner does not need archaeology to know what to
run.

---

## [Challenge]

### C-1. AT-10 observation kind is informal — "note the gap" is not a verifiable condition

Q5 closure text (Section IV) says:

> The observation kind for a live temporal read is not yet formally registered;
> the implementer must use the closest available PROP-005 envelope kind and note
> the gap in the implementation record.

AT-10 requires "a structured observation record." But with no registered kind,
"structured" is self-defined. An implementer who emits any JSON-shaped object
and labels it an observation satisfies the literal text of AT-10. The
observation could omit the time coordinate, the contract ref, or the token ref,
and there is no AT condition that would catch the omission.

"Note the gap in the implementation record" is not a verifiable acceptance
condition. It is a documentation obligation, but it does not define what must
be present in the observation for it to be valid.

**Severity**: medium. Not a gate-opening blocker — requiring formal PROP-005
observation kind registration before Gate 3 opens would delay the request
unnecessarily. But the observation content must be constrained enough to be
useful for debugging wrong results from live time-travel reads.

**Required addition** (can be addressed in a post-gate track, not in the request
itself): route a PROP-005 errata or addendum track to define the minimum content
of a `temporal_read_observation` kind before Phase 1 live reads proceed. AT-10
should name this track as a named pending obligation, parallel to how AT-2
names `compatibility-report-composition-v0`.

### C-2. AT-2 "must land before any live eval proceeds" is implicit sequencing

The Require table entry for AT-2 says:

> Reference shape: pending track `compatibility-report-composition-v0` (not yet
> landed; must land before any live eval proceeds)

AT-2 is listed as a gate acceptance condition, but the composition track has not
landed. This creates a three-phase sequence that is implicit rather than stated:

```text
Phase 1: Gate 3 approved (AT-2 named but composition track missing)
Phase 2: compatibility-report-composition-v0 lands (AT-2 reference shape exists)
Phase 3: live eval proceeds (AT-2 satisfied)
```

An Architect who approves Gate 3 on the basis of this document is approving a
state where AT-2 is named but not satisfiable yet. If the Architect decision
record says "AT-1 through AT-12 verified before live eval" and the composition
track has not landed, the decision record is technically contradicted.

This is not unsafe — AT-2 correctly blocks live eval until the track lands. But
the request should state explicitly:

> Architect approval does not immediately enable live TEMPORAL reads. Live reads
> require all AT conditions satisfied. AT-2 and AT-10 depend on pending tracks;
> those tracks must land before live eval regardless of gate open state.

**Severity**: low-medium. The sequencing is implied by "must land before any
live eval proceeds" but the implication should be made explicit to prevent
misinterpretation of the Architect decision as "live eval authorized now."

### C-3. Q2 temporary-exclusion path leaves a gap in the request

Q2 is still an open Architect decision:

> Is BiHistory[T] excluded permanently (requires new gate) or temporarily
> (deferred within this gate)?

Section VI recommends condition 2: "Q2 = separate gate required." But if the
Architect decides Q2 = temporary deferral (BiHistory included via addendum once
physical serving proof lands), the request document does not have addendum
language for BiHistory. The Scope Boundary section says addenda are only
permitted "where explicitly permitted by this document," and no such permission
is granted for BiHistory.

If the Architect wants to answer Q2 as "temporary deferral," they would need to
either: (a) amend the request document to add BiHistory addendum language, or
(b) supersede this request with a broader request. Neither path is named in the
current document.

**Severity**: low. The recommended answer (separate gate) avoids this gap. But
the request should name the "redirect" path more precisely:

> If the Architect decides Q2 = temporary deferral (BiHistory within this gate
> pending physical serving proof), this request document must be superseded by
> a new request that includes BiHistory addendum language and the physical
> serving proof requirement. The current document is not a sufficient basis
> for that decision.

### C-4. AT-12 "gate-scope-exclusion refusal" is a coined label, not a canonical reason code

AT-12 requires the executor to refuse CORE artifacts "with a named refusal
reason" and both AT-7 and AT-12 use the phrase "gate-scope-exclusion refusal"
as the reason description. This phrase does not appear in PROP-030, the
existing GuardedRuntimeMachine proof, or any canonical reason code table.

PROP-030 defines `runtime.executor_approval_*` codes. The existing proof chain
uses `runtime.temporal_gate3_closed`, `runtime.temporal_cache_schema_mismatch`,
and `runtime.executor_approval_missing`. "Gate-scope-exclusion" is not in that
namespace.

An implementer following AT-12 would invent a reason code without a canonical
reference. Two implementers might emit different codes for the same refusal,
breaking any future tooling that inspects refusal reasons.

**Severity**: low. This is a naming/canonicalization issue, not a safety issue
— CORE artifacts will still be refused regardless of what the code is called.
But PROP-030 should be extended with a `runtime.temporal_scope_exclusion` (or
similar) reason code before implementation to prevent fragmentation.

---

## [Missing]

### M-1. No named pending track for AT-10 observation kind

AT-2 names `compatibility-report-composition-v0` as the pending track that
must land before live eval. AT-10 says "note the gap in the implementation
record" for the missing PROP-005 observation kind. These are asymmetric: AT-2
has a named track that can be tracked and verified; AT-10 has an informal
documentation obligation that cannot be tracked.

The request should name a pending track for temporal read observation kind
definition — for example `prop-005-temporal-read-observation-v0` or
`spec-temporal-read-observation-kind-v0` — and treat it as a parallel obligation
to AT-2: must land before Phase 1 live reads proceed.

### M-2. PROP-030 reason code for AT-12 and AT-7

Both AT-7 (BiHistory at executor) and AT-12 (CORE at executor) use the informal
label "gate-scope-exclusion refusal." PROP-030 should receive an errata entry or
an addendum defining the canonical reason code for executor scope exclusions
(artifacts that reach the executor but are outside this gate's authorized scope).
This should be routed as a Compiler/Grammar Expert item.

---

## [Sharper Question]

Not: "Are the S3-R11-X1 HOLD items closed?"

They are. Both HIGH items are closed, correctly, without introducing new
HIGH-severity gaps.

The sharper question for the revised request is:

> **Does the Architect decision record, as described, create a clear enough
> implementation handoff that a Research Agent can implement AT-1..AT-12 in
> sequence without ambiguity about what "done" looks like for each condition?**

For most AT conditions: yes. AT-3 through AT-9, AT-11, AT-12 are precise.

For AT-2 and AT-10: partially. AT-2 depends on a composition track that must
land before live eval — the sequencing is implied but not stated as a transition
condition. AT-10 requires an observation whose content is not yet constrained —
"structured" without a schema is not verifiable.

Both of these are one level below the Architect review threshold — they are
implementation-phase clarity items, not gate-decision safety gaps. The Architect
decision does not need to resolve them before approving.

---

## [Route]

→ **PROCEED to Architect review.** Both S3-R11-X1 HOLD blockers are closed.
No new blocker-level ambiguity was introduced. The revised request is safe to
route.

→ **PROP (PROP-030 errata)** → Compiler/Grammar Expert:
  Define canonical `runtime.temporal_scope_exclusion` (or equivalent) reason
  code for AT-7 and AT-12 executor scope refusals. Must land before or
  concurrent with Phase 1 implementation; does not block Architect review.

→ **track** (parallel to Phase 1 implementation) → Research Agent or Bridge
  Agent: `prop-005-temporal-read-observation-v0` (or equivalent). Define minimum
  content of a `temporal_read_observation` envelope: time coordinate, contract
  ref, token ref, result status. Name this track in AT-10 as a parallel pending
  obligation. Must land before Phase 1 live reads; does not block Architect
  review.

→ **PROP (request amendment)** → Meta Expert (one sentence, if desired before
  Architect review, otherwise carry into Architect decision record): Add the
  Q2 redirect path: "If the Architect decides Q2 = temporary deferral, this
  document must be superseded; it is not sufficient for that path." Low urgency
  — the recommended Q2 answer avoids this entirely.

→ **backlog** (post-gate, do not block Architect review):
  - AT-2 sequencing explicitness (approval ≠ immediate live eval)
  - Ch7 sync: `spec-ch7-gate3-approval-sync` (already routed in C1 revision)
  - CompatibilityReport composition: `compatibility-report-composition-v0`

---

## Risk Table

| Risk | Severity | New since X1? | Blocker before Architect review? | Required before live eval? | Post-gate backlog |
|------|----------|---------------|----------------------------------|---------------------------|-------------------|
| C-1: authority ref deferrable (HOLD) | HIGH | — | **CLOSED** ✅ | — | — |
| C-2: AT-10 conditional on Q5 (HOLD) | HIGH | — | **CLOSED** ✅ | — | — |
| AT-10 observation kind informal; "note gap" not verifiable | Medium | Yes | No | Yes — name pending track in AT-10 | prop-005-temporal-read-observation-v0 |
| AT-2 "must land before live eval" sequencing implicit | Low-Medium | Yes | No | Yes — add explicit transition statement | compatible with current text |
| Q2 temporary-exclusion path uncovered (redirect undefined) | Low | Yes | No | No — recommended path avoids it | one-sentence amendment if desired |
| AT-12 / AT-7 reason code coined, not canonical | Low | Yes | No | No — semantic is correct | PROP-030 errata for reason code |
| BiHistory excluded | — | — | ✅ Four layers | — | — |
| Production cache excluded | — | — | ✅ Consistent | — | — |
| Abstract TBackend vs Ledger-backed phase | — | — | ✅ C4 phase table | — | — |
| AT-12 CORE artifact refusal | — | — | ✅ Present | — | — |
| Scope does not expand on approval | — | — | ✅ Scope Boundary | — | — |

**Overall: PROCEED. Both HOLD items are closed. Four new low-to-medium naming
and sequencing observations do not require further revision before Architect
review. They are routed to parallel implementation-phase tracks.**
