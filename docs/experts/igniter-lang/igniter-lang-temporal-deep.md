# Igniter Contract Language — Temporal Model: Deep Strengthening

Date: 2026-04-27.
Status: ★ FRONTIER — current peak of the research track.
Priority: HIGH — closes the five open directions from igniter-lang-temporal.md
into a unified, production-grade temporal model.
Scope: bitemporal, temporal synthesis, causal chain detection, probabilistic
temporal rules, distributed time, unified model.

*Continues: [igniter-lang-temporal.md](igniter-lang-temporal.md)*

---

## § 1. Bitemporal Dimension

### § 1.1 The Problem One Time Axis Cannot Solve

A pricing error is discovered: for the last 3 months, Product X was priced at
$100 but should have been $90. We need simultaneously:

1. Correct future pricing — yes
2. NOT change past order totals (frozen, legally binding) — yes
3. Retroactive analysis: "what should revenue have been?" — yes
4. Audit trail: "what did the system believe on date D?" — yes

Single-axis `History[T]` cannot answer (3) and (4) without breaking (2).
You need two independent time axes.

### § 1.2 Bitemporal Type `BiHistory[T]`

```
type BiHistory[T] = [{
  value:          T
  valid_from:     DateTime     -- when the fact became true in business reality
  valid_until:    DateTime?    -- when it stopped being true (open interval)
  recorded_from:  DateTime     -- when the system recorded this knowledge
  recorded_until: DateTime?    -- when the system corrected/superseded it
}]
```

The data is a 2D surface: valid time (`vt`) × transaction time (`tt`).
A point query `price[vt: t1, tt: t2]` asks: "what was the price at
business moment t1, as the system understood it at recording time t2?"

### § 1.3 The Four Canonical Queries

| Query | Meaning | Use case |
|-------|---------|----------|
| `price[vt: now, tt: now]` | Current price, current knowledge | Live display |
| `price[vt: order.created_at, tt: order.created_at]` | Price at order creation, as the system then believed | Frozen order total |
| `price[vt: order.created_at, tt: now]` | Price at order creation, with today's corrected knowledge | Retroactive audit |
| `price[vt: past_date, tt: report_date]` | Price on a past date, as known at reporting time | Regulatory report |

### § 1.4 The Subtyping Chain

```
T  ⊑  History[T]  ⊑  BiHistory[T]
```

- `T`: constant, no temporal tracking (default for most fields)
- `History[T]`: single-axis, valid time only (the base temporal model)
- `BiHistory[T]`: full bitemporal tracking

Opt-in at entity field level:

```
entity Product {
  name:  String              -- constant (no temporal)
  price: Money @bitemporal   -- full BiHistory[Money]
  stock: Int   @temporal     -- single-axis History[Int] (valid time only)
}
```

Most enterprise fields only need `@temporal`. `@bitemporal` is for values
where retroactive correction is legally or analytically important
(prices, rates, regulatory parameters).

### § 1.5 Bitemporal Access Syntax

```
-- Point access (both axes)
price[vt: t1, tt: t2]

-- Named shortcuts
price.current                  -- [vt: now, tt: now]
price.at(t)                    -- [vt: t, tt: now]
price.as_known_at(t)           -- [vt: now, tt: t]
price.as_known_when_valid(t)   -- [vt: t, tt: t]  ← frozen value

-- Slice (returns BiHistory[T] over a region)
price[vt: period, tt: now]     -- historical prices as currently known
price[vt: now, tt: past_year]  -- how current price knowledge evolved
```

### § 1.6 Bitemporal Invariants

```
invariant FrozenOrderTotal : Order {
  -- Frozen using knowledge-at-creation-time: legally binding
  total == OrderTotal {
    order: self,
    as_of:          created_at,      -- vt: when order was placed
    knowledge_as_of: created_at      -- tt: what we knew then
  }.total
}

invariant AuditableOrderTotal : Order {
  -- Retroactive analysis: what total should have been
  audited_total == OrderTotal {
    order: self,
    as_of:          created_at,      -- vt: same business moment
    knowledge_as_of: DateTime.now()  -- tt: corrected knowledge
  }.total
  -- audited_total != total is valid and expected after a price correction
}
```

