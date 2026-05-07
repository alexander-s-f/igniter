# Track: SparkCRM History Pressure v0

Role: `[Igniter-Lang Applied Pressure Agent]`
Track: `igniter-lang/docs/tracks/sparkcrm-history-pressure-v0.md`
Status: done
Slice state: done on 2026-05-07
Affected neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`

## Frame

This track pressure-tests `History[T]`, `BiHistory[T]`, temporal projections,
retention, and diagnostics against Spark CRM operational realities.

Safety boundary:

- synthetic operational facts only;
- no real Spark CRM records, customers, phones, emails, endpoints, vendor
  payloads, credentials, tokens, provider config, queue names, or infrastructure
  details;
- Spark-shaped business logic is used only as applied pressure.

Source horizon:

- `igniter-lang/docs/README.md`
- `igniter-lang/docs/operating-model.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/proposals/PROP-022-history-type-constructor-v0.md`
- `igniter-lang/docs/tracks/history-type-proof-planning-v0.md`
- `igniter-lang/docs/tracks/spark-technician-availability-fixture-v0.md`
- `igniter-lang/docs/tracks/spark-lead-signal-boundary-fixture-v0.md`
- `igniter-lang/docs/tracks/spark-operation-action-lifecycle-fixture-v0.md`
- `igniter-lang/source/tenant_availability_projection.ig`
- `igniter-lang/source/vendor_lead_pipeline.ig`

Core applied claim:

```text
Spark CRM history pressure is not "show me old rows".

It is:
  what was true in the business world
  what did the system know at decision time
  what correction arrived later
  what projection did we emit
  what raw material can be compacted without losing explanation rights
