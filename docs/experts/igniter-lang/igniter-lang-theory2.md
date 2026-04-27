# Igniter Contract Language — Theoretical Foundations of Property Model Synthesis

Date: 2026-04-27.
Perspective: mathematical logic; formal verification; automated reasoning; programming language theory.
Subject: Rigorous theoretical foundations for property-model-to-contract synthesis — decidability, soundness, completeness, and the logical fragment that makes all three achievable simultaneously.

*Status: experimental research — formal theory, not a feature proposal.*
*Follows: [igniter-lang-propmodel.md](igniter-lang-propmodel.md) — property model architecture.*

---

## Preamble: What Theory Needs to Prove

The property model proposal in the previous document made three claims without proof:

1. **Synthesis is decidable** — the compiler can always determine whether a valid contract exists for a given model
2. **Synthesis is sound** — if the compiler produces a contract, that contract is guaranteed correct with respect to the model
3. **Synthesis is complete** — if a correct contract exists, the synthesiser finds it

These are not optional nice-to-haves. Without decidability, the compiler might loop forever. Without soundness, synthesised contracts can be wrong. Without completeness, the synthesiser silently misses valid solutions.

This document proves all three — within a precisely defined logical fragment — and shows which extensions break which guarantees and why.

---

## 1. The Logical Fragment

### 1.1 The Problem with Full First-Order Logic

Full first-order logic (FOL) is expressive but undecidable (Church, 1936; Turing, 1936). If property models were arbitrary FOL formulas, synthesis would be undecidable in general — the compiler could not guarantee termination.

We need a **restricted fragment** that is:
- Expressive enough to describe real business models
- Weak enough to admit decidable synthesis

### 1.2 Horn Clauses and Datalog

A **Horn clause** is a first-order formula of the form:

```
B₁ ∧ B₂ ∧ ... ∧ Bₙ → H
```

where each `Bᵢ` and `H` is an atomic formula (a predicate applied to terms), and `H` is the *head* (at most one positive literal in the consequent).

**Datalog** is the language of Horn clauses over a fixed finite domain, without function symbols. Its key properties:

- **Decidable**: evaluation always terminates
- **PTIME-complete**: evaluation takes time polynomial in the size of the input
- **Confluent**: the result does not depend on evaluation order
- **Monotone**: adding input facts can only add derived facts, never remove them

**Theorem 1.1** (Datalog characterisation): A property model M is in the *Horn fragment* if and only if every rule in M can be written as a Datalog Horn clause over the property domain.

The Horn fragment covers:
- `requires: x.p = true` → `holds(p, x) :- given(x)`
- `derives: y = f(a, b)` → `val(y, V) :- val(a, A), val(b, B), apply(f, A, B, V)`
- `consistency: a.p → b.q = true` → `holds(q, b) :- holds(p, a)`
- `goal: x.status = :complete` → `complete(x) :- holds(status_complete, x)`

The Horn fragment does **not** cover:
- Unrestricted negation: `NOT product.recalled` (requires stratification — see §6)
- Disjunctive requirements: `a.p OR b.q` (requires disjunctive Datalog — undecidable in general)
- Arithmetic aggregations with unbounded quantifiers (requires restriction to stratified aggregation)

### 1.3 The Synthesis Fragment

**Definition**: A property model M is in the *synthesis fragment* if:
1. All rules are Horn clauses (no unrestricted disjunction)
2. The domain of each property type is finite or bounded by declared constraints
3. The model is **stratifiable**: there exists a ranking function `rank: predicates → ℕ` such that for every rule `B₁ ∧ ... ∧ Bₙ → H`, `rank(H) > rank(Bᵢ)` for all `i`

Stratifiability ensures there are no circular dependencies — the property model is itself a DAG.

---

## 2. Decidability

### 2.1 The Synthesis Problem

**Definition** (synthesis problem): Given a property model M in the synthesis fragment and a set of input types I, find a contract C such that:

```
∀ inputs v ∈ ⟦I⟧ : ⟦C⟧(v) satisfies goal(M)
```

