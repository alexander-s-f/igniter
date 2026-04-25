# Active Tracks

This is the first file agents should read. It is intentionally compact.

Full accepted/history context lives in [Tracks History](./tracks-history.md).
Reusable active-track boundaries live in [Constraint Sets](./constraints.md).
Long-range research context lives in [Research Horizon](../research-horizon/README.md)
and external expert input lives in [Experts](../experts/README.md).

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

## Protocol

1. Read this file.
2. Find your role in **Active Handoffs**.
3. Read only the linked track and explicitly listed dependencies.
4. Apply any named constraint sets cited by the track.
5. Append a compact labeled handoff to the track you changed.
6. Return the compact status format below.

Do not paste long summaries of unrelated tracks. If a task needs historical
context, read only the linked history entry or dependency.

## Compact Status

```text
[Agent Role / Codex]
track: <path>
status: landed | blocked | needs-review
delta: <changed files, one line each>
verify: <tier/result>
ready: <who can proceed>
block: none | <blocker>
```

## Active Handoffs

| Agent | Current Task | Start Here | Dependencies | Return To |
| --- | --- | --- | --- | --- |
| `[Architect Supervisor / Codex]` | Maintain compact active index, constraint sets, and next small implementation/process slice | [Agent Cycle Optimization](../experts/agent-cycle-optimization.md) | [Constraint Sets](./constraints.md), [Application Web POC Feedback Track](./application-web-poc-feedback-track.md), [Tracks History](./tracks-history.md) | user |
| `[Agent Application / Codex]` | Add app-local action ledger and `/events` read model under `:interactive_poc_guardrails` | [Application Web POC Action Log Track](./application-web-poc-action-log-track.md) | [Constraint Sets](./constraints.md), [Application Web POC Feedback Track](./application-web-poc-feedback-track.md), [Application Web POC Task Creation Track](./application-web-poc-task-creation-track.md), [Application Rack Host DSL Track](./application-rack-host-dsl-track.md) | `[Architect Supervisor / Codex]` |
| `[Agent Web / Codex]` | Render recent activity from app-owned state under `:interactive_poc_guardrails` | [Application Web POC Action Log Track](./application-web-poc-action-log-track.md) | [Constraint Sets](./constraints.md), [Application Web POC Feedback Track](./application-web-poc-feedback-track.md), [Application Web POC Skeleton Track](./application-web-poc-skeleton-track.md) | `[Architect Supervisor / Codex]` |
| `[Research Horizon / Codex]` | Standby; full interactive app facade remains deferred | [Interactive Operator DSL Proposals](../research-horizon/interactive-operator-dsl-proposals.md) | [Expert Review](../experts/expert-review.md), [Interactive App DSL Proposal](../experts/interactive-app-dsl.md) | `[Architect Supervisor / Codex]` when research resumes |
| `[Agent Embed / Codex]` | Standby for private SparkCRM/Contractable pressure feedback | [Embed Contract Class Integration Track](./embed-contract-class-integration-track.md) | [Differential Shadow Contractable Track](./differential-shadow-contractable-track.md), [Human Sugar DSL Doctrine](./human-sugar-dsl-doctrine.md) | `[Architect Supervisor / Codex]` |
| `[Agent Contracts / Codex]` | Standby for `StepResultPack` review and future shared seams | [Embed Contract Class Integration Track](./embed-contract-class-integration-track.md) | [Contracts And Extensions Stewardship](./contracts-extensions-stewardship.md), [Igniter Contracts Spec](./igniter-contracts-spec.md) | `[Architect Supervisor / Codex]` |

## Current Cycle

[Architect Supervisor / Codex] Current compact state:

- Interactive operator POC is the active live pressure-test line.
- Accepted chain: skeleton -> `Application.rack_app` -> task creation ->
  feedback/refusal visibility.
- Research/expert proposals are useful, but full `interactive_app`, UI kit,
  Plane/canvas, flow/chat/proactive agent DSL, SSE/live updates, generator, and
  production server layer remain deferred.
- Agent-cycle optimization has started with the highest-impact change:
  `tracks.md` is now active-only; historical context moved to
  [Tracks History](./tracks-history.md).
- Constraint shorthand is now available for new active tracks:
  [Constraint Sets](./constraints.md).
- Next implementation slice is opened as a compact action-log pressure test:
  [Application Web POC Action Log Track](./application-web-poc-action-log-track.md).

## Active Review

### Application Web POC Feedback

Status: landed and accepted.

Track:

- [Application Web POC Feedback Track](./application-web-poc-feedback-track.md)

Current result:

- App-local query-string feedback landed.
- Blank task creation redirects with `error=blank_title` and does not mutate.
- Successful create/resolve redirects with known `notice` codes.
- Web surface renders compact known-code feedback markers.
- Smoke proves blank refusal, create feedback, resolve feedback, and final
  open-task count.

Acceptance gate already observed:

- `ruby examples/application/interactive_web_poc.rb` passed.
- `ruby examples/run.rb smoke` passed with 74 examples and 0 failures.
- `bundle exec rubocop examples/application/interactive_web_poc.rb examples/application/interactive_operator examples/catalog.rb`
  passed with no offenses.
- `git diff --check` passed.

Accepted decision:

- Feedback POC accepted.
- Keep next implementation compact; do not jump to full `interactive_app`.

### Agent Cycle Optimization

Status: active supervisor protocol change.

Source:

- [Agent Cycle Optimization](../experts/agent-cycle-optimization.md)

Accepted now:

- Proposal 1: split active tracks from history.
- Proposal 2, narrowed: shared constraint registry for new active tracks only.

Deferred:

- full micro-format enforcement beyond the compact status template above
- parallel task windows
- graduated verification tiers
- track retirement automation

Active constraint sets:

- `:interactive_poc_guardrails`
- `:activation_safety`
- `:research_only`
- `:embed_shadow_safety`
- `:human_sugar_parallel_form`

Next possible process slice:

- Either use constraint sets in the next implementation track, or add a minimal
  verification-tier vocabulary if agent handoffs remain too verbose.

### Application Web POC Action Log

Status: ready for agent implementation.

Track:

- [Application Web POC Action Log Track](./application-web-poc-action-log-track.md)

Constraint set:

- `:interactive_poc_guardrails`

Accepted next slice:

- Add a small app-local action ledger.
- Let `/events` expose open count plus action facts.
- Let the board render recent activity from app-owned state.
- Keep this as observability pressure inside the POC, not live transport,
  persistence, or a UI framework.
