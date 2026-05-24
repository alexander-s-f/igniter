# Igniter Ledger Server Stress Boundary Probe v0

Status: PASS - bounded local probe completed
Date: 2026-05-24
Card: S3-R166-C2-P1
Route: UPDATE
Track: igniter-ledger-server-stress-boundary-probe-v0
Guidance: PG-2026-05-20-01

## Purpose

Map and run a bounded local stress probe for Igniter Ledger server/read-write
behavior before Spark-style availability/read-model pressure grows.

This is local stress/probe evidence only. It is not a production benchmark,
capacity claim, marketing number, or Spark adoption authorization.

## Source Read

Read current Ledger package/server docs and specs:

- `packages/igniter-ledger/README.md`
- `packages/igniter-ledger/docs/server-model.md`
- `packages/igniter-ledger/docs/server-api-proposal.md`
- `packages/igniter-ledger/docs/store-server-production-surface.md`
- `packages/igniter-ledger/docs/storage-durability-contract.md`
- `packages/igniter-ledger/lib/igniter/store/igniter_store.rb`
- `packages/igniter-ledger/lib/igniter/store/store_server.rb`
- `packages/igniter-ledger/lib/igniter/store/network_backend.rb`
- `packages/igniter-ledger/lib/igniter/store/http_adapter.rb`
- `packages/igniter-ledger/lib/igniter/store/tcp_adapter.rb`
- `packages/igniter-ledger/lib/igniter/store/mcp_adapter.rb`
- `packages/igniter-ledger/spec/igniter/store/store_server_spec.rb`
- `packages/igniter-ledger/spec/igniter/store/network_backend_spec.rb`
- `packages/igniter-ledger/spec/igniter/store/http_adapter_spec.rb`
- `packages/igniter-ledger/spec/igniter/store/tcp_adapter_spec.rb`
- `packages/igniter-ledger/spec/igniter/store/mcp_adapter_spec.rb`

## Current Execution Modes

### In-Process Store

`Igniter::Store::IgniterStore` / `Igniter::Ledger::LedgerStore` is the embedded
store. It owns FactLog, cache, scope indexes, partition indexes, schema graph,
optional backend, and optional changefeed.

Observed boundary:

- no process boundary;
- app calls store methods directly;
- file persistence can be supplied through `FileBackend`;
- broad concurrent writes are not guarded by one obvious store-wide write mutex;
- scope/partition indexes have their own mutexes, but write/read as a whole is
  not documented as a production concurrency contract.

### Legacy StoreServer + NetworkBackend

`Igniter::Store::StoreServer` is the legacy TCP/Unix socket server for
`NetworkBackend`. It uses CRC32-framed JSON requests such as:

- `write_fact`
- `replay`
- `write_snapshot`
- `stats`
- `server_status`
- `subscribe`

Observed boundary:

- one thread per accepted connection;
- `write_fact`, `replay`, and snapshot paths are guarded by `@write_mutex`;
- server has `max_connections`, active connection metrics, drain/stop, status,
  recent events, changefeed, and metrics snapshots;
- memory backend keeps facts in server memory;
- file backend persists through `FileBackend` WAL and can replay after restart.

### HTTPAdapter / Rack

`Igniter::Store::HTTPAdapter` exposes `Protocol::Interpreter` as a Rack app.
Canonical route is `POST /v1/dispatch`; convenience/ops routes include health,
metadata, status, ready, metrics, SSE events, recent events, and compaction
activity.

Observed boundary:

- Rack app is mountable; built-in `start` uses Puma as dev/test convenience;
- canonical semantic surface is WireEnvelope through `/v1/dispatch`;
- direct Rack dispatch was probed, not a real HTTP server/socket deployment;
- adapter delegates to a shared `Protocol::Interpreter`.

Important implementation caveat:

```text
StoreServer#protocol currently constructs a fresh IgniterStore for the
HTTP/TCP envelope adapter plane. It is independent of the legacy StoreServer
fact log used by NetworkBackend.
```

So the current server process can host two planes, but Spark must not assume the
legacy NetworkBackend path and HTTP/TCP WireEnvelope path share the same facts
unless/until that is explicitly unified or documented as intentional.

### TCPAdapter

`Igniter::Store::TCPAdapter` exposes WireEnvelope over CRC32-framed TCP/Unix
sockets. This is the newer envelope dispatch path, distinct from the legacy
`NetworkBackend` path.

Observed boundary:

- one thread per accepted connection;
- delegates requests to shared `Protocol::Interpreter`;
- no explicit adapter-level write mutex was observed around interpreter/store
  dispatch.

### MCP Adapter

`Igniter::Store::MCPAdapter` is read-oriented operator/agent adapter over local
`IgniterStore`, local `Protocol::Interpreter`, or remote `/v1/dispatch`.

Observed boundary:

- it should not add persistence semantics;
- remote mode routes through HTTP dispatch;
- mutating MCP pressure remains outside this probe.

## Commands Run

Local socket commands initially fail inside default sandbox with:

```text
Errno::EPERM: Operation not permitted - bind(2) for "127.0.0.1" port 0
```

