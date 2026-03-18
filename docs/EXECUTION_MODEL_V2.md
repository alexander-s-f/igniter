# Igniter v2 Execution Model

## Execution Lifecycle

Each contract instance owns one runtime execution session.

Lifecycle:

1. caller provides inputs
2. contract builds or reuses a compiled graph
3. execution is created with input state, cache, and event bus
4. caller requests one output or all outputs
5. runtime resolves only required nodes
6. cache stores node states
7. input updates invalidate downstream nodes
8. subsequent resolution reuses valid states and recomputes stale states only

## Core Runtime Objects

### `Execution`

Public runtime session.

Responsibilities:

- own compiled graph
- own input store
- own cache
- own event bus
- expose `resolve`, `resolve_all`, `update_inputs`, `result`

### `Resolver`

Single responsibility: resolve a node into a `NodeState`.

Responsibilities:

- resolve dependencies first
- execute the node's callable or adapter
- wrap success/failure into `NodeState`
- emit start/success/failure events

### `NodeState`

Represents runtime state for one compiled node.

Fields:

- `node_id`
- `path`
- `status`
- `value`
- `error`
- `version`
- `resolved_at`
- `stale`

Statuses:

- `:pending`
- `:running`
- `:succeeded`
- `:failed`
- `:stale`

### `Cache`

Stores `NodeState` by node id.

Responsibilities:

- fetch current state
- write new state
- mark state stale
- answer freshness queries

### `Invalidator`

Knows downstream dependency edges and invalidates affected nodes after input changes.

Responsibilities:

- walk reverse dependency graph
- mark stale states
- emit invalidation events

## Resolution Rules

### Lazy by default

`result.total` should resolve only the nodes required for `total`.

`result.to_h` may resolve all declared outputs, but should still use lazy node-level resolution internally.

### Cached by default

If a node is already resolved and not stale, the cached state is returned.

### Deterministic order

When a set of nodes must be resolved together, Igniter uses the compiler-generated topological order. This gives:

- predictable behavior
- deterministic event ordering
- easier testing and auditing

## Input Update Rules

When inputs change:

1. validate input keys
2. update input values
3. find all downstream nodes
4. mark cached downstream states as stale
5. emit `input_updated` and `node_invalidated` events

No recomputation happens during invalidation itself unless explicitly requested by the caller.

## Failure Rules

Failures are stored as node state, not hidden in logs.

If dependency resolution fails:

- dependent node resolves to failed state
- failure is explicit
- dependent nodes can choose fail-fast behavior

Default kernel policy:

- input node failures are validation failures
- compute node failures wrap exceptions in `ResolutionError`
- output nodes mirror source node state

## Composition Execution

Composition node resolution:

1. resolve parent-side mapping dependencies
2. build child inputs
3. instantiate child execution
4. resolve child outputs inside the child execution
5. return child `Result`

Composition should not flatten child state into the parent cache. Child execution remains isolated.

Recommended metadata on composition events:

- `parent_execution_id`
- `child_execution_id`
- `composition_node_id`
- `child_contract`

## Event Contract

Canonical kernel events:

- `execution_started`
- `execution_finished`
- `execution_failed`
- `input_updated`
- `node_started`
- `node_succeeded`
- `node_failed`
- `node_invalidated`

Suggested event fields:

- `event_id`
- `execution_id`
- `timestamp`
- `type`
- `node_id`
- `node_name`
- `path`
- `status`
- `payload`

Current payload examples:

- composition success payload includes `child_execution_id` and `child_graph`
- `execution_failed` includes `graph`, `targets`, and `error`
- `node_invalidated` includes `cause`

## Public Resolution API

Recommended public behavior:

```ruby
contract = PriceContract.new(order_total: 100, country: "UA")

contract.result.total
contract.result.to_h

contract.update_inputs(order_total: 120)
contract.result.total
```

The runtime contract should be:

- reads are lazy
- writes invalidate
- recomputation is explicit via subsequent reads

## Concurrency

The first version should be synchronous and single-threaded.

Reasons:

- deterministic semantics first
- simpler cache invariants
- easier event ordering
- easier debugging

Thread-safe or parallel execution can be added later behind explicit executors.

## Kernel Invariants

These invariants should be enforced by tests:

1. compiled graph is immutable
2. node path is stable
3. same fresh node is not recomputed twice
4. stale downstream nodes are recomputed on next read
5. unrelated nodes are not invalidated
6. event order is deterministic
7. failures remain inspectable in cache/result
8. composition creates isolated child executions

## Testing Strategy

Minimum runtime test matrix:

- resolves a linear graph
- resolves a branching graph
- skips unrelated nodes
- caches resolved nodes
- invalidates only downstream nodes
- preserves unaffected cached nodes
- captures compute exceptions as failed node state
- resolves nested composition
- emits expected events in order
- exposes machine-readable execution/result/event payloads
- exposes diagnostics reports for both success and failure flows
