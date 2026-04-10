# Igniter Mesh — Phase 1: Static Mesh

> **Status**: v1 shipped (2026-04)
> **Require**: `require "igniter/extensions/mesh"`

---

## Overview

Igniter Mesh extends the `remote:` DSL with intelligent peer routing. Instead of hard-coding a
URL for every remote node, contracts can declare their **capability requirements**, and the mesh
router selects an alive peer automatically at runtime.

Phase 1 is a **static mesh** — the peer topology is declared once at startup (no gossip, no
dynamic discovery). Each peer advertises capabilities it can handle. The mesh router:

- **Probes peer health** before routing (5s TTL cache to avoid per-request overhead).
- **Load-balances** across alive peers using round-robin.
- **Defers gracefully** when no capable peer is alive — the node becomes `:pending` and retries
  automatically when inputs are updated, rather than failing the whole graph.
- **Escalates to incident** for pinned (critical) nodes that must run on a specific peer.

---

## Quick Start

```ruby
require "igniter/extensions/mesh"

# ── 1. Declare the peer topology ─────────────────────────────────────────────

Igniter::Mesh.configure do |c|
  c.peer_name          = "api-node"          # this node's identity
  c.local_capabilities = [:api]              # capabilities this node itself provides

  c.add_peer "orders-node",
             url:          "http://orders.internal:4567",
             capabilities: %i[orders inventory]

  c.add_peer "audit-node",
             url:          "http://audit.internal:4567",
             capabilities: %i[audit]
end

# ── 2. Advertise capabilities on the server side ──────────────────────────────

Igniter::Server.configure do |c|
  c.peer_name         = "orders-node"
  c.peer_capabilities = %i[orders inventory]
  c.register "ProcessOrder", ProcessOrderContract
end

# ── 3. Route by capability (auto-select, deferred on failure) ─────────────────

class OrderPipeline < Igniter::Contract
  define do
    input :order_id

    remote :order_result,
           contract:   "ProcessOrder",
           capability: :orders,           # auto-select any alive peer with :orders
           inputs:     { order_id: :order_id }

    output :order_result
  end
end

# ── 4. Route by name (pinned, incident on failure) ────────────────────────────

class AuditPipeline < Igniter::Contract
  define do
    input :event

    remote :audit_log,
           contract:  "WriteAudit",
           pinned_to: "audit-node",       # must use this exact peer
           inputs:    { event: :event }

    output :audit_log
  end
end
```

---

## Configuration

### `Igniter::Mesh.configure`

```ruby
Igniter::Mesh.configure do |c|
  c.peer_name          = "my-node"           # String — this node's identity in the mesh
  c.local_capabilities = %i[api search]      # Symbols — capabilities this node provides

  c.add_peer "peer-name",
             url:          "http://host:port",
             capabilities: %i[orders inventory]
end
```

| Option | Type | Description |
|--------|------|-------------|
| `peer_name=` | String | Identity of the local node (used in manifest responses) |
| `local_capabilities=` | Array\<Symbol\> | Capabilities this node advertises |
| `add_peer(name, url:, capabilities: [])` | — | Register a remote peer |

### Reset

```ruby
Igniter::Mesh.reset!  # clears config + router (useful in tests)
```

---

## `remote:` Routing Modes

All three modes use the same `remote:` DSL keyword. Exactly one of `node:`, `capability:`, or
`pinned_to:` must be provided.

### `:static` — hard-coded URL (original behaviour)

```ruby
remote :result,
       contract: "MyContract",
       node:     "http://scoring.internal:4567",
       inputs:   { value: :value }
```

Behaviour unchanged from pre-mesh. Fails immediately if the peer is unreachable.

---

### `:capability` — auto-select an alive peer

```ruby
remote :result,
       contract:   "MyContract",
       capability: :orders,        # any alive peer advertising :orders
       inputs:     { order_id: :order_id }
```

**Runtime behaviour:**

