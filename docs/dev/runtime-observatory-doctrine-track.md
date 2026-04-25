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
