# Application Lense Showcase Finalization Track

This track makes the accepted Lense POC easy to discover, run, and inspect
without expanding its feature scope.

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
- [Application Lense POC Implementation Track](./application-lense-poc-implementation-track.md)
- [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting the Lense implementation.

The next slice should make the showcase presentable and discoverable. It should
not add LLMs, persistence, SSE, a public facade, code editing, or broader web
framework abstractions.

## Goal

Finalize Lense as a compact showcase artifact:

- clear guide or README entry
- obvious run commands
- stable expected smoke markers
- optional manual browser instructions
- modest visual/readability polish if needed
- no new feature scope

## Scope

In scope:

- docs/guide or dev index references
- `examples/application/lense/README.md` if useful
- catalog/example wording
- small copy/layout fixes in the Lense surface
- optional manual-browser smoke instructions

Out of scope:

- new analysis features
- package-level `interactive_app` facade
- generic dashboard/UI kit
- LLM provider integration
- persistence/history/trends database
- SSE/WebSocket
- file watcher/scheduler
- code editing or patch generation
- production server/auth/session framework

## Task 1: Showcase Discoverability

Owner: `[Agent Application / Codex]`

Acceptance:

- Add or update a compact discoverability note explaining what Lense proves.
- Include one-command smoke usage:
  `ruby examples/application/lense_poc.rb`.
- Include optional manual browser usage:
  `ruby examples/application/lense_poc.rb server`.
- Keep the wording clear that Lense is a POC, not a package API.
- Do not add new runtime behavior unless correcting a mismatch.

## Task 2: Web Readiness

Owner: `[Agent Web / Codex]`

Acceptance:

- Review the Lense dashboard for obvious marker/copy/layout issues.
- Preserve stable smoke markers and app-local snapshot conventions.
- If making visual tweaks, keep them local to the Lense example.
- Do not introduce new UI framework, live transport, or generic components.
- Confirm the optional server path is suitable for manual browser inspection.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
ruby examples/application/lense_poc.rb
ruby examples/run.rb smoke
bundle exec rubocop examples/application/lense_poc.rb examples/application/lense examples/catalog.rb
```

If package code changes, run focused package specs too.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` makes Lense discoverable and documents run
   commands.
2. `[Agent Web / Codex]` reviews the dashboard/manual-browser readiness without
   expanding scope.
3. `[Architect Supervisor / Codex]` decides whether Lense can be marked
   showcase-ready and what the next product/app pressure line should be.

[Agent Application / Codex]
track: `docs/dev/application-lense-showcase-finalization-track.md`
status: landed
delta: added `examples/application/lense/README.md` with a compact explanation
  of what Lense proves, one-command smoke usage, optional manual browser usage,
  stable marker examples, and explicit POC/non-package-API boundaries.
delta: updated `docs/guide/interactive-app-structure.md` so Lense is visible
  alongside the earlier interactive POC examples and includes both smoke and
  manual-browser commands.
delta: kept scope unchanged: no LLM, persistence, scheduler, SSE/WebSocket,
  public `interactive_app` facade, code editing, or production server behavior.
verify: `git diff --check` passed.
verify: `ruby examples/application/lense_poc.rb` passed.
verify: `ruby examples/run.rb smoke` passed, 77 examples.
verify: `bundle exec rubocop examples/application/lense_poc.rb examples/application/lense examples/catalog.rb`
  passed.
ready: `[Agent Web / Codex]` can review dashboard/manual-browser readiness;
  `[Architect Supervisor / Codex]` can decide whether Lense is showcase-ready.
block: none

[Agent Web / Codex]
track: `docs/dev/application-lense-showcase-finalization-track.md`
status: landed
delta: reviewed the Lense dashboard/manual-browser path and kept the Web slice
  local to the example: no new framework scope, live transport, UI kit, or
  package-level API.
delta: aligned the documented stable markers with the actual smoke output by
  adding `lense_poc_web_events_parity=true` and
  `lense_poc_web_report_endpoint=true` aliases to
  `examples/application/lense_poc.rb` and `examples/catalog.rb`.
delta: confirmed the optional browser path remains
  `ruby examples/application/lense_poc.rb server`, which prints the local
  `lense_poc_url=...` and serves the existing dashboard/workbench.
verify: `git diff --check` passed.
verify: `ruby examples/application/lense_poc.rb` passed.
verify: `ruby examples/run.rb smoke` passed, 77 examples.
verify: `bundle exec rubocop examples/application/lense_poc.rb examples/application/lense examples/catalog.rb`
  passed.
ready: `[Architect Supervisor / Codex]` can decide whether Lense is
  showcase-ready and choose the next product/app pressure line.
block: none
