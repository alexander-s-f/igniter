# Stream T Proof v0

Card: S2-R4-C4-P
Role: `[Igniter-Lang Research Agent]`
Track: `stream-t-proof-v0`
Status: done
Date: 2026-05-07
Depends on: none

## Goal

Create the first bounded executable proof for PROP-023 `stream T`.

This slice proves the smallest useful stream path:

```text
stream Integer
  -> count window of 3 events
  -> fold_stream bounded by that window
  -> deterministic durable snapshot
```

It is proof-local. Parser syntax, production stream adapters, OLAPPoint, and
production RuntimeMachine integration remain out of scope.

## Current Horizon

Stage 1 is closed. Stage 2 already has History/BiHistory temporal memory
proofs, temporal access runtime extraction, and invariant severity proof.

PROP-023 adds a different temporal surface:

```text
stream T  = ingress / flow / ESCAPE channel
History T = durable temporal memory addressed by explicit time
```

The bridge from stream to CORE is a bounded materialized window. In this proof,
the RuntimeMachine-shaped evaluator sees `fold_stream` as a fold over a finite
`Collection[Integer]`.

## Fixture

Experiment:

```text
igniter-lang/experiments/stream_t_proof/stream_t_proof.rb
```

Source sketch:

```text
igniter-lang/experiments/stream_t_proof/stream_integer_window.ig
```

The source sketch is not parsed in this slice. The runner builds a hand-authored
SemanticIR-like program with:

```text
stream_input_node
window_decl_node
fold_stream_node
```

Contract:

```text
IntegerWindowSum
  in device_id: String
  stream readings: Integer
  window integer/{device_id}: count size 3 on_close snapshot
  fold_stream(readings, 0, integer_sum_lambda) @window_bounded
  out IntegerWindowSnapshot lifecycle durable
```

## Runtime Proof

The proof includes two source modes.

Finite replay/test stream:

```text
mode: finite_replay
events: [4, 5, 6, 7, 8]
window: first 3 events
result: 4 + 5 + 6 = 15
status: ok
trusted_output: true
```

Open live stream:

```text
mode: open_live
adapter_ref: adapter/synthetic-live-integer-stream
status: waiting_for_window_close
trusted_output: false
output: null
```

This distinction is intentional:

```text
finite replay  -> deterministic proof/test stream
open live      -> runtime stream handle, no output until the count window closes
```

## Evidence

The finite replay output carries a `stream_window_observation`:

```text
kind: stream_window_observation
source_mode: finite_replay
window_kind: count
event_count: 3
sequence_range: [1, 3]
consumed_event_refs:
  - evt/stream/...
  - evt/stream/...
  - evt/stream/...
```

The output snapshot includes:

```text
total: 15
count: 3
window_id: window/stream/...
consumed_event_refs: [...]
```

Each consumed event is also linked through `evidence_links` with
`rel: consumed_event`.

## Negative Cases

The proof emits compact OOF reports:

```text
negative_unbounded_fold       -> OOF-S1
negative_missing_window       -> OOF-S2
negative_direct_stream_use    -> OOF-S4
```

All negative reports have:

```text
pass_result: oof
semantic_ir_ref: null
category: stream_oof
```

## Proof Output

```text
PASS stream_t_proof
semanticir.stream_input_node: ok
semanticir.window_decl_node: ok
semanticir.fold_stream_node: ok
classification.stream_is_escape: ok
classification.fold_result_is_core: ok
runtime.finite_replay_window_closed: ok
runtime.fold_stream_sum: ok
evidence.consumed_events_window: ok
runtime.open_live_waits_for_close: ok
negative.oof_s1_unbounded_fold: ok
negative.oof_s2_missing_window: ok
negative.oof_s4_direct_stream_use: ok
history.relationship_documented: ok
finite_replay.window: closed/3 events
finite_replay.output.total: 15
open_live.status: waiting_for_window_close
summary: igniter-lang/experiments/stream_t_proof/summary.json
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

## Generated Artifacts

```text
experiments/stream_t_proof/summary.json
experiments/stream_t_proof/golden/semantic_ir_program.json
experiments/stream_t_proof/golden/finite_replay_result.json
experiments/stream_t_proof/golden/open_live_descriptor.json
experiments/stream_t_proof/golden/negative_unbounded_fold.json
experiments/stream_t_proof/golden/negative_missing_window.json
experiments/stream_t_proof/golden/negative_direct_stream_use.json
```

## Proof-Local vs Target

Proof-local:

```text
hand-authored SemanticIR-like nodes
finite replay stream source
open live descriptor
stream capability handler
integer sum lambda
OOF report shaping
```

Language/compiler/runtime target:

```text
parser support for stream declarations and windows
classifier ownership for stream ESCAPE propagation
TypeChecker ownership for fold_stream bounds and CORE accumulator lambdas
SemanticIR emission of stream_input/window/fold_stream nodes
RuntimeMachine stream_input capability handler
adapter boundary for live ingress sources
```

## Changed Files

```text
docs/tracks/stream-t-proof-v0.md
experiments/stream_t_proof/stream_t_proof.rb
experiments/stream_t_proof/stream_integer_window.ig
experiments/stream_t_proof/summary.json
experiments/stream_t_proof/golden/semantic_ir_program.json
experiments/stream_t_proof/golden/finite_replay_result.json
experiments/stream_t_proof/golden/open_live_descriptor.json
experiments/stream_t_proof/golden/negative_unbounded_fold.json
experiments/stream_t_proof/golden/negative_missing_window.json
experiments/stream_t_proof/golden/negative_direct_stream_use.json
```

## Handoff

```text
Card: S2-R4-C4-P
[Igniter-Lang Research Agent]
Track: stream-t-proof-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Used `stream Integer` with a count window of 3 as the smallest bounded proof.
- Kept parser syntax as a source sketch; runner starts from proof-local SemanticIR-like JSON.
- Proved finite replay/test stream separately from open live stream.
- Kept History/BiHistory runtime files untouched.

[S] Signals:
- `stream T` is ESCAPE.
- `fold_stream` over a closed bounded window yields a CORE fold result.
- Runtime output includes consumed-event evidence and a stream window observation.
- Open live stream produces no trusted output until the runtime window closes.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/stream_t_proof/stream_t_proof.rb -> PASS
- ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb -> PASS

[R] Risks / Recommendations:
- Compiler/Grammar should own parser/classifier/typechecker slices for OOF-S1..S5.
- Bridge Agent should treat live stream adapters as ESCAPE capability handlers.
- Runtime extraction should keep the materialized-window-as-Collection boundary.

[Next] Suggested next slice:
- stream-parser-classifier-boundary-v0
```
