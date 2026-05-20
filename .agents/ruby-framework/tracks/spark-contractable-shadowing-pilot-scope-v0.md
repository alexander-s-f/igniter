# Spark Contractable Shadowing Pilot Scope v0

Card: S3-R87-C1-RF1
Agent: [Igniter Ruby Framework Supervisor]
Role: ruby-framework-supervisor
Track: spark-contractable-shadowing-pilot-scope-v0
Route: UPDATE
Status: proposed-design
Date: 2026-05-20

---

## Goal

Define the first bounded Spark CRM contractable observation/shadowing pilot for
Igniter Ruby framework adoption.

This document is design-only. It does not authorize Spark CRM code edits,
Igniter package code edits, production behavior changes, or Spark production
authority changes.

## Evidence Read

- `.agents/ruby-framework/current-status.md`
- `.agents/ruby-framework/spark-contractable-shadowing-adoption-plan-v0.md`
- `.agents/ruby-framework/cards/s3-r87-c1-rf1-spark-contractable-shadowing-pilot-scope-v0.md`
- `packages/igniter-contracts/README.md`
- `packages/igniter-embed/README.md`
- `packages/igniter-ledger/README.md`
- `packages/igniter-ledger-client/README.md`
- `igniter-lang/docs/gates/r86-spec-sync-and-spark-applicability-routing-decision-v0.md`
- `igniter-lang/docs/tracks/sparkcrm-igniter-adoption-readiness-map-v0.md`
- `/Users/alex/dev/projects/sparkcrm/docs/agents/spark-ledger-igniter-friendly-roadmap.md`
- `/Users/alex/dev/projects/sparkcrm/.agents/spark-app/letters/outgoing/2026-05-20-igniter-ruby-framework-spark-contractable-needs.md`

No private Spark CRM service code was inspected.

## Decision

Recommend `AvailabilityLedger`-style slot-map / why-not availability reasoning
as the first observed-service pilot target.

Keep `OrderPriceLedger`-style finder / chain-winner explanation as the second
pilot family after the observation receipt path is proven.

## Target Comparison

| Option | Strength | Risk | Verdict |
| --- | --- | --- | --- |
| Availability slot map / why-not reasons | Naturally explainable; can normalize to reason codes, counts, time windows, and scope refs; useful in primary-only mode before a candidate exists. | May touch scheduling-sensitive flows, so receipt capture must be fail-open and low-sample at first. | First target. |
| Order price finder / chain winner | High business value; strong fit for later primary/candidate comparison and chain explanation. | Numeric normalization, accepted divergence thresholds, and policy language need more care before receipts are meaningful. | Second target. |

## Primary Authority Statement

Spark primary service output remains authoritative.

The contractable wrapper may record a receipt, emit notifications, enqueue
durable persistence, and later run a candidate in shadow. It must return the
original primary result and must not change live scheduling, pricing, vendor,
customer, billing, telephony, webhook, or ledger authority.

## Minimal Rails-First API Shape

Use existing Ruby package surfaces as an adoption profile, not a new package API.

Illustrative primary-only shape:

```ruby
SparkAvailabilityObservation = Igniter::Embed.contractable(:availability_slot_map) do
  observe AvailabilitySlotMapPrimary
  shadow async: false, sample: 0.01
  use :normalizer, AvailabilitySlotMapNormalizer
  use :redaction, only: %i[request_ref company_ref service_area_ref trade_ref window_ref]
  use :store, SparkContractableReceiptStore

  on :observation, SparkContractableNotifications
  on :failure, SparkContractableNotifications
end
```

This is not an implementation directive. Spark can adapt naming, service
objects, and initializer layout locally.

## Observed-Service First Step

The first pilot should run in `observed_service` mode:

```text
Spark caller
  -> existing primary service
  -> same primary result returned
  -> redacted receipt generated
  -> receipt persistence enqueued or written fail-open
  -> admin/debug link by observation_id
```

Required properties:

- no candidate execution;
- no production result comparison;
- no source-of-truth changes;
- receipt capture failure does not fail the primary call;
- `observation_id` is generated for every sampled observation;
- unsampled calls may produce only minimal `:unsampled` receipts if Spark
  chooses to retain a sampling audit trail.

## Later Shadow Candidate Step

After observed-service receipts are accepted, Spark may design a candidate:

```text
primary existing service
  -> candidate availability explanation contract
  -> normalize both sides
  -> compare reason summaries and availability shape
  -> record :ok / :diverged / :candidate_error / :acceptance_failed
```

Candidate mode requires:

- explicit candidate callable boundary;
- primary and candidate normalizers;
- deterministic output shape;
- candidate timeout/error policy;
- acceptance policy;
- divergence taxonomy;
- manual review report;
- sampling gate.

## Receipt Contract

Use the Embed receipt vocabulary.

Observation receipt fields:

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

Event receipt fields:

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

Allowed statuses:

- `:ok`;
- `:diverged`;
- `:candidate_error`;
- `:acceptance_failed`;
- `:store_error`;
- `:unsampled`.

## Input Policy

Inputs in receipts must be redacted by construction.

Allowed input classes:

- stable synthetic or internal references such as `request_ref`,
  `company_ref`, `service_area_ref`, `trade_ref`, and `window_ref`;
- coarse time-window descriptors;
- small enum-like scope descriptors;
- input digest values.

Closed input classes:

- raw customer names, phone numbers, email addresses, addresses, notes, or
  provider payloads;
- credentials, tokens, webhook bodies, raw API requests, or session material;
- direct ActiveRecord object dumps;
- unbounded params hashes.

Digest policy:

- compute a deterministic `input_digest` over the redacted normalized input
  shape, not over raw request payloads;
- include `digest_version`;
- use the digest for correlation and idempotency hints only;
- do not treat digest equality as business equivalence without normalizer proof.

## Output Policy

Availability pilot output should prefer normalized summaries over raw objects.

Allowed primary output shape:

- `available_count`;
- `unavailable_count`;
- `reason_codes`;
- `reason_counts`;
- `window_summary`;
- `scope_refs`;
- `output_digest`;
- optional `explanation_summary`.

Closed output classes:

- raw provider/customer records;
- full slot payloads when they contain sensitive detail;
- private scheduling implementation structures;
- raw SQL/ActiveRecord attributes.

Digest policy:

- compute `output_digest` over normalized summary fields;
- include `output_digest_version`;
- keep human-readable reason summaries low-cardinality and redacted.

## Redaction Defaults

Default to allow-list redaction.

Recommended default:

```text
redaction.input_policy = :only
redaction.output_policy = :normalized_summary
raw_ref_export = false
```

Any future exception-based redaction should be treated as higher risk and
reviewed before pilot implementation.

## Store Adapter Protocol

Spark app-local store adapter should implement:

```ruby
record_observation(receipt)
record_event(receipt)
```

The adapter may persist to Spark-owned ActiveRecord tables, an outbox, or a
sidecar sink. It should not couple Spark callers to Ledger internals.

Behavior requirements:

- `record_observation` is idempotent by `observation_id`;
- `record_event` is append-only and linked by `observation_id`;
- duplicate event handling is explicit;
- store failure is captured as `:store_error` and primary output remains
  unchanged;
- admin lookup by `observation_id` is supported.

## Notifications

Spark should bridge Embed events into app-local instrumentation.

Recommended notification names:

```text
spark.contractable.primary_success
spark.contractable.primary_error
spark.contractable.candidate_success
spark.contractable.candidate_error
spark.contractable.divergence
spark.contractable.acceptance_failure
spark.contractable.store_error
spark.contractable.observation
```

Notification payload should include:

- `observation_id`;
- `name`;
- `role`;
- `stage`;
- `status`;
- `sampled`;
- `severity`;
- redacted metadata;
- no raw inputs or outputs.

These names are Spark-local integration guidance, not an Igniter package API
commitment.

## Async And Durable Persistence

Default pilot posture:

```text
very low sample + inline observation assembly + fail-open durable enqueue
```

