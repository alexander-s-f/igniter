# Track: SparkCRM BiHistory Fixture Pressure v0

Role: `[Igniter-Lang Applied Pressure Agent]`
Track: `igniter-lang/docs/tracks/sparkcrm-bihistory-fixture-pressure-v0.md`
Status: done
Slice state: done on 2026-05-07
Affected neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`

## Frame

This track narrows `sparkcrm-history-pressure-v0` into one Research-Agent-ready
fixture: a synthetic bitemporal technician availability correction.

Safety boundary:

- synthetic SparkCRM-shaped facts only;
- no real Spark CRM data, customers, phones, emails, endpoints, provider
  payloads, credentials, tokens, queue names, or infrastructure details;
- no package adapter work.

Canonical temporal shape:

- use `bihistory_at(history, vt, tt) -> Option[T]`;
- use canonical `Option[T]` JSON:
  `{ "kind": "some", "value": V }` or `{ "kind": "none" }`;
- missing `vt` or `tt` is a typechecker/OOF failure, not runtime guesswork.

## Goal Fixture

Prove this single product truth:

```text
At dispatch time, technician t-17 looked busy for the requested window.
Later, a correction says that busy schedule was already canceled in valid time.

The corrected availability projection changes,
but the original dispatch decision remains explainable as "known then".
```

## Synthetic Scenario

Fixture identity:

```text
company_id: company/fixture-acme
technician_id: tech/t-17
service_date: 2026-05-07
timezone: America/New_York
requested_order_id: order/fixture-o-410
requested_window_local: 10:00..11:00
decision_tt: 2026-05-07T13:30:00Z
correction_tt: 2026-05-07T15:10:00Z
report_tt: 2026-05-07T15:20:00Z
```

Local slot mapping for the proof:

| Local slot | Valid-time point |
|------------|------------------|
| 09:00 | `2026-05-07T13:00:00Z` |
| 10:00 | `2026-05-07T14:00:00Z` |
| 11:00 | `2026-05-07T15:00:00Z` |
| 12:00 | `2026-05-07T16:00:00Z` |

[D] The fixture should avoid real timezone libraries in the first proof. Use
these explicit UTC valid-time points and keep `timezone` as metadata.

## Minimal Facts

### Technician Profile

Single bitemporal record, unchanged:

```json
{
  "history_ref": "bihistory/technician_profile/company-fixture-acme/tech-t-17",
  "type": "BiHistory[TechnicianProfile]",
  "events": [
    {
      "event_id": "hist/technician_profile/t-17/active/v1",
      "valid_from": "2026-05-07T00:00:00Z",
      "valid_until": "2026-05-08T00:00:00Z",
      "tx_from": "2026-05-07T12:00:00Z",
      "value": {
        "technician_id": "tech/t-17",
        "company_id": "company/fixture-acme",
        "status": "active",
        "timezone": "America/New_York"
      }
    }
  ]
}
```

### Schedule History

This is the correction heart of the fixture.

```json
{
  "history_ref": "bihistory/schedule/company-fixture-acme/tech-t-17/2026-05-07",
  "type": "BiHistory[ScheduleSlotObservation]",
  "events": [
    {
      "event_id": "hist/schedule/t-17/10/planned/as-known-1205",
      "valid_from": "2026-05-07T14:00:00Z",
      "valid_until": "2026-05-07T15:00:00Z",
      "tx_from": "2026-05-07T12:05:00Z",
      "value": {
        "slot_local": "10:00",
        "status": "planned",
        "order_ref": "order/existing-o-100",
        "blocks_availability": true
      }
    },
    {
      "event_id": "hist/schedule/t-17/10/canceled/correction-1510",
      "valid_from": "2026-05-07T14:00:00Z",
      "valid_until": "2026-05-07T15:00:00Z",
      "tx_from": "2026-05-07T15:10:00Z",
      "corrects_event_ref": "hist/schedule/t-17/10/planned/as-known-1205",
      "correction_reason": "synthetic_prior_cancellation_recorded_late",
      "value": {
        "slot_local": "10:00",
        "status": "canceled",
        "order_ref": "order/existing-o-100",
        "blocks_availability": false
      }
    }
  ]
}
```

### Off Schedule History

```json
{
  "history_ref": "bihistory/off_schedule/company-fixture-acme/tech-t-17/2026-05-07",
  "type": "BiHistory[OffScheduleObservation]",
  "events": [
    {
      "event_id": "hist/off_schedule/t-17/12/personal-block",
      "valid_from": "2026-05-07T16:00:00Z",
      "valid_until": "2026-05-07T17:00:00Z",
      "tx_from": "2026-05-07T11:55:00Z",
      "value": {
        "slot_local": "12:00",
        "reason": "personal_block",
        "blocks_availability": true
      }
    }
  ]
}
```

### Day Off Config History

Keep this present but non-blocking so the first proof has one policy/config
history without adding a second correction.

```json
{
  "history_ref": "bihistory/day_off_config/company-fixture-acme/tech-t-17",
  "type": "BiHistory[DayOffConfigVersion]",
  "events": [
    {
      "event_id": "hist/day_off_config/t-17/v1",
      "valid_from": "2026-05-07T00:00:00Z",
      "valid_until": "2026-05-08T00:00:00Z",
      "tx_from": "2026-05-07T00:00:00Z",
      "value": {
        "config_version": "day-off-config-synthetic-v1",
        "blocked_slots_local": []
      }
    }
  ]
}
```

## Minimal Contract Sketch

This is an implementation target sketch, not final syntax.

```text
contract SparkCRMBiHistoryAvailabilityCorrection {
  input company_id: String
  input technician_id: String
  input service_date: Date
  input decision_tt: DateTime
  input report_tt: DateTime

  escape bihistory_read

  read schedule_history: BiHistory[ScheduleSlotObservation]
    from "synthetic/sparkcrm/schedule_history"
    lifecycle :durable
    @bitemporal

  read off_schedule_history: BiHistory[OffScheduleObservation]
    from "synthetic/sparkcrm/off_schedule_history"
    lifecycle :durable
    @bitemporal

  read day_off_config_history: BiHistory[DayOffConfigVersion]
    from "synthetic/sparkcrm/day_off_config_history"
    lifecycle :audit
    @bitemporal

  compute decision_projection =
    project_availability_bitemporal(
      schedule_history,
      off_schedule_history,
      day_off_config_history,
      service_day_points,
      decision_tt
    )

  compute corrected_projection =
    project_availability_bitemporal(
      schedule_history,
      off_schedule_history,
      day_off_config_history,
      service_day_points,
      report_tt
    )

  output decision_snapshot: AvailabilitySnapshot lifecycle :audit
  output corrected_snapshot: AvailabilitySnapshot lifecycle :durable
  output correction_report: AvailabilityCorrectionReport lifecycle :audit
}
```

Proof-local helper:

```text
project_availability_bitemporal(histories, valid_time_points, tx_time)
  -> for each slot vt:
       schedule = bihistory_at(schedule_history, vt, tx_time)
       off      = bihistory_at(off_schedule_history, vt, tx_time)
       day_off  = bihistory_at(day_off_config_history, vt, tx_time)
       reason   = busy | off | day_off | available
       emit selected_event_refs and temporal coordinates
