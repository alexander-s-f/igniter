# Contracts Migration Roadmap

This note tracks the practical migration from legacy `igniter-core` /
`igniter/extensions/*` surfaces toward `igniter-contracts` and public packs.

It is intentionally more tactical than
[igniter-contracts-spec.md](./igniter-contracts-spec.md): it answers "where are
we now, what is still open, and what should come next?"

## Current State

The new target shape is now real, not hypothetical:

- `igniter-contracts` is its own implementation package and does not depend on
  `igniter-core`
- `igniter-core` remains in the monorepo only as a legacy reference and
  comparison baseline
- legacy `igniter/core` and legacy `igniter/extensions/*` entrypoints warn by
  default and can fail fast with `IGNITER_LEGACY_CORE_REQUIRE=error`
- `igniter-extensions` now has a contracts-facing lane that installs packs only
  through public `Igniter::Contracts` APIs

## Migration Snapshot

### Closed Or Explicitly Replaced

These legacy activators now have a clear contracts-side replacement:

- `igniter/extensions/execution_report`
  `Igniter::Extensions::Contracts::ExecutionReportPack`
- `igniter/extensions/dataflow`
  `Igniter::Extensions::Contracts::DataflowPack`
- `igniter/extensions/incremental`
  `Igniter::Extensions::Contracts::IncrementalPack`
- `igniter/extensions/provenance`
  `Igniter::Extensions::Contracts::ProvenancePack`
- `igniter/extensions/saga`
  `Igniter::Extensions::Contracts::SagaPack`

These are already reflected in:

- `packages/igniter-extensions/lib/igniter/extensions/legacy.rb`
- runnable migration examples under `examples/contracts/`
- package specs and load-time warning specs

### Semantically Covered But Not Yet A Named Pack

These behaviors already have a contracts-side story, but not yet a dedicated
pack or drop-in migration package:

- `igniter/extensions/introspection`
  now mostly maps to `CompilationReport`, `ValidationReport`,
  `DiagnosticsReport`, and structured `to_h` exports
- parts of diagnostics/auditing are already partially covered by
  `ExecutionReportPack`, `ProvenancePack`, and the journal/effect-executor lane

This means the architecture direction is clear, but migration ergonomics are
still weaker than for the explicit replacement packs above.

### Still Open Legacy Surfaces

These entrypoints still point to a direction, not a finished replacement:

- `igniter/extensions/auditing`
- `igniter/extensions/capabilities`
- `igniter/extensions/content_addressing`
- `igniter/extensions/differential`
- `igniter/extensions/invariants`
- `igniter/extensions/reactive`

Those are the main remaining migration backlog at the extension boundary.

## What Still Remains Beyond Activators

The migration is not finished just because the activator map is improving.
There are still a few deeper tracks:

- continue replacing legacy root examples with `examples/contracts/*`
  counterparts
- keep using `igniter-core` only as a reference implementation in tests, not as
  an implementation dependency
- keep extracting host-side orchestration helpers into packs instead of adding
  more implicit runtime patching
- eventually decide which current legacy examples are:
  contracts-targeted,
  upper-layer machine/cluster stories,
  or intentionally legacy-only references

In practice this means the next phase should probably focus less on generic
infrastructure and more on finishing the remaining migration candidates one by
one.

## DebugPack Idea

`DebugPack` looks promising, but it should be shaped carefully.

### Why It Makes Sense

We now already have several useful debugging-oriented building blocks:

- `ExecutionReportPack`
- `ProvenancePack`
- `JournalPack`
- structured `CompilationReport`
- structured `DiagnosticsReport`
- structured `ExecutionResult`
- explicit `IncrementalPack` / `DataflowPack` result objects

So there is already enough material for a coherent debugging bundle.

### What DebugPack Should Be

My recommendation is:

- `DebugPack` should start as an opt-in debugging bundle in
  `igniter-extensions`
- it should primarily be a diagnostics and observability pack
- it should not change business semantics
- it should be safe to enable locally in development and tests
- it should be easy to exclude from production profiles

Good first responsibilities:

- install `ExecutionReportPack`
- install `ProvenancePack`
- add a dedicated debug diagnostics contributor that summarizes:
  profile fingerprint,
  pack names,
  outputs,
  state keys,
  validation findings when compilation is invalid
