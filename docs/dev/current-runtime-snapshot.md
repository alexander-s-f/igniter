# Current Runtime Snapshot

This snapshot captures the current clean-slate runtime track.

It is the short reference to read before choosing the next development slice.
Older roadmap notes may still contain useful reference material, but this file
describes the active package graph and the current direction.

## Active Package Graph

The active runtime graph is:

- `igniter-contracts`
  canonical embedded kernel
- `igniter-extensions`
  packs, tooling, operational behavior, and domain vocabulary over contracts
- `igniter-application`
  contracts-native local application runtime
- `igniter-embed`
  host-local contract embedding, Rails/application pressure layer, and
  Contractable observation/shadowing
- `igniter-cluster`
  contracts-native distributed runtime
- `igniter-mcp-adapter`
  adapter surface over contracts-native MCP tooling

Supporting packages may exist, such as `igniter-web`, but they are not runtime
pillars. They should stay as focused integration, UI, adapter, or tooling
packages.

Legacy code remains reference-only until deletion. We are not preserving weak
legacy shapes for compatibility during this reset.

## Current Contracts State

`igniter-contracts` is now intentionally small.

Canonical baseline DSL:

- `input`
- `const`
- `compute`
- `effect`
- `output`

The kernel owns graph authoring, compilation, validation, profiles, local
execution, effect/executor registries, and minimal diagnostics.

Important current decisions:

- `effect` is a baseline node with an explicit named adapter boundary.
- `project` is extension-level DSL lowered into `compute`.
- `lookup` is extension-level DSL lowered into `compute`.
- `count`, `sum`, and `avg` are extension-level aggregate DSL lowered into
  `compute`.
- `branch` is an extension-level decision layer that lowers into observable
  selection data.
- `collection` lives in extensions as keyed item graph orchestration.
- `compose` lives in extensions as explicit nested graph invocation.
- `collection` and `compose` both preserve invocation adapter hooks so
  application and cluster layers can provide local, remote, or distributed
  execution without changing user DSL.

Pack manifests now support a first-class dependency graph:

- hard pack dependencies through `requires_packs`
- semantic capability declarations through `provides_capabilities`
- soft/audit requirements through `requires_capabilities`

## Current Extensions State

`igniter-extensions` is the home for useful vocabulary that should not enlarge
the contracts kernel.

Current important packs and behaviors include:

- ergonomic data access and aggregate DSL
- branch decision DSL
- compose and collection execution packs
- incremental and dataflow sessions
- audit, provenance, execution reports, diagnostics, debug tooling
- journal, saga, reactive, differential, content addressing, invariants
- pack authoring/creator tooling
- MCP contract tooling
- commerce/domain examples over the same pack model

Domain packs should compose through public DSL and pack dependencies, not by
injecting raw extension node kinds into the compiled graph.

## Current Application State

`igniter-application` is the local runtime host over contracts.

Current shape:

- `Application::Kernel`
- `Application::Profile`
- `Application::Environment`
- `ApplicationBlueprint`
- `ApplicationStructurePlan`
- `ApplicationManifest`
- `ApplicationLayout`
- `MountRegistration`
- `ApplicationLoadReport`
- config, provider, service, contract, host, loader, scheduler seams
- `MemorySessionStore` and configurable `session_store`
- agent-native flow session snapshots and event envelopes
- local durable sessions for compose and collection
- transport-ready compose and collection invokers
- manifest and canonical user app layout
- scaffold-free app blueprints
- named layout profiles for standalone and compact app capsules
- capsule export/import metadata for portable app boundaries
- optional feature-slice reporting metadata
- app-owned flow declaration metadata
- application-owned capsule inspection reports
- human-facing capsule authoring DSL over `ApplicationBlueprint`
- read-only capsule composition reports for explicit import/export readiness
- read-only capsule assembly plans over composition readiness and mount intents
- read-only capsule handoff manifests for portable transfer and host wiring
  review
- read-only capsule transfer inventories for dry-run review of declared
  capsule paths/files before any future copy or package tooling
