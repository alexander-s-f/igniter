# Active Tracks

This is the first file agents should read. It is intentionally compact.

Full accepted/history context lives in [Tracks History](./tracks-history.md).
Reusable active-track boundaries live in [Constraint Sets](./constraints.md).
The lifecycle pattern is captured in
[Agent Track Lifecycle Doctrine](./agent-track-lifecycle-doctrine.md).
Documentation compression rules live in
[Documentation Compression Doctrine](./documentation-compression-doctrine.md).
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
| `[Architect Supervisor / Codex]` | Review second non-task POC scenario and decide whether to implement or pause | [Application Web POC Second Scenario Track](./application-web-poc-second-scenario-track.md) | [Application Web POC Pattern Guide Track](./application-web-poc-pattern-guide-track.md), [Documentation Compression Doctrine](./documentation-compression-doctrine.md), [Constraint Sets](./constraints.md) | user |
| `[Agent Application / Codex]` | Propose app-local seams for a second non-task POC scenario | [Application Web POC Second Scenario Track](./application-web-poc-second-scenario-track.md) | [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md), [Application Web POC Pattern Guide Track](./application-web-poc-pattern-guide-track.md) | `[Architect Supervisor / Codex]` |
| `[Agent Web / Codex]` | Propose web surface and markers for a second non-task POC scenario | [Application Web POC Second Scenario Track](./application-web-poc-second-scenario-track.md) | [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md), [Application Web POC Pattern Guide Track](./application-web-poc-pattern-guide-track.md) | `[Architect Supervisor / Codex]` |
| `[Research Horizon / Codex]` | Standby; full interactive app facade remains deferred | [Interactive Operator DSL Proposals](../research-horizon/interactive-operator-dsl-proposals.md) | [Expert Review](../experts/expert-review.md), [Interactive App DSL Proposal](../experts/interactive-app-dsl.md) | `[Architect Supervisor / Codex]` when research resumes |
| `[Agent Embed / Codex]` | Standby for private SparkCRM/Contractable pressure feedback | [Embed Contract Class Integration Track](./embed-contract-class-integration-track.md) | [Differential Shadow Contractable Track](./differential-shadow-contractable-track.md), [Human Sugar DSL Doctrine](./human-sugar-dsl-doctrine.md) | `[Architect Supervisor / Codex]` |
| `[Agent Contracts / Codex]` | Standby for `StepResultPack` review and future shared seams | [Embed Contract Class Integration Track](./embed-contract-class-integration-track.md) | [Contracts And Extensions Stewardship](./contracts-extensions-stewardship.md), [Igniter Contracts Spec](./igniter-contracts-spec.md) | `[Architect Supervisor / Codex]` |

## Current Cycle

[Architect Supervisor / Codex] Current compact state:

- Interactive operator POC is the active live pressure-test line.
- Accepted POC chain: skeleton -> `Application.rack_app` -> task creation ->
  feedback/refusal visibility -> action ledger/recent activity -> command
  result -> board snapshot/read model.
- Research/expert proposals are useful, but full `interactive_app`, UI kit,
  Plane/canvas, flow/chat/proactive agent DSL, SSE/live updates, generator, and
  production server layer remain deferred.
- Agent-cycle optimization has started with the highest-impact change:
  `tracks.md` is now active-only; historical context moved to
  [Tracks History](./tracks-history.md).
- Constraint shorthand is now available for new active tracks:
  [Constraint Sets](./constraints.md).
- The emerging agent workflow is captured as a reusable lifecycle doctrine:
  [Agent Track Lifecycle Doctrine](./agent-track-lifecycle-doctrine.md).
- Expert formalization is accepted as reference vocabulary, not as an
  implementation mandate:
  [Agent Track Pattern](../experts/agent-track-pattern.md).
- Next slice is docs-only second scenario selection:
  [Application Web POC Second Scenario Track](./application-web-poc-second-scenario-track.md).
- `examples/lineup` is research sandbox only; do not replace active compact
  handoffs with Line-Up.

## Active Review

### Current Accepted POC State

Status: pattern guide landed and accepted.

Accepted slices:

- [Feedback](./application-web-poc-feedback-track.md): app-local feedback and
  blank refusal.
- [Action Log](./application-web-poc-action-log-track.md): deterministic action
  ledger and recent activity.
- [Command Result](./application-web-poc-command-result-track.md): unified
  app-local command result shape.
- [Read Model](./application-web-poc-read-model-track.md): app-local
  `BoardSnapshot` consumed by `/events` and the web board.
- [Structure Synthesis](./application-web-poc-structure-synthesis-track.md):
  app-local and web-local pattern findings.
- [Pattern Guide](./application-web-poc-pattern-guide.md): compact copyable
  app/web structure note.

Verification gate observed for latest slice:

- `ruby examples/application/interactive_web_poc.rb` passed.
- `ruby examples/run.rb smoke` passed with 74 examples and 0 failures.
- `bundle exec rubocop examples/application/interactive_web_poc.rb examples/application/interactive_operator examples/catalog.rb`
  passed with no offenses.
- `git diff --check` passed.

### Process State

Status: active supervisor compression pass.

Accepted:

- Active tracks/history split.
- Constraint sets for reusable boundaries.
- Agent lifecycle doctrine and expert track-pattern vocabulary.
- Documentation compression doctrine, narrowed to manual active-context hygiene.
- Line-Up research sandbox acknowledged; not accepted as active tooling.

Deferred:

- front-matter conversion, generators, validators, automated history
  compression, native track compiler, and native agent execution.

Next:

- Application/Web agents should propose a second non-task scenario before any
  new POC implementation.