The compiler verifies that `total` (frozen) and `audited_total` (corrected)
are computed from different `tt` axes — never confused.

### § 1.7 Bitemporal Corrections

```
-- Record a price correction (retroactive)
effect :correct_price =
  PriceCorrection {
    product:     product
    correct_price: 90_00    -- the price that should have been
    valid_from:   3.months.ago
    valid_until:  Date.today
    reason:       :data_entry_error
  }
  @audit
```

The correction inserts a new row in the `tt` dimension: all future queries
with `tt: now` see the corrected price. All queries with `tt: before_correction`
see the original. `FrozenOrderTotal` (using `tt: created_at`) is unaffected.

---

## § 2. Temporal Synthesis

### § 2.1 The Problem

A business analyst states: *"December revenue should be 15% higher than
November."* They want a pricing rule, not an SQL report.

Goal-directed rule synthesis: given a temporal goal property and historical
data, synthesize a `rule` declaration that achieves the goal while respecting
all declared invariants.

### § 2.2 Synthesis DSL

```
synthesize rule for OrderManagement {
  goal:
    PeriodReport { period: december }.actual_revenue >=
    PeriodReport { period: november }.actual_revenue * 1.15

  template: rule SynthesizedPromotion : Product {
    applies: { months: [:december] }
    compute: fn(product) -> Float = ?rate    -- ? marks synthesis target
    priority: 60
    combines: :override
  }

  constraints: [PriceFloor, CustomerFairness, MaxDiscountRate(0.30)]

  using: orders |> select { |o| o.created_at.in?(last_year) }
}
```

The synthesiser finds the smallest `?rate` (least invasive change) such that
the goal is satisfied over the historical data set, subject to constraints.

### § 2.3 Reduction to Linear Programming

For linear pricing rules `effective_price = base * (1 - rate)`:

Let `n` = number of orders in the synthesis period.
Let `tᵢ` = order `i`'s total at base prices.
Let `r` = the discount rate (the synthesis variable).

Goal constraint:
```
Σᵢ tᵢ × (1 - r) ≥ 1.15 × Σᵢ tᵢ_november
```

Wait — a discount reduces revenue. The analyst wants *higher* revenue, so
the synthesiser may need a **price increase** (`r < 0` = markup) rather than
a discount. This is surfaced explicitly in the result.

PriceFloor constraint:
```
∀ product: base_price × (1 - r) ≥ cost_price × 1.10
→  r ≤ 1 - (cost_price × 1.10) / base_price   for each product
→  r ≤ min_across_products(1 - cost_margin)
```

This is a **linear program** — PTIME via simplex. Result: either a feasible
rate `r*` or a proof of infeasibility (goal cannot be achieved while respecting
all constraints).

### § 2.4 Synthesis Result

```
-- Synthesiser output (proposed rule, not yet activated):
rule SynthesizedPromotion_2026_12 : Product {
  applies: { months: [:december] }
  compute: fn(product) -> Float = -0.14    -- 14% price increase
  priority: 60
  combines: :override
  @generated(
    goal:       "december_revenue >= 1.15 * november_revenue",
    confidence: 0.92,                      -- based on historical variance
    orders_used: 847,
    feasibility: :satisfied
  )
}

-- Impact preview (run WhatIfAnalysis automatically):
-- Expected revenue delta: +$124,000
-- Orders affected: 847 (100%)
-- Average order increase: +$146
-- PriceFloor: satisfied for all 234 products
-- CustomerFairness: WARNING — 12 products exceed max_increase threshold
```

