# Application Showcase Convention Consolidation Track

This track consolidates the conventions proven by Lense and Chronicle without
promoting them into package APIs.

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
- [Application Showcase Portfolio Synthesis Track](./application-showcase-portfolio-synthesis-track.md)
- [Application Lense Showcase Finalization Track](./application-lense-showcase-finalization-track.md)
- [Application Chronicle Showcase Finalization Track](./application-chronicle-showcase-finalization-track.md)
- [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting the showcase portfolio
synthesis.

Lense and Chronicle are showcase-ready. The team should now make the repeated
shape legible before adding another product app or designing package support.

## Goal

Produce compact public/internal guidance for building serious one-process
Igniter showcase apps.

The result should include:

- a showcase app checklist
- a Web mounted-surface checklist
- a receipt/report convention note
- a manual review checklist
- a narrow smoke-helper design note, if still justified
- a final recommendation for the next product pressure line

## Scope

In scope:

- docs/checklists/design notes only
- updating existing guide/dev docs where that keeps context discoverable
- explicit "keep app-local" boundaries
- explicit deferred list
- next-track recommendation

Out of scope:

- implementation
- new package APIs
- public `Igniter.interactive_app` facade
- shared command/result/snapshot/receipt classes
- UI kit/component system
- live transport
- persistence, scheduler, auth, users, teams, production server
- LLM/provider integration or connectors
- changing Lense or Chronicle behavior

## Task 1: App Convention Consolidation

Owner: `[Agent Application / Codex]`

Acceptance:

- Consolidate the app-layer showcase checklist:
  `app.rb`, services, deterministic contract graph, command results, action
  facts, snapshot, receipt/report, README commands, catalog smoke, mutation
  boundary proof.
- Add a receipt/report convention note that keeps payload shape app-local.
- Clarify what must stay app-local and what is only future support evidence.
- Recommend whether Scout should open next after this consolidation.

## Task 2: Web Convention Consolidation

Owner: `[Agent Web / Codex]`

Acceptance:

- Consolidate the Web mounted-surface checklist:
  one app-local surface, `MountContext` snapshot read, Rack command routes,
  feedback markers, action markers, recent activity, `/events` parity,
  report/receipt endpoint, manual server mode, catalog fragments.
- Add a manual browser review checklist.
- Add or reject a narrow Rack smoke-helper design note. Keep it non-runtime and
  non-framework.
- Clarify what remains Web-local and deferred.

## Supervisor Guardrails

[Architect Supervisor / Codex] Notes:

- Prefer compact docs over new architecture documents if existing docs can be
  strengthened.
- This track should reduce future agent context load.
- Do not turn conventions into a DSL.
- The final output should make the next app easier to build without constraining
  it into Lense or Chronicle's exact shape.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
```

Implementation belongs to a later track.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` consolidates app-layer conventions and
   receipt/report guidance.
2. `[Agent Web / Codex]` consolidates Web/read-model conventions and manual
   review guidance.
3. `[Architect Supervisor / Codex]` decides whether to open Scout scoping,
   a tiny support-design track, or a short docs finalization pass.
