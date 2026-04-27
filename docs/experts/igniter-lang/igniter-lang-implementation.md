# Igniter-Lang: Implementation Strategy

*Research Series — Document 12*
*Track: Implementation*

---

## §0 Strategy

**Core decision**: Ruby DSL is the Reference Implementation of Igniter-Lang.
Grammar comes later, once semantics are proven.

This is not a compromise — it is the proven path. TypeScript started as "JavaScript
with types". Kotlin started as "Java with better syntax". In both cases the host
language provided the runtime while the semantics were validated on real code.
The grammar was frozen only when the design stabilised.

For Igniter-Lang:

```
Phase 1 — DSL as language (now)
  Extend the Ruby DSL to express the full Igniter-Lang spec.
  ContractBuilder gains new keywords. Existing contracts unchanged.
  Semantics proven on real applications.

Phase 2 — Replaceable backends (parallel with Phase 1)
  Backend interface made explicit.
  Ruby backend = current runtime, extracted and formalised.
  Rust backend = future, for WCET / real-time / certified export.

Phase 3 — Grammar (when design is stable)
  .il syntax sugar → parser → same AST the DSL builds.
  All backends unchanged. Grammar is a front-end, not a redesign.
```

**Signals that Phase 3 is ready:**
- DSL stable ≥ 3–6 months without breaking changes
- 2–3 real applications written in the DSL
- Friction list for Ruby syntax is concrete and stable (see §4)

Until those signals appear, grammar work is premature optimisation.

---

## §1 Backend Interface

The backend is the only seam between the language and execution. Making it explicit
enables: Ruby today, Rust for real-time tomorrow, formal verification export for
space/medicine the day after.

```ruby
module Igniter
  module Lang
    # Abstract backend. All backends include this module and implement the four methods.
    module Backend
      # Compile an Igniter::Lang::AST node to a backend-specific artifact.
      # For the Ruby backend this produces a frozen CompiledGraph.
      # For a Rust backend this would produce native bytecode.
      # @param  ast  [Igniter::Lang::AST::Contract]
      # @return [CompiledArtifact]
      def compile(ast) = raise NotImplementedError

      # Execute a compiled artifact with the given inputs.
      # @param  artifact [CompiledArtifact]
      # @param  inputs   [Hash]
      # @return [ExecutionResult]
      def execute(artifact, inputs) = raise NotImplementedError

      # Static verification: type-check, invariant analysis, storage manifest,
      # WCET analysis (if deadline: declared), unit dimension check.
      # Returns a VerificationReport regardless of pass/fail; caller decides.
      # @param  ast [Igniter::Lang::AST::Contract]
      # @return [Igniter::Lang::VerificationReport]
      def verify(ast) = raise NotImplementedError

      # Export the AST as a formal artefact for external tooling.
      # @param  ast    [Igniter::Lang::AST::Contract]
      # @param  format [Symbol]  :aadl | :sysml | :tla_plus | :coq | :sbom | :json_schema
      # @return [String]
      def export(ast, format:) = raise NotImplementedError
    end

    module Backends
      # Default backend. Wraps the existing Igniter compilation and runtime pipeline.
      class Ruby
        include Backend
        # compile  → Igniter::CompiledGraph  (existing compiler, unchanged)
        # execute  → Igniter::Runtime::Execution  (existing runtime, unchanged)
        # verify   → extends CompiledGraph with Lang-level checks
        # export   → raises NotImplementedError for non-Ruby formats (for now)
      end

      # Future. Rust extension via Magnus FFI.
      # compile  → native bytecode
      # verify   → WCET analysis, physical unit dimension check
      # export   → AADL, TLA+, Coq
      # class Rust; include Backend; end
    end
  end
end
```

**Selection**: the backend is configured globally or per-contract:

```ruby
Igniter::Lang.configure do |c|
  c.backend = Igniter::Lang::Backends::Ruby.new   # default
end

# Per-contract override (useful for certified export of critical contracts):
contract :thermal_control, backend: :rust do
  ...
end
```

---

## §2 DSL Extension Catalog

Eight groups of extensions. Each group is independent; they can be shipped
incrementally. Priority order matches the roadmap in §5.

---

### Group 1 — Temporal Type Objects

New Ruby objects representing `History[T]`, `BiHistory[T]`, and the type hierarchy
`T ⊑ History[T] ⊑ BiHistory[T]`.

