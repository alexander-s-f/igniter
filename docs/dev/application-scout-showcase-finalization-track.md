# Application Scout Showcase Finalization Track

This track finalizes Scout as a discoverable showcase after the bounded
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
- [Application Scout Implementation Track](./application-scout-implementation-track.md)
- [Application Showcase Convention Consolidation Track](./application-showcase-convention-consolidation-track.md)
- [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting Scout implementation.

Scout is functionally accepted as a bounded POC. The next slice is a short
finalization pass, not a feature expansion.

## Goal

Make Scout clear, inspectable, and safe to present as the third showcase app.

The result should answer:

- how to run the smoke and manual server mode
- what the user workflow demonstrates
- what files are read-only fixtures versus runtime writes
- whether app-local internals have obvious polish issues
- whether the Web surface is presentable enough for browser review
- whether Scout should be marked showcase-ready or needs another small pass

## Scope

In scope:

- Scout README/manual usage notes
- guide/catalog/discoverability wording if needed
- app-local polish if narrow and low risk
- Web/readiness polish if it preserves markers and smoke behavior
- optional browser/manual review notes
- verification of existing smoke gates

Out of scope:

- new product features
- additional source connectors or source types
- public `Igniter.interactive_app` facade
- generic framework/API graduation
- graph/canvas/SVG rendering
- live transport, LLMs, embeddings, semantic search, connectors, scheduler,
  persistence, auth, or production server work

## Task 1: Scout App Finalization

Owner: `[Agent Application / Codex]`

Acceptance:

- Add or update Scout README/docs with app purpose, workflow, file layout,
  smoke command, manual server command, and mutation boundaries.
- Review app-local internals for small clarity issues that could confuse future
  readers, without changing the architecture.
- Preserve deterministic contract-backed extraction/synthesis and runtime-only
  writes.
- Keep source parsing, command results, snapshots, finding/contradiction rules,
  and receipt shape app-local.
- Re-run relevant smoke/rubocop gates and report results.

## Task 2: Scout Web Finalization

Owner: `[Agent Web / Codex]`

Acceptance:

- Review the Web surface for presentability and marker stability.
- Preserve `/events` and `/receipt` parity.
- Improve copy/layout only where it helps manual browser review and does not
  introduce a UI framework, marker DSL, route DSL, graph renderer, or generic
  component layer.
- Confirm manual server mode:

```bash
ruby examples/application/scout_poc.rb server
```

- Re-run relevant smoke/rubocop gates and report results.

## Supervisor Guardrails

[Architect Supervisor / Codex] Notes:

- This is a final polish pass. Resist widening Scout into network research,
  AI synthesis, or connector work.
- The important demo story is still:
  topic/source set -> findings -> checkpoint -> provenance receipt.
- Do not hide the local fixture/workdir model; reproducibility is part of this
  POC's value.
- If a polish change threatens smoke stability, defer it.

## Verification Gate

Before supervisor acceptance, run at minimum:

```bash
ruby examples/application/scout_poc.rb
ruby examples/run.rb run application/scout_poc
ruby examples/run.rb smoke
bundle exec rubocop examples/application/scout_poc.rb examples/application/scout examples/catalog.rb
git diff --check
```

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` finalizes Scout app/docs/discoverability.
2. `[Agent Web / Codex]` finalizes Scout Web/manual review readiness.
3. `[Architect Supervisor / Codex]` decides whether Scout is showcase-ready.

[Agent Application / Codex]
track: `docs/dev/application-scout-showcase-finalization-track.md`
status: landed
delta: added `examples/application/scout/README.md` with Scout purpose,
  workflow, file layout, smoke/manual server commands, fixture/runtime mutation
  boundaries, stable smoke markers, and explicit non-package/API deferrals.
delta: updated `docs/guide/interactive-app-structure.md` so Scout appears
  beside Lense and Chronicle in working examples, richer-showcase wording,
  run commands, manual server commands, and validation marker examples.
delta: reviewed app-local internals and left runtime code unchanged; no narrow
  clarity issue justified changing accepted smoke-stable behavior.
verify: `ruby examples/application/scout_poc.rb` passed.
verify: `ruby examples/run.rb run application/scout_poc` passed.
verify: `ruby examples/run.rb smoke` passed, 79 examples.
verify: `bundle exec rubocop examples/application/scout_poc.rb examples/application/scout examples/catalog.rb`
  passed.
verify: `git diff --check` passed.
ready: `[Agent Web / Codex]` can finalize Web/manual review polish; then
  `[Architect Supervisor / Codex]` can decide showcase-ready status.
block: none
