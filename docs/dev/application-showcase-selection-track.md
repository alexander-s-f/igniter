# Application Showcase Selection Track

This track chooses the next practical application pressure test after capsule
transfer and ledger-backed activation reached finalized-for-now status.

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
- [Application Proposals](../experts/application-proposals.md)
- [Igniter Strategic Report](../experts/igniter-strategic-report.md)
- [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting capsule activation guide
consolidation.

Capsule transfer should pause as finalized-for-now. The next value is a real
one-process application POC that pressures application structure, web
interaction, receipts, and developer experience.

## Goal

Select the first showcase/reference app and define a compact POC slice.

The result must decide:

- which proposal to build first
- why it is the best next pressure test
- what the one-process MVP includes
- which package boundaries it pressures
- what is intentionally deferred
- what runnable acceptance will prove

## Candidate Default

[Architect Supervisor / Codex] Default recommendation is **Lense** from
[Application Proposals](../experts/application-proposals.md).

Reason:

- developer audience matches Igniter early adopters
- local code analysis can run in one process without external services
- contracts-as-analysis-graph is easy to demonstrate
- dashboard + guided session pressures application/web structure
- receipt-like report output connects back to the capsule/receipt doctrine

## Scope

In scope:

- docs/design selection only
- first POC slice definition
- application-local structure recommendation
- web surface expectation
- receipt/report expectation
- verification criteria

Out of scope:

- implementation
- `Igniter.interactive_app` public facade
- SSE/WebSocket
- LLM provider integration
- durable distributed sessions
- capsule marketplace
- real production deployment

## Task 1: Application POC Slice

Owner: `[Agent Application / Codex]`

Acceptance:

- Compare Lense, Scout, Dispatch, Chronicle, and Aria for the next POC.
- Recommend one app and one smallest useful scenario.
- Define app-local directories/services/contracts/reports needed for the POC.
- Define what can run without network, LLM, database, or external services.
- Define expected receipt/report output.

## Task 2: Web Surface Slice

Owner: `[Agent Web / Codex]`

Acceptance:

- Define the minimum useful web surface for the recommended app.
- Reuse current app/web POC conventions instead of introducing a new facade.
- Define interactions and read model shape.
- Keep SSE/WebSocket deferred unless the POC cannot work without it.
- Define browser/smoke acceptance without requiring production server features.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
```

Implementation belongs to the next track.

## Application Selection

[Agent Application / Codex] Recommendation: build **Lense** first.

Comparison:

| Candidate | Fit For First One-Process POC | Main Risk |
| --- | --- | --- |
| Lense | Best fit: developer audience, local files, contracts-as-analysis-graph, deterministic reports, one-command launch. | Must avoid promising LLM/code-edit automation in the first slice. |
| Scout | Strong second: provenance and long-lived sessions are excellent, but useful research collection tends to want network/search/LLM connectors. | Offline-only POC would feel less real than Lense. |
| Dispatch | High drama and clear receipts, but incident detection wants timers, integrations, and mutating remediation semantics. | Pulls toward proactive/background infrastructure too early. |
| Chronicle | Good architecture-audience fit and local Markdown store, but less directly shows contracts over live code structure. | Could become document workflow before stressing app runtime. |
| Aria | Strong enterprise receipt story, but hiring workflow is domain-heavy and compliance-sensitive. | Needs careful UX/content work before it pressures core Igniter. |

Decision:

- Select **Lense — Codebase Intelligence Agent**.
- First useful scenario: **local codebase health scan plus guided issue
  session**.
- The POC should run as one process with one command against a local project
  root, using no network, no LLM provider, no database, no background scheduler,
  and no external services.

Smallest useful scenario:

1. User launches the app against a local target root.
2. App scans Ruby files under explicit include paths.
3. App builds deterministic metrics: file count, line count, simple complexity
   signals, large files, TODO/FIXME hotspots, repeated line fingerprints, and
   app-local architectural findings.
4. App publishes a detached `CodebaseSnapshot` for web/read endpoints.
5. User starts a guided session for one top issue.
6. User can mark a step as done, skip it, or add a note.
7. App emits a `LenseAnalysisReceipt`/report with scan identity, counts,
   findings, issue-session actions, skipped work, and deterministic evidence
   refs.

Recommended app-local structure:

```text
examples/application/lense/
  app.rb
  services/
    codebase_analyzer.rb
    issue_session_store.rb
    lense_reporter.rb
  contracts/
    codebase_health_contract.rb
  reports/
    lense_analysis_receipt.rb
  web/
    lense_dashboard.rb
```

Service ownership:

- `CodebaseAnalyzer` owns filesystem reads under the explicit target root and
  returns analysis facts, never mutating files.
- `IssueSessionStore` owns app-local guided-session state, command results,
  action facts, and the detached read snapshot.
- `LenseReporter` converts scan/session facts into JSON/Markdown-ready report
  data.

Contract/report ownership:

- `codebase_health_contract` should be the first contracts-native pressure
  point: inputs are scan facts and thresholds; outputs are health score,
  prioritized findings, and report metadata.
- `LenseAnalysisReceipt` is a report artifact, not a transfer/activation
  receipt. It should echo the receipt doctrine: explicit identity, counts,
  evidence refs, actions, skipped/deferred items, and generated-at timestamp.

Runs without external dependencies:

- No network/search.
- No LLM provider; narrative text is deterministic template output.
- No database; state stays in memory for the POC.
- No background job or scheduler; "weekly report" is represented by a manual
  `/events`/snapshot refresh or command-run scan.
- No code modification; suggested refactoring steps are guidance only.

Package boundaries pressured:

- `igniter-application`: app composition seam, services, command results,
  snapshots, contracts invocation, report/receipt-shaped output.
- `igniter-contracts` and `igniter-extensions`: deterministic analysis graph,
  collection/composition, diagnostics/provenance-friendly report data.
- `igniter-web`: one dashboard plus one guided session surface consuming an
  app-owned snapshot.

Deferred:

- public `Igniter.interactive_app` facade
- LLM provider integration
- persistent history/trends database
- code editing or patch generation
- file watcher, cron, background scheduler, SSE/WebSocket
- multi-repo support
- CI webhook
- production server/auth/session framework

Runnable acceptance for the implementation track:

- `ruby examples/application/lense_poc.rb` prints stable markers for scanned
  files, findings, top issue, session state, actions, report validity, evidence
  refs, and no mutations.
- Catalog smoke includes the Lense example.
- If a Rack surface is added, smoke proves dashboard render, start-session
  command, note/skip/done command, `/events` snapshot parity, and final report
  output.
- `git diff --check` and focused RuboCop pass.

## Web Surface Selection

[Agent Web / Codex] Recommendation: build one **Lense dashboard/workbench**
surface first, not a generic interactive app facade.

The Web slice should reuse the current app/web POC convention:

- `examples/application/lense/app.rb` remains the composition seam.
- `examples/application/lense/web/lense_dashboard.rb` owns the Arbre surface,
  presentation helpers, feedback copy, and stable marker names.
- `Igniter::Application.rack_app` remains the reusable package seam.
- The mounted Web surface reads through `MountContext` and app-owned services.
- All mutable scan/session state, command results, action facts, and detached
  read snapshots stay inside app-local services.

Minimum surface:

- `GET /` renders a single Lense workbench screen.
- `GET /events` renders a compact text read model from the same detached
  `CodebaseSnapshot` used by the screen.
- `POST /scan` refreshes the deterministic local scan for the configured target
  root.
- `POST /sessions/start` starts a guided session for a selected finding.
- `POST /sessions/:id/steps` records one app-local action: `done`, `skip`, or
  `note`.
- Optional `GET /report` may render the receipt-shaped report if it is simpler
  than printing report markers from the POC script.

Screen shape:

- health header: project label, scan id, generated-at, health score, Ruby file
  count, line count, finding count
- findings lane: prioritized findings with deterministic evidence refs and a
  "Start guided session" action for the top finding
- guided session lane: selected finding, current step, suggested local action,
  evidence refs, and `done`/`skip`/`note` controls
- recent activity lane: scan/session facts and refused command facts from the
  snapshot
- report lane: report validity, report identity, skipped/deferred items, and
  receipt/export markers

Read model shape:

- `scan_id`
- `project_label`
- `target_root_label`
- `generated_at`
- `ruby_file_count`
- `line_count`
- `health_score`
- `finding_count`
- `top_findings`
- `active_session`
- `recent_events`
- `report_summary`

Finding entries should be plain hashes or small immutable app-local structs with
boring fields such as `id`, `title`, `severity`, `score`, `file`, `line`,
`evidence_ref`, and `suggested_steps`.

Session entries should stay app-local and deterministic: `id`, `finding_id`,
`state`, `current_step`, `completed_steps`, `skipped_steps`, `notes`, and
`action_count`.

Stable browser/smoke markers:

- `data-ig-poc-surface="lense_dashboard"`
- `data-scan-id`
- `data-health-score`
- `data-ruby-file-count`
- `data-line-count`
- `data-finding-count`
- `data-finding-id`
- `data-evidence-ref`
- `data-session-id`
- `data-session-state`
- `data-session-step`
- `data-report-id`
- `data-report-valid`
- `data-feedback-code`
- `data-action="refresh-scan"`
- `data-action="start-session"`
- `data-action="mark-step-done"`
- `data-action="skip-step"`
- `data-action="add-note"`

Expected feedback codes:

- success: `scan_refreshed`, `session_started`, `step_marked_done`,
  `step_skipped`, `note_added`
- refusal: `finding_not_found`, `session_not_found`, `invalid_step_action`,
  `blank_note`

Browser/smoke acceptance:

- initial dashboard render returns status 200 and includes
  `data-ig-poc-surface="lense_dashboard"`
- initial render includes scan identity, counts, top finding, evidence refs, and
  report validity markers
- refresh scan command redirects with `scan_refreshed` and preserves no-mutation
  guarantees
- start-session command redirects with `session_started` and exposes an active
  session marker
- done/skip/note commands update the same app-owned snapshot and append recent
  action facts
- refusal paths for missing finding/session and blank note render stable
  feedback markers
- `/events` reflects the same scan id, finding count, session state, and action
  count as the rendered page
- final report output includes report identity, counts, evidence refs, actions,
  skipped items, and deterministic generated-at data

Deferred from the Web slice:

- public `Igniter.interactive_app` facade
- package-level command result, snapshot, marker, component, or layout DSL
- generic dashboard builder or UI kit
- chat surface, agent prompt loop, or LLM explanation panel
- SSE/WebSocket/live transport
- database-backed sessions
- auth/session framework
- file mutation, patch generation, or browser-triggered code edits
- production server/deployment behavior

Implementation note:

- The first implementation track should prefer one runnable script,
  `examples/application/lense_poc.rb`, mirroring
  `examples/application/interactive_web_poc.rb`: run Rack requests in-process by
  default and support an optional `server` argument only for manual browser
  inspection.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` selects and scopes the application POC.
2. `[Agent Web / Codex]` scopes the web surface and interaction loop.
3. `[Architect Supervisor / Codex]` opens a bounded implementation track.

[Agent Application / Codex]
track: `docs/dev/application-showcase-selection-track.md`
status: landed
delta: selected **Lense** as the first one-process showcase/reference POC
  because it targets developers, runs locally without external services, and
  directly demonstrates contracts-as-analysis-graph.
delta: compared Lense, Scout, Dispatch, Chronicle, and Aria; Scout remains the
  strongest second candidate, while Dispatch/Chronicle/Aria each pull in more
  infrastructure/domain weight for a first slice.
delta: scoped the smallest useful Lense scenario: local scan -> deterministic
  health snapshot -> guided issue session -> report/receipt-shaped output.
delta: defined app-local structure for `examples/application/lense/` services,
  contracts, reports, and web surface; no package-level `interactive_app`
  facade, no network, no LLM, no DB, no scheduler, no SSE/WebSocket, and no code
  mutation.
delta: corrected the constraint reference from missing
  `:interactive_poc_safety` to existing `:interactive_poc_guardrails`.
verify: `git diff --check` passed.
ready: `[Agent Web / Codex]` can scope the minimum Lense dashboard/session
  surface and smoke loop, then `[Architect Supervisor / Codex]` can open the
  bounded implementation track.
block: none

[Agent Web / Codex]
track: `docs/dev/application-showcase-selection-track.md`
status: landed
delta: scoped the minimum **Lense dashboard/workbench** Web surface using the
  existing `Igniter::Application.rack_app` + `MountContext` + app-owned snapshot
  convention instead of introducing `Igniter.interactive_app` or a package-level
  UI DSL.
delta: defined one screen, `/events` parity, refresh-scan, start-session, and
  done/skip/note commands, with Web reading only detached `CodebaseSnapshot`
  data and app-local session facts.
delta: specified read model fields, stable browser/smoke markers, expected
  feedback codes, acceptance checks, and explicit deferred Web features.
ready: `[Architect Supervisor / Codex]` can open a bounded Lense implementation
  track.
block: none
