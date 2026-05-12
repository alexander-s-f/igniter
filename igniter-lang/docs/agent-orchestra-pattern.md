# Agent Orchestra Pattern

Status: active pattern note
Owner: `[Architect Supervisor / Codex]`
Last updated: 2026-05-09

---

## Purpose

This document records the emerging pattern for bringing a new human/agent
participant into the Igniter-Lang work without losing the shared composition.

The metaphor is intentional: the system should let us bring a new musician
into the orchestra quickly. The musician does not need the entire history of
the orchestra, but they do need the score, role, instrument, conductor, and
rules for entering the piece.

Without this pattern, every agent tends to compose its own work. With it, each
agent can add pressure, proof, critique, or implementation while preserving the
shared direction.

---

## Core Pattern

```text
Agent joins
  -> receives Role profile
  -> receives current Context capsule
  -> receives Card / Track / Question
  -> may receive a borrowed Lens
  -> works inside Authority boundary
  -> returns Handoff / Route
  -> Supervisor or Meta integrates into the system
```

The short form:

```text
Role + Context + Card + Lens + Authority + Route
```

Each part prevents a specific failure mode.

| Part | Prevents |
|------|----------|
| Role | Agent invents its own job or claims a neighbor's authority |
| Context | Agent rereads history or reconstructs a stale world model |
| Card | Agent expands the scope beyond the current slice |
| Lens | Agent critiques from the wrong viewpoint or too many viewpoints |
| Authority | Agent treats discussion/proof/review as canon |
| Route | Useful output remains trapped as prose instead of becoming work |

---

## Role And Agent Are Different

An agent is a concrete participant in a round. A role is the repeatable profile
that defines ownership, boundaries, and authority.

```text
Agent: [Igniter-Lang External Pressure Reviewer V2 Cross Test]
Role:  external-pressure-reviewer
Lens:  runtime-pressure
```

This distinction lets one role have multiple agents, and one agent temporarily
borrow a lens without replacing its base role.

---

## Borrowed Lens

A borrowed lens is a temporary viewpoint assigned for one card or discussion.
It does not change ownership or authority.

Examples:

```text
Role: external-pressure-reviewer
Borrowed lens: runtime-pressure

Role: meta-expert
Borrowed lens: compiler-form-pressure
```

Useful lenses:

- `runtime-pressure`: production execution, cache, gates, failure paths;
- `product-pressure`: usefulness, user value, application fit;
- `comprehension-pressure`: whether humans/agents can understand the surface;
- `implementation-pressure`: whether the design can be built without hidden debt;
- `meta-pressure`: whether process, roles, and docs still fit the system.

Rule: a borrowed lens changes the questions an agent asks, not the decisions it
is allowed to make.

---

## Authority Boundary

Every agent output must be interpreted by its authority level.

| Output type | Authority |
|-------------|-----------|
| Discussion | pressure only; never canon by itself |
| Review | signal; requires intake/routing |
| Track | evidence for a bounded slice |
| Proposal | candidate semantics until accepted |
| Spec | canon after accepted/synced |
| Gate request | asks for authorization; does not authorize |
| Gate decision | Architect-owned authorization |

The phrase "proceed" in a pressure review means "safe to route onward", not
"implementation is authorized".

---

## Internal And External Agents

The S3-R13 External Pressure cross-test produced an important signal:

```text
Full-context internal reviewer:
  finds edge cases and subtle process gaps

Public/read-only external reviewer:
  tests whether the system is self-explanatory from limited context
```

Both are useful, but they answer different questions.

Use internal reviewers when:

- the issue is semantically or operationally subtle;
- local code/proofs/gates must be cross-checked;
- a decision could authorize production behavior.

Use external/read-only reviewers when:

- testing whether onboarding and public docs are comprehensible;
- checking for obvious scope leaks from outside the local context;
- validating that role/lens/authority semantics are visible without private
  history.

External/read-only review should be labeled explicitly:

```text
Context: public-github-only
Write access: none
Canon authority: none
```

---

## Orchestra Intake Checklist

When bringing a new agent into the system, provide:

```text
Agent:
Role:
Borrowed lens: <optional>
Context level: local-full | repo-only | public-github-only | provided-docs-only
Write access: yes | no
Authority: discussion | review | track | proposal | implementation | gate-request
Card:
Track:
Goal:
Scope:
Deliver:
Route expectation:
```

Minimum viable onboarding:

```text
Read:
- igniter-lang/AGENTS.md
- igniter-lang/roles/README.md
- assigned role profile
- igniter-lang/docs/agent-context.md
- igniter-lang/docs/current-status.md
- assigned card/source docs

Do not:
- claim Architect authority
- promote discussion to canon
- edit outside assigned scope
- reconstruct the entire archive unless assigned archaeology
```

---

## Route-Aware Activation

The Agent Orchestra DNA side experiment produced one durable process rule:
activation route changes the first move.

Do not use one generic onboarding flow for every agent or context.

| Route / context | First move |
|-----------------|------------|
| `INIT` + workspace | read the compact map, choose operating surface/docs language only if needed |
| `INIT` + inline chat | use safe defaults, avoid setup questions first, offer a tiny bounded demo/proof |
| `UPDATE` / active role | reread role + current map; check what changed since last card |
| `DISCUSSION` | activate as pressure/review, not canon or implementation |
| `REVIEW` | critique explicitly; do not pretend to be initialized for work |

Activation is not review. If an agent receives role/bootstrap material as an
activation seed, it should enter the assigned route rather than summarize or
rate the material. Review is allowed only when the card asks for review.

Small demos/proofs are allowed as cold-start probes, but they must close with a
route:

```text
complete / repeat / promote-to-track / archive
```

This keeps experiments from becoming zombie context.

---

## Failure Modes

| Failure | Symptom | Guard |
|---------|---------|-------|
| Role drift | Agent acts as Architect/Meta/Implementer without assignment | Role profile + Card authority |
| Context flood | Agent rereads old tracks and ignores current maps | `agent-context.md` + proof budget |
| Scope creep | Agent turns a review into implementation | Mode + Route |
| Canon leak | Discussion becomes accepted semantics without proposal/spec sync | Authority table |
| External blindness | Public-only agent misses local edge cases | Treat as cross-test, not final proof |
| Local overfitting | Full-context agent assumes too much hidden context | External/read-only cross-test |

---

## Current Insight

The agent system is not just a way to do work. It is pressure shaping the
language itself.

Igniter-Lang is moving toward a world where contracts, roles, authority,
runtime context, time, and observations are explicit. The agent workflow is a
live prototype of that same model:

```text
agent role      ~= contract surface
card            ~= invocation context
lens            ~= projection / viewpoint
handoff         ~= observation
route           ~= next contract edge
gate decision   ~= authority boundary
```

This is the practical side of the human-agent symbiosis vision: not one agent
holding the whole world, but a coordinated system where partial agents can
contribute safely because the work surface is explicit.

---

## Sources

- [operating-model.md](operating-model.md)
- [agent-context.md](agent-context.md)
- [discussions/README.md](discussions/README.md)
- [discussions/gate3-decision-safety-pressure-v0.md](discussions/gate3-decision-safety-pressure-v0.md)
- [discussions/gate3-decision-safety-pressure-v0-agent-v2-cross-test.md](discussions/gate3-decision-safety-pressure-v0-agent-v2-cross-test.md)
- [meta-proposals/META-EXPERT-010-human-agent-symbiosis-vision-v0.md](meta-proposals/META-EXPERT-010-human-agent-symbiosis-vision-v0.md)
