# Portfolio Decision: Ruby Ledger Unified State-Plane Implementation Authorization Review

Status: authorized-bounded
Date: 2026-05-24
Card: S3-R168-C2-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: ruby-ledger-unified-state-plane-implementation-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R167-C2-P1

## Decision

Authorize a bounded Igniter Ledger package hardening implementation:

```text
ledger-server-unified-state-plane-and-serialized-envelope-dispatch-v0
```

The authorized slice is intentionally narrow:

- make the `StoreServer`-hosted HTTP/TCP WireEnvelope state plane explicit;
- serialize `StoreServer`-hosted HTTP/TCP envelope dispatch through one
  server-owned dispatch mutex;
- prove HTTP and TCP envelope adapters observe one shared `Protocol::Interpreter`
  / `IgniterStore` state plane when hosted by the same `StoreServer`;
- document legacy `NetworkBackend` as compatibility-only and outside
  Spark-facing server assumptions for this slice.

This card does not authorize bridging legacy `NetworkBackend` raw fact handling
into the envelope `IgniterStore`. That bridge remains a separate later design
because raw fact ingestion semantics need their own proof.

## Accepted Input Evidence

Accepted:

- S3-R166 bounded local stress probe passed focused server/transport specs:
  `80 examples, 0 failures`;
- S3-R167 design boundary is PASS;
- current split-plane risk is real: legacy `NetworkBackend`/fact-log and
  HTTP/TCP WireEnvelope dispatch do not have a proven shared fact plane;
- preferred Spark-facing direction is a single server-owned envelope state
  plane with conservative serialized dispatch;
- no production readiness, benchmark, Spark binding, or source-of-truth claim
  exists.

## State-Plane Decision

Decision for this implementation slice:

```text
StoreServer-hosted HTTP and TCP WireEnvelope adapters must share one
server-owned Protocol::Interpreter / IgniterStore state plane.
```

Legacy `NetworkBackend` stance:

```text
compatibility_only_for_this_slice
```

Meaning:

- legacy `NetworkBackend` behavior must not be broken;
- legacy and envelope transports are not claimed to share data;
- docs/spec names must make this compatibility-only boundary visible;
- Spark must not assume legacy/envelope interoperability.

## Serialized Dispatcher Boundary

Authorized first concurrency contract:

```text
For StoreServer-hosted HTTP/TCP WireEnvelope adapters, every dispatch is routed
through one server-owned Mutex. Reads and writes are serialized together for
this first hardening slice.
```

Allowed implementation shapes:

- an internal serialized dispatcher object owned by `StoreServer`;
- or an internal dispatch mutex injected into StoreServer-hosted HTTP/TCP
  adapter handlers;
- or an equivalent package-local helper that preserves the same contract.

Standalone `HTTPAdapter.new(interpreter:)` and `TCPAdapter.new(interpreter:)`
must not silently claim server-grade serialization unless the implementation
explicitly passes the serialized dispatcher/mutex. Standalone adapter behavior
may remain as-is if the docs/specs say server-grade serialization applies only
to `StoreServer`-hosted adapters.

## Authorized Write Scope

Package code/specs:

```text
packages/igniter-ledger/lib/igniter/store/store_server.rb
packages/igniter-ledger/lib/igniter/store/http_adapter.rb
packages/igniter-ledger/lib/igniter/store/tcp_adapter.rb
packages/igniter-ledger/spec/igniter/store/store_server_spec.rb
packages/igniter-ledger/spec/igniter/store/http_adapter_spec.rb
packages/igniter-ledger/spec/igniter/store/tcp_adapter_spec.rb
packages/igniter-ledger/spec/igniter/store/server_production_surface_spec.rb
```

Docs/reports:

```text
packages/igniter-ledger/docs/server-model.md
packages/igniter-ledger/docs/server-api-proposal.md
packages/igniter-ledger/docs/store-server-production-surface.md
.agents/ruby-framework/tracks/ledger-server-unified-state-plane-and-serialized-envelope-dispatch-v0.md
.agents/ruby-framework/reports/s3-r168-ruby-ledger-unified-state-plane-and-serialized-envelope-dispatch.md
```

Optional local diagnostic proof file, if useful:

```text
packages/igniter-ledger/spec/support/ledger_server_state_plane_helpers.rb
```

Do not edit gemspecs, version files, release metadata, Spark files, or
Igniter-Lang compiler files.

## Required Specs / Proofs

Required proof matrix:

- `StoreServer`-hosted HTTP and TCP adapters share one envelope state plane;
- write through HTTP, read/query through TCP, and the reverse direction if the
  protocol supports the needed read/write operations;
- concurrent mixed HTTP/TCP envelope dispatch is serialized and returns exact
  final counts with no missing writes under bounded local load;
- invalid envelope dispatch returns envelope-shaped errors or existing adapter
  errors without corrupting state;
- legacy `NetworkBackend` compatibility behavior still passes existing focused
  specs;
- docs explicitly state legacy/envelope interop is not claimed in this slice.

Required command gate:

```bash
BUNDLE_GEMFILE=packages/igniter-ledger/Gemfile bundle exec rspec \
  packages/igniter-ledger/spec/igniter/store/store_server_spec.rb \
  packages/igniter-ledger/spec/igniter/store/network_backend_spec.rb \
  packages/igniter-ledger/spec/igniter/store/http_adapter_spec.rb \
  packages/igniter-ledger/spec/igniter/store/tcp_adapter_spec.rb \
  packages/igniter-ledger/spec/igniter/store/server_production_surface_spec.rb
```

If the implementation changes shared store/protocol behavior more broadly, run:

```bash
BUNDLE_GEMFILE=packages/igniter-ledger/Gemfile bundle exec rspec packages/igniter-ledger/spec
```

## Local Stress Smoke Status

Authorized for this slice:

```text
bounded local stress/proof only
```

Not authorized:

```text
production benchmark
capacity claim
p99/SLO claim
marketing benchmark
Spark production adoption evidence
```

A repeatable local stress smoke task may be proposed or added only if it stays
package-local, clearly non-production, and does not require external services.

## Closed Surfaces

This decision does not authorize:

- gem release;
- tag or branch push;
- public API widening beyond package-internal adapter wiring needed for this
  slice;
- production readiness or benchmark claims;
- Spark production adoption;
- Ledger source-of-truth claim for Spark;
- legacy `NetworkBackend` bridge into envelope state plane;
- retry, outbox, idempotency, auth/TLS, connection pooling, replication,
  multi-host, failover, or cluster semantics;
- Igniter-Lang compiler/runtime changes.

## Exact Next Ruby Card Boundary

```text
Card: RUBY-LEDGER-SERVER-P1-I
Agent: [Ruby Framework Implementation Agent]
Role: implementation-agent
Track: ledger-server-unified-state-plane-and-serialized-envelope-dispatch-v0
Route: UPDATE

Goal:
Implement and prove StoreServer-hosted HTTP/TCP WireEnvelope shared state-plane
and serialized dispatch, while keeping legacy NetworkBackend compatibility-only
for this slice.

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
- .agents/ruby-framework/reports/s3-r168-ruby-ledger-unified-state-plane-and-serialized-envelope-dispatch.md

Required:
- one StoreServer-owned envelope state plane for hosted HTTP/TCP;
- one StoreServer-owned serialized envelope dispatch boundary;
- focused specs proving shared HTTP/TCP envelope state;
- focused specs or proof proving bounded concurrent dispatch safety;
- docs saying legacy NetworkBackend remains compatibility-only and not
  interoperable with envelope state in this slice.

Do not:
- release gems;
- widen public API beyond package-internal wiring;
- claim production readiness;
- bind Spark to Ledger;
- bridge legacy NetworkBackend into envelope state plane.
```

## Compact Receipt

```text
card: S3-R168-C2-A
status: done
decision: authorize_bounded_package_implementation
authorized_track: ledger-server-unified-state-plane-and-serialized-envelope-dispatch-v0
state_plane_decision: StoreServer_hosted_HTTP_TCP_envelope_shared_state_plane
serialized_dispatch: required_server_owned_mutex
legacy_network_backend: compatibility_only_this_slice
production_readiness_claim: no
spark_binding_authorized: no
gem_release_authorized: no
public_api_widening: no_except_internal_wiring_if_needed
```
