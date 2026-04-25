# Runtime Observatory Doctrine Track

This track graduates the Research Horizon Runtime Observatory Graph synthesis
into a docs-only doctrine candidate.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Research notes are marked:

```text
[Research Horizon / Codex]
```

## Decision

[Architect Supervisor / Codex] Accepted the Runtime Observatory Graph as
research input only.

The next step is a docs-only doctrine that gives agents a shared vocabulary for
observability-shaped read models. It must not introduce a runtime graph package,
query language, graph database, global report object, or execution planner.

## Goal

Draft `docs/dev/runtime-observatory-doctrine.md` as a compact vocabulary and
placement guide for read-only observatory views across Igniter.

The doctrine should help agents describe:

- observation frames
- nodes
- edges
- facets
- evidence
- blockers
- warnings
- metadata

## Scope

In scope:

- docs-only doctrine
- mapping to existing handoff doctrine and interaction doctrine
- mapping to application capsule, transfer, activation, operator, and research
  track artifacts
- guidance for when a package-local read model may be justified later
- explicit distinction between observing explicit artifacts and discovering
  runtime/project state

Out of scope:

- new package
- shared runtime graph object
- generalized query language
- graph database
- autonomous agent execution
- AI provider calls
- cluster routing or placement
- host activation execution
- browser transport
- mutation
- hidden discovery

## Task: Doctrine Draft

Owner: `[Research Horizon / Codex]`

Acceptance:

- Add `docs/dev/runtime-observatory-doctrine.md`.
- Keep the document concise and doctrine-level, not implementation-level.
- Reuse the vocabulary from the research report only where it helps current
  agent collaboration and explicit artifact review.
- Include a refusal section that rejects graph packages, query engines,
  runtime discovery, mutation, host activation, browser transport, cluster
  routing, and autonomous execution.
- Link the doctrine from `docs/dev/README.md` if accepted by the draft.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
```

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Research Horizon / Codex]` drafts the docs-only doctrine.
2. Do not touch packages or runtime implementation.
3. Return with changed files, compact accepted/deferred summary, and
   verification result.

[Research Horizon / Codex]
Track: `docs/dev/runtime-observatory-doctrine-track.md`
Status: drafted.
Changed:
- Added `docs/dev/runtime-observatory-doctrine.md`.
- Linked it from `docs/dev/README.md`.
- Added this short track reference without changing package implementation
  handoffs.
Accepted/Ready:
- The doctrine defines frames, nodes, edges, facets, evidence, blockers,
  warnings, and metadata.
- It maps research/track review, capsule transfer and activation review,
  operator/orchestration review, and cluster/mesh review without merging
  ownership.
- It explains the relationship to Handoff Doctrine and Interaction Doctrine.
- It explicitly rejects a new observatory package, shared runtime graph object,
  graph database, generalized query language, global report object, runtime
  discovery, hidden scanning, mutation, activation execution, mount binding,
  route activation, browser transport, contract execution, cluster routing or
  placement, AI provider calls, and autonomous agent execution.
Verification:
- `git diff --check` passed.

## Supervisor Acceptance

[Architect Supervisor / Codex] Accepted after the 2026-04-25 cycle.

Accepted:

- [Runtime Observatory Doctrine](./runtime-observatory-doctrine.md) is accepted
  as docs-only language alignment.
- The doctrine usefully separates bounded observation frames from execution,
  discovery, routing, mutation, and global graph modeling.
- It can guide later read-only reports, but does not authorize package work by
  itself.

Still rejected:

- new observatory package
- shared runtime graph object
- graph database
- generalized query language
- global report object
- hidden runtime discovery
- mutation
- activation execution
- mount binding
- route activation
- browser transport
- contract execution
- cluster routing or placement
- AI provider calls
- autonomous agent execution

Verification:

- `git diff --check` passed.

Next:

- Continue through
  [Runtime Observatory Activation Frame Track](./runtime-observatory-activation-frame-track.md).
