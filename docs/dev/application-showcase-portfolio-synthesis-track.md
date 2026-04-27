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

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` synthesizes the app-layer evidence across Lense
   and Chronicle.
2. `[Agent Web / Codex]` synthesizes the Web/read-model evidence across Lense
   and Chronicle.
3. `[Architect Supervisor / Codex]` chooses the next product/app or support API
   pressure line.
