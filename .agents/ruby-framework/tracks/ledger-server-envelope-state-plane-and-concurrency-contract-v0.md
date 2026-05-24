# Ledger Server Envelope State-Plane And Concurrency Contract v0

Status: PASS - design boundary accepted, implementation gated
Date: 2026-05-24
Card: S3-R167-C2-P1
Route: UPDATE
Track: ledger-server-envelope-state-plane-and-concurrency-contract-v0
Guidance: PG-2026-05-20-01

## Purpose

Design the minimum Ledger server state-plane and envelope concurrency contract
needed before Spark-style availability/read-model pressure grows.

This is local design/proof evidence only. It is not implementation
authorization, a production readiness claim, or Spark production adoption
authorization.

## Source Read

- `.agents/ruby-framework/reports/s3-r166-c2-p1-igniter-ledger-server-stress-boundary-probe.md`
- `.agents/ruby-framework/tracks/igniter-ledger-server-stress-boundary-probe-v0.md`
- `packages/igniter-ledger/docs/server-model.md`
- `packages/igniter-ledger/docs/server-api-proposal.md`
- `packages/igniter-ledger/docs/store-server-production-surface.md`
- `packages/igniter-ledger/lib/igniter/store/store_server.rb`
- `packages/igniter-ledger/lib/igniter/store/http_adapter.rb`
- `packages/igniter-ledger/lib/igniter/store/tcp_adapter.rb`
- `packages/igniter-ledger/lib/igniter/store/network_backend.rb`
- `igniter-lang/docs/org/portfolio-guidance-log-v0.md`
- `igniter-lang/docs/org/portfolio-reporting-protocol-v0.md`
- `igniter-lang/roles/base-role.md`

## Current Observed Boundary

The current server has two distinct state paths inside one process:

1. Legacy `StoreServer` + `NetworkBackend`
   - client-side `NetworkBackend` serializes RPCs on one socket with a mutex;
   - server-side `write_fact`, `replay`, and snapshot handling use
     `StoreServer`'s `@write_mutex`;
   - memory mode stores facts in `@in_memory_facts`;
   - file mode writes to `FileBackend` WAL.

2. HTTP/TCP WireEnvelope adapters
   - `HTTPAdapter` handles `POST /v1/dispatch` and delegates directly to
     `@interpreter.wire.dispatch(envelope)`;
   - `TCPAdapter` runs one thread per accepted connection and delegates each
     frame directly to `@interpreter.wire.dispatch(envelope)`;
   - `StoreServer#protocol` currently creates a fresh `IgniterStore` and a
     lazy `Protocol::Interpreter` for the adapter plane;
   - current comment in `StoreServer#protocol` correctly states that this is
     independent of the legacy fact log.

This means current local stress evidence proves bounded behavior per path, but
does not prove one shared server state plane across legacy and WireEnvelope
transports.

## Decision Matrix

| Option | Shape | Pros | Risks | Decision |
| --- | --- | --- | --- | --- |
| A. Keep planes separate intentionally | Legacy port owns raw fact log; HTTP/TCP own separate `IgniterStore` | Low implementation risk; current code already matches | Confusing server semantics; Spark/client users can observe split-brain behavior across transports | Reject as Spark-facing contract |
| B. Unify server state plane | One server-owned store/fact plane feeds legacy and HTTP/TCP envelope transports | Matches server docs; one process has one projection state; easiest client story | Requires careful raw fact ingestion semantics and specs | Recommended target |
| C. Envelope-only Spark bridge | Mark legacy path compatibility-only; Spark uses only HTTP/TCP envelope/client boundary | Smaller immediate promise; avoids legacy coupling | Still needs docs and explicit non-assumption that legacy and envelope paths interoperate | Acceptable interim if unification is delayed |
| D. Add async/RW-lock/pool semantics now | Optimize concurrency beyond one serialized dispatch path | Future performance headroom | Too broad before state-plane contract is settled | Defer |

## Chosen Contract

The Ledger server should move toward one canonical server-owned state plane
before Spark-style server adoption. The current separate plane can remain as a
transitional implementation fact, but it must not become the Spark-facing or
public mental model.

Minimum contract:

- A `StoreServer` process owns one canonical store/fact plane.
- HTTP and TCP WireEnvelope adapters in that process dispatch against the same
  `Protocol::Interpreter` and store.
- Legacy `NetworkBackend` is either bridged to the same store/fact plane or
  explicitly documented as compatibility-only and outside Spark-facing server
  assumptions.
- Envelope dispatch is serialized at the server boundary before returning to
  clients.
- Reads and writes through the same server-hosted interpreter observe one
  process-local total order.
