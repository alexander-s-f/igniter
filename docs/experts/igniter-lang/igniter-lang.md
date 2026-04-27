# Igniter Contract Model as Language Foundation — Research Report

Date: 2026-04-26.
Perspective: experimental programming language research; information density theory.
Subject: Feasibility, grammar sketch, Turing completeness, and the information-density hypothesis for a contract-native language built on Igniter's core model.

*Status: experimental research — not a feature proposal, not a track.*

---

## 1. The Question

Igniter's Ruby DSL is expressive. The contract model — a validated, compile-time dependency graph with lazy resolution and structural caching — is a strong abstraction. But the DSL is still *hosted* in Ruby, and Ruby itself starts generating syntactic noise: service classes, inheritance boilerplate, file structure, `def call(kwargs:)` wrappers. Every `compute` node eventually delegates to a Ruby class that exists purely to hold one expression.

The research question is:

> Can the Igniter contract model be the semantic foundation of a new programming
> language — one where the graph topology and the computation inside each node
> speak the same language, eliminating the host-language tax?

---

## 2. Is It Possible?

**Yes, and the foundations are unusually solid.**

Igniter's DSL already defines a complete set of language-level primitives:

| DSL keyword | Language-level concept |
|-------------|------------------------|
| `input` | typed parameter / free variable |
| `compute` | named expression (let-binding) |
| `branch` | pattern matching / conditional dispatch |
| `compose` | function application / contract call |
| `collection` | map / functor over a collection |
| `guard` | assertion / precondition |
| `await` | algebraic effect / async suspension |
| `effect` | bounded side effect |
| `aggregate` | fold / reduce |
| `const` | constant binding |
| `project` / `map` | field projection / value transform |

The topologically sorted `resolution_order` produced by `GraphCompiler` is already an execution plan. The `CompiledGraph` is already an AST. What is missing is not the semantic model — it is the *concrete syntax* and the ability to write computation expressions inline at the node, without escaping to a Ruby class.

---

## 3. The Information-Density Hypothesis

### 3.1 The Problem Statement

The current encoding of a contract program is:

```
Program = Contract DSL  (topology, ~1 line/node)
        + Ruby classes  (computation, ~5–10 lines/node)
```

Ruby is a general-purpose language; its syntax is optimised for all programs, not specifically for contract graphs. The result is a systematic *density mismatch*: the contract describes *what* and *in what order* at high density; the Ruby class describes *how* at low density, wrapped in language machinery that has nothing to do with the computation.

```ruby
# Contract: one line carrying four semantic claims
compute :vendor, depends_on: :vendor_id, call: FetchVendor, cache_ttl: 60

# Implementation: five lines for one expression
class FetchVendor < Executor
  def call(vendor_id:)
    Vendor.find_by!(id: vendor_id)
  end
end
```

The information was packed, then forcibly unpacked by the wrapper.

### 3.2 Formal Framing

This maps to **Kolmogorov complexity** and **domain-specific compression**. A language whose primitives match the domain can describe the same computation in fewer symbols — not by being terse, but by eliminating concepts that do not exist in the domain.

In the contract domain the following do not exist: object identity, method dispatch hierarchies, file namespaces, class inheritance for plain value transforms. A contract-native language need not represent them.

The proposed metric for empirical validation is the **Semantic Information Ratio**:

```
SIR = (number of distinct business claims) / (total LOC)
```

Hypothesis: for typical workflow programs, a contract-native language achieves SIR > 2× compared to Ruby DSL + executor classes.

### 3.3 Why "Process Level" vs "Object Level"

The contract model operates at the *process level*: it describes a computation as a flow of named values through a directed graph. Ruby operates at the *object level*: it describes computation as message passing between objects. Forcing a process-level declaration to delegate to an object-level implementation is the root cause of the density loss — not a deficiency in Ruby, but a fundamental level mismatch.

---

## 4. Grammar Sketch

### 4.1 Level 1 — Contract-First Syntax (minimum viable)

Extend Igniter's semantics with inline expressions at compute nodes. Not a new language, but the maximum step within a DSL:

```
contract PriceQuote {
  in vendor_id: Id
  in zip_code:  Zip
  in as_of:     Time = now()

  compute vendor = http.get("/vendors/{vendor_id}") |> Vendor.parse
                   @cache(60s)

  compute slots  = vendor.slots
                     |> select { |s| s.zip == zip_code && s.available }
                     |> select { |s| s.time > as_of }
                   @coalesce

  branch availability {
    on slots.count > 0 => AvailableQuote { slots: slots, vendor: vendor }
    default            => EmptyQuote     { vendor: vendor }
  }

  out quote  = availability
  out vendor = vendor
}
```