Local Ruby thread async is acceptable only for framework proof or local smoke
work. It is not durable enough for production-adjacent Spark flow.

Before any broader rollout, Spark needs an app-owned durable adapter:

```text
contractable receipt
  -> outbox row or ActiveJob/Sidekiq job
  -> idempotency key: observation_id
  -> retry policy
  -> redacted payload only
  -> receipt sink
```

Durable enqueue failure must fail open for the primary service. The failure
should be visible through notification/logging and, when possible, a minimal
local error receipt.

## Missing Receipt And Store Error Behavior

Missing receipt behavior:

- primary result remains unchanged;
- caller does not receive a hard failure;
- operator-facing telemetry records receipt capture loss when possible;
- rollout metrics track receipt loss rate.

Store error behavior:

- contractable status becomes `:store_error` if an observation object exists;
- primary result remains unchanged;
- `store_error` is redacted and does not include raw payloads;
- repeated store errors should trip an operational alert, not a production
  behavior switch.

## Admin Lookup

Spark should expose an app-local admin/debug lookup by `observation_id`.

Minimum lookup fields:

- observation id;
- target name;
- status;
- mode;
- sampled flag;
- timestamps/duration;
- redacted input digest;
- normalized output digest;
- reason summary;
- event list;
- store error/candidate error summaries;
- optional sidecar pointer.

The lookup is read-only and diagnostic.

## Optional Igniter Ledger Sidecar Boundary

Igniter Ledger may be used as a sidecar receipt sink only.

Allowed:

- persist `contractable_observations`;
- append `contractable_events`;
- query by `observation_id`;
- inspect divergence/error receipts;
- use `Igniter::LedgerClient` as the protocol boundary.

Closed:

- Ledger as Spark source of truth;
- Ledger replay as production decision state;
- direct Spark business code dependency on Ledger internals;
- raw Spark data mirrored into Ledger.

## Proof / Parity Evidence Before Implementation

Before Spark implementation authorization:

- target selected and reviewed;
- redaction allow-list accepted;
- input and output digest versions named;
- normalizer contract specified;
- store adapter behavior specified;
- notification payload specified;
- sampling default selected;
- durable adapter requirement accepted;
- admin lookup fields accepted;
- missing receipt and store error behavior accepted;
- closed surfaces reaffirmed.

Before candidate shadow authorization:

- observed-service receipt quality reviewed;
- receipt loss rate acceptable;
- normalizer produces stable summaries;
- candidate boundary reviewed;
- acceptance policy reviewed;
- divergence taxonomy reviewed;
- candidate runtime/failure budget reviewed;
- manual review dashboard/report specified.

## Implementation Authorization Checklist

Implementation may proceed only after a separate card explicitly authorizes it.

Required checklist:

- [ ] Portfolio or owning supervisor accepts this design boundary.
- [ ] Spark App Supervisor selects the concrete service target.
- [ ] Spark App Supervisor approves redaction policy.
- [ ] Spark App Supervisor approves app-local store adapter shape.
- [ ] Durable enqueue strategy is selected for anything beyond tiny sampling.
- [ ] Admin/debug lookup route is scoped as read-only.
- [ ] Test/proof plan is named.
- [ ] Rollback/disable flag is named.
- [ ] No production authority change is included.

## Closed Surfaces

This design does not authorize:

- private Spark CRM code inspection;
- Spark CRM code edits;
- Igniter Ruby framework code edits;
- Spark production behavior changes;
- production authority switches;
- Ledger as source-of-truth database;
- raw customer/provider payloads, credentials, tokens, phone/email data,
  endpoint details, or infrastructure details in receipts or docs;
- high-volume receipt rollout before durable async handling exists;
- Igniter-Lang runtime execution of Spark decisions;
- public API/CLI/compiler widening;
- `.igapp` operational deployment.

## Recommended Next

Send this design to Spark App Supervisor as the Ruby Framework lane answer to
the Rails-first contractable observation needs letter.

Then open a separate implementation-scope card only if Spark confirms:

- concrete target;
- redaction allow-list;
- store adapter location;
- durable enqueue posture;
- admin lookup boundary.

