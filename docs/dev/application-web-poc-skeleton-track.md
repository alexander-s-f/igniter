# Application Web POC Skeleton Track

This track follows the accepted interactive application/web POC.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Package agents should report with:

```text
[Agent Application / Codex]
[Agent Web / Codex]
```

## Decision

[Architect Supervisor / Codex] Accepted as the next compact finalization track.

The browser-tested POC is useful enough to become a small app skeleton. The goal
is not a generator yet. The goal is to let a real runnable app pressure-test
Igniter's application and web structure.

## Goal

Extract the single-file POC into an organic, app-local skeleton while preserving
the same runnable behavior.

The result should help answer:

- where app-owned state/services should live
- where web-owned pages/surfaces should live
- where the Rack/server boundary should live
- how a user can run the app in smoke mode and server mode
- what folder/file structure feels portable enough to copy into another project

## Preferred Shape

Keep `examples/application/interactive_web_poc.rb` as the stable launcher for
the examples catalog.

Add an app-local skeleton under a directory such as:

```text
examples/application/interactive_operator/
```

Suggested files:

```text
app.rb
services/task_board.rb
web/operator_board.rb
server/rack_app.rb
config.ru
README.md
```

Adjust names to fit the codebase if a cleaner local pattern emerges.

## Scope

In scope:

- app-local skeleton directory
- service/state extraction out of the launcher
- web surface extraction out of the launcher
- Rack-compatible host extraction out of the launcher
- optional `config.ru` for Rack-compatible manual runs
- launcher remains smoke-friendly and exits by default
- `server` mode remains available for browser testing
- docs that explain the app skeleton briefly
- examples catalog remains stable

Out of scope:

- generator
- production server package
- new framework layer
- Rails integration
- database persistence
- authentication
- background jobs
- websockets
- cluster placement
- host activation commit
- private project specifics

## Task 1: Application Skeleton

Owner: `[Agent Application / Codex]`

Acceptance:

- Move app-owned state/service code into the app skeleton.
- Keep app-local code inside the skeleton directory.
- Keep the launcher compact.
- Preserve smoke fragments already used by the examples catalog.
- Do not introduce production dependencies.

## Task 2: Web Skeleton

Owner: `[Agent Web / Codex]`

Acceptance:

- Move web-owned surface/page code into the app skeleton.
- Keep the interaction path unchanged: render -> form POST -> state change ->
  changed render.
- Keep server mode browser-usable.
- Avoid frontend framework work and unrelated visual redesign.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/interactive_web_poc.rb
ruby examples/run.rb smoke
bundle exec rubocop examples/application/interactive_web_poc.rb examples/application/interactive_operator examples/catalog.rb
git diff --check
```

If package code changes:

```bash
bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb
rake rubocop
```

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` extracts the app-owned service/state and
   launcher shape.
2. `[Agent Web / Codex]` extracts the web-owned surface and keeps the request
   interaction intact.
3. Keep this compact; do not add a generator until the skeleton has taught us
   what the real shape should be.