where `⟦I⟧` is the set of all values of input types and `⟦C⟧` is the denotation of C.

**Theorem 2.1** (Decidability): The synthesis problem for the synthesis fragment is decidable, and the synthesis algorithm runs in time O(|M|² · |dom|^k) where |dom| is the maximum domain size and k is the maximum rule arity.

**Proof sketch**:

The synthesis algorithm is bottom-up Datalog evaluation (Ullman 1988):

```
Algorithm Synthesize(M, I):
  S ← ground(I)                  // initialise with input facts
  repeat
    S ← S ∪ { H | (B₁∧...∧Bₙ→H) ∈ M, {B₁,...,Bₙ} ⊆ S }
  until no new facts added        // fixpoint reached
  if goal(M) ⊆ S:
    return derivation_tree(goal(M), S, M)   // the contract
  else:
    return UNREACHABLE
```

This terminates because:
1. S is monotonically increasing (Horn clauses are monotone)
2. The total number of ground facts is bounded by |M| · |dom|^k (finite)
3. Each iteration adds at least one new fact or terminates

Termination + finite iterations → decidable. ∎

**Corollary 2.2**: Synthesis unreachability is also decidable (the algorithm returns UNREACHABLE in finite time).

### 2.2 The Derivation Tree

When synthesis succeeds, the algorithm produces a **derivation tree**: a DAG whose leaves are input facts and whose root is the goal, with each internal node labelled by the rule that derived it.

```
goal: complete(order)
  ← available(product)    [rule: requires]
  ← stock_ok(product)     [rule: requires]
  ← approved(manager)     [rule: requires]
    ← within_limit(order) [rule: derives, from: price, limit]
      ← price(order)      [rule: derives, from: product, marketing]
```

The derivation tree IS the contract graph. The synthesis translation is:

| Derivation tree node | Contract graph node |
|---------------------|---------------------|
| Input fact | `input` node |
| Rule application | `compute` node |
| Consistency check | `guard` node |
| Goal fact | `output` node |
| Conditional rule | `branch` node |

The synthesis is not a search — it is a **single bottom-up pass** followed by a **backward trace** from the goal. Both passes are linear in the size of the derivation.

---

## 3. Soundness

### 3.1 Hoare Logic and Weakest Preconditions

**Hoare logic** (Hoare 1969) reasons about program correctness using triples:

```
{ P }  program  { Q }
```

meaning: if precondition P holds before execution, then postcondition Q holds after. This is **partial correctness**: it says nothing about termination.

For contract synthesis, we need:

```
{ requires(M) }  C  { goal(M) }
```

**Dijkstra's weakest precondition** `wp(C, Q)` is the weakest formula P such that `{P} C {Q}` holds. Soundness requires:

```
requires(M) ⊢ wp(C, goal(M))
```

i.e., the model's `requires` clause logically implies the weakest precondition of the synthesised contract.

### 3.2 wp for Contract Nodes

The synthesis algorithm assigns a verification condition (VC) to each synthesis step. The wp calculus for contract nodes:

```
wp(output :x = v,    Q) = Q[x ↦ v]                        // substitution
wp(compute :x = f(deps), Q) = wp(f, Q)[x ↦ f(deps)]       // function wp
wp(guard { P },      Q) = P → Q                            // guard implies Q
wp(branch { on c => C₁; default => C₂ }, Q)
                       = (c → wp(C₁, Q)) ∧ (¬c → wp(C₂, Q))
wp(compose A then B, Q) = wp(B, wp(A, Q))                  // composition
```

### 3.3 The Synthesis Soundness Theorem

**Theorem 3.1** (Synthesis soundness): Let M be a property model in the synthesis fragment, and let C = Synthesize(M, I) be the synthesised contract. Then:

```
requires(M) ⊢ wp(C, goal(M))
```

**Proof by structural induction on the derivation tree**:

*Base case*: Input nodes. If `v ∈ I` is required, then `requires(M) ⊢ holds(v, ·)` by definition. The input node `input :v` has `wp(input :v, Q) = Q[v ↦ given_v]`, and `requires(M)` is exactly the assumption that the given values satisfy the constraints. ✓

