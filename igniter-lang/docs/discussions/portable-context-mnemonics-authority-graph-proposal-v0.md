# Shadow Proposal: Portable Context Mnemonics — Compressed Authority Graph v0

Card: Shadow-MN-R1-C4-SP
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: shadow-proposal
Initiator: user
Track: portable-context-mnemonics-authority-graph-proposal-v0

Shadow status: exploration only. This document does not create canon,
does not author accepted grammar syntax, and does not authorize
parser/tooling work. It is a design proposal for review and pressure,
not an implementation instruction.

Depends on:
- Shadow-MN-R1-C1-P1 (grammar options)
- Shadow-MN-R1-C2-P1 (reconstruction proof)
- Shadow-MN-R1-C3-X (comprehension pressure)

---

## Problem Statement

The current mnemonic grammar variants (C1-P1 V1/V2/V3) solve **context
compression** — fitting more information into fewer tokens. The deeper problem
is different:

> An agent must be able to **operate on the compressed form** without unpacking
> it. The compressed form must be closed under the operations agents actually
> perform.

The most important operation in any multi-agent orchestration context is:

```text
"Is X authorized? By whom? What is blocked?"
```

This question should be answerable directly from the mnemonic — without
restoring the full document chain. Currently it is not. An agent reading
`B1=CLOSED` must remember the rule `Gate > TrackClaim`, apply it, and
check whether B1 was closed by a gate or by a track recommendation. Three
steps, one of which requires external knowledge.

The distinction this proposal targets:

```text
Compressed narrative  →  smaller text, same reasoning steps
Compressed authority graph  →  fewer reasoning steps, authority is structural
```

---

## Core Insight: Authority as a First-Class Attribute

The hardest thing to preserve across context windows is not state — it is
**whose state it is**. Currently authority travels as a separate rule
(`Gate > TrackClaim`) that must be kept in working memory alongside the
state assertions.

This proposal makes authority a **first-class marker on every assertion**:

```text
B1[CLOSED:R47-C3-A]          — closed; authority carrier is Architect gate R47
B7[CLOSED:R47-C3-A]          — closed; same authority
impl[HELD:R45-C3-A]          — held; authority is Architect gate R45
evidence_satisfied[B1]       — no authority carrier; this is evidence only
```

The authority carrier `[AUTH:source]` travels with the assertion. An
assertion without a carrier is structurally different from one with a
carrier. The invariant

```text
evidence != formal closure != implementation authorization
```

is no longer a rule-to-remember — it is **encoded in the syntax**:

- `[EVIDENCE]` or bare `=` → evidence, no authority
- `[CLOSED:gate-ref]` → formally closed, authority is the cited gate
- `[AUTH:gate-ref]` → authorized action, authority is the cited gate

An agent can answer "is this formally closed?" by checking the carrier
type, not by recalling a rule.

---

## Three Operationally Closed Levels

The mnemonic operates at three levels. Each level is **sufficient for a class
of decisions** without expanding to a higher level. Expansion is lazy and
on-demand.

### Level 0 — Atomic (decision-ready)

```text
B1[CLOSED:R47-C3-A]
B7[CLOSED:R47-C3-A]
B8[CLOSED:R47-C3-A]
B3/B4/B5/B6/B9[OPEN]
impl[HELD:R45-C3-A]
surface[facade-only]
```

Answers without unpacking:
- "Can I write CLI code?" → `impl[HELD:...]` → NO
- "Is B1 formally closed?" → `B1[CLOSED:R47-C3-A]` → YES, Architect gate
- "Is this closure by a track or a gate?" → carrier type → gate
- "What is currently public?" → `surface[facade-only]`

Level 0 is the minimum viable mnemonic. It fits in ~6 lines. It answers
all authority and authorization questions.

### Level 1 — Group (state-ready)

```text
PROP036.CLI{
  closed=[B1,B7,B8]:R47-C3-A
  open=[B3,B4,B5,B6,B9]
  impl=HELD:R45-C3-A
  surface=facade-only
  ?B1 → gates/prop036-b7-b8-docs-and-criteria-precision-review-v0.md
  ?impl → gates/prop036-cli-exposure-design-and-blocker-tracking-decision-v0.md
}
```

Adds beyond Level 0:
- grouping by topic frame
- **expansion anchors** `?key → path` — on-demand, non-blocking
- level 0 is mechanically derivable from level 1

Answers additionally:
- "Where do I get details on B1 closure?" → `?B1 → ...`
- "What frame does this belong to?" → `PROP036.CLI{}`

### Level 2 — Balanced (onboarding-ready)

Equivalent to current MN-B plus:
- closure evidence summaries
- non-authorized surface list
- explicit invariant in canonical form
- expansion anchors for all authority sources

Used when:
- onboarding a fresh agent
- switching models across sessions
- starting a new chat with no prior context

Level 2 expands to MN-B. Level 1 and Level 0 are derived mechanically
from Level 2 by stripping evidence and anchor detail.

---

## Expansion Anchors: Lazy Self-Unpacking

The `?key → path` construct is what makes the grammar **self-unpacking**
without requiring upfront expansion. It is not a state assertion — it is
an **address for on-demand retrieval**.

```text
PROP036.CLI{
  closed=[B1,B7,B8]:R47-C3-A
  ?B1 → experiments/minimal_compiler_profile_finalization_proof/out/compiler_profile_source.stage3_proof.json
  ?B7 → docs/ruby-api.md
  ?impl-hold → gates/prop036-cli-exposure-design-and-blocker-tracking-decision-v0.md
}
```

