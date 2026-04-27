# Igniter Contract Language — OLAP Point, History Internals, and Time Travel

Date: 2026-04-27.
Status: ★ FRONTIER — current peak of the research track.
Priority: HIGH — OLAP Point is a candidate fundamental construct on par with
`contract`; History internals unlock native cluster parallelism.
Scope: OLAP Point as a language primitive, History internal structure for
cluster-native parallelism, time travel specification (backward and forward).

*Builds on: [igniter-lang-temporal-deep.md](igniter-lang-temporal-deep.md)*

---

## § 0. The Central Insight

`History[T]` is a 1D OLAP structure — a value parameterised by a single
dimension (time). But enterprise data is inherently **multi-dimensional**:

- Price = f(time, product, customer_tier, region)
- Revenue = f(time, product, channel, region)
- Inventory = f(time, warehouse, product, sku)

The natural generalisation: an **OLAP Point** is a value at a specific
point in a multi-dimensional space. `History[T]` becomes a special case:
`OLAPPoint[T, time: DateTime]`.

This is not an analytics bolt-on. It is a candidate **first-class language
construct** alongside `contract`, `rule`, `entity`, and `invariant`. The
reason: the same declarative, composable, verifiable model that makes
contracts powerful applies equally to multi-dimensional data — and most
enterprise systems spend the majority of their complexity budget on exactly
this problem.

---

## § 1. History Internal Structure

### § 1.1 Design Goals

The `History[T]` internal structure must support:
- **Immutable past**: recorded intervals never mutate
- **Append-only writes**: new intervals extend the head; old segments sealed
- **Content-addressed segments**: each segment hashed → deduplication and cache safety
- **O(log n) point access**: binary search on interval list
- **Parallel reads without coordination**: sealed segments are freely distributable
- **Time-range sharding**: cluster nodes own non-overlapping time windows

### § 1.2 Segment Structure

```
// One immutable chunk of history (sealed when full or on explicit snapshot)
type HistorySegment[T] = {
  id:           SegmentId          // globally unique (content hash)
  intervals:    Interval[T][]      // sorted, non-overlapping, contiguous
  valid_range:  DateRange          // the time range this segment covers
  sealed:       Bool               // true = immutable, may be cached/distributed
  checksum:     Bytes              // SHA-256 of sorted interval data
  node_id:      NodeId?            // cluster node that owns this segment (nil = replicated)
}

// The History is a pointer structure over segments
type History[T] = {
  type_tag:     TypeTag[T]
  segments:     SegmentId[]        // ordered chronologically (oldest first)
  head_id:      SegmentId          // the only mutable segment (append target)
  snapshots:    Map[DateTime, SegmentId]   // fast jump-to-time index
  segment_size: Int                // max intervals per segment (default: 1_000)
}
```

### § 1.3 Write Path — Append Only

```
append_interval(history, interval):
  head = load_segment(history.head_id)

  if head.sealed:
    error "cannot write to sealed segment"

  if head.intervals.count >= history.segment_size:
    seal(head)
    new_segment = create_segment(node_id: local_node)
    history.segments.append(new_segment.id)
    history.head_id = new_segment.id
    head = new_segment

  head.intervals.append(interval)
  -- no mutation of past segments, ever
```

A segment is **sealed** when:
- It reaches `segment_size` intervals
- An explicit `snapshot` call is made
- A cluster rebalance moves responsibility for this time range

Once sealed, a segment is:
- **Immutable** — content never changes
- **Content-addressed** — its `id` is the hash of its content
- **Freely distributable** — any node can cache it without coordination
- **Verified on read** — recompute hash, compare to `id`

### § 1.4 Read Path — Binary Search + Segment Index

```
read_at(history, t):
  -- Fast path: check snapshot index
  if snapshot_id = history.snapshots[t]:
    segment = load_segment(snapshot_id)
    return segment.intervals.find { |i| i.covers?(t) }

  -- Find the right segment by time range (binary search on segment list)
  segment = binary_search(history.segments) { |s| s.valid_range.covers?(t) }
  return segment.intervals.binary_search { |i| i.covers?(t) }

-- Total: O(log S + log N) where S = number of segments, N = intervals per segment
-- Amortised O(log n) for n total intervals
```

