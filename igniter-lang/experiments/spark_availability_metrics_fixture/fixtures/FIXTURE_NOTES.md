# Spark Availability Metrics Fixture Notes

Track: spark-availability-synthetic-fixture-creation-v0
Card: LANG-SPARK-P6-I
Date: 2026-05-20
Authority: fixture-design vocabulary / non-canon / non-implementation

---

## Fixture Contents

Two synthetic aggregate metrics-backed summary fixtures:

| File | `availability_bucket` | Description |
| --- | --- | --- |
| `spark_availability_slot_map_summary_available.json` | `available` | Agent has slots available; `dominant_unavailable_state` reflects minority state |
| `spark_availability_slot_map_summary_unavailable.json` | `unavailable` | Agent has no available slots; `dominant_unavailable_state` reflects majority blocking state |

---

## `receipt_kind` Is Fixture-Design Vocabulary, Not Lang Canon

**Important:** The field `receipt_kind` and its value `availability_slot_map_summary` are
fixture-design vocabulary only. They are not Igniter-Lang canon, not a stable schema term,
and not implementation authority.

Neither Spark nor Lang has promoted `receipt_kind` or `availability_slot_map_summary` to a
stable cross-lane schema term. Future canon decisions remain separate and require explicit
authorization.

Do not infer canonical status for `receipt_kind` from its presence in these fixtures.

---

## Sanitization Guarantees

These fixtures contain only synthetic aggregate data. They do not contain:

- Spark class names, metric names, or internal source names;
- raw slot arrays, slot boundaries, or time ranges;
- employee refs, technician refs, company ids, user or contact data;
- `observation_id`, `event_id`, input/output digests, or idempotency fields;
- `reason_counts` container (deferred to a future richer receipt route);
- production timestamps or real production values.

All numeric values are synthetic aggregate counts chosen for example clarity,
not extracted from or matching any production data.

---

## Deferred Fields (Absent by Design)

The following are explicitly absent and must not be added without separate authorization:

| Field / concept | Deferred until |
| --- | --- |
| `observation_id` | Dedicated observation receipt store / event protocol |
| `event_id` | Dedicated event receipt protocol |
| `input_digest` / `output_digest` | Compare/shadow/replay or richer receipt evidence |
| Idempotency policy / idempotency key | Metrics path is duplicate-tolerant; idempotency deferred |
| `reason_counts` | Richer dedicated observation receipt route |
| Raw `window_summary` | Separately authorized synthetic route |
| `scope_refs` | No raw refs in this route |

Deferred fields are absent, not null. Null-valued deferred fields would create
implicit schema pressure to fill them; absent fields do not.

---

## Error Summary Not Included

The metrics error summary (with `availability_bucket: "unknown"`) is held pending
one Spark-side confirmation that `unknown` is not a production state label that
carries Spark-internal semantic connotations. See LANG-SPARK-P5-X NB-1 and NB-2.

If confirmed synthetic, the error summary may be added in a follow-up fixture card.

---

## Authorized by

- LANG-SPARK-P3: availability fixture readiness report (design-only route opened)
- LANG-SPARK-P4-D: fixture design (`spark-availability-metrics-fixture-design-v0`)
- LANG-SPARK-P5-X: pressure review (`spark-availability-metrics-fixture-design-pressure-v0`, 7/7 PASS)
- LANG-SPARK-P6-I: this fixture creation card