Properties of expansion anchors:
- Anchors are **invisible to operation**: `closed=[B1,B7,B8]` is read
  without touching `?B1`
- Anchors are **available on demand**: an agent that needs B1 closure
  evidence navigates `?B1`
- Anchors are **stable**: the path does not change when the state changes;
  only the state assertion changes
- Anchors may point to files, gate documents, experiments, or proof outputs

This is the difference between a document and a **living reference system**:
the mnemonic is a map, not a copy.

---

## Structural Prohibition on Unauthorized Assertions

A compressed authority graph enforces one structural rule:

```text
An assertion without an authority carrier is structurally OPEN or EVIDENCE.
It cannot carry the status CLOSED, AUTHORIZED, or HELD without [AUTH:source].
```

Concretely:

| Assertion | Meaning | Valid status |
| --- | --- | --- |
| `B1=evidence_satisfied` | no carrier | EVIDENCE only |
| `B1[CLOSED:R47-C3-A]` | Architect gate carrier | CLOSED |
| `impl[HELD:R45-C3-A]` | Architect gate carrier | HELD |
| `B1[CLOSED:track-rec]` | track carrier | INVALID — tracks cannot close |

The third row is the key. The grammar structurally prevents a track
recommendation from claiming the same status as an Architect gate decision.
An agent reading `B1[CLOSED:track-rec]` recognizes this as malformed —
not because it remembers a rule, but because `track-rec` is not a valid
authority carrier type.

Valid carrier types:
```text
[AUTH:gate-ref]          — Architect gate decision
[EVIDENCE]               — track, discussion, or proof output
[HELD:gate-ref]          — implementation held by Architect gate
[OPEN]                   — no closure, no evidence claim
[DEFERRED:gate-ref]      — explicitly deferred by Architect gate
```

---

## Domain Independence

The structure is domain-independent. The authority carrier and expansion
anchor pattern applies wherever the distinction between evidence, formal
closure, and authorization matters:

**Legal:**
```text
Case.Motion.R14{
  filed[EVIDENCE:Plaintiff-2024-01]
  ruled[AUTH:JudgeSmirnov-2024-05]
  appeal=HELD:pending-higher-court
  ?ruling → case-files/motion-R14-ruling.pdf
}
```
Operation: "Can I appeal?" → `appeal=HELD:pending` → not yet authorized.

**Medical protocol:**
```text
Treatment.Procedure.X{
  proposed[EVIDENCE:DrSmith-2024]
  approved[AUTH:EthicsCommittee-R14]
  administered=HELD:pending-patient-consent
  ?approval → ethics/committee-report-R14.pdf
}
```
Operation: "Is this procedure authorized?" → `approved[AUTH:...]` → yes,
but `administered=HELD` → not yet performed.

**Regulatory compliance:**
```text
Feature.GDPR.DataRetention{
  reviewed[EVIDENCE:LegalTeam-Q1]
  approved[AUTH:DPO-Decision-2024-03]
  deployed=HELD:pending-engineering-gate
  ?dpo-decision → compliance/dpo-2024-03.pdf
}
```

The grammar vocabulary changes. The operation — "check carrier type,
check `HELD`/`OPEN`/`CLOSED`, follow `?anchor` if needed" — is identical.

---

## What This Adds to the Current Grammar

| Current grammar (C1-P1) | This proposal |
| --- | --- |
| Authority as a remembered rule | Authority as a structural carrier |
| Compression of narrative | Compression of decision-relevant state |
| Three variants at different verbosity | Three levels, each operationally sufficient |
| Expansion requires reading the full packet | Expansion is lazy via `?anchor` |
| Invariant as a separate phrase | Invariant encoded in carrier types |
| `->` ambiguous (sequence vs transition) | `->` stays for transitions; card sequences use separate `route` frame |
| `@` for source (conflicts with social-media prior) | `[AUTH:ref]` / `[EVIDENCE]` as typed carriers |
| `#` for status (conflicts with markdown) | status expressed via carrier type, not `#` |

The proposal does not replace the current grammar — it is a **precision
layer on top of Variant 1**. The minimal readable grammar remains the
readable surface. The authority carrier `[...]` is the addition.

---

## Recommended Next Steps (shadow only)

These are research recommendations, not implementation instructions.

1. **Pressure-test the carrier syntax** against the PROP-036 state map. Can
   the current blocker map be expressed at Level 0 in under 10 lines? Is it
   still unambiguous?

2. **External two-model validation** using a Level 0 packet only. Question:
   "Is any implementation currently authorized?" If both models answer "no"
   by reading `impl[HELD:R45-C3-A]` alone — the carrier syntax is working.

3. **Define the carrier type vocabulary** precisely: exactly which strings
   are valid after `:` in `[CLOSED:...]`? Allowed: `gate-ref`. Not allowed:
   `track-ref`, `discussion-ref`, `self`. This is the grammar's single most
   important constraint.

4. **Test expansion anchors** for navigability: can a fresh agent follow
   `?B1 → gates/...` and arrive at the right document without additional
   guidance?

5. **Domain transfer test**: transcribe one non-code use case (legal, medical,
   or regulatory) using the Level 1 grammar. Does the carrier type vocabulary
   remain meaningful?

---

## Non-Authorization

This shadow proposal does not authorize:

- Igniter-Lang syntax or spec changes
- Parser or tooling implementation
- Changes to any gate, track, or canonical document
- Canonical mnemonic standardization without Architect review
- Implementation of any PROP-036 surface

It is a design sketch for pressure, iteration, and eventual Architect routing
if the concept proves useful in practice.
