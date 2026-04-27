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

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` synthesizes app-local repeated patterns.
2. `[Agent Web / Codex]` synthesizes web/read-model repeated patterns.
3. `[Architect Supervisor / Codex]` decides the next product/app pressure line.
