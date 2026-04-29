# Contract-Native Store: Research Iterations

Status date: 2026-04-29.
Format: living research document — each iteration appended below.
Scope: distributed proactive agent clusters; optional separate package.
Canonical: this file. Russian companion: `contract-native-store-research.ru.md`.

---

## Iteration 0 — Constraints and Decisions

*Recorded from design session, 2026-04-29.*

These constraints bound the research and are not re-opened without cause.

### Target context

Igniter Application / Cluster layer. The primary consumer is an application
running decentralized, distributed, proactive agents. The store must serve
agents that:

- react to data changes proactively (not polled from outside)
- are distributed across a cluster
- need consistent shared state without coordination overhead
- need to reason about historical state (what happened before event Y?)

### Boundary with external databases

We do not forbid developers from using their preferred database. We provide a
minimal coupling API; everything beyond that is the developer's responsibility
to implement in their own intermediate layer. If the native store proves better
in practice, it sells itself. No forcing.

### Priority features

From all possible directions, two are prioritized:

1. **Compile-time query optimization** — access paths derived from the contract
   graph before any data exists, not at runtime.
2. **Time-travel** — every state queryable at any past point, as a structural
   consequence of immutability, not a bolted-on feature.

### Package scope

Optional, separate package (candidate name: `igniter-store`). Recommended but
not imposed. The product must justify itself on merit.

---

## Iteration 1 — Where Existing Systems Fall Short

*Recorded from design session, 2026-04-29.*

All existing storage systems are storage-first. Business logic lives outside:

```
Relational (PG, SQLite)  → tables   → ORM       → business logic (outside)
Document (Mongo)         → docs     → ODM       → business logic (outside)
Event stores (Kafka, ES) → events   → manual    → business logic (outside)
Datomic                  → facts    → Datalog   → business logic (outside)
Graph DB (Neo4j)         → nodes    → Cypher    → business logic (outside)
```

In every case the storage engine is blind to intent. It does not know why data
is read or what the data means in the domain.

Igniter is the first system where the **full dependency graph of business logic
is known at compile time**. This opens doors that are structurally closed to
every system above.

### The three gaps that matter most for distributed agents

**Gap 1 — Runtime query planning.**
SQL and every ORM derive the query plan at runtime. The engine sees the query
for the first time when it executes. In a contract, every `store_read` is a
typed compile-time dependency. The store can know the complete access pattern
before any data or query exists.

**Gap 2 — Projection maintenance is manual.**
In CQRS/ES, projections are hand-written consumers that rebuild read models
from events. In Igniter, projections are contracts. If the store understands
contracts, it can maintain projections automatically — incrementally, with
cache invalidation derived from the graph.

**Gap 3 — History is an afterthought.**
Datomic has time-travel, but it is a separate query mode (`as-of`, `history`).
In Igniter, `History[T]` is a first-class storage shape. An append-only fact
log is not an audit add-on; it is the write model. Current state is always a
projection of the history.

---

## Iteration 2 — Core Architecture Sketch

*Recorded from design session, 2026-04-29.*

### The synthesis: contracts + time-travel + distributed agents

The three priorities reinforce each other:

```
Compile-time graph  →  access paths known at deploy
                    →  store pre-indexes by contract, not by query
                    →  agents declare reads; store routes writes to relevant nodes

Append-only facts   →  every write is a new fact, nothing is mutated
                    →  time-travel is structural (scan facts where t <= T)
                    →  Raft consensus log IS the time axis

Content addressing  →  facts stored by hash of content (like Git objects)
                    →  structural sharing between versions is free
                    →  deduplication is automatic
                    →  causation chain links facts (previous_hash field)
```

### Fact model

Every `store_write` produces an immutable fact:

```
Fact {
  contract:      ReminderContract,        # which contract produced this
  store:         :reminders,              # which Store[T]
  key:           "uuid-123",              # identity within the store
  value_hash:    "sha256:abc...",         # content address of the value
  value:         { id: "...", ... },      # the actual payload
  causation:     "sha256:prev...",        # links to the previous fact for this key
  timestamp:     1714000000,              # wall-clock (for time-travel queries)
  term:          42,                      # Raft term (for distributed ordering)
  schema_hash:   "sha256:schema...",      # content address of the schema version
}
```

This one structure gives:

- **Time-travel**: `facts.select { |f| f.timestamp <= t && f.store == :reminders }`
- **Audit trail**: follow `causation` chain backward
- **Schema versioning**: `schema_hash` links each fact to the exact schema version that produced it
- **Distributed ordering**: `term` from Raft consensus resolves conflicts
- **Deduplication**: same content ⟹ same `value_hash`

### Compile-time access path generation

When a contract declares:

```ruby
store_read :reminder, from: :reminders, by: :id, using: :reminder_id,
           cache_ttl: 60, coalesce: true
```

The compiler emits:

```
AccessPath {
  store:          :reminders,
  lookup:         :primary_key,
  key_binding:    :reminder_id,
  cache_strategy: :ttl,
  cache_ttl:      60,
  coalesce:       true,
  consumers:      [ReminderContract, ReminderDetailProjection, ...]
}
```

The store reads this at deploy time and pre-builds the index. At runtime there
is no "plan this query" step — the path was materialized when the contract was
compiled.

### Data-locality for distributed agents

When `ProactiveAgent` declares:

```ruby
store_read :pending_tasks, from: :tasks, scope: :pending, cache_ttl: 30
```

The store knows at deploy time:

- `ProactiveAgent` reads `:tasks` with `:pending` scope
- cache is 30 s
- when `:tasks` changes, `ProactiveAgent`'s cache is the invalidation target
- if `ProactiveAgent` runs on Node A, replicate relevant `:tasks` changes to
  Node A with priority

This is **data-locality optimization derived from the contract graph** — not
possible with any ORM or query planner today.

### Internal store structure (candidate)

```
igniter-store/
  WriteStore     ← append-only fact log; WAL-backed; content-addressed values
  ReadStore      ← projections maintained by contract graph; live materialized views
  TimeIndex      ← timestamp + term index over the fact log (O(log n) time-travel)
  SchemaGraph    ← compile-time generated access paths from contracts
  ClusterSync    ← consensus replication using existing Igniter::Consensus (Raft)
  Adapter API    ← minimal coupling surface for external DBs (escape hatch)
```

### Relation to existing Igniter components

```
Igniter::Consensus  →  ClusterSync uses Raft log; log entries = facts
Igniter::NodeCache  →  ReadStore respects existing TTL + coalescing semantics
Igniter::AI::Agent  →  ProactiveAgent can subscribe to ReadStore projections
incremental dataflow →  projection maintenance is the incremental computation model
Saga / Effect       →  store_write failure triggers Saga compensation; fact is not committed
```

---

## Iteration 3 — Open Threads

*Recorded from design session, 2026-04-29. To be expanded in future iterations.*

### Thread A — Minimal Adapter API surface

What is the minimum interface a developer needs to wire an external DB?

Candidate shape:

```ruby
module Igniter::Store::Adapter
  # Called by store_read nodes at runtime (after compile-time path resolves)
  def read(store_key, lookup)     # → Fact or nil

  # Called by store_write nodes at app boundary
  def write(store_key, fact)      # → committed Fact

  # Called by store_append nodes (History[T])
  def append(history_key, fact)   # → appended Fact

  # Called by compile-time path builder at deploy time
  def build_access_path(path_descriptor)  # → void; implementation stores the index
end
```

Open: should `build_access_path` be optional (skip for simple adapters)?

### Thread B — Time-travel query API

What does a time-travel query look like from a contract?

Candidate DSL:

```ruby
store_read :reminder_at_t, from: :reminders, by: :id, using: :reminder_id,
           as_of: :query_time   # :query_time is an input node

# Or as a projection:
project :reminder_history, from: :reminders, key: :reminder_id,
        over: :all_time         # returns Array<Fact> ordered by timestamp
```

Open: should time-travel be a first-class DSL keyword or an option on
`store_read`? Should `as_of` accept a Raft term (for distributed consistency)
in addition to a wall-clock timestamp?

### Thread C — Contract as Query Language

Radical direction: the contract language IS the query language. No SQL, no
GraphQL. A read-only query contract declares its `store_read` dependencies; the
store executes them as a compiled query plan.

```ruby
class FindPendingTasksQuery < Igniter::Contract
  define do
    input  :agent_id
    store_read :tasks, from: :tasks, scope: :pending,
               filter: { assigned_to: :agent_id }
    compute :prioritized, depends_on: [:tasks], call: PrioritySort
    output :prioritized
  end
end
```

Open: is this worth pursuing in the native store, or is it a layer above the
store API?

### Thread D — Schema evolution without migration

When a contract field type changes from `:string` to `:integer`, the store
holds facts produced under both schema versions (tracked via `schema_hash`). A
coercion contract can bridge them:

```ruby
class ReminderContract::Coercion::V1toV2 < Igniter::Contract
  define do
    input  :fact_v1
    compute :coerced, depends_on: [:fact_v1], call: CoerceStatusField
    output :fact_v2
  end
end
```

Old facts are never rewritten. The read path runs the coercion contract
transparently when `schema_hash` does not match the current version.

Open: should coercion contracts be auto-generated from the field diff (migration
plan), or always hand-authored?

### Thread E — Reactive store for proactive agents

When an agent is proactive, it should not poll the store. The store should push
invalidation signals to agents whose `store_read` access paths cover changed
facts.

```
Fact written to :tasks (scope: :pending touched)
→ store inspects SchemaGraph: who has AccessPath on :tasks/:pending?
→ ProactiveAgent on Node A and Node B are subscribed
→ store pushes invalidation to both agents' mailboxes
→ agents re-resolve their :tasks dependency without polling
```

This fuses the existing `Igniter::AI::Agent` mailbox model with the store's
access path registry.

Open: push invalidation or push the new fact? Push to local node cache first,
then to remote agents?

---

## Next Iteration Candidates

Priority order (open to revision):

1. **Thread A** — nail down the minimal adapter API; this defines the escape
   hatch and bounds the native store scope
2. **Thread B** — define the time-travel query API; this is the highest-value
   differentiator
3. **Thread E** — reactive store + proactive agents; this is the primary use
   case and should shape the write path design
4. **Thread D** — coercion contracts / zero-migration evolution; builds on B
5. **Thread C** — contract-as-query-language; most radical, lowest urgency

---

## Reference

- [Contract Persistence Organic Model](./contract-persistence-organic-model.md)
- [Contract Persistence Roadmap](./contract-persistence-roadmap.md)
- [Companion Current Status Summary](./companion-current-status-summary.md)
