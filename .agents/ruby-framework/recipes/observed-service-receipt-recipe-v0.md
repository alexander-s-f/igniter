# Ruby Framework Observed-Service Receipt Recipe v0

Status: active recipe
Date: 2026-05-20
Card: PORT-2026-05-20-RUBY-P2
Guidance: PG-2026-05-20-01
Audience: Spark app-local pilot implementers and Ruby Framework reviewers.

## Purpose

Use this recipe when a host app wants to wrap one existing Ruby service as an
observed service and persist redacted receipts without changing primary
business behavior.

This is the approved shape for the first Spark pilot:

- primary-only observation;
- redacted aggregate receipts;
- app-local persistence;
- fail-open receipt capture;
- no shadow candidate;
- no Ledger sidecar as source of truth;
- no new Ruby package generalization.

## Primary-Only Wrapper

The host app keeps the existing service as authority and wraps it with
`Igniter::Embed.contractable`:

```ruby
SparkAvailabilityObserver = Igniter::Embed.contractable(:availability_slot_map) do
  observe SparkPrimaryService
  shadow async: false, sample: sample_rate
  use :normalizer, SparkAvailabilitySummaryNormalizer
  use :redaction, only: %i[request_ref company_ref service_area_ref trade_ref window_ref]
  use :store, SparkReceiptStore

  on :observation, SparkReceiptNotifications
  on :failure, SparkReceiptNotifications
end
```

Required invariants:

- the wrapper returns the primary service result unchanged;
- the primary service remains the only business authority;
- the candidate callable is absent;
- comparison fields stay empty;
- receipt write failure does not fail the primary flow.

## Normalizer Hook

The normalizer converts the primary result into an aggregate receipt payload.
It should not expose raw slot maps, customer payloads, provider payloads, tokens,
or private schedule rows.

Recommended availability output vocabulary:

```text
available_count
unavailable_count
availability_ratio
availability_bucket
dominant_unavailable_state
reason_codes
reason_counts
window_summary
scope_refs
input_digest
output_digest
```

The hook should return:

```ruby
{
  status: :ok,
  outputs: {
    available_count: 4,
    unavailable_count: 2,
    reason_codes: %i[outside_hours capacity_held],
    reason_counts: { outside_hours: 1, capacity_held: 1 },
    window_summary: { window_ref: "window_2026_05_20_pm" },
    scope_refs: {
      company_ref: "company_demo",
      service_area_ref: "area_demo",
      trade_ref: "trade_demo"
    },
    input_digest: "...",
    output_digest: "..."
  },
  metadata: {
    normalizer: :availability_slot_map_v0
  }
}
```

## Redaction Hook

Use an allow-list, not a deny-list. The first Spark pilot should allow only
stable refs and digests that are already safe for admin/debug receipt lookup.

Minimum allow-list:

```text
request_ref
company_ref
service_area_ref
trade_ref
window_ref
input_digest
output_digest
```

Closed until a later review:

- raw slot payloads;
- customer, employee, or provider personal data;
- internal scheduling row payloads;
- auth/session/request headers;
- free-form exception payloads that may include private input.

## Store Adapter Protocol

The store adapter is app-local. It can write to a dedicated receipt table, an
outbox, a metrics-backed proof table, or an optional Ledger sink, but the host
app owns the persistence decision.

Minimum protocol:

```ruby
class SparkReceiptStore
  def record_observation(receipt)
    # Persist one observation receipt.
  end

  def record_event(receipt)
    # Persist one event receipt.
  end
end
```

Recommended store behavior:

- append-only receipt writes;
- idempotent or safely duplicate-tolerant by `observation_id` / `event_id`;
- read-only admin lookup by `observation_id`;
- no source-of-truth coupling to business decisions;
- observable write failures through logs, metrics, or admin events.

## Fail-Open Behavior

Receipt capture must be fail-open:

- primary success remains success if receipt persistence fails;
- primary error is re-raised as before;
- store failure is represented in receipt state when possible;
- a `:failure` event should be emitted for primary errors or receipt pipeline
  failures;
- alerting can happen through Spark app-local notifications, not through a new
  package-level adapter.

For the current Embed surface, primary errors are recorded as event receipts
with `event: :primary_error`; the original primary exception is re-raised.

## Observation Receipt Shape

Ruby supports this minimal observation receipt shape now:

```text
schema_version
receipt_kind: :contractable_observation
observation_id
name
role: :observed_service
stage
mode: :observe
async
sampled
status
started_at
finished_at
duration_ms
inputs
primary
candidate: nil
report: nil
match: nil
accepted: nil
acceptance: nil
error
store_error
metadata
redaction
```

Primary payload:

```text
status
outputs
metadata
error
```

Required observation statuses:

```text
:ok
:store_error
:unsampled
```

## Event Receipt Shape

Ruby supports this minimal event receipt shape now:

```text
schema_version
receipt_kind: :contractable_event
event_id
observation_id
event
name
occurred_at
severity
summary
observation_ref
metadata
```

Recommended first-pilot events:

```text
:observation_recorded
:store_error
:primary_error
:receipt_lookup
```

## Spark App-Local Boundary

For the first Spark pilot, Spark owns:

- selected service target;
- feature flag and sample rate;
- normalizer implementation;
- redaction allow-list;
- receipt persistence;
- admin/MCP lookup surface;
- monitoring and alerting;
- fixture sanitization.

Ruby Framework owns:

- current `Igniter::Embed.contractable` surface;
- receipt shape guidance;
- example proof app maintenance;
- package release-readiness evidence.

The first pilot should prove one persisted redacted receipt path end-to-end in
Spark before any broad Ruby package API is introduced.

## Closed Before Package Generalization

Do not open these items for the first pilot:

- shadow candidate implementation;
- package-level Spark adapter;
- Rails adoption kit API;
- package-owned ActiveJob or Sidekiq adapter;
- mandatory Ledger sidecar;
- Ledger sidecar as business source of truth;
- public fixture export with raw availability payloads;
- generalized receipt schema migration API.

## Pilot Proof Checklist

Before recommending a Spark pilot beyond local/admin proof:

- exact Spark service target is named;
- sample rate and feature flag are defined;
- redaction allow-list is reviewed;
- normalizer output contains aggregates only;
- one persisted redacted observation receipt exists;
- one event receipt exists for lookup or failure behavior;
- admin/MCP lookup is read-only and scoped by `observation_id`;
- store failure is demonstrated fail-open;
- Ruby proof app still passes against current gems.

References:

- `.agents/ruby-framework/reports/port-2026-05-20-ruby-p1-minimal-receipt-shape.md`
- `.agents/ruby-framework/reports/ruby-framework-rails-contracts-ledger-proof-round-v0.md`
- `examples/rails_contracts_ledger/README.md`
