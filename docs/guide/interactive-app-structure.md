# Interactive App Structure

Use this guide for small real applications that combine `igniter-application`
and `igniter-web` without inventing a public framework API.

This is a copyable convention, not a compatibility contract.

## Current Examples

- `examples/application/interactive_operator/`
- `examples/application/operator_signal_inbox/`
- `examples/application/lense/`
- `examples/application/chronicle/`
- `examples/application/scout/`
- `examples/application/dispatch/`

Run the richer showcases:

```bash
ruby examples/application/lense_poc.rb
ruby examples/application/chronicle_poc.rb
ruby examples/application/scout_poc.rb
ruby examples/application/dispatch_poc.rb
```

Add `server` for manual browser review. Server mode is example scaffolding, not
production server behavior.

## App Shape

- `app.rb` is the composition boundary.
- `contracts/` owns deterministic business graphs.
- `services/` owns loading, mutable state, commands, and snapshots.
- `reports/` owns receipt/report artifacts when the workflow has evidence.
- `web/` owns the mounted Arbre surface.
- the launcher script owns smoke and optional server mode.

Keep domain names, command results, snapshot fields, feedback codes, markers,
routes, receipts, thresholds, and readiness rules local until repeated apps
prove a package API is worth extracting.

## Runtime Loop

A serious one-process showcase should have:

- app-local services that load inputs and own session state
- one contracts-native graph for core analysis/readiness/payload
- command routes that return app-local success/refusal results
- deterministic action facts recorded at command boundaries
- one detached snapshot shared by Web rendering, `/events`, and smoke
- one receipt/report artifact when the workflow reaches a useful checkpoint
- explicit mutation-boundary proof

Do not imply hidden LLM calls, external connectors, schedulers, databases,
auth, live transport, production hosting, or cluster placement in the first
slice.

## Web Surface

Use one mounted web surface:

- mount through `Igniter::Web.mount` and app-local `mount_web`
- read state through `MountContext`
- render from one app-owned snapshot
- keep command routes in `app.rb`
- expose stable app-local `data-` markers for smoke and manual review
- keep `/events` on the same snapshot shape as the visible surface
- add `/report` or `/receipt` only when the app owns a stable artifact

Marker vocabulary is local. Do not extract a UI kit, marker DSL, route DSL, or
`interactive_app` facade until repetition makes local readability worse.

## Proof Checklist

The smoke path should prove:

- initial HTML render and top-level surface marker
- one successful command path
- one refusal path when the app has one
- feedback marker and feedback code
- domain counters/records through app-local `data-` markers
- recent activity from the same snapshot
- `/events` parity
- receipt/report validity when present
- no unintended fixture or target mutation

Manual browser review should confirm the same seams through the printed local
URL.

For the showcase map, see
[Application Showcase Portfolio](./application-showcase-portfolio.md).
