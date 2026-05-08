# Discussion: Gate 3 Request Readiness Pressure

Card: S3-R10-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: meta-expert
Track: gate3-request-readiness-pressure-v0
Date: 2026-05-08
Status: complete — routed

---

## Question

Does S3-R10 evidence give enough grounding to draft a Gate 3 opening request,
and what would make such a request unsafe if drafted now?

## Context: S3-R10 C1–C4 Summary

**C1** `executor-approval-token-report-proof-v0`

Full PROP-030 validation matrix proved in report-only CompatibilityReport:
all 13 runtime refusal cases PASS. The valid-token case confirms
`executor_approval_check: ok` while Gate 3 still blocks
`evaluation_readiness` with `temporal_gate3_closed`. No executor, TBackend,
Ledger, or cache call attempted.

**C2** `guarded-runtime-executor-approval-enforcement-v0`

GuardedRuntimeMachine upgraded from generic temporal refusal to PROP-030
approval-aware refusal. Definitive refusal ordering established:

```text
capabilities -> approval token -> Gate 3 -> cache key schema -> artifact guard
```

Reason code mapping is now canonical (not lossy):

| CompatibilityReport | GuardedRuntimeMachine | Status |
|--------------------|-----------------------|--------|
| `temporal_executor_approval_missing` | `executor_approval_missing` | PROP-030 canonical |
| `temporal_gate3_closed` | `temporal_gate3_closed` | identical |
| `temporal_cache_schema_mismatch` | `temporal_cache_schema_mismatch` | identical |

GuardedRuntimeMachine should remain proof-local until production RuntimeMachine
owns the same checks.

**C3** `compatibility-report-package-descriptor-consumption-v0`

Ratified Gate 2 descriptor metadata consumed into report-only
`backend_check.temporal_backend_descriptor`. Blocks on missing hashes,
missing capabilities, malformed diagnostics, non-authorization violation, and
CORE cache policy for TEMPORAL (OOF-TM9). Every report carries:

```text
"descriptor bihistory_read is metadata evidence only;
 it does not prove physical BiHistory at(vt:, tt:) serving"
```

`runtime_enforced: false` throughout. Gate 3 not opened.

**C4** `invariant-source-metadata-preservation-v0`

Parser → SemanticIR preserves invariant source metadata and start span.
Descriptive only; no language or runtime semantics changed.

---

## Closure Check: S3-R9-X1-S M-Items

| S3-R9-X1-S item | Resolution after S3-R10 |
|-----------------|------------------------|
| M-1: enforcement proof as Gate 3 prerequisite | Partial — GuardedRuntimeMachine proves check ordering; production binding still missing |
| M-2: GuardedRuntimeMachine path decision (A or B) | **Closed** — Path A taken; GuardedRM upgraded to first-class codes (C2) |
| M-3: token validation matrix (all 13 cases proved) | **Closed** — C1 PASS for all 13 + 5 additional invariant checks |

The two previously blocking items are closed. The enforcement gap remains and
is correctly scoped to the Gate 3 request, not the proof surface.

---

## [Agree]

**The proof chain from smoke through enforcement is now a coherent vertical
stack.**

Starting from S3-R8-C1 through S3-R10-C2, there is an unbroken proof surface:

```text
six-surface smoke         → runtime evaluates/refuses correctly
CompatibilityReport C1    → reports load/eval split + all four executor profiles
CompatibilityReport C3    → reports descriptor metadata + bihistory warning
token report proof C1-R10 → all 13 PROP-030 token refusals proved
GuardedRuntimeMachine C2  → enforces missing/gate/cache-key before any live path
cache-key contract C3-R9  → TEMPORAL key required; CORE-shaped refused L-T5
```

Every layer is proof-local and report-only. That is correct for this milestone.
What matters is that the chain is complete and the proofs are consistent with
each other — which they now are.

**M-2 is closed: reason code mapping is canonical, not lossy.**

