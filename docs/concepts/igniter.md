# Igniter: Concepts and Principles

This document describes the core ideas behind Igniter in the shortest possible form.
For the filesystem and layer map, start with [Architecture Index](./ARCHITECTURE_INDEX.md).

## What is Igniter?

**Igniter** is a Ruby framework for expressing business logic as a **validated dependency graph**.

Instead of writing one long imperative flow, you describe:

- the required inputs
- the derived computations
- the exposed outputs
- the dependencies between them

Igniter then compiles that graph, validates it, and executes it lazily at runtime.

The central separation is:

- **what** the graph is: model + DSL + compiler
- **how** values are produced: runtime + executors

## Philosophy

1. **Declarative structure, imperative logic.**
   Graph structure is declared with a constrained DSL. The actual business logic stays in normal Ruby.

2. **Explicit dependencies.**
   Data flow is always declared. If node `A` depends on node `B`, that relationship should be visible in code.

3. **Compile first, execute second.**
   Contracts are validated and frozen before runtime starts. Execution should never operate on a half-built graph.

4. **Lazy and inspectable runtime.**
   Igniter resolves only what is needed, caches resolved nodes, and keeps execution observable through events, diagnostics, and introspection.

5. **Optional layers over a hard core.**
   Core contracts stay the same whether you use embedded mode, AI features, server hosting, or a cluster.

## Core Concepts

### Contract

The main unit of work in Igniter.

A contract is a class inheriting from `Igniter::Contract`. It defines:

- inputs
- compute nodes
- outputs
- optional composition, routing, collections, effects, and reactive behavior

### Definition graph

The static blueprint of a contract.

It is created once when the class is loaded inside the `define do ... end` block.
The compiler validates this graph and produces a frozen compiled representation.

### Execution

The live runtime session for one input set.

An execution owns:

- current inputs
- node states
- cache
- event stream
- resolution behavior

### Nodes

The building blocks of the graph. Common DSL node types are:

- `input` — external data entering the graph
- `compute` — derived value or delegated executor call
- `output` — public result exposed by the contract
- `compose` — nested contract execution
- `branch` — declarative runtime routing
- `collection` — fan-out over an array of item inputs
- `await` — suspend until an external event arrives
- `effect` / reactive hooks — side effects driven by runtime events

## Contract Lifecycle

1. **Definition**
   Ruby loads the contract class and executes `define do ... end`.

2. **Compilation**
   Igniter validates the graph and freezes the compiled form.

3. **Initialization**
   `MyContract.new(inputs)` creates a contract instance and its `Runtime::Execution`.

4. **Resolution**
   A result reader such as `contract.result.total` or `contract.resolve_all` triggers lazy resolution of only the required nodes.

5. **Observation**
   Events, diagnostics, audit snapshots, and introspection tools expose what happened during execution.

6. **Update and invalidation**
   `contract.update_inputs(...)` marks affected downstream nodes stale. Re-computation happens only when values are requested again.

## Architectural View

Igniter is intentionally layered:

- **Core**: DSL, model, compiler, runtime, events, diagnostics
- **Agents**: actor runtime, supervision, registry, reusable agent implementations
- **Core features**: tools, memory, metrics, temporal support, caches
- **Extensions**: auditing, provenance, incremental, dataflow, invariants, and similar behavioral add-ons
- **Capability layers**: AI and Channels
- **Hosting/profile layers**: Server, App, Cluster
- **Plugins**: framework-specific integrations such as Rails

That layering exists so that embedded use stays small, while larger deployments can add hosting and distributed concerns without rewriting domain contracts.
