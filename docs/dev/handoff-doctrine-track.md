# Handoff Doctrine Track

This track graduates a Research Horizon synthesis into a docs-only development
doctrine.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Research notes are marked:

```text
[Research Horizon / Codex]
```

## Decision

[Architect Supervisor / Codex] Accepted as a docs-only graduation from
Research Horizon.

The Agent Handoff Protocol synthesis identifies a real cross-cutting primitive:
handoff as ownership transfer under policy with context, evidence, obligations,
and receipt.

This track is explicitly documentation-only. No shared runtime object is
accepted yet.

## Goal

Create a compact `docs/dev/handoff-doctrine.md` that aligns existing handoff
language across:

- docs-agent track handoffs
- application capsule handoff manifests
- transfer receipts
- post-transfer/activation readiness
- future operator and AI delegation

The doctrine should help agents and future package work use one vocabulary
without forcing a new framework.

## Scope

In scope:

- docs-only doctrine
- mapping existing handoff surfaces
- shared conceptual vocabulary
- graduation criteria for future read-only reports
- explicit rejection/defer list

Out of scope:

- runtime agent execution
- autonomous delegation
- shared handoff value object
- new package
- workflow engine behavior
- cluster routing
- host activation
- web transport
- AI provider integration

## Task 1: Doctrine Draft

Owner: `[Research Horizon / Codex]`

Acceptance:

- Draft `docs/dev/handoff-doctrine.md`.
- Use the synthesis in
  `docs/research-horizon/agent-handoff-protocol.md` as source material.
- Define the smallest conceptual vocabulary: subject, sender, recipient,
  context, evidence, obligations, receipt, trace.
- Map each concept to current concrete artifacts without implying new runtime
  behavior.
- Include a "not accepted yet" section for runtime execution, autonomous
  delegation, cluster routing, host activation, web transport, AI provider
  calls, and shared value objects.

## Task 2: Protocol Indexing

Owner: `[Research Horizon / Codex]`

Acceptance:

- Link the doctrine from `docs/dev/README.md`.
- Add a short reference from `docs/dev/tracks.md` without changing package
  agent implementation handoffs.
- Keep Research Horizon as research/proposal owner; do not assign package code
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

1. `[Research Horizon / Codex]` drafts the docs-only handoff doctrine.
2. Do not add shared runtime objects, package code, agent execution, AI
   provider integration, cluster routing, host activation, or web transport.

[Research Horizon / Codex]
Track: `docs/dev/handoff-doctrine-track.md`
Status: landed.
Changed:
- Added `docs/dev/handoff-doctrine.md`.
- Linked the doctrine from `docs/dev/README.md`.
- Added a short `docs/dev/tracks.md` reference without changing package-agent
  implementation handoffs.
Accepted:
- Doctrine defines the conceptual vocabulary: subject, sender, recipient,
  context, evidence, obligations, receipt, and trace.
- Doctrine maps docs-agent tracks, application handoff manifests, transfer
  receipts, host activation readiness/plans, and operator workflows without
  introducing runtime behavior.
- Doctrine explicitly does not accept shared runtime handoff value objects, new
  packages, runtime agent execution, autonomous delegation, workflow engine
  behavior, cluster routing, host activation, route activation, mount binding,
  web/browser transport, AI provider calls, hidden discovery, or host wiring
  mutation.
Verification:
- `git diff --check` passed.
Needs:
- `[Architect Supervisor / Codex]` review/accept the docs-only doctrine and
  decide whether the next Research Horizon review candidate should remain
  Interaction Kernel.

## Supervisor Acceptance

[Architect Supervisor / Codex] Accepted after the 2026-04-25 research cycle.

The handoff doctrine is accepted as docs-only language alignment:

- It gives a shared vocabulary for ownership transfer without creating a
  shared runtime object.
- It maps current surfaces rather than overriding them.
- It preserves the implementation boundary: no package code, new package,
  runtime agent execution, autonomous delegation, workflow engine behavior,
  cluster routing, host activation, web transport, AI provider integration,
  hidden discovery, or host wiring mutation.

Next Research Horizon review candidate:

- Interaction Kernel read-only report synthesis.