| Situation | Outcome |
|-----------|---------|
| At least one alive peer with the capability | Round-robin selection; contract executes normally |
| No alive peers (all down or none configured) | Node becomes **`:pending`**; graph continues resolving other nodes |
| `:pending` node retried on `resolve_all` | If a peer comes up, resolves normally; otherwise stays `:pending` |

A pending `capability:` node does **not** fail the graph — it's treated the same as a dependency
that hasn't arrived yet. This enables graceful degradation and retry-on-recovery patterns.

---

### `:pinned` — must use a specific named peer

```ruby
remote :audit_log,
       contract:  "WriteAudit",
       pinned_to: "audit-node",   # exactly this peer, no fallback
       inputs:    { event: :event }
```

**Runtime behaviour:**

| Situation | Outcome |
|-----------|---------|
| Named peer is alive | Executes normally |
| Named peer is down | Node becomes **`:failed`** with `Igniter::Mesh::IncidentError` |
| Named peer is not registered | Node becomes **`:failed`** with `Igniter::Mesh::IncidentError` |

Use `pinned_to:` for critical side-effects (audit trails, payment processors, authoritative
records) that must not be load-balanced and must alert an operator when unavailable.

---

## Error Types

### `Igniter::Mesh::DeferredCapabilityError`

Raised internally by `Mesh::Router#find_peer_for` when no alive peer has the requested
capability. Inherits from `Igniter::PendingDependencyError`, so the runtime's existing
`rescue PendingDependencyError` branch catches it and transitions the node to `:pending`.

```ruby
rescue Igniter::Mesh::DeferredCapabilityError => e
  e.capability  # => :orders
  e.message     # => "No alive peer with capability :orders"
end
```

### `Igniter::Mesh::IncidentError`

Raised internally by `Mesh::Router#resolve_pinned` when the pinned peer is unknown or
unreachable. Inherits from `Igniter::ResolutionError < StandardError`, so the runtime's
existing `rescue StandardError` branch catches it and transitions the node to `:failed`.

```ruby
rescue Igniter::Mesh::IncidentError => e
  e.peer_name  # => "audit-node"
  e.message    # => "Pinned peer 'audit-node' is unreachable — manual intervention required"
end
```

---

## Health Routing — `Mesh::Router`

The router is obtained via `Igniter::Mesh.router` (lazy-initialized, thread-safe).

### Health cache

To avoid a health-check HTTP call on every node resolution, each peer's alive/dead status is
cached for **5 seconds** (configurable via `Mesh::Router::HEALTH_CACHE_TTL`).

```
First resolution      → health check → cache entry { alive: true, checked_at: now }
Subsequent (< 5s)     → cache hit, no HTTP call
After 5s              → cache expires → next resolution triggers a new health check
After request failure → call invalidate_health!(url) to force re-check immediately
```

### Round-robin

Across multiple alive peers sharing the same capability, the router selects peers using a
per-capability counter (`(counter % alive_count)th` peer). The counter increments on each
selection and is never reset, providing even distribution over time.

### Manual operations

```ruby
router = Igniter::Mesh.router

# Expire a peer's health cache entry (e.g. after a known failure)
router.invalidate_health!("http://orders.internal:4567")

# Directly find a URL for a capability (raises DeferredCapabilityError if none alive)
url = router.find_peer_for(:orders, deferred_result)

# Directly resolve a pinned peer's URL (raises IncidentError if down/unknown)
url = router.resolve_pinned("audit-node")
```

---

## Server — Peer Identity & Manifest

### Advertising capabilities

Configure the local server to declare its identity and capabilities:

```ruby
require "igniter/server"

Igniter::Server.configure do |c|
  c.peer_name         = "orders-node"
  c.peer_capabilities = %i[orders inventory]
  c.register "ProcessOrder", ProcessOrderContract
end
```

### `GET /v1/manifest`

Returns a JSON description of the peer: its name, capabilities, registered contracts, and URL.
Used by other mesh nodes for peer discovery and health-probing.