### § 1.5 Cluster Distribution

```
type HistoryPartition = {
  node_id:    NodeId
  time_range: DateRange            // this node owns intervals in this range
  segments:   SegmentId[]          // sealed segments in this range
}

type DistributedHistory[T] = {
  local:      History[T]           // this node's write-active partition
  partitions: HistoryPartition[]   // cluster map (read-only metadata)
  replication_factor: Int          // how many nodes hold each sealed segment
}
```

**Reading from a distributed history:**

```
read_distributed(dh, t):
  partition = dh.partitions.find { |p| p.time_range.covers?(t) }
  if partition.node_id == local_node:
    return read_at(dh.local, t)
  else:
    segment_id = partition.segments.find_for(t)
    segment = fetch_or_cache(segment_id, from: partition.node_id)
    -- segment is content-addressed: safe to cache anywhere
    return segment.intervals.binary_search { |i| i.covers?(t) }
```

Sealed segments are **gossip-distributed**: a node that reads a segment
caches it locally. Subsequent reads from any node find it in cache.
Content-addressing ensures cache correctness without coordination.

### § 1.6 Parallelism Properties

| Operation | Parallelism | Coordination |
|-----------|------------|--------------|
| Read point `h[t]` | Fully parallel across nodes | None (immutable segments) |
| Read range `h[t1..t2]` | Parallel segment reads | None |
| Append to head | Single writer per partition | Partition lock (local) |
| Seal segment | Single writer | Partition lock (local) |
| OLAP rollup | Parallel per segment | Reduce step at end |
| Snapshot | Single writer | Partition lock (local) |
| Rebalance partitions | Background, non-blocking | Gossip protocol |

---

## § 2. Time Travel Specification

### § 2.1 Backward Time Travel

Backward time travel is already fully specified: `value[t]` for any past `t`.

Additional introspection on the backward path:

```
-- Point in time
product.price[3.months.ago]

-- Nearest recorded value (if exact point has no interval)
product.price.nearest(3.months.ago)

-- Step back until a change is found
product.price.last_change_before(3.months.ago)

-- Entire history up to a point
product.price.history_until(3.months.ago)   -- History[T] sub-sequence

-- Replay: re-execute a contract as-of a past time
OrderTotal { order: order, as_of: 3.months.ago }
```

### § 2.2 Forward Time Travel

Forward time travel evaluates what values will be (or might be) in the future.
Three modes with increasing uncertainty:

**Mode 1 — Deterministic (known future rules)**

```
-- A rule is already declared with a future applies: spec
rule ChristmasSale : Product {
  applies: { from: :december_20, until: :january_2 }
  compute: fn(product) -> Float = 0.25
}

-- Forward evaluation uses scheduled rules
product.price[2.months.from_now]   -- deterministic if ChristmasSale covers that date
```

The runtime evaluates future `as_of` by applying all rules whose `applies:`
predicate is satisfied at that future point. Result type: `T` (exact).

**Mode 2 — Counterfactual (proposed rules)**

```
-- What would the price be if we activated this proposed rule?
product.price.with(ProposedRule)[2.months.from_now]

-- Equivalent to:
OrderTotal {
  order:       order,
  as_of:       2.months.from_now,
  extra_rules: [ProposedRule]
}
```

Result type: `T` (exact given the proposed rule set).

**Mode 3 — Approximate (trend projection)**

```
-- Statistical extrapolation of observed trend
~product.price[6.months.from_now]
  @approximate(method: :trend_extrapolation, window: 12.months, confidence: 0.70)

-- Seasonal model (repeating yearly pattern)
~product.price[next_december]
  @approximate(method: :seasonal, cycle: :yearly, confidence: 0.80)
```

Result type: `~T` (approximate) with declared confidence.

### § 2.3 The Time Machine Construct

For multi-scenario forward projection:

```
time_machine :price_forecast {
  subject:     product.price
  horizon:     6.months
  granularity: :weekly

  scenarios: [
    {
      name:  :baseline
      rules: system.current_rules
    }
    {
      name:  :holiday_promotion
      rules: system.current_rules + [ChristmasSale]
    }
    {
      name:  :competitor_response
      rules: system.current_rules + [PriceMatch]
      @approximate(confidence: 0.65)
    }
  ]
}
```

Returns a `Forecast` record:

```
type Forecast[T] = {
  subject:    String
  horizon:    DateRange
  scenarios:  Map[Symbol, ForecastScenario[T]]
}

type ForecastScenario[T] = {
  name:       Symbol
  values:     History[T] | History[~T]    -- exact or approximate
  confidence: Float?
}
```

Usage in a contract:

```
contract PricingStrategy {
  in product: Product
  in horizon: Duration = 6.months

  compute :forecast = time_machine :price_forecast {
    subject:     product.price
    horizon:     horizon
    scenarios:   [:baseline, :holiday_promotion]
  }

  compute :holiday_uplift =
    forecast.scenarios[:holiday_promotion].values.avg[next_quarter] -
    forecast.scenarios[:baseline].values.avg[next_quarter]

  out strategy: PricingDecision = {
    current_price:    product.price.current
    holiday_uplift:   holiday_uplift
    recommendation:   if holiday_uplift > 50 then :activate_sale else :hold
  }
}
```

### § 2.4 Time Travel Invariants

```
invariant TimeConsistency {
  -- Backward travel cannot exceed the earliest recorded interval
  as_of >= system.earliest_recorded_at
}

invariant ForwardDeterminism {
  -- Exact forward travel only valid for rules with declared future applies:
  -- Approximate forward travel always valid but returns ~T
  when as_of > DateTime.now() && result_type == :exact {
    applied_rules.all? { |r| r.applies_spec.covers_future? }
  }
}
```

---

## § 3. OLAP Point — Language Construct

### § 3.1 Motivation

`History[T]` = `OLAPPoint[T, time: DateTime]` — a value parameterised by time only.

Generalise: an OLAP Point is a **multi-dimensional function** mapping a
point in dimension space to a measure value. The dimensions can include time,
but also product, region, customer tier, channel — any categorical or ordinal axis.

This is not a database concept imported into the language. It is the **natural
generalisation of History** that emerges from the observation that most enterprise
values depend on more than one dimension.

### § 3.2 Declaration Syntax

```
olap_decl ::=
  'olap_point' IDENT '{'
    'dimensions' ':' '{' {dim_decl ','} '}'
    'measure'    ':' type_expr
    ['granularity' ':' '{' {grain_decl} '}']
    ['source'    ':' expr]
    ['indexed'   ':' '[' {SYMBOL ','} ']']
  '}'

dim_decl  ::= IDENT ':' type_expr
grain_decl ::= IDENT ':' SYMBOL    -- e.g. time: :daily
```

**Examples:**

```
olap_point Revenue {
  dimensions: {
    time:          DateTime
    product:       Product
    region:        Region
    channel:       Enum[:online, :retail, :wholesale]
  }
  measure:   Money

  granularity: {
    time:    :daily      -- default aggregation unit
    region:  :country    -- default roll-up level
  }

  source: fn(t, product, region, channel) -> Money =
    FulfilledOrders {
      period:  t.day
      product: product
      region:  region
      channel: channel
    }.total

  indexed: [:time, :product]   -- cluster shard keys
}

olap_point Inventory {
  dimensions: {
    time:      DateTime
    warehouse: Warehouse
    product:   Product
  }
  measure: Int    -- units on hand

  source: fn(t, warehouse, product) -> Int =
    warehouse.stock_at(product, t)
}

olap_point Price {
  dimensions: {
    time:          DateTime
    product:       Product
    customer_tier: Enum[:standard, :vip, :wholesale]
  }
  measure:   Money

  source: fn(t, product, tier) -> Money =
    product.base_price[t]
    |> apply(TierRules[t], for: tier)
    |> apply(SeasonalRules[t], for: product)
}
```

`History[T]` is a special case:
```
-- History[Money] is exactly:
olap_point PriceHistory {
  dimensions: { time: DateTime }
  measure:    Money
  source:     product.price_history
}
```

