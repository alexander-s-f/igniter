# Track: Spark Lead Signal Boundary Fixture v0

Status: done
Slice state: done on 2026-05-06
Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/spark-lead-signal-boundary-fixture-v0`
Supervisor: `[Architect Supervisor / Codex]`
Neighbors: `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`
Artifacts:
- `igniter-lang/experiments/spark_lead_signal_boundary_fixture/spark_lead_signal_boundary_fixture.rb`
- `igniter-lang/docs/tracks/spark-lead-signal-boundary-pressure-v0.md`

---

## Frame

This slice turns the Spark lead-signal boundary pressure case into an
executable synthetic fixture.

Safety boundary:

- synthetic normalized lead facts only
- no real Spark CRM data
- no vendor payloads, endpoints, queue names, provider configs, secrets,
  tokens, customers, phones, emails, or infrastructure details
- proof fixture only, not package adapter code

---

## What The Fixture Models

Positive case:

```text
LeadSignalBoundaryHorizon
  -> LeadSignalObservation x3
  -> IdempotencyKeyObservation x3
  -> HourlyLeadSignalRollup
  -> BoundaryCloseReceipt
  -> RetentionReceipt(dry_run)
  -> RetentionReceipt(execute)
```

Boundary identity:

```text
company_id: company/fixture-acme
boundary_id: lead_boundary/company-fixture-acme/20260506T10Z
hour_bucket_utc: 2026-05-06T10:00:00Z..2026-05-06T11:00:00Z
as_of: 2026-05-06T11:05:00Z
schema_version: lead_signal_schema@0.1.0
rollup_rule_version: lead_rollup_rules@1
retention_rule_version: lead_retention_rules@1
```

Positive admitted signals:

```text
ls-001 accepted=true  bid=Decimal("125.50")
ls-002 accepted=false bid=Decimal("0.00")
ls-003 accepted=true  bid=Decimal("80.25")
```

Rollup:

```text
accepted_count: 2
rejected_count: 1
total_count: 3
accepted_bid_amount: Decimal("205.75")
rejected_bid_amount: Decimal("0.00")
total_bid_amount: Decimal("205.75")
```

---

## Negative / Boundary Cases

[D] Duplicate suppression is boundary non-admission:

```text
status: duplicate_suppressed
decision: non_admission
diagnostic: lead_signal.duplicate_idempotency_key
rollup_changed: false
```

The duplicate does not emit a fourth `LeadSignalObservation` and does not
count as `accepted=false`.

[D] Decimal drift blocks before aggregation:

```text
diagnostic: lead_signal.bid_decimal_invalid
rollup_changed: false
```

The proof rejects a Float-backed `125.5` bid and separately proves
`Decimal("0.10") + Decimal("0.20") == Decimal("0.30")` using `BigDecimal`.

[D] Late mutation of a retained closed boundary blocks:

```text
diagnostic: lead_signal.late_boundary_reopen_required
rollup_changed: false
requires:
  - BoundaryReopenIntent
  - ReopenReceipt
  - replacement SemanticImage if rollup changes