- This contract is per-process only; it does not imply cluster, replication,
  retry, idempotency, or multi-host guarantees.

## Envelope Concurrency / Serialization Contract

Recommended first implementation contract:

```text
For server-hosted HTTP/TCP WireEnvelope adapters, every call to
Protocol::Interpreter#wire.dispatch is executed through one server-owned
dispatch mutex.

Mutating and read-like envelope operations are serialized together for the first
hardening slice, so each response observes all earlier completed dispatches in
that server process.
```

Why serialize reads too:

- it is the smallest explicit contract that avoids partial snapshot questions;
- it matches the existing conservative legacy `@write_mutex` shape for
  `write_fact` and `replay`;
- it can later be relaxed to a documented read/write lock after conformance
  tests exist.

Standalone adapter usage remains narrower:

- `HTTPAdapter.new(interpreter:)` and `TCPAdapter.new(interpreter:)` outside
  `StoreServer` should not imply server-grade serialization unless they receive
  an explicit serialized dispatcher or a documented `dispatch_mutex`.
- The package should avoid implying that every arbitrary interpreter instance is
  thread-safe for production concurrent mutation.

## Minimum Specs / Proofs Before Spark-Style Server Use

Required package hardening proofs:

| Proof | Purpose | Expected evidence |
| --- | --- | --- |
| HTTP/TCP shared plane | Write through HTTP, read/query/replay through TCP, and vice versa | Same fact count and expected values |
| Legacy/envelope boundary decision | Either prove legacy writes are visible through envelope and envelope writes through legacy, or prove/document legacy compatibility-only separation | Spec names must encode chosen boundary |
| Serialized mixed dispatch | Concurrent writes and reads over HTTP/TCP return exact final counts with 0 missing writes | Focused spec plus bounded local smoke |
| File-backed restart | Envelope writes to file-backed server replay after stop/start | Exact count and values after restart |
| Descriptor/metadata consistency | Concurrent descriptor registration and metadata/read operations remain coherent | Metadata snapshot matches registered descriptors |
| Error isolation | Invalid envelopes return envelope-shaped errors without corrupting store state | Before/after fact count unchanged |

Recommended local smoke after specs:

```text
ledger-server-local-stress-smoke-task-v0
```

The smoke should be a repeatable developer task, not a production benchmark.
It should cover concurrent HTTP/TCP dispatch, optional legacy compatibility
visibility, restart/replay when file-backed, and cleanup of local sockets/files.

## What Spark May Safely Assume Now

Spark may assume:

- Ruby packages can continue app-local observed-service receipt work;
- Ledger server stress evidence is local and bounded, useful for design
  pressure but not production authorization;
- `client:`-style adapter boundaries remain the right direction for future
  receipt sinks;
- an envelope-only local proof can be designed after the server state-plane
  boundary is implemented or explicitly documented.

Spark must not assume:

- Ledger is a Spark source of truth;
- current `StoreServer` legacy and HTTP/TCP envelope paths share facts;
- current server adapters provide production concurrency, p99, retry,
  idempotency, outbox, auth, TLS, backpressure, or failover;
- Spark production adoption is authorized.

## Future Implementation Authorization Boundary

Do not implement in this card. The next authorized hardening slice should decide
one of these implementation routes:

1. Preferred route: unify `StoreServer` around one canonical store/fact plane
   and add a server-owned serialized dispatcher for HTTP/TCP adapters.
2. Interim route: keep legacy `NetworkBackend` compatibility-only, document that
   it is not the same state plane, and make the Spark-facing route envelope-only
   with explicit specs.

The implementation card must include package code/spec authorization. Until
then, docs and reports must keep the current separation visible.

## Recommended Next Hardening Card

```text
Card: RUBY-LEDGER-SERVER-P1
Track: ledger-server-unified-state-plane-and-serialized-envelope-dispatch-v0

Goal:
Implement and prove the chosen Ledger server state-plane contract for
StoreServer-hosted HTTP/TCP WireEnvelope dispatch before Spark-style server use.

Scope:
- package code/specs only for igniter-ledger;
- add one server-owned serialized dispatcher for StoreServer-hosted envelope
  dispatch;
- decide and implement legacy NetworkBackend bridge vs compatibility-only
  boundary;
- add HTTP/TCP shared-plane specs;
- add mixed concurrent dispatch specs;
- add file-backed restart/replay proof if the envelope plane is file-backed;
- no gem release;
- no production readiness claim;
- no Spark production binding.
```

Hold reasons if not accepted:

- current local stress remains useful but split-plane semantics remain a
  blocker for Spark-style server assumptions;
- package docs would need a narrower compatibility note before any external
  server usage guidance grows.

