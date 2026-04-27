# Igniter-Lang: Persistence and Cluster Distribution Model

*Research Series — Document 11*
*Frontier: ★ (current peak)*

---

## §0 Central Insight

In conventional systems, persistence is an infrastructure concern: you configure
databases, write migrations, manage connection pools, and annotate models. The type
system knows nothing about storage.

In a contract-native language, **the type fully specifies the access pattern**.
`History[T]` is not a tag — it declares: append-only, time-indexed, segment-structured,
causally consistent. `OLAPPoint[T, dims]` declares: columnar, partition-prunable,
scan-heavy, scatter-gather parallelisable. `entity` declares: transactional, point-
readable, foreign-key constrained.

The compiler can derive the physical storage layout, the cluster placement strategy,
and the consistency requirements from the type alone. **Persistence becomes a type
property, not an infrastructure concern.** The only configuration is what cannot
be inferred: replication factor, acceptable staleness, backend choice.

Secondary insight: the write path unifies with the language vocabulary. Conflict
resolution for concurrent writes uses `combines:` — the same clause used for rule
conflicts. The seal condition for `HistorySegment` is a temporal invariant.
Execution state checkpoints are just `History[ExecutionState]`. The entire language
applies to the persistence layer; no separate vocabulary is needed.

---

## §1 Storage Shape Taxonomy

Each language construct has a natural *storage shape* — a set of access patterns
that fully determines the physical backend requirements.

| Construct | Shape | Access pattern | Consistency need |
|-----------|-------|----------------|-----------------|
| `entity` | Relational | Point reads/writes, FK joins, transactions | Strong (ACID) |
| `History[T]` | Append-only log | Time-range scans, no updates | Causal |
| `BiHistory[T]` | Bitemporal log | Two-axis range scans, correction-via-append | Causal |
| `OLAPPoint[T, dims]` | Columnar | Partition-pruned scans, aggregations | Eventual |
| `await` / saga state | Durable event log | Sequential append, replay from offset | At-least-once |
| `cache_ttl` / coalesce | Ephemeral KV | Point reads/writes, TTL eviction | None (best-effort) |
| `rule` declarations | Versioned rule set | Read-heavy, immutable versions | Causal |

The compiler reads these shapes from the node type annotations and emits a
*storage requirements manifest* as part of the compilation artifact:

```
CompiledGraph {
  resolution_order: [...],
  storage_requirements: {
    :price_history  => { shape: :timeseries, type: History[Money], ... },
    :revenue_cube   => { shape: :columnar,   type: OLAPPoint[...], ... },
    :order_workflow => { shape: :log,        type: ExecutionState, ... },
  }
}
```

This manifest is the contract between the language and the infrastructure layer.
The runtime reads it to instantiate the correct backend adapters.

---

## §2 `Store[T]` as a Language Construct

A `store` declaration introduces a named, typed, persistent store into the contract
graph. It is itself a contract: `Contract({}) → Store[T]`.

```
store :price_history, History[Money],
  backend:     :timeseries,          # physical engine
  partition:   :by_product,          # partitioning strategy
  consistency: :causal,              # consistency level
  replicas:    3,                    # cluster replication
  seal_after:  { size: 10_000, time: 1.hour }  # head-segment sealing

store :revenue_cube, OLAPPoint[Money, { product: String, region: String, month: Date }],
  backend:            :columnar,
  partition:          :by_month,
  source:             :orders,       # operational → analytical bridge
  materialization:    :incremental,  # strategy (see §5)
  lag:                30.seconds

store :workflow_log, ExecutionState,
  backend:     :log,
  retention:   90.days,
  idempotency: :content_addressed    # dedup by input hash
```

**Backend options** (open set, pluggable):

| Backend | Suitable for | Examples |
|---------|-------------|----------|
| `:memory` | Development, tests | Igniter built-in |
| `:timeseries` | `History[T]`, `BiHistory[T]` | TimescaleDB, InfluxDB, native |
| `:columnar` | `OLAPPoint` | DuckDB, ClickHouse, Parquet |
| `:relational` | `entity` | PostgreSQL, SQLite |
| `:log` | `await`, saga state | NATS JetStream, Kafka, native |
| `:kv` | `cache_ttl` | Redis, Memcached, native |

The compiler's default mapping (used when `store` is implicit):

