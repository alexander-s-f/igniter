# Track: Temporal Lifecycle Application Scenarios v0

Status: done
Slice state: done on 2026-05-05
Owner: `[Igniter-Lang Research Agent]`
Supervisor: `[Architect Supervisor / Codex]`

## Frame

This slice pressure-tests temporal lifecycle semantics with a concrete app:
Spark CRM technician dispatch.

The goal is not Spark implementation design. The goal is to model where
Igniter-Lang `T` must preserve meaning and where it must allow bounded
retention, flush, semantic GC, snapshots, and compaction.

This is a hypothetical Igniter-Lang application model:

- no package code
- no Spark CRM code changes
- no final syntax promise
- no Ledger-specific solution
- no assumption that all facts live forever

## Source Horizon

- `igniter-lang/docs/temporal-lifecycle.md`
- `igniter-lang/docs/runtime-machine.md`
- `igniter-lang/docs/proposals/PROP-008-tbackend-contract-v0.md`
- `igniter-lang/docs/proposals/PROP-009-semantic-image-resume-compatibility-v0.md`
- `igniter-lang/docs/proposals/PROP-010-temporal-lifecycle-retention-semantics-v0.md`
- `igniter-lang/docs/tracks/temporal-contracts-and-projections-v0.md`
- `igniter-lang/docs/tracks/runtime-machine-lifecycle-v0.md`
- `igniter-lang/docs/tracks/bridge-observation-envelope-implementation-plan-v0.md`

## Compact Claim

[D] A dispatch app proves that temporal semantics cannot mean "store every
observation forever."

Spark CRM has high-frequency live signals and long-lived business/audit facts:

```text
GeoSignal / vendor / telephony / lead streams
  -> short retention windows
  -> route and availability snapshots
  -> boundary receipts
  -> compacted stubs

DispatchDecision / AssignmentReceipt / approval evidence
  -> durable/audit retention
  -> explainable action rights
```

[D] The language must preserve decision meaning, not raw detail by default.
Raw signals are retained while they can change availability, explain an open
order, or support a boundary. After the boundary closes, snapshots and audit
receipts become the semantic roots.

## Domain Model

Spark CRM domain pressure:

- Employee belongs to a company/user.
- An employee may be a technician.
- Technicians have services, zones, locations, schedules, off schedules, and
  mostly stable weekly availability config.
- Orders occupy schedule slots.
- Geo/vendor/telephony/lead signals may arrive frequently.
- Dispatch decisions must explain why a technician was available, chosen, or
  rejected.
- Business/audit facts must outlive raw telemetry.

## Contract Sketch

This is non-final syntax. It names contracts and payload shapes only.

```text
contract Technician do
  input employee_id: EmployeeId
  output technician_id: TechnicianId
  output company_id: CompanyId
  output services: Set[ServiceId]
  output zones: Set[ZoneId]
  output active: Bool
end
```

```text
contract Order do
  input order_id: OrderId
  output company_id: CompanyId
  output service_id: ServiceId
  output customer_location: GeoPoint
  output requested_window: TimeRange
  output status: :new | :scheduled | :in_progress | :completed | :cancelled
  output priority: :normal | :urgent | :emergency
end
```

```text
contract ScheduleSlot do
  input technician_id: TechnicianId
  input slot_id: SlotId
  output order_id: Option[OrderId]
  output window: TimeRange
  output status: :open | :held | :assigned | :completed | :cancelled
end
```

```text
contract OffSchedule do
  input technician_id: TechnicianId
  input off_schedule_id: OffScheduleId
  output window: TimeRange
  output reason: :break | :day_off | :early_leave | :manual_block | :system_block
  output source: :technician | :dispatcher | :policy | :integration
end
```

```text
contract DayOffConfig do
  input employee_id: EmployeeId
  output weekly_rules: Collection[WeeklyAvailabilityRule]
  output effective_from: Date
  output rule_version: VersionRef
end
```

```text
contract GeoSignal do
  input technician_id: TechnicianId
  input observed_at: Timestamp
  output point: GeoPoint
  output accuracy_m: Option[Int]
  output source: :mobile_app | :vehicle | :vendor | :manual
end
```

