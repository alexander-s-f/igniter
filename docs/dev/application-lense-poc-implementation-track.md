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