- read-only capsule transfer readiness reports over handoff manifests and
  transfer inventories
- read-only capsule transfer bundle plans over readiness and inventory artifacts
- explicit capsule transfer bundle artifact writer from accepted bundle plans
- read-only capsule transfer bundle verification over written artifacts
- read-only capsule transfer intake plans over verified artifacts and explicit
  destination roots
- read-only capsule transfer apply operation plans over accepted intake data
- explicit dry-run-first capsule transfer apply execution reports over
  reviewed apply plans
- read-only capsule transfer applied verification reports over committed
  transfer results
- read-only capsule transfer receipts over explicit transfer reports
- public capsule transfer guide over the read-only report/composition/assembly/
  handoff chain
- compact capsule transfer end-to-end smoke path from capsule declaration to
  final receipt
- read-only host activation readiness over explicit post-transfer host
  decisions
- read-only host activation plans over accepted readiness
- read-only host activation plan verification over supplied plan data
- consolidated host activation review guide with a hard stop before execution
- explicit sparse/complete structure plans for materializing missing app layout
  paths
- generic mount registry for web, agent, and future interaction surfaces
- lifecycle plans and reports

Application and web integration is tracked separately in
[Application And Web Integration](./application-web-integration.md). The current
rule is that `igniter-web` should mount into `igniter-application` as an
interaction layer for agents, streams, dashboards, and operator workflows, not
as a CRUD-first application model. The current application-side primitive is a
generic mount registration with `kind`, `at`, `capabilities`, and metadata;
`kind: :web` is only a classification, not a dependency on `igniter-web`.
Web-owned surface projection reports may be supplied as plain metadata for
inspection, including summary status and related flow/feature names, but
application does not inspect web screen graphs.
`ApplicationCapsuleReport` is the current read-only aggregate for humans and
agents that need to inspect a capsule before editing, moving, or mounting it.
`ApplicationHandoffManifest` is the current read-only transfer review artifact
for humans and agents that need to see what capsules are moving, whether the
set is ready, which host wiring is still required, and which optional web
surface metadata was supplied. It is not a packaging, copy, discovery, boot,
mount, routing, execution, or cluster placement mechanism.
`ApplicationTransferInventory` is the current read-only dry-run inventory over
declared capsule material. It reports expected/missing paths and can enumerate
files only under explicit capsule roots and declared layout paths. It accepts
optional supplied web path metadata without inspecting web internals, and it is
not a transfer, archive, discovery, loading, boot, mount, routing, execution,
or cluster placement mechanism.
`ApplicationTransferReadiness` is the current read-only decision report over a
handoff manifest and transfer inventory. It separates blockers from warnings,
classifies findings by source, and exposes one `ready` boolean without
packaging, copying, activation, routing, execution, or cluster placement.
`ApplicationTransferBundlePlan` is the current read-only plan for a future
bundle/package operation. It summarizes included files already enumerated by
the transfer inventory, missing paths, supplied surfaces, blockers, warnings,
and policy without writing archives, copying files, loading constants, booting
apps, mounting web, routing, executing, or placing work on a cluster.
`ApplicationTransferBundleArtifact` is the current explicit directory artifact
writer from an accepted bundle plan. It writes only to a caller-provided output
path, refuses existing output by default, includes only planned files, and
embeds serialized review metadata. It still does not discover projects,
auto-select destinations, install or extract bundles, load constants, boot
apps, mount web, route, execute, or place work on a cluster.
`ApplicationTransferBundleVerification` is the current read-only readback
surface for written artifacts. It reads the explicit artifact path, parses
`igniter-transfer-bundle.json`, compares planned files with actual files under
`files/`, and reports mismatches without installing, extracting, activating,
routing, executing, or placing work on a cluster.
`ApplicationTransferIntakePlan` is the current read-only destination planning
surface over a verified artifact and an explicit destination root. It reports
planned paths, destination conflicts, blockers, host wiring, warnings, and
supplied surface metadata before any future extraction or installation exists.
`ApplicationTransferApplyPlan` is the current read-only operation planning
surface over accepted intake data. It lists ordered future directory creation,
file copy, and manual host wiring operations plus blockers and warnings without
creating directories, copying files, applying host wiring, or installing a
bundle.
`ApplicationTransferApplyResult` is the current dry-run-first execution report
over reviewed transfer apply plans. It defaults to non-mutating review; with
`commit: true` it uses refusal-first preflight and may only create reviewed
directories and copy reviewed files under the destination root. It does not
apply host wiring, activate web, load, boot, route, execute contracts, or place
work on a cluster.
`ApplicationTransferAppliedVerification` is the current read-only post-apply
verification report over committed transfer results. It proves destination
directories/files match reviewed operations and artifact sources without
repairing, overwriting, applying host wiring, activating web, booting apps,
routing, executing contracts, or placing work on a cluster.
`ApplicationTransferReceipt` is the current read-only transfer closure report
over explicit verification/result/plan reports. It summarizes final status,
counts, findings, refusals, skipped work, manual actions, and supplied surface
count without mutation, rediscovery, activation, verification reruns, or
execution.
`examples/application/capsule_transfer_end_to_end.rb` is the current compact
public transfer path. It demonstrates capsule declaration, inventory,
readiness, bundle artifact writing, bundle verification, destination intake,
apply planning, dry-run apply, committed apply, applied verification, and
receipt generation without adding new runtime machinery.
Post-transfer host integration is currently docs/checklist-only. The existing
handoff manifest, assembly plan, transfer readiness, apply plan, applied
verification, and receipt already carry the required review signals for host
exports, capabilities, manual wiring, load paths, providers, contracts, and
optional mounts. Transfer completion is not runtime activation; application
does not auto-wire hosts, bind web routes, load constants, boot apps, execute
contracts, or place work on a cluster.
`ApplicationHostActivationReadiness` is the current read-only activation
preflight over explicit transfer receipts, handoff metadata, and host-supplied
decisions. It reports blockers and warnings before activation without mutating
host wiring, loading constants, booting apps, binding mounts, activating web,
routing browser traffic, executing contracts, or placing work on a cluster.
`ApplicationHostActivationPlan` is the current read-only operation review over
accepted activation readiness. It carries readiness blockers/warnings forward
when blocked, and otherwise describes confirm/review operations without
mutating host wiring, changing load paths, registering providers/contracts,
booting apps, binding mounts, activating routes, executing contracts,
discovering projects, or placing work on a cluster.
`ApplicationHostActivationPlanVerification` is the current read-only
verification report over supplied activation plan data. It checks that
executable/non-executable state, operation vocabulary, review-only status, and
mount-intent metadata are internally consistent without executing, mutating,
loading, booting, registering, mounting, routing, activating web, executing
contracts, discovering projects, or placing work on a cluster.
The user-facing host activation review path is now consolidated as receipt,
post-transfer host integration review, readiness, activation plan, activation
plan verification, and then an explicit stop line. A valid verification means
Igniter reviewed activation intent only; future real activation must start at a
separate host-owned, web-owned, or cluster-owned execution boundary.

