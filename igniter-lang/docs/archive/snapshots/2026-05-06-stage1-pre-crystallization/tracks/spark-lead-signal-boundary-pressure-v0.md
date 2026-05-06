# Track: Spark Lead Signal Boundary Pressure v0

Role: `[Igniter-Lang Applied Pressure Agent]`
Track: `igniter-lang/docs/tracks/spark-lead-signal-boundary-pressure-v0.md`
Status: done
Slice state: done on 2026-05-06
Affected neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`

## Frame

This track prepares the second Spark operational fixture after technician
availability. It turns lead signal analytics into language pressure around
normalized observations, deterministic idempotency, Decimal bid totals, hourly
materialization, retention receipts, duplicate handling, and late boundary
reopen.

Safety boundary:

- synthetic IDs only;
- no real customers, tenants, employees, phone numbers, endpoint paths, URLs,
  vendor payloads, tokens, secrets, credentials, queue names, or infrastructure
  details;
- fixture is business-logic pressure, not a Spark implementation.

## Source Horizon

- `igniter-lang/docs/tracks/spark-crm-applied-language-pressure-v0.md`
- `igniter-lang/docs/tracks/spark-crm-real-business-candidate-map-v0.md`
- `igniter-lang/docs/tracks/spark-technician-availability-fixture-pressure-v0.md`
- `igniter-lang/docs/tracks/temporal-lifecycle-boundary-fixtures-v0.md`
- Sanitized local Spark CRM business-code review already captured in the real
  candidate map.

## Compact Claim

[D] The second Spark proof should make Igniter-Lang answer one concrete
operational question:

```text
given normalized lead signals for one hourly boundary,
which signals are accepted/rejected, which duplicates are suppressed,
what Decimal bid totals are materialized, and what retention receipt proves
raw details were handled without losing meaning?
```

[D] This is stronger than a simple aggregation fixture because the language
must keep four boundaries explicit:

```text
raw vendor-shaped input  -> normalized LeadSignalObservation
normalized signal        -> deterministic IdempotencyKey
hour window              -> HourlyLeadSignalRollup
retention action         -> dry-run/execution receipt
```

## Fixture Identity

All IDs are synthetic and safe for public docs.

```text
fixture_id: spark_lead_signal_boundary_minimal_v0
company_id: company/fixture-acme
boundary_id: lead_boundary/company-fixture-acme/20260506T10Z
schema_version: lead_signal_schema@0.1.0
rollup_rule_version: lead_rollup_rules@1
retention_rule_version: lead_retention_rules@1
hour_bucket_utc: 2026-05-06T10:00:00Z..2026-05-06T11:00:00Z
as_of: 2026-05-06T11:05:00Z
currency: USD
decimal_scale: 2
```

Tenant scope:

```text
fact_scope:
  company_id: company/fixture-acme
  stores:
    - lead_signals
    - lead_signal_hourly_rollups
    - retention_receipts
```

Boundary dimensions:

```text
dimensions:
  channel_ref: channel/fixture-web
  trade_ref: trade/fixture-appliance
  vendor_ref: vendor/fixture-marketplace
  geo_ref: geo/fixture-region-001
```

## Minimal Input Facts

The fixture uses three unique normalized lead signals in one UTC hour.

```text
LeadSignalInput ls-001:
  signal_ref: lead_signal/fixture/ls-001
  company_id: company/fixture-acme
  channel_ref: channel/fixture-web
  trade_ref: trade/fixture-appliance
  vendor_ref: vendor/fixture-marketplace
  geo_ref: geo/fixture-region-001
  did_ref: did/fixture-main
  upi_ref: upi/fixture-a
  signal_at: 2026-05-06T10:05:00Z
  accepted: true
  bid: Decimal("125.50")
  request_ref: request/fixture-r-001
  trace_ref: trace/fixture-t-001

