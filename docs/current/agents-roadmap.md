# Agents Roadmap

This note tracks the next practical development stages for `contracts & agents`.

It is intentionally shorter than the deeper architecture notes. The goal is to
keep one current roadmap that reflects what is already landed and what should
come next.

## Current State

Already landed:

- `agent` is a first-class graph node in core
- agent delivery supports `mode: :call | :cast`
- call nodes support `reply: :single | :deferred | :stream`
- pending agent work materializes as `AgentSession`
- stream sessions expose typed events and tool-loop semantics
- planner and diagnostics expose orchestration hints and actions
- `igniter-app` can open orchestration follow-ups into an inbox
- inbox items can now `acknowledge`, `resolve`, and `dismiss`
- resolving an inbox item can resume the underlying runtime session
- orchestration actions now carry explicit policy metadata for default and allowed handling
- built-in handlers enforce those policies through one app-level entrypoint
- app-level orchestration now has domain verbs like `wake`, `approve`, `reply`, `complete`, and `handoff`, instead of speaking only in inbox lifecycle verbs
- `handoff` now preserves ownership metadata (`assignee`, `queue`, `channel`) and handoff history on inbox items
- policies now also seed default queue/channel routing for newly opened follow-ups, with app-level overrides available through `register_orchestration_routing(...)`
- orchestration policies are now queue-aware too, so different operator lanes can change default and allowed handling semantics without replacing the action itself
- orchestration lanes are now first-class bundles over routing, policy, and handler semantics, so higher layers can reason about named operator lanes instead of only queue strings
- local registry-backed agents now propagate `PendingDependencyError` as honest runtime `pending`, not timeout failure
- `execution.agent_session_query` now gives a read-only query surface over live agent sessions and derived orchestration metadata
- that runtime query surface now also supports `facet`, `facets`, and `summary`
- `App.orchestration_query` now gives a read-only operator query surface over inbox items, including lane, queue, channel, assignee, and lifecycle filters
- that app operator query surface now also supports `facet`, `facets`, and `summary`
- `App.operator_query(target)` now joins live sessions and inbox items into one operator-facing query surface
- diagnostics now also expose that unified operator plane as `app_operator`
- `App.operator_overview_for_execution(graph:, execution_id:)` now restores a durable execution and projects that same operator plane without a live contract object
- `Igniter::App::Observability::OperatorOverviewHandler` now makes that plane directly mountable as a custom JSON route for dashboard/admin surfaces
- `Igniter::App::Observability::OperatorActionHandler` now makes the same mounted operator surface writable for common orchestration transitions
- `mount_operator_overview(...)` and `mount_operator_observability(...)` now make that endpoint a first-class app DSL pack instead of a repeated custom route snippet
- that mounted operator endpoint now also supports stable filter/order query params and reflects the applied query contract back in the response payload
- `mount_operator_surface(...)` now adds a built-in operator console over that same queryable plane, including execution-scoped drill-down and row-level operator actions
- operator items now also expose canonical `action_history` with explicit operator identity like `actor`, `origin`, and `actor_channel`, so the surface has a real audit trail instead of only latest-state observability
- latest audit identity is now also filterable/facetable/orderable through `latest_action_actor`, `latest_action_origin`, and `latest_action_source`
- the unified operator plane now also includes ignition records from the durable ignite trail, so operator visibility is no longer limited to agent sessions and orchestration inbox items
- mounted operator actions now also handle ignition lifecycle transitions through the same operator action API, so the operator plane is beginning to converge around one writable workflow surface
- app-facing generic operator verbs now also dispatch across orchestration and ignite records, and ignite records now expose policy-shaped metadata plus latest operator identity dimensions, so the operator plane is getting closer to one honest workflow language
- ignite records now also distinguish operator-facing action language, lifecycle meaning, and execution operation more explicitly, which is an important foundation for further convergence work with orchestration policies/handlers
- orchestration handlers and ignite handling now also share a more explicit `Igniter::App::Operator` layer, so policy resolution, result shape, and action dispatch are beginning to converge structurally instead of only by convention
- `App.handle_operator_item(...)` now routes through an explicit shared operator dispatcher/registry, which means orchestration and ignite are converging not only on policy and result shape but also on handler selection
- operator records now also expose explicit `record_kind` and shared `lifecycle` schema, which means convergence is no longer only about how records are handled, but also about how they are described to query/API/UI layers
- `agent` nodes now also support routed delivery metadata:
  - `node:`
  - `capability:`
  - `query:`
  - `pinned_to:`
- core runtime now also ships the first routed-agent delivery foundation:
  - `AgentRoute`
  - `AgentRouteResolver`
  - `AgentTransport`
  - `ProxyAgentAdapter`
- cluster now also ships:
  - `AgentRouteResolver`
  - `RoutedAgentAdapter`
  so capability/pinned routing already works at route-resolution/runtime-semantics level, even though a fully canonical remote transport protocol is still a later step

That is enough to treat agents as a real execution surface, not only an adapter seam.

## Planning Snapshot

If we pause after the current operator/audit/query/ignite convergence work, the realistic near-term choices are:

1. Operator workflow convergence

