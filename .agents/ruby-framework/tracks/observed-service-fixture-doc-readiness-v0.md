# Observed-Service Fixture Doc Readiness v0

Status: evaluated
Date: 2026-05-20
Card: RUBY-FIXTURE-P1
Route: UPDATE
Track: observed-service-fixture-doc-readiness-v0
Guidance: PG-2026-05-20-01

## Purpose

Evaluate whether the Lang Spark availability fixtures are sufficient input for
a future `igniter-embed` observed-service docs sync.

This note does not edit package docs, generalize Ruby API, add package code,
publish gems, or open shadow candidate implementation.

## Read Set

- `igniter-lang/docs/reports/port-2026-05-20-lang-spark-p3-availability-fixture-readiness.md`
- `igniter-lang/docs/tracks/spark-availability-metrics-fixture-design-v0.md`
- `igniter-lang/docs/tracks/spark-availability-synthetic-fixture-creation-v0.md`
- `igniter-lang/experiments/spark_availability_metrics_fixture/fixtures/FIXTURE_NOTES.md`
- `igniter-lang/experiments/spark_availability_metrics_fixture/fixtures/spark_availability_slot_map_summary_available.json`
- `igniter-lang/experiments/spark_availability_metrics_fixture/fixtures/spark_availability_slot_map_summary_unavailable.json`
- `.agents/ruby-framework/recipes/observed-service-receipt-recipe-v0.md`
- `.agents/ruby-framework/tracks/observed-service-recipe-package-doc-sync-v0.md`

## Readiness Verdict

```text
docs sync can open after Spark feedback, but only as a narrow package-doc sync
```

The Lang fixtures are sufficient input for one part of future
`igniter-embed` docs:

```text
sanitized aggregate normalizer output examples
```

They are not sufficient input for a complete observed-service receipt docs sync:

```text
not observation receipts
not event receipts
not store adapter evidence
not idempotent receipt records
not public schema canon
```

Ruby can use the fixture shape as documentation pressure for the normalizer
payload inside `primary.outputs`, but must not present it as the canonical
`Igniter::Embed` receipt envelope.

## What The Lang Fixtures Prove

The fixtures prove that a public/shared example can use synthetic aggregate
availability data without private Spark vocabulary:

- `status`;
- `receipt_kind`;
- `redaction_policy`;
- `availability_bucket`;
- `dominant_unavailable_state`;
- `available_ratio`;
- `total_slots`;
- `available_slots`;
- `scheduled_slots`;
- `off_schedule_slots`;
- `day_off_slots`;
- `past_slots`.

They also prove that the examples intentionally exclude:

- Spark class names, metric names, and source names;
- raw slot arrays and slot boundaries;
- employee, technician, customer, provider, company, user, or contact data;
- `observation_id`;
- `event_id`;
- `input_digest` / `output_digest`;
- idempotency fields;
- `reason_counts`;
- raw `window_summary`;
- `scope_refs`.

## Fit With Ruby Observed-Service Recipe

The fixtures fit this Ruby recipe area:

```text
normalizer aggregate output vocabulary
```

They do not fit these Ruby recipe areas yet:

```text
observation receipt envelope
event receipt envelope
record_observation / record_event persistence
fail-open store-error receipt evidence
read-only lookup by observation_id
idempotency / duplicate-tolerance by observation_id or event_id
```

Recommended Ruby interpretation:

```text
Lang fixture payload -> example primary.outputs summary only
Embed receipt envelope -> keep using contractable_observation /
  contractable_event shape from Ruby recipe
```

## Package-Doc Sync Opening Decision

Package-doc sync should not open immediately as a broad docs change.

It may open after Spark feedback as a narrow `igniter-embed` README/docs change
if the scope is limited to:

- primary-only observed-service wrapper;
- app-local normalizer;
- app-local redaction allow-list;
- app-local store adapter protocol;
- fail-open receipt capture;
- optional Ledger sink;
- one sanitized aggregate normalizer example adapted from Lang fixtures;
- explicit statement that the aggregate fixture is not the receipt envelope.

It must not include:

- new Ruby API;
- Spark adapter;
- Rails generator;
- durable queue/outbox API;
- shadow candidate implementation;
- public canon promotion for Lang fixture fields;
- claim that Spark has a dedicated observation/event receipt store.

## Exact Blockers Before Package-Doc Sync

1. Spark must confirm the Lang fixture values are acceptable as public-facing
   sanitized examples for package docs, not only Lang fixture-design material.

2. Spark/Ruby must settle the ratio wording for docs:

   ```text
   available_ratio  = Spark metrics fixture term
   availability_ratio = Ruby recipe candidate term
   ```

   The docs must either choose one term for the normalizer example or explicitly
   mark the other as an alias/translation. Do not include both in the same
   payload.

3. Ruby must prevent `receipt_kind` collision:

   - Embed receipt envelope uses `receipt_kind: :contractable_observation` or
     `:contractable_event`.
   - Lang fixture payload uses `receipt_kind: "availability_slot_map_summary"`
     as fixture-design vocabulary only.

   Package docs must not imply `availability_slot_map_summary` is an Embed
   receipt kind.

4. Spark must answer whether the error summary with
   `availability_bucket: "unknown"` is safe. Until then, package docs should
   include only the two success-case examples.

5. Spark must confirm whether the first docs sync should stay metrics-only or
   whether a dedicated persisted observation/event receipt pair is expected
   before public docs.

   Ruby recommendation: metrics-only examples are enough for a narrow normalizer
   example, but not enough for receipt-envelope examples.

6. Ruby must choose the docs mapping from flat Spark slot counts to any
   wrapper-level reason vocabulary:

   - keep flat counts exactly as fixture payload fields; or
   - show a Ruby normalizer that transforms them into `reason_codes` /
     `reason_counts`.

   Do not document both as required shapes.

7. Package docs must include an explicit "app-local" boundary:

   - Spark/host app owns target selection;
   - Spark/host app owns normalizer, redaction, persistence, lookup, rollout,
     and alerting;
   - Ledger is optional;
   - primary behavior remains authoritative.

8. Package docs must preserve deferred richer receipt fields:

   - `observation_id` / `event_id` in Spark fixtures;
   - input/output digests;
   - idempotency key/policy;
   - `reason_counts`;
   - raw `window_summary`;
   - `scope_refs`.

   These may appear in Ruby receipt recipe shape, but not as Spark fixture
   evidence.

## Recommended Next

Ask Spark for the short feedback packet above. If Spark confirms, Ruby can open
a narrow `package-doc sync` round focused on `igniter-embed` observed-service
docs.

Hold release-readiness review until after that docs sync. Continue to keep Ruby
API generalization closed.