```text
contract AvailabilityProjection do
  input technician_id: TechnicianId
  input dispatch_window: TimeRange
  input horizon: ProjectionHorizon
  output status: :available | :busy | :off | :out_of_zone | :unknown
  output reasons: Collection[ConstraintRef]
  output snapshot_ref: Option[SnapshotRef]
end
```

```text
contract DispatchCandidate do
  input order_id: OrderId
  input technician_id: TechnicianId
  output eligible: Bool
  output rank: Int
  output score_factors:
    service_match: Bool
    zone_match: Bool
    availability_status: AvailabilityStatus
    distance_band: :near | :regional | :remote | :unknown
    conflict_refs: Collection[ObsId]
end
```

```text
contract DispatchDecision do
  input order_id: OrderId
  input candidates: Collection[DispatchCandidate]
  input decision_horizon: ProjectionHorizon
  output selected_technician_id: Option[TechnicianId]
  output rejected_candidates: Collection[RejectedCandidate]
  output reason: :best_available | :manual_override | :no_available_tech
  output audit_ref: ObsId
end
```

```text
contract AssignmentReceipt do
  input decision_ref: ObsId
  input order_id: OrderId
  input technician_id: TechnicianId
  output assignment_id: AssignmentId
  output status: :accepted | :rejected | :deduplicated | :failed
  output notification_refs: Collection[ObsId]
  output route_refs: Collection[ObsId]
end
```

```text
contract NotificationReceipt do
  input assignment_id: AssignmentId
  output channel: :sms | :push | :email | :voice | :vendor
  output status: :sent | :delivered | :failed | :skipped
  output provider_ref: Option[ExternalRef]
end
```

```text
contract RouteReceipt do
  input assignment_id: AssignmentId
  output route_segment_ref: Option[SnapshotRef]
  output eta_band: :lt_15m | :lt_30m | :lt_60m | :unknown
  output status: :planned | :sent | :failed
end
```

## Dispatch Flow

```text
Order + Technician + DayOffConfig + ScheduleSlot + OffSchedule + GeoSignal
  -> AvailabilityProjection[technician, window]
  -> DispatchCandidate[order, technician]
  -> DispatchDecision[order]
  -> AssignmentReceipt
  -> NotificationReceipt / RouteReceipt
```

The live view and the decision view are different slices:

```text
technician_availability_live
  horizon.as_of: :latest
  lifecycle: T.window
  action: inspect / suggest

dispatch_decision_pinned
  horizon.as_of: decision_time
  lifecycle: T.audit
  action: assign / approve / audit
```

[D] Availability is naturally live. Assignment must be pinned.

## Temporal Lifecycle Classification

| Material | Lifecycle | Why |
|----------|-----------|-----|
| distance calculation intermediates | `T.local` | useful only during one evaluation |
| rank/score scratch values | `T.local` | recomputable from preserved inputs or snapshots |
| provider API raw response body | `T.local` / `T.session` | keep only if failure or receipt needs it |
| runtime resolution trace | `T.session` | explains one RuntimeMachine session |
| live availability projection | `T.session` / `T.window` | useful while screen/session/window is open |
| raw GeoSignal | `T.window` | high-frequency; decision-relevant for a bounded window |
| telephony/vendor/lead signals | `T.window` | high-volume; compact into source summaries |
| OffSchedule slot | `T.window` / `T.durable` | dynamic business fact; preserve while slot/order can be disputed |
| ScheduleSlot assignment | `T.durable` | business state; survives restarts |
| Order | `T.durable` | business state and customer obligation |
| Technician profile/services/zones | `T.durable` | business state, slowly changing |
| DayOffConfig version | `T.durable` | mostly stable policy input |
| AvailabilitySnapshot | `T.compacted` / `T.audit` | closes availability meaning for a window |
| RouteSegmentSnapshot | `T.compacted` | replaces high-frequency geo details |
| DispatchDecision | `T.audit` | explanation and action rights |
| AssignmentReceipt | `T.audit` | proves mutation/effect |
| Notification/Route receipt | `T.audit` | proves external action or failure |
| SemanticImage for dispatch session | `T.session` / `T.audit` | audit when linked to decision/receipt |
| CompatibilityReport for resume/migration | `T.audit` when used for action | gates reproducibility |

