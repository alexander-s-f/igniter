# Track: Spark Technician Availability Fixture Pressure v0

Role: `[Igniter-Lang Applied Pressure Agent]`
Track: `igniter-lang/docs/tracks/spark-technician-availability-fixture-pressure-v0.md`
Status: done
Slice state: done on 2026-05-06
Affected neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`

## Frame

This track turns Spark CRM technician availability pressure into a concrete
fixture specification for `[Igniter-Lang Research Agent]`.

Safety boundary:

- synthetic IDs only;
- no real customers, tenants, employees, phones, addresses, endpoints, vendor
  payloads, tokens, secrets, or infrastructure details;
- fixture is business-logic pressure, not a Spark implementation.

## Source Horizon

- `igniter-lang/docs/tracks/spark-crm-applied-language-pressure-v0.md`
- `igniter-lang/docs/tracks/spark-crm-real-business-candidate-map-v0.md`
- `igniter-lang/source/availability_projection.ig`
- `igniter-lang/docs/tracks/temporal-lifecycle-boundary-fixtures-v0.md`

## Compact Claim

[D] The first Spark availability proof should be one technician, one company,
one local day, one requested window, and three blocking evidence kinds:

```text
ScheduleSlotObservation -> :busy
OffScheduleObservation  -> :off
DayOffConfigVersion     -> :day_off
no blocker              -> :available
```

[D] The proof must show that availability is not just a slot count. It is a
projection under tenant scope, timezone, rule version, schedule status, and
source observations.

## Fixture Identity

All IDs are synthetic and safe for public docs.

```text
fixture_id: spark_availability_minimal_v0
company_id: company/fixture-acme
technician_id: tech/t-17
employee_id: employee/e-17
date: 2026-05-06
weekday: wed
company_timezone: America/New_York
rule_version: availability_rules@1
schema_version: 0.1.0
slot_duration_minutes: 60
company_workday_local: 2026-05-06T08:00:00-04:00..2026-05-06T17:00:00-04:00
requested_window_local: 2026-05-06T09:00:00-04:00..2026-05-06T16:00:00-04:00
requested_window_utc: 2026-05-06T13:00:00Z..2026-05-06T20:00:00Z
as_of: 2026-05-06T12:30:00Z
```

Tenant scope:

```text
fact_scope:
  company_id: company/fixture-acme
  technician_id: tech/t-17
  stores:
    - technicians
    - schedules
    - off_schedules
    - day_off_configs
```

## Minimal Input Facts

### Company

```text
CompanyAvailabilityPolicy = {
  company_id: company/fixture-acme
  timezone: America/New_York
  beginning_of_day_hour: 8
  end_of_day_hour: 17
  slot_duration_minutes: 60
  boundary_mode: :strict
}
```

### Technician

```text
TechnicianProfile = {
  technician_id: tech/t-17
  employee_id: employee/e-17
  company_id: company/fixture-acme
  status: :active
  roles: [:technician]
  services: [service/appliance]
  zones: [zone/north]
}
```

### Day Off Config

```text
DayOffConfigVersion = {
  config_id: day_off_config/e-17/v1
  employee_id: employee/e-17
  technician_id: tech/t-17
  company_id: company/fixture-acme
  schema_version: 0.1.0
  effective_from: 2026-05-01
  rule_version: day_off_rules@1
  weekly_rules:
    wed: [14]
}
```

Interpretation: local 14:00..15:00 is blocked by recurring day-off policy.

### Schedule

```text
ScheduleSlotObservation = {
  schedule_id: schedule/t-17/2026-05-06/10
  company_id: company/fixture-acme
  technician_id: tech/t-17
  order_id: order/o-100
  start_at_local: 2026-05-06T10:00:00-04:00
  end_at_local: 2026-05-06T11:00:00-04:00
  status: :planned
  kind: :initial_order
}
```

Interpretation: local 10:00..11:00 is blocked by an active job.

### Off Schedule

```text
OffScheduleObservation = {
  off_schedule_id: off/t-17/2026-05-06/12
  company_id: company/fixture-acme
  technician_id: tech/t-17
  start_at_local: 2026-05-06T12:00:00-04:00
  end_at_local: 2026-05-06T13:00:00-04:00
  reason: :manual_block
  source: :dispatcher
}
```

Interpretation: local 12:00..13:00 is blocked by explicit off schedule.

## Expected Observations

### TechnicianProfile Observation

```text
obs_id: obs/technician_profile/t-17/asof-20260506T123000Z
kind: fact_observation
lifecycle: T.durable
payload: TechnicianProfile
temporal:
  as_of: 2026-05-06T12:30:00Z
  valid_time: 2026-05-06
