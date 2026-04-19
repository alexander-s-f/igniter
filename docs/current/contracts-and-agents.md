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

That keeps text streaming simple while leaving room for richer agent execution and observability.

## Practical Boundary

Near-term architectural rule:

- keep the graph/compiler/runtime kernel small and explicit
- move richer orchestration semantics upward into contracts and agents
- avoid hiding new execution concepts in adapters or package internals when they deserve first-class runtime shape

See also:

- [Agents](./agents.md)
- [Agent Node](./agent-node.md)
