# Application Lense POC Implementation Track

This track implements the first practical one-process showcase app after
capsule transfer and ledger-backed activation reached finalized-for-now status.

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
- [Application Showcase Selection Track](./application-showcase-selection-track.md)
- [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting Lense as the first
showcase/reference POC.

The goal is a useful, runnable, one-process app that demonstrates Igniter's
application structure, contracts-as-analysis-graph, web read model, guided
actions, and receipt-shaped report output without introducing a new public
facade.

## Goal

Implement Lense as a compact local codebase intelligence POC.

The app must prove:

- deterministic local Ruby file scan under an explicit target root
- app-local analysis services and session store
- contracts-native health scoring / finding prioritization
- detached `CodebaseSnapshot` read model
- one dashboard/workbench Rack surface
- guided issue session actions: `done`, `skip`, `note`
- receipt-shaped `LenseAnalysisReceipt` output
- no filesystem mutation of the scanned project

## Scope

In scope:

- `examples/application/lense_poc.rb`
- `examples/application/lense/`
- app-local services, contract, report, and web surface
- catalog smoke entry
- focused smoke markers and in-process Rack requests
- optional `server` argument for manual browser inspection, matching existing
  POC convention

Out of scope:

- package-level public `Igniter.interactive_app` facade
- generic dashboard builder or UI kit
- package-level command/result/snapshot DSL
- LLM provider integration
- network/search
- database persistence
- background scheduler, file watcher, SSE/WebSocket
- code editing, patch generation, or scanned-project mutation
- multi-repo support
- CI webhook
- auth/session framework
- production server/deployment behavior

## Task 1: Lense App Core

Owner: `[Agent Application / Codex]`

Acceptance:

- Add app-local structure under `examples/application/lense/`.
- Implement `CodebaseAnalyzer` that reads Ruby files only under an explicit
  target root and returns deterministic facts.
- Implement `CodebaseHealthContract` as the contracts-native analysis graph for
  health score, prioritized findings, and report metadata.
- Implement `IssueSessionStore` for guided session state, command results,
  recent events, and detached `CodebaseSnapshot`.
- Implement `LenseAnalysisReceipt` with scan identity, counts, findings,
  evidence refs, actions, skipped/deferred items, validity, and generated-at.
- Ensure no scanned-project file is modified.

## Task 2: Lense Web Surface

Owner: `[Agent Web / Codex]`

Acceptance:

- Add a single dashboard/workbench surface under
  `examples/application/lense/web/`.
- Use current `Igniter::Application.rack_app` and `MountContext` conventions.
- Add `GET /`, `GET /events`, `POST /scan`, `POST /sessions/start`, and
  `POST /sessions/:id/steps`.
- Render stable markers from the selection track, including scan, finding,
  session, feedback, and report markers.
- Implement feedback codes:
  `scan_refreshed`, `session_started`, `step_marked_done`, `step_skipped`,
  `note_added`, `finding_not_found`, `session_not_found`,
  `invalid_step_action`, and `blank_note`.
- Keep all mutation in app-local services and never mutate the scanned project.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
ruby examples/application/lense_poc.rb
ruby examples/run.rb smoke
bundle exec rubocop examples/application/lense_poc.rb examples/application/lense examples/catalog.rb
```

If shared package code changes, run the focused package specs as well.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` implements the Lense app core and report path.
2. `[Agent Web / Codex]` implements the dashboard/workbench surface and smoke
   loop.
3. `[Architect Supervisor / Codex]` reviews whether Lense is a useful showcase
   without exceeding the POC guardrails.

[Agent Application / Codex]
track: `docs/dev/application-lense-poc-implementation-track.md`
status: landed
delta: added `examples/application/lense_poc.rb` and app-local
  `examples/application/lense/` core structure with `app.rb`, services,
  contract, and receipt report.
delta: implemented `CodebaseAnalyzer` for deterministic Ruby file scans under
  an explicit target root, producing scan identity, file facts, duplicate-line
  groups, and counts without mutating the scanned project.
delta: implemented `CodebaseHealthContract` as a contracts-native analysis
  graph for counts, prioritized findings, health score, and report metadata.
delta: implemented `IssueSessionStore` with guided session commands
  `done`, `skip`, and `note`, app-local command results/feedback codes,
  recent action facts, and detached `CodebaseSnapshot`.
delta: implemented `LenseAnalysisReceipt` with scan identity, counts,
  findings, evidence refs, actions, skipped/deferred items, validity, and
  generated timestamp.
delta: added catalog smoke coverage for the Application slice markers; Web
  surface/Rack endpoints remain for `[Agent Web / Codex]`.
verify: `ruby examples/application/lense_poc.rb` passed.
verify: `ruby examples/run.rb smoke` passed, 77 examples.
verify: `bundle exec rubocop examples/application/lense_poc.rb examples/application/lense examples/catalog.rb`
  passed.
verify: `git diff --check` passed.
ready: `[Agent Web / Codex]` can mount the Lense dashboard/workbench over the
  app-owned snapshot, session commands, and receipt report.
block: none

[Agent Web / Codex]
track: `docs/dev/application-lense-poc-implementation-track.md`
status: landed
delta: added `examples/application/lense/web/lense_dashboard.rb` as the single
  Arbre dashboard/workbench surface over the app-owned `CodebaseSnapshot`,
  guided session state, recent events, and receipt report markers.
delta: updated `examples/application/lense/app.rb` with
  `Igniter::Application.rack_app` wiring for `GET /`, `GET /events`,
  `GET /report`, `POST /scan`, `POST /sessions/start`, and
  `POST /sessions/:id/steps`, preserving app-local mutation boundaries.
delta: extended `examples/application/lense_poc.rb` and `examples/catalog.rb`
  with in-process Rack smoke coverage for dashboard render, refresh, start
  session, done/skip/note, refusal feedback, `/events` parity, report output,
  and no scanned-project mutation.
delta: added narrow dynamic route params support to
  `Igniter::Application::RackHost` with focused spec coverage so the POC can use
  `/sessions/:id/steps` without introducing a broader server layer.
verify: `ruby examples/application/lense_poc.rb` passed.
verify: `ruby examples/run.rb smoke` passed, 77 examples.
verify: `bundle exec rubocop examples/application/lense_poc.rb examples/application/lense examples/catalog.rb packages/igniter-application/lib/igniter/application/rack_host.rb packages/igniter-application/spec/igniter/application/rack_host_spec.rb`
  passed.
verify: `bundle exec rspec packages/igniter-application/spec/igniter/application/rack_host_spec.rb`
  passed, 2 examples.
verify: `git diff --check` passed.
ready: `[Architect Supervisor / Codex]` can review the completed Lense
  implementation track.
block: none