```

## Expected Outputs Before Correction

Run projection with:

```text
tx_time = decision_tt = 2026-05-07T13:30:00Z
```

Slot table:

| Slot local | Schedule at `(vt, decision_tt)` | Off at `(vt, decision_tt)` | Result | Reason |
|------------|----------------------------------|----------------------------|--------|--------|
| 09:00 | `{ "kind": "none" }` | `{ "kind": "none" }` | available | `available` |
| 10:00 | `{ "kind": "some", "value": { "status": "planned" } }` | `{ "kind": "none" }` | blocked | `busy` |
| 11:00 | `{ "kind": "none" }` | `{ "kind": "none" }` | available | `available` |
| 12:00 | `{ "kind": "none" }` | `{ "kind": "some", "value": { "reason": "personal_block" } }` | blocked | `off` |

Expected `decision_snapshot`:

```json
{
  "snapshot_id": "availability_snapshot/t-17/2026-05-07/as-known-1330",
  "company_id": "company/fixture-acme",
  "technician_id": "tech/t-17",
  "service_date": "2026-05-07",
  "known_time": "2026-05-07T13:30:00Z",
  "available_count": 2,
  "blocked_count": 2,
  "reason_counts": {
    "available": 2,
    "busy": 1,
    "off": 1,
    "day_off": 0
  },
  "requested_window": {
    "local": "10:00..11:00",
    "result": "blocked",
    "reason": "busy",
    "source_event_refs": [
      "hist/schedule/t-17/10/planned/as-known-1205"
    ]
  },
  "trust_status": "trusted"
}
```

Expected dispatch explanation:

```json
{
  "decision_ref": "dispatch_decision/order-fixture-o-410/t-17/as-known-1330",
  "candidate": "tech/t-17",
  "candidate_status": "not_selected",
  "reason": "busy",
  "known_time": "2026-05-07T13:30:00Z",
  "valid_time_window": "2026-05-07T14:00:00Z..2026-05-07T15:00:00Z",
  "snapshot_ref": "availability_snapshot/t-17/2026-05-07/as-known-1330",
  "evidence_refs": [
    "hist/schedule/t-17/10/planned/as-known-1205"
  ],
  "explanation_right": "preserved"
}
```

## Expected Outputs After Correction

Run projection with:

```text
tx_time = report_tt = 2026-05-07T15:20:00Z
```

Slot table:

| Slot local | Schedule at `(vt, report_tt)` | Off at `(vt, report_tt)` | Result | Reason |
|------------|--------------------------------|--------------------------|--------|--------|
| 09:00 | `{ "kind": "none" }` | `{ "kind": "none" }` | available | `available` |
| 10:00 | `{ "kind": "some", "value": { "status": "canceled" } }` | `{ "kind": "none" }` | available | `available` |
| 11:00 | `{ "kind": "none" }` | `{ "kind": "none" }` | available | `available` |
| 12:00 | `{ "kind": "none" }` | `{ "kind": "some", "value": { "reason": "personal_block" } }` | blocked | `off` |

Expected `corrected_snapshot`:

```json
{
  "snapshot_id": "availability_snapshot/t-17/2026-05-07/as-known-1520",
  "company_id": "company/fixture-acme",
  "technician_id": "tech/t-17",
  "service_date": "2026-05-07",
  "known_time": "2026-05-07T15:20:00Z",
  "available_count": 3,
  "blocked_count": 1,
  "reason_counts": {
    "available": 3,
    "busy": 0,
    "off": 1,
    "day_off": 0
  },
  "requested_window": {
    "local": "10:00..11:00",
    "result": "available",
    "reason": "available",
    "source_event_refs": [
      "hist/schedule/t-17/10/canceled/correction-1510"
    ]
  },
  "trust_status": "trusted"
}
```

Expected `correction_report`:

```json
{
  "report_id": "availability_correction/t-17/2026-05-07/1520",
  "prior_snapshot_ref": "availability_snapshot/t-17/2026-05-07/as-known-1330",
  "corrected_snapshot_ref": "availability_snapshot/t-17/2026-05-07/as-known-1520",
  "changed_slots": [
    {
      "slot_local": "10:00",
      "valid_time": "2026-05-07T14:00:00Z",
      "prior_known_time": "2026-05-07T13:30:00Z",
      "corrected_known_time": "2026-05-07T15:20:00Z",
      "prior_reason": "busy",
      "corrected_reason": "available",
      "prior_event_ref": "hist/schedule/t-17/10/planned/as-known-1205",
      "corrected_event_ref": "hist/schedule/t-17/10/canceled/correction-1510",
      "diagnostic": "availability.corrected_after_decision"
    }
  ],
  "original_decision_status": "still_explainable",
  "original_decision_rewritten": false
}
```

[D] The fixture must assert that the original dispatch explanation still points
to the planned schedule event known at `decision_tt`. The correction report is
new evidence; it must not mutate or replace the original decision snapshot.

## Diagnostics

Positive diagnostics:

```text
availability.corrected_after_decision
history.bitemporal_access_recorded
projection.original_snapshot_preserved
retention.explanation_right_preserved
```

Negative cases for the Research Agent fixture:

| Case | Input mutation | Expected diagnostic |
|------|----------------|---------------------|
| Missing `vt` | call `bihistory_at(schedule_history, tt: decision_tt)` | `OOF-BT2` / `history.valid_time_axis_missing` |
| Missing `tt` | call `bihistory_at(schedule_history, vt: slot_10)` | `OOF-BT3` / `history.transaction_time_axis_missing` |
| Wrong axis type | pass slot label `"10:00"` as `vt` instead of DateTime | `OOF-BT4` / `history.axis_type_mismatch` |
| Overwrite attempt | correction removes prior planned event instead of appending | `history.bitemporal_overwrite_attempt` |
| Snapshot rewrite | after correction, original snapshot reason changes from `busy` to `available` | `projection.original_snapshot_rewritten` |
| Early compaction | planned schedule raw event removed without evidence stub while decision cites it | `retention.explanation_right_lost` |

## Retention And Compaction

Explanation rights:

```text
DispatchDecisionExplanation
  -> decision_snapshot_ref
  -> selected bitemporal event refs
  -> selected vt/tt coordinates
  -> content hashes or compacted evidence stubs after retention
