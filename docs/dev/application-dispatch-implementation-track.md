# Application Dispatch Implementation Track

This track implements Dispatch as the next bounded one-process showcase app. It
follows the accepted scoping from
[Application Dispatch Scoping Track](./application-dispatch-scoping-track.md).

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
- [Application Dispatch Scoping Track](./application-dispatch-scoping-track.md)
- [Application Showcase Evidence And Smoke Design Track](./application-showcase-evidence-smoke-design-track.md)
- [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting Dispatch scoping.

Implement one useful Dispatch slice:

```text
seeded incident event bundle -> deterministic triage/routing evidence ->
assignment or escalation checkpoint -> incident handoff receipt
```

This is an example/showcase implementation, not a package API graduation.

## Goal

Create a runnable Dispatch POC that can be smoke-tested and manually opened in
a browser.

The implementation should provide:

- read-only local incident/event/runbook/team fixtures
- runtime-only session/action/receipt writes
- app-owned services and local command results
- deterministic contract-backed triage/routing/readiness/receipt analysis
- one mounted Web command center
- `/events` and `/receipt` inspection endpoints
- smoke output proving the full workflow and fixture no-mutation
- catalog registration if the smoke remains deterministic and fast

## Scope

In scope:

- `examples/application/dispatch_poc.rb`
- `examples/application/dispatch/`
- `examples/application/dispatch/app.rb`
- `examples/application/dispatch/config.ru`
- app-local services, contracts, reports, data fixtures, and Web surface
- optional README for manual usage
- `examples/catalog.rb` registration if the POC is stable

Out of scope:

- package API changes unless a tiny existing seam is clearly required
- public `Igniter.interactive_app` facade
- generic incident/workflow/report DSL
- live monitoring, timers, queues, schedulers, background workers
- Slack/PagerDuty/Opsgenie/log/metrics/deploy connectors
- LLM/provider integration or generated remediation
- real remediation commands, shell execution, or external mutation
- graph/canvas/SVG evidence map
- UI kit or generic Web components
- live transport/SSE/WebSocket
- persistence database
- auth/users/teams/production server concerns
- cluster placement or distributed runtime

## Task 1: Dispatch Application Implementation

Owner: `[Agent Application / Codex]`

Acceptance:

- Create app-local Dispatch structure and read-only incident/event/runbook/team
  fixtures.
- Implement transparent fixture loading/parsing for the incident bundle.
- Implement app-owned services such as `IncidentLibrary`,
  `DispatchAnalyzer`, `IncidentSessionStore`, and `Dispatch::App` or equivalent
  names.
- Implement local `CommandResult` and `DispatchSnapshot` shapes.
- Implement commands:
  `open_incident`, `triage_incident`, `assign_owner`,
  `escalate_incident`, and `emit_receipt`.
- Implement action facts for incident/event/triage/route/assignment/
  escalation/receipt/refusal paths.
- Implement a deterministic contract-backed graph for event facts, severity,
  suspected cause, routing options, assignment readiness, handoff readiness, and
  incident receipt payload.
- Implement receipt emission into the runtime workdir only.
- Prove fixture no-mutation in `dispatch_poc.rb` smoke output.

## Task 2: Dispatch Web Implementation

Owner: `[Agent Web / Codex]`

Acceptance:

- Implement one mounted Arbre command center under
  `examples/application/dispatch/web/`.
- Render from the app-owned `DispatchSnapshot`; Web must not own fixture
  parsing, triage state, routing rules, readiness, or receipt payloads.
- Implement Rack routes for open incident, triage, assignment, escalation,
  receipt emission, `/events`, and `/receipt`.
- Render stable markers from the scoping track, including incident/session,
  event/provenance, severity/cause, routing, assignment/escalation, handoff,
  receipt, feedback, and recent-activity markers.
- Render event/routing/handoff evidence as nested HTML, not graph/canvas/live
  transport.
- Add in-process Rack smoke coverage in `dispatch_poc.rb` for initial render,
  unknown incident, open incident, triage, receipt-not-ready, invalid/unknown
  team, blank escalation reason, assignment or escalation, receipt emission,
  `/events` parity, `/receipt`, and fixture no-mutation.
- Provide manual server mode similar to the other app POCs.

## Coordination Notes

[Architect Supervisor / Codex] Notes:

- Prefer the existing Lense/Chronicle/Scout showcase style over new
  abstractions.
- Keep write scopes app-local; package changes require explicit justification in
  the handoff.
- Do not DRY up `CommandResult`, snapshots, markers, fixtures, or smoke helpers
  yet.
- If the first slice feels too large, reduce fixture count or presentation
  detail before cutting triage evidence, checkpoint, or receipt behavior.
- No command should imply production remediation. Use receipt/deferred scope to
  make this explicit.

## Verification Gate

Before supervisor acceptance, run at minimum:

```bash
ruby examples/application/dispatch_poc.rb
ruby examples/run.rb smoke
bundle exec rubocop examples/application/dispatch_poc.rb examples/application/dispatch examples/catalog.rb
git diff --check
```

If catalog registration is deferred, explain why in the handoff.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` implements Dispatch app-local services,
   fixtures, contract graph, command results, snapshots, receipt/report, and
   core smoke output.
2. `[Agent Web / Codex]` implements the mounted command center, Rack routes,
   markers, `/events`, `/receipt`, manual server mode, and web smoke
   assertions.
3. `[Architect Supervisor / Codex]` reviews implementation and decides whether
   Dispatch is showcase-ready or needs a finalization pass.

[Agent Application / Codex]
track: `docs/dev/application-dispatch-implementation-track.md`
status: landed
delta: added `examples/application/dispatch/` with read-only incident/event/
  runbook/team fixtures, fixture parser/library, deterministic dispatch
  analyzer, contract-backed incident triage graph, session store, command
  results, snapshots, incident receipt writer, and app-local `Dispatch::App`.
delta: added `examples/application/dispatch_poc.rb` core smoke proving unknown
  incident, incident open, receipt-not-ready, triage, severity/cause/routing,
  unknown team, blank escalation reason, assignment checkpoint, receipt
  emission, deferred no-remediation scope, runtime writes, and fixture
  no-mutation.
delta: registered `application/dispatch_poc` in `examples/catalog.rb` while
  leaving mounted Web command center, Rack routes, markers, `/events`,
  `/receipt`, and manual server mode to `[Agent Web / Codex]`.
verify: `ruby examples/application/dispatch_poc.rb` passed.
verify: `ruby examples/run.rb run application/dispatch_poc` passed.
verify: `ruby examples/run.rb smoke` passed, 80 examples.
verify: `bundle exec rubocop examples/application/dispatch_poc.rb examples/application/dispatch examples/catalog.rb`
  passed.
verify: `git diff --check` passed.
ready: `[Agent Web / Codex]` can implement Dispatch mounted command center,
  command routes, Web markers, `/events`, `/receipt`, manual server mode, and
  web smoke assertions on top of the app-local core.
block: none

[Agent Web / Codex]
track: `docs/dev/application-dispatch-implementation-track.md`
status: landed
delta: added Dispatch Rack wiring through `Dispatch.build`, including mounted
  command center, command redirects, `/events`, `/receipt`, and manual server
  mode.
delta: added `examples/application/dispatch/web/command_center.rb` with an
  Arbre command center rendered from `DispatchSnapshot`, stable incident,
  event, provenance, severity, routing, checkpoint, receipt, feedback, and
  recent-activity markers.
delta: expanded `examples/application/dispatch_poc.rb` and
  `examples/catalog.rb` with in-process Rack smoke evidence for initial render,
  refusals, triage, assignment, receipt emission, `/events` parity, `/receipt`,
  and fixture no-mutation.
verify: `ruby examples/application/dispatch_poc.rb` passed.
verify: `ruby examples/run.rb run application/dispatch_poc` passed.
verify: `ruby examples/run.rb smoke` passed, 80 examples.
verify: `bundle exec rubocop examples/application/dispatch_poc.rb examples/application/dispatch examples/catalog.rb`
  passed.
verify: `git diff --check` passed.
verify: `ruby examples/application/dispatch_poc.rb server` served GET `/` on
  `http://127.0.0.1:9297/` during manual local check.
ready: `[Architect Supervisor / Codex]` can review Dispatch as a complete
  bounded one-process showcase candidate.
block: none
