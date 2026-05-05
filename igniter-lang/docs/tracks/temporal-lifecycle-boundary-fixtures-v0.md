# Track: Temporal Lifecycle Boundary Fixtures v0

Status: done
Slice state: done on 2026-05-05
Owner: `[Igniter-Lang Research Agent]`
Supervisor: `[Architect Supervisor / Codex]`

## Frame

This slice turns the Spark CRM technician dispatch pressure case into concrete
fixtures.

The fixture chain:

```text
GeoSignal stream
  -> RouteSegmentSnapshot
  -> AvailabilitySnapshot
  -> DailyTechnicianBoundary
  -> compacted stubs
  -> DispatchDecision audit trail
```

The goal is to show:

- boundary inputs and outputs
- what gets compacted
- what is preserved
- which links prove enough meaning after compaction
- when reproducibility is downgraded or blocked

This is still research:

- no package code
- no Spark CRM code
- no final syntax
- no Ledger-specific solution

## Source Horizon

- `igniter-lang/docs/temporal-lifecycle.md`
- `igniter-lang/docs/proposals/PROP-008-tbackend-contract-v0.md`
- `igniter-lang/docs/proposals/PROP-009-semantic-image-resume-compatibility-v0.md`
- `igniter-lang/docs/proposals/PROP-010-temporal-lifecycle-retention-semantics-v0.md`
- `igniter-lang/docs/tracks/temporal-lifecycle-application-scenarios-v0.md`
- `igniter-lang/docs/tracks/temporal-contracts-and-projections-v0.md`

## Compact Claim

[D] A boundary fixture is a small proof that compaction preserved meaning.

```text
raw observations
  + projection horizon
  + snapshot
  + boundary receipt
  + compacted stubs
  -> explainable decision after raw details expire
```

[D] Reproducibility after compaction requires a trusted coverage chain:

```text
DispatchDecision
  -> AvailabilitySnapshot
  -> RouteSegmentSnapshot
  -> DailyTechnicianBoundary
  -> CompactionReceipt
  -> compacted GeoSignal stubs
```

If any required link is missing, the decision becomes provisional, stale, or
blocked depending on whether a trusted snapshot covers the missing raw detail.

## Fixture Constants

Shared fixture identity:

```text
company_id: company/acme
technician_id: tech/t-17
employee_id: employee/e-17
order_id: order/o-930
day: 2026-05-05
shift_window: 2026-05-05T09:00:00Z..2026-05-05T17:00:00Z
decision_time: 2026-05-05T10:42:00Z
rule_version: dispatch_rules@42
runtime_contract_ref: obs/runtime/local-inline-v0
axiom_descriptor_ref: obs/axiom/core-v0
tbackend_descriptor_ref: obs/tbackend/file-or-ledger-v0
semantic_image_ref: obs/image/dispatch-session-2026-05-05-t17
```

Tenant scope is part of every horizon:

```text
fact_scope:
  company_id: company/acme
  stores:
    - technicians
    - schedules
    - off_schedules
    - day_off_configs
    - geo_signals
    - orders
```

[D] A fixture that omits `company_id` from `fact_scope` is invalid for dispatch
reproducibility.

## Fixture A: GeoSignal Stream

Purpose: represent high-frequency raw location facts without implying they
must live forever.

### Inputs

```text
GeoSignal stream: geo_stream/t-17/2026-05-05
lifecycle: T.window
window: DailyTechnicianBoundary(company/acme, tech/t-17, 2026-05-05)
raw_ttl: 72h
detail_retain_after_boundary: 48h
privacy.payload_policy: :present_summary during window, :hashed after compaction
```

Sample observations:

```text
geo/g-001:
  technician_id: tech/t-17
  observed_at: 2026-05-05T10:00:00Z
  point_hash: hash(lat/lng redacted)
  accuracy_m: 12
  source: :mobile_app

geo/g-002:
  technician_id: tech/t-17
  observed_at: 2026-05-05T10:05:00Z
  point_hash: hash(lat/lng redacted)
  accuracy_m: 15
  source: :mobile_app

geo/g-003:
  technician_id: tech/t-17
  observed_at: 2026-05-05T10:10:00Z
  point_hash: hash(lat/lng redacted)
  accuracy_m: 11
  source: :mobile_app
```

The real stream may contain hundreds or thousands of points. The fixture uses
three samples plus a count/hash summary.

### Output

The stream itself is not a final business artifact. It is input to snapshots.

```text
GeoSignalWindowSummary = {
  stream_ref: geo_stream/t-17/2026-05-05
  signal_count: 288
  first_observed_at: 2026-05-05T09:00:12Z
  last_observed_at: 2026-05-05T16:59:44Z
  ordered_signal_hash: hash(g-001..g-288)
  anomalies: []
}
```