links:
  - rel: :scoped_to
    ref: company/fixture-acme
```

### ScheduleSlotObservation

```text
obs_id: obs/schedule_slot/t-17/20260506-10/asof-20260506T123000Z
kind: fact_observation
lifecycle: T.durable
payload: ScheduleSlotObservation
temporal:
  as_of: 2026-05-06T12:30:00Z
links:
  - rel: :belongs_to
    ref: company/fixture-acme
  - rel: :blocks_slot
    ref: slot/t-17/20260506/10
```

### OffScheduleObservation

```text
obs_id: obs/off_schedule/t-17/20260506-12/asof-20260506T123000Z
kind: fact_observation
lifecycle: T.window
payload: OffScheduleObservation
temporal:
  as_of: 2026-05-06T12:30:00Z
links:
  - rel: :belongs_to
    ref: company/fixture-acme
  - rel: :blocks_slot
    ref: slot/t-17/20260506/12
```

### DayOffConfigVersion

```text
obs_id: obs/day_off_config/e-17/v1/asof-20260506T123000Z
kind: fact_observation
lifecycle: T.durable
payload: DayOffConfigVersion
temporal:
  as_of: 2026-05-06T12:30:00Z
links:
  - rel: :versioned_by
    ref: day_off_rules@1
  - rel: :blocks_slot
    ref: slot/t-17/20260506/14
```

### AvailabilityHorizon

```text
obs_id: obs/availability_horizon/t-17/20260506/asof-20260506T123000Z
kind: platform_observation
lifecycle: T.session
payload:
  projection_name: availability[technician, requested_window]
  mode: :reproducible
  as_of: 2026-05-06T12:30:00Z
  rule_version: availability_rules@1
  timezone: America/New_York
  requested_window_local: 2026-05-06T09:00:00-04:00..2026-05-06T16:00:00-04:00
  requested_window_utc: 2026-05-06T13:00:00Z..2026-05-06T20:00:00Z
  fact_scope:
    company_id: company/fixture-acme
    technician_id: tech/t-17
```

### AvailabilityProjection

```text
obs_id: obs/availability_projection/t-17/20260506/asof-20260506T123000Z
kind: value_observation
lifecycle: T.window
payload:
  technician_id: tech/t-17
  company_id: company/fixture-acme
  status: :available
  available_count: 4
  blocked_count: 3
  slots:
    - { hour: 9,  status: :available, why_not: [] }
    - { hour: 10, status: :busy,      why_not: [:busy] }
    - { hour: 11, status: :available, why_not: [] }
    - { hour: 12, status: :off,       why_not: [:off] }
    - { hour: 13, status: :available, why_not: [] }
    - { hour: 14, status: :day_off,   why_not: [:day_off] }
    - { hour: 15, status: :available, why_not: [] }
links:
  - rel: :computed_under
    ref: obs/availability_horizon/t-17/20260506/asof-20260506T123000Z
  - rel: :derived_from
    ref: obs/technician_profile/t-17/asof-20260506T123000Z
  - rel: :derived_from
    ref: obs/schedule_slot/t-17/20260506-10/asof-20260506T123000Z
  - rel: :derived_from
    ref: obs/off_schedule/t-17/20260506-12/asof-20260506T123000Z
  - rel: :derived_from
    ref: obs/day_off_config/e-17/v1/asof-20260506T123000Z