### T.local

`T.local` covers values that can be discarded after one evaluation/request:

- candidate scoring scratch
- route ETA probe details not used in a receipt
- cache fills
- intermediate constraints that are not linked from failure/decision evidence

If a local value is linked by a failure or decision, PROP-010 DR-1 promotes it
to `T.session`.

### T.session

`T.session` covers the RuntimeMachine session:

- resolution trace
- live candidate list seen by a dispatcher
- provisional diagnostics
- cache invalidation evidence
- pending tokens for notifications or route providers

At checkpoint, only refs/hashes enter `SemanticImage`; raw payloads stay under
their lifecycle policy.

### T.window

`T.window` is the workhorse for Spark-like dispatch:

- technician shift
- order lifecycle
- daily route segment window
- off-schedule window
- high-frequency signal window

Window material can be compacted only after a trusted boundary receipt and
detail retention TTL.

### T.durable

`T.durable` is app business state:

- orders
- schedule slots
- technician profile/services/zones
- DayOffConfig versions
- assigned order facts

Durable facts do not compact unless migrated with receipt.

### T.audit

`T.audit` is explanation and responsibility:

- DispatchDecision
- AssignmentReceipt
- capability/approval evidence
- NotificationReceipt / RouteReceipt
- decision-linked SemanticImage
- decision-linked CompatibilityReport
- legally significant failure observations

Audit observations can be archived, not compacted away.

### T.compacted

`T.compacted` is the witness after raw detail is replaced:

- raw GeoSignal stubs with content_hash
- RouteSegmentSnapshot
- AvailabilitySnapshot
- DailyTechnicianBoundary
- OrderBoundary

The compacted stub remains resolvable by ObsId/content_hash.

## Retention And Flush Model

| Moment | Flush / retention action | Required evidence |
|--------|--------------------------|-------------------|
| after evaluation/request | discard unlinked `T.local`; promote linked failures to `T.session` | FlushReceipt or local runtime diagnostic |
| after runtime session | checkpoint SemanticImage; persist session refs/cursors; discard unlinked traces | SemanticImage + Checkpoint |
| after technician shift/day | close DailyTechnicianBoundary; snapshot availability and route segments; start detail TTL | BoundaryReceipt + SnapshotRefs |
| after order completion | close OrderBoundary; preserve decision/assignment/notification receipts; compact open telemetry details after TTL | OrderBoundary + receipts |
| after month/year boundary | archive audit roots; compact closed windows into summaries; keep business/audit refs resolvable | ArchiveReceipt + CompactionReceipt |
| before backend/runtime migration | freeze SemanticImages; compute CompatibilityReports; block compaction of required cursors/snapshots | CompatibilityReport + migration plan |

### After Evaluation / Request

```text
flush(after_evaluation):
  discard T.local scratch
  preserve failure-linked evidence
  persist decision-linked refs
  downgrade live projections if required refs are absent
```

The request result may show live availability, but assignment still requires a
pinned decision slice.

### After Runtime Session

```text
flush(after_session):
  emit SemanticImage
  emit Checkpoint
  persist replay_cursor or snapshot_ref
  discard unlinked session trace
```

If the session included a DispatchDecision or AssignmentReceipt, the related
SemanticImage becomes `T.audit` or at least a preserve root for the audit
horizon.

### After Technician Shift / Day

```text
close DailyTechnicianBoundary:
  raw GeoSignal[technician, day]
  + OffSchedule[technician, day]
  + ScheduleSlot[technician, day]
  -> RouteSegmentSnapshot
  -> AvailabilitySnapshot
  -> DailyTechnicianBoundary receipt
```

Raw geo may remain for 24-72h after close, then compact to stubs when the
boundary is trusted.

### After Order Completion

```text
close OrderBoundary:
  order facts
  + candidate decisions
  + assignment receipt
  + notifications/routes
  -> OrderBoundary receipt
```

Open disputes, failed notifications, missing route receipts, or unresolved
capability questions block compaction.

### Month / Year Boundary

Monthly/yearly jobs are not silent storage cleanup. They are semantic lifecycle
operations:

```text
archive audit roots
compact closed telemetry windows
preserve business facts and receipts
emit CompactionReceipt / ArchiveReceipt
update replay baselines
```

