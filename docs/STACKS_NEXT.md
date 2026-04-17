# Igniter Stack/App Next

This document defines the next model for `Igniter::Stack` and `Igniter::App`.

## Thesis

`apps/` should remain code boundaries, not mandatory process boundaries.

The previous model leaned toward:

- one app
- one process
- one port

That was reasonable when runtime roles were the dominant abstraction.
It becomes increasingly awkward in a capability-first cluster model.

## The New Separation

There are now three different boundaries and they should stay distinct:

### App

An app is a code boundary inside a stack.

It owns:

- contracts
- executors
- tools
- agents
- skills
- app-local wiring

An app does **not** automatically imply a dedicated server process.

### Service

A service is a runtime boundary.

It owns:

- one or more apps
- one listener / host boundary
- process-level environment
- public/internal exposure
- deployment intent

If multiple apps can safely live together, they should be able to share one service.

### Node

A node is a running cluster participant.

It owns:

- identity
- trust state
- capability claims
- live runtime metadata

This is the correct level for cluster thinking.

## Design Rule

Use this rule when deciding where something belongs:

- the number of **apps** should grow with bounded contexts
- the number of **services** should grow with runtime isolation needs
- the number of **nodes** should grow with topology, resilience, scale, and placement needs

These three quantities should not be forced to grow together.

## Why This Matters

If a stack has ten apps, that should not automatically mean:

- ten processes in dev
- ten ports locally
- ten containers in deployment

That coupling creates needless operational cost and discourages modularity.

## vNext Runtime Model

`Igniter::Stack` should be able to:

- register many apps
- define services separately from apps
- run a service that hosts one or more apps
- generate local dev and compose output from services rather than from apps

The first practical shape of this model is:

- one root app may own `/`
- additional apps in the same service can be mounted under prefixes such as `/apps/<name>`

This is not the final form forever, but it is a good compatibility-preserving step.

## Configuration Direction

### `apps/<name>/app.yml`

Should trend toward app-local concerns:

- app-local defaults
- packs
- local persistence defaults
- local feature/runtime wiring

It should stop being the canonical place for service port allocation.

### `config/topology.yml`

Should become the home of runtime boundaries:

- services
- which apps live inside each service
- ports
- exposure
- replica and deployment intent

## Compatibility Direction

Legacy stacks where topology is app-shaped should continue to work.

But the preferred model going forward is:

- `apps:` for code registration
- `services:` for runtime grouping

## First Slice

The first implementation slice of Stack/App Next should provide:

1. topology-level `services`
2. service-based `bin/dev` and compose generation
3. `start_service` / `rack_service`
4. ability for one service to mount multiple apps behind one listener

That is enough to prove the model without forcing a full rewrite of hosting.

## One-Line Rule

`Apps are code boundaries. Services are runtime boundaries. Nodes are cluster boundaries.`
