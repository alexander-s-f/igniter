# Igniter SDK v1

This document defines the canonical model for optional capability packs in Igniter.

`sdk/*` is the only public surface for optional shared capabilities.
Top-level optional entrypoints such as `igniter/ai`, `igniter/agents`,
`igniter/channels`, `igniter/data`, and `igniter/tools` are not part of the
public API.

## What SDK Means

In Igniter, `sdk/*` is a horizontal capability layer:

- **Core** stays minimal and embedding-friendly
- **Server / App / Cluster** remain runtime layers
- **SDK packs** provide optional capabilities that higher layers can opt into explicitly

That means `sdk/*` is not another runtime pyramid. It is a catalog of reusable
capability packs that sit beside the runtime layers.

## Canonical Rule

If a capability is optional and shared, its public entrypoint must live under:

```ruby
require "igniter/sdk/<pack>"
```

Examples:

```ruby
require "igniter/sdk/agents"
require "igniter/sdk/ai"
require "igniter/sdk/channels"
require "igniter/sdk/data"
require "igniter/sdk/tools"
```

## Built-in Packs

| Pack | Namespace | Require | Allowed layers | Responsibility |
|------|-----------|---------|----------------|----------------|
| `agents` | `Igniter::Agents` | `require "igniter/sdk/agents"` | `app`, `server`, `cluster` | generic built-in agents for reliability, pipeline, scheduling, proactive monitoring, metrics |
| `ai` | `Igniter::AI` | `require "igniter/sdk/ai"` | `app`, `server`, `cluster` | providers, AI executors, skills, transcription, AI agents, AI tool registry |
| `channels` | `Igniter::Channels` | `require "igniter/sdk/channels"` | `app`, `server`, `cluster` | transport-neutral communication adapters |
| `data` | `Igniter::Data` | `require "igniter/sdk/data"` | `core`, `app`, `server`, `cluster` | JSON-first app persistence and lightweight records |
| `tools` | `Igniter` | `require "igniter/sdk/tools"` | `app`, `server`, `cluster` | built-in operational tools such as discovery, workflow selection, bootstrap planning |

These policies are registered in [lib/igniter/sdk.rb](/Users/alex/dev/projects/igniter/lib/igniter/sdk.rb:5).

## Activation Model

Packs can be loaded directly with `require`, or activated declaratively through
the SDK registry:

```ruby
Igniter.use :data

class MyApp < Igniter::App
  use :agents, :ai, :tools
end

Igniter::Server.use :channels
Igniter::Cluster.use :ai, :channels
```

`use` is intentionally thin. It validates layer policy, then performs a normal
Ruby `require`.

## Dependency Rules

SDK packs may depend downward, never upward.

Practical rules:

- `sdk/*` may depend on `igniter` and `igniter/core/*`
- `sdk/*` must not redefine or backdoor runtime-layer boot
- `sdk/*` must not install transport adapters as a side effect of `require`
- a pack that needs `App`, `Server`, or `Cluster` must declare that explicitly in policy and structure

Current built-in policy:

```text
core
  ├─ sdk/data
  └─ runtime layers
       ├─ sdk/agents
       ├─ sdk/ai
       ├─ sdk/channels
       └─ sdk/tools
```

## Placement Rules

Put code in `sdk/*` when all of the following are true:

- it is optional
- it is reusable across multiple apps or runtimes
- it is not part of the minimal embedded kernel
- it is not a framework plugin

Do not put code in `sdk/*` when it belongs more naturally to:

- **core**: contracts, compiler, runtime, actor/tool primitives, fundamental execution features
- **app/server/cluster**: lifecycle, host/runtime wiring, network transport, topology
- **extensions**: behavioral add-ons to core runtime
- **plugins**: Rails or other framework integration

## Pack-by-Pack Guidance

### `sdk/agents`

Use for reusable non-AI standard-library agents.

Good fit:

- retry orchestration
- batch/pipeline helpers
- scheduling agents
- proactive monitoring
- metrics collection agents

Bad fit:

- app-specific domain agents
- cluster ownership/consensus agents
- AI agents

### `sdk/ai`

Use for AI-specific capabilities.

Good fit:

- provider clients
- prompt/skill abstractions
- tool-using AI executors
- transcription
- built-in AI agents

Bad fit:

- generic actors
- transport channels
- cluster routing logic

### `sdk/channels`

Use for communication and delivery transports.

Good fit:

- webhook adapters
- Telegram delivery
- future email / SMS / WhatsApp adapters

### `sdk/data`

Use for lightweight app-facing persistence abstractions.

Good fit:

- notes, bindings, preferences, lightweight records
- small JSON-first stores used by apps and companion systems

Bad fit:

- execution persistence internals
- cluster replication logs
- low-level runtime stores that belong to core

### `sdk/tools`

Use for built-in operational tools, not tool primitives.

Good fit:

- environment discovery
- workflow selection
- bootstrap planning

Bad fit:

- `Igniter::Tool` base abstractions
- general tool DSL primitives

## File Layout

Canonical layout:

```text
lib/igniter/sdk.rb
lib/igniter/sdk/
  agents.rb
  ai.rb
  channels.rb
  data.rb
  tools.rb
  agents/
  ai/
  channels/
  data/
  tools/
```

`lib/igniter/` root should keep runtime/layer entrypoints such as:

```text
lib/igniter.rb
lib/igniter/core.rb
lib/igniter/app.rb
lib/igniter/server.rb
lib/igniter/cluster.rb
lib/igniter/stack.rb
lib/igniter/sdk.rb
```

## Mental Model

```text
runtime pyramid
  core -> server/app -> cluster

horizontal capability packs
  sdk/agents
  sdk/ai
  sdk/channels
  sdk/data
  sdk/tools
```

Read next:

- [Module System v1](./MODULE_SYSTEM_V1.md)
- [Layers v1](./LAYERS_V1.md)
- [Architecture Index](./ARCHITECTURE_INDEX.md)
- [Architecture v2](./ARCHITECTURE_V2.md)