**Response:**
```json
{
  "peer_name":    "orders-node",
  "capabilities": ["orders", "inventory"],
  "contracts":    ["ProcessOrder"],
  "url":          "http://0.0.0.0:4567"
}
```

### `Client#manifest`

Fetch a remote peer's manifest from application code:

```ruby
client = Igniter::Server::Client.new("http://orders.internal:4567")
info = client.manifest
# => { peer_name: "orders-node", capabilities: [:orders, :inventory],
#      contracts: ["ProcessOrder"], url: "http://..." }
```

---

## Architecture

```
DSL: remote(name, capability: / pinned_to: / node:)
          │
          ▼
Model::RemoteNode
  routing_mode → :static | :capability | :pinned
          │
          ▼
Compiler::RemoteValidator
  :static   → validates node_url starts with http(s)://
  :capability → validates capability is a Symbol
  :pinned     → validates pinned_to is a non-empty String
          │
          ▼
Runtime::Resolver#resolve_remote_url(node)
  :static     → node.node_url (unchanged)
  :capability → Igniter::Mesh.router.find_peer_for(cap, deferred_result)
                  ✓ alive peer found  → URL → execute via Client
                  ✗ no alive peer     → DeferredCapabilityError
                                        → existing rescue PendingDependencyError
                                        → NodeState(:pending)
  :pinned     → Igniter::Mesh.router.resolve_pinned(peer_name)
                  ✓ alive             → URL → execute via Client
                  ✗ down / unknown    → IncidentError
                                        → existing rescue StandardError
                                        → NodeState(:failed)
```

**Key invariant:** The mesh introduces zero new rescue branches in `resolver.rb`. Error
routing piggybacks entirely on the existing `PendingDependencyError` and `StandardError`
rescue chains.

---

## Multi-Node Topology Example

```
┌────────────────────────────────────────────────────────────────────┐
│  API Node  :4567                                                    │
│  capabilities: [:api]                                               │
│                                                                     │
│  OrderPipeline                                                      │
│    remote :order_result, capability: :orders                        │
│    remote :audit_log,    pinned_to:  "audit-node"   ─────────────┐ │
└──────────────────────────────┬─────────────────────────────────── ┼─┘
                               │ round-robin                         │
          ┌────────────────────┴────────────────────┐               │
          ▼                                          ▼               ▼
┌─────────────────────┐               ┌─────────────────────┐  ┌────────────────────┐
│  orders-node-1:4568 │               │  orders-node-2:4568 │  │  audit-node :4569  │
│  capabilities:      │               │  capabilities:      │  │  capabilities:     │
│    [:orders,        │               │    [:orders,        │  │    [:audit]        │
│     :inventory]     │               │     :inventory]     │  │                    │
│  ProcessOrder       │               │  ProcessOrder       │  │  WriteAudit        │
└─────────────────────┘               └─────────────────────┘  └────────────────────┘

  ↑ alive? cached 5s ↑                  ↑ alive? cached 5s ↑    ↑ alive? cached 5s ↑
  If both down → :pending               If down → :pending       If down → :failed (incident)
```

---

## Testing

Use `Igniter::Mesh.reset!` in `after` hooks to isolate tests:

```ruby
require "igniter/extensions/mesh"

RSpec.describe "OrderPipeline" do
  after { Igniter::Mesh.reset! }

  it "resolves via alive peer" do
    # Stub the HTTP client
    stub_client = instance_double(Igniter::Server::Client)
    allow(stub_client).to receive(:health).and_return({ "status" => "ok" })
    allow(stub_client).to receive(:execute).and_return(
      { status: :succeeded, outputs: { result: { id: 42, status: "processed" } } }
    )
    allow(Igniter::Server::Client).to receive(:new).and_return(stub_client)

    Igniter::Mesh.configure do |c|
      c.add_peer "orders-node",
                 url:          "http://orders.internal:4567",
                 capabilities: [:orders]
    end

    contract = OrderPipeline.new(order_id: 42)
    contract.resolve_all
    expect(contract.result.order_result[:status]).to eq("processed")
  end

  it "defers when no peer is alive" do
    dead_client = instance_double(Igniter::Server::Client)
    allow(dead_client).to receive(:health)
      .and_raise(Igniter::Server::Client::ConnectionError, "refused")
    allow(Igniter::Server::Client).to receive(:new).and_return(dead_client)

    Igniter::Mesh.configure do |c|
      c.add_peer "orders-node",
                 url:          "http://orders.internal:4567",
                 capabilities: [:orders]
    end

    contract = OrderPipeline.new(order_id: 42)
    begin; contract.resolve_all; rescue Igniter::Error; nil; end

    state = contract.execution.cache.fetch(:order_result)
    expect(state&.status).to eq(:pending)
  end
end
```

