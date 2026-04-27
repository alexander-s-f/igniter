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

## App Convention Consolidation

[Agent Application / Codex] Consolidated in
[Interactive App Structure](../guide/interactive-app-structure.md):

- added a richer showcase checklist covering `app.rb`, app-local services,
  deterministic contract graph, command results, action facts, detached
  snapshot, receipt/report artifact, README commands, catalog smoke, and
  mutation-boundary proof.
- added a receipt/report convention note that treats receipts as evidence
  artifacts with ids, validity, subject identity, evidence refs, action facts,
  provenance, deferred scope, and caller metadata.
- kept receipt/report payload keys, rendering, validity rules, evidence ref
  format, deferred vocabulary, command results, snapshots, and runtime write
  layout app-local.
- left package API graduation explicitly deferred: no `interactive_app` facade,
  no shared command/result/snapshot/receipt classes, no workflow/session DSL,
  and no persistence or live runtime.

Application recommendation:

- After Web consolidation lands, open Scout scoping as the next product pressure
  line only if it is offline/local-source first.
- Do not open a package implementation track from these conventions alone.
- A later support-design track may discuss receipt/report and smoke-helper
  conventions, but it should remain narrow and evidence-driven.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` consolidates app-layer conventions and
   receipt/report guidance.
2. `[Agent Web / Codex]` consolidates Web/read-model conventions and manual
   review guidance.
3. `[Architect Supervisor / Codex]` decides whether to open Scout scoping,
   a tiny support-design track, or a short docs finalization pass.

[Agent Application / Codex]
track: `docs/dev/application-showcase-convention-consolidation-track.md`
status: landed
delta: updated `docs/guide/interactive-app-structure.md` with the app-layer
  showcase checklist and receipt/report convention guidance.
delta: kept command results, snapshots, receipts/reports, payload keys,
  validity rules, evidence refs, runtime write layout, and smoke labels
  app-local; no package API or DSL graduation.
delta: recommended Scout scoping next only after Web consolidation, and only as
  an offline/local-source first slice; package support remains a later narrow
  design topic.
verify: `git diff --check` passed.
ready: `[Agent Web / Codex]` can consolidate Web/manual review guidance, then
  `[Architect Supervisor / Codex]` can choose Scout/support/docs next.
block: none
