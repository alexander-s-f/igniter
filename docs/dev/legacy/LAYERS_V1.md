# Igniter Layers v1

Legacy reference note:

- this document remains useful for historical separation rationale
- for the current canonical reading, start with [docs/dev/module-system.md](./dev/module-system.md), [docs/dev/package-map.md](./dev/package-map.md), and [docs/dev/architecture.md](./dev/architecture.md)

This document defines the intended separation between the three main Igniter
deployment modes:

- `Embed` — lightweight business-logic kernel for an existing Ruby app
- `Server` — single-machine app runtime
- `Cluster` — distributed, fault-tolerant network runtime

The goal is not only namespacing. The goal is load-bearing separation:

- a Rails app should be able to `require "igniter"` without pulling in server,
  cluster, AI, stack, or operational tooling concerns
- upper layers should compose the lower ones explicitly
- shared seams should be narrow, stable, and replaceable

## The Three Modes

### 1. Embed

Primary entrypoint:

```ruby
require "igniter"
```

Responsibility:

- contract DSL
- graph model
- compiler
- runtime
- events
- diagnostics
- core execution stores and runners

This is the business-logic kernel. It should feel natural inside Rails, Sidekiq,
or plain Ruby without dragging in hosting, networking, providers, or scaffolding.

Optional add-ons that still preserve embedded use:

- `require "igniter/extensions/<feature>"`
- `require "igniter/core/<feature>"` for focused core features like memory,
  temporal support, metrics, and caches
- `require "igniter/core"` only when the app also wants actors / tools

### 2. Server

Primary entrypoints:

```ruby
require "igniter/app"
require "igniter/core"
require "igniter/sdk/agents"   # optional
require "igniter/ai"        # optional
require "igniter/sdk/channels"  # optional
```

Responsibility:

- single-machine hosting
- Rack / HTTP server
- stack / app profile
- agent runtime
- generic agent libraries, AI, and communication capabilities when requested by the app

Conceptually:

```text
Server = Embed + hosting + app/stack profile + actor/tool kit + optional agents/AI/channels
```

`Igniter::App` stays above `Igniter::Server`. It is not a peer of the
embedded kernel; it is the opinionated packaging layer for the single-node mode.

### 3. Cluster

Primary entrypoint:

```ruby
require "igniter/cluster"
```

Responsibility:

- everything from `Server`
- network-aware remote routing
- mesh / consensus / replication
- ownership, projection, and distributed execution support
- fault tolerance and future self-evolution features

Conceptually:

```text
Cluster = Server + networking + decentralization + resilience + evolution
```

## Dependency Direction

Allowed direction:

```text
Embed
  ├─ Extensions
  ├─ Actor/Tool kit
  ├─ Agents
  ├─ AI
  ├─ Channels
  └─ Server
       └─ App / Stack
            └─ Cluster
```

Practical rules:

- `Embed` must not require `Server`, `App`, `Stack`, `Cluster`, `AI`, or `Channels`.
- `Server` may depend on `Embed`, actor/tool primitives, and optional capability layers.
- `App` may depend on `Server`, but `Server` should not depend on `App`.
- `Cluster` may depend on `Server`, but `Server` must not depend on `Cluster`.
- `Agents`, `AI`, and `Channels` are capabilities, not the base kernel.

## Shared Seams That Need To Stay Narrow

### Remote execution seam

Current shared seam:

- `Igniter::Runtime.remote_adapter`

This is the correct kind of seam: core runtime knows only that a transport
adapter exists. It does not need to know whether the transport is HTTP, mesh,
owner-routing, or something else.

What to improve next:

- avoid hidden global side effects where upper-layer entrypoints silently replace
  the adapter
- make transport activation more explicit in `Server` / `Cluster`
- keep the default embedded experience safe: remote nodes should fail clearly
  without loading network layers

### Config seam

Keep separate:

- embedded execution config
- server transport / registry config
- stack / app profile config
- cluster topology / ownership / consensus config

The same object should not grow into a universal cross-layer config bag.

### Tooling seam

`Igniter::Tool` belongs to the actor/tool kit, but built-in operational tools such
as local environment discovery do not belong in the minimal core load path.

Entry point split:

- `require "igniter/core"` — actor/tool primitives
- `require "igniter/sdk/tools"` — built-in operational tool pack

### Data seam

Keep distinct:

- execution persistence
- app record persistence (`Igniter::Data`)
- cluster replication / projection state
- memory / reflection / AI state

These can share storage engines, but they should not share ownership or API
surfaces by accident.

## Current Refactoring Decisions

Implemented now:

- `require "igniter"` remains the embedded kernel entrypoint
- `require "igniter/core"` no longer auto-loads built-in operational tools
- built-in system/bootstrap tools now live behind `require "igniter/sdk/tools"`
- generic built-in agents now live behind `require "igniter/sdk/agents"`
- `Igniter::SDK` can register and activate optional capability packs per layer
- `Igniter.use`, `Igniter::App.use`, `Igniter::Server.use`, and `Igniter::Cluster.use`
  now provide a thin declarative wrapper over ordinary `require`
- load-boundary specs verify that `igniter`, `igniter/core`, and `igniter/sdk/*`
  stay separated without fallback top-level optional-pack aliases

## Recommended Next Steps

1. Keep transport activation explicit in examples, docs, and generated apps instead
   of relying on `require` side effects.
2. Split server-facing config objects from stack/profile config more sharply.
3. Decide whether generic non-AI agents remain in the actor/tool kit or move under
   a dedicated server-mode standard library entrypoint.
4. Keep examples and generated apps loading the smallest entrypoints they need.

For the pack-by-pack contract, see [SDK v1](./SDK_V1.md).
For the full three-axis module model, see [Module System v1](./MODULE_SYSTEM_V1.md).
