# Igniter-Lang Implementation Delta Report

Status: Research Horizon proposal / implementation delta.

Date: 2026-04-27.

Source: `docs/experts/igniter-lang/igniter-lang-implementation.md`.

Audience: project owner and `[Architect Supervisor / Codex]`.

## Executive Read

The strongest idea in `igniter-lang-implementation.md` is correct:

```text
Ruby DSL first. Grammar later.
```

The current `igniter-contracts` architecture already supports this direction
better than the expert document assumes. DSL keywords, node kinds, validators,
normalizers, runtime handlers, diagnostics, effects, and executors are already
registered through profile-owned packs. That means Igniter-Lang can begin as
additive Ruby DSL packs without a parser, without a new backend, and without
changing existing contracts.

The main correction: not all proposed extension groups are equally
non-invasive. They fall into three buckets:

1. Already present or mostly present.
2. Can be added as metadata/reporting sugar over the current Ruby backend.
3. Require backend/compiler/runtime changes before they are real semantics.

Recommended first move:

```text
Do not build grammar, Rust backend, OLAP runtime, or time_machine runtime first.
Start with a tiny igniter-lang foundation pack:
- type descriptors
- verification report shape
- invariant metadata
- store declarations as manifest/report only
- deadline/wcet declarations as metadata only
```

This gives real language-design evidence without committing to new execution
semantics too early.

## Current Foundation In The Codebase

### Contracts Kernel

The baseline DSL already exists in `igniter-contracts`:

- `input`
- `const`
- `compute`
- `effect`
- `output`

The implementation is pack-owned:

- `packages/igniter-contracts/lib/igniter/contracts/assembly/baseline_pack.rb`
- `packages/igniter-contracts/lib/igniter/contracts/execution/builder.rb`
- `packages/igniter-contracts/lib/igniter/contracts/execution/compiler.rb`
- `packages/igniter-contracts/lib/igniter/contracts/execution/runtime.rb`

Important existing seams:

- `Assembly::Kernel` installs packs before finalization.
- `Assembly::Profile` freezes DSL keywords, node kinds, validators, runtime
  handlers, diagnostics, effects, and executors.
- `Execution::Operation` stores arbitrary attributes.
- `Execution::Compiler` already runs normalizer and validator hooks.
- Runtime dispatches by operation kind through profile runtime handlers.

This is exactly the shape needed for Ruby DSL as reference implementation.

### Existing DSL / Pack Coverage

Already present through baseline or extensions:

- class DSL via `Igniter::Contract.define`
- block compilation via `Igniter::Contracts.compile`
- `lookup` / `project` style path access lowered to `compute`
- `branch` lowered to `compute`
- `count`, `sum`, `avg` aggregate helpers lowered to `compute`
- `compose` as nested contract execution
- `collection` as keyed item graph execution
- `effect` adapter seam
- diagnostics contributors
- content addressing, capabilities, audit, provenance, incremental/dataflow,
  differential, reactive, saga packs
- external invariant suites and case verification

The project already has the "DSL sugar compiles to clean form" pattern.

### Current Gaps

Missing or incomplete relative to the Igniter-Lang frontier:

- no `Igniter::Lang` namespace
- no explicit `Backend` interface
- no `VerificationReport` dedicated to language-level verification
- no type descriptor model for `History[T]`, `BiHistory[T]`, `OLAPPoint`, or
  `Forecast[T]`
- baseline type validator is currently a no-op
- no graph-level metadata manifest for stores/deadlines/invariants
- no warnings channel in `ExecutionResult`
- invariant support is external to contract definition, not a contract DSL node
- no `store` declaration
- no `olap` node kind
- no `rule` / temporal rule declaration
- no `deadline:` contract option or `wcet:` compute metadata behavior
- no `time_machine` node or forecast runtime
- no formal export backend

## Bucket 1: Already Exists Or Mostly Exists

### DSL Assembly Model

Already exists:

```ruby
kernel = Igniter::Contracts.build_kernel(SomePack)
profile = kernel.finalize
Igniter::Contracts.compile(profile: profile) { ... }
```

This already satisfies the key implementation strategy: multiple isolated
profiles, pack installation, and frozen profile fingerprints.

