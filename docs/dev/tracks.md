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
| `[Architect Supervisor / Codex]` | Review Dispatch finalization and decide showcase-ready status | [Application Dispatch Showcase Finalization Track](./application-dispatch-showcase-finalization-track.md) | [Application Dispatch Implementation Track](./application-dispatch-implementation-track.md), [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md), [Constraint Sets](./constraints.md) | user |
| `[Agent Application / Codex]` | Finalize Dispatch app/docs/discoverability after bounded implementation | [Application Dispatch Showcase Finalization Track](./application-dispatch-showcase-finalization-track.md) | [Application Dispatch Implementation Track](./application-dispatch-implementation-track.md), [Application Showcase Convention Consolidation Track](./application-showcase-convention-consolidation-track.md), [Constraint Sets](./constraints.md) | `[Architect Supervisor / Codex]` |
| `[Agent Web / Codex]` | Finalize Dispatch Web/manual review readiness after bounded implementation | [Application Dispatch Showcase Finalization Track](./application-dispatch-showcase-finalization-track.md) | [Application Dispatch Implementation Track](./application-dispatch-implementation-track.md), [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md), [Constraint Sets](./constraints.md) | `[Architect Supervisor / Codex]` |
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
- Application proposals are accepted as future showcase/reference-app backlog,
  not as the current active track:
  [Application Proposals](../experts/application-proposals.md).
- Activation Evidence Schema accepted the normative application schema and
  metadata-only mount boundary.
- Host Activation Ledger Adapter accepted the narrow Phase 3 proof.
- Host Activation Ledger Verification Receipt accepted Phase 4 over the
  ledger proof.
- Activation Guide Consolidation accepted capsule transfer/activation as
  finalized-for-now.
- Next active track selects the first real showcase/reference app:
  [Application Showcase Selection Track](./application-showcase-selection-track.md).
- Lense application slice and Web dashboard/workbench slice have landed in the
  showcase selection track.
- Next active track implements Lense as a bounded one-process POC:
  [Application Lense POC Implementation Track](./application-lense-poc-implementation-track.md).
- Lense POC implementation accepted: local scan, contract-backed analysis,
  dashboard/workbench, guided session actions, `/events`, report output, and
  no scanned-project mutation.
- Next active track finalizes Lense as a discoverable showcase:
  [Application Lense Showcase Finalization Track](./application-lense-showcase-finalization-track.md).
- Lense discoverability docs and Web readiness review have landed; supervisor
  accepted Lense as showcase-ready.
- New `igniter-lang` expert report is research-only context, not an active
  feature proposal:
  [Igniter Lang Research](../experts/igniter-lang/igniter-lang.md).
- Next active track synthesizes app/web POC patterns before adding more scope:
  [Application Showcase Synthesis Track](./application-showcase-synthesis-track.md).
- App-local and Web/read-model synthesis have landed; both recommend Chronicle
  showcase scoping next under offline one-process guardrails.
- Showcase synthesis accepted; repeated app/web shapes remain guide-level
  convention, not public facade/API.
- Next active track scopes Chronicle as the second product/app pressure test:
  [Application Chronicle Scoping Track](./application-chronicle-scoping-track.md).
- Chronicle app-local and Web scoping have landed; supervisor can decide
  whether to open bounded implementation.
- Chronicle scoping accepted; next active track implements the bounded
  offline one-process POC:
  [Application Chronicle Implementation Track](./application-chronicle-implementation-track.md).
- Chronicle app-local and Web implementation have landed; supervisor can
  review showcase readiness or request a finalization pass.
- Chronicle implementation accepted as a complete bounded POC; next active
  track finalizes discoverability and showcase readiness:
  [Application Chronicle Showcase Finalization Track](./application-chronicle-showcase-finalization-track.md).
- Chronicle app and Web finalization have landed; supervisor can decide whether
  Chronicle is showcase-ready beside Lense.
- Chronicle accepted as showcase-ready beside Lense.
- Next active track synthesizes the showcase portfolio before opening another
  app or package-support design track:
  [Application Showcase Portfolio Synthesis Track](./application-showcase-portfolio-synthesis-track.md).
- Showcase portfolio app-layer and Web/read-model synthesis have landed;
  supervisor can choose consolidation, tiny support design, or the next product
  pressure line.
- Showcase portfolio synthesis accepted; next active track consolidates
  conventions as docs/checklists before Scout or any support API work:
  [Application Showcase Convention Consolidation Track](./application-showcase-convention-consolidation-track.md).
- Showcase convention consolidation has landed for both app and Web; supervisor
  can choose Scout scoping, tiny support design, or docs finalization.
- Showcase convention consolidation accepted; next active track scopes Scout as
  an offline/local-source product pressure line:
  [Application Scout Scoping Track](./application-scout-scoping-track.md).
- Scout app and Web scoping have landed; supervisor can decide whether to open
  bounded Scout implementation or choose a support/design pass.
- Scout scoping accepted; next active track implements the bounded
  offline/local-source POC:
  [Application Scout Implementation Track](./application-scout-implementation-track.md).
- Scout implementation accepted as a complete bounded POC; next active track
  finalizes discoverability and showcase readiness:
  [Application Scout Showcase Finalization Track](./application-scout-showcase-finalization-track.md).
- Scout accepted as showcase-ready beside Lense and Chronicle.
- Next active track updates the showcase portfolio and chooses the next
  strategic line:
  [Application Showcase Portfolio Update Track](./application-showcase-portfolio-update-track.md).
- Showcase portfolio update accepted; next active track designs the tiny
  evidence/smoke proof convention before Dispatch/helper/Embed decisions:
  [Application Showcase Evidence And Smoke Design Track](./application-showcase-evidence-smoke-design-track.md).
- Showcase evidence/smoke design accepted; next active track scopes Dispatch as
  an offline/fixture-backed incident command pressure line:
  [Application Dispatch Scoping Track](./application-dispatch-scoping-track.md).
- Dispatch scoping accepted; next active track implements the bounded
  offline/fixture-backed incident command POC:
  [Application Dispatch Implementation Track](./application-dispatch-implementation-track.md).
- Dispatch implementation accepted as a complete bounded POC; next active track
  finalizes discoverability and manual review readiness:
  [Application Dispatch Showcase Finalization Track](./application-dispatch-showcase-finalization-track.md).
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
- Phase 3 file-backed activation ledger proof is accepted.
- Phase 4 ledger verification and activation receipt are accepted.
- Capsule transfer/activation is finalized-for-now; real host activation and
  web mount behavior remain out of scope.
- Next step is a practical one-process showcase app selection, with Lense as
  the accepted candidate.
- Lense is showcase-ready; next step is synthesis across existing app/web POCs
  before opening another implementation track.