### Preserved

- stream ref
- signal count
- first/last observed time
- ordered signal hash
- anomaly refs
- links to snapshots that consume the stream

### Compactable

- raw point payloads after boundary close + detail retain
- provider-specific raw metadata
- duplicate low-accuracy points not linked to anomaly/decision evidence

### Must Block Compaction

Compaction is blocked when:

- DailyTechnicianBoundary is not closed
- a DispatchDecision links directly to a raw point without snapshot coverage
- route anomaly is unresolved
- active replay cursor still requires raw observations
- tenant scope is missing or mixed

## Fixture B: RouteSegmentSnapshot

Purpose: replace raw movement detail with decision-relevant route meaning.

### Inputs

```text
inputs:
  geo_stream_ref: geo_stream/t-17/2026-05-05
  window: 2026-05-05T10:00:00Z..2026-05-05T10:30:00Z
  source_signal_refs: [geo/g-001, geo/g-002, geo/g-003, ...]
  order_ref: order/o-930
  technician_ref: tech/t-17
  rule_version: route_rules@9
```

### Output

```text
RouteSegmentSnapshot = {
  snapshot_id: route_snapshot/t-17/2026-05-05/10-00-10-30
  lifecycle: T.compacted
  technician_id: tech/t-17
  company_id: company/acme
  window: 2026-05-05T10:00:00Z..2026-05-05T10:30:00Z
  source_count: 37
  source_hash: hash(geo/g-001..geo/g-037)
  path_hash: hash(normalized_polyline_redacted)
  start_point_hash: hash(start redacted)
  end_point_hash: hash(end redacted)
  distance_band: :near
  eta_band: :lt_30m
  anomaly_refs: []
}
```

### Links

```text
links:
  - rel: :derived_from, ref: geo_stream/t-17/2026-05-05
  - rel: :observed_under, ref: runtime_contract_ref
  - rel: :observed_under, ref: axiom_descriptor_ref
  - rel: :observed_under, ref: tbackend_descriptor_ref
```

### Preserved

- `snapshot_id`
- `source_hash`
- `path_hash`
- distance/ETA bands
- anomaly refs
- runtime/axiom/TBackend refs

### Compacted

- individual raw point payloads
- precise redacted route path
- provider-specific telemetry fields

[D] RouteSegmentSnapshot is sufficient for most dispatch explanations:
"technician was near enough under route_rules@9." It is not sufficient for a
legal dispute requiring exact GPS trace unless policy marks raw points as
`T.audit`.

## Fixture C: AvailabilitySnapshot

Purpose: preserve why technician t-17 was considered available or unavailable
at decision time.

### Inputs

```text
inputs:
  technician_ref: tech/t-17
  order_ref: order/o-930
  day_off_config_ref: day_off/e-17/rule-v12
  schedule_slot_refs:
    - schedule/t-17/2026-05-05/10-00
    - schedule/t-17/2026-05-05/10-30
  off_schedule_refs:
    - off/t-17/break-1030
  route_segment_snapshot_ref: route_snapshot/t-17/2026-05-05/10-00-10-30
  horizon:
    as_of: 2026-05-05T10:42:00Z
    rule_version: dispatch_rules@42
    fact_scope:
      company_id: company/acme
      technician_id: tech/t-17
      order_id: order/o-930
```

### Output

```text
AvailabilitySnapshot = {
  snapshot_id: availability/t-17/o-930/2026-05-05T10-42-00Z
  lifecycle: T.compacted
  status: :available
  constraints:
    service_match: true
    zone_match: true
    schedule_conflict: false
    off_schedule_conflict: false
    distance_band: :near
    eta_band: :lt_30m
  source_summary_hash: hash(day_off + schedules + off_schedules + route_snapshot)
  route_segment_snapshot_ref: route_snapshot/t-17/2026-05-05/10-00-10-30
  source_refs:
    - day_off/e-17/rule-v12
    - schedule/t-17/2026-05-05/10-00
    - off/t-17/break-1030
}
```

### Preserved

- status
- constraint values
- source refs
- source summary hash
- horizon
- rule version
- route snapshot ref

### Compactable

- raw geo details already covered by RouteSegmentSnapshot
- scoring scratch values
- repeated schedule reads not referenced by snapshot

### Downgrade

AvailabilitySnapshot is downgraded to `:provisional` if:

- route snapshot exists but was produced under conditional VerificationReport
- runtime/TBackend refs are synthetic
- some source refs are compacted but covered by trusted snapshot
- `as_of` is fixed but rule_version is `:latest`