LeadSignalInput ls-002:
  signal_ref: lead_signal/fixture/ls-002
  company_id: company/fixture-acme
  channel_ref: channel/fixture-web
  trade_ref: trade/fixture-appliance
  vendor_ref: vendor/fixture-marketplace
  geo_ref: geo/fixture-region-001
  did_ref: did/fixture-main
  upi_ref: upi/fixture-b
  signal_at: 2026-05-06T10:20:00Z
  accepted: false
  bid: Decimal("0.00")
  request_ref: request/fixture-r-002
  trace_ref: trace/fixture-t-002

LeadSignalInput ls-003:
  signal_ref: lead_signal/fixture/ls-003
  company_id: company/fixture-acme
  channel_ref: channel/fixture-web
  trade_ref: trade/fixture-appliance
  vendor_ref: vendor/fixture-marketplace
  geo_ref: geo/fixture-region-001
  did_ref: did/fixture-main
  upi_ref: upi/fixture-c
  signal_at: 2026-05-06T10:45:00Z
  accepted: true
  bid: Decimal("80.25")
  request_ref: request/fixture-r-003
  trace_ref: trace/fixture-t-003
```

## Idempotency Contract

The idempotency key must be deterministic CORE over a bounded normalized
record. No provider-shaped raw payload participates directly.

```text
IdempotencyKeyInput = {
  company_id,
  channel_ref,
  did_ref,
  upi_ref,
  geo_ref,
  trade_ref,
  vendor_ref,
  signal_at_utc_iso8601,
  accepted,
  bid_decimal_string
}

canonicalization:
  field_order: lexical
  absent_optional: null
  timestamp_precision: microsecond
  decimal_format: fixed scale 2 string
  timezone: UTC only
```

Expected fixture keys use stable symbolic hashes. The research proof may
replace them with actual SHA-256 values if it also records the canonical
preimage.

```text
lead_signal/fixture/ls-001 -> idem/sha256/lead-signal-001
lead_signal/fixture/ls-002 -> idem/sha256/lead-signal-002
lead_signal/fixture/ls-003 -> idem/sha256/lead-signal-003
```

## Expected Observations

### LeadSignalObservation

One observation per admitted input signal after normalization:

```text
obs_id: obs/lead_signal/ls-001/asof-20260506T110500Z
kind: fact_observation
lifecycle: T.window
payload: LeadSignalInput
payload_policy: :redacted_raw_vendor_payload
temporal:
  observed_at: 2026-05-06T10:05:00Z
  as_of: 2026-05-06T11:05:00Z
links:
  - rel: :scoped_to
    ref: company/fixture-acme
  - rel: :belongs_to_boundary
    ref: lead_boundary/company-fixture-acme/20260506T10Z
```

The same shape applies to `ls-002` and `ls-003`.

### IdempotencyKeyObservation

```text
obs_id: obs/idempotency/lead-signal-001/asof-20260506T110500Z
kind: platform_observation
lifecycle: T.durable
payload:
  key: idem/sha256/lead-signal-001
  algorithm: sha256
  canonicalization_ref: canonical/lead_signal_idempotency@1
  preimage_policy: :field_refs_only
links:
  - rel: :derived_from
    ref: lead_signal/fixture/ls-001
```

### LeadSignalBoundaryHorizon

```text
obs_id: obs/lead_signal_boundary/company-fixture-acme/20260506T10Z
kind: platform_observation
lifecycle: T.session
payload:
  boundary_id: lead_boundary/company-fixture-acme/20260506T10Z
  mode: :reproducible
  hour_bucket_utc: 2026-05-06T10:00:00Z..2026-05-06T11:00:00Z
  as_of: 2026-05-06T11:05:00Z
  rollup_rule_version: lead_rollup_rules@1
  schema_version: lead_signal_schema@0.1.0
  fact_scope:
    company_id: company/fixture-acme
```

### HourlyLeadSignalRollup

```text
rollup_id: lead_rollup/company-fixture-acme/20260506T10Z/web/appliance/vendor
lifecycle: T.durable
bucket_at: 2026-05-06T10:00:00Z
dimensions:
  company_id: company/fixture-acme
  channel_ref: channel/fixture-web
  trade_ref: trade/fixture-appliance
  vendor_ref: vendor/fixture-marketplace
  geo_ref: geo/fixture-region-001