### § 3.3 OLAP Operations

OLAP operations on an `OLAPPoint` return new `OLAPPoint` values — they are
composable and lazy (evaluated on demand).

**Slice** — fix one dimension, reduce dimensionality by one:

```
Revenue[time: :q4_2026]                 -- OLAPPoint[product, region, channel]
Revenue[product: laptop]                -- OLAPPoint[time, region, channel]
Revenue[channel: :online]               -- OLAPPoint[time, product, region]

-- Chain slices (dice):
Revenue[time: :q4_2026][region: :west]  -- OLAPPoint[product, channel]
```

**Rollup** — aggregate over a dimension:

```
Revenue.rollup(:region)                         -- sum across all regions → OLAPPoint[time, product, channel]
Revenue.rollup(:region, fn: :avg)               -- average instead of sum
Revenue.rollup(:time, grain: :monthly)          -- monthly totals
Revenue.rollup(:time, grain: :quarterly)        -- quarterly totals
```

**Drill-down** — increase granularity of a dimension:

```
Revenue.drill(:time, :hourly)                   -- from daily to hourly
Revenue.drill(:region, :city)                   -- from country to city
```

**Pivot** — reshape into a 2D matrix:

```
Revenue[time: :q4_2026].pivot(:product, :region)
-- Returns: Map[Product, Map[Region, Money]]
-- A table: rows = products, columns = regions, cells = revenue
```

**Transform** — apply a function to each cell:

```
Revenue.transform { |v| v * 1.15 }             -- 15% uplift scenario
Revenue.transform { |v| ~v }                   -- lift to approximate
```

**Compare** — compare two OLAP Points (same dimensions):

```
Revenue[time: :q4_2026].compare(Revenue[time: :q3_2026])
-- Returns: OLAPPoint of deltas: same dimensions, measure = Money (signed)
```

**Type rules:**

```
-- Slice reduces dimensionality
op: OLAPPoint[T, {d₁: D₁, d₂: D₂, d₃: D₃}] [ d₁: v ] →
    OLAPPoint[T, {d₂: D₂, d₃: D₃}]

-- Rollup eliminates a dimension
op: OLAPPoint[T, {d₁: D₁, d₂: D₂}].rollup(d₁) →
    OLAPPoint[T, {d₂: D₂}]

-- Fully rolled up: becomes a scalar
op: OLAPPoint[T, {}] → T

-- History is 1D OLAP:
History[T]  ≡  OLAPPoint[T, {time: DateTime}]
```

### § 3.4 OLAP Point in Contracts

An `OLAPPoint` is a first-class value in the contract language:

```
contract RegionalReport {
  in period:  DateRange
  in region:  Region

  compute :revenue =
    Revenue[time: period, region: region]
    .rollup(:time, grain: :monthly)      -- monthly totals for this region

  compute :top_products =
    Revenue[time: period, region: region]
    .rollup(:time)                       -- total for period
    .pivot_to_list(:product)             -- list of (product, revenue)
    |> sort_by { .measure }
    |> take(10)

  compute :vs_last_year =
    revenue.compare(
      Revenue[time: period.shift(-1.year), region: region]
      .rollup(:time, grain: :monthly)
    )

  out report: RegionalReport = {
    monthly_revenue:  revenue
    top_10_products:  top_products
    yoy_comparison:   vs_last_year
  }
}
```

**No SQL. No joins. No ETL pipeline.** The OLAP Point is the contract's
native analytical primitive.

### § 3.5 OLAP Point and the Contract Graph

An OLAP Point declared in a `system` is a **global analytical node** in the
contract graph. Any contract in the system can access it by name.

```
system OrderManagement {
  entities:    [Order, Product, Customer]
  olap_points: [Revenue, Inventory, Price]   -- global analytical nodes
  contracts:   [FulfillOrder, ProcessOrder, ...]
  rules:       [SeasonalDiscount, WeekendPrice, ...]
}
```

When a contract resolves an OLAP Point access (e.g., `Revenue[time: t]`),
the runtime:

1. Checks the cluster partition map for the relevant time range
2. Fetches sealed segments from owning node (cached after first fetch)
3. Applies any registered rules that transform the measure
4. Returns the result (exact or `~T` for projected/approximate)

---

## § 4. History as 1D OLAP Point — The Unification

The key unification in the type system:

```
History[T]  ≡  OLAPPoint[T, {time: DateTime}]

-- All History operations are special cases of OLAP operations:
price[t]                  ≡  Price[time: t]                    -- slice to scalar
price[t1..t2]             ≡  Price[time: t1..t2]               -- slice to 1D OLAP
price.avg[period]         ≡  Price[time: period].rollup(:time, fn: :avg)
price.rollup(:week)       ≡  Price[time: all].rollup(:time, grain: :weekly)
```

This unification has practical consequences:

**1. The cluster model applies uniformly**: History segments = 1D OLAP partitions.
All the cluster distribution logic for History works identically for any OLAP Point.

**2. OLAP operations work on History**:

```
product.price.rollup(:month)            -- monthly average prices
product.price.compare(competitor.price) -- price gap over time
product.price.drill(:hour)              -- intra-day price movement
```

**3. History can be promoted to multi-dimensional OLAP**:

```
-- Start with a 1D history:
product.price: History[Money]

-- Promote to multi-dimensional when customer tier is added:
olap_point Price {
  dimensions: { time: DateTime, tier: CustomerTier }
  measure:    Money
  source:     fn(t, tier) -> Money = product.base_price[t] |> apply(TierRules[t], for: tier)
}

-- The 1D history is now a slice of the 2D OLAP Point:
product.price[t]  ≡  Price[time: t, tier: :standard]
```

Dimension promotion does not break existing code — it adds new access patterns.

---

## § 5. OLAP Introspection API

Data access only — no computation. These operations read from History/OLAP
without triggering rule evaluation.

### § 5.1 History Introspection

```
-- Raw interval access
product.price.intervals                 -- [Interval[Money]] (all recorded intervals)
product.price.intervals_in(period)      -- intervals overlapping period
product.price.interval_at(t)            -- Interval[Money]? (exact interval covering t)

-- Change events
product.price.changes                   -- [ChangeEvent[Money]] (all value changes)
product.price.changes_in(period)        -- changes within period
product.price.last_change               -- most recent ChangeEvent
product.price.first_recorded            -- earliest ChangeEvent

-- Structural queries
product.price.covered?                  -- Bool: is the full time domain covered?
product.price.gap_at(t)                 -- Bool: is time t in a gap?
product.price.gaps                      -- [DateRange]: uncovered intervals

-- Statistics on the recorded history
product.price.count_changes_in(period)  -- Int
product.price.duration_of(value)        -- Duration: how long was this value active?
product.price.volatility(period)        -- Float: standard deviation of changes
```

### § 5.2 OLAP Point Introspection

```
-- Dimension inspection
Revenue.dimensions                       -- { time: DateTime, product: Product, ... }
Revenue.measure_type                     -- Money

-- Coverage queries
Revenue.covered?[time: period]           -- Bool: are all cells in period populated?
Revenue.missing_cells[time: :q4_2026]    -- list of (product, region, channel) tuples with no data

-- Distribution
Revenue[time: :q4_2026].distribution(:product)   -- histogram of revenue by product
Revenue[time: :q4_2026].percentile(0.90)          -- 90th percentile cell value

-- Anomaly detection (data-only, no computation)
Revenue.outliers[time: :q4_2026]         -- cells > 3σ from mean
Revenue.trend(:time)[product: laptop]    -- linear trend coefficients over time
```

### § 5.3 Slices as First-Class Values

An OLAP slice is a first-class value — it can be passed to contracts, stored in
outputs, and serialised:

```
type OLAPSlice[T, Dims] = {
  source:     OLAPPointRef
  fixed_dims: Map[Symbol, Any]           -- the fixed dimension values
  free_dims:  Map[Symbol, TypeTag]       -- the remaining queryable dimensions
  measure:    TypeTag[T]
}

-- Use in contract output:
out regional_revenue: OLAPSlice[Money, {time: DateTime}] =
  Revenue[region: region]               -- 1D slice: time series for this region
```