### Block

AvailabilitySnapshot is blocked if:

- tenant scope is missing
- schedule/off_schedule refs cannot resolve and no boundary covers them
- route snapshot is required but missing
- raw GeoSignal was compacted before RouteSegmentSnapshot was emitted

## Fixture D: DailyTechnicianBoundary

Purpose: close a technician/day window and establish the compaction root.

### Inputs

```text
inputs:
  technician_id: tech/t-17
  company_id: company/acme
  day: 2026-05-05
  geo_stream_ref: geo_stream/t-17/2026-05-05
  route_segment_snapshot_refs:
    - route_snapshot/t-17/2026-05-05/10-00-10-30
  availability_snapshot_refs:
    - availability/t-17/o-930/2026-05-05T10-42-00Z
  schedule_refs:
    - schedule/t-17/2026-05-05/*
  off_schedule_refs:
    - off/t-17/*
  dispatch_decision_refs:
    - dispatch_decision/o-930/2026-05-05T10-42-00Z
```

### Output

```text
DailyTechnicianBoundary = {
  boundary_id: daily_boundary/company-acme/t-17/2026-05-05
  lifecycle: T.audit
  close_status: :trusted
  closed_at: 2026-05-05T17:10:00Z
  window: 2026-05-05T09:00:00Z..2026-05-05T17:00:00Z
  source_counts:
    geo_signals: 288
    schedules: 8
    off_schedules: 2
    availability_snapshots: 5
    route_segment_snapshots: 12
    dispatch_decisions: 3
  boundary_hash: hash(all source refs + snapshot refs)
  compaction_allowed_after: 2026-05-07T17:10:00Z
}
```

### Links

```text
links:
  - rel: :materializes, ref: geo_stream/t-17/2026-05-05
  - rel: :depends_on, ref: route_snapshot/t-17/2026-05-05/10-00-10-30
  - rel: :depends_on, ref: availability/t-17/o-930/2026-05-05T10-42-00Z
  - rel: :caused_by, ref: shift_closed/t-17/2026-05-05
```

### Preserved

- boundary receipt
- source counts and hashes
- snapshot refs
- dispatch decision refs
- compaction eligibility time

### Compactable After Detail Retain

- raw GeoSignal payloads
- non-anomalous provider metadata
- live availability projection duplicates
- route calculation scratch

### Must Stay Open

Boundary must stay open if:

- shift is not closed
- any dispatch decision is pending assignment receipt
- any route anomaly is unresolved
- any notification failure is unresolved and depends on raw signal evidence
- source count/hash cannot be computed

[D] DailyTechnicianBoundary is the primary permission to compact raw telemetry.
Without it, raw window facts must be retained or promoted.

## Fixture E: Compacted Stubs

Purpose: show that compaction is not deletion.

### Inputs

```text
inputs:
  compaction_policy:
    strategy: :ttl
    before_time: 2026-05-07T17:10:00Z
    preserve:
      - daily_boundary/company-acme/t-17/2026-05-05
      - dispatch_decision/o-930/2026-05-05T10-42-00Z
      - availability/t-17/o-930/2026-05-05T10-42-00Z
  target_refs:
    - geo/g-001
    - geo/g-002
    - geo/g-003
```

### Output

```text
CompactionReceipt = {
  compaction_id: compact/geo/company-acme/t-17/2026-05-05
  lifecycle: T.audit
  removed_payload_count: 288
  preserved_stub_count: 288
  boundary_ref: daily_boundary/company-acme/t-17/2026-05-05
  new_baseline_cursor:
    anchor: :timestamp
    position: 2026-05-05T17:10:00Z
  status: :ok
}
```

Each raw signal becomes a stub:

```text
CompactedStub = {
  original_obs_id: geo/g-001
  lifecycle: T.compacted
  payload_policy: :hashed
  content_hash: hash(original geo payload)
  lifecycle_ref: compact/geo/company-acme/t-17/2026-05-05
  covered_by:
    - route_snapshot/t-17/2026-05-05/10-00-10-30
    - daily_boundary/company-acme/t-17/2026-05-05
}
```

### Preserved

- original ObsId
- content_hash
- lifecycle_ref to CompactionReceipt
- boundary coverage refs
- snapshot coverage refs

### Removed

- raw point payload
- exact provider metadata
- precise path detail not required by audit policy

### Downgrade

Compaction downgrades future exact replay to `:partial` when:

- raw point payload is gone
- RouteSegmentSnapshot covers dispatch explanation
- exact route reconstruction is no longer possible