Lifecycle now follows this shape:

- `plan_boot`
- `execute_boot_plan`
- `BootReport`
- `plan_shutdown`
- `execute_shutdown_plan`
- `ShutdownReport`

Application owns local lifecycle and local session durability. It does not own
routing, placement, topology, membership, trust, failover, or mesh behavior.
Those belong in `igniter-cluster`.

## Current Embed State

`igniter-embed` is the host-local bridge for applications that want to consume
contracts without adopting the full application runtime.

Current accepted shape:

- host-level contract registration through `Igniter::Embed.configure`
- human-facing host sugar through `Igniter::Embed.host`
- `owner`, `path`, `cache`, and `contracts.add` sugar over clean config
- app-local `Class < Igniter::Contract` consumption from embed
- optional discovery with explicit cache/reload boundaries
- `Contractable` wrappers for migration candidates, observed services, and
  discovery probes
- differential shadow comparison through `DifferentialPack` via an embed-side
  adapter
- async candidate execution through a local thread-backed adapter by default,
  with host-supplied durable adapters allowed
- visible host-boundary adapter sugar for normalizer, redaction, acceptance,
  and store
- typed event hooks with `on :failure` as a failure-family alias and
  `:divergence` intentionally separate
- generated contractable runner access through `host.contractable(:name)`,
  `host.fetch_contractable(:name)`, and `host.contractable_names`
