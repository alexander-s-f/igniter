# Track: Spark Availability Synthetic Fixture Creation v0

Card: LANG-SPARK-P6-I
Agent: `[Igniter-Lang Implementation Agent]`
Role: implementation-agent
Track: `spark-availability-synthetic-fixture-creation-v0`
Route: UPDATE
Status: done
Date: 2026-05-20
Authority: fixture-design vocabulary / non-canon / non-implementation

Authorized by:
- LANG-SPARK-P3 (availability fixture readiness — design-only route opened)
- LANG-SPARK-P4-D (`spark-availability-metrics-fixture-design-v0`)
- LANG-SPARK-P5-X (`spark-availability-metrics-fixture-design-pressure-v0`, 7/7 PASS)

---

## Goal

Create the first narrow sanitized synthetic Spark availability metrics fixture,
scoped to the two success-case summary shapes authorized by P4-D and confirmed
by P5-X.

---

## Inputs Read

- `docs/tracks/spark-availability-metrics-fixture-design-v0.md` (P4-D)
- `docs/discussions/spark-availability-metrics-fixture-design-pressure-v0.md` (P5-X)
- `docs/reports/port-2026-05-20-lang-spark-p3-availability-fixture-readiness.md` (P3)

---

## Changed Files

```text
experiments/spark_availability_metrics_fixture/
  fixtures/spark_availability_slot_map_summary_available.json     ← NEW
  fixtures/spark_availability_slot_map_summary_unavailable.json   ← NEW
  fixtures/FIXTURE_NOTES.md                                       ← NEW

docs/tracks/spark-availability-synthetic-fixture-creation-v0.md  ← NEW (this doc)
```

No other files changed. No specs, proposals, canon, compiler, runtime,
public API/CLI, loader/report, CompatibilityReport, assembler, `.igapp`, `.ilk`,
signing, dispatch, RuntimeMachine/Gate 3, Ledger/TBackend, BiHistory,
stream/OLAP, cache, or production surfaces modified.

---

## Fixture Summary

### Allowed Field Set

Exactly the 12 fields authorized by P4-D and confirmed clean by P5-X:

`status`, `receipt_kind`, `redaction_policy`, `availability_bucket`,
`dominant_unavailable_state`, `available_ratio`, `total_slots`,
`available_slots`, `scheduled_slots`, `off_schedule_slots`, `day_off_slots`,
`past_slots`.

### Available Summary

`fixtures/spark_availability_slot_map_summary_available.json`

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

Represents: agent with four slots in window; three available, one blocked by
day-off rule. Derived from SPARK-VOCAB-P3 recommended sanitized example.

### Unavailable Summary

`fixtures/spark_availability_slot_map_summary_unavailable.json`

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

Represents: agent with three slots, all past. Fully unavailable; no
available capacity for the requested window.

---

## Receipt-Kind Non-Canon Note

**`receipt_kind` is fixture-design vocabulary, not Igniter-Lang canon.**

The field `receipt_kind` and its value `availability_slot_map_summary` are
fixture-design candidates marked as candidates in both SPARK-VOCAB-P3 and P4-D.
Neither Spark nor Lang has promoted them to a stable cross-lane schema term.

Do not infer canonical status from fixture inclusion. Future canon decisions
require separate authorization.

This note appears in full in `fixtures/FIXTURE_NOTES.md` adjacent to the
fixture files.

---

## Sanitization Checklist

| Check | Result |
| --- | --- |
| No Spark class names, metric names, or internal source names | ✓ absent |
| No raw slot arrays, slot boundaries, or time ranges | ✓ absent |
| No employee refs, technician refs, company ids, user/contact data | ✓ absent |
| No `observation_id`, `event_id`, input/output digests | ✓ absent |
| No `reason_counts` container | ✓ absent |
| No idempotency fields | ✓ absent |
| No production timestamps or real production values | ✓ absent |
| `receipt_kind` non-canon note present in adjacent FIXTURE_NOTES.md | ✓ present |
| Error summary held (unknown state vocabulary unconfirmed) | ✓ not created |
| Fixtures scoped to P4-D authorized field set only | ✓ 12 fields only |

---

## Deferred Fields (Absent by Design)

| Field / concept | Deferred until |
| --- | --- |
| `observation_id` | Dedicated observation receipt store / event protocol |
| `event_id` | Same as `observation_id` |
| `input_digest` / `output_digest` | Compare/shadow/replay route |
| Idempotency policy | Metrics path is duplicate-tolerant; deferred |
| `reason_counts` | Richer dedicated observation receipt route |
| Raw `window_summary` | Separately authorized synthetic route |
| `scope_refs` | No raw refs in this route |
| Error summary / `unknown` state | Held pending Spark-side `unknown` vocabulary confirmation |

---

## Non-Authorizations Preserved

```text
spec_proposal_canon_changes:             false
compiler_runtime_changes:                false
public_api_cli_changes:                  false
loader_report_changes:                   false
compatibility_report_changes:            false
assembler_igapp_ilk_changes:             false
signing_dispatch_changes:                false
runtime_machine_gate3_widening:          false
ledger_tbackend_binding:                 false
bihistory_live_execution:                false
stream_olap_production:                  false
cache_production_changes:                false
spark_code_inspection_or_edits:          false
ruby_framework_generalization:           false
igniter_ledger_sidecar:                  false
error_summary_fixture:                   false (held — unknown vocabulary unconfirmed)
receipt_kind_canon_promotion:            false
```

---

## Remaining Blockers

1. **Error summary fixture**: held until one Spark-side confirmation that
   `unknown` is not a production state label (P5-X NB-1). If confirmed safe,
   a follow-up fixture card may add the error summary.

2. **`receipt_kind` / `available_ratio` canon promotion**: requires separate
   cross-lane authorization if either term is to become a stable Igniter-Lang
   schema term.

3. **Richer receipt fixtures** (`observation_id`, `event_id`, digests, idempotency,
   `reason_counts`): require a separate receipt-store/event-protocol route with
   stable vocabulary from Spark.

---

## Handoff

```text
Card: LANG-SPARK-P6-I
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: spark-availability-synthetic-fixture-creation-v0
Status: done

[D]
- Created two success-case synthetic fixtures: available and unavailable summaries.
- Held error summary pending `unknown` vocabulary confirmation (P5-X NB-1/NB-2).
- Added FIXTURE_NOTES.md with receipt_kind non-canon note, sanitization
  guarantees, and deferred-field list.
- No spec/proposal/canon/compiler/runtime surfaces modified.

[S]
- Fixtures use available_ratio (not availability_ratio).
- 12 authorized fields only; deferred fields absent (not null).
- receipt_kind is fixture-design vocabulary, not canon.

[T]
- Sanitization checklist: 10/10 ✓.
- No runnable proof required (pure fixture data).

[R]
- Error summary may follow in a short follow-up card once unknown vocabulary
  is confirmed by Spark side.
- receipt_kind / available_ratio canon promotion requires separate authorization.
```
