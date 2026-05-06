# Igniter-Lang — Language Specification

Version: 0.2 (Stage 1 + Stage 2 reserved)
Maintainer: `[Igniter-Lang Meta Expert]`
Status: living document — updated as PROPs are accepted
Last updated: 2026-05-06

> **This document is a consolidated reference, not the source of truth.**
> For formal decisions, see the canonical PROP documents in `proposals/`.
> Each section below links its authoritative PROP.

---

## How to Navigate

```
Start here          → this file (overview + cross-references)
Formal decisions    → docs/proposals/PROP-001..025+
Strategy            → docs/meta-proposals/META-EXPERT-001..006+
Stage 1 progress    → docs/current-status.md (§ Stage 1 Progress)
```

---

## § 1. Language Identity

Igniter-Lang is an **Epistemic Contract Language** — a language for declaring
computations as validated dependency graphs with provable termination,
structural caching, and observable execution.

**Five formal identities** (from `playgrounds/docs/experts/igniter-lang/igniter-lang-theory.md`):

| Theory | Identity |
|--------|---------|
| Anokhin TFS | Result-oriented system — outputs define structure |
| Attribute Grammars (Knuth 1968) | `compute` = synthesized attribute; `in` = inherited attribute; `resolution_order` = evaluation schedule |
| Concurrent Constraint Programming (Saraswat 1989) | `tell` = compute write; `ask` = guard; confluence = determinism despite concurrency |
| Stratified Datalog | DAG contracts are decidable, PTIME, confluent — `resolution_order` IS the Datalog stratification |
| Category Theory | Contracts form a monoidal category; `compose` = morphism composition |

**Design principle**: The contract model is not a novel construct. It is a
convergent rediscovery of five deep theoretical structures. Building on this
foundation means inheriting decades of optimisation research, formal guarantees,
and extension pathways.

**Authoritative ref**: `PROP-001-semantic-domain-v0.md`

---

## § 2. Fragment Classification

Every construct in a contract belongs to one of three fragment classes.
Classification is **static (Pass 0)** — no runtime information needed.

```
CORE    Decidably valid, provably terminating
        = Stratified Datalog fragment
        = PTIME, confluent, deterministic

ESCAPE  Capability-gated, annotated
        = Declared external dependency (IO, stream, TBackend, FFI)
        = Effect-typed; produces typed receipts
        = Propagates through >> and embed; NOT across ||

OOF     Out-of-fragment violation
        = Compile error: emits failure_observation
        = Never reaches SemanticIR
```

### CORE constructs

| Construct | Notes |
|-----------|-------|
| `in name: Type` | typed parameter (inherited attribute) |
| `compute name = expr` | named expression (synthesized attribute) |
| `branch name { on ... }` | pattern matching / conditional dispatch |
| `compose name = Contract { ... }` | first-class composition |
| `out name = expr` | output declaration |
| `guard expr` | assertion / precondition |
| `const name = value` | constant binding |
| `fn name(params) -> T = expr` | pure function (non-recursive) |
| `type Name { field: Type }` | structural type declaration |
| `fold(xs, init, fn)` | bounded aggregate (TR-1: terminates if xs is Collection[T]) |
| `map(xs, fn)` | structure-preserving transform |
| `filter(xs, pred)` | bounded filter |

### ESCAPE constructs (named vocabulary — closed in v0)

| Escape name | What it covers |
|-------------|---------------|
| `stream_input` | `stream name: Type` — unbounded stream source |
| `bi_temporal` | BiHistory[T] corrections (append + audit) |
| `refinement_predicate` | `T where φ` with arbitrary predicate |
| `causal_clock` | `LogicalTimestamp` / vector clock operations |
| `platform_extension_code` | FFI / Ruby interop / external library calls |
| `soft_real_time` | deadline annotations with wcet: (Stage 3) |

### OOF patterns (compile errors)