Key syntax decisions:
- `=` instead of `call:` — expression directly at the binding site
- `@cache(60s)`, `@coalesce` — annotations as node decorators
- `|>` — pipeline operator for transforms (no intermediate names)
- `on expr => Contract` — branch on arbitrary expression, not only `eq:` / `in:`

### 4.2 Level 2 — Standalone Contract Language

A self-contained language with types, functions, and contracts as equal first-class citizens.

**EBNF skeleton:**

```ebnf
program      = (type_def | fn_def | contract_def)*

type_def     = "type" IDENT "{" field+ "}"
field        = IDENT ":" type_expr

contract_def = "contract" IDENT (":" IDENT)? "{" node* "}"
node         = in_node | compute_node | branch_node
             | compose_node | out_node

in_node      = "in"      IDENT ":" type_expr ("=" expr)?
compute_node = "compute" IDENT "=" expr annotation*
branch_node  = "branch"  IDENT "{" arm+ default_arm? "}"
arm          = "on"      expr "=>" expr
default_arm  = "default"      "=>" expr
compose_node = "compose" IDENT "=" IDENT "{" (IDENT ":" expr)* "}"
out_node     = "out"     IDENT "=" expr

annotation   = "@" IDENT ("(" arg_list ")")?

fn_def       = "fn" IDENT "(" param* ")" "->" type_expr "=" expr

expr         = literal | path | call | pipe | block | if_expr | contract_call
pipe         = expr "|>" expr
block        = "{" stmt* "}"
contract_call = IDENT "{" (IDENT ":" expr)* "}"
```

**Complete program example:**

```
type Vendor {
  id:    Id
  name:  String
  slots: [Slot]
}

type Slot {
  time:      DateTime
  zip:       Zip
  available: Bool
}

fn parse_vendor(data: Json) -> Vendor = Vendor {
  id:    data.id
  name:  data.name
  slots: data.slots |> each(Slot.parse)
}

contract PriceQuote {
  in vendor_id: Id
  in zip_code:  Zip
  in as_of:     DateTime = now()

  compute vendor = http.get("/vendors/{vendor_id}") |> parse_vendor
                   @cache(5min)

  compute slots  = vendor.slots
                     |> select { |s| s.zip == zip_code }
                     |> select { |s| s.available }
                     |> select { |s| s.time > as_of }
                   @coalesce

  branch result {
    on slots.count > 0 => AvailableQuote { slots: slots, vendor: vendor }
    default            => EmptyQuote     { vendor: vendor }
  }

  out quote  = result
  out vendor = vendor
}

contract FullOrder {
  in order_id: Id

  compose order   = FetchOrder    { id: order_id }
  compose pricing = PriceQuote    { vendor_id: order.vendor_id,
                                    zip_code:  order.zip }
  compose stock   = InventoryCheck { vendor_id: order.vendor_id }

  out confirmed = merge(pricing.quote, stock.availability)
}
```

---

## 5. Turing Completeness

### 5.1 The DAG Is Not Turing-Complete — and That Is Intentional

An acyclic graph computes a strictly bounded class of functions. No cycle → no non-trivial recursion → no Turing completeness. This is not a deficiency; it is a property: **DAG-contracts always terminate**. They fall in (at most) PTIME and may admit static proofs of resource bounds, absence of infinite loops, and full graph observability.

For the target domain — business workflows, financial logic, compliance pipelines — guaranteed termination is a feature worth preserving.

### 5.2 Three Paths to Completeness

**Path A — Recursive contracts**

A contract may call itself. The DAG unfolds into a call tree; termination is a property of the input, not the language.

```
contract Fibonacci {
  in n: Int

  branch result {
    on n <= 1 => n
    default   => Fibonacci { n: n-1 }.value
              +  Fibonacci { n: n-2 }.value
  }

  out value = result
}
```

**Path B — Explicit iteration node**

A single looping construct; the rest of the graph remains acyclic. Turing-complete when the termination condition is unrestricted.

```
compute primes = iterate(seed: 2, acc: []) { |n, acc|
  next:       next_candidate(n)
  accumulate: acc + [n] when is_prime(n)
  until:      n > limit
}
```

**Path C — Streaming / coinductive contracts**

A contract whose input is a stream unfolds indefinitely. Turing-complete through corecursion.

```
contract LivePricing {
  in vendor_id: Id
  stream events: PriceEvent

  compute quote = fold(events, initial_quote) { |state, event|
    update_quote(state, event)
  }

  out quote = quote
}
```

### 5.3 Recommended Strategy

