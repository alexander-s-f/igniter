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
