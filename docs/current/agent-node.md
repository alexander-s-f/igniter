# Agent Node

This note tracks the first graph-level bridge between contracts and long-lived agents.

## What Exists Now

Igniter now has a first-pass `agent` node in the core graph model.

Current shape:

- `Igniter::Model::AgentNode`
- DSL: `agent :name, via:, message:, inputs:, timeout:, mode:, reply:, finalizer:`
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
- `agent` call nodes now declare `reply: :single | :deferred | :stream`
- stream call nodes may also declare `finalizer:`
- `agent` cast nodes implicitly use `reply: :none`
- they map contract dependencies into an agent message payload
- they delegate delivery to an adapter instead of talking to the registry directly from core
- the default adapter in `igniter-agents` resolves `via:` through `Igniter::Registry`
- `mode: :call` performs `ref.call(...)` and returns the reply as the node value
- `mode: :cast` performs `ref.send(...)` and resolves the node with `nil` by default

Reply modes now have explicit meaning:

- `reply: :single` means the agent must resolve in the current execution turn
- `reply: :deferred` means the agent may either resolve immediately or materialize a resumable session
- `reply: :stream` means the agent must enter the session lifecycle and surfaces a `Runtime::StreamResult` while pending
- `finalizer:` controls how a streaming session materializes its final value when resumed without an explicit `value:`

That gives contracts both synchronous request/reply, resumable deferred work, and an honest place to grow streaming semantics without coupling core to the actor runtime.

Current stream finalizers:

- default `:join`
- built-ins `:join`, `:array`, `:last`, `:events`
- custom contract methods via `finalizer: :method_name`
- custom callables via `finalizer: ->(chunks:, events:, messages:, session:, contract:, execution:) { ... }`

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
- session `reply_mode`
- append-only `messages`
- `last_request` and `last_reply` envelopes
- session `history`
- execution and graph identity

That makes pending agent work addressable as a domain object rather than a loose token convention.

The important shift is that the session is no longer just "a token plus payload". It is now the beginning of a conversation model:

- the opening agent delivery becomes the first request envelope
- each continuation appends another request envelope
- stream continuations may append partial reply envelopes while staying pending
- final completion appends a reply envelope
- diagnostics and persisted snapshots can now describe the conversation shape, not only the latest pending payload

For user-facing runtime values this now means:

- `reply: :deferred` pending outputs still appear as `DeferredResult`
- `reply: :stream` pending outputs appear as `StreamResult`
- `StreamResult` exposes current `phase`, typed `events`, accumulated `chunks`, and the backing session metadata
- a stream node can be resumed without `value:` and will materialize through its configured finalizer

The current event model is intentionally small:

- legacy text-style replies may still send `payload[:chunk]`
- richer streams may now send `payload[:event]` or `payload[:events]`
- `chunks` are derived from stream events with `type: :chunk`
- current canonical event types are `:chunk`, `:status`, `:tool_call`, `:tool_result`, `:artifact`, and `:final`
- stream continuations are now runtime-validated against that event contract before they enter the persisted session log
- `Igniter::Runtime::AgentSession` now exposes canonical constructors like `status_event`, `tool_call_event`, `tool_result_event`, `artifact_event`, `chunk_event`, and `final_event`
- `StreamResult` now exposes derived readers like `statuses`, `tool_calls`, `tool_results`, `artifacts`, and `final_event`
- tool activity is now also correlated into `tool_interactions`, matching by `call_id` first and then by tool identity/order when `call_id` is absent
- tool loops now expose higher-level execution signals: `all_tool_calls_resolved?`, `tool_loop_consistent?`, `tool_loop_complete?`, `tool_loop_status`, and `tool_loop_summary`

That keeps the text path easy while allowing stream semantics to grow into tool calls, status events, and artifacts.

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
- richer typed event contracts beyond today's first runtime validator pass
- capability-routed or cluster-routed agent delivery
- explicit `AgentNode` lifecycle ownership across long-running workflows
- a generalized `ProxyAdapter`

## Next Likely Steps

The most natural next slices are:

1. richer session semantics beyond append-only request/reply envelopes
2. richer stream event/result assembly beyond today's built-in finalizers
3. support for agent targeting beyond the local registry
4. deciding whether `AgentAdapter` stays specialized or becomes a more general `ProxyAdapter`
