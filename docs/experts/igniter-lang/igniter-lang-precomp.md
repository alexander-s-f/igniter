# Igniter Contract Language — Probabilistic Pre-Computation

Date: 2026-04-27.
Perspective: programming language theory; approximate computing; decision-directed evaluation.
Subject: A two-level evaluation model where every computation node has a cheap probabilistic pre-computation mode, and the runtime determines the minimum required precision from downstream consumer needs.

*Status: experimental research — theoretical proposal, not a feature track.*
*Follows: [igniter-lang-theory.md](igniter-lang-theory.md) — theoretical foundations.*

---

## 1. The Core Idea

Traditional computation collapses the distinction between "knowing the answer" and "needing to compute it fully." Every node in a computation graph either evaluates completely or not at all.

The proposal is a third mode:

> **Pre-computation**: produce a cheap probabilistic approximation of a node's
> result — a distribution, confidence interval, or statistical summary — without
> executing the full computation. Commit to full computation only if the
> approximation is insufficient for the downstream decision.

For a billion-parameter tensor `A`:

```
Traditional:  X = A + B*C   →  load A (expensive), compute (expensive), return X
Pre-compute:  X̃ ≈ Ã + B*C  →  use statistical description of A, return (X̃, confidence, interval)
              escalate to exact only if consumer needs precision beyond interval
```

The key shift: **the consumer defines required precision, not the producer**.

---

## 2. Formal Structure

### 2.1 Two-Level Domains

Every computable value lives in two domains simultaneously:

```
Exact domain    V   : the actual value (Real, Tensor, Record, ...)
Abstract domain Ṽ   : a description of V (distribution, interval, shape, ...)
```

The abstract domain is a **sound approximation**: if the exact value is `v`, then `v ∈ γ(ṽ)` where `γ` is the concretisation function. The approximation is never wrong — it is only potentially imprecise.

For common abstract domains:

| Abstract domain | Representation | Concretisation |
|-----------------|---------------|----------------|
| Interval | `[lo, hi]` | `{x : lo ≤ x ≤ hi}` |
| Gaussian | `(μ, σ)` | `N(μ, σ)` — infinite set, finite description |
| Confidence interval | `(estimate, ε, α)` | with probability `α`, `|X − estimate| ≤ ε` |
| Shape (tensors) | `[d₁, d₂, ..., dₙ]` | all tensors of that shape |
| Sign | `{+, −, 0}` | all numbers of that sign |

### 2.2 Lifted Operations

Every function `f : V → W` has a corresponding **lifted** version `f̃ : Ṽ → W̃` that operates on descriptions:

```
f    :  V  →  W       (exact)
f̃   :  Ṽ  →  W̃      (approximate)
```

Lifting methods, in order of increasing cost and precision:

| Method | How | When to use |
|--------|-----|-------------|
| **Shape inference** | Algebraic rules on dimensions | Tensor operations, always free |
| **Interval arithmetic** | `[a,b] op [c,d]` rules | Monotone functions, symbolic |
| **Delta method** | Linearise `f` around `μ_A` | Smooth `f`, cheap |
| **Monte Carlo** | Sample `Ã` k times, run `f` on each | Always applicable |
| **Learned surrogate** | A cheap model approximating `f` | `f` called very frequently |

The lifting does not require the full value of `A` — only its description `Ã`. For a billion-parameter tensor, `Ã` might be its mean vector and covariance — computed once and reused across many pre-computations.

### 2.3 Decision-Directed Evaluation

The critical insight: **downstream consumers declare their precision requirement, not the producer**.

A branch node that compares `X > threshold` only needs to know whether the interval `[X_lo, X_hi]` is entirely above, entirely below, or straddles the threshold:

```
Case 1:  X_hi < threshold  →  branch outcome is certain (False), no exact needed
Case 2:  X_lo > threshold  →  branch outcome is certain (True), no exact needed
Case 3:  threshold ∈ [X_lo, X_hi]  →  uncertain, escalate to exact X
```

This is **decision-directed lazy evaluation**: the decision structure of the computation graph determines the minimum precision needed at every node. Only nodes whose approximation is insufficient for downstream decisions get computed exactly.

