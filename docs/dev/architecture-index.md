# Igniter — Architecture Index

Start here if you want the shortest accurate map of Igniter's structure.

## Layer Map

| Layer | Namespace / Require | Responsibility |
|------|----------------------|----------------|
| Embed kernel | `Igniter` / `require "igniter"` | contract DSL, model, compiler, runtime, events, diagnostics |
| Legacy kernel lane | `Igniter` / `require "igniter/legacy"` or `require "igniter/legacy/<feature>"` | explicit compatibility/reference lane over the old kernel implementation |
| Deprecated core alias | `Igniter` / `require "igniter/core"` or `require "igniter/core/<feature>"` | warning alias kept for migration parity; not the preferred loading surface |
| Agents runtime | `Igniter::Agent` / `require "igniter/agent"` and `require "igniter/agents"` | actor primitives, registry, supervision, generic built-in agents, AI agent implementations |
| SDK tools pack | `Igniter` / `require "igniter/sdk/tools"` | system discovery, workflow selection, bootstrap-planning tools |
| Extensions | `require "igniter/extensions/<feature>"` | behavioral add-ons such as auditing, provenance, incremental, dataflow, invariants |
| AI SDK pack | `Igniter::AI` / `require "igniter/ai"` | providers, AI executors, skills, transcription, AI tool registry |
| Channels SDK pack | `Igniter::Channels` / `require "igniter/sdk/channels"` | transport adapters such as webhook, Telegram, WhatsApp, email, SMS |
| Data SDK pack | `Igniter::Data` / `require "igniter/sdk/data"` | JSON-first stores for app records, notes, bindings, and lightweight app data |
| Server | `Igniter::Server` / `require "igniter/server"` | HTTP hosting, Rack app, remote execution transport; activation is explicit |
| App | `Igniter::App` / `require "igniter/app"` | single-node app runtime profile: config, autoloading, scheduler, host-adapter seam |
| Stack | `Igniter::Stack` / `require "igniter/stack"` | stack coordinator: shared paths, app registry, mounted runtime, optional node profiles |
| App Runtime | `Igniter::App` / `require "igniter/app/runtime"` | narrow leaf runtime entrypoint without stack umbrella |
| Cluster | `Igniter::Cluster` / `require "igniter/cluster"` | network runtime: consensus, mesh, replication, cluster-aware routing |
| Plugins | `Igniter::Plugins::*` / `require "igniter/plugins/<name>"` | framework-specific integrations |

## Dependency Rules

Allowed direction of dependencies:

```text
runtime pyramid
  core -> server/app -> cluster

actor runtime
  igniter-agents

horizontal capability plane
  sdk/*

horizontal integration plane
  plugins/*
```

Practical rules:

- Core must not know about `Agents`, `Server`, `Cluster`, `sdk/*`, or `plugins/*`.
- `igniter-agents` may depend on core, but core must not regain ownership of actor runtime.
- Extensions may build on core, but should not become a grab-bag for unrelated features.
- `sdk/*` may depend on core, and must stay explicit.
- `Server` may depend on core and optional upper capability layers.
- `App` is a profile over `Server`, not a sibling capability layer.
- `Igniter::Stack` coordinates mounted apps and optional node profiles; `Igniter::App` remains the leaf runtime.
- `Cluster` sits above `Server`.
- Plugins adapt external frameworks into Igniter layers; they do not redefine the core.

## Filesystem Rules

Canonical layout:

```text
packages/igniter-core/lib/igniter/
  core.rb
  core/
packages/igniter-agents/lib/igniter/
  agent.rb
  agents.rb
  registry.rb
  supervisor.rb
  agent/
  agents/
  ai/agents.rb
  ai/agents/
packages/igniter-ai/lib/igniter/
  ai.rb
  ai/
packages/igniter-sdk/lib/igniter/
  sdk.rb
  sdk/
packages/igniter-app/lib/igniter/
  app.rb
  app/
packages/igniter-server/lib/igniter/
  server.rb
  server/
packages/igniter-cluster/lib/igniter/
  cluster.rb
  cluster/
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
- `packages/igniter-core/lib/igniter/legacy/` is the explicit compatibility lane
  that stable entrypoints should prefer over direct `igniter/core/*` feature paths.
- `packages/igniter-agents/lib/igniter/` holds actor runtime and agent implementations.
- `lib/igniter/extensions/` holds extension entrypoints.
- `packages/igniter-sdk/lib/igniter/sdk/` holds the SDK registry plus non-AI, non-agent sdk packs.
- `packages/igniter-ai/lib/igniter/ai/` holds canonical AI implementation.
- `packages/igniter-app/lib/igniter/app/`, `packages/igniter-server/lib/igniter/server/`, and `packages/igniter-cluster/lib/igniter/cluster/` hold the remaining layer implementation code.
- `lib/igniter/plugins/` holds framework-specific integrations.

## Loading Rules

Prefer the smallest require that matches the feature you need.

| Need | Require |
|------|---------|
| Contracts, DSL, runtime | `require "igniter"` |
| Explicit legacy kernel lane | `require "igniter/legacy"` |
| Actor runtime primitives | `require "igniter/agent"` |
| Generic agents | `require "igniter/agents"` |
| SDK registry / capability activation | `require "igniter/sdk"` |
| Built-in operational tools | `require "igniter/sdk/tools"` |
| One legacy feature | `require "igniter/legacy/tool"` or `require "igniter/legacy/temporal"` |
| One extension | `require "igniter/extensions/auditing"` |
| AI | `require "igniter/ai"` |
| AI agents | `require "igniter/ai/agents"` |
| Channels | `require "igniter/sdk/channels"` |
| App data persistence | `require "igniter/sdk/data"` |
| HTTP hosting | `require "igniter/server"` |
| App scaffold/profile | `require "igniter/app"` |
| Distributed runtime | `require "igniter/cluster"` |
| Rails plugin | `require "igniter/plugins/rails"` |
| Frontend package | `require "igniter-frontend"` |
| Schema rendering package | `require "igniter-schema-rendering"` |

`require "igniter/core"` remains available only as a deprecated warning alias
for the retirement window.

Frontend docs:

- [Frontend Authoring](./FRONTEND_AUTHORING.md)
- [Frontend Components](./FRONTEND_COMPONENTS.md)
- [Schema Rendering Authoring](./SCHEMA_RENDERING_AUTHORING.md)
- [Frontend Packages Idea](./FRONTEND_PACKAGES_IDEA.md)

## Placement Heuristics

If you are adding new code:

- Put it in **core** if it is useful in embedded mode and does not require hosting, distribution, providers, or frameworks.
- Put it in **agents** if it is actor runtime infrastructure or a reusable long-lived agent implementation.
- Put it in **extensions** if it changes or enriches runtime behavior without belonging to a separate capability layer.
- Put it in **AI** if it depends on providers, prompts, skills, transcription, or AI tool orchestration.
- Put it in **Channels** if it is a communication or delivery transport.
- Put it in **Server** if it is about HTTP hosting or remote transport.
- Put it in **App** if it is about project layout, boot lifecycle, or scheduler/profile behavior.
- Put it in **Cluster** if it is about distributed coordination or routing across nodes.
  Ownership, cluster event logs, projection feeds, routing-to-owner, projection stores, leases, and replicated metadata belong here too.
- Put it in **Plugins** if it adapts Rails or another framework.

## Canonical Mental Model

```text
core foundation
  + optional core features
  + optional extensions
  + optional capability layers (agents, ai, channels, data, tools)
  + optional hosting/profile layers (server, app, cluster)
  + optional plugins
```

Read next:

- [SDK v1](./SDK_V1.md)
- [Integrations v1](./INTEGRATIONS_V1.md)
- [Module System v1](./MODULE_SYSTEM_V1.md)
- [Layers v1](./LAYERS_V1.md)
- [Architecture v2](./ARCHITECTURE_V2.md)
- [Persistence Model v1](./PERSISTENCE_MODEL_V1.md)
- [Cluster Debug v1](./CLUSTER_DEBUG_V1.md)
- [Deployment Scenarios v1](./DEPLOYMENT_V1.md)
- [App v1](./APP_V1.md)
- [Stacks v1](./STACKS_V1.md)

Cluster direction:

- [Cluster Next Roadmap](./cluster/ROADMAP_NEXT.md)
- [Cluster State Snapshot](./cluster/STATE_NEXT.md)
- [OLAP Point v1](./OLAP_POINT_V1.md) — each node as a multi-dimensional query surface
- [MeshQL v1](./MESH_QL_V1.md) — declarative string query language for the cluster field