metrics:
  accepted_count: 2
  rejected_count: 1
  total_count: 3
  accepted_bid_amount: Decimal("205.75")
  rejected_bid_amount: Decimal("0.00")
  total_bid_amount: Decimal("205.75")
  first_signal_at: 2026-05-06T10:05:00Z
  last_signal_at: 2026-05-06T10:45:00Z
links:
  - rel: :aggregated_from
    ref: obs/lead_signal/ls-001/asof-20260506T110500Z
  - rel: :aggregated_from
    ref: obs/lead_signal/ls-002/asof-20260506T110500Z
  - rel: :aggregated_from
    ref: obs/lead_signal/ls-003/asof-20260506T110500Z
```

### Retention Receipts

Dry-run receipt:

```text
receipt_id: retention/lead_signal/dry-run/company-fixture-acme/20260506T10Z
kind: retention_receipt
mode: :dry_run
policy_ref: lead_retention_rules@1
boundary_ref: lead_boundary/company-fixture-acme/20260506T10Z
candidate_count: 3
would_compact_count: 3
would_delete_raw_payload_count: 3
preserved_refs:
  - lead_rollup/company-fixture-acme/20260506T10Z/web/appliance/vendor
  - idem/sha256/lead-signal-001
  - idem/sha256/lead-signal-002
  - idem/sha256/lead-signal-003
status: :ok
```

Execution receipt:

```text
receipt_id: retention/lead_signal/execute/company-fixture-acme/20260506T10Z
kind: retention_receipt
mode: :execute
policy_ref: lead_retention_rules@1
boundary_ref: lead_boundary/company-fixture-acme/20260506T10Z
compacted_count: 3
deleted_raw_payload_count: 3
preserved_stub_count: 3
rollup_preserved: true
status: :ok
```

## Expected Result Table

| Signal | Signal time UTC | Business accepted? | Bid | Idempotency key | Rollup effect | Expected boundary status |
|--------|-----------------|----------|-----|-----------------|---------------|-----------------|
| `ls-001` | `2026-05-06T10:05:00Z` | true | `Decimal("125.50")` | `idem/sha256/lead-signal-001` | `accepted_count +1`, `accepted_bid +125.50` | admitted |
| `ls-002` | `2026-05-06T10:20:00Z` | false | `Decimal("0.00")` | `idem/sha256/lead-signal-002` | `rejected_count +1`, `rejected_bid +0.00` | admitted |
| `ls-003` | `2026-05-06T10:45:00Z` | true | `Decimal("80.25")` | `idem/sha256/lead-signal-003` | `accepted_count +1`, `accepted_bid +80.25` | admitted |

Rollup summary:

| Metric | Expected |
|--------|----------|
| `accepted_count` | `2` |
| `rejected_count` | `1` |
| `total_count` | `3` |
| `accepted_bid_amount` | `Decimal("205.75")` |
| `rejected_bid_amount` | `Decimal("0.00")` |
| `total_bid_amount` | `Decimal("205.75")` |
| `first_signal_at` | `2026-05-06T10:05:00Z` |
| `last_signal_at` | `2026-05-06T10:45:00Z` |

## Negative Cases

### DUP-1: Duplicate Signal

Input:

```text
signal_ref: lead_signal/fixture/ls-001-duplicate
same canonical idempotency fields as ls-001
different request_ref: request/fixture-r-001b
different trace_ref: trace/fixture-t-001b
```

Expected:

```text
status: :duplicate_suppressed
duplicate_of: idem/sha256/lead-signal-001
rollup_changed: false
retention_candidate_count_delta: 0
diagnostic: lead_signal.duplicate_idempotency_key
```

The language must distinguish a duplicate observation receipt from a rejected
lead signal. It is not `accepted=false`; it is boundary non-admission.

### LATE-1: Late Signal For Closed Hour

Input:

```text
signal_ref: lead_signal/fixture/ls-004-late
signal_at: 2026-05-06T10:55:00Z
arrived_at: 2026-05-06T12:30:00Z
target_boundary: lead_boundary/company-fixture-acme/20260506T10Z
boundary_state: :closed
retention_execution_receipt_exists: true
```

Expected default:

```text
status: :blocked
diagnostic: lead_signal.late_boundary_reopen_required
rollup_changed: false
requires:
  - BoundaryReopenIntent
  - MigrationReceipt or ReopenReceipt
  - replacement SemanticImage if the rollup is changed