Delta:

- Add `Igniter::Lang.with(...)` or `Igniter::Lang.profile(...)` only as a
  convenience wrapper, not as a new composition root.

### Ruby Backend As Reference Semantics

The current Ruby backend is implicit:

- compile: `Igniter::Contracts.compile`
- execute: `Igniter::Contracts.execute`
- validate: `Igniter::Contracts.compilation_report`
- diagnose: `Igniter::Contracts.diagnose`

Delta:

- A thin `Igniter::Lang::Backends::Ruby` adapter can wrap these existing calls.
- It does not need to change compiler/runtime behavior.

### Clean-Form Extension Pattern

Already proven by:

- `LookupPack`
- `BranchPack`
- `AggregatePack`
- `ComposePack`
- `CollectionPack`

These show three patterns useful for Igniter-Lang:

- pure DSL sugar lowered to `compute`
- new node kinds with validators and runtime handlers
- nested compiled graphs carried as operation attributes

Delta:

- Use these patterns as the implementation style guide for every Lang feature.

## Bucket 2: Non-Invasive Additions Over Current Backend

These can be implemented without changing the execution model. They either
create definition-time objects, add metadata, add validators, or produce reports.

### 2.1 `Igniter::Lang` Namespace And Ruby Backend Wrapper

Possible now:

```ruby
require "igniter/lang"

backend = Igniter::Lang::Backends::Ruby.new
artifact = backend.compile(profile: profile) do
  input :amount
  output :amount
end

result = backend.execute(artifact, inputs: { amount: 100 }, profile: profile)
report = backend.verify(artifact)
```

Non-invasive because it wraps existing public APIs.

Caution:

- Do not introduce a separate AST yet. Current `CompiledGraph` and operations are
  enough as reference artifacts until real grammar work starts.

### 2.2 Type Descriptor Objects

Possible now:

```ruby
History[Money]
BiHistory[Kelvin]
OLAPPoint[Money, { region: String, month: Date }]
Forecast[Price]
```

These can be immutable definition-time descriptors used in `type:` metadata:

```ruby
input :price_history, type: History[Money]
```

Non-invasive because current operations preserve arbitrary attributes.

First useful behavior:

- include descriptors in structured dumps
- include descriptors in diagnostics
- add validation that descriptor objects are well-formed

Not yet:

- no storage behavior
- no subtype lattice enforcement
- no automatic historical lookup

### 2.3 `store` Declaration As Manifest Only

Possible now as a DSL keyword that records a declaration into a report, without
runtime storage:

```ruby
store :price_history, History[Money],
  backend: :timeseries,
  partition: :by_product,
  consistency: :causal
```

Implementation options:

- Add a `:store` node kind with `requires_runtime: false`, if node contracts
  allow declaration-only nodes.
- Or add a `store` DSL keyword that records metadata through a diagnostics
  contributor / compilation report extension.
- Or model store declaration as `const` metadata first, but this is less clean.

Non-invasive version:

- `store` appears in a `Lang::StorageManifest`.
- Compiler validates shape.
- Runtime ignores it.

Backend work needed later:

- instantiating adapters
- read/write semantics
- consistency and partition enforcement

### 2.4 Invariant Metadata On Existing Invariant Suites

Current invariant support already exists externally:

```ruby
suite = Igniter::Extensions::Contracts.build_invariants do
  invariant(:total_non_negative) { |total:, **| total >= 0 }
end
```

Non-invasive extension:

```ruby
invariant :total_non_negative,
  label: "TOTAL-001",
  severity: :error,
  message: "Total must be non-negative" do |total:, **|
    total >= 0
  end
```

This can extend `Igniter::Extensions::Contracts::Invariants::Invariant` with
metadata and update reports.

Non-invasive because:

- invariant execution remains external
- contract runtime does not change
- severity can be reported without changing graph execution

Not yet:

- inline `invariant` inside contract body
- warning channel in `ExecutionResult`
- audited override workflow

### 2.5 Deadline And WCET Metadata

Possible now:

```ruby
compute :path_candidate,
  depends_on: [:obstacle_map],
  call: PathPlanner,
  wcet: 5 # milliseconds as plain metadata first
```

