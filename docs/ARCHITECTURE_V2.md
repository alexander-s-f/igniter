# Igniter — Architecture

## Design Principles

1. **Small, hard core.** The kernel is minimal, strict, and independently testable.
   Extensions, server, and cluster layers are opt-in.

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
┌─────────────────────────────────────────────────────────────────┐
│  Cluster Layer  (igniter-cluster, future gem)                    │
│  Consensus (Raft) · Mesh (gossip) · Replication                  │
├─────────────────────────────────────────────────────────────────┤
│  Server Layer   (igniter-server, future gem)                     │
│  HTTP Server · Rack · Application scaffold · CLI                 │
│  Actor system (Agent/Supervisor/Registry)                        │
│  LLM integration · Tool registry · Skill system                  │
│  Memory stores · Metrics · Scheduler                             │
├─────────────────────────────────────────────────────────────────┤
│  Core Library   (igniter)                                        │
│  Model · Compiler · DSL · Runtime · Events                       │
│  Extensions: auditing, saga, provenance, incremental, dataflow,  │
│              differential, invariants, content-addressing         │
│  Capabilities · Temporal · Fingerprint · NodeCache               │
│  Property testing                                                │
└─────────────────────────────────────────────────────────────────┘
```

Each layer is a strict superset of the one below it. Your domain contracts live
in the core layer and are never rewritten as you scale.

---

## Core Layer

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

## Server Layer

Activated by `require "igniter/server"` or `require "igniter/application"`.

### `Igniter::Server`

Rack-compatible HTTP server exposing contracts as a REST API.

| Component | Responsibility |
|-----------|----------------|
| `Server::RackApp` | Request routing, JSON serialisation |
| `Server::HttpServer` | Built-in TCP server (no external dep) |
| `Server::Registry` | Named contract registry |
| `Server::Client` | HTTP client for `remote:` DSL |
| `Server::Handlers` | /execute, /events, /health, /contracts, /metrics |

### `Igniter::Application`

Convention-over-configuration entry point for single-machine deployments.

DSL: `config_file`, `configure`, `executors_path`, `contracts_path`, `tools_path`,
`agents_path`, `skills_path`, `on_boot`, `register`, `schedule`.

Lifecycle: `autoload_paths!` → `on_boot` blocks → `configure` blocks → start server.

### Actor system — `Igniter::Agent` / `Igniter::Supervisor` / `Igniter::Registry`

Lightweight actor model built on Ruby threads and message-passing mailboxes.
Used for stateful background processes (proactive agents, stream loops).

### LLM integration — `Igniter::LLM`

LLM compute nodes with provider failover, tool-use auto-loop, structured output,
feedback refinement, and audio transcription.

Providers: Ollama · Anthropic · OpenAI (+ compatible: Groq, Mistral, Azure).

### Tool system — `Igniter::Tool` / `Igniter::Skill`

- `Tool < Executor` — atomic operation with schema, capability guard, discoverable interface.
- `Skill < LLM::Executor` — agentic sub-process with its own LLM loop and tool registry.
- Both register in `Igniter::ToolRegistry` with scope: `:bundled` | `:managed` | `:workspace`.

---

## Cluster Layer

Activated by `require "igniter/consensus"` and `require "igniter/extensions/mesh"`.

### `Igniter::Consensus`

Raft-based cluster coordination.

- Leader election with quorum.
- `StateMachine` DSL for replicated state machines.
- `Cluster.start` bootstraps the node and connects to peers.
- Read consistency: `:any` (low-latency) or `:quorum` (strongly consistent).

### `Igniter::Mesh`

Gossip-based peer discovery.

- Periodic peer exchange — no central registry required.
- Prometheus SD endpoint (`/v1/prometheus/targets`).
- Kubernetes health probes (`/v1/healthz`, `/v1/readyz`).
- Node metadata propagation (available contracts, version, load).

### `Igniter::Replication`

Distributed execution state replication across nodes so any node can
continue a distributed workflow after a peer failure.

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
| `lib/igniter/contract.rb` | Core | Contract class — define, compile, execute |
| `lib/igniter/dsl/contract_builder.rb` | Core | All DSL keywords |
| `lib/igniter/compiler/graph_compiler.rb` | Core | Compilation orchestrator |
| `lib/igniter/compiler/compiled_graph.rb` | Core | Frozen compiled graph |
| `lib/igniter/runtime/execution.rb` | Core | Execution lifecycle |
| `lib/igniter/runtime/resolver.rb` | Core | Node resolution (TTL cache, coalescing) |
| `lib/igniter/type_system.rb` | Core | Type validation |
| `lib/igniter/errors.rb` | Core | Error hierarchy |
| `lib/igniter/server/rack_app.rb` | Server | HTTP request handling |
| `lib/igniter/application.rb` | Server | Application scaffold entry point |
| `lib/igniter/agent.rb` | Server | Actor agent base class |
| `lib/igniter/tool.rb` | Server | Tool base class |
| `lib/igniter/skill.rb` | Server | Skill base class |
| `lib/igniter/integrations/llm.rb` | Server | LLM integration entry point |
| `lib/igniter/consensus/cluster.rb` | Cluster | Raft cluster bootstrap |
| `lib/igniter/mesh/gossip.rb` | Cluster | Gossip peer exchange |

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
require "igniter/application"
require "igniter/integrations/llm"

# Cluster: adds consensus and mesh on top of server
require "igniter/consensus"
require "igniter/extensions/mesh"
```

Do **not** `require "igniter/consensus"` in an embedded context — it is a cluster-tier
component with its own operational requirements (quorum, persistent WAL, network ports).

See [`docs/DEPLOYMENT_V1.md`](DEPLOYMENT_V1.md) for full scenario walkthroughs.
