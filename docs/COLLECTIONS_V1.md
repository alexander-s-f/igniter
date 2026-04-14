# Collections v1

## Goal

`collection` introduces explicit fan-out over a list of homogeneous items as a graph primitive.

The feature should make iteration:

- declarative
- visible in the graph model
- visible in runtime diagnostics
- compatible with future parallel and async execution

It should avoid hiding loops inside generic `compute` blocks.

## DSL

### Basic form

```ruby
collection :technicians,
  with: :technician_inputs,
  each: TechnicianContract,
  key: :technician_id,
  mode: :collect
```

Where `technician_inputs` resolves to an array of hashes:

```ruby
[
  { technician_id: 1 },
  { technician_id: 2 }
]
```

### Exporting item results

```ruby
output :technicians
```

This should return a dedicated collection result object.

## Why the input should be item hashes

For v1, the input to `collection` should already be normalized item inputs.

Preferred:

```ruby
compute :technician_inputs, with: :technician_ids do |technician_ids:|
  technician_ids.map { |id| { technician_id: id } }
end
```

Then:

```ruby
collection :technicians,
  with: :technician_inputs,
  each: TechnicianContract,
  key: :technician_id
```

This is preferable to implicit input mapping because:

- the graph remains explicit
- compile-time validation is simpler
- schema-driven graph building is easier

## Scope of v1

Supported:

- one dependency providing an array of item input hashes
- `depends_on:` extra context dependencies
- `map_inputs:` / `using:` item-to-child input mapping
- child contract execution per item
- stable key extraction
- synchronous collection execution
- explicit failure mode configuration

Not supported in v1:

- executor-based collections
- nested async item execution
- item-level `defer` semantics
- schema inference from arbitrary item shapes
- implicit item input mapping without an explicit mapper

## Suggested DSL Options

- `with:` selector for the collection input
- `depends_on:` extra parent dependencies available to the mapper
- `each:` child contract class
- `key:` stable item identity
- `mode:` failure behavior
- `map_inputs:` / `using:` explicit item mapper

Example:

```ruby
collection :technicians,
  with: :technician_inputs,
  depends_on: [:date],
  each: TechnicianContract,
  key: :technician_id,
  map_inputs: ->(item:, date:) { { technician_id: item[:technician_id], date: date } },
  mode: :collect
```

## Runtime Semantics

1. Resolve the collection input dependency.
2. Expect an array. By default each item should already be a child input hash.
3. For each item:
   - derive item key
   - either use the item directly or transform it with `map_inputs:`
   - instantiate child contract with the resulting child input hash
   - resolve child contract
4. Aggregate results according to `mode`

## Stable Key

`key:` should be required in v1.

Why:

- supports item identity in diagnostics
- supports future invalidation and resume semantics
- makes collection output easier to inspect

Possible accepted forms:

- symbol key:
  ```ruby
  key: :technician_id
  ```
- proc form can be a future extension

For v1, symbol key is enough.

## Failure Modes

Collections need explicit failure semantics.

Suggested v1 options:

- `mode: :collect`
  - run all items
  - keep successes and failures
  - collection node itself succeeds unless collection setup is invalid

- `mode: :fail_fast`
  - stop on first failed item
  - collection node fails

Recommended default for v1:

- `:collect`

This is more practical for real orchestration and more useful for diagnostics.

## Result Shape

Collections v1 should return a dedicated result object:

- `Igniter::Runtime::CollectionResult`

Suggested surface:

- `items`
- `keys`
- `successes`
- `failures`
- `pending`
- `to_h`
- `as_json`

Example conceptual shape:

```ruby
{
  items: {
    1 => { status: :succeeded, result: ... },
    2 => { status: :failed, error: ... }
  }
}
```

Returning a plain array would be too weak for diagnostics and future runtime extensions.

## Compile-Time Validation

The compiler should validate:

- `with:` points to a resolvable dependency
- `each:` is an `Igniter::Contract` subclass
- `key:` is present
- child contract is compiled
- `map_inputs:` / `using:` is optional but, when present, shifts shape validation to runtime
- if the source type is known, it is compatible with an array-like input

## Runtime Validation

At runtime, the collection should validate:

- source value is an array
- each item is a hash
- the declared key exists in each item
- keys are unique within the collection input

These should raise structured runtime errors.

## Events

Collections should introduce collection-aware events in v1 or v2.

Minimum useful event:

- `collection_item_started`
- `collection_item_succeeded`
- `collection_item_failed`

Each event should include:

- collection node name
- item key
- child contract graph

If this feels too heavy for v1, item information can first live only inside collection result and diagnostics.

## Introspection

### Graph

Collection nodes should render distinctly from compute/composition/branch nodes.

The graph should show:

- source dependency
- child contract
- key
- mode

### Plan

Before execution:

- collection node is blocked on the source dependency

After execution:

- item count
- item statuses

### Diagnostics

Diagnostics should surface:

- collection size
- per-item key
- per-item status
- per-item errors when present

## Relation to Parallel Execution

Collections are a natural fit for `thread_pool` execution.

But v1 does not need to solve parallel execution immediately.

Recommended rollout:

1. synchronous collection primitive
2. parallel runner support
3. later async/pending/store support for items

## Relation to Future Async

Collections should be designed with future item-level async in mind:

- stable keys
- collection result object
- explicit item states

But v1 should stay synchronous.

## Error Model

Suggested runtime errors:

- `Igniter::CollectionInputError`
- `Igniter::CollectionKeyError`

Potentially later:

- `Igniter::CollectionItemError`

## Future Extensions

Possible later additions:

- proc-based `key:`
- `map_inputs:` from primitive arrays
- item-level async
- item-level retries
- collection-level aggregation helpers
- branch-aware collections

These should not be part of v1.