---

## Compile-Time Validation

The compiler validates mesh routing options before any contract executes:

| Violation | Error |
|-----------|-------|
| `capability:` and `pinned_to:` both provided | `CompileError` — mutually exclusive |
| None of `node:`, `capability:`, `pinned_to:` provided | `CompileError` — one required |
| `capability:` is not a Symbol | `ValidationError` |
| `pinned_to:` is an empty string | `ValidationError` |
| `node:` does not start with `http://` or `https://` | `ValidationError` |

---

---

## Phase 2 — Dynamic Discovery

> **Status**: v2 shipped (2026-04)

Eliminates the need for static `add_peer` declarations. Every peer acts as a registry,
stores the known peer list, and exposes it at `GET /v1/mesh/peers`.

### Configuration

```ruby
Igniter::Mesh.configure do |c|
  c.peer_name          = "api-node"
  c.local_url          = "http://api.internal:4567"   # how OTHER peers reach this node
  c.local_capabilities = %i[api]
  c.seeds              = %w[http://orders.internal:4567 http://audit.internal:4567]
  c.discovery_interval = 30   # seconds between polls (default)
  c.auto_announce      = true # announce self to seeds at startup (default)

  # Static peers still work alongside dynamic discovery:
  c.add_peer "legacy-node", url: "http://legacy.internal:4567", capabilities: %i[billing]
end

Igniter::Mesh.start_discovery!   # announce + poll + background thread
# …on graceful shutdown:
Igniter::Mesh.stop_discovery!    # deannounce + stop background thread
```

### `Igniter::Mesh.start_discovery!`

Performs three steps synchronously:

1. **Announce** — POSTs self-manifest to each seed (`POST /v1/mesh/peers`).
2. **Immediate poll** — fetches `GET /v1/mesh/peers` from each seed and populates
   the local `PeerRegistry` with newly discovered peers.
3. **Background poller** — starts a thread that repeats the poll every `discovery_interval` seconds.

Returns `Igniter::Mesh` (chainable).

### `Igniter::Mesh.stop_discovery!`

1. **Deannounce** — sends `DELETE /v1/mesh/peers/:name` to each seed (best-effort).
2. Stops the background polling thread.

### Peer registry endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `GET /v1/mesh/peers` | GET | List all known peers (static + dynamic, merged) |
| `POST /v1/mesh/peers` | POST | Register a peer in this node's dynamic registry |
| `DELETE /v1/mesh/peers/:name` | DELETE | Deregister a peer by name (idempotent) |

**POST body:**
```json
{ "name": "orders-node", "url": "http://orders.internal:4567", "capabilities": ["orders"] }
```

**GET response:**
```json
[
  { "name": "orders-node", "url": "http://orders.internal:4567", "capabilities": ["orders"] },
  { "name": "legacy-node", "url": "http://legacy.internal:4567", "capabilities": ["billing"] }
]
```

### Static + dynamic peer merge

The `Router` and `GET /v1/mesh/peers` both merge static and dynamic peers:

- Static peers (`add_peer`) take **precedence** — if a static and dynamic peer share
  the same name, the static entry wins.
- Dynamic-only peers are appended after all static peers.

### `PeerRegistry`