```

### AvailabilitySnapshot

```text
obs_id: obs/availability_snapshot/t-17/20260506/asof-20260506T123000Z
kind: snapshot_observation
lifecycle: T.compacted
payload:
  snapshot_id: availability_snapshot/t-17/20260506/requested-window/v1
  company_id: company/fixture-acme
  technician_id: tech/t-17
  requested_window_utc: 2026-05-06T13:00:00Z..2026-05-06T20:00:00Z
  status: :available
  available_count: 4
  blocked_count: 3
  reason_counts:
    busy: 1
    off: 1
    day_off: 1
    available: 4
  source_summary_hash: hash(technician + schedule + off_schedule + day_off + horizon)
links:
  - rel: :materializes
    ref: obs/availability_projection/t-17/20260506/asof-20260506T123000Z
  - rel: :computed_under
    ref: obs/availability_horizon/t-17/20260506/asof-20260506T123000Z
```

## Expected Result Table

| Local slot | UTC slot start | Expected status | Why-not reasons | Required evidence |
|------------|----------------|-----------------|-----------------|-------------------|
| 09:00 | 2026-05-06T13:00:00Z | `:available` | `[]` | horizon + technician profile |
| 10:00 | 2026-05-06T14:00:00Z | `:busy` | `[:busy]` | planned schedule observation |
| 11:00 | 2026-05-06T15:00:00Z | `:available` | `[]` | horizon + absence of blockers at `as_of` |
| 12:00 | 2026-05-06T16:00:00Z | `:off` | `[:off]` | off schedule observation |
| 13:00 | 2026-05-06T17:00:00Z | `:available` | `[]` | horizon + absence of blockers at `as_of` |
| 14:00 | 2026-05-06T18:00:00Z | `:day_off` | `[:day_off]` | day off config version |
| 15:00 | 2026-05-06T19:00:00Z | `:available` | `[]` | horizon + absence of blockers at `as_of` |

Expected projection summary:

```text
status: :available
available_count: 4
blocked_count: 3
why_not_reason_counts:
  busy: 1
  off: 1
  day_off: 1
  available: 4
meaning_status: :reproducible
```

## Why-Not Reason Rules

Reason priority for this fixture:

1. `:busy` when an active schedule overlaps the slot.
2. `:off` when an explicit off schedule overlaps the slot and no active
   schedule already explains it.
3. `:day_off` when the day-off config blocks the local hour and no schedule or
   off schedule already explains it.
4. `:available` when no blocker applies.

The fixture should preserve all applicable evidence links even when priority
selects one display status. For v0, no slot has overlapping blockers. A later
fixture can test multi-reason slots.

## Negative Cases

### N1: Missing Tenant Scope

Mutation:

```text
AvailabilityHorizon.fact_scope.company_id = nil
```

Expected:

```text
result: failure_observation
decision: :blocked
failure_kind: availability.tenant_scope_missing
must_not_emit: AvailabilitySnapshot
```

Reason: availability is not reproducible without `company_id` in fact scope.

### N2: Mixed Tenant Scope

Mutation:

```text
ScheduleSlotObservation.company_id = company/other
AvailabilityHorizon.fact_scope.company_id = company/fixture-acme
```

Expected:

```text
result: failure_observation
decision: :blocked
failure_kind: availability.tenant_scope_mismatch
offending_refs:
  - obs/schedule_slot/t-17/20260506-10/asof-20260506T123000Z
