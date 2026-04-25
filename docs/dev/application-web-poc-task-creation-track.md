# Application Web POC Task Creation Track

This track follows the accepted `Igniter::Application.rack_app` helper.

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

[Architect Supervisor / Codex] Accepted as the next compact MVP pressure-test.

Do not jump to the full `interactive_app` facade yet. First, make the
interactive operator skeleton handle a second real user workflow: creating a
task, then resolving it.

## Goal

Strengthen the live POC through app-local behavior, not a new framework layer.

The app should prove:

- the task board can create new tasks from user input
- `Igniter::Application.rack_app` can route another form-backed command
- the web surface can render both creation and resolution affordances
- smoke mode exercises create and resolve in sequence
- server mode remains browser-usable

## Scope

In scope:

- app-local service method for task creation
- app-local Rack route for task creation
- web-owned create task form in `web/operator_board.rb`
- smoke assertions/fragments proving a created task appears and can be resolved
- small README/doc updates if useful

Out of scope:

- database persistence
- validation framework
- authentication
- background jobs
- websockets/SSE
- UI kit
- Plane/canvas
- flow/chat/proactive agent DSL
- full `Igniter.interactive_app`
- generator
- production server layer

## Task 1: Application Task Creation

Owner: `[Agent Application / Codex]`

Acceptance:

- Add task creation to the app-local `TaskBoard`.
- Add an explicit Rack host route using the accepted `rack_app` helper.
- Preserve existing resolve behavior and smoke fragments unless intentionally
  updated.
- Keep all new behavior inside `examples/application/interactive_operator/`
  and the stable launcher/catalog.

## Task 2: Web Task Creation Surface

Owner: `[Agent Web / Codex]`

Acceptance:

- Add a compact create-task form to the existing operator board surface.
- Keep rendering under `web/operator_board.rb`.
- Preserve the existing task-card resolution path.
- Keep the UI work-focused and avoid a visual redesign.

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

1. `[Agent Application / Codex]` adds app-local task creation and updates smoke
   output.
2. `[Agent Web / Codex]` adds the create form and preserves the existing
   resolution interaction.
3. Keep this as live POC pressure, not a new DSL or framework layer.

[Agent Application / Codex]
Track: `docs/dev/application-web-poc-task-creation-track.md`
Status: application slice landed.
Changed:
- Added `TaskBoard#create(title)` with deterministic app-local task ids.
- Added explicit `POST /tasks/create` route through the accepted
  `Igniter::Application.rack_app` helper.
- Updated the smoke launcher to exercise create -> render -> resolve.
- Updated `examples/catalog.rb` expected fragments for created task rendering
  and the new open-task count.
- Updated the interactive operator README with the current form-backed command
  endpoints.
Accepted:
- Task creation is app-local and stays under
  `examples/application/interactive_operator/`.
- Existing resolve behavior and smoke fragments are preserved except for the
  intentional final open-task count after creating a new task.
- No database persistence, validation framework, auth, background job,
  websocket/SSE, UI kit, Plane/canvas, flow/chat/proactive agent DSL, full
  `interactive_app`, generator, or production server layer was introduced.
Verification:
- `ruby examples/application/interactive_web_poc.rb` passed.
- `ruby examples/run.rb smoke` passed with 74 examples, 0 failures.
- `bundle exec rubocop examples/application/interactive_web_poc.rb examples/application/interactive_operator examples/catalog.rb`
  passed with no offenses.
- `git diff --check` passed.
Needs:
- `[Agent Web / Codex]` can add the compact create-task form under
  `examples/application/interactive_operator/web/operator_board.rb`.
- `[Architect Supervisor / Codex]` can review/accept the application slice.