```
History[T]         → :timeseries  (or :log if cluster not present)
BiHistory[T]       → :timeseries  with bitemporal support
OLAPPoint[T, dims] → :columnar
entity             → :relational
await / saga       → :log
cache_ttl          → :kv
```

Explicit `store` declarations override the default. When no `store` declaration
exists and no default backend is configured, the compiler emits a warning and falls
back to `:memory` (safe for development, not for production).

---

## §3 Cluster Parallelism Model

The contract graph encodes the parallelism structure statically. Three levels:

### Level 1 — Node-level parallelism (within a contract)

Already implemented via `thread_pool` runner. The compiler computes topological
layers; all nodes in the same layer are independent and run concurrently. No new
work needed here — this is the baseline.

### Level 2 — Contract-level parallelism (across contracts)

Whole contracts are routed to cluster nodes. Two sub-modes:

**Stateless routing**: contracts with no `await` or persistent state can execute
on any node. A consistent-hash router assigns contracts to nodes based on input
hash, achieving data locality without coordination.

**Stateful routing**: contracts with `await` nodes or `store` access must be routed
to the node that owns the relevant partition. The partition map (gossip-propagated)
maps `(store_name, partition_key)` → `(node_address, replica_addresses)`.

### Level 3 — Data-level parallelism (contract fanout)

The most powerful form. When a contract reads from a partitioned `store`, the
compiler generates a *fanout plan*:

```
# User writes:
contract :monthly_revenue do
  input :year
  olap :revenue, Revenue, rollup: :month, partition: :by_region
  output :by_region_month, from: :revenue
end

# Compiler generates (conceptually):
FanoutPlan {
  scatter: query partition map → N regions
  per_shard: execute :monthly_revenue on each region's owner node
  gather:    collect OLAPSlice[N] → merge with rollup function
}
```

The user writes one contract. The compiler produces a scatter-gather MapReduce
plan. No `parallel do`, no explicit coordination, no `async/await`. The topology
declares the parallelism.

### Topology-Aware Placement

The compiler computes a *communication cost graph*: for each pair of dependent
nodes `(A → B)`, what is the expected data transfer volume? Nodes with high
communication cost should be co-located.

Placement objective: minimise total network I/O subject to load-balance constraints.

```
PlacementPlan {
  :price_lookup   → node_1  (owns price_history partition P1)
  :tax_compute    → node_1  (depends on :price_lookup, same node = 0 network hops)
  :revenue_olap   → node_2  (owns revenue_cube partition R1)
  :final_total    → gateway (aggregates from node_1 + node_2)
}
```

This placement is a compile-time hint, not a hard constraint. The scheduler may
override it for load-balancing, but the hint drives the default.

---

## §4 Write Path for `History[T]`

Reading `History[T]` is solved: content-addressed sealed segments, freely
distributable, O(log n) access, no cache invalidation needed. Writing is harder.

### The Head Segment Problem

Each `History[T]` has:
- **N sealed segments**: immutable, content-addressed, replicated freely
- **1 mutable head**: the open segment currently being written to

The head is the concurrency boundary. Two concurrent writers cannot both update
the head without coordination.

### Four Write Strategies

**Strategy A — Single writer**

Each `History[T]` partition has a designated writer node. All writes to that
partition are routed to it. Other nodes route writes via the partition map.

- Consistency: strong (no conflict possible)
- Throughput: limited by single writer
- Failure: writer crash → writes queue until new writer elected
- Sealing: writer decides when to seal (size or time threshold reached)

**Strategy B — Log-structured merge (LSM)**

Multiple writers append to their own local micro-segments. A background merge
process consolidates micro-segments into sealed segments (like LevelDB compaction).

- Consistency: eventual for reads during merge window
- Throughput: high (no coordination on write path)
- Complexity: merge process must handle overlapping time intervals

**Strategy C — CRDT segments**

Each write immediately creates a new sealed micro-segment. Merge is lazy, at read
time. Works because segments are intervals — merge is a well-defined set operation.

```
Writer A: segment { [t=10, t=10]: price=100, recorded: now }
Writer B: segment { [t=10, t=10]: price=110, recorded: now+1ms }
Read at t=10: both segments exist → apply conflict resolution
```

- Consistency: eventual, but causally ordered (transaction_time is the tiebreaker)
- Coordination: none on write path
- Read overhead: merge on read (amortised by segment cache)

