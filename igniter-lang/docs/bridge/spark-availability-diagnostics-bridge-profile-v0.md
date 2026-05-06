# Spark Availability Diagnostics Bridge Profile v0

Role: `[Igniter-Lang Bridge Agent]`
Track: `igniter-lang/spark-availability-diagnostics-bridge-profile-v0`
Status: proposal
Date: 2026-05-06
Neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`, `[Igniter-Lang Applied Pressure Agent]`

## Purpose

Map the executable Spark technician availability fixture into metadata-only
diagnostics.

This bridge profile does not edit packages and does not authorize real Spark
adapters, real tenant data, or package runtime enforcement.

## Source Signals

[S] `spark-technician-availability-fixture-v0` is executable and synthetic.
It proves tenant scope, scoped reads with declared cardinality, positive
availability projection/snapshot, and blocked negative cases.

[S] `spark-tenant-and-pipeline-formalization-v0` defines `TenantScope`,
`ScopedFactRead`, `CardinalityBound`, `StepObservation`, and `PipelineTrace`
as typed diagnostic surfaces.

[S] `spark-technician-availability-fixture-pressure-v0` requires slot reason
counts, source refs for `busy`, `off`, and `day_off`, and redaction policy
before any real package adapter work.

## Bridge Claim

[D] The executable fixture can be represented as a metadata-only availability
diagnostic profile:

```text
TenantScope
  -> AvailabilityHorizon
  -> ScopedFactRead bundle
  -> AvailabilityProjection
  -> AvailabilitySnapshot | failure_observation
  -> PipelineTrace
```

[D] The profile may report tenant scope, scoped read subjects, cardinality
bounds, slot reason counts, source refs, failed step, and failure kind. It must
not read real Spark data, execute package code, enforce app readiness, or expose
raw technician/company/user-like refs outside a redaction policy.

## Diagnostic JSON Shape

```json
{
  "diagnostic_id": "spark_availability/fixture-v0/positive",
  "profile": "spark_availability_diagnostics_v0",
  "status": "ok",
  "decision": "trusted",
  "subject": {
    "projection": "availability[technician, requested_window]",
    "tenant_scope": {
      "company_ref": "redacted:company:fixture-acme",
      "scope_version": "tenant-scope-v1",
      "source_ref": "obs/tenant-scope-source",
      "established_at": "2026-05-06T12:30:00Z"
    },
    "technician_ref": "redacted:technician:t-17",
    "date": "2026-05-06"
  },
  "horizon": {
    "as_of": "2026-05-06T12:30:00Z",
    "timezone": "America/New_York",
    "rule_version": "availability_rules@1",
    "requested_window_utc": "2026-05-06T13:00:00Z..2026-05-06T20:00:00Z",
    "mode": "reproducible"
  },
  "scoped_reads": [
    {
      "subject": "technician_profile",
      "type": "TechnicianProfile",
      "tenant_scope_ref": "obs/tenant-scope-source",
      "cardinality_bound": { "min": 1, "max": 1, "source": "declared" },
      "result_count": 1,
      "read_ref": "obs/scoped-read-technician-profile"
    },
    {
      "subject": "schedule_slots",
      "type": "ScheduleSlotObservation",
      "tenant_scope_ref": "obs/tenant-scope-source",
      "cardinality_bound": { "min": 0, "max": 500, "source": "declared" },
      "result_count": 1,
      "read_ref": "obs/scoped-read-schedule-slots"
    },
    {
      "subject": "off_schedules",
      "type": "OffScheduleObservation",
      "tenant_scope_ref": "obs/tenant-scope-source",
      "cardinality_bound": { "min": 0, "max": 500, "source": "declared" },
      "result_count": 1,
      "read_ref": "obs/scoped-read-off-schedules"
    },
    {
      "subject": "day_off_config",
      "type": "DayOffConfigVersion",
      "tenant_scope_ref": "obs/tenant-scope-source",
      "cardinality_bound": { "min": 1, "max": 1, "source": "declared" },
      "result_count": 1,
      "read_ref": "obs/scoped-read-day-off-config"
    }
  ],
  "slot_summary": {
    "available_count": 4,
    "blocked_count": 3,
    "reason_counts": {
      "available": 4,
      "busy": 1,
      "off": 1,
      "day_off": 1
    },
    "source_refs": {
      "busy": ["redacted:schedule:t-17-20260506-10"],
      "off": ["redacted:off_schedule:t-17-20260506-12"],
      "day_off": ["redacted:day_off_config:e-17-v1"]
    }
  },
  "pipeline": {
    "pipeline_id": "pipeline/spark-technician-availability-fixture-v0",
    "steps_attempted": [
      "establish_tenant_scope",
      "validate_availability_horizon",
      "read_scoped_facts",
      "compute_availability_projection",
      "materialize_availability_snapshot"
    ],
    "failed_step": null,
    "failure_kind": null,
    "trace_ref": "obs/pipeline-trace-positive"
  },
  "redaction_policy": {
    "profile": "spark_availability_public_synthetic_v0",
    "redacted_ref_kinds": ["company", "technician", "employee", "user", "schedule", "off_schedule", "day_off_config", "order"],
    "raw_ref_export": false,
    "hash_source_refs": true,
    "allow_synthetic_refs_in_research": true
  },
  "semantics": {
    "report_only": true,
    "runtime_enforced": false,
    "package_adapter_authorized": false,
    "real_spark_data_authorized": false
  }
}
```

Negative diagnostics use the same shape but set:

```json
{
  "status": "blocked",
  "decision": "blocked",
  "pipeline": {
    "failed_step": "read_scoped_facts",
    "failure_kind": "availability.tenant_scope_mismatch"
  },
  "snapshot_ref": null,
  "must_not_emit": "AvailabilitySnapshot"
}
```

Fixture failure kinds to preserve:

- `availability.tenant_scope_mismatch`
- `availability.invalid_time_window`
- `availability.inactive_technician`
- `availability.schedule_status_evidence_mismatch`

The pressure spec also names `availability.tenant_scope_missing`,
`availability.timezone_drift`, and `availability.cardinality_bound_failed` as
compatible future diagnostic cases.

## Redaction Policy

[D] Technician, company, employee, user-like, schedule, order, and day-off refs
must be redacted or hash-wrapped before leaving research fixtures.

Rules:

- research fixtures may display synthetic refs
- package diagnostics must default to redacted refs
- raw ref export requires an explicit policy flag outside this bridge
- source refs for `busy`, `off`, and `day_off` must preserve reason identity
  while hiding real subject identifiers
- failure context must omit raw customer, phone, email, endpoint, provider
  payload, token, secret, or infrastructure data

## Package Touchpoint Recommendation

[R] First package touchpoint, if approved:

```text
packages/igniter-contracts/
  Igniter::Lang::VerificationReport
  optional generic diagnostic payload section
