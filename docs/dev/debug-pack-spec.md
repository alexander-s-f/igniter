# DebugPack Spec

This document defines the target shape for three related developer-facing
layers:

- `DebugPack`
  the observability and debugging foundation
- `CreatorPack`
  the authoring and scaffold workflow built on top of `DebugPack`
- `McpPack`
  the later tooling/protocol adapter layer

The goal is to keep these concerns connected, but not collapsed into one
umbrella.

## Why This Exists

`igniter-contracts` now has enough structure to execute and introspect graphs
cleanly:

- `CompilationReport`
- `ValidationReport`
- `DiagnosticsReport`
- `ExecutionResult`
- `ProvenancePack`
- `ExecutionReportPack`
- `JournalPack`
- `IncrementalPack`
- `DataflowPack`

That means the next leverage point is not "more hidden runtime magic", but
"better developer visibility and better pack-authoring ergonomics".

## Layer Model

The intended stack is:

1. `DebugPack`
   developer observability and pack diagnostics
2. `CreatorPack`
   guided authoring workflow using `DebugPack` primitives
3. `McpPack`
   external tooling/protocol surface over stabilized debug/creator APIs

The ordering matters.

We should not freeze an external protocol before the internal debug and author
experience are coherent.

This ordering has now largely been realized in the repo:

1. `DebugPack`
   implemented as the developer observability and diagnostics bundle
2. `CreatorPack`
   implemented with scaffold, workflow, writer, and wizard layers
3. `McpPack`
   implemented as the tooling semantics surface
4. `igniter-mcp-adapter`
   implemented as the transport-facing adapter package over that surface

That means the design question is no longer "should we build this stack?".
The design question is now "how do we finish migration and retire core cleanly
without reopening the stack design?".

## DebugPack

### Purpose

`DebugPack` should be an opt-in, development-oriented pack that helps answer:

- what packs are installed in this profile?
- what seams are actually present?
- why did compilation fail?
- why did runtime produce this output?
- which inputs contributed to this value?
- what changed across incremental/dataflow updates?
- what is missing from my custom pack?

### Design Goals

- do not change graph semantics
- do not depend on `igniter-core`
- do not require internal `Assembly` / `Execution` namespaces from consumer code
- work as a pack composition layer, not a monkeypatch layer
- remain safe to enable locally in development and tests
- remain easy to exclude from production profiles

### Non-Goals

- not a replacement for domain-specific UI or dashboards
- not a hidden always-on logger
- not a compatibility shim for every legacy introspection API
- not a pack generator by itself
- not a transport/protocol package

### Public Responsibilities

Phase 1 `DebugPack` should bundle and expose:

- profile debug
  pack names, fingerprint, declared registry keys, supported effects/executors
- compile debug
  `CompilationReport`, `ValidationReport`, structured findings
- runtime debug
  `ExecutionResult`, `DiagnosticsReport`, provenance summaries
- pack debug
  manifest visibility, completeness checks, installed DSL keywords, node kinds,
  validators, runtime handlers, diagnostics contributors, effects, executors
- optional journals
  composition with `JournalPack`
- incremental/dataflow summaries
  changed nodes, skipped nodes, diff snapshots, maintained aggregate snapshots

### Recommended Composition

The first implementation should likely compose:

- `ExecutionReportPack`
- `ProvenancePack`
- optionally `JournalPack`

And then add one `DebugPack`-specific contributor/helper layer on top.

### Suggested Public API

At the facade level, something like:

```ruby
require "igniter/extensions/contracts"

environment = Igniter::Extensions::Contracts.with(
  Igniter::Extensions::Contracts::DebugPack
)

report = Igniter::Extensions::Contracts.debug_report(environment) do
  input :amount
  compute :tax, depends_on: [:amount] do |amount:|
    amount * 0.2
  end
  output :tax
end
```

Potential helpers:

- `debug_report(environment, inputs: nil, compiled_graph: nil, &block)`
- `debug_snapshot(result)`
- `debug_profile(profile)`
- `debug_pack(pack_or_name, profile:)`
- `explain_debug(result)`

The important point is that these helpers should return structured, typed data
first and human-readable formatting second.

### Debug Report Shape

The main structured report should probably include:

- `profile`
  fingerprint, pack names, registry keys, supported effects/executors
- `compilation`
  `CompilationReport#to_h`
- `execution`
  `ExecutionResult#to_h` when execution succeeded
- `diagnostics`
  `DiagnosticsReport#to_h`
- `provenance`
  output-level lineage summaries when available
- `pack_debug`
  installed hooks and declared pack contracts
- `journals`
  if `JournalPack` is also present

This can then support:

- text formatter
- markdown formatter
- stable `to_h` / JSON for tooling

### What DebugPack Needs From Contracts

Phase 1 can be built with today’s public surface.

But true step-by-step runtime tracing likely needs a new seam in
`igniter-contracts`.

Good future seam candidates:

- execution observer
- trace sink
- runtime event hooks per operation lifecycle:
  before resolve,
  after resolve,
  cache hit,
  output emit,
  effect apply,
  executor start/finish

`DebugPack` should not reach into runtime internals to fake this. If we want
node-level tracing, we should add an explicit seam first.

## CreatorPack

### Purpose

`CreatorPack` should be a developer workflow layer for creating custom packs.

It is not just scaffolding. It should help a developer move from idea to
working pack with feedback along the way.

### Why It Should Build On DebugPack

Pack authoring immediately runs into debugging questions:

- did my node kind register?
- did my DSL keyword register?
- did I forget a runtime handler?
- are my validators returning the right shaped findings?
- is my pack complete?
- what public seams am I actually using?

Those are `DebugPack` concerns first. That is why `CreatorPack` should be built
on top of debug/report primitives instead of inventing a separate parallel
validation stack.

### Responsibilities

`CreatorPack` should eventually help with:

- pack templates / scaffolding
- completeness validation
- recommended file layout
- README/spec/example generation
- identifying missing seams
- validating hook signatures and return contracts
- suggesting which pack type fits the user’s goal

### Suggested Authoring Flow

The ideal flow looks like:

1. choose the pack kind
   feature pack, bundle pack, debug/dev pack, host adapter
2. choose the capabilities
   node kind, DSL keyword, validator, runtime handler, diagnostics,
   effect/executor
3. generate skeleton
4. run debug validation
5. add runnable example
6. add package-owned specs

### Suggested Public Helpers

Potential facade:

- `CreatorPack.scaffold(...)`
- `CreatorPack.validate(...)`
- `CreatorPack.explain_missing_seams(...)`
- `CreatorPack.example_template(...)`

But phase 1 does not need to implement a wizard yet. A report-driven authoring
assistant would already be enough to prove the direction.

## McpPack

### Purpose

`McpPack` should be a later tooling/protocol layer that exposes stabilized
debug/creator capabilities to external tools, editors, agents, or MCP-based
developer assistants.

### Why It Should Come Later

If we expose MCP too early, we risk freezing:

- unstable debug schemas
- unstable authoring flows
- unstable expectations around pack generation

That would make the protocol the tail wagging the architecture.

So `McpPack` should come only after:

- `DebugPack` report shapes are coherent
- `CreatorPack` authoring flow is coherent
- we know which operations are worth exposing remotely

### Likely Responsibilities

Once ready, `McpPack` could expose tools like:

- inspect profile
- inspect installed packs
- compile and return structured findings
- run and return structured debug snapshots
- scaffold a new pack skeleton
- validate an existing pack against the public quality bar

But again, this should adapt stable APIs. It should not define them.

## Recommended Package Placement

Near-term recommendation:

- `DebugPack`
  lives in `igniter-extensions`
- `CreatorPack`
  also starts in `igniter-extensions`
- `McpPack`
  should probably live separately or as a tooling package once it becomes real

Why:

- `DebugPack` and `CreatorPack` are both optional, developer-facing, and should
  not bloat baseline `igniter-contracts`
- `McpPack` is even more clearly integration/tooling-specific

## Implementation Phases

### Phase 1: Debug Bundle

Build `DebugPack` as:

- bundle pack depending on `ExecutionReportPack` + `ProvenancePack`
- optional composition with `JournalPack`
- structured debug report over:
  profile,
  compilation,
  execution,
  diagnostics,
  provenance,
  installed pack metadata
- runnable example
- package-owned specs

### Phase 2: Pack Diagnostics

Add:

- pack manifest visibility
- installed seam summaries
- "what is missing?" diagnostics for author-defined packs
- authoring-oriented explainers

This is the bridge into `CreatorPack`.

### Phase 3: Creator Workflow

Add `CreatorPack` with:

- pack templates
- authoring validation
- example/spec/README scaffolding hints
- maybe an interactive or semi-interactive wizard later

### Phase 4: Trace Seam

If we still need it after phases 1-3:

- add explicit execution observer / trace sink seam to `igniter-contracts`
- extend `DebugPack` to produce node-level traces

### Phase 5: MCP Adapter

Only after the prior phases stabilize:

- add `McpPack`
- expose debug/creator capabilities through a tooling/protocol surface

## Minimum Success Criteria

I would consider this direction successful when:

- a developer can install `DebugPack` and understand a broken or surprising
  custom pack quickly
- a developer can author a new pack without touching internal namespaces
- examples and docs show a clean path from app-local pack to distributable pack
- `McpPack`, if added later, is mostly a transport adapter over already-stable
  debug/creator APIs

## Relationship To The Migration Roadmap

`DebugPack` is not just a nice-to-have DX tool. It also supports migration.

It should help us replace remaining legacy surfaces such as:

- `differential`
- `auditing`
- `reactive`
- `invariants`

because all of those want stronger observability, diagnostics, and authoring
confidence instead of more global runtime patching.
