# Igniter Contract Language — Theoretical Foundations

Date: 2026-04-27.
Perspective: cross-disciplinary research; programming language theory, automata, constraint systems, cybernetics.
Subject: Scientific grounding for the contract-native language — five theoretical domains, their contributions, cross-domain isomorphisms, and a proposed unified formal model.

*Status: experimental research — theoretical groundwork, not a feature proposal.*
*Follows: [igniter-lang.md](igniter-lang.md) — initial feasibility and grammar sketch.*

---

## Preamble: Why Theory First

Building a language without a theoretical foundation is engineering without science. The result is a language shaped by implementation accidents rather than by the structure of the problem it solves. Before designing syntax or a runtime, we need to answer:

1. What mathematical object IS a contract?
2. What class of computations can it express?
3. What are the natural laws of composition, equivalence, and transformation?
4. What extensions are coherent with the core, and which ones break it?

These are not philosophical questions — they are engineering pre-requisites. A language whose semantics can be stated in ten lines of mathematics is easier to implement correctly, easier to optimise, easier to extend, and easier to reason about than one whose semantics live only in the implementation.

The hypothesis driving this report:

> The Igniter contract model is not a novel construct. It is a convergent
> rediscovery of several deep theoretical structures from different fields.
> Naming those structures is the fastest path to a solid foundation.

---

## 1. Theory of Functional Systems (Anokhin, 1935–1974)

### 1.1 The Theory

Pyotr Anokhin's Theory of Functional Systems (TFS) is a model of purposeful biological and behavioural systems. Its central claim is a radical inversion of the classical systems view:

> A functional system is not defined by its components.
> It is defined by its **result** — the useful adaptive outcome it produces.
> Structure follows result, not the other way around.

The core components of a functional system:

| TFS concept | Definition |
|-------------|-----------|
| **Полезный приспособительный результат** | The useful adaptive result — the goal the system is organised around |
| **Афферентный синтез** | Integration of multiple incoming signals before action |
| **Акцептор результата действия** | Result acceptor — the system's internal model of the expected result, used for comparison |
| **Санкционирующая афферентация** | Confirming reverse afferentation — feedback that the result was actually achieved |
| **Системообразующий фактор** | The result-forming factor — the result is what *forms* the system |

### 1.2 The Isomorphism with Contracts

The mapping is precise:

| TFS concept | Contract equivalent |
|-------------|---------------------|
| Полезный приспособительный результат | `output` nodes — the goal the contract is organised around |
| Афферентный синтез | Multi-`input` integration before computation |
| Акцептор результата действия | `guard` nodes — expected result check before/after computation |
| Санкционирующая афферентация | `effect` nodes — side effects confirming system state |
| Иерархия функциональных систем | `compose` — systems within systems |
| Системообразующий фактор | The compile-time graph — built in service of the declared outputs |

### 1.3 Why This Matters

TFS inverts the conventional direction of reasoning. In OOP, you define objects and from their interaction behavior emerges. In FP, you define transformations and their composition produces results. In TFS — and in Igniter contracts — you define **the result first**, and the system organises itself to produce it.

When a contract is compiled, `GraphCompiler` performs topological sort *backward from outputs*. The resolution order is literally determined by what is needed to produce the declared results. This is not a coincidence of implementation — it is the direct expression of the TFS principle.

**The language design implication**: in the contract-native language, `out` declarations should be written first, or at least first-class. The compiler always works backward from them. The programmer's mental model should do the same.

---

## 2. Automata Theory and Computation Hierarchy

### 2.1 Contract as Transducer

A Mealy machine (finite transducer) maps input sequences to output sequences by traversing a state graph. A contract does the same: it takes a set of input values and produces a set of output values by traversing a computation graph.

Formally, a contract is a **deterministic acyclic transducer** (DAT):

