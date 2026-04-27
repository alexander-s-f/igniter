# Igniter Contract Language — Property Models and Algorithm Synthesis

Date: 2026-04-27.
Perspective: programming language theory; knowledge representation; specification-driven synthesis.
Subject: A property-model layer above the contract graph — declare object types and property relationships, derive algorithms automatically; LLM as model author.

*Status: experimental research — theoretical proposal, not a feature track.*
*Follows: [igniter-lang-precomp.md](igniter-lang-precomp.md) — probabilistic pre-computation.*

---

## 1. The Fundamental Problem

In every workflow program, there are two things happening at once:

1. **Stating what the world must look like** for the goal to be achieved
2. **Implementing how to check and produce that world state**

Today these two things are written in the same language, at the same level, mixed together. The result is that the *specification* (what) is invisible — it lives implicitly in the implementation (how). To understand what the code means, you must reconstruct the specification by reading the code.

The proposal: **separate them into distinct levels**. Declare the specification explicitly. Derive the implementation from it.

---

## 2. The Three Levels

### 2.1 Level 0 — Ontology (what objects exist and what properties they have)

```
type Product {
  available: Bool
  stock:     Int where stock >= 0
  price:     Money where price > 0
  category:  Enum[:physical, :digital]
}

type Marketing {
  campaign_active:  Bool
  discount_applied: Bool
  discount_rate:    Float where 0.0 <= discount_rate <= 1.0
}

type Manager {
  approved:         Bool
  approval_limit:   Money
}

type Order {
  status: Enum[:pending, :processing, :complete, :cancelled]
  total:  Money
}
```

This is a typed **ontology**: objects, their properties, and the constraints on property values (refinement types).

### 2.2 Level 1 — Property Model (what relationships exist between properties)

```
model OrderFulfillment {
  goal: order.status = :complete

  requires:
    product.available   = true
    product.stock       > 0
    manager.approved    = true
    order.total         <= manager.approval_limit

  consistency:
    marketing.campaign_active → marketing.discount_applied = true

  derives:
    order.total = product.price * (1.0 - discount_rate_if_any)
}
```

This is a **property specification**: what must be true about the objects for the goal to hold, and what relationships exist between properties. No implementation. No "how".

### 2.3 Level 2 — Algorithm (derived or written)

From the model, the system synthesises:

```
contract FulfillOrder {
  in product:   Product
  in marketing: Marketing
  in manager:   Manager

  // derived from model consistency rule
  guard :discount_consistent {
    when marketing.campaign_active
    then marketing.discount_applied must be true
  }

  // derived from model requires
  guard :fulfillable {
    product.available = true
    product.stock > 0
    manager.approved = true
  }

  // derived from model derives
  compute :effective_price =
    product.price * (1.0 - marketing.discount_rate
                          .if_present(when: marketing.discount_applied))

  compute :within_limit = effective_price <= manager.approval_limit

  // derived from model goal + requires + derives
  compute :status =
    fulfillable && within_limit ? :complete : :pending

  out result = Order { status: status, total: effective_price }
}
```

The algorithm is not written by the programmer — it is **synthesised by the compiler** from the property model. The programmer only writes Level 0 (types) and Level 1 (model). Level 2 is derived.

### 2.4 Level 3 — Execution with Pre-Computation

The synthesised contract is executed using the runtime from the previous report:
- `product.available` is a cheap boolean property check → pre-compute first
- `manager.approval_limit` is a DB lookup → compute only if product is available
- `effective_price` → exact or approximate depending on consumer precision requirement

The four levels connect into a single pipeline: **ontology → model → contract → execution**.

---

## 3. What Synthesis Can and Cannot Do

### 3.1 Automatically Synthesisable

| Pattern | Model declaration | Synthesised form |
|---------|------------------|-----------------|
| Property check | `requires: x.p = true` | `guard :x { x.p = true }` |
| Conditional consistency | `a.p → b.q = true` | `guard` with `when:` |
| Property derivation | `derives: x = f(a, b)` | `compute :x = f(a, b)` |
| Goal from properties | `goal: x.status = :complete` | `compute :status` + `out` |
| Aggregation | `derives: total = sum(items.price)` | `aggregate :total` |
| Conditional goal | `requires: if a.p then b.q` | `branch` node |

### 3.2 Beyond Synthesis — Requires Functions

Some computations cannot be derived from property relationships alone. They require explicit function definitions:

```
// This cannot be synthesised — it is a genuine transformation
fn shipping_cost(product: Product, destination: Address) -> Money = {
  base_rate(destination.zone) * product.weight_kg * urgency_multiplier
}
```

