# Igniter Module System v1

This document is the top-level map of Igniter's module system.

Igniter now has three independent architectural axes:

1. **Runtime layers** — how execution is hosted and scaled
2. **SDK packs** — optional shared capabilities
3. **Plugins** — framework and environment integrations

If you want the shortest accurate answer to "where should this code live?",
start here.

## The Three Axes

### 1. Runtime Pyramid

The runtime pyramid defines execution and hosting:

```text
core
  -> server/app
       -> cluster
```

Public entrypoints:

| Layer | Require | Responsibility |
|------|---------|----------------|
| Core | `require "igniter"` | contracts, compiler, runtime, diagnostics, events |
| Actor / tool foundation | `require "igniter/core"` | actors, tool primitives, memory, metrics, temporal support, caches |
| Server | `require "igniter/server"` | HTTP hosting, remote execution transport |
| App | `require "igniter/app"` | single-node runtime profile, host/loader/scheduler wiring |
| Stack | `require "igniter/stack"` | multi-app stack coordination |
| Cluster | `require "igniter/cluster"` | mesh, consensus, replication, distributed execution |

Rules:

- lower layers must not know about upper layers
- upper layers may compose lower layers explicitly
- `require` must not silently mutate runtime state just because a layer loads

## 2. SDK Packs

`sdk/*` is the optional capability plane.

These are reusable packs that higher layers can opt into without inflating the
embedded core.

Public entrypoints:

| Pack | Require | Namespace | Responsibility |
|------|---------|-----------|----------------|
| Agents | `require "igniter/sdk/agents"` | `Igniter::Agents` | reusable non-AI standard-library agents |
| AI | `require "igniter/sdk/ai"` | `Igniter::AI` | providers, skills, AI executors, transcription, AI agents |
| Channels | `require "igniter/sdk/channels"` | `Igniter::Channels` | communication and delivery adapters |
| Data | `require "igniter/sdk/data"` | `Igniter::Data` | lightweight app-facing persistence |
| Tools | `require "igniter/sdk/tools"` | `Igniter` | built-in operational tools |

Rules:

- SDK packs are the only public surface for optional shared capabilities
- top-level optional shortcuts are not public API
- SDK packs may depend downward on core and explicitly allowed runtime layers
- SDK packs must not become hidden boot mechanisms

## 3. Plugins

`plugins/*` is the integration plane.

Plugins adapt external environments into Igniter. They are not part of the
runtime pyramid and they are not generic capability packs.

Public entrypoints:

| Plugin | Require | Namespace | Responsibility |
|--------|---------|-----------|----------------|
| Rails | `require "igniter/plugins/rails"` | `Igniter::Rails` | Railtie, ActiveJob, ActionCable, controller concerns, generators |
| View | `require "igniter/plugins/view"` | `Igniter::Plugins::View` | schema-driven view/runtime integration |

Rules:

- plugins may depend on core and on the layer they integrate with
- plugins may depend on `sdk/*` where the integration contract requires it
- plugins must expose environment-facing integration code, not generic reusable primitives

## Unified Mental Model

All three axes together:

```text
runtime pyramid
  core -> server/app -> cluster

horizontal capability plane
  sdk/agents
  sdk/ai
  sdk/channels
  sdk/data
  sdk/tools

horizontal integration plane
  plugins/rails
  plugins/view
```

Another way to see it:

```text
Igniter
  = runtime foundation
  + optional capability packs
  + optional integration plugins
```

## Dependency Matrix

### Runtime layers

- `core` must not depend on `server`, `app`, `stack`, `cluster`, `sdk/*`, or `plugins/*`
- `server` may depend on `core`
- `app` may depend on `server` and `core`
- `stack` may depend on `app`
- `cluster` may depend on `server`, `app`, and `core`

### SDK packs

- `sdk/*` may depend on `core`
- some packs may be allowed only for upper runtime layers via `Igniter::SDK`
- `sdk/*` must not introduce hidden runtime-layer side effects

### Plugins

- `plugins/*` may depend on core and the layer they integrate with
- `plugins/*` may depend on `sdk/*` if that is part of the plugin contract
- `plugins/*` should not redefine the module system or bypass it

## Placement Guide

When adding new code:

- put it in **core** if it is fundamental and embedding-friendly
- put it in **server/app/stack/cluster** if it is runtime-hosting or distributed execution behavior
- put it in **sdk/*** if it is optional, shared, and reusable across apps
- put it in **plugins/*** if it adapts a framework, UI runtime, or host environment
- put it in **extensions** if it enriches runtime behavior without becoming its own capability or plugin

Quick heuristic:

```text
Is it fundamental execution machinery?
  -> core / runtime layer

Is it optional and reusable?
  -> sdk/*

Is it a framework or environment adapter?
  -> plugins/*
```

## Filesystem Model

Canonical root entrypoints:

```text
lib/igniter.rb
lib/igniter/core.rb
lib/igniter/app.rb
lib/igniter/server.rb
lib/igniter/cluster.rb
lib/igniter/stack.rb
lib/igniter/sdk.rb
lib/igniter/plugins.rb
```

Canonical implementation roots:

```text
lib/igniter/core/
lib/igniter/app/
lib/igniter/server/
lib/igniter/cluster/
lib/igniter/sdk/
lib/igniter/plugins/
lib/igniter/extensions/
```

`lib/igniter/` root should not grow new shortcut entrypoints for optional packs
or plugins.

## Loading Rules

Prefer the narrowest public require that matches the job:

```ruby
require "igniter"                # embedded core
require "igniter/core"           # actor/tool foundation
require "igniter/app"            # app runtime profile
require "igniter/cluster"        # distributed runtime
require "igniter/sdk/ai"         # optional capability
require "igniter/plugins/rails"  # framework integration
```

## Recommended Reading

- [Architecture Index](./ARCHITECTURE_INDEX.md)
- [Layers v1](./LAYERS_V1.md)
- [SDK v1](./SDK_V1.md)
- [Plugins v1](./PLUGINS_V1.md)
- [Architecture v2](./ARCHITECTURE_V2.md)