```ruby
# Type constructors — used as type annotations in contract DSL
History   = Igniter::Lang::Types::History    # History[T] via History[Money]
BiHistory = Igniter::Lang::Types::BiHistory  # BiHistory[T]
OLAPPoint = Igniter::Lang::Types::OLAPPoint  # OLAPPoint[T, dims]
Forecast  = Igniter::Lang::Types::Forecast   # Forecast[T] for time-travel forward

# Generic syntax — History[Money] calls History.[] (existing Ruby idiom)
# No new syntax needed; pure Ruby.

# Examples:
input :price_history, History[Money]
input :telemetry,     BiHistory[Kelvin]
```

`History[T]` is not just a marker — it carries the access-pattern contract that
informs the backend's storage requirements manifest.

---

### Group 2 — `store` Declaration

New top-level DSL keyword, usable outside or inside a contract block.

```ruby
# Top-level store (shared across contracts in a namespace):
store :price_history, History[Money],
  backend:        :timeseries,
  partition:      :by_product,
  consistency:    :causal,
  replicas:       3,
  seal_after:     { size: 10_000, time: 1.hour },
  write:          :single_writer,
  write_conflict: :last_wins

store :revenue_cube,
      OLAPPoint[Money, { product: String, region: String, month: Date }],
  backend:         :columnar,
  partition:       :by_month,
  source:          :orders,
  materialization: :incremental,
  lag:             30.seconds

store :workflow_log, ExecutionState,
  backend:     :log,
  retention:   90.days,
  idempotency: :content_addressed
```

The `store` declaration feeds the compiler's storage requirements manifest.
The Ruby backend passes the manifest to the runtime for adapter instantiation.

---

### Group 3 — `invariant` Extensions

Extend existing `invariant` DSL with `label:`, `severity:`, and `overridable_with:`.

```ruby
# Current (already works):
invariant "price > 0", on: :price

# Extended:
invariant "price > 0",
  on:       :price,
  label:    "PRICE-FLOOR-01",          # traceability to requirements doc
  severity: :error,                    # :error (raises) | :warn (logs) | :log (metric)
  message:  "Price must be positive"

# Overridable invariant (medicine / aviation — human override with audit):
invariant "interactions.none? { |i| i.severity == :contraindicated }",
  on:               :interactions,
  label:            "CG-INTERACTION-01",
  severity:         :error,
  overridable_with: :documented_justification   # override stored in BiHistory audit trail
```

`severity: :warn` does not raise — it attaches a `Warning` object to the
`ExecutionResult`. The caller decides whether to present, block, or log.

---

### Group 4 — `olap` Node Type

New node type in `ContractBuilder`. Declares that a node reads from an
`OLAPPoint` store and produces an `OLAPSlice`.

```ruby
contract :monthly_revenue do
  input :year, Integer

  olap :revenue, OLAPPoint[Money, { product: String, region: String, month: Date }],
    slice:     { year: :year },          # filter dimension
    rollup:    :sum,                     # aggregation
    partition: :by_region                # fanout hint for cluster scatter-gather

  compute :top_products, with: [:revenue], call: TopProductsAnalyzer

  output :by_region, from: :revenue
  output :leaders,   from: :top_products
end
```

The backend receives the `olap` node and knows to:
- For Ruby backend: execute against the configured columnar store
- For Rust backend: generate a parallel scatter-gather execution plan

---

### Group 5 — `rule` DSL Clarification

The temporal rule system exists; this is a clarification and stabilisation of the
API. No breaking changes — additive only.

```ruby
# Full rule declaration (stabilised API):
rule :weekend_manager_price do
  applies_to :price                     # which contract node this rule modifies
  applies:   -> { as_of.saturday? || as_of.sunday? }
  compute:   -> (price) { price * 1.15 }
  priority:  10
  combines:  :override                  # :override | :additive | :clamp_min | :clamp_max
end

# Probabilistic rule (from temporal-deep spec):
rule :demand_surge_price do
  applies_to :price
  ~applies:  -> { demand_model.surge_probability(as_of) }   # ~ prefix = probabilistic
  compute:   -> (price) { price * 1.30 }
  priority:  20
end

# Synthesised rule (compiler generates from goal):
synthesize rule :optimal_discount do
  goal:     "revenue.maximise subject_to: margin >= 0.20"
  template: -> (price) { price * (1 - discount_rate) }
end
```

---

### Group 6 — Physical Unit Types

Value objects representing physical units. Unit algebra at the Ruby object level;
compile-time dimension check in the backend verifier.

