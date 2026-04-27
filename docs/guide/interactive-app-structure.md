# Interactive App Structure

Use this guide when you want a small interactive application that combines
`igniter-application` and `igniter-web` without inventing a package API.

Working examples:

- `examples/application/interactive_operator/`
- `examples/application/operator_signal_inbox/`
- `examples/application/lense/`
- `examples/application/chronicle/`
- `examples/application/interactive_web_poc.rb`
- `examples/application/signal_inbox_poc.rb`
- `examples/application/lense_poc.rb`
- `examples/application/chronicle_poc.rb`

This is a copyable convention, not a framework contract. Keep domain vocabulary
inside your app until the same shape repeats enough to justify a package-level
API.

`interactive_operator` and `operator_signal_inbox` are small command/read-model
pressure tests. `lense` is the first richer showcase: it scans a local Ruby
project, runs a contracts-native health analysis, renders a dashboard/workbench,
records guided issue-session actions, and produces a receipt-shaped report.
`chronicle` is the second richer showcase: it compares a local proposal against
seed decision records, shows deterministic conflict evidence, records
acknowledgement/sign-off/refusal actions, and emits a decision receipt.

Run Lense with:

```bash
ruby examples/application/lense_poc.rb
```

Run Chronicle with:

```bash
ruby examples/application/chronicle_poc.rb
```

For manual browser inspection:

```bash
ruby examples/application/lense_poc.rb server
ruby examples/application/chronicle_poc.rb server
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

## Showcase Checklist

Use this checklist when an example is meant to be a serious one-process
showcase, not only a small interaction pressure test.

- Keep `app.rb` as the visible composition boundary.
- Put domain state and commands in app-local services.
- Add one deterministic contracts-native graph for the core analysis or
  readiness computation.
- Keep the contract graph offline: no network, LLM provider, scheduler, file
  watcher, database, or external mutation in the first slice.
- Return app-local command results for success and refusal paths.
- Record action facts at the command boundary.
- Expose one detached snapshot for Web rendering, `/events`, and smoke
  inspection.
- Emit one app-local receipt/report artifact when the workflow reaches a useful
  checkpoint.
- Document smoke usage and optional manual server usage in the app README.
- Register a catalog smoke entry only when the run is deterministic and fast.
- Prove the mutation boundary: either no target mutation, or runtime writes only
  in an explicit workdir.

## Receipt/Report Convention

Receipts and reports are evidence artifacts, not a shared framework class. Lense
and Chronicle both prove the shape, but their payloads remain domain-specific.

Include these ideas when useful:

- stable receipt/report id
- kind, validity, and generated timestamp
- subject identity such as scan id, proposal id, session id, or project label
- evidence refs back to files, decisions, findings, sources, or sections
- compact action facts relevant to the artifact
- provenance for input files, target roots, fixture paths, or contract version
- skipped/deferred scope such as no LLM, no scheduler, or no external mutation
- metadata supplied by the caller or inspection endpoint

Keep these local for now:

- receipt/report class names
- payload keys and nested shapes
- Markdown versus hash rendering
- validity rules
- evidence reference format
- deferred item vocabulary
- runtime write layout

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

## Web Surface Checklist

Use this checklist when the example is meant to be manually inspected in a
browser as well as smoke-tested.

- Build one app-local Arbre surface under `web/`.
- Mount it through `Igniter::Web.mount` and `mount_web` from `app.rb`.
- Read the app service through `MountContext`; render from one app-owned
  snapshot near the top of the page.
- Keep Rack command routes in `app.rb`, not in the surface.
- Map command results to redirects or text responses at the app boundary.
- Render feedback through query-string state and stable
  `data-feedback-code` markers.
- Mark command buttons with app-local `data-action` values.
- Mark domain records and counters with explicit `data-` attributes.
- Render recent activity from the same snapshot and mark it with
  `data-ig-activity` and `data-activity-kind`.
- Keep `/events` on the same snapshot shape used by the surface.
- Add a report or receipt endpoint only when the app already owns a stable
  artifact.
- Keep manual `server` mode available for browser review, but treat it as
  example scaffolding, not production server behavior.
- Register catalog fragments only for markers that are deterministic and
  useful as inspection evidence.

Keep these Web details local for now:

- surface names and CSS direction
- marker attribute names and action values
- feedback messages
- endpoint labels such as `/report` or `/receipt`
- grouping choices such as findings, conflicts, sessions, or sign-off lanes
- smoke output labels and catalog fragments

## Manual Browser Review

Before calling a showcase manually reviewable, run the server mode and inspect
the browser-facing seams.

- Start the app with its documented `server` command.
- Confirm the printed local URL opens the mounted surface.
- Confirm the top-level `data-ig-poc-surface` marker is present.
- Run one successful command through the page.
- Run one refusal path when the app has one.
- Confirm feedback renders with `data-feedback-code`.
- Confirm recent activity updates from the same read model.
- Open `/events` and confirm it agrees with the visible surface state.
- Open `/report` or `/receipt` when the app exposes one.
- Confirm fixtures or scanned targets are not mutated unexpectedly.

## Smoke Helper Design Note

Lense and Chronicle repeat small smoke-script mechanics: Rack env construction,
form encoding, redirect following, response status checks, marker checks, and
catalog fragments. That repetition is enough to justify a future design
discussion, but not a runtime framework.

If a helper is designed later, keep it narrow:

- It should live in examples or specs first, not production runtime.
- It should help build Rack envs, encode form bodies, follow redirects, and
  assert marker fragments.
- It should not know app domain names, command names, feedback codes, snapshot
  fields, or receipt/report schemas.
- It should not require browser automation for normal smoke runs.
- It should not introduce a UI kit, marker DSL, route DSL, or
  `interactive_app` facade.

## Validation

Add a runnable launcher and catalog smoke entry for each app. The smoke should
prove command success, refusal feedback, final state, recent action facts, and
`/events` parity with the snapshot used by the web surface.

For richer showcase apps, also prove receipt/report evidence and mutation
boundaries. Good smoke output names are app-local and boring, for example
`lense_poc_receipt_valid=true`, `chronicle_poc_web_events_parity=true`, or
`chronicle_poc_fixture_no_mutation=true`.