- expose a helper like `explain_debug(result)` or `debug_snapshot(...)`
- optionally compose with `JournalPack` for execution/effect journals

### What DebugPack Should Not Be Yet

I would avoid making it:

- a graph-mutating pack
- a "turn on hidden magic logging everywhere" patch
- a pack that depends on legacy `igniter-core`
- a pack that tries to emulate every old introspection API exactly

### The Important Architectural Constraint

True node-by-node runtime tracing is still not a first-class seam in
`igniter-contracts`.

Today a pack can:

- add diagnostics after execution
- wrap executors
- inspect `ExecutionResult`
- inspect `CompiledGraph`

But a pack cannot yet cleanly observe every operation evaluation step inside the
runtime loop without reaching deeper than we probably want.

So the right staged plan is:

1. `DebugPack` phase 1:
   bundle existing reports, provenance, journals, and debug-oriented summaries
2. if we still want step tracing:
   add an explicit execution observer / trace sink seam to
   `igniter-contracts`
3. `DebugPack` phase 2:
   build node-level traces on that new seam

That keeps the architecture honest.

## Suggested Next Migration Order

If we continue on migration value instead of novelty, I would prioritize:

1. `differential`
   because it fits naturally with debugging, validation, and side-by-side
   comparison
2. `auditing`
   because a clean contracts-side diagnostics/audit story is now close
3. `reactive`
   because it likely wants explicit subscription/report hooks, not runtime
   patching
4. `invariants`
   because it should probably become validator/diagnostics-oriented
5. `capabilities`
   because it likely wants compile-time contracts over global graph patching
6. `content_addressing`
   because it may need a more opinionated effect/runtime cache seam

## Track For User-Created Packs

This now deserves an explicit product/developer story, not just internal
examples.

### Stage 1: App-Local Packs

The easiest starting path should be:

- define a pack module inside the host app
- depend only on `igniter-contracts`
- install nodes / DSL / validators / handlers through the public facade
- keep the pack next to the app code while it is still changing quickly

This is already illustrated by:

- `examples/contracts/build_your_own_pack.rb`
- `examples/contracts/build_effect_executor_pack.rb`
- `examples/contracts/compose_your_own_packs.rb`

### Stage 2: Package-Local Packs In The Monorepo

When the pack is no longer app-private:

- move it into a package like `igniter-extensions`
- give it package-local specs
- add a runnable example
- make its public entrypoint explicit
- avoid depending on `Igniter::Contracts::Assembly` /
  `Igniter::Contracts::Execution` internals

This is the current proving ground for pack architecture.

### Stage 3: Standalone External Gems

Once a pack is stable enough, it should be able to live as its own gem:

- depend on `igniter-contracts`
- optionally depend on `igniter-extensions` only when intentionally composing
  other public packs from there
- expose a clear entrypoint such as:
  `require "my_company/igniter_packs"`
- expose one or more pack constants:
  `MyCompany::IgniterPacks::PaymentsPack`
- optionally expose a small facade like:
  `MyCompany::IgniterPacks.with_defaults`

### Distribution Heuristics

I would explicitly distinguish three kinds of public packages:

- pure feature packs
  new node kinds, validators, handlers, diagnostics contributors
- bundle packs / presets
  coherent combinations of other packs for a use case
- host adapter packages
  Rails or other framework integration that assembles packs for a host

That separation will help avoid re-creating another umbrella by accident.

### Minimum Quality Bar For A Public Pack

Before calling a user pack distributable, I would want:

- public entrypoint requiring only public `Igniter::Contracts` APIs
- package-owned specs
- at least one runnable example
- README with installation and usage
- no dependency on `igniter-core`
- no dependency on internal `Assembly` / `Execution` namespaces
- an explicit statement whether it is:
  production pack,
  experimental pack,
  or debug/dev-only pack

## Recommended Near-Term Docs Track

The next documentation layer should likely be:

1. keep this roadmap updated as migration closes more legacy surfaces
2. add a dedicated user-facing guide for authoring custom packs
3. add a packaging/distribution guide for publishing pack gems
4. add a debugging guide if `DebugPack` becomes real

That would give us:

- internal migration clarity
- external authoring clarity
- a healthier future ecosystem around `igniter-contracts`
