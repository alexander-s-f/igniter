# Igniter Contract Language — Research Series

Experimental research track on using the Igniter contract model as the foundation
for a new programming language and paradigm. Not a product track or feature proposal.

## Frontier Marker

`★ FRONTIER` marks the current peak of the research track — the document where
the strongest active ideas live. The frontier advances as new documents are added;
older documents remain the permanent theoretical foundation.

**Current frontier: [igniter-lang-temporal.md](igniter-lang-temporal.md)**
Temporal dimension as a first-class axis: `History[T]`, temporal access operator `[t]`,
rule declarations with algebra and conflict detection, orthogonality principle (adding a
rule touches zero existing contracts), temporal invariants, counterfactual reports, and
bitemporal / rule-synthesis open directions.

*Previous frontier (now foundation layer): [igniter-lang-invariants.md](igniter-lang-invariants.md)*

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
| ★ [igniter-lang-temporal.md](igniter-lang-temporal.md) · [ru](igniter-lang-temporal.ru.md) | **FRONTIER** — Temporal dimension — `History[T]`, `[t]` operator, `T ⊑ History[T]`, rule declarations (applies/compute/priority/combines), orthogonality principle, temporal invariants (frozen values, consistency, monotone), counterfactual period reports, rule algebra + conflict detection, situation calculus foundation, 5 open directions (bitemporal, synthesis, causal chains, probabilistic rules, distributed time) |

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
