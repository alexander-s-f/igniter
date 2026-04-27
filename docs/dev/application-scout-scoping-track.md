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

## Scout Application Scoping

[Agent Application / Codex] Proposed first slice:

Scout should center on one reproducible research workflow:

```text
topic + local source set -> extracted findings -> contradiction/direction
checkpoint -> synthesis receipt with provenance
```

Smallest useful scenario:

- Topic: "How should engineering teams adopt AI coding assistants?"
- Source pack: three to five local Markdown/JSON/text source fixtures with
  short excerpts, claims, audience tags, source type, date, and citation id.
- Product story: Scout extracts local findings, detects a governance versus
  velocity tension, asks for a direction checkpoint, and emits a source-backed
  synthesis receipt.
- No source is fetched. No source is summarized by an LLM. No fixture is
  mutated during smoke.

Local fixture shape:

```text
examples/application/scout/data/sources/*.md
examples/application/scout/data/source_index.json
```

Markdown source example:

```text
id: SRC-001
title: Enterprise AI assistant policy notes
type: internal_note
date: 2026-02-04
audience: enterprise
tags: governance,security,policy

## Summary
Large teams adopted AI assistants faster after policy and review rules were
clear.

## Claims
- Governance improved adoption confidence. [p1]
- Security review is the most repeated blocker. [p2]
```

App-owned services:

- `SourceLibrary`: loads source fixtures and exposes source ids, metadata,
  excerpts, tags, and citation anchors.
- `FindingExtractor`: deterministic extraction from `## Claims`, tags, source
  type, and citation anchors.
- `ResearchSessionStore`: owns selected topic, source set, checkpoint choice,
  action facts, refusal paths, and receipt emission.
- `ScoutApp`: composition boundary that wires services, commands, Rack routes,
  and the mounted surface later.

Command names:

- `start_session(topic:, source_ids:)`: validates local sources and creates a
  research session.
- `extract_findings(session_id:)`: runs deterministic extraction and stores
  finding evidence.
- `choose_checkpoint(session_id:, direction:)`: records one of
  `governance`, `velocity`, or `balanced` after contradiction/direction
  evidence exists.
- `add_local_source(session_id:, source_id:)`: adds an existing local fixture
  only; unknown ids are refused.
- `emit_receipt(session_id:)`: writes a synthesis receipt only after extraction
  and checkpoint choice.

Local command result shape:

```ruby
CommandResult = Data.define(
  :kind,
  :feedback_code,
  :session_id,
  :source_id,
  :finding_id,
  :receipt_id,
  :action
)
```

Expected feedback codes:

- `scout_session_started`
- `scout_findings_extracted`
- `scout_checkpoint_chosen`
- `scout_local_source_added`
- `scout_receipt_emitted`
- `scout_blank_topic`
- `scout_unknown_source`
- `scout_unknown_session`
- `scout_no_sources`
- `scout_invalid_checkpoint`
- `scout_receipt_not_ready`

Action facts:

- `session_started`
- `source_selected`
- `source_added`
- `findings_extracted`
- `contradiction_detected`
- `checkpoint_chosen`
- `receipt_emitted`
- `command_refused`

Snapshot shape:

```ruby
ScoutSnapshot = Data.define(
  :session_id,
  :topic,
  :status,
  :source_count,
  :finding_count,
  :contradiction_count,
  :checkpoint_choice,
  :top_findings,
  :contradictions,
  :source_refs,
  :receipt_id,
  :action_count,
  :recent_events
)
```

First useful contract graph:

- `topic`: input normalized topic.
- `sources`: input parsed local source fixtures.
- `source_claims`: project each source into deterministic claim records.
- `findings`: cluster claims by tags and normalized keywords.
- `contradictions`: detect governance/velocity/security/adoption tensions when
  finding clusters disagree or emphasize different directions.
- `direction_options`: compute available checkpoint choices from contradictions
  and finding coverage.
- `checkpoint_readiness`: require extracted findings plus a valid checkpoint
  before receipt emission.
- `synthesis_payload`: output topic, findings, source citations,
  contradictions, checkpoint choice, provenance, deferred scope, and validity.

This graph must remain deterministic and offline. It should not fetch URLs,
call LLMs, use embeddings, write files, or invent claims absent from fixtures.

Research receipt shape:

- `receipt_id`: stable session-derived id.
- `topic`: normalized topic and original user text.
- `sources`: source id, title, type, fixture path, tags, citation anchors.
- `findings`: finding id, statement, confidence signal, source refs.
- `contradictions`: tension id, directions, supporting finding/source refs.
- `checkpoint`: chosen direction, available options, action fact.
- `synthesis`: deterministic paragraph or bullets assembled from findings and
  checkpoint choice.
- `provenance`: fixture paths, source index path, contract version.
- `actions`: compact action ledger slice.
- `deferred`: no network search, no LLM, no connectors, no persistence DB, no
  live transport, no scheduler.
- `validity`: true only after extraction and checkpoint choice.

Keep app-local for this slice:

- Source fixture schema and parser.
- Claim extraction rules.
- Finding clustering and contradiction heuristics.
- Checkpoint choices and readiness rules.
- Command result class and feedback codes.
- Snapshot fields and status names.
- Receipt payload shape, citation format, validity rules, and rendered output.
- Runtime workdir layout and smoke labels.

Observe for future support only:

- App-owned source library plus runtime session store pattern.
- Deterministic contract-backed receipt payload.
- Receipt/report convention from Lense, Chronicle, and Scout if implemented.
- Smoke helper repetition if Scout repeats the Rack/catalog boilerplate.

Application recommendation:

- Implement Scout next if Web scoping can keep the first surface to one
  local-source research workspace with nested provenance evidence.
- Keep the first slice offline/local-source only. Do not introduce web fetch,
  LLM/provider calls, connectors, SSE/live progress, scheduler, persistence DB,
  auth/users/teams, or generic research workflow APIs.
- If implementation feels too large, preserve the end-to-end path and reduce
  source count or presentation detail before cutting provenance, checkpoint, or
  receipt behavior.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` scopes Scout's local-source app model,
   deterministic contract graph, command flow, snapshot, and research receipt.
2. `[Agent Web / Codex]` scopes Scout's mounted Web surface, provenance markers,
   `/events`, report/receipt inspection, and smoke evidence.
3. `[Architect Supervisor / Codex]` decides whether to implement Scout or choose
   a support/design pass.

[Agent Application / Codex]
track: `docs/dev/application-scout-scoping-track.md`
status: landed
delta: scoped Scout as an offline/local-source research workflow: topic plus
  seed source pack, deterministic findings, contradiction/direction checkpoint,
  and synthesis receipt with provenance.
delta: defined local fixture shape, app-owned services, command names, command
  result fields, feedback codes, action facts, snapshot fields, refusal paths,
  deterministic contract graph, and research receipt payload.
delta: kept source parsing, extraction rules, clustering/contradiction
  heuristics, checkpoint choices, snapshots, command results, receipt payloads,
  citation format, workdir layout, and smoke labels app-local.
delta: recommended Scout implementation next only if Web scoping preserves a
  one-surface offline/local-source workspace; network, LLMs, connectors,
  live transport, scheduler, persistence DB, auth/users/teams, and generic
  research APIs remain deferred.
verify: `git diff --check` passed.
ready: `[Agent Web / Codex]` can scope the Scout mounted surface and smoke
  evidence; `[Architect Supervisor / Codex]` can decide implementation after
  Web scoping lands.
block: none
