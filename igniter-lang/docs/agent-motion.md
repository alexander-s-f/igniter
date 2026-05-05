# Igniter-Lang Agent Motion

Status: active coordination note
Supervisor: `[Architect Supervisor / Codex]`
Date: 2026-05-05

## Current Agents

```text
[Architect Supervisor / Codex]
  |
  |-- [Igniter-Lang Research Agent]
  |     role: researcher-practitioner
  |     writes: igniter-lang/docs/tracks
  |     current: semantic-domain-reconciliation-v0
  |
  |-- [Igniter-Lang Compiler/Grammar Expert]
  |     role: formal semantics / compiler / grammar meta-reviewer
  |     writes: igniter-lang/docs/proposals
  |     current: PROP-002 Contract Composition Algebra
  |
  |-- Package Agent / Companion+Store
        role: package implementer
        writes: packages/*
        current relation: downstream only, waits for approved bridge notes
```

## Coordination Rule

Research tracks may be bold and practical. Formal proposals may be strict and
corrective. Package work must wait for explicit bridge or package tracks.

```text
research signal
-> formal correction / proposal
-> Architect review
-> bridge proposal
-> package track
```

No Igniter-Lang agent edits `packages/`.

## Active Movement

### Research Agent

Current slice:

- `tracks/semantic-domain-reconciliation-v0.md`

Goal:

- Reconcile the completed practical tracks with `META-001` and `PROP-001`.
- Do not rewrite history destructively.
- Produce compact errata/update recommendations and bridge candidates.

### Compiler/Grammar Expert

Current slice:

- `proposals/PROP-002-contract-composition-algebra-v0.md`

Goal:

- Define how contracts compose over the `PROP-001` semantic domain.
- Identify algebraic laws, invalid compositions, and decidability boundaries.
- Prepare the ground for `PROP-003 Grammar Fragment Classification`.

### Package Agent

Current relation:

- No Igniter-Lang package work yet.
- Package Agent may consume only approved bridge tracks.
- Candidate future bridge: observation envelope / failure diagnostics mapping.

## Review Cadence

Each agent returns one compact handoff. The supervisor reviews for:

- semantic coherence
- decidability pressure
- package boundary safety
- bridge readiness
- documentation compression