The synthesiser surfaces warnings before activation. The analyst can adjust
the template (exclude product categories, cap per-product increase) and
re-run synthesis.

### § 2.5 Multi-Variable Synthesis

For more expressive templates with multiple `?` targets:

```
template: rule TieredPromotion : Product {
  applies: { months: [:december] }
  compute: fn(product) -> Float =
    if product.category == :premium then ?premium_rate
    else if product.margin > 0.40  then ?high_margin_rate
    else                                ?standard_rate
}
```

Each `?` is an independent LP variable. The system solves for the combination
that minimises total price change subject to the revenue goal.

---

## § 3. Causal Chain Detection

### § 3.1 The Problem

Two rules appear independent but share a value path:

```
rule VolumeDiscount : Order {
  applies: { when: order.total > 1_000 }
  compute: fn(order) -> Float = 0.10
}

rule SeasonalDiscount : Product {
  applies: { months: [:december] }
  compute: fn(product) -> Float = 0.20
}
```

In December: `SeasonalDiscount` reduces product prices → `order.total` drops
below `1_000` → `VolumeDiscount.applies` becomes false → `order.total`
increases again → `VolumeDiscount.applies` becomes true → oscillation.

This is a hidden **feedback loop** in the rule set.

### § 3.2 Rule Dependency Graph

The compiler builds a **Rule Dependency Graph (RDG)** where:
- Nodes = rules and the temporal values they read/write
- Edge `r → v`: rule `r` writes (computes) value `v`
- Edge `v → r`: rule `r`'s `applies:` predicate reads value `v`

```
SeasonalDiscount → Product.effective_price → Order.total → VolumeDiscount.applies
VolumeDiscount   → Order.effective_total   → Order.total   (feedback!)
```

The cycle: `Order.total → VolumeDiscount → Order.total` — detected as a cycle
in the RDG.

### § 3.3 Cycle Classification

Not all cycles are equal:

| Cycle type | Condition | Convergence |
|-----------|-----------|-------------|
| **Monotone decreasing** | Each iteration only reduces values | Guaranteed convergence |
| **Monotone increasing** | Each iteration only increases values | Guaranteed convergence |
| **Bounded oscillation** | Cycle visits finite states | Convergence to periodic orbit |
| **Unbounded** | Values can grow without limit | Divergence — ERROR |

For discount rules (rate ∈ `[0, 1]`): any cycle through prices is monotone
decreasing → converges in at most O(log(price/floor)) iterations.

For price adjustment rules (rate can be > 1): must check boundedness.

### § 3.4 Compiler Diagnostics and Resolution

The compiler emits a diagnostic with the cycle trace and convergence
classification:

```
WARNING: Causal cycle in rule evaluation
  Cycle: SeasonalDiscount → Order.total → VolumeDiscount → Order.total
  Type:  Monotone decreasing (discounts only)
  Convergence: guaranteed within 2 iterations

  Resolution options:
  (a) Declare explicit evaluation order:
        SeasonalDiscount >> VolumeDiscount
      Effect: VolumeDiscount sees post-seasonal totals (intended behaviour)

  (b) Snapshot intermediate value:
        rule VolumeDiscount { applies: { when: order.pre_rule_total > 1_000 } }
      Effect: VolumeDiscount checks the original total (before any rules)

  (c) Accept convergence (add @converge annotation):
        rule VolumeDiscount { ... @converge(max_iterations: 3) }
      Effect: runtime iterates until stable, error if not converged in 3 steps
```

### § 3.5 Resolution Strategies

**Strategy A — Explicit order** `>>`

```
system OrderManagement {
  rules: [SeasonalDiscount >> VolumeDiscount, CustomerLoyalty, PriceFloor]
  -- SeasonalDiscount evaluated first; VolumeDiscount sees post-seasonal total
}
```

This is the most predictable: evaluation order is the declared composition order.
The RDG becomes a DAG.

**Strategy B — Snapshot**