```
C = ⟨Σ_in, Σ_out, Q, q₀, F, δ, λ⟩

where:
  Σ_in  = product domain of all input types
  Σ_out = product domain of all output types
  Q     = set of resolution states (one per node × execution context)
  q₀    = initial state (all inputs available, no nodes resolved)
  F     = final states (all outputs resolved)
  δ     = transition function (dependency resolution step)
  λ     = output function (node computation)
```

Because the graph is acyclic, the transducer is acyclic — it visits each state exactly once.

### 2.2 The Contract Complexity Hierarchy

Different contract shapes fall into different levels of the Chomsky-Hopcroft hierarchy:

| Contract form | Equivalent automaton | Complexity class | Example |
|---------------|---------------------|-----------------|---------|
| Pure DAG (no branch) | Finite transducer | `AC⁰` (parallel) | `PriceQuote` |
| DAG with `branch` | Nondeterministic finite transducer, deterministic interpretation | `NC¹` | Conditional workflows |
| Recursive contracts | Pushdown transducer | `CFL` / `PSPACE` | `Fibonacci`, tree traversal |
| `iterate` with unrestricted condition | Turing machine | `RE` | General loops |
| Streaming contracts | ω-transducer | ω-regular / Büchi | `LivePricing` |

This hierarchy is not academic trivia. It determines:
- **What you can prove statically** (termination, resource bounds)
- **What the runtime must do** (whether a stack is needed)
- **What optimisations are safe** (memoisation, partial evaluation)

The pure DAG core is in `AC⁰` — the complexity class of circuits computable in constant parallel time with polynomial size. This means: the entire contract executes in depth proportional to the critical path, not total node count. Parallelism is maximal and provable by construction.

### 2.3 Compositionality

The product of two transducers is a transducer. `compose` in a contract is transducer product: the composed contract's transduction function is the composition of the two transduction functions. This gives us:

> Contract composition is mathematically well-defined and has known algebraic properties.

Specifically, composition is associative but not commutative (input/output types must match). This gives the contract language the structure of a **monoidal category** (see §4).

---

## 3. Formal Grammar Theory and Attribute Grammars

### 3.1 Attribute Grammars (Knuth, 1968)

Donald Knuth introduced attribute grammars as a formalism for defining the semantics of context-free grammars. An attribute grammar augments a CFG with:

- **Synthesized attributes** — computed bottom-up from children
- **Inherited attributes** — passed top-down from parent to children
- **Semantic rules** — compute attribute values at each node

A contract IS an attribute grammar over its dependency DAG:

| Attribute grammar concept | Contract equivalent |
|--------------------------|---------------------|
| Non-terminal / production | node name + dependencies |
| Synthesized attribute | `output` (computed upward from dependencies) |
| Inherited attribute | `input` (passed downward from caller) |
| Semantic rule | `compute` node (the computation) |
| Attribute domain | node type |
| Attribute evaluation order | `resolution_order` (topological sort) |

This identification is not metaphorical — it is definitional. Knuth showed that attribute grammars are exactly the structure needed to give semantics to syntax. Contracts are attribute grammars over computation graphs rather than parse trees.

### 3.2 What This Gives Us

**Knuth's well-definedness condition**: an attribute grammar is well-defined if no attribute depends on itself (no cycles in the dependency graph). This is exactly what `GraphCompiler` enforces.

**Ordered attribute grammars** (Kastens, 1980): a subclass where the attribute evaluation order can be determined statically. Igniter's `resolution_order` IS the ordered evaluation schedule.

**Circular attribute grammars** (Farrow, 1986): allow cycles with fixed-point iteration. This is the theoretical pathway to recursive/iterative contracts — circular AGs with bounded fixed-point iteration.

**The language design implication**: the contract-native language is a concrete syntax for attribute grammars over typed dependency graphs. The compiler computes the evaluation order (AG scheduling) at compile time. Circular dependencies → either a compile error (pure DAG mode) or an `iterate`/recursive declaration (opt-in).

### 3.3 Graph Grammars

