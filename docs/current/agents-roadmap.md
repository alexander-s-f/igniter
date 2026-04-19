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
- local registry-backed agents now propagate `PendingDependencyError` as honest runtime `pending`, not timeout failure

That is enough to treat agents as a real execution surface, not only an adapter seam.

## Next

### 1. Orchestration Runtime

Priority: very high

Goal:

- turn orchestration actions into a fuller runtime API, not only planner output and app inbox items

What this likely means:

- explicit orchestration policies for approval, wakeup, and follow-up handling
- app-level adapters/handlers for `require_manual_completion`, `await_deferred_reply`, and interactive sessions
- cleaner bridges between inbox lifecycle and runtime session lifecycle
- durable store-backed orchestration handling, not only in-memory app state

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

### 3. Remote And Routed Agents

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

### 4. Self-Application

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

### 5. Unified Execution Profiles

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
