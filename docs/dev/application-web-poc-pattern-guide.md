# Application Web POC Pattern Guide

This guide captures the copyable structure proven by the current app/web POCs.
It is a pattern note, not a package API contract.

Reference skeletons:

- `examples/application/interactive_operator/app.rb`
- `examples/application/interactive_operator/services/task_board.rb`
- `examples/application/interactive_operator/web/operator_board.rb`
- `examples/application/interactive_web_poc.rb`
- `examples/application/operator_signal_inbox/app.rb`
- `examples/application/operator_signal_inbox/services/signal_inbox.rb`
- `examples/application/operator_signal_inbox/web/signal_inbox.rb`
- `examples/application/signal_inbox_poc.rb`
- `examples/application/lense/app.rb`
- `examples/application/lense/services/codebase_analyzer.rb`
- `examples/application/lense/services/issue_session_store.rb`
- `examples/application/lense/contracts/codebase_health_contract.rb`
- `examples/application/lense/reports/lense_analysis_receipt.rb`
- `examples/application/lense/web/lense_dashboard.rb`
- `examples/application/lense_poc.rb`

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

- The shape has repeated beyond the task board. Keep it as a guide-level
  convention until at least one more distinct app proves that package support
  would reduce mechanical duplication without hiding domain intent.

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

- `MountContext` plus app snapshot rendering is now the documented convention.
  Add helper APIs to `igniter-web` only after another distinct app repeats the
  same boilerplate enough to obscure the surface's domain vocabulary.

## Repeated Convention

The pattern has now repeated in three domains:

- `interactive_operator`: task board commands and board snapshot.
- `operator_signal_inbox`: signal commands and signal snapshot.
- `lense`: local codebase scan/session commands, codebase snapshot,
  contracts-backed analysis, and receipt-shaped report.

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
- contract graph shape and thresholds
- report/receipt schema

Lense adds a contracts-native analysis graph and a receipt-shaped report, but
those shapes have not repeated across app/web POCs yet. Treat them as important
showcase evidence, not package API pressure.

Do not promote a package-level `CommandResult`, snapshot API, marker DSL, UI
kit, generator, live transport, or `interactive_app` from three POCs alone.

Promotion trigger:

- The third POC confirms a guide-level convention. Consider a narrow package
  experiment only after a fourth distinct POC repeats the same mechanical
  duplication, or earlier only if the duplication starts hiding domain intent.
