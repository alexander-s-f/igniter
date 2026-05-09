# Discussion: Gate 3 Decision Safety Pressure

Card: S3-R13-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: gate3-decision-safety-pressure-v0
Date: 2026-05-09
Status: complete — routed

---

## Question

Does the Gate 3 decision record (`gate3-decision-record-v0.md`, S3-R13-C1-A)
contain any hidden authorization leak — a reading path by which "approved"
could be interpreted as authorizing Ledger adapter, BiHistory, stream/OLAP,
writes, replay, compact, or production cache? And is the authority_ref /
issuance / revocation specification concrete enough for Phase 1 implementation?

---

## Surface-By-Surface Closure Check

### Ledger adapter

| Location | Language |
|----------|----------|
| Section "Decision" header | "using a proof-local or non-Ledger adapter / with no Ledger package binding" |
| Authorized Scope table | "Abstract TBackend call — Allowed only through a proof-local/non-Ledger adapter" |
| Explicit Exclusions table | "Real Ledger-backed TBackend adapter — Closed until Phase 2 Architect addendum" |
| Explicit Exclusions table | "Any Ledger package read through package code — Closed until Phase 2 Architect addendum" |
| Safe status phrase | "Gate 3 is not open for Ledger..." |
| Acceptance Surface | "`runtime_enforced: true` must not imply Ledger authorization" |

**Verdict: ✅ Closed across six independent locations.** No reading path from
"approved" leads to Ledger adapter authorization for Phase 1.

### BiHistory

| Location | Language |
|----------|----------|
| Explicit Exclusions | "`BiHistory[T]` live evaluation — Closed; separate gate required" |
| Explicit Exclusions | "`bihistory_at`, transaction-time read, `at(vt:, tt:)` — Closed; separate gate required" |
| Q2 decision | "BiHistory requires a separate gate request after physical `at(vt:, tt:)` serving proof lands. It cannot be added to Phase 1 or Phase 2 by quiet addendum." |
| Safe status phrase | "Gate 3 is not open for ... BiHistory..." |

**Verdict: ✅ Closed with the critical Q2 answer.** The phrase "cannot be added
to Phase 1 or Phase 2 by quiet addendum" directly closes the gap from S3-R12-X1-S
C-3 (temporary-exclusion path uncovered). BiHistory requires a new gate, not an
addendum — the Architect named this explicitly.

### Stream / OLAP executor

| Location | Language |
|----------|----------|
| Explicit Exclusions | "Stream executor — Closed; separate gate required" |
| Explicit Exclusions | "OLAP executor — Closed; separate gate required" |
| Safe status phrase | "Gate 3 is not open for ... stream, OLAP..." |

**Verdict: ✅ Closed.**

### Writes / replay / compact / subscribe

| Location | Language |
|----------|----------|
| Explicit Exclusions | "Ledger write / append / replay / compact — Closed; separate gate required" |
| Explicit Exclusions | "Ledger subscribe / changefeed / stream binding — Closed; separate gate required" |
| Q3 Phase 2 addendum requirements | "refusal cases for writes/replay/compact/subscribe/stream/BiHistory" must be named in the addendum |

**Verdict: ✅ Closed.** Write operations are excluded from both Phase 1 and
Phase 2. The Phase 2 addendum requirements explicitly enumerate them as
surfaces that the Phase 2 implementation must have named refusal cases for —
which means even Phase 2 cannot accidentally enable writes.

### Production cache

| Location | Language |
|----------|----------|
| Explicit Exclusions | "Production RuntimeMachine memoization/cache — Closed; separate gate required" |
| Q4 decision | "production cache is deferred" |
| Q4 decision | "must not introduce production RuntimeMachine memoization or a production cache store" |

**Verdict: ✅ Closed.** Q4 permits TEMPORAL cache-key schema validation (to
enforce L-T5 and prevent silent staleness) but explicitly forbids a production
cache store. This is the right distinction.

### `runtime_enforced: true` scope

A subtle leak path: if `runtime_enforced: true` is set in CompatibilityReport
for Phase 1, does that flag imply Ledger authorization elsewhere in the
runtime?

