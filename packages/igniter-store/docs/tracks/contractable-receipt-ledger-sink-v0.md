# Track: Contractable Receipt Ledger Sink v0

Status date: 2026-05-04
Status: ready
Supervisor: [Architect Supervisor / Codex]
Agent: Package Agent / Companion+Store (pkg:companion-store)

## Goal

Close the loop opened by `igniter-embed/contractable-observation-receipts-v0`:
canonical contractable observation/event receipts should be easy to persist as
Ledger facts without adding Rails, ActiveRecord, Sidekiq, or `igniter-embed` as
hard dependencies to `igniter-store`.

Target flow:

```text
Igniter::Embed contractable runner
  -> store.record_observation(receipt)
  -> store.record_event(receipt)
  -> Igniter::Store ContractableReceiptSink
  -> observation record facts + event history facts
  -> query/replay/explain through Store/Ledger surfaces
```

This is the first reusable durable sink for Spark-style migration receipts.

## Read First

Use the compact fresh-chat route:

1. `packages/igniter-store/docs/package-agent-onboarding.md`
2. `packages/igniter-store/docs/progress.md`
3. `packages/igniter-embed/README.md` — Observation Receipts section only
4. `packages/igniter-embed/docs/tracks/contractable-observation-receipts-v0.md`
5. this track

Then inspect only implementation files needed for this slice.

## Context

The Embed slice now emits:

```ruby
receipt_kind: :contractable_observation
observation_id: "obs_..."
status: :ok | :diverged | :candidate_error | :acceptance_failed | :store_error | :unsampled
redaction: { input_policy:, output_policy:, classes: [] }
```

and event receipts:

```ruby
receipt_kind: :contractable_event
event_id: "evt_..."
observation_id: "obs_..."
event: :divergence | :primary_error | :candidate_error | ...
severity: :info | :warning | :error
```

`igniter-store` should persist these as ordinary facts. It should not know how
to run the primary/candidate service and should not import Embed internals.

## Scope A: Receipt Sink

Add a small adapter class under `igniter-store`, suggested name:

```ruby
Igniter::Store::ContractableReceiptSink
```

Constructor shape:

```ruby
sink = Igniter::Store::ContractableReceiptSink.new(
  store: Igniter::Store::IgniterStore.new,
  observations_store: :contractable_observations,
  events_store: :contractable_events,
  producer: { type: :embed, name: :contractable_receipt_sink }
)
```

Required hooks:

```ruby
sink.record_observation(receipt)
sink.record_event(receipt)
```

Behavior:

- `record_observation` writes a record-like fact keyed by
  `receipt[:observation_id]`.
- `record_event` appends or writes an event-like fact keyed by
  `receipt[:event_id]`.
- Missing required receipt fields raise a local validation error before writing.
- Store write errors should propagate to the caller; Embed already isolates
  store failures from primary responses.
- The class should expose the underlying store for tests/introspection.

## Scope B: Descriptor / Metadata Registration

If the current `IgniterStore`/Protocol surface can do this cleanly, register
descriptors for both receipt stores:

```text
contractable_observations
  shape: store
  key: observation_id
  fields: observation_id, name, role, stage, status, sampled, async,
          started_at, finished_at, duration_ms, redaction
  scopes: by_status, errors, divergences

contractable_events
  shape: history
  key: event_id
  partition_key: observation_id
  fields: event_id, observation_id, event, severity, summary, occurred_at
```

Do not invent a new manifest system. Use existing Store descriptor/protocol
helpers if they fit; otherwise keep descriptor registration internal and
document the gap.

## Scope C: Query Helpers

Add compact helper methods on the sink:

```ruby
sink.observation(observation_id)
sink.events_for(observation_id)
sink.observations(status: nil, limit: nil)
sink.error_events(limit: nil)
```

These helpers are for tests and early app integration. They should delegate to
normal Store reads/history/query paths rather than creating a side database.

## Scope D: Embed Integration Proof

Add a focused cross-package spec that wires:

```text
Igniter::Embed.contractable(...)
  store: ContractableReceiptSink.new(store: IgniterStore.new)
```

Acceptance:

- primary result is returned unchanged
- observation receipt is written to the observation store
- divergence/candidate/store error event receipts are written when emitted
- `events_for(observation_id)` replays events in commit order
- legacy Embed behavior remains green

Keep this dependency direction soft:

- Store may accept receipt hashes from Embed.
- Embed should not require Store.
- No Rails/ActiveRecord/Sidekiq dependencies.

## Scope E: Docs

Update:

- `packages/igniter-store/README.md` with a tiny receipt sink example.
- `packages/igniter-store/docs/README.md` track index.
- `packages/igniter-embed/README.md` only if a link to the durable sink helps.

## Acceptance

- `packages/igniter-store` targeted specs pass.
- `packages/igniter-embed` contractable specs still pass.
- Receipt sink validates required fields.
- Observation/event writes are inspectable as normal Store facts.
- Descriptor/metadata registration exists or the gap is documented explicitly.
- No hard dependency on Rails, ActiveRecord, Sidekiq, or Spark.
- No change to production primary response semantics in Embed.

## Non-Goals

- No Spark CRM code.
- No UI/admin receipt viewer.
- No Sidekiq adapter implementation.
- No remote mutating protocol for receipt cleanup.
- No deep PII/output redaction.
- No Store-to-Ledger rename.

## Risks / Watch Points

- Idempotency: retries may call `record_observation` or `record_event` more than
  once. Decide whether same ids should overwrite current state, create visible
  causation chains, or deduplicate. Document the decision.
- Event noise: Embed records `primary_success` too. The sink may store all
  events by default, but query helpers should make warnings/errors easy.
- Size: observation receipts can contain report details. Do not add automatic
  compression here; just keep the storage path compatible with future
  compaction/boundary work.
- Layering: keep this as a generic receipt-hash sink, not an Embed runner
  dependency.

## Handoff Format

```text
[Package Agent / Companion+Store]
Track: igniter-store/contractable-receipt-ledger-sink-v0
Status: done | partial | blocked

[D] Decisions:
- ...

[S] Shipped:
- ...

[T] Tests:
- ...

[R] Risks / next recommendations:
- ...
```
