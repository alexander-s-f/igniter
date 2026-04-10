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
  c.log_format = :text         # :text (default) or :json — structured JSON for Loki/ELK
  c.drain_timeout = 30         # seconds to drain in-flight requests on SIGTERM (default: 30)
  c.metrics_collector = Igniter::Metrics::Collector.new  # enable Prometheus metrics
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

### `GET /v1/live`

Kubernetes **liveness** probe. Always returns `200 OK`. If this endpoint fails, the pod should be restarted.

**Response:**
```json
{ "status": "alive", "pid": 12345 }
```

---

### `GET /v1/ready`

Kubernetes **readiness** probe. Returns `200` when the server can accept traffic, `503` when it cannot (no contracts registered or store unreachable).

**Response (ready):**
```json
{ "status": "ready", "checks": { "store": "ok", "contracts": "ok" } }
```

**Response (not ready, 503):**
```json
{ "status": "not_ready", "checks": { "store": "ok", "contracts": "no_contracts_registered" } }
```

---

### `GET /v1/metrics`

Prometheus text format metrics (exposition format 0.0.4). Returns `501` if no `metrics_collector` is configured.

**Content-Type:** `text/plain; version=0.0.4; charset=utf-8`

**Metrics exposed:**

| Metric | Type | Labels | Description |
|--------|------|--------|-------------|
| `igniter_executions_total` | counter | `graph`, `status` | Contract executions completed |
| `igniter_execution_duration_seconds` | histogram | `graph` | Execution wall-clock duration |
| `igniter_http_requests_total` | counter | `method`, `path`, `status` | HTTP requests received |
| `igniter_http_request_duration_seconds` | histogram | `method`, `path`, `status` | HTTP request processing duration |
| `igniter_pending_executions` | gauge | `graph` | Executions currently in pending state in the store |

Dynamic path segments are collapsed to avoid high cardinality (e.g. `/v1/contracts/MyContract/execute` → `/v1/contracts/:name/execute`).

**Enable metrics:**
```ruby
require "igniter/metrics"

Igniter::Server.configure do |c|
  c.metrics_collector = Igniter::Metrics::Collector.new
end
```

---

### `GET /v1/health`

General health check (human-readable, not a K8s probe).

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

## Kubernetes Deployment

### Deployment manifest

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: igniter-server
spec:
  replicas: 3
  template:
    spec:
      terminationGracePeriodSeconds: 60   # must be > drain_timeout
      containers:
        - name: igniter
          image: my-org/igniter-app:latest
          ports:
            - containerPort: 4567
          env:
            - name: REDIS_URL
              valueFrom:
                secretKeyRef: { name: redis-secret, key: url }
          livenessProbe:
            httpGet: { path: /v1/live, port: 4567 }
            initialDelaySeconds: 5
            periodSeconds: 10
          readinessProbe:
            httpGet: { path: /v1/ready, port: 4567 }
            initialDelaySeconds: 3
            periodSeconds: 5
          lifecycle:
            preStop:
              exec:
                command: ["/bin/sh", "-c", "sleep 5"]  # give k8s time to drain
```

### Server configuration for K8s

```ruby
require "igniter/server"
require "igniter/metrics"

Igniter::Server.configure do |c|
  c.host         = "0.0.0.0"
  c.port         = 4567
  c.log_format   = :json          # structured logs → stdout → Loki/CloudWatch
  c.drain_timeout = 30            # seconds, must be < terminationGracePeriodSeconds
  c.metrics_collector = Igniter::Metrics::Collector.new
  c.store        = Igniter::Runtime::Stores::RedisStore.new(
    redis: Redis.new(url: ENV.fetch("REDIS_URL")),
    namespace: "igniter:prod"
  )
  c.register "MyContract", MyContract
end

Igniter::Server.start
```

### Prometheus scraping (prometheus.yml)

```yaml
scrape_configs:
  - job_name: igniter
    static_configs:
      - targets: ["igniter-service:4567"]
    metrics_path: /v1/metrics
```

---

## Structured Logging

igniter-server logs every request and lifecycle event to `$stdout`.

**Text format** (default, `:text`):
```
[2026-04-10T12:00:00Z] INFO igniter-server started host=0.0.0.0 port=4567 pid=1
[2026-04-10T12:00:01Z] INFO POST /v1/contracts/MyContract/execute status=200
[2026-04-10T12:00:02Z] INFO SIGTERM received — draining drain_timeout=30 pid=1
```

**JSON format** (`:json`) — one JSON object per line, compatible with Loki, ELK, CloudWatch Logs:
```json
{"time":"2026-04-10T12:00:00.123Z","level":"INFO","msg":"igniter-server started","host":"0.0.0.0","port":4567,"pid":1}
{"time":"2026-04-10T12:00:01.456Z","level":"INFO","msg":"POST /v1/contracts/MyContract/execute","status":200}
```

Configure via:
```ruby
Igniter::Server.configure { |c| c.log_format = :json }
```

---

## Graceful Shutdown

On `SIGTERM`, the server:
1. Stops accepting new connections
2. Waits up to `drain_timeout` seconds for in-flight requests to complete
3. Exits cleanly

```ruby
Igniter::Server.configure { |c| c.drain_timeout = 30 }
```

Set `terminationGracePeriodSeconds` in your Kubernetes Deployment to a value greater than `drain_timeout` (e.g. 60s) to give the server enough time to drain before the pod is force-killed.

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
