# Spark Availability Error Fixture Design v0

Card: LANG-SPARK-P7-D
Agent: [Igniter-Lang Supervisor]
Role: igniter-lang-supervisor
Route: UPDATE
Track: spark-availability-error-fixture-design-v0
Status: done
Date: 2026-05-20
Authority: design-only / non-fixture / non-canon / non-implementation

---

## Goal

Design, but do not create, an optional synthetic error fixture now that Spark
confirmed `unknown` is not a production state label.

This track creates no fixture files and authorizes no spec, proposal, canon,
compiler, runtime, Spark, Ruby, Ledger, or production changes.

---

## Read Set

- `igniter-lang/docs/tracks/spark-availability-metrics-fixture-design-v0.md`
- `igniter-lang/docs/discussions/spark-availability-metrics-fixture-design-pressure-v0.md`
- `igniter-lang/docs/tracks/spark-availability-synthetic-fixture-creation-v0.md`
- `/Users/alex/dev/projects/sparkcrm/.agents/spark-app/reports/PORT-2026-05-20-SPARK-FIXTURE-P1.md`

---

## Spark Confirmation

Spark confirmed:

```text
unknown_is_spark_production_state_label = no
```

Spark production SlotMap states are:

```text
available
scheduled
off_schedule
day_off
past
```

Spark production availability buckets are:

```text
available
unavailable
```

Current Spark error metrics emit:

```text
status = error
error_class = <class name>
```

They do not emit:

```text
availability_bucket = "unknown"
```

Lang interpretation:

```text
`unknown` may be used only as synthetic error-fixture vocabulary.
It must not be treated as Spark production state vocabulary or a production
success bucket/state label.
```

---

## Design Verdict

Recommendation:

```text
optional error fixture may be created later if separately authorized
```

The optional error fixture design is safe only with explicit labeling:

```text
unknown is a synthetic error-summary bucket/state for fixture pressure only.
Spark production success receipts do not emit this bucket/state.
```

No fixture is created by this design track.

---

## Optional Synthetic Error Shape

Candidate shape, design-only:

```json
{
  "status": "error",
  "receipt_kind": "availability_slot_map_summary",
  "redaction_policy": "availability_slot_map_summary_v1",
  "availability_bucket": "unknown",
  "dominant_unavailable_state": "unknown",
  "available_ratio": 0.0,
  "total_slots": 0,
  "available_slots": 0,
  "scheduled_slots": 0,
  "off_schedule_slots": 0,
  "day_off_slots": 0,
  "past_slots": 0
}
```

Required adjacent note if a later fixture file is created:

```text
This error summary is synthetic fixture pressure only. `unknown` is not a Spark
production slot state, not a Spark production success bucket, and not evidence
that Spark production availability receipts emit unknown availability states.
```

---

## `unknown` Vocabulary Boundary

Allowed:

- `availability_bucket: "unknown"` in an explicitly synthetic error fixture;
- `dominant_unavailable_state: "unknown"` in the same explicitly synthetic
  error fixture;
- prose explaining that unknown means "not modeled as a production
  availability bucket/state in this synthetic error summary."

Not allowed:

- treating `unknown` as a Spark production SlotMap state;
- treating `unknown` as a Spark production success `availability_bucket`;
- adding `unknown` to success-case fixtures;
- using `unknown` to imply raw Spark error payload semantics;
- using `unknown` to model `error_class`, stack traces, class names, exception
  messages, or private Spark internals;
- adding `unknown` to spec/proposal/canon vocabulary from this design.

---

## Fixture-Creation Boundary

This card does not create fixture files.

If a later card creates the optional error fixture, it must:

- edit only the exact fixture file boundary authorized by that later card;
- reuse the 12-field metrics-backed aggregate fixture field set;
- add the required `unknown` synthetic-only note adjacent to the fixture;
- avoid Spark class names, metric names, raw ids, raw slot payloads, production
  timestamps, customer/provider/technician/company/user/contact data, endpoints,
  credentials, tokens, and infrastructure details;
- keep `observation_id`, `event_id`, input/output digests, idempotency,
  `reason_counts`, raw `window_summary`, and `scope_refs` absent;
- preserve the existing success fixtures unchanged unless explicitly authorized.

---

## Recommended Next Route

Recommended next route:

```text
spark-availability-error-fixture-creation-v0
```

Route type:

```text
bounded fixture creation only
no spec/proposal/canon mutation
no compiler/runtime changes
```

Exact future boundary should be:

```text
Create one optional synthetic error fixture and update adjacent fixture notes
only. Do not edit success fixtures except to add cross-reference notes if
explicitly authorized.
```

If Portfolio/Lang wants to stay more conservative, hold the error fixture and
keep only the two current success fixtures.

---

## Closed Surfaces

This design does not authorize:

- fixture file creation;
- spec/proposal/canon updates;
- compiler/runtime edits;
- parser, classifier, TypeChecker, SemanticIR, assembler, `.igapp`, `.ilk`,
  signing, dispatch, RuntimeMachine/Gate 3, Ledger/TBackend, BiHistory,
  stream/OLAP, cache, or production widening;
- public API/CLI, loader/report, or CompatibilityReport changes;
- Spark CRM code inspection or edits from the Lang lane;
- Ruby Framework code edits or API generalization;
- Igniter Ledger sidecar implementation;
- treating `unknown` as Spark production state vocabulary;
- treating Spark metric names, class names, raw ids, private fields, or
  production values as public Igniter-Lang vocabulary;
- treating this design as canon, implementation authority, production
  authority, or fixture creation authorization.

---

## Handoff

```text
[Igniter-Lang Supervisor]
Track: spark-availability-error-fixture-design-v0
Status: done
Card: LANG-SPARK-P7-D

[D]
- Designed optional synthetic error fixture shape.
- Marked `unknown` as synthetic error-fixture vocabulary only.
- Preserved Spark confirmation that `unknown` is not a production state label.
- Created no fixture files.

[S]
- Error fixture may be created later only with adjacent synthetic-only note.
- Existing success fixtures remain the stable minimum set.
- Richer receipt fields remain deferred/absent.

[T]
- Docs-only route; no tests run.

[R]
- Optional next: `spark-availability-error-fixture-creation-v0`.
- Otherwise hold and keep only current success fixtures.
```

