# Agents Current

This note captures the current direction for Igniter agents after the package split to `igniter-agents`.

## Current Decision

Agents are now treated as their own domain layer, separate from both the graph kernel and the optional SDK registry.

Current package ownership:

- `igniter-core` owns the contract/model/compiler/runtime kernel
- `igniter-agents` owns actor runtime primitives and built-in agents
- `igniter-ai` owns providers, executors, skills, transcription, and AI runtime
- `igniter-sdk` owns capability registration and non-agent optional packs

## What Lives In `igniter-agents`

- `Igniter::Agent`
- `Igniter::Registry`
- `Igniter::Supervisor`
- `Igniter::Agents::*`
- `Igniter::AI::Agents::*`

Canonical entrypoints:

- `require "igniter/agent"`
- `require "igniter/registry"`
- `require "igniter/supervisor"`
- `require "igniter/agents"`
- `require "igniter/ai/agents"`

## Why This Split Exists

The immediate goal is package honesty, not just file motion.

- `igniter-core` should stay focused on validated dependency graphs and execution
- actor runtime should no longer be implied by `require "igniter/core"`
- reusable built-in agents should not remain buried under `sdk/*`
- AI agents should be modeled as agent implementations first, AI runtime conveniences second

## What This Split Does Not Mean Yet

This package split does **not** mean that agents are already a fully mature contract execution model.

Still not true yet:

- agent lifecycle is not yet a fully planner-native execution category across the whole graph
- richer typed stream events are not yet the only canonical stream surface

Today, agents are both actor runtime primitives and an early graph primitive through `AgentNode`, but the deeper execution model is still intentionally narrow.

Even in that narrow form, agents are no longer opaque:

- `agent` nodes support `call` and `cast`
- call nodes now declare an explicit reply contract: `single`, `deferred`, or `stream`
- deliveries surface structured traces in diagnostics
- pending agent work is visible in provenance
- successful deliveries retain sideband execution details instead of disappearing into a plain scalar result
- pending agent work materializes as `Runtime::AgentSession`, not just a raw token
- sessions can now continue across turns before final completion
- store-backed executions preserve those sessions as part of the runtime model
- local registry-backed agents can now surface `PendingDependencyError` back into the contract runtime as honest pending state
- app-level orchestration inbox items can now reopen, acknowledge, dismiss, and resolve against the underlying runtime session
- runtime resume is now node-aware as well as token-aware, which matters once multiple agent nodes share similar session identity
- app orchestration lanes are now explicit too, so queue-like operator flows can carry named lane semantics instead of only string assignment metadata
- runtime now also exposes `execution.agent_session_query`, a read-only query surface over live agent sessions and derived orchestration metadata
- that query surface includes `facet`, `facets`, and `summary`, so agent work can already be inspected as a small local field before any richer distributed query layer exists
- app now also exposes `App.operator_query(target)`, which joins live agent sessions with orchestration inbox items into one operator-facing read model
- diagnostics now also expose the same joined operator read model through `app_operator`
- app now also exposes `App.operator_overview_for_execution(graph:, execution_id:)`, so the same operator plane can be restored from durable store state without keeping a live contract instance around
- `igniter-app` now ships `Igniter::App::Observability::OperatorOverviewHandler` as a reusable custom-route adapter for that operator plane
- `igniter-app` now also ships `Igniter::App::Observability::OperatorActionHandler`, so mounted operator surfaces can drive orchestration transitions through the same app-facing plane
- apps can now mount that operator endpoint declaratively with `mount_operator_overview(...)` or `mount_operator_observability(...)`
- that mounted operator endpoint is now query-aware too, so operator surfaces can ask for focused slices like `status=acknowledged`, `queue=manual-review`, or `assignee=ops:alice` instead of always fetching the full record set
- `mount_operator_surface(...)` now also gives apps a built-in operator console page with those same filters, execution drill-down links, and row-level operator actions
- operator items now also carry `action_history`, including explicit operator identity like `actor`, `origin`, and `actor_channel`, so agent-facing workflows have a canonical audit trail at the app/operator layer, not only a current inbox status
- `agent` nodes now also support routed delivery metadata beyond the local registry:
  - `node:` for static remote delivery
  - `capability:` and `query:` for capability-routed delivery
  - `pinned_to:` for explicit peer routing
- agent node interaction semantics now also live behind one explicit model-level value object:
  - `Igniter::Model::AgentInteractionContract`
  - it now owns delivery mode, reply semantics, stream finalization, tool-loop policy, session policy, and routed delivery metadata as one canonical shape
- core runtime now also exposes a generalized routed-agent seam:
  - `Igniter::Runtime::AgentRoute`
  - `Igniter::Runtime::AgentRouteResolver`
  - `Igniter::Runtime::AgentTransport`
  - `Igniter::Runtime::ProxyAgentAdapter`