A richer extension: **graph grammars** allow describing which graph shapes are valid productions. This could be the formal basis for:
- Type-checking compositions (are edge types compatible?)
- Macro/template nodes (a pattern that expands to a subgraph)
- Refactoring rules (graph grammar rewrite systems)

---

## 4. Category Theory and Functional Programming

### 4.1 The Categorical Structure

Category theory is the mathematics of composition. Its core insight: the important thing about a mathematical object is not its internal structure but how it composes with other objects.

A contract has a natural categorical reading:

- **Objects** = types (input and output type signatures)
- **Morphisms** = contracts (a contract from input type `A` to output type `B`)
- **Identity** = the trivial contract that passes its input directly to output
- **Composition** = sequential contract composition

This forms a **category of contracts**. The key laws:

```
identity composition:    id ∘ C = C = C ∘ id
associativity:          (A ∘ B) ∘ C = A ∘ (B ∘ C)
```

These are guaranteed by the graph semantics.

### 4.2 Contract as Profunctor

More precisely, a contract is a **profunctor**: it is *contravariant* in inputs (adding an input restricts the valid callers) and *covariant* in outputs (adding an output enriches the result). Profunctors are the right categorical structure for "processes with inputs and outputs."

### 4.3 The Node-Level Functors

Individual node types map to standard categorical structures:

| Node type | Categorical structure |
|-----------|----------------------|
| `compute :y = f(x)` | Function application (morphism) |
| `collection :ys = map(xs, f)` | Functor (`fmap`) |
| `aggregate :total = fold(xs, f)` | Catamorphism |
| `branch :r { on ... }` | Coproduct (sum type elimination) |
| `compose :sub = Sub { ... }` | Functor composition |
| `await :x event: :e` | Continuation (free monad suspension) |

This decomposition shows that contract nodes are not ad hoc primitives — they are instances of fundamental categorical constructs.

### 4.4 Denotational Semantics

Category theory gives us compositional denotational semantics: the meaning of a composed contract is determined entirely by the meanings of its parts. This is the mathematical guarantee that `compose` works correctly — no hidden global state, no action at a distance.

The denotation of a contract `C`:

```
⟦C⟧ : ⟦Inputs(C)⟧ → ⟦Outputs(C)⟧
```

For composition `C = A compose B` (B's outputs feed A's inputs):
```
⟦C⟧ = ⟦A⟧ ∘ ⟦B⟧
```

This is the formal statement of what `compose` does — and it works because contracts form a category.

---

## 5. Constraint Programming

### 5.1 Concurrent Constraint Programming (Saraswat, 1989)

Vijay Saraswat's Concurrent Constraint Programming (CCP) is a model of concurrent computation built on constraint stores rather than message passing. Agents communicate by:

- `tell(c)`: add constraint `c` to the shared store
- `ask(c)`: block until constraint `c` is entailed by the store

A contract execution IS a CCP execution:

| CCP concept | Contract equivalent |
|-------------|---------------------|
| Constraint store | The set of resolved node values in an execution |
| `tell(c)` | A `compute` node writing its result |
| `ask(c)` | A `guard` node checking a condition |
| Constraint entailment | Dependency satisfaction (a node fires when all deps resolved) |
| Concurrent agents | Parallel node resolution in thread-pool runner |
| Partial information | Lazy resolution (only compute what is needed) |

### 5.2 What CCP Gives Us

**The operational semantics of contract execution is concurrent constraint propagation.**

This is precise and well-studied. From CCP theory we inherit:

1. **Confluence** — the result of a contract execution does not depend on the order in which independent nodes are resolved (determinism despite concurrency)
2. **Monotonicity** — the constraint store only grows (values are never retracted, only added), which makes caching safe
3. **Completeness** — if the inputs entail the outputs, the execution always succeeds

The `coalesce` feature (deduplicating concurrent requests for the same node) is a direct CCP optimization: multiple `ask`s for the same constraint are collapsed.

### 5.3 Soft Constraints and Cache Policies

