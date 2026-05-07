# Runtime Temporal Access Node Loader v0

Card: S2-R4-C1-P
Role: `[Igniter-Lang Research Agent]`
Track: `runtime-temporal-access-node-loader-v0`
Status: done
Date: 2026-05-07
Depends on: `S2-R3-C2-P`

## Goal

Map SemanticIR `temporal_access_node` onto
`TemporalAccessRuntime::MemoryBackend` for the two already-proven Stage 2
temporal cases:

```text
History[T]   axis: valid_time
BiHistory[T] axis: bitemporal
```

This is still experiments-level Runtime/SemanticIR loading. It does not create
a production runtime package, parser support, typechecker support, or TBackend
adapter.

## Current Horizon

Stage 1 is closed. Stage 2 has:

```text
History[Integer] point proof    -> PASS
SparkCRM BiHistory fixture      -> PASS
TemporalAccessRuntime backend   -> shared MemoryBackend
```

The remaining gap was that proof code still called backend methods directly
instead of making the SemanticIR node shape the boundary.

## Loader Boundary

New helper:

```text
TemporalAccessRuntime::SemanticIRTemporalAccessEvaluator
```

Input contract:

```text
evaluate(access_node, temporal_inputs:, inputs:)

access_node:
  kind: temporal_access_node
  access: point
  source_ref: <temporal_input_node.name>
  axis: valid_time | bitemporal

temporal_inputs:
  name -> temporal_input_node

inputs:
  runtime input map used by time refs and templated store/history refs
```

Output envelope:

```json
{
  "kind": "temporal_access_evaluation",
  "node": "current_count",
  "axis": "valid_time",
  "result": { "kind": "some", "value": 7 },
  "observation": { "...": "history_access_observation" },
  "evidence_links": [
    {
      "rel": "selected_append",
      "from": "obs/history_access/...",
      "to": "obs/history_append/..."
    }
  ]
}
```

## Supported Shapes

History point access:

```json
{
  "kind": "temporal_access_node",
  "name": "current_count",
  "source_ref": "job_count_history",
  "access": "point",
  "time_ref": "as_of",
  "result_type": { "constructor": "Option", "element_type": "Integer" }
}
```

Mapped to:

```text
MemoryBackend#read_as_of(subject, as_of)
```

BiHistory point access:

```json
{
  "kind": "temporal_access_node",
  "name": "schedule_at",
  "source_ref": "schedule_history",
  "axis": "bitemporal",
  "access": "point",
  "valid_time_ref": "valid_time",
  "transaction_time_ref": "known_time",
  "result_type": { "constructor": "Option", "element_type": "ScheduleSlotObservation" }
}
```

Mapped to:

```text
MemoryBackend#bihistory_at(history_ref, vt:, tt:, node_name:)
```

Both paths preserve canonical `Option[T]`:

```json
{ "kind": "some", "value": "V" }
```

```json
{ "kind": "none" }
```

Both paths emit selected evidence links:

```text
valid_time  -> selected_append_ref
bitemporal  -> selected_event_ref
```

## Implementation Notes

[D] Added the evaluator in `experiments/temporal_access_runtime/`; this is the
smallest reusable Runtime/SemanticIR boundary without production extraction.

[D] Updated `history_type_proof` so its proof-local RuntimeMachine loads
`semantic_ir_program.json`, finds `temporal_input_node` and
`temporal_access_node`, and evaluates through the shared evaluator.

[D] Updated `sparkcrm_bihistory_fixture` to define proof-local
`temporal_input_node` and `temporal_access_node` maps for schedule,
off-schedule, and day-off accesses, then evaluate snapshots through the shared
evaluator.

[D] Kept parser and typechecker untouched. Their current pass/negative behavior
is preserved.

## Proof Output

History proof:

```text
PASS history_type_proof
history.append_seed_observations: ok
parser.hand_authored_history_parsed_program: ok
classifier.history_read_escape: ok
typechecker.history_at_option_integer: ok
semanticir.temporal_input_node: ok
semanticir.temporal_access_node: ok
assembler.history_igapp: ok
runtime.load_history_igapp_trusted: ok
runtime.evaluate_as_of_2026_05_03: ok
runtime.evaluate_as_of_2026_05_06: ok
runtime.output_links_selected_append_observation: ok
runtime.temporal_access_node_loader_valid_time: ok
negative.missing_as_of_oof_h1: ok
compilation.positive_report_ok: ok
option.encoding: some={"kind":"some","value":value} none={"kind":"none"}
summary: igniter-lang/experiments/history_type_proof/history_type_proof_summary.json
```

SparkCRM BiHistory proof:

```text
PASS sparkcrm_bihistory_fixture
seed.synthetic_bihistory_events: ok
option.canonical_some: ok
option.canonical_none: ok
decision.snapshot_blocks_requested_window: ok
corrected.snapshot_frees_requested_window: ok
correction.report_links_prior_and_corrected_events: ok
dispatch.original_explanation_preserved: ok
runtime.temporal_access_node_loader_bitemporal: ok
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

## Remaining Production Runtime Gap

The final gap before production RuntimeMachine integration is no longer
"how should a temporal_access_node call the memory backend?" That boundary now
exists in proof code.

Remaining production work:

```text
1. Move SemanticIRTemporalAccessEvaluator behind the production RuntimeMachine
   evaluator interface.
2. Replace MemoryBackend with a TBackend adapter boundary.
3. Add capability checks for history_read / bihistory_read at load/evaluate.
4. Define canonical RuntimeMachine error/OOF behavior for missing or malformed
   temporal access refs.
5. Decide whether bitemporal access nodes use `history_ref` or templated
   `store_ref` in canonical SemanticIR.
```

Still out of scope:

```text
parser grammar
typechecker axis inference
range access
temporal aggregates
streams
OLAPPoint
retention/compaction execution
real Spark CRM adapters
```

## Changed Files

```text
docs/tracks/runtime-temporal-access-node-loader-v0.md
experiments/temporal_access_runtime/temporal_access_runtime.rb
experiments/history_type_proof/history_type_proof.rb
experiments/history_type_proof/history_type_proof_summary.json
experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb
experiments/sparkcrm_bihistory_fixture/summary.json
experiments/sparkcrm_bihistory_fixture/golden/decision_snapshot.json
experiments/sparkcrm_bihistory_fixture/golden/corrected_snapshot.json
```

## Handoff

```text
Card: S2-R4-C1-P
[Igniter-Lang Research Agent]
Track: runtime-temporal-access-node-loader-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Added experiments-level SemanticIRTemporalAccessEvaluator as the loader/evaluator boundary.
- Supported valid_time History point access and bitemporal BiHistory point access.
- Preserved canonical Option[T] and selected evidence links.
- Kept parser/typechecker and production package untouched.

[S] Signals:
- History RuntimeMachine proof now evaluates temporal_access_node through the shared evaluator.
- SparkCRM BiHistory fixture now routes schedule/off/day-off reads through proof-local SemanticIR temporal nodes.
- Stage 1 close candidate remains PASS.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/history_type_proof/history_type_proof.rb -> PASS
- ruby igniter-lang/experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb -> PASS
- ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb -> PASS

[R] Risks / Recommendations:
- Production RuntimeMachine still needs capability checks, TBackend adapters, and canonical malformed-node diagnostics.
- Compiler/Grammar should align canonical BiHistory SemanticIR on `history_ref` vs templated `store_ref`.

[Next] Suggested next slice:
- production-runtime-temporal-access-integration-v0
```
