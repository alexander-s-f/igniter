# Application Chronicle Showcase Finalization Track

This track finalizes Chronicle as a discoverable showcase after the bounded
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
- [Application Chronicle Implementation Track](./application-chronicle-implementation-track.md)
- [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting Chronicle implementation.

Chronicle is functionally accepted as a bounded POC. The next slice is a short
finalization pass, not a feature expansion.

## Goal

Make Chronicle clear, inspectable, and safe to present as a second showcase app.

The result should answer:

- how to run the smoke and manual server mode
- what the user workflow demonstrates
- what files are read-only fixtures versus runtime writes
- whether app-local internals have obvious polish issues
- whether the Web surface is presentable enough for browser review
- whether Chronicle should be marked showcase-ready or needs another small pass

## Scope

In scope:

- Chronicle README/manual usage notes
- catalog/discoverability wording
- app-local polish if it is narrow and low risk
- Web/readiness polish if it preserves markers and smoke behavior
- optional browser/manual review notes
- verification of existing smoke gates

Out of scope:

- new product features
- additional proposals/decision flows unless needed as tiny fixture clarity
- public `Igniter.interactive_app` facade
- generic framework/API graduation
- graph/canvas/SVG rendering
- live transport, LLMs, connectors, scheduler, persistence, auth, or production
  server work

## Task 1: Chronicle App Finalization

Owner: `[Agent Application / Codex]`

Acceptance:

- Add or update Chronicle README/docs with the app purpose, workflow, file
  layout, smoke command, manual server command, and mutation boundaries.
- Review app-local internals for small clarity issues that could confuse future
  readers, without changing the architecture.
- Preserve deterministic contract-backed analysis and runtime-only writes.
- Keep `CommandResult`, snapshots, parser, conflict rules, and receipt shape
  app-local.
- Re-run relevant smoke/rubocop gates and report results.

## Task 2: Chronicle Web Finalization

Owner: `[Agent Web / Codex]`

Acceptance:

- Review the Web surface for presentability and marker stability.
- Preserve `/events` and `/receipt` parity.
- Improve copy/layout only where it helps manual browser review and does not
  introduce a UI framework or generic component layer.
- Confirm manual server mode:

```bash
ruby examples/application/chronicle_poc.rb server
```

- Re-run relevant smoke/rubocop gates and report results.

## Supervisor Guardrails

[Architect Supervisor / Codex] Notes:

- This is a final polish pass. Resist widening Chronicle into a product backlog.
- The important demo story is still:
  proposal -> conflicts -> acknowledgement/sign-off/refusal -> receipt.
- Do not hide the local file/workdir model; it is part of the enterprise
  clarity of this POC.
- If a polish change threatens smoke stability, defer it.

## Verification Gate

Before supervisor acceptance, run at minimum:

```bash
ruby examples/application/chronicle_poc.rb
ruby examples/run.rb run application/chronicle_poc
ruby examples/run.rb smoke
bundle exec rubocop examples/application/chronicle_poc.rb examples/application/chronicle examples/catalog.rb
git diff --check
```

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` finalizes Chronicle app/docs/discoverability.
2. `[Agent Web / Codex]` finalizes Chronicle Web/manual review readiness.
3. `[Architect Supervisor / Codex]` decides whether Chronicle is showcase-ready.

[Agent Application / Codex]
track: `docs/dev/application-chronicle-showcase-finalization-track.md`
status: landed
delta: added `examples/application/chronicle/README.md` covering purpose,
  workflow, smoke command, manual server command, fixture/runtime write
  boundaries, and stable inspection markers.
delta: updated `docs/guide/interactive-app-structure.md` so Chronicle appears
  beside Lense as a richer app/web showcase with both smoke and manual browser
  commands.
delta: polished app-local refusal plumbing by replacing internal
  `send(:refusal, ...)` calls with an explicit `DecisionSessionStore`
  `command_refusal` method; command result/snapshot/parser/conflict/receipt
  shapes remain app-local.
verify: `ruby examples/application/chronicle_poc.rb` passed.
verify: `ruby examples/run.rb run application/chronicle_poc` passed.
verify: `ruby examples/run.rb smoke` passed, 78 examples.
verify: `bundle exec rubocop examples/application/chronicle_poc.rb examples/application/chronicle examples/catalog.rb`
  passed.
verify: `git diff --check` passed.
ready: `[Agent Web / Codex]` can finish browser/manual review polish, then
  `[Architect Supervisor / Codex]` can decide showcase-ready status.
block: none

[Agent Web / Codex]
track: `docs/dev/application-chronicle-showcase-finalization-track.md`
status: landed
delta: polished `examples/application/chronicle/web/decision_compass.rb` for
  manual review with responsive grid/header behavior and explicit inspection
  links to `/events` and `/receipt`, preserving all smoke markers.
delta: updated `docs/dev/application-web-poc-pattern-guide.md` so Chronicle is
  included as the fourth app/web POC while keeping command result, snapshot,
  marker, UI kit, and `interactive_app` promotion deferred.
delta: confirmed manual server mode with local HTTP checks for `/`, `/events`,
  and `/receipt`.
verify: `ruby examples/application/chronicle_poc.rb` passed.
verify: `ruby examples/run.rb run application/chronicle_poc` passed.
verify: `ruby examples/run.rb smoke` passed, 78 examples.
verify: `bundle exec rubocop examples/application/chronicle_poc.rb examples/application/chronicle examples/catalog.rb`
  passed.
verify: `git diff --check` passed.
ready: `[Architect Supervisor / Codex]` can decide Chronicle showcase-ready
  status.
block: none

## Supervisor Acceptance

[Architect Supervisor / Codex] Accepted.

Decision:

- Chronicle is showcase-ready as the second bounded one-process reference app.
- The finalization pass improved discoverability and manual review readiness
  without widening scope or promoting app-local patterns into package APIs.
- Chronicle now sits beside Lense as a complementary showcase:
  Lense stresses codebase analysis and guided remediation sessions; Chronicle
  stresses decision evidence, sign-off/refusal state, and durable receipts.
- The app-local boundary remains correct: fixtures are read-only, runtime
  writes stay in the workdir, contracts compute deterministic analysis, and Web
  consumes snapshots plus stable markers.

Supervisor verification:

```bash
ruby examples/application/chronicle_poc.rb
ruby examples/run.rb run application/chronicle_poc
ruby examples/run.rb smoke
bundle exec rubocop examples/application/chronicle_poc.rb examples/application/chronicle examples/catalog.rb
git diff --check
```

Result:

- `chronicle_poc` passed.
- `examples/run.rb run application/chronicle_poc` passed.
- `examples/run.rb smoke` passed with 78 examples and 0 failures.
- RuboCop passed with no offenses.
- `git diff --check` passed.

Next:

- Open [Application Showcase Portfolio Synthesis Track](./application-showcase-portfolio-synthesis-track.md)
  to compare Lense and Chronicle as the first two serious showcase apps before
  selecting another product slice or graduating any tiny support API.