```

[D] `History[T]` is useful for single-axis operational trends and bounded
point access. Spark CRM pressure needs `BiHistory[T]` quickly for decisions,
late signals, corrections, and audit because "valid at" and "recorded/known at"
often diverge.

## Scenario 1: Technician Availability Correction

Purpose: prove why a technician was available or unavailable at dispatch time,
then explain a later correction without rewriting the original decision.

Synthetic scope:

```text
company_id: company/fixture-acme
technician_id: tech/t-17
service_date: 2026-05-07
requested_window_local: 09:00..16:00
decision_at: 2026-05-07T09:30:00Z
report_at: 2026-05-07T13:00:00Z
timezone: America/New_York
```

History inputs:

| History | Type | Example content | Why it needs history |
|---------|------|-----------------|----------------------|
| `technician_profile_history` | `BiHistory[TechnicianProfile]` | active at decision time; later corrected to inactive after 15:00 local | availability and later audit must know which state was known when |
| `schedule_history` | `BiHistory[ScheduleSlotObservation]` | 10:00 planned appointment known at `decision_at`; later correction says it was canceled before visit | dispatch decision must remain explainable under old and corrected knowledge |
| `off_schedule_history` | `BiHistory[OffScheduleObservation]` | 12:00 blocked personal/off interval | raw off blocks are durable enough to explain why-not |
| `day_off_config_history` | `BiHistory[DayOffConfigVersion]` | 14:00 company policy day-off block version `cfg-3` | day-off rules are versioned facts, not ambient config |

Contract sketch:

```text
contract AvailabilityFromHistory {
  input company_id: String
  input technician_id: String
  input service_date: Date
  input decision_at: DateTime
  input report_at: DateTime

  escape history_read

  read schedule_history: BiHistory[ScheduleSlotObservation]
    from "spark/schedule_history"
    lifecycle :durable
    @bitemporal

  read off_schedule_history: BiHistory[OffScheduleObservation]
    from "spark/off_schedule_history"
    lifecycle :durable
    @bitemporal

  read day_off_config_history: BiHistory[DayOffConfigVersion]
    from "spark/day_off_config_history"
    lifecycle :audit
    @bitemporal

  compute schedules_as_decided =
    schedule_history[vt: day_window(service_date), tt: decision_at]

  compute schedules_corrected =
    schedule_history[vt: day_window(service_date), tt: report_at]

  compute availability_at_decision =
    project_availability(schedules_as_decided, off_schedule_history, day_off_config_history)

  compute corrected_availability =
    project_availability(schedules_corrected, off_schedule_history, day_off_config_history)

  output snapshot: AvailabilitySnapshot lifecycle :durable
  output correction_report: AvailabilityCorrectionReport lifecycle :audit
}
```

Expected projection table:

| Local slot | Known at decision | Corrected at report | Why-not at decision | Diagnostic |
|------------|-------------------|---------------------|---------------------|------------|
| 09:00 | free | free | available | none |
| 10:00 | planned schedule | canceled correction | busy | `availability.corrected_after_decision` |
| 11:00 | free | free | available | none |
| 12:00 | off schedule | off schedule | off | none |
| 13:00 | free | free | available | none |
| 14:00 | day-off config | day-off config | day_off | none |
| 15:00 | active technician | inactive correction | available | `technician.profile_correction_after_decision` |

Demands on `History[T]` / `BiHistory[T]`:

- `BiHistory[T]` range access over valid-time windows and explicit
  transaction-time axis.
- `at decision_at` must mean "as known then", not "as corrected now".
- Projection output must carry both source history refs and selected
  `(vt, tt)` query axes.
- `AvailabilitySnapshot` must be reproducible from history slices after raw
  schedule/off_schedule rows are compacted.
- Diagnostics must distinguish:
  - `history.axis_missing`
  - `history.gap_at_valid_time`
  - `history.corrected_after_decision`
  - `availability.projection_sources_compacted`

Retention pressure:

- `AvailabilitySnapshot` and dispatch explanation are `:audit` if used to
  justify assignment.
- schedule/off_schedule facts are `:durable`;
- geo and route signals can be `:window` then compacted into route or
  availability summaries;
- day-off policy versions are `:audit` when they influence why-not output.

## Scenario 2: Order / Schedule Lifecycle Audit

Purpose: separate visible action policy, executable authority, request receipt,
execution receipt, and schedule state history.

Synthetic scope:

```text
company_id: company/fixture-acme
order_id: order/fixture-o-300
schedule_id: schedule/fixture-s-300
actor_id: actor/operator-1
policy_view_at: 2026-05-07T10:00:00Z
action_at: 2026-05-07T10:05:00Z
audit_at: 2026-05-07T12:00:00Z
```

History inputs:

| History | Type | Example content | Retention |
|---------|------|-----------------|-----------|
| `order_history` | `BiHistory[OrderState]` | order created, assigned, completed/canceled corrections | `:audit` when linked to operation receipt |
| `schedule_state_history` | `BiHistory[ScheduleState]` | planned -> in_progress from execution receipt | `:audit` for state transitions |
| `action_policy_history` | `BiHistory[ActionPolicyProjection]` | action visible at policy view, stale by action time | `:durable` plus audit refs |
| `operation_request_history` | `History[OperationRequestReceipt]` | cancel request pending, duplicate suppressed | `:audit` |
| `operation_execution_history` | `History[OperationExecutionReceipt]` | status mutation receipt | `:audit` |

Expected behavior:

| Case | Query | Expected result |
|------|-------|-----------------|
| Visible policy | `action_policy_history[vt: policy_view_at, tt: policy_view_at]` | shows visible actions only |
| Fresh execution check | `action_policy_history[vt: action_at, tt: action_at]` | required before schedule mutation |
| Request action | `operation_request_history.at(action_at)` | creates pending request, no schedule mutation |
| Duplicate request | `operation_request_history.changes_in(open_request_window)` | duplicate suppressed with diagnostic |
| State mutation audit | `schedule_state_history[vt: action_at, tt: audit_at]` | transition must link to execution receipt |

Failure modes:

- `operation_action.policy_context_drift`: visible policy used as executable
  authority.
- `operation_request.unexpected_subject_mutation`: request action changed
  schedule state.
- `operation_execution.receipt_missing_for_state_transition`: state changed
  without receipt.
- `history.bi_axis_ambiguous`: `BiHistory[T]` queried without explicit `vt` and
  `tt`.

Demands:

- `BiHistory[T]` must support "known at action time" and "corrected at audit
  time" without collapsing them.
- Schedule state transitions should be explainable as history deltas:
  `before`, `after`, `receipt_ref`, `actor_ref`, `policy_ref`.
- `History[T].changes_in(period)` is more important here than numeric
  aggregates.
- Diagnostics should point to the missing receipt or stale policy projection,
  not just to a failed Boolean guard.

Retention pressure:

- Request, execution, no-op, duplicate suppression, and bridge receipts are
  `:audit`.
- Visible policy projections may be compacted only if their policy hash,
  source config refs, and output table remain resolvable.
- Order/schedule lifecycle history cannot be compacted into only the latest
  row if any audit receipt references an earlier state.

## Scenario 3: Lead / Vendor / Telephony Boundary History

Purpose: model vendor lead and telephony signals as temporal evidence feeding a
closed hourly boundary, then explain duplicates, late arrivals, and retention.

Synthetic scope:

```text
company_id: company/fixture-acme
hour_bucket_utc: 2026-05-07T10:00:00Z..2026-05-07T11:00:00Z
boundary_closed_at: 2026-05-07T11:05:00Z
audit_at: 2026-05-07T12:00:00Z
```

History inputs:

| History | Type | Example content | Lifecycle |
|---------|------|-----------------|-----------|
| `lead_signal_history` | `BiHistory[LeadSignalObservation]` | accepted/rejected normalized signals, duplicate non-admission, late signal | `:window` raw, `:durable` rollup |
| `vendor_signal_history` | `History[VendorSignalObservation]` | vendor status or quality markers | `:durable` |
| `telephony_signal_history` | `History[TelephonySignalObservation]` | answered/missed/failed synthetic call outcomes | `:window` raw, compacted summary |
| `hourly_rollup_history` | `BiHistory[HourlyLeadSignalRollup]` | closed rollup and possible replacement after reopen | `:audit` |
| `retention_receipt_history` | `History[RetentionReceipt]` | dry-run and execution receipts | `:audit` |

Expected boundary table:

| Signal | Valid time | Transaction time | Boundary effect | Diagnostic |
|--------|------------|------------------|-----------------|------------|
| `ls-001` accepted | 10:05 | 10:05 | accepted_count +1 | none |
| `ls-002` rejected | 10:20 | 10:20 | rejected_count +1 | none |
| `ls-001-dup` duplicate | 10:30 | 10:30 | no rollup change | `lead_signal.duplicate_idempotency_key` |
| `call-001` answered | 10:35 | 10:35 | telephony_contact_count +1 | none |
| `ls-003-late` accepted | 10:45 | 11:07 | blocked until reopen | `lead_signal.late_boundary_reopen_required` |

Demands:

- Hourly rollup is a projection over `History[T]` slices, but replacement after
  late arrival needs `BiHistory[HourlyLeadSignalRollup]`.
- Duplicate suppression is a history event or receipt, not a rejected business
  lead.
- Retention execution must prove that boundary materialization covers the raw
  window before raw signals are compacted.
- Telephony raw events should compact into a contact rollup while preserving
  enough evidence refs for "why did this alert fire?".
- Decimal bid values and idempotency keys remain Spark-specific hard pressure,
  but history adds the missing "when did this boundary know what it knew?"
  dimension.

Failure modes:

- `history.boundary_closed_before_signal_recorded`
- `history.retained_raw_missing_boundary_receipt`
- `history.rollup_replacement_without_reopen_receipt`
- `lead_signal.duplicate_counted_as_rejection`
- `telephony.raw_compacted_without_summary`

Retention pressure:

- raw normalized lead and telephony observations may be `:window`;
- idempotency refs, hourly rollups, close/reopen receipts, and retention
  receipts are `:audit`;
- vendor status history is `:durable`;
- replacement rollups must link to prior rollup and reopen receipt.

## Cross-Cutting Demands

### History Type Demands

`History[T]` must provide:

- point access: `history_at(history, as_of) -> Option[T]`;
- range access: `history_range(history, period) -> History[T]`;
- change access: `changes`, `changes_in(period)`;
- gap diagnostics: `gap_at(t)`, `covered?`, `gaps`;
- projection provenance: every access should emit selected interval refs.

`BiHistory[T]` must provide:

- explicit `vt` and `tt` axes for point and range access;
- OOF on ambiguous axis access;
- correction/replacement semantics through ESCAPE append and receipts;
- comparison between `as_known_when_valid` and `corrected_at(report_at)`;
- ability to preserve old decision meaning after later corrections.

### Projection Demands

Spark CRM projections need:

- `AvailabilitySnapshot` from bitemporal schedule/off/day-off slices;
- `ActionPolicyProjection` with freshness and source config refs;
- `HourlyLeadSignalRollup` as a closed boundary materialization;
- compacted telephony/contact summaries with evidence refs;
- compatibility between `Projection[T]`, `History[T]`, and `OLAPPoint[T,Dims]`
  for future multi-dimensional reporting by company, vendor, technician, and
  hour.

### Retention Demands

Must be retained:

- dispatch decisions and why-not explanations used for assignment;
- operation request/execution/no-op/duplicate receipts;
- boundary close/reopen receipts;
- retention dry-run/execution receipts;
- source config or policy hashes that affect decisions;
- replacement SemanticImage links when retained projections change.

May be compacted after trusted boundary coverage:

- high-volume geo samples;
- raw telephony event details;
- raw normalized lead signal details;
- transient availability intermediate slots not linked to a decision;
- local runtime traces not referenced by failure/audit output.

Must block or downgrade if compacted too early:

- any audit output with unresolved source refs;
- any rollup whose raw window has no trusted close receipt;
- any decision that cites a compacted snapshot without a boundary receipt;
- any correction that replaces prior meaning without a replacement link.

### Diagnostics Demands

History diagnostics should be typed, not prose-only:

```text
history.as_of_missing
history.bi_axis_ambiguous
history.gap_at_valid_time
history.corrected_after_decision
history.boundary_closed_before_signal_recorded
history.compaction_without_boundary_receipt
history.rollup_replacement_without_reopen_receipt
history.audit_ref_unresolvable
projection.source_history_missing
projection.stale_policy_used_as_authority
retention.raw_window_not_covered
```

Diagnostics must include:

- contract ref;
- history ref;
- selected `vt` and `tt` axes when applicable;
- lifecycle class;
- projection/snapshot ref;
- missing or compacted evidence refs;
- trust result: `trusted`, `provisional`, `downgraded`, or `blocked`.

## What Current Igniter-Lang Already Handles

Strong existing pressure/proof base:

- explicit `as_of` and no ambient clock direction;
- lifecycle vocabulary: `:window`, `:durable`, `:audit`, `:compacted`;
- availability fixtures with scoped reads, StepObservations, why-not reasons,
  and blocked negatives;
- lead boundary fixture with idempotency, Decimal pressure, retention receipts,
  duplicate suppression, and late boundary block;
- operation lifecycle fixture with visible vs executable action separation and
  receipts;
- PROP-022 has first-class `History[T]` and `BiHistory[T]` shape, operations,
  OOF-H1/H2/H3/H4, and SemanticIR temporal node sketches;
- history proof planning has a narrow first executable target:
  `history_at(History[Integer], DateTime) -> Option[Integer]`.

## Where It Breaks

Breakpoints:

- First proof covers only `History[Integer]` point access; Spark needs
  record-valued histories and bitemporal range slices.
- `BiHistory[T]` is essential for corrections, but no executable proof exists
  yet.
- `History[T]` access must return evidence and selected interval refs, not only
  `Option[T]`.
- Projection freshness needs a formal link between history access axes and
  snapshot provenance.
- Retention/compaction must be history-aware, especially for boundary rollups
  and dispatch explanation.
- Timezone and local-day boundaries are not fully typed in `History[T]`
  examples.
- Policy/version/config histories need stable hashes and source refs to avoid
  stale authority.

## Concrete Next Requests

### Research Agent

Create `sparkcrm-history-fixture-v0` as a synthetic executable planning target
with three cases:

1. `availability_bihistory_correction`: bitemporal schedule/off/day-off slices,
   positive decision snapshot, later correction report, and blocked missing-axis
   negative.
2. `operation_schedule_history_audit`: schedule state history with request,
   execution, duplicate no-op, and missing execution receipt negative.
3. `lead_telephony_boundary_history`: hourly rollup history, duplicate
   suppression, late boundary reopen block, retention coverage negative.

Start minimal if needed:

- first executable proof can implement only scenario 1 with
  `BiHistory[ScheduleSlotObservation]` represented as synthetic JSON and a
  proof-local `bihistory_at(vt, tt)` helper;
- if `BiHistory[T]` is too early, fall back to two `History[T]` axes and record
  the semantic mismatch explicitly.

### Compiler/Grammar Expert

Formal questions:

1. Should Stage 2 add `bihistory_at(history, vt, tt)` as the first executable
   function before method/index syntax?
2. Should range access return `History[T]`, `Collection[ChangeEvent[T]]`, or a
   `TemporalSlice[T]` value with selected interval refs?
3. Is `History[T]` access required to emit provenance/evidence refs in
   SemanticIR, or is that a bridge/runtime responsibility?
4. How should local-day/timezone boundaries typecheck with `DateTime`,
   `Date`, and `Duration`?
5. Does `BiHistory[T]` correction imply replacement SemanticImage semantics
   when a projection changes, or only a new receipt?
6. Can retention policy depend on `History[T]` projection coverage without
   introducing arbitrary runtime policy code?

### Bridge Agent

Bridge candidates:

- `HistoryAccessDiagnostic`
- `BiHistoryAxisDiagnostic`
- `TemporalProjectionSourceReport`
- `AvailabilityCorrectionReport`
- `ScheduleStateTransitionHistoryReport`
- `LeadBoundaryHistoryReport`
- `RetentionCoverageReport`
- `CompactedHistoryEvidenceStub`

All bridge profiles must remain metadata-only and provider-neutral.

## Handoff

```text
[Igniter-Lang Applied Pressure Agent]
Track: igniter-lang/docs/tracks/sparkcrm-history-pressure-v0.md
Status: done

