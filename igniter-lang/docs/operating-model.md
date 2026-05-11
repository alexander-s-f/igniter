# Igniter-Lang Operating Model

Status: active
Owner: `[Architect Supervisor / Codex]`
Last updated: 2026-05-09

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

For the broader agent-intake pattern, see
`docs/agent-orchestra-pattern.md`. The operating model defines the process; the
orchestra pattern defines how new agents enter the process without losing the
shared composition.

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

External review can enter the system as a pressure loop:

```text
[External Pressure Reviewer]
  Fresh-context critique / gap discovery

        |
        v

[Architect Supervisor / Codex]
  Intake, scope, and decide whether verification is needed

        |
        v

[Igniter-Lang Meta Expert or owning role]
  Verify against code/spec/status and extract requirements

        |
        v

PROP / track / backlog / rejection
```

External review is never canon by itself. It becomes work only after routing.

External review can also run as a bounded discussion:

```text
Mode: discussion
Initiator: user | architect-supervisor | meta-expert
Role: external-pressure-reviewer
Borrowed lens: <optional role id>
```

In discussion mode, the reviewer may temporarily borrow another role's lens
except Architect Supervisor. This changes the review viewpoint, not authority.
The output should end with a route:

```text
PROP / track / review / reject / keep-discussing
```

A discussion does not create implementation work until the Supervisor or Meta
Expert converts it into a card.

---

## Ownership

| Surface | Owner | Rule |
|---------|-------|------|
| `docs/current-status.md` | Meta Expert + Supervisor | Compact state map, not a narrative log |
| `docs/operating-model.md` | Supervisor | Process contract and handoff rules |
| `docs/agent-motion.md` | Supervisor | Historical protocol; agents do not update by default |
| `docs/tracks/*.md` | Assigned agent | Slice evidence, proof notes, handoff |
| `docs/inbox/` | Supervisor | Temporary intake only; every item must have a disposition |
| `docs/proposals/*.md` | Assigned agent | Formal proposal or accepted design candidate |
| `docs/spec/` | Meta Expert + approved implementer | Canonical crystallized language description |
| `docs/meta-proposals/` | Meta Expert | Governance, audits, closure plans |
| `docs/archive/` | Supervisor + Meta Expert | Snapshots and archaeology |
| `roles/*.md` | Supervisor | Role profiles; concrete agent names are assigned in handoff cards |

---

## Source Of Truth

| Question | Read first |
|----------|------------|
| Where are we now? | `docs/current-status.md` |
| What should a new agent read? | `docs/README.md`, then this file |
| What repeats every round/stage? | `docs/operating-scheduler.md` |
| What is canonical language behavior? | `docs/spec/` and `language-spec.md` |
| What is accepted but not fully implemented? | `docs/proposals/README.md` |
| What proved a slice? | `docs/tracks/<track>.md` and matching experiment |
| What incoming material is not yet canon? | `docs/inbox/README.md` |
| What changed historically? | git history or `docs/archive/` |

If two documents disagree, prefer this order:

```text
spec/current-status
  > accepted proposal
  > active proposal
  > track
  > historical motion/archive
```

Track completion and proposal acceptance are different status namespaces:

```text
Track: done
  = the assigned card delivered its artifact/handoff.

Proposal: authored-pending-review / accepted / implemented-proof / experiment-pass
  = the proposal lifecycle state recorded in docs/proposals/README.md.
```

A `done` track that authors a proposal does not accept that proposal and does not
authorize implementation unless an explicit gate or Architect decision says so.

---

## Agent Handoff Format

Supervisor-assigned cards should include a compact identifier:

```text
Card: S2-R2-C3-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
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
Agent: [Igniter-Lang <Agent Name>]
Role: <role-profile-id>
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

## New Agent Onboarding

Agents need a compact role profile plus the current map, not the whole history.

Read order for every new slice:

1. `igniter-lang/AGENTS.md`
2. `igniter-lang/roles/README.md`
3. the assigned role profile in `igniter-lang/roles/`
4. `igniter-lang/docs/README.md`
5. `igniter-lang/docs/operating-model.md`
6. `igniter-lang/docs/current-status.md`
7. relevant chapters in `igniter-lang/docs/spec/`
8. the assigned track/proposal/source docs only

Do not read archives, old tracks, package docs, or external project docs unless
the card explicitly names them.

When adding a new role, start from `igniter-lang/roles/role-template.md`.

Role-specific launch capsules live in `igniter-lang/handoff/` as onboarding
cards. Use `igniter-lang/handoff/ONBOARDING_CARD_TEMPLATE.md` when creating a
new one. Onboarding cards should be refreshed at stage open/close and whenever
gate state or role ownership changes. See `docs/operating-scheduler.md`.

---

## Anti-Drift Rules

- Do not use `agent-motion.md` as a daily work log.
- Do not update global status unless the slice explicitly assigns that role.
- Do not add proposal numbers without updating `docs/proposals/README.md`.
- Do not duplicate the same decision across several active documents.
- Do not make new agents read archives unless archaeology is the task.
- Keep track docs focused on evidence and next movement.
- Do not leave inbox documents without a disposition and destination route.

---

## Current Practical Loop

1. Supervisor opens a track card.
2. Agent reads role profile, docs map, current status, relevant spec chapters,
   and assigned track only.
3. Agent works inside owned files and proof scope.
4. Agent returns compact handoff.
5. Meta Expert updates map/governance when asked. Round-close map updates use
   Meta Expert in Status Curator mode.
6. Supervisor accepts, redirects, or opens the next slice.
