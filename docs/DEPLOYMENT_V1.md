# Igniter — Deployment Scenarios

Igniter is designed to work at three distinct levels of scale. Each level is a strict superset
of the one below it — you can start with embedded contracts and grow into a full cluster
without changing your domain logic.

## Loading Rules

Use the smallest entrypoint that matches the deployment mode:

| Need | Require |
|------|---------|
| Core contracts and runtime | `require "igniter"` |
| Actor / tool foundation | `require "igniter/core"` |
| Built-in operational tools | `require "igniter/tools"` |
| Specific core features | `require "igniter/core/temporal"`, `require "igniter/core/node_cache"` |
| Extensions | `require "igniter/extensions/auditing"`, `require "igniter/extensions/capabilities"` |
| AI | `require "igniter/ai"` |
| Channels | `require "igniter/channels"` |
| HTTP hosting | `require "igniter/server"` |
| App profile | `require "igniter/app"` |
| Cluster runtime | `require "igniter/cluster"` |
| Rails plugin | `require "igniter/rails"` |

Loading `igniter/server` or `igniter/cluster` does not install a transport adapter as
a side effect. Hosted entrypoints such as `Igniter::Server.start`,
`Igniter::Server.rack_app`, and `Igniter::App.start` activate transport for you.
For ad hoc `remote:` execution, call `Igniter::Server.activate_remote_adapter!` or
`Igniter::Cluster.activate_remote_adapter!` explicitly.

---

## Scenario 1 — Embedded Library

**Profile:** single Ruby process, user-managed structure, no HTTP layer.

Igniter is added to an existing application (Rails, Sidekiq, plain Ruby service) and
contracts are called directly by user code. No scaffolding, no server process — just
`require "igniter"` and write contracts.

### When to choose

- Business logic already lives inside a Rails app, a job queue, or a script.
- You want compile-time validation and lazy dependency resolution without adding infrastructure.
- You control when and how contracts are instantiated.

### What you get

```
igniter
  + optional igniter/core/* features
  + optional igniter/extensions/* behaviors
```

No server, no cluster, no HTTP transport. Add `igniter/core/*`, `igniter/extensions/*`,
`igniter/tools`, `igniter/ai`, or `igniter/channels` only when your app needs them.

### Structure — entirely up to the user

```
app/
  services/
    pricing_contract.rb
    vat_executor.rb
```

### Usage

```ruby
# Gemfile
gem "igniter"

# app/services/pricing_contract.rb
class PricingContract < Igniter::Contract
  define do
    input  :order_total, type: :numeric
    input  :country,     type: :string
    compute :vat_rate, depends_on: :country do |country:|
      country == "UA" ? 0.2 : 0.0
    end
    compute :gross_total, depends_on: %i[order_total vat_rate] do |order_total:, vat_rate:|
      order_total * (1 + vat_rate)
    end
    output :gross_total
  end
end

# Called from a Rails controller, Sidekiq job, rake task — anywhere
result = PricingContract.new(order_total: 100, country: "UA").result
result.gross_total  # => 120.0
```

### Optional extensions for embedded use

```ruby
require "igniter/extensions/auditing"       # execution timeline
require "igniter/extensions/saga"           # compensation / rollback
require "igniter/extensions/provenance"     # data lineage
require "igniter/extensions/incremental"    # memoization across calls
require "igniter/extensions/dataflow"       # incremental O(change) collections
require "igniter/core/temporal"             # reproducible historical execution
require "igniter/extensions/capabilities"   # capability-based security
require "igniter/core/node_cache"           # TTL cache + request coalescing
require "igniter/rails"                     # Railtie, ActiveJob, ActionCable, generators
```

### Rails plugin

```ruby
# config/initializers/igniter.rb
require "igniter/rails"

Igniter::Rails.configure do |c|
  c.store = Igniter::Runtime::Stores::MemoryStore.new
end
```

Rails generators scaffold contracts and executors under `app/igniter/`.
See [`docs/RAILS_INTEGRATION.md`](RAILS_INTEGRATION.md) (TODO) for the full reference.

---

## Scenario 2 — Application Server (single machine)

**Profile:** standalone HTTP service hosting contracts, single node.

Igniter provides a full stack scaffold — directory layout, YAML config, autoloading,
scheduler, and HTTP hosting — via `Igniter::Stack`, leaf `Igniter::App` apps,
and the `igniter-stack` CLI.
AI, tools, skills, and channels remain opt-in layers that an application can load when needed.

### When to choose

- You want contracts exposed as a REST API (or as a Rack app behind Puma).
- You need background agents, scheduled tasks, or LLM-powered compute nodes.
- One machine is sufficient; horizontal scaling is not yet required.

### What you get

```
igniter + igniter/core + igniter/server + igniter/app
    + optional igniter/ai
    + optional igniter/channels
```

