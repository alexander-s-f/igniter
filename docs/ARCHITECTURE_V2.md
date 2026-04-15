# Igniter — Architecture

For the shortest operational overview, start with [Architecture Index](./ARCHITECTURE_INDEX.md).

For the intended persistence direction across local apps and distributed clusters,
see [Persistence Model v1](./PERSISTENCE_MODEL_V1.md).

## Design Principles

1. **Small, hard core.** The kernel is minimal, strict, and independently testable.
   Extensions and higher layers are opt-in.

2. **Compile first, execute second.** Graphs are validated and frozen before any
   execution begins. Runtime never deals with half-built DSL objects.

3. **Explicit data flow.** Dependencies, output exposure, and composition mappings
   are always declared. Nothing is implicit.

4. **Extensions over hooks.** Auditing, reactive effects, tracing, and introspection
   consume the runtime event stream instead of being coupled to execution internals.

5. **Stable identities.** Every node has a stable `id`, `kind`, `name`, and `path`.
   Runtime logic does not rely on Ruby object identity.

6. **Strict separation of compile-time and runtime concerns.**
   - *Model time*: describe the graph (DSL).
   - *Compile time*: validate and freeze the graph (Compiler).
   - *Runtime*: resolve the graph against one input set (Runtime).

---

## Layer Map

```
┌─────────────────────────────────────────────────────────────────────┐
│  Cluster Layer                                                     │
│  Igniter::Cluster                                                  │
│  Consensus · Mesh · Replication · cluster-aware remote routing     │
├─────────────────────────────────────────────────────────────────────┤
│  Application / Hosting Layers                                      │
│  Igniter::App · Igniter::Server                            │
│  App scaffold · scheduler · autoloading · Rack · HTTP transport    │
├─────────────────────────────────────────────────────────────────────┤
│  Capability Layers                                                 │
│  Igniter::AI · Igniter::Channels                                   │
│  providers · skills · transcription · webhook / messaging adapters │
├─────────────────────────────────────────────────────────────────────┤
│  Core Library                                                      │
│  Igniter                                                            │
│  contract DSL · model · compiler · runtime · events · diagnostics  │
│  actor runtime · tool foundation · memory · metrics · caches       │
│  temporal · capabilities · fingerprint · property testing          │
│  extensions: auditing, reactive, introspection, saga, provenance,  │
│              incremental, dataflow, differential, invariants,      │
│              content-addressing                                    │
└─────────────────────────────────────────────────────────────────────┘
```

The core layer is the foundation. Higher layers add hosting, distribution, AI,
or transport concerns without changing domain contracts.

## Filesystem and Loading Rules

- `lib/igniter/` contains only top-level public entrypoints such as `igniter.rb`,
  `core.rb`, `ai.rb`, `server.rb`, `cluster.rb`, `application.rb`, `channels.rb`,
  `plugins.rb`, and `rails.rb`.
- Substantive core code lives under `lib/igniter/core/`.
- Behavioral add-ons live under `lib/igniter/extensions/`.
- Framework integrations live under `lib/igniter/plugins/`.
- Layer-specific implementation lives under `lib/igniter/ai/`, `server/`,
  `cluster/`, `app/`, and `channels/`.

## Terminology

- **Core** means the hard foundation under `Igniter` and `igniter/core/*`.
- **Core features** are focused facilities still owned by core, for example tools, memory, metrics, temporal support, capabilities, and caches.
- **Extensions** are optional behavioral add-ons loaded from `igniter/extensions/*`.
- **Capability layers** are optional subsystems such as `Igniter::AI` and `Igniter::Channels`.
- **Hosting layers** are `Igniter::Server` and `Igniter::Cluster`.
- **Profile** means `Igniter::App`: a packaged assembly/runtime style over `Igniter::Server`.
- **Plugin** means framework-specific integration such as `Igniter::Rails`.

---

## Core Layer

Primary entrypoints:

- `require "igniter"` — contract DSL, model, compiler, runtime, events, diagnostics
- `require "igniter/core"` — actor runtime and tool foundation
- `require "igniter/core/<feature>"` — focused core feature loading
- `require "igniter/extensions/<feature>"` — opt-in behavioral extensions

