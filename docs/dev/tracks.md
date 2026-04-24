# Active Tracks Index

This is the first file agents should read when they need current architecture
state, ownership, or next tasks.

The goal is context efficiency:

- read this index first
- drill down only into your active track and direct cross-agent dependencies
- report back compactly with changed files, accepted items, blockers, and next
  requested handoff

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Package agents should keep reporting with their role labels:

```text
[Agent Contracts / Codex]
[Agent Extensions / Codex]
[Agent Embed / Codex]
[Agent Application / Codex]
[Agent Web / Codex]
[Agent Cluster / Codex]
```

`[Agent Contracts / Codex]` currently absorbs `[Agent Extensions / Codex]` for
work in `packages/igniter-contracts` and `packages/igniter-extensions`. See
[Contracts And Extensions Stewardship](./contracts-extensions-stewardship.md).

## Agent Drill-Down Protocol

1. Read this file.
2. Find your agent role in **Active Handoffs**.
3. Read only the linked track document and any explicitly named dependency
   document.
4. Do the task.
5. Append a short labeled handoff note to the track you changed.
6. Return a compact status:

```text
[Agent X / Codex]
Track: <track name>
Changed: <files or docs>
Accepted/Ready: <yes/no + why>
Verification: <commands and result>
Needs: <next agent or supervisor decision>
```

Do not paste long summaries of unrelated tracks. If a track references private
pressure-test material, mention only the public conclusion unless the current
task explicitly requires private details.

## Active Handoffs

| Agent | Current Task | Start Here | Dependencies | Return To |
| --- | --- | --- | --- | --- |
| `[Agent Embed / Codex]` | Discovery hardening and private SparkCRM host cleanup | [Embed Contract Class Integration Track](./embed-contract-class-integration-track.md) | [Embed Target Plan](./embed-target-plan.md), [Contract Class DSL Guide](../guide/contract-class-dsl.md), private SparkCRM track if directed | `[Architect Supervisor / Codex]` |
| `[Agent Contracts / Codex]` | Narrow optional `StepResultPack` slice landed; awaiting review | [Embed Contract Class Integration Track](./embed-contract-class-integration-track.md) | [Igniter Contracts Spec](./igniter-contracts-spec.md) | `[Architect Supervisor / Codex]`; then `[Agent Embed / Codex]` for pressure-test feedback |
| `[Agent Contracts / Codex]` | Contracts/extensions stewardship; standby for future `DifferentialPack` seams | [Contracts And Extensions Stewardship](./contracts-extensions-stewardship.md) | [Differential Shadow Contractable Track](./differential-shadow-contractable-track.md), [Igniter Contracts Spec](./igniter-contracts-spec.md) | `[Architect Supervisor / Codex]`; `[Agent Embed / Codex]` if a seam is requested |
| `[Agent Embed / Codex]` | Collect private `Contractable` Rails pressure-test findings | [Differential Shadow Contractable Track](./differential-shadow-contractable-track.md) | [Embed Contract Class Integration Track](./embed-contract-class-integration-track.md), `DifferentialPack` in `igniter-extensions`, private SparkCRM track if directed | `[Architect Supervisor / Codex]`; then `[Agent Contracts / Codex]` only if `DifferentialPack` needs a seam |
| `[Agent Embed / Codex]` | Standby for Human Sugar DSL pressure feedback and small docs fixes | [Human Sugar DSL Doctrine](./human-sugar-dsl-doctrine.md) | [Differential Shadow Contractable Track](./differential-shadow-contractable-track.md), [Embed Contract Class Integration Track](./embed-contract-class-integration-track.md), private SparkCRM track if directed | `[Architect Supervisor / Codex]` |
| `[Agent Application / Codex]` | User-facing application capsule guide and current structure alignment | [Application Capsule Guide Track](./application-capsule-guide-track.md) | [Application Capsule Inspection Track](./application-capsule-inspection-track.md), [Application Structure Research](./application-structure-research.md), [App Guide](../guide/app.md), [Current App Structure](../current/app-structure.md) | `[Architect Supervisor / Codex]`; `[Agent Web / Codex]` for web surface guide wording |
| `[Agent Web / Codex]` | Web-as-surface guide notes for application capsules | [Application Capsule Guide Track](./application-capsule-guide-track.md) | [Application Capsule Inspection Track](./application-capsule-inspection-track.md), [Application/Web Integration Tasks](./application-web-integration-tasks.md), [Igniter Web Target Plan](./igniter-web-target-plan.md) | `[Architect Supervisor / Codex]`; `[Agent Application / Codex]` for shared guide wording |

## Track Map

### Broad Cycle Snapshot

[Architect Supervisor / Codex] Current cycle status after the Embed/SparkCRM
pressure-test wave:

- Human Sugar DSL for Embed is stabilized and documented.
- Contractable shadowing, observed services, discovery probes, generated
  runners, visible adapters, typed events, and explicit-target capability
  attachments are accepted at the Embed layer.
- No new lower-layer `igniter-contracts` or `igniter-extensions` seam is needed
  for capability attachments yet.
- Application/Web and Agent-Native sessions have a landed metadata-first flow
  snapshot/read-model path.
- Optional feature-slice reporting, app-owned flow declarations, and web-owned
  surface projection reports have landed.
- Capsule inspection landed as one compact application-owned read model over
  layout, manifest, feature, flow, and optional surface metadata.
- The next broad track is user-facing capsule documentation and current app
  structure alignment.

### Embed And Contract Class DSL

Status: core class-contract/embed integration landed; `StepResultPack` review
still pending.

Primary track:

- [Embed Contract Class Integration Track](./embed-contract-class-integration-track.md)

Public user-facing guide:

- [Contract Class DSL](../guide/contract-class-dsl.md)

Current accepted state:

- `igniter-contracts` owns `Igniter::Contract`.
- `igniter-embed` consumes class contracts.
- `igniter-embed` supports host-level `config.contract SomeContract, as: :name`.
- `Container#register(Class < Igniter::Contract)` can infer a stable name from
  named contract classes and rejects anonymous classes without `as:`.
- `config.root` is host-local contract directory metadata; it does not load
  files by itself.
- `config.discover!` is opt-in discovery and `container.reload!` is the
  host-agnostic cache-clear boundary.
- Optional `StepResultPack` is implemented in `igniter-contracts` with
  `StepResult`, `step`, fail-fast dependency short-circuiting, and serializable
  step trace.
- Public examples exist under `examples/contracts/class_*.rb`.

Next:

- `[Architect Supervisor / Codex]`: review the narrow `StepResultPack`
  implementation when contracts work resumes.
- `[Agent Embed / Codex]`: standby for pressure feedback; do not add more
  Embed DSL breadth without new host pressure.

Private pressure tests:

- App-specific Rails/SparkCRM notes live outside this public track. Use only
  when explicitly directed by supervisor or user.

### Human Sugar DSL

Status: accepted surface documented; standby.

Primary track:

- [Human Sugar DSL Doctrine](./human-sugar-dsl-doctrine.md)

Current accepted state:

- Clean agent form and human sugar DSL form are both valid public authoring
  forms when they compile to the same lower-level model.
- Sugar is allowed to use controlled magic when it removes ceremony without
  hiding package boundaries.
- Embed and Contractable Rails-style host configuration is the current pressure
  point.
- Clean form remains supported and should be inspectable from sugar.
- User candidate syntax with `owner`, `path`, `contracts.add`,
  `contract.use`, and `contract.on` is accepted as the primary shape to
  evaluate in the proposal.
- `contract.use` should prefer contract-backed capabilities: if logging,
  reporting, validation, metrics, normalization, redaction, or acceptance can be
  represented as contracts, they should be represented as contracts.
- `[Agent Embed / Codex]` drafted the Task 1 proposal.
- `[Agent Contracts / Codex]` reviewed and accepted the direction with guardrails:
  sugar compiles to clean config, inspection is required, events stay typed,
  and lower-layer contracts/extensions seams wait until Embed proves pressure.
- `[Architect Supervisor / Codex]` accepted the proposal for narrow
  implementation.
- First slice landed and was accepted: `Igniter::Embed.host`, `owner`, `path`,
  `cache`, `contracts.add`, and `host.sugar_expansion.to_h`.
- Second slice landed and was accepted: `migration`, `observe`, `discover`,
  `shadow`, and `capture` fill the existing `Contractable::Config` shape and
  generated contractables appear in `host.sugar_expansion.to_h`.
- Supervisor correction landed: `contracts.add` creates a generated
  contractable only when its block actually configures contractable behavior;
  an empty block remains plain contract registration.
- Third slice landed and was accepted: `use :normalizer`, `use :redaction`,
  `use :acceptance`, and `use :store` map to existing `Contractable::Config`
  adapter slots and remain visible in `host.sugar_expansion.to_h`.
- Supervisor correction landed: `use :acceptance` without `policy:` raises
  `Igniter::Embed::SugarError`.
- Fourth slice landed and was accepted: typed `on` event hooks map to explicit
  observation events, `on :failure` is an alias family for typed failure events,
  and `:divergence` remains separate.
- Private SparkCRM pressure test completed. Accepted generic finding: the sugar
  shape is readable and inspectable, but generated contractables need an
  ergonomic host-level runner accessor/registry.
