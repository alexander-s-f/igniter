# igniter-ledger-client

Protocol-first client package for Igniter Ledger / Store Open Protocol.

Status: pre-v1 skeleton. This package owns the client boundary, not the storage
engine.

## Purpose

`igniter-ledger-client` is the shared client layer for packages and host apps
that need to talk to a Ledger/Store endpoint without depending on
`igniter-store` internals.

```text
Embed / Companion / Web / MCP / Spark adapters
  -> Igniter::LedgerClient
  -> Store Open Protocol envelope
  -> local dispatch | remote HTTP | future TCP/pool/outbox transport
```

The package deliberately has no runtime dependency on `igniter-store`.

## Owns

- request/response envelope helpers
- client error semantics
- stable Ruby method surface for common Ledger operations
- transport adapters such as object dispatch and remote HTTP
- future pooling, timeout, retry, and backpressure policy seams

## Does Not Own

- fact storage engine
- WAL, segments, compaction, or changefeed internals
- contract execution
- Rails, Sidekiq, ActiveRecord, or Spark-specific code
- Store-to-Ledger package rename

## Example

```ruby
require "igniter-ledger-client"

client = Igniter::LedgerClient.remote_http(
  "http://127.0.0.1:7300/v1/dispatch",
  open_timeout: 1.0,
  read_timeout: 2.0
)

client.write(
  store: :orders,
  key: "order-1",
  value: { status: :open },
  producer: { type: :app, name: :spark }
)

client.read(store: :orders, key: "order-1")
```

For local/integration tests, wrap any object exposing `dispatch(envelope)` or
`wire.dispatch(envelope)`:

```ruby
client = Igniter::LedgerClient.wrap(protocol_interpreter.wire)
client.metadata_snapshot
```

## v0 Surface

```ruby
client.register_descriptor(...)
client.write(store:, key:, value:, **metadata)
client.append(history:, event:, key: nil, partition_key: nil, **metadata)
client.read(store:, key:, as_of: nil)
client.query(store:, where:, limit: nil, as_of: nil, order: nil)
client.replay(store: nil, from: nil, to: nil, filter: nil)
client.resolve(relation:, from:, as_of: nil)
client.metadata_snapshot
client.descriptor_snapshot
client.observability_snapshot
client.compaction_activity(store: nil, kind: nil, since: nil, limit: nil)
client.close
```

`append` currently lowers to the Store Open Protocol `write` op because the
server protocol does not yet expose a distinct append operation. That gap should
be closed in the next protocol slice before high-volume history clients depend
on it.

## Error Policy

The client raises `Igniter::LedgerClient::Error` for protocol error envelopes
and `Igniter::LedgerClient::TransportError` for transport failures. Successful
calls return the protocol `result` payload directly.

## Package Boundary

`igniter-embed` should not own Store connections, pools, retries, or
backpressure. Embed emits receipts to an adapter protocol. The adapter can then
use `igniter-ledger-client` to deliver those receipts locally, remotely, or
through a host outbox.