### Block

Compaction is blocked when:

- no trusted DailyTechnicianBoundary exists
- no RouteSegmentSnapshot covers target raw points
- target raw point is explicitly linked by DispatchDecision audit trail
- raw point is under legal hold / audit lifecycle

## Fixture F: DispatchDecision Audit Trail

Purpose: preserve why technician t-17 was chosen for order o-930 after raw
telemetry is compacted.

### Inputs

```text
inputs:
  order_ref: order/o-930
  candidate_refs:
    - candidate/o-930/t-17
    - candidate/o-930/t-22
    - candidate/o-930/t-31
  selected_candidate_ref: candidate/o-930/t-17
  availability_snapshot_ref: availability/t-17/o-930/2026-05-05T10-42-00Z
  route_segment_snapshot_ref: route_snapshot/t-17/2026-05-05/10-00-10-30
  decision_horizon:
    as_of: 2026-05-05T10:42:00Z
    rule_version: dispatch_rules@42
    fact_scope:
      company_id: company/acme
      order_id: order/o-930
      technician_ids: [tech/t-17, tech/t-22, tech/t-31]
```

### Output

```text
DispatchDecisionAuditTrail = {
  decision_ref: dispatch_decision/o-930/2026-05-05T10-42-00Z
  lifecycle: T.audit
  selected_candidate_ref: candidate/o-930/t-17
  rejected_candidate_refs:
    - candidate/o-930/t-22
    - candidate/o-930/t-31
  selected_reason:
    service_match: true
    zone_match: true
    status: :available
    distance_band: :near
    eta_band: :lt_30m
  rejected_reasons:
    candidate/o-930/t-22: schedule_conflict
    candidate/o-930/t-31: out_of_zone
  availability_snapshot_refs:
    - availability/t-17/o-930/2026-05-05T10-42-00Z
  route_segment_snapshot_refs:
    - route_snapshot/t-17/2026-05-05/10-00-10-30
  runtime_contract_ref: obs/runtime/local-inline-v0
  axiom_descriptor_ref: obs/axiom/core-v0
  tbackend_descriptor_ref: obs/tbackend/file-or-ledger-v0
  semantic_image_ref: obs/image/dispatch-session-2026-05-05-t17
  compatibility_report_ref: obs/compat/dispatch-session-2026-05-05-t17
}
```

### Preserved

- selected candidate and rejected candidates
- availability and route snapshots
- decision horizon
- rule version
- runtime/axiom/TBackend refs
- SemanticImage and CompatibilityReport refs
- assignment/notification/route receipts when produced

### Not Required After Boundary

- all raw geo payloads
- scoring scratch
- repeated live projection frames
- exact provider response bodies, unless receipt/failure requires them

[D] The audit trail must preserve rejected-candidate reasons. Keeping only the
selected technician is not enough to explain dispatch.

## End-To-End Fixture States

### State 1: Live Before Decision

```text
GeoSignal stream: open
RouteSegmentSnapshot: partial
AvailabilitySnapshot: live
DailyTechnicianBoundary: open
DispatchDecision: none
meaning_status: :live
allowed action: inspect / suggest
```

Compaction: blocked. The boundary is open and no pinned decision exists.

### State 2: Pinned Decision Before Boundary Close

```text
GeoSignal stream: open
RouteSegmentSnapshot: present for selected horizon
AvailabilitySnapshot: pinned
DailyTechnicianBoundary: open
DispatchDecision: audit root
AssignmentReceipt: present
meaning_status: :reproducible for decision horizon if raw refs still resolve
allowed action: assign / audit
```

Compaction: blocked for raw signals used by the open day boundary, but the
decision itself is audit-preserved.

### State 3: Boundary Closed, Detail Retain Active

```text
DailyTechnicianBoundary: trusted
RouteSegmentSnapshot: trusted
AvailabilitySnapshot: trusted
GeoSignal raw payloads: retained until detail_retain expires
meaning_status: :reproducible
allowed action: audit / resume
```

Compaction: not yet; detail retain period is active.

### State 4: Boundary Closed, Raw Details Compacted

```text
DailyTechnicianBoundary: trusted
RouteSegmentSnapshot: trusted
AvailabilitySnapshot: trusted
GeoSignal: compacted stubs
CompactionReceipt: present
DispatchDecisionAuditTrail: present
meaning_status: :reproducible for dispatch explanation
exact raw replay: :partial or unavailable
```

Compaction: complete. Reproducibility remains for decision meaning, not for
exact GPS reconstruction.

### State 5: Snapshot Missing After Compaction

