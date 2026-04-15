# Igniter — Architecture Index

Start here if you want the shortest accurate map of Igniter's structure.

## Layer Map

| Layer | Namespace / Require | Responsibility |
|------|----------------------|----------------|
| Embed kernel | `Igniter` / `require "igniter"` | contract DSL, model, compiler, runtime, events, diagnostics |
| Actor / tool kit | `Igniter` / `require "igniter/core"` or `require "igniter/core/<feature>"` | actors, tool base classes, memory, metrics, temporal support, caches |
| Built-in tools | `Igniter::Tools` / `require "igniter/tools"` | system discovery, workflow selection, bootstrap-planning tools |
| Extensions | `require "igniter/extensions/<feature>"` | behavioral add-ons such as auditing, provenance, incremental, dataflow, invariants |
| AI | `Igniter::AI` / `require "igniter/ai"` | providers, AI executors, skills, transcription, AI tool registry |
| Channels | `Igniter::Channels` / `require "igniter/channels"` | transport adapters such as webhook, Telegram, WhatsApp, email, SMS |
| Server | `Igniter::Server` / `require "igniter/server"` | HTTP hosting, Rack app, remote execution transport; activation is explicit |
| Application | `Igniter::App` / `require "igniter/app"` | single-node app runtime profile: config, autoloading, scheduler, host-adapter seam |
| Stack | `Igniter::Stack` / `require "igniter/stack"` | stack coordinator: shared paths, app registry, topology-aware boot/rack routing |
| App Runtime | `Igniter::App` / `require "igniter/app/runtime"` | narrow leaf runtime entrypoint without stack umbrella |
| Cluster | `Igniter::Cluster` / `require "igniter/cluster"` | network runtime: consensus, mesh, replication, cluster-aware routing |
| Plugins | `Igniter::Plugins::*` / `require "igniter/rails"` | framework-specific integrations |

## Dependency Rules

Allowed direction of dependencies:

```text
Embed
  ├─ Extensions
  ├─ Actor/Tool kit
  ├─ AI
  ├─ Channels
  └─ Server
       └─ Application
            └─ Cluster

Plugins depend on the layer they integrate with.
```

Practical rules:

- Core must not know about `Server`, `Cluster`, `AI`, `Channels`, or plugins.
- Extensions may build on core, but should not become a grab-bag for unrelated features.
- `AI` may depend on core.
- `Channels` may depend on core.
- `Server` may depend on core and optional upper capability layers.
- `Application` is a profile over `Server`, not a sibling capability layer.
- `Igniter::Stack` coordinates leaf apps; `Igniter::App` remains the leaf runtime.
- `Cluster` sits above `Server`.
- Plugins adapt external frameworks into Igniter layers; they do not redefine the core.

## Filesystem Rules

Canonical layout:

```text
lib/igniter/
  ai.rb
  app.rb
  app.rb
  channels.rb
  cluster.rb
  core.rb
  plugins.rb
  rails.rb
  server.rb
  ai/
  app/
  channels/
  cluster/
  core/
  extensions/
  plugins/
  rails/
  server/
```

Stack project layout:

```text
my_app/
  stack.rb
  stack.yml
  apps/
    main/
      app.rb
      app.yml
      app/
      spec/
  lib/<project>/shared/
  spec/
```

Placement rules:

- `lib/igniter/` keeps only top-level public entrypoints.
- `lib/igniter/core/` holds substantive core implementation.
- `lib/igniter/extensions/` holds extension entrypoints.
- `lib/igniter/ai/`, `channels/`, `server/`, `cluster/`, `app/` hold authoritative layer code.
- `lib/igniter/plugins/` holds framework-specific integrations.

## Loading Rules

Prefer the smallest require that matches the feature you need.

| Need | Require |
|------|---------|
| Contracts, DSL, runtime | `require "igniter"` |
| Actors and tools | `require "igniter/core"` |
| SDK registry / capability activation | `require "igniter/sdk"` |
| Built-in operational tools | `require "igniter/tools"` |
| One core feature | `require "igniter/core/tool"` or `require "igniter/core/temporal"` |
| One extension | `require "igniter/extensions/auditing"` |
| AI | `require "igniter/ai"` |
| Channels | `require "igniter/channels"` |
| HTTP hosting | `require "igniter/server"` |
| App scaffold/profile | `require "igniter/app"` |
| Distributed runtime | `require "igniter/cluster"` |
| Rails plugin | `require "igniter/rails"` |

## Placement Heuristics

If you are adding new code:

- Put it in **core** if it is useful in embedded mode and does not require hosting, distribution, providers, or frameworks.
- Put it in **extensions** if it changes or enriches runtime behavior without belonging to a separate capability layer.
- Put it in **AI** if it depends on providers, prompts, skills, transcription, or AI tool orchestration.
- Put it in **Channels** if it is a communication or delivery transport.
- Put it in **Server** if it is about HTTP hosting or remote transport.
- Put it in **Application** if it is about project layout, boot lifecycle, or scheduler/profile behavior.
- Put it in **Cluster** if it is about distributed coordination or routing across nodes.
  Ownership, cluster event logs, projection feeds, routing-to-owner, projection stores, leases, and replicated metadata belong here too.
- Put it in **Plugins** if it adapts Rails or another framework.

## Canonical Mental Model

```text
core foundation
  + optional core features
  + optional extensions
  + optional capability layers (ai, channels)
  + optional hosting layers (server, application, cluster)
  + optional plugins
```

Read next:

- [Layers v1](./LAYERS_V1.md)
- [Architecture v2](./ARCHITECTURE_V2.md)
- [Persistence Model v1](./PERSISTENCE_MODEL_V1.md)
- [Cluster Debug v1](./CLUSTER_DEBUG_V1.md)
- [Deployment Scenarios v1](./DEPLOYMENT_V1.md)
- [App v1](./APP_V1.md)
- [Stacks v1](./STACKS_V1.md)
