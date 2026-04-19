# Contracts And Agents

This note captures the intended doctrine for Igniter as the runtime grows.

## Core Position

- contracts are the fundamental execution model
- agents are a first-class runtime concept, not an optional wrapper around callbacks
- Igniter should gradually be able to build more of itself out of contracts and agents

That does **not** mean every low-level kernel class must be rewritten in terms of higher abstractions. The kernel should stay small, direct, and predictable.

It **does** mean that orchestration layers should increasingly become self-applications of the same primitives Igniter exposes to users.

## What "Contract Fundamental" Means

Contracts remain the canonical place for:

- declaration of dataflow and dependency edges
- validation and compilation
- execution planning
- output ownership and provenance
- stable runtime semantics

If a workflow can be modeled as a validated graph, it should prefer contracts over ad-hoc orchestration code.

## What "Agent First" Means

Agents are no longer just implementation details behind adapters.

They are becoming first-class in three ways:

- graph-visible through `agent` nodes
- runtime-visible through `AgentSession`
- interaction-visible through explicit reply modes and stream events

This makes long-lived, stateful, message-driven execution part of Igniter's actual model instead of a side channel.

## Self-Application Direction

The long-term direction is architectural self-application:

- routing
- planning
- retries
- tool loops
- AI workflows
- cluster coordination

These are strong candidates to be expressed with contracts and agents internally once the primitives are mature enough.

The analogy is a compiler that eventually becomes able to compile itself. For Igniter, the corresponding goal is a runtime that can increasingly orchestrate itself using its own validated execution model.

## Typed Stream Direction

Streaming should converge on typed events rather than raw text chunks alone.

Current events are intentionally small, but the direction is clear:

- `:chunk`
- `:status`
- `:tool_call`
- `:tool_result`
- `:artifact`
- `:final`

`chunks` remain a convenient derived view for text-first cases, but the canonical model should be an ordered stream of typed events.

The first runtime slice now validates those event types before stream continuations are accepted into `AgentSession`, so the event model is already beginning to act like a language contract rather than an informal convention.

The next practical layer is tool-loop honesty: stream events should have canonical constructors and readers for tool activity, so `tool_call` and `tool_result` become first-class runtime language, not just arbitrary hashes buried in payloads.

That now includes correlation helpers as well: tool activity can be read back as matched interactions instead of a flat event list, which makes tool loops much closer to a real execution model.

It also now carries explicit completion semantics. That matters because planner/diagnostics-friendly signals such as `open`, `complete`, and `orphaned` are much closer to how real agent orchestration needs to reason about tool work.

That signal is now active in runtime behavior too: stream sessions no longer auto-finalize through built-in finalizers while tool work is still open or orphaned. In other words, the tool-loop model is no longer only descriptive; it is beginning to constrain execution.

The planner now sees some of that distinction as well. Agent-backed plans expose orchestration hints for things like interactive streaming sessions, manual completion, deferred resumable calls, and delivery-only casts. They also now expose recommended orchestration actions such as opening an interactive session, requiring manual completion, or awaiting a deferred reply. `igniter-app` already consumes that surface to open deduplicated orchestration inbox items, and those items now have their own small lifecycle (`acknowledge`, `resolve`, `dismiss`). That is the first concrete step from "planner semantics" toward actual runtime follow-up handling.

That app-level follow-up path is now tied back into runtime truth too:

- opening follow-ups against a live contract materializes the relevant pending agent sessions before inbox items are created
- inbox items carry runtime identity such as graph, execution id, node, token, and reply shape when a live session exists
- resolving an inbox item can now resume the underlying agent session instead of only changing inbox state
- resume is now node-aware, not only token-aware, so parallel agent nodes do not get conflated when session tokens are reused
- orchestration actions now carry explicit app-level policy metadata rather than only raw action names
- built-in handlers enforce those policies, so allowed operations and default behavior now come from one visible contract
- that contract is now also starting to speak the language of agent workflows rather than only inbox lifecycle:
  - `wake`
  - `handoff`
  - `approve`
  - `reply`
  - `complete`
- `handoff` is now also ownership-aware: orchestration items can carry assignee, queue, and channel metadata plus a small handoff history, which is the first real step from "runtime inbox" toward operator workflow
- initial queue/channel routing is now planner-visible too, and apps can override it per orchestration action without rewriting the policy surface
- queue selection is now also policy-aware: apps can register queue-specific orchestration policies, so operator lanes may change default behavior and allowed operations, not only assignment metadata
- orchestration lanes are now explicit too: apps can register first-class lane bundles that carry routing, policy, and handler semantics together instead of treating queues as plain strings
- app-level operator tooling now has a read-only query surface too, so inbox state can be sliced by lane, queue, channel, assignee, status, and interaction without reaching directly into snapshots
- that operator view now also supports `facet`, `facets`, and `summary`, so orchestration state can already be treated as a small aggregate field rather than only a list of inbox items

There is also now a clearer direction for OLAP-like query semantics in agents:

- `cluster` already has the mature path `NodeObservation -> ObservationQuery -> MeshQL`
- `agents` already have most of the raw dimensions through `AgentSession`, stream events, and orchestration inbox state
- the safest next step is a read-only query surface over live agent sessions and orchestration items, not an immediate distributed `MeshQL for agents`
- runtime now has that first query slice through `execution.agent_session_query`, which keeps the work local and observational instead of forcing early registry/discovery changes
- the runtime query slice now also supports `facet`, `facets`, and `summary`, which is the first honest OLAP-like surface for agents without introducing a new language yet

The local agent runtime also crossed an important threshold: `PendingDependencyError` raised inside a local registry-backed agent no longer degrades into a timeout. It now propagates back through the registry adapter as an honest runtime `pending` result, which means local actor delivery and graph-level resumable semantics are finally aligned.

That keeps text streaming simple while leaving room for richer agent execution and observability.

## Current Development Priorities

The next likely development order is:

1. harden orchestration as an end-to-end runtime surface, not only a planner/introspection surface
2. deepen `AgentSession` into a stronger conversational lifecycle model
3. extend agent delivery beyond the local registry without losing the same graph/session semantics
4. increasingly move Igniter's own orchestration layers onto contracts and agents

See also:

- [Agents Roadmap](./agents-roadmap.md)

## Practical Boundary

Near-term architectural rule:

- keep the graph/compiler/runtime kernel small and explicit
- move richer orchestration semantics upward into contracts and agents
- avoid hiding new execution concepts in adapters or package internals when they deserve first-class runtime shape

See also:

- [Agents](./agents.md)
- [Agent Node](./agent-node.md)
