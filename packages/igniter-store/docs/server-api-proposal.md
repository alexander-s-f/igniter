# Igniter Store Server API Proposal

Status date: 2026-05-02.
Status: proposal for the server/API layer above Igniter Store Open Protocol.
Not a stable public API.

## Claim

Igniter Store Open Protocol is the semantic waist. The server API should expose
that waist over transport without inventing a second meaning layer.

```text
clients
  CompanionStore / agents / external DSLs / JS apps / sync hubs
        |
        v
Server API layer
  HTTP / TCP / Unix socket / SSE or WebSocket
        |
        v
WireEnvelope
  protocol, schema_version, request_id, op, packet
        |
        v
Protocol::Interpreter
  descriptor import, fact IO, query, resolve, metadata, replay, sync
        |
        v
IgniterStore fact engine
```

The server should be a protocol host and durable projection host. It must not
become a contract-logic RPC server.

## Layers

### 1. Protocol Core

Already present in `Igniter::Store::Protocol::Interpreter`:

- `register_descriptor`
- `write`
- `write_fact`
- `read`
- `query`
- `resolve`
- `metadata_snapshot`
- `descriptor_snapshot`
- `replay`
- `sync_hub_profile`

This layer is in-process Ruby and owns protocol semantics.

### 2. Wire Envelope

Already present in `Igniter::Store::Protocol::WireEnvelope`:

```ruby
{
  protocol: :igniter_store,
  schema_version: 1,
  request_id: "req_123",
  op: :write_fact,
  packet: {
    kind: :fact,
    store: :tasks,
    key: "t1",
    value: { title: "Draft API" }
  }
}
```

Response:

```ruby
{
  protocol: :igniter_store,
  schema_version: 1,
  request_id: "req_123",
  status: :ok,
  result: { ... }
}
```

Errors should stay envelope-shaped:

```ruby
{
  protocol: :igniter_store,
  schema_version: 1,
  request_id: "req_123",
  status: :error,
  error: "Unknown or missing op: :teleport"
}
```

### 3. Server Transport

The next implementation layer should route transport requests into
`WireEnvelope#dispatch`.

Initial target:

```text
POST /v1/dispatch
```

This endpoint accepts one wire envelope and returns one wire envelope response.

Transport alternatives can share the same payload:

- HTTP JSON for human/debug/tool interoperability.
- TCP or Unix socket framed packets for local/server runtime.
- SSE or WebSocket for subscription delivery.

## Minimal HTTP Surface

The canonical surface should be small:

| Route | Purpose |
|-------|---------|
| `POST /v1/dispatch` | Canonical protocol operation endpoint. |
| `GET /v1/health` | Server liveness/readiness and protocol version. |
| `GET /v1/metadata` | Convenience wrapper for `metadata_snapshot`. |
| `POST /v1/sync/profile` | Convenience wrapper for `sync_hub_profile`. |
| `GET /v1/events` | SSE stream for fact/subscription events. |

Only `/v1/dispatch` is required for the first slice. The rest are convenience
or operational endpoints.

## Convenience Endpoints

Convenience REST endpoints may be useful later, but they should lower to
wire-envelope operations internally:

| Route | Lowers to |
|-------|-----------|
| `POST /v1/descriptors` | `op: :register_descriptor` |
| `POST /v1/facts` | `op: :write_fact` |
| `GET /v1/stores/:store/:key` | `op: :read` |
| `POST /v1/query` | `op: :query` |
| `POST /v1/resolve` | `op: :resolve` |
| `GET /v1/replay` | `op: :replay` |

These are adapters, not separate semantics. If a convenience endpoint cannot be
expressed as a wire op, it should not be added yet.

## StoreServer Integration

Current `StoreServer` already hosts durable facts and network replay/write
paths. The next server slice should add envelope dispatch without removing the
existing lower-level path.

Target shape:

```text
StoreServer
  owns: IgniterStore
  owns: Protocol::Interpreter
  owns: Protocol::WireEnvelope
  routes:
    legacy write_fact/replay/subscribe
    protocol dispatch envelope
```

This lets existing `NetworkBackend` tests remain valid while opening OP1-OP4 to
remote clients.

## Boundary Rules

- No contract node execution in the server.
- No Ruby DSL evaluation in the server.
- No materializer execution in the server.
- No SQL/ORM assumptions in protocol routes.
- No hidden migration or schema enforcement from descriptor registration.
- No public API stability promise before conformance tests exist.

The server may store descriptors, facts, receipts, snapshots, subscriptions,
and sync profiles. It may not decide business meaning.

## Security And Policy

Not first-slice requirements, but the API shape should leave room for:

- API token or mTLS authentication.
- Per-client producer metadata.
- Operation allowlists.
- Store-level read/write authorization.
- Rate limits for write/query/replay.
- Audit facts for accepted/rejected remote operations.

Security policy should wrap the dispatch layer, not fork protocol semantics.

## Observability

Minimum operational status:

```text
GET /v1/health
  -> protocol=:igniter_store
  -> schema_version=1
  -> status=:ready | :draining | :error
  -> backend=:memory | :file
  -> fact_count
  -> subscription_count
```

Future diagnostics can expose:

- protocol op counts
- rejection counts
- replay cursor
- compaction receipt count
- last checkpoint time
- active subscribers

## First Slice

Recommended slice: StoreServer envelope integration.

Aim:

```text
HTTP or framed request
  -> WireEnvelope#dispatch
  -> Protocol::Interpreter
  -> IgniterStore
  -> envelope response
```

Acceptance:

- `POST /v1/dispatch` accepts an OP3 envelope.
- `register_descriptor -> write -> read -> query -> resolve -> metadata_snapshot`
  works through the server boundary.
- `sync_hub_profile` works through the same boundary.
- Error responses remain envelope-shaped.
- Existing `write_fact`, `replay`, and `subscribe` server behavior still passes.
- Server does not evaluate contract logic.

Suggested smoke:

```text
1. register store descriptor :tasks
2. register relation descriptor :project_tasks
3. write task facts
4. read one task
5. query open tasks
6. resolve project_tasks
7. fetch metadata_snapshot
8. fetch sync_hub_profile
```

## Open Questions

- Should first transport be HTTP JSON, framed TCP/Unix, or both?
- Should `NetworkBackend` move to wire envelopes immediately or keep the legacy
  path until compatibility is proven?
- Should subscriptions use SSE first, or remain framed socket push?
- Should descriptor registration persist across server restart before the
  protocol API is called stable?
- Should sync profiles be generated on demand only, or also persisted as facts?

## Handoff

```text
[Architect Supervisor / Codex]
Track: igniter-store-server-api
Status: proposal drafted.
[D] Open Protocol is the semantic waist; server API is transport over it.
[R] Canonical first endpoint should be POST /v1/dispatch accepting WireEnvelope.
[R] Convenience REST endpoints must lower to protocol ops and add no semantics.
[R] StoreServer remains fact/projection host, not contract-logic RPC.
[S] OP1-OP4 are implemented in-process; next proof is server-boundary dispatch.
Next: implement StoreServer envelope integration with a protocol smoke.
```