- cluster now also provides the first routed-agent implementation:
  - `Igniter::Cluster::AgentRouteResolver`
  - `Igniter::Cluster::RoutedAgentAdapter`
  - capability and pinned routing already resolve through mesh semantics and preserve pending/failure behavior
- server now also provides the first canonical remote agent protocol:
  - `Igniter::Server::AgentTransport`
  - `Igniter::Server::AgentSessionStore`
  - `POST /v1/agents/:via/messages/:message/call`
  - `POST /v1/agents/:via/messages/:message/cast`
  - `POST /v1/agent-sessions/:token/continue`
  - `POST /v1/agent-sessions/:token/resume`
- routed delivery now already has one honest HTTP transport path
- routed `AgentSession` objects now also carry explicit ownership and delivery metadata like `ownership`, `owner_url`, and `delivery_route`
- core runtime now also exposes optional continuation/resume hooks above the initial routed seam:
  - `AgentAdapter#continue_session`
  - `AgentAdapter#resume_session`
  - `AgentTransport#continue_session`
  - `AgentTransport#resume_session`
- those hooks are intentionally opt-in today, so graph-owned local continuity remains the default until a transport explicitly declares session lifecycle support
- the server transport now declares that support and uses a real owner-driven remote session protocol:
  - initial pending remote calls persist their session in `AgentSessionStore`
  - continuation and resume resolve by token against that server-owned store
  - that owner state now lives behind the server's configured runtime store, so remote session ownership becomes durable when the server store is durable
  - the wire format still carries full `AgentSession` snapshots, but the remote owner is now the source of truth once the session is opened

## Near-Term Direction

Near-term work should preserve this separation:

1. keep `igniter-core` free of actor-runtime ownership
2. make `igniter-ai` depend on `igniter-agents` only where AI agents are explicitly loaded
3. let `cluster` and app scaffolds depend on `igniter-agents` openly instead of via `core`
4. continue moving canonical docs and examples to `igniter/agent` and `igniter/agents`
5. evolve `agent node` and app orchestration as the first graph-level bridge into long-lived actors

## Session Direction

The current session model is intentionally simple but now explicit:

- an `agent` node may stay pending across multiple turns
- each continuation updates `turn`, `history`, `payload`, and `agent_trace`
- sessions now also keep `phase`, `messages`, `last_request`, and `last_reply`
- sessions now also expose an explicit lifecycle contract instead of only ad hoc booleans:
  - `lifecycle_state`
  - `interactive?`
  - `terminal?`
  - `continuable?`
  - `routed?`
- sessions now also carry explicit routed ownership metadata when delivery is remote:
  - `ownership`
  - `owner_url`
  - `delivery_route`
- session/runtime surfaces now also project the same canonical agent interaction vocabulary instead of only scattered reply/session/tool-loop fields:
  - `interaction_contract`
  - `routing_mode`
  - `finalizer`
  - `session_policy`
  - `tool_loop_policy`
- stream/runtime surfaces now also project a first-class tool runtime contract instead of only flat `tool_loop_status`:
  - `tool_runtime`
  - `interaction_count`
  - `pending_count`
  - `completed_count`
  - `orphaned_count`
  - `open_tools`
  - `orphan_tools`
- `reply: :single` forbids pending delivery
- `reply: :deferred` preserves the current resumable single-reply lifecycle
- `reply: :stream` requires session-based delivery and opens a path toward partial replies
- `reply: :stream` now also surfaces a dedicated `Runtime::StreamResult` while the node is still pending
- stream nodes can now auto-materialize their final value through `finalizer:`
- streaming is beginning to move from raw `chunk` payloads to typed stream events, with `chunks` kept as a derived convenience view
- final completion preserves the completed session in node details for diagnostics/provenance
- store-backed runners persist and restore that lifecycle instead of treating the session as caller-owned state
- routed sessions may now opt into adapter-owned continuation/resume handling through the new session lifecycle hooks, while still falling back to the existing graph-owned continuity model by default
- the first concrete transport that uses that seam is now `Igniter::Server::AgentTransport`, which handles remote continuation/resume over `/v1/agent-sessions/:token/...`
- on the server side those continuation/resume calls now resolve against stored owner state by token, rather than relying only on the caller to resend the current session snapshot every turn
- the runtime query plane now also treats those routed/session semantics as first-class dimensions:
  - `ownership`
  - `lifecycle_state`
  - `interactive`
  - `terminal`
  - `continuable`
  - `routed`
- the same query truth is now also available directly from durable store-backed executions through:
  - `Contract.agent_session_query_from_store(execution_id, ...)`
  - `Contract.agent_session_summary_from_store(execution_id, ...)`
