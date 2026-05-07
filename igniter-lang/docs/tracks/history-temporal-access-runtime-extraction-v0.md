# History Temporal Access Runtime Extraction v0

Card: S2-R3-C2-P
Role: `[Igniter-Lang Research Agent]`
Track: `history-temporal-access-runtime-extraction-v0`
Status: done
Date: 2026-05-07
Depends on: `S2-R2-C1-B`, `S2-R2-C4-B`

## Goal

Extract proof-local temporal access behavior from the History and SparkCRM
BiHistory proofs into a small reusable experiments-level runtime helper.

This is a step toward RuntimeMachine support for `temporal_access_node`, not a
production runtime package.

## Extracted Runtime Surface

New helper:

```text
experiments/temporal_access_runtime/temporal_access_runtime.rb
```

It provides:

```text
TemporalAccessRuntime::Canonical
TemporalAccessRuntime::Option
TemporalAccessRuntime::AxisTypeError
TemporalAccessRuntime::MemoryBackend
```

Supported access paths:

```text
axis: "valid_time"
  MemoryBackend#history_at(subject, as_of)
  MemoryBackend#read_as_of(subject, as_of)

axis: "bitemporal"
  MemoryBackend#bihistory_at(history_ref, vt:, tt:, node_name:)
```

Shared runtime behavior:

```text
Option[T] canonical output:
  Some(V) -> { "kind": "some", "value": V }
  None    -> { "kind": "none" }

valid_time point selection:
  latest append with valid_from <= as_of

bitemporal point selection:
  latest event where valid_from <= vt < valid_until and tx_from <= tt

evidence:
  history_access_observation.selected_append_ref
  bihistory_access_observation.selected_event_ref
```

## Decisions

[D] Kept extraction inside `experiments/`. No production runtime package or
Igniter gem code was added.

[D] Kept parser/typechecker untouched. Compiler/Grammar axes work can proceed
in parallel.

[D] Kept scenario-specific logic local:

```text
History proof:
  ParsedProgram/ClassifiedProgram/TypedProgram/SemanticIR hand-authored proof
  .igapp fixture assembly
  RuntimeMachine load smoke wrapper

SparkCRM fixture:
  availability projection rules
  correction report
  OOF-BT diagnostic report shaping
  synthetic safety scan
```

[D] Extracted only the temporal access runtime mechanics:

```text
canonical JSON hashing
Option[T] constructors
axis parsing/type errors
memory-backed selection
access observation construction
```

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

## Production Runtime Target

The eventual RuntimeMachine extraction should provide:

```text
RuntimeMachine temporal_access_node evaluator
  axis: valid_time
  axis: bitemporal
  canonical Option[T]
  selected observation/event evidence
  capability checks for history_read / bihistory_read
  adapter boundary for TBackend
```

Still out of scope:

```text
range access
aggregates
streams
OLAPPoint
subscriptions
compaction/retention policy execution
real TBackend adapters
parser/typechecker axis generalization
```

## Changed Files

```text
docs/tracks/history-temporal-access-runtime-extraction-v0.md
experiments/temporal_access_runtime/temporal_access_runtime.rb
experiments/history_type_proof/history_type_proof.rb
experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb
```

## Handoff

```text
Card: S2-R3-C2-P
[Igniter-Lang Research Agent]
Track: history-temporal-access-runtime-extraction-v0
Status: done

[D] Decisions
- Extracted shared temporal access mechanics into experiments/temporal_access_runtime.
- Supported valid_time point access and bitemporal vt/tt access only.
- Preserved canonical Option[T] shape and selected evidence refs.
- Left parser/typechecker and production RuntimeMachine untouched.

[S] Shipped / Signals
- History proof now uses TemporalAccessRuntime::MemoryBackend for history_at/read_as_of.
- SparkCRM BiHistory proof now uses the same backend for bihistory_at.
- Removed duplicated Option/canonical/axis/access-observation logic from both proofs.

[T] Tests / Proofs
- ruby igniter-lang/experiments/history_type_proof/history_type_proof.rb -> PASS
- ruby igniter-lang/experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb -> PASS
- ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb -> PASS

[R] Risks / Recommendations
- Next runtime slice can map SemanticIR temporal_access_node directly onto this API.
- Compiler/Grammar can continue axis parser/typechecker work independently.

[Next] Suggested next slice
- runtime-temporal-access-node-loader-v0
```
