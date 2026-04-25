# Interaction Doctrine Track

This track is a docs-only graduation candidate from Research Horizon.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Research notes are marked:

```text
[Research Horizon / Codex]
```

## Decision

[Architect Supervisor / Codex] Accepted as a docs-only next research track.

The Interaction Kernel synthesis identifies a useful conceptual vocabulary for
read-only interaction state: subject, participants, affordances, pending state,
surface context, session context, policy context, evidence, and outcomes.

This track is explicitly documentation-only. No shared interaction package,
runtime object, browser transport, workflow engine, agent execution, cluster
placement, or AI provider integration is accepted.

## Goal

Draft `docs/dev/interaction-doctrine.md` as a compact doctrine that explains
how existing interaction surfaces relate without merging their ownership:

- application owns active flow snapshots and pending state
- web owns candidate surface interaction metadata
- operator surfaces own accountability and action review
- capsule/activation reports own transfer and host review state
- future agents may inspect these surfaces through explicit reports

## Scope

In scope:

- docs-only doctrine
- mapping current application/web/operator/capsule interaction surfaces
- small conceptual vocabulary
- explicit rejection/defer list

Out of scope:

- new package
- shared runtime interaction object
- browser transport
- workflow engine behavior
- runtime agent execution
- AI provider calls
- cluster routing/placement
- web screen graph inspection by application
- route activation
- host activation

## Task 1: Doctrine Draft

Owner: `[Research Horizon / Codex]`

Acceptance:

- Draft `docs/dev/interaction-doctrine.md`.
- Use `docs/research-horizon/interaction-kernel-report.md` as source material.
- Keep the doctrine compact and practical.
- Define the conceptual vocabulary without proposing class names.
- Map each concept to current concrete surfaces.
- Explain how this differs from Handoff Doctrine.
- Include a "not accepted yet" section.

## Task 2: Indexing

Owner: `[Research Horizon / Codex]`

Acceptance:

- Link the doctrine from `docs/dev/README.md`.
- Add a short track/index reference without assigning package implementation
  work.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
```

No tests are required unless implementation files change, which this track
should avoid.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Research Horizon / Codex]` drafts docs-only Interaction Doctrine.
2. Do not add runtime objects, package code, browser transport, route
   activation, agent execution, AI integration, cluster placement, or web
   screen inspection by application.
