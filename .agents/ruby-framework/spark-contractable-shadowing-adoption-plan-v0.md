# Spark Contractable Shadowing Adoption Plan v0

Card: roadmap
Agent: [Igniter Ruby Framework Supervisor]
Role: ruby-framework-supervisor
Track: spark-contractable-shadowing-adoption-plan-v0
Route: INIT
Status: proposed
Date: 2026-05-20

---

## Goal

Prepare the Igniter Ruby package adoption path for Spark-compatible
contractable shadowing and receipt infrastructure, without implementing code in
Spark or Igniter during this INIT route.

The target is an incremental adoption shape:

```text
Spark primary service remains authoritative
  -> observed-service wrapper records redacted receipt
  -> optional candidate runs in shadow
  -> normalized outputs are compared
  -> observation/event receipts persist durably
  -> reports prove parity before authority changes
```

## Design Principles

1. Primary result stability is mandatory.

   Contractable wrappers may observe, normalize, compare, and emit receipts, but
   the synchronous Spark result must remain the existing primary result.

2. Start with observation before shadow.

   The first useful adoption step is primary-only observed-service mode. Shadow
   candidates should come only after the redaction, normalization, and durable
   receipt path are proven.

3. Receipts are evidence, not authority.

   Observation and event receipts support analytics, divergence review, replay,
   and promotion gates. They do not authorize execution, provider calls, Spark
   behavior changes, or Ledger authority.

4. Redaction is part of the contract.

   Receipt payloads must carry only approved identifiers, digests, enums,
   counters, and normalized business outcomes. Raw customer/provider payloads,
   credentials, phones, emails, and full request bodies stay closed.

5. Durable adapters gate rollout.

   Local thread async is acceptable for framework proof and tiny sampled pilots.
   Production-adjacent Spark volume requires a durable app adapter such as
   ActiveJob, Sidekiq, or an outbox-backed handoff.

6. Prefer client/protocol boundaries for persistence.

   Local `LedgerStore` is valid for package proof. Spark-facing adapters should
   be designed so `Igniter::LedgerClient` can replace local coupling.

## Existing Framework Surfaces To Reuse

### igniter-contracts

- Core `Igniter::Contracts::Contractable` service declaration.
- Declared `input`, `output`, `role`, `stage`, and `meta`.
- Normalized result protocol with `outputs`, `observations`, `error`,
  `metadata`, and success/failure status.
- Report-only Lang receipt payloads and redaction boundaries for future fixture
  pressure.

### igniter-embed

- Host-local `Igniter::Embed.contractable`.
- `observe` for primary-only observed services.
- `migrate ... to:` and `shadow` for primary/candidate comparison.
- Normalizer, redaction, acceptance, store, event, and capability attachment
  sugar.
- Observation receipts with `schema_version`, `receipt_kind`,
  `observation_id`, `status`, timing, inputs, primary/candidate payloads,
  differential report, acceptance, metadata, and redaction metadata.
- Event receipts with `event_id`, `observation_id`, event type, severity,
  summary, and optional observation reference.
- Async handoff descriptor carrying `observation_id`, redacted inputs,
  metadata, and queue time.

### igniter-ledger

- `ContractableReceiptSink` adapter for `record_observation` and `record_event`.
- Observation store descriptor keyed by `observation_id`.
- Event history descriptor partitioned by `observation_id`.
- Query helpers for current observations, events for an observation, filtered
  observations, and error events.

### igniter-ledger-client

- Protocol-first client facade for local object dispatch or remote HTTP.
- `wrap(ledger.protocol)` local adoption path.
- Package boundary guidance: adapters accept `client:` rather than reaching into
  Ledger internals.

## Spark Adoption Phases

### Phase 0 - Scope And Safety Contract

Define the first Spark pilot target without reading or editing private Spark
code unless separately authorized.

Deliverables:

- candidate target comparison;
- redaction policy;
- input/output digest policy;
- receipt shape;
- sampling gate;
- durable-adapter requirement;
- fail-open behavior;
- proof checklist;
- closed-surface list.

### Phase 1 - Observed-Service Pilot Design

Design a primary-only wrapper around the chosen Spark service.

Expected framework shape:

```ruby
Igniter::Embed.contractable(:spark_target_name) do
  observe ExistingSparkService
  shadow async: false, sample: 0.01
  use :normalizer, SparkTargetNormalizer
  use :redaction, only: %i[request_ref company_ref target_ref]
  use :store, SparkObservationStore
end
```