[D] Decisions
- Spark CRM pressure validates History[T] as useful but quickly requires
  BiHistory[T] for corrections, late signals, and audit.
- Availability, operation lifecycle, and lead/telephony boundaries are the
  first three domain fixtures for history pressure.
- Retention must be history-aware: compaction is safe only when projections,
  boundary receipts, and evidence stubs preserve explanation rights.

[S] Shipped / Signals
- Added concrete synthetic scenarios for technician availability correction,
  order/schedule lifecycle audit, and lead/vendor/telephony boundary history.
- Identified explicit demands on point/range/change access, bitemporal axes,
  projection provenance, retention coverage, and typed diagnostics.
- Confirmed existing fixtures already contain the operational vocabulary that
  History[T] must now temporalize.

[T] Tests / Proofs
- Documentation-only pressure slice; no executable tests run.

[R] Risks / Recommendations
- Risk: proving only History[Integer] point access will underfit Spark CRM
  unless a bitemporal record-valued fixture follows soon.
- Recommendation: Research Agent should build a synthetic BiHistory availability
  correction fixture before broadening to OLAP or streams.
- Recommendation: Compiler/Grammar Expert should settle first executable
  `bihistory_at(history, vt, tt)` and temporal slice return shape.
- Recommendation: Bridge Agent should draft metadata-only history/projection
  diagnostics before any package adapter work.

[Next] Suggested next slice
- sparkcrm-history-fixture-v0: executable synthetic proof for bitemporal
  availability correction, with missing-axis, compaction, and correction
  diagnostics.
```