Thread-safe registry for dynamically discovered peers. Available at
`Igniter::Mesh.config.peer_registry`:

```ruby
reg = Igniter::Mesh.config.peer_registry

reg.register(Igniter::Mesh::Peer.new(name: "x", url: "http://x:4567", capabilities: [:orders]))
reg.unregister("x")         # idempotent
reg.all                     # → Array<Peer> snapshot
reg.peer_named("x")         # → Peer | nil
reg.peers_with_capability(:orders)  # → Array<Peer>
reg.size                    # → Integer
reg.clear                   # (useful in tests)
```

### `Client` mesh methods

```ruby
client = Igniter::Server::Client.new("http://seed:4567")

client.list_peers
# => [{ name: "orders-node", url: "http://...", capabilities: [:orders] }, ...]

client.register_peer(name: "api-node", url: "http://api:4567", capabilities: %i[api])
# => { "registered" => true, "name" => "api-node" }

client.unregister_peer("api-node")
```

### Topology diagram (Phase 2)

```
Node A starts:
  Igniter::Mesh.start_discovery!(seeds: ["http://seed:4567"])
    → POST /v1/mesh/peers  to seed  (self-announce)
    → GET  /v1/mesh/peers  from seed (immediate poll → fills PeerRegistry)
    → background thread polls seed every 30s

Node B starts later:
  same flow → also announces to seed
  Next poll on Node A → discovers Node B → added to PeerRegistry
  Node A's capability routing now includes Node B

Node C goes offline:
  Health cache expires → alive?(C) returns false → C skipped in routing
  C's entry stays in PeerRegistry (no auto-remove) — will route again if C recovers
```

---

## Phase 3 — Gossip Protocol

> **Status**: v1 shipped (2026-04)

### Motivation

Phase 2 seeds act as soft coordinators — topology is only as complete as the seeds know.
If a seed goes offline after bootstrapping, peers can still communicate, but new nodes
cannot be discovered. Phase 3 adds **peer-to-peer gossip**: after each seed poll, every
node also exchanges its peer list with N randomly chosen nodes from its own registry.
This makes topology convergence faster, decentralised, and resilient to seed failure.

### How It Works

```
Each poll_once cycle (every discovery_interval seconds):
  1. Seed poll:    GET /v1/mesh/peers from each seed → register returned peers  (Phase 2)
  2. Gossip round: pick min(gossip_fanout, registry.size) random registry peers
                   GET /v1/mesh/peers on each → register returned peers          (Phase 3)
```

No new server endpoints are introduced. Gossip reuses the existing `GET /v1/mesh/peers`
endpoint from Phase 2.

### Convergence Example

```
Seed knows [A, B, C] → after bootstrap, every node knows A, B, C
Seed goes down        → Phase 2 can't discover new peer D
D joins, announces    → seed down, but D's poller is running
E polls seed (empty), then gossips with A → E discovers D ← Phase 3 win
```

With fanout = 3 in a 10-node mesh, each node contacts 3 random peers per round.
After ~2 rounds every node has high probability of knowing any new peer.

### Configuration

```ruby
Igniter::Mesh.configure do |c|
  c.peer_name          = "api-node"
  c.local_url          = "http://api.internal:4567"
  c.seeds              = %w[http://seed:4567]
  c.discovery_interval = 30
  c.gossip_fanout      = 3   # random peers per gossip round (default 3, 0 = disabled)
end

Igniter::Mesh.start_discovery!
```

| Option | Default | Description |
|--------|---------|-------------|
| `gossip_fanout` | `3` | Number of random registry peers to contact per gossip round. Set to `0` to disable gossip entirely. |

### `GossipRound` API

`GossipRound` is a plain object created and invoked automatically by `Poller#poll_once`,
but you can also call it directly (e.g. for a one-off topology refresh):

```ruby
Igniter::Mesh::GossipRound.new(Igniter::Mesh.config).run
```

