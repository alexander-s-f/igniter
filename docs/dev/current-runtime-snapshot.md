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
- `ApplicationManifest`
- `ApplicationLayout`
- config, provider, service, contract, host, loader, scheduler seams
- `MemorySessionStore` and configurable `session_store`
- local durable sessions for compose and collection
- transport-ready compose and collection invokers
- manifest and canonical user app layout
- lifecycle plans and reports

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
