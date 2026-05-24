# Round Report: ruby-framework S3-R167-C2-P1 Ledger server envelope state-plane and concurrency contract

Status: PASS - design boundary accepted; implementation gated
Date: 2026-05-24
Supervisor: [Ruby Framework Supervisor]
Route: UPDATE
Track: ledger-server-envelope-state-plane-and-concurrency-contract-v0
Guidance: PG-2026-05-20-01
Scope: Design/prove the Igniter Ledger server state-plane and envelope
concurrency contract needed before Spark-style server adoption pressure grows.

## Executive Summary

- Current `StoreServer` has two observed state paths: legacy
  `NetworkBackend`/fact-log handling and HTTP/TCP WireEnvelope dispatch through
  a separate `Protocol::Interpreter` over a fresh `IgniterStore`.
- The Spark-facing target should be one canonical server-owned store/fact plane,
  not intentionally separate transport state planes.
- Recommended first concurrency contract: server-hosted HTTP/TCP envelope
  dispatch is serialized through one server-owned dispatch mutex; reads and
  writes share the same lock for the first hardening slice.
- Legacy `NetworkBackend` should either be bridged to the same state plane or
  explicitly documented as compatibility-only and outside Spark-facing server
  assumptions.
- No package code, public API, release, production benchmark, or Spark
  production adoption was authorized in this round.

## Decisions Needed From Portfolio

- [ ] Authorize or hold the next Ruby/Ledger hardening slice:
  `ledger-server-unified-state-plane-and-serialized-envelope-dispatch-v0`.

## Completed

- Re-read S166 stress boundary results and active Portfolio guidance.
- Reviewed current Ledger server model/API/production-surface docs.
- Reviewed `StoreServer`, `HTTPAdapter`, `TCPAdapter`, and `NetworkBackend`
  implementation boundaries.
- Defined the preferred unified state-plane contract and an acceptable interim
  envelope-only boundary if unification is delayed.
- Defined minimum specs/proofs before Spark-style server use.
- Filed a track/design doc and this compact Portfolio report.

## Changed Files

- `.agents/ruby-framework/tracks/ledger-server-envelope-state-plane-and-concurrency-contract-v0.md`
- `.agents/ruby-framework/reports/s3-r167-c2-p1-ledger-server-envelope-state-plane-and-concurrency-contract.md`
- `.agents/ruby-framework/current-status.md`

No package code, package docs, examples, tags, releases, or publish artifacts
were changed.

## Evidence

Tracks:

- `.agents/ruby-framework/tracks/ledger-server-envelope-state-plane-and-concurrency-contract-v0.md`
- `.agents/ruby-framework/tracks/igniter-ledger-server-stress-boundary-probe-v0.md`

Prior probe evidence:

- `.agents/ruby-framework/reports/s3-r166-c2-p1-igniter-ledger-server-stress-boundary-probe.md`
- Bounded local probe passed for legacy server, direct Rack dispatch, TCP
  adapter dispatch, file-backed legacy restart/replay, and max connection
  enforcement.
- Focused server/transport specs from S166: `80 examples, 0 failures`.

Current read evidence:

- `packages/igniter-ledger/docs/server-model.md`
- `packages/igniter-ledger/docs/server-api-proposal.md`
- `packages/igniter-ledger/docs/store-server-production-surface.md`
- `packages/igniter-ledger/lib/igniter/store/store_server.rb`
- `packages/igniter-ledger/lib/igniter/store/http_adapter.rb`
- `packages/igniter-ledger/lib/igniter/store/tcp_adapter.rb`
- `packages/igniter-ledger/lib/igniter/store/network_backend.rb`

Tests/proofs this round:

- Design/docs-only round. No specs were rerun.

## Decision Matrix

| Option | Decision | Reason |
| --- | --- | --- |
| Keep legacy and envelope planes separate intentionally | Reject as Spark-facing contract | Creates confusing split-brain semantics across transports |
| Unify one server-owned state plane | Recommended | Matches server docs and gives one process one projection state |
| Envelope-only Spark bridge, legacy compatibility-only | Acceptable interim | Smaller promise if unification is delayed, but must be documented |
| Add broader async/RW-lock/pool semantics now | Defer | Too much scope before state-plane contract is proven |

## Risks / Drift

- Current package docs say a server process owns `IgniterStore` and
  `Protocol::Interpreter`, while current `StoreServer#protocol` creates a fresh
  independent adapter-plane store. This is design drift, not a release blocker
  until server adoption guidance grows.
- Serializing all envelope dispatch is conservative and may limit throughput,
  but gives a clear first contract before any read/write optimization.
- Raw fact ingestion semantics need careful implementation if legacy
  `NetworkBackend` is bridged into the same state plane.
- No production readiness, capacity, p99, multi-host, auth/TLS, retry,
  idempotency, outbox, or failover claim exists.

## Cross-Lane Requests

To Ruby Framework / Igniter Ledger:

- Open the next package hardening card only with explicit code/spec
  authorization.
- Keep current docs/reports clear that today's legacy and envelope paths are
  not proven as one shared state plane.

To Spark CRM:

- Do not assume Ledger server shared state-plane behavior yet.
- Continue primary-only observed-service receipt work app-locally.
- Treat any future server/client proof as local, not production source of truth.

To Portfolio:

- Decide whether to authorize the hardening slice now or hold until Spark has a
  concrete server-pressure need.

## Recommended Next

```text
RUBY-LEDGER-SERVER-P1
ledger-server-unified-state-plane-and-serialized-envelope-dispatch-v0
```

Exact boundary:

- implement/prove one canonical `StoreServer` state plane for HTTP/TCP
  WireEnvelope dispatch;
- add server-owned serialized envelope dispatch;
- decide legacy bridge vs compatibility-only boundary;
- add focused specs and optional repeatable local smoke;
- no gem release;
- no production readiness claim;
- no Spark production binding.

## Explicit Non-Authorizations

- No gem release.
- No tag or branch push.
- No public API widening.
- No production benchmark or production readiness claim.
- No Spark production adoption.
- No Ledger source-of-truth claim for Spark.