**Soft/weighted CSP** extends hard constraints with costs. Cache annotations can be modelled as soft constraints:

- `@cache(60s)` = soft freshness constraint: prefer the cached value if it is less than 60 seconds old, otherwise re-compute
- `guard` = hard constraint: must hold, or the execution fails
- Type annotations = domain constraints: the value must be of type `T`

This unification suggests a **unified constraint layer** over the computation graph, where hard guards, type constraints, and soft cache policies are all instances of the same construct — differing only in their violation semantics.

---

## 6. Probability Theory and Bayesian Networks

### 6.1 Contract as Bayesian Network

A Bayesian network is a directed acyclic graph where:
- Nodes represent random variables
- Edges represent conditional dependencies
- Each node has a conditional probability table given its parents

A contract graph has the same structure. When `compute :price, depends_on: [:vendor, :region]` is declared, the contract is asserting:

> `price` is conditionally independent of everything else given `vendor` and `region`.

This IS the d-separation condition in Bayesian networks. The contract graph encodes a conditional independence structure over its domain.

### 6.2 Probabilistic Extension

A probabilistic contract allows nodes to be distributions rather than deterministic values:

```
compute :risk_score = sample(Beta(α(vendor), β(region)))
compute :approval   = risk_score > 0.7
```

This turns the contract into a **probabilistic program** — a generative model. The contract can then be:
- **Sampled forward**: generate a random outcome (Monte Carlo execution)
- **Inferred backward**: given an observed output, infer the likely inputs (Bayesian inference)

Backward inference is the "inverse contract" operation: given that `approval` is true, what are the likely values of `vendor` and `region`? This is computationally equivalent to probabilistic programming inference (Pyro, Stan, Gen.jl).

### 6.3 Information-Theoretic Density

The SIR metric from the previous report has a rigorous basis in information theory. The **minimum description length (MDL)** principle states that the best model is the one that maximally compresses the data.

Applied to programs:
- A program description is a compressed representation of a computation
- The information density of a language is how close its programs are to the MDL bound for the computations it expresses
- A domain-specific language can compress a domain-specific computation closer to its MDL bound than a general-purpose language

**Formal SIR revisited**:

```
SIR(P, L) = H(semantics(P)) / |P|_L
```

Where `H(semantics(P))` is the Shannon entropy of the program's semantic content (how many distinct things it says) and `|P|_L` is the length of program `P` in language `L`. Higher SIR = more meaning per symbol.

---

## 7. Logic Programming and Datalog

### 7.1 Contract as Datalog Program

Datalog is a declarative logic language — a subset of Prolog without function symbols. It is the natural language for deductive databases and graph queries.

A Datalog program is a set of rules of the form:
```
head :- body₁, body₂, ..., bodyₙ
```

A contract compute node IS a Datalog rule:
```datalog
% compute :slots, depends_on: [:vendor, :zip], call: CheckSlots
slots(Result) :- vendor(V), zip(Z), check_slots(V, Z, Result).

% input :vendor_id
vendor_id(X) :- given(vendor_id, X).

% guard :vendor, eq: :active, on: :status
active_vendor(V) :- vendor(V), V.status == :active.
```

### 7.2 What Datalog Gives Us

This identification is the strongest formal result in this report:

> **A pure DAG contract is a stratified Datalog program.**

Datalog is:
- **Decidable** — evaluation always terminates (no infinite loops)
- **Confluent** — the unique minimal model is the result, regardless of evaluation order
- **In PTIME** — evaluation is polynomial in the size of the input
- **Stratifiable** — layers of the computation correspond to strata in the DAG

Igniter's `resolution_order` IS the Datalog stratification order.

The evaluation algorithm in `GraphCompiler` / `Resolver` is **bottom-up Datalog evaluation** (semi-naïve evaluation): compute the fixpoint by adding facts layer by layer.

### 7.3 Extensions of Datalog Match Extensions of Contracts

