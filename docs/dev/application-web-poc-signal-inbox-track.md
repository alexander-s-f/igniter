# Application Web POC Signal Inbox Track

This track implements `operator_signal_inbox` as the second non-task
interactive POC scenario.

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
- [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md)

## Decision

[Architect Supervisor / Codex] Accepted `operator_signal_inbox` as the second
scenario after the planning cycle.

Why accepted:

- It is not another task board.
- It repeats the app/web shape with different domain vocabulary.
- It has command success/refusal paths.
- It has useful counters and a read snapshot.
- It can stay small and app-local.

## Goal

Build a copyable app-local signal inbox example that proves the accepted pattern
can repeat outside the task-board domain.

The app should prove:

- service-owned mutable signal state
- app-local `CommandResult`
- deterministic action facts
- app-local `SignalSnapshot`
- Rack command endpoints for acknowledge and escalate
- compact feedback redirects
- mounted web surface rendered from snapshot
- stable markers for smoke/browser checks
- `/events` parity with the web snapshot shape

## Scope

In scope:

- `examples/application/operator_signal_inbox/`
- launcher script such as `examples/application/signal_inbox_poc.rb`
- catalog smoke entry
- app-local README
- service, web surface, Rack endpoints, and smoke markers

Out of scope:

- changes to `packages/igniter-application`
- changes to `packages/igniter-web`
- package-level `CommandResult` or read model API
- UI kit
- live transport
- generator
- full `interactive_app`
- Line-Up/front-matter tooling

## Task 1: Application Signal Inbox

Owner: `[Agent Application / Codex]`

Acceptance:

- Add app-local `SignalInbox` service with seeded signals.
- Implement `acknowledge(id)` and `escalate(id, note:)`.
- Return app-local `CommandResult` for success/refusal paths.
- Record deterministic action facts for seed, acknowledge, escalate, and
  refusal paths.
- Expose `SignalSnapshot` with detached `signals`, `open_count`,
  `critical_count`, `action_count`, and `recent_events`.
- Add Rack endpoints and `/events` read model.
- Keep the existing task-board POC unchanged.

## Task 2: Web Signal Inbox Surface

Owner: `[Agent Web / Codex]`

Acceptance:

- Add one mounted `signal_inbox` surface rendered from `SignalSnapshot`.
- Render open/critical counters, feedback, signal cards, acknowledge form,
  escalate-with-note form, and recent activity.
- Use stable markers:
  `data-ig-poc-surface="operator_signal_inbox"`, `data-open-count`,
  `data-critical-count`, `data-feedback-code`, `data-signal-id`,
  `data-signal-status`, `data-signal-severity`,
  `data-action="acknowledge-signal"`, `data-action="escalate-signal"`,
  `data-ig-activity="recent"`, and `data-activity-kind`.
- Keep marker vocabulary and labels app-local.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/signal_inbox_poc.rb
ruby examples/run.rb smoke
bundle exec rubocop examples/application/signal_inbox_poc.rb examples/application/operator_signal_inbox examples/catalog.rb
git diff --check
```

If package code changes:

```bash
bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb packages/igniter-application/spec/igniter/application/rack_host_spec.rb packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb
rake rubocop
```

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` creates the app-local signal inbox skeleton,
   service, Rack endpoints, launcher, and smoke/catalog fragments.
2. `[Agent Web / Codex]` creates the mounted web surface and stable markers.
3. Keep the whole slice app-local; this is repeatability pressure, not package
   API promotion.

[Agent Application / Codex]
track: `docs/dev/application-web-poc-signal-inbox-track.md`
status: landed
delta: `examples/application/operator_signal_inbox/services/signal_inbox.rb`
  adds app-local `SignalInbox`, `CommandResult`, deterministic action facts,
  and detached `SignalSnapshot`.
delta: `examples/application/operator_signal_inbox/app.rb` adds
  `Igniter::Application.rack_app` wiring, explicit signal service factory,
  `/events`, `/signals/acknowledge`, and `/signals/escalate`.
delta: `examples/application/operator_signal_inbox/web/signal_inbox.rb` adds
  one snapshot-rendered mounted surface with open/critical counters, feedback,
  signal cards, command forms, and stable `data-` markers.
delta: `examples/application/signal_inbox_poc.rb`, `examples/catalog.rb`,
  `examples/application/operator_signal_inbox/README.md`, `config.ru`, and
  `examples/README.md` add the runnable smoke/catalog path.
verify: `ruby examples/application/signal_inbox_poc.rb` passed.
verify: `ruby examples/run.rb smoke` passed with 75 examples, 0 failures.
verify: `bundle exec rubocop examples/application/signal_inbox_poc.rb examples/application/operator_signal_inbox examples/catalog.rb`
  passed with no offenses.
verify: `git diff --check` passed.
ready: `[Agent Web / Codex]` can review marker/surface vocabulary or
  `[Architect Supervisor / Codex]` can review the completed second POC slice.
block: none
