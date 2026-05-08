# Track: Stream Replay Metadata Emission v0

Card: S3-R9-C5-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `igniter-lang/stream-replay-metadata-emission-v0`
Status: done
Date: 2026-05-08

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Bridge Agent]`, `[Igniter-Lang Meta Expert]`

---

## Goal

Close the proof-local `stream_fold` default gap by making bounded replay
metadata explicit in SemanticIR and assembled `.igapp` contract artifacts.

No production stream executor is introduced.

---

## Decision

[D] STREAM replay metadata belongs at two levels:

- SemanticIR `nodes`: `stream_input_node`, `window_decl_node`,
  `fold_stream_node`
- assembled contract artifact: `contracts/<contract>.json.stream_nodes`

[D] `window_decl_node` owns window replay shape:

```text
window_kind
bounded
size | period | idle
on_close
```

[D] `fold_stream_node` owns fold replay shape:

```text
init
fn_ref
bound.window_ref
event_binding.value_path
```

[D] The classifier/typechecker boundary must preserve parsed stream metadata
instead of treating it as proof-local fixture data. Classifier now carries
`window.options` and `fold_stream.bound`; TypeChecker keeps raw
`fold_stream.expr` for the emitter.

---

## Shipped

[S] `SemanticIREmitter.emit_typed` now emits complete replay metadata for the
current proven stream T surface:

- stream input points at its window
- window has kind, size, close policy, and boundedness
- fold has init literal, function reference, normalized bound/window ref, and
  event payload binding

[S] `Assembler` now preserves stream nodes under `stream_nodes` in each
assembled contract file and carries window replay metadata into
`requirements.json.temporal.windows`.

[S] `runtime_smoke_post_switch_full_coverage` now evaluates `stream_fold` from
the assembled contract `stream_nodes` metadata. It no longer falls back to
fixture defaults for `window.size`, `fold_stream.init`, or `fold_stream.fn_ref`.

[S] Ch6 SemanticIR spec now documents STREAM replay metadata nodes and the
assembled `stream_nodes` section.

---

## Proof Signal

The assembled stream contract now carries enough metadata for proof-local
finite replay:

```text
contracts/integer_window_sum.json
  stream_nodes:
    stream_input_node.window_ref
    window_decl_node.window_kind = count
    window_decl_node.size = 3
    window_decl_node.bounded = true
    fold_stream_node.init = integer_literal(0)
    fold_stream_node.fn_ref = integer_sum_lambda
    fold_stream_node.bound.window_ref = integer/{device_id}
    fold_stream_node.event_binding.value_path = ["value"]
```

`runtime_smoke_post_switch_full_coverage_summary.json` now reports:

```text
stream_fold.assembled_replay_metadata: true
runtime_note: assembled_stream_replay_metadata_complete
metadata_source: assembled_contract.stream_nodes
```

---

## Tests / Proofs

[T] PASS:

```bash
ruby igniter-lang/experiments/runtime_smoke_post_switch_full_coverage/runtime_smoke_post_switch_full_coverage.rb
ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden
ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb
ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden
ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb --check-golden
ruby igniter-lang/experiments/stream_t_proof/stream_t_proof.rb
ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
```

---

## Remaining Gaps

[R] No production stream executor exists. The replay metadata only enables
proof-local finite replay and future executor design.

[R] `fn_ref` is a semantic reference, not a general lambda bytecode/lowering
format. Broader lambda lowering remains a future compiler/runtime boundary.

[R] Event envelope shape is explicit as `event_binding.value_path`, but live
stream ingress, ordering, watermarking, and durable replay remain out of scope.

[R] STREAM is still represented as the legacy `escape` contract fragment in
some assembled summaries. A future grammar/spec cleanup may rename that
contract-level class once stream runtime ownership is stable.

---

## Handoff

```text
Card: S3-R9-C5-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: igniter-lang/stream-replay-metadata-emission-v0
Status: done

[D] Decisions
- STREAM replay metadata is canonical in SemanticIR nodes and assembled
  contract stream_nodes.
- window_decl_node owns kind/boundedness/size/on_close.
- fold_stream_node owns init/fn_ref/bound.window_ref/event_binding.
- No production stream executor is authorized.

[S] Shipped / Signals
- Preserved window.options and fold_stream.bound across classifier/typechecker.
- emit_typed now emits complete stream replay metadata.
- assembler writes stream_nodes and window replay requirements.
- runtime smoke evaluates stream_fold from assembled metadata, with no hidden
  proof-local defaults.
- Ch6 SemanticIR spec documents the shape.

[T] Tests / Proofs
- runtime_smoke_post_switch_full_coverage -> PASS
- source_to_semanticir_fixture --check-golden -> PASS
- typechecker_proof -> PASS
- typechecker_proof --check-golden -> PASS
- classifier_pass_proof --check-golden -> PASS
- stream_t_proof -> PASS
- stage1_close_candidate -> PASS

[R] Risks / Recommendations
- Production stream executor, live ingress, and durable replay are still future
  Bridge/Runtime work.
- General lambda lowering beyond current fn_ref references remains open.
- Contract-level STREAM vs legacy escape naming remains a future cleanup.

[Next] Suggested next slice
- Bridge/Runtime can consume stream_nodes as an executor input contract when a
  production stream evaluator is explicitly authorized.
```