This is illustrative only; this roadmap does not authorize implementation.

### Phase 2 - Durable Receipt Adapter Design

Specify the Spark-owned store adapter that implements:

- `record_observation(receipt)`;
- `record_event(receipt)`;
- fail-open store errors;
- dedupe/idempotency expectations for observation retries;
- append-only event behavior;
- queue/outbox behavior for async handoff;
- optional delivery through `Igniter::LedgerClient`.

The first design may target Spark ActiveRecord tables. The replacement point
should remain compatible with `Igniter::Ledger::ContractableReceiptSink` and
`Igniter::LedgerClient`.

### Phase 3 - Shadow Candidate Pilot Design

Add a candidate only after Phase 1 and Phase 2 evidence is accepted.

Required additions:

- candidate callable boundary;
- primary and candidate normalizers;
- acceptance policy;
- divergence taxonomy;
- candidate error taxonomy;
- sampling and timeout policy;
- parity report fields;
- manual review loop.

### Phase 4 - Reporting And Promotion Gates

Define read-only reporting before any authority switch:

- match rate by target/scope;
- divergence count and reasons;
- candidate error count;
- acceptance failure count;
- store error count;
- unsampled rate;
- receipt lag/freshness;
- representative receipt links;
- redaction conformance evidence.

Promotion gates are advisory only in this roadmap.

## First Pilot Target Recommendation

Recommended first card should compare two R86-approved target candidates:

- Option A: AvailabilityLedger-style slot map for why-not availability reasons.
- Option B: OrderPriceLedger-style finder for chain-winner price explanation.

Initial recommendation: Option A as the first observed-service design target,
subject to confirmation in the next card.

Rationale:

- availability why-not reasons are naturally explainability-oriented;
- the output can likely be normalized into reason codes and counts rather than
  raw customer/provider data;
- primary-only observation can provide value before a candidate exists;
- divergence semantics can be introduced later as candidate availability logic
  matures.

Option B remains strong for a later shadow candidate because price chain
explanation is high-value, but it is more likely to require careful numeric
normalization and business acceptance rules before receipts become meaningful.

## Receipt Vocabulary v0

Observation receipt minimum:

- `schema_version`;
- `receipt_kind: :contractable_observation`;
- `observation_id`;
- `name`;
- `role`;
- `stage`;
- `mode`;
- `async`;
- `sampled`;
- `status`;
- `started_at`;
- `finished_at`;
- `duration_ms`;
- redacted `inputs`;
- normalized `primary`;
- optional normalized `candidate`;
- optional differential `report`;
- `match`;
- `accepted`;
- `acceptance`;
- `error`;
- `store_error`;
- `metadata`;
- `redaction`.

Event receipt minimum:

- `schema_version`;
- `receipt_kind: :contractable_event`;
- `event_id`;
- `observation_id`;
- `event`;
- `name`;
- `occurred_at`;
- `severity`;
- `summary`;
- optional `observation_ref`;
- `metadata`.

Allowed receipt statuses:

- `:ok`;
- `:diverged`;
- `:candidate_error`;
- `:acceptance_failed`;
- `:store_error`;
- `:unsampled`.

## Proof Required Before Implementation

- Target selected and bounded.
- Redaction policy reviewed.
- Receipt shape accepted.
- Normalizer contract specified.
- Missing-receipt and store-error behavior is fail-open.
- Sampling defaults are explicit.
- Async strategy is explicit.
- Durable adapter dependency is recorded before high-volume rollout.
- Optional Ledger sidecar boundary is read-only and client/protocol-oriented.
- No Spark production authority changes are included.

## Closed Surfaces

This roadmap does not authorize:

- code implementation;
- Spark CRM code inspection beyond already supplied docs;
- Spark CRM code edits;
- Igniter package code edits;
- production behavior changes;
- raw Spark data in receipts or docs;
- Ledger as primary Spark database;
- unsampled/high-volume production-adjacent receipt recording;
- `.igapp` policy deployment;
- Igniter-Lang runtime execution of Spark decisions.

## Next Card

Proceed with the design-only first card:

- `cards/s3-r87-c1-rf1-spark-contractable-shadowing-pilot-scope-v0.md`
