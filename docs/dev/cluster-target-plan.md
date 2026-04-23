# Cluster Target Plan

This note defines the target direction for a contracts-native `Cluster` layer.

It should be read together with:

- [Post-Core Target Plan](./post-core-target-plan.md)
- [Embed Target Plan](./embed-target-plan.md)
- [Application Target Plan](./application-target-plan.md)
- [Igniter Contracts Spec](./igniter-contracts-spec.md)

The central design rule is:

- `Cluster` is not "core plus distributed patches"
- `Cluster` is not "server with more coordination"
- `Cluster` is a distributed runtime substrate over `Embed` and optionally
  `Application`

## Problem Statement

The current cluster layer grew by accumulating several different concerns:

- remote execution transport
- routing
- capabilities and capability queries
- mesh membership and discovery
- trust/admission
- ownership and distributed placement
- replication/bootstrap flows
- consensus-style coordination
- distributed diagnostics and explainability

Many of these are legitimate cluster concerns, but they are not all the same
kind of concern.

The next architecture needs a more explicit shape so that:

- contracts remain the executable graph abstraction
- application hosting remains a separate local host concern
- cluster semantics become explicit distributed seams rather than incidental
  behavior leaking out of the old kernel

## Target Thesis

`Cluster` should be the distributed operating mode over the contracts-first
embedded kernel.

That means:

- `Embed` owns executable graph semantics
- `Application` owns local hosting/profile concerns
- `Cluster` owns distribution, routing, admission, replication, and network
  coordination

The job of `Cluster` is not to redefine contracts.

The job of `Cluster` is to place, route, execute, and explain distributed work
built from contracts and packs.

## What Cluster Is

Cluster means:

- remote execution
- capability-aware routing and admission
- mesh membership and topology
- ownership and placement
- replication/bootstrap of runtime capacity
- distributed diagnostics and routing explanation
- consensus or other coordination mechanisms where needed

Typical cluster scenarios:

- capability-routed execution across heterogeneous peers
- distributed ownership of entities or workloads
- resilient remote execution with routing fallback
- topology-aware expansion and contraction
- operator-facing explainability for placement and routing behavior

## What Cluster Is Not

Cluster is not:

- the embedded kernel
- the local application boot lifecycle
- code loading as a primary concern
- local scheduler ownership
- generic app hosting

Those belong to `Embed` and `Application`.

## Recommended Role In The Package Graph

The target package story should be:

- `igniter-contracts`
  canonical embedded kernel
- `igniter-extensions`
  packs over the embedded kernel
- `igniter-app`
  local host/profile layer
- `igniter-cluster`
  distributed runtime layer over the embedded kernel and, when useful, app
  profiles

This implies:

- cluster should depend on explicit contracts/runtime surfaces
- cluster should not require the old kernel as its semantic home
- cluster-specific logic should stop being justified as "core runtime detail"

## Recommended Layer Splits

The cluster layer should be decomposed into distinct subdomains.

### 1. Remote Execution Substrate

This subdomain owns:

- remote contract execution
- request/response semantics
- execution handoff
- result/error propagation
- execution transport adapters

Questions:

- what is the minimal remote execution contract?
- how does a compiled graph or execution request move across nodes?
- what metadata belongs to remote execution versus routing?

### 2. Routing And Admission

This subdomain owns:

- capability queries
- peer selection
- admission/trust checks
- route explanation
- fallback/deferred routing behavior

Questions:

- what is the canonical routing contract?
- how should capabilities participate in admission and placement?
- how do we make routing explanations first-class for diagnostics and tooling?

Current direction:

- cluster routing should be expressed through an explicit `CapabilityQuery`
  value object
- ergonomic APIs may still accept `capabilities:` / `peer:`, but those are
  only sugar over the query object
- routing, placement, admission, and transport diagnostics should consume the
  same query shape instead of ad-hoc metadata fields
- route, placement, and admission explanations should be explicit
  `DecisionExplanation` values instead of free-form strings
- the default cluster control surface should be declarative policy objects such
  as `RoutePolicy`, `AdmissionPolicy`, and `PlacementPolicy`, with raw seam
  overrides treated as lower-level escape hatches
- peer identity should be explicit and structured, so policies and diagnostics
  can consume a canonical peer profile instead of loose capability arrays and
  ad-hoc metadata hashes
- capability queries should be able to express richer intent than plain names:
  traits, labels, and region/zone locality should be part of the canonical
  routing and placement contract
- peer locality should live in an explicit topology value object, so placement
  and future rebalancing can depend on canonical topology data rather than
  loose profile fields
- cluster movement should be explicit and explainable: topology-driven
  redistribution should produce first-class rebalance plans rather than hidden
  runtime behavior
- ownership should be planned explicitly too: workload/entity ownership should
  come from first-class ownership plans rather than implicit peer selection
- leases and renewals should be explicit planning/results too, so coordination
  can evolve from explainable contracts instead of hidden timeout logic
- degraded and failed peers should be handled through explicit health and
  failover plans, so recovery paths are visible and testable instead of being
  buried inside transport/runtime branching
