# Application Web POC Second Scenario Track

This track proposes a second, non-task interactive POC scenario to test whether
the accepted pattern repeats outside the task-board domain.

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
- [Documentation Compression Doctrine](./documentation-compression-doctrine.md)

## Decision

[Architect Supervisor / Codex] Accepted as the next docs-only planning slice.

The pattern guide says not to promote command results, snapshots, or web
helpers from one task-board POC. The next useful move is to choose a second
small scenario that can pressure-test the same shape.

## Goal

Pick one compact non-task scenario and define its acceptance before writing
code.

Candidate scenario qualities:

- small enough for one or two implementation cycles
- not another task board
- has at least one command/refusal path
- has a read snapshot
- has visible web feedback and stable data markers
- can run through `examples/run.rb smoke`

## Scope

In scope:

- propose one or two candidate scenarios
- choose one recommended scenario
- define app-local seams, web surface, commands, snapshot, and smoke markers
- define what would prove the pattern repeated

Out of scope:

- code changes
- package API changes
- UI kit
- live transport
- generator
- full `interactive_app`
- Line-Up/front-matter tooling

## Task 1: Application Scenario Proposal

Owner: `[Agent Application / Codex]`

Acceptance:

- Propose a compact non-task domain.
- Define service state, commands, refusals, action facts, command result, and
  snapshot fields.
- Keep it app-local and copyable.

## Task 2: Web Scenario Proposal

Owner: `[Agent Web / Codex]`

Acceptance:

- Define the mounted web surface and stable markers for the proposed scenario.
- Keep rendering snapshot-oriented.
- Avoid UI kit, redesign, live transport, or new web abstraction.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
```

If code changes, the track is out of scope and must return to supervisor.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` proposes the second scenario from app structure
   needs.
2. `[Agent Web / Codex]` validates the scenario as a compact web surface.
3. `[Architect Supervisor / Codex]` accepts one scenario or pauses the POC line.

[Agent Application / Codex]
track: `docs/dev/application-web-poc-second-scenario-track.md`
status: landed
delta: recommended scenario: `operator_signal_inbox`, a small app-local inbox
  for incoming operational signals rather than tasks.
delta: service state: `SignalInbox` owns seeded `Signal` records
  (`id`, `source`, `summary`, `severity`, `status`) plus deterministic action
  facts for seed, acknowledge, escalate, and refusal paths.
delta: commands: `acknowledge(id)` marks an open signal acknowledged;
  `escalate(id, note:)` marks an open signal escalated with an operator note;
  blank note and missing/closed signal cases return refusals.
delta: command result: keep a local `CommandResult` shape with `success?`,
  `feedback_code`, `signal_id`, and `action`; feedback codes stay domain-local
  (`signal_acknowledged`, `signal_escalated`, `signal_not_found`,
  `blank_escalation_note`, `signal_closed`).
delta: snapshot: `SignalSnapshot` exposes detached `signals`,
  `open_count`, `critical_count`, `action_count`, and `recent_events`; `/events`
  can render from the same snapshot as the web surface.
delta: smoke proof: expected fragments should show initial open/critical counts,
  refusal feedback, successful acknowledge, successful escalate, rendered
  recent action facts, and `/events` parity.
delta: alternate considered: `operator_runbook_review`; weaker because it
  still feels task-like and pressures document editing more than
  command/result/snapshot shape.
delta: recommendation: implement `operator_signal_inbox` only after
  `[Agent Web / Codex]` confirms a compact snapshot-oriented surface and stable
  marker vocabulary.
verify: `git diff --check` passed for docs-only proposal.
ready: `[Agent Web / Codex]` can validate web surface shape and markers.
block: none

[Agent Web / Codex]
track: `docs/dev/application-web-poc-second-scenario-track.md`
status: landed
delta: web recommendation accepts `operator_signal_inbox` as the second
  scenario because it pressure-tests the same app/web shape outside the
  task-board domain while staying small and non-live.
delta: mounted surface: `web/signal_inbox.rb` should expose one
  `signal_inbox` surface mounted at `/`, render from
  `SignalInbox#snapshot(recent_limit:)`, and keep Arbre presentation helpers,
  feedback copy, and marker names local to the surface module.
delta: visible regions: header counters for open/critical signals, compact
  feedback panel, signal cards, acknowledge form, escalate-with-note form, and
  recent activity list.
delta: stable markers: use `data-ig-poc-surface="operator_signal_inbox"`,
  `data-open-count`, `data-critical-count`, `data-ig-feedback`,
  `data-feedback-code`, `data-signal-id`, `data-signal-status`,
  `data-signal-severity`, `data-action="acknowledge-signal"`,
  `data-action="escalate-signal"`, `data-ig-activity="recent"`, and
  `data-activity-kind`.
delta: smoke proof should assert initial counts, blank-note refusal feedback,
  missing/closed refusal feedback if exercised, successful acknowledge,
  successful escalate, rendered recent action facts, and `/events` parity from
  the same snapshot.
delta: remain local: severity labels, feedback copy, activity labels, form
  action names, and marker vocabulary should not become `igniter-web` API until
  a later non-signal POC repeats them.
delta: recommendation: implement this scenario only as another app-local
  skeleton/example; do not add UI kit, component DSL, live transport, generator,
  `interactive_app`, Line-Up tooling, or package-level marker helpers.
verify: `git diff --check` passed for docs-only proposal.
ready: `[Architect Supervisor / Codex]` can accept `operator_signal_inbox`,
  pause the POC line, or request a smaller scenario.
block: none
