# Application Scout Implementation Track

This track implements Scout as the next bounded one-process showcase app. It
follows the accepted scoping from
[Application Scout Scoping Track](./application-scout-scoping-track.md).

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
- [Application Scout Scoping Track](./application-scout-scoping-track.md)
- [Application Showcase Convention Consolidation Track](./application-showcase-convention-consolidation-track.md)
- [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting Scout scoping.

Implement one useful Scout slice:

```text
topic + local source set -> deterministic findings -> direction checkpoint ->
synthesis receipt with source provenance
```

This is an example/showcase implementation, not a package API graduation.

## Goal

Create a runnable Scout POC that can be smoke-tested and manually opened in a
browser.

The implementation should provide:

- read-only local source fixtures
- runtime-only session/action/receipt writes
- app-owned services and local command results
- deterministic contract-backed extraction/readiness/receipt analysis
- one mounted Web research workspace
- `/events` and `/receipt` inspection endpoints
- smoke output proving the full workflow and fixture no-mutation
- catalog registration if the smoke remains deterministic and fast

## Scope

In scope:

- `examples/application/scout_poc.rb`
- `examples/application/scout/`
- `examples/application/scout/app.rb`
- `examples/application/scout/config.ru`
- app-local services, contracts, reports, source fixtures, and Web surface
- optional README for manual usage
- `examples/catalog.rb` registration if the POC is stable

Out of scope:

- package API changes unless a tiny existing seam is clearly required
- public `Igniter.interactive_app` facade
- generic research/workflow/report DSL
- network search, web fetching, connectors, RSS, PDF upload, or external APIs
- LLM/provider integration, embeddings, semantic search, or generated summaries
- graph/canvas/SVG evidence map
- UI kit or generic Web components
- live transport/SSE/WebSocket
- scheduler/file watcher/background agent runtime
- persistence database
- auth/users/teams/production server concerns
- mutating external repositories, fixtures, or systems

## Task 1: Scout Application Implementation

Owner: `[Agent Application / Codex]`

Acceptance:

- Create app-local Scout structure and read-only local source fixtures.
- Implement transparent source parsing/loading for the fixture pack.
- Implement app-owned services such as `SourceLibrary`, `FindingExtractor`,
  `ResearchSessionStore`, and `Scout::App` or equivalent names.
- Implement local `CommandResult` and `ScoutSnapshot` shapes.
- Implement commands:
  `start_session`, `extract_findings`, `add_local_source`,
  `choose_checkpoint`, and `emit_receipt`.
- Implement action facts for session/source/extraction/contradiction/
  checkpoint/receipt/refusal paths.
- Implement a deterministic contract-backed graph for source claims, finding
  clusters, contradictions, direction options, checkpoint readiness, and
  research receipt payload.
- Implement receipt emission into the runtime workdir only.
- Prove fixture no-mutation in `scout_poc.rb` smoke output.

## Task 2: Scout Web Implementation

Owner: `[Agent Web / Codex]`

Acceptance:

- Implement one mounted Arbre research workspace under
  `examples/application/scout/web/`.
- Render from the app-owned `ScoutSnapshot`; Web must not own source parsing,
  extraction state, checkpoint readiness, or receipt payloads.
- Implement Rack routes for start session, extract findings, add local source,
  choose checkpoint, receipt emission, `/events`, and `/receipt`.
- Render stable markers from the scoping track, including topic/session,
  source/provenance, finding, contradiction, checkpoint, receipt, feedback, and
  recent-activity markers.
- Render source/provenance evidence as nested HTML, not graph/canvas/live
  transport.
- Add in-process Rack smoke coverage in `scout_poc.rb` for initial render,
  blank topic, unknown source, successful session start, findings extraction,
  receipt-not-ready, invalid checkpoint, valid checkpoint, receipt emission,
  `/events` parity, `/receipt`, and fixture no-mutation.
- Provide manual server mode similar to the other app POCs.

## Coordination Notes

[Architect Supervisor / Codex] Notes:

- Prefer the existing Lense/Chronicle showcase style over new abstractions.
- Keep write scopes app-local; package changes require explicit justification in
  the handoff.
- Do not DRY up `CommandResult`, snapshots, markers, fixtures, or smoke helpers
  yet.
- If the first slice feels too large, reduce source count or presentation
  detail before cutting provenance, checkpoint, or receipt behavior.
- If Application and Web work in parallel, Application owns services/contracts/
  reports/data/app wiring; Web owns `web/`, Rack route wiring, manual server
  affordances, and smoke-marker integration.

## Verification Gate

Before supervisor acceptance, run at minimum:

```bash
ruby examples/application/scout_poc.rb
ruby examples/run.rb smoke
bundle exec rubocop examples/application/scout_poc.rb examples/application/scout examples/catalog.rb
git diff --check
```

If catalog registration is deferred, explain why in the handoff.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` implements Scout app-local services, fixtures,
   contract graph, command results, snapshots, receipt/report, and core smoke
   output.
2. `[Agent Web / Codex]` implements the mounted research workspace, Rack routes,
   markers, `/events`, `/receipt`, manual server mode, and web smoke
   assertions.
3. `[Architect Supervisor / Codex]` reviews implementation and decides whether
   Scout is showcase-ready or needs a finalization pass.

[Agent Application / Codex]
track: `docs/dev/application-scout-implementation-track.md`
status: landed
delta: added `examples/application/scout/` with read-only local source
  fixtures, source parser/library, deterministic finding extractor,
  contract-backed research synthesis graph, session store, command results,
  snapshots, research receipt writer, and app-local `Scout::App`.
delta: added `examples/application/scout_poc.rb` core smoke proving blank
  topic, no sources, unknown source, session start, finding extraction,
  receipt-not-ready, invalid checkpoint, local source add, re-extraction,
  checkpoint choice, receipt emission, provenance citation, runtime writes, and
  fixture no-mutation.
delta: registered `application/scout_poc` in `examples/catalog.rb` while
  leaving Web routes/surface/manual server mode to `[Agent Web / Codex]`.
verify: `ruby examples/application/scout_poc.rb` passed.
verify: `ruby examples/run.rb run application/scout_poc` passed.
verify: `ruby examples/run.rb smoke` passed, 79 examples.
verify: `bundle exec rubocop examples/application/scout_poc.rb examples/application/scout examples/catalog.rb`
  passed.
verify: `git diff --check` passed.
ready: `[Agent Web / Codex]` can implement Scout mounted research workspace,
  Rack routes, `/events`, `/receipt`, web markers, and manual server mode on
  top of the app-local core.
block: none