```

Open design pressure: a language-level late-boundary policy may allow
`:reopen_with_receipt`, but silent mutation of a closed rollup is OOF.

### DEC-1: Decimal Bid Precision Drift

Input:

```text
signal_ref: lead_signal/fixture/ls-decimal-drift
bid: 125.5
bid_source_type: Float
```

Expected:

```text
status: :blocked
diagnostic: lead_signal.bid_decimal_invalid
reason: bid must be canonical Decimal string with fixed scale before rollup
rollup_changed: false
```

The proof should also include `Decimal("0.10") + Decimal("0.20")` style
pressure so a Float-backed implementation cannot pass by accident.

### RET-1: Retention Before Boundary Coverage

Input:

```text
mode: :execute
boundary_state: :open
rollup_receipt_exists: false
```

Expected:

```text
status: :blocked
diagnostic: retention.boundary_coverage_missing
deleted_raw_payload_count: 0
requires:
  - closed boundary
  - HourlyLeadSignalRollup
  - retention dry-run receipt or explicit skip policy
```

## Language Capability Demands

- `Decimal` or `Money` must be a typed value with explicit scale, not an
  ambient host numeric.
- `IdempotencyKey` must be deterministic over a canonical normalized record
  and must be addressable as evidence.
- Hourly rollup must be a boundary materialization with `aggregated_from`
  links, not an untraceable cache.
- Duplicate suppression must produce an observation/receipt distinct from a
  rejected business signal.
- Retention must produce dry-run and execution receipts with preserved
  semantic coverage.
- Late signals for closed boundaries must be blocked or reopened through a
  receipt-bearing migration/reopen operation.

## Concrete Research Agent Fixture Request

Please implement a standalone fixture proof:

```text
track_request: spark_lead_signal_boundary_fixture_v0
suggested_dir: igniter-lang/experiments/spark_lead_signal_boundary_fixture/
inputs:
  - three positive LeadSignalInput facts
  - DUP-1 duplicate case
  - LATE-1 late closed-boundary case
  - DEC-1 decimal drift case
  - RET-1 retention-before-coverage case
outputs:
  - golden positive observations
  - golden hourly rollup summary
  - dry-run retention receipt
  - execution retention receipt
  - golden negative diagnostics
checker:
  - validates accepted/rejected counts
  - validates Decimal totals as exact strings
  - validates idempotency dedupe does not mutate rollup
  - validates late closed-boundary signal cannot silently mutate rollup
  - validates retention execution requires boundary coverage
safety:
  - synthetic facts only
  - no Spark endpoints, secrets, payloads, provider configs, customer data, or
    infrastructure names
