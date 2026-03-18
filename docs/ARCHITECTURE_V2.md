# Igniter v2 Architecture

## Goal

Igniter v2 is a Ruby library for describing business logic as a validated dependency graph and executing that graph with:

- deterministic resolution
- lazy evaluation
- selective invalidation
- transparent events
- optional extensions built on top of the event stream

The core design principle is strict separation between:

- model time: describing the graph
- compile time: validating and freezing the graph
- runtime: resolving the graph against inputs

## Design Principles

1. Small, hard core.
   The kernel should be minimal, strict, and easy to test.

2. Compile first, execute second.
   No runtime should deal with half-built DSL objects.

3. Explicit data flow.
   Dependencies, output exposure, and composition mappings are always declared.

4. Extensions over hooks.
   Auditing, reactions, tracing, and introspection consume runtime events instead of being deeply embedded in execution.

5. Stable identities.
   Nodes should have stable `id`, `path`, and `kind`. Runtime logic must not depend on Ruby object identity alone.

## Layered Architecture

### 1. `Igniter::Model`

Pure compile-time domain objects. No lazy execution, no caching, no observers.

Primary objects:

- `Igniter::Model::Graph`
- `Igniter::Model::Node`
- `Igniter::Model::InputNode`
- `Igniter::Model::ComputeNode`
- `Igniter::Model::OutputNode`
- `Igniter::Model::CompositionNode`
- `Igniter::Model::Dependency`

Responsibilities:

- represent graph topology
- store node metadata
- store dependency declarations
- store source location metadata for diagnostics
- expose graph traversal primitives

Constraints:

- immutable after compilation
- no implicit mutation during runtime

### 2. `Igniter::Compiler`

Transforms draft model definitions into a validated `CompiledGraph`.

Primary objects:

- `Igniter::Compiler::GraphCompiler`
- `Igniter::Compiler::CompiledGraph`
- `Igniter::Compiler::Validator`
- `Igniter::Compiler::ResolutionPlan`

Responsibilities:

- validate node uniqueness
- validate paths and namespaces
- validate dependency references
- detect cycles
- validate composition mappings
- compute topological order
- freeze the result

Compiler output:

- stable node registry by id and path
- dependency index
- reverse dependency index
- topological resolution plan
- output registry

### 3. `Igniter::Runtime`

Executes a compiled graph for one input set.

Primary objects:

- `Igniter::Runtime::Execution`
- `Igniter::Runtime::Resolver`
- `Igniter::Runtime::Cache`
- `Igniter::Runtime::Invalidator`
- `Igniter::Runtime::NodeState`
- `Igniter::Runtime::Result`
- `Igniter::Runtime::ExecutorRegistry`

Responsibilities:

- hold input values
- resolve requested outputs or nodes
- cache node states
- invalidate downstream nodes on input changes
- emit lifecycle events
- expose execution result

Non-responsibilities:

- graph validation
- DSL parsing
- auditing persistence
- reactive policy decisions

### 4. `Igniter::DSL`

Thin syntax layer that produces a graph draft or a builder input for the compiler.

Primary objects:

- `Igniter::DSL::Contract`
- `Igniter::DSL::Builder`
- `Igniter::DSL::Reference`

Responsibilities:

- provide ergonomic declaration syntax
- map user declarations to model/compiler input
- attach source-location metadata for errors

Rules:

- DSL must not contain execution logic
- DSL must not decide invalidation or cache behavior
- DSL should prefer explicit references over `method_missing`

### 5. `Igniter::Events`

Canonical runtime event schema.

Primary objects:

- `Igniter::Events::Event`
- `Igniter::Events::Bus`
- `Igniter::Events::Subscriber`

Responsibilities:

- publish structured execution events
- provide extension point for diagnostics and reactive features

### 6. `Igniter::Extensions`

Optional packages built on top of the event stream and compiled/runtime APIs.

Initial extension namespaces:

- `Igniter::Extensions::Auditing`
- `Igniter::Extensions::Reactive`
- `Igniter::Extensions::Introspection`

## Runtime Boundaries

The runtime is split by responsibility:

- `Execution`: public session object
- `Resolver`: resolves one node using dependencies
- `Cache`: stores `NodeState` by node id
- `Invalidator`: marks downstream nodes stale
- `Result`: output facade for callers
- `Bus`: emits execution events

This is deliberate. The old shape concentrated orchestration, state mutation, notifications, and invalidation in one class. In v2, each concern gets a dedicated object.

## Node Model

Every compiled node should have:

- `id`
- `kind`
- `name`
- `path`
- `dependencies`
- `metadata`

Candidate node kinds for v2:

- `:input`
- `:compute`
- `:output`
- `:composition`

Optional later kinds:

- `:constant`
- `:projection`
- `:group`

### Why reduce node kinds

The kernel should start with the smallest set that explains the execution model clearly. Extra node kinds should be added only when they materially simplify the model rather than encode DSL convenience.

## Composition Strategy

Composition is a first-class node kind.

A composition node:

- references another compiled contract
- defines an input mapping from parent execution to child execution
- returns either a child `Result` or a collection of child `Result` objects

Composition rules:

- parent and child graphs are independently compiled
- child execution has its own cache and event stream
- parent events may carry child execution correlation metadata

## Extension Strategy

Extensions must subscribe to events and read runtime state through stable APIs.

Examples:

- auditing stores a timeline of events and snapshots
- reactive runs side effects in response to selected events
- introspection formats compiled graphs and runtime state

The kernel should not know persistence formats, storage adapters, or replay UIs.

## Error Model

Errors should be typed and predictable.

Primary families:

- `Igniter::CompileError`
- `Igniter::ValidationError`
- `Igniter::CycleError`
- `Igniter::InputError`
- `Igniter::ResolutionError`
- `Igniter::CompositionError`

Compile errors should include source metadata when available:

- contract class
- node path
- line number
- declaration snippet or declaration type

## Packaging Rules

The public surface should be intentionally small:

- `require "igniter"`
- `Igniter::Contract`
- `Igniter.compile`
- `Igniter.execute`

Autoloading must be optional convenience, not a hard dependency for correctness.

The gem must be valid and packageable without:

- a `.git` directory
- Rails
- optional extensions

## Initial Directory Shape

```text
lib/
  igniter.rb
  igniter/
    version.rb
    errors.rb
    contract.rb
    model/
    compiler/
    runtime/
    events/
    dsl/
    extensions/
      auditing/
      reactive/
      introspection/
spec/
  compiler/
  runtime/
  integration/
docs/
  ARCHITECTURE_V2.md
  EXECUTION_MODEL_V2.md
  API_V2.md
```

## Non-Goals for the First Rewrite

These should not block the first working kernel:

- Rails integration
- persistence adapters
- replay UI
- async execution
- distributed execution
- type inference
- speculative optimization

The first target is a strict, reliable, inspectable synchronous engine.
