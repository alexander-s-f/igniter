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

## Agent Sessions

Pending agent nodes now materialize as first-class runtime sessions.

- `execution.agent_sessions` returns `Igniter::Runtime::AgentSession` objects for pending agent work
- `execution.find_agent_session(token)` resolves a specific session
- `execution.continue_agent_session(session_or_token, payload:, trace: ...)` advances a session without completing the node
- `execution.resume_agent_session(session_or_token, value:)` completes the pending node through the session handle
- store-backed flows can continue or resume through `Contract.continue_agent_session_from_store(...)` and `Contract.resume_agent_session_from_store(...)`

An agent session is the bridge between graph execution and long-lived agent work. It now carries:

- the pending token
- node identity and path
- `via`, `message`, and `mode`
- structured `agent_trace`
- session `turn`
- session `phase`
- append-only `messages`
- `last_request` and `last_reply` envelopes
- session `history`
- execution and graph identity

That makes pending agent work addressable as a domain object rather than a loose token convention.

The important shift is that the session is no longer just "a token plus payload". It is now the beginning of a conversation model:

- the opening agent delivery becomes the first request envelope
- each continuation appends another request envelope
- final completion appends a reply envelope
- diagnostics and persisted snapshots can now describe the conversation shape, not only the latest pending payload

## Why This Shape

The goal is to make agents visible in the graph without collapsing layers again.

- core owns the node kind and execution seam
- `igniter-agents` owns local actor runtime behavior
- richer delivery strategies can evolve behind the adapter boundary

That gives us a real graph primitive now, while still keeping room for future routing and proxy semantics.

## What This Does Not Solve Yet

This is not the final agent model.

Not covered yet:

- rich mailbox-style session state beyond request/reply envelopes
- streaming replies
- capability-routed or cluster-routed agent delivery
- explicit `AgentNode` lifecycle ownership across long-running workflows
- a generalized `ProxyAdapter`

## Next Likely Steps

The most natural next slices are:

1. richer session semantics beyond append-only request/reply envelopes
2. deferred and streaming reply models on top of the session lifecycle
3. support for agent targeting beyond the local registry
4. deciding whether `AgentAdapter` stays specialized or becomes a more general `ProxyAdapter`
