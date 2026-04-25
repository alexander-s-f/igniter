# Application Web POC Command Result Track

This track strengthens the interactive operator POC with explicit app-local
command results.

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
pressure-test after the action ledger landed.

The current POC now records action facts, but command methods still expose mixed
return shapes: `create` returns a task or `nil`, while `resolve` returns a
boolean. The next useful strengthening is an app-local command result object
that carries success/failure, feedback code, task id, and action facts in one
small readable shape.

## Goal

Make task commands return explicit results without promoting a framework API.

The app should prove:

- create/resolve/refuse paths return a stable command result shape
- Rack endpoints map command results to the existing feedback redirects
- action ledger behavior remains unchanged
- smoke mode proves success/failure result facts indirectly through redirects,
  `/events`, and rendered activity
- all behavior remains local to the interactive operator skeleton

## Scope

In scope:

- small app-local result object inside `services/task_board.rb`
- result fields such as `success?`, `kind`, `feedback_code`, `task_id`, and
  `action`
- Rack endpoint cleanup that uses the result object
- smoke updates only if output markers need to become clearer
- README note if the local command shape becomes visible to readers

Out of scope:

- package-level `CommandResult` API
- contract runtime changes
- StepResultPack promotion
- validation framework
- persistence
- background jobs
- websocket/SSE transport
- UI redesign
- broader `interactive_app` facade

## Task 1: Application Command Result

Owner: `[Agent Application / Codex]`

Acceptance:

- `TaskBoard#create` and `TaskBoard#resolve` return the same app-local result
  type for success and refusal paths.
- Existing feedback redirects remain identical.
- Existing action ledger facts remain deterministic.
- `/events` output remains compatible with the action-log track.
- No package-level API or new framework layer is introduced.

## Task 2: Web Compatibility Check

Owner: `[Agent Web / Codex]`

Acceptance:

- Existing board feedback and recent activity rendering still work unchanged.
- If the application result shape exposes a clearer user-visible state, render
  only a tiny app-local marker or copy change.
- Do not redesign the board or introduce new web abstractions.

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

1. `[Agent Application / Codex]` replaces mixed `nil`/boolean command returns
   with a small app-local command result shape.
2. `[Agent Web / Codex]` verifies the board stays compatible and makes only a
   tiny visible adjustment if the result shape exposes useful state.
3. Keep this as application pressure on result modeling, not a package API.

[Agent Application / Codex]
track: `docs/dev/application-web-poc-command-result-track.md`
status: landed
delta: `examples/application/interactive_operator/services/task_board.rb`
  adds app-local `CommandResult` with `success?`, `failure?`, `kind`,
  `feedback_code`, `task_id`, `action`, and `to_h`.
delta: `examples/application/interactive_operator/services/task_board.rb`
  makes `create` and `resolve` return `CommandResult` for success and refusal
  paths while preserving deterministic action entries.
delta: `examples/application/interactive_operator/app.rb` maps command results
  to the existing `notice`/`error` redirect params without changing feedback
  codes or task ids.
delta: `examples/application/interactive_operator/README.md` documents the
  local command result shape.
verify: `ruby examples/application/interactive_web_poc.rb` passed.
verify: `ruby examples/run.rb smoke` passed with 74 examples, 0 failures.
verify: `bundle exec rubocop examples/application/interactive_web_poc.rb examples/application/interactive_operator examples/catalog.rb`
  passed with no offenses.
verify: `git diff --check` passed.
ready: `[Agent Web / Codex]` can verify board compatibility; no visible board
  change is required by the application slice.
block: none

[Agent Web / Codex]
track: `docs/dev/application-web-poc-command-result-track.md`
status: landed
delta: no Web surface code change required; `web/operator_board.rb` remains
  compatible because command results preserve the existing feedback query codes
  and app-owned recent activity facts.
delta: verified existing rendered markers for feedback, task cards, and recent
  activity still pass after the app-local `CommandResult` change.
verify: `ruby examples/application/interactive_web_poc.rb` passed.
verify: `ruby examples/run.rb smoke` passed with 74 examples, 0 failures.
verify: `bundle exec rubocop examples/application/interactive_web_poc.rb examples/application/interactive_operator examples/catalog.rb`
  passed with no offenses.
verify: `git diff --check` passed.
ready: `[Architect Supervisor / Codex]` can review/accept the completed command
  result POC slice.
block: none

## Supervisor Acceptance

[Architect Supervisor / Codex] Accepted after the cycle review.

Accepted:

- `TaskBoard#create` and `TaskBoard#resolve` now return the same app-local
  `CommandResult` shape for success and refusal paths.
- `CommandResult` exposes `success?`, `failure?`, `kind`, `feedback_code`,
  `task_id`, `action`, and `to_h`.
- Rack endpoints map command results to the existing `notice`/`error` redirect
  params without changing feedback codes or task ids.
- Existing action ledger facts, `/events` output, feedback rendering, task
  cards, and recent activity markers remain stable.
- This stays inside `:interactive_poc_guardrails`: no package-level
  `CommandResult`, contract runtime changes, StepResultPack promotion,
  validation framework, persistence, live transport, UI redesign, or broader
  `interactive_app`.

Verification:

- `ruby examples/application/interactive_web_poc.rb` passed.
- `ruby examples/run.rb smoke` passed with 74 examples and 0 failures.
- `bundle exec rubocop examples/application/interactive_web_poc.rb examples/application/interactive_operator examples/catalog.rb`
  passed with no offenses.
- `git diff --check` passed.

Next:

- Open [Application Web POC Read Model Track](./application-web-poc-read-model-track.md)
  to introduce a small app-local board snapshot consumed by both `/events` and
  the web board.