```ruby
module Igniter::Lang::Units
  # Base unit types — immutable value objects wrapping Numeric
  Kelvin  = Data.define(:value) { def +(other) = Kelvin.new(value + other.value) }
  Meter   = Data.define(:value)
  Second  = Data.define(:value)
  Kilogram = Data.define(:value)
  Newton  = Data.define(:value)   # kg⋅m/s²

  # Convenience constructors on Numeric:
  #   250.kelvin  →  Kelvin.new(250)
  #   9.81.meter_per_second_squared  →  Acceleration(9.81)
  refine Numeric do
    def kelvin   = Kelvin.new(self)
    def meter    = Meter.new(self)
    def kilogram = Kilogram.new(self)
    def newton   = Newton.new(self)
  end
end

# In a contract:
input  :temperature, Kelvin
input  :mass,        Kilogram

invariant "temperature.value >= 0.0",   # physically meaningful constraint
  on: :temperature, label: "THERMO-01"

compute :force, with: [:mass, :acceleration],
  call:        ForceCalc,
  return_type: Newton    # backend verifier checks F = ma dimensional consistency
```

The backend `verify` pass checks dimensional consistency: if `ForceCalc` is declared
to return `Newton` but the implementation returns `Kilogram`, that is a type error at
verification time, not runtime.

---

### Group 7 — `deadline:` Contracts

Real-time execution contracts. Compile-time WCET analysis in the Rust backend;
runtime deadline monitoring in the Ruby backend.

```ruby
# Contract-level deadline:
contract :navigation_step, deadline: 10.milliseconds do
  # Compute nodes declare WCET (worst-case execution time) as documentation for now,
  # enforced by Rust backend when available:
  compute :obstacle_map,     with: [:sensor_fusion], call: ObstacleMapper,   wcet: 2.milliseconds
  compute :path_candidate,   with: [:obstacle_map],  call: PathPlanner,       wcet: 5.milliseconds
  compute :velocity_command, with: [:path_candidate], call: VelocityController, wcet: 1.millisecond

  # Ruby backend: measures actual wall time, emits :deadline_exceeded warning if over
  # Rust backend: static WCET analysis at compile time — rejects if critical path > deadline
  ...
end
```

Ruby backend behaviour on deadline miss: attaches `DeadlineMissed` warning to
`ExecutionResult`. Does not raise by default (degraded-mode operation). Caller may
escalate to error. Rust backend fails at compile time if static analysis shows
critical-path WCET exceeds deadline.

---

### Group 8 — `time_machine` and `Forecast[T]`

From the OLAP document. Declarative time-travel and forward projection.

```ruby
# Backward (already expressible via as_of; this makes it explicit):
time_machine :price_rewind, on: :price do
  backward { |t| price_history[:as_of t] }
end

# Forward — three modes:
time_machine :price_forecast, on: :price do
  forward :deterministic do
    # Mode 1: apply known future rules (e.g. scheduled price changes)
    apply_rules_scheduled_after: as_of
  end

  forward :counterfactual do |scenario|
    # Mode 2: what-if — substitute inputs
    with_inputs: scenario.overrides
  end

  forward :approximate do
    # Mode 3: trend extrapolation → returns Forecast[T]
    extrapolate: :linear, horizon: 90.days
  end
end
```

`Forecast[T]` is a wrapper: `{ value: ~T, horizon: DateTime, method: Symbol }`.

---

## §3 Existing Infrastructure — What Does Not Change

A key advantage of DSL-first: the vast majority of Igniter is untouched.

| Component | Status | Notes |
|-----------|--------|-------|
| `Igniter::Contract` | Unchanged | Works as today |
| `ContractBuilder` DSL | Extended only | New keywords additive |
| `Compiler::GraphCompiler` | Unchanged | New node types register via existing extension points |
| `Runtime::Execution` | Unchanged | New node types need resolvers |
| `Runtime::Resolver` | Extended | New resolver for `:olap`, `:store`, `:time_machine` node types |
| Actor system | Unchanged | |
| Server / Mesh | Unchanged | |
| All extensions | Unchanged | |

Existing contracts that do not use the new keywords compile and execute identically.
No migration required.

---

## §4 Ruby DSL Friction Points — Grammar Motivation Log

Track these as the DSL evolves. When the list stabilises, it defines the grammar.

| Friction | DSL workaround | Grammar solution |
|----------|----------------|-----------------|
| `History[Money]` — not idiomatic Ruby | `History.of(Money)` alternative | `History<Money>` or `History[Money]` as native syntax |
| Invariant strings have no IDE support | Just strings today | First-class `invariant expr` (not a string) with syntax highlighting |
| `~applies:` with proc syntax | `~applies: -> { ... }` | `~applies { ... }` block syntax |
| Physical unit arithmetic in procs | `Newton.new(m * a)` | Infix: `mass * acceleration : Newton` |
| `compute` return type annotation | `return_type: Newton` kwarg | `compute :force → Newton { ... }` |
| `rule` block inside contract body | Separate top-level declaration | `within contract :x rule :y { ... }` |
| No import / namespace system | Ruby `require` + modules | `import Igniter::Lang::Units::*` |