| Contract extension | Datalog extension |
|-------------------|-------------------|
| Recursive contracts | Recursive Datalog (Datalog+) |
| Probabilistic nodes | ProbLog |
| Uncertain inputs | Dempster-Shafer Datalog |
| Temporal contracts | Temporal Datalog |
| Streaming | Continuous Datalog (C-Datalog) |
| Constraint guards | Constraint Logic Programming (CLP) |

This is a research gift: every well-studied extension of Datalog is a candidate for a well-founded extension of the contract language.

---

## 8. Game Theory and Mechanism Design

### 8.1 The Mechanism Design Framing

Mechanism design is "reverse game theory": instead of analyzing how rational agents play a given game, you design the game so that rational agents produce a desired outcome. Hurwicz, Maskin, and Myerson received the 2007 Nobel Prize in Economics for this theory.

A contract is a mechanism:
- **Principal** = the contract caller (wants the specified outputs)
- **Agents** = node executors (have private information about how long computation takes, what the result will be)
- **Mechanism** = the contract graph (the rules of the game)
- **Desired outcome** = all output nodes resolved correctly

The mechanism designer's problem: design the contract so that the rational behavior of each executor (doing the minimum work necessary) produces the desired aggregate outcome.

### 8.2 Caching and Coalescing as Mechanism Design

From this framing, `@cache` and `@coalesce` are not performance optimisations — they are **incentive structures**:

| Feature | Mechanism design interpretation |
|---------|--------------------------------|
| `@cache(ttl)` | Reward past effort: reuse a previous computation's result. This reduces the cost to the executor without reducing benefit to the principal. |
| `@coalesce` | Prevent a race to compute the same value. This is a coordination mechanism that eliminates the prisoner's dilemma of duplicate work. |
| `guard` | Refusal mechanism: the contract refuses to proceed if the expected conditions are not met. This aligns the executor's incentives with the principal's requirements. |

### 8.3 Complete vs Incomplete Contracts

Contract theory in economics distinguishes:
- **Complete contracts** — all contingencies are specified
- **Incomplete contracts** — some contingencies are left to future negotiation

Igniter contracts are compile-time-validated complete contracts. This is the key differentiator from REST APIs (incomplete: behavior not fully specified, caller must handle unexpected responses) and from event-driven systems (incomplete: event ordering not guaranteed).

**Complete contracts** enable static analysis, formal verification, and guaranteed compositional behavior. **Incomplete contracts** are flexible but unsafe. The language design should preserve completeness by default and make incompleteness explicit (e.g., `await` for externally determined contingencies).

---

## 9. Synthesis: The Unified Formal Model

Drawing the threads together:

### 9.1 What a Contract Is

From the preceding analysis, a contract is simultaneously:

| Perspective | What it is |
|-------------|-----------|
| TFS (Anokhin) | A result-oriented functional system, organised around its outputs |
| Attribute grammar | An attribute grammar over a typed dependency DAG |
| CCP | A concurrent constraint propagation program |
| Datalog | A stratified Datalog program (decidable, PTIME, confluent) |
| Category theory | A profunctor in the category of typed processes |
| Automata theory | A deterministic acyclic transducer |
| Mechanism design | A complete contract aligning executor incentives with principal goals |
| Bayesian network | A conditional independence structure over a domain |

These are not different theories describing different aspects — they are different languages describing the same mathematical object. Their convergence on the contract structure is what makes that structure fundamental, not accidental.

### 9.2 The Proposed Formal Model

**Definition**: A *contract* `C` over input type `I` and output type `O` is:

```
C = ⟨N, E, τ, σ, κ, γ⟩

where:
  N    = finite set of nodes (inputs, computes, outputs, guards, branches)
  E ⊆ N×N  = directed acyclic edge relation (dependencies)
  τ : N → Type   = type assignment
  σ : N → Stratum = stratification (topological layer)
  κ : N → Callable = computation function (for compute nodes)
  γ : N → Constraint set = guard and cache constraints
```

