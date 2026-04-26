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
| `[Architect Supervisor / Codex]` | Review narrow Phase 3 ledger adapter implementation | [Host Activation Ledger Adapter Track](./application-capsule-host-activation-ledger-adapter-track.md) | [Activation Evidence Schema Track](./application-capsule-activation-evidence-schema-track.md), [Capsule Transfer Finalization Roadmap](./application-capsule-transfer-finalization-roadmap.md), [Constraint Sets](./constraints.md) | user |
| `[Agent Application / Codex]` | Implement file-backed host activation ledger adapter with refusal/idempotency/readback coverage | [Host Activation Ledger Adapter Track](./application-capsule-host-activation-ledger-adapter-track.md) | [Activation Evidence Schema Track](./application-capsule-activation-evidence-schema-track.md), [Host Activation Commit Readiness Track](./application-capsule-host-activation-commit-readiness-track.md), [Application Capsules Guide](../guide/application-capsules.md) | `[Architect Supervisor / Codex]` |
| `[Agent Web / Codex]` | Guard web boundary; confirm no mount/route/Rack/browser/rendering behavior entered Phase 3 | [Host Activation Ledger Adapter Track](./application-capsule-host-activation-ledger-adapter-track.md) | [Activation Evidence Schema Track](./application-capsule-activation-evidence-schema-track.md), [Application Capsules Guide](../guide/application-capsules.md) | `[Architect Supervisor / Codex]` |
| `[Research Horizon / Codex]` | Standby; full interactive app facade remains deferred | [Interactive Operator DSL Proposals](../research-horizon/interactive-operator-dsl-proposals.md) | [Expert Review](../experts/expert-review.md), [Interactive App DSL Proposal](../experts/interactive-app-dsl.md) | `[Architect Supervisor / Codex]` when research resumes |
| `[Agent Embed / Codex]` | Standby for private SparkCRM/Contractable pressure feedback | [Embed Contract Class Integration Track](./embed-contract-class-integration-track.md) | [Differential Shadow Contractable Track](./differential-shadow-contractable-track.md), [Human Sugar DSL Doctrine](./human-sugar-dsl-doctrine.md) | `[Architect Supervisor / Codex]` |
| `[Agent Contracts / Codex]` | Standby for `StepResultPack` review and future shared seams | [Embed Contract Class Integration Track](./embed-contract-class-integration-track.md) | [Contracts And Extensions Stewardship](./contracts-extensions-stewardship.md), [Igniter Contracts Spec](./igniter-contracts-spec.md) | `[Architect Supervisor / Codex]` |

## Current Cycle

[Architect Supervisor / Codex] Current compact state:

- Interactive operator POC is the active live pressure-test line.
- Accepted POC chain: task board skeleton -> feedback/refusal -> action ledger
  -> command result -> read snapshot -> pattern guide -> signal inbox repeat.
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
- Repeatability synthesis is accepted; the pattern is guide-level convention,
  not package API.
- Current line returns to capsule transfer:
  [Capsule Transfer Finalization Roadmap](./application-capsule-transfer-finalization-roadmap.md).
- Activation Evidence And Receipt accepted the right vocabulary.
- External expert report accepted as strategic reference, not implementation
  mandate:
  [Capsule Transfer Expert Report](../experts/capsule-transfer-expert-report.md).
- Whole-project strategic expert report accepted as reference framing, not as
  an immediate track replacement:
  [Igniter Strategic Report](../experts/igniter-strategic-report.md).
- Activation Evidence Schema accepted the normative application schema and
  metadata-only mount boundary.
- Next active track is narrow implementation:
  [Host Activation Ledger Adapter Track](./application-capsule-host-activation-ledger-adapter-track.md).
- `examples/lineup` is research sandbox only; do not replace active compact
  handoffs with Line-Up.

## Active Review

### Current Accepted POC State

Status: paused after repeatability; guide consolidation can resume later.

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
- [Second Scenario](./application-web-poc-second-scenario-track.md): accepted
  `operator_signal_inbox`.
- [Signal Inbox](./application-web-poc-signal-inbox-track.md): second app-local
  POC with signal commands, snapshot, web surface, and smoke coverage.
- [Repeatability Synthesis](./application-web-poc-repeatability-synthesis-track.md):
  guide-level convention accepted; package API deferred.

Verification gate observed for latest slice:

- `ruby examples/application/interactive_web_poc.rb` passed.
- `ruby examples/run.rb smoke` passed with 74 examples and 0 failures.
- `bundle exec rubocop examples/application/interactive_web_poc.rb examples/application/interactive_operator examples/catalog.rb`
  passed with no offenses.
- `git diff --check` passed.

### Process State

Status: capsule transfer finalization reopened.

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

- Boundary review accepted only a narrow possible Phase 3; Application/Web
  agents completed the evidence schema pass.
- Phase 3 opens only for a file-backed activation ledger adapter; real host
  activation and web mount behavior remain out of scope.
