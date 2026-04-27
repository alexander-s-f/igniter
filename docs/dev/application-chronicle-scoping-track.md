# Application Chronicle Scoping Track

This track scopes Chronicle as the second product/app pressure test after Lense.
It must decide whether Chronicle is worth implementing as a bounded one-process
POC and what the smallest useful slice should be.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Package agents should report with:

```text
[Agent Application / Codex]
[Agent Web / Codex]
```

Constraints:

- `:interactive_poc_guardrails` from [Constraint Sets](./constraints.md)
- [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md)
- [Application Showcase Synthesis Track](./application-showcase-synthesis-track.md)
- [Application Proposals](../experts/application-proposals.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting app/web showcase
synthesis.

Chronicle is selected for scoping because it can stress a different enterprise
application shape without leaving the current guardrails:

- local Markdown decision/proposal records
- deterministic proposal and conflict scanning
- explicit decision/sign-off commands
- linked decision/read-model snapshots
- receipt-shaped decision records
- Web inspection with stable markers and `/events` parity

This is not yet approval to implement Chronicle.

## Goal

Define a compact Chronicle POC slice that is useful to an end user and sharp
enough to test Igniter application structure.

The result must answer:

- what local files/data Chronicle reads and writes, if any
- what app-owned services exist
- what the first contracts graph should validate or compute
- what commands exist and what their local result shape looks like
- what snapshot/read model the Web surface consumes
- what receipt/report artifact Chronicle produces
- what stable Web markers and smoke assertions prove
- what is explicitly out of scope for the first slice
- whether the next cycle should implement Chronicle or choose another pressure
  line

## Scope

In scope:

- docs/design scoping only
- local deterministic data model
- app-local service boundaries
- candidate contract graph shape
- command/result/snapshot shape
- receipt-shaped output shape
- one mounted Web surface sketch
- smoke-test acceptance sketch

Out of scope:

- implementation
- public `Igniter.interactive_app` facade
- generic decision/workflow framework
- UI kit, graph/canvas renderer, SVG map, or component library
- LLM provider integration
- network/search/connectors
- scheduler/file watcher
- persistence database
- auth, users, teams, or production server concerns
- mutating external repositories or external systems

## Task 1: Chronicle Application Scoping

Owner: `[Agent Application / Codex]`

Acceptance:

- Propose the smallest local Chronicle domain model using Markdown or plain
  files as the backing store.
- Define app-owned services, command names, command result shape, action facts,
  snapshot shape, and refusal paths.
- Propose the first useful contract graph, keeping it deterministic and
  runnable offline.
- Define a receipt/report shape that proves provenance, conflicts, and sign-off
  state without becoming a generic report framework.
- Identify which pieces must stay app-local and which repeated conventions
  should be observed for future graduation.

## Task 2: Chronicle Web Scoping

Owner: `[Agent Web / Codex]`

Acceptance:

- Propose one mounted Web surface for Chronicle using app-owned snapshots.
- Define page sections, forms/actions, feedback codes, `/events` parity, and
  stable `data-` markers.
- Prefer inspectable nested HTML for linked decisions/conflicts; do not propose
  graph/canvas/SVG tooling in the first slice.
- Define smoke assertions for initial render, command success, refusal path,
  receipt/report marker, and `/events` parity.
- Identify which Web pieces stay app-local and which repeated boilerplate
  should merely be observed.

## Supervisor Guardrails

[Architect Supervisor / Codex] Notes:

- Chronicle must feel like a real enterprise workflow, not a toy ADR viewer.
- The first slice should center on "proposal meets existing decisions":
  conflict evidence, explicit sign-off, and a durable decision receipt.
- A tiny file store is allowed if it stays transparent and deterministic.
- Do not use Chronicle to smuggle in a public app DSL, production workflow
  engine, or UI framework.
- The useful output of this track is a scoped implementation decision.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
```

Implementation belongs to a later track.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` scopes Chronicle's app-local model and first
   contract-backed workflow.
2. `[Agent Web / Codex]` scopes Chronicle's mounted surface and smoke evidence.
3. `[Architect Supervisor / Codex]` decides whether to implement Chronicle or
   choose another pressure line.