**Behaviour:**
- Picks `min(gossip_fanout, registry.size)` random peers, excluding self (by `local_url`).
- Fetches `GET /v1/mesh/peers` from each candidate.
- Skips entries with `nil` name or `nil` url, and skips self (by `peer_name` match).
- Registers newly discovered peers in `PeerRegistry` (idempotent — latest version wins).
- Swallows `ConnectionError` per peer — a dead peer must not abort the round.

### Example

See `examples/mesh_gossip.rb` for a 3-node scenario: A knows B, C only knows A. After
a single gossip round C discovers B without any seed involvement.

### Topology Diagram (Phase 3)

```
Seed goes offline after bootstrap:
  Node A: registry = {B, C}
  Node B: registry = {A, C}
  Node C: registry = {A, B}

New node D announces itself to seed (seed accepts, but is unreachable to others):
  Only D's local registry has {D}

Next gossip round on Node A:
  A picks B and C at random, fetches their lists
  B returns {A, C, D} ← D has gossiped with B already
  A registers D → A now knows D

Next gossip round on Node E (new node, only knows seed):
  Seed is down → seed poll returns []
  E picks A from registry, fetches A's list
  A returns {B, C, D} → E discovers all three
```

---

## Observability — Prometheus Service Discovery

> **Status**: v1 shipped (2026-04)

### Problem

Each node already exposes `GET /v1/metrics` (Prometheus text 0.0.4). In a dynamic mesh the
set of nodes changes as peers join/leave. Maintaining a static `prometheus.yml` target list
is fragile. `GET /v1/mesh/sd` solves this: Prometheus polls one stable endpoint and
automatically discovers all scrape targets as the topology changes.

### Endpoint

```
GET /v1/mesh/sd
```

Returns the current peer list (static `add_peer` + dynamic `PeerRegistry`, same merge logic
as `GET /v1/mesh/peers`) in **Prometheus HTTP SD format**. Self is not included (consistent
with `/v1/mesh/peers`). Returns `[]` when Mesh is not loaded.

### Response Format

```json
[
  {
    "targets": ["node-a:4567"],
    "labels": {
      "__meta_igniter_peer_name":    "node-a",
      "__meta_igniter_capabilities": "orders,inventory"
    }
  },
  {
    "targets": ["node-b:4567"],
    "labels": {
      "__meta_igniter_peer_name":    "node-b",
      "__meta_igniter_capabilities": "audit"
    }
  }
]
```

- `targets` — `host:port` extracted from the peer URL (scheme stripped).
- `__meta_igniter_peer_name` — peer name; available during Prometheus relabeling.
- `__meta_igniter_capabilities` — comma-separated capability list (empty string if none).
  Labels with `__meta_` prefix are dropped after relabeling unless explicitly kept via
  `relabel_configs`.

### Prometheus Configuration

Point `http_sd_configs` at any mesh node that has seed/gossip knowledge of the cluster.
Because topology propagates via gossip, any node works — no dedicated coordinator required.

```yaml
scrape_configs:
  - job_name: igniter
    http_sd_configs:
      - url: http://any-seed:4567/v1/mesh/sd
        refresh_interval: 30s      # re-polls every 30s; matches default discovery_interval
    metrics_path: /v1/metrics
    # Optional: keep peer metadata as labels after scraping
    relabel_configs:
      - source_labels: [__meta_igniter_peer_name]
        target_label: igniter_peer
      - source_labels: [__meta_igniter_capabilities]
        target_label: igniter_capabilities
```

### How Metrics Flow

```
Prometheus
  → GET /v1/mesh/sd (any seed, 30s refresh)
      ← [{ targets: ["node-a:4567"], ...}, { targets: ["node-b:4567"], ...}]
  → GET http://node-a:4567/v1/metrics  (15s scrape)
  → GET http://node-b:4567/v1/metrics  (15s scrape)
  → GET http://node-c:4567/v1/metrics  (appears after gossip propagation)
```

New nodes are discovered within one gossip round + one SD refresh interval — typically
under 60 seconds in a default configuration.

---

## Roadmap

*(No further phases currently planned.)*
