# Distributed Contracts v1

## Goal

`Distributed Contracts` extend `igniter` from in-process orchestration to long-running, event-driven workflow execution.

The feature should make distributed workflows:

- explicit
- correlation-aware
- resumable
- observable end to end
- compatible with the existing graph model

It should avoid pushing cross-system workflow state into ad hoc service objects, background jobs, or loosely related tables.

## Problem Shape

Typical legacy pain looks like this:

- one business flow starts from an inbound request
- later signals arrive from different systems
- signals must be matched by business identity, not by process memory
- some steps complete immediately, others wait minutes or hours
- failures are not local, they are causal and temporal

Examples:

- vendor request -> callrail webhook -> ringcentral webhook -> operator match -> order creation -> billing decision -> invoice
- lead accepted now, enrichment later
- call started now, attribution resolved later

`igniter` already has useful building blocks:

- `pending`
- snapshot / restore
- store-backed execution
- token-based resume
- diagnostics and audit

Distributed Contracts v1 should formalize these into a workflow model.

## Core Principles

### Correlation first

The primary question is not:

- "which service should run next?"

It is:

- "which execution does this external signal belong to?"

Distributed execution must be resumable by stable business correlation keys.

### External signals are graph-visible

Waiting for an external system should be represented in the graph model, not hidden inside generic polling or callback code.

### Transport stays outside

Controllers, jobs, consumers, and webhook adapters remain outside `igniter`.

They should translate transport concerns into workflow operations such as:

- start workflow
- deliver signal
- resume execution

`igniter` should not become a message bus.

## Proposed v1 Surface

### Starting a distributed workflow

```ruby
execution = CallLifecycleContract.start(
  request_id: "req-123",
  company_id: "42",
  vendor_lead_id: "lead-77"
)
```

This is conceptually similar to `new(...).resolve`, but v1 should expose a clearer workflow-oriented entry point.

### Correlation metadata

```ruby
class CallLifecycleContract < Igniter::Contract
  correlate_by :request_id, :company_id, :vendor_lead_id
end
```

This should define the business keys used to find the execution later.

Suggested v1 requirements:

- correlation keys are declared explicitly
- correlation values come from initial inputs and/or delivered signals
- the execution store can index and look up executions by correlation values

### Awaiting an external signal

```ruby
await :callrail_call,
  event: :callrail_webhook_received

await :ringcentral_match,
  event: :ringcentral_call_matched
```

This is preferable to generic `defer` for distributed flows because it makes the waiting state explicit in the graph.

### Delivering an external signal

```ruby
CallLifecycleContract.deliver_event(
  :callrail_webhook_received,
  correlation: { request_id: "req-123", company_id: "42" },
  payload: { call_id: "cr-1", started_at: "2026-03-19T10:00:00Z" }
)
```

Expected behavior:

1. Find the matching execution by correlation.
2. Find a matching `await` node for the event.
3. Bind the payload to that waiting node.
4. Resume the workflow.

### Diagnostics for waiting workflows

```ruby
contract.diagnostics.to_h
```

Should make waiting state explicit:

- current status
- known correlation keys
- expected external events
- last delivered event
- current blocked / waiting nodes

## Scope of v1

Supported:

- explicit correlation keys
- explicit external wait nodes
- event delivery by correlation
- store-backed lookup and resume
- diagnostics for waiting state
- audit trail of delivered external signals

Not supported in v1:

- message bus integration
- retries / dead-letter routing
- event schema registry
- compensation / saga semantics
- multi-execution joins
- time-based wakeups or cron waits
- out-of-order signal reconciliation beyond simple correlation lookup

## DSL

### Basic shape

```ruby
class CallLifecycleContract < Igniter::Contract
  correlate_by :request_id, :company_id, :vendor_lead_id

  define do
    input :request_id, type: :string
    input :company_id, type: :string
    input :vendor_lead_id, type: :string

    await :callrail_call, event: :callrail_webhook_received
    await :ringcentral_match, event: :ringcentral_call_matched

    aggregate :billing_context, with: %i[callrail_call ringcentral_match] do |callrail_call:, ringcentral_match:|
      {
        call_id: callrail_call[:call_id],
        operator_id: ringcentral_match[:operator_id],
        channel: ringcentral_match[:channel]
      }
    end

    output :billing_context
  end
end
```

### Signal delivery

```ruby
CallLifecycleContract.deliver_event(
  :ringcentral_call_matched,
  correlation: {
    request_id: "req-123",
    company_id: "42",
    vendor_lead_id: "lead-77"
  },
  payload: {
    operator_id: 55,
    channel: "paid_search"
  }
)
```

## Why `await` instead of reusing generic `defer`

`defer` is useful as a low-level runtime primitive.

But distributed workflows need more explicit semantics:

- what event is being awaited
- how to resume it
- how to show it in diagnostics
- how to route external signals safely

`await` should be modeled as a graph primitive, not just a custom executor returning `DeferredResult`.

## Runtime Semantics

### Starting execution