```

[D] Retention execution requires boundary coverage:

```text
diagnostic: retention.boundary_coverage_missing
deleted_raw_payload_count: 0
```

---

## Proof Output

```text
ruby igniter-lang/experiments/spark_lead_signal_boundary_fixture/spark_lead_signal_boundary_fixture.rb
```

Output:

```text
PASS spark_lead_signal_boundary_fixture
positive.admitted_signal_count: ok
positive.rollup_counts: ok
positive.decimal_totals_exact: ok
positive.idempotency_evidence: ok
positive.retention_receipts: ok
duplicate.non_admission: ok
duplicate.rollup_unchanged: ok
decimal.drift_blocked: ok
decimal.no_float_drift: ok
late.closed_boundary_blocked: ok
late.rollup_unchanged: ok
retention.coverage_required: ok
safety.synthetic_only: ok
positive.rollup: accepted=2 rejected=1 total_bid=205.75
duplicate: duplicate_suppressed diagnostic=lead_signal.duplicate_idempotency_key
late_boundary: blocked diagnostic=lead_signal.late_boundary_reopen_required
retention_before_coverage: blocked diagnostic=retention.boundary_coverage_missing
```

The proof also supports:

```text
ruby igniter-lang/experiments/spark_lead_signal_boundary_fixture/spark_lead_signal_boundary_fixture.rb --dump
```

to inspect generated synthetic observations.

---

## Gap Report

### Compiler / Grammar

[Next] Formalize `Decimal(scale: 2)` as a CORE or stdlib typed value before
SemanticIR. This proof treats Float-backed bid values as invalid before
aggregation.

[Next] Define `IdempotencyKey[T]` and canonicalization descriptors. The proof
uses deterministic SHA-256 over a normalized bounded record and records the
canonical preimage hash.

[Next] Decide whether `HourlyLeadSignalRollup` is a dedicated
`BoundaryMaterialization[T]` kind or a `Projection[T, horizon]` with lifecycle
metadata.

[Q] Late boundary reopen remains blocked here. Compiler/Grammar should define
whether `BoundaryReopenIntent -> ReopenReceipt` is source syntax, migration
syntax, or runtime-only receipt discipline.

### Bridge

[Next] Draft metadata-only bridge profiles for:

- `LeadSignalBoundaryDiagnostic`
- `HourlyLeadSignalRollup`
- `DuplicateSuppressionReceipt`
- `RetentionReceipt`
- `DecimalValue`

[Q] Bridge should decide how preserved rollup/idempotency refs are exposed
after raw payload compaction without leaking provider-shaped payloads.

---

## Boundaries

[X] Rejected: real Spark CRM reads, endpoints, credentials, vendor payloads,
provider configs, queue names, customer data, phones, or emails.

[X] Rejected: duplicate idempotency as a rejected business lead.

[X] Rejected: Float-backed bid totals.

[X] Rejected: silent mutation of a closed retained hourly boundary.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/spark-lead-signal-boundary-fixture-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Built a stdlib-only executable synthetic fixture.
- Positive case emits three LeadSignalObservation records, three
  IdempotencyKeyObservation records, one HourlyLeadSignalRollup, dry-run
  retention receipt, and execution retention receipt.
- Duplicate suppression emits non-admission evidence and leaves the rollup
  unchanged.
- Decimal drift blocks before aggregation; Decimal totals remain exact typed
  strings.
- Late closed-boundary mutation blocks and requires reopen/migration evidence.
- Retention execute blocks without closed-boundary rollup coverage.

[R] Recommendations:
- Compiler/Grammar: formalize Decimal, IdempotencyKey, boundary
  materialization, retention typing, and late-boundary reopen semantics.
- Bridge: define metadata-only diagnostic/receipt profiles before mapping to
  any package-facing Spark diagnostics.

[S] Signals:
- Idempotency keys are evidence, not hidden indexes.
- Retention is semantic because it changes reproducibility conditions.
- Duplicate suppression is boundary admission control, not business rejection.

[T] Tests / Proofs:
- spark_lead_signal_boundary_fixture.rb -> PASS

[Files] Changed:
- igniter-lang/experiments/spark_lead_signal_boundary_fixture/spark_lead_signal_boundary_fixture.rb
- igniter-lang/docs/tracks/spark-lead-signal-boundary-fixture-v0.md
- igniter-lang/docs/README.md

[Q] Open Questions:
- Decimal primitive vs stdlib structural type?
- CORE canonical hash vs ESCAPE hash receipt?
- Projection plus lifecycle vs dedicated BoundaryMaterialization kind?
- Formal late-boundary reopen protocol?

[X] Rejected:
- Real Spark data or endpoints.
- Float-backed Decimal proof.
- Silent retained-boundary mutation.

[Next] Proposed next slice:
- Bridge Agent: lead boundary diagnostic and retention receipt bridge profile.
- Compiler/Grammar Expert: Decimal and boundary materialization syntax.
```