must_not_emit: AvailabilitySnapshot
```

Reason: a mixed-tenant blocker would make the projection unsafe to act on.

### N3: Timezone Drift

Mutation:

```text
CompanyAvailabilityPolicy.timezone = America/Chicago
AvailabilityHorizon.timezone = America/New_York
requested_window_utc remains 2026-05-06T13:00:00Z..2026-05-06T20:00:00Z
```

Expected:

```text
result: failure_observation
decision: :blocked
failure_kind: availability.timezone_drift
must_not_emit: trusted AvailabilitySnapshot
```

Reason: local slot identity and day-off weekday/hour semantics changed. A
future migration/timezone-equivalence receipt may downgrade this to
`:provisional`, but v0 blocks it.

### N4: Schedule Status Drift

Mutation:

```text
ScheduleSlotObservation.status = :canceled
source_summary_hash or expected result still assumes :planned busy slot
```

Expected:

```text
result: failure_observation
decision: :blocked
failure_kind: availability.schedule_status_evidence_mismatch
must_not_emit: trusted AvailabilitySnapshot
```

Reason: schedule status participates in availability meaning. A canceled
schedule should not block the slot, and a planned schedule should. If status
changes, the projection must be recomputed under a new observation or horizon.

## Research Agent Proof Request

Request: implement `spark-technician-availability-fixture-v0` as a research
fixture, not package code.

Minimum deliverables:

- fixture JSON or Ruby fixture data for the positive case and N1-N4;
- generated or hand-authored expected observation artifacts for the seven
  observation kinds listed above;
- a checker that verifies:
  - `available_count == 4`;
  - `blocked_count == 3`;
  - each blocked slot has the expected why-not reason;
  - every projection and snapshot has tenant scope;
  - missing/mixed tenant scope blocks snapshot emission;
  - timezone drift blocks trusted snapshot emission;
  - schedule status drift blocks stale/trusted snapshot emission;
- a README explaining how this fixture relates to
  `availability_projection.ig`.

Suggested path:

```text
igniter-lang/experiments/spark_technician_availability_fixture/
```

Acceptance for Research Agent:

- the fixture runs without Spark CRM;
- all IDs are synthetic;
- no secrets, endpoints, provider payloads, customer data, or infrastructure
  details appear in fixture artifacts;
- positive case emits `AvailabilityProjection` and `AvailabilitySnapshot`;
- negative cases emit failure observations and no trusted snapshot;
- output is suitable to become a parser/compiler/runtime acceptance target
  later.

## Handoff

[Igniter-Lang Applied Pressure Agent]
Track: igniter-lang/docs/tracks/spark-technician-availability-fixture-pressure-v0.md
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- The first Spark availability fixture is one technician, one company, one date, one requested window, one active schedule, one off schedule, and one day-off rule.
- Expected positive result is four available slots and three blocked slots: busy, off, and day_off.
- Missing tenant scope, mixed tenant scope, timezone drift, and schedule status drift are blocking negative cases in v0.

[R] Recommendations:
- Research Agent should implement this as `spark-technician-availability-fixture-v0` before expanding to multi-technician ranking.
- Compiler/Grammar Expert should use this fixture to decide tenant scope, timezone, and schedule-status evidence rules.
- Bridge Agent should later map the same observation names to metadata-only Spark diagnostics.

[S] Signals:
- `availability_projection.ig` is close enough to reuse conceptually, but the fixture needs richer typed inputs than current `ScheduleFact`.
- The smallest useful proof needs absence-of-blocker evidence for available slots, not only blocker evidence for busy/off/day_off slots.
- Timezone and tenant scope are not optional metadata; they are part of availability meaning.

[T] Tests / Proofs:
- Documentation-only fixture spec; no tests were run.

[Files] Changed:
- `igniter-lang/docs/tracks/spark-technician-availability-fixture-pressure-v0.md`
- `igniter-lang/docs/README.md`

[Q] Open Questions:
- Should `:available` be represented as an explicit why-not reason count or as absence of blockers only?
- Should timezone drift be blocked or provisional when UTC requested window is unchanged?
- Should schedule status drift compare source hashes, explicit status observations, or both?

[X] Rejected:
- No real Spark data.
- No endpoint, provider payload, token, secret, customer, tenant, or infrastructure details.
- No package/compiler/runtime implementation in this slice.

[Next] Proposed next slice:
- `[Igniter-Lang Research Agent]` `spark-technician-availability-fixture-v0`: implement the positive fixture and N1-N4 negative checker.
