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