```
rule VolumeDiscount : Order {
  applies: { when: order.base_total > 1_000 }    -- base_total = pre-rule value
  compute: fn(order) -> Float = 0.10
}
```

`base_total` is a `@snapshot` node: its value is frozen before any rule
application in the current evaluation context.

**Strategy C — Convergence annotation**

```
rule VolumeDiscount : Order {
  applies: { when: order.total > 1_000 }
  compute: fn(order) -> Float = 0.10
  @converge(max_iterations: 5, tolerance: 0.01)
}
```

The runtime iterates the rule set until the change between iterations is
less than `tolerance` or `max_iterations` is reached (error if not converged).
Correct for monotone cycles; runtime overhead for non-trivial cycles.

---

## § 4. Probabilistic Temporal Rules

### § 4.1 Rules With Uncertain Applicability

Some rules should fire based on probabilistic conditions — a promotion pending
manager approval, a forecast-driven seasonal adjustment, an A/B experiment.

```
rule AnticipatedPromotion : Product {
  applies: { when: ~approval_likelihood > 0.8 }    -- probabilistic predicate
  compute: fn(product) -> Float = 0.15
  priority: 70
  @approximate(confidence: 0.9)
}
```

`~approval_likelihood` is a `~Float` from the pre-computation model
([igniter-lang-precomp.md](igniter-lang-precomp.md)): it carries
`{ value: 0.85, lo: 0.72, hi: 0.94, confidence: 0.9 }`.

The `applies:` comparison `~Float > 0.8` returns `Bool | Uncertain` — the
three-valued result from §1.5 of the language spec.

### § 4.2 Two-Level Temporal Evaluation

The pre-computation model maps directly to rule evaluation:

| Level | Rule applies? | Result type | Use case |
|-------|--------------|-------------|----------|
| **Approximate** | Probabilistically determined | `~T` | Planning, forecasting, pre-authorisation |
| **Exact** | Rule is activated or not (Bool) | `T` | Committed order total, invoice |

```
contract OrderTotal {
  in order: Order
  in as_of: DateTime = order.created_at

  -- Approximate: include probable rules
  compute :expected_total: ~Money =
    apply_rules(order, ActiveRules[as_of] ++ ProbableRules[as_of])
    @approximate(confidence: 0.85)

  -- Exact: only confirmed rules
  compute :committed_total: Money =
    apply_rules(order, ActiveRules[as_of] |> filter { .confirmed? })
    @exact

  out total:    Money  = committed_total   -- legal commitment
  out expected: ~Money = expected_total    -- planning figure
}
```

### § 4.3 The Decision-Directed Precision Model

From [igniter-lang-precomp.md](igniter-lang-precomp.md): downstream consumers
declare their precision requirement, triggering exact computation only when needed.

Applied to temporal rules:

```
-- Inventory planning: approximate is sufficient
compute :planned_revenue: ~Money =
  orders |> sum { .expected }
  @tolerance(0.05)       -- 5% error acceptable

-- Invoice generation: must be exact
compute :invoice_total: Money =
  order.total            -- forces committed_total path
  @exact
```

When `@exact` is requested, the runtime ensures all probabilistic rules are
resolved (waiting for approval, A/B test completion, etc.) before computing
the total.

### § 4.4 Probabilistic Rule Invariants

```
invariant ProbabilisticConsistency : Order {
  -- Committed total must be within the approximate estimate's confidence interval
  total in expected.lo..expected.hi
  -- If the committed total falls outside the estimate, flag for review
}

invariant ConfidenceThreshold : OrderBatch {
  -- Don't commit a batch unless aggregate confidence is sufficient
  items.avg { .expected.confidence } >= 0.85
}
```

---

## § 5. Distributed Time

### § 5.1 The Problem

In a distributed system with nodes A and B:
- Node A processes an order at wall-clock `10:00:00`
- Node B processes an event at wall-clock `09:59:58` (2 seconds behind)
- `as_of: DateTime.now()` returns different values on each node
- The same order may be evaluated with inconsistent rule sets