```text
GeoSignal: compacted stubs
RouteSegmentSnapshot: missing
AvailabilitySnapshot: missing or incomplete
DailyTechnicianBoundary: trusted but source coverage incomplete
DispatchDecisionAuditTrail: links to missing availability
meaning_status: :stale or :unknown
ResumeStatus: :blocked if replay needed
```

Compaction outcome: invalid for reproducible dispatch. Apply PROP-010 DR-4 and
DR-5.

### State 6: Migration Before Boundary Close

```text
DailyTechnicianBoundary: open
SemanticImage: checkpointed
CompatibilityReport: required
GeoSignal raw payloads: preserved
replay_cursor: preserved
meaning_status: :provisional until CompatibilityReport passes
```

Compaction: blocked before migration. Migration cannot move the backend
baseline past open replay cursors.

## Reproducibility Outcomes

| Fixture condition | Decision outcome |
|-------------------|------------------|
| raw refs available, snapshots present, trusted CompatibilityReport | reproducible |
| raw refs compacted, trusted snapshots cover decision horizon | reproducible for decision meaning, partial for exact raw replay |
| raw refs compacted, snapshots missing | blocked for resume/replay |
| boundary open | live/provisional |
| boundary closed but detail retain active | reproducible, compaction pending |
| CompatibilityReport provisional | provisional even if snapshots exist |
| tenant scope missing | blocked / OOF |
| rejected candidates missing | audit incomplete, downgraded |
| assignment receipt missing | action incomplete, blocked for mutation audit |

[D] "Reproducible" must name the scope. A decision can be reproducible as a
business/audit decision while exact raw telemetry replay is no longer available.

## Fixture Acceptance Criteria

A boundary fixture is valid when it can answer:

1. Which raw observations entered the boundary?
2. Which snapshot(s) summarize them?
3. Which boundary receipt authorizes compaction?
4. Which compacted stubs preserve content identity?
5. Which audit trail explains the dispatch decision?
6. Which observations are semantic GC roots?
7. Which observations are compactable?
8. Which reproduction scope is still valid after compaction?
9. Which condition downgrades or blocks resume?
10. Which tenant/company scope guards the fixture?

## Rejected Paths

[X] Fixture with raw GeoSignals compacted before RouteSegmentSnapshot exists.

[X] Fixture with DailyTechnicianBoundary closed without source counts/hashes.

[X] Fixture with DispatchDecision audit trail that omits rejected candidates.

[X] Fixture with tenant scope outside the projection horizon.

[X] Fixture that treats compacted stubs as deleted observations.

[X] Fixture that claims exact GPS replay after raw payload compaction.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/docs/tracks/temporal-lifecycle-boundary-fixtures-v0.md
Status: done

[D] Decisions:
- Boundary fixtures must show a complete coverage chain:
  GeoSignal -> RouteSegmentSnapshot -> AvailabilitySnapshot ->
  DailyTechnicianBoundary -> compacted stubs -> DispatchDecision audit trail.
- Compaction is allowed only after trusted boundary close and detail retain,
  unless policy explicitly preserves raw data longer.
- Compacted stubs are not deletion. They preserve ObsId, content_hash,
  lifecycle_ref, and snapshot/boundary coverage links.
- Dispatch reproducibility is scoped: decision meaning can remain reproducible
  after exact raw telemetry replay becomes partial or unavailable.
- Missing snapshots after raw compaction block resume/replay for decisions that
  need those inputs.

[R] Recommendations:
- Use these fixtures as golden cases for future sidecar packet builders.
- Add negative fixtures for missing route snapshot, missing rejected candidate
  reasons, missing tenant scope, and migration before boundary close.
- Require every DispatchDecision audit trail to include selected and rejected
  candidate reasons.
- Make reproducibility assertions name their scope: decision meaning vs exact
  raw telemetry replay.

[S] Signals:
- Boundary fixtures make PROP-010 DR-4/DR-5 concrete and testable.
- The daily technician boundary is the natural compaction permission for raw
  mobility data.
- RouteSegmentSnapshot is the privacy-preserving middle layer between raw GPS
  and audit explanations.

[Q] Open Questions:
- Should exact route reconstruction ever be audit-required, or is route segment
  meaning enough for most dispatch domains?
- How much source count/hash detail should DailyTechnicianBoundary expose?
- Should compacted stubs be grouped by stream or emitted per observation?
- Should migration fixtures preserve raw telemetry until target backend passes
  CompatibilityReport?

[Next] Proposed next slice:
- `igniter-lang/docs/tracks/bridge-packet-builder-golden-fixtures-v0.md`
  using these boundary fixtures as expected sidecar packet profiles.
```