### Before Backend / Runtime Migration

Before migration:

- preserve all active SemanticImages
- preserve checkpoints for open orders and active shifts
- emit CompatibilityReport for target runtime/backend
- block compaction when replay cursors are still required
- downgrade or block resume when snapshots do not cover compacted detail

## Semantic GC Roots

### Must Preserve

| Root | Reason |
|------|--------|
| AxiomDescriptor / RuntimeContract / TBackendDescriptor | defines meaning of decisions |
| contract descriptors and rule versions | explain which rules produced availability |
| DispatchDecision | audit/action root |
| AssignmentReceipt | proves mutation |
| NotificationReceipt / RouteReceipt | proves external effects |
| approval/capability receipts | authorization chain |
| OrderBoundary while order is open or disputed | business lifecycle root |
| DailyTechnicianBoundary while shift/day is open | window lifecycle root |
| latest SemanticImage linked to open work | resume root |
| CompatibilityReport used for migration/resume | trust root |
| failure evidence for unresolved failures | remediation root |

### Can Discard

| Material | Condition |
|----------|-----------|
| score scratch | not linked from decision/failure |
| cache fills | source facts/snapshots remain available |
| provider response body | receipt contains safe summary/hash |
| live diagnostics | no open failure and no audit link |
| old provisional candidate list | superseded and not pinned |

### Can Compact

| Material | Compact into |
|----------|--------------|
| raw GeoSignal | RouteSegmentSnapshot + compacted stubs |
| high-frequency vendor pings | VendorSignalSummary + compacted stubs |
| telephony event detail | NotificationAttemptSummary + receipt refs |
| lead signal stream | LeadSignalBoundary |
| availability raw inputs for a day | AvailabilitySnapshot + DailyTechnicianBoundary |
| closed order intermediate traces | OrderBoundary + DispatchDecision audit trail |

### Must Block Compaction Until Closed

| Open state | Why |
|------------|-----|
| open order | assignment may still be disputed or changed |
| active shift/day boundary | availability may still be recalculated |
| unresolved failed notification | provider evidence may be needed |
| route mismatch/failure | route detail may explain delay |
| pending off schedule | may change availability claims |
| active replay cursor | resume still depends on raw observations |
| untrusted CompatibilityReport | migration cannot prove safety |

[D] The GC question is not "is this old?" It is "is this still a root for
action, audit, resume, or boundary closure?"

## Boundary Model

Boundaries close raw temporal surfaces into durable semantic surfaces.

### DailyTechnicianBoundary

Purpose: close one technician/day or technician/shift.

```text
DailyTechnicianBoundary = {
  technician_id
  company_id
  day
  schedule_refs
  off_schedule_refs
  route_segment_snapshot_refs
  availability_snapshot_refs
  dispatch_decision_refs
  compaction_policy_ref
}
```

It preserves:

- which schedule/off-schedule facts were visible
- which availability snapshots were emitted
- which route segment summaries replaced raw geo
- which dispatch decisions relied on the day

After trusted close, raw GeoSignal details can compact to stubs because
availability and route meaning are preserved by snapshots.

### OrderBoundary

Purpose: close one order lifecycle.

```text
OrderBoundary = {
  order_id
  company_id
  requested_window
  candidate_projection_ref
  dispatch_decision_ref
  selected_technician_ref
  assignment_receipt_ref
  notification_receipt_refs
  route_receipt_refs
  completion_or_cancel_ref
}
```

It preserves:

- why a technician was chosen or rejected
- which order state was visible
- which assignment/effect receipts exist
- which route/notification proofs exist

Raw candidate traces can compact after this boundary if the decision audit
trail is complete.

### AvailabilitySnapshot

Purpose: preserve availability meaning for a horizon.

```text
AvailabilitySnapshot = {
  technician_id
  horizon:
    as_of
    rule_version
    fact_scope
    replay_cursor | snapshot_ref
  status
  constraints
  source_summary_hash
}
```

It does not need every raw geo point. It needs enough summary/hashes/links to
explain why status was available, busy, off, out_of_zone, or unknown.

### RouteSegmentSnapshot

Purpose: summarize raw movement signals.

