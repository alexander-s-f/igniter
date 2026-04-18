# MeshQL — v1

MeshQL is a declarative string query language for the cluster's OLAP Point field. It lets you express multi-dimensional peer selection queries as readable strings that can be stored, logged, transmitted, and round-tripped.

## Relationship to ObservationQuery

MeshQL is a **grammar over** `ObservationQuery`. Parsing a MeshQL string produces a `ParsedQuery` that applies the equivalent filter/order/limit chain to an `ObservationQuery`. There is no separate execution engine — MeshQL compiles down to Ruby method calls on `NodeObservation`.

```
MeshQL string  →  ParsedQuery  →  ObservationQuery chain  →  Array<NodeObservation>
```

## Syntax

```
SELECT capability-list
[WHERE condition [AND condition ...]]
[ORDER BY metric [ASC|DESC] [, metric [ASC|DESC] ...]]
[LIMIT n]
```

### Capability list

```
SELECT :database, :orders    -- require all listed capabilities
SELECT *                     -- any capability (no filter)
```

### Conditions (WHERE clause)

All keywords are **case-insensitive**.

| Condition | OLAP Dimension | ObservationQuery method |
|-----------|---------------|------------------------|
| `TRUSTED` | trust | `.trusted` |
| `HEALTHY` | state | `.healthy` |
| `AUTHORITATIVE` | provenance | `.authoritative` |
| `TAGGED :tag` | capabilities | `.tagged(:tag)` |
| `NOT :capability` | capabilities | `.without(:capability)` |
| `IN ZONE value` | locality | `.in_zone(value)` |
| `IN REGION value` | locality | `.in_region(value)` |
| `metric op value` | state / provenance | `.where { ... }` |

Metric conditions:

| Metric | Maps to |
|--------|---------|
| `load_cpu` | `obs.load_cpu` |
| `load_memory` | `obs.load_memory` |
| `concurrency` | `obs.concurrency` |
| `queue_depth` | `obs.queue_depth` |
| `confidence` | `obs.confidence` |
| `hops` | `obs.hops` |

Operators: `<` `<=` `>` `>=` `=` `!=`

### ORDER BY

```
ORDER BY load_cpu ASC
ORDER BY load_cpu ASC, concurrency DESC
```

Orderable metrics: `load_cpu`, `load_memory`, `concurrency`, `queue_depth`, `confidence`, `hops`.

Default direction: `ASC`.

### LIMIT

```
LIMIT 3
```

## Entry Points

```ruby
require "igniter/cluster"

# Parse → run against an observation array
results = Igniter::Cluster::Mesh::MeshQL.run(
  "SELECT :database WHERE trusted AND load_cpu < 0.5 LIMIT 3",
  observations
)

# Parse → ObservationQuery (lazy, chainable)
query = Igniter::Cluster::Mesh::MeshQL.parse(source).to_query(observations)
query.each { |obs| puts obs.name }

# Top-level Mesh entry point (uses live PeerRegistry)
obs_query = Igniter::Cluster::Mesh.meshql("SELECT :database WHERE healthy ORDER BY load_cpu")
obs_query.limit(5).to_a

# Round-trip
pq = Igniter::Cluster::Mesh::MeshQL.parse("SELECT :database WHERE trusted ORDER BY load_cpu ASC LIMIT 3")
pq.to_meshql  # => "SELECT :database WHERE TRUSTED ORDER BY load_cpu ASC LIMIT 3"
```

## Examples

```
-- Find the lowest-load trusted database node in us-east-1a
SELECT :database WHERE TRUSTED AND load_cpu < 0.7 AND IN ZONE us-east-1a ORDER BY load_cpu LIMIT 1

-- All healthy analytics nodes, best confidence first
SELECT :analytics WHERE HEALTHY ORDER BY confidence DESC

-- Any peer that is not overloaded and is authoritative
SELECT * WHERE load_cpu < 0.9 AND concurrency <= 8 AND AUTHORITATIVE

-- Linux nodes with orders capability in us-east region
SELECT :orders WHERE TAGGED :linux AND IN REGION us-east-1 ORDER BY load_cpu ASC LIMIT 3
```

## ParsedQuery

`MeshQL.parse(source)` returns a `ParsedQuery` — a frozen typed value object:

```ruby
pq = MeshQL.parse("SELECT :database WHERE trusted LIMIT 5")
pq.capabilities  # => [:database]
pq.conditions    # => [{ type: :trusted }]
pq.orderings     # => []
pq.limit         # => 5
pq.to_meshql     # => "SELECT :database WHERE TRUSTED LIMIT 5"
pq.to_query(observations)  # => ObservationQuery
```

`ParsedQuery` is safe to store, cache, and serialize as a string via `to_meshql`.

## Architecture

MeshQL lives entirely in the cluster layer:

```
lib/igniter/cluster/mesh/mesh_ql.rb
  MeshQL (module)
    .parse(source)   → ParsedQuery
    .run(source, observations) → Array<NodeObservation>
    Tokenizer (module)   — zero dependencies, hand-written
    Parser (class)       — recursive descent
    ParsedQuery (class)  — typed, frozen, round-trippable
```

No external parsing library. No change to `ObservationQuery`. No change to `CapabilityQuery`.

## What MeshQL v1 Does Not Support

- `OR` — conditions are AND-only in v1
- `NOT (compound condition)` — only `NOT :capability`
- Capability freshness / governance conditions — use `ObservationQuery` directly or `.matching(capability_query)`
- Named queries / variables
- Distributed fan-out execution — v1 evaluates locally against a snapshot

These are natural v2 extensions.

## Relationship to Future MeshQL

MeshQL v1 is intentionally minimal. The grammar is:

```
SELECT  →  ObservationQuery#with / #without
WHERE   →  ObservationQuery#trusted / #healthy / #in_zone / #max_load_cpu / etc.
ORDER BY → ObservationQuery#order_by
LIMIT   →  ObservationQuery#limit
```

A future MeshQL v2 could add:
- `OR` and parenthesized conditions
- Cross-node aggregation: `SELECT COUNT(:database) BY zone`
- Named query parameters: `SELECT :database WHERE load_cpu < $threshold`
- Distributed execution via mesh fan-out

For placement, see [Cluster Next Roadmap — Phase 3](./cluster/ROADMAP_NEXT.md).
For the OLAP Point concept, see [OLAP Point v1](./OLAP_POINT_V1.md).
