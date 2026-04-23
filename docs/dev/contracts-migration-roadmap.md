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

The current developer-tooling stack is also now real:

- `DebugPack`
  contracts-side observability and pack diagnostics
- `CreatorPack`
  scaffold, workflow, writer, and stateful wizard flow for custom packs
- `McpPack`
  tooling semantics over debug/creator surfaces
- `igniter-mcp-adapter`
  separate transport-facing adapter package over that tooling catalog
- MCP server wrapper and stdio host entrypoint
  in `igniter-mcp-adapter`

That means the current phase is no longer "prove the architecture". The current
phase is:

- finish the remaining migration away from `igniter-core`
- then delete `igniter-core`
- then clean the repo and docs around the post-core world

## Migration Snapshot

### Closed Or Explicitly Replaced

These legacy activators now have a clear contracts-side replacement:

- `igniter/extensions/execution_report`
  `Igniter::Extensions::Contracts::ExecutionReportPack`
- `igniter/extensions/dataflow`
  `Igniter::Extensions::Contracts::DataflowPack`
- `igniter/extensions/differential`
  `Igniter::Extensions::Contracts::DifferentialPack`
- `igniter/extensions/incremental`
  `Igniter::Extensions::Contracts::IncrementalPack`
- `igniter/extensions/provenance`
  `Igniter::Extensions::Contracts::ProvenancePack`
- `igniter/extensions/saga`
  `Igniter::Extensions::Contracts::SagaPack`

These developer-facing lanes are also now established as first-class packages:

- debug / observability
  `Igniter::Extensions::Contracts::DebugPack`
- creator / pack authoring
  `Igniter::Extensions::Contracts::CreatorPack`
- tooling semantics
  `Igniter::Extensions::Contracts::McpPack`
- transport adapter
  `Igniter::MCP::Adapter`

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
- `igniter/extensions/invariants`
- `igniter/extensions/reactive`

Those are the main remaining migration backlog at the extension boundary.

## Scope Finalization Snapshot

The current scope should be considered complete in these areas:

- `igniter-contracts`
  independent implementation package with its own compile/runtime spine
- external packs in `igniter-extensions`
  execution report, provenance, saga, incremental, dataflow, journal, aggregates,
  commerce, creator/debug/tooling
- migration examples
  `examples/contracts/*` now form a real public migration lane
- creator ergonomics
  scaffold, report, workflow, writer, wizard
- MCP-facing tooling
  tool catalog, invocation, creator session flow
- separate adapter package
  `igniter-mcp-adapter`
- transport-ready server wrapper and stdio host
  package-local MCP host surface

So the next work should not reopen these foundations casually. It should focus
on migration closure and repo cleanup.

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

## Core Retirement Track

The end state should be very explicit:

- `igniter-core` is fully removed
- all surviving public stories are expressed through:
  `igniter-contracts`,
  `igniter-extensions`,
  upper-layer machine/cluster/app packages,
  and adapter packages like `igniter-mcp-adapter`
- no package in the target architecture treats `igniter-core` as a dependency
  or implementation crutch

### Retirement Phases

#### Phase 1: Finish Remaining Replacements

Close the remaining legacy extension surfaces:

- `auditing`
- `capabilities`
- `content_addressing`
- `invariants`
- `reactive`

For each one:

- define the contracts-side replacement
- add or extend runnable `examples/contracts/*`
- update `packages/igniter-extensions/lib/igniter/extensions/legacy.rb`
- keep the legacy activator warning message pointing at the replacement

#### Phase 2: Eliminate Remaining Core-Only Public Stories

After activator replacements, inventory the remaining root examples and docs:

- which examples are still intentionally legacy reference only?
- which examples should become contracts/machine/cluster stories instead?
- which docs still describe `igniter-core` as if it were the target package?

The goal of this phase is:

- no important public learning path depends on core-first onboarding
- legacy examples become reference-only or disappear

#### Phase 3: Tighten Boundary Guards

Before deletion, strengthen the repo checks:

- no runtime dependency on `igniter-core` outside the legacy package itself
- no `require "igniter/core"` from target packages
- no `require "igniter-core"` from target packages
- no internal references that quietly reach into core for behavior

At this point `igniter-core` should already be semantically dead, even if the
files still exist.

#### Phase 4: Remove Core Package

Once the previous phases are complete:

- delete `packages/igniter-core`
- remove `igniter-core` dependency edges from gemspecs
- remove remaining legacy activator shims that only existed for transition
- remove `IGNITER_LEGACY_CORE_REQUIRE` compatibility behavior
- update package maps, docs, and READMEs to reflect the post-core package graph

This should be treated as a cleanup phase, not as a design phase.

#### Phase 5: Post-Removal Cleanup

After deletion:

- remove stale migration docs that only explained temporary compatibility
- compress or archive legacy reference material
- simplify examples and README navigation around the new package graph
- rerun architecture docs so they describe the actual repo, not the transitional one

## DebugPack Idea

`DebugPack` looks promising, but it should be shaped carefully.

The deeper design now lives in [DebugPack Spec](./debug-pack-spec.md).

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

1. `auditing`
   because a clean contracts-side diagnostics/audit story is now close
2. `reactive`
   because it likely wants explicit subscription/report hooks, not runtime
   patching
3. `invariants`
   because it should probably become validator/diagnostics-oriented
4. `capabilities`
   because it likely wants compile-time contracts over global graph patching
5. `content_addressing`
   because it may need a more opinionated effect/runtime cache seam

After those are closed, the priority should switch from "new capability" to
"core retirement and cleanup."

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
5. once the remaining legacy surfaces are replaced, write a short
   `core retirement checklist` and use it as the deletion gate for
   `igniter-core`

That would give us:

- internal migration clarity
- external authoring clarity
- a healthier future ecosystem around `igniter-contracts`
