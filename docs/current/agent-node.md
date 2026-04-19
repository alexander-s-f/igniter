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
- stream call nodes may also declare `tool_loop_policy:`
- stream call nodes may also declare `session_policy:`
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
- `session_policy:` controls the broader lifecycle rules for a streaming session
- `finalizer:` controls how a streaming session materializes its final value when resumed without an explicit `value:`
- `tool_loop_policy:` controls when a streaming session is allowed to auto-finalize without an explicit `value:`

That gives contracts both synchronous request/reply, resumable deferred work, and an honest place to grow streaming semantics without coupling core to the actor runtime.

Current stream finalizers:

- default `:join`
- built-ins `:join`, `:array`, `:last`, `:events`
- custom contract methods via `finalizer: :method_name`
- custom callables via `finalizer: ->(chunks:, events:, messages:, session:, contract:, execution:) { ... }`

Current tool loop policies:

- default `:complete`
- `:complete` requires the tool loop to be `:idle` or `:complete`
- `:resolved` requires all tool calls to be resolved, even if orphan results are still present
- `:ignore` allows auto-finalization regardless of tool-loop state

Current session policies:

- default `:interactive`
- `:interactive` allows multi-turn continuation and built-in auto-finalization rules
- `:single_turn` forbids continuation after the initial pending session is opened
- `:manual` allows the session lifecycle but requires explicit `value:` for final completion

## Diagnostics Surface

`agent` nodes now participate in diagnostics as their own execution surface.

- successful, pending, and failed agent deliveries produce structured `agent_trace`
- traces are summarized under `report[:agents]`
- pending and failed outputs include `agent_trace` and `agent_trace_summary`
- execution state keeps sideband node details so successful agent deliveries remain visible after resolution

This matters because it turns agents into observable graph participants rather than opaque adapter calls.

Planning and explain surfaces now expose agent orchestration hints too:

- `execution.plan` includes top-level `orchestration` summary for agent-backed work
- `execution.orchestration_plan` exposes that orchestration summary directly
- each agent node now exposes an `orchestration` hint with:
  - `interaction` such as `:interactive_session`, `:manual_session`, `:single_turn_session`, `:deferred_call`, `:single_reply_call`, or `:delivery_only`
  - `attention_required`
  - `resumable`
  - `allows_continuation`
  - `requires_explicit_completion`
  - `auto_finalization`
- orchestration summaries now also include recommended actions for higher layers:
  - `:open_interactive_session`
  - `:require_manual_completion`
  - `:await_single_turn_completion`
  - `:await_deferred_reply`
- diagnostics now surface that same orchestration view, so app/runtime tooling can consume it without separately asking for `plan`
- `igniter-app` now uses that surface to open app-level orchestration inbox items via `App.open_orchestration_followups(...)`
- those inbox items are deduplicated by action id and show up in `diagnostics[:app_orchestration][:inbox]`
- inbox items now support lifecycle transitions through `acknowledge`, `resolve`, and `dismiss`
- opening follow-ups against a live contract now materializes the relevant pending agent nodes first, so inbox items carry real runtime session metadata instead of planner-only action ids
- resolving a follow-up item can now resume the underlying agent session directly from the app layer
- `igniter-app` now also exposes `App.handle_orchestration_item(...)`, which routes a follow-up item through a built-in handler for its action semantics instead of forcing callers to choose inbox verbs manually
- the same handler path can now resume store-backed agent sessions when only `graph + execution_id + token + node` are available, so live and durable orchestration follow-ups share one app-level API
- orchestration actions now also carry explicit app-level policy metadata, including:
  - policy name
  - default operation
  - allowed operations
  - lifecycle operations
  - operation aliases from domain verbs to inbox lifecycle verbs
  - default routing
  - runtime completion expectation
- actions also now carry resolved routing metadata, so plan/follow-up surfaces can see initial `queue/channel` assignment before any handoff happens
- inbox items preserve that policy shape, so policy is visible in diagnostics and follow-up handling
- built-in handlers now enforce those policies instead of relying on action-specific defaults hidden in handler classes
- the canonical app-level operations are now domain-oriented:
  - interactive sessions prefer `wake`, may be `handoff`ed, can be `complete`d, and may still be `dismiss`ed
  - manual completion steps prefer `approve`
  - deferred replies prefer `reply`
  - single-turn steps prefer `complete`
- low-level `acknowledge`, `resolve`, and `dismiss` still exist as lifecycle verbs, but they are now secondary to the domain-oriented orchestration surface
- `igniter-app` now exposes helper entrypoints like `wake_orchestration_item`, `approve_orchestration_item`, `reply_to_orchestration_item`, `complete_orchestration_item`, and `handoff_orchestration_item`
- `handoff` is now a real ownership transition, not only an alias:
  - inbox items can now carry `assignee`, `queue`, and `channel`
  - handoffs increment `handoff_count`
  - handoffs append to `handoff_history`
  - diagnostics expose assignment summaries through inbox snapshots
- policies now also provide initial routing for new follow-ups:
  - interactive sessions default to `interactive-sessions`
  - manual completions default to `manual-completions`
  - deferred replies default to `deferred-replies`
  - single-turn completions default to `single-turn-completions`
