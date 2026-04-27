# Application Showcase Synthesis Track

This track synthesizes what the current app/web POCs prove before opening more
product features or package-level facade work.

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
- [Application Lense Showcase Finalization Track](./application-lense-showcase-finalization-track.md)
- [Application Proposals](../experts/application-proposals.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting Lense as showcase-ready.

Igniter now has multiple app/web pressure tests:

- `interactive_operator`
- `operator_signal_inbox`
- `lense`

Before adding another feature or facade, synthesize what repeated naturally and
what should remain app-local.

## Goal

Decide the next product/app pressure line from evidence, not enthusiasm.

The result must answer:

- which app-local shapes repeated across the POCs
- which shapes are still domain-specific
- whether any tiny package support should be proposed later
- whether the next track should be a second Lense slice, a second showcase app,
  or a minimal facade design pass
- what remains explicitly deferred

## Scope

In scope:

- docs/design synthesis only
- comparison of current examples
- candidate graduation list
- rejected/deferred list
- next-track recommendation

Out of scope:

- implementation
- `Igniter.interactive_app` public facade
- UI kit/component system
- SSE/WebSocket
- LLM provider integration
- persistence/history database
- file watcher/scheduler
- code editing or patch generation
- production server/auth/session framework

## Task 1: Application Pattern Synthesis

Owner: `[Agent Application / Codex]`

Acceptance:

- Compare app-local services, command results, snapshots, actions, contracts,
  reports/receipts, and runnable scripts across the current POCs.
- Identify repeated patterns and domain-specific patterns.
- Recommend what should stay app-local for at least one more app.
- Recommend any tiny package support candidates, if truly justified.

## Task 2: Web Pattern Synthesis

Owner: `[Agent Web / Codex]`

Acceptance:

- Compare mounted surfaces, `MountContext` reads, `/events`, forms, feedback
  codes, stable markers, and in-process Rack smoke loops across the current
  POCs.
- Identify repeated markup/marker/action patterns.
- Recommend what should stay local versus what might graduate later.
- Avoid proposing a UI kit or generic dashboard framework unless the evidence
  is overwhelming.

## Research/Expert Input

[Architect Supervisor / Codex] Notes:

- [Igniter Lang Research](../experts/igniter-lang/igniter-lang.md) is accepted
  as research-only context. It is not a feature proposal and should not affect
  this implementation path unless a later explicit track promotes it.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
```

Implementation belongs to a later track.

## Application Pattern Synthesis

[Agent Application / Codex] Current evidence:

| POC | App-Owned Service | Command Result | Snapshot | Action Facts | Contracts | Report/Receipt | Launcher |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `interactive_operator` | `TaskBoard` owns tasks and mutations. | Local `CommandResult` with feedback code, task id, action. | `BoardSnapshot`. | `task_seeded`, `task_created`, refusals, `task_resolved`. | None. | None. | `interactive_web_poc.rb`. |
| `operator_signal_inbox` | `SignalInbox` owns signals and mutations. | Local `CommandResult` with feedback code, signal id, action. | `SignalSnapshot`. | `signal_seeded`, acknowledge/escalate/refusal facts. | None. | None. | `signal_inbox_poc.rb`. |
| `lense` | `CodebaseAnalyzer` and `IssueSessionStore` own scan/session state. | Local `CommandResult` with feedback code, session/finding ids, action. | `CodebaseSnapshot`. | `scan_refreshed`, session/step/note/refusal facts. | `CodebaseHealthContract`. | `LenseAnalysisReceipt`. | `lense_poc.rb`. |

Repeated naturally:

- `app.rb` is the composition seam and package boundary: app-owned services are
  registered there, Rack routes translate local command results, and web mounts
  remain opaque.
- Mutable state lives in app-local services, not web surfaces or package-level
  framework objects.
- Each app defines a small local `CommandResult` with success/failure,
  feedback code, domain ids, and the recorded action fact.
- Each command records deterministic action facts at the mutation boundary.
- Each app exposes a detached snapshot for rendering, `/events`, smoke
  inspection, and cross-surface parity.
- Each app has a stable launcher plus catalog smoke coverage.
- Refusal paths are first-class and smoke-tested, not hidden exceptions.

Still domain-specific:

- Entity vocabulary: task ids, signal ids, finding/session ids, step ids.
- Feedback codes and copy.
- Snapshot fields and counters.
- Action kinds and status labels.
- Web marker names and forms.
- Contract graph shape: only Lense needs a contracts-native analysis graph so
  far.
- Report/receipt shape: Lense proves a report-shaped artifact, but task board
  and signal inbox did not need one.

Keep app-local for at least one more app:

- `CommandResult` classes.
- Snapshot class names and fields.
- Action fact schemas.
- Feedback code registries.
- Report/receipt helper shape.
- Guided session step vocabulary.
- Contracts used inside a showcase app.
- Web marker vocabulary and form naming.

Tiny future package-support candidates, not implementation mandates:

- Guide-level naming convention for app-owned `CommandResult`,
  `Action`, and `Snapshot`.
- A small Rack smoke helper for `rack_env` and form bodies if another POC
  repeats the same boilerplate.
- A report/receipt-shaped plain hash convention, but only after a second
  non-Lense app emits a comparable artifact.
- Route parameter support is already accepted narrowly in `RackHost`; avoid
  turning it into a production server framework.

Do not graduate yet:

- public `Igniter.interactive_app`
- generic command/result/snapshot DSL
- generic session/flow DSL
- UI kit or marker DSL
- live transport/SSE/WebSocket
- persistence/history database
- LLM/provider integration
- code editing or patch generation
- production server/auth/session framework

Next-track recommendation:

- Do not add a second Lense feature slice immediately; Lense is showcase-ready.
- Do not start a minimal facade design pass yet; the repeated shapes are
  guide-level convention, not package API pressure.
- Open a **Chronicle showcase scoping track** as the next pressure test. Scout
  remains attractive for a later product-facing slice, but under the current
  offline/one-process guardrails Chronicle is safer because a local Markdown
  decision store can stress reports, sign-offs, provenance, conflict detection,
  and app-owned records without network, LLM, scheduler, or connector scope.

## Web Pattern Synthesis

[Agent Web / Codex] Current evidence:

| POC | Mounted Surface | Read Shape | Commands | `/events` | Markers | Smoke Loop |
| --- | --- | --- | --- | --- | --- | --- |
| `interactive_operator` | `web/operator_board.rb` renders one task board. | `BoardSnapshot` with tasks, open count, recent events. | create task, resolve task. | text model from the same snapshot. | surface, create form, task id/state, feedback, activity. | in-process Rack requests plus optional server. |
| `operator_signal_inbox` | `web/signal_inbox.rb` renders one signal inbox. | `SignalSnapshot` with signals, open/critical counts, recent events. | acknowledge signal, escalate signal. | text model from the same snapshot. | surface, counters, signal id/status/severity, feedback, action buttons, activity. | in-process Rack requests plus optional server. |
| `lense` | `web/lense_dashboard.rb` renders one dashboard/workbench. | `CodebaseSnapshot` with scan counts, findings, active session, recent events, report data. | refresh scan, start session, done/skip/note step actions. | text model from the same snapshot. | surface, scan/count/finding/session/report, feedback, activity. | in-process Rack requests plus optional server. |

Repeated naturally:

- Each app has one mounted Arbre surface module under local `web/`.
- Each surface reads app state through `MountContext` and an app-owned service,
  usually `assigns[:ctx].service(:name).call.snapshot(...)`.
- Each surface treats the snapshot as the render source for counters, records,
  recent activity, and footer/read-model hints.
- Each app keeps command handling in Rack routes; forms submit to the app, then
  routes translate app-local command results into redirects with feedback query
  params.
- `/events` is not live transport. It is a compact inspection endpoint rendered
  from the same detached snapshot shape as the page.
- Stable `data-` markers are the actual browser/smoke seam: surface marker,
  domain ids/states, feedback code, action buttons, recent activity facts, and
  app-specific report markers when needed.
- The smoke loop is intentionally boring: in-process Rack requests, string
  assertions over stable markers, refusal paths, final state, recent activity,
  `/events` parity, and optional manual `server` mode.

Still domain-specific:

- Layout structure: task board, signal inbox, and Lense workbench have different
  panel shapes and should not be normalized into a generic dashboard.
- Marker names: `data-task-id`, `data-signal-id`, `data-finding-id`,
  `data-session-id`, and `data-report-id` carry domain meaning.
- Feedback copy and feedback codes remain local.
- Form paths and params remain local.
- Counter names and status/severity labels remain local.
- Activity label helpers remain local because they translate domain action
  facts into human-readable copy.
- Lense's report lane and dynamic session route are showcase-specific evidence,
  not enough to justify a generic report component or flow/session UI.

Keep local for at least one more app:

- Arbre component/layout helpers.
- Feedback parser helpers.
- Marker naming helpers or marker DSL.
- Generic form/action builders.
- Generic recent-activity component.
- `/events` serialization helper.
- Browser smoke helper API beyond the existing script-local `rack_env` and form
  body utilities.

Tiny future package-support candidates, not implementation mandates:

- A guide-level "mounted surface checklist" for app-local Web examples:
  one surface, one snapshot, `/events` parity, stable `data-` markers, refusal
  smoke, optional server mode.
- A small test helper for in-process Rack requests may become worthwhile if
  Chronicle repeats the same boilerplate.
- `MountContext` is already the right package seam; future work should improve
  documentation before adding helper APIs.
- Route params in `RackHost` are sufficient for app-local POC routes; avoid
  broad server/router growth.

Do not graduate yet:

- UI kit, component library, layout DSL, marker DSL, or generic dashboard
  framework.
- Live transport/SSE/WebSocket.
- Browser automation framework as part of `igniter-web`.
- Generic report, graph, map, sign-off, or wizard components.
- Public `Igniter.interactive_app` facade.

Next-track recommendation from Web:

- Agree with Application: open **Chronicle showcase scoping** next rather than a
  second Lense slice or facade design pass.
- Chronicle should be scoped as an offline one-process app: local Markdown
  decision store, deterministic proposal/conflict scan, decision/sign-off
  commands, app-owned relationship snapshot, `/events` parity, and a
  receipt-shaped decision record.
- Chronicle is a better immediate Web pressure test than Scout because it can
  stress linked records, conflict evidence, sign-off state, and report output
  without network/search/LLM connectors.
- Chronicle should avoid SVG/canvas/graph frameworks in the first slice; render
  the decision map as inspectable nested HTML with stable markers unless a later
  track proves a real need.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` synthesizes app-local repeated patterns.
2. `[Agent Web / Codex]` synthesizes web/read-model repeated patterns.
3. `[Architect Supervisor / Codex]` decides the next product/app pressure line.

[Agent Application / Codex]
track: `docs/dev/application-showcase-synthesis-track.md`
status: landed
delta: compared `interactive_operator`, `operator_signal_inbox`, and `lense`
  across app-owned services, local command results, snapshots, action facts,
  contracts, reports/receipts, and runnable scripts.
delta: identified repeated app-local conventions: `app.rb` composition seam,
  service-owned mutation, local command results, deterministic action facts,
  detached snapshots, refusal-first commands, and catalog smoke coverage.
delta: identified domain-specific shapes that should stay local: entity ids,
  feedback codes, snapshot fields, action schemas, report shape, guided session
  step vocabulary, contracts usage, and marker/form naming.
delta: recommended no package-level `interactive_app`, command/result/snapshot
  DSL, session DSL, UI kit, live transport, persistence, LLM integration, code
  editing, or production server scope yet.
delta: recommended the next track be Chronicle showcase scoping, not a second
  Lense feature slice or facade design pass; Chronicle is the safest immediate
  offline/one-process pressure test, while Scout remains a later product-facing
  candidate when network/LLM/connectors are allowed.
verify: `git diff --check` passed.
ready: `[Agent Web / Codex]` can synthesize the web/read-model side, then
  `[Architect Supervisor / Codex]` can decide the next product/app pressure
  line.
block: none

[Agent Web / Codex]
track: `docs/dev/application-showcase-synthesis-track.md`
status: landed
delta: compared `interactive_operator`, `operator_signal_inbox`, and `lense`
  across mounted surfaces, `MountContext` reads, `/events`, forms, feedback
  codes, stable markers, and in-process Rack smoke loops.
delta: identified the repeated Web convention: one local Arbre surface, one
  app-owned snapshot render source, Rack form redirects with feedback, `/events`
  snapshot parity, stable `data-` markers, refusal smoke, final-state smoke,
  and optional manual server mode.
delta: kept UI/layout/marker/form/activity helpers local; no UI kit,
  component DSL, marker DSL, live transport, browser automation framework,
  generic report/graph/sign-off component, or public `interactive_app` facade
  should graduate yet.
delta: agreed with the Chronicle showcase scoping recommendation, with a Web
  boundary: offline Markdown decision store, deterministic conflict/sign-off
  flows, nested HTML decision map, `/events` parity, and no SVG/canvas/graph
  framework in the first slice.
verify: `git diff --check` passed.
ready: `[Architect Supervisor / Codex]` can decide the next product/app
  pressure line.
block: none

## Supervisor Acceptance

[Architect Supervisor / Codex] Accepted.

Decision:

- The synthesis is accepted as the current app/web evidence baseline.
- Repeated shapes are real, but they remain guide-level conventions rather than
  package APIs.
- `CommandResult`, snapshots, action facts, feedback codes, Web markers,
  report helpers, and form/layout helpers stay app-local for at least one more
  full app.
- `Igniter.interactive_app`, a generic app DSL, a UI kit, live transport,
  persistence/history database, LLM/provider integration, and production server
  concerns remain deferred.
- Tiny support candidates are acknowledged only as future evidence targets:
  in-process Rack smoke helpers, mounted-surface checklist language, and a
  receipt-shaped plain-data convention after another app proves it.

Next:

- Open [Application Chronicle Scoping Track](./application-chronicle-scoping-track.md)
  as the next bounded product/app pressure line.
- Chronicle is accepted only as scoping/design in the next cycle, not as
  implementation approval.
- The first Chronicle slice must stay offline, one-process, deterministic, and
  app-local-first.