```text
RouteSegmentSnapshot = {
  technician_id
  window
  source_count
  path_hash
  start_point_hash
  end_point_hash
  distance_band
  eta_band
  anomaly_refs
}
```

It can replace raw high-frequency GeoSignal details for most dispatch audit
needs while keeping content-addressed stubs for verification.

### DispatchDecision Audit Trail

Purpose: preserve the actual action explanation.

```text
DispatchDecisionAuditTrail = {
  decision_ref
  order_ref
  selected_candidate_ref
  rejected_candidate_refs
  availability_snapshot_refs
  rule_version
  decision_horizon
  runtime_contract_ref
  axiom_descriptor_ref
  tbackend_descriptor_ref
  capability_receipt_refs
}
```

[D] The audit trail is the durable meaning root. Raw telemetry supports it
temporarily; boundaries let raw details expire without erasing why the decision
was made.

## Reproducibility Model

### Reproducible Dispatch Decision

A dispatch decision is reproducible when:

```text
fixed(decision_horizon.as_of)
fixed(decision_horizon.rule_version)
bounded(decision_horizon.fact_scope)
runtime_contract_ref present
axiom_descriptor_ref present
tbackend_descriptor_ref present
SemanticImage present
CompatibilityReport.resume_status = :trusted
raw evidence available OR trusted snapshots cover compacted evidence
```

In this state, a later auditor can ask:

- which facts were visible?
- which schedule/off-schedule windows applied?
- which route/availability snapshot was used?
- which candidates were rejected and why?
- which runtime/backend semantics were in force?

### Live / Provisional

A dispatch result is live/provisional when:

- `as_of: :latest`
- raw geo is moving
- off_schedules can still change
- route/vendor/telephony provider receipt is pending
- RuntimeContract or TBackendDescriptor is synthetic/missing
- CompatibilityReport is `:provisional` or `:downgraded`
- high-frequency cursor is live/ring-buffer only

Live/provisional is valid for dashboards and suggestions. It is not enough for
assignment without pinning.

### Stale / Blocked

A dispatch result is stale or blocked when:

- a newer OffSchedule invalidates the selected window
- the order was reassigned/cancelled/completed
- the replay cursor was compacted and no snapshot covers the gap
- a required audit receipt cannot be resolved
- CompatibilityReport is `:blocked`
- target runtime/backend is incompatible
- tenant isolation cannot be proven

### SemanticImage And CompatibilityReport With Retention

Retention changes resume semantics:

```text
raw evidence retained
  -> replay_availability compatible
  -> possible :trusted resume

raw evidence compacted but trusted snapshot exists
  -> replay_availability downgrade or compatible by policy
  -> :trusted or :provisional depending on snapshot coverage

raw evidence compacted and no covering snapshot
  -> replay_availability blocked
  -> ResumeStatus: :blocked
```

[D] SemanticImage stores refs and hashes. CompatibilityReport decides whether
those refs still resolve directly or through trusted boundaries/snapshots.

## DSL Pressure

This syntax is intentionally non-final. It is only pressure vocabulary.

### retention

```text
contract GeoSignal do
  retention lifecycle: :window,
            raw_ttl: "72h",
            boundary: :daily_technician,
            compact_to: :route_segment_snapshot
end
```

### flush

```text
runtime DispatchRuntime do
  flush after: :evaluation, discard: :local
  flush after: :session, checkpoint: :semantic_image
  flush after: :business_boundary, compact: :eligible_windows
end
```

### preserve

```text
contract DispatchDecision do
  preserve :decision_ref,
           :assignment_receipt,
           :availability_snapshot,
           :runtime_evidence,
           as: :audit
end
```

### boundary

```text
boundary DailyTechnicianBoundary do
  key [:company_id, :technician_id, :day]
  close_on :day_end
  includes :schedules, :off_schedules, :route_segments, :availability
  emits :availability_snapshot, :route_segment_snapshot
end
```

### compact

```text
compact GeoSignal do
  when boundary(:daily_technician).trusted?
  after detail_retain("48h")
  keep :content_hash, :source_count, :route_segment_snapshot
end
```

### audit

```text
audit DispatchDecision do
  require :decision_horizon
  require :selected_candidate
  require :rejected_candidates
  require :assignment_receipt
  require :runtime_contract
  require :compatibility_report
end
```

