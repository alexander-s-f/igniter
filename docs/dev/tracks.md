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
| `[Agent Application / Codex]` | Read-only transfer readiness report over handoff manifest and transfer inventory | [Application Capsule Transfer Readiness Track](./application-capsule-transfer-readiness-track.md) | [Application Capsule Transfer Inventory Track](./application-capsule-transfer-inventory-track.md), [Application Capsule Handoff Manifest Track](./application-capsule-handoff-manifest-track.md), [Application Capsule Transfer Guide Track](./application-capsule-transfer-guide-track.md) | `[Architect Supervisor / Codex]`; `[Agent Web / Codex]` for optional web metadata review |
| `[Agent Web / Codex]` | Compatibility review for optional web metadata in transfer readiness findings | [Application Capsule Transfer Readiness Track](./application-capsule-transfer-readiness-track.md) | [Application Capsule Transfer Inventory Track](./application-capsule-transfer-inventory-track.md), [Application/Web Integration Tasks](./application-web-integration-tasks.md), [Igniter Web Target Plan](./igniter-web-target-plan.md) | `[Architect Supervisor / Codex]`; `[Agent Application / Codex]` for readiness wording needs |

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
- User-facing capsule documentation and current app structure alignment have
  landed.
- Narrow human authoring DSL for capsules landed and compiles to
  `ApplicationBlueprint`.
- Read-only capsule composition landed: explicit import/export readiness across
  multiple capsules and host-supplied exports.
- Read-only capsule assembly plan landed over composition readiness, host
  metadata, optional surface metadata, and mount intents.
- Read-only capsule handoff manifests landed: portable transfer/wiring review
  now has a stable serializable artifact.
- Public transfer guide over capsule handoff manifests and host wiring review
  landed.
- Read-only dry-run transfer inventory for declared capsule material landed.
- The next broad track is a read-only transfer readiness report over handoff
  manifest and transfer inventory.

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

Status: landed and accepted.

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
- `docs/guide/application-capsules.md` is the first public user-facing
  narrative for the current capsule model.
- `docs/current/app-structure.md` records the current doctrine and points to the
  guide.

Next:

- Continue through [Application Capsule Authoring DSL Track](./application-capsule-authoring-dsl-track.md).
- Keep docs as the public reference while the DSL remains narrow.

### Application Capsule Authoring DSL

Status: landed and accepted.

Primary track:

- [Application Capsule Authoring DSL Track](./application-capsule-authoring-dsl-track.md)

Dependencies:

- [Application Capsule Guide Track](./application-capsule-guide-track.md)
- [Human Sugar DSL Doctrine](./human-sugar-dsl-doctrine.md)
- [Application Capsule Inspection Track](./application-capsule-inspection-track.md)

Current accepted state:

- Clean `ApplicationBlueprint` authoring remains valid.
- A human sugar form is allowed if it compiles to the same inspectable
  blueprint model.
- `Igniter::Application.capsule(...)` and `CapsuleBuilder` are accepted as the
  first human authoring DSL over `ApplicationBlueprint`.
- The DSL stays authoring sugar, not loading, execution, routing, or workflow
  runtime.

Next:

- Continue through [Application Capsule Composition Track](./application-capsule-composition-track.md).
- Keep future DSL additions pressure-driven and inspectable.

### Application Capsule Composition

Status: landed and accepted.

Primary track:

- [Application Capsule Composition Track](./application-capsule-composition-track.md)

Dependencies:

- [Application Capsule Authoring DSL Track](./application-capsule-authoring-dsl-track.md)
- [Application Capsule Inspection Track](./application-capsule-inspection-track.md)
- [Application Structure Research](./application-structure-research.md)

Current accepted state:

- Capsules expose explicit exports/imports.
- `ApplicationCompositionReport` is the read-only readiness report over
  explicit metadata, not a boot/mount/runtime/cluster mechanism.
- Clean blueprints and DSL capsules should both be accepted through
  `to_blueprint`.
- Matching is conservative exact `name` / `kind`; host satisfaction comes from
  explicit `host_exports`.

Next:

- Continue through [Application Capsule Assembly Plan Track](./application-capsule-assembly-plan-track.md).
- Keep composition read-only and explicit.

### Application Capsule Assembly Plan

Status: landed and accepted.

Primary track:

- [Application Capsule Assembly Plan Track](./application-capsule-assembly-plan-track.md)

Dependencies:

- [Application Capsule Composition Track](./application-capsule-composition-track.md)
- [Application Capsule Authoring DSL Track](./application-capsule-authoring-dsl-track.md)
- [Application Capsule Inspection Track](./application-capsule-inspection-track.md)

Current accepted state:

- `ApplicationAssemblyPlan` is the host-local read-only plan over explicit
  capsule inputs.
- It includes composition readiness, host exports/capabilities, surface
  metadata, and mount intents.
- `MountIntent` is metadata only.
- It does not boot, mount, route, discover, execute, or perform cluster
  placement.

Next:

- Continue through [Application Capsule Handoff Manifest Track](./application-capsule-handoff-manifest-track.md).
- Keep assembly as an inspection/plan boundary.

### Application Capsule Handoff Manifest

Status: landed and accepted.

Primary track:

- [Application Capsule Handoff Manifest Track](./application-capsule-handoff-manifest-track.md)

Dependencies:

- [Application Capsule Assembly Plan Track](./application-capsule-assembly-plan-track.md)
- [Application Capsule Composition Track](./application-capsule-composition-track.md)
- [Application Capsule Inspection Track](./application-capsule-inspection-track.md)

Current accepted state:

- A handoff manifest should be descriptive metadata for humans and agents.
- It may summarize capsule reports, composition readiness, assembly plan
  metadata, mount intents, and surface metadata.
- It must not package, copy, discover, load, boot, mount, route, execute, or
  perform cluster placement.
- `ApplicationHandoffManifest` and
  `Igniter::Application.handoff_manifest(...)` are accepted as the
  application-owned read-only handoff surface.
- Building from explicit capsules or an existing `ApplicationAssemblyPlan` is
  accepted.
- Web metadata remains caller-supplied plain hashes; `igniter-application`
  does not inspect web internals.

Next:

- Continue through [Application Capsule Transfer Guide Track](./application-capsule-transfer-guide-track.md).
- Keep the handoff manifest read-only and explicit.

### Application Capsule Transfer Guide

Status: landed and accepted.

Primary track:

- [Application Capsule Transfer Guide Track](./application-capsule-transfer-guide-track.md)

Dependencies:

- [Application Capsule Handoff Manifest Track](./application-capsule-handoff-manifest-track.md)
- [Application Capsule Assembly Plan Track](./application-capsule-assembly-plan-track.md)
- [Application Capsule Guide Track](./application-capsule-guide-track.md)

Current accepted state:

- The implementation is ready for a public narrative pass.
- Transfer review means reading explicit metadata, readiness, unresolved
  requirements, suggested host wiring, mount intents, and optional surface
  metadata.
- This track is documentation-first and must not introduce activation,
  copying, packaging, discovery, runtime mounting, routing, contract execution,
  or cluster placement.
- `docs/guide/application-capsules.md` now documents transfer/handoff review.
- `docs/current/app-structure.md` now records the read-only transfer chain.
- `packages/igniter-web/README.md` documents web-owned plain metadata helpers
  for handoff manifests without implying an application dependency on web.

Next:

- Continue through [Application Capsule Transfer Inventory Track](./application-capsule-transfer-inventory-track.md).
- Keep transfer review separate from runtime activation.

### Application Capsule Transfer Inventory

Status: landed and accepted.

Primary track:

- [Application Capsule Transfer Inventory Track](./application-capsule-transfer-inventory-track.md)

Dependencies:

- [Application Capsule Transfer Guide Track](./application-capsule-transfer-guide-track.md)
- [Application Capsule Handoff Manifest Track](./application-capsule-handoff-manifest-track.md)
- [Application Capsule Assembly Plan Track](./application-capsule-assembly-plan-track.md)

Current accepted state:

- The next bridge toward real portability is a dry-run inventory of declared
  capsule material.
- The inventory should report roots, active groups, expected paths, missing
  paths, and optionally safely enumerable files under explicit capsule roots.
- It must stay read-only and must not copy, archive, create, delete, autoload,
  boot, mount, route, execute, or coordinate clusters.
- Web path/surface details remain optional supplied metadata.
- `ApplicationTransferInventory` and
  `Igniter::Application.transfer_inventory(...)` are accepted as the
  application-owned read-only dry-run inventory surface.
- File enumeration constrained to explicit capsule roots and declared layout
  paths is accepted.
- `igniter-application` does not inspect web-local structure beyond supplied
  opaque metadata.

Next:

- Continue through [Application Capsule Transfer Readiness Track](./application-capsule-transfer-readiness-track.md).
- Keep transfer inventory read-only and separate from packaging/copying.

### Application Capsule Transfer Readiness

Status: next broad track.

Primary track:

- [Application Capsule Transfer Readiness Track](./application-capsule-transfer-readiness-track.md)

Dependencies:

- [Application Capsule Transfer Inventory Track](./application-capsule-transfer-inventory-track.md)
- [Application Capsule Handoff Manifest Track](./application-capsule-handoff-manifest-track.md)
- [Application Capsule Transfer Guide Track](./application-capsule-transfer-guide-track.md)

Current accepted state:

- Handoff manifests and transfer inventories are complementary review
  artifacts.
- The next useful artifact is a compact readiness report with blockers,
  warnings, finding sources, and stable `to_h`.
- It must compose existing explicit reports instead of duplicating
  import/export matching or file enumeration.
- It must not copy, archive, mutate, discover, load, boot, mount, route,
  execute, or coordinate clusters.

Next:

- `[Agent Application / Codex]`: implement the smallest transfer readiness
  value, facade, specs, and smoke example.
- `[Agent Web / Codex]`: verify optional web metadata remains supplied and
  opaque in readiness findings.

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
