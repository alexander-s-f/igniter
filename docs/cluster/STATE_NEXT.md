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

- `NodeObservation` — typed, frozen per-node snapshot with seven OLAP dimensions
- `Peer#to_observation(now:, workload_tracker:)` — produces a NodeObservation; if `workload_tracker` is supplied, the workload dimension is populated from live signals
- `Peer#profile` now returns `NodeObservation` (backwards-compatible with `CapabilityQuery`)
- `PeerRegistry#observation_for`, `#observations`, `#observations_matching_query` — all accept `workload_tracker:` kwarg
- `Mesh::Config#local_state` / `#local_locality` — new dimension config
- `Announcer` propagates state and locality in peer announcements
- `NodeObservation#dimensions` — full OLAP Point summary across all seven dimensions

The seven dimensions live in typed readers: capabilities, trust, state, locality, governance, provenance, **workload**.
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
- `PlacementPlanner` — weighted scorer across 8 dimensions (health 25%, trust 20%, load_cpu 18%, load_memory 12%, workload 15%, locality 7%, confidence 2%, freshness 1%)
- `PlacementDecision` — typed result: chosen node, composite score, per-dimension breakdown, rejected candidates, degraded flag
- `RebalancePlanner` — detects ownership skew across eligible nodes, generates greedy transfer plan
- `RebalancePlan` — typed list of `:transfer_ownership` actions, `#to_routing_plans` for executor integration
- `Mesh.place(capability, policy:)` — convenience entry point using live `PeerRegistry` with workload_tracker
- `Mesh.rebalance(ownership_registry, capabilities:, skew_threshold:)` — convenience entry point

Scoring model: `score = Σ weight_i × dim_score_i`. Deterministic — ties broken by node name.
Workload score: healthy=1.0, overloaded=0.3, degraded=0.2, both=0.0, no data=0.8 (neutral-positive).

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

Workload clauses added in Phase 10:
```
  AND NOT DEGRADED               -- workload dimension: not in degraded state
  AND NOT OVERLOADED             -- workload dimension: not overloaded
  AND failure_rate < 0.1         -- workload metric (float)
  AND avg_latency_ms < 200       -- workload metric (milliseconds)
ORDER BY failure_rate ASC
ORDER BY avg_latency_ms DESC
```

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

## Landed Remote RAG Fan-out (Phase 7)

The knowledge plane is now genuinely distributed:

- `RAG::NetHttpAdapter` — production `Net::HTTP` client: `POST /rag/search` with JSON body, deserialises response into `RetrievalResult` objects with the caller's `NodeObservation` attached for composite scoring. All errors return `[]` (graceful degradation). Injectable for testing.
- `RAG::FanoutRetriever` — parallel fan-out engine: discovers `:rag`-capable peers via `ObservationQuery`, spawns one Thread per peer (network I/O bound), merges local + remote results through trust-aware `Ranker`. `require_trust: true` (default) skips untrusted peers; `require_trust: false` includes them with reduced composite score.
- `Mesh.retrieve(text, distributed: false)` — extended with `distributed:`, `require_trust:`, `timeout:`, `now:`, and `http_adapter:` kwargs. When `distributed: false` (default) behaviour is unchanged (local shard). When `distributed: true` delegates to `FanoutRetriever`.
- `Companion::Main::RagSearchHandler` — route handler for `POST /v1/rag/search`, exposes the local shard over HTTP so peer nodes can fan out to it.
- Route wired in `Companion::MainApp`: `route "POST", "/v1/rag/search", with: Companion::Main::RagSearchHandler`.

Wire format (request body): `{ "text": "...", "tags": [...], "limit": N, "min_score": 0.0 }`
Wire format (response body): `{ "results": [...], "shard": "node-name", "count": N }`

Spec coverage: `spec/igniter/cluster/rag_fanout_spec.rb` + companion `main_app_spec.rb` — 25 new examples, 0 failures.

Example:
```ruby
# On each node:
Igniter::Cluster::Mesh.configure do |c|
  c.peer_name          = "knowledge-node-a"
  c.local_capabilities = [:rag]
end
Igniter::Cluster::Mesh.shard.add("Ruby closures capture their environment", tags: [:ruby])

# Local-only retrieval (default):
Igniter::Cluster::Mesh.retrieve("closures", limit: 5)

# Distributed fan-out across all :rag peers:
Igniter::Cluster::Mesh.retrieve("closures", distributed: true, require_trust: true, timeout: 3)

# Custom transport for testing:
mock_adapter = ->(url, query, observation: nil) { [...] }
Igniter::Cluster::Mesh.retrieve("closures", distributed: true, http_adapter: mock_adapter)
```