- cluster plans should also have a first-class execution seam, so rebalance,
  ownership, lease, and failover can move through a canonical
  `plan -> executor -> report` path before richer real handlers are attached
- mesh-specific execution should sit on top of that executor seam, with
  explicit mesh request/response/attempt/trace values instead of ad-hoc peer
  transport side effects
- membership, peer discovery, and retry/fallback should also be explicit
  mesh-layer values, so future gossip/discovery/trust systems can plug in
  without changing cluster plan semantics
- mesh trust/admission should be explicit too, so candidate peers can be
  denied before execution with structured reasons that show up in mesh traces

### 3. Ownership And Placement

This subdomain owns:

- ownership claims
- placement decisions
- rebalance plans
- entity/workload location decisions

Questions:

- what should be owned?
- how are placement decisions represented?
- what is the boundary between routing and ownership?

### 4. Replication And Capacity Expansion

This subdomain owns:

- replication plans
- node bootstrap/expansion
- capacity acquisition
- host pool / node profile growth

Questions:

- what belongs in cluster substrate versus operational packs?
- what parts of replication should be pack-driven?
- what parts are true cluster semantics?

### 5. Coordination / Consensus

This subdomain owns:

- state agreement where required
- coordination protocols
- distributed safety conditions

Questions:

- where is strong coordination actually necessary?
- where can looser eventual or operator-mediated models replace heavy consensus?

This area should be the most carefully scoped instead of becoming the default
home for every "distributed" idea.

## Keep / Rebuild / Drop

### Keep

These ideas still look strong:

- capability-aware routing
- explicit remote adapter seams
- ownership as a first-class concern
- routing/placement explainability
- topology-aware capacity reasoning

### Rebuild

These should likely be redesigned rather than preserved as-is:

- cluster as a wide umbrella package with many mixed responsibilities
- any hidden dependency on old embedded runtime internals
- coupling between routing and transport details
- coupling between local app boot assumptions and distributed substrate design

### Drop Or Demote

These should not define the target:

- preserving old cluster public APIs for their own sake
- justifying distributed behavior as "core runtime detail"
- defaulting to heavyweight coordination when weaker explicit models are enough

## Relationship To Application

`Application` and `Cluster` should relate like this:

- `Application` owns local host/runtime profile
- `Cluster` may host or coordinate applications
- `Cluster` does not own the basic local app model

A single application should remain valid without cluster.

Cluster should be additive:

- distributed transport
- distributed routing
- distributed placement
- distributed coordination

not redefinitional.

## Relationship To Embed

`Embed` is still the foundation.

That means:

- contracts are authored and reasoned about in the embedded/contracts-first
  model
- cluster should execute or route those contracts
- cluster should not mutate their fundamental semantics by surprise

In other words:

- `Embed` defines executable work
- `Cluster` decides where and how distributed work runs

## Proposed Public Surface

The public API should trend toward explicit cluster composition:

```ruby
kernel = Igniter::Cluster::Kernel.new
kernel.transport(:http)
kernel.router(:capability_mesh)
kernel.ownership(:distributed_registry)
kernel.replication(:capacity_expander)
kernel.install_pack(MyClusterPack)

profile = kernel.finalize
cluster = Igniter::Cluster::Environment.new(profile)
```

Or simpler facades built on the same shape:

```ruby
cluster = Igniter::Cluster.with(
  transport: :http,
  router: :capability_mesh
)
```

The important part is:

- explicit cluster assembly
- explicit distributed seams
- explicit finalized profile

## Diagnostics Direction

Cluster diagnostics should be contributor-based and explicit.

They should surface:

- routing decisions
- placement/ownership status
- topology state
- admission and trust decisions
- replication/expansion actions
- distributed execution results

This should compose with contracts/app diagnostics rather than replacing them.

`DebugPack` and future tooling should be able to observe cluster runtime state
through stable structured reports.

## Suggested Delivery Sequence

1. define the minimal remote execution contract
2. define the routing/admission contract
3. define the ownership/placement contract
4. define which replication and coordination concerns truly belong in cluster
5. then prototype a contracts-native cluster kernel/profile/environment shape

This order helps avoid rebuilding the old umbrella in a different folder.

## Current First Slice

The new package can now start from a much narrower first implementation:

- reuse `Igniter::Application::TransportRequest`
- reuse `Igniter::Application::TransportResponse`
- add explicit cluster seams for:
  - `peer_registry`
  - `placement`
  - `router`
  - `admission`
  - `transport`
- expose cluster-owned `compose_invoker` / `collection_invoker` that feed those
  seams without changing contracts DSL

That gives `igniter-cluster` a real substrate for routed remote execution
without prematurely importing legacy mesh, consensus, replication, or
governance models.

## Success Criteria

The target is successful when:

- `Cluster` can be described as a distributed runtime over `Embed` /
  `Application`
- remote execution, routing, ownership, and replication are explicit seams
- cluster no longer depends conceptually on legacy core semantics
- distributed concerns stop leaking down into the embedded kernel
- deleting the old cluster/core coupling becomes cleanup, not redesign
