# Application Dispatch Scoping Track

This track scopes Dispatch as the next product pressure line after Lense,
Chronicle, and Scout.

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
- [Application Showcase Evidence And Smoke Design Track](./application-showcase-evidence-smoke-design-track.md)
- [Application Showcase Convention Consolidation Track](./application-showcase-convention-consolidation-track.md)
- [Interactive App Structure](../guide/interactive-app-structure.md)
- [Application Proposals](../experts/application-proposals.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting showcase evidence/smoke
design.

Dispatch is selected for scoping because it can stress operational event intake,
triage/routing evidence, assignment or escalation state, handoff checkpoints,
and incident receipts. The first slice must stay offline and fixture-backed.

This is not yet approval to implement Dispatch.

## Goal

Define a compact Dispatch POC slice that feels useful without relying on live
monitoring, timers, queues, schedulers, LLMs, connectors, or production
incident tooling.

The result must answer:

- what local incident/event fixtures Dispatch reads
- what app-owned services exist
- what deterministic contract graph computes
- what commands and refusal paths exist
- what snapshot/read model the Web surface consumes
- what dispatch/incident receipt artifact proves
- what smoke evidence and mutation-boundary proof look like
- what remains explicitly out of scope
- whether the next cycle should implement Dispatch or return to support/package
  work

## Scope

In scope:

- docs/design scoping only
- local event/incident fixtures
- deterministic triage, routing, escalation, and handoff rules
- app-local incident session state
- candidate contract graph shape
- command/result/snapshot shape
- receipt-shaped incident output
- one mounted Web surface sketch
- smoke-test acceptance sketch

Out of scope:

- implementation
- public `Igniter.interactive_app` facade
- live monitoring, timers, queues, schedulers, background workers
- SSE/WebSocket/live transport
- LLM/provider integration
- PagerDuty/Opsgenie/Slack/log/metrics/deploy connectors
- real remediation commands or shell execution
- persistence database
- auth/users/teams/production server behavior
- cluster placement or distributed runtime
- generic incident/workflow/report framework

## Task 1: Dispatch Application Scoping

Owner: `[Agent Application / Codex]`

Acceptance:

- Propose the smallest useful offline incident scenario.
- Define fixture shape, app-owned services, command names, command result
  shape, action facts, snapshot shape, and refusal paths.
- Propose a deterministic contract graph for event intake, severity,
  suspected cause, routing/assignment, escalation readiness, handoff state, and
  incident receipt payload.
- Define a receipt/report shape that proves evidence, routing rationale,
  checkpoint choice, action facts, deferred scope, provenance, validity, and
  mutation boundary while keeping payload shape app-local.
- Identify what must stay app-local and what should only be observed for future
  support evidence.

## Task 2: Dispatch Web Scoping

Owner: `[Agent Web / Codex]`

Acceptance:

- Propose one mounted Web surface using an app-owned Dispatch snapshot.
- Define page sections, forms/actions, feedback codes, `/events` parity,
  `/receipt` inspection, and stable `data-` markers.
- Render event/triage/routing/handoff evidence as nested HTML with app-local
  markers; do not propose graph/canvas/live transport.
- Define smoke assertions for initial render, intake/triage command success,
  assignment or escalation command, refusal path, receipt evidence, `/events`
  parity, and fixture no-mutation.
- Identify what remains Web-local and what is deferred.

## Supervisor Guardrails

[Architect Supervisor / Codex] Notes:

- Dispatch should demonstrate "incident command you can replay", not live
  production monitoring.
- The first slice can use seeded incident/event fixtures and deterministic
  routing rules.
- The product story should be:
  event intake -> triage/routing evidence -> assignment/escalation checkpoint
  -> handoff/incident receipt.
- No command may mutate real infrastructure or imply real remediation.
- Do not use Dispatch to introduce scheduler, queue runtime, live transport,
  connectors, LLM triage, auth, production server, or cluster placement.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
```

Implementation belongs to a later track.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` scopes Dispatch's fixture-backed incident
   model, deterministic contract graph, commands, snapshot, and incident
   receipt.
2. `[Agent Web / Codex]` scopes Dispatch's mounted Web surface, triage/routing
   markers, `/events`, `/receipt`, and smoke evidence.
3. `[Architect Supervisor / Codex]` decides whether to implement Dispatch or
   return to support/package work.

## Dispatch Application Scoping

[Agent Application / Codex] Proposed first slice:

Dispatch should center on one replayable incident command workflow:

```text
seeded event bundle -> deterministic triage/routing evidence ->
assignment/escalation checkpoint -> incident handoff receipt
```

Smallest useful scenario:

- Incident: `INC-001`, payments checkout degradation.
- Trigger: seeded event bundle reports elevated checkout errors, a recent
  deploy, and a database migration clue.
- Product story: Dispatch intakes local event evidence, computes severity and
  suspected cause, proposes an owner/escalation route, records a human
  assignment or escalation checkpoint, and emits an incident receipt.
- No live polling happens. No queue runs. No Slack/PagerDuty/Opsgenie/log/
  metrics/deploy connector is used. No remediation command mutates
  infrastructure.

Local fixture shape:

```text
examples/application/dispatch/data/incidents/inc-001.json
examples/application/dispatch/data/events/*.json
examples/application/dispatch/data/runbooks/*.md
examples/application/dispatch/data/teams.json
```

Incident fixture example:

```json
{
  "id": "INC-001",
  "title": "Checkout errors after payments deploy",
  "service": "payments-api",
  "started_at": "2026-04-26T14:23:07Z",
  "event_ids": ["EVT-001", "EVT-002", "EVT-003", "EVT-004"],
  "default_route": "payments-platform"
}
```

Event fixture example:

```json
{
  "id": "EVT-001",
  "kind": "metric",
  "service": "payments-api",
  "signal": "checkout_error_rate",
  "value": 12.4,
  "threshold": 5.0,
  "severity_hint": "critical",
  "citation": "metrics#checkout_error_rate"
}
```

Runbook fixture example:

```text
id: RB-001
service: payments-api
owner: payments-platform
escalation: database-oncall
keywords: migration, undefined-column, rollback-risk

## Routing Rules
- Undefined column after deploy routes to payments-platform and database-oncall.
- Rollback or migration action requires explicit human approval.
```

App-owned services:

- `IncidentLibrary`: loads incident/event/runbook/team fixtures and exposes
  event bundles by incident id.
- `DispatchAnalyzer`: deterministic wrapper around the contract graph.
- `IncidentSessionStore`: owns selected incident, triage state, assignment or
  escalation checkpoint, action facts, refusals, and receipt emission.
- `Dispatch::App`: composition boundary for services, commands, Web mount,
  `/events`, and `/receipt`.

Command names:

- `open_incident(incident_id:)`: validates fixture id and starts an incident
  command session.
- `triage_incident(session_id:)`: runs deterministic event intake and routing
  analysis.
- `assign_owner(session_id:, team:)`: records an assignment checkpoint when
  routing options exist.
- `escalate_incident(session_id:, team:, reason:)`: records an escalation
  checkpoint when escalation is allowed and the reason is present.
- `emit_receipt(session_id:)`: writes the incident handoff receipt only after
  triage and assignment or escalation checkpoint.

Local command result shape:

```ruby
CommandResult = Data.define(
  :kind,
  :feedback_code,
  :session_id,
  :incident_id,
  :event_id,
  :team,
  :receipt_id,
  :action
)
```

Expected feedback codes:

- `dispatch_incident_opened`
- `dispatch_triage_completed`
- `dispatch_owner_assigned`
- `dispatch_incident_escalated`
- `dispatch_receipt_emitted`
- `dispatch_unknown_incident`
- `dispatch_unknown_session`
- `dispatch_triage_not_ready`
- `dispatch_unknown_team`
- `dispatch_invalid_assignment`
- `dispatch_blank_escalation_reason`
- `dispatch_receipt_not_ready`

Action facts:

- `incident_opened`
- `event_ingested`
- `triage_completed`
- `route_proposed`
- `assignment_recorded`
- `escalation_recorded`
- `receipt_emitted`
- `command_refused`

Snapshot shape:

```ruby
DispatchSnapshot = Data.define(
  :session_id,
  :incident_id,
  :title,
  :service,
  :status,
  :severity,
  :suspected_cause,
  :event_count,
  :route_options,
  :assigned_team,
  :escalated_team,
  :handoff_ready,
  :top_events,
  :routing_evidence,
  :receipt_id,
  :action_count,
  :recent_events
)
```

Deterministic contract graph:

```text
inputs:
  incident, events, runbooks, teams, checkpoint

computes:
  event_facts             # normalized metrics/log/deploy/runbook evidence
  severity                # critical/high/medium from thresholds and hints
  suspected_cause         # deploy, migration, upstream, capacity, unknown
  routing_options         # owner/escalation teams from service, runbook, facts
  assignment_readiness    # whether owner/escalation can be recorded
  handoff_readiness       # whether receipt can be emitted
  incident_receipt_payload

outputs:
  event_facts,
  severity,
  suspected_cause,
  routing_options,
  assignment_readiness,
  handoff_readiness,
  incident_receipt_payload
```

Receipt shape:

The app-local `IncidentReceipt` should include:

- receipt id such as `dispatch-receipt:dispatch-session-inc-001`
- kind, validity, and generated timestamp
- incident id, title, service, status, and selected checkpoint
- severity and suspected cause with deterministic rationale
- routing decision: assigned team or escalated team, plus options considered
- evidence refs back to event ids, runbook ids, fixture paths, and citations
- compact action facts relevant to the handoff
- provenance: fixture paths, contract version, app version when useful
- deferred scope: no live monitoring, no queues, no connectors, no LLM triage,
  no remediation execution, no persistence database, no production server, no
  cluster placement
- mutation boundary: fixture files are read-only; runtime sessions/actions/
  receipts are written only to `ENV["DISPATCH_WORKDIR"]` or a temp workdir

Smoke evidence sketch:

- unknown incident refusal
- open incident success
- triage success with severity, suspected cause, route options, and event count
- receipt-not-ready refusal before checkpoint
- unknown team or invalid assignment refusal
- assignment or escalation checkpoint success
- receipt emission success and validity marker
- `/events` parity with snapshot once Web lands
- fixture no-mutation marker
- runtime session/action/receipt count markers

Keep app-local:

- `CommandResult`, `DispatchSnapshot`, `IncidentReceipt`, feedback codes,
  action facts, fixture schemas, routing rules, severity thresholds, suspected
  cause vocabulary, receipt payload keys, workdir layout, and smoke marker
  names.

Observe for future support evidence only:

- repeated receipt/report checklist fields
- repeated mutation-boundary proof pattern
- repeated smoke shape for success/refusal/final-state evidence
- possible script-local smoke helper mechanics if Web agrees later

Still deferred:

- public `Igniter.interactive_app`
- generic incident/workflow/report framework
- live monitoring, timers, queues, schedulers, background workers
- Slack/PagerDuty/Opsgenie/log/metrics/deploy connectors
- LLM triage or generated remediation
- shell/remediation execution
- SSE/WebSocket/live transport
- persistence database, auth, production server, cluster placement

Recommendation:

- Open a bounded Dispatch implementation track after Web scoping lands, unless
  Supervisor prefers one tiny script-local smoke helper first.
- Do not return to package/core work yet; Dispatch should pressure the
  evidence/smoke convention with a fourth domain before any framework
  graduation decision.

[Agent Application / Codex]
track: `docs/dev/application-dispatch-scoping-track.md`
status: landed
delta: scoped Dispatch app-side first slice as offline seeded incident event
  bundle -> deterministic triage/routing evidence -> assignment/escalation
  checkpoint -> incident handoff receipt.
delta: defined fixture shapes, app-owned services, command names, command
  result shape, action facts, snapshot shape, refusal paths, deterministic
  contract graph, receipt payload checklist, smoke evidence, mutation boundary,
  and app-local/deferred boundaries.
delta: recommended bounded Dispatch implementation after Web scoping, with
  helper/package graduation still deferred until another pressure pass.
verify: `git diff --check` passed.
ready: `[Agent Web / Codex]` can scope mounted Web surface, markers,
  `/events`, `/receipt`, and smoke evidence.
block: none