### Scaffold

```bash
gem install igniter
igniter-stack new my_app
cd my_app && bundle install && bin/start
```

Generated structure:

```
my_app/
├── stack.rb            # Igniter::Stack coordinator
├── stack.yml           # stack metadata
├── config/
│   ├── topology.yml        # deployment roles + wiring
│   └── deploy/
│       ├── Dockerfile      # shared container image
│       └── compose.yml     # local / reference multi-app deployment
├── Gemfile
├── config.ru               # Rack entry point
├── apps/
│   └── main/
│       ├── app.rb  # leaf Igniter::App subclass
│       ├── app.yml # app-local server config
│       ├── app/
│       │   ├── contracts/
│       │   ├── executors/
│       │   ├── tools/
│       │   ├── agents/
│       │   └── skills/
│       └── spec/
├── lib/
│   └── my_app/shared/
├── bin/
│   ├── start               # stack start wrapper
│   └── demo                # runnable smoke test
└── spec/
    └── shared + integration + stack-level specs
```

Deployment config intentionally lives outside `apps/*`:

- `apps/*` = code and leaf runtime defaults
- `stack.yml` = shared stack defaults
- `config/topology.yml` = deployment roles and cross-app wiring
- `config/deploy/*` = Docker / Compose / future operational artifacts

### Stack + leaf app

```ruby
# stack.rb
require "igniter/stack"
require_relative "apps/main/app"

module MyApp
  class Stack < Igniter::Stack
    root_dir __dir__
    shared_lib_path "lib"

    app :main, path: "apps/main", klass: MyApp::MainApp, default: true
  end
end
```

```ruby
# apps/main/app.rb
require "igniter/app"
require "igniter/core"
require "igniter/ai"

module MyApp
  class MainApp < Igniter::App
    root_dir __dir__
    config_file "app.yml"

    executors_path "app/executors"
    contracts_path "app/contracts"
    tools_path     "app/tools"
    agents_path    "app/agents"
    skills_path    "app/skills"

    on_boot do
      Igniter::AI.configure do |c|
        c.default_provider = :anthropic
        c.anthropic.api_key = ENV["ANTHROPIC_API_KEY"]
      end

      register "OrderContract", MyApp::OrderContract
    end

    configure do |c|
      c.app_host.port = ENV.fetch("PORT", 4567).to_i
      c.log_format = :json
      c.store      = Igniter::Runtime::Stores::MemoryStore.new
    end

    schedule :cleanup, every: "1h" do
      puts "[cleanup] #{Time.now}"
    end
  end
end
```

### REST API (built-in)

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/v1/contracts/:name/execute` | Execute a contract synchronously |
| `POST` | `/v1/contracts/:name/events` | Deliver an event to a distributed contract |
| `GET`  | `/v1/executions/:id` | Poll execution status |
| `GET`  | `/v1/health` | Health check |
| `GET`  | `/v1/contracts` | List contracts with I/O schemas |
| `GET`  | `/metrics` | Prometheus-compatible metrics |

### Scaling on a single machine

- Use the `:thread_pool` runner for concurrency within one process: `runner :thread_pool, pool_size: 8`.
- Use `node_cache` with `coalesce: true` to collapse concurrent identical calls.
- Run behind Puma for multi-process concurrency via `MyApp.rack_app`.

### Reference example

`examples/companion/` is the main stack-based application demo: voice assistant pipeline,
LLM chat/intent/TTS/ASR contracts, proactive agents, tool registry, scheduled session GC.

`examples/companion_legacy/` remains as the older flat-layout reference during transition.

See [`docs/APP_V1.md`](APP_V1.md), [`docs/STACKS_V1.md`](STACKS_V1.md), and [`docs/SERVER_V1.md`](SERVER_V1.md).

---

## Scenario 3 — Application Server Cluster (distributed network)

**Profile:** multiple `igniter-stack` nodes cooperating via Raft consensus, gossip mesh,
and distributed contract routing.

Each node runs Scenario 2 (application server), plus the cluster layer adds:

- **Consensus** (`Igniter::Cluster::Consensus`) — Raft-based leader election, distributed state machines,
  strongly consistent reads and writes.
- **Mesh** (`Igniter::Cluster::Mesh`) — gossip-based peer discovery, Prometheus SD, K8s health probes,
  node metadata propagation.
- **Replication** (`Igniter::Cluster::Replication`) — contract execution state replicated across nodes;
  any node can continue a distributed workflow after a peer failure.
- **Remote contracts** — the `remote:` DSL transparently calls contracts on peer nodes.

### When to choose

- Single machine cannot handle throughput, or you need fault tolerance.
- You need distributed workflows where events arrive on different nodes.
- You want zero-downtime rolling upgrades (Raft ensures quorum during transitions).
- You're building a platform where different contract services are owned by different teams.

### What you get

```
igniter + igniter/core + igniter/server + igniter/cluster
    + optional igniter/app
    + optional igniter/ai
    + optional igniter/channels