| Location | Language |
|----------|----------|
| Authorized Scope | "`runtime_enforced: true` — Allowed only for the authorized Phase 1 CompatibilityReport path" |
| Acceptance Surface | "`runtime_enforced: true` must not imply Ledger authorization." |
| Acceptance Surface | "`runtime_enforced: true` is allowed only for this restricted Phase 1 path." |

**Verdict: ✅ Addressed.** The Acceptance Surface explicitly severs the link
between the flag and Ledger authorization. An implementer cannot argue that
`runtime_enforced: true` implicitly authorizes adjacent surfaces.

---

## [Agree]

**The exclusions table is comprehensive and cross-referenced correctly.**

Every excluded surface appears in at least two locations in the document:
the Explicit Exclusions table and the Safe status phrase or a Q-decision. The
mutual reinforcement makes accidental omission harder — an implementer would
have to miss the same surface in two independent sections.

**The "no excluded surface may be inferred" clause closes the implication gap.**

The final line of the Explicit Exclusions section:

> No excluded surface may be inferred from the words "Gate 3 approved".

This is a direct prohibition on the interpretive shortcut "Gate 3 is open,
therefore TEMPORAL in general is live." Combined with the Scope Boundary clause
in the request, this prevents scope-creep from ambiguous phrasing.

**The S3-R12-X1-S medium risks are elevated to pre-live conditions correctly.**

The three items from S3-R12-X1-S that needed parallel tracking are now hard
pre-live gates in Section "Pre-Live Conditions":

1. `compatibility-report-composition-v0` — was AT-2 dependency
2. `prop-005-temporal-read-observation-v0` — was AT-10 observation kind gap
3. `prop-030-temporal-scope-exclusion-errata-v0` — was AT-12/AT-7 coined reason code

The Architect decision converted routing recommendations into blocking conditions
for Phase 1 live reads. An implementer cannot skip any of these by claiming they
are "post-gate backlog."

**The Phase 2 addendum requirement list is enumerated, not open-ended.**

Q3 Phase 2 names seven specific items that the addendum must cover. An
implementer who wants Phase 2 authorization cannot submit a minimal addendum —
they must address adapter identity, descriptor hash, operation scope, approval
token scope, observation emission shape, persistence gap handling, and refusal
cases for writes/replay/compact/subscribe/stream/BiHistory. This is a
meaningful checklist, not a rubber stamp.

**Q2 BiHistory exclusion is stronger than the request required.**

The request said "Q2 = separate gate required" as a recommendation. The
Architect decision went further: "It cannot be added to Phase 1 or Phase 2 by
quiet addendum." This closes the S3-R12-X1-S M-2 gap where an alternative Q2
answer (temporary deferral via addendum) was uncovered by the request text. The
decision collapses both options into one: new gate, no addendum path.

---

## [Challenge]

### C-1. Authority ref resolution mechanism is not specified for Phase 1

The decision record provides the authority URI:

```text
architect-supervisor://igniter-lang/gates/gate3/runtime-temporal-executor/restricted-history-valid-time-v0/2026-05-09
```

and states: "Phase 1 tokens may be issued only by an implementation or proof
harness that explicitly references this decision record and the exact
`authority_ref` above."

But it does not say how the Phase 1 executor *learns* the trusted URI at
runtime. Options:

- **Hardcoded in the executor**: the executor embeds the URI as a constant and
  compares token `authority_ref` against it. Simplest for Phase 1; fragile for
  production.
- **Loaded from runtime config**: a startup config file carries the trusted URI.
  The config must itself be trusted (unsigned config = no real security).
- **Embedded in the `.igapp` manifest**: the `.igapp` requirements carry
  the expected `authority_ref`. But the Issuance Rule explicitly says "tokens
  are not self-issued by `.igapp` artifacts" — using `.igapp` to name the
  authority would blur this boundary.

