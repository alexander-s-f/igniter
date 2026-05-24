# Round Report: ruby-framework S3-R166-C2-P1 Igniter Ledger server stress boundary probe

Status: PASS - bounded local probe completed
Date: 2026-05-24
Supervisor: [Ruby Framework Supervisor]
Route: UPDATE
Track: igniter-ledger-server-stress-boundary-probe-v0
Guidance: PG-2026-05-20-01
Scope: Map and run a bounded local stress probe for Igniter Ledger server/read-write
behavior before Spark-style availability/read-model pressure grows.

## Executive Summary

- Mapped current Ledger execution modes: in-process store, legacy
  StoreServer/NetworkBackend, HTTP Rack adapter, TCP envelope adapter, and MCP
  adapter.
- Ran a local bounded stress probe; all permitted local socket/Rack probes
  passed after rerunning with local socket permission.
- Focused server/transport specs passed: `80 examples, 0 failures`.
- Strongest concurrent evidence is the legacy `StoreServer` + `NetworkBackend`
  path: mixed writes/replays had 0 errors and exact final fact count.
- File-backed legacy server persisted 160 concurrent writes and replayed exact
  count after restart.
- Important caveat: `StoreServer#protocol` currently creates a fresh
  independent store for HTTP/TCP envelope adapters, so Spark must not assume all
  server transports share one fact plane.
- No production claims or Spark production adoption are authorized.

## Decisions Needed From Portfolio

- [ ] Confirm whether Ruby/Ledger should open
  `ledger-server-envelope-state-plane-and-concurrency-contract-v0` before any
  Spark-style server adoption pressure grows.

## Completed

- Reviewed Ledger server docs, production-surface docs, storage durability docs,
  implementation, and focused server/transport specs.
- Designed a local-only probe covering concurrent reads, mixed read/write load,
  connection count enforcement, file backend restart/replay, Rack dispatch, and
  TCP envelope dispatch.
- Ran focused server/transport specs.
- Filed boundary findings and recommended hardening slice.

## Changed Files

- `.agents/ruby-framework/tracks/igniter-ledger-server-stress-boundary-probe-v0.md`
- `.agents/ruby-framework/reports/s3-r166-c2-p1-igniter-ledger-server-stress-boundary-probe.md`
- `.agents/ruby-framework/current-status.md`

No package code, public API, examples, tags, or release artifacts were changed.

## Commands Run

First local socket attempts in the default sandbox failed with
`Errno::EPERM` on `127.0.0.1` bind. The same commands were rerun with local
socket permission; no external network was used.

```bash
ruby /private/tmp/igniter_ledger_stress_probe.rb
```

```bash
BUNDLE_GEMFILE=packages/igniter-ledger/Gemfile bundle exec rspec \
  packages/igniter-ledger/spec/igniter/store/store_server_spec.rb \
  packages/igniter-ledger/spec/igniter/store/network_backend_spec.rb \
  packages/igniter-ledger/spec/igniter/store/http_adapter_spec.rb \
  packages/igniter-ledger/spec/igniter/store/tcp_adapter_spec.rb
```

## Results Table

| Probe | Clients | Work | Result | p50 ms | p95 ms | Max ms |
| --- | ---: | --- | --- | ---: | ---: | ---: |
| `in_process_store_read_only` | 8 | 4,000 reads over 500 seeded facts | 0 errors; 500 final facts | 0.001 | 0.002 | 0.208 |
| `legacy_store_server_network_backend_mixed` | 12 | 550 writes + 150 replay calls | 0 errors; 550 final facts; active connections returned to 0 | 2.241 | 7.337 | 10.589 |
| `legacy_store_server_max_connections` | 8 attempts | `max_connections: 3` | 3 ok; 5 rejected/reset; active observed 3 | n/a | n/a | n/a |
| `legacy_store_server_file_backend_write_restart_replay` | 4 | 160 writes, stop/restart/replay | 0 errors; 160 before restart; 160 after restart | 0.211 | 0.397 | 0.868 |
| `http_rack_dispatch_direct_mixed` | 8 | 200 writes + 200 metadata reads through Rack app | 0 errors; final query count 200 | 0.033 | 0.089 | 14.691 |
| `tcp_adapter_dispatch_mixed` | 8 | 160 writes + 160 metadata reads through TCPAdapter | 0 errors; final query count 160 | 0.675 | 1.162 | 1.851 |

Focused specs:

```text
80 examples, 0 failures
```

## Risks / Unknowns

- No production throughput, soak, p99, memory, crash-consistency, native-backend,
  Puma, SSE-load, MCP-load, replication, or multi-host claim.
- In-process concurrent writes are not proven as a documented app contract.
- HTTP/TCP envelope dispatch passed bounded local stress, but adapter/interpreter
  concurrency policy is not explicitly documented.
- HTTP/TCP envelope adapters and legacy `NetworkBackend` currently do not
  clearly share one store/fact plane inside `StoreServer`.

## Cross-Lane Requests

To Igniter Ledger package:

- Decide and document whether the legacy server path and envelope adapter path
  should share one fact plane.
- Add explicit concurrency contract/specs for `Protocol::Interpreter` dispatch.

To Spark CRM:

- Do not assume Ledger server production readiness or source-of-truth behavior.
- Prefer an app-local receipt adapter/outbox and `client:`-style boundary.

To Portfolio:

- Route a package hardening slice before Spark-style server pressure escalates.

## Recommended Next

```text
ledger-server-envelope-state-plane-and-concurrency-contract-v0
```

Secondary support slice:

```text
ledger-server-local-stress-smoke-task-v0
```

## Explicit Non-Authorizations

- No gem release.
- No tag or branch push.
- No public API change.
- No production benchmark or production readiness claim.
- No Spark production adoption.
- No Ledger source-of-truth claim for Spark.
