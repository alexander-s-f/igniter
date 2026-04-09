# igniter-server v1

igniter-server turns any Igniter contract into an HTTP service. Multiple server nodes can call
each other using the `remote:` DSL, enabling distributed multi-node architectures with
compile-time validated cross-node contracts.

## Quick Start

### Ruby API

```ruby
require "igniter/server"

class ScoringContract < Igniter::Contract
  define do
    input :value
    compute :score, depends_on: :value, call: ->(value:) { value * 1.5 }
    output :score
  end
end

Igniter::Server.configure do |c|
  c.host = "0.0.0.0"
  c.port = 4567
  c.register "ScoringContract", ScoringContract
end

Igniter::Server.start  # blocking
```

### CLI

```bash
# Start server, loading contracts from a file
igniter-server start --port 4567 --require ./contracts.rb

# With a config block for additional setup
igniter-server start --port 4567 --require ./contracts.rb --config ./server_config.rb
```

### Rack / Puma (production)

```ruby
# config.ru
require "igniter/server"
require_relative "contracts"

Igniter::Server.configure do |c|
  c.register "ScoringContract", ScoringContract
  c.store = Igniter::Runtime::Stores::MemoryStore.new
end

run Igniter::Server.rack_app
```

```bash
bundle exec puma config.ru -p 4567
```

---

## Configuration

```ruby
Igniter::Server.configure do |c|
  c.host = "0.0.0.0"          # bind address (default: "0.0.0.0")
  c.port = 4567                # TCP port (default: 4567)
  c.store = my_store           # execution store for distributed contracts
  c.register "Name", MyClass   # register a contract
  c.contracts = {              # bulk registration
    "ContractA" => ContractA,
    "ContractB" => ContractB
  }
end
```

Reset configuration (useful in tests):

```ruby
Igniter::Server.reset!
```

---

## REST API Reference

All responses use `Content-Type: application/json`.

### `POST /v1/contracts/:name/execute`

Execute a contract synchronously. For distributed contracts (`correlate_by`), this is
equivalent to `Contract.start` and returns a `pending` response.

**Request body:**
```json
{ "inputs": { "value": 42 } }
```

**Responses:**

```json
// Succeeded
{ "execution_id": "uuid", "status": "succeeded", "outputs": { "score": 63.0 } }

// Failed node
{ "execution_id": "uuid", "status": "failed",
  "error": { "type": "Igniter::ResolutionError", "message": "...", "node": "score" } }

// Pending (distributed contract waiting for events)
{ "execution_id": "uuid", "status": "pending", "waiting_for": ["data_received"] }
```

**HTTP status codes:** `200` for all execution outcomes (including failed), `404` if contract
not registered, `422` for Igniter errors, `500` for unexpected errors.

---

### `POST /v1/contracts/:name/events`

Deliver an event to a distributed contract execution.

**Request body:**
```json
{
  "event":       "data_received",
  "correlation": { "request_id": "r1" },
  "payload":     { "data": "value" }
}
```

**Response:** same shape as `/execute`.

---

### `GET /v1/executions/:id`

Poll the status of a previously started execution.

**Response:**
```json
{ "execution_id": "uuid", "status": "pending", "waiting_for": ["data_received"] }
```

Returns `404` if the execution is not found in the configured store.

---

### `GET /v1/health`

Health check endpoint.

**Response:**
```json
{
  "status":    "ok",
  "contracts": ["ScoringContract", "PipelineContract"],
  "store":     "MemoryStore",
  "pending":   3
}
```

---

### `GET /v1/contracts`

List registered contracts with their input and output names.

**Response:**
```json
[
  { "name": "ScoringContract", "inputs": ["value"], "outputs": ["score"] }
]
```

---

## `remote:` DSL — Cross-Node Contract Composition

Call a contract on a remote igniter-server as a node inside a local graph:

```ruby
require "igniter/server"

class OrchestratorContract < Igniter::Contract
  define do
    input :data

    # Calls ScoringContract on a remote node over HTTP
    remote :scored,
           contract: "ScoringContract",
           node:     "http://scoring-service:4568",
           inputs:   { value: :data },
           timeout:  10   # seconds (default: 30)

    compute :label, depends_on: :scored do |scored:|
      scored[:score] > 50 ? "high" : "low"
    end

    output :label
  end
end
```

The `remote:` node is validated at compile time:
- `node:` must start with `http://` or `https://`
- `contract:` must be a non-empty string
- All keys in `inputs:` must reference nodes that exist in the local graph

At runtime, if the remote service is unreachable or the remote contract fails,
an `Igniter::ResolutionError` is raised and propagates like any other node failure.

**Note:** `require "igniter/server"` is required to load `Igniter::Server::Client`.
Without it, any contract with a `remote:` node will raise at resolution time.

---

## HTTP Client

Use `Igniter::Server::Client` directly to call a remote service from application code:

```ruby
require "igniter/server"

client = Igniter::Server::Client.new("http://localhost:4568", timeout: 30)

# Execute a contract
response = client.execute("ScoringContract", inputs: { value: 42 })
# => { status: :succeeded, execution_id: "uuid", outputs: { score: 63.0 } }

# Deliver an event
client.deliver_event("LeadWorkflow",
  event:       "data_received",
  correlation: { request_id: "r1" },
  payload:     { value: "hello" })

# Poll execution status
client.status("uuid")
# => { status: :pending, waiting_for: ["data_received"] }

# Health check
client.health
# => { status: "ok", contracts: [...], pending: 0 }
```

Errors:
- `Igniter::Server::Client::ConnectionError` — network unreachable (wraps `Errno::ECONNREFUSED`, `SocketError`, etc.)
- `Igniter::Server::Client::RemoteError` — HTTP 4xx/5xx response from the server

---

## Multi-Node Architecture

```
┌──────────────────────────┐         ┌──────────────────────────┐
│  Orchestrator  :4567     │         │  Scoring Service  :4568  │
│                          │         │                          │
│  OrchestratorContract    │         │  ScoringContract         │
│    remote :scored,   ────┼──HTTP──▶│  POST /v1/contracts/     │
│      node: "…:4568"      │         │       ScoringContract/   │
│                          │◀────────┤       execute            │
│  contract.result.label   │         │  ← { status, outputs }   │
└──────────────────────────┘         └──────────────────────────┘
```

Each node is an independent Ruby process. The orchestrator's graph is validated
at load time — if `ScoringContract`'s URL is malformed, it fails at compile time,
not at the first HTTP call.

---

## Security

igniter-server ships with no built-in authentication. For production deployments:

- Place the server behind a reverse proxy (nginx, Caddy, AWS ALB) that handles TLS and auth
- Use network-level access controls (VPC, security groups, firewall rules)
- Add Rack middleware for API key validation when using `rack_app`

Example with Rack middleware:

```ruby
# config.ru
require "igniter/server"

app = Igniter::Server.rack_app

auth_app = ->(env) {
  return [401, {}, ["Unauthorized"]] unless env["HTTP_X_API_KEY"] == ENV["API_KEY"]
  app.call(env)
}

run auth_app
```

---

## Store Configuration

For stateless contracts (no `await` or `correlate_by`), the default `MemoryStore` is fine.

For distributed contracts that survive process restarts, use an external store:

```ruby
Igniter::Server.configure do |c|
  # Redis (requires redis gem)
  c.store = Igniter::Runtime::Stores::RedisStore.new(ENV["REDIS_URL"])

  # ActiveRecord (requires Rails + activerecord gem)
  c.store = Igniter::Runtime::Stores::ActiveRecordStore.new
end
```

See [Store Adapters](STORE_ADAPTERS.md) for full reference.
