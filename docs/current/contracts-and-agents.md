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

The planner now sees some of that distinction as well. Agent-backed plans expose orchestration hints for things like interactive streaming sessions, manual completion, deferred resumable calls, and delivery-only casts. They also now expose recommended orchestration actions such as opening an interactive session, requiring manual completion, or awaiting a deferred reply. That matters because higher-level orchestration should not have to rediscover those semantics by reverse-engineering low-level node flags.

That keeps text streaming simple while leaving room for richer agent execution and observability.

## Practical Boundary

Near-term architectural rule:

- keep the graph/compiler/runtime kernel small and explicit
- move richer orchestration semantics upward into contracts and agents
- avoid hiding new execution concepts in adapters or package internals when they deserve first-class runtime shape

See also:

- [Agents](./agents.md)
- [Agent Node](./agent-node.md)
