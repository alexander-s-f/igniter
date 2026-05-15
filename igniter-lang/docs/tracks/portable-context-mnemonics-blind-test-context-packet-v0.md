# Portable Context Mnemonics Blind Test And Context Packet v0

Card: Shadow-MN-R1-Followup
Agent: [Architect Supervisor / Codex]
Role: architect-supervisor
Track: portable-context-mnemonics-blind-test-context-packet-v0
Route: UPDATE
Status: done
Date: 2026-05-14

Shadow status: research-only. This note does not promote Portable Context
Mnemonics to Igniter-Lang syntax, does not update canonical spec, and does not
authorize parser/tooling implementation.

---

## Purpose

Record the first informal blind validation results for Portable Context
Mnemonics and preserve the emerging `Context Packet v0` direction for later
continuation.

The test was intentionally hard: the external agent had no project context and
was asked to infer meaning from compact mnemonic packets alone.

---

## Blind Test 1: No Register Header

Packet:

```text
B1[CLOSED:gate:S3-R49-C1-A]
impl[HELD:gate:S3-R45-C3-A]
B6[OPEN]
?B1 -> docs/gates/...
```

Observed reconstruction:

- Correctly inferred object + bracketed status/source shape.
- Correctly inferred `?B1 -> docs/gates/...` as a reference/expansion path.
- Incorrectly read `gate` as physical/logical gates rather than authority
  decisions.
- Incorrectly read `S3-R49-C1-A` as coordinates rather than
  stage/round/card/authority code.
- Incorrectly read `CLOSED` as an action around a gate, not formal blocker
  closure.

Decision:

```text
Portable mnemonics are not self-orienting without a register header.
```

---

## Blind Test 2: Register Header Added

Packet:

```text
[MN:orchestration | gate=authority-decision | S/R/C=stage/round/card]
B1[CLOSED:gate:S3-R49-C1-A]
impl[HELD:gate:S3-R45-C3-A]
B6[OPEN]
?B1 -> docs/gates/...
```

Observed reconstruction improved:

- `MN` was understood as a mnemonic/meta notation marker.
- `orchestration` was understood.
- `gate=authority-decision` was understood.
- `S/R/C=stage/round/card` was understood.
- `?B1 -> docs/gates/...` remained understandable.

Remaining error:

- `B1[CLOSED:gate:...]` was still read as "B1 closed the authority gate" rather
  than "B1 has formal closed status backed by the cited gate."

Decision:

```text
Register headers work, but bracket-only state carriers can still make subjects
look like actors.
```

---

## Blind Test 3: Explicit Status Slot

Packet:

```text
[MN:orchestration | X.status=STATE[source] | gate=authority-decision | S/R/C=stage/round/card]
B1.status=CLOSED[gate:S3-R49-C1-A]
impl.status=HELD[gate:S3-R45-C3-A]
B6.status=OPEN
?B1 -> docs/gates/...
```

Observed reconstruction:

- The external agent recognized the repeated packet when accidentally sent
  twice.
- It understood the `X.status=STATE[source]` template.
- It still summarized `B1.status=CLOSED[...]` as "B1 closed the authority gate."

Decision:

```text
Explicit `.status=` helps, but the atom `CLOSED` remains too domain-ambiguous
when paired with `gate`.
```

---

## Resulting Rule: Domain-Qualified Atoms

High-density syntax needs domain-qualified state atoms.

Avoid ambiguous general words when they collide with strong external priors.
`CLOSED + gate` is especially risky because many models read it as physical or
procedural gate-closing.

Prefer:

```text
BLOCKER_CLOSED
BLOCKER_OPEN
EVIDENCE_SATISFIED
IMPLEMENTATION_HELD
AUTHORIZED
DEFERRED
```

over:

```text
CLOSED
OPEN
HELD
AUTH
```

when a packet is meant for fresh agents or external systems.

---

## Context Packet v0 Candidate

The first production-shaped portable packet should carry:

1. register header;
2. grammar id;
3. dictionary id;
4. domain-qualified state atoms;
5. safety invariants;
6. expansion references.

Suggested header:

```text
[MN:v0 | domain=orchestration | grammar=state-carrier | dict=orchestration-v0]
```

Suggested mini-grammar:

```text
Packet       := Header Line+
Header       := "[MN:v0 | domain=" Domain " | grammar=" Grammar " | dict=" Dict "]"
Line         := StateLine | RefLine | RuleLine | DispatchLine
StateLine    := Subject "." Slot "=" State "[" Authority "]"
RefLine      := "?" Subject "->" Path
RuleLine     := "Rule:" Expr
DispatchLine := "Dispatch:" Round "=" Step ("->" Step)+
Authority    := SourceKind ":" SourceId
```

Suggested `orchestration-v0` dictionary:

```text
Subject:
  B<n>       = blocker number n
  impl       = implementation authorization surface
  gate       = authority decision, not physical gate

Slot:
  state      = current formal status
  evidence   = proof/evidence status
  route      = planned or approved route

State:
  BLOCKER_CLOSED       = blocker formally closed by authority
  BLOCKER_OPEN         = blocker not closed
  EVIDENCE_SATISFIED   = proof/evidence exists but formal closure may still be pending
  IMPLEMENTATION_HELD  = implementation is not authorized
  AUTHORIZED           = action is authorized by cited authority
  DEFERRED             = explicitly deferred by cited authority

SourceKind:
  gate        = Architect authority decision
  track       = evidence/handoff, not authority by itself
  discussion  = pressure/review, not authority by itself
  spec        = canonical spec source
  card        = planned work unit

Rule:
  Evidence != Closure != Auth
  Track != Gate
  Pressure != Canon
  ClosedBlocker != ImplementationAuth
```

Suggested packet:

```text
[MN:v0 | domain=orchestration | grammar=state-carrier | dict=orchestration-v0]

B1.state=BLOCKER_CLOSED[gate:S3-R49-C1-A]
impl.state=IMPLEMENTATION_HELD[gate:S3-R45-C3-A]
B6.state=BLOCKER_OPEN
Rule: Evidence != Closure != Auth
Rule: ClosedBlocker != ImplementationAuth
?B1 -> docs/gates/...
```

Expected reconstruction:

```text
B1 is a blocker and is formally closed by Architect gate S3-R49-C1-A.
Implementation remains held by Architect gate S3-R45-C3-A.
B6 is still an open blocker.
Closed blocker status does not authorize implementation.
B1 details can be expanded through docs/gates/...
```

---

## Design Principles Captured

```text
Portable mnemonics need a register, not just syntax.
Authority should travel with state assertions.
Fresh-agent packets should use domain-qualified atoms.
Safety invariants should be first-class lines.
Expansion refs turn compressed memory into a lazy map, not a document copy.
```

---

## Non-Authorization

This note does not authorize:

- Igniter-Lang syntax;
- parser work;
- SemanticIR changes;
- runtime behavior;
- Agent Orchestra DNA implementation;
- canonical mnemonic standardization;
- changes to PROP-036 or CLI implementation.

---

## Next Suggested Experiment

Run a second blind two-agent validation with the `Context Packet v0` candidate.

Questions:

```text
1. What is B1?
2. Is implementation authorized?
3. What does gate mean?
4. What is B6?
5. What should the agent read to expand B1?
6. Are these mnemonics a programming language or a context packet?
```

Pass bar:

```text
Both agents answer:
- B1 is a blocker, not an actor.
- implementation is not authorized.
- gate is authority decision, not physical gate.
- B6 is an open blocker.
- ?B1 points to expansion docs.
- this is a context packet, not a programming language.
```
