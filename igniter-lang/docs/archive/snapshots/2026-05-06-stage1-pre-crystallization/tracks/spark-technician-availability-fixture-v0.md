# Track: Spark Technician Availability Fixture v0

Status: done
Slice state: done on 2026-05-06
Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/spark-technician-availability-fixture-v0`
Supervisor: `[Architect Supervisor / Codex]`
Neighbors: `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`
Artifacts:
- `igniter-lang/experiments/spark_technician_availability_fixture/spark_technician_availability_fixture.rb`
- `igniter-lang/docs/tracks/spark-technician-availability-fixture-pressure-v0.md`
- `igniter-lang/docs/tracks/spark-tenant-and-pipeline-formalization-v0.md`

---

## Frame

This slice turns the Spark technician availability pressure case into an
executable synthetic fixture.

Safety boundary:

- synthetic facts only
- no real Spark CRM data
- no endpoints, provider payloads, secrets, tokens, customers, phones, emails,
  credentials, or infrastructure details
- no package or real adapter code

---

## What The Fixture Models

Positive case:

```text
TenantScope
  -> AvailabilityHorizon
  -> ScopedFactRead[TechnicianProfile]
  -> ScopedFactRead[ScheduleSlotObservation]
  -> ScopedFactRead[OffScheduleObservation]
  -> ScopedFactRead[DayOffConfigVersion]
  -> AvailabilityProjection
  -> AvailabilitySnapshot
```

Pipeline discipline:

- one `StepObservation` for each executed pipeline step
- `PipelineTrace` records attempted steps and first failure
- failed steps halt the pipeline; downstream steps do not execute
- negative cases emit `failure_observation` and no trusted snapshot

Positive synthetic facts:

- one company: `company/fixture-acme`
- one technician: `tech/t-17`
- one local day: `2026-05-06`
- requested window: local `09:00..16:00`
- planned schedule block at `10:00`
- explicit off schedule at `12:00`
- day-off config block at `14:00`

Expected snapshot:

```text
status: available
available_count: 4
blocked_count: 3
reason_counts:
  available: 4
  busy: 1
  off: 1
  day_off: 1
```

Expected slot reasons:

```text
09 available []
10 busy      [busy]
11 available []
12 off       [off]
13 available []
14 day_off   [day_off]
15 available []
```

---

## Negative Cases

The executable proof covers:

- wrong tenant: `availability.tenant_scope_mismatch`
- invalid time window: `availability.invalid_time_window`
- inactive technician: `availability.inactive_technician`
- schedule status mismatch: `availability.schedule_status_evidence_mismatch`

All negative cases:

- emit `failure_observation`
- mark decision `blocked`
- emit a failing `StepObservation`
- emit no `AvailabilitySnapshot`

---

## Proof Output

```text
ruby igniter-lang/experiments/spark_technician_availability_fixture/spark_technician_availability_fixture.rb
```

Output:

```text
PASS spark_technician_availability_fixture
positive.pipeline_trace_ok: ok
positive.snapshot_counts: ok
positive.why_not_reasons: ok
positive.step_observations: ok
positive.scoped_fact_reads: ok
negative.wrong_tenant_blocked: ok
negative.invalid_time_window_blocked: ok
negative.inactive_technician_blocked: ok
negative.status_mismatch_blocked: ok
negative.no_trusted_snapshots: ok
safety.synthetic_only: ok
positive.snapshot: available available=4 blocked=3
positive.why_not: 9:available, 10:busy, 11:available, 12:off, 13:available, 14:day_off, 15:available
negative.failures: wrong_tenant=availability.tenant_scope_mismatch, invalid_time_window=availability.invalid_time_window, inactive_technician=availability.inactive_technician, status_mismatch=availability.schedule_status_evidence_mismatch
```

The proof also supports:

```text
ruby igniter-lang/experiments/spark_technician_availability_fixture/spark_technician_availability_fixture.rb --dump
```

to inspect the generated observation packets.

---

## Gap Report

### Compiler / Grammar

[Next] `spark-pipeline-grammar-v0` should define source syntax for:

- `pipeline` as sugar over `Result.flat_map`
- mandatory `StepObservation`
- `scoped_by` reads
- `TenantScope` as explicit value, not ambient state
- `CardinalityBound` on `ScopedFactRead`
- `AvailabilitySnapshot` as a materialized projection/snapshot form

[Q] The fixture currently treats available slots as absence of blockers plus
`reason_counts.available`. Compiler/Grammar should decide whether
`:available` is a first-class reason or only a derived count.

[Q] The proof blocks schedule status mismatch. Compiler/Grammar should decide
whether future status drift can become provisional with an equivalence receipt.

### Bridge

[Next] Bridge profile should map synthetic observation names to metadata-only
Spark diagnostics:

- tenant scope source
- scoped read subjects
- cardinality bounds
- slot reason counts
- source refs for busy/off/day_off
- failed step and failure kind

[Q] Bridge should define redaction policy for technician/user/company labels
before any package adapter emits real diagnostics.

---

## Boundaries

[X] Rejected: real Spark CRM reads, endpoints, credentials, provider payloads,
customer data, or package code.

[X] Rejected: ambient tenant context.

[X] Rejected: emitting a trusted snapshot from any negative case.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/spark-technician-availability-fixture-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Built a stdlib-only executable synthetic fixture.
- Positive case emits TenantScope, ScopedFactRead records,
  StepObservations, PipelineTrace, AvailabilityProjection, and
  AvailabilitySnapshot.
- Positive result is 4 available slots and 3 blocked slots.
- Negative wrong tenant, invalid time window, inactive technician, and
  schedule status mismatch all block and emit no trusted snapshot.
- Fixture uses synthetic IDs only.

[R] Recommendations:
- Compiler/Grammar: define source syntax for pipeline/scoped_by/cardinality
  using this fixture as the acceptance target.
- Bridge: map this observation vocabulary to metadata-only diagnostics before
  touching real package data.

[S] Signals:
- Tenant scope, timezone, schedule status, and day-off config are semantic
  inputs, not optional labels.
- Available slots need explicit reproducibility evidence, not just absence of
  busy facts in host state.

[T] Tests / Proofs:
- spark_technician_availability_fixture.rb -> PASS.
- ruby -c spark_technician_availability_fixture.rb -> Syntax OK.

[Files] Changed:
- igniter-lang/experiments/spark_technician_availability_fixture/spark_technician_availability_fixture.rb
- igniter-lang/docs/tracks/spark-technician-availability-fixture-v0.md
- igniter-lang/docs/README.md

[Q] Open Questions:
- Should available be a first-class why-not reason or derived absence?
- Should schedule status drift always block, or become provisional with a
  future equivalence/migration receipt?
- Should bridge diagnostics expose raw synthetic IDs or redacted display refs?

[X] Rejected:
- Real Spark data or endpoints.
- Ambient tenant scope.
- Trusted snapshots for negative cases.

[Next] Proposed next slices:
- [Compiler/Grammar Expert] spark-pipeline-grammar-v0.
- [Bridge Agent] spark-availability-diagnostics-bridge-profile-v0.
```
