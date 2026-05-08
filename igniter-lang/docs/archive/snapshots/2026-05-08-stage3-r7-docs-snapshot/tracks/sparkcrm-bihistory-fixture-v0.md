# SparkCRM BiHistory Fixture v0

Card: S2-R2-C4-B
Role: `[Igniter-Lang Research Agent]`
Track: `sparkcrm-bihistory-fixture-v0`
Status: done
Date: 2026-05-07
Depends on: `S2-R2-C1-B`

## Goal

Implement an executable synthetic SparkCRM-shaped bitemporal availability
correction proof.

The proof answers one product question:

```text
Can a dispatch-time availability decision remain trusted as "known then" while
a later bitemporal correction changes the current projection?
```

## Scope

[D] This fixture uses synthetic facts only. No real Spark CRM data, endpoints,
provider payloads, credentials, tokens, adapters, or customer records are used.

[D] Runtime is proof-local. `MemoryBiHistoryBackend` models append-only
valid-time and transaction-time records.

[D] `Option[T]` uses the canonical shape from
`temporal-option-and-bihistory-shape-v0`:

```json
{ "kind": "some", "value": "V" }
```

```json
{ "kind": "none" }
```

[D] Parser/runtime generalization is out of scope. This fixture establishes
the bitemporal behavior and expected diagnostics first.

## Experiment

Command:

```bash
ruby igniter-lang/experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb
```

Files:

```text
experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb
experiments/sparkcrm_bihistory_fixture/summary.json
experiments/sparkcrm_bihistory_fixture/golden/decision_snapshot.json
experiments/sparkcrm_bihistory_fixture/golden/corrected_snapshot.json
experiments/sparkcrm_bihistory_fixture/golden/correction_report.json
experiments/sparkcrm_bihistory_fixture/golden/negative_missing_vt.json
experiments/sparkcrm_bihistory_fixture/golden/negative_missing_tt.json
experiments/sparkcrm_bihistory_fixture/golden/negative_wrong_axis_type.json
```

## Scenario

Synthetic identity:

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

Synthetic correction:

```text
At decision_tt:
  slot 10:00 has schedule event "planned", blocks availability.

At report_tt:
  slot 10:00 has later transaction-time correction "canceled",
  valid for the same valid-time window, and no longer blocks availability.
```

## Positive Outputs

Decision-time projection:

```text
known_time: 2026-05-07T13:30:00Z
requested_window.result: blocked
requested_window.reason: busy
requested_window.source_event_refs:
  - hist/schedule/t-17/10/planned/as-known-1205
trust_status: trusted
```

Corrected projection:

```text
known_time: 2026-05-07T15:20:00Z
requested_window.result: available
requested_window.reason: available
requested_window.source_event_refs:
  - hist/schedule/t-17/10/canceled/correction-1510
trust_status: trusted
```

Correction report:

```text
prior_event_ref: hist/schedule/t-17/10/planned/as-known-1205
corrected_event_ref: hist/schedule/t-17/10/canceled/correction-1510
prior_reason: busy
corrected_reason: available
original_decision_status: still_explainable
original_decision_rewritten: false
```

## Negative Outputs

The fixture emits typechecker-style OOF reports:

```text
negative_missing_vt          -> OOF-BT2 history.valid_time_axis_missing
negative_missing_tt          -> OOF-BT3 history.transaction_time_axis_missing
negative_wrong_axis_type     -> OOF-BT4 history.axis_type_mismatch
```

Each negative report has:

```text
pass_result: oof
semantic_ir_ref: nil
category: typechecker_oof
stage.typecheck: oof
```

## Proof Output

```text
PASS sparkcrm_bihistory_fixture
seed.synthetic_bihistory_events: ok
option.canonical_some: ok
option.canonical_none: ok
decision.snapshot_blocks_requested_window: ok
corrected.snapshot_frees_requested_window: ok
correction.report_links_prior_and_corrected_events: ok
dispatch.original_explanation_preserved: ok
negative.missing_vt_oof_bt2: ok
negative.missing_tt_oof_bt3: ok
negative.wrong_axis_type_oof_bt4: ok
safety.synthetic_only: ok
decision.requested_window: blocked/busy
corrected.requested_window: available/available
correction.changed_slots: 1
summary: igniter-lang/experiments/sparkcrm_bihistory_fixture/summary.json
```

Stage 1 regression:

```text
PASS stage1_close_candidate
classifier: PASS
typechecker: PASS
semanticir: PASS
stdlib_kernel: PASS
igapp_assembler: PASS
summary: igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.json
```

## Gaps

[R] Parser support for `BiHistory[T]`, `bihistory_at`, and named axes remains a
future Compiler/Grammar slice.

[R] RuntimeMachine support for `temporal_access_node` with `axis:"bitemporal"`
remains proof-local here.

[R] No real TBackend adapter or Spark CRM bridge was added. Bridge work should
start from the access observation and correction report shapes produced here.

## Changed Files

```text
docs/tracks/sparkcrm-bihistory-fixture-v0.md
experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb
experiments/sparkcrm_bihistory_fixture/summary.json
experiments/sparkcrm_bihistory_fixture/golden/decision_snapshot.json
experiments/sparkcrm_bihistory_fixture/golden/corrected_snapshot.json
experiments/sparkcrm_bihistory_fixture/golden/correction_report.json
experiments/sparkcrm_bihistory_fixture/golden/negative_missing_vt.json
experiments/sparkcrm_bihistory_fixture/golden/negative_missing_tt.json
experiments/sparkcrm_bihistory_fixture/golden/negative_wrong_axis_type.json
```

## Handoff

```text
Card: S2-R2-C4-B
[Igniter-Lang Research Agent]
Track: sparkcrm-bihistory-fixture-v0
Status: done

[D] Decisions
- Use proof-local MemoryBiHistoryBackend with append-only vt/tt records.
- Use canonical Option[T] encoding from S2-R2-C1-B.
- Preserve original dispatch explanation; correction report adds evidence but
  does not rewrite the decision snapshot.
- Keep parser/runtime generalization out of this card.

[S] Shipped / Signals
- Added executable SparkCRM-shaped BiHistory correction fixture.
- Added decision_snapshot, corrected_snapshot, correction_report goldens.
- Added OOF-BT2, OOF-BT3, and OOF-BT4 negative reports.
- Added safety check for synthetic-only fixture content.

[T] Tests / Proofs
- ruby igniter-lang/experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb -> PASS
- ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb -> PASS

[R] Risks / Recommendations
- Next Compiler/Grammar slice should generalize parser/typechecker for BiHistory axes.
- Next runtime slice should extract bitemporal temporal_access_node evaluation
  from this proof-local backend.

[Next] Suggested next slice
- bihistory-parser-typechecker-axes-v0
```