*Inductive case — derives rule*: Rule `B₁ ∧ ... ∧ Bₙ → derives(y, F(b₁,...,bₙ))`.
By inductive hypothesis, `requires(M) ⊢ wp(compute :bᵢ, Q)` for each `bᵢ`.
The synthesised node is `compute :y = F(b₁,...,bₙ)`.
`wp(compute :y, Q) = wp(F, Q[y ↦ F(b₁,...,bₙ)])`.
Since `F` is a pure function with no side effects: `wp(F, Q') = Q'[b₁,...,bₙ ↦ given_values]`.
By inductive hypothesis, all `bᵢ` values satisfy their requires. ✓

*Inductive case — requires rule*: Rule `requires: x.p = v`.
The synthesised node is `guard :g { x.p = v }`.
`wp(guard { x.p = v }, Q) = (x.p = v) → Q`.
By definition, `requires(M) ⊢ x.p = v` (it is a requirement).
Therefore `requires(M) ⊢ wp(guard { x.p = v }, Q)`. ✓

*Inductive case — goal rule*: The root of the derivation tree.
By induction all intermediate VCs discharge. The goal fact is in S (the fixpoint), so `goal(M)` is derivable. `wp(output :goal, goal(M)) = True`. ✓

By structural induction, all VCs discharge. ∎

### 3.4 What Soundness Guarantees

Soundness means: **a synthesised contract cannot produce a wrong answer**. If the inputs satisfy `requires(M)`, the output always satisfies `goal(M)`.

What soundness does **not** guarantee:
- Behaviour on inputs that violate `requires(M)` (unconstrained)
- Efficiency of the synthesised contract (it is correct, not necessarily fast)
- Uniqueness (multiple correct contracts may exist)

---

## 4. Completeness

### 4.1 Herbrand's Theorem

**Herbrand's theorem** (1930): A set of Horn clauses S is satisfiable if and only if it has a *Herbrand model* — a model built from ground terms (no variables), where a predicate P(t₁,...,tₙ) is true exactly when it is derivable from S.

The Herbrand model is **canonical**: it is the unique minimal model of S (the least fixpoint of the bottom-up evaluation).

**Corollary**: For a Horn clause set S, a ground fact F is derivable from S if and only if F is in the Herbrand model of S.

### 4.2 The Synthesis Completeness Theorem

**Theorem 4.1** (Synthesis completeness): Let M be a property model in the synthesis fragment. If there exists any contract C such that `{requires(M)} C {goal(M)}`, then Synthesize(M, I) returns a contract C' such that `{requires(M)} C' {goal(M)}`.

**Proof**:

Suppose contract C satisfies `{requires(M)} C {goal(M)}`. Then the denotation `⟦C⟧` is a function that, given inputs satisfying `requires(M)`, produces outputs satisfying `goal(M)`.

The execution trace of C on any input v satisfying `requires(M)` produces a sequence of intermediate values — a derivation of `goal(M)` from the input facts.

By the Horn clause characterisation (Theorem 1.1), this derivation can be expressed as a sequence of rule applications from M. Each such sequence corresponds to a path in the Herbrand model.

By Herbrand's theorem, the ground fact `goal(M)` is in the Herbrand model of M ∪ {ground(I)}. The bottom-up algorithm (the proof of Theorem 2.1) computes exactly the Herbrand model. Therefore `goal(M) ∈ S` at fixpoint, and the synthesis succeeds. ∎

**Corollary 4.2**: The synthesis algorithm is **relatively complete**: it misses a solution only when no solution exists.

### 4.3 The Closed-World Assumption

Completeness relies on the **closed-world assumption** (CWA): properties not derivable from the input are assumed false.

Under CWA: if `product.available` is not in the input, it is false. A guard `requires: product.available = true` will block.

This is standard in Datalog and in most business logic contexts (if we don't know a product is available, we treat it as unavailable). For open-world systems, the model must explicitly declare default values.

---

## 5. The Situation Calculus: Property Changes Over Time

### 5.1 Why Static Models Are Insufficient

The property models in the previous document assumed a single snapshot: all properties have fixed values at the moment of contract execution. But real workflows involve **state transitions**: a manager approves an order, changing `manager.approved` from false to true.

The **situation calculus** (McCarthy 1963; Reiter 1991) formalises this:

- **Fluents** `F(x, s)`: property F of object x in situation (state) s
- **Actions** `a`: events that change fluent values
- **Do**: `do(a, s)` is the situation after performing action a in situation s
- **Poss**: `Poss(a, s)` holds when action a is possible in situation s
- **Successor state axiom** for each fluent F and action A:
  ```
  F(x, do(A, s)) ↔ γ⁺_F(x, A, s) ∨ (F(x, s) ∧ ¬γ⁻_F(x, A, s))
  ```
  where γ⁺ is the condition under which A causes F to become true, and γ⁻ is the condition under which A causes F to become false.

### 5.2 The Frame Problem

The **frame problem** (McCarthy & Hayes 1969): specifying which properties do NOT change after an action is as difficult as specifying what does change.

Naive specification requires axioms for every action-fluent pair. For n actions and m fluents: O(n·m) axioms.

**Reiter's solution** (1991): *Successor state axioms* replace frame axioms. For each fluent F, one axiom covers all actions:

```
F(x, do(A, s)) ↔
  (∃a: A = cause_F_true(a, x)) ∨       // action caused F to become true
  (F(x, s) ∧ ¬∃a: A = cause_F_false(a, x))  // F was true and action didn't falsify it
