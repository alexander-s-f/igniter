# Interactive App Structure

Use this guide when you want a small interactive application that combines
`igniter-application` and `igniter-web` without inventing a package API.

Working examples:

- `examples/application/interactive_operator/`
- `examples/application/operator_signal_inbox/`
- `examples/application/lense/`
- `examples/application/interactive_web_poc.rb`
- `examples/application/signal_inbox_poc.rb`
- `examples/application/lense_poc.rb`

This is a copyable convention, not a framework contract. Keep domain vocabulary
inside your app until the same shape repeats enough to justify a package-level
API.

`interactive_operator` and `operator_signal_inbox` are small command/read-model
pressure tests. `lense` is the first richer showcase: it scans a local Ruby
project, runs a contracts-native health analysis, renders a dashboard/workbench,
records guided issue-session actions, and produces a receipt-shaped report.
Run it with:

```bash
ruby examples/application/lense_poc.rb
```

For manual browser inspection:

```bash
ruby examples/application/lense_poc.rb server
```

## Application Structure

Use `app.rb` as the composition boundary.

- Register app-owned services with explicit factories.
- Mount web surfaces as opaque mount objects.
- Keep Rack command endpoints small and explicit.
- Translate local command results into redirects or text responses at the app
  boundary.

Use app-owned services for state, commands, and reads.

- Keep mutable state private to the service.
- Return a local command result for success and refusal paths.
- Record deterministic action facts where commands happen.
- Expose one detached snapshot for readers.

A command result should stay local and boring.

- Include `success?` or equivalent success/failure state.
- Include a domain feedback code such as `task_resolved` or
  `signal_escalated`.
- Include the domain entity id such as `task_id` or `signal_id`.
- Include the recorded action fact when that helps inspection.

A snapshot should be detached from mutable service arrays.

- Include the domain records needed by the surface.
- Include small counters such as open, critical, or action counts.
- Include recent action facts for inspection.
- Use the same snapshot shape for `/events` and web rendering.

Keep these local for now:

- command result class names
- snapshot class names and fields
- feedback codes and copy
- action kinds
- entity id names
- command parameters
- counters and status labels

## Web Structure

Use one mounted web surface for the screen.

- Keep the Arbre page, presentation helpers, feedback copy, and marker names in
  the local `web/` file.
- Read app state through `MountContext`, usually with
  `assigns[:ctx].service(:service_name).call`.
- Treat the mount as a consumer of an app read snapshot, not as the owner of
  command state.
- Return the mount from the app as an opaque web object.

Render from one app-owned snapshot.

- Take the snapshot once near the top of the render block.
- Use that snapshot for counters, records, recent activity, and footer hints.
- Keep `/events` on the same snapshot shape so API and HTML inspection agree.
- Avoid extra direct service reads during rendering unless a later app proves
  the snapshot is too coarse.

Use stable `data-` markers as the inspection seam.

- Mark the surface with `data-ig-poc-surface`.
- Mark visible counters with names such as `data-open-count` or
  `data-critical-count`.
- Mark command buttons with `data-action`.
- Mark feedback with `data-ig-feedback` and `data-feedback-code`.
- Mark domain records with app-local ids and states such as `data-task-id`,
  `data-task-state`, `data-signal-id`, or `data-signal-status`.
- Mark recent activity with `data-ig-activity`, `data-activity-kind`, and the
  domain id needed by the smoke check.

Keep marker vocabulary local for now.

- Surface names, action names, id attribute names, status labels, feedback copy,
  and style helpers belong to the app.
- Do not introduce a generic UI kit, marker DSL, component DSL, or live
  transport until another distinct app repeats enough mechanical code to make
  local readability worse.

## Validation

Add a runnable launcher and catalog smoke entry for each app. The smoke should
prove command success, refusal feedback, final state, recent action facts, and
`/events` parity with the snapshot used by the web surface.
