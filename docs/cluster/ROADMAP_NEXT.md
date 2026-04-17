# Igniter Cluster Next

This document fixes the current direction for `Igniter::Cluster`.

It is not a frozen product roadmap. It is the architectural program for the next stage of cluster development while the codebase is still free to evolve aggressively.

## Current Thesis

`Igniter::Cluster` is a capability-driven, trust-aware, self-observing mesh.

The cluster should not be modeled as:

- fixed node roles
- hard-coded machine classes
- static topology assumptions
- “distributed server” with a little failover on top

The cluster should be modeled as:

- a live capability field
- a routing and replication layer over that field
- a trust and policy layer over what nodes can do and what they are allowed to do
- a resilient network that can degrade gracefully and recover plasticity as peers come and go

## What Is Already True

The following direction is already established in the codebase:

- node roles are no longer the foundation
- capabilities are the ground truth
- routing is capability-query driven
- freshness and confidence are part of cluster observation
- policy and decision semantics are layered over capability selection
- routing explainability and diagnostics are first-class
- cluster diagnostics live in the cluster layer rather than leaking into core

This matters because the roadmap below is an extension of the current design, not a restart from zero.

## Architectural Principles

### 1. Capability-First, Not Role-First

The cluster routes and reasons over:

- what a node can do
- what is currently available
- what is allowed
- how fresh the observation is
- how much the network trusts that observation

“Roles” may exist only as:

- UX labels
- presets
- derived summaries over capability predicates

They must not become the primary execution model.

### 2. Plasticity Over Static Placement

A healthy cluster should survive partial loss, rebalance work, and adapt to changing availability without rewriting business contracts.

### 3. Trust Is A First-Class Dimension

Capability without identity and trust is not enough.

The cluster must eventually reason over:

- who claims a capability
- who observed it
- whether the claim is signed
- whether the peer is trusted
- whether the action requires approval

### 4. Core Stays Small

Cluster intelligence should not leak downward into `core`.

- `core` remains the execution kernel
- `app` remains the single-node runtime/profile
- `cluster` owns network, routing, trust, replication, and decentralized behavior
- `sdk` owns optional cluster-native capabilities such as future RAG

## Phase Map

## Phase 0: Capability Mesh Foundation

Status: landed

This phase established the new base model:

- `CapabilityQuery`
- capability-based routing
- policy-aware and decision-aware routing
- freshness/confidence observation
- routing explainability
- cluster-specific diagnostics and remediation plans

This phase is the foundation for everything below.

## Phase 1: Identity And Trust Foundation

Priority: highest
Status: next

Goal:

Introduce a minimal but real identity model for cluster peers.

What this phase should add:

- stable `node_id`
- per-node keypair
- signed peer manifest
- signed capability snapshot
- trusted peer set
- trust bootstrap model
- trust metadata in cluster observation

Why now:

- routing is already smart enough to need trust
- capability gossip without identity is too weak
- future governance, approval, and decentralized knowledge all depend on identity

Non-goals for this phase:

- full PKI
- enterprise-grade auth stack
- complex certificate automation

Simple, explicit, and inspectable is the right start.

## Phase 2: Discovery And Capability Registry Protocol

Priority: very high
Status: next

Goal:

Make node discovery and capability registration a formal cluster primitive.

What this phase should add:

- canonical capability snapshot schema
- split between static, runtime, and observed capabilities
- capability provenance
- capability snapshot signing
- capability registry / gossip normalization
- clearer handling of stale or conflicting observations

Desired model:

- `can_do`
- `available_now`
- `allowed_to_do`
- `observed_by`
- `observed_at`
- `confidence`
- `trust`

This phase turns the current capability field into a more stable protocol surface.

## Phase 3: Placement, Ownership, And Rebalancing

Priority: high
Status: after identity/discovery

Goal:

Move from “find a matching peer” to “continuously place work well”.

What this phase should add:

- ownership transfer with capability awareness
- rebalancing by load, trust, locality, freshness, and policy
- graceful degradation paths
- replication planner as a cluster-native subsystem
- better distinction between preferred placement and fallback placement

This is where the cluster starts behaving like a living adaptive runtime rather than only a smart router.

## Phase 4: Governance And Controlled Evolution

Priority: high
Status: after identity foundation

Goal:

Extend approval/policy thinking from app evolution into cluster actions.

What this phase should add:

- cluster action classes
- action policy
- approval-required cluster changes
- trusted operator / approver model
- signed governance trail
- diagnostics that distinguish auto, approval, and forbidden paths

Examples:

- admitting a new peer
- trusting a new key
- enabling risky capabilities
- accepting topology-affecting replication

## Phase 5: Decentralized Knowledge Plane

Priority: medium-high
Status: after trust foundation

Goal:

Introduce decentralized retrieval and knowledge sharing as a cluster-native capability layer.

Important:

This should not be a `core` feature.

The most likely home is:

- `sdk/rag`
- plus cluster integration points

What this phase should add:

- local knowledge shards on peers
- distributed retrieval
- content-addressed references
- trust-aware merge/rank of retrieved results
- capability-based routing for retrieval and indexing

Short version:

Decentralized RAG fits Igniter well, but only after identity and trust exist.

## Phase 6: Signed Crest And Compacted Replicated State

Priority: medium-high
Status: later

Goal:

Realize the “wave crest” idea for replicated cluster state.

Instead of treating cluster history as something that must grow forever, the cluster should preserve a signed, auditable crest of relevant state and compact older history behind checkpoints.

What this phase should add:

- rolling checkpoints
- signed state snapshots
- compacted cluster event history
- proof of current state without retaining all history forever
- bounded audit horizon with explicit archival strategy

Note:

This is intentionally not framed as “blockchain”.
The important idea is signed, compacted, replicated state with auditability, not chain maximalism.

## What We Are Explicitly Not Optimizing For Yet

- bringing roles back as a primary abstraction
- heavy consensus everywhere
- global universal policy engine before identity exists
- RAG in `core`
- blockchain framing as the primary design metaphor

## Recommended Immediate Implementation Order

If we implement the roadmap in the healthiest order, the next steps should be:

1. Introduce cluster identity primitives.
2. Sign manifests and capability snapshots.
3. Add trusted peer configuration and trust-aware diagnostics.
4. Normalize capability discovery protocol around signed observation.
5. Then expand toward placement/rebalancing.

## Success Criteria For “Cluster Next”

We can say this roadmap stage is working when:

- a node has a stable identity
- capability claims are attributable and inspectable
- the router can factor trust into peer choice
- discovery is formalized rather than ad hoc
- cluster diagnostics can explain not just fit, but trust and governance state
- future decentralized capabilities can build on this without changing the kernel

## One-Line Direction

`Igniter::Cluster` should become a capability-driven, trust-aware, decentralized execution mesh whose business graphs stay stable while the network around them remains plastic, inspectable, and governable.