- orchestration now also has a runtime-owned overview layer instead of living only as planner output and app inbox projection:
  - `Execution#orchestration_overview`
  - `Execution#orchestration_summary`
  - `Execution#orchestration_transition_query`
  - `Execution#orchestration_transition_summary`
  - `Execution#orchestration_transition_overview`
  - `Contract#orchestration_overview`
  - `Contract#orchestration_summary`
  - `Contract.orchestration_overview_from_store(execution_id, ...)`
  - `Contract.orchestration_summary_from_store(execution_id, ...)`
  - `Contract.orchestration_transition_overview_from_store(execution_id, ...)`
  - `Contract.orchestration_transition_summary_from_store(execution_id, ...)`
- that overview now also carries an explicit orchestration runtime contract, not only ad hoc status strings:
  - `runtime_status`
  - `runtime_state`
  - `runtime_state_class`
  - `runtime_terminal`
  - `latest_runtime_transition`
  - `runtime_transitions`
- that runtime contract is derived from execution state plus runtime events, so live and store-backed orchestration views can speak one execution-owned vocabulary for session-backed, active, pending, blocked, and terminal states
- orchestration runtime now also has a first-class transition surface over that contract:
  - top-level `transitions` overview
  - filterable/orderable transition query
  - durable store-backed transition summary/restore path
- store-backed pending agent snapshots now also normalize their embedded session lifecycle from the merged routed ownership/session fields, so persisted `lifecycle` truth stays aligned with `ownership`, `owner_url`, and `delivery_route`
- app operator records now also project the same session truth into the joined operator plane through fields like:
  - `session_lifecycle_state`
  - `ownership`
  - `owner_url`
  - `delivery_route`
  - `interactive`
  - `terminal`
  - `continuable`
  - `routed`
- mounted operator surfaces now also expose those session dimensions directly:
  - operator overview/API filters support `ownership`, `session_lifecycle_state`, `interactive`, `terminal`, `continuable`, and `routed`
  - `App.operator_overview(...)` now also carries an explicit `runtime` block with session-focused counts/facets like `total_sessions`, `interactive_sessions`, `routed_sessions`, `by_ownership`, and `by_session_lifecycle_state`
- execution-scoped `App.operator_overview(...)` now also carries `orchestration_runtime`, which projects the runtime-owned orchestration overview alongside the operator record plane
- that app-level `orchestration_runtime` projection now also merges inbox/operator history back into the runtime records through fields like `inbox_status`, `inbox_action_history`, and `combined_timeline`, so orchestration workflow visibility is no longer split into unrelated runtime and inbox histories
- app now also exposes that merged orchestration runtime truth directly through:
  - `App.orchestration_runtime_overview(target)`
  - `App.orchestration_runtime_summary(target)`
  - `App.orchestration_runtime_transition_overview(target)`
  - `App.orchestration_runtime_transition_summary(target)`
  - `App.orchestration_runtime_overview_for_execution(graph:, execution_id:)`
  - `App.orchestration_runtime_summary_for_execution(graph:, execution_id:)`
- and the same transition surface is now available for restored executions too:
  - `App.orchestration_runtime_transition_overview_for_execution(...)`
  - `App.orchestration_runtime_transition_summary_for_execution(...)`
- diagnostics now also surface that same execution-owned orchestration runtime as `app_orchestration_runtime`, so follow-up workflow visibility is no longer hidden only inside the operator overview payload
- orchestration resume/resolve results now also carry a post-operation runtime snapshot contract instead of only `runtime_resumed` flags:
  - `orchestration_runtime_summary`
  - `orchestration_runtime_record`
  - `orchestration_runtime_status`
  - `orchestration_runtime_state`
  - `orchestration_runtime_state_class`
  - `orchestration_runtime_timeline`
- that same contract now comes back from both live and store-backed orchestration resume paths, so app handlers and mounted operator actions no longer have to infer runtime truth from inbox status alone
  - the built-in operator console now round-trips those filters, renders runtime session cards, and shows the same session lifecycle/ownership/timeline fields in record detail

This is the first step toward making agents a durable execution concept inside Igniter rather than a thin adapter callback.

## Next Architectural Pass

After the package split is stable, we can evaluate a deeper model:

- agent behavior as a contract-level execution primitive
- graph-visible agent/proxy nodes
- a core-side adapter for bridging contracts to long-lived actors
- clearer semantics for mailbox state versus graph state
- higher-level orchestration handlers built on top of planner-visible agent actions
- a read-only query surface over live `AgentSession` and orchestration state before attempting a full `MeshQL`-style language for agents
- deeper remote agent lifecycle ownership above the new routed-agent seam, rather than only initial remote delivery

That is a separate architectural pass and should be designed intentionally rather than smuggled into the gem extraction.

See also: [Agent Node](./agent-node.md)
See also: [Contracts And Agents](./contracts-and-agents.md)
See also: [Agents Roadmap](./agents-roadmap.md)
