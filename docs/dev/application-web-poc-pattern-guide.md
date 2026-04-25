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

Use one mounted surface module for the screen.

- Keep the Arbre page, presentation helpers, feedback copy, and marker names in
  `web/operator_board.rb`.
- Read app state through `MountContext` and app-owned services.
- Treat the web mount as a consumer of an app read model, not as the owner of
  command state or domain vocabulary.

Render from the app-owned snapshot.

- Take one snapshot at the top of the page render.
- Use that snapshot for open counts, task cards, recent activity, and footer
  copy.
- Do not mix snapshot rendering with extra direct service reads unless a new
  POC proves a real need.

Use stable `data-` markers as the current inspection seam.

- Mark the surface, forms, task state, feedback code, and activity facts.
- Let smoke scripts and future browser checks assert those markers.
- Prefer boring markers over a UI kit while the interaction model is still
  being pressure-tested.

Keep web vocabulary local for now.

- Feedback messages, activity labels, task-card styling, and form action names
  belong to the app surface.
- Do not promote a generic component system or web DSL from this single
  task-board POC.

Future graduation candidate:

- If another non-task interactive POC repeats the same shape, document a
  `MountContext` plus app snapshot rendering convention before adding helper
  APIs to `igniter-web`.

## Repeated Convention

The pattern has now repeated in two domains:

- `interactive_operator`: task board commands and board snapshot.
- `operator_signal_inbox`: signal commands and signal snapshot.

Guide-level convention:

- Keep `app.rb` as the composition boundary.
- Keep mutable state, command methods, command results, action facts, and read
  snapshots inside app-owned services.
- Let Rack endpoints map app-local command results to transport behavior.
- Render `/events` and web surfaces from the same detached snapshot shape.
- Let mounted web surfaces consume app snapshots through `MountContext`.
- Use stable `data-` markers as the smoke/browser inspection seam.
- Add catalog smoke coverage for command success, refusal, final state, recent
  action facts, and `/events` parity.

Still app-local:

- entity ids and marker names such as `task_id` or `signal_id`
- feedback codes and copy
- action kinds
- snapshot class names and fields
- counter names
- command parameters
- status/severity labels and styling

Do not promote a package-level `CommandResult`, snapshot API, marker DSL, UI
kit, generator, live transport, or `interactive_app` from two POCs alone.

Promotion trigger:

- Consider a narrow package experiment only after a third distinct POC repeats
  the same shape, or if mechanical duplication starts hiding domain intent.