Function definitions are Level 0.5 — between ontology and model. They define how properties are computed, not what must be true of them.

### 3.3 The Synthesis Boundary

```
Declarative region (synthesisable):
  ├── property checks (requires)
  ├── conditional consistency (if P then Q)
  ├── arithmetic derivations (total = price * quantity)
  └── goal conditions (status = :complete)

Computational region (requires fn):
  ├── non-trivial transformations (routing algorithms)
  ├── external system calls (DB queries, HTTP)
  ├── domain-specific calculations (shipping cost formula)
  └── learned models (ML predictions)
```

Hypothesis: **for most business workflows, the declarative region covers ≥70% of nodes**. The computational region is the minority — and it is exactly what today's executor classes implement. The language makes the split explicit.

---

## 4. Formal Foundations (Pointer to Theory Document)

The property model level connects to well-established formal theory. This section maps the constructs; the next document in this series develops the theoretical foundations rigorously.

### 4.1 Situation Calculus (McCarthy, 1963)

The situation calculus formalises how **actions change properties of objects** over time. A "situation" is a snapshot of all property values. Actions transition between situations.

The property model is a restricted situation calculus: the "situation" is the set of current object properties, the "action" is executing the contract, and the "goal" is the target property values.

### 4.2 Description Logics / OWL

The ontology level (Level 0) is a description logic: a typed schema with property constraints and relationship declarations. OWL (Web Ontology Language) is the most widely deployed description logic, used in the semantic web and knowledge graphs.

The property model (Level 1) corresponds to OWL axioms: necessary and sufficient conditions for class membership, property restrictions, consistency constraints.

### 4.3 Hoare Logic

Each synthesised contract corresponds to a Hoare triple:

```
{ precondition(A, B, C) }  contract  { postcondition(X) }
```

The `requires` declarations are the precondition. The `goal` declaration is the postcondition. The synthesis problem is: find a program that transforms the precondition state to the postcondition state.

### 4.4 Refinement Types

Property constraints (`stock >= 0`, `price > 0`) are **refinement types**: types augmented with logical predicates. The LiquidHaskell and Dafny languages use refinement types for specification-driven verification.

In the contract language, refinement types propagate through the contract graph: if `compute :total = sum(items.price)` and `price > 0` for all items, then the compiler can derive `total > 0` statically.

### 4.5 Planning (STRIPS / PDDL)

The synthesis problem — given object properties and a goal property state, find the contract that achieves the goal — is an instance of **automated planning**. PDDL (Planning Domain Definition Language) is the standard formalism.

The critical difference: PDDL planning is sequential (find an action sequence), while contract synthesis is a data-flow graph. The right formalism is **hierarchical task network (HTN) planning** extended to DAG structures.

---

## 5. LLM as Model Author

### 5.1 Why LLMs Work Better at Level 1

LLMs are trained on natural language, which expresses world knowledge primarily as **property relationships**: "an order is complete when the product is available, the manager has approved, and the payment has cleared." This is Level 1 vocabulary, not implementation code.

When an LLM generates Level 3 code directly, it must:
- Invent implementation details not in the training data
- Make implicit assumptions about data structures
- Produce unverifiable output

When an LLM generates Level 1 models, it:
- Expresses what it actually knows (property relationships)
- Produces formally verifiable output
- Stays within its competence boundary

### 5.2 The LLM-Compiler Contract

```
LLM responsibility:  express property relationships correctly
                     (goal, requires, consistency, derives)

Compiler responsibility: synthesise a correct contract
                         verify the model is consistent
                         reject contradictory or incomplete models

Runtime responsibility: execute with pre-computation,
                        backward precision propagation
```

This is a **division of labour** where each party does what it is good at. The LLM contributes knowledge. The compiler contributes correctness. The runtime contributes efficiency.

### 5.3 Verifiable LLM Output

The critical property: a Level 1 model is **formally checkable** before execution.

The compiler can verify:
- **Consistency**: no property is required to be both true and false
- **Completeness**: every path to the goal has all necessary properties declared
- **Termination**: the synthesis terminates (DAG property model → guaranteed)
- **Reachability**: the goal is reachable from the declared inputs

If the LLM produces an inconsistent model, the compiler rejects it with a specific error — not a runtime crash, not wrong output. This is **LLM output verification at the semantic level**.

### 5.4 Iterative Model Refinement

The LLM-compiler loop:

```
1. LLM generates Level 1 model from natural language description
2. Compiler checks consistency and completeness
3. If errors: compiler returns structured feedback to LLM
4. LLM refines the model
5. Repeat until the model is accepted
6. Compiler synthesises the contract
7. Contract executes with full provenance and introspection
```

