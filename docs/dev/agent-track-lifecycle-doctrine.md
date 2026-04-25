# Agent Track Lifecycle Doctrine

This doctrine captures the working pattern that emerged while optimizing the
multi-agent development cycle. It is intentionally practical: the current docs
are the first implementation of the lifecycle.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

## Why This Exists

The process is no longer only project management around agents. It is becoming
a reusable Igniter lifecycle shape:

1. discover a pressure point
2. open a bounded track
3. apply named constraints
4. let focused agents implement or research
5. return compact facts
6. accept, reject, defer, or open the next track
7. move completed context out of the active working set

This pattern should stay useful later when Igniter grows first-class agent and
LLM capabilities.

## Current Artifacts

- [Active Tracks](./tracks.md) is the live routing table.
- [Tracks History](./tracks-history.md) is accepted long context.
- [Constraint Sets](./constraints.md) is reusable boundary vocabulary.
- [Agent Track Pattern](../experts/agent-track-pattern.md) is accepted as an
  expert reference, not as an implementation mandate.
- Individual track files hold goal, scope, owners, acceptance, verification,
  handoffs, and supervisor acceptance.
- Research and expert directories can feed proposals, but they do not directly
  become active work until the supervisor accepts a slice.

## Vocabulary

The current lightweight vocabulary is intentionally smaller than the full expert
specification:

- Signal: a user, agent, research, expert, verification, or application-pressure
  trigger that may become a track.
- Track: a bounded unit of work with owner roles, constraints, acceptance, and
  verification.
- Task: a discrete owner-scoped piece inside a track.
- Window: a group of tasks that may run in parallel and should be reviewed
  together.
- Constraint set: a named boundary policy cited by active tracks.
- Handoff: a compact structured observation emitted by an agent.
- Acceptance: a supervisor decision to accept, reject, defer, or follow up.
- Memory layer: active, warm, cold, or speculative context with different read
  costs.

Do not add formal front-matter, generators, validators, or native agent runtime
from this vocabulary yet. The vocabulary is accepted so humans and agents can
name the shape consistently while the docs protocol continues to evolve.

## Lifecycle

### 1. Signal

A signal can come from:

- user insight
- failed verification
- agent handoff
- research proposal
- expert review
- real application pressure

The signal should be turned into a track only when it has a clear next action.

### 2. Track Opened

A track opens with:

- a named goal
- owner roles
- scope and out-of-scope boundaries
- named constraint sets when useful
- acceptance criteria
- verification gate
- compact handoff format

The track should be small enough that an agent can complete one meaningful
cycle without reading the whole repository history.

### 3. Execution

Agents work inside the track and its listed dependencies only. Their output is
a compact status, not a narrative dump.

Expected status shape:

```text
[Agent Role / Codex]
track: <path>
status: landed | blocked | needs-review
delta: <changed files, one line each>
verify: <tier/result>
ready: <who can proceed>
block: none | <blocker>
```

### 4. Supervisor Review

The supervisor decides:

- accept as landed
- ask for a narrow follow-up
- reject a proposal or implementation direction
- defer the idea into history/research
- open the next track

Supervisor review should leave an explicit labeled note in the changed track or
in [Active Tracks](./tracks.md).

### 5. Compression

Completed or inactive context should leave the active working set.

Compression targets:

- active index stays short
- completed decisions move to history or track acceptance sections
- reusable boundaries move into constraint sets
- speculative ideas stay in research/expert docs until accepted

## Design Principles

- Prefer one small accepted slice over one broad unresolved plan.
- Keep long context reachable, not active.
- Name constraints once; cite them often.
- Make handoffs factual and compact.
- Use real application pressure to validate abstractions.
- Keep human sugar and agent-clean forms compatible.
- Treat rejection and deferral as useful outputs, not failures.

## Future Agent/LLM Implication

This lifecycle can become the future shape for Igniter-native agents:

- a track is a task contract
- constraint sets are execution policy
- handoffs are structured observations
- supervisor acceptance is a gate
- history is memory compression
- research is exploration outside the execution boundary

Do not implement this as a runtime abstraction yet. The current docs are the
living prototype. Promote only after multiple POC cycles show the same shape.

## Supervisor Notes

[Architect Supervisor / Codex]

Accepted as doctrine after the interactive POC and agent-cycle optimization
work exposed the pattern.

Current implementation status:

- active routing exists in [Active Tracks](./tracks.md)
- history compression exists in [Tracks History](./tracks-history.md)
- named constraints exist in [Constraint Sets](./constraints.md)
- expert formalization exists in [Agent Track Pattern](../experts/agent-track-pattern.md)
- next live test is [Application Web POC Command Result Track](./application-web-poc-command-result-track.md)

Next evolution should happen through use, not premature framework code.

Accepted from expert review:

- vocabulary for Signal, Track, Task, Window, Constraint set, Handoff,
  Acceptance, and Memory layer
- framing of the docs protocol as a future candidate for Igniter-native agent
  compilation

Deferred from expert review:

- front-matter conversion
- active index generator
- handoff validator
- track compiler
- native agent execution
