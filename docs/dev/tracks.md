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
[Research Horizon / Codex]
```

`[Agent Contracts / Codex]` currently absorbs `[Agent Extensions / Codex]` for
work in `packages/igniter-contracts` and `packages/igniter-extensions`. See
[Contracts And Extensions Stewardship](./contracts-extensions-stewardship.md).

`[Research Horizon / Codex]` is not an implementation package agent. It works
in `docs/research-horizon/` on long-range architecture research, innovation,
and "step beyond the horizon" proposals. Its ideas graduate into `docs/dev/`
only after `[Architect Supervisor / Codex]` filters them into a narrow accepted
track.

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
| `[Agent Application / Codex]` | Verify read-only host activation plans before any future execution boundary | [Application Capsule Host Activation Plan Verification Track](./application-capsule-host-activation-plan-verification-track.md) | [Application Capsule Host Activation Plan Track](./application-capsule-host-activation-plan-track.md), [Application Capsule Host Activation Readiness Track](./application-capsule-host-activation-readiness-track.md) | `[Architect Supervisor / Codex]`; `[Agent Web / Codex]` for mount-intent verification boundary |
| `[Agent Web / Codex]` | Boundary review for web mount-intent verification metadata | [Application Capsule Host Activation Plan Verification Track](./application-capsule-host-activation-plan-verification-track.md) | [Application Capsule Host Activation Plan Track](./application-capsule-host-activation-plan-track.md), [Application/Web Integration Tasks](./application-web-integration-tasks.md), [Igniter Web Target Plan](./igniter-web-target-plan.md) | `[Architect Supervisor / Codex]`; `[Agent Application / Codex]` for verification wording needs |
| `[Research Horizon / Codex]` | Prepare Interaction Kernel read-only report synthesis | [Research Horizon Supervisor Review](../research-horizon/supervisor-review.md) | [Handoff Doctrine](./handoff-doctrine.md), [Horizon Proposals](../research-horizon/horizon-proposals.md), [Research Horizon](../research-horizon/README.md) | `[Architect Supervisor / Codex]` for filtering and graduation decision |

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
- Read-only transfer readiness report over handoff manifest and transfer
  inventory landed.
- Read-only transfer bundle plan landed.
- Explicit transfer bundle artifact writer from accepted bundle plans landed.
- Read-only verification/readback for transfer bundle artifacts landed.
- Read-only destination intake planning for verified transfer bundle artifacts
  landed.
- Read-only apply operation planning over accepted intake data landed.
- Explicit dry-run-first apply execution for reviewed transfer apply plans
  landed.
- Read-only post-apply verification for committed transfer results landed.
- Read-only transfer receipt/audit generation over explicit transfer reports
  landed and was accepted.
- User-facing transfer guide consolidation and compact end-to-end smoke path
  landed and were accepted.
- Post-transfer host integration boundary/checklist wording landed and was
  accepted without adding a new object.
- Read-only host activation readiness over explicit host decisions landed and
  was accepted.
- Read-only host activation planning over accepted readiness landed and was
  accepted.
- The next implementation track is read-only verification of host activation
  plans before any future execution boundary.
- `[Research Horizon / Codex]` joined as a long-range research role. Its work
  stays in `docs/research-horizon/` until `[Architect Supervisor / Codex]`
  graduates a proposal into a narrow `docs/dev/` implementation track.
- Research Horizon's Agent Handoff Protocol synthesis graduated into accepted
  docs-only [Handoff Doctrine](./handoff-doctrine.md), not a runtime object.

### Research Horizon

Status: active research, not implementation.

Primary area:

- [Research Horizon](../research-horizon/README.md)

Current research reports:

- [Current State Report](../research-horizon/current-state-report.md)
- [Horizon Proposals](../research-horizon/horizon-proposals.md)
- [Supervisor Review](../research-horizon/supervisor-review.md)

Current accepted state:

- `[Research Horizon / Codex]` explores innovation, long-range architecture,
  experimental system models, and Human <-> AI Agent interface directions.
- `[Architect Supervisor / Codex]` filters Horizon output, extracts the
  smallest useful next move, and decides what can graduate into `docs/dev/`.
- Research documents are allowed to be speculative, but must separate
  observation, proposal, risks, and implementation readiness.
- Research does not authorize code changes or package tracks by itself.

Near-term supervisor filter:

- First graduated candidate accepted: [Handoff Doctrine](./handoff-doctrine.md).
- Next review candidate: Interaction Kernel read-only report synthesis.
- Runtime Observatory Graph remains promising but should wait until a smaller
  handoff/interaction vocabulary is clearer.

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

Status: landed and accepted.

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
- `ApplicationTransferReadiness` and
  `Igniter::Application.transfer_readiness(...)` are accepted as the
  application-owned read-only decision surface.
- Stable findings with `severity`, `source`, `code`, `message`, and `metadata`
  are accepted.
- Web metadata remains supplied/opaque; application may count surface names but
  must not inspect web internals.

Next:

- Continue through [Application Capsule Transfer Bundle Plan Track](./application-capsule-transfer-bundle-plan-track.md).
- Keep readiness read-only and separate from packaging/copying.

### Application Capsule Transfer Bundle Plan

Status: landed and accepted.

Primary track:

- [Application Capsule Transfer Bundle Plan Track](./application-capsule-transfer-bundle-plan-track.md)

Dependencies:

- [Application Capsule Transfer Readiness Track](./application-capsule-transfer-readiness-track.md)
- [Application Capsule Transfer Inventory Track](./application-capsule-transfer-inventory-track.md)
- [Application Capsule Handoff Manifest Track](./application-capsule-handoff-manifest-track.md)

Current accepted state:

- The next useful artifact is a read-only bundle plan for a future package/copy
  operation.
- It should summarize subject, capsules, included files, missing paths,
  supplied surfaces, blockers, warnings, and policy.
- It must compose existing readiness/inventory/manifest artifacts instead of
  duplicating their logic.
- It must not copy, archive, write, mutate, discover, load, boot, mount, route,
  execute, or coordinate clusters.
- `ApplicationTransferBundlePlan` and
  `Igniter::Application.transfer_bundle_plan(...)` are accepted as the
  application-owned read-only plan surface.
- Included files must come only from transfer inventory.
- `bundle_allowed` is false by default when readiness is false; explicit
  `allow_not_ready` remains review-only planning.

Next:

- Continue through [Application Capsule Transfer Bundle Artifact Track](./application-capsule-transfer-bundle-artifact-track.md).
- Keep artifact writing explicit and bounded by the bundle plan.

### Application Capsule Transfer Bundle Artifact

Status: landed and accepted.

Primary track:

- [Application Capsule Transfer Bundle Artifact Track](./application-capsule-transfer-bundle-artifact-track.md)

Dependencies:

- [Application Capsule Transfer Bundle Plan Track](./application-capsule-transfer-bundle-plan-track.md)
- [Application Capsule Transfer Readiness Track](./application-capsule-transfer-readiness-track.md)
- [Application Capsule Transfer Inventory Track](./application-capsule-transfer-inventory-track.md)

Current accepted state:

- The next useful artifact is a tiny explicit writer from a bundle plan.
- The writer must require explicit output and refuse overwrite by default.
- It must include only files already listed by the bundle plan and embed
  serializable review metadata.
- It must not discover, install, extract, load, boot, mount, route, execute, or
  coordinate clusters.
- `ApplicationTransferBundleArtifact`,
  `ApplicationTransferBundleArtifactResult`, and
  `Igniter::Application.write_transfer_bundle(...)` are accepted as the
  application-owned explicit artifact writer.
- Directory artifact shape with `files/` plus
  `igniter-transfer-bundle.json` metadata is accepted.
- Default refusal when `bundle_allowed` is false, output exists, or parent is
  missing without `create_parent: true` is accepted.

Next:

- Continue through [Application Capsule Transfer Bundle Verification Track](./application-capsule-transfer-bundle-verification-track.md).
- Keep artifact verification read-only.

### Application Capsule Transfer Bundle Verification

Status: landed and accepted.

Primary track:

- [Application Capsule Transfer Bundle Verification Track](./application-capsule-transfer-bundle-verification-track.md)

Dependencies:

- [Application Capsule Transfer Bundle Artifact Track](./application-capsule-transfer-bundle-artifact-track.md)
- [Application Capsule Transfer Bundle Plan Track](./application-capsule-transfer-bundle-plan-track.md)
- [Application Capsule Transfer Inventory Track](./application-capsule-transfer-inventory-track.md)

Current accepted state:

- The next useful artifact was read-only verification of a written transfer
  bundle artifact.
- `ApplicationTransferBundleVerification` and
  `Igniter::Application.verify_transfer_bundle(path)` are accepted as the
  application-owned artifact readback surface.
- Verification reads the explicit artifact path, parses metadata, compares
  planned files with actual files, and reports mismatches.
- It must not install, extract, copy into a destination, load, boot, mount,
  route, execute, or coordinate clusters.
- Web metadata remains supplied and opaque.
- Verification passed on 2026-04-25 with application/current specs, web
  skeleton specs, examples, and RuboCop.

Next:

- Continue through [Application Capsule Transfer Intake Plan Track](./application-capsule-transfer-intake-plan-track.md).
- Keep receiving-side planning read-only and explicit.

### Application Capsule Transfer Intake Plan

Status: landed and accepted.

Primary track:

- [Application Capsule Transfer Intake Plan Track](./application-capsule-transfer-intake-plan-track.md)

Dependencies:

- [Application Capsule Transfer Bundle Verification Track](./application-capsule-transfer-bundle-verification-track.md)
- [Application Capsule Transfer Bundle Artifact Track](./application-capsule-transfer-bundle-artifact-track.md)
- [Application Capsule Transfer Bundle Plan Track](./application-capsule-transfer-bundle-plan-track.md)

Current accepted state:

- The next useful artifact was a read-only receiving-side intake plan for a
  verified transfer bundle.
- `ApplicationTransferIntakePlan` and
  `Igniter::Application.transfer_intake_plan(...)` are accepted as the
  application-owned receiving-side review surface.
- Intake planning accepts an explicit verified bundle or artifact path and
  an explicit destination root.
- It reports planned destination paths, conflicts, blockers, warnings,
  required host wiring, supplied surface metadata count, and stable `to_h`.
- It must not extract, copy, write, install, load, boot, mount, route, execute,
  or coordinate clusters.
- Web metadata remains supplied and opaque.
- Intake planning passed on 2026-04-25 with application/current specs, web
  skeleton specs, examples, and RuboCop.

Next:

- Continue through [Application Capsule Transfer Apply Plan Track](./application-capsule-transfer-apply-plan-track.md).
- Keep apply planning read-only and explicit.

### Application Capsule Transfer Apply Plan

Status: landed and accepted.

Primary track:

- [Application Capsule Transfer Apply Plan Track](./application-capsule-transfer-apply-plan-track.md)

Dependencies:

- [Application Capsule Transfer Intake Plan Track](./application-capsule-transfer-intake-plan-track.md)
- [Application Capsule Transfer Bundle Verification Track](./application-capsule-transfer-bundle-verification-track.md)
- [Application Capsule Transfer Bundle Artifact Track](./application-capsule-transfer-bundle-artifact-track.md)

Current accepted state:

- The next useful artifact was a read-only apply operation plan over accepted
  transfer intake data.
- `ApplicationTransferApplyPlan` and
  `Igniter::Application.transfer_apply_plan(...)` are accepted as the
  application-owned operation review surface.
- Apply planning accepts an explicit intake plan or compatible serialized
  intake hash.
- It reports executable status, ordered operations, blockers, warnings,
  supplied surface metadata count, and stable `to_h`.
- It must not create, copy, write, delete, install, load, boot, mount, route,
  execute, or coordinate clusters.
- Web metadata remains supplied and opaque.
- Apply planning passed on 2026-04-25 with application/current specs, web
  skeleton specs, examples, and RuboCop.

Next:

- Continue through [Application Capsule Transfer Apply Execution Track](./application-capsule-transfer-apply-execution-track.md).
- Keep apply execution explicit, dry-run-first, and refusal-first.

### Application Capsule Transfer Apply Execution

Status: landed and accepted.

Primary track:

- [Application Capsule Transfer Apply Execution Track](./application-capsule-transfer-apply-execution-track.md)

Dependencies:

- [Application Capsule Transfer Apply Plan Track](./application-capsule-transfer-apply-plan-track.md)
- [Application Capsule Transfer Intake Plan Track](./application-capsule-transfer-intake-plan-track.md)
- [Application Capsule Transfer Bundle Verification Track](./application-capsule-transfer-bundle-verification-track.md)

Current accepted state:

- The next useful artifact was the first narrow mutable transfer boundary.
- `ApplicationTransferApplyResult` and
  `Igniter::Application.apply_transfer_plan(...)` are accepted as the
  application-owned dry-run-first execution surface.
- Apply execution accepts an explicit apply plan or compatible serialized
  apply-plan hash.
- It defaults to dry-run mode and requires explicit commit before
  filesystem mutation.
- It executes only reviewed `ensure_directory` and `copy_file` operations.
- It refuses non-executable plans and refuses overwrites by default.
- It must not apply host wiring, activate web, load, boot, route, execute
  contracts, or coordinate clusters.
- Web metadata remains supplied and opaque.
- Apply execution passed on 2026-04-25 with application/current specs, web
  skeleton specs, examples, and RuboCop.

Next:

- Continue through [Application Capsule Transfer Applied Verification Track](./application-capsule-transfer-applied-verification-track.md).
- Keep post-apply verification read-only and explicit.

### Application Capsule Transfer Applied Verification

Status: landed and accepted.

Primary track:

- [Application Capsule Transfer Applied Verification Track](./application-capsule-transfer-applied-verification-track.md)

Dependencies:

- [Application Capsule Transfer Apply Execution Track](./application-capsule-transfer-apply-execution-track.md)
- [Application Capsule Transfer Apply Plan Track](./application-capsule-transfer-apply-plan-track.md)
- [Application Capsule Transfer Intake Plan Track](./application-capsule-transfer-intake-plan-track.md)

Current accepted state:

- The next useful artifact was a read-only verification report after committed
  apply execution.
- `ApplicationTransferAppliedVerification` and
  `Igniter::Application.verify_applied_transfer(...)` are accepted as the
  application-owned post-apply readback surface.
- Applied verification accepts an explicit apply result or compatible
  serialized apply-result hash.
- It verifies reviewed destination directories/files against the committed
  result and artifact sources when available.
- It must report findings rather than repair, overwrite, or rediscover.
- It must not apply host wiring, activate web, load, boot, route, execute
  contracts, or coordinate clusters.
- Web metadata remains supplied and opaque.
- Applied verification passed on 2026-04-25 with application/current specs, web
  skeleton/composer specs, examples, and RuboCop.

Next:

- Continue through [Application Capsule Transfer Receipt Track](./application-capsule-transfer-receipt-track.md).
- Keep receipt generation read-only and explicit.

### Application Capsule Transfer Receipt

Status: landed and accepted.

Primary track:

- [Application Capsule Transfer Receipt Track](./application-capsule-transfer-receipt-track.md)

Dependencies:

- [Application Capsule Transfer Applied Verification Track](./application-capsule-transfer-applied-verification-track.md)
- [Application Capsule Transfer Apply Execution Track](./application-capsule-transfer-apply-execution-track.md)
- [Application Capsule Transfer Apply Plan Track](./application-capsule-transfer-apply-plan-track.md)

Current accepted state:

- `ApplicationTransferReceipt` and
  `Igniter::Application.transfer_receipt(...)` are accepted as the final
  read-only closure report over explicit transfer verification/result/plan
  data.
- Receipt generation accepts value objects or compatible serialized hashes.
- It summarizes complete/valid/committed status, artifact and destination
  roots, planned/applied/verified/finding/refusal/skipped/manual counts,
  manual actions, supplied surface count, and caller metadata.
- `complete` requires valid committed verification with no findings, refusals,
  skipped work, or manual actions.
- It must not mutate, repair, rediscover, rerun apply, rerun verification,
  activate web, load, boot, route, execute contracts, or coordinate clusters.
- Web metadata remains supplied and opaque.
- Receipt acceptance passed on 2026-04-25 with application/current specs, web
  skeleton/composer specs, examples, and RuboCop.

Next:

- Continue through [Application Capsule Transfer Guide Consolidation Track](./application-capsule-transfer-guide-consolidation-track.md).
- Keep the next cycle user-facing and stabilizing; do not add more transfer
  runtime machinery without new pressure.

### Application Capsule Transfer Guide Consolidation

Status: landed and accepted.

Primary track:

- [Application Capsule Transfer Guide Consolidation Track](./application-capsule-transfer-guide-consolidation-track.md)

Dependencies:

- [Application Capsule Transfer Receipt Track](./application-capsule-transfer-receipt-track.md)
- [Application Capsule Transfer Applied Verification Track](./application-capsule-transfer-applied-verification-track.md)
- [Application Capsule Transfer Apply Execution Track](./application-capsule-transfer-apply-execution-track.md)

Current accepted state:

- The transfer chain is complete enough for a consolidation pass.
- `examples/application/capsule_transfer_end_to_end.rb` is accepted as the
  compact public path from capsule declaration to final transfer receipt.
- The public guide lists the full chain in order and clearly states that only
  committed apply mutates the destination filesystem.
- Host wiring remains manual review data.
- Web metadata remains supplied and opaque and does not imply route activation,
  mount binding, browser traffic, screen inspection, or an application
  dependency on `igniter-web`.
- The consolidation pass added no new runtime classes, facades, transfer
  semantics, discovery, host wiring automation, web activation, contract
  execution, or cluster placement.
- Acceptance passed on 2026-04-25 with end-to-end/receipt smoke examples,
  application/current specs, web skeleton/composer specs, and RuboCop.

Next:

- Continue through [Application Capsule Post-Transfer Host Integration Track](./application-capsule-post-transfer-host-integration-track.md).
- Keep the next cycle focused on host-owned integration decisions after a
  verified receipt; do not introduce automatic activation yet.

### Application Capsule Post-Transfer Host Integration

Status: landed and accepted.

Primary track:

- [Application Capsule Post-Transfer Host Integration Track](./application-capsule-post-transfer-host-integration-track.md)

Dependencies:

- [Application Capsule Transfer Guide Consolidation Track](./application-capsule-transfer-guide-consolidation-track.md)
- [Application Capsule Transfer Receipt Track](./application-capsule-transfer-receipt-track.md)
- [Application Capsule Handoff Manifest Track](./application-capsule-handoff-manifest-track.md)

Current accepted state:

- The transfer chain ends with a verified receipt, but transfer completion does
  not equal runtime activation.
- Existing artifacts are enough for this cycle: handoff manifest, assembly
  plan, transfer readiness, apply plan, applied verification, and receipt.
- Host-owned decisions are explicit: exports, capabilities, manual wiring,
  load paths, providers, contracts, lifecycle, and optional mounts.
- No checklist/report object was added because the guide can express the
  boundary without duplicating existing transfer report data.
- Web surface metadata remains supplied/opaque context until a web-owned layer
  explicitly consumes it.
- Mount intents remain review data, not web mount calls, Rack/browser traffic,
  route activation, or screen/component inspection.
- Acceptance passed on 2026-04-25 with end-to-end smoke, application/current
  specs, web skeleton/composer specs, and diff check.

Next:

- Continue through [Application Capsule Host Activation Readiness Track](./application-capsule-host-activation-readiness-track.md).
- Keep the next cycle as activation readiness only; do not add activation,
  loading, boot, route mounting, browser traffic, or contract execution.

### Application Capsule Host Activation Readiness

Status: landed and accepted.

Primary track:

- [Application Capsule Host Activation Readiness Track](./application-capsule-host-activation-readiness-track.md)

Dependencies:

- [Application Capsule Post-Transfer Host Integration Track](./application-capsule-post-transfer-host-integration-track.md)
- [Application Capsule Transfer Receipt Track](./application-capsule-transfer-receipt-track.md)
- [Application Capsule Handoff Manifest Track](./application-capsule-handoff-manifest-track.md)

Current accepted state:

- `ApplicationHostActivationReadiness` and
  `Igniter::Application.host_activation_readiness(...)` are accepted as the
  read-only preflight over explicit transfer receipt, optional handoff
  manifest, and host-supplied decisions.
- It reports stable `ready`, `blockers`, `warnings`, `decisions`,
  `manual_actions`, `mount_intents`, `surface_count`, and `metadata`.
- Incomplete receipts, missing required host exports/capabilities, and
  unresolved manual actions are blockers.
- Missing load path, provider, contract, lifecycle, and optional mount
  decisions are warnings.
- It does not mutate, load, boot, register providers/contracts, mount, route,
  execute contracts, activate web, discover projects, place work on a cluster,
  or require `igniter-web`.
- Acceptance passed on 2026-04-25 with readiness/end-to-end smoke examples,
  application/current specs, web skeleton/composer specs, and RuboCop.

Next:

- Continue through [Application Capsule Host Activation Plan Track](./application-capsule-host-activation-plan-track.md).
- Keep the next cycle as read-only planning only; do not add activation
  execution.

### Application Capsule Host Activation Plan

Status: landed and accepted.

Primary track:

- [Application Capsule Host Activation Plan Track](./application-capsule-host-activation-plan-track.md)

Dependencies:

- [Application Capsule Host Activation Readiness Track](./application-capsule-host-activation-readiness-track.md)
- [Application Capsule Post-Transfer Host Integration Track](./application-capsule-post-transfer-host-integration-track.md)

Current accepted state:

- `ApplicationHostActivationPlan` and
  `Igniter::Application.host_activation_plan(...)` are accepted as read-only
  planning over activation readiness.
- Non-ready readiness produces a non-executable plan with no operations and
  carries blockers/warnings forward.
- Ready readiness produces ordered descriptive review operations for host
  exports/capabilities, load paths, providers, contracts, lifecycle, manual
  actions, and mount intents.
- Web-related operations remain `review_mount_intent` metadata only.
- It does not execute activation, mutate host wiring, change load paths,
  register providers/contracts, boot, bind mounts, activate routes, send
  browser traffic, execute contracts, discover projects, place work on a
  cluster, or require `igniter-web`.
- Acceptance passed on 2026-04-25 with activation plan/readiness smoke,
  application/current specs, web skeleton/composer specs, RuboCop, and diff
  check.

Next:

- Continue through [Application Capsule Host Activation Plan Verification Track](./application-capsule-host-activation-plan-verification-track.md).
- Keep the next cycle as read-only plan verification only; do not add
  activation execution.

### Application Capsule Host Activation Plan Verification

Status: active.

Primary track:

- [Application Capsule Host Activation Plan Verification Track](./application-capsule-host-activation-plan-verification-track.md)

Dependencies:

- [Application Capsule Host Activation Plan Track](./application-capsule-host-activation-plan-track.md)
- [Application Capsule Host Activation Readiness Track](./application-capsule-host-activation-readiness-track.md)

Current accepted state:

- Activation plans are descriptive operation review artifacts.
- The next useful artifact is read-only verification of supplied plan data:
  executable state, blockers/warnings, accepted operation vocabulary, and
  review-only statuses.
- Verification must not inspect host runtime state or execute operations.
- Web-related verification remains about `review_mount_intent` metadata only.

Next:

- `[Agent Application / Codex]`: land the smallest read-only plan verification
  only if it reduces real ceremony before any future execution boundary.
- `[Agent Web / Codex]`: verify mount-intent operations remain metadata only.

### Handoff Doctrine

Status: landed and accepted.

Primary track:

- [Handoff Doctrine Track](./handoff-doctrine-track.md)

Doctrine:

- [Handoff Doctrine](./handoff-doctrine.md)

Dependencies:

- [Agent Handoff Protocol](../research-horizon/agent-handoff-protocol.md)
- [Research Horizon Supervisor Review](../research-horizon/supervisor-review.md)

Current accepted state:

- Research Horizon identified handoff as ownership transfer under policy with
  context, evidence, obligations, and receipt.
- [Handoff Doctrine](./handoff-doctrine.md) is accepted as docs-only language
  alignment, not a shared runtime object.
- No package code, new package, runtime agent execution, autonomous delegation,
  cluster routing, host activation, web transport, or AI provider integration
  is accepted.

Next:

- `[Research Horizon / Codex]`: prepare Interaction Kernel read-only report
  synthesis for supervisor filtering.

[Research Horizon / Codex]
Track: `docs/dev/handoff-doctrine-track.md`
Status: drafted.
Changed:
- Added `docs/dev/handoff-doctrine.md`.
- Linked it from `docs/dev/README.md`.
- Added this short track reference without changing package implementation
  handoffs.
Accepted/Ready:
- The doctrine defines subject, sender, recipient, context, evidence,
  obligations, receipt, and trace.
- It maps docs-agent tracks, application handoff manifests, transfer receipts,
  host activation readiness/plans, and operator workflows to that vocabulary.
- It explicitly rejects shared runtime objects, new packages, runtime agent
  execution, autonomous delegation, cluster routing, host activation, web
  transport, AI provider calls, hidden discovery, and host-wiring mutation.
Verification:
- `git diff --check` passed.
Needs:
- `[Architect Supervisor / Codex]` accepted this docs-only doctrine; next
  Research Horizon review candidate is Interaction Kernel.

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