```
OOF-S1: fold_stream without @window_bounded or @count_bounded
OOF-S2: stream without window declaration
OOF-S3: ESCAPE inside fold_stream accumulator
OOF-S4: stream value used outside fold_stream
OOF-H1: History[T] access without as_of context
OOF-H2: BiHistory[T] access without explicit (vt, tt) axes
OOF-I4: overridable_with: on severity: :error invariant
```

**Authoritative ref**: `PROP-003-grammar-fragment-classification-v0.md` (+ errata v0.1)

---

## § 3. Type System

### § 3.1 Primitive types

```
Integer    Boolean    String
Float      DateTime   Duration
Decimal[N]            -- fixed-point decimal with N decimal places
```

### § 3.2 Container types

```
Collection[T]          -- finite, bounded sequence
Option[T]              -- Some(T) | None
Result[T, E]           -- Ok(T) | Err(E)
Record { f₁: T₁, ... } -- structural record (anonymous or named)
Variant { case₁: T₁ | case₂: T₂ }  -- tagged union
```

**Authoritative ref**: `PROP-013-stdlib-fold-aggregate-v0.md`, `PROP-004-type-system-v0.md`

### § 3.3 Temporal types (Stage 2)

```
History[T]              -- time-indexed sequence of T values (single axis: valid time)
BiHistory[T]            -- two-axis: valid time × transaction time

-- Subtyping chain:
T  ⊑  History[T]  ⊑  BiHistory[T]

-- Unification:
History[T]  ≡  OLAPPoint[T, {time: DateTime}]
```

**Annotations**:
```
@temporal    -- field/node uses History[T]
@bitemporal  -- field/node uses BiHistory[T]
```

**Authoritative ref**: `PROP-022-history-type-constructor-v0.md`

### § 3.4 Analytical types (Stage 2)

```
OLAPPoint[T, Dims]      -- value T at a point in multi-dimensional space Dims

-- Type rules:
OLAPPoint[T, D][d: v]  →  OLAPPoint[T, D - {d}]   -- slice
OLAPPoint[T, {}]       →  T                         -- fully resolved
```

**Authoritative ref**: `PROP-024-olap-point-primitive-v0.md`

### § 3.5 Probabilistic types (Stage 2 — reserved, PROP-026 pending)

```
~T   -- probabilistic lift: T with confidence metadata
     -- { value: T, confidence: Float, lo: T?, hi: T? }
T ⊑ ~T
```

Generated by `:soft` severity invariants (PROP-025).

### § 3.6 Unit types (Stage 2, via refinement)

```
type Kelvin         = Float where value >= 0.0
type Meter          = Float
type MeterPerSecond = Float   -- semantic alias
-- Full unit algebra (dimensional analysis) → Stage 3
```

**Authoritative ref**: `PROP-004-type-system-v0.md` (errata v0.1, §E5)

### § 3.7 Trait system (Stage 2)

```
trait Numeric   { add, sub, mul, div, neg, compare }
trait Temporal  { as_of, at, rollup, history_until }
trait Foldable  { fold, map, filter, count, first, last }
trait Observable { to_obs_packet }
```

**Implementations**:
```
impl Numeric  for Integer, Float, Decimal[N]
impl Temporal for History[T], BiHistory[T], OLAPPoint[T, Dims]
impl Foldable for Collection[T], History[T], OLAPPoint[T, Dims]
impl Observable for all contract output types
```

**Authoritative ref**: `PROP-016-polymorphism-traits-contract-shapes-v0.md`, `PROP-004` errata v0.1

---

## § 4. Contract Surface

A contract is a named, typed dependency graph:

```
contract Name {
  -- 1. Inputs (in, stream)
  in     field: Type
  stream field: Type     ← ESCAPE

  -- 2. Stores (read)
  read field: Type
    from "path/key"
    lifecycle :durable | :window | :snapshot | :session

  -- 3. Computation (compute, branch, compose, const, fn call)
  compute name: Type = expr
  branch  name { on expr => value ... default => value }
  compose name = Contract { field: expr, ... }
  const   name = literal

  -- 4. Safety (guard, invariant)
  guard expr
  invariant "predicate"
    severity: :error | :warn | :soft | :metric
    label:    "REQ-ID"
    message:  "Human readable message"
    overridable_with: :justification_kind?

  -- 5. Effects (effect)
  effect name,
    depends_on: node_ref,
    call: Callable,
    idempotent: Boolean

  -- 6. Outputs (out)
  out name: Type = expr
    lifecycle :durable?
}
```

