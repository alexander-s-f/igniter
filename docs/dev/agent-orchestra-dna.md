# Agent Orchestra DNA

Status: portable process seed
Owner: Architect Supervisor
Last updated: 2026-05-12

This document describes the minimal repeatable pattern for deploying an
agent-orchestrated development loop in another project.

It is intentionally project-agnostic. Use it as the DNA for a new workspace,
then let the local Architect Supervisor adapt names, roles, folders, and cadence
to the target project.

## Core Thesis

Agents need a map, not the whole history.

The system works when every participant can answer:

- where are we now?
- what is canonical?
- what is being worked now?
- who owns each decision?
- what evidence proves a change?
- where should useful pressure route next?

The short formula:

```text
Role + Context + Card + Lens + Authority + Route
```

Each part prevents a common failure:

| Part | Prevents |
| --- | --- |
| Role | Agent invents its own job or claims another role's authority |
| Context | Agent rereads history and reconstructs a stale project model |
| Card | Slice expands beyond the current task |
| Lens | Review asks the wrong questions |
| Authority | Discussion or pressure accidentally becomes canon |
| Route | Useful insight remains prose instead of becoming work |

## Minimal Workspace Shape

Default path for a new project:

```text
docs/agents/
  README.md
  current-status.md
  operating-model.md
  roles/
    README.md
  handoff/
    README.md
    onboarding-card-template.md
    instance-routing.md
  tracks/
    README.md
  discussions/
    README.md
  decisions/
    README.md
  lineups/
    README.md
  inbox/
    README.md
  archive/
```

If the project already has a documentation convention, adapt the path. The
important thing is not the folder name. The important thing is that active maps,
ephemeral tracks, decisions, role profiles, discussions, and archives are not
mixed together.

## Roles

Start with a small orchestra. Add roles only when the work produces a real
pressure that a current role cannot hold cleanly.

| Role | Purpose |
| --- | --- |
| Architect Supervisor | Owns rounds, scope, authority, gates, and final routing |
| Implementation Agent | Makes bounded code changes after authority exists |
| Research Agent | Builds proofs, maps uncertainty, validates hypotheses |
| Domain Pressure Agent | Pushes from product, user, domain, and business reality |
| QA/Test Agent | Runs targeted verification and turns failures into evidence |
| Status Curator | Maintains current maps, round summaries, and next-state clarity |
| External Pressure Reviewer | Fresh-context critique; pressure only, no canon authority |
| Archive/Form Expert | Separates history, canon, archive, and zombie documents |
| Line Up Summarizer | Compresses bulky sources into compact memory cards |
| History Curator | Long-cycle archaeology, preservation, and context hygiene |

Role and agent are different:

```text
Agent: [Spark CRM Runtime Reviewer]
Role:  external-pressure-reviewer
Lens:  runtime-pressure
```

One role may have multiple instances. One agent may borrow a lens for a single
card, but it does not replace the base role.

## Card Codes

Use compact card ids so humans can dispatch parallel work without rereading the
whole plan.

```text
Card: S1-R2-C3-P1
```

Meaning:

| Code | Meaning |
| --- | --- |
| `S1` | Stage 1 |
| `R2` | Supervisor round 2 |
| `C3` | Card 3 inside the round |
| `P` | Parallel-safe |
| `P1`, `P2` | Parallel series; same number may start together |
| `B` | Blocked or ordered; check dependencies before starting |
| `S` | Serial or supervisor-only; usually after a round barrier |
| `A` | Architect/authority decision; no implementation unless scoped |
| `I` | Implementation/code-writing slice; tests or proofs expected |

Dispatch pattern:

```text
R = [[C1-P1, C2-P1] -> C3-S -> [C4-P2, C5-P2]]
```

`C1-P1` and `C2-P1` may run together. `C3-S` runs after P1 closes. `C4-P2` and
`C5-P2` may run together after the serial barrier.

## Instance Routes

Every agent instance should choose a startup route before work.

| Situation | Route | Use when |
| --- | --- | --- |
| New chat / fresh agent | `INIT` | No previous handoff in this chat |
| Same agent, new card | `UPDATE` | Role is known, work changed |
| Same card in progress | `IN_FLIGHT_REFRESH` | Need to re-check changed files or maps |
| Returning after delay | `STALE_REFRESH` | Stage, round, gate, or same-role work moved |
| Discussion mode | `DISCUSSION` | Producing critique or pressure, not code/canon |
| Stage-level role | `STAGE_LOOP` | Long-cycle work without per-round cards |

Minimal startup statement:

```text
Route:
Agent:
Role:
Card:
Current stage/round observed:
Neighbor risk:
```

## Authority Boundary

Output types are not equal.

| Output type | Authority |
| --- | --- |
| Inbox note | Unrouted input |
| Discussion | Pressure only |
| Review | Signal that needs intake |
| Track | Evidence for one bounded slice |
| Proposal | Candidate design or semantics |
| Spec | Canon after acceptance/sync |
| Decision | Architect-owned authorization |
| Implementation | Code inside an authorized surface |

The word `proceed` in a review means "safe to route onward", not "authorized to
implement".

## Round Loop

The default loop:

```text
Architect Supervisor
  -> opens cards and authority boundaries
Agents
  -> execute bounded slices and handoff
External Pressure / QA
  -> challenge and verify
Status Curator / Meta
  -> updates maps and extracts next blockers
Architect Supervisor
  -> closes, redirects, authorizes, or opens next round
```

Keep the loop small enough that the current state can be reloaded from the maps,
not reconstructed from the archive.

## Document Lifecycle

No document should have an undefined status.

```text
inbox
  -> reject
  -> discussion
  -> track
  -> decision
  -> proposal
  -> spec
  -> lineup
  -> archive
```

Use lineups for context hoisting:

```text
large source document
  -> compact Line Up summary
  -> source remains authoritative for exact proof logs
  -> active maps link to Line Up, not bulky history
```

Use archive mode for history:

```text
history is preserved
  but not required reading for new work
```

## Safety Rules

- Do not read the entire repository unless explicitly assigned archaeology.
- Do not revert, stage, clean, or remove files that may belong to another agent.
- Do not promote pressure, discussion, or research into canon without routing.
- Do not implement behavior before authority exists.
- Do not hide unresolved blockers behind a positive summary.
- Prefer exact file links and compact handoffs over narrative memory.
- Treat multiple instances of the same role as normal.

## Stage 0 Bootstrap

For a new project, the first stage should produce only a map and operating
surface. Avoid code changes unless the user explicitly asks.

Suggested first round:

```text
S0-R1-C1-A  Architect Supervisor: create project intake map
S0-R1-C2-P1 Research Agent: project structure and build/test map
S0-R1-C3-P1 Domain Pressure Agent: product/domain pain map
S0-R1-C4-P1 Archive/Form Expert: documentation/context map
S0-R1-X1-S  External Pressure Reviewer: fresh-context critique
S0-R1-C5-S  Status Curator: current-status and next round
```

After Stage 0, the project should have:

- a current status map;
- a role map;
- a first backlog of concrete tracks;
- a clear list of protected surfaces;
- known build/test commands;
- known document rotation rules.

## Copy-Paste Bootstrap

Use [Architect Supervisor Bootstrap](./architect-supervisor-bootstrap.md) to
initialize a new project chat.