Or contract-level metadata via class DSL wrapper:

```ruby
class NavigationStep < Igniter::Contract
  deadline 10

  define do
    ...
  end
end
```

Non-invasive first behavior:

- keep `deadline` and `wcet` in metadata
- produce a critical-path budget report
- warn at verification/report time if declared `wcet` sum exceeds deadline

Not yet:

- runtime timing
- warnings in `ExecutionResult`
- compile-time WCET proof

### 2.6 Physical Unit Value Objects

Possible now as opt-in Ruby value objects/refinements:

```ruby
Kelvin.new(273.15)
Meter.new(10)
```

Non-invasive first behavior:

- type descriptors and invariant examples
- runtime values are plain Ruby objects
- no compiler changes needed for basic usage

Not yet:

- static dimensional analysis
- verified return type checking
- unit algebra integrated with compiler

## Bucket 3: Requires Backend / Compiler / Runtime Work

These should not be presented as "just DSL" because behavior requires deeper
execution semantics.

### 3.1 Real `store` Runtime

Required work:

- storage manifest attached to compiled artifact
- adapter registry
- lifecycle for stores
- read/write operations
- consistency rules
- materialization policies

Likely owner:

- `igniter-contracts` for manifest shape
- `igniter-extensions` or future `igniter-lang` pack for concrete store DSL
- application/cluster layers for host-specific adapters and distributed stores

### 3.2 Inline Contract Invariants

If invariants live inside contract bodies:

```ruby
contract :quote do
  compute :price, ...
  invariant "price > 0", on: :price
end
```

Required work:

- DSL keyword registration
- representation in compiled graph or verification manifest
- dependency validation
- execution/report semantics
- severity policy
- optional warning collection
- override/audit integration

Minimal backend change:

- add invariant manifest and diagnostics only

Full backend change:

- execute invariants during contract run and affect result success/warnings

### 3.3 `olap` Node Type

The proposal's `olap` keyword is not just metadata. It implies reading a
multi-dimensional store and producing an `OLAPSlice`.

Required work:

- new node kind `:olap`
- DSL keyword
- validators for dimensions, slice keys, rollup functions, partition hints
- runtime handler
- source store abstraction
- result object (`OLAPSlice`)
- diagnostics

Can be staged:

1. `olap` declaration manifest only.
2. in-memory Ruby handler over arrays/hashes.
3. adapter-backed handler.
4. cluster scatter-gather much later.

### 3.4 Temporal `rule` Semantics

The current codebase has no contract-level temporal rule system equivalent to:

```ruby
rule :weekend_price do
  applies_to :price
  applies { as_of.saturday? }
  compute { |price| price * 1.15 }
  priority 10
  combines :override
end
```

Required work:

- rule model
- conflict resolution
- applies/priority/combines semantics
- integration point with target node resolution
- diagnostics for rule application
- possibly state/history awareness

This is backend-level semantics, not surface syntax.

Non-invasive precursor:

- declare rules as metadata and produce a rule manifest/report.

### 3.5 `time_machine` And `Forecast[T]`

Backward `as_of` patterns can be modeled manually today, but a real
`time_machine` construct implies:

- standardized historical store read API
- current vs historical input binding
- counterfactual execution mode
- forecast result shape
- uncertainty propagation for approximate forecasts
- diagnostics explaining which time mode was used

This requires backend/runtime semantics after storage/history primitives exist.

### 3.6 Runtime Deadline Monitoring

Runtime timing is feasible in Ruby but requires core result shape changes:

- wrap node execution with timing
- collect timings per operation
- attach warnings or diagnostics
- define behavior on deadline miss
- preserve zero-cost path for normal execution

Current `ExecutionResult` has state, outputs, profile fingerprint, and compiled
graph only. There is no warning channel.

Staging:

1. diagnostics-only declared budget report
2. optional timing executor
3. warning channel in execution result
4. policy-driven escalation

### 3.7 Return Type / Dimension Verification

The current `validate_types` hook is a no-op. Real `return_type:` and unit
dimension checking require:

- type descriptor model
- callable return annotation convention
- node output type propagation
- validators that can compare declared and inferred types
- runtime sampling or static callable metadata