The S3-R9 C4 track explicitly described the GuardedRuntimeMachine mapping as
"intentionally lossy." S3-R10 C2 corrects this: the GuardedRuntimeMachine now
uses the canonical PROP-030 reason codes. When the production RuntimeMachine
is built, it will have a correct proof-local reference to build from, not a
reference that requires mental translation.

This matters strategically: proof-local code that uses wrong reason codes
teaches future implementers wrong names. That is corrected.

**C3 makes the descriptor-to-report bridge explicit and non-authorizing.**

The Gate 2 ratification established that descriptor metadata is trusted. C3
bridges that metadata into the CompatibilityReport shape. But crucially, C3 is
not passive — it carries explicit non-authorization flags and the BiHistory
warning on every report. This means the CompatibilityReport cannot be read as
an authorization even if the descriptor content is trusted.

This is the right design: trust of metadata does not imply authorization of
execution. C3 makes that distinction machine-readable.

**The refusal ordering from C2 is the production implementation contract.**

The check order:

```text
capabilities -> approval token -> Gate 3 -> cache key schema -> artifact guard
```

is now proved in a proof-local machine that Architect Supervisor can read as
a specification. When a Gate 3 request asks "what must production RuntimeMachine
do?", this ordering is the answer.

---

## [Challenge]

### C-1. `runtime_enforced: false` throughout the entire stack

Every proof layer from S3-R5 through S3-R10 carries this flag. The proofs are
correct. The ordering is right. The refusal codes are canonical. And nothing
in production enforces any of it.

This is not a new observation — it has been tracked since S3-R7-X1-S. But
it is important to name it precisely for the Gate 3 request:

> The proof chain proves what production MUST do. It does not prove that
> production WILL do it.

A Gate 3 opening request that does not include an explicit commitment — "before
any live TEMPORAL evaluation, production RuntimeMachine must bind these checks
and report `runtime_enforced: true`" — is incomplete. The Architect approving
the request must be approving a specific implementation commitment, not just a
proof artifact.

**Severity**: not a blocker to writing the request. It IS the core of what
the request must say.

### C-2. Physical BiHistory serving is unproved, and C3 names this explicitly

C3 carries this required warning on every report:

```text
descriptor bihistory_read is metadata evidence only;
it does not prove physical BiHistory at(vt:, tt:) serving
```

This is correct. Gate 2 ratified descriptor metadata. Descriptor metadata says
the Ledger adapter claims `bihistory_read`. But:

- Does the native data plane serve `at(vt:, tt:)` correctly?
- Does bitemporal append actually record transaction_time independently of
  valid_time?
- Does the `rb_range_by_valid_time` and `rb_at_bi` gap identified in the
  S3-R2-X1-S external review still exist in the implementation?

A Gate 3 opening for BiHistory evaluation without physical serving proof creates
a risk: evaluation proceeds, TBackend is called, and the native plane serves
data from the wrong time coordinate silently — because the descriptor claim
was treated as execution proof.

**Severity**: HIGH for BiHistory scope. The Gate 3 request should explicitly
decide whether BiHistory evaluation is in scope or whether initial Gate 3 is
scoped to History (valid_time) only, with BiHistory requiring a separate
physical serving proof.

This is not a new gap — it was identified in S3-R2-X1-S. It has never been
closed. It would be unsafe to let it remain unnamed in the Gate 3 request.

### C-3. Authority infrastructure is unspecified

PROP-030 defines the `ExecutorApprovalToken` shape. It specifies `authority_ref`
as identifying "who is allowed to issue the token" — but does not define what
that identifier looks like, how a production RuntimeMachine verifies it, or how
revocation propagates.

The C1 R10 track notes this explicitly:

> [Q] Open Question: Which authority registry and revocation source owns
> production token trust?

In a production Gate 3 deployment:

- Token issuance: what is the process? Who can issue a `tbackend_gate3` scoped
  token?
- Authority verification: is `authority_ref` a public key fingerprint, a
  recorded-decision hash, a URL, or something else?