Well-formedness conditions:
1. `(N, E)` is a DAG *(ensures Datalog stratifiability)*
2. `τ` is consistent across edges *(ensures attribute grammar well-definedness)*
3. All output nodes are reachable from at least one input *(ensures TFS result-orientation)*
4. All `guard` constraints are over nodes in `τ`'s domain *(ensures CCP entailment is decidable)*

**Composition**: For contracts `A : I_A → O_A` and `B : I_B → O_B` where `O_B ⊇ I_A`:
```
A ∘ B : I_B → O_A
```
with graph product merging `N_A ∪ N_B`, `E_A ∪ E_B ∪ E_binding`, where `E_binding` connects `O_B` to `I_A`.

### 9.3 The Language Design Principles

From the formal model, the contract language must:

1. **Declare results first** (TFS / Anokhin) — `out` declarations drive compilation
2. **Express types structurally** (attribute grammar / category theory) — types flow along edges, not just at boundaries
3. **Make constraints uniform** (CCP) — guards, types, cache policies are all constraints
4. **Distinguish DAG from recursive** (automata / Datalog) — recursion must be explicit opt-in
5. **Make composition the primary operation** (category theory) — composition must be syntactically cheap
6. **Express probability explicitly** (Bayesian networks) — uncertain nodes are declared, not hidden in error handling

---

## 10. Research Agenda

### Priority 1 — Formal Semantics (3–6 months)

Define the denotational semantics of contracts as an attribute grammar over typed DAGs. Prove:
- Correctness of compilation (compiler produces well-formed AG)
- Confluence of execution (CCP monotonicity)
- Termination for pure DAG contracts (Datalog decidability)

Tools: formal specification in TLA+ or Coq, verified against test suite.

### Priority 2 — Type System (2–4 months)

Design a type system with:
- Structural type inference along edges (no explicit annotations in simple cases)
- Constraint types: `guard`-derived refinement types
- Effect types: mark IO nodes with effect annotations
- Probabilistic types (optional): distinguish deterministic and stochastic nodes

### Priority 3 — Complexity Bounds (1–2 months)

Prove the complexity hierarchy from §2.2:
- Pure DAG contracts: PTIME (from Datalog characterisation)
- Contracts with bounded recursion: which subclass of PSPACE?
- Streaming contracts: what is the automata-theoretic characterisation?

### Priority 4 — Density Measurement (ongoing, empirical)

Build the SIR benchmark:
- Select 15 representative workflow programs from `examples/`
- Implement in: (a) current Ruby DSL + executors, (b) compact syntax Level 1, (c) contract-native language
- Measure LOC, SIR, cyclomatic complexity, Halstead volume
- Target: ≥2× SIR improvement, statistical significance at p < 0.05

### Priority 5 — Probabilistic Extension (research track)

Explore: can Igniter contracts become ProbLog programs? What would Bayesian inference over a workflow look like? What practical problems does this solve (risk scoring, fraud detection, uncertain data integration)?

---

## Summary

The Igniter contract model is a convergent rediscovery of five deep theoretical structures:

1. **Anokhin's TFS** — the result-orientation principle: outputs define the system
2. **Attribute grammars** — the natural semantics of contracts over DAGs (Knuth 1968)
3. **Concurrent constraint programming** — the operational semantics of execution (Saraswat 1989)
4. **Stratified Datalog** — the logical foundation: decidable, PTIME, confluent
5. **Category theory** — compositional semantics: contracts form a monoidal category

These are not analogies. They are formal identities. Building the contract-native language on this foundation means inheriting:
- Decades of Datalog optimisation research
- CCP's confluence and monotonicity guarantees
- Category theory's compositional reasoning
- Attribute grammar scheduling algorithms
- TFS's result-first design philosophy

The practical payoff: a language that is correct by construction, provably terminating in its DAG core, efficiently executable in parallel (AC⁰), and extensible into probability, recursion, and streaming through well-understood theoretical pathways — not by guesswork.