- apps may override that routing with `register_orchestration_routing(...)`, so default queues and channels are configurable without replacing the policy itself
- apps may now also register queue-specific orchestration policies with `register_orchestration_policy(..., queue: ...)`, so a lane can change default and allowed operations without redefining the base action
- that means queue selection is now semantically meaningful: an `interactive` step routed into one lane may default to `wake`, while another lane may default to `complete`
- apps may now also register first-class orchestration lanes with `register_orchestration_lane(...)`, bundling lane metadata with queue-specific routing, policy, and handler semantics
- planner, follow-up, inbox, and diagnostics surfaces now carry `lane` metadata explicitly, so operator workflows can reason about lanes without reverse-engineering queue strings
- app orchestration now also exposes `App.orchestration_query`, a read-only operator view over inbox items with filters like `lane`, `queue`, `channel`, `assignee`, `status`, `interaction`, and `attention_required`
- that operator view also supports `facet`, `facets`, and `summary`, so queue/lane/operator state can be inspected as an aggregate field instead of only as a filtered list
- app orchestration now also exposes `App.operator_query(target)`, which joins live `AgentSession` state with inbox/operator state into one read model with `joined`, `session_only`, and `inbox_only` records
- diagnostics now also expose that joined plane through `diagnostics[:app_operator]`, so the same operator-facing model is available to reports, dashboards, and app-level observability without recomputing joins
- `igniter-app` now also exposes `App.operator_overview_for_execution(graph:, execution_id:)`, which restores a durable execution from store and projects the same joined operator plane without requiring a live contract instance
- `Igniter::App::Observability::OperatorOverviewHandler` now packages that read model as a reusable custom-route handler, so mounted admin or dashboard surfaces can serve operator overview JSON without hand-writing store-restore glue
- apps can now mount that surface declaratively through `mount_operator_overview` or `mount_operator_observability`, which turns the handler into a small observability pack instead of another per-app route snippet
- the mounted operator overview API is now query-aware too: it accepts filters like `status`, `node`, `lane`, `queue`, `assignee`, plus `order_by` and `direction`, and returns those applied query settings in the overview payload
- `mount_operator_surface` now gives a built-in operator console page above that same API, including execution drill-down and filter-driven inspection without adding a frontend dependency
- `lane` and current `queue/channel` are intentionally not the same thing: lane identifies the orchestration surface the item belongs to, while a later `handoff` may move the item to a different queue or channel without erasing its lane identity
- deduplication only applies to active items, so resolved or dismissed actions can be reopened later if the workflow becomes pending again
- `explain_plan` now renders those hints directly for human review

That gives higher layers a stable place to reason about agent workflow shape without re-deriving it from low-level reply/session/tool-loop flags.

The next safe query-oriented step for agents is not a full `MeshQL` port yet. The better first move is a read-only query layer over live `AgentSession` and orchestration state, because those objects already expose typed dimensions like `phase`, `reply_mode`, `tool_loop_status`, `queue`, `channel`, and assignee-facing workflow state.

That first slice is now in place at runtime level through `execution.agent_session_query`, which gives a chainable read-only query surface over live `AgentSession` objects and derived orchestration metadata like `interaction`, `reason`, `attention_required`, and `resumable`.
It also now supports `facet`, `facets`, and `summary`, which makes the local agent runtime usable as a small OLAP-like field before any richer distributed query language exists.

The next layer above that is now also in place in `igniter-app`: `App.operator_query(target)` joins the live session field with the app inbox field, so operators can inspect runtime/session state and workflow/ownership state without hand-joining on `node`, `token`, `graph`, or `execution_id`.

## Agent Sessions

Pending agent nodes now materialize as first-class runtime sessions.

- `execution.agent_sessions` returns `Igniter::Runtime::AgentSession` objects for pending agent work
- `execution.find_agent_session(token)` resolves a specific session
- `execution.continue_agent_session(session_or_token, payload:, trace: ...)` advances a session without completing the node
- `execution.resume_agent_session(session_or_token, value:)` completes the pending node through the session handle
- `execution.resume_agent_session(session_or_token, node_name:, value:)` can now resume a specific pending agent node even when several sessions share a token
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
- a stream node can be resumed without `value:` and will materialize through its configured finalizer according to its `tool_loop_policy:`
- under the default `:complete` policy, open or orphaned tool loops block auto-finalization unless the caller explicitly supplies `value:`
- `session_policy:` sits above that rule: `:manual` disables auto-finalization entirely, while `:single_turn` forbids follow-up continuations

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

One subtle but important runtime fix also landed under this model: local registry-backed agents now propagate `PendingDependencyError` back to the graph as `pending`. In other words, a local actor that wants to stay open no longer falls through to a reply timeout first.

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

1. harden orchestration handling above planner/inbox level
2. richer session semantics beyond today's append-only conversational envelopes
3. support for agent targeting beyond the local registry
4. deciding whether `AgentAdapter` stays specialized or becomes a more general `ProxyAdapter`

See also: [Agents Roadmap](./agents-roadmap.md)