This loop has a formal stopping condition (compiler acceptance), unlike current LLM code generation which has no formal stopping condition.

---

## 6. Information Density at the Model Level

### 6.1 SIR at Each Level

Extending the Semantic Information Ratio metric from the first document:

| Level | Description | Estimated SIR |
|-------|-------------|---------------|
| Ruby DSL + executor classes | Current state | 1.0× (baseline) |
| Contract-native (Level 2) | Previous documents | ~2× |
| Property model (Level 1) | This document | ~4–6× (hypothesis) |

The model level is denser because:
- No implementation details
- No structural boilerplate
- Semantic content is maximally concentrated
- The same model generates multiple contracts for different execution strategies

### 6.2 The Kolmogorov Argument

A property model is the **minimum description** of a workflow's intent. You cannot describe the intent of "order fulfillment" in fewer concepts than: the objects involved, what properties they must have, and what the goal is. Any additional information is implementation detail.

This is the information-theoretic lower bound on program description: the property model approaches the Minimum Description Length (MDL) of the workflow specification.

---

## 7. Architecture of the Full System

The complete four-level architecture with the new layer:

```
┌─────────────────────────────────────────────────────┐
│  Level 0: Ontology                                  │
│  Object types + property constraints + fn defs      │
│  Author: developer (or LLM)                         │
│  Tool: type checker + constraint validator          │
└────────────────────────┬────────────────────────────┘
                         │ declares
┌────────────────────────▼────────────────────────────┐
│  Level 1: Property Model                            │
│  goal + requires + consistency + derives            │
│  Author: developer OR LLM                           │
│  Tool: model checker (consistency, completeness)    │
└────────────────────────┬────────────────────────────┘
                         │ synthesises
┌────────────────────────▼────────────────────────────┐
│  Level 2: Contract Graph                            │
│  input/compute/guard/branch/output nodes            │
│  Author: synthesiser (or developer for fn nodes)    │
│  Tool: GraphCompiler + type inference               │
└────────────────────────┬────────────────────────────┘
                         │ executes via
┌────────────────────────▼────────────────────────────┐
│  Level 3: Runtime with Pre-Computation              │
│  Two-level evaluation, backward precision prop.     │
│  Author: runtime (automatic)                        │
│  Tool: Resolver + approximate evaluator             │
└─────────────────────────────────────────────────────┘
```

---

## 8. Open Questions

### 8.1 Synthesis Completeness

For which classes of property models does a correct contract always exist? When does the synthesis fail, and what feedback should the compiler give?

Formal question: **for what fragment of first-order logic over property relationships is synthesis decidable?**

Preliminary answer (from planning theory): if the property model is monotone (adding facts never removes goals), synthesis is decidable in polynomial time. Non-monotone models (e.g., cancellation, revocation) require more powerful machinery.

### 8.2 Model Ambiguity

A property model may be achievable by multiple contracts. Which one should the synthesiser choose? Selection criteria:
- Minimum cost (fewest expensive nodes)
- Maximum parallelism (most concurrent nodes)
- Most robust to missing data (most graceful degradation)

This is a **synthesis optimisation problem** — not just "find a contract" but "find the best contract".

### 8.3 Property Evolution

When the ontology changes (e.g., `Manager` gains a `delegation_level` property), which property models are affected? Which synthesised contracts need to be regenerated?

This is **change impact analysis** at the model level — formally tractable because the model is explicit.

### 8.4 Probabilistic Property Models

Combining with the pre-computation document: what if properties are probabilistic?

```
model FraudDetection {
  goal: transaction.flagged = true
  requires:
    location.anomaly_score > 0.8    // probabilistic property
    amount.deviation > 3.0          // statistical property
    velocity.rate > threshold       // approximate
}
```

A probabilistic property model synthesises a contract with approximate nodes, using the pre-computation mechanism from the previous document. This unifies both research threads.

---

## Summary

The property model layer adds a declaration-first level above the contract graph:
- **Ontology** (Level 0): what objects and properties exist
- **Property model** (Level 1): what relationships between properties achieve the goal
- **Contract** (Level 2): synthesised from the model
- **Execution** (Level 3): runtime with pre-computation

The model level is the natural interface for LLMs: it expresses world knowledge as property relationships — exactly what LLMs are trained on — in a form that is formally verifiable and automatically compilable.

The information density at the model level approaches the theoretical MDL lower bound for workflow specification: no redundant implementation details, only semantic content.

The key open question is the synthesis boundary: for which property models is automatic contract synthesis decidable and practically efficient? The next document in this series addresses this through rigorous theoretical foundations — situation calculus, description logics, Hoare logic, and planning theory.
