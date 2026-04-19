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

This package split does **not** mean that agents are already a first-class contract node.

Not true yet:

- there is no canonical `AgentNode` in the contract model
- there is no `agent` DSL primitive in the graph builder
- `ProxyAdapter` / `AgentAdapter` is not yet the execution bridge for graph-native agents

Today, agents are still actor runtime primitives that can cooperate with contracts, not graph nodes inside the kernel.

## Near-Term Direction

Near-term work should preserve this separation:

1. keep `igniter-core` free of actor-runtime ownership
2. make `igniter-ai` depend on `igniter-agents` only where AI agents are explicitly loaded
3. let `cluster` and app scaffolds depend on `igniter-agents` openly instead of via `core`
4. continue moving canonical docs and examples to `igniter/agent` and `igniter/agents`
5. evolve `agent node` as the first graph-level bridge into long-lived actors

## Next Architectural Pass

After the package split is stable, we can evaluate a deeper model:

- agent behavior as a contract-level execution primitive
- graph-visible agent/proxy nodes
- a core-side adapter for bridging contracts to long-lived actors
- clearer semantics for mailbox state versus graph state

That is a separate architectural pass and should be designed intentionally rather than smuggled into the gem extraction.

See also: [Agent Node](./agent-node.md)