---

## 3. Two-Level Contract Nodes

### 3.1 Node Declaration

In the contract-native language, a compute node declares both levels:

```
compute :total_risk {
  approximate: portfolio.sample(1_000) |> estimate_risk(rates)
               @confidence(0.95) @method(:monte_carlo)

  exact: portfolio |> calculate_exact_risk(rates)
}

compute :revenue {
  approximate: transactions |> statistical_summary |> estimate_revenue(fx_rates)
               @confidence(0.90) @tolerance(0.01)   // within 1% of exact

  exact: transactions |> calculate_exact_revenue(fx_rates)
}
```

The `approximate` level is optional. Nodes without it fall back to exact computation.

### 3.2 Consumer Precision Declarations

Downstream nodes declare what precision they need:

```
branch decision {
  on total_risk > 1_000_000 => TriggerAlert { risk: total_risk @exact }
  default                   => NoAction     {}
}

compute :report_line = format_revenue(revenue @tolerance(0.05))
// report only needs 5% tolerance → approximate is always sufficient
```

### 3.3 Runtime Resolution Strategy

```
For each node X:
  1. Collect precision requirements from all direct consumers
  2. If any consumer requires @exact → run exact computation
  3. Otherwise → run approximate:
       a. Execute approximate level → get (X̃, confidence, interval)
       b. For each consumer decision using X̃:
            - Can the decision be made from interval? → yes: proceed
            - Cannot decide? → escalate: run exact X, invalidate X̃
  4. Return the minimum-cost sufficient result
```

---

## 4. Graph-Level Implications

### 4.1 Approximation Propagation

Abstract interpretation propagates through the graph automatically. If `X̃` is known and `Y = g(X)`, then `Ỹ = g̃(X̃)` can be computed without `X`. This means:

```
contract RiskPipeline {
  in portfolio: Portfolio        // Ã = shape + sample statistics
  in rates:     Rates            // exact (small)

  compute :raw_exposure  = exposure_matrix(portfolio, rates)
                           // Ã_exposure = shape [N, M], bounds [0, rate_max]

  compute :total_risk    = sum(raw_exposure)
                           // Ã_total = (sum of bounds) = [0, N*M*rate_max]
                           // plus: sample 1K rows → tighter estimate

  compute :risk_category = classify(total_risk)
                           // can decide: is total_risk > 1M? probably yes/no

  out decision = risk_category
}
```

If the approximation at `total_risk` is sufficient to classify, neither `raw_exposure` nor `total_risk` need to be computed exactly. The decision cascades from the output back to the inputs: **backward propagation of precision requirements**.

### 4.2 Pruning Branches Early

In a contract with `branch`, the pre-computation level can resolve which branch is taken before any branch-specific computation runs:

```
branch routing {
  on estimated_revenue(summary) > threshold => HighValuePath { revenue: revenue }
  default                                   => StandardPath  { }
}
```

If `estimated_revenue(summary) >> threshold` with confidence 0.99, the `HighValuePath` is selected. The `revenue` node is then resolved lazily only if the `HighValuePath` contract actually uses it — and only to the precision it needs.

---

## 5. Connection to Theoretical Foundations

This proposal connects to all five theoretical pillars from the previous report:

### 5.1 Abstract Interpretation (Cousot 1977)

The probabilistic pre-computation IS abstract interpretation with a probabilistic abstract domain. Cousot's framework provides:

- **Soundness guarantee**: the abstract result is always a valid over-approximation
- **Monotonicity**: refining the abstract value can only improve precision
- **Convergence**: for DAG contracts, pre-computation always terminates (no fixpoint needed)

The probabilistic domain `(μ, σ, α)` is a specific instance of Cousot's abstract domain framework, well-studied under the name **probabilistic abstract interpretation** (Monniaux 2000).

### 5.2 Attribute Grammars (Knuth 1968)

The two-level model maps directly onto the attribute grammar structure:

- **Exact attributes**: standard synthesized/inherited attributes (computed top-down or bottom-up)
- **Abstract attributes**: a second set of attributes carrying approximations
- **Evaluation strategy**: abstract attributes are computed first; exact attributes are computed only when the abstract is insufficient

This is a **stratified attribute grammar**: one stratum computes abstract attributes, a second stratum computes exact attributes conditioned on the first.

### 5.3 CCP (Saraswat 1989)

Pre-computation adds a new kind of `tell` to the constraint store:

- `tell_exact(X = v)`: add exact constraint (standard CCP)
- `tell_approx(X ∈ [lo, hi], α)`: add probabilistic constraint

`ask` operations on decision nodes check both kinds:
- If `ask(X > threshold)` is decidable from the approximate constraint → proceed
- If not → block until exact constraint is available

This is **probabilistic concurrent constraint programming** — a known extension of CCP (Gupta et al. 1994).

### 5.4 Bayesian Networks

The probabilistic pre-computation level IS Bayesian inference over the contract graph. If inputs have prior distributions, the abstract computation propagates those distributions forward through the graph, producing a posterior over the output.

The two-level model is the pragmatic version: forward-pass the distributions cheaply (the "pre-computation"), and only commit to exact inference where the posterior is too uncertain for the required decision.

### 5.5 Datalog (Decidability)

The abstract computation level is itself a Datalog program over the abstract domain — decidable and PTIME. The exact computation level is also Datalog (for the DAG core). Both levels terminate. The escalation protocol terminates because:
1. Pre-computation terminates (Datalog)
2. Escalation to exact is monotone (once exact, stays exact)
3. DAG structure guarantees no cycles

---

## 6. What Exists and What Is Novel

### 6.1 Existing Work

| System / Field | What it does | Relation to this proposal |
|----------------|-------------|--------------------------|
| Haskell lazy evaluation | Defers computation until needed | Defers but computes exactly when needed |
| JAX / TensorFlow tracing | Shape inference before execution | Abstract domain = shapes only |
| Approximate computing (Carbin 2012+) | Permit approximate results | Focuses on hardware, not language semantics |
| Probabilistic programming (Stan, Pyro) | Work with distributions | Full inference, not a pre-computation layer |
| Abstract interpretation (Cousot 1977) | Analyse programs without running them | Static analysis tool, not a runtime strategy |
| Speculative execution (CPUs) | Execute before knowing if needed | Hardware level, not semantics level |

### 6.2 What Is Novel Here

The combination has not been built:

> A contract-native language where:
> 1. Every node declares both an exact and an approximate computation
> 2. Downstream consumers declare their required precision
> 3. The runtime propagates precision requirements backward through the graph
> 4. Only nodes whose approximation is insufficient for downstream decisions are computed exactly
> 5. The entire mechanism is part of the language semantics, not a separate optimisation layer

The key novelty is **backward propagation of precision requirements through a computation graph as a first-class language feature**. Existing systems either do this statically (abstract interpretation, type inference) or not at all. No existing language expresses this as a runtime contract between producer and consumer.

---

## 7. The Lifting Problem (Open Research)

The hardest theoretical question: **how do you lift arbitrary computations to their approximations?**

### 7.1 Lifting Taxonomy

Not all functions can be lifted cheaply. A taxonomy by lifting difficulty:

| Function class | Lifting method | Cost | Soundness |
|---------------|---------------|------|-----------|
| Linear (`f(x) = ax + b`) | Exact interval propagation | Free | Exact |
| Monotone | Interval arithmetic | Free | Sound |
| Smooth, differentiable | Delta method (1st-order Taylor) | Low | Approximate |
| Lipschitz continuous | Interval with Lipschitz bound | Low | Sound |
| Black box | Monte Carlo sampling | Medium | Statistical |
| Discontinuous, non-smooth | Monte Carlo or give up | High | Statistical |

### 7.2 The Auto-Lifting Hypothesis

Hypothesis: for a significant fraction of real-world workflow computations (financial, logistics, compliance), the functions are smooth or monotone, making automatic sound lifting feasible.

