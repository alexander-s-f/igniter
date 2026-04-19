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
- there is no generalized `ProxyAdapter` for remote or routed delivery
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
- `reply: :single` forbids pending delivery
- `reply: :deferred` preserves the current resumable single-reply lifecycle
- `reply: :stream` requires session-based delivery and opens a path toward partial replies
- `reply: :stream` now also surfaces a dedicated `Runtime::StreamResult` while the node is still pending
- stream nodes can now auto-materialize their final value through `finalizer:`
- streaming is beginning to move from raw `chunk` payloads to typed stream events, with `chunks` kept as a derived convenience view
- final completion preserves the completed session in node details for diagnostics/provenance
- store-backed runners persist and restore that lifecycle instead of treating the session as caller-owned state

This is the first step toward making agents a durable execution concept inside Igniter rather than a thin adapter callback.

## Next Architectural Pass

After the package split is stable, we can evaluate a deeper model:

- agent behavior as a contract-level execution primitive
- graph-visible agent/proxy nodes
- a core-side adapter for bridging contracts to long-lived actors
- clearer semantics for mailbox state versus graph state
- higher-level orchestration handlers built on top of planner-visible agent actions
- a read-only query surface over live `AgentSession` and orchestration state before attempting a full `MeshQL`-style language for agents

That is a separate architectural pass and should be designed intentionally rather than smuggled into the gem extraction.

See also: [Agent Node](./agent-node.md)
See also: [Contracts And Agents](./contracts-and-agents.md)
See also: [Agents Roadmap](./agents-roadmap.md)
