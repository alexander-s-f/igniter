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

## Landed Discovery Protocol (Phase 2)

The canonical observation envelope is now implemented:

- `NodeObservation` — typed, frozen per-node snapshot with six OLAP dimensions
- `Peer#to_observation(now:)` — produces a NodeObservation with freshness computed at call time
- `Peer#profile` now returns `NodeObservation` (backwards-compatible with `CapabilityQuery`)
- `PeerRegistry#observation_for`, `#observations`, `#observations_matching_query` — typed query surface
- `Mesh::Config#local_state` / `#local_locality` — new dimension config
- `Announcer` propagates state and locality in peer announcements
- `NodeObservation#dimensions` — full OLAP Point summary across all six dimensions

The six dimensions now live in typed readers: capabilities, trust, state, locality, governance, provenance.
`CapabilityQuery` works against `NodeObservation` without any change (same duck-type interface).

## Landed OLAP Point Query Surface (Phase 4b)

The OLAP field is now queryable via a Ruby DSL:

- `ObservationQuery` — immutable, chainable query builder over `NodeObservation` collections
- Dimension-native filter methods: `.with`, `.without`, `.tagged`, `.trusted`, `.healthy`, `.max_load_cpu`, `.in_region`, `.in_zone`, etc.
- `.where { |o| ... }` — arbitrary predicate escape hatch
- `.matching(query)` — passthrough to existing `CapabilityQuery`
- `.order_by(:load_cpu)` / `.order_by(:concurrency, direction: :desc)` — multi-key ordering
- `.limit(n)`, `.first`, `.count`, `.empty?`, full `Enumerable` support
- `Igniter::Cluster::Mesh.query(now:)` and `registry.query(now:)` as entry points

Example:
```ruby
Igniter::Cluster::Mesh.query
  .with(:database)
  .trusted
  .in_zone("us-east-1a")
  .max_load_cpu(0.5)
  .order_by(:load_cpu)
  .first
```

This is the OLAP Point query surface. MeshQL would be a grammar/parser on top.

## Landed Placement & Rebalancing (Phase 3)

Multi-dimensional placement and ownership rebalancing are now implemented:

- `PlacementPolicy` — declarative constraints (health, trust, load thresholds, locality affinity, degraded fallback)
- `PlacementPlanner` — weighted scorer across 7 dimensions (health 30%, trust 20%, load_cpu 20%, load_memory 15%, locality 10%, confidence 3%, freshness 2%)
- `PlacementDecision` — typed result: chosen node, composite score, per-dimension breakdown, rejected candidates, degraded flag
- `RebalancePlanner` — detects ownership skew across eligible nodes, generates greedy transfer plan
- `RebalancePlan` — typed list of `:transfer_ownership` actions, `#to_routing_plans` for executor integration
- `Mesh.place(capability, policy:)` — convenience entry point using live `PeerRegistry`
- `Mesh.rebalance(ownership_registry, capabilities:, skew_threshold:)` — convenience entry point

Scoring model: `score = Σ weight_i × dim_score_i`. Deterministic — ties broken by node name.

Degraded fallback: when primary candidate set is empty and `degraded_fallback: true`, placement retries with a fully relaxed policy and marks the `PlacementDecision` as degraded.

Rebalancing algorithm: floor-division target per node; ineligible (orphaned) owners prioritised as sources; stops when max-min count among eligible nodes is ≤ 1.

Example:
```ruby
policy = Igniter::Cluster::Mesh::PlacementPolicy.new(
  zone: "us-east-1a", locality_preference: :zone,
  require_trust: true, max_load_cpu: 0.7, degraded_fallback: true
)
decision = Igniter::Cluster::Mesh.place(:database, policy: policy)
decision.url      # => "http://node-a:4567"
decision.score    # => 0.87
decision.degraded? # => false

plan = Igniter::Cluster::Mesh.rebalance(ownership_registry, capabilities: [:worker])
plan.balanced?          # => false
plan.skew               # => 4
plan.to_routing_plans   # => [{action: :transfer_ownership, ...}, ...]
```

