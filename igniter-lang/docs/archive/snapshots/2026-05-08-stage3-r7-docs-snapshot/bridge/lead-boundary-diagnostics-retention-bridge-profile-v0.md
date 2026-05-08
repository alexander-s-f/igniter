# Lead Boundary Diagnostics Retention Bridge Profile v0

Role: `[Igniter-Lang Bridge Agent]`
Track: `igniter-lang/lead-boundary-diagnostics-retention-bridge-profile-v0`
Status: proposal
Date: 2026-05-06
Neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`, `[Igniter-Lang Applied Pressure Agent]`

## Purpose

Map the executable lead-signal boundary fixture into metadata-only bridge
profiles.

This note does not authorize package edits, Spark-specific package classes,
provider adapters, real customer/provider data, retention execution behavior,
or production boundary reopen behavior.

## Current Horizon

- Lead boundary diagnostics must distinguish admitted signals, duplicate
  non-admission, Decimal invalidation, late closed-boundary blocking, and
  retention coverage failure.
- Hourly rollups are boundary materializations with `aggregated_from` evidence,
  not untraceable caches.
- Decimal values need a stable wire shape independent of host numeric types.
- Idempotency keys are evidence and must be linked through `identified_by`.
- Retention is semantic because it changes what raw evidence remains available.

## Source Signals

[S] `spark-lead-signal-boundary-fixture-v0` is executable and synthetic. It
proves:

```text
LeadSignalBoundaryHorizon
  -> LeadSignalObservation x3
  -> IdempotencyKeyObservation x3
  -> HourlyLeadSignalRollup
  -> BoundaryCloseReceipt
  -> RetentionReceipt(dry_run)
  -> RetentionReceipt(execute)
```

[S] The proof passes the positive and blocked cases:

```text
positive.admitted_signal_count: ok
positive.rollup_counts: ok
positive.decimal_totals_exact: ok
positive.idempotency_evidence: ok
positive.retention_receipts: ok
duplicate.non_admission: ok
duplicate.rollup_unchanged: ok
decimal.drift_blocked: ok
late.closed_boundary_blocked: ok
late.rollup_unchanged: ok
retention.coverage_required: ok
safety.synthetic_only: ok
```

[S] `spark-lead-signal-boundary-pressure-v0` fixes the safety boundary: no real
Spark reads, customer data, vendor/provider payloads, endpoints, tokens,
secrets, queue names, or infrastructure details.

## Bridge Claim

[D] Lead-signal boundary proof can move toward package work only as
metadata-only diagnostics and receipts:

```text
BoundaryHorizon evidence
  -> LeadSignalBoundaryDiagnostic
  -> admitted LeadSignalObservation refs
  -> IdempotencyKey evidence
  -> HourlyLeadSignalRollup
  -> DuplicateSuppressionReceipt | NonAdmissionReceipt
  -> RetentionDryRunReceipt
  -> RetentionExecutionReceipt