- Revocation: how does a revoked token reach RuntimeMachine instances that
  already have a copy?
- In-flight evaluation: what happens when a token is revoked during execution?

None of these have answers. The Gate 3 request must specify at least the first
two before the Architect can evaluate whether the authorization model is secure.

**Severity**: medium — these don't need to be solved before writing the
request, but they must be answered within it. A request that says "we'll figure
out authority later" is not reviewable.

### C-4. CompatibilityReport dimensions are siloed across proof artifacts

After S3-R10, the CompatibilityReport has these separate dimensions:

| Dimension | Proof artifact | Report-only? |
|-----------|----------------|-------------|
| load / evaluate split | C1 R7 (temporal load check) | yes |
| executor profiles 1-2 | C2 R8 (executor boundary) | yes |
| executor profiles 3-4 | C4 R9 (C2 profile consistency) | yes |
| token validation matrix | C1 R10 (approval token proof) | yes |
| descriptor backend_check | C3 R10 (descriptor consumption) | yes |
| cache schema | C3 R9 (cache-key contract) | proof-local |
| GuardedRM enforcement | C2 R10 (approval enforcement) | proof-local |

Each proof was designed to be standalone. But a production CompatibilityReport
must compose all these dimensions into a single report that RuntimeMachine can
act on.

No track currently composes these into a unified report shape. This is not a
bug — composition is a Gate 3 implementation task. But the Gate 3 request
should name it explicitly: "the production CompatibilityReport must compose
the approval, descriptor, cache, and evaluation dimensions into one coherent
report, all with `runtime_enforced: true`."

### C-5. Production signature verification is still a placeholder

C1 R10 uses `recorded-decision-hash` as the signature method. The track notes:

> [R] Production signature verification must replace the proof-local
> deterministic `recorded-decision-hash`.

The PROP-030 token shape says `signature.alg: "ed25519|recorded-decision-hash"`.
For production Gate 3 tokens, the signature must be verifiable without a
shared secret and without trusting the token issuer's claim about the
content. Neither ed25519 key management nor the recorded-decision-hash
verification process is specified.

**Severity**: medium — this does not block the Gate 3 request draft, but it
is a non-trivial implementation requirement that the request must surface.

---

## [Missing]

### M-1. The Gate 3 request document itself

After ten rounds of evidence, there is no draft of the actual Gate 3 opening
request. The proof artifacts collectively constitute the evidence base, but
Architect Supervisor cannot review proof artifacts as a gate decision — they
need a formal request document that:

- names what is being authorized
- lists acceptance conditions that production must meet before live evaluation
- records what is explicitly NOT authorized (stream executor, OLAP executor,
  production cache, Ledger write/replay, BiHistory if excluded)
- identifies the implementation owner for each enforcement item
- includes PROP-030 as a formal dependency
- includes the refusal ordering from C2 as a required implementation contract
- names the authority infrastructure required

This document should be authored by Compiler/Grammar Expert + Meta Expert and
routed to Architect Supervisor for decision. Everything else is prerequisite.

### M-2. BiHistory scope decision

The Gate 3 request must explicitly decide:

**Option A** (full scope): Gate 3 opens for both History (valid_time) and
BiHistory (bitemporal). Requires a physical serving proof before BiHistory
evaluation is allowed. The C3 warning becomes a blocking condition in the
production CompatibilityReport.

**Option B** (restricted scope): Gate 3 opens for History (valid_time) only.
BiHistory evaluation requires a separate gate decision after physical serving
is proved. This is lower risk and defers the `rb_at_bi` implementation gap
question until a dedicated proof exists.

Neither option is wrong. But the choice must be made in the request, not left
as an open question.

### M-3. Explicit Gate 3 exclusions list

The Gate 3 request should include a machine-readable or clearly enumerated
exclusions list:

```text
Gate 3 opening DOES authorize:
  - live TEMPORAL History evaluation (if Option A: + BiHistory)
  - production ExecutorApprovalToken validation
  - production CompatibilityReport enforcement (runtime_enforced: true)
  - single-axis TBackend read binding

Gate 3 opening DOES NOT authorize:
  - stream executor production binding
  - OLAP executor production binding
  - production runtime cache (separate gate)
  - Ledger write / append / compact / replay
  - BiHistory evaluation (if Option B)
  - self-issued tokens or capability-flag-only authorization
  - evaluation without a valid ExecutorApprovalToken
```

Without an explicit exclusions list, implementers may interpret "Gate 3 is
open" as permission for adjacent surfaces that were never in scope.

---

## [Sharper Question]

Not: "Is the proof chain complete?"

The proof chain is complete. The proofs are coherent. The refusal ordering is
correct. Everything that can be proved without a live executor is proved.

The sharper question is:

> **Is the proof chain being used as a substitute for the Gate 3 request, or
> as evidence for it?**

Ten rounds of proof work have produced a strong evidence base. If the team
continues adding proof tracks without writing the request, the evidence base
will keep growing but no gate decision will happen. At some point, additional
proof work before the request is submitted is not evidence accumulation — it is
risk-avoidance displacement.

The current state of proofs is sufficient for Architect Supervisor to evaluate
a request. The missing item is not more proof. It is the request document that
takes the proof and translates it into an authorization decision with acceptance
conditions.

---

## [Route]

→ **PROCEED**. Draft the Gate 3 opening request. This is not a "proceed
  to prep" — it is a proceed to author. The request is ready to be written.

→ **PROP (Gate 3 opening request)** → Compiler/Grammar Expert + Meta Expert:
  `runtime-temporal-executor-gate3-request-v0`.
  Must include:
  - What Gate 3 authorizes (and explicitly excludes)
  - BiHistory scope decision (Option A or B)
  - Production enforcement commitment (runtime_enforced: true before live eval)
  - Required production check ordering (capabilities → token → Gate 3 → cache key → guard)
  - Authority infrastructure specification (token issuance, authority_ref format,
    revocation process, in-flight handling)
  - Production signature requirement (replace recorded-decision-hash)
  - CompatibilityReport composition requirement (all dimensions unified)
  - CompatibilityReport audit/persistence requirement
  - Implementation owner for each acceptance condition
  - PROP-030 as formal dependency
  - Evidence pointer to S3-R8 through S3-R10 proof chain
  Priority: **ready now**.

→ **backlog** (inside Gate 3 implementation, not blocking the request):
  CompatibilityReport dimension composition, production signature infrastructure,
  BiHistory physical serving proof (if Option A chosen).

→ **backlog** (completely separate from Gate 3):
  Stream executor production binding, OLAP executor binding, Ledger write/append/
  replay, production runtime cache — these are later gates that must not be
  implied by Gate 3 opening.

---

## Risk Table

| Risk | Severity | Blocker before request? | Blocker inside request? | Post-Gate-3 impl backlog |
|------|----------|------------------------|------------------------|--------------------------|
| `runtime_enforced: false` throughout | HIGH | No | YES — request must commit to `true` before live eval | — |
| BiHistory physical serving unproved (C3 warning) | HIGH | No | YES — scope decision (Option A/B) required | BiHistory physical proof if A |
| Authority infrastructure undefined (issuance, revocation, in-flight) | Medium | No | YES — must be in request | — |
| Production signature verification is placeholder | Medium | No | Yes (surface in request) | ed25519 or equivalent |
| CompatibilityReport dimensions siloed, not composed | Low-Medium | No | Yes (name as acceptance condition) | Composition track post-gate |
| CompatibilityReport audit/persistence missing | Low | No | Yes (name as requirement) | Audit track post-gate |
| Gate 3 exclusions list absent | Medium | No | YES — required for safe implementation | — |
| Proof chain used instead of being evidence for request | Strategic | **YES** | — | — |

**Overall: PROCEED. Draft the request. The evidence base is complete. The
missing artifact is the request document itself, and only the request can force
the remaining design decisions into resolution.**
