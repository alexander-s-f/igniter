# igniter-store

Experimental contract-native store package for Igniter.

Status: POC package, not stable API, not wired into core.

## Owns

- immutable content-addressed facts
- append-only `Store[T]` and `History[T]` fact log experiments
- causation chains
- current and time-travel reads
- reactive cache invalidation
- compile-time access path registry experiments
- optional JSONL WAL replay

## Does Not Own

- contract DSL integration
- core graph node types
- SQL schema generation
- migration execution
- PostgreSQL sync hub implementation
- cluster consensus
- materializer execution

## Why `igniter-store`

This package is broader than persistence. The research direction includes
time-travel, reactive agents, access paths, hot/cold sync, retention, and future
cluster replay. `igniter-persistence` remains reserved for stable durable
capability APIs if they later emerge from this work.

## Example

```ruby
require "igniter-store"

store = Igniter::Store::IgniterStore.new

store.write(
  store: :reminders,
  key: "r1",
  value: { title: "Buy milk", status: :open }
)

store.read(store: :reminders, key: "r1")
```

Run the POC smoke:

```bash
ruby -I packages/igniter-store/lib packages/igniter-store/examples/store_poc.rb
```

Run package specs:

```bash
bundle exec rspec packages/igniter-store/spec
```

## Research Track

- [Contract-Native Store Research](../../docs/research/contract-native-store-research.md)
- [Contract-Native Store POC](../../docs/research/contract-native-store-poc.md)
- [Contract-Native Store Sync Hub](../../docs/research/contract-native-store-sync-hub.md)
- [Contract Persistence Development Track](../../docs/research/contract-persistence-development-track.md)