1. Create a normal execution.
2. Persist workflow metadata:
   - execution id
   - graph name
   - correlation keys
   - workflow status
3. Resolve until:
   - success
   - failure
   - waiting on one or more `await` nodes

### Await resolution

When an `await` node is reached:

1. Mark node status as `waiting_for_event`
2. Persist expected event metadata
3. Stop downstream execution until signal arrives

### Event delivery

When `deliver_event` is called:

1. Resolve execution lookup by correlation
2. Validate event name
3. Match event to a waiting `await` node
4. Persist audit metadata for the incoming signal
5. Resume execution with delivered payload

### Terminal states

Suggested workflow-level statuses:

- `running`
- `waiting`
- `succeeded`
- `failed`

Later possible additions:

- `cancelled`
- `timed_out`
- `abandoned`

## Graph Model

Distributed Contracts v1 should introduce a dedicated node kind:

- `:await`

Suggested internal shape:

```ruby
AwaitNode.new(
  name: :ringcentral_match,
  event: :ringcentral_call_matched
)
```

This should not be modeled as generic compute.

## Correlation Model

Correlation should be explicit and inspectable.

Suggested v1 API:

```ruby
correlate_by :request_id, :company_id, :vendor_lead_id
```

Suggested stored metadata:

```ruby
{
  request_id: "req-123",
  company_id: "42",
  vendor_lead_id: "lead-77"
}
```

V1 should assume exact equality matching.

Future versions may allow:

- computed correlation values
- partial lookup
- secondary indexes

## Store Requirements

The execution store needs more than snapshot persistence.

Distributed Contracts v1 should require:

- fetch by `execution_id`
- save snapshot
- delete snapshot
- lookup execution ids by correlation keys
- persist workflow metadata

Conceptually:

```ruby
store.save(snapshot:, metadata:)
store.find_by_correlation(graph: "CallLifecycleContract", correlation: { ... })
```

This probably means a new workflow-aware store interface, not just extending the current minimal snapshot store informally.

## Compile-Time Validation

The compiler should validate:

- declared correlation keys exist as contract inputs
- `await` node names are unique
- awaited event names are unique within a graph unless explicitly allowed
- `await` nodes are valid dependencies for downstream nodes

Suggested v1 restriction:

- one `await` node per event name within a contract

This keeps signal delivery unambiguous.

## Runtime Validation

At runtime, delivery should validate:

- the target execution exists
- the execution belongs to the expected contract graph
- the event is currently awaited
- the same awaited signal is not delivered twice unless idempotency policy allows it

Suggested runtime errors:

- `Igniter::WorkflowNotFoundError`
- `Igniter::AwaitedEventMismatchError`
- `Igniter::DuplicateSignalError`

## Events and Audit

Distributed Contracts v1 should add workflow-aware events.

Suggested additions:

- `workflow_started`
- `workflow_waiting`
- `workflow_resumed`
- `external_event_received`
- `await_satisfied`

Suggested payload for incoming external signal:

```ruby
{
  event: :ringcentral_call_matched,
  correlation: {
    request_id: "req-123",
    company_id: "42",
    vendor_lead_id: "lead-77"
  }
}
```

Audit should make it possible to answer:

- which external events were received
- in what order
- which waiting node they satisfied
- why the workflow is still blocked

## Introspection

### Graph

`await` nodes should render distinctly from compute, branch, collection, and composition.

The graph should show:

- awaited event name
- correlation keys at the workflow level

### Plan

Before execution:

- `await` nodes look like normal pending nodes

When waiting:

- plan should show explicit waiting state
- ideally also the awaited event name

### Diagnostics

Diagnostics should surface:

- workflow status
- correlation keys
- awaited events
- satisfied events
- last external event
- blocked nodes

Example conceptual shape:

```ruby
{
  status: :waiting,
  correlation: {
    request_id: "req-123",
    company_id: "42"
  },
  waiting_on: [
    { node: :ringcentral_match, event: :ringcentral_call_matched }
  ],
  last_external_event: :callrail_webhook_received
}
```

## Relation to Existing Pending Support

Distributed Contracts v1 should build on existing pending/store/resume support instead of replacing it.

Conceptually:

- `await` is a higher-level workflow primitive
- internally it may still use pending state and resume mechanics
- `deliver_event` is a safer, domain-oriented wrapper over generic token resume

This keeps the runtime coherent and incremental.

## Recommended Architectural Pattern

Do not start with one giant distributed contract from request to invoice.

Prefer stage-oriented workflow design:

- `InboundLeadContract`
- `CallAttributionContract`
- `OrderBillingContract`
- optional orchestration shell above them

This keeps contracts:

- understandable
- diagnosable
- evolvable

## Future Extensions

Possible later additions:

- event payload schema validation
- timeout / expiry policies on `await`
- idempotency keys for signal delivery
- compensation hooks
- `await_any` / `await_all`
- workflow versioning and migration
- cross-workflow linking
- visual workflow tracing

These should not be part of v1.
