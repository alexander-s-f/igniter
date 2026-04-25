# Application Web POC Action Log Track

This track strengthens the interactive operator POC with a small app-local
action ledger.

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
pressure-test after feedback/refusal visibility.

The POC can now create and resolve tasks and show immediate command feedback.
The next useful model strengthening is an app-owned action log: each command
should leave a small observable fact that both Rack endpoints and the web
surface can read.

## Goal

Add a deterministic, app-local action ledger without changing the architecture.

The app should prove:

- task create/resolve/refuse paths produce typed action records
- `GET /events` exposes a compact read model beyond only open count
- the web board can render recent activity from app state
- smoke mode proves the ledger for success and refusal paths
- all behavior remains copyable inside the application skeleton

## Scope

In scope:

- in-memory action records inside `services/task_board.rb`
- small read helpers such as `events` or `recent_events`
- compact `/events` output with count/open/action facts
- a recent activity section in `web/operator_board.rb`
- smoke fragments for action records
- README/catalog updates if visible markers change

Out of scope:

- persistence
- background jobs
- websocket/SSE transport
- session framework
- auth
- UI kit or redesign
- broader `interactive_app` facade
- generator
- production server layer

## Task 1: Application Action Ledger

Owner: `[Agent Application / Codex]`

Acceptance:

- `TaskBoard` records deterministic action entries for seed/open state,
  successful create, blank create refusal, successful resolve, and missing-task
  resolve.
- Existing public behavior remains stable: create/resolve redirects, feedback
  query params, open count, and browser server still work.
- `GET /events` exposes open count and enough action-log facts for smoke checks.
- No persistence, jobs, transport, auth, or new framework layer is introduced.

## Task 2: Web Recent Activity Surface

Owner: `[Agent Web / Codex]`

Acceptance:

- The operator board renders recent activity from app-owned state.
- Rendered entries include stable `data-` markers for smoke checks.
- Existing task cards, create form, resolve form, and feedback messages remain
  intact.
- Styling stays local to `web/operator_board.rb`; no UI kit or redesign.

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

1. `[Agent Application / Codex]` adds the app-local action ledger and `/events`
   read model.
2. `[Agent Web / Codex]` renders recent activity from the same app-owned state.
3. Keep the slice inside `:interactive_poc_guardrails`; this is observability
   pressure, not a live transport or UI framework.

[Agent Application / Codex]
track: `docs/dev/application-web-poc-action-log-track.md`
status: landed
delta: `examples/application/interactive_operator/services/task_board.rb`
  records deterministic app-local action entries for seeded tasks, create
  success, blank create refusal, resolve success, and missing-task resolve
  refusal.
delta: `examples/application/interactive_operator/app.rb` keeps existing
  feedback redirects and expands `GET /events` to `open=<n> actions=<n>
  recent=<kind:task:status|...>`.
delta: `examples/application/interactive_web_poc.rb` and `examples/catalog.rb`
  smoke-check the ledger facts for seed/refusal/create/missing/resolve paths.
delta: `examples/application/interactive_operator/README.md` documents that
  `/events` now includes action count and recent typed facts.
verify: `ruby examples/application/interactive_web_poc.rb` passed.
verify: `ruby examples/run.rb smoke` passed with 74 examples, 0 failures.
verify: `bundle exec rubocop examples/application/interactive_web_poc.rb examples/application/interactive_operator examples/catalog.rb`
  passed with no offenses.
verify: `git diff --check` passed.
ready: `[Agent Web / Codex]` can render recent activity from
  `TaskBoard#recent_events` under `web/operator_board.rb`.
block: none

[Agent Web / Codex]
track: `docs/dev/application-web-poc-action-log-track.md`
status: landed
delta: `examples/application/interactive_operator/web/operator_board.rb`
  renders recent activity from app-owned `TaskBoard#recent_events` with stable
  `data-ig-activity`, `data-activity-kind`, `data-activity-task-id`, and
  `data-activity-status` markers.
delta: `examples/application/interactive_web_poc.rb` and `examples/catalog.rb`
  smoke-check the rendered activity surface for seeded, refused create,
  successful create, refused resolve, and successful resolve facts.
delta: `examples/application/interactive_operator/README.md` documents that the
  board renders recent activity from the same state that backs `/events`.
verify: `ruby examples/application/interactive_web_poc.rb` passed.
verify: `ruby examples/run.rb smoke` passed with 74 examples, 0 failures.
verify: `bundle exec rubocop examples/application/interactive_web_poc.rb examples/application/interactive_operator examples/catalog.rb`
  passed with no offenses.
verify: `git diff --check` passed.
ready: `[Architect Supervisor / Codex]` can review/accept the completed action
  log POC slice.
block: none