### `Igniter::Model`

Pure compile-time domain objects. Immutable after the compiler runs.

| Object | Responsibility |
|--------|----------------|
| `Model::Graph` | Graph topology and traversal primitives |
| `Model::Node` | Base node with id, kind, name, path, metadata |
| `Model::InputNode` | Input declaration with type and default |
| `Model::ComputeNode` | Computation with dependency declarations, cache_ttl, coalesce |
| `Model::OutputNode` | Output exposure |
| `Model::CompositionNode` | Nested contract reference |
| `Model::BranchNode` | Conditional routing |
| `Model::CollectionNode` | Fan-out over an array |
| `Model::AwaitNode` | Suspend execution until an external event |
| `Model::EffectNode` | Declared side effect with compensation |
| `Model::AggregateNode` | Multi-input aggregation |

### `Igniter::Compiler`

Transforms DSL-built graph drafts into a frozen `CompiledGraph`.

Responsibilities:
- Node uniqueness and path validation
- Dependency reference validation (no dangling edges)
- Cycle detection (topological sort)
- Composition mapping validation
- Freeze and seal the result

Outputs:
- Stable node registry by `id` and `path`
- Dependency index and reverse dependency index
- Topological resolution order
- Required capabilities surface

### `Igniter::DSL`

Fluent builder that translates keyword declarations into model objects.

Key methods: `input`, `compute`, `output`, `compose`, `branch`, `collection`,
`await`, `const`, `lookup`, `map`, `project`, `aggregate`, `guard`, `expose`,
`export`, `effect`, `on_success`, `scope`, `namespace`, `remote`.

Rules:
- DSL contains no execution logic.
- DSL never decides cache or invalidation behavior.
- Source location metadata is attached for diagnostics.

### `Igniter::Runtime`

Executes a compiled graph for one input set.

| Object | Responsibility |
|--------|----------------|
| `Runtime::Execution` | Public session: inputs, resolve, events |
| `Runtime::Resolver` | Resolve one node: call executor, apply cache, emit events |
| `Runtime::Cache` | Store NodeState by node id within one execution |
| `Runtime::Invalidator` | Mark downstream nodes stale on input change |
| `Runtime::Result` | Output facade — lazy, one accessor per output |
| `Runtime::NodeState` | One resolved node: value, error, timing, status |
| `Runtime::Planner` | Compute minimal resolution plan for a requested output |
| `Runtime::InputValidator` | Type-check inputs at execution boundary |

