# Igniter: Concepts and Principles

This document describes the high-level concepts, philosophy, and architectural principles behind the Igniter framework.

## What is Igniter?

**Igniter** is a Ruby framework for building **declarative, auditable, and reactive business processes**.

It allows you to describe complex business logic not as a sequence of imperative steps, but as a **dependency graph** of
data and computations. Igniter handles the orchestration of this graph: it determines *when* and in *what order* to
perform computations, and it does so lazily—only when a result is actually needed.

The core idea is to separate the description of **WHAT** needs to be done (the graph's structure) from **HOW** it's
done (the Ruby logic within the computations).

## Philosophy

1. **Declarative Structure, Imperative Logic.**
   The process structure (inputs, outputs, dependencies) is described using a simple and limited DSL. The computations
   and business rules themselves are written in pure, powerful, and familiar Ruby. We are not inventing a new language,
   but providing a framework for organizing existing code.

2. **Explicit is better than Implicit.**
   Dependencies between components are always declared explicitly (`from: ...`). The framework avoids "magic," automatic
   dependency injection, or hidden behaviors. If node `A` depends on node `B`, it's always visible in the code.

3. **Separation of Concerns.**
   Igniter is architecturally divided into independent modules:
    * **Definition:** The static "description" of a contract.
    * **Runtime:** The "live" execution and computation of the graph.
    * **DSL:** The tools for building the definition graph.
    * **Auditing:** Recording and replaying the execution history.
    * **Reactive:** Reacting to events within the graph.

4. **Transparency and Debugging "out of the box."**
   The framework is designed so that its execution is easy to trace. Built-in introspection (`print_runtime`) and
   auditing (`Player`) mechanisms are not add-ons, but an integral part of the core.

## Key Concepts

#### Contract

The main unit of work in Igniter. A class inheriting from `Igniter::Root` that encapsulates a single business process.

#### Definition Graph

The static "blueprint" or "plan" of a contract. It is created once when the class is loaded, within the
`context do ... end` block. This graph describes all the nodes, their types, and the dependencies between them. It is
immutable during execution.

#### Runtime Graph

The "live" representation of the contract at runtime. It contains `Runtime::Node` objects, which store the computed
values, statuses (`:success`, `:failure`), and errors for each node.

#### Nodes

The basic building blocks of the graph. The main node types in the DSL are:

* **`input`**: The entry point for data into the contract.
* **`compute`**: The main workhorse node. It performs data transformation. It can be a simple computation (with a `Proc`
  or method) or a composition of another contract.
* **`output`**: The public interface of the contract. It declares which internal nodes are the official result of the
  process.
* **`composition`**: A special kind of `compute` that encapsulates and executes another contract, allowing for the
  construction of a process hierarchy.
* **`reaction`**: A node describing a side effect that should occur in response to an event on the graph (e.g., on the
  successful computation of another node).

## Contract Lifecycle

1. **Definition:** Ruby loads the contract class. The `context` block is executed, building the static
   `Definition::Graph`.
2. **Initialization:** `MyContract.new(inputs)` is called. An instance of the contract and its execution context (
   `Runtime::Execution`) are created. The input data is stored.
3. **Execution:** `contract.resolve!` is called. Igniter begins to lazily traverse the dependency graph, starting from the
   `output` nodes. It only computes the nodes necessary to produce the result. Computation results are cached.
4. **Result:** After `resolve!` completes, the `contract.result` object provides access to the outputs and the overall
   status (`success?`/`failed?`).
5. **Update and Re-computation:** When input data is changed (e.g., `contract.inputs.zip_code = "..."`) and `resolve!`
   is called again, Igniter invalidates only the parts of the graph that depend on the changed input and re-computes only
   them.