## Landed Governance-Backed Peer Admission (Phase 8)

Peer admission is now a formal governance workflow, not just a routing plan:

- `Governance::AdmissionRequest` — immutable `Data.define` value: `request_id` (UUID), `peer_name`, `node_id`, `public_key`, `capabilities`, `justification`, `requested_at`, `fingerprint` (24-hex SHA256 of public key)
- `Governance::AdmissionDecision` — typed result: `outcome` (`:admitted / :rejected / :pending_approval / :already_trusted`), `request`, `rationale`, `decided_at`. Predicate readers: `admitted?`, `rejected?`, `pending_approval?`, `already_trusted?`
- `Governance::AdmissionPolicy` — declarative evaluation rules. Evaluation order (first match wins): (1) `trust_store.known?(node_id)` → `:already_trusted`; (2) forbidden capability present → `:rejected`; (3) matching `known_keys` fingerprint → `:admitted`; (4) `require_approval: true` (default) → `:pending_approval`; (5) open policy → `:admitted`
- `Governance::AdmissionQueue` — thread-safe `Mutex`-guarded in-memory store for pending requests. `enqueue`, `pending`, `find`, `dequeue`, `expire_stale!(ttl)`, `clear!`
- `Governance::AdmissionWorkflow` — orchestrates the full lifecycle: evaluates policy, records governance trail events, updates `TrustStore` on admission, manages `AdmissionQueue`. Methods: `request_admission`, `approve_pending!`, `reject_pending!`, `approve_all_pending!`, `expire_stale!`, `pending_requests`
- `Mesh::Config#admission_policy` / `#admission_queue` — new lazy attrs
- `Mesh.request_admission(peer_name:, node_id:, public_key:, ...)` — submit request
- `Mesh.approve_admission!(request_id)` — operator approval
- `Mesh.reject_admission!(request_id, reason:)` — operator rejection
- `Mesh.pending_admissions` — list pending requests
- `Mesh.expire_stale_admissions!` — expire by policy TTL

Governance trail events recorded: `:admission_requested`, `:admission_admitted`, `:admission_pending`, `:admission_approved`, `:admission_rejected`, `:admission_expired`

Spec coverage: `spec/igniter/cluster/governance_admission_spec.rb` — 54 examples, 0 failures.

Example:
```ruby
Igniter::Cluster::Mesh.configure do |c|
  c.peer_name = "seed-node"
  c.admission_policy = Igniter::Cluster::Governance::AdmissionPolicy.new(
    known_keys:             { "trusted-node" => "known_fingerprint_hex" },
    require_approval:       true,
    forbidden_capabilities: [:admin]
  )
end

# Peer requests to join:
decision = Igniter::Cluster::Mesh.request_admission(
  peer_name: "new-node", node_id: "new-node",
  public_key: pem, capabilities: [:rag, :database]
)
decision.pending_approval? # => true

# Operator approves:
Igniter::Cluster::Mesh.approve_admission!(decision.request.request_id)
# new-node is now in the TrustStore; governance trail has full audit record
```

## Landed Workload Signal Tracker (Phase 9)

The self-heal loop is now reactive to real runtime signals, not just routing reports:

- `Mesh::WorkloadSignal` — immutable `Data.define` per-event record: `peer_name`, `capability`, `success`, `duration_ms`, `error_class`, `recorded_at`. `failure?` predicate.
- `Mesh::PeerCapacityReport` — typed aggregate: `total`, `successes`, `failures`, `failure_rate`, `avg_duration_ms`, `degraded?`, `overloaded?`, `healthy?`. `degraded?` ↔ `failure_rate >= threshold`; `overloaded?` ↔ `avg_duration_ms >= threshold_ms`.
- `Mesh::WorkloadTracker` — thread-safe `Mutex`-guarded sliding window accumulator (bounded per peer-capability pair). Methods: `record`, `report_for`, `report_for_capability`, `all_reports`, `degraded_peers`, `overloaded_peers`, `known_peers`, `reset_peer!`, `reset!`, `total_signals`. Window overflow drops oldest signals — memory bounded by `window_size`.
- `Mesh.workload_tracker` — lazily creates singleton tracker.
- `Mesh.record_workload(peer_name, capability, success:, duration_ms:, error:)` — records a signal and automatically emits governance trail events on state transitions: `:peer_degraded` (first time failure_rate exceeds threshold), `:peer_recovered` (drops back below), `:peer_overloaded` (avg latency exceeds threshold).
- `Mesh.repair_from_workload_signals!(degraded_threshold:, execute:)` — identifies degraded and overloaded peers (both static and registry peers), generates `:refresh_capabilities` routing plans, optionally executes automated ones. Returns `{ degraded:, overloaded:, plans:, results: }`.

