# Igniter Contract Language — Temporal Dimension and Time-Varying Values

Date: 2026-04-27.
Status: ★ FRONTIER — current peak of the research track.
Priority: HIGH — solves the hardest practical enterprise pain: pricing rules, discounts,
period reports, and temporal consistency without code explosion.
Scope: temporal types, rule declarations, as-of evaluation, orthogonality principle,
temporal invariants, counterfactual reports, formal foundation.

*Builds on: [igniter-lang-invariants.md](igniter-lang-invariants.md) ·
[igniter-lang-algebra.md](igniter-lang-algebra.md) ·
[igniter-lang-theory2.md](igniter-lang-theory2.md) (situation calculus, §7)*

---

## § 0. The Problem

A manager changes a product price for the weekend. In every language and framework
the author has seen, this turns a one-page algorithm into a sprawling system:

- `effective_date` added to every model that touches price
- `price_histories` table with complex joins
- "as-of" query logic scattered across repositories
- Special cases in the order total computation
- New columns in every report
- Audit trail bolted on as an afterthought
- Tests that pass but miss the temporal edge cases

The root cause is architectural: **time is a second-class citizen**. Price is
typed as `Float`. But price is not a `Float` — price is a **function of time**:
`DateTime → Money`.

The contract language's answer: make the temporal dimension **first-class**,
**orthogonal** to the computation graph, and **composable** with the invariant
system. Adding a weekend pricing rule must not touch the order contract, the
totals computation, or the reporting contract.

---

## § 1. Temporal Types

### § 1.1 `History[T]` — Value Over Time

```
type History[T] = [{ value: T, from: DateTime, until: DateTime? }]
```

A `History[T]` is an ordered sequence of intervals, each carrying a value of
type `T` and the half-open interval `[from, until)` during which it is valid.
The sequence is non-overlapping and covers a contiguous domain.

Constants are degenerate histories:

```
T ⊑ History[T]
```

A plain `Money` value is a `History[Money]` with one interval: `[epoch, ∞)`.
This means **existing contracts work unchanged** — temporal is purely additive.

### § 1.2 The Temporal Access Operator `[t]`

```
expr '[' time_expr ']'    -- resolve History[T] to T at time t
expr '[' range_expr ']'   -- slice History[T] over an interval → History[T]
```

`price[t]` evaluates the history at point `t` and returns the value of type `T`
active at that instant. If no interval covers `t`, the result is `Null`.

```
product.price[order.created_at]          -- price when order was placed
product.price[Date.today]                -- current price
product.price[period.start..period.end]  -- price history over a period
product.price.current                    -- alias for product.price[DateTime.now()]
```

**Type rule:**
```
Γ ⊢ h : History[T]   Γ ⊢ t : DateTime
──────────────────────────────────────────
Γ ⊢ h[t] : T?                            -- Null if t is not covered
```

### § 1.3 Declaring Temporal Nodes

A `compute` or `in` node whose value changes over time is declared with
the `temporal` annotation:

```
in product_id: Id

compute :product = fetch(product_id)   @temporal   -- value may vary with time

compute :price   = product.price       @temporal
compute :rules   = ActiveRules         @temporal
```

A `@temporal` node is automatically typed as `History[T]` at the contract level.
Inside temporal expressions it is accessed via `[t]`.

### § 1.4 The `as_of` Evaluation Context

Every contract carries an implicit `as_of: DateTime` parameter.

```
in as_of: DateTime = DateTime.now()
```

When the runtime evaluates a `@temporal` node, it automatically applies
`[as_of]` to resolve the history to a point value. The user writes:

```
compute :effective_price = product.price
```

The compiler rewrites this to:

```
compute :effective_price = product.price[as_of]
```

Callers that need a specific evaluation point pass `as_of` explicitly:

```
compose :historical = OrderTotal { order: order, as_of: order.created_at }
compose :current    = OrderTotal { order: order, as_of: Date.today }
```

---

## § 2. Rule Declarations

### § 2.1 Syntax

