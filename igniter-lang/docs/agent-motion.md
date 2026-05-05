# Agent Motion

Status: living document
Date: 2026-05-05
Maintainer: `[Igniter-Lang Compiler/Grammar Expert]`
Supervisor: `[Architect Supervisor / Codex]`

---

## Purpose

This document defines how agents move through the `igniter-lang` research
workspace: how they enter, what they may touch, how they advance, how they
hand off, and how the Architect Supervisor corrects or redirects them.

It is a **motion protocol**, not a task list. Task lists live in tracks and
proposals. Motion governs the meta-level: how the research process itself
behaves.

---

## Agent Roles

| Role | Identity | Scope |
|------|----------|-------|
| Research Agent | `[Igniter-Lang Research Agent]` | Observable semantics, observation spine, failure model |
| Compiler/Grammar Expert | `[Igniter-Lang Compiler/Grammar Expert]` | Formal semantics, type theory, grammar fragments, composition algebra |
| Architect Supervisor | `[Architect Supervisor / Codex]` | Review, approve, redirect, bridge requests |
| Bridge Agent | `[Igniter-Lang Bridge Agent]` | Bridge proposals from lang research to platform packages |

Roles may overlap in one conversation. An agent declares its role at the top
of each document it authors.

---

## Entry Protocol

When an agent enters the workspace:

```text
1. Read igniter-lang/AGENTS.md              — identity + write boundary
2. Read igniter-lang/docs/README.md         — current research index
3. Read igniter-lang/docs/agent-motion.md   — this document
4. Read the most recent completed track     — current semantic horizon
5. Read the most recent proposal            — current formal horizon
6. Declare role + entry point in first authored document
```

An agent must NOT:

- Start writing without reading the current horizon
- Edit package code (`packages/`, `lib/`, `examples/`)
- Author a grammar or parser before semantics are stable
- Open a new track when a queued proposal covers the same ground

---

## Motion Modes

### Mode 1: Track Slice

A focused research slice. One document in `docs/tracks/`.

```text
Frame -> Source Horizon -> Compact Claim -> Laws/Decisions
-> Risks/Rejected -> Bridge Candidates -> Next Slice -> Handoff
```

Exit condition: handoff section complete, slice state = done.

### Mode 2: Proposal

A formal design document. One document in `docs/proposals/`.

```text
Purpose -> Formal definitions -> Key properties -> Corrections
-> Open Questions -> Rejected Paths -> Handoff
```

Exit condition: handoff complete, Architect review pending.

### Mode 3: Meta-Observation

Cross-cutting review of existing tracks or proposals.
Format: `META-NNN-<topic>.md` in `docs/proposals/`.

Exit condition: corrections listed, next proposals identified.

### Mode 4: Bridge Note

Proposal to carry one idea from `igniter-lang` into the platform.
One document in `docs/bridge/` (create directory on first use).

```text
Source Signal -> Bridge Claim -> Package Touch Points
-> Migration Risk -> Architect Decision Required
```

Exit condition: Architect approves or rejects the bridge.

---

## Advancement Rules

An agent advances to the next slice when:

1. The current document has a complete handoff section.
2. The handoff includes `[Next]` recommendation(s).
3. The document is saved to the correct directory.
4. The research index (`docs/README.md`) is updated.

An agent does NOT advance if:

- Open `[Q]` questions block the next slice.
- The Architect has issued a redirect or rejection.
- The next slice requires an approved proposal still pending.

---

## Correction Protocol

The Compiler/Grammar Expert acts as a **meta-corrector**:

- Reads completed tracks and proposals.
- Identifies formal inconsistencies, hidden assumptions, decidability risks.
- Issues corrections with `[X]` markers and formal restatements.
- Proposes replacements in PROP documents.
- Does NOT silently rewrite existing tracks. Corrections are additive.

Corrections go through `docs/proposals/META-NNN-*.md`.
The Architect Supervisor decides which corrections to absorb into canon.

---

## Current Agent Positions

| Agent | Last Document | Status | Next |
|-------|--------------|--------|------|
| `[Igniter-Lang Research Agent]` | `tracks/failure-observation-v0.md` | done | bridge-observation-envelope-v0 |
| `[Igniter-Lang Compiler/Grammar Expert]` | `proposals/PROP-001-semantic-domain-v0.md` | done | PROP-002 |

---

## Handoff Cadence

Every completed document ends with:

```text
[Role Name]
Track/Proposal: <path>
Status: done | partial | blocked

[D] Decisions: ...
[R] Recommendations: ...
[S] Signals: ...
[Q] Open Questions: ...
[Next] Proposed next slice: ...
```

The Architect Supervisor responds with one of:

```text
approve        -> agent proceeds to [Next]
redirect       -> agent changes direction, update motion table
reject         -> document closed with [X] reason, motion table updated
bridge_request -> a Bridge Agent picks up the bridge note
```

---

## Research Boundary Map

```text
igniter-lang/docs/
  README.md                      <- living research index (update on every new doc)
  agent-motion.md                <- this document
  research-process.md            <- lifecycle, compression rules
  ecosystem-split-proposal.md

  tracks/                        <- completed research slices
    observable-contract-language-v0.md   [done]
    observable-spine-v0.md               [done]
    failure-observation-v0.md            [done]
    bridge-observation-envelope-v0.md    [queued - Research Agent]

  proposals/                     <- formal design proposals
    README.md                                        [index]
    META-001-compiler-grammar-expert-entry.md        [done]
    PROP-001-semantic-domain-v0.md                   [done]
    PROP-002-contract-composition-algebra-v0.md      [in progress]
    PROP-003-grammar-fragment-classification-v0.md   [queued]
    PROP-004-type-system-v0.md                       [queued]
    PROP-005-bridge-observation-envelope-v0.md       [queued]

  experiments/                   <- approved experiment plans (none yet)
  bridge/                        <- bridge notes to Igniter platform (none yet)
```

---

## Write Boundary (Summary)

```text
MAY write:      igniter-lang/docs/
MAY read:       entire repository (read-only outside igniter-lang/)
MUST NOT write: packages/, lib/, examples/, spec/, root docs/
MUST NOT write: .il syntax files before semantics are stable
```

---

## Motion Log

| Date | Agent | Action | Result |
|------|-------|--------|--------|
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/observable-contract-language-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/observable-spine-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/failure-observation-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Compiler/Grammar Expert]` | proposals/META-001 entry assessment | done |
| 2026-05-05 | `[Igniter-Lang Compiler/Grammar Expert]` | proposals/PROP-001 semantic domain v0 | done |
| 2026-05-05 | `[Igniter-Lang Compiler/Grammar Expert]` | docs/agent-motion.md | done |
| 2026-05-05 | `[Igniter-Lang Compiler/Grammar Expert]` | proposals/PROP-002 composition algebra | in progress |
