# Track: Stream SemanticIR Surface Lowering v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: `igniter-lang/stream-semanticir-surface-lowering-v0`
Card: S2-R10-C2-P
Status: done
Date: 2026-05-07
Depends on: S2-R7-C2-P, S2-R8-C3-P, S2-R9-C2-P

---

## Context

The stream T proof already had a stable proof-local SemanticIR shape:

- `stream_input_node`
- `window_decl_node`
- `fold_stream_node`

S2-R9 introduced `SemanticIREmitter#emit_typed` for Stage 2 typed lowering and
moved OLAPPoint boundary lowering into the extracted emitter. This slice moves
the proven stream T surface onto that same typed emitter path without changing
parser syntax, classifier escape rules, or OOF ownership.

---

## Implemented Boundary

[D] `IgniterLang::SemanticIREmitter#emit_typed` now lowers typed stream
declarations into SemanticIR nodes:

```json
{
  "kind": "stream_input_node",
  "name": "readings",
  "type": "Integer",
  "window_ref": "integer_count_window",
  "escape_capability": "stream_input",
  "fragment": "escape"
}
```

```json
{
  "kind": "fold_stream_node",
  "name": "total",
  "stream_ref": "readings",
  "init": { "kind": "integer_literal", "value": 0 },
  "fn_ref": "integer_sum_lambda",
  "bound": { "kind": "window_bounded", "window_ref": "integer_count_window" },
  "result_type": { "name": "Integer", "params": [] },
  "escape_capability": "stream_input",
  "result_fragment": "core"
}
```

[D] The emitter also carries the proven window node shape:

```json
{
  "kind": "window_decl_node",
  "ref": "integer_count_window",
  "key": "integer/{device_id}",
  "window_kind": "count",
  "size": 3,
  "on_close": "snapshot"
}
```

[D] Stream typed contracts now emit a `stream_input` escape boundary requiring
`stream_input` and producing `stream_window_observation`.

[D] The parsed-source emitter path remains unchanged. Existing
`source_to_semanticir_fixture` goldens still pass without updates.

---

## Proof Updates

[S] `stream_t_proof` now builds a proof-local `TypedProgram` and calls:

```ruby
IgniterLang::SemanticIREmitter.new.emit_typed(stream_t_typed_program)
```

The runtime proof consumes the emitted SemanticIR instead of a hand-authored
SemanticIR program.

[S] New/updated stream proof signals:

```text
semanticir.stream_input_node: ok
semanticir.window_decl_node: ok
semanticir.fold_stream_node: ok
semanticir.emitter_typed_program_ref: ok
```

[S] OOF ownership is preserved:

- `OOF-S1`: parser
- `OOF-S2`: classifier
- `OOF-S3`: TypeChecker
- `OOF-S4`: classifier
- `OOF-S5`: parser

No SC-1/2/3 classifier behavior was changed.

---

## Compatibility Note

[D] A nearby invariant parser change made `predicate` a keyword, which broke the
existing `Claim { predicate: String }` source-to-SemanticIR fixture. This slice
keeps the invariant keyword intact and restores compatibility by allowing
keyword tokens as field names inside `type { ... }` declarations. This is not a
stream syntax change.

---

## Remaining Stream Lowering Gaps

[R] Remaining stream gaps:

1. `window_ref` matching per stream and fold remains proof-carried metadata. The
   parser/classifier surface still lacks an explicit per-stream window identity.

2. TBackend read inside `fold_stream` lambda remains an explicit strictness gap
   for OOF-S3. Current TypeChecker detection catches stream refs in the lambda
   body, but not read/TBackend ESCAPE refs.

3. Production parser -> classifier -> typechecker -> typed emitter orchestration
   still needs to carry stream/window/fold metadata end to end instead of using
   the proof-local TypedProgram carrier.

4. Runtime stream adapter integration remains proof-local. The proof models
   finite replay and open live descriptors, but production runtime capabilities
   are not wired.

5. `on_close: :snapshot` to OLAP snapshot bridge remains future work. This slice
   only preserves the observation boundary shape.

6. Invariant severity lowering remains deferred; no stream change depends on it.

---

## Verification

```text
ruby igniter-lang/experiments/stream_t_proof/stream_t_proof.rb
  -> PASS stream_t_proof

ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden
  -> PASS typechecker_golden_check

ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden
  -> PASS source_to_semanticir_fixture_golden_check

ruby -c igniter-lang/lib/igniter_lang/semanticir_emitter.rb
  -> Syntax OK

ruby -c igniter-lang/lib/igniter_lang/parser.rb
  -> Syntax OK

ruby -c igniter-lang/experiments/stream_t_proof/stream_t_proof.rb
  -> Syntax OK
```

---

## Handoff

```text
Card: S2-R10-C2-P
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/stream-semanticir-surface-lowering-v0
Status: done

[D] Decisions:
- Added typed stream lowering to SemanticIREmitter.
- Kept parser stream syntax unchanged.
- Preserved OOF-S1..S5 ownership and SC-1/2/3 behavior.
- Restored type field keyword compatibility after adjacent invariant keyword drift.

[S] Shipped / Signals:
- stream_t_proof now consumes SemanticIREmitter#emit_typed output.
- Emitted stream nodes preserve stream_input_node, window_decl_node, and fold_stream_node shapes.
- Stream typed contracts emit the stream_input escape boundary.

[T] Tests / Proofs:
- stream_t_proof: PASS.
- typechecker_proof --check-golden: PASS.
- source_to_semanticir_fixture --check-golden: PASS.
- Ruby syntax checks: PASS.

[R] Risks / Residuals:
- TBackend read inside fold lambda remains a strictness gap.
- Per-stream window_ref matching is still not grammar-owned.
- Production stream TypedProgram carrier remains to be wired end to end.

[Next]
- TypeChecker should carry fold_stream expr/bound/window metadata in accepted TypedProgram.
- Parser/classifier should eventually represent explicit stream-to-window refs.
- Bridge Agent can plan production compiler orchestration for typed emitter entry.
```
