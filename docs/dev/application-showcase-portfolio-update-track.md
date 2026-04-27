# Application Showcase Portfolio Update Track

This track updates the application showcase portfolio after Scout became the
third reference-quality one-process app.

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
- [Application Scout Showcase Finalization Track](./application-scout-showcase-finalization-track.md)
- [Application Showcase Convention Consolidation Track](./application-showcase-convention-consolidation-track.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting Scout as showcase-ready.

Igniter now has three serious reference apps:

- Lense: codebase analysis, guided remediation session, report evidence.
- Chronicle: decision conflict evidence, sign-off/refusal state, receipt
  evidence.
- Scout: reproducible local-source research, checkpoint choice, citation
  provenance, receipt evidence.

Before opening another implementation track, update the portfolio view and
choose the next strategic line.

## Goal

Decide whether Igniter should next pursue another product app, a tiny support
design track, a documentation consolidation pass, or return to package/core
work.

The result must answer:

- what the three showcase apps collectively prove
- what repeated enough to become stronger convention
- what still must remain app-local
- whether any tiny support candidate is now justified for design
- whether Dispatch, Aria, or another app should be scoped next
- whether Embed/Contracts/Core should become the next active pressure line
- what remains explicitly deferred

## Scope

In scope:

- docs/design synthesis only
- comparison of Lense, Chronicle, and Scout
- updated candidate graduation list
- rejected/deferred list
- next-track recommendation

Out of scope:

- implementation
- public `Igniter.interactive_app` facade
- UI kit/component system
- live transport/SSE/WebSocket
- LLM/provider integration
- persistence/history database
- scheduler/file watcher
- auth/users/teams/production server framework
- changing existing showcase behavior

## Task 1: App Portfolio Update

Owner: `[Agent Application / Codex]`

Acceptance:

- Compare Lense, Chronicle, and Scout across services, deterministic contracts,
  command results, snapshots, action facts, sessions, reports/receipts,
  fixture/workdir boundaries, README/manual usage, and catalog smoke.
- Identify what is stronger convention now that three apps exist.
- Identify what still stays app-local.
- Recommend whether a tiny support-design track is justified.
- Recommend the next product/package pressure line.

## Task 2: Web Portfolio Update

Owner: `[Agent Web / Codex]`

Acceptance:

- Compare Lense, Chronicle, and Scout across mounted surfaces, `MountContext`
  reads, Rack command routes, feedback redirects, stable markers, `/events`,
  report/receipt endpoints, manual server mode, and smoke loops.
- Identify what is stronger Web convention now that three apps exist.
- Identify what still stays Web-local.
- Recommend whether a tiny Web/test helper design track is justified.
- Recommend the next product/package pressure line.

## Supervisor Guardrails

[Architect Supervisor / Codex] Notes:

- Three apps are enough to discuss support design, but not enough to assume a
  broad framework.
- Prefer the smallest useful next step. The likely candidates are:
  a tiny smoke-helper design track, a receipt/report convention design track,
  Dispatch/Aria scoping, or returning attention to Embed/Contracts/Core.
- Do not promote `interactive_app`, UI kit, marker DSL, live runtime,
  persistence, or LLM/connectors by implication.
- Keep the final recommendation compact and actionable.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
```

Implementation belongs to a later track.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` updates app-layer portfolio evidence across
   Lense, Chronicle, and Scout.
2. `[Agent Web / Codex]` updates Web/read-model evidence across Lense,
   Chronicle, and Scout.
3. `[Architect Supervisor / Codex]` chooses the next strategic line.

## App Portfolio Evidence

[Agent Application / Codex] App-layer comparison:

| Axis | Lense | Chronicle | Scout |
| --- | --- | --- | --- |
| Product pressure | Local Ruby codebase intelligence and guided remediation. | Proposal-vs-decision conflict review with sign-off/refusal state. | Reproducible local-source research with checkpoint and citations. |
| Composition boundary | `examples/application/lense/app.rb` wires scan, sessions, report, Web, and Rack routes. | `examples/application/chronicle/app.rb` wires fixture stores, scanner, sessions, receipt, Web, and Rack routes. | `examples/application/scout/app.rb` wires source library, extractor, sessions, receipt, Web, and Rack routes. |
| App services | `CodebaseAnalyzer`, `IssueSessionStore`. | `DecisionStore`, `ProposalStore`, `MarkdownRecordParser`, `DecisionConflictScanner`, `DecisionSessionStore`. | `SourceLibrary`, `SourceParser`, `FindingExtractor`, `ResearchSessionStore`. |
| Deterministic contract | `CodebaseHealthContract` computes scan facts, health, findings, report metadata. | `DecisionReviewContract` computes conflicts, sign-off readiness, receipt payload. | `ResearchSynthesisContract` computes claims, findings, contradictions, checkpoint readiness, synthesis payload. |
| Command result | `IssueSessionStore::CommandResult` stays local to finding-session actions. | `DecisionSessionStore::CommandResult` stays local to proposal/conflict/sign-off actions. | `ResearchSessionStore::CommandResult` stays local to topic/source/checkpoint actions. |
| Snapshot/read model | `CodebaseSnapshot` is app-owned and detached from mutable store state. | `ChronicleSnapshot` is app-owned and detached from mutable store state. | `ScoutSnapshot` is app-owned and detached from mutable store state. |
| Action facts | Guided actions record done, skip, note, and refusal facts. | Review actions record scan, acknowledgement, sign-off, refusal, receipt, and refusal facts. | Research actions record session, source, extraction, contradiction, checkpoint, receipt, and refusal facts. |
| Receipt/report | `LenseAnalysisReceipt` is an app-local Markdown/hash evidence artifact. | `DecisionReceipt` is an app-local Markdown/hash evidence artifact. | `ResearchReceipt` is an app-local Markdown/hash evidence artifact. |
| Fixture/workdir boundary | Reads a local sample project and proves no scanned-project mutation. | Reads decision/proposal fixtures and writes sessions/actions/receipts only to workdir. | Reads source fixtures and writes sessions/actions/receipts only to workdir. |
| Discoverability | README documents purpose, smoke/manual commands, stable markers, and POC boundaries. | README documents purpose, smoke/manual commands, fixture/runtime boundaries, stable markers, and POC boundaries. | README documents purpose, workflow, smoke/manual commands, fixture/runtime boundaries, stable markers, and POC boundaries. |
| Catalog smoke | `application/lense_poc` proves command loop, report, no mutation, Web markers. | `application/chronicle_poc` proves conflict loop, receipt, fixture no-mutation, Web markers. | `application/scout_poc` proves research loop, receipt, fixture no-mutation, Web markers. |

What is now stronger convention:

- `app.rb` is the visible composition boundary for app services, mounted Web,
  and small Rack command routes.
- Each serious showcase owns one deterministic contracts-native graph for the
  core analysis/readiness computation.
- Mutable state belongs in app-local stores; readers consume detached snapshots
  rather than mutable service internals.
- Success and refusal paths return small app-local command results and record
  explicit action facts.
- A useful workflow ends with one app-local evidence artifact: report or
  receipt, with validity, provenance, action facts, deferred scope, and
  generated metadata.
- Smoke scripts should prove happy path, refusal path, final state, receipt or
  report evidence, `/events` parity with Web, and mutation boundaries.
- README/manual usage is part of showcase quality, not optional decoration.

What should still stay app-local:

- `CommandResult`, snapshot class names, payload fields, feedback codes, and
  action fact vocabularies.
- Parser formats, analysis thresholds, contradiction/conflict/finding rules,
  checkpoint/readiness semantics, and receipt/report schemas.
- Runtime workdir layouts and fixture pack formats.
- Domain command names and entity ids such as findings, decisions, proposals,
  sources, sessions, checkpoints, and sign-offs.
- Web marker names, endpoint labels, and copy until `[Agent Web / Codex]`
  separately proves a narrow helper candidate.

Tiny support-design recommendation:

- A tiny design track is now justified, but only at guide/design level first:
  `Application Evidence Artifact Convention`.
- The candidate should describe receipt/report checklist vocabulary, smoke
  evidence expectations, and mutation-boundary proof patterns.
- It should not introduce a shared receipt class, command result type, snapshot
  type, route DSL, `interactive_app` facade, persistence layer, or UI kit.
- If `[Agent Web / Codex]` independently recommends a smoke helper, merge the
  two into one narrow "showcase evidence helper design" track before any code.

Next line recommendation:

- Recommended immediate next track: tiny support-design synthesis for evidence
  artifacts and smoke proof shape, because three apps now repeat enough
  mechanics to make future showcases cheaper without forcing framework scope.
- Recommended next product app after that: Dispatch over Aria. Dispatch would
  pressure event intake, assignment/escalation decisions, and operational
  handoff receipts while staying offline and fixture-backed.
- Recommended package/core fallback if product work pauses: return to
  Embed/Contracts pressure before Cluster/Mesh work, because current showcase
  evidence is app-local and does not yet need distributed runtime machinery.
- Explicitly deferred: public `Igniter.interactive_app`, generic workflow DSL,
  shared command result/snapshot classes, LLM/connectors, persistence/history
  database, scheduler/file watcher, auth, production server, live transport,
  and cluster placement.

[Agent Application / Codex]
track: `docs/dev/application-showcase-portfolio-update-track.md`
status: landed
delta: added app-layer portfolio comparison for Lense, Chronicle, and Scout
  across services, deterministic contracts, command results, snapshots, action
  facts, reports/receipts, fixture/workdir boundaries, README/manual usage, and
  catalog smoke evidence.
delta: identified stronger conventions around `app.rb`, app-owned services,
  deterministic contracts, detached snapshots, command-result refusals, action
  facts, evidence artifacts, smoke proof, and README/manual discoverability.
delta: kept domain payloads, feedback/action vocabulary, parser/rule schemas,
  receipt/report schemas, fixture/workdir layouts, and route/marker labels
  app-local.
delta: recommended a tiny guide/design-level evidence artifact and smoke proof
  synthesis track before any new helper/API code; Dispatch is the preferred
  next product app after that, while Embed/Contracts is the preferred package
  fallback.
verify: `git diff --check` passed.
ready: `[Agent Web / Codex]` can add Web/read-model portfolio evidence; then
  `[Architect Supervisor / Codex]` can choose the next strategic line.
block: none

## Web Portfolio Evidence

[Agent Web / Codex] Web/read-model comparison:

| Axis | Lense | Chronicle | Scout |
| --- | --- | --- | --- |
| Mounted surface | `web/lense_dashboard.rb` mounts `:lense_dashboard` at `/`. | `web/decision_compass.rb` mounts `:decision_compass` at `/`. | `web/research_workspace.rb` mounts `:research_workspace` at `/`. |
| Snapshot read | Reads one `CodebaseSnapshot` through `MountContext`. | Reads one `ChronicleSnapshot` through `MountContext`. | Reads one `ScoutSnapshot` through `MountContext`. |
| Rendered state | Scan counts, findings, guided issue session, recent activity, report state. | Proposal/session state, conflicts, related decisions, sign-offs/refusals, recent activity, receipt state. | Topic/session state, source pack, findings, provenance citations, contradictions, checkpoint, recent activity, receipt state. |
| Rack commands | Refresh scan, start session, mark step done/skip, add note. | Scan proposal, acknowledge conflict, sign off, refuse sign-off, emit receipt. | Start session, extract findings, add local source, choose checkpoint, emit receipt. |
| Feedback | Query-string redirect feedback with app-local codes and `data-feedback-code`. | Query-string redirect feedback with app-local codes and `data-feedback-code`. | Query-string redirect feedback with app-local codes and `data-feedback-code`. |
| Inspection endpoints | `/events` mirrors the snapshot; `/report` exposes app-owned report data. | `/events` mirrors the snapshot; `/receipt` exposes emitted Markdown receipt. | `/events` mirrors the snapshot; `/receipt` exposes emitted Markdown receipt. |
| Stable markers | Surface, scan/count/finding/evidence/session/report/action/activity markers. | Surface, proposal/session/conflict/evidence/relationship/sign-off/receipt/action/activity markers. | Surface, topic/session/source/citation/provenance/finding/contradiction/checkpoint/receipt/action/activity markers. |
| Smoke loop | In-process Rack smoke covers initial render, redirects, refusal feedback, final state, `/events` parity, and report endpoint. | In-process Rack smoke covers initial render, redirects, refusals, receipt-not-ready, final state, `/events` parity, `/receipt`, and fixture no-mutation. | In-process Rack smoke covers initial render, redirects, refusals, receipt-not-ready, invalid checkpoint, final state, `/events` parity, `/receipt`, and fixture no-mutation. |
| Manual review | `server` mode opens the dashboard/workbench. | `server` mode opens the decision compass. | `server` mode opens the research workspace. |

What is now stronger Web convention:

- One app-local Arbre surface is the right first showcase slice; each surface
  keeps presentation helpers, copy, styles, and marker vocabulary local.
- Web reads exactly one app-owned detached snapshot near the top of render and
  treats app services, contracts, reports, receipts, and persistence as owned
  by the app layer.
- Rack command routes belong in `app.rb`; they translate app-local command
  results into redirects or text responses and keep mounted surfaces opaque.
- Query-string feedback plus `data-feedback-code` is the current success and
  refusal inspection seam.
- `/events` must render from the same snapshot shape as the mounted surface.
  `/report` and `/receipt` should expose app-owned artifacts only when the app
  already owns stable report/receipt emission.
- Stable `data-` markers are now strong smoke/browser evidence, but should
  remain explicit and domain-named instead of becoming a marker DSL.
- Manual `server` mode is part of showcase readiness, but remains example
  scaffolding rather than production server behavior.

What should still stay Web-local:

- Surface names, route labels, marker attribute names, `data-action` values,
  feedback copy, CSS direction, panel layout, and grouping choices.
- Whether evidence is grouped as findings, conflicts, source citations,
  sign-off lanes, guided sessions, report panels, or receipt lanes.
- Report/receipt endpoint naming and display choices.
- Smoke output labels and catalog fragments.
- Any browser automation choice; current smoke should stay in-process Rack
  unless a later track explicitly needs browser tooling.

Tiny Web/test support recommendation:

- A tiny design track is justified, but it should be a **showcase evidence
  helper design** track that merges Application's evidence-artifact concern
  with Web's smoke-helper concern.
- The design can specify checklist vocabulary for mounted surface readiness,
  `/events` parity, feedback markers, action markers, receipt/report endpoint
  checks, manual server review, and mutation-boundary proof.
- A future helper may be script-local first: `rack_env`, `form_body`,
  redirect-following, response status assertions, marker checks, and endpoint
  parity checks.
- Do not create runtime API, route DSL, marker DSL, UI kit, screen compiler,
  generic report/receipt viewer, `interactive_app`, live transport, or
  persistence from this evidence.

Next line recommendation from Web:

- Agree with Application: open one narrow design synthesis for showcase
  evidence and smoke proof before another implementation track.
- After that, prefer Dispatch as the next product app if it can stay offline
  and fixture-backed: event intake, assignment/escalation decisions, operator
  handoff, and receipt evidence would pressure Web differently than Lense,
  Chronicle, and Scout.
- If product pressure pauses, return to Embed/Contracts before Cluster/Mesh;
  the current Web evidence still favors app-local snapshots and one-process
  mounted surfaces over distributed runtime work.
- Keep Aria, LLM/connectors, live streams, scheduler/file watcher,
  persistence/history DB, auth, production server, UI kit, and public
  `interactive_app` explicitly deferred.

[Agent Web / Codex]
track: `docs/dev/application-showcase-portfolio-update-track.md`
status: landed
delta: added Web/read-model portfolio comparison for Lense, Chronicle, and
  Scout across mounted surfaces, `MountContext` reads, Rack command routes,
  feedback redirects, stable markers, `/events`, report/receipt endpoints,
  manual server mode, and smoke loops.
delta: identified stronger Web conventions around one app-local Arbre surface,
  app-owned snapshot rendering, app-owned routes, query-string feedback,
  `/events` parity, stable domain markers, and manual server review.
delta: kept marker names, route labels, feedback copy, layout, endpoint names,
  smoke labels, and browser automation choices Web-local.
delta: recommended one narrow showcase evidence/smoke proof design track before
  helper/API code; Dispatch is the preferred next product app if product
  pressure resumes, while Embed/Contracts is the package fallback.
verify: `git diff --check` passed.
ready: `[Architect Supervisor / Codex]` can choose the next strategic line.
block: none
