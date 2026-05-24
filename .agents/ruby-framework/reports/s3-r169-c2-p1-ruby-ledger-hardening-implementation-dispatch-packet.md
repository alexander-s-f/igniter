# Round Report: ruby-framework S3-R169-C2-P1 Ruby Ledger hardening implementation dispatch packet

Status: PASS - implementation card ready to run
Date: 2026-05-24
Supervisor: [Ruby Framework Supervisor]
Route: UPDATE
Track: ruby-ledger-hardening-implementation-dispatch-packet-v0
Depends on:
- S3-R168-C2-A
- S3-R167-C2-P1

## Executive Summary

- Portfolio authorized a bounded Igniter Ledger package hardening slice:
  `ledger-server-unified-state-plane-and-serialized-envelope-dispatch-v0`.
- The implementation boundary is narrow: StoreServer-hosted HTTP/TCP
  WireEnvelope adapters must share one server-owned
  `Protocol::Interpreter` / `IgniterStore` state plane.
- Dispatch for StoreServer-hosted HTTP/TCP envelope traffic must be serialized
  through one server-owned mutex; reads and writes serialize together for this
  first slice.
- Legacy `NetworkBackend` remains compatibility-only for this slice; no
  legacy-to-envelope state bridge is authorized.
- No gem release, production readiness claim, Spark production binding, or
  broad public API widening is authorized.

## Decisions Needed From Portfolio

- None. S3-R168 already authorized the bounded package implementation.

## Blocker List

No blockers found for dispatch.

Guardrails that must remain visible during implementation:

- Do not bridge legacy `NetworkBackend` into the envelope state plane.
- Do not claim legacy/envelope interoperability.
- Do not change versions, gemspec release metadata, tags, or publishing state.
- Do not edit Spark CRM or Igniter-Lang compiler/runtime surfaces.
- Do not turn local stress evidence into production benchmark/readiness claims.

## Exact Implementation Card Text