This should begin as declared-type checks, not full inference.

### 3.8 Explicit Backend Interface With AST

A thin Ruby backend wrapper is non-invasive. A true `Backend` interface over
`Igniter::Lang::AST` requires:

- AST node classes
- DSL builder emitting AST rather than directly emitting operations, or a
  reversible operation-to-AST mapping
- compile target abstraction
- export formats

Recommendation:

- delay true AST until at least one real DSL extension exposes friction.
- use `CompiledGraph` and `Operation` as the reference artifact for now.

## Proposed Graduation Plan

### Phase 0: Report-Only Alignment

Docs only:

- accept "Ruby DSL first, grammar later"
- define invasive vs non-invasive buckets
- reject parser/Rust/backend export for now

Deliverable:

- this report

### Phase 1: Lang Foundation Pack

Scope:

- `Igniter::Lang` namespace
- `Igniter::Lang::Backends::Ruby` wrapper over current API
- type descriptors: `History`, `BiHistory`, `OLAPPoint`, `Forecast`
- `VerificationReport` as a read-only report structure
- no new runtime behavior

Verification:

- existing specs pass
- new specs prove existing contracts compile/execute through Ruby backend wrapper
- structured dump includes type descriptor metadata

Risk:

- Low. Mostly additive.

### Phase 2: Metadata DSL Pack

Scope:

- `store` declaration manifest
- invariant metadata extension for external invariant suites
- `deadline` / `wcet` metadata and verification report
- maybe `return_type:` metadata report, not enforcement

Verification:

- compilation report includes storage/invariant/deadline sections
- no runtime behavior changes

Risk:

- Low to medium. Need avoid confusing metadata with enforced semantics.

### Phase 3: First Runtime Semantics

Choose exactly one:

- in-memory `olap` node over local enumerable data
- optional timing executor for deadline observations
- inline invariant manifest + post-run invariant report

Recommended first runtime semantic:

- inline invariant manifest/report, because it reinforces Evidence-First
  Architecture and science-critical validation without requiring storage.

Risk:

- Medium. Requires result/report shape decisions.

### Phase 4: Storage / Temporal / OLAP Runtime

Scope:

- real stores
- historical read API
- `olap` adapters
- `time_machine`

Risk:

- High. This becomes a platform subsystem, not a DSL tweak.

### Phase 5: Grammar / Rust Backend

Only after:

- 2-3 real apps use the Ruby DSL
- friction log is stable for 3-6 months
- a real certification/real-time/export use case exists

## Recommended First Track For Supervisor

Track name:

```text
Igniter-Lang Foundation Pack Track
```

Owner:

- likely `[Agent Contracts / Codex]` with Research Horizon as design input

Scope:

- add `Igniter::Lang` namespace
- add `Backends::Ruby` wrapper
- add immutable type descriptor classes
- add read-only `VerificationReport`
- add docs/examples showing current contracts running through Lang wrapper

Out of scope:

- parser
- `.il` files
- Rust
- store runtime
- OLAP runtime
- time machine
- unit algebra enforcement
- deadline runtime enforcement
- changing existing contract execution

Acceptance criteria:

- existing contract tests pass unchanged
- `require "igniter/lang"` is additive
- backend wrapper delegates to current `Igniter::Contracts` APIs
- type descriptors can be used as operation metadata
- report is inspectable and serializable
- no new production dependency

## Handoff Request

```text
[Research Horizon / Codex]
Track: docs/research-horizon/igniter-lang-implementation-delta-report.md
Status: proposal / needs supervisor filter
Changed:
- Added implementation delta report for docs/experts/igniter-lang/igniter-lang-implementation.md.
Core idea:
- Ruby DSL first is correct and matches current pack/profile architecture.
- Start with Lang foundation + metadata reports, not grammar/backend runtime.
- Separate non-invasive metadata from real backend semantics.
Recommended graduation:
- Consider a narrow Igniter-Lang Foundation Pack Track.
Risks:
- Premature parser/Rust/store/OLAP work would freeze unproven semantics.
- Metadata DSL may overpromise if docs do not mark it as report-only.
Needs:
- [Architect Supervisor / Codex] accept / reject / narrow / assign owner.
```