**Rule**: add to this log whenever a real use case produces awkward DSL. Do not
add entries based on theory. Grammar design is driven by real friction, not aesthetic
preference.

---

## §5 Implementation Roadmap

### Iteration 1 — Foundation (~400 LOC)

- `Igniter::Lang::Backend` module + `Igniter::Lang::Backends::Ruby` wrapper
- `Igniter::Lang::Types::History`, `BiHistory`, `OLAPPoint`, `Forecast` type objects
- `Igniter::Lang::VerificationReport` structure
- `Igniter.lang_backend=` configuration
- Tests: backend interface contract satisfied by Ruby backend

Deliverable: `require "igniter/lang"` loads the foundation; all existing specs pass.

### Iteration 2 — Core DSL Extensions (~600 LOC)

- `store` declaration DSL keyword (Group 2)
- `invariant` extensions: `label:`, `severity:`, `overridable_with:` (Group 3)
- `olap` node type + resolver (Group 4)
- `rule` DSL stabilisation (Group 5)
- Storage requirements manifest emitted by compiler

Deliverable: `store`, `invariant label:`, and `olap` usable in contracts.
`VerificationReport` includes storage manifest and invariant coverage map.

### Iteration 3 — Domain Extensions (~500 LOC)

- Physical unit types: `Kelvin`, `Meter`, `Kilogram`, `Newton` + `Numeric` refinements (Group 6)
- `deadline:` on contracts + `wcet:` on compute nodes (Group 7)
- Ruby backend: runtime deadline monitoring → `DeadlineMissed` warning
- `time_machine` DSL + `Forecast[T]` type (Group 8)

Deliverable: science/robotics/space/medicine DSL sketches from the validation
report are fully runnable on the Ruby backend.

### Iteration 4 — Grammar Front-End (when friction log stabilises)

- Choose parser tool: `Racc` (stdlib, zero deps) vs `Parslet` (cleaner PEG, one dep)
- Parser produces `Igniter::Lang::AST::*` nodes — same structures the DSL builds
- Compiler accepts both AST (from parser) and DSL builder output
- `.il` files usable alongside `.rb` contracts
- All backends unchanged

**Racc** is the default choice: zero new dependencies, proven in Ruby stdlib and
MRI itself. `Parslet` is acceptable if the grammar requires PEG semantics (e.g.
significant whitespace or complex lookaheads).

### Iteration 5 — Rust Backend (when real-time or certification is needed)

- Rust crate: `igniter-lang-compiler` (published separately)
- Ruby gem: `igniter-lang-rust` — Magnus FFI wrapper
- Implements `Backend` interface: `compile`, `verify` (with WCET), `export` (AADL, TLA+)
- Physical unit dimension check at compile time
- `deadline:` contracts verified statically (critical-path WCET ≤ deadline)

---

## §6 Formal Identities from Implementation

The implementation confirms the theoretical identities from earlier documents:

```
ContractBuilder call     ≡  AST node construction
                            (DSL and parser produce identical ASTs)

store declaration        ≡  Contract({}) → Store[T]
                            (store is itself a zero-input contract)

invariant label:         ≡  Named refinement type assertion
                            (label is the type name in the requirements namespace)

Backend.verify(ast)      ≡  Compiler-as-verifier
                            (PTIME for Horn fragment, per invariants doc)

Backend.export(ast, :aadl) ≡  Certified export
                            (compilation artifact IS the formal specification)

Ruby backend             ≡  Reference semantics
Rust backend             ≡  Optimised semantics with same observable behaviour
```

---

## §7 Non-Goals

- **No Ruby monkey-patching on user classes.** All extensions are opt-in via `include`
  or explicit DSL calls. The `Numeric` refinements for units use `refine` (scoped),
  not `class Numeric`.

- **No new runtime objects in the hot path.** `History[T]` and `BiHistory[T]` type
  objects exist only at definition time (compile phase). At runtime, values are
  plain Ruby objects — the type is in the compiled graph, not in every value.

- **No grammar before signals.** Iteration 4 does not start until the friction log
  has been stable for at least one real application. Writing a grammar for a spec
  that is still changing is waste.

- **No Rust backend before real-time or certification use case.** Iteration 5
  requires a concrete use case (a real robotics project, a real space ground system,
  a real medical device certification) to justify the maintenance cost.
