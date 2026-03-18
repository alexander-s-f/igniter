# Igniter Backlog

This file is a lightweight backlog for ideas that are worth preserving before they turn into active implementation work.

## Collections v1

Status: idea
Priority: high

Problem:

- Real orchestration often needs fan-out over a list of homogeneous items.
- Without a collection primitive, users will hide loops inside `compute` nodes.
- That reduces graph transparency and makes diagnostics, invalidation, and async execution weaker.

Example direction:

```ruby
collection :technicians,
  depends_on: :technician_inputs,
  each: TechnicianContract,
  key: :technician_id,
  mode: :collect
```

Likely semantics:

- `depends_on:` should resolve to an array of item input hashes
- `each:` should point to a child contract or executor-like collection worker
- `key:` should provide stable item identity for invalidation, resume, and diagnostics
- `mode:` should control failure semantics, for example `:collect` vs `:fail_fast`

Why it matters:

- enables explicit fan-out/fan-in in the graph model
- fits naturally with `thread_pool` execution
- creates a path toward item-level async/pending/resume
- improves diagnostics over collection workflows

Open design questions:

- result shape: array, keyed hash, or dedicated `CollectionResult`
- compile-time validation for item schema and key extraction
- per-item invalidation and snapshot/restore behavior
- item-level events and auditing model
- parent failure semantics when some items fail or remain pending

Suggested implementation order:

1. write a short design doc for Collections v1
2. define graph/model/runtime semantics
3. add compile-time validators
4. add a minimal synchronous implementation
5. extend to parallel runner
6. later extend to pending/store-backed item execution

## Conditional Branches v1

Status: idea
Priority: high

Problem:

- Real orchestration often needs explicit conditional routing.
- Without a branching primitive, users push control flow into `compute` blocks or executors.
- That hides workflow structure and weakens diagnostics and introspection.

Example direction:

```ruby
branch :delivery_strategy, depends_on: :country do
  on "US", contract: USDeliveryContract
  on "UA", contract: LocalDeliveryContract
  else contract: DefaultDeliveryContract
end
```

Why it matters:

- makes control flow explicit in the graph
- keeps routing logic out of generic `compute` nodes
- improves explainability by showing which branch was selected
- fits future schema/UI-driven graph composition

Likely semantics:

- `depends_on:` resolves the selector input
- one branch is selected at runtime based on ordered matching
- the selected branch behaves like a composition-like node
- diagnostics and events should include which branch matched

Open design questions:

- exact-match only vs predicate-based matching
- whether `else` is required or optional
- compatibility of outputs across different branches
- how branch nodes appear in plans, graphs, and runtime state
- whether branches select contracts only or also arbitrary nodes/executors

Suggested implementation order:

1. write a short design doc for Branches v1
2. define graph/model/runtime semantics
3. add compile-time validation for branch definitions
4. implement a minimal contract-branching version
5. add introspection and diagnostics for selected branch visibility
6. later extend to schema-driven graph builders
