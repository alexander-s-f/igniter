# Igniter Cluster State Snapshot

This document captures the current implemented state of `Igniter::Cluster` so we can return later, recover context quickly, and continue without rediscovering the last several development steps.

Use it together with:

- [Cluster Next Roadmap](./ROADMAP_NEXT.md) for direction
- this document for actual landed slices, proving surfaces, and next insights

## Current Thesis

`Igniter::Cluster` is no longer moving toward a role-based distributed runtime.

The live shape is now:

- capability-first
- trust-aware
- governance-aware
- self-observing
- increasingly self-healing

The network is treated as a plastic capability mesh rather than a static set of machine classes.

## What Is Settled

These points now feel architecturally settled rather than exploratory:

- node roles are not the foundation
- capabilities are the ground truth
- routing is expressed as capability queries rather than role selection
- trust, policy, decision, and governance are separate dimensions layered over capability fit
- cluster diagnostics belong in the cluster layer, not in `core`
- `apps` are code boundaries, `services` are runtime boundaries, `nodes` are cluster boundaries
- `companion` is the proving surface for the new cluster model

## Landed Capability Mesh Foundation

The following is already implemented and working:

- `CapabilityQuery` as the main routing surface
- filtering by capabilities, tags, metadata, policy, decision, trust, and governance
- explainable routing with structured trace output
- routing diagnostics with incidents, remediation hints, and executable plans
- capability freshness and confidence in peer observation
- capability-space ranking rather than only flat matching

This means the cluster can already reason in terms of:

- what a peer can do
- whether it is a good fit
- whether it is allowed
- whether we trust it
- how fresh that knowledge is
- what to do when routing fails

## Landed Identity And Trust Foundation

Phase 1 is no longer merely planned. A real minimal identity/trust layer is already present:

- stable `node_id`
- per-node identity primitive
- signed peer manifests
- signed capability attestations
- trust store and verifier
- trust-aware diagnostics
- trust-aware routing preference
- explicit trust requirements inside capability queries

The important shift is that capability claims are no longer anonymous observations. They are attributable and inspectable.

## Landed Governance Slice

Cluster governance has also moved from idea to working substrate:

- governance trail
- persisted governance trail with retention/compaction
- signed governance checkpoint over the live crest
- replicated governance checkpoint through mesh discovery/gossip
- governance-aware routing and diagnostics
- governance remediation plans
- executable governance actions

This is not a full decentralized state protocol yet, but it is already the beginning of a signed, compacted, auditable cluster crest.

## Landed Self-Healing Slice

Routing remediation is not only diagnostic anymore.

The cluster already has:

- executable routing plans
- batch routing plan execution
- trust admission workflow
- governance refresh and governance relaxation actions
- background repair loop
- runtime publication of routing reports from real distributed failures

The practical result is important:

- runtime failure can publish a routing report
- the report contains executable plans
- the repair loop can consume automated plans
- governance trail records what happened

This is the first real self-healing loop in the cluster.

## Companion As Proving Surface

The new `examples/companion` is now the main proving ground for the rebuilt stack and cluster model.

What it already illustrates:

- stack/service/node separation
- stable local node identities
- local trust catalog
- capability envelopes and mocked capabilities
- cluster status and peer discovery
- governance checkpoint visibility
- self-heal demo through the dashboard

The dashboard can now trigger synthetic cluster incidents and show:

- active routing report
- incident and plan summaries
- automated repair tick
- governance trail updates after self-heal

This matters because we now have a concrete, runnable surface for cluster ideas instead of only deep infrastructure and specs.

## What Is Not Done Yet

Several pieces are still clearly incomplete:

- a more formal capability discovery/registry protocol
- richer placement and rebalancing beyond routing-time preference
- stronger topology and ownership transfer semantics
- broader automatic runtime repair from real workload signals
- peer admission / trust bootstrap UX beyond the current controlled workflow
- decentralized knowledge plane / RAG layer
- stronger signed replicated crest exchange between peers

So the base is real, but the cluster is not yet at the stage of fully adaptive distributed placement or decentralized knowledge.

## My Current Development Insights

These are the strongest next-step insights from the implementation work so far.

### 1. The next major value is placement, not more routing syntax

Routing is already expressive.

The next big gain will come from:

- ownership movement
- rebalance
- locality-aware placement
- degraded-mode placement
- preferred vs fallback placement

In other words, the cluster should start deciding where work should live over time, not only which peer matches right now.

### 2. Discovery needs to become a clearer protocol surface

We already have manifests, attestations, freshness, and trust, but the model is still spread across runtime structures.

The next refactor should make discovery more explicit as a protocol:

- canonical snapshot shape
- canonical observation envelope
- clearer distinction between self-claim and relayed observation
- explicit conflict/staleness handling

### 3. Governance is now strong enough to become a general cluster action layer

We should stop thinking of governance only as audit and begin treating it as the control plane for:

- peer admission
- risky capability enablement
- topology-affecting changes
- automated vs approval-required repair

This feels like the beginning of a proper cluster governance model, not a side feature.

### 4. Companion should keep pace with cluster internals

The biggest accelerant recently was having a runnable proving surface.

Companion should keep illustrating:

- real runtime failure -> routing report publication
- background repair loop activity
- trust admission flows
- governance checkpoint drift/refresh

If the cluster grows without companion narratives, comprehension cost will rise fast.

### 5. Signed crest is promising, but should stay compact

The current governance checkpoint is useful precisely because it is small and inspectable.

The next steps should preserve that property:

- signed checkpoints
- bounded crest
- explicit compaction
- clear provenance

The design should resist becoming a heavyweight chain-shaped subsystem.

## Recommended Next Focus

If we resume cluster work after a pause, the healthiest next focus looks like this:

1. Formalize the capability discovery/registry protocol.
2. Start placement and rebalancing primitives.
3. Deepen self-healing from synthetic/demo and routing-level cases into more real workload-driven cases.
4. Keep companion aligned so each new cluster slice has a visible proving story.

## Short Resume Prompt

If we need to re-enter this work quickly later, the mental starting point is:

`Igniter::Cluster` already has a real capability mesh, signed identity/trust, governance crest, routing remediation, and a first self-healing loop. The next likely leap is from smart routing to adaptive placement and clearer discovery protocol design, while keeping Companion as the visible proving surface.