```

[D] Retention receipt profiles may describe planned or observed compaction, but
they must not execute compaction, delete raw data, rewrite history, or mark a
late mutation safe without a future reopen/migration protocol.

## Generic JSON Shapes

### DecimalValue

`DecimalValue` is a wire shape, not a host numeric:

```json
{
  "kind": "DecimalValue",
  "coefficient": "20575",
  "scale": 2,
  "display": "205.75",
  "currency": "USD",
  "canonical": "205.75"
}
```

Rules:

- `coefficient` is a base-10 integer string without decimal point.
- `scale` is the number of fractional decimal places.
- `display` is the fixed-scale human form used in reports.
- host `Float` is not accepted as evidence for this profile.
- package payloads must preserve the structural form, not only `display`.

### IdempotencyKey

```json
{
  "key_ref": "idem/sha256/lead-signal-001",
  "profile": "idempotency_key_v0",
  "algorithm": "sha256",
  "canonicalization_ref": "canonical/lead_signal_idempotency@1",
  "preimage_policy": "field_refs_only",
  "canonical_preimage_hash": "sha256:redacted-preimage-hash",
  "identified_by": [
    { "rel": "identified_by", "ref": "redacted:company:fixture-acme" },
    { "rel": "identified_by", "ref": "redacted:channel:fixture-web" },
    { "rel": "identified_by", "ref": "redacted:did:fixture-main" },
    { "rel": "identified_by", "ref": "redacted:upi:fixture-a" },
    { "rel": "identified_by", "ref": "redacted:geo:fixture-region-001" },
    { "rel": "identified_by", "ref": "redacted:trade:fixture-appliance" },
    { "rel": "identified_by", "ref": "redacted:provider:fixture-marketplace" },
    { "rel": "identified_by", "ref": "time:2026-05-06T10:05:00Z" },
    { "rel": "identified_by", "ref": "value:accepted:true" },
    { "rel": "identified_by", "ref": "decimal:125.50" }
  ],
  "semantics": {
    "report_only": true,
    "runtime_enforced": false,
    "dedupe_store_authorized": false,
    "ledger_core": false
  }
}
```

### LeadSignalBoundaryDiagnostic

```json
{
  "diagnostic_id": "lead_boundary/fixture/20260506T10Z",
  "profile": "lead_signal_boundary_diagnostic_v0",
  "boundary_ref": "redacted:lead_boundary:20260506T10Z",
  "schema_version": "lead_signal_schema@0.1.0",
  "rollup_rule_version": "lead_rollup_rules@1",
  "retention_rule_version": "lead_retention_rules@1",
  "decision": "trusted",
  "status": "ok",
  "horizon": {
    "hour_bucket_utc": "2026-05-06T10:00:00Z..2026-05-06T11:00:00Z",
    "as_of": "2026-05-06T11:05:00Z",
    "mode": "reproducible"
  },
  "admission_summary": {
    "admitted_count": 3,
    "duplicate_suppressed_count": 0,
    "blocked_count": 0
  },
  "diagnostics": [],
  "evidence_links": {
    "boundary_horizon_ref": "obs/lead-signal-boundary-horizon",
    "rollup_ref": "lead_rollup/fixture/20260506T10Z",
    "retention_dry_run_receipt_ref": "retention/lead_signal/dry-run/fixture",
    "retention_execution_receipt_ref": "retention/lead_signal/execute/fixture"
  },
  "redaction_policy": {
    "profile": "lead_boundary_public_metadata_v0",
    "redacted_ref_kinds": ["provider", "vendor", "customer", "request", "trace", "did", "upi", "company", "geo"],
    "raw_ref_export": false,
    "hash_source_refs": true
  },
  "semantics": {
    "report_only": true,
    "runtime_enforced": false,
    "retention_execution_authorized": false,
    "boundary_reopen_authorized": false,
    "ledger_core": false
  }
}
```

Blocked variants use the same shape with:

```json
{
  "decision": "blocked",
  "status": "blocked",
  "diagnostics": [
    {
      "code": "lead_signal.late_boundary_reopen_required",
      "severity": "error",
      "rollup_changed": false,
      "requires": ["BoundaryReopenIntent", "ReopenReceipt", "replacement SemanticImage if rollup changes"]
    }
  ]
}
```

### HourlyLeadSignalRollup

```json
{
  "rollup_id": "lead_rollup/fixture/20260506T10Z",
  "profile": "hourly_lead_signal_rollup_v0",
  "boundary_ref": "redacted:lead_boundary:20260506T10Z",
  "bucket_at": "2026-05-06T10:00:00Z",
  "dimensions": {
    "company_ref": "redacted:company:fixture-acme",
    "channel_ref": "redacted:channel:fixture-web",
    "trade_ref": "redacted:trade:fixture-appliance",
    "provider_ref": "redacted:provider:fixture-marketplace",
    "geo_ref": "redacted:geo:fixture-region-001"
  },
  "metrics": {
    "accepted_count": 2,
    "rejected_count": 1,
    "total_count": 3,
    "accepted_bid_amount": {
      "kind": "DecimalValue",
      "coefficient": "20575",
      "scale": 2,
      "display": "205.75",
      "currency": "USD",
      "canonical": "205.75"
    },
    "rejected_bid_amount": {
      "kind": "DecimalValue",
      "coefficient": "0",
      "scale": 2,
      "display": "0.00",
      "currency": "USD",
      "canonical": "0.00"
    },
    "total_bid_amount": {
      "kind": "DecimalValue",
      "coefficient": "20575",
      "scale": 2,
      "display": "205.75",
      "currency": "USD",
      "canonical": "205.75"
    },
    "first_signal_at": "2026-05-06T10:05:00Z",
    "last_signal_at": "2026-05-06T10:45:00Z"
  },
  "evidence_links": {
    "computed_under": "obs/lead-signal-boundary-horizon",
    "aggregated_from": [
      "obs/lead_signal/ls-001",
      "obs/lead_signal/ls-002",
      "obs/lead_signal/ls-003"
    ],
    "identified_by": [
      "idem/sha256/lead-signal-001",
      "idem/sha256/lead-signal-002",
      "idem/sha256/lead-signal-003"
    ]
  },
  "source_summary_hash": "sha256:redacted-admitted-signal-ref-hash",
  "semantics": {
    "report_only": true,
    "runtime_enforced": false,
    "cache_authorized": false,
    "ledger_core": false
  }
}
```

### DuplicateSuppressionReceipt / NonAdmissionReceipt

```json
{
  "receipt_id": "duplicate_suppression/fixture/ls-001-duplicate",
  "profile": "duplicate_suppression_receipt_v0",
  "decision": "non_admission",
  "status": "duplicate_suppressed",
  "diagnostic": "lead_signal.duplicate_idempotency_key",
  "signal_ref": "redacted:lead_signal:ls-001-duplicate",
  "duplicate_of": "idem/sha256/lead-signal-001",
  "original_signal_ref": "redacted:lead_signal:ls-001",
  "rollup_changed": false,
  "retention_candidate_count_delta": 0,
  "must_not_emit": "LeadSignalObservation",
  "evidence_links": {
    "duplicates": "obs/lead_signal/ls-001",
    "identified_by": "idem/sha256/lead-signal-001",
    "boundary_ref": "redacted:lead_boundary:20260506T10Z"
  },
  "semantics": {
    "report_only": true,
    "runtime_enforced": false,
    "dedupe_store_authorized": false,
    "ledger_core": false
  }
}
```

[D] A duplicate is boundary non-admission. It is not a rejected business lead
and must not increment `rejected_count`.

### RetentionDryRunReceipt

```json
{
  "receipt_id": "retention/lead_signal/dry-run/fixture",
  "profile": "retention_dry_run_receipt_v0",
  "mode": "dry_run",
  "policy_ref": "lead_retention_rules@1",
  "boundary_ref": "redacted:lead_boundary:20260506T10Z",
  "candidate_count": 3,
  "would_compact_count": 3,
  "would_delete_raw_payload_count": 3,
  "preserved_refs": [
    "lead_rollup/fixture/20260506T10Z",
    "idem/sha256/lead-signal-001",
    "idem/sha256/lead-signal-002",
    "idem/sha256/lead-signal-003"
  ],
  "status": "ok",
  "evidence_links": {
    "covers": "lead_rollup/fixture/20260506T10Z",
    "boundary_horizon_ref": "obs/lead-signal-boundary-horizon"
  },
  "semantics": {
    "report_only": true,
    "runtime_enforced": false,
    "retention_execution_authorized": false,
    "raw_deletion_authorized": false,
    "ledger_core": false
  }
}
```

### RetentionExecutionReceipt

```json
{
  "receipt_id": "retention/lead_signal/execute/fixture",
  "profile": "retention_execution_receipt_v0",
  "mode": "execute",
  "policy_ref": "lead_retention_rules@1",
  "boundary_ref": "redacted:lead_boundary:20260506T10Z",
  "compacted_count": 3,
  "deleted_raw_payload_count": 3,
  "preserved_stub_count": 3,
  "rollup_preserved": true,
  "preserved_refs": [
    "lead_rollup/fixture/20260506T10Z",
    "idem/sha256/lead-signal-001",
    "idem/sha256/lead-signal-002",
    "idem/sha256/lead-signal-003"
  ],
  "status": "ok",
  "evidence_links": {
    "follows": "retention/lead_signal/dry-run/fixture",
    "preserves": "lead_rollup/fixture/20260506T10Z"
  },
  "semantics": {
    "report_only": true,
    "runtime_enforced": false,
    "retention_execution_authorized": false,
    "raw_deletion_authorized": false,
    "ledger_core": false
  }
}
```

Blocked retention execution uses the same profile with:

```json
{
  "status": "blocked",
  "diagnostic": "retention.boundary_coverage_missing",
  "deleted_raw_payload_count": 0,
  "requires": ["closed boundary", "HourlyLeadSignalRollup", "retention dry-run receipt or explicit skip policy"]
}
```

## Diagnostic Codes To Preserve

- `lead_signal.duplicate_idempotency_key`
- `lead_signal.bid_decimal_invalid`
- `lead_signal.late_boundary_reopen_required`
- `lead_signal.outside_boundary_window`
- `retention.boundary_coverage_missing`

## Redaction Policy

[D] Provider/vendor, customer-like, request, trace, DID, UPI, company, geo, and
raw payload refs default to redacted or hash-wrapped forms.

Rules:

- synthetic fixture refs may appear in research docs
- package diagnostics must default to `raw_ref_export: false`
- raw provider payloads, endpoints, URLs, tokens, secrets, queue names,
  customer names, phone numbers, emails, infrastructure ids, and request traces
  are not allowed in public package payloads
- idempotency preimages may expose field refs or a canonical preimage hash, not
  raw provider-shaped payloads
- retention receipts must preserve rollup/idempotency refs after compaction
  without leaking deleted raw payloads

## Package Touchpoint Recommendation

[R] First package touchpoint, if Architect approves:

```text
packages/igniter-contracts/
  Igniter::Lang::VerificationReport
  optional generic boundary diagnostics / retention receipts payload section