Non-responsibilities of runtime:
- Graph validation (Compiler's job)
- DSL parsing (DSL's job)
- Persistence (store adapters)
- Reactive policy decisions (event subscribers)

Runners:
- `:inline` — sequential, single-threaded (default)
- `:thread_pool` — concurrent via `pool_size` threads
- `:store` — async / deferred nodes with snapshot / restore

### Core actor runtime and tool foundation

These abstractions are part of the core, not the server layer.

| Object | Responsibility |
|--------|----------------|
| `Igniter::Agent` | Stateful mailbox-driven process |
| `Igniter::Supervisor` | Worker lifecycle / restart policy |
| `Igniter::Registry` | Named actor lookup |
| `Igniter::StreamLoop` | Long-lived pull / poll loop |
| `Igniter::Tool` | Executor + schema + discoverability for machine-usable operations |

### `Igniter::Events`

All runtime state changes produce structured events. Extensions and reactive
effects consume events without coupling to execution internals.

```
node_started · node_succeeded · node_failed · node_cached
node_ttl_cache_hit · node_coalesced · input_validated
execution_started · execution_completed · execution_failed
```

### `Igniter::Extensions`

Optional packages that enrich the core without modifying it.

| Extension | Require | Purpose |
|-----------|---------|---------|
| Auditing | `igniter/extensions/auditing` | Execution timeline + snapshots |
| Reactive | built-in | `effect`, `on_success`, `on_failure` DSL hooks |
| Introspection | `igniter/extensions/introspection` | Text + Mermaid graph render |
| Saga | `igniter/extensions/saga` | Compensation / rollback pattern |
| Provenance | `igniter/extensions/provenance` | Data lineage tracking |
| Incremental | `igniter/extensions/incremental` | Always-on memoization + backdating |
| Dataflow | `igniter/extensions/dataflow` | O(change) incremental collections |
| Differential | `igniter/extensions/differential` | Contract version comparison |
| Invariants | `igniter/extensions/invariants` | Runtime invariant enforcement |
| Content addressing | `igniter/extensions/content_addressing` | Universal input-fingerprint cache |

---

## AI Layer

Activated by `require "igniter/ai"`.

### `Igniter::AI`

LLM-oriented execution features that are intentionally outside the hard core.

- Provider configuration and failover
- `Igniter::AI::Executor`
- `Igniter::AI::Skill`
- `Igniter::AI::ToolRegistry`
- Structured output and tool loop orchestration
- Audio transcription

Providers: Ollama · Anthropic · OpenAI (+ compatible providers such as Groq, Mistral, Azure).

---

## Channels Layer

Activated by `require "igniter/channels"`.

### `Igniter::Channels`

Transport-neutral outbound communication layer built on `Igniter::Effect`.

- `Igniter::Channels::Message` — immutable transport-agnostic message envelope.
- `Igniter::Channels::DeliveryResult` — normalized send result.
- `Igniter::Channels::Base < Igniter::Effect` — adapter base for Telegram, WhatsApp, email, webhook, SMS.
- `Igniter::Channels::Webhook` — first built-in transport adapter.

---

## Server Layer

Loaded by `require "igniter/server"` and also loaded indirectly by the default
server host pack behind `require "igniter/app"`.
Remote transport becomes active when you call `Igniter::Server.start`,
`Igniter::Server.rack_app`, or `Igniter::Server.activate_remote_adapter!`.

### `Igniter::Server`

Rack-compatible HTTP transport and service hosting for contracts.

| Component | Responsibility |
|-----------|----------------|
| `Server::RackApp` | Request routing, JSON serialisation |
| `Server::HttpServer` | Built-in TCP server (no external dep) |
| `Server::Registry` | Named contract registry |
| `Server::Client` | HTTP client for remote execution |
| `Server::RemoteAdapter` | Bridge from runtime remote seam to HTTP transport |
| `Server::Handlers` | /execute, /events, /health, /contracts, /metrics |

---

## App Layer

Activated by `require "igniter/app/runtime"` and re-exported by
`require "igniter/app"`.

### `Igniter::App`

Convention-over-configuration entry point for single-machine deployments.

DSL: `host`, `config_file`, `configure`, `executors_path`, `contracts_path`,
`tools_path`, `agents_path`, `skills_path`, `on_boot`, `register`, `loader`,
`scheduler`, `schedule`.

Lifecycle: loader adapter → `on_boot` blocks → `configure` blocks → build host config → run through host adapter.

`Igniter::App` is a profile over hosting. Today the default host adapter is
`Igniter::App::AppHost`, so the public API still runs on top of
`Igniter::Server` without hard-wiring HTTP classes into `Application` itself.

When an app needs cluster-aware hosting, it can opt into
`Igniter::App::ClusterAppHost`, which layers mesh/bootstrap concerns on top of
the same host model. The application
declares this through `host :cluster_app`, while `host_adapter(...)` remains available
for fully custom hosts. Canonical host profiles are now supplied through
`Igniter::App::HostRegistry`, so future host packs can register
themselves without pushing more branching logic back into `Application`. In other
words, `require "igniter/app"` registers the server host pack, the default
filesystem loader pack, and the default threaded scheduler pack, while
`require "igniter/cluster"` extends the host registry with the cluster host pack.
Scaffold generation is no longer part of the runtime entrypoint; it is loaded
explicitly through `require "igniter/app/scaffold_pack"`. The application
entrypoint itself is now a thin manifest over `igniter/app/runtime_pack`
plus `igniter/app/workspace_pack`, while
`require "igniter/app/runtime"` exposes just the leaf runtime side.

---

## Cluster Layer

Loaded by `require "igniter/cluster"`.
Cluster-aware remote routing becomes active when you call
`Igniter::Cluster.activate_remote_adapter!` or run through a hosted cluster flow.

### `Igniter::Cluster::Consensus`

Raft-based cluster coordination.

- Leader election with quorum.
- `StateMachine` DSL for replicated state machines.
- `Cluster.start` bootstraps the node and connects to peers.
- Read consistency: `:any` (low-latency) or `:quorum` (strongly consistent).

### `Igniter::Cluster::Mesh`

Gossip-based peer discovery.

- Periodic peer exchange — no central registry required.
- Prometheus SD endpoint (`/v1/prometheus/targets`).
- Kubernetes health probes (`/v1/healthz`, `/v1/readyz`).
- Node metadata propagation (available contracts, version, load).

### `Igniter::Cluster::Ownership`

Ownership is the bridge between local-first persistence and distributed routing.

- Entities can be claimed by an owner node or role.
- Reads and follow-up writes should route to the owner.
- Ownership metadata is small cluster state, not a global application database.
- Capability routing remains a fallback when no explicit owner is known.

### `Igniter::Cluster::Replication`

Distributed execution state replication across nodes so any node can
continue a distributed workflow after a peer failure.

---

## Plugin Layer

Framework-specific integrations live under `Igniter::Plugins`.

- `Igniter::Plugins::Rails`
- short public entrypoint: `require "igniter/rails"`

---

## Error Model

All errors inherit from `Igniter::Error` with structured context metadata:
`graph:`, `node:`, `path:`, `source:`.

Primary families:

| Class | When |
|-------|------|
| `CompileError` | Graph structure is invalid |
| `ValidationError` | Input fails type or guard check |
| `CycleError` | Dependency graph has a cycle |
| `ResolutionError` | Executor raises during node resolution |
| `CompositionError` | Nested contract mapping is invalid |
| `CapabilityViolationError` | Executor uses a denied capability |
| `ToolLoopError` | LLM tool-use loop exceeds `max_tool_iterations` |

---

## Key Files

| File | Layer | Purpose |
|------|-------|---------|
| `lib/igniter/core/contract.rb` | Core | Contract class — define, compile, execute |
| `lib/igniter/core/dsl/contract_builder.rb` | Core | All DSL keywords |
| `lib/igniter/core/compiler/graph_compiler.rb` | Core | Compilation orchestrator |
| `lib/igniter/core/compiler/compiled_graph.rb` | Core | Frozen compiled graph |
| `lib/igniter/core/runtime/execution.rb` | Core | Execution lifecycle |
| `lib/igniter/core/runtime/resolver.rb` | Core | Node resolution (TTL cache, coalescing) |
| `lib/igniter/core/type_system.rb` | Core | Type validation |
| `lib/igniter/core/errors.rb` | Core | Error hierarchy |
| `lib/igniter/server/rack_app.rb` | Server | HTTP request handling |
| `lib/igniter/app.rb` | Application | Application scaffold entry point |
| `lib/igniter/core/agent.rb` | Core | Actor agent base class entry point |
| `lib/igniter/core/tool.rb` | Core | Tool base class entry point |
| `lib/igniter/ai/skill.rb` | AI | Skill base class |
| `lib/igniter/ai.rb` | AI | AI integration entry point |
| `lib/igniter/cluster/consensus/cluster.rb` | Cluster | Raft cluster bootstrap |
| `lib/igniter/cluster/mesh/gossip.rb` | Cluster | Gossip peer exchange |

---

## Packaging Roadmap

The gem is currently shipped as a single package with load-time optional require boundaries.
The planned split into three gems mirrors the deployment hierarchy:

```
igniter               # core library
  └─ igniter-server   # server + application scaffold + actors + LLM
       └─ igniter-cluster   # consensus + mesh + replication
```

Until the split is complete, enforce tier boundaries through optional requires:

```ruby
# Embedded: only load what you need
require "igniter"
require "igniter/extensions/saga"

# Server: adds the server layer
require "igniter/server"
require "igniter/app"
require "igniter/ai"

# Cluster: adds consensus and mesh on top of server
require "igniter/cluster"
require "igniter/cluster"
```

Do **not** `require "igniter/cluster"` in an embedded context — it is a cluster-tier
component with its own operational requirements (quorum, persistent WAL, network ports).

See [`docs/DEPLOYMENT_V1.md`](DEPLOYMENT_V1.md) for full scenario walkthroughs.