Ship a **Turing-incomplete DAG core** (guaranteed termination, static analysis, full observability). Add completeness as explicit opt-in extensions: `iterate`, recursive contracts, stream inputs. Users who need loops declare them explicitly; the rest of the program retains its safety properties.

---

## 6. Formal Placement

### 6.1 Nearest Academic Relatives

| Model | Similarity | Difference |
|-------|-----------|------------|
| Kahn Process Networks (1974) | data flows along edges, processes in nodes | KPN nodes are infinite loops; contract nodes are single-shot |
| Call-by-need λ-calculus | lazy evaluation, sharing | dependencies in λ are implicit; in contracts they are explicit and named |
| Lustre / Esterel | synchronous dataflow for safety-critical systems | oriented toward hardware/embedded; no composition or caching model |
| FRP / Elm | reactive dataflow | focused on UI event streams; no compile-time graph validation |
| Self-Adjusting Computation (Acar 2002) | incremental re-evaluation on input change | no explicit graph declaration; change propagation is automatic but opaque |

### 6.2 What Is Novel

The combination is not found in existing work:

1. **Named intermediate results** — every node has a stable identity, enabling introspection, diffing, and provenance tracking
2. **Compile-time graph validation** — topology errors are caught before execution
3. **Structural caching annotations** — `@cache`, `@coalesce` as first-class graph attributes, not runtime hints
4. **First-class composition** — contracts compose structurally, not by calling each other's methods
5. **Business domain orientation** — designed for workflow, not scientific computation or UI rendering

The central claim:

> The contract model reifies the *structure of computation* as the program.
> The graph IS the code. Introspection is not a debug tool — it is the primary
> representation.

---

## 7. Why Ruby DSL Is Not the Final Form

Three concrete limitations:

**7.1 Wrapper tax on every node**
Each `compute` requires a class, inheritance, and a `call` method. That is a structural tax imposed by the host language, not by the domain.

**7.2 Expressions are not first-class at nodes**
`call:` accepts only a class reference. Lambda support exists but is a second path, not the primary one — and anonymous callables lose introspection.

**7.3 Types are decorative, not structural**
`type:` in `input` / `output` is metadata for validation and documentation. It does not flow through graph edges as a static type, so the compiler cannot infer that a node returning `Money` feeds into a node expecting `Numeric` — that inference only happens at runtime.

A contract-native language addresses all three: inline expressions, no wrapper classes, type inference along edges.

---

## 8. Open Research Questions

1. **Effect typing**: how to type IO nodes without monadic overhead? Algebraic effects (OCaml 5, Koka) are the most promising direction.

2. **Dynamic topology**: `branch` breaks static topology — the subgraph selected is only known at runtime. How to type union-of-graphs at the branch site?

3. **Cache transitivity**: if `PriceQuote` caches `vendor` for 5 minutes and `FullOrder` composes `PriceQuote` — how do cache policies propagate across composition boundaries?

4. **Density measurement**: the SIR metric needs a reference corpus. Proposal: rewrite 10 examples from `examples/` in the new syntax, measure LOC, SIR, and cyclomatic complexity against the Ruby originals.

5. **Runtime reuse**: can a parser targeting the contract-native syntax compile directly to Igniter's `CompiledGraph` and run on the existing Ruby runtime? This would yield a working prototype without a new VM.

---

## 9. Practical Path to a Prototype

The fastest way to test the hypothesis without writing a full compiler:

**Step 1 — Parser over Ruby** (~500 lines)
A PEG or hand-written parser for the compact syntax, emitting `ContractBuilder` calls. Shares the entire Igniter runtime.

**Step 2 — Inline expressions**
Add support for `compute :x = expr` where `expr` is a minimal expression language (path, pipe, block). Compiles to an anonymous lambda.

**Step 3 — Density measurement**
Rewrite 5–10 existing examples; measure SIR, LOC, and cognitive complexity.

**Step 4 — Type inference** (if hypothesis confirmed)
Add static type inference along edges. This is the boundary into full language work — a type checker over the DAG, operating at compile time.

---

## Summary

The Igniter contract model is **a strong theoretical foundation** for a new language. The semantic core already exists in the DSL and compiler. The information-density hypothesis is formally grounded: moving from object-level (executor classes) to process-level (inline expressions at nodes) eliminates a systematic host-language tax and should increase semantic density measurably.

The DAG core provides guaranteed termination as a default safety property. Turing completeness is achievable through explicit opt-in extensions. The combination of named intermediates, compile-time graph validation, and structural caching is not found together in existing dataflow languages.

The most critical open question is not feasibility but expressiveness: how far can a minimal expression language inside nodes go before it needs to become a full language? That is an empirical question. The prototype path above answers it at low cost.
