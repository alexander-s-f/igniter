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

- `:interactive_poc_safety` from [Constraint Sets](./constraints.md)
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

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` selects and scopes the application POC.
2. `[Agent Web / Codex]` scopes the web surface and interaction loop.
3. `[Architect Supervisor / Codex]` opens a bounded implementation track.