Spec coverage: `spec/igniter/cluster/mesh_workload_tracker_spec.rb` — 42 examples, 0 failures.

Example:
```ruby
# During request handling:
begin
  result = route_request_to(:database)
  Igniter::Cluster::Mesh.record_workload(result.peer_name, :database,
    success: true, duration_ms: result.elapsed_ms)
rescue => e
  Igniter::Cluster::Mesh.record_workload("node-b", :database,
    success: false, error: e)
end

# Periodic self-heal tick:
outcome = Igniter::Cluster::Mesh.repair_from_workload_signals!(
  degraded_threshold: 0.25,
  execute: true          # run automated plans immediately
)
# outcome[:degraded]  → ["node-b"]
# outcome[:plans]     → [{ action: :refresh_capabilities, ... }]
```

## Landed Workload Dimension in NodeObservation (Phase 10)

The OLAP Point model now has a 7th live dimension — workload signals from `WorkloadTracker` are embedded directly into every `NodeObservation`. This closes the most expensive integration seam: runtime failure state now flows into every query surface simultaneously.

**What changed:**

- `NodeObservation` workload accessors: `workload_failure_rate`, `workload_avg_duration_ms`, `workload_total`, `workload_degraded?`, `workload_overloaded?`, `workload_healthy?`, `workload_observed?`
- `WorkloadTracker#to_metadata_for(peer_name)` — builds `{ mesh_workload: {...} }` metadata hash from a `PeerCapacityReport`; returns nil when no signals recorded
- `Peer#to_observation(now:, workload_tracker:)` — merges workload metadata when tracker is supplied
- `PeerRegistry#observations(now:, workload_tracker:)`, `#query(now:, workload_tracker:)`, `#observation_for(now:, workload_tracker:)` — all propagate the tracker through
- `Mesh.query`, `Mesh.meshql`, `Mesh.place`, `Mesh.rebalance`, `Mesh.repair_from_workload_signals!` — all automatically pass `config.workload_tracker` so workload data is always live in the observation layer

**ObservationQuery new filters:**
- `.not_degraded` — exclude peers where `workload_degraded? == true`
- `.not_overloaded` — exclude peers where `workload_overloaded? == true`
- `.workload_healthy` — keep only peers that are neither degraded nor overloaded
- `.max_failure_rate(threshold)` — filter by failure rate; nil passes through (no data = acceptable)
- `.max_latency_ms(threshold)` — filter by avg latency; nil passes through
- `ORDER BY :failure_rate`, `ORDER BY :avg_latency_ms` — added to ORDERABLE_DIMENSIONS

**PlacementPlanner scoring updated:**
- Workload is now the 5th scoring dimension (weight 15%): healthy=1.0, overloaded=0.3, degraded=0.2, both=0.0, no data=0.8
- Other weights rebalanced: health 25%, trust 20%, load_cpu 18%, load_memory 12%, locality 7%, confidence 2%, freshness 1%

**MeshQL extended:**
- `NOT DEGRADED`, `NOT OVERLOADED` — keyword conditions
- `failure_rate`, `avg_latency_ms` — numeric metrics with full operator support
- `ORDER BY failure_rate`, `ORDER BY avg_latency_ms` — orderable
- `ParsedQuery#to_meshql` serialises all new conditions (round-trippable)

Spec coverage: 38 new examples across `mesh_node_observation_spec.rb`, `mesh_observation_query_spec.rb`, `mesh_placement_planner_spec.rb`, `mesh_ql_spec.rb`. Total cluster suite: 897 examples, 0 failures.