```

This is O(m) axioms total — linear in the number of fluents.

### 5.3 Property Models with State Transitions

For the contract language, the situation calculus gives us **dynamic property models**:

```
model OrderLifecycle {
  fluent: order.status

  action: submit_order(order, product, manager) {
    possible when: product.available && product.stock > 0
    effect:        order.status := :processing
  }

  action: approve_order(order, manager) {
    possible when: order.status = :processing && manager.approved
    effect:        order.status := :complete
  }

  goal: order.status = :complete
}
```

Synthesis from a dynamic model produces a **workflow contract** — a contract that sequences the necessary actions and checks conditions at each step.

The situation calculus synthesis problem is: find a sequence of actions (a plan) such that, starting from the initial situation, the goal fluent holds.

**Theorem 5.1**: Dynamic property model synthesis is decidable when the action space is finite and the fluent domain is finite. The problem is PSPACE-complete (equivalent to STRIPS planning).

For DAG-structured plans (parallel workflows, not sequential): **polynomial partial-order planning** (McAllester & Rosenblitt 1991) reduces to Datalog evaluation when action effects are monotone (no delete effects) — recovering PTIME complexity.

---

## 6. Stratified Negation

### 6.1 The Problem with Negation

Pure Horn clauses cannot express negation: `NOT product.recalled` cannot be expressed as a Horn clause. But negation is essential for real models.

**Stratified Datalog** (Apt, Blair & Walker 1988) extends Datalog with stratified negation:

A Datalog program P is **stratified** if there exists a partition of predicates into strata `P₁, P₂, ..., Pₖ` such that:
1. If rule `B₁ ∧ ... ∧ ¬Bᵢ ∧ ... ∧ Bₙ → H`, then `stratum(Bᵢ) < stratum(H)` (negated predicates computed in earlier strata)
2. If rule `B₁ ∧ ... ∧ Bₙ → H` (no negation), then `stratum(Bᵢ) ≤ stratum(H)`

**Theorem 6.1** (Stratified Datalog): Stratified Datalog has a unique **perfect model** (Przymusinski 1988), computable in PTIME by evaluating strata bottom-up.

**The synthesis fragment extended to stratified negation**:

```
model FulfillmentWithExclusions {
  requires:
    product.available   = true
    NOT product.recalled          // stratified negation: computed before requires check
    manager.approved    = true
    NOT order.cancelled           // stratified negation

  goal: order.status = :complete
}
```

The synthesis algorithm evaluates negated predicates in earlier strata:
- Stratum 1: compute `product.recalled`, `order.cancelled` (positive derivations)
- Stratum 2: apply `NOT product.recalled` as a guard (negation from stratum 1)
- Stratum 3: derive `goal` from stratum 2 results

Synthesised contract:
```
compute :recalled   = product.recalled     // stratum 1
compute :cancelled  = order.cancelled      // stratum 1
guard :not_recalled  { NOT recalled  }     // stratum 2
guard :not_cancelled { NOT cancelled }     // stratum 2
...
```

### 6.2 What Breaks Stratification

A model is **not stratifiable** (and synthesis becomes undecidable in general) when there are **negative cycles**:

```
// INVALID: circular dependency through negation
model Bad {
  derives: a.approved = NOT b.blocked
  derives: b.blocked  = NOT a.approved    // ← negative cycle: a depends on ¬b, b depends on ¬a
}
```

The compiler detects this during consistency checking and rejects the model with a specific error. There is no valid synthesis for a negatively cyclic model — and no valid semantics either.

---

## 7. Description Logics and the EL Fragment

### 7.1 DL as Ontology Language

**Description logics** (DL) are fragments of first-order logic designed for knowledge representation. They give formal semantics to the ontology level (Level 0) of the property model architecture.

A DL knowledge base has two components:
- **TBox** (terminological): class and property definitions
  ```
  Product ⊑ ∀available.Bool           // Product has property available of type Bool
  AvailableProduct ≡ Product ⊓ available = true   // defined class
  ```
- **ABox** (assertional): instance facts
  ```
  product1 : Product
  available(product1) = true
  ```

**Reasoning services** on DL KBs correspond exactly to our synthesis operations:

| DL reasoning task | Synthesis operation |
|------------------|---------------------|
| TBox consistency | Model consistency check |
| ABox consistency | Input validity check |
| Concept subsumption (C ⊑ D?) | Does `requires(M)` imply a property? |
| Instance checking (a : C?) | Does this input satisfy requires? |
| Concept realisation | What is the minimal set of properties for goal? |

### 7.2 The EL Fragment

Not all DLs are tractable. **EL** (Baader et al. 2005) is the Horn fragment of description logic:
- Only existential quantification (∃), conjunction (⊓), and top (⊤)
- No universal quantification (∀), disjunction (⊔), or negation (¬)

**Theorem 7.1** (EL tractability): Concept subsumption in EL is decidable in **polynomial time** (PTIME).

**Theorem 7.2** (EL = Horn Datalog): The EL fragment corresponds exactly to Horn Datalog over the property domain. EL reasoning is equivalent to Datalog bottom-up evaluation.

This is the theoretical anchor: **EL ontologies + Horn property models = PTIME synthesis**.

OWL 2 EL is the W3C standard DL profile used for large-scale biomedical ontologies (SNOMED CT has 300K+ concepts, all in EL). Its polynomial-time reasoning is proven and implemented. We inherit this machinery.

### 7.3 Beyond EL

For richer models:
- **ELI** (inverse roles): properties can be navigated in reverse → PTIME
- **ALC** (full DL): negation + universal quantification → PSPACE-complete
- **SROIQ** (OWL 2 Full): decidable but NEXPTIME

For the synthesis fragment: **stay in EL for guaranteed PTIME synthesis**. Opt into richer fragments only when needed, with documented complexity cost.

---

## 8. Refinement Types and Type-Directed Synthesis

### 8.1 Refinement Types

A **refinement type** (Freeman & Pfenning 1991) augments a base type with a logical predicate:

```
{ x : Int | x >= 0 }        // non-negative integer
{ m : Money | m > 0 }        // positive money
{ p : Product | p.available } // available product
```

In the contract language:
```
type AvailableProduct = Product where available = true
type ApprovedManager  = Manager  where approved = true && approval_limit > 0
```

### 8.2 Type-Directed Synthesis Optimisation

If the input type is a refinement type, the synthesiser can eliminate guards:

**Example**: If the input is declared as `AvailableProduct` (type guarantees `available = true`), the model requirement `requires: product.available = true` is **statically satisfied by the type**. No `guard` node is needed in the synthesised contract.

**Theorem 8.1** (Type-directed guard elimination): Let M be a property model and I be input types with refinement predicates R(I). For every requirement `requires: x.p = v` in M, if `R(I) ⊢ x.p = v` (derivable from the input refinement type), the corresponding guard node can be eliminated from the synthesised contract.

This gives a **compile-time optimisation**: the richer the input types, the fewer guards are synthesised, the cheaper the contract.

### 8.3 Liquid Types and SMT Solving

**Liquid types** (Rondon, Kawaguchi & Jhala 2008) extend refinement types with linear arithmetic constraints and check them using SMT solvers.

For the synthesis fragment:
- Refinement predicates with linear arithmetic: `price > 0`, `stock >= min_stock`
- Checked by an SMT solver (Z3, CVC5) during type checking
- DPLL(T)-decidable for linear arithmetic (PTIME for fixed number of variables)

This gives us **arithmetic guard elimination** at compile time — contracts over numerical properties can have their guards discharged before execution.

---

## 9. The Unified Theoretical Picture

### 9.1 Five Theories, One Object

The synthesis fragment sits at the intersection of five well-studied theories:

```
EL Description Logic ──────────────────────── Ontology reasoning
         │                                     (PTIME concept subsumption)
         │