```

Proof acceptance:

- positive fixture emits exactly three admitted signal observations;
- rollup summary matches the expected table above;
- duplicate case emits duplicate suppression evidence and leaves rollup
  unchanged;
- decimal drift case fails before aggregation;
- late case either blocks or emits an explicit reopen/migration receipt, but
  never mutates a closed rollup silently;
- retention execution preserves rollup and idempotency evidence after raw
  payload compaction.

## Compiler/Grammar Expert Questions

1. Should `Decimal(scale: 2)` be a primitive CORE type, a stdlib structural
   type with operations, or an ESCAPE-backed host numeric with capability
   receipts?
2. Is `IdempotencyKey[T]` a first-class typed value derived by a CORE
   `canonical_hash` primitive, or should hashing be ESCAPE with a receipt?
3. Where should canonicalization rules live: type declaration metadata,
   contract declaration metadata, or a separate schema/canonicalization
   descriptor?
4. Does `HourlyLeadSignalRollup` require a language-level
   `BoundaryMaterialization[T]` kind, or can it be represented by existing
   `Projection[T, horizon]` plus lifecycle metadata?
5. What is the formal status of duplicate suppression: `Result[Admitted,
   DuplicateReceipt]`, a diagnostic observation, or a boundary admission
   contract?
6. How should retention be typed: lifecycle transition, TBackend compaction
   operation, schema migration-like receipt, or all three with different
   layers?
7. What is the admissible language semantics for late boundary reopen:
   always blocked, `BoundaryReopenIntent -> ReopenReceipt`, or
   migration-style replacement image?
8. Can SemanticIR contain unresolved Decimal scale coercions, or must all
   Decimal scale and rounding policy be resolved before SemanticIR?

## Bridge Agent Candidates

- A metadata-only `LeadSignalBoundaryDiagnostic` bridge profile that surfaces
  duplicate, Decimal, late-boundary, and retention coverage diagnostics.
- A package-facing `RollupReceipt` shape that can map Igniter-Lang
  `aggregated_from` evidence to current platform diagnostics without importing
  Spark-specific concepts.
- A `RetentionReceipt` bridge profile aligned with existing TBackend
  compaction semantics and future storage adapters.
- A `DecimalValue` bridge wrapper for exact string representation, scale, and
  host conversion diagnostics.

## Handoff

```text
[Igniter-Lang Applied Pressure Agent]
Track: igniter-lang/docs/tracks/spark-lead-signal-boundary-pressure-v0.md
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Fixed the second Spark operational fixture around normalized lead signals,
  idempotency, hourly rollup, Decimal bid totals, retention receipts,
  duplicate suppression, and late closed-boundary pressure.
- Chose synthetic IDs and symbolic hashes so the fixture can be public and
  implementable without exposing real Spark internals.
- Treated duplicate signal suppression as boundary non-admission, not as a
  rejected lead.
- Treated late mutation of a closed retained boundary as OOF unless protected
  by a reopen/migration receipt.

[R] Recommendations:
- Research Agent should implement the standalone fixture and checker exactly
  enough to prove positive rollup, duplicate suppression, Decimal exactness,
  late-boundary blocking, and retention coverage.
- Compiler/Grammar Expert should answer Decimal, canonical hash, boundary
  materialization, retention typing, and late reopen semantics before this
  becomes source syntax.
- Bridge Agent should prepare metadata-only diagnostic/receipt bridge shapes
  for rollups, retention, Decimal values, and boundary admission failures.

[S] Signals:
- Decimal arithmetic is now first-class applied pressure, not incidental host
  math.
- Idempotency keys are evidence, not hidden database indexes.
- Retention is a semantic operation because it changes reproducibility
  conditions.
- Late-arriving facts require language-level boundary lifecycle semantics.

[T] Tests / Proofs:
- Not run; documentation/specification slice only.
- Requested Research Agent proof:
  `igniter-lang/experiments/spark_lead_signal_boundary_fixture/`.

[Files] Changed:
- igniter-lang/docs/tracks/spark-lead-signal-boundary-pressure-v0.md
- igniter-lang/docs/README.md

[Q] Open Questions:
- Decimal primitive vs stdlib vs ESCAPE-backed host numeric?
- CORE canonical hash vs ESCAPE hash receipt?
- Projection plus lifecycle vs dedicated BoundaryMaterialization kind?
- Formal late-boundary reopen protocol and replacement image requirements?

[X] Rejected:
- Publishing real Spark endpoint, payload, provider, customer, or
  infrastructure details.
- Treating duplicate idempotency as a normal rejected lead signal.
- Allowing Float-backed bid totals to satisfy rollup proofs.
- Silent mutation of a retained closed hourly boundary.

[Next] Proposed next slice:
- Research Agent: implement `spark_lead_signal_boundary_fixture_v0`.
- Compiler/Grammar Expert: formalize Decimal, idempotency, retention, and late
  boundary reopen semantics.
- Bridge Agent: draft lead boundary diagnostic and retention receipt bridge
  candidates.
```