Example:
```ruby
# ObservationQuery with workload filters
Igniter::Cluster::Mesh.query
  .with(:database)
  .not_degraded
  .max_failure_rate(0.1)
  .max_latency_ms(300)
  .order_by(:failure_rate)
  .first

# MeshQL workload clauses
Igniter::Cluster::Mesh.meshql(
  "SELECT :database WHERE NOT DEGRADED AND failure_rate < 0.1 AND avg_latency_ms < 300 ORDER BY failure_rate ASC LIMIT 1"
)

# Placement automatically uses live workload data
decision = Igniter::Cluster::Mesh.place(:database)
decision.dimensions[:workload]  # => 1.0 (healthy) or 0.2 (degraded)
```

## Landed AdmissionWorkflow → PeerRegistry Auto-Registration (Phase 11)

The second major integration seam is now closed: admitted peers become immediately routable without any manual registration step.

**What changed:**

- `AdmissionRequest` gains a `url:` field (optional, defaults to `""`) and a `routable?` predicate (`true` when url is non-empty)
- `AdmissionWorkflow#request_admission` accepts `url:` kwarg and propagates it into the request
- `AdmissionWorkflow#register_in_peer_registry!(request)` — private method: builds a `Mesh::Peer` with capabilities + trust metadata and calls `config.peer_registry.register(peer)`. No-ops when `!request.routable?`
- Registration fires at both auto-admit paths: `request_admission` (policy evaluates `:admitted`) and `approve_pending!` (operator approval)
- `Mesh.request_admission` accepts `url:` kwarg; passes it through to the workflow

**Behaviour:**
- Peer provides `url:` → on admission, appears in `PeerRegistry`, routable via `Mesh.query`, `Mesh.place`, `Mesh.meshql`
- Peer omits `url:` → trust-only admission (TrustStore updated, no routing registration); unchanged from Phase 8
- `reject_pending!` and `expire_stale!` do NOT register — only admitted peers become routable

Spec coverage: 16 new examples in `governance_admission_spec.rb`. Total cluster suite: 913 examples, 0 failures.

Example:
```ruby
# Open-key policy: peer is auto-admitted and immediately routable
Igniter::Cluster::Mesh.configure do |c|
  c.admission_policy = Igniter::Cluster::Governance::AdmissionPolicy.new(
    known_keys: { "peer-b" => fp_b }
  )
end

decision = Igniter::Cluster::Mesh.request_admission(
  peer_name:    "node-b",
  node_id:      "peer-b",
  public_key:   pem,
  url:          "http://node-b:4567",
  capabilities: [:database, :rag]
)
decision.admitted?  # => true

# Immediately routable — no manual add_peer required
Igniter::Cluster::Mesh.query.with(:database).map(&:name)  # => ["node-b"]
Igniter::Cluster::Mesh.place(:rag).url                    # => "http://node-b:4567"

# Manual approval path also registers
request_id = Igniter::Cluster::Mesh.pending_admissions.first.request_id
Igniter::Cluster::Mesh.approve_admission!(request_id)
# => peer is now in PeerRegistry
```

## Landed Unified Repair Tick (Phase 12)

The `RepairLoop` background thread is now a single, unified tick that consumes both signal sources simultaneously.

**What changed:**

- `RepairLoop#heal_once` is now the unified entry point: calls `execute_routing_heal` (existing path) and `execute_workload_heal` (new path) in sequence on every tick
- `execute_routing_heal` — extracted from the former `heal_once` body; records `:routing_self_heal_tick` governance trail event; backward-compatible return type (`RoutingPlanResult`)
- `execute_workload_heal` — new private method: reads `degraded_peers` and `overloaded_peers` from `config.workload_tracker`, builds observations from `PeerRegistry` + static peers, generates `:refresh_capabilities` plans for each problem peer, executes them via `RoutingPlanExecutor`, records `:workload_self_heal_tick` governance trail event with `{ degraded:, overloaded:, plans:, applied:, blocked: }` payload
- `execute_workload_heal` is only called when `@config.workload_tracker` is set — zero overhead when workload tracking is not configured
- Both repair paths are fully independent: a `StandardError` in workload heal returns nil (does not interrupt routing heal); a `StandardError` in routing heal returns `idle_result(:loop_error)` as before
- Backward-compatible: `heal_once` still returns the `RoutingPlanResult` from the routing path

**New governance trail event:**
- `:workload_self_heal_tick` — recorded when at least one degraded or overloaded peer generates plans; payload: `{ source: :repair_loop, degraded: [...], overloaded: [...], plans: N, applied: N, blocked: N }`