```

Must retain as `:audit`:

- `decision_snapshot`;
- dispatch explanation;
- correction report;
- selected bitemporal access observations;
- correction event and `corrects_event_ref`;
- compacted evidence stubs if raw schedule details are compacted.

May be `:durable`:

- current corrected availability snapshot;
- schedule/off_schedule/day_off history descriptors;
- non-selected daily availability summary.

May be compacted only after:

- both `decision_snapshot` and `correction_report` exist;
- each cited event has either raw detail or `CompactedHistoryEvidenceStub`;
- the stub preserves `event_id`, content hash, type, lifecycle, `vt`, `tt`,
  and redacted display fields;
- compatibility/resume can still answer why the technician was not selected
  at `decision_tt`.

Must block or downgrade:

- correction report with missing prior snapshot;
- decision explanation with unresolved selected event ref;
- corrected snapshot that overwrites original snapshot;
- compacted schedule history without evidence stub.

## Minimal Research Implementation Shape

Suggested directory:

```text
igniter-lang/experiments/sparkcrm_bihistory_fixture/
```

Suggested files:

```text
sparkcrm_bihistory_fixture.rb
golden/decision_snapshot.json
golden/corrected_snapshot.json
golden/correction_report.json
golden/negative_missing_vt.json
golden/negative_missing_tt.json
golden/negative_snapshot_rewrite.json
summary.json
```

Acceptance checklist:

```text
SPK-BH-1: Seeds synthetic BiHistory events for schedule, off_schedule,
          day_off_config, and technician profile.
