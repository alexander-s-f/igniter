# Application Scout Scoping Track

This track scopes Scout as the next product pressure line after Lense and
Chronicle.

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
- [Application Showcase Convention Consolidation Track](./application-showcase-convention-consolidation-track.md)
- [Application Showcase Portfolio Synthesis Track](./application-showcase-portfolio-synthesis-track.md)
- [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md)
- [Application Proposals](../experts/application-proposals.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting showcase convention
consolidation.

Scout is selected for scoping because it can stress research provenance,
source-backed findings, contradiction/direction checkpoints, and synthesis
receipts. The first slice must stay offline and local-source only.

This is not yet approval to implement Scout.

## Goal

Define a compact Scout POC slice that feels useful without relying on network,
LLMs, connectors, background workers, or live transport.

The result must answer:

- what local source fixtures Scout reads
- what app-owned services exist
- what deterministic contract graph computes
- what commands and refusal paths exist
- what snapshot/read model the Web surface consumes
- what research receipt/synthesis artifact Scout produces
- what provenance markers and smoke assertions prove
- what remains explicitly out of scope
- whether the next cycle should implement Scout or choose a support/design pass

## Scope

In scope:

- docs/design scoping only
- local source fixtures, for example Markdown/JSON/text files
- deterministic extraction and provenance rules
- app-local session/checkpoint state
- candidate contract graph shape
- command/result/snapshot shape
- receipt-shaped research output
- one mounted Web surface sketch
- smoke-test acceptance sketch

Out of scope:

- implementation
- public `Igniter.interactive_app` facade
- network search or web fetching
- LLM/provider integration
- connectors, RSS, PDF upload, Notion, Google Docs, Zotero
- SSE/WebSocket/live transport
- scheduler/file watcher/background agent runtime
- persistence database
- auth/users/teams/production server behavior
- generic research/workflow/report framework

## Task 1: Scout Application Scoping

Owner: `[Agent Application / Codex]`

Acceptance:

- Propose the smallest useful local-source research scenario.
- Define fixture shape, app-owned services, command names, command result
  shape, action facts, snapshot shape, and refusal paths.
- Propose a deterministic contract graph for source extraction, finding
  clustering, contradiction/direction evidence, checkpoint readiness, and
  research receipt payload.
- Define a receipt/report shape that proves findings, citations/provenance,
  checkpoint choice, contradictions, deferred scope, and validity while keeping
  payload shape app-local.
- Identify what must stay app-local and what should only be observed for future
  support evidence.

## Task 2: Scout Web Scoping

Owner: `[Agent Web / Codex]`

Acceptance:

- Propose one mounted Web surface using an app-owned Scout snapshot.
- Define page sections, forms/actions, feedback codes, `/events` parity,
  `/report` or `/receipt` inspection, and stable `data-` markers.
- Render source/provenance evidence as nested HTML with app-local markers; do
  not propose graph/canvas/live transport.
- Define smoke assertions for initial render, source/session command success,
  checkpoint choice, refusal path, receipt/report evidence, `/events` parity,
  and fixture no-mutation.
- Identify what remains Web-local and what is deferred.

## Supervisor Guardrails

[Architect Supervisor / Codex] Notes:

- Scout should demonstrate "research you can reproduce", not "AI web search".
- The first slice can use seeded local sources and deterministic extraction.
- The product story should be:
  topic/source set -> extracted findings -> contradiction or direction
  checkpoint -> synthesis receipt with provenance.
- Keep the source model transparent; provenance is the point.
- Do not use Scout to introduce LLMs, connectors, live feeds, or a generic
  workflow framework.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
```

Implementation belongs to a later track.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` scopes Scout's local-source app model,
   deterministic contract graph, command flow, snapshot, and research receipt.
2. `[Agent Web / Codex]` scopes Scout's mounted Web surface, provenance markers,
   `/events`, report/receipt inspection, and smoke evidence.
3. `[Architect Supervisor / Codex]` decides whether to implement Scout or choose
   a support/design pass.