Spec coverage: 5 new examples in `mesh_discovery_spec.rb` (workload tick context). Total cluster suite: **918 examples, 0 failures**.

Example:
```ruby
Igniter::Cluster::Mesh.configure do |c|
  c.peer_name          = "api-node"
  c.self_heal_interval = 30           # seconds between ticks
  c.workload_tracker   = Igniter::Cluster::Mesh::WorkloadTracker.new
end

# On each background tick, both repair paths run:
#   1. Routing diagnostics plans (from config.self_heal_report_provider)
#   2. Workload-degraded peer plans (from config.workload_tracker)

Igniter::Cluster::Mesh.start_repair_loop!

# Governance trail captures both:
# { type: :routing_self_heal_tick, payload: { plans: 2, applied: 2, ... } }
# { type: :workload_self_heal_tick, payload: { degraded: ["node-b"], plans: 1, applied: 1, ... } }
```

## Landed Checkpoint Gossip Loop (Phase 13)

Governance checkpoints are now automatically replicated across the mesh during every peer discovery and gossip exchange. This closes the "one-directional checkpoint" gap: nodes receive peers' signed checkpoints passively during normal discovery, compare them to the local checkpoint, and persist any newer one.

**What changed:**

- `Mesh::CheckpointGossip` — new module with a single `sync(peer_metadata, config:, source:)` method:
  1. Extracts `mesh_governance.checkpoint` hash from peer metadata (already embedded by `PeerIdentityEnvelope#attach_governance`)
  2. Reconstructs a `Governance::Checkpoint` via `from_h`
  3. Verifies the RSA/ECDSA signature — tampered or unsigned payloads are silently dropped
  4. Compares `checkpointed_at` timestamps against the local `CheckpointStore`
  5. Saves only when the remote checkpoint is strictly newer than the local one
  6. Records `:checkpoint_replicated` governance trail event on save: `{ from_peer:, crest_digest:, checkpointed_at: }`
  7. All errors swallowed via `rescue StandardError` — checkpoint sync is best-effort
- `Poller#fetch_peers_from` — calls `CheckpointGossip.sync(attributes[:metadata], config: @config, source: :poller)` after each peer registration
- `GossipRound#exchange_with` — calls `CheckpointGossip.sync(attributes[:metadata], config: @config, source: :gossip)` after each peer registration
- Both paths are no-ops when `config.checkpoint_store` is nil

**Security:**
- Self-verifying: remote checkpoint carries its own `public_key`; signature is verified before acceptance
- Timestamps compared as `Time` objects, not strings, preventing timezone-format edge cases
- Tampered checkpoints (crest modified after signing) fail `verify_signature` and are dropped silently

**New governance trail event:**
- `:checkpoint_replicated` — recorded when a newer remote checkpoint is persisted locally; payload: `{ source: :poller|:gossip, from_peer:, crest_digest:, checkpointed_at: }`

Spec coverage: 6 new examples — 5 in Poller checkpoint gossip context + 1 GossipRound describe block. Total cluster suite: **924 examples, 0 failures**.

Example:
```ruby
Igniter::Cluster::Mesh.configure do |c|
  c.peer_name       = "api-node"
  c.seeds           = %w[http://seed1:4567]
  c.checkpoint_store = Igniter::Cluster::Governance::Stores::CheckpointStore.new(
    path: "var/governance/checkpoint.json"
  )
end

# On every poll_once tick, if any peer carries a newer signed checkpoint:
# 1. Checkpoint is verified and saved to checkpoint_store
# 2. Governance trail records :checkpoint_replicated
# 3. Next compact_governance! chains from the replicated checkpoint

Igniter::Cluster::Mesh.start_discovery!

# Later inspection:
cp = Igniter::Cluster::Mesh.config.checkpoint_store.load
cp.crest_digest    # => "3a8f..."
cp.verify_signature # => true
```

## Landed Companion Modernisation (Phase 14)

The companion dashboard now surfaces three new operational panels, bringing it in sync with the Phase 10–13 cluster infrastructure.

**What changed:**