- `[Agent Contracts / Codex]` reviewed capability contracts after pressure test.
  Accepted: no lower-layer contracts/extensions seam is needed yet; capability
  attachment should start in Embed and promote only after repeated patterns
  prove common graph/runtime semantics.
- Generated contractable runner materialization landed and was accepted:
  `host.contractable(:name)` / `host.fetch_contractable(:name)` return cached
  runners, `host.contractable_names` lists generated runners, and expansion
  output includes the runner accessor.
- Explicit-target capability attachment landed and was accepted:
  `use :logging`, `use :reporting`, `use :metrics`, and `use :validation`
  require explicit host-owned targets, classify targets as `kind: :contract` or
  `kind: :callable_adapter`, and appear in `host.sugar_expansion.to_h`.
- Public docs/examples pass landed and was accepted:
  `packages/igniter-embed/README.md`, `examples/contracts/embed_human_sugar.rb`,
  and the active examples catalog document the accepted sugar surface with
  neutral public names.
- Verification passed: `bundle exec rspec packages/igniter-embed/spec`.
- Verification passed: `ruby examples/contracts/embed_human_sugar.rb` and
  `bundle exec rspec packages/igniter-embed/spec
  spec/current/example_scripts_spec.rb`.

Next:

- `[Agent Embed / Codex]`: standby for private pressure-test feedback and small
  docs/example corrections.
- `[Agent Embed / Codex]`: do not add more Human Sugar DSL breadth without new
  host pressure or supervisor direction.
- `[Agent Contracts / Codex]`: standby; no lower-layer seam is needed until
  repeated Embed capability implementations prove common graph/runtime
  semantics.

### Differential Shadow Contractable

Status: landed; pressure-tested through Embed sugar; standby for rollout
findings.

Primary track:

- [Differential Shadow Contractable Track](./differential-shadow-contractable-track.md)

Foundation stewardship:

- [Contracts And Extensions Stewardship](./contracts-extensions-stewardship.md)

Current accepted state:

- `DifferentialPack` already exists in `igniter-extensions` and is the
  comparison/reporting engine.
- `igniter-embed` is the right host-local layer for `Contractable`: wrapping
  legacy services, observed services, discovery probes, and contract-backed
  candidates.
- `Contractable` has roles: `:migration_candidate`, `:observed_service`, and
  `:discovery_probe`.
- `Contractable` has lightweight lifecycle stages such as `:captured`,
  `:profiled`, `:shadowed`, `:accepted`, `:promoted`, and `:retired`.
- Production shadow mode should run the legacy primary synchronously and the
  contract candidate asynchronously by default.
- Primary-only observed-service mode should work without a candidate.
- Persistence should start as a tiny app-supplied `store.record(observation)`
  protocol, not a heavy orchestration subsystem.
- Contractable comparison has two signals: objective diff `match` and rollout
  policy `accepted`.
- First built-in acceptance policies are `:exact`, `:completed`, and `:shape`;
  later predicates such as `one_of`, `in`, and `between` should fit behind the
  same policy surface.
- Packs should expose useful self-description through `PackManifest` metadata
  before adding any larger registry.
- Minimal `Igniter::Embed.contractable` implementation landed and reuses
  `DifferentialPack` through an embed-side adapter; no extensions seam was
  needed.
- `async true` now uses a local thread-backed adapter by default; `async false`
  uses inline execution for tests/debugging.
- Private Rails pressure testing informed Human Sugar DSL and runner
  materialization. Public status contains only generic findings.

Next:

- `[Agent Embed / Codex]`: standby for rollout feedback from private apps.
- `[Agent Embed / Codex]`: promote only generic conclusions here if private
  pressure changes public architecture.
- `[Agent Contracts / Codex]`: owns any future `DifferentialPack` seam because
  it now absorbs the former `[Agent Extensions / Codex]` role.

### Application/Web Integration

Status: mostly landed; maintenance and follow-up active.

Primary tracks:

- [Application/Web Integration Tasks](./application-web-integration-tasks.md)
- [Application And Web Integration](./application-web-integration.md)

Current accepted state:

- Application owns layout, manifest, mounts, sessions, and flow snapshots.
- Web owns mounts, surface structure, surface manifests, interaction targets,
  and web-to-application pending-state adapter.

Next:

- Continue narrow handoffs. Do not move web screen knowledge into
  `igniter-application`.

### Agent-Native Interaction Sessions

Status: resume/status policy landed; feature/flow declarations and capsule
inspection landed.

Primary track:

- [Agent-Native Interaction Session Track](./agent-native-interaction-session-track.md)

Related proposal:

- [Agent-Native Application Track Proposal](./agent-native-application-track-proposal.md)

Current accepted state:

- Application-owned flow session snapshots and events landed.
- Web-owned interaction metadata and adapter landed.
- Read model/adapter boundary accepted.
- Explicit `resume_flow` status, pending input/action, and artifact update
  semantics landed and were verified.

Next:

- Continue through [Application Capsule Guide Track](./application-capsule-guide-track.md).

### Application Structure And Capsules

Status: landed first pass; feature/flow metadata and capsule inspection landed;
guide/current-doc alignment is active.

Primary track:

- [Application Structure Research](./application-structure-research.md)

Current accepted state:

- App capsule is the portability boundary.
- Web is an optional surface inside the app capsule.
- Layout profiles, sparse structure plans, exports/imports, and web surface
  structure/manifest are landed.

Next:

- Continue through [Application Capsule Guide Track](./application-capsule-guide-track.md).
- Align or supersede `docs/current/app-structure.md` there.

### Application Feature Slice And Flow Declarations

Status: landed and accepted.

Primary track:

- [Application Feature Slice And Flow Declaration Track](./application-feature-slice-flow-track.md)

Dependencies:

- [Agent-Native Interaction Session Track](./agent-native-interaction-session-track.md)
- [Application Structure Research](./application-structure-research.md)
- [Application/Web Integration Tasks](./application-web-integration-tasks.md)

Current accepted state:

- Feature slices are optional reporting/organization metadata, not mandatory
  runtime boundaries.
- Flow declarations are app-owned metadata; active runtime state remains
  `FlowSessionSnapshot`.
- Web may expose flow-related candidate metadata, but application must not
  inspect web screen graphs.
- `Igniter::Web.flow_surface_projection(...)` is accepted as a web-owned
  inspection/reporting helper over plain hashes.

Next:

- Continue through [Application Capsule Inspection Track](./application-capsule-inspection-track.md).
- Keep browser transport, real agent runtime, cluster semantics, and automatic
  contract execution out of follow-up work.

### Application Capsule Inspection

Status: landed and accepted.

Primary track:

- [Application Capsule Inspection Track](./application-capsule-inspection-track.md)

Dependencies:

- [Application Feature Slice And Flow Declaration Track](./application-feature-slice-flow-track.md)
- [Application Structure Research](./application-structure-research.md)
- [Agent-Native Interaction Session Track](./agent-native-interaction-session-track.md)

Current accepted state:

- The capsule remains the portability boundary.
- `ApplicationCapsuleReport` aggregates existing explicit metadata instead of
  creating a loader, flow engine, browser transport, or contract executor.
- Application owns the report vocabulary.
- Web can supply plain enriched surface metadata with summary status, related
  flows/features, and nested projection hashes.

Next:

- Continue through [Application Capsule Guide Track](./application-capsule-guide-track.md).
- Keep future inspection refinements read-only and explicit.

### Application Capsule Guide

Status: next broad track.

Primary track:

- [Application Capsule Guide Track](./application-capsule-guide-track.md)

Dependencies:

- [Application Capsule Inspection Track](./application-capsule-inspection-track.md)
- [Application Structure Research](./application-structure-research.md)
- [Application/Web Integration Tasks](./application-web-integration-tasks.md)

Current accepted state:

- The model is stable enough for a first user-facing narrative.
- Guide wording should explain sparse-first capsules, optional feature slices,
  flow declarations, capsule reports, and web as an optional surface.
- This is a docs-first stabilization pass, not a new runtime API pass.

Next:

- `[Agent Application / Codex]`: write/align the user-facing application
  capsule guide and current app structure doc.
- `[Agent Web / Codex]`: add web-as-surface guide notes without coupling
  application to web.

### Cluster

Status: target planning.

Primary track:

- [Cluster Target Plan](./cluster-target-plan.md)

Dependencies:

- [Application Target Plan](./application-target-plan.md)
- [Embed Target Plan](./embed-target-plan.md)

Next:

- Keep cluster above Embed/Application. Do not pull distributed semantics into
  embedded contracts or local application host layers.

## Public Vs Private Track Rule

Public docs in `docs/dev/` should contain:

- package ownership
- architecture decisions
- generic tasks and acceptance
- cross-agent handoffs
- verification commands/results

Private pressure-test docs should contain:

- private app names and business logic
- concrete model/query/response details
- rollout notes for a private app
- evidence used to inform public design

When private evidence changes a public architecture decision, summarize the
generic conclusion in the public track and keep private specifics private.

## Compact Status Template

Use this when reporting after a cycle:

```text
[Agent Role / Codex]
Track: <public track path>
Status: <landed / needs review / blocked>
Changed:
- <path>
Verification:
- <command> => <result>
Accepted:
- <what is ready for next agent>
Needs:
- <next handoff or supervisor decision>
```

Keep the report short. Link files instead of copying code.
