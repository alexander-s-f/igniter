# Agent Node

This note tracks the first graph-level bridge between contracts and long-lived agents.

## What Exists Now

Igniter now has a first-pass `agent` node in the core graph model.

Current shape:

- `Igniter::Model::AgentNode`
- DSL: `agent :name, via:, message:, inputs:, timeout:`
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
          timeout: 2

    output :greeting
  end
end
```

## Current Semantics

This first pass is intentionally narrow.

- `agent` nodes are request/reply nodes
- they map contract dependencies into an agent message payload
- they delegate delivery to an adapter instead of talking to the registry directly from core
- the default adapter in `igniter-agents` resolves `via:` through `Igniter::Registry` and performs `ref.call(...)`

The result of the node is the reply payload returned by the agent handler.

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
- fire-and-forget / cast semantics
- streaming replies
- capability-routed or cluster-routed agent delivery
- explicit `AgentNode` lifecycle ownership
- a generalized `ProxyAdapter`

## Next Likely Steps

The most natural next slices are:

1. richer delivery modes such as `mode: :send` or deferred replies
2. agent-node diagnostics and provenance formatting
3. support for agent targeting beyond the local registry
4. deciding whether `AgentAdapter` stays specialized or becomes a more general `ProxyAdapter`