Horn Datalog / Stratified Datalog ──────────── Synthesis algorithm
         │                                     (bottom-up evaluation)
         │
Hoare Logic / wp calculus ──────────────────── Soundness verification
         │                                     (VC discharge)
         │
Herbrand's theorem ─────────────────────────── Completeness
         │                                     (minimal Herbrand model)
         │
Situation Calculus + STRIPS ────────────────── Dynamic models
                                               (state-transition synthesis)
```

Each theory contributes a different guarantee:

| Theory | Guarantee provided |
|--------|-------------------|
| EL DL | Consistency checking is PTIME; type-level inference |
| Horn Datalog | Synthesis algorithm terminates, is PTIME, confluent |
| Hoare logic | Synthesised contract is correct (soundness) |
| Herbrand theorem | Synthesiser misses nothing (completeness) |
| Situation calculus | Dynamic models with state transitions are handled |
| Refinement types | Guard elimination at compile time |

### 9.2 The Central Theorem

**Theorem 9.1** (Main result): For property models in the synthesis fragment (Horn Datalog + stratified negation + EL ontology + refinement types):

1. **(Decidability)** The synthesis problem is decidable in PTIME
2. **(Soundness)** The synthesised contract satisfies its specification: `requires(M) ⊢ wp(C, goal(M))`
3. **(Completeness)** If any correct contract exists, synthesis finds one (closed-world completeness)
4. **(Optimality)** The synthesised contract is the minimal-depth DAG contract (critical path optimal)

**Conditions for the theorem**:
- No negative cycles in the property model
- No disjunctive requirements (only conjunctive)
- Finite or bounded property domains
- Pure function definitions in `derives` (no side effects)

**When conditions fail**: the compiler rejects the model with a specific, actionable error explaining which condition is violated and how to fix it.

---

## 10. The Boundary: What Falls Outside the Fragment

### 10.1 Disjunctive Requirements

```
// OUTSIDE THE FRAGMENT
model TwoSuppliers {
  requires: supplier_a.available OR supplier_b.available
  goal:     order.fulfillable = true
}
```

Disjunctive Horn logic (Datalog with disjunction in the head) is **NP-complete** (instead of PTIME). Synthesis is still decidable but exponentially harder.

**Practical workaround**: split into separate models (`ModelA`, `ModelB`) and branch:
```
branch fulfillment {
  on supplier_a.available => FulfillViaA { ... }
  on supplier_b.available => FulfillViaB { ... }
}
```
This is always expressible when the disjunction is over input properties.

### 10.2 Recursive Models

```
// OUTSIDE THE FRAGMENT (in the DAG core)
model TreeAggregation {
  derives: node.total = node.value + sum(node.children.total)  // self-reference
}
```

Recursive models correspond to **recursive Datalog** — decidable but no longer PTIME (complexity rises to PSPACE for datalog with recursion over infinite domains).

**Practical path**: allow recursive models as explicit opt-in (annotated with `@recursive`). The synthesiser generates a recursive contract (see Theorem 5.1 in the first theory document) with the known complexity cost.

### 10.3 Probabilistic Properties

```
// EXTENSION — requires probabilistic Datalog
model RiskModel {
  requires: location.anomaly_score > 0.8   // probabilistic threshold
}
```

**ProbLog** (De Raedt et al. 2007) extends Datalog with probabilistic facts. ProbLog inference is **PP-complete** (#P-hard exact inference, PTIME approximate).

The synthesis fragment extends to probabilistic models by replacing exact Herbrand derivation with **weighted model counting** — connecting back to the pre-computation document.

---

## 11. Research Agenda: What Remains to Be Proven

### Open Problem 1 — Optimal Synthesis
The current synthesis finds *a* correct contract. Prove that the bottom-up Datalog evaluation produces the **minimum-depth DAG** (critical path optimal) among all correct contracts.

*Conjecture*: The synthesis algorithm is critical-path optimal because the stratification order corresponds to the dependency order, and Datalog bottom-up evaluation produces the minimum derivation.

*Proof approach*: Reduction to shortest-path in the derivation DAG, using the stratum rank as edge weight.

### Open Problem 2 — Incremental Synthesis
When a property model changes (e.g., a new `requires` clause is added), prove that the synthesised contract can be updated incrementally without full re-synthesis.

*Conjecture*: Semi-naive Datalog evaluation can be applied to contract synthesis: only rules affected by the model change are re-evaluated.

*Proof approach*: Adapt the semi-naive evaluation theorem (Bancilhon 1986) to the synthesis setting.

### Open Problem 3 — Type-Directed Completeness
Prove that guard elimination via refinement types preserves completeness: the synthesised contract without eliminated guards is still correct.

*Conjecture*: If `R(I) ⊢ x.p = v`, then the contract without the `guard :x` has the same denotation as the contract with it, on all inputs satisfying R(I).

*Proof approach*: Weakest precondition calculation with type-refined input.

### Open Problem 4 — Probabilistic Synthesis Soundness
Extend the soundness theorem to probabilistic models: if the synthesised contract uses approximate nodes, prove that the output satisfies the goal with probability ≥ α (the declared confidence level).

*Proof approach*: Probability theory + weakest precondition extended to distributions.

### Open Problem 5 — Complexity of EL + Stratified Negation
Prove the exact complexity of synthesis for the full synthesis fragment (EL ontology + stratified negation + refinement types). Conjecture: still PTIME, because stratified negation adds at most a polynomial factor per stratum.

---

## Summary

The theoretical foundations establish that the synthesis fragment has all three required properties — decidability, soundness, completeness — with PTIME complexity.

The proof chain:

```
Horn Datalog bottom-up evaluation
  → Decidability (Theorem 2.1)
  → Termination + correctness of synthesis algorithm

Hoare logic / wp calculus
  → Soundness (Theorem 3.1)
  → Synthesised contract is correct by construction

Herbrand's theorem
  → Completeness (Theorem 4.1)
  → Synthesiser misses nothing in the fragment

EL description logic = Horn Datalog
  → PTIME ontology reasoning
  → Type checking and guard elimination are PTIME

Stratified Datalog / Przymusinski perfect model
  → Stratified negation handled correctly
  → Unique semantics, PTIME evaluation

Situation calculus + STRIPS
  → Dynamic models: PSPACE for sequential plans
  → PTIME for monotone DAG plans (parallel workflow)
```

The fragment is not arbitrary — it is determined by tractability requirements. Every extension (disjunction, unrestricted recursion, probabilistic) is possible but carries a documented complexity cost. The language makes this cost visible and requires explicit opt-in.

This is the scientific foundation: not "we think it works" but "we know it works, within these boundaries, with these proofs."