- explicit-target capability attachment metadata for logging, reporting,
  metrics, and validation
- inspectable `host.sugar_expansion.to_h`
- public docs/examples for the accepted sugar surface

Current rule:

- do not add more Embed DSL breadth without new host pressure
- do not promote capability attachments into `igniter-contracts` or
  `igniter-extensions` until repeated Embed implementations prove common
  graph/runtime semantics

## Current Cluster State

`igniter-cluster` is now a substantial distributed runtime substrate over
application transport and contracts execution.

Core identity and intent:

- `CapabilityCatalog`
- `CapabilityQuery`
- `PeerProfile`
- `PeerTopology`
- `PeerHealth`
- `PeerView`
- `MembershipProjection`

Control and placement:

- `RoutePolicy`
- `AdmissionPolicy`
- `PlacementPolicy`
- `ProjectionPolicy`
- `ProjectionExecutor`
- `ProjectionReport`
- `DecisionExplanation`

Planning:

- `TopologyPolicy` / `RebalancePlan`
- `OwnershipPolicy` / `OwnershipPlan`
- `LeasePolicy` / `LeasePlan`
- `HealthPolicy` / `FailoverPlan`
- `RemediationPolicy` / `RemediationPlan`

Execution:

- `PlanExecutor`
- `PlanExecutionReport`
- `PlanActionResult`
- `execute_plan`
- `execute_rebalance_plan`
- `execute_ownership_plan`
- `execute_lease_plan`
- `execute_failover_plan`
- `execute_remediation_plan`

Diagnostics and operator surfaces:

- `ClusterDiagnosticsReport`
- `ClusterDiagnosticsExecutor`
- `ClusterEvent`
- `ClusterEventLog`
- `OperatorTimeline`
- `ClusterIncident`
- `RecoveryTimeline`
- `IncidentEntry`
- `IncidentAction`
- `IncidentWorkflow`
- `MemoryIncidentRegistry`
- `ActiveIncidentSet`

Mesh-specific runtime:

- `MeshExecutor`
- `MeshExecutionRequest`
- `MeshExecutionResponse`
- `MeshExecutionAttempt`
- `MeshExecutionTrace`
- `MeshMembership`
- `MeshMembershipSource`
- `RegistryMembershipSource`
- `PeerDiscovery`
- `MeshRetryPolicy`
- `MeshTrustPolicy`
- `MeshAdmission`
- `DiscoveryFeed`
- `MembershipFeed`
- `MembershipSnapshot`
- `MembershipDelta`

The current cluster shape is:

- plan first
- explain decisions
- execute through explicit reports
- collect diagnostics as structured artifacts
- preserve mesh-specific behavior above plan semantics
- keep incidents durable and observable
- manage incidents through explicit workflow actions
- turn active incidents into remediation plans

## Runnable Reference Lane

Active runnable examples are part of the current source of truth.

Cluster examples now include:

- `examples/cluster/routing.rb`
- `examples/cluster/incidents.rb`
- `examples/cluster/incident_workflow.rb`
- `examples/cluster/mesh_diagnostics.rb`
- `examples/cluster/remediation.rb`

The active smoke lane currently covers contracts and cluster examples together.

Useful commands:

```bash
ruby examples/run.rb smoke
bundle exec rake
bundle exec rake architecture
```

## Current Validation Baseline

The current default workflow is green:

- active specs
- active examples
- architecture boundary guards
- RuboCop over the active surface

This matters because the reset is no longer only design prose. The current
runtime graph has working code paths and runnable reference scenarios.