The receiver can further slice, roll up, or pivot the output.

---

## § 6. Cluster-Native OLAP

### § 6.1 Partition Strategy

OLAP Points are partitioned across cluster nodes by their `indexed:` dimensions:

```
olap_point Revenue {
  ...
  indexed: [:time, :product]   -- shard by time × product
}
```

The cluster assigns each (time range, product range) block to a node.
Queries that specify both indexed dimensions go to a single node (hot path).
Queries that scan many products go to multiple nodes in parallel (scatter-gather).

### § 6.2 Parallel OLAP Query Execution

```
-- Revenue for Q4, all products, region=west
-- time is indexed → find partitions covering Q4
-- product is indexed → fan out to all product partitions in parallel

Revenue[time: :q4_2026, region: :west]
  .rollup(:product)
```

Execution plan (generated by compiler):

```
1. SCATTER: find all partitions covering (Q4, all_products)
2. PARALLEL: for each partition node:
     fetch Revenue[time: partition.time_range, region: :west]
     rollup(:product)   -- local reduce
3. GATHER: combine partial rollups from all nodes
4. REDUCE: merge into final result
```

This is a MapReduce pattern generated automatically from the OLAP operation.
The programmer declares WHAT — the compiler generates the distributed execution.

### § 6.3 OLAP Point Cache Hierarchy

```
L1: In-process cache     — sealed segments on local node (immutable, no TTL)
L2: Node-local cache     — recently fetched remote segments (content-addressed)
L3: Cluster gossip cache — segments replicated across replication_factor nodes
L4: Cold storage         — archived segments (object storage, S3-compatible)
```

Because sealed segments are content-addressed, a cache hit is always correct —
no cache invalidation is ever needed for sealed segments. Only the head
segment (unsealed, mutable) requires synchronisation.

---

## § 7. Connection to the Contract Graph

### § 7.1 OLAP Points as Contract Nodes

An `olap_point` declaration creates a special node type in the contract graph:
an **Analytical Node**. It has the same properties as other nodes:
- Typed (the measure type)
- Lazy (evaluated on demand)
- Cached (content-addressed sealed segments)
- Versioned (the segment chain is the version history)

But it is not evaluated by the normal contract execution engine — it is
served by the OLAP engine, which handles distributed partitioning and
parallel aggregation.

### § 7.2 The Operational → Analytical Bridge

The contract system computes facts (operational). The OLAP system aggregates
facts (analytical). The bridge is the `source:` function in the OLAP Point
declaration:

```
olap_point Revenue {
  source: fn(t, product, region, channel) -> Money =
    FulfilledOrders {          -- contract execution (operational)
      period: t.day
      product: product
      region:  region
      channel: channel
    }.total                   -- OLAP engine ingests the result (analytical)
}
```

The OLAP engine calls the source contract at each unique (t, product, region,
channel) combination and stores the result in the segment structure.
Subsequent reads come from the segment cache — the contract is only called once
per unique input combination.

This gives the system the best of both worlds: **contract correctness** for
individual fact computation, **OLAP performance** for aggregate queries.

---

## § 8. Open Research Directions

1. **OLAP Point synthesis** — given a revenue goal expressed as a constraint
   on an OLAP Point, synthesize the contract (or rule) that achieves it.
   Connects temporal synthesis (§2 of temporal-deep) to multi-dimensional goals.

2. **Incremental OLAP** — when a new order is fulfilled, update only the
   affected OLAP cells rather than recomputing from scratch. Connection to
   [igniter-lang-precomp.md](igniter-lang-precomp.md) incremental computation.

3. **OLAP invariants** — declare constraints on OLAP Points as invariants:
   `Revenue.rollup(:all) >= cost.rollup(:all)` (system is profitable).
   Compiler verifies statically.

4. **Approximate OLAP** — use `~T` cells for high-cardinality dimensions where
   exact computation is too expensive. Sampling strategies for OLAP approximation.

5. **OLAP as a query language** — the slice/rollup/drill/pivot operations form
   a complete query language. Is this equivalent to (a subset of) SQL or MDX?
   What are the formal expressive limits?
