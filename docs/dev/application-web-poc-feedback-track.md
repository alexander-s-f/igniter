# Application Web POC Feedback Track

This track follows the accepted task creation workflow in the interactive
operator POC.

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

[Architect Supervisor / Codex] Accepted as the next compact live-app
pressure-test.

The POC now has two commands: create task and resolve task. Before introducing
larger DSLs or UI packages, the live app should learn how to show command
outcomes and harmless validation feedback.

## Goal

Add small feedback/state visibility to the existing POC without changing the
architecture.

The app should prove:

- a successful create/resolve action can show a visible message on the next
  render
- an empty create submission is refused without creating a task
- the refusal is visible to the user
- smoke mode exercises success and refusal paths
- all behavior remains app-local and server mode remains browser-usable

## Scope

In scope:

- query-string or app-local flash-style feedback suitable for the current
  RackHost helper
- create-task refusal for blank titles
- visible success/error messages in `web/operator_board.rb`
- smoke fragments for success and refusal messages
- small docs/catalog updates

Out of scope:

- session/cookie framework
- persistent flash storage
- validation framework
- UI kit
- Plane/canvas
- flow/chat/proactive agent DSL
- SSE/live updates
- full `Igniter.interactive_app`
- generator
- production server layer

## Task 1: Application Feedback Boundary

Owner: `[Agent Application / Codex]`

Acceptance:

- Keep feedback app-local and simple.
- Refuse blank task creation without mutating the board.
- Redirect with enough explicit state for the next render to show success or
  error.
- Preserve existing create and resolve smoke behavior.

## Task 2: Web Feedback Surface

Owner: `[Agent Web / Codex]`

Acceptance:

- Render compact success/error feedback in the operator board.
- Keep feedback under `web/operator_board.rb`.
- Preserve create and resolve forms.
- Avoid a visual redesign or new component system.

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

1. `[Agent Application / Codex]` adds the app-local feedback/refusal boundary.
2. `[Agent Web / Codex]` renders compact success/error messages.
3. Keep this as live POC pressure, not a UI kit or validation framework.

[Agent Application / Codex]
Track: `docs/dev/application-web-poc-feedback-track.md`
Status: application slice landed.
Changed:
- Added app-local command feedback redirects in
  `examples/application/interactive_operator/app.rb`.
- `POST /tasks/create` now redirects with `notice=task_created` and `task=<id>`
  on success.
- Blank task creation now redirects with `error=blank_title` and does not
  mutate the task board.
- `POST /tasks` now redirects with `notice=task_resolved` or
  `error=task_not_found`.
- Server mode now passes `QUERY_STRING` through to the Rack app.
- Smoke output and catalog fragments now cover blank refusal, success feedback
  redirects, create rendering, resolve feedback redirects, and final open-task
  count.
- The interactive operator README documents the feedback query params.
Accepted:
- Feedback remains app-local and query-string based; no session/cookie or
  persistent flash storage was added.
- Blank create is refused without mutation.
- Existing create and resolve behavior remains intact.
- No validation framework, UI kit, Plane/canvas, flow/chat/proactive agent DSL,
  SSE/live runtime, full `interactive_app`, generator, or production server
  layer was introduced.
Verification:
- `ruby examples/application/interactive_web_poc.rb` passed.
- `ruby examples/run.rb smoke` passed with 74 examples, 0 failures.
- `bundle exec rubocop examples/application/interactive_web_poc.rb examples/application/interactive_operator examples/catalog.rb`
  passed with no offenses.
- `git diff --check` passed.
Needs:
- `[Agent Web / Codex]` can render compact success/error feedback from
  `QUERY_STRING` under `examples/application/interactive_operator/web/operator_board.rb`.
- `[Architect Supervisor / Codex]` can review/accept the application feedback
  boundary.