For a Phase 1 proof-local implementation with a `MemoryBackend`, hardcoding
the URI against this document is the correct and safe approach. The Issuance
Rule implicitly permits this ("references this decision record and the exact
authority_ref above"). But "implicitly permits" is not the same as "specifies."

**Severity**: medium for Phase 1; high for Phase 2. Not a blocker for Phase 1
if implementers read the Issuance Rule carefully. But the decision record should
add one sentence: "For Phase 1, the trusted URI may be embedded as a constant
in the executor implementation, directly referencing this document."

### C-2. "Runtime authority registry" is referenced but not defined

The revocation rule reads:

> The authority ref is active until one of the following exists: ... the
> runtime authority registry marks the ref as revoked ...

A "runtime authority registry" is named as a revocation mechanism, but no
such registry exists in any spec, track, or PROP. This is a forward reference
to an artifact that may never be created.

For Phase 1, revocation via this mechanism is effectively a no-op: there is no
registry to consult. Revocation for Phase 1 is correctly handled by the other
two conditions: a `gate3-revocation-*` document, or token expiry. The registry
clause is harmless for Phase 1.

For Phase 2, however, if the runtime authority registry does not exist, one of
the three revocation paths is permanently unavailable. This is not a safety
risk — Phase 2 can still use the other revocation paths — but a reference to
an undefined artifact creates confusion.

**Severity**: low for Phase 1; medium for Phase 2. The decision record should
note: "The runtime authority registry is not yet defined. For Phase 1, the
active revocation paths are: a `gate3-revocation-*` document, and token
expiry. The registry mechanism requires a separate definition track before
Phase 2."

### C-3. In-flight revocation during evaluation is not addressed

This was identified in S3-R10-X1-S C-3 and was never formally resolved. The
decision record defines revocation as an "independent refusal condition" and
requires runtime validation to check revocation. But it does not address what
happens when a token is revoked during an active `read_as_of` call:

- Does the executor check revocation before every backend call, or only once
  at evaluation start?
- If the token expires during a multi-step evaluation, does the partial result
  become invalid?
- For Phase 1 (proof-local, single-step): this is moot — there is no
  concurrent token revocation in a proof harness.
- For Phase 2 (real Ledger adapter, potentially longer reads): this could
  matter.

**Severity**: low for Phase 1; medium for Phase 2. Acceptable to leave
unresolved for Phase 1. Should be named as a required specification item in
the Phase 2 addendum.

### C-4. "Non-Ledger adapter" is an undefined category

The Phase 1 description permits a "proof-local or non-Ledger adapter." This
is correct in intent but "non-Ledger" is not defined anywhere in spec, PROP,
or this document. An adapter that wraps a thin proxy over Ledger could be
argued to be "non-Ledger" since it doesn't directly call the Ledger package.

The Explicit Exclusions table's second row tightens this: "Any Ledger package
read through package code — Closed until Phase 2 Architect addendum." This is
the binding definition: any adapter that calls Igniter-Ledger package code is
Ledger-backed and requires a Phase 2 addendum. Indirect calls through wrappers
do not escape this — the test is "does the adapter path eventually invoke
Igniter-Ledger package code?"

The "non-Ledger" language in the Phase 1 description is redundant with and
weaker than the Explicit Exclusions table. It should be tightened to: "a
proof-local adapter that does not invoke Igniter-Ledger package code."

**Severity**: low. The Explicit Exclusions table is the binding condition;
"non-Ledger" in the Phase 1 description is informal shorthand. An implementer
who reads both sections understands the boundary correctly.

---

## [Missing]

### M-1. No explicit statement that Phase 1 may hardcode the authority URI

The Issuance Rule implies it but does not state it. For Phase 1 implementers:
the safest reading is "embed the URI as a constant in the executor." The
decision record should confirm this explicitly to prevent implementers from
waiting for a production signing system before starting Phase 1.

### M-2. Phase 2 addendum trigger is "explicit Architect addendum" but the format is unspecified

The Phase 2 addendum is mentioned in five places. The Q3 decision specifies
what it must contain. But it does not specify:
- What document type the addendum is (a new `gate3-*` document? A section
  appended to this record?)
- Who requests it (Meta Expert?)
- Who reviews it before Architect sign-off?

This is a process gap, not a safety gap for Phase 1. Named for completeness.

---

## [Sharper Question]

Not: "Does the decision record authorize too much?"

It does not. The exclusions are comprehensive, the safe status phrase is
correct, the pre-live conditions elevate the right S3-R12-X1-S gaps to hard
gates, and the Q2 answer is stronger than required.

The sharper question is:

> **Can a Phase 1 implementer read this decision record in isolation and
> derive exactly what they must build, without ambiguity about the authority
> URI resolution or the observation shape, and without accidentally exceeding
> the authorized scope?**

Answer: **Almost yes.**

- Scope boundaries: unambiguous — excluded surfaces are named, layered, and
  mutually reinforcing.
- Authority URI: usable (hardcode from this document), but the permission to
  hardcode is implicit.
- Observation shape: correct (unconditional emission required), but minimum
  content is deferred to `prop-005-temporal-read-observation-v0` — correctly
  named as a pre-live condition.
- Revocation: usable for Phase 1 (expiry + revocation-* document), but the
  "runtime authority registry" reference is a dangling pointer.

The two implicit items (hardcode permission, dangling registry reference) are
low-friction to resolve: one sentence each. They do not require further
revision of the gate request or a new gate decision.

---

## [Route]

→ **PROCEED.** The decision record is safe. No hidden authorization leaks
were found. No blocker exists for Phase 1 implementation to begin.

→ **AMEND** (non-blocking, two sentences in the decision record):
  
  *Sentence 1* (closes C-1, M-1): Add to the Issuance Rule:
  > For Phase 1 proof-local and MemoryBackend implementations, the trusted
  > authority URI may be embedded as a constant in the executor, referencing
  > this document directly.

  *Sentence 2* (closes C-2): Add to the revocation rule:
  > The runtime authority registry is not yet defined. For Phase 1, the
  > active revocation paths are a `gate3-revocation-*` document and token
  > expiry. A runtime authority registry requires a separate definition track
  > before Phase 2.

  These are documentation amendments to the decision record, not a new gate
  request. They do not change the authorized scope.

→ **track** (Phase 2 planning, not blocking Phase 1):
  `gate3-authority-registry-v0` — define the runtime authority registry
  format, Phase 2 revocation propagation mechanism, and in-flight revocation
  behavior.

→ **track** (Phase 2 addendum, name the process):
  The Phase 2 addendum process should be described in `docs/gates/README.md`:
  who requests it, what document type, who reviews before Architect sign-off.

→ **backlog** (Phase 2 implementation, not blocking Phase 1):
  C-4 "non-Ledger adapter" definition: tighten the Phase 1 description to
  "proof-local adapter that does not invoke Igniter-Ledger package code."
  C-3 in-flight revocation: name as required specification in Phase 2 addendum.

---

## Risk Table

| Risk | Severity | Blocker for Phase 1 impl? | Blocker for Phase 1 live reads? | Blocker for Phase 2? |
|------|----------|---------------------------|----------------------------------|----------------------|
| Ledger adapter accidentally authorized | — | **CLOSED ✅** | — | — |
| BiHistory accidentally authorized | — | **CLOSED ✅** | — | — |
| Stream/OLAP accidentally authorized | — | **CLOSED ✅** | — | — |
| Writes/replay/compact/subscribe authorized | — | **CLOSED ✅** | — | — |
| Production cache accidentally authorized | — | **CLOSED ✅** | — | — |
| `runtime_enforced: true` implies Ledger | — | **CLOSED ✅** | — | — |
| Authority URI resolution mechanism implicit | Medium | No — implicit permission sufficient for Phase 1 | No | No — but name explicitly |
| "Runtime authority registry" undefined | Low | No | No | Medium — dangling reference |
| In-flight revocation unspecified | Low | No | No | Medium — Phase 2 addendum item |
| "Non-Ledger adapter" undefined category | Low | No | No | Low — Explicit Exclusions table is binding |
| Phase 2 addendum process unspecified | Low | No | No | Low — process gap |
| Pre-live conditions correctly elevated | — | **CONFIRMED ✅** | — | — |
| S3-R12-X1-S C-3 Q2 temporary-exclusion gap | — | **CLOSED by Q2 answer ✅** | — | — |

**Overall: PROCEED. Zero blockers for Phase 1 implementation. Two non-blocking
documentation amendments recommended. Medium risks are Phase 2 concerns only.**
