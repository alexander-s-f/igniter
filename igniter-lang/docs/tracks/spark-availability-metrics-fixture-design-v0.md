# Spark Availability Metrics Fixture Design v0

Card: LANG-SPARK-P4-D
Agent: [Igniter-Lang Supervisor]
Role: igniter-lang-supervisor
Route: UPDATE
Track: spark-availability-metrics-fixture-design-v0
Status: done
Date: 2026-05-20
Authority: design-only / non-fixture / non-canon / non-implementation

---

## Goal

Open a design-only sanitized synthetic fixture route for Spark availability
metrics-backed aggregate receipt vocabulary.

This track designs candidate fixture shapes only. It creates no fixture files
and authorizes no spec, proposal, canon, compiler, runtime, Spark, Ruby, Ledger,
or production changes.

---

## Read Set

- `igniter-lang/docs/reports/port-2026-05-20-lang-spark-p3-availability-fixture-readiness.md`
- `/Users/alex/dev/projects/sparkcrm/.agents/spark-app/reports/PORT-2026-05-20-SPARK-VOCAB-P3.md`

Supporting prior context:

- `igniter-lang/docs/reports/port-2026-05-20-lang-spark-p2-availability-vocabulary-recheck.md`
- `igniter-lang/docs/org/indexes/spark-availability-receipt-vocabulary-intake-map-v0.md`
- `igniter-lang/docs/org/portfolio-guidance-log-v0.md`

---

## Design Verdict

Recommendation:

```text
proceed to pressure review before fixture creation
```

P4-D successfully opens the narrow design boundary for synthetic aggregate
metrics-backed examples.

Actual fixture file creation should remain held until a short pressure review
confirms no private Spark vocabulary leakage and accepts an exact fixture file
boundary.

---

## Fixture Surface

Allowed candidate fields for metrics-backed synthetic examples:

| Field | Status | Notes |
| --- | --- | --- |
| `status` | fixture-design candidate | Use `success` / `error` as aggregate metrics status values. |
| `receipt_kind` | fixture-design candidate | Use `availability_slot_map_summary` as synthetic aggregate receipt kind. |
| `redaction_policy` | fixture-design candidate | Use `availability_slot_map_summary_v1` as sanitized policy marker. |
| `availability_bucket` | fixture-design candidate | Use aggregate category values, not raw slot data. |
| `dominant_unavailable_state` | fixture-design candidate | Use aggregate state labels only. |
| `available_ratio` | fixture-design candidate | Adopt Spark P3 stable metrics term for this route. |
| `total_slots` | fixture-design candidate | Synthetic aggregate count only. |
| `available_slots` | fixture-design candidate | Synthetic aggregate count only. |
| `scheduled_slots` | fixture-design candidate | Synthetic aggregate count only. |
| `off_schedule_slots` | fixture-design candidate | Synthetic aggregate count only. |
| `day_off_slots` | fixture-design candidate | Synthetic aggregate count only. |
| `past_slots` | fixture-design candidate | Synthetic aggregate count only. |

Field stance:

```text
These are fixture-design candidates, not language canon.
They are allowed only in synthetic aggregate examples.
```

---

## Synthetic Example Shapes

These examples are design sketches only. They are not fixture files.

### Available Summary

```json
{
  "status": "success",
  "receipt_kind": "availability_slot_map_summary",
  "redaction_policy": "availability_slot_map_summary_v1",
  "availability_bucket": "available",
  "dominant_unavailable_state": "day_off",
  "available_ratio": 0.75,
  "total_slots": 4,
  "available_slots": 3,
  "scheduled_slots": 0,
  "off_schedule_slots": 0,
  "day_off_slots": 1,
  "past_slots": 0
}
```

### Unavailable Summary

```json
{
  "status": "success",
  "receipt_kind": "availability_slot_map_summary",
  "redaction_policy": "availability_slot_map_summary_v1",
  "availability_bucket": "unavailable",
  "dominant_unavailable_state": "past",
  "available_ratio": 0.0,
  "total_slots": 3,
  "available_slots": 0,
  "scheduled_slots": 0,
  "off_schedule_slots": 0,
  "day_off_slots": 0,
  "past_slots": 3
}
```

### Metrics Error Summary

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

Error example note:

```text
The error shape is a design candidate for aggregate metrics status only.
It does not model thrown primary errors, event receipts, or idempotent
observation records.
```

---

## Naming Decisions

Ratio term:

```text
Use `available_ratio` for this metrics-backed fixture design.
```

Reason:

- Spark VOCAB-P3 marks `available_ratio` stable for the deployed metrics path.
- `availability_ratio` remains a Ruby/Lang-facing alias candidate only.
- Do not include both names in the same synthetic metrics fixture.

Reason-count container:

```text
Do not use `reason_counts` in this metrics-backed design.
```

Reason:

- Spark P3 explicitly keeps flat slot count tags for the metrics path.
- `reason_counts` is deferred to a richer dedicated observation receipt route.