The same commands were rerun with local socket permission. No external network
was used.

Stress probe command:

```bash
ruby /private/tmp/igniter_ledger_stress_probe.rb
```

Focused server/transport spec gate:

```bash
BUNDLE_GEMFILE=packages/igniter-ledger/Gemfile bundle exec rspec \
  packages/igniter-ledger/spec/igniter/store/store_server_spec.rb \
  packages/igniter-ledger/spec/igniter/store/network_backend_spec.rb \
  packages/igniter-ledger/spec/igniter/store/http_adapter_spec.rb \
  packages/igniter-ledger/spec/igniter/store/tcp_adapter_spec.rb
```

## Probe Results

| Probe | Clients | Work | Result | p50 ms | p95 ms | Max ms |
| --- | ---: | --- | --- | ---: | ---: | ---: |
| `in_process_store_read_only` | 8 | 4,000 reads over 500 seeded facts | 0 errors; 500 final facts | 0.001 | 0.002 | 0.208 |
| `legacy_store_server_network_backend_mixed` | 12 | 550 writes + 150 replay calls | 0 errors; 550 final facts; active connections returned to 0 | 2.241 | 7.337 | 10.589 |
| `legacy_store_server_max_connections` | 8 attempts | `max_connections: 3` | 3 ok; 5 rejected/reset; active observed 3 | n/a | n/a | n/a |
| `legacy_store_server_file_backend_write_restart_replay` | 4 | 160 writes, stop/restart/replay | 0 errors; 160 before restart; 160 after restart; 43,000 WAL bytes | 0.211 | 0.397 | 0.868 |
| `http_rack_dispatch_direct_mixed` | 8 | 200 writes + 200 metadata reads through Rack app | 0 errors; final query count 200 | 0.033 | 0.089 | 14.691 |
| `tcp_adapter_dispatch_mixed` | 8 | 160 writes + 160 metadata reads through TCPAdapter | 0 errors; final query count 160 | 0.675 | 1.162 | 1.851 |

Focused specs:

```text
80 examples, 0 failures
```

## Safe To Call Concurrently Now

With current evidence:

- legacy `StoreServer` + `NetworkBackend` can accept concurrent local clients
  for `write_fact` and `replay` under bounded local load;
- legacy `StoreServer` enforces `max_connections` by rejecting excess clients;
- file-backed legacy server can persist a bounded concurrent write set and
  replay exact count after restart;
- direct Rack `HTTPAdapter#rack_app` and `TCPAdapter` can survive bounded mixed
  write/metadata dispatch in local tests.

## Not Proven

- Production throughput, capacity, latency SLOs, or p99 behavior.
- Long-running soak, memory growth, descriptor churn, retention/compaction under
  mixed load, SSE fan-out under load, or MCP remote load.
- Crash consistency during concurrent file-backed writes.
- Native extension / Rust backend stress parity.
- Puma or any production HTTP server deployment behavior.
- HTTP/TCP envelope adapter sharing the same fact plane as legacy
  `NetworkBackend`.
- In-process concurrent writes as a documented app contract.
- Multi-process, multi-host, cluster, replication, failover, or quorum behavior.

## What Spark Must Not Assume Yet

- Ledger is not a Spark source of truth.
- `igniter-ledger` server is not a production-ready availability/read-model
  database.
- HTTP/TCP adapter facts and legacy NetworkBackend facts are not automatically
  one shared server state plane.
- No unlimited writer/client count, connection pool, retry, backpressure,
  idempotency, or outbox guarantee exists from this probe.
- No Spark production adoption or high-volume rollout is authorized.

## API / Adapter Shape To Reduce Spark/Igniter Delta

Recommended bridge shape:

- Spark should talk through `igniter-ledger-client` or an app-local store adapter
  protocol, not directly to Ledger internals.
- The receipt adapter should accept a `client:` and stay compatible with local,
  remote, and outbox-backed delivery.
- Spark should own redaction, sampling, rollout flags, and durable outbox/retry.
- Ledger package should expose one clearly documented server state plane for
  WireEnvelope dispatch before Spark relies on a server process.
- Add explicit server-side dispatch serialization or document the exact
  concurrency contract for `Protocol::Interpreter` and `IgniterStore`.

## Recommended Next Package Hardening Slice

```text
ledger-server-envelope-state-plane-and-concurrency-contract-v0
```

Scope suggestion:

- decide whether `StoreServer#protocol` should wrap the same store/fact plane as
  the legacy `NetworkBackend` path or remain intentionally separate;
- add focused specs that prove the chosen boundary;
- add an explicit mutex/concurrency policy around envelope dispatch if shared
  interpreter writes are meant to be concurrent-safe;
- add a small public docs note separating embedded store, legacy server, HTTP
  envelope, TCP envelope, and MCP adapter responsibilities;
- add a repeatable stress smoke task under package test/dev tooling, still
  framed as local diagnostic evidence, not a benchmark.

## Explicit Non-Authorizations

- No gem release.
- No tag or branch push.
- No public API change.
- No production benchmark or production readiness claim.
- No Spark production adoption.
- No Ledger source-of-truth claim for Spark.