**`StackOverview` additions:**
- `workload_snapshot` — reads from `WorkloadTracker.all_reports`; returns sorted array of `{ peer_name, total, failure_rate, avg_ms, degraded, overloaded, healthy }` hashes; no-op when tracker not configured
- `governance_snapshot` — reads `Trail#snapshot(limit: 20)`, `CheckpointStore#load`; returns `{ total, by_type, recent_events (last 8, newest-first), checkpoint (peer_name, crest_digest, checkpointed_at, chained) }`
- `admission_snapshot` — reads `AdmissionQueue#pending`; returns array of `{ request_id, peer_name, node_id, capabilities, requested_at, routable }` hashes
- `routing_snapshot` extended with `latest_workload_tick` field (mirrors `latest_self_heal_tick` for `:workload_self_heal_tick` events)
- `counts` extended with `pending_admissions:` and `workload_peers:` metric counts

**Three new `HomePage` panels:**
- **Workload Health** — per-peer KeyValueList: `signals=N failure_rate=0.xxx avg_ms=NN [healthy|DEGRADED|OVERLOADED|degraded + overloaded]`; empty-state message when no signals recorded
- **Governance Trail** — checkpoint summary (peer, digest, timestamp, chained flag), events-by-type counts, recent events resource list (type, source, timestamp); no-op sections when empty
- **Admission Queue** — pending requests resource list with per-request Approve / Reject form buttons (POST to `/admin/admission?action=admit|reject&request_id=...`); empty-state when queue is clear

**Self-Heal panel updated:** "last self-heal" row renamed to "last routing tick"; new "last workload tick" row shows `:workload_self_heal_tick` timestamp

**New handler and route:**
- `AdmissionActionHandler` — `POST /admin/admission`; reads `action` and `request_id` from query string (via `URI.decode_www_form`); calls `Mesh.approve_admission!` or `Mesh.reject_admission!`; redirects to `/?admission=admit|reject`
- Route wired in `DashboardApp`: `route "POST", "/admin/admission", with: Companion::Dashboard::AdmissionActionHandler`

Spec coverage: 4 new examples in `dashboard_app_spec.rb` (panel presence, overview keys, admit redirect, reject redirect). Companion suite: **8 examples, 0 failures**. Full cluster suite: **924 examples, 0 failures**.

## Architectural Assessment (post Phase 14)

### What is genuinely strong

- **Dimensions-first model holds through 14 phases.** Seven OLAP dimensions, all query surfaces consistent, workload data flows automatically.
- **All integration seams closed.** WorkloadTracker→PlacementPlanner, AdmissionWorkflow→PeerRegistry, RepairLoop unified tick, passive checkpoint gossip — all landed.
- **Companion is now a genuine proving surface.** Workload heatmap, governance trail, admission queue, and self-heal demo all visible and operable from the dashboard without code changes.
- **Zero production dependencies at full functionality.** SHA256, OpenSSL, Net::HTTP, Mutex, Thread — all stdlib. This constraint held through 14 phases.

### Where the remaining weaknesses are

**RAG scoring is keyword-only.** `text_score = hits/words` is primitive. No BM25, no positional weight. Retrieval quality is limited for semantic queries.

**Checkpoint gossip is passive.** Checkpoints are synced when peers are discovered, but there is no active push. Good enough for most topologies; active push would be an edge-case improvement.

**Companion RAG demo is absent.** The `RagSearchHandler` exists in the main app but the dashboard has no search UI for it.

### Key insight (updated)

Fourteen phases in, and the cluster is operationally self-contained: admission, routing, workload health, self-healing, governance compaction, checkpoint replication, and now operator visibility through a live dashboard. The remaining work is retrieval quality (BM25) and the RAG demo UI — neither is a seam in the infrastructure.

## Recommended Next Focus

### Level 3 — Retrieval quality

**D. BM25 scoring for RAG** — replace `hits/words` with BM25 (pure math, no deps). Significantly better retrieval quality for multi-word queries. Scoring formula: `TF × IDF` with length normalization; all math is stdlib Ruby arithmetic.

## Short Resume Prompt

`Igniter::Cluster` has a full 14-phase implementation: capability mesh, signed identity/trust, OLAP Point observation (7 dimensions) with MeshQL, multi-dimensional placement and rebalancing, compacted governance trail with checkpoint chaining, governance-backed peer admission, distributed RAG fan-out, workload signal tracking, workload dimension in NodeObservation, AdmissionWorkflow→PeerRegistry auto-registration, unified RepairLoop tick (routing + workload), passive checkpoint gossip, and companion dashboard modernisation (workload heatmap, governance trail panel, admission queue with approve/reject UI). All integration seams closed. Remaining: BM25 for RAG scoring.