Service/source/metric names:

```text
Do not include Spark metric names, class names, observed service names, or
source names in public fixture payloads.
```

If future docs cite those names, cite them only as Spark-owned source evidence,
not as fixture vocabulary.

---

## Forbidden / Private Vocabulary

The following must not appear in public Lang fixture payloads for this route:

- Spark class names;
- Spark metric names;
- raw Spark ids;
- raw slot boundaries;
- raw slot arrays;
- employee refs;
- technician refs;
- customer, provider, company, user, contact, or endpoint data;
- credentials, tokens, infrastructure names, or internal URLs;
- per-technician Portfolio reporting fields;
- production timestamps or real production values;
- private source names as public vocabulary.

Allowed handling:

- use synthetic counts and categories;
- use aggregate bucket/state labels;
- use sanitized policy labels;
- keep all examples detached from production identity.

---

## Deferred Richer Receipt Fields

Do not include these in the metrics-backed fixture design:

| Field / concept | Disposition |
| --- | --- |
| `observation_id` | Deferred until dedicated observation receipt store/event protocol. |
| `event_id` | Deferred until dedicated event receipt protocol. |
| `input_digest` | Deferred until compare/shadow/replay or richer receipt evidence. |
| `output_digest` | Deferred until compare/shadow/replay or richer receipt evidence. |
| `idempotency_key` / idempotency policy | Deferred; metrics path is duplicate-tolerant counters, not idempotent records. |
| `reason_counts` | Deferred; use flat slot counts for current metrics-backed examples. |
| raw `window_summary` | Deferred/forbidden unless fully synthetic and separately authorized. |
| `scope_refs` | Deferred; no raw refs or private ids in this route. |

---

## Future Fixture File Boundary

This card does not create fixture files.

If a later authorization opens fixture creation, the fixture card should define
an exact file boundary before editing. Candidate future locations may include a
dedicated docs fixture directory or a track-local fixture appendix, but this
design does not choose or create either.

Minimum future creation rules:

- one small synthetic fixture set only;
- no production data;
- no Spark class names or raw ids in payloads;
- fields limited to the allowed candidate set above;
- richer receipt fields explicitly absent or marked deferred in prose, not
  represented as nulls in fixture payloads;
- pressure review completed first.

---

## Recommended Next Route

Recommended next card:

```text
Card: LANG-SPARK-P5-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Track: spark-availability-metrics-fixture-design-pressure-v0
Route: UPDATE

Goal:
Pressure-test the P4 synthetic metrics fixture design for private vocabulary
leakage, accidental canon/spec implications, and premature fixture creation
authority.

Scope:
- Read `spark-availability-metrics-fixture-design-v0`.
- Read Lang P3 report and Spark VOCAB-P3.
- Confirm no raw Spark ids/classes/private data appear as public Lang
  vocabulary.
- Confirm deferred richer receipt fields remain deferred.
- Confirm exact next route should be fixture creation, hold, or follow-up.
- Do not create fixture files.
- Do not edit specs/proposals/canon/compiler/runtime code.

Deliver:
- pressure review in `igniter-lang/docs/discussions/`
- PASS/HOLD recommendation
- exact next allowed route boundary
```

If pressure passes, the likely next route can be a narrow fixture-creation
authorization request. If pressure finds leakage or ambiguity, hold and ask
Spark/Ruby follow-up.

---

## Blockers Before Fixture Creation

Remaining blockers:

- pressure review of this design;
- exact fixture file path and write scope;
- decision on whether to include the metrics error summary or hold to success
  examples only;
- confirmation that `unknown` is acceptable only as synthetic error-category
  vocabulary, not Spark production vocabulary;
- final review that `available_ratio` does not conflict with any Lang-facing
  alias policy;
- separate authorization for fixture file creation.

Blockers before richer receipt fixture work remain unchanged:

- stable `observation_id` / `event_id`;
- input/output digest envelopes;
- idempotency policy;
- `reason_counts` payload container;
- dedicated receipt/event store or protocol evidence.

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
- treating Spark metric names, class names, raw ids, private fields, or
  production values as public Igniter-Lang vocabulary;
- treating this design as canon, implementation authority, production
  authority, or fixture creation authorization.

---

## Handoff

```text
[Igniter-Lang Supervisor]
Track: spark-availability-metrics-fixture-design-v0
Status: done
Card: LANG-SPARK-P4-D

[D]
- Opened design-only sanitized synthetic fixture route.
- Defined allowed metrics-backed aggregate field set.
- Drafted three synthetic design examples: available, unavailable, error.
- Kept Spark-owned names out of public fixture payloads.

[S]
- Use `available_ratio` for this metrics-backed design.
- Keep `reason_counts`, observation/event ids, digests, and idempotency deferred.
- No fixture files were created.

[T]
- Docs-only route; no tests run.

[R]
- Run `spark-availability-metrics-fixture-design-pressure-v0` next.
- Fixture creation remains held until pressure and separate authorization.
```

