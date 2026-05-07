# Igniter-Lang Operating Model

Status: active
Owner: `[Architect Supervisor / Codex]`
Last updated: 2026-05-07

---

## Core Rule

Agents need a map, not the whole history.

The active documentation surface should answer:

- where we are
- what is canonical
- what is being worked now
- what evidence proves it
- what should happen next

Historical detail belongs in git history, archived snapshots, or completed track
documents. It should not be required reading for a new slice.

---

## Motion Flow

```text
[Architect Supervisor / Codex]
  Open track, define acceptance, assign role

        |
        v

[Agents]
  Work inside assigned track/proof/doc scope
  Produce compact handoff

        |
        v

[Igniter-Lang Meta Expert]
  Analyze, reconcile, update map/scoreboard/governance
  Identify gaps and next slices

        |
        v

[Architect Supervisor / Codex]
  Close, redirect, accept, or open the next track
```

The supervisor owns input/output motion. Agents own their slice artifacts.

---

## Ownership

| Surface | Owner | Rule |
|---------|-------|------|
| `docs/current-status.md` | Meta Expert + Supervisor | Compact state map, not a narrative log |
| `docs/operating-model.md` | Supervisor | Process contract and handoff rules |
| `docs/agent-motion.md` | Supervisor | Historical protocol; agents do not update by default |
| `docs/tracks/*.md` | Assigned agent | Slice evidence, proof notes, handoff |
| `docs/proposals/*.md` | Assigned agent | Formal proposal or accepted design candidate |
| `docs/spec/` | Meta Expert + approved implementer | Canonical crystallized language description |
| `docs/meta-proposals/` | Meta Expert | Governance, audits, closure plans |
| `docs/archive/` | Supervisor + Meta Expert | Snapshots and archaeology |

---

## Source Of Truth

| Question | Read first |
|----------|------------|
| Where are we now? | `docs/current-status.md` |
| What should a new agent read? | `docs/README.md`, then this file |
| What is canonical language behavior? | `docs/spec/` and `language-spec.md` |
| What is accepted but not fully implemented? | `docs/proposals/README.md` |
| What proved a slice? | `docs/tracks/<track>.md` and matching experiment |
| What changed historically? | git history or `docs/archive/` |

If two documents disagree, prefer this order:

```text
spec/current-status
  > accepted proposal
  > active proposal
  > track
  > historical motion/archive
```

---

## Agent Handoff Format

Supervisor-assigned cards should include a compact identifier:

```text
Card: S2-R2-C3-P
[Igniter-Lang Research Agent]
Track: production-compiler-diagnostics-extraction-v0
```

Card code:

```text
S2  = Stage 2
R2  = supervisor round 2
C3  = card 3 inside that round
P   = parallel-safe; other agents may be working nearby
B   = blocked/ordered; check Depends on before starting
S   = serial/supervisor-only or should run after the round closes
```

Agents should copy the `Card:` line into their track document and handoff. When
the suffix is `P`, assume neighboring agents may touch related docs or proof
areas; keep edits inside the assigned scope and do not stage, restore, or clean
unrelated files. When the suffix is `B`, do not start until the dependency is
reported done by the supervisor or the assigned track explicitly says it is
unblocked.

Agents should end every slice with a compact block:

```text
Card:
[Role]
Track:
Status:

[D] Decisions
- ...

[S] Shipped / Signals
- ...

[T] Tests / Proofs
- ...

[R] Risks / Recommendations
- ...

[Next] Suggested next slice
- ...
```

The handoff should fit into one screen unless the evidence genuinely requires
more. Long reasoning belongs in the track document.

---

## Anti-Drift Rules

- Do not use `agent-motion.md` as a daily work log.
- Do not update global status unless the slice explicitly assigns that role.
- Do not add proposal numbers without updating `docs/proposals/README.md`.
- Do not duplicate the same decision across several active documents.
- Do not make new agents read archives unless archaeology is the task.
- Keep track docs focused on evidence and next movement.

---

## Current Practical Loop

1. Supervisor opens a track card.
2. Agent reads role, docs map, current status, and assigned track only.
3. Agent works inside owned files and proof scope.
4. Agent returns compact handoff.
5. Meta Expert updates map/governance when asked.
6. Supervisor accepts, redirects, or opens the next slice.