Wall-clock `DateTime.now()` is not a safe `as_of` in a distributed context.

### § 5.2 Logical Clocks as `as_of`

**Lamport timestamps (1978)**: each event gets an integer timestamp `L`.
If event A causally precedes B, `L(A) < L(B)`. Total order consistent
with causal order.

```
type LogicalTimestamp = {
  node_id:  Id
  sequence: Int
}

-- Ordering: (n1, s1) < (n2, s2) iff s1 < s2 || (s1 == s2 && n1 < n2)
```

The `as_of` parameter becomes a `LogicalTimestamp`:

```
in as_of: LogicalTimestamp = LogicalClock.current()
```

`price[as_of: lt]` resolves the history to the value visible at logical
time `lt`: all writes with `recorded_from ≤ lt` are visible.

### § 5.3 The Causal `as_of`

The `await` construct must carry the sender's logical time, not the receiver's:

```
await :payment_confirmed,
  event:  :payment_received,
  as_of:  event.sender_logical_time    -- causal time of the event source
```

Without this: a late-arriving event (due to network delay) is evaluated with
a `now` that is later than the event's causal time — the system "sees the
future" relative to the event's context.

With causal `as_of`: the contract is always evaluated in the causal context
of its inputs.

### § 5.4 Vector Clocks and Consistency Levels

**Vector clocks** track per-node causal history:
`VC = { node_1: 5, node_2: 3, node_3: 7 }`

`VC(A) ≤ VC(B)` iff every component of A is ≤ the corresponding component of B.
This gives a partial order (not total) — concurrent events are incomparable.

This maps to distributed consistency levels in the temporal model:

| Consistency level | `as_of` semantics | Guarantee |
|------------------|------------------|-----------|
| **Causal** | Vector clock of last write | Sees all causally preceding writes |
| **Monotonic read** | Max of seen timestamps | Never goes back in time |
| **Session** | Vector clock of this session's writes | Sees own writes |
| **Eventual** | `DateTime.now()` on local node | No ordering guarantee |

```
contract OrderTotal {
  in order: Order
  in as_of: LogicalTimestamp = LogicalClock.current()
  in consistency: Symbol = :causal      -- default

  compute :price = product.price[as_of, consistency: consistency]
}
```

### § 5.5 Temporal Invariants Under Distributed Time

The `FrozenOrderTotal` invariant must be strengthened for distributed contexts:

```
invariant FrozenOrderTotal : Order {
  -- Frozen at the causal time of order creation (not wall clock)
  total == OrderTotal {
    order:   self,
    as_of:   created_at_logical,     -- LogicalTimestamp, not DateTime
    consistency: :causal
  }.total
}
```

The `created_at_logical` field is a `LogicalTimestamp` stamped by the node
that created the order. This is the causal anchor for the frozen value.

**The key invariant for distributed temporal rules:**

```
invariant CausalRuleApplication : Order {
  -- All rules applied to this order had valid_from ≤ order.created_at_logical
  applied_rules.all? { |r|
    r.logical_valid_from <= created_at_logical
  }
}
```

A rule that was activated *after* the order was created (in causal order)
cannot have been applied to that order.

---

## § 6. The Unified Temporal Model

Combining all five strengthening directions into a coherent whole:

### § 6.1 The Complete Type Hierarchy

```
T                        -- constant (no temporal tracking)
  ⊑ History[T]           -- single-axis: valid time
      ⊑ BiHistory[T]     -- two-axis: valid time × transaction time
          ⊑ ~BiHistory[T] -- approximate + bitemporal (full model)
```

### § 6.2 The Temporal Contract Parameters

```
contract C {
  in as_of:          DateTime | LogicalTimestamp = LogicalClock.current()
  in knowledge_as_of: DateTime                   = DateTime.now()    -- tt axis
  in consistency:    Symbol                      = :causal
  ...
}
```

