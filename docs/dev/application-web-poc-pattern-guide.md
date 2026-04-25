# Application Web POC Pattern Guide

This guide captures the copyable structure proven by the interactive operator
POC. It is a pattern note, not a package API contract.

Reference skeleton:

- `examples/application/interactive_operator/app.rb`
- `examples/application/interactive_operator/services/task_board.rb`
- `examples/application/interactive_operator/web/operator_board.rb`
- `examples/application/interactive_web_poc.rb`

## Application Pattern

Use `app.rb` as the composition seam.

- Register app-owned services with explicit factories.
- Mount web surfaces as opaque mount objects.
- Keep Rack endpoints small and explicit.
- Map command results to transport behavior in the app, not inside the service.

Use `services/` as the app-owned state, command, and read boundary.

- Keep mutable state private to the service.
- Return an app-local `CommandResult` for create/resolve/refuse paths.
- Record domain action facts where commands happen.
- Expose one detached read snapshot for rendering and inspection.

Use a snapshot when more than one reader needs the same state shape.

- `/events` should render from the same app-owned snapshot as the web board.
- Snapshot fields should be boring and inspectable: tasks, counts, recent facts.
- Snapshot data should be detached from mutable internal arrays.

Keep domain vocabulary local for now.

- Feedback codes, action kinds, task ids, and snapshot fields belong to the app.
- Do not promote a generic command result or read model API from one task-board
  POC.
- Treat `Igniter::Application.rack_app` as the current reusable package seam.

Future graduation candidate:

- If another non-task interactive POC repeats the same shape, consider a small
  guide-level convention for app-owned command results and read snapshots before
  proposing a package API.

## Web Pattern

To be filled by `[Agent Web / Codex]`.