**Authoritative ref**: `PROP-001-semantic-domain-v0.md`, `PROP-002-contract-composition-algebra-v0.md`

---

## § 5. Input Kinds

| Keyword | Kind | Fragment | Description |
|---------|------|---------|-------------|
| `in` | value input | CORE | Named typed parameter |
| `read` | store read | ESCAPE | Read from TBackend store with lifecycle |
| `stream` | stream input | ESCAPE | Unbounded stream source; must have window |

**Stream surface** (Stage 2):
```
stream readings: SensorReading

window "sensor/{device_id}" {
  kind:     :count
  size:     100
  on_close: :snapshot
}

compute stats: Stats =
  fold_stream(readings, init, fn) @window_bounded
```

**Authoritative ref**: `PROP-023-stream-input-surface-v0.md`

---

## § 6. Stdlib Primitives

### Collection operations (Stage 1, CORE)

```
fold(xs: Collection[T], init: A, fn: (A, T) -> A) -> A
map(xs: Collection[T], fn: T -> U) -> Collection[U]
filter(xs: Collection[T], pred: T -> Boolean) -> Collection[T]
count(xs: Collection[T]) -> Integer
sum(xs: Collection[T]) -> T           -- requires Numeric[T]
avg(xs: Collection[T]) -> Option[T]   -- None if empty; requires Numeric[T]
min(xs: Collection[T]) -> Option[T]   -- requires Numeric[T]
max(xs: Collection[T]) -> Option[T]   -- requires Numeric[T]
group_by(xs, fn) -> Map[K, Collection[T]]
sort_by(xs, fn) -> Collection[T]
take(xs, n: Integer) -> Collection[T]
first(xs) -> Option[T]
last(xs) -> Option[T]
```

### Stream operations (Stage 2, ESCAPE → CORE)

```
fold_stream(s: stream T, init: A, fn: (A, T) -> A) @window_bounded -> A
fold_stream(s: stream T, init: A, fn: (A, T) -> A) @count_bounded(n) -> A
```

### History[T] operations (Stage 2, CORE if from Store; ESCAPE if from stream)

```
history_at(h, t: DateTime) -> Option[T]
history_avg(h, p: DateRange) -> Option[T]    -- requires Numeric[T]
history_rollup(h, grain: Symbol) -> History[T]
history_until(h, t: DateTime) -> History[T]
history_changes(h) -> Collection[ChangeEvent[T]]
```

### OLAPPoint operations (Stage 2)

```
olap_slice(p, dim, v) -> OLAPPoint[T, D - {dim}]
olap_rollup(p, dim, fn: Symbol) -> OLAPPoint[T, D - {dim}]
olap_drill(p, dim, grain) -> OLAPPoint[T, D]
olap_compare(a, b) -> OLAPPoint[T, D]
olap_resolve(p: OLAPPoint[T, {}]) -> T
```

**Authoritative ref**: `PROP-013-stdlib-fold-aggregate-v0.md` (+ errata v0.1)

---

## § 7. Annotations

| Annotation | Applies to | Meaning |
|-----------|-----------|---------|
| `@cache(ttl)` | compute node | Cache result for `ttl` duration |
| `@coalesce` | compute node | Deduplicate concurrent requests |
| `@temporal` | field, node, store | Tracks History[T] |
| `@bitemporal` | field, node, store | Tracks BiHistory[T] |
| `@window_bounded` | fold_stream | Bounded by window declaration |
| `@count_bounded(n)` | fold_stream | Bounded by count n |
| `@confidence(f)` | compute node | Declares output confidence (0.0..1.0) |
| `@requires Trait[T]` | compute node | Trait constraint assertion |
| `@exact` | expression | Force ~T → T resolution |
| `@best_effort(fallback)` | expression | ~T → T with fallback |

