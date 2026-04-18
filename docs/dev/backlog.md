# Igniter Backlog

This file tracks the next meaningful development steps for Igniter.
Implemented features should move out of the backlog and into stable docs.

## Recently Landed

- `branch` is implemented, including exported child outputs, runtime `branch_selected`
  events, and matcher-style routing via exact values, `in:`, and `matches:`.
- `collection` is implemented with `CollectionResult`, `:collect` / `:fail_fast` /
  `:incremental`, per-item events, diagnostics, and `map_inputs`.
- `scope` / `namespace` are implemented as path-grouping tools for readability and
  introspection.

## Cluster: Formal Capability Discovery Protocol (Phase 2)

Status: next
Priority: very high

Problem:

- The cluster already has capability queries, signed manifests, and trust-aware routing.
- The model is still spread across runtime structures without a canonical snapshot shape.
- Stale or conflicting observations have no explicit handling protocol.

What this needs:

- `NodeObservation` as a first-class value object in the cluster layer
- Canonical observation envelope with all dimensions: capabilities, state, trust, locality, governance
- Split between self-claimed and relayed observations
- Explicit conflict and staleness resolution
- Gossip propagates full observation envelopes, not raw capability hashes
- `CapabilityQuery` accepts an `ObservationPoint` input

Why now:

- Phase 2 is the precondition for the OLAP Point query surface
- Without a canonical envelope, each new dimension (load, locality, knowledge) adds ad hoc fields to gossip structures

## Cluster: Placement And Rebalancing (Phase 3)

Status: next
Priority: high

Problem:

- Routing is already expressive: it finds a peer that matches right now.
- The cluster has no concept of where work should live over time.
- Degraded nodes stay overloaded; healthy nodes are under-used; ownership does not shift with load.

What this needs:

- Ownership transfer with capability awareness
- Rebalancing by load, trust, locality, freshness, and policy
- Graceful degradation paths when preferred placement is unavailable
- Preferred vs fallback placement distinction
- Replication planner as a cluster-native subsystem

Why it matters:

- The cluster should decide where work lives, not only which peer matches a query.
- Self-healing is more valuable when the cluster can also redistribute work proactively.

## Cluster: OLAP Point Query Surface

Status: design — see OLAP_POINT_V1.md
Priority: high

Problem:

- CapabilityQuery is one-dimensional: it filters by capability.
- Routing, placement, and diagnostics each need multi-dimensional reasoning over the same peer data.
- There is no unified model for "a node's observable profile".

What this needs:

- `NodeObservation` with canonical dimension fields (Phase 2 prerequisite)
- Multi-dimensional ranking in CapabilityQuery: capabilities + load + trust + locality
- Diagnostics that explain rejections by dimension
- Foundation for MeshQL

Why it matters:

- Placement, routing, and diagnostics converge on the same observable surface instead of growing separate data paths.
- MeshQL depends on this as its query target.

See [OLAP Point v1](./OLAP_POINT_V1.md) for the full concept.

## Cluster: Decentralized RAG (Phase 5)

Status: idea — after trust foundation
Priority: medium-high

Problem:

- Knowledge retrieval today is either centralized or outside the cluster.
- Nodes with domain-specific knowledge have no way to advertise or share it through the mesh.
- RAG-style retrieval needs to be trust-aware and capability-routed.

What this needs:

- Local knowledge shards on peers (`sdk/rag`)
- Distributed retrieval via capability-routing (`:knowledge` capability)
- Content-addressed references for shard identity
- Trust-aware merge and rank of retrieved results from multiple peers

Why later:

- Decentralized RAG depends on stable identity (Phase 1, landed) and formal discovery protocol (Phase 2).
- The knowledge dimension in the OLAP Point envelope is the integration point.

## Cluster: MeshQL (future — after OLAP Point)

Status: concept
Priority: medium

Problem:

- As the cluster becomes a multi-dimensional OLAP field, routing queries expressed as Ruby keyword arguments become limiting.
- Complex placement decisions need a composable, inspectable query language.

What this needs:

- A Ruby DSL over `NodeObservation` arrays (first step — no parser needed)
- Formal grammar over the canonical observation envelope
- Local evaluation for small clusters; distributed fan-out for larger topologies

Why later:

- MeshQL has no value before the OLAP Point observation envelope exists (Phase 2).
- A query language built on an ad hoc gossip structure will need to be rewritten.

See [OLAP Point v1](./OLAP_POINT_V1.md) for the preconditions.

## Branch Predicates vNext

Status: idea
Priority: medium

Problem:

- Current branch routing covers exact values, set membership, and regex matching.
- Some workflows still need richer predicates that combine several context values or
  perform custom boolean checks.
- Today that logic must still fall back to `compute` nodes before branching.

Example direction:

```ruby
branch :delivery_strategy, with: :country, depends_on: [:vip] do
  on eq: "US", contract: USDeliveryContract
  on_if ->(selector:, vip:) { selector == "CA" && vip }, contract: PriorityCanadaContract
  default contract: DefaultDeliveryContract
end
```

Why it matters:

- keeps routing declarative even for non-trivial business rules
- avoids scattering selector normalization across helper compute nodes
- makes future schema/UI routing editors more expressive

Open design questions:

- proc matcher shape: `selector:` only or full context values
- compile-time validation vs runtime-only validation for callable matchers
- how predicate cases should appear in graph introspection and schema export
- how to keep case ordering understandable when mixing exact and predicate branches

Suggested implementation order:

1. add a short design note for callable branch predicates
2. keep ordered-first-match semantics
3. add introspection formatting for predicate cases
4. add runtime event payloads that expose matcher kind clearly

## Async Collections vNext

Status: idea
Priority: high

Problem:

- Collections already support synchronous fan-out and incremental diffing.
- Real deployments still need per-item pending/resume and durable store-backed item
  execution for slow or external work.
- Without item-level persistence, large batches must either block inline or move
  orchestration outside Igniter.

Example direction:

```ruby
collection :quotes,
  with: :quote_inputs,
  each: QuoteContract,
  key: :quote_id,
  mode: :collect,
  runner: :store
```

Why it matters:

- unlocks long-running fan-out workflows
- fits naturally with existing `await` and store-backed execution
- creates a path toward resumable partial batches

Open design questions:

- item-level snapshot format and execution identifiers
- whether parent collection state becomes pending or partially pending
- resume API surface for single item vs whole collection
- interaction with `:incremental` collection mode

Suggested implementation order:

1. design item snapshot and restore semantics
2. persist child execution ids in `CollectionResult`
3. support resume for pending items
4. extend diagnostics with pending-item summaries

## Scoped Interfaces vNext

Status: idea
Priority: medium

Problem:

- `scope` / `namespace` currently improve readability by grouping node paths.
- Larger contracts may eventually need stronger subgraph semantics without paying the
  full cost of extracting every group into a standalone composed contract.
- There is still no local-interface concept for a grouped block.

Example direction:

```ruby
namespace :availability do
  input :vendor_id
  input :zip_code_raw

  compute :vendor, ...
  compute :availability, ...

  expose :availability
end
```

Why it matters:

- creates a middle layer between visual grouping and full composition
- could improve future graph editors and schema-driven authoring
- makes large contracts easier to reason about as explicit subgraphs

Open design questions:

- should scoped inputs/outputs be compile-time sugar or real model nodes
- how visibility rules should work across scope boundaries
- whether inline scopes should compile into one graph or nested child executions
- how export/expose semantics should behave for scoped outputs

Suggested implementation order:

1. write a design note comparing scoped interfaces vs composition
2. decide whether vNext is syntax sugar or a real subgraph primitive
3. define path and visibility semantics
4. add introspection output that makes scope boundaries explicit