```
rule_decl ::=
  'rule' IDENT ':' type_name '{'
    'applies' ':' applies_spec
    'compute' ':' fn_expr
    ['requires' ':' IDENT]
    ['priority' ':' INT]
    ['combines' ':' SYMBOL]
  '}'

applies_spec ::=
  | '{' {applies_clause ','} '}'
  | 'always'

applies_clause ::=
  | 'from' ':' date_expr
  | 'until' ':' date_expr
  | 'days' ':' '[' {SYMBOL ','} ']'
  | 'months' ':' '[' {SYMBOL ','} ']'
  | 'when' ':' predicate
  | 'manual' ':' BOOL
```

### § 2.2 Examples

```
rule WeekendManagerPrice : Product {
  applies: { days: [:saturday, :sunday], manual: true }
  compute: fn(product, override) -> Money = override.weekend_price
  requires: ManagerApproval
  priority: 100
}

rule SeasonalDiscount : Product {
  applies: { from: :december_1, until: :january_15 }
  compute: fn(product) -> Float = 0.20     -- 20% discount rate
  priority: 50
}

rule CustomerLoyaltyDiscount : Customer {
  applies: { when: customer.orders_count > 10 }
  compute: fn(customer) -> Float = 0.05    -- 5% loyalty rate
  priority: 30
  combines: :additive                      -- stacks with other discounts
}

rule PriceFloor : Product {
  applies: always
  compute: fn(product) -> Money = product.cost_price * 1.10   -- 10% margin floor
  priority: 1000                           -- floor always wins
  combines: :clamp_min
}
```

### § 2.3 Rule Registration in System

```
system OrderManagement {
  entities: [Order, Product, Customer]
  rules: [
    WeekendManagerPrice
    SeasonalDiscount
    CustomerLoyaltyDiscount
    PriceFloor
  ]
}
```

Adding a new rule is a **one-line change** to the system declaration. No other
contracts are modified.

---

## § 3. Temporal Contract Evaluation

### § 3.1 The OrderTotal Contract — Before and After

**Before temporal rules** (original, unchanged):

```
contract OrderTotal {
  in order: Order

  compute :items = order.items
  aggregate :total = sum(items |> map { |i| i.product.price * i.qty })

  out total: Money = total
}
```

**After temporal rules** (compiler rewrites; source unchanged):

The compiler sees that `product.price` is `@temporal` and rewrites the
evaluation to pass `as_of` automatically:

```
contract OrderTotal {
  in order:  Order
  in as_of:  DateTime = order.created_at    -- injected by compiler

  compute :items = order.items
  compute :effective_prices =
    items |> map { |i|
      i.product.price[as_of]
      |> apply(ActiveRules[as_of], for: i.product)
      |> apply(CustomerRules[as_of], for: order.customer)
      |> enforce(PriceFloor[as_of], for: i.product)
    }

  aggregate :total = sum(effective_prices |> map { |p, i| p * i.qty })

  out total:         Money      = total
  out as_of:         DateTime   = as_of
  out rules_applied: [RuleName] = active_rules_applied
}
```

The user's source code **did not change**. The temporal machinery is injected
by the compiler when temporal nodes and rules are declared.

### § 3.2 Rule Evaluation Order

For each temporal node, the runtime builds a **rule stack** for the evaluation
point `t`:

1. Collect all rules whose `applies` predicate is satisfied at `t`
2. Sort by `priority` (descending)
3. Apply in order according to each rule's `combines` strategy

`combines` strategies:

| Strategy | Meaning |
|----------|---------|
| `:override` (default) | Higher priority replaces lower |
| `:additive` | Stack with previous results (e.g., sum discounts) |
| `:clamp_min` | Result = max(previous, this rule's value) |
| `:clamp_max` | Result = min(previous, this rule's value) |
| `:first_match` | Stop after first matching rule |

### § 3.3 Temporal Node Resolution Algorithm

```
resolve_temporal(node, t):
  base_value  = node.compute_at(t)
  rule_stack  = system.rules_for(node.type, t)
               |> sort_by(:priority)
  result      = base_value
  for rule in rule_stack:
    result = combine(result, rule.compute(result, t), rule.combines)
  return result
```

This is PTIME for finite rule sets — a simple ordered fold.

---

## § 4. The Orthogonality Principle

The central architectural guarantee: **temporal rules are orthogonal to the
contract computation graph**.

Adding a rule:
- Does NOT change the graph topology (no new edges, no new nodes)
- Does NOT change the type signatures of any existing contract
- Does NOT require touching any existing contract source
- Only changes **what value a temporal node resolves to** at a given time

Formally: let `G` be the contract graph and `R` be the rule set. The evaluation
of `G` with rule set `R ∪ {r}` differs from `G` with `R` only in the resolved
values of temporal nodes — not in the graph structure, dependency order, or
type-checking result.

This is the **frame property** of the temporal model: everything that is not
touched by a rule is unchanged. It maps directly to Reiter's solution to the
frame problem in situation calculus:

> *Successor state axiom*: the value of a fluent after an action is either the
> value set by the action, or the previous value (if the action does not affect
> the fluent).

In contract terms: a rule sets the value of a temporal node for an interval.
All other nodes are unaffected.

---

## § 5. Temporal Invariants

### § 5.1 Frozen Values

Some values must be **frozen at creation time** — they must not change even if
the underlying temporal data changes later.

```
invariant FrozenOrderTotal : Order {
  -- Order total is fixed at creation time, never retroactively changed
  total == OrderTotal { order: self, as_of: created_at }.total
}

invariant FrozenItemPrices : OrderItem {
  -- Each item's price is the price that was active when the order was created
  unit_price == product.price[order.created_at]
               |> apply(ActiveRules[order.created_at], for: product)
}
```

The compiler verifies these statically: adding a new pricing rule cannot
retroactively change the `total` of an already-created order.

### § 5.2 Temporal Consistency

```
invariant RuleIntegrity : Order {
  -- All rules applied to this order were active at creation time
  applied_rules.all? { |r| r.applies_at(created_at) }
}

invariant TemporalCoverage : Product {
  -- Price history has no gaps — a price always exists
  price.covers?(DateRange.all)
}
```

### § 5.3 Monotone Constraints

```
invariant SalePriceIsLower : Product {
  when sale_active_at(t) {
    price[t] <= price[t - 1.day]    -- sale price must be lower than pre-sale
  }
}

invariant PriceFloorRespected : Product {
  price.all? { |interval| interval.value >= cost_price * 1.10 }
}
```

### § 5.4 Temporal Invariants and the Compiler

Temporal invariants propagate through composition exactly like static invariants
(from [igniter-lang-invariants.md](igniter-lang-invariants.md)), with one
addition: the compiler checks temporal invariants across the declared rule set.

When a new rule `r` is added:
1. Compiler computes the temporal node values under `R ∪ {r}`
2. Checks all `FrozenValue` invariants — verifies no frozen value changes
3. Checks all `TemporalConsistency` invariants
4. Emits diagnostic if any invariant is violated

If the compiler finds a violation, the rule is rejected with a specific
invariant trace — not a runtime exception.

---

## § 6. Reports and Counterfactual Analysis

### § 6.1 Period Report

```
contract PeriodReport {
  in period:  DateRange
  in orders:  [Order]

  -- Actual revenue: each order evaluated at its creation time
  collection :actuals =
    map(orders, OrderTotal)             -- as_of defaults to order.created_at

  -- Counterfactual: same orders with today's rules
  collection :counterfactual =
    map(orders, OrderTotal { as_of: Date.today })

  -- Breakdown by rule
  collection :rule_impact =
    map(orders, fn(order) -> {
      order_id: order.id
      actual:   OrderTotal { order: order, as_of: order.created_at }.total
      current:  OrderTotal { order: order, as_of: Date.today }.total
      delta:    current - actual
    })

  aggregate :actual_revenue        = sum(actuals         |> map { .total })
  aggregate :counterfactual_revenue = sum(counterfactual  |> map { .total })
  aggregate :price_impact          = counterfactual_revenue - actual_revenue

  out summary: PeriodSummary = {
    actual:         actual_revenue
    counterfactual: counterfactual_revenue
    price_impact:   price_impact
    period:         period
  }
  out detail: [RuleImpact] = rule_impact
}
```

This contract answers:
- "What was our actual revenue this month?" → `actual_revenue`
- "What would revenue be if we applied today's prices retroactively?" → `counterfactual_revenue`
- "How much did weekend pricing changes affect revenue?" → `price_impact`
- "Which orders were most affected?" → `detail`

No SQL. No joins. No separate analytics service.

### § 6.2 What-If Analysis

```
contract WhatIfAnalysis {
  in orders:       [Order]
  in proposed_rule: Rule
  in period:        DateRange

  -- Current revenue with existing rules
  collection :current =
    map(orders |> select { |o| period.covers?(o.created_at) }, OrderTotal)

  -- Hypothetical revenue with proposed rule added
  collection :hypothetical =
    map(
      orders |> select { |o| period.covers?(o.created_at) },
      OrderTotal { extra_rules: [proposed_rule] }
    )

  aggregate :current_revenue     = sum(current     |> map { .total })
  aggregate :hypothetical_revenue = sum(hypothetical |> map { .total })

  out impact: RuleImpactAnalysis = {
    revenue_delta:    hypothetical_revenue - current_revenue
    orders_affected:  hypothetical |> count { |h, c| h.total != c.total }
    avg_order_change: (hypothetical_revenue - current_revenue) / orders.count
  }
}
```

A pricing manager can evaluate a proposed rule against historical data
**before activating it** — no code changes, no staging environment needed.

---

## § 7. Rule Composition Algebra

### § 7.1 Operations

Rules compose with the same algebra as contracts:

```
-- Sequential: r2 sees r1's result
rule_1 >> rule_2

-- Choose the more specific (narrower temporal scope wins)
rule_1 | rule_2

-- Both apply independently, results combined
rule_1 ∧ rule_2

-- Exclusive: only one may match in a given interval
rule_1 ⊕ rule_2

-- Conditional override: r2 only if r1 didn't match
rule_1 else rule_2
```

### § 7.2 Conflict Detection

The compiler detects rule conflicts statically:

**Overlap conflict**: two rules of the same priority and type both apply to
overlapping intervals — ambiguous result:

```
-- CONFLICT: both apply on weekends in December, same priority
rule WeekendDiscount : Product { applies: { days: [:saturday, :sunday] } ... }
rule DecemberSale    : Product { applies: { from: :december_1 } ... }
```

Compiler emits: "temporal conflict — WeekendDiscount ∩ DecemberSale on
[dec_1..jan_15 ∩ saturdays/sundays]; resolve with priority or combines."

**Floor violation**: a discount rule conflicts with a floor rule:

```
rule AggressiveDiscount : Product {
  applies: { when: marketing.campaign_active }
  compute: fn(product) -> Money = product.price * 0.40   -- 60% off
}

-- PriceFloor is declared at priority:1000 with combines: :clamp_min
-- Compiler warns: AggressiveDiscount may violate PriceFloor at campaign_active intervals
```

### § 7.3 Rule Specificity Order

When no explicit priority is set, the compiler orders rules by specificity:

1. **Temporal specificity**: narrower interval is more specific
   (`{ days: [:saturday] }` > `{ months: [:december] }` > `always`)
2. **Predicate specificity**: more conditions = more specific
3. **Type specificity**: subtype rule > supertype rule
   (`VipCustomer` rule > `Customer` rule)

---

## § 8. Formal Foundation

### § 8.1 Situation Calculus (McCarthy 1963, Reiter 1991)

From [igniter-lang-theory2.md](igniter-lang-theory2.md), §7: situation calculus
is the formal model for reasoning about changing worlds.

| Situation calculus | Contract temporal model |
|-------------------|------------------------|
| Situation `S` | Evaluation context `(contract, as_of: t)` |
| Fluent `F(S)` | Temporal node value at `as_of` |
| Action `A` | Rule application |
| Successor state axiom | `applies:` spec + `compute:` function |
| Frame axiom | Orthogonality principle: untouched nodes unchanged |
| Initial situation `S₀` | Base value of `History[T]` before any rules |

Reiter's solution to the frame problem: O(m) successor state axioms for m
actions. In contract terms: O(r) rule declarations for r rules. No axiom
explosion.

### § 8.2 PTIME Evaluation

Temporal evaluation is PTIME for:
- Finite rule sets (guaranteed for any finite system declaration)
- Finite history intervals (guaranteed by `from`/`until` declarations)
- PTIME `applies:` predicates (linear arithmetic on DateTime — yes; recursive — no)

Rule resolution is an ordered fold over a finite sorted list — O(r log r) for
sorting + O(r) for application = O(r log r) total, dominated by sort.

History slice `h[t]` is a binary search on the interval list — O(log n) for
n intervals.

### § 8.3 Connection to Temporal Datalog

Temporal evaluation maps to **temporal Datalog** (Chomicki & Imielinski 1988):
rules are Datalog clauses with a temporal argument. The evaluation is a
fixpoint over the time domain, which remains PTIME for bounded domains.

This preserves the decidability guarantee of [igniter-lang-theory2.md](igniter-lang-theory2.md)
Theorem 2.1 for the temporal fragment.

---

## § 9. Compactness Promise

The test case: a manager changes a product price for the weekend. What changes?

| Change | Classical system | Contract temporal model |
|--------|-----------------|------------------------|
| Add weekend price | +migration, +price_history table, +join in order query, +report columns | +1 `rule WeekendPrice` declaration |
| Add loyalty discount | +customer_discounts table, +eligibility logic, +report join | +1 `rule CustomerLoyalty` |
| Add seasonal rule | +seasonal_prices table, +date range logic, +special cases in totals | +1 `rule SeasonalDiscount` |
| Freeze order prices | +snapshot logic, +audit trail, +migration | automatic: `FrozenOrderTotal` invariant |
| Period report | +new SQL query, +separate analytics service, +data pipeline | +`PeriodReport` contract using existing `OrderTotal` |
| What-if analysis | +analytics service, +staging data copy | +`WhatIfAnalysis` contract (~20 lines) |
| Price impact report | +bespoke query, +warehouse ETL | +`counterfactual` collection in `PeriodReport` |

In every row: classical approach = new files, new tables, changes to existing code.
Contract approach = new declarations, zero changes to existing contracts.

---

## § 10. Open Research Directions

### § 10.1 Bitemporal Dimension

Most systems track one time axis (valid time: when a fact is true in the world).
Bitemporal systems track two independent axes:

- **Valid time** (`vt`): when the fact was true in the business reality
- **Transaction time** (`tt`): when the system recorded it

```
product.price[vt: order.created_at, tt: DateTime.now()]
-- "what was the price when the order was placed, using everything we know today?"

product.price[vt: order.created_at, tt: order.created_at]
-- "what was the price using only information available at order creation?"
```

Bitemporal access enables:
- Retroactive price corrections without affecting historical order totals
- Audit trail: "what did the system believe at time T?"
- Regulatory compliance: "what was true on date D for reporting period R?"

This requires extending `History[T]` to a 2D surface rather than a 1D sequence.

### § 10.2 Temporal Synthesis

Given: *"In December, revenue should increase by 15% over November"*
Given: current rule set and pricing history
Synthesize: a discount or pricing rule that achieves the revenue goal

This connects the temporal model to property model synthesis from
[igniter-lang-propmodel.md](igniter-lang-propmodel.md). The goal becomes
a temporal property; the synthesiser searches over the rule space.

Feasibility: for linear pricing rules (`base * factor + constant`), the
synthesis is a linear programming problem — PTIME via simplex.

### § 10.3 Causal Chains Between Rules

When rule A modifies value X and rule B depends on X, evaluation order matters.
Two rules that appear independent may be causally coupled:

```
rule VolumeDiscount : Order {
  applies: { when: order.total > 1_000 }
  compute: fn(order) -> Float = 0.10
}

rule SeasonalDiscount : Product {
  applies: { from: :december_1, until: :january_15 }
  compute: fn(product) -> Float = 0.20
}

-- After SeasonalDiscount, order.total may drop below 1_000
-- VolumeDiscount then no longer applies — causal dependency!
```

The compiler should detect and warn about such causal cycles in rule evaluation.

### § 10.4 Probabilistic Temporal Rules

Rules with uncertain `applies:` predicates — e.g., "apply if the promotion is
likely to be approved by the manager" — connect temporal rules to the
approximate computation model from [igniter-lang-precomp.md](igniter-lang-precomp.md):

```
rule AnticipatedPromotion : Product {
  applies: { when: ~approval_likelihood > 0.8 }   -- probabilistic applies
  compute: fn(product) -> Float = 0.15
  @approximate(confidence: 0.9)
}
```

### § 10.5 Distributed Time

In a distributed system, clocks disagree. `as_of: DateTime.now()` is ambiguous
across nodes. Questions to resolve:

- Which node's clock defines "now" for rule evaluation?
- How does the `await` construct interact with temporal evaluation?
- Can two concurrent workflows evaluate the same order at different `as_of`
  points and produce inconsistent results?

Connection: logical clocks (Lamport 1978) as the temporal axis for distributed
contract evaluation.