- keep converging orchestration and ignition toward one honest operator workflow surface
- make action semantics, retry/approval handling, and audit/history behavior feel consistent across both kinds of records
- keep this mostly in `igniter-app` and the operator read/write model

2. Runtime/session semantics

- deepen `AgentSession`, session persistence, and execution semantics further
- keep strengthening the runtime truth that the operator plane sits on top of
- likely touches core runtime more than app/operator surfaces

3. Remote and routed agents

- move the current `agent node -> session -> orchestration` model beyond the local registry
- preserve the same session/orchestration semantics for remote delivery
- harden the new route/transport seam into a canonical remote delivery contract
- likely the strongest next architecture move once the operator surface feels “good enough”

For now, option 1 is the smallest and cleanest continuation from the current landed state.
Option 3 is still the larger architectural continuation.

## Deferred Line

The agent/query work should stay separate from the cluster query-language naming track.

- do not let `MeshQL` naming cleanup drive the current agents/runtime plan
- keep the cluster query language as a low-priority separate line
- rename work should happen before that language becomes more public, but not in the middle of the current agents/operator iteration

## Next

### 1. Orchestration Runtime

Priority: very high

Goal:

- turn orchestration actions into a fuller runtime API, not only planner output and app inbox items

What this likely means:

- app-level adapters/handlers for `require_manual_completion`, `await_deferred_reply`, and interactive sessions
- cleaner bridges between inbox lifecycle and runtime session lifecycle
- durable store-backed orchestration handling, not only in-memory app state

First slice is now in place:

- built-in orchestration handlers back current planner actions
- `App.handle_orchestration_item(...)` gives a single runtime entrypoint over those handlers
- default handler semantics are now explicit instead of being spread across ad hoc inbox calls
- those handler semantics are now backed by explicit orchestration policies, not only action names
- durable store-backed session resume now goes through that same handler surface when an inbox item carries runtime identity
- convenience helpers now exist for the most common domain operations, so higher layers do not have to remember raw action ids plus low-level lifecycle verbs
- lane metadata is now explicit in plan, follow-up, inbox, and diagnostics surfaces, and apps can register bundled lane semantics through `register_orchestration_lane(...)`

Why this comes first:

- we already have planner-visible orchestration language
- we already have an app inbox
- the biggest missing step is to make that orchestration surface operational end to end

### 2. Richer Session Model

Priority: high

Goal:

- make `AgentSession` a stronger conversational runtime object

What this likely means:

- clearer lifecycle phases
- better request/reply envelope shapes
- optional session metadata for operator or UI surfaces
- stronger session identity rules beyond token-only addressing
- better persistence and restore semantics for multi-turn sessions

Why it matters:

- `AgentSession` is already the bridge between graph execution and long-lived agents
- if that bridge stays thin, higher layers will start inventing parallel session models

### 3. Agent Query Surface

Priority: high

Goal:

- bring the `OLAP Point like` idea into agents in a safe, read-only form

What this likely means:

- treat `AgentSession` and app orchestration items as the first queryable observation field
- add an `AgentSessionQuery` style surface before attempting a full `MeshQL`-like language
- query dimensions like `phase`, `reply_mode`, `tool_loop_status`, `queue`, `channel`, `assignee`, `interaction`, and `attention_required`

Why this comes before full agent MeshQL:

- the typed dimensions already exist in runtime and app orchestration
- registry-level agent capability metadata does not exist yet
- a read-only query surface can deliver immediate value without changing delivery or supervision semantics

First slice is now in place:

- runtime exposes `execution.agent_session_query`
- the query surface is chainable and read-only, similar in spirit to `ObservationQuery`
- it currently joins live session state with orchestration metadata already present in execution planning

### 4. Remote And Routed Agents

Priority: high

Goal:

- move beyond local registry-only delivery

What this likely means:

- evaluate `ProxyAdapter` or a broader delivery seam above `AgentAdapter`
- support capability-routed or cluster-routed agents
- preserve the same graph/session/orchestration semantics across local and remote delivery

Why it matters:

- agent nodes become much more valuable when the execution model survives outside one process
- cluster and agent work should converge on one honest runtime model instead of separate abstractions

## Later

### 5. Self-Application

Priority: high, but after orchestration and session hardening

Goal:

- let Igniter increasingly build its own orchestration layers out of contracts and agents

Strong candidates:

- planner-side routing helpers
- tool-loop orchestration
- approval and wakeup workflows
- retries and supervision policies
- AI workflow orchestration
- some cluster coordination paths

Rule of thumb:

- keep the kernel direct and small
- move orchestration layers onto `contracts & agents` when the primitives are strong enough

### 6. Unified Execution Profiles

Priority: medium

Goal:

- make agent-backed work a clearer execution category across the whole runtime

What this likely means:

- clearer interaction between agent nodes and other pending/resumable nodes
- better planner semantics for interactive, manual, deferred, and delivery-only work
- stronger explain/provenance/diagnostics language for long-lived execution

## Non-Goals Right Now

Not the immediate next move:

- rewriting the kernel in terms of higher abstractions
- collapsing agents back into `sdk`
- inventing a large abstract distributed framework before local semantics are solid

## Reading Order

- [Contracts And Agents](./contracts-and-agents.md)
- [Agents](./agents.md)
- [Agent Node](./agent-node.md)