```

### Topology example — 3-node cluster

```
          ┌─────────────────────┐
          │   igniter-stack    │  node 1 (leader)
          │   port 4567         │  PricingContract, OrderContract
          └──────────┬──────────┘
                     │  Raft + gossip
          ┌──────────┴──────────┐
          │                     │
┌─────────┴───────┐   ┌─────────┴───────┐
│  igniter-stack │   │  igniter-stack │
│  port 4568      │   │  port 4569      │
│  ScoringContract│   │  InventoryContract│
└─────────────────┘   └─────────────────┘
```

### Cluster setup

```ruby
# apps/main/app.rb (same on every node)
require "igniter/app"
require "igniter/cluster"

class ClusterApp < Igniter::App
  config_file "app.yml"
  executors_path "app/executors"
  contracts_path "app/contracts"

  on_boot do
    cluster = Igniter::Cluster::Consensus::Cluster.start(
      node_id:   ENV.fetch("NODE_ID"),
      peers:     ENV.fetch("PEERS").split(","),
      store:     Igniter::Runtime::Stores::MemoryStore.new
    )

    Igniter::Cluster::Mesh.configure do |c|
      c.node_id  = ENV.fetch("NODE_ID")
      c.peers    = cluster.peer_addresses
      c.metadata = { contracts: %w[OrderContract PricingContract] }
    end

    register "OrderContract", OrderContract
  end

  configure do |c|
    c.app_host.port = ENV.fetch("PORT", 4567).to_i
  end
end
```

### Remote contracts

Call contracts on peer nodes transparently from the DSL:

```ruby
class PipelineContract < Igniter::Contract
  define do
    input :data

    remote :scored,
           contract: "ScoringContract",
           node:     "http://scoring-node:4568",
           inputs:   { value: :data }

    output :scored
  end
end
```

The `remote:` DSL resolves peer addresses from the mesh registry dynamically —
no hardcoded hostnames required when using gossip discovery.

### Distributed workflows across nodes

`await` + `correlate_by` + `deliver_event` work across nodes. Any node can deliver an event
to any execution, regardless of which node started it, because execution state is replicated:

```ruby
# Node 1 — starts the workflow
exec = LeadWorkflow.start({ request_id: "r1" }, store: cluster_store)

# Node 2 — delivers the event (e.g., from a webhook)
LeadWorkflow.deliver_event(:crm_received,
  correlation: { request_id: "r1" },
  payload:     { company: "Acme" },
  store:        cluster_store)
```

### Scaling and operations

- **Leader election**: Raft guarantees exactly one leader at all times. Followers forward
  write requests to the leader automatically.
- **Reads**: configure `read_consistency: :any` for low-latency reads, `:quorum` for
  strongly consistent reads.
- **Rolling upgrades**: drain a node (`/v1/drain`), upgrade, restart — Raft maintains quorum.
- **Kubernetes**: use the `/v1/healthz` (liveness) and `/v1/readyz` (readiness) probes.
- **Prometheus SD**: mesh publishes a `/v1/prometheus/targets` endpoint compatible with
  `http_sd_config`.

See [`docs/MESH_V1.md`](MESH_V1.md), [`docs/CONSENSUS_V1.md`](CONSENSUS_V1.md),
and [`examples/mesh.rb`](../examples/mesh.rb).

---

## Gem Layer Roadmap

The current gem ships all layers in one package with explicit load boundaries.
The planned gem separation mirrors the same architecture:

```
igniter               # core + extensions
  ├─ igniter-ai       # AI capability layer
  ├─ igniter-channels # transport capability layer
  ├─ igniter-stack   # hosting layer + transport for remote execution
  └─ igniter-cluster  # distributed hosting layer
```

Benefits of separation:

- Embedded users don't pull in Raft and HTTP server code.
- Capability layers can evolve on their own cadence.
- Each tier has its own version cycle.
- The `igniter-stack` binary lives in the correct gem.
- Dependencies are explicit rather than load-time optional.

Until the split is complete, the optional-require pattern enforces the same boundaries:

| Layer | What to require |
|------|----------------|
| Core | `require "igniter"` |
| Core features | `require "igniter/core"` or `require "igniter/core/<feature>"` |
| Extensions | `require "igniter/extensions/<feature>"` |
| Capability layers | `require "igniter/ai"` / `require "igniter/channels"` |
| Hosting profile | `require "igniter/app"` |
| Hosting layer | `require "igniter/server"` |
| Distributed hosting | `require "igniter/cluster"` |
| Plugin | `require "igniter/rails"` |

Never `require "igniter/cluster"` in an embedded context —
it is a cluster-tier component with its own operational requirements.