Evidence for the hypothesis:
- Aggregations (`sum`, `avg`, `max`) are linear/monotone → exact interval lifting
- Business rules (`price * quantity * rate`) are linear → exact lifting
- Classification thresholds (`risk > 1M`) need only bounds, not distributions
- The genuinely non-smooth cases (LLM calls, external API calls) are naturally approximate anyway

### 7.3 User-Declared Lifting

For functions that cannot be lifted automatically, the programmer declares the lifting:

```
fn calculate_risk(portfolio: Portfolio, rates: Rates) -> Money {
  // exact implementation
  portfolio.reduce { |acc, pos| acc + pos.value * rates[pos.currency] }
}

fn ~calculate_risk(portfolio: ~Portfolio, rates: Rates) -> ~Money {
  // approximate lifting: sample 1000 positions, scale
  portfolio.sample(1_000).reduce { |acc, pos|
    acc + pos.value * rates[pos.currency]
  } * (portfolio.size / 1_000.0)
  @confidence(0.95) @method(:sampling)
}
```

The `~` prefix denotes the approximate level. The language enforces the soundness contract: if the user declares a lifting, the compiler checks (statically or at test time) that it is a valid approximation.

---

## 8. Cost Model

The pre-computation layer introduces a meta-level cost model. Every node has:

```
Cost(X, level) = { approx_cost(X), exact_cost(X) }
Value(X, decision) = precision needed to resolve decision
```

The runtime optimises:

```
minimise Σ cost(Xᵢ, levelᵢ)
subject to: for each downstream decision D,
            approximation of its inputs is sufficient to resolve D
```

This is a **resource-constrained computation planning** problem — NP-hard in general, but tractable for DAG contracts with bounded decision trees (the typical case).

In practice, the heuristic is:
1. Try approximate for all nodes
2. Walk the decision tree; mark nodes that need escalation
3. Compute exactly only the marked nodes

This gives the minimum-cost execution plan in a single forward + backward pass over the graph.

---

## 9. Research Agenda

### Priority 1 — Probabilistic Abstract Domain (2–3 months)

Define the formal abstract domain:
- Which distribution families to support (Gaussian, uniform, empirical)
- Soundness proof for standard lifted operations
- Integration with the contract formal model from the theory document

### Priority 2 — Lifting Calculus (3–4 months)

Define rules for automatic lifting:
- Complete lifting rules for linear/monotone operations
- Delta-method rules for smooth functions
- Monte Carlo as universal fallback with statistical soundness guarantees

### Priority 3 — Backward Precision Propagation (2–3 months)

Formalise the backward pass:
- How consumer precision requirements propagate through the graph
- Prove the propagation terminates and is sound
- Define the escalation protocol precisely

### Priority 4 — Language Integration (4–6 months)

Design the concrete syntax for two-level nodes in the contract language:
- `approximate:` / `exact:` node declarations
- `@tolerance` / `@confidence` consumer annotations
- `~fn` syntax for user-declared liftings
- Type system extensions for approximate values

### Priority 5 — Empirical Validation (ongoing)

Build a benchmark:
- Select 10 workflow contracts with expensive computation nodes
- Implement approximate levels using Monte Carlo
- Measure: cost reduction, precision of approximation, decision accuracy
- Target: ≥10× cost reduction for non-escalating decisions with ≥0.95 confidence

---

## Summary

The pre-computation model adds a vertical dimension to the contract graph:

```
Level 0 (Pre-computation):  cheap, approximate, probabilistic
                            ↓ if insufficient for decision
Level 1 (Exact):            expensive, precise, deterministic
```

The direction of evaluation is **backwards from decisions to data**: consumer requirements determine minimum precision, which propagates through the graph, which determines what must be computed exactly and what can stay approximate.

This is abstract interpretation (Cousot) with probabilistic domains, run as a runtime optimisation strategy rather than a static analysis. It fits the contract model naturally because the dependency graph already makes the consumer-producer relationships explicit — the backward propagation of precision requirements is just another traversal of the same graph.

The novel contribution is making this a first-class language feature: declarative approximate levels, typed confidence intervals, and precision-propagating runtime — not a bolted-on optimisation, but part of the language semantics from the ground up.
