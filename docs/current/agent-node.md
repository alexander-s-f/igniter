# Agent Node

This note tracks the first graph-level bridge between contracts and long-lived agents.

## What Exists Now

Igniter now has a first-pass `agent` node in the core graph model.

Current shape:

- `Igniter::Model::AgentNode`
- DSL: `agent :name, via:, message:, inputs:, timeout:, mode:`
- runtime seam: `Igniter::Runtime::AgentAdapter`
- default local implementation from `igniter-agents`: `Igniter::Runtime::RegistryAgentAdapter`

Example:

```ruby
require "igniter"
require "igniter/agent"

class GreetingContract < Igniter::Contract
  define do
    input :name

    agent :greeting,
          via: :greeter,
          message: :greet,
          inputs: { name: :name },
          mode: :call,
          timeout: 2

    output :greeting
  end
end
```

## Current Semantics

This first pass is intentionally small, but no longer request/reply only.

- `agent` nodes support `mode: :call` and `mode: :cast`
- they map contract dependencies into an agent message payload
- they delegate delivery to an adapter instead of talking to the registry directly from core
- the default adapter in `igniter-agents` resolves `via:` through `Igniter::Registry`
- `mode: :call` performs `ref.call(...)` and returns the reply as the node value
- `mode: :cast` performs `ref.send(...)` and resolves the node with `nil` by default

That gives contracts both synchronous request/reply and fire-and-forget delivery without coupling core to the actor runtime.

## Diagnostics Surface

`agent` nodes now participate in diagnostics as their own execution surface.

- successful, pending, and failed agent deliveries produce structured `agent_trace`
- traces are summarized under `report[:agents]`
- pending and failed outputs include `agent_trace` and `agent_trace_summary`
- execution state keeps sideband node details so successful agent deliveries remain visible after resolution

This matters because it turns agents into observable graph participants rather than opaque adapter calls.

## Why This Shape

The goal is to make agents visible in the graph without collapsing layers again.

- core owns the node kind and execution seam
- `igniter-agents` owns local actor runtime behavior
- richer delivery strategies can evolve behind the adapter boundary

That gives us a real graph primitive now, while still keeping room for future routing and proxy semantics.

## What This Does Not Solve Yet

This is not the final agent model.

Not covered yet:

- graph-native long-lived sessions
- streaming replies
- capability-routed or cluster-routed agent delivery
- explicit `AgentNode` lifecycle ownership
- a generalized `ProxyAdapter`

## Next Likely Steps

The most natural next slices are:

1. richer delivery modes such as deferred replies or streaming
2. richer provenance for successful agent nodes, not just pending/failed traces
3. support for agent targeting beyond the local registry
4. deciding whether `AgentAdapter` stays specialized or becomes a more general `ProxyAdapter`
