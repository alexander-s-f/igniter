# Application Web POC Read Model Track

This track strengthens the interactive operator POC with an explicit app-local
read model.

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

## Decision

[Architect Supervisor / Codex] Accepted as the next compact live-app
pressure-test after command results landed.

The POC now has explicit command results, action facts, and feedback redirects.
The remaining asymmetry is on reads: `/events` and the web board still pull
directly from `TaskBoard` methods. The next useful strengthening is an
app-local read model snapshot that can be consumed by both Rack endpoints and
the web surface.

## Goal

Introduce a small `BoardSnapshot` read model without promoting a framework API.

The app should prove:

- application state can expose a stable read snapshot
- `/events` renders from the same snapshot shape as the board
- the board renders task cards and recent activity from the snapshot
- command results and action ledger behavior remain unchanged
- all behavior remains local to the interactive operator skeleton

## Scope

In scope:

- app-local snapshot object inside `services/task_board.rb`
- snapshot fields such as `tasks`, `open_count`, `action_count`, and
  `recent_events`
- `/events` rendering from a snapshot rather than ad hoc service calls
- web board rendering from the same snapshot
- smoke updates only if markers need to become clearer
- README note if the read model shape becomes visible to readers

Out of scope:

- package-level read model API
- persistence
- database projection
- background jobs
- websocket/SSE transport
- auth/session framework
- UI redesign
- broader `interactive_app` facade

## Task 1: Application Board Snapshot

Owner: `[Agent Application / Codex]`

Acceptance:

- `TaskBoard` exposes a single app-local snapshot/read model method.
- Snapshot data is detached from mutable internal arrays.
- `GET /events` renders from the snapshot and preserves current output facts.
- Existing `CommandResult` and action ledger behavior remain stable.
- No package-level API or new framework layer is introduced.

## Task 2: Web Snapshot Rendering

Owner: `[Agent Web / Codex]`

Acceptance:

- The operator board renders from the app-local snapshot.
- Existing feedback, task card, open count, and recent activity markers remain
  stable.
- No UI redesign or new web abstraction is introduced.

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
bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb packages/igniter-application/spec/igniter/application/rack_host_spec.rb packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb
rake rubocop
```

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` introduces an app-local board snapshot and
   moves `/events` to render from it.
2. `[Agent Web / Codex]` moves the board surface to render from the same
   snapshot.
3. Keep this as read-model pressure inside the POC, not a package API,
   persistence layer, or live transport.