```

Recommended first package surface:

```text
Igniter::Lang::BoundaryDiagnosticProfile
```

or, for the smallest package change:

```text
VerificationReport#metadata[:boundary_diagnostics]
VerificationReport#metadata[:retention_receipts]
```

Why first:

- `igniter-contracts` already carries report-only Lang metadata and schema
  diagnostic precedent.
- Boundary diagnostics and retention receipt payloads can stay generic and
  package-neutral.
- It avoids Spark-specific public classes, package runtime enforcement,
  retention deletion behavior, and Ledger-as-core coupling.

Not first:

- `packages/igniter-application`: may later display or consume boundary
  diagnostics, but should not own the generic semantics first.
- `packages/igniter-ledger` / Ledger clients: may later transport durable refs
  and receipts as a TBackend adapter, but must not become language core.
- Spark-specific package namespaces: blocked.

## Package Agent Approval / Blocker Note

[R] Package Agent may start only after explicit Architect Supervisor approval.
The approved package slice should be metadata-only, generic, report-only, and
should preserve:

- `report_only: true`
- `runtime_enforced: false`
- required `evidence_links`
- `DecimalValue` structural wire shape
- `identified_by` links for idempotency evidence
- redaction policy defaulting to no raw ref export
- no retention execution authorization
- no boundary reopen authorization
- no Ledger-as-core semantics

[X] Package Agent is blocked from:

- editing packages from this bridge slice
- creating Spark-specific public package classes
- implementing retention compaction or raw payload deletion
- implementing provider/customer/request adapters
- implementing dedupe storage or admission mutation
- implementing boundary reopen/migration behavior
- serializing raw provider/customer/request/trace-like refs by default
- treating Ledger as required language core

## Explicitly Unauthorized

[X] No package edits in this bridge slice.

[X] No Spark-specific public package classes.

[X] No real Spark reads, provider payloads, endpoints, credentials, queue names,
customers, phone numbers, emails, request traces, or infrastructure details.

[X] No Float-backed Decimal acceptance.

[X] No retention execution, raw deletion, compaction rewrite, dedupe mutation,
or boundary reopen behavior.

[X] No application readiness enforcement.

[X] No Ledger-as-core semantics.

## Handoff

```text
[Igniter-Lang Bridge Agent]
Track: igniter-lang/lead-boundary-diagnostics-retention-bridge-profile-v0
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent | Applied Pressure Agent

