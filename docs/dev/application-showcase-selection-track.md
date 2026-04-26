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
