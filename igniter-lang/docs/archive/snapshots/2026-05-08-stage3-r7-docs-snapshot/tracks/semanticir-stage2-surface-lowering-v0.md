# Track: SemanticIR Stage 2 Surface Lowering v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: igniter-lang/semanticir-stage2-surface-lowering-v0
Card: S2-R9-C2-P
Status: done
Date: 2026-05-07

---

## Context

R8 extracted `IgniterLang::SemanticIREmitter` as a reusable Stage 1
`ParsedProgram -> SemanticIRProgram` boundary. R8 also proved OLAPPoint
TypeChecker/SemanticIR shapes proof-locally.

This slice starts moving proven Stage 2 surfaces into the extracted emitter
without changing the existing source-to-SemanticIR fixture outputs.

---

## Implemented Boundary

[D] `IgniterLang::SemanticIREmitter` now has a typed Stage 2 entry point:

```ruby
IgniterLang::SemanticIREmitter.new.emit_typed(typed_program)
```

It accepts a `TypedProgram` hash and returns the same high-level envelope shape
as the existing parsed-source emitter:

```text
{
  "semantic_ir" => SemanticIRProgram | nil,
  "compilation_report" => CompilationReport
}
```

[D] The existing `emit(parsed_program, sample_input:)` path is unchanged. This
preserves Stage 1 source fixture goldens and keeps production CLI behavior stable.

[D] `emit_typed` lowers OLAPPoint TypedProgram artifacts into:

- top-level `olap_point_decl` entries from `typed_program["olap_points"]`
- contract `olap_access_node` entries from typed declarations carrying
  `semantic_node`
- explicit `result_type.dims_record`

The emitted OLAP access node preserves the R8 shape:

```json
{
  "kind": "olap_access_node",
  "name": "revenue_point",
  "olap_ref": "Revenue",
  "operation": "point",
  "result_type": {
    "constructor": "OLAPPoint",
    "measure": "Decimal[2]",
    "dims_record": {
      "kind": "dims_record",
      "dims": { "date": "String", "region": "String", "channel": "String" }
    }
  }
}
```

---

## Proof Updates

`olap_point_proof.rb` now uses the extracted emitter for the OLAP boundary:

```ruby
IgniterLang::SemanticIREmitter.new.emit_typed(typed)
```

Updated goldens:

```text
experiments/olap_point_proof/golden/semantic_ir_boundary.json
experiments/olap_point_proof/golden/typechecker_boundary.json
experiments/olap_point_proof/summary.json
```

New proof signal:

```text
semanticir.emitter_typed_program_ref: ok
```

---

## Deferred Surfaces

[R] Remaining Stage 2 SemanticIR gaps:

```text
1. Stream SemanticIR lowering
   stream_input_node / window_decl_node / fold_stream_node still live in
   stream_t_proof as proof-local SemanticIR. Not moved here to avoid expanding
   the emitter and OLAP surface in one slice.

2. Invariant severity lowering
   Parser/TypeChecker implementation remains deferred. SemanticIR lowering should
   wait until invariant severity is represented in TypedProgram.

3. OLAP rollup/drill/compare SemanticIR
   This slice lowers point access only. Distributed rollup/scatter-gather planning
   remains out of scope.

4. Production classifier -> typechecker -> typed emitter orchestration
   The typed OLAP carrier is proven, but the production compiler pipeline still
   needs a coordinator that feeds TypedProgram into SemanticIREmitter.

5. Source function signature lowering
   `source:` typing for OLAP declarations remains future TypeChecker/emitter work.
```

[X] Stream lowering was not added in this card.

Reason: the current stream SemanticIR proof is independent and carries runtime
semantics. Adding it beside OLAP typed lowering would risk mixing two Stage 2
surfaces in one emitter change.

[X] Invariant severity lowering remains deferred.

Reason: the implementation surface is not yet present in TypedProgram.

---

## Verification

```text
ruby igniter-lang/experiments/olap_point_proof/olap_point_proof.rb
  -> PASS olap_point_proof
  -> semanticir.emitter_typed_program_ref: ok

ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden
  -> PASS source_to_semanticir_fixture_golden_check

ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden
  -> PASS typechecker_golden_check

ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
  -> PASS stage1_close_candidate

ruby -c igniter-lang/lib/igniter_lang/semanticir_emitter.rb
  -> Syntax OK

ruby -c igniter-lang/experiments/olap_point_proof/olap_point_proof.rb
  -> Syntax OK
```

---

## Handoff

```text
Card: S2-R9-C2-P
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/semanticir-stage2-surface-lowering-v0
Status: done

[D] Decisions:
- Added SemanticIREmitter#emit_typed for TypedProgram -> SemanticIRProgram.
- Integrated OLAPPoint typed boundary lowering into the extracted emitter.
- Preserved olap_access_node and dims_record shapes from R8.
- Kept existing ParsedProgram emitter path stable.
- Did not add stream or invariant severity lowering in this slice.

[S] Shipped / Signals:
- OLAP proof goldens now exercise the extracted SemanticIREmitter.
- Source-to-SemanticIR Stage 1 goldens remain unchanged and PASS.
- Typed SemanticIR output now includes compilation_report_ref and contract_ref.

[T] Tests / Proofs:
- olap_point_proof: PASS.
- source_to_semanticir_fixture --check-golden: PASS.
- typechecker_proof --check-golden: PASS.
- stage1_close_candidate: PASS.

[R] Remaining Stage 2 SemanticIR gaps:
- stream_input_node/window_decl_node/fold_stream_node emitter lowering.
- invariant severity emitter lowering after parser/TypeChecker implementation.
- OLAP rollup/drill/compare/scatter-gather lowering.
- production orchestration from TypedProgram into SemanticIREmitter.
- OLAP source function signature lowering.

[Next] Suggested next slice:
- stream-semanticir-surface-lowering-v0, after deciding whether stream lowering
  should consume ParsedProgram, ClassifiedProgram, or TypedProgram as its source.
```

## Files Changed

```text
igniter-lang/lib/igniter_lang/semanticir_emitter.rb
igniter-lang/experiments/olap_point_proof/olap_point_proof.rb
igniter-lang/experiments/olap_point_proof/golden/semantic_ir_boundary.json
igniter-lang/experiments/olap_point_proof/golden/typechecker_boundary.json
igniter-lang/experiments/olap_point_proof/summary.json
igniter-lang/docs/tracks/semanticir-stage2-surface-lowering-v0.md
```
