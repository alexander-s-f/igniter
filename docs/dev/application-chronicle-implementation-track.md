# Application Chronicle Implementation Track

This track implements Chronicle as the second bounded one-process showcase app.
It follows the accepted scoping from
[Application Chronicle Scoping Track](./application-chronicle-scoping-track.md).

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
- [Application Chronicle Scoping Track](./application-chronicle-scoping-track.md)
- [Application Showcase Synthesis Track](./application-showcase-synthesis-track.md)
- [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting Chronicle scoping.

Implement one useful Chronicle slice:

```text
proposal meets existing decisions -> deterministic conflicts are shown ->
human acknowledges/signs off/refuses -> durable decision receipt is emitted
```

This is an example/showcase implementation, not a package API graduation.

## Goal

Create a runnable Chronicle POC that can be smoke-tested and manually opened in
a browser.

The implementation should provide:

- read-only seed decision/proposal fixtures
- runtime-only session/action/receipt writes
- app-owned services and local command results
- deterministic contract-backed conflict/readiness/receipt analysis
- one mounted Web workbench
- `/events` and `/receipt` inspection endpoints
- smoke output proving the user workflow and fixture no-mutation
- catalog registration if the smoke remains deterministic and fast

## Scope

In scope:

- `examples/application/chronicle_poc.rb`
- `examples/application/chronicle/`
- `examples/application/chronicle/app.rb`
- `examples/application/chronicle/config.ru`
- app-local services, contracts, reports, data fixtures, and Web surface
- optional README for manual usage
- `examples/catalog.rb` registration if the POC is stable

Out of scope:

- package API changes unless a tiny existing seam is clearly required
- public `Igniter.interactive_app` facade
- generic app/workflow/decision/report DSL
- UI kit or generic Web components
- SVG/canvas/graph rendering
- live transport/SSE/WebSocket
- LLM provider integration, semantic search, network calls, or connectors
- scheduler/file watcher
- persistence database
- auth/users/teams/production server concerns
- mutating external repositories or systems

## Task 1: Chronicle Application Implementation

Owner: `[Agent Application / Codex]`

Acceptance:

- Create the app-local Chronicle structure and read-only seed Markdown fixtures.
- Implement a transparent parser for the seed decision/proposal files.
- Implement app-owned services:
  `DecisionStore`, `ProposalStore`, `DecisionConflictScanner`,
  `DecisionSessionStore`, and `Chronicle::App` or equivalent names.
- Implement local `CommandResult` and `ChronicleSnapshot` shapes.
- Implement commands:
  `scan_proposal`, `acknowledge_conflict`, `sign_off`,
  `refuse_signoff`, and `emit_receipt`.
- Implement action facts for scan/conflict/ack/sign-off/refusal/receipt/refusal
  paths.
- Implement a deterministic contract-backed analysis graph for conflict
  evidence, required sign-offs, readiness, and receipt payload.
- Implement receipt emission into the runtime workdir only.
- Prove fixture no-mutation in `chronicle_poc.rb` smoke output.

## Task 2: Chronicle Web Implementation

Owner: `[Agent Web / Codex]`

Acceptance:

- Implement one mounted Arbre workbench surface under
  `examples/application/chronicle/web/`.
- Render from the app-owned `ChronicleSnapshot`; do not let Web own mutation or
  analysis state.
- Implement Rack routes for scan, acknowledge conflict, sign-off, refusal,
  receipt emission, `/events`, and `/receipt`.
- Render stable markers from the scoping track, including proposal/session,
  conflict/readiness, relationship, sign-off/refusal, receipt, feedback, and
  recent-activity markers.
- Render linked decisions/conflicts as nested HTML, not SVG/canvas/graph
  tooling.
- Add in-process Rack smoke coverage in `chronicle_poc.rb` for initial render,
  successful scan, acknowledgement, sign-off, blank refusal reason,
  receipt-not-ready, receipt emission, `/events` parity, `/receipt`, and
  fixture no-mutation.
- Provide manual server mode similar to the other app POCs.

## Coordination Notes

[Architect Supervisor / Codex] Notes:

- Prefer the existing `lense`/`operator_signal_inbox` example style over new
  abstractions.
- Keep write scopes app-local; package changes require explicit justification in
  the handoff.
- Do not DRY up `CommandResult`, snapshots, markers, or smoke helpers yet.
- If the first slice feels too large, preserve the full end-to-end flow and
  reduce presentation detail before cutting core receipt/sign-off behavior.
- If Application and Web work in parallel, Application owns services/contracts/
  reports/data/app wiring; Web owns `web/`, Rack route wiring, manual server
  affordances, and smoke-marker integration.

## Verification Gate

Before supervisor acceptance, run at minimum:

```bash
ruby examples/application/chronicle_poc.rb
ruby examples/run.rb smoke
bundle exec rubocop examples/application/chronicle_poc.rb examples/application/chronicle examples/catalog.rb
git diff --check
```

If catalog registration is deferred, explain why in the handoff.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` implements Chronicle app-local services,
   fixtures, contracts, reports, command results, snapshots, and core smoke
   output.
2. `[Agent Web / Codex]` implements the mounted workbench, Rack routes, markers,
   `/events`, `/receipt`, manual server mode, and web smoke assertions.
3. `[Architect Supervisor / Codex]` reviews implementation and decides whether
   Chronicle is showcase-ready or needs a finalization pass.