```

Do not add Spark-specific public classes to `igniter-contracts`. The package
surface should remain generic, such as a report-only projection or pipeline
diagnostic payload that can carry this profile.

Candidate future package names only after Architect approval:

```text
Igniter::Lang::ProjectionDiagnostic
Igniter::Lang::PipelineDiagnostic
```

Not first:

- `packages/igniter-application`: may eventually display blocked readiness, but
  should consume generic diagnostics later.
- `packages/igniter-ledger` / `packages/igniter-ledger-client`: may eventually
  transport source refs, but must not own availability meaning.
- Spark-specific adapter packages: blocked until redaction policy, selected
  profile admission, and package-neutral diagnostics are approved.

## Approval / Blocker Note For Package Agent

[R] Package Agent may start only a package-neutral, metadata-only diagnostic
carrier if Architect approves it. It must be generic enough for
`ProjectionDiagnostic` / `PipelineDiagnostic` and must not mention Spark as a
runtime dependency or public package namespace.

[X] Package Agent is blocked from starting any Spark availability adapter or
real-data diagnostic exporter until:

- redaction behavior is implemented and reviewed
- selected-profile or equivalent fixture admission exists
- package-neutral diagnostic carrier is accepted
- Architect explicitly approves a Spark adapter slice

## Explicitly Unauthorized

[X] No package edits in this bridge slice.

[X] No real Spark reads, endpoints, credentials, provider payloads, customer
data, phones, emails, or infrastructure details.

[X] No ambient tenant scope.

[X] No unbounded scoped reads.

[X] No trusted snapshot for blocked cases.

[X] No application readiness enforcement.

[X] No Ledger-as-core semantics.

## Handoff

```text
[Igniter-Lang Bridge Agent]
Track: igniter-lang/spark-availability-diagnostics-bridge-profile-v0
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent | Applied Pressure Agent

[D] Decisions:
- Mapped the executable Spark technician availability fixture into metadata-only diagnostics.
- Preserved tenant scope source, scoped read subjects, cardinality bounds, slot reason counts, source refs, failed step, and failure kind.
- Added a redaction policy for technician/company/employee/user-like refs.
- Kept all Spark package adapter work out of scope.

[R] Recommendations:
- Package Agent may start only a generic report-only ProjectionDiagnostic/PipelineDiagnostic carrier after Architect approval.
- Do not add Spark-specific public classes to igniter-contracts.
- Block real Spark adapter/exporter work until redaction, selected-profile admission, and package-neutral diagnostics are approved.

[S] Signals:
- spark_technician_availability_fixture.rb passes and proves positive counts plus blocked negative cases.
- Tenant scope, timezone, schedule status, and day-off config are semantic inputs, not optional labels.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/spark_technician_availability_fixture/spark_technician_availability_fixture.rb -> PASS.

[Files] Changed:
- igniter-lang/docs/bridge/spark-availability-diagnostics-bridge-profile-v0.md
- igniter-lang/docs/bridge/README.md
- igniter-lang/docs/README.md
- igniter-lang/docs/agent-motion.md

[Q] Open Questions:
- Should generic package diagnostics be named ProjectionDiagnostic/PipelineDiagnostic, or stay as plain VerificationReport payload sections?
- Should package diagnostics reject raw refs by default or serialize them only under an explicit redaction policy object?

[X] Rejected:
- Package edits in this slice.
- Real Spark adapter work.
- Raw tenant/user-like refs in package diagnostics.
- App readiness enforcement and Ledger-as-core.

[Next] Proposed next slice:
- Architect-approved package-neutral diagnostic carrier plan for ProjectionDiagnostic/PipelineDiagnostic in igniter-contracts.
```