**Strategy D — Coordinator sealing**

Writers append to a Raft-replicated log. A coordinator reads the log and produces
sealed segments. Strong consistency, coordinator is the bottleneck.

The language expresses the choice as a `store` parameter:

```
store :prices, History[Money],
  write: :single_writer   # Strategy A — strong consistency, simplest
  # write: :crdt          # Strategy C — no coordination, eventual
  # write: :lsm           # Strategy B — high throughput
```

Default: `:single_writer` (simplest, matches most use cases). `:crdt` for
high-write-volume, partition-tolerant scenarios.

### Write Conflict Resolution

When two writers produce values for the same `valid_time`:

```
Writer A: price[valid_time=T] = 100
Writer B: price[valid_time=T] = 110   (concurrent)
```

Resolution uses the `combines:` vocabulary from rule declarations — the same
clause applies here. This is not coincidence: a concurrent write conflict is
structurally identical to a rule conflict.

```
store :prices, History[Money],
  write_conflict: :last_wins      # BiHistory natural model (by transaction_time)
  # write_conflict: :error        # strict mode — conflict is a runtime error
  # write_conflict: combines: :max  # user-defined: max(100, 110) = 110
  # write_conflict: combines: :min
```

The unification of rule conflict and write conflict into one vocabulary is a
design goal: the language has one concept for "what to do when two values compete
for the same slot", applied consistently.

---

## §5 Operational → Analytical Materialization

The `source:` clause on an `OLAPPoint` store declares a bridge from an operational
entity to an analytical store. Three materialization strategies:

### Strategy 1 — Synchronous (write-through)

```
OLTP write → atomically update OLAP store (same transaction)
```

Every `entity` write also writes to the `OLAPPoint` store in the same transaction.
- OLAP consistency: strong (zero lag)
- OLTP latency: increases by ~write-to-columnar overhead
- Best for: low-write-volume, read-heavy OLAP, small fact tables

### Strategy 2 — CDC (change data capture)

```
OLTP write → commit → CDC event → async OLAP write
```

An event stream carries deltas from the operational log to the OLAP store. Standard
approach (Debezium, etc.), but in Igniter-Lang it is declared, not configured:

```
store :revenue_cube, OLAPPoint[...],
  source:          :orders,
  materialization: :cdc,
  lag:             30.seconds   # acceptable staleness SLA
```

The compiler generates a `MaterializationContract` that subscribes to `orders`
events and applies projections to the OLAP store. The lag SLA becomes a temporal
invariant on the store's `recorded_time`.

### Strategy 3 — Incremental dataflow

```
OLTP write → delta → propagate through OLAP graph → minimal recomputation
```

Uses `igniter/extensions/dataflow` (already implemented). Only affected aggregation
cells are recomputed. Best for complex OLAP graphs with many derived dimensions.

```
store :revenue_cube, OLAPPoint[...],
  source:          :orders,
  materialization: :incremental,
  lag:             5.seconds
```

### Materialization as a Contract

Critically, the materialization pipeline is itself a first-class contract:

```
MaterializeRevenueCube: Contract({orders_stream: Stream[Order]}) → Void

  input  :orders_stream
  compute :completed, filter: orders_stream by status == :completed
  compute :revenue_records, map: completed → RevenueRecord
  effect  :write_olap, depends_on: :revenue_records,
            call: OLAPStore::Writer,
            idempotent: true,
            store: :revenue_cube
```

This means the materialization strategy is:
- Declared in the language, not in infrastructure scripts
- Verified by the compiler (input/output types checked)
- Observable via the same introspection tools as any contract
- Testable with the same test infrastructure
- Auditable via the same provenance extension

---

## §6 Consistency Model

### CAP in Contract Terms

| Contract construct | P-tolerance | Consistency requirement | CAP choice |
|-------------------|-------------|------------------------|------------|
| `entity` write | Optional | Strong (ACID) | CA (single node) or CP (Raft) |
| `History[T]` append | Required | Causal | CP or AP+causal |
| `OLAPPoint` read | Required | Eventual (lag SLA) | AP |
| `await` event delivery | Required | At-least-once + dedup | AP |
| Rule application | Required | Causal (rule version) | CP |

The `consistency:` parameter on `store` maps to these choices:

| Value | Semantics | Network requirement |
|-------|-----------|-------------------|
| `:strong` | Linearisable reads/writes | Raft consensus on write |
| `:causal` | Causal order preserved | Vector clocks on all ops |
| `:monotonic_reads` | Reads never go backward | Sticky session per reader |
| `:eventual` | Last-write-wins by transaction_time | No coordination |

### Consistency Connects to Temporal `as_of`

The consistency level of a store determines the semantics of `as_of` queries on
that store. This connects directly to the distributed time model:

```
# Store with :causal consistency
store :prices, History[Money], consistency: :causal

# Query: as_of uses the causal clock inherited from the contract execution context
# If this contract was triggered by an event from :order_service,
# then as_of is causally after all writes from that event's causal past.
price[:as_of last_event_from: :order_service]
```

For `:eventual` stores, `as_of` queries may return stale data within the lag SLA.
The `lag:` parameter becomes a temporal invariant:

```
# Compiler-enforced invariant:
# revenue_cube.recorded_time >= now - lag
# If violated, the query raises TemporalConsistencyError
```

---

## §7 Execution State Durability

### The Problem

Between `await` nodes, contract execution is suspended. If the node crashes,
the execution must recover to the correct position without re-executing completed nodes.

```
class OrderWorkflow < Igniter::Contract
  correlate_by :order_id
  define do
    input   :order_id
    await   :payment,  event: :payment_confirmed   # ← suspend point 1
    await   :shipping, event: :shipped              # ← suspend point 2
    effect  :notify_customer, depends_on: :shipping, idempotent: true
    output  :complete, from: :shipping
  end
end
```

### Execution State as Event Log

The execution state is persisted as an ordered event log:

```
[start,           { order_id: "o1", inputs: { order_id: "o1" } }]
[node_resolved,   { node: :order_id, value: "o1" }]
[node_suspended,  { node: :payment, awaiting: :payment_confirmed,
                    correlation: { order_id: "o1" } }]
[event_received,  { node: :payment, payload: { amount: 99.99 } }]
[node_resolved,   { node: :payment, value: { amount: 99.99 } }]
[node_suspended,  { node: :shipping, awaiting: :shipped, ... }]
...
```

On recovery:
1. Read log for correlation key `{ order_id: "o1" }`
2. Replay to reconstruct in-memory execution state
3. Resume from last suspended node — no re-execution of completed nodes

### Idempotency Requirement

Replay must be safe. Pure compute nodes are trivially idempotent (same inputs
→ same output, no side effects). Effects require explicit idempotency:

```ruby
class SendConfirmationEmail < Igniter::Effect
  idempotent true    # existing DSL — already implemented
  effect_type :notification
  def call(order_id:)
    EmailService.send_confirmation(order_id)
  end
end
```

The `idempotent: true` flag already exists in the Effect system. The compiler
enforces that all `effect` nodes in a durable workflow declare idempotency.

### Checkpoint Protocol

For long-running workflows (days, weeks), replaying from the beginning is
expensive. The checkpoint protocol seals execution state snapshots:

```
Checkpoint = {
  id:              content_hash(execution_state),   # content-addressed
  at_node:         :shipping,                       # after this node resolved
  state_snapshot:  serialized_execution_state,
  log_offset:      1247,                            # resume replay from here
  recorded_at:     Time.now
}
```

Checkpoints are sealed, immutable, and content-addressed — exactly like
`HistorySegment`. This is not an analogy; it is the same construct:

```
ExecutionCheckpoints ≡ History[ExecutionState]
```

The same `HistorySegment` infrastructure stores execution checkpoints. Recovery
loads the latest checkpoint and replays only subsequent log entries.

### Durability Store

```
store :order_workflow_state, ExecutionState,
  backend:     :log,
  checkpoint:  { after: :every_await, max_replay: 1000 },
  retention:   90.days,
  idempotency: :content_addressed
```

---

## §8 Unified Architecture

The full stack from type declaration to physical execution:

```
Language Layer
  contract / entity / store / await
         ↓  (compile-time)
Compiler Layer
  - Storage requirements manifest (shape → backend)
  - Fanout plan (partition map → scatter-gather)
  - Placement hints (communication cost graph)
  - Materialization contracts (source: → pipeline)
  - Consistency invariants (lag SLA → temporal invariant)
         ↓  (runtime init)
Storage Adapter Layer
  Backend registry: { :timeseries → TimescaleAdapter,
                      :columnar   → DuckDBAdapter,
                      :log        → NATSAdapter,
                      :relational → PostgreSQLAdapter,
                      :kv         → RedisAdapter,
                      :memory     → BuiltinAdapter }
         ↓  (execution)
Cluster Execution Layer
  Partition map  →  scatter-gather runner
  Placement map  →  node routing
  Vector clocks  →  causal consistency
  Raft log       →  strong consistency (opt-in)
```

At every layer, the contract graph is the unit of work. A contract is not
"a thing that runs and uses a database" — it is a typed dataflow graph whose
compilation artifact includes a complete description of its storage, placement,
and consistency requirements.

---

## §9 Open Questions

**Q1: Store versioning.** When the type of a `store` changes (schema migration),
what is the update model? `History[T]` is append-only — old segments have the old
type. Possible answer: sealed segments are immutable, migration creates a new store
with a versioned name, a migration contract transforms old segments to new format.

**Q2: Cross-store transactions.** Can a single contract atomically write to an
`entity` store and append to a `History[T]`? This requires distributed transactions
(2PC or saga). The saga extension already exists — the natural answer is: use a
saga contract for cross-store writes, not atomic transactions.

**Q3: Store discovery in a dynamic cluster.** The partition map is gossip-propagated.
What is the convergence time? What happens during a partition when the map is stale?
The consistency level should govern the answer: `:strong` stores reject writes during
partition; `:eventual` stores accept writes and reconcile.

**Q4: Columnar backend portability.** DuckDB is an excellent embedded columnar engine
but is not cluster-native. The `:columnar` backend may need a two-tier model:
in-process DuckDB for single-node + scatter-gather protocol for cluster. Parquet
files on shared object storage (S3) may be the simplest cluster-portable option.

**Q5: Rule store and temporal consistency.** When a new `rule` version is deployed,
in-flight contract executions may be mid-computation using the old rule set. The
compiler should emit a rule version pin at contract-start time, ensuring a single
execution always uses one consistent rule snapshot.

---

## §10 POC Roadmap

### Iteration 1 — Persistence Interface (~500 LOC)

- `Igniter::Storage::Backend` abstract interface: `read`, `append`, `scan`, `checkpoint`
- `Igniter::Storage::Memory` — in-process backend (already partial via `NodeCache::Memory`)
- `Igniter::Storage::Log` — append-only log for `await`/saga durability
- `store` DSL keyword in `ContractBuilder`
- Compiler emits storage requirements manifest
- Compiler validates: all `await` nodes in a contract have a durable log store

Deliverable: distributed contracts survive node restart; execution replays from log.

### Iteration 2 — History Store + Materialization (~700 LOC)

- `Igniter::Storage::TimeSeries` backend (SQLite-based for dev, TimescaleDB for prod)
- `HistorySegment` sealing protocol (single-writer strategy)
- Write conflict detection via `combines:` clause
- Synchronous materialization for `OLAPPoint source:`
- Lag SLA enforcement as temporal invariant

Deliverable: `History[T]` stores survive restart; `OLAPPoint` reads from materialised store.

### Iteration 3 — Cluster Distribution (~800 LOC)

- Partition map protocol (extends existing gossip mesh)
- Contract fanout compiler transformation for partitioned `store` reads
- Scatter-gather execution runner
- Causal consistency via vector clocks on `History[T]` appends
- Placement hint propagation to scheduler

Deliverable: OLAP queries scatter across cluster; History appends causally ordered.

**Total estimate: ~2000 LOC** (not counting existing mesh/actor infrastructure).

---

## §11 Key Formal Identities

The persistence model introduces no new primitives — it unifies existing concepts:

```
ExecutionCheckpoint  ≡  HistorySegment[ExecutionState]
Write conflict       ≡  Rule conflict  →  resolved by combines:
Lag SLA              ≡  Temporal invariant on recorded_time
Materialization      ≡  Contract (source → OLAP store)
Partition map        ≡  Distributed lookup table  →  same as entity
Backend selection    ≡  Compile-time inference from type
```

The language grows by unification, not by addition. Each new concept resolves
into existing vocabulary. The contract model is the universal substrate.
