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