Three independent knobs:
- `as_of`: **when** to evaluate (vt axis)
- `knowledge_as_of`: **what we knew** when evaluating (tt axis, for bitemporal)
- `consistency`: **how strongly** to enforce ordering (for distributed)

### § 6.3 Rule Set Evaluation Pipeline

```
1. COLLECT    rules where applies(as_of, context) → Bool | ~Bool
2. RESOLVE    probabilistic applies: ~Bool → Bool (or keep as ~)
3. ORDER      by priority + explicit >> composition
4. CHECK      RDG for causal cycles; apply resolution strategy
5. APPLY      ordered fold with combines strategies
6. CONVERGE   if @converge annotated: iterate until stable
7. VERIFY     temporal invariants on output
```

Each step is PTIME for finite, Horn-fragment rule sets.

### § 6.4 Correctness Properties

The unified model satisfies:

| Property | Guarantee |
|----------|-----------|
| **Temporal determinism** | Same inputs + same `as_of` + same rule set → same output |
| **Causal consistency** | Rules applied only with causally preceding knowledge |
| **Frozen value integrity** | `@bitemporal` + `tt: created_at` → values never retroactively change |
| **Causal cycle safety** | Monotone cycles converge; unbounded cycles are compile errors |
| **Approximate soundness** | `~T` results are within declared confidence bounds |
| **Distributed monotonicity** | `as_of` advances monotonically within a session |

---

## § 7. Revised POC Roadmap

### § 7.1 Three-Iteration Plan

**Iteration 1 — Single-axis temporal + rules (foundation)**
- `History[T]`, `[t]` operator, `@temporal` annotation
- `rule` declarations with `applies:` / `compute:` / `priority:`
- Orthogonality: rule registration in system, no contract changes
- Temporal invariants: `FrozenOrderTotal`, `TemporalCoverage`
- Compiler: temporal node detection, `as_of` injection, rule resolution fold
- Smoke test: `FulfillOrder` + `WeekendPrice` rule

**Iteration 2 — Causal chains + bitemporal + synthesis**
- RDG construction and cycle detection
- `@converge` and `@snapshot` resolution strategies
- `BiHistory[T]`, `[vt: t, tt: t]` access syntax
- `synthesize rule` DSL + LP solver integration (simplex)
- Extended smoke test: `PeriodReport` + `WhatIfAnalysis`

**Iteration 3 — Probabilistic rules + distributed time**
- `~applies` with `@approximate` rules
- Two-level evaluation (expected vs. committed)
- `LogicalTimestamp` as `as_of` type
- `CausalRuleApplication` invariant
- Distributed smoke test: multi-node order processing with consistent temporal evaluation

### § 7.2 Minimal Ruby DSL Surface (Iteration 1)

```ruby
# Model layer additions
class RuleNode < Node
  attr_reader :target_type, :applies_spec, :compute_fn, :priority, :combines
end

class TemporalNode < ComputeNode
  attr_reader :temporal_axis   # :single | :bitemporal
end

# DSL additions in ContractBuilder
def rule(name, type:, applies:, compute:, priority: 50, combines: :override)
  # ...
end

def temporal(name, type, &block)
  # declare compute node with @temporal
end

# System additions
class SystemDeclaration
  def rules(*rule_names)
    @rules = rule_names
  end
end

# Compiler additions
class RuleDependencyGraph
  def build(system); end
  def detect_cycles; end
  def classify_cycle(cycle); end
end

class TemporalNodeInjector
  def inject_as_of(contract); end   # rewrites contract with as_of parameter
end

class RuleResolver
  def resolve(node, as_of, system); end   # ordered fold
end
```

Total new lines of code (estimate): ~400 in compiler + ~150 in DSL + ~200 in runtime.
This is the scale of "one concentrated sprint" — not a multi-month project.