[D] Decisions:
- Mapped the executable lead-signal boundary fixture into metadata-only profiles.
- Defined generic JSON shapes for LeadSignalBoundaryDiagnostic, HourlyLeadSignalRollup, DuplicateSuppressionReceipt/NonAdmissionReceipt, RetentionDryRunReceipt, RetentionExecutionReceipt, DecimalValue, and IdempotencyKey.
- Preserved duplicate suppression as non-admission, late closed-boundary mutation as blocked/reopen-required, and retention coverage as required evidence.
- Required DecimalValue as coefficient/scale/display and idempotency links through identified_by.
- Added redaction policy for provider/customer/request/trace-like refs.

[R] Recommendations:
- First package touchpoint should be packages/igniter-contracts as a generic report-only boundary diagnostics/retention receipts carrier after Architect approval.
- Prefer VerificationReport metadata sections for smallest package surface, or Igniter::Lang::BoundaryDiagnosticProfile if a standalone class is approved.
- Keep igniter-application as later consumer and Ledger as optional TBackend/transport adapter.

[S] Signals:
- spark_lead_signal_boundary_fixture.rb passes accepted/rejected counts, exact Decimal totals, idempotency evidence, duplicate non-admission, late-boundary block, and retention coverage checks.
- Retention is semantic because it changes reproducibility conditions after raw payload compaction.
- Idempotency keys are evidence, not hidden indexes.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/spark_lead_signal_boundary_fixture/spark_lead_signal_boundary_fixture.rb -> PASS.

[Files] Changed:
- igniter-lang/docs/bridge/lead-boundary-diagnostics-retention-bridge-profile-v0.md
- igniter-lang/docs/bridge/README.md
- igniter-lang/docs/README.md
- igniter-lang/docs/agent-motion.md

[Q] Open Questions:
- Should the first package slice use VerificationReport metadata sections or a standalone BoundaryDiagnosticProfile class?
- Should DecimalValue become a shared generic value type before boundary diagnostics land?
- How should future BoundaryReopenIntent/ReopenReceipt relate to schema migration receipts?

[X] Rejected:
- Package edits in this slice.
- Spark-specific public package classes.
- Provider/customer/request adapters, raw retention deletion, dedupe mutation, boundary reopen behavior, application readiness enforcement, and Ledger-as-core.

[Next] Proposed next slice:
- Architect-reviewed package plan for generic boundary diagnostics and retention receipt carriers in igniter-contracts.
```