SPK-BH-2: bihistory_at returns canonical Option[T] JSON.
SPK-BH-3: decision projection at decision_tt blocks 10:00 as busy.
SPK-BH-4: corrected projection at report_tt marks 10:00 available.
SPK-BH-5: correction_report links prior event and corrected event.
SPK-BH-6: original dispatch explanation remains unchanged and trusted.
SPK-BH-7: missing vt/tt negatives block with OOF-BT2/OOF-BT3.
SPK-BH-8: overwrite/rewrite/early-compaction negatives block or downgrade.
SPK-BH-9: safety scan proves no real Spark CRM data or provider payloads.
```

## Handoff

```text
[Igniter-Lang Applied Pressure Agent]
Track: igniter-lang/docs/tracks/sparkcrm-bihistory-fixture-pressure-v0.md
Status: done

[D] Decisions
- Shape the next proof as one bitemporal availability correction fixture.
- Use functional `bihistory_at(history, vt, tt)` and canonical Option[T]
  `{ kind:"some", value:V } | { kind:"none" }`.
- The corrected projection changes availability, but the original dispatch
  decision remains trusted because it is anchored to decision-time knowledge.

[S] Shipped / Signals
- Defined synthetic facts for technician profile, schedule correction,
  off_schedule, and day_off_config.
- Defined expected decision snapshot, corrected snapshot, correction report,
  diagnostics, and negative cases.
- Defined retention/compaction explanation rights for preserving old decisions
  after raw history detail is compacted.

[T] Tests / Proofs
- Documentation-only pressure slice; no executable tests run.

[R] Risks / Recommendations
- Research Agent should implement this as `sparkcrm_bihistory_fixture` with
  proof-local memory bitemporal stubs before parser/runtime generalization.
- Compiler/Grammar Expert should ensure `OOF-BT2`, `OOF-BT3`, and `OOF-BT4`
  are represented in the proof reports.
- Bridge Agent should prepare `CompactedHistoryEvidenceStub` and
  `AvailabilityCorrectionReport` metadata profiles after the fixture passes.

[Next] Suggested next slice
- Research Agent: implement `sparkcrm-bihistory-fixture-v0` executable proof
  with positive before/after correction outputs and negative axis/retention
  diagnostics.
```
