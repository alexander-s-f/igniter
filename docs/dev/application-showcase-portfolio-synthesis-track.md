# Application Showcase Portfolio Synthesis Track

This track synthesizes the first two serious showcase apps, Lense and Chronicle,
before adding more product surface or graduating package APIs.

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
- [Application Lense Showcase Finalization Track](./application-lense-showcase-finalization-track.md)
- [Application Chronicle Showcase Finalization Track](./application-chronicle-showcase-finalization-track.md)
- [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting Chronicle as
showcase-ready.

Igniter now has two reference-quality one-process apps:

- Lense: codebase analysis, guided issue session, contract-backed report.
- Chronicle: decision evidence, sign-off/refusal flow, contract-backed receipt.

Before opening another implementation track, synthesize what this portfolio
proves.

## Goal

Decide the next serious product/app pressure line from evidence.

The result must answer:

- what repeated across Lense and Chronicle at the app layer
- what repeated across their Web surfaces
- what still must stay app-local
- whether any tiny package-support candidate is now justified
- whether the next track should be another showcase app, a support API design
  pass, or documentation consolidation
- what remains explicitly deferred

## Scope

In scope:

- docs/design synthesis only
- comparison of Lense and Chronicle, with older POCs as background context
- candidate graduation list
- rejected/deferred list
- next-track recommendation

Out of scope:

- implementation
- public `Igniter.interactive_app` facade
- UI kit/component system
- live transport/SSE/WebSocket
- LLM provider integration
- persistence/history database
- scheduler/file watcher
- auth/users/teams/production server framework
- changing Lense or Chronicle behavior

## Task 1: Showcase Application Synthesis

Owner: `[Agent Application / Codex]`

Acceptance:

- Compare Lense and Chronicle across services, contracts, command results,
  snapshots, action facts, sessions, reports/receipts, fixture/workdir
  boundaries, README/manual usage, and catalog smoke.
- Identify what is now repeated strongly enough to document as convention.
- Identify what still stays app-local.
- Recommend whether any tiny package support candidate deserves a design track.
- Recommend the next product/app pressure line.

## Task 2: Showcase Web Synthesis

Owner: `[Agent Web / Codex]`

Acceptance:

- Compare Lense and Chronicle across mounted surfaces, `MountContext` reads,
  Rack route commands, feedback redirects, stable markers, `/events`, report or
  receipt endpoints, manual server mode, and smoke loops.
- Identify what is now repeated strongly enough to document as convention.
- Identify what still stays Web-local.
- Recommend whether any small web/test helper deserves a design track.
- Recommend the next product/app pressure line from the Web side.

## Supervisor Guardrails

[Architect Supervisor / Codex] Notes:

- The default answer remains "document convention, do not graduate API" unless
  the evidence is strong.
- Do not use two apps as an excuse to create a broad app framework.
- Tiny support means tiny: smoke helpers, checklist language, or a narrow
  existing seam. No DSL, UI kit, server framework, or live runtime.
- Scout, Dispatch, and future reference apps remain possible, but the next step
  should be chosen by evidence rather than excitement.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
```

Implementation belongs to a later track.

## Showcase Application Synthesis

[Agent Application / Codex] Current evidence:

| App | Services | Contract Graph | Commands | Snapshot | Report/Receipt | Data Boundary | Smoke/Docs |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Lense | `CodebaseAnalyzer` reads a target Ruby tree; `IssueSessionStore` owns guided issue sessions and actions. | `CodebaseHealthContract` computes counts, prioritized findings, health score, and report metadata. | Refresh scan, start session, record step actions. | `CodebaseSnapshot` exposes scan counts, findings, active session, actions, and recent events. | `LenseAnalysisReceipt` captures scan identity, findings, evidence refs, actions, skipped items, validity, and metadata. | Reads an explicit target root and proves no scanned-project mutation. | README, manual server command, catalog smoke, report endpoint markers. |
| Chronicle | `DecisionStore`, `ProposalStore`, `DecisionConflictScanner`, and `DecisionSessionStore` own fixtures, conflict scan, sessions, sign-offs, refusals, actions, and receipts. | `DecisionReviewContract` computes conflict evidence, required sign-offs, readiness, and receipt payload. | Scan proposal, acknowledge conflict, sign off, refuse sign-off, emit receipt. | `ChronicleSnapshot` exposes proposal/session state, conflicts, sign-offs, receipt id, actions, and recent events. | `DecisionReceipt` captures proposal, conflicts, sign-off/refusal state, provenance, actions, deferred items, validity, and metadata. | Reads repo fixtures and writes only to an explicit runtime workdir; smoke proves fixture no-mutation. | README, manual server command, catalog smoke, `/events`, `/receipt`, fixture no-mutation markers. |

Repeated strongly enough to document as convention:

- A showcase app has an `app.rb` composition boundary, app-local services,
  one contract-backed analysis graph, one detached snapshot, and one
  receipt/report artifact.
- Domain services own mutation and command state; Web and Rack routes translate
  command results but do not own analysis state.
- Contracts are deterministic and offline in the first slice. They compute
  analysis/readiness/report payloads but do not write files or call external
  systems.
- Commands return app-local command results with feedback codes, domain ids,
  receipt/session ids when relevant, and the recorded action fact.
- Action facts are part of the app's evidence trail, not just UI activity.
- Receipts include provenance, evidence refs, action ledger slices, deferred
  scope, validity, and caller metadata.
- Every showcase documents smoke usage and optional manual server usage in a
  local README.
- Smoke must prove the core user workflow, a refusal path, final read model,
  receipt/report evidence, and no unintended mutation.

Still app-local:

- Analyzer/parser details, fixture schemas, thresholds, conflict rules, and
  guided step/sign-off vocabulary.
- Command result class names and feedback code registries.
- Snapshot fields and status names.
- Action kinds and ledger schemas.
- Receipt/report class names, Markdown/hash shape, validity rules, and deferred
  item vocabulary.
- Runtime workdir layout and fixture seeding strategy.
- Catalog marker names and smoke output labels.

Tiny package-support candidates:

- A **documentation-only showcase checklist** is justified now: app boundary,
  deterministic contract graph, app-owned snapshot, command result/refusal,
  action facts, receipt/report, README commands, manual server mode, and
  mutation boundary proof.
- A **receipt-shaped report convention design note** is justified, but should
  remain a convention first. Lense and Chronicle both emit receipts, yet their
  domains still need different payloads and validity semantics.
- A **smoke helper design investigation** may be useful after Web synthesis
  because Lense and Chronicle both repeat rack env/form body/catalog marker
  boilerplate. This should be a narrow test helper discussion, not a runtime
  framework.

Do not graduate yet:

- public `Igniter.interactive_app`
- generic app/workflow/session DSL
- shared `CommandResult`, snapshot, action ledger, receipt, parser, or report
  classes
- generic persistence/workdir API
- live transport/SSE/WebSocket
- UI kit/component system
- LLM/provider integration
- scheduler/file watcher
- auth/users/teams/production server framework

Next-track recommendation:

- Open a **showcase convention consolidation track** before another app. The
  goal should be docs/checklists and possibly a tiny design note for
  receipt-shaped reports and smoke helpers, not implementation.
- After consolidation, Scout is still the strongest next product pressure line
  if the team is ready to introduce source/provenance pressure carefully.
  Dispatch should wait until live monitoring, scheduler, and stronger approval
  semantics are explicitly in scope.
- If the team wants to avoid support-design work and keep product pressure
  first, choose Scout only as an offline/local-source slice; do not add network,
  LLM, connectors, SSE, or persistence in its first pass.

## Showcase Web Synthesis

[Agent Web / Codex] Current evidence:

| App | Mounted Surface | Snapshot Read | Commands | Feedback | Inspection Endpoints | Stable Markers | Smoke Loop |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Lense | `web/lense_dashboard.rb` mounts `:lense_dashboard` at `/` through `Igniter::Web.mount`. | Reads one `CodebaseSnapshot` through `MountContext` and renders scan counts, findings, active session, recent events, and report state. | Refresh scan, start session, record step done/skip/note. | Query-string redirect feedback for success and refusal paths. | `/events` mirrors snapshot text; `/report` exposes receipt-shaped report data. | Surface, scan/count/finding/evidence/session/report/feedback/action/activity markers. | In-process Rack requests cover initial render, command redirects, refusal feedback, final state, `/events` parity, and report endpoint. |
| Chronicle | `web/decision_compass.rb` mounts `:decision_compass` at `/` through `Igniter::Web.mount`. | Reads one `ChronicleSnapshot` through `MountContext` and renders proposal/session state, conflicts, linked decisions, sign-offs/refusals, recent events, and receipt state. | Scan proposal, acknowledge conflict, sign off, refuse sign-off, emit receipt. | Query-string redirect feedback via app-local command result mapping. | `/events` mirrors snapshot text; `/receipt` exposes emitted Markdown receipt. | Surface, proposal/session/conflict/evidence/relationship/sign-off/receipt/feedback/action/activity markers. | In-process Rack requests cover initial render, command redirects, refusal feedback, receipt-not-ready, final state, `/events` parity, `/receipt`, and fixture no-mutation. |

Repeated strongly enough to document as Web convention:

- One app-local mounted surface is enough for the first serious slice; both
  apps keep Arbre helpers, copy, styles, and marker names inside `web/`.
- Web reads through `MountContext` and an app-owned snapshot; it does not own
  command state, analysis state, report payloads, or persistence.
- Rack routes stay in `app.rb`, translate app-local commands to redirects/text,
  and keep the mounted surface as an opaque Web object.
- Query-string feedback plus `data-feedback-code` is the current stable
  refusal/success inspection seam.
- `/events` must use the same snapshot shape as the surface. Report/receipt
  endpoints can expose app-owned artifacts, but their payload shapes stay local.
- Stable `data-` markers are the smoke/browser contract for now. They should be
  boring, explicit, and domain-named rather than hidden behind a marker DSL.
- Manual `server` mode is now a showcase convention, but it remains example
  scaffolding, not production server behavior.

Still Web-local:

- Surface names, marker attribute names, action names, feedback copy, CSS
  direction, panel layout, and endpoint labels.
- Whether report/receipt inspection is rendered as a panel, link, or endpoint.
- Domain grouping choices such as findings versus conflicts, guided sessions
  versus sign-off lanes, and report versus receipt blocks.
- Smoke output labels and catalog fragments.

Tiny web/test support candidates:

- A **docs-only Web surface checklist** is justified now: mounted surface,
  `MountContext` snapshot read, feedback markers, action markers, recent
  activity markers, `/events` parity, report/receipt endpoint, manual server
  mode, and catalog fragments.
- A **script-local Rack smoke helper design investigation** is justified:
  Lense and Chronicle repeat `rack_env`, `form_body`, redirect-following, status
  assertions, and marker checks. Keep this as a test/example helper discussion,
  not runtime API.
- A **manual review checklist** is useful: server command, initial surface
  marker, one success command, one refusal command, `/events`, report/receipt
  endpoint, and no fixture mutation.

Do not graduate yet:

- generic UI kit, component library, layout DSL, marker DSL, or screen compiler
- public `Igniter.interactive_app`
- live transport/SSE/WebSocket
- generic report/receipt viewer
- generic workflow/wizard controller
- browser automation requirement for smoke
- production server/auth/session framework

Next-track recommendation from Web:

- Agree with Application: open **showcase convention consolidation** first.
  Make it documentation/checklist-oriented and optionally include a narrow
  smoke-helper design note.
- Do not open a package API implementation track yet. `MountContext` plus
  app-owned snapshot rendering is the reusable seam; everything above it still
  carries useful domain vocabulary.
- If product pressure wins over consolidation, Scout is the best next app only
  as an offline/local-source slice. Web should render source/provenance evidence
  as nested HTML with markers, not graph/canvas/live transport.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` synthesizes the app-layer evidence across Lense
   and Chronicle.
2. `[Agent Web / Codex]` synthesizes the Web/read-model evidence across Lense
   and Chronicle.
3. `[Architect Supervisor / Codex]` chooses the next product/app or support API
   pressure line.

[Agent Application / Codex]
track: `docs/dev/application-showcase-portfolio-synthesis-track.md`
status: landed
delta: compared Lense and Chronicle across app-owned services, deterministic
  contracts, command results, snapshots, action facts, sessions,
  reports/receipts, file/workdir boundaries, README/manual usage, and catalog
  smoke.
delta: identified repeated showcase conventions: `app.rb` composition boundary,
  app-owned service state, offline contract-backed analysis, local command
  results, action facts, detached snapshots, receipt-shaped evidence, README
  commands, manual server mode, and mutation-boundary smoke proof.
delta: kept analyzers/parsers, fixture schemas, thresholds, conflict rules,
  feedback codes, snapshot fields, action schemas, receipt payloads, workdir
  layout, and smoke marker labels app-local.
delta: recommended documentation-only showcase convention consolidation plus
  narrow design notes for receipt-shaped reports and smoke helpers before any
  package API graduation.
delta: recommended Scout as the next product pressure line only after
  consolidation and only as an offline/local-source first slice; Dispatch waits
  for scheduler/live-monitoring/approval scope.
verify: `git diff --check` passed.
ready: `[Agent Web / Codex]` can synthesize Web/read-model evidence, then
  `[Architect Supervisor / Codex]` can choose the next pressure line.
block: none

[Agent Web / Codex]
track: `docs/dev/application-showcase-portfolio-synthesis-track.md`
status: landed
delta: compared Lense and Chronicle across mounted Arbre surfaces,
  `MountContext` snapshot reads, Rack command routes, feedback redirects,
  stable markers, `/events`, report/receipt endpoints, manual server mode, and
  in-process Rack smoke loops.
delta: identified Web conventions strong enough to document: one app-local
  mounted surface, app-owned snapshot rendering, route-owned command mapping,
  query-string feedback markers, `/events` parity, report/receipt inspection,
  stable domain markers, and manual `server` mode.
delta: kept surface names, marker attributes, action names, feedback copy,
  layout, report/receipt presentation, smoke labels, UI kit, marker DSL,
  live transport, and `interactive_app` Web behavior deferred/app-local.
delta: recommended a docs-only Web checklist and narrow Rack smoke-helper
  design investigation before package API work; if product pressure comes next,
  Scout should be offline/local-source with nested HTML provenance evidence.
verify: `git diff --check` passed.
ready: `[Architect Supervisor / Codex]` can choose the next product/app or
  support-design pressure line.
block: none

## Supervisor Acceptance

[Architect Supervisor / Codex] Accepted.

Decision:

- Portfolio synthesis is accepted.
- Lense and Chronicle prove a useful showcase-app convention, but not a public
  `interactive_app` facade or package-level app framework.
- The next step is documentation/checklist consolidation, not another
  implementation track and not package API graduation.
- Tiny candidates are accepted only as design/doc topics:
  showcase checklist, Web surface checklist, receipt-shaped report convention,
  manual review checklist, and narrow Rack smoke-helper investigation.
- Scout remains the likely next product pressure line after consolidation, but
  only as an offline/local-source first slice. Dispatch remains deferred until
  scheduler/live monitoring/approval semantics are explicitly in scope.

Rejected/deferred:

- public `Igniter.interactive_app`
- generic app/workflow/session DSL
- shared `CommandResult`, snapshot, action ledger, receipt/report classes
- UI kit, marker DSL, generic report viewer, graph/canvas renderer
- live transport/SSE/WebSocket
- persistence/history database
- LLM/provider integration, connectors, scheduler/file watcher
- auth/users/teams/production server framework

Next:

- Open [Application Showcase Convention Consolidation Track](./application-showcase-convention-consolidation-track.md).