[D] The stable semantic need is not these keywords. The stable need is:
lifecycle class, retention policy, flush scope, preserve roots, boundary
closure, compaction receipt, and audit roots.

## Risks And Questions

### Privacy And PII

Technician location, customer address, calls, and lead signals are PII-heavy.

[R] Default raw signal payloads should be `:hashed`, `:redacted`, or
short-window `:present` with strict retention. Audit should preserve why a
decision was made, not expose all personal movement data forever.

### High-Frequency Telemetry

GeoSignal volume grows quickly. The app needs route/availability meaning, not
permanent raw telemetry.

[R] Use `T.window -> RouteSegmentSnapshot -> compacted stubs` as the default.

### Legal / Audit Retention

Some industries may require long retention of assignment, notification, and
customer contact evidence.

[Q] Which fields are legal audit roots versus operational audit roots? This is
likely jurisdiction and contract dependent.

### Replay Cost

Full replay of a month of raw telemetry is too expensive.

[R] Prefer boundary snapshots with content hashes and replay baselines. Full
raw replay should be a short-window capability, not the default audit path.

### Partial Retention Breaking Reproducibility

If raw facts compact before snapshots exist, reproducibility is false.

[R] Apply PROP-010 DR-4 and DR-5: downgrade when snapshots cover the gap, block
when they do not.

### Cross-Company Tenancy Isolation

Spark CRM is multi-tenant. Fact scope must include company/user boundaries.

[D] A projection whose `fact_scope` crosses company boundaries without an
explicit policy is OOF for dispatch. Tenant isolation is a reproducibility and
privacy precondition, not a filter after the fact.

## Rejected Paths

[X] Store all GeoSignals forever as language meaning.

[X] Delete raw telemetry without boundary receipt.

[X] Treat live availability as sufficient for assignment.

[X] Preserve only the selected technician and discard rejected-candidate
reasons.

[X] Let migration compact replay cursors before CompatibilityReport.

[X] Use Ledger-specific retention as the language model.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/docs/tracks/temporal-lifecycle-application-scenarios-v0.md
Status: done

[D] Decisions:
- Spark CRM technician dispatch validates six lifecycle classes in practice:
  T.local, T.session, T.window, T.durable, T.audit, T.compacted.
- High-frequency telemetry is windowed meaning, not permanent language memory.
- DispatchDecision, AssignmentReceipt, Notification/Route receipts, runtime
  evidence, and compatibility evidence are audit roots.
- DailyTechnicianBoundary and OrderBoundary are the core business containers
  that let raw detail compact without erasing decision meaning.
- A dispatch decision is reproducible only when pinned horizon, runtime/axiom/
  TBackend refs, SemanticImage, CompatibilityReport, and raw-or-snapshot
  evidence all line up.

[R] Recommendations:
- Treat Spark CRM dispatch as the reference practical scenario for retention,
  flush, semantic GC, and boundary semantics.
- Next bridge/package work should model golden fixtures for raw signal ->
  snapshot -> boundary -> compacted stub -> audit decision.
- Preserve rejected-candidate reasons, not only selected assignment.
- Keep tenant/company scope as a mandatory projection horizon field.

[S] Signals:
- PROP-010's lifecycle classes map cleanly to real dispatch pressure.
- The important product split is live availability vs pinned dispatch decision.
- Boundary snapshots are the answer to "not everything forever" without losing
  explainability.

[Q] Open Questions:
- Which legal regimes require raw location retention versus hash-only witness?
- How much candidate detail must be kept for rejected technicians?
- Should off_schedules become durable facts, window facts, or durable facts
  with compacted daily boundaries?
- What is the minimum RouteSegmentSnapshot needed to explain ETA/routing?
- Where should tenant isolation live in the type system: ProjectionHorizon,
  fact_scope, capability policy, or all three?

[Next] Proposed next slice:
- `igniter-lang/docs/tracks/temporal-lifecycle-boundary-fixtures-v0.md`
  defining concrete fixture cases for DailyTechnicianBoundary, OrderBoundary,
  AvailabilitySnapshot, RouteSegmentSnapshot, and DispatchDecision audit trail.
```
