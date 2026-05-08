# Track: OLAPPoint TypeChecker SemanticIR v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: igniter-lang/olap-point-typechecker-semanticir-v0
Card: S2-R8-C2-P
Status: done
Date: 2026-05-07
Depends on: S2-R7-C3-P

---

## Context

S2-R7-C3-P made the live parser accept the minimal OLAP surface:

- top-level `olap_point`
- `ParsedProgram.olap_points`
- `OLAPPoint[T, {dim: Type}]` with `dims_record`
- named bracket slices parsed as `index_access` over `slice_record`

This slice implements/proves the next boundary: TypeChecker ownership of
`OOF-O2..OOF-O5` and typed lowering toward SemanticIR OLAP nodes. Distributed OLAP
execution remains out of scope.

---

## Implemented Boundary

[D] `IgniterLang::TypeChecker` now accepts optional top-level
`classified_program["olap_points"]` and builds an `olap_env`.

Each OLAP declaration lowers to a typed/semantic declaration:

```json
{
  "kind": "olap_point_decl",
  "name": "Revenue",
  "dimensions": { "date": "String", "region": "String", "channel": "String" },
  "measure_type": "Decimal[2]",
  "granularity": { "date": "daily" },
  "source_ref": "synthetic_fulfilled_order_facts",
  "indexed": ["date", "region"]
}
```

[D] `index_access` over a known OLAP point with `slice_record` lowers to an
`olap_access_node` on the typed compute declaration.

The node carries:

- `olap_ref`
- sorted typed `slices`
- `operation: "point"`
- `result_type.measure`
- `result_type.dims_record`
- scalar `resolved_type` equal to the OLAP measure type for fully specified point access

[D] `dims_record` is preserved as an explicit semantic boundary shape rather
than collapsed into a generic type parameter.

---

## OOF-O Ownership

[D] TypeChecker now owns:

```text
OOF-O2  rollup over non-indexed dimension without explicit scatter/gather flag
        -> warning, non-blocking

OOF-O3  olap_point with no source/source_ref/seeded_data
        -> blocking error

OOF-O4  OLAPPoint access missing a required dimension
        -> blocking error

OOF-O5  dimension value type mismatch
        -> blocking error
```

[D] `OOF-O4` and `OOF-O5` replace the proof-local aliases `OOF-O-T1` and
`OOF-O-T2` in the OLAP proof outputs.

[D] `OOF-O1` remains parser/stage-gate owned and was not implemented here.

---

## Proof Updates

`olap_point_proof.rb` now runs a live parser + TypeChecker boundary proof for
`revenue_point.ig`:

- parses live `olap_point Revenue`
- builds a proof-local ClassifiedProgram preserving `olap_points`
- typechecks the positive OLAP point access
- lowers typed declarations into proof-local SemanticIR boundary output
- exercises OOF-O2/O3/O4/O5 targeted cases

New OLAP golden artifacts:

```text
experiments/olap_point_proof/golden/typechecker_boundary.json
experiments/olap_point_proof/golden/semantic_ir_boundary.json
```

Existing runtime behavior remains intact: cells materialize, point access is
deterministic, and local rollup stays `local_single_node_no_scatter_gather`.

---

## Not Implemented

[X] Distributed scatter/gather execution is not implemented.

This slice only records `OOF-O2` as a non-blocking TypeChecker warning for
non-indexed rollup without an explicit scatter/gather flag. Planning and runtime
execution of scatter/gather remains future distributed OLAP work.

[X] The production SemanticIR emitter module is not changed here.

The proof emits SemanticIR-shaped OLAP boundary output from `TypedProgram`, but
the reusable emitter extraction is a neighboring Stage 2 track.

[X] Full `source:` function signature typing is not implemented.

This slice recognizes `source`, `source_ref`, or `seeded_data` as satisfying
`OOF-O3`; checking that a source function's parameters match the dimension map
remains future TypeChecker work.

---

## Verification

```text
ruby igniter-lang/experiments/olap_point_proof/olap_point_proof.rb
  -> PASS olap_point_proof
  -> typechecker.oof_o2_warning_nonblocking: ok
  -> typechecker.oof_o3_empty_without_source: ok
  -> typechecker.oof_o4_missing_dimension: ok
  -> typechecker.oof_o5_dimension_type_mismatch: ok
  -> semanticir.boundary_olap_point_decl_from_typed: ok
  -> semanticir.boundary_olap_access_node_from_typed: ok
  -> semanticir.boundary_dims_record_lowered: ok

ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden
  -> PASS typechecker_golden_check

ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
  -> PASS stage1_close_candidate
```

Neighbor note: the current shared worktree also contains a stream `OOF-S3`
TypeChecker proof surface. This OLAP slice verified against that combined
worktree and did not revert or re-own the neighboring stream files.

---

## Handoff

```text
Card: S2-R8-C2-P
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/olap-point-typechecker-semanticir-v0
Status: done

[D] Decisions:
- TypeChecker builds an OLAP environment from optional classified_program.olap_points.
- Typed OLAP declarations lower to olap_point_decl semantic nodes.
- OLAP slice access lowers to olap_access_node with explicit dims_record.
- OOF-O2 is a non-blocking warning; OOF-O3/O4/O5 are blocking TypeChecker errors.
- OOF-O4/O5 replace proof-local OOF-O-T1/T2 in OLAP proof outputs.
- Scatter/gather execution stays out of scope.

[S] Shipped / Signals:
- Added live parser + TypeChecker OLAP boundary proof inside olap_point_proof.
- Added SemanticIR-shaped OLAP boundary golden output.
- Existing OLAP runtime proof behavior remains PASS.

[T] Tests / Proofs:
- olap_point_proof: PASS.
- typechecker_proof --check-golden: PASS.
- stage1_close_candidate: PASS.
- Ruby syntax checks for touched Ruby files: PASS.

[R] Risks / Recommendations:
- The ClassifiedProgram OLAP carrier is proof-local; production classifier/emitter
  integration should be coordinated with the SemanticIR emitter extraction track.
- Source function signature validation is still a future TypeChecker rule.
- Distributed OLAP scatter/gather planning remains future work.

[Next] Suggested next slice:
- Integrate OLAP nodes into the extracted SemanticIR emitter once that emitter
  boundary is stable.
```

## Files Changed

```text
igniter-lang/lib/igniter_lang/typechecker.rb
igniter-lang/experiments/olap_point_proof/olap_point_proof.rb
igniter-lang/experiments/olap_point_proof/summary.json
igniter-lang/experiments/olap_point_proof/golden/negative_missing_dimension.json
igniter-lang/experiments/olap_point_proof/golden/negative_dimension_type_mismatch.json
igniter-lang/experiments/olap_point_proof/golden/typechecker_boundary.json
igniter-lang/experiments/olap_point_proof/golden/semantic_ir_boundary.json
igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.json
igniter-lang/docs/tracks/olap-point-typechecker-semanticir-v0.md
```