## Landed MeshQL v1

A declarative string query language for the OLAP Point field is now implemented:

- `MeshQL.parse(source)` → `ParsedQuery` (typed query specification)
- `MeshQL.run(source, observations)` → `Array<NodeObservation>`
- `Igniter::Cluster::Mesh.meshql(source, now:)` → `ObservationQuery`
- `ParsedQuery#to_meshql` → canonical MeshQL string (round-trip)
- Hand-written tokenizer (no external dependencies) + recursive descent parser

**Supported syntax:**
```
SELECT :database, :orders       -- capabilities; * = any
WHERE TRUSTED                   -- trust dimension
  AND HEALTHY                   -- state dimension
  AND load_cpu < 0.5            -- metric operators: < <= > >= = !=
  AND concurrency <= 4
  AND IN ZONE us-east-1a        -- locality dimension
  AND IN REGION us-east-1
  AND TAGGED :linux              -- tag filter
  AND NOT :analytics             -- capability exclusion
  AND AUTHORITATIVE              -- provenance dimension
ORDER BY load_cpu ASC, concurrency DESC
LIMIT 3
```

All keywords are case-insensitive. Unquoted zone/region identifiers (e.g. `us-east-1a`) are supported.

## Landed Decentralized Knowledge Plane (Phase 5 v1)

A cluster-native knowledge shard system is now implemented:

- `RAG::Chunk` — content-addressed knowledge unit (SHA256 id, frozen, idempotent add)
- `RAG::RetrievalQuery` — typed query spec (text, tags, limit, min_score)
- `RAG::RetrievalResult` — result with provenance: raw score, source shard, NodeObservation
- `RAG::KnowledgeShard` — thread-safe in-memory store with keyword relevance search
- `RAG::Ranker` — trust-aware merger/deduplicator across multiple shards
- `Mesh.shard` — lazily creates the local `KnowledgeShard` (name = peer_name)
- `Mesh.retrieve(text, tags:, limit:, min_score:)` — convenience retrieval from local shard

Keyword search scoring:
- `text_score = matched_query_words / total_query_words`
- `tag_bonus = 0.1 × matching_tag_count`
- `raw_score = min(text_score + tag_bonus, 1.0)`
- `composite_score = raw_score × trust_factor × confidence` (Ranker ranking key)

Adding identical content is idempotent (same SHA256 id → same slot).
Empty query with no tags returns [] (null-query guard).

v2 direction: fan-out retrieval to remote `:rag`-capable peers via `ObservationQuery`, merge results through `Ranker`.

Example:
```ruby
Igniter::Cluster::Mesh.configure do |c|
  c.peer_name = "knowledge-node"
  c.local_capabilities = [:rag]
end

shard = Igniter::Cluster::Mesh.shard
shard.add("Ruby closures capture their surrounding environment", tags: [:ruby, :closures])
shard.add("Elixir processes are isolated by default", tags: [:elixir])

results = Igniter::Cluster::Mesh.retrieve("how closures work in Ruby", tags: [:ruby], limit: 5)
results.first.content     # => "Ruby closures capture their surrounding environment"
results.first.score       # => 0.75
results.first.composite_score # => 0.75 (trusted local, confidence 1.0)
```

## Landed Signed Crest & Compacted Replicated State (Phase 6)

The governance trail now has a first-class compaction and checkpoint-chaining subsystem:

- `Trail#compact!(keep_last:, identity:, peer_name:, previous:)` → `CompactionRecord` — collapses old events into a signed Checkpoint, retains `keep_last` recent events in memory and on disk, records a `:trail_compacted` event
- `Trail#events_since(checkpoint)` — returns only events recorded after a checkpoint's timestamp, enabling incremental recovery on restart
- `Trail#compaction_history` — ordered list of all CompactionRecord values produced in this Trail's lifetime
- `CompactionRecord` — typed result: `checkpoint`, `removed_events`, `kept_events`, `checkpoint_digest`, `compacted?`, `signed?`
- `Checkpoint#previous_digest` — optional field linking this checkpoint to the preceding one; included in the signed payload, forming a verifiable chain
- `Checkpoint#chained?` — true when `previous_digest` is set
- `Checkpoint.build(..., previous:)` — accepts a prior Checkpoint and embeds its `crest_digest` as `previous_digest`
- `Stores::CheckpointStore` — file-backed store for a single signed Checkpoint (`save`, `load`, `load_verified`, `clear!`, `exists?`)
- `Stores::FileStore#compact!(events)` — rewrites the NDJSON log to contain exactly the given events (used by `Trail#compact!`)
- `Mesh::Config#checkpoint_store` — optional `CheckpointStore` for persisting compaction output
- `Mesh.compact_governance!(keep_last:, identity:, previous:)` — convenience one-liner: compacts the trail, signs the checkpoint, saves to `CheckpointStore`, and chains to the previous checkpoint loaded from the store

Spec coverage: `spec/igniter/cluster/governance_compaction_spec.rb` — 38 examples, 0 failures.

Example:
```ruby
store = Igniter::Cluster::Governance::Stores::CheckpointStore.new(path: "var/governance/cp.json")
Igniter::Cluster::Mesh.configure do |c|
  c.peer_name        = "node-a"
  c.checkpoint_store = store
  c.governance_log   "var/governance/trail.ndjson", retain_events: 200
end

# First compaction
rec1 = Igniter::Cluster::Mesh.compact_governance!(keep_last: 50)
rec1.compacted?              # => true
rec1.checkpoint.crest_digest # => "3a8f..."

# Second compaction: automatically chained to rec1
rec2 = Igniter::Cluster::Mesh.compact_governance!(keep_last: 50)
rec2.checkpoint.previous_digest # => rec1.checkpoint.crest_digest
rec2.checkpoint.chained?        # => true
rec2.checkpoint.verify_signature # => true
```

## What Is Not Done Yet

Several pieces are still clearly incomplete:

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

## OLAP Point — New Direction

The cluster nodes are now understood as **OLAP Points**: multi-dimensional queryable surfaces exposing capabilities, state, trust, locality, governance, and future knowledge dimensions.

The cluster is a distributed OLAP field over these points. This framing unifies routing (capability dimension), placement (multi-dimension ranking), diagnostics (explain by which dimension eliminated a peer), and gives MeshQL a clear query target.

Key insight: every cluster phase so far has been adding a new dimension to the same per-node observable profile. OLAP Point names this pattern explicitly.

See [OLAP Point v1](../OLAP_POINT_V1.md) for the design document.

The natural implementation path:

1. Phase 2 (discovery protocol) delivers the canonical `NodeObservation` envelope — all existing dimensions in one structured value.
2. Phase 3 (placement) uses the full envelope for multi-dimensional ranking.
3. Phase 4b (OLAP Point query surface) adds a Ruby DSL query layer over observation arrays.
4. MeshQL follows once the observation envelope is stable.

## Recommended Next Focus

If we resume cluster work after a pause, the healthiest next focus looks like this:

1. Formalize the capability discovery/registry protocol (Phase 2) — delivers the `NodeObservation` envelope.
2. Start placement and rebalancing primitives (Phase 3) — uses the envelope for multi-dimension ranking.
3. Build the OLAP Point query surface (Phase 4b) — makes the field queryable as a unified DSL.
4. Keep companion aligned so each new cluster slice has a visible proving story.

## Short Resume Prompt

If we need to re-enter this work quickly later, the mental starting point is:

`Igniter::Cluster` already has a real capability mesh, signed identity/trust, governance crest, routing remediation, and a first self-healing loop. The next likely leap is from smart routing to adaptive placement and clearer discovery protocol design, while keeping Companion as the visible proving surface.