```text
Card: RUBY-LEDGER-SERVER-P1-I
Agent: [Ruby Framework Implementation Agent]
Role: implementation-agent
Track: ledger-server-unified-state-plane-and-serialized-envelope-dispatch-v0
Route: UPDATE
Parent: [Ruby Framework Supervisor]
Workspace: /Users/alex/dev/projects/igniter
Authorization: S3-R168-C2-A

Goal:
Implement and prove StoreServer-hosted HTTP/TCP WireEnvelope shared state-plane
and serialized dispatch, while keeping legacy NetworkBackend compatibility-only
for this slice.

Required reads:
- AGENTS.md
- .agents/ruby-framework/reports/s3-r168-c2-a-ruby-ledger-unified-state-plane-implementation-authorization-review.md
- .agents/ruby-framework/reports/s3-r167-c2-p1-ledger-server-envelope-state-plane-and-concurrency-contract.md
- .agents/ruby-framework/tracks/ledger-server-envelope-state-plane-and-concurrency-contract-v0.md
- packages/igniter-ledger/docs/server-model.md
- packages/igniter-ledger/docs/server-api-proposal.md
- packages/igniter-ledger/docs/store-server-production-surface.md
- packages/igniter-ledger/lib/igniter/store/store_server.rb
- packages/igniter-ledger/lib/igniter/store/http_adapter.rb
- packages/igniter-ledger/lib/igniter/store/tcp_adapter.rb
- packages/igniter-ledger/lib/igniter/store/network_backend.rb
- packages/igniter-ledger/spec/igniter/store/store_server_spec.rb
- packages/igniter-ledger/spec/igniter/store/network_backend_spec.rb
- packages/igniter-ledger/spec/igniter/store/http_adapter_spec.rb
- packages/igniter-ledger/spec/igniter/store/tcp_adapter_spec.rb
- packages/igniter-ledger/spec/igniter/store/server_production_surface_spec.rb

Allowed write scope:
- packages/igniter-ledger/lib/igniter/store/store_server.rb
- packages/igniter-ledger/lib/igniter/store/http_adapter.rb
- packages/igniter-ledger/lib/igniter/store/tcp_adapter.rb
- packages/igniter-ledger/spec/igniter/store/store_server_spec.rb
- packages/igniter-ledger/spec/igniter/store/http_adapter_spec.rb
- packages/igniter-ledger/spec/igniter/store/tcp_adapter_spec.rb
- packages/igniter-ledger/spec/igniter/store/server_production_surface_spec.rb
- packages/igniter-ledger/docs/server-model.md
- packages/igniter-ledger/docs/server-api-proposal.md
- packages/igniter-ledger/docs/store-server-production-surface.md
- .agents/ruby-framework/tracks/ledger-server-unified-state-plane-and-serialized-envelope-dispatch-v0.md
- .agents/ruby-framework/reports/s3-r169-ruby-ledger-unified-state-plane-and-serialized-envelope-dispatch.md
- .agents/ruby-framework/current-status.md

Optional write scope if useful:
- packages/igniter-ledger/spec/support/ledger_server_state_plane_helpers.rb

Required implementation:
- StoreServer-hosted HTTPAdapter and TCPAdapter must share one server-owned
  Protocol::Interpreter / IgniterStore state plane.
- StoreServer-hosted HTTP/TCP WireEnvelope dispatch must run through one
  server-owned Mutex or equivalent serialized dispatcher.
- Reads and writes through the StoreServer-hosted envelope dispatch path must
  serialize together for this first hardening slice.
- Standalone HTTPAdapter.new(interpreter:) and TCPAdapter.new(interpreter:)
  behavior may remain as-is; server-grade serialization applies only when
  hosted/wired by StoreServer unless explicitly documented otherwise.
- Legacy NetworkBackend behavior must keep passing existing focused specs, but
  remains compatibility-only and not claimed interoperable with the envelope
  state plane.

Required specs/proofs:
- StoreServer-hosted HTTP and TCP adapters observe one shared envelope state
  plane.
- Write through HTTP, then read/query through TCP.
- Write through TCP, then read/query through HTTP, if the current protocol
  supports the needed operation shape.
- Bounded concurrent mixed HTTP/TCP envelope dispatch returns exact final
  counts with no missing writes.
- Invalid envelope dispatch returns envelope-shaped errors or existing adapter
  errors without corrupting state.
- Existing legacy NetworkBackend compatibility specs still pass.
- Docs explicitly state legacy NetworkBackend is compatibility-only in this
  slice and legacy/envelope interoperability is not claimed.

Required command gate:
BUNDLE_GEMFILE=packages/igniter-ledger/Gemfile bundle exec rspec \
  packages/igniter-ledger/spec/igniter/store/store_server_spec.rb \
  packages/igniter-ledger/spec/igniter/store/network_backend_spec.rb \
  packages/igniter-ledger/spec/igniter/store/http_adapter_spec.rb \
  packages/igniter-ledger/spec/igniter/store/tcp_adapter_spec.rb \
  packages/igniter-ledger/spec/igniter/store/server_production_surface_spec.rb

If shared store/protocol behavior changes more broadly, also run:
BUNDLE_GEMFILE=packages/igniter-ledger/Gemfile bundle exec rspec packages/igniter-ledger/spec

Deliver:
- implementation track:
  .agents/ruby-framework/tracks/ledger-server-unified-state-plane-and-serialized-envelope-dispatch-v0.md
- Ruby Framework implementation report:
  .agents/ruby-framework/reports/s3-r169-ruby-ledger-unified-state-plane-and-serialized-envelope-dispatch.md
- changed file list and rationale;
- command evidence and pass/fail result;
- exact remaining blockers, if any;
- PASS/HOLD recommendation for this hardening slice.

Do not:
- release gems;
- tag, push, or publish;
- edit gemspec release metadata or version files;
- widen public API beyond package-internal wiring needed for this slice;
- claim production readiness, benchmark capacity, p99/SLO, multi-host, auth/TLS,
  retry, idempotency, outbox, connection pooling, replication, failover, or
  cluster semantics;
- bind Spark to Ledger;
- claim Ledger as Spark source of truth;
- bridge legacy NetworkBackend into the envelope state plane;
- edit Spark CRM files;
- edit Igniter-Lang compiler/runtime files.
```

## Evidence

Accepted authorization:

- `.agents/ruby-framework/reports/s3-r168-c2-a-ruby-ledger-unified-state-plane-implementation-authorization-review.md`

Accepted design input:

- `.agents/ruby-framework/reports/s3-r167-c2-p1-ledger-server-envelope-state-plane-and-concurrency-contract.md`
- `.agents/ruby-framework/tracks/ledger-server-envelope-state-plane-and-concurrency-contract-v0.md`

No code or specs were changed in this dispatch card.

## Cross-Lane Requests

To Ruby Framework Implementation:

- Run the implementation card exactly within the authorized package scope.
- Return a compact implementation report with changed files, command evidence,
  risks, and PASS/HOLD status.

To Spark CRM:

- Continue treating Ledger server work as local package hardening only.
- Do not assume server production readiness or legacy/envelope interoperability.

To Portfolio:

- No further decision is needed before implementation starts, unless the
  implementation discovers it must bridge legacy `NetworkBackend` or widen API.

## Recommended Next

```text
Run RUBY-LEDGER-SERVER-P1-I:
ledger-server-unified-state-plane-and-serialized-envelope-dispatch-v0
```

Implementation may proceed under S3-R168 authorization.

## Explicit Non-Authorizations

- No gem release.
- No tag, push, or publish.
- No Spark production binding.
- No production readiness or benchmark claim.
- No Ledger source-of-truth claim for Spark.
- No legacy `NetworkBackend` bridge.
- No public API widening beyond package-internal wiring needed for this slice.

