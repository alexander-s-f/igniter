# Igniter Contract Language — Research Series

Experimental research track on using the Igniter contract model as the foundation
for a new programming language and paradigm. Not a product track or feature proposal.

## Frontier Marker

`★ FRONTIER` marks the current peak of the research track — the document where
the strongest active ideas live. The frontier advances as new documents are added;
older documents remain the permanent theoretical foundation.

**Current frontier: [igniter-lang-implementation.md](igniter-lang-implementation.md)**
Implementation strategy: Ruby DSL as Reference Implementation (grammar after semantics proven);
explicit `Backend` interface (`compile`/`execute`/`verify`/`export`); pluggable backends
(Ruby now, Rust for WCET/certification/formal export); 8 DSL extension groups (`store`,
`invariant label:/severity:`, `olap` node, `rule` stabilisation, physical unit types,
`deadline:` contracts, `time_machine`); Ruby DSL friction log as grammar design input;
5-iteration roadmap (~1500 LOC to full DSL, grammar in iteration 4, Rust in iteration 5).

*Previous frontier (now layer): [igniter-lang-persistence.md](igniter-lang-persistence.md)*
*Foundation layer: [igniter-lang-invariants.md](igniter-lang-invariants.md)*

## Documents

| Document | Contents |
|----------|----------|
| [igniter-lang.md](igniter-lang.md) · [ru](igniter-lang.ru.md) | Feasibility analysis, grammar sketch (EBNF + examples), Turing completeness paths, information-density hypothesis (SIR metric), formal placement, prototype roadmap |
| [igniter-lang-theory.md](igniter-lang-theory.md) · [ru](igniter-lang-theory.ru.md) | Scientific grounding — five theoretical domains (TFS/Anokhin, attribute grammars, CCP, Datalog, category theory), cross-domain isomorphisms, unified formal model, research agenda |
| [igniter-lang-precomp.md](igniter-lang-precomp.md) · [ru](igniter-lang-precomp.ru.md) | Probabilistic pre-computation — two-level evaluation model, decision-directed lazy computation, lifting problem taxonomy, backward precision propagation, connection to abstract interpretation and CCP |
| [igniter-lang-propmodel.md](igniter-lang-propmodel.md) · [ru](igniter-lang-propmodel.ru.md) | Property models and algorithm synthesis — ontology/model/contract/execution four-level architecture, synthesis boundary, LLM as model author with formal verification loop, information density at MDL bound |
| [igniter-lang-theory2.md](igniter-lang-theory2.md) · [ru](igniter-lang-theory2.ru.md) | Theoretical foundations of synthesis — decidability (Horn Datalog, PTIME), soundness (Hoare/wp calculus), completeness (Herbrand), EL description logics, stratified negation, refinement types, situation calculus; 5 open problems |
| [igniter-lang-spec.md](igniter-lang-spec.md) · [ru](igniter-lang-spec.ru.md) | Language specification v0.1 — type system BNF, 12 node constructs with formal type rules, contract signature, annotation system, fn declarations, complete grammar, worked example, compile-time guarantee table |
| [igniter-lang-algebra.md](igniter-lang-algebra.md) · [ru](igniter-lang-algebra.ru.md) | Contract algebra and enterprise model — everything-is-a-contract unification, closed algebraic operations, Arrows connection, organic three-tier axiom layer, enterprise primitives (entity/workflow/policy/system), the ideal of compute disappearing, standard library blueprint |
| [igniter-lang-invariants.md](igniter-lang-invariants.md) · [ru](igniter-lang-invariants.ru.md) | Invariants as first-class contracts — invariant algebra (lattice, conjunction/weakening/parametrisation), formal identity with refinement types / Liquid Types, Hoare logic propagation through composition, enterprise invariant patterns, compiler-as-verifier (PTIME), 3-iteration POC roadmap |
| [igniter-lang-temporal.md](igniter-lang-temporal.md) · [ru](igniter-lang-temporal.ru.md) | Temporal dimension — `History[T]`, `[t]` operator, `T ⊑ History[T]`, rule declarations (applies/compute/priority/combines), orthogonality principle, temporal invariants (frozen/consistency/monotone), counterfactual reports, rule algebra + conflict detection, situation calculus foundation |
| [igniter-lang-temporal-deep.md](igniter-lang-temporal-deep.md) · [ru](igniter-lang-temporal-deep.ru.md) | Full temporal model: bitemporal `BiHistory[T]` (4 canonical queries, `T⊑History⊑BiHistory`), goal-directed rule synthesis (LP→PTIME, `synthesize rule` DSL), causal chain detection (Rule Dependency Graph, cycle classification, 3 resolution strategies), probabilistic rules (`~applies`, two-level evaluation), distributed time (Lamport/vector clocks, causal `as_of`, consistency levels), unified 3-axis parameters, 3-iteration POC roadmap (~750 LOC) |
| [igniter-lang-olap.md](igniter-lang-olap.md) · [ru](igniter-lang-olap.ru.md) | History internal structure (`HistorySegment[T]` content-addressed, sealed, append-only, O(log n) reads; `DistributedHistory[T]` cluster partition map); time travel spec (backward full introspection, forward 3 modes: deterministic/counterfactual/approximate, `time_machine` construct, `Forecast[T]` type); **OLAP Point** as fundamental construct — multi-dimensional analytical node, `slice`/`rollup`/`drill-down`/`pivot`/`compare`, cluster scatter-gather MapReduce, L1–L4 cache; `source:` operational→analytical bridge; unification `History[T] ≡ OLAPPoint[T, {time: DateTime}]` |
| [igniter-lang-persistence.md](igniter-lang-persistence.md) · [ru](igniter-lang-persistence.ru.md) | Storage shape taxonomy (type → backend inference); `Store[T]` as language construct; three-level cluster parallelism (node/contract/data-fanout); write path for `History[T]` (four strategies, `combines:` unifies write+rule conflicts); materialization-as-contract (synchronous/CDC/incremental); consistency model + `as_of` semantics; execution state durability (`ExecutionCheckpoint ≡ HistorySegment[ExecutionState]`); unified architecture stack; 3-iteration POC (~2000 LOC) |
| ★ [igniter-lang-implementation.md](igniter-lang-implementation.md) · [ru](igniter-lang-implementation.ru.md) | **FRONTIER — Implementation Track** — Ruby DSL as Reference Implementation; explicit `Backend` interface (pluggable: Ruby default, Rust future); 8 DSL extension groups (`store`, `invariant label:/severity:/overridable_with:`, `olap` node, `rule` API, physical unit types + `Numeric` refinements, `deadline:`+`wcet:`, `time_machine`); friction log as grammar motivation; 5-iteration roadmap (~1500 LOC); non-goals (no monkey-patch, no hot-path type objects, no grammar before signals) |

## Core Claim

The Igniter contract model is a convergent rediscovery of five deep theoretical
structures: Anokhin's Theory of Functional Systems, Knuth's attribute grammars,
Saraswat's concurrent constraint programming, stratified Datalog, and category
theory. These are formal identities, not analogies.

## Central Hypothesis

A contract-native language achieves ≥2× Semantic Information Ratio (SIR) compared
to Ruby DSL + executor classes, by eliminating the host-language tax: wrapper
classes, file namespaces, `def call` boilerplate, and decorative types.

## Key Results (Theoretical)

- Pure DAG contracts ≡ stratified Datalog programs → PTIME, decidable, confluent
- Contract graph ≡ attribute grammar over typed DAG → evaluation order is computable at compile time
- Contract execution ≡ concurrent constraint propagation (CCP) → confluence and monotonicity guaranteed
- Contract ≡ deterministic acyclic transducer in AC⁰ → full parallelism provable by construction
- `out` nodes are the *системообразующий фактор* (result-forming factor) in Anokhin's sense