## Next Development Tracks

### 1. Incident Workflow And Remediation Lifecycle

This is the most direct continuation of the latest work.

Build from:

- durable incident registry
- active incident set
- recovery timelines
- remediation plans

Likely next objects:

- `IncidentWorkflow`
- `IncidentAction`
- `IncidentResolution`
- `IncidentWorkflowReport`

Likely lifecycle actions:

- acknowledge
- assign
- silence
- escalate
- retry remediation
- mark recovered
- close

Design goal:

- incidents should become durable operator workflows, not just execution
  artifacts
- remediation execution should be able to update incident state explicitly
- dashboards and automation should read the same structured workflow history

### 2. Application And Cluster Observability Bridge

This track connects local application runtime reports with cluster diagnostics.

Build from:

- application boot/shutdown plans and reports
- application session store
- cluster diagnostics reports
- cluster incident registry
- operator timelines

Likely next objects:

- `ApplicationDiagnosticsReport`
- `RuntimeDiagnosticsBridge`
- `ClusterSessionLink`
- `OperatorRuntimeSnapshot`

Design goal:

- local application sessions and remote cluster execution should feel like one
  explainable runtime story
- application diagnostics should be able to reference cluster route, mesh,
  incident, and remediation artifacts when they exist
- cluster should remain optional above application

### 3. Real Remediation Handlers

The current remediation execution path is structurally real, but still mostly
simulated unless a handler is supplied.

Build from:

- remediation plans
- plan executor handler hooks
- mesh executor
- incident workflow state

Likely next objects:

- `RemediationHandler`
- `RetryFailoverHandler`
- `LeaseReissueHandler`
- `OwnershipReconcileHandler`
- `RemediationExecutionReport`

Design goal:

- move from "planned response" to useful default response handlers
- keep handlers replaceable
- record every handler result into incident workflow and recovery timeline

### 4. Dynamic Membership And Discovery Persistence

The mesh layer already has snapshots, feeds, deltas, and membership-aware retry.
The next step is durable membership history.

Build from:

- `DiscoveryFeed`
- `MembershipFeed`
- `MembershipSnapshot`
- `MembershipDelta`
- mesh trace snapshot refs

Likely next objects:

- `MembershipSnapshotStore`
- `DiscoveryAdapter`
- `MembershipFeedCursor`
- `MembershipProjectionHistory`

Design goal:

- mesh traces should reference durable membership snapshots
- discovery should be pluggable without losing explainability
- later gossip, HTTP discovery, or filesystem discovery can share the same
  snapshot/delta model

### 5. Transport And Adapter Hardening

Application and cluster now have transport-ready contracts, but most examples
are in-memory.

Build from:

- application transport request/response
- cluster route/admission/placement pipeline
- mesh executor request/response shape
- MCP adapter patterns

Likely next objects:

- HTTP transport adapter
- local process transport adapter
- MCP transport bridge
- serialized execution envelope

Design goal:

- prove remote execution outside in-memory lambdas
- keep transport as an adapter concern
- keep cluster semantics independent from the protocol used to move bytes

### 6. User-Facing Guides For The New Runtime

The implementation has moved faster than the user-facing guide.

Likely next docs:

- contracts-native quickstart
- packs and lowering guide
- application lifecycle guide
- cluster planning guide
- incidents and remediation guide

Design goal:

- make the new model explainable without requiring the reader to know the
  legacy system
- use runnable examples as the guide backbone

## Recommended Next Track

The incident workflow foundation now exists:

- `IncidentAction`
- `IncidentWorkflow`
- registry workflow history per incident key
- environment helpers for acknowledge, assign, silence, escalate, resolve, and
  close
- remediation execution records workflow actions
- `examples/cluster/incident_workflow.rb`

The strongest next track is now:

- Real Remediation Handlers

Reason:

- incidents are durable
- workflow history is explicit
- remediation plans exist
- remediation execution now appends workflow actions
- the next useful step is making remediation actions do real default work
  through replaceable handlers