---

## § 8. Invariants

```
invariant "predicate expression"
  severity:         :error | :warn | :soft | :metric
  label:            "REQ-ID"?
  message:          "Human description"?
  overridable_with: :justification_kind?
```

**Severity semantics**:

| Severity | Predicate false | Output | ObsPacket |
|----------|-----------------|--------|-----------|
| `:error` (default) | raises `InvariantViolation` | none | `failure_observation` |
| `:warn` | continues | T + `warnings: [...]` | `warning_observation` |
| `:soft` | continues | `~T` (uncertain) | `soft_observation` |
| `:metric` | continues | T (unaffected) | `metric_observation` |

**Authoritative ref**: `PROP-025-invariant-severity-levels-v0.md`

---

## § 9. Module System

```
module Name {
  fn name(params) -> T = expr        -- pure function (non-recursive, CORE)
  type Name { field: Type }          -- structural type declaration
  olap_point Name { ... }            -- analytical node declaration (Stage 2)
  import "module/path"               -- module import
}
```

**Authoritative ref**: `PROP-015-grammar-module-system-v0.md`

---

## § 10. Compiler Pipeline

```
source.ig
  ↓ Parser          (Parse → ParsedProgram)         PROP-014, PROP-018
  ↓ Classifier      (Pass 0: CORE/ESCAPE/OOF mark)  PROP-003, PROP-020
  ↓ TypeChecker     (Pass 1: structural resolution)  PROP-004, PROP-021
  ↓ SemanticIR Emitter (ClassifiedAST → SIR)        PROP-019, PROP-019.1
  ↓ .igapp/ Assembler  (SIR → deployment bundle)    PROP-012

CompilationReport   (errors, warnings, artifact location)
SemanticIRProgram   (loadable if report.status == :ok)
```

**Stage 1 proven**: Classifier ✓, SemanticIR Emitter (canonical envelope) ✓
**Stage 1 in flight**: golden file migration, .igapp/ assembler, TypeChecker, stdlib execution

**Authoritative ref**: `PROP-018`, `PROP-019.1`, `PROP-020`, `PROP-021`

---

## § 11. Runtime Machine

```
RuntimeMachine.load(path)         → LoadedProgram | LoadError
RuntimeMachine.evaluate(program, inputs)  → EvaluationResult
RuntimeMachine.checkpoint(program)        → CheckpointBundle  (ESCAPE)
RuntimeMachine.resume(bundle)             → LoadedProgram     (ESCAPE)
```

**CORE evaluation**: bottom-up Datalog evaluation over the dependency graph.
Parallel node resolution (thread-pool runner). Structural caching (`@cache`, `@coalesce`).

**Authoritative ref**: `PROP-011-runtime-machine-lifecycle-v0.md`, `PROP-006`

---

## § 12. Extension Roadmap

### Stage 1 (in flight)

```
[ ] golden file migration (source_to_semanticir PASS gate)
[ ] .igapp/ Assembler proof
[ ] TypeChecker proof (PROP-021)
[ ] Stdlib execution (numeric + fold + collection)
```

### Stage 2 (spec complete — awaiting Stage 1 close)

```
History[T] as type constructor      PROP-022 ✓
stream T surface form               PROP-023 ✓
OLAPPoint[T, Dims] primitive        PROP-024 ✓
Invariant severity levels           PROP-025 ✓
~T probabilistic types              PROP-026 (pending)
```

### Stage 3 (theoretical, not yet specified)

```
BiHistory[T] full implementation    (connect to TBackend)
Deadline contracts + WCET           (compile-time critical path analysis)
Full unit algebra                   (dimensional type checking)
Plastic Runtime Cells               (ownership + migration)
Rule synthesis via LP               (goal-directed rule generation)
Igniter Plane                       (graph canvas visualization)
Uplink-able rule declarations       (serializable rule format)
```

**Authoritative ref**: `META-EXPERT-006-language-model-revision-v0.md`
