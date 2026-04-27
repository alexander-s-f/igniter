# Application Dispatch Showcase Finalization Track

This track finalizes Dispatch as a discoverable showcase after the bounded
implementation landed.

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
- [Application Dispatch Implementation Track](./application-dispatch-implementation-track.md)
- [Application Showcase Convention Consolidation Track](./application-showcase-convention-consolidation-track.md)
- [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting Dispatch implementation.

Dispatch is functionally accepted as a bounded POC. The next slice is a short
finalization pass, not a feature expansion.

## Goal

Make Dispatch clear, inspectable, and safe to present as the fourth showcase
app.

The result should answer:

- how to run smoke and manual server mode
- what workflow the incident command loop demonstrates
- what files are read-only fixtures versus runtime writes
- whether app-local internals need any tiny clarity polish
- whether the Web surface is presentable enough for browser review
- whether Dispatch should be marked showcase-ready or needs one more small pass

## Scope

In scope:

- Dispatch README/manual usage notes
- catalog/guide/discoverability wording if needed
- app-local polish if narrow and low risk
- Web/readiness polish if it preserves markers and smoke behavior
- optional browser/manual review notes
- verification of existing smoke gates

Out of scope:

- new product features
- new incident scenarios unless needed as tiny fixture clarity
- public `Igniter.interactive_app` facade
- generic framework/API graduation
- graph/canvas/SVG rendering
- live transport, LLMs, connectors, schedulers, persistence, auth, or
  production server work

## Task 1: Dispatch App Finalization

Owner: `[Agent Application / Codex]`

Acceptance:

- Add or update Dispatch README/docs with app purpose, workflow, file layout,
  smoke command, manual server command, and mutation boundaries.
- Review app-local internals for small clarity issues that could confuse future
  readers, without changing the architecture.
- Preserve deterministic contract-backed triage/routing/readiness analysis and
  runtime-only writes.
- Keep fixture loading, command results, snapshots, routing rules, and receipt
  shape app-local.
- Re-run relevant smoke/rubocop gates and report results.

## Task 2: Dispatch Web Finalization

Owner: `[Agent Web / Codex]`

Acceptance:

- Review the Web surface for presentability and marker stability.
- Preserve `/events` and `/receipt` parity.
- Improve copy/layout only where it helps manual browser review and does not
  introduce a UI framework, marker DSL, route DSL, or generic component layer.
- Confirm manual server mode:

```bash
ruby examples/application/dispatch_poc.rb server
```

- Re-run relevant smoke/rubocop gates and report results.

## Supervisor Guardrails

[Architect Supervisor / Codex] Notes:

- This is a final polish pass. Resist widening Dispatch into live operations,
  connectors, remediation, or a framework backlog.
- The important demo story is still:
  open incident -> triage evidence -> assignment or escalation checkpoint ->
  handoff receipt.
- Do not hide the read-only fixture/workdir model; reproducibility is part of
  this POC's value.
- If a polish change threatens smoke stability, defer it.

## Verification Gate

Before supervisor acceptance, run at minimum:

```bash
ruby examples/application/dispatch_poc.rb
ruby examples/run.rb run application/dispatch_poc
ruby examples/run.rb smoke
bundle exec rubocop examples/application/dispatch_poc.rb examples/application/dispatch examples/catalog.rb
git diff --check
```

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` finalizes Dispatch app/docs/discoverability.
2. `[Agent Web / Codex]` finalizes Dispatch Web/manual review readiness.
3. `[Architect Supervisor / Codex]` decides whether Dispatch is showcase-ready.

[Agent Application / Codex]
track: `docs/dev/application-dispatch-showcase-finalization-track.md`
status: landed
delta: added `examples/application/dispatch/README.md` with Dispatch purpose,
  workflow, file layout, smoke/manual server commands, fixture/runtime mutation
  boundaries, stable smoke markers, manual browser review notes, and explicit
  non-package/API deferrals.
delta: updated `docs/guide/interactive-app-structure.md` so Dispatch appears
  beside Lense, Chronicle, and Scout in working examples, richer-showcase
  wording, run commands, manual server commands, and validation marker
  examples.
delta: reviewed app-local internals and left runtime code unchanged; the
  accepted implementation already includes the Supervisor correction for
  invalid assignment and blank escalation evidence.
verify: `ruby examples/application/dispatch_poc.rb` passed.
verify: `ruby examples/run.rb run application/dispatch_poc` passed.
verify: `ruby examples/run.rb smoke` passed, 80 examples.
verify: `bundle exec rubocop examples/application/dispatch_poc.rb examples/application/dispatch examples/catalog.rb`
  passed.
verify: `git diff --check` passed.
ready: `[Agent Web / Codex]` can finalize Web/manual review polish; then
  `[Architect Supervisor / Codex]` can decide showcase-ready status.
block: none

[Agent Web / Codex]
track: `docs/dev/application-dispatch-showcase-finalization-track.md`
status: landed
delta: reviewed Dispatch Web marker stability and preserved existing
  smoke-facing surface, feedback, event/provenance, routing, checkpoint,
  receipt, `/events`, `/receipt`, and activity seams.
delta: polished `examples/application/dispatch/web/command_center.rb`
  checkpoint copy for manual browser review without adding framework/API
  surface or changing markers.
delta: updated `docs/dev/application-web-poc-pattern-guide.md` and
  `docs/guide/interactive-app-structure.md` so Dispatch is represented in the
  repeated app/web, receipt/report, and smoke-helper convention language.
verify: `ruby examples/application/dispatch_poc.rb` passed.
verify: `ruby examples/run.rb run application/dispatch_poc` passed.
verify: `ruby examples/run.rb smoke` passed, 80 examples.
verify: `bundle exec rubocop examples/application/dispatch_poc.rb examples/application/dispatch examples/catalog.rb`
  passed.
verify: `git diff --check` passed.
verify: `ruby examples/application/dispatch_poc.rb server` served GET `/` on
  `http://127.0.0.1:9297/` during manual local check.
ready: `[Architect Supervisor / Codex]` can decide whether Dispatch is
  showcase-ready beside Lense, Chronicle, Scout, and the earlier POCs.
block: none
