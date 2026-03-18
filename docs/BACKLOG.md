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
