# Track: OLAPPoint Parser Implementation v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/olap-point-parser-implementation-v0`
Card: S2-R7-C3-P
Status: done
Date: 2026-05-07
Depends on: S2-R6-C3-P
Parallel note: Parser/typechecker extraction may run nearby. Kept implementation parser-local and golden-guarded.

---

## Context

The boundary track `olap-point-parser-typechecker-boundary-v0` defined the minimal live
parser surface for PROP-024:

- top-level `olap_point Name { ... }`
- `source_file.olap_points`
- `OLAPPoint[T, {dim: Type, ...}]` with a structured `dims_record` type parameter
- parser ownership of the Stage 1 OOF-O1 gate, with OOF-O2..O5 deferred to TypeChecker

Before this slice, `experiments/olap_point_proof/revenue_point.ig` was a syntax sketch:
the live parser could not parse the `olap_point` declaration, the inline dims record, or
the proof's bracketed OLAP slice expression.

---

## Implemented Boundary

`lib/igniter_lang/parser.rb` now supports the minimal OLAPPoint parser boundary:

1. `olap_point` is a lexer keyword and top-level declaration.
2. ParsedProgram includes `olap_points: []` in the public envelope.
3. `parse_olap_point_decl` emits:

```json
{
  "kind": "olap_point",
  "name": "Revenue",
  "dimensions": { "date": "String", "region": "String", "channel": "String" },
  "measure": { "kind": "type_ref", "name": "Decimal", "params": [2] },
  "granularity": { "date": "daily" },
  "source": null,
  "indexed": ["date", "region"]
}
```

4. `OLAPPoint[Decimal[2], {date: String, ...}]` emits the boundary `dims_record` node:

```json
{
  "kind": "type_ref",
  "name": "OLAPPoint",
  "params": [
    { "kind": "type_ref", "name": "Decimal", "params": [2] },
    { "kind": "dims_record", "dims": { "date": "String" } }
  ]
}
```

5. Typed `compute name: Type = expr` is accepted so the OLAP proof sketch can carry its
   result type annotation without changing existing untyped compute nodes.
6. Bracketed named slices such as `Revenue[date: date, region: region]` parse as an
   `index_access` whose index is a `slice_record`.
7. Files with any top-level OLAP point report `grammar_version: "olap-point-v0"`.

The implementation deliberately does not emit SemanticIR OLAP nodes, validate OLAP type
compatibility, or implement distributed scatter/gather.

---

## Golden Impact

Adding `olap_points: []` changes the stable ParsedProgram envelope. The active
`source_to_semanticir_fixture` parsed-AST goldens were regenerated so golden checks remain
deterministic. No SemanticIR or compilation report JSON shape changed for the Stage 1
fixtures.

---

## Remaining TypeChecker Gap

The next compiler extraction unit should be **OLAPPoint TypeChecker/SemanticIR boundary**:

- Build an `olap_env` from `parsed_program.olap_points`.
- Validate `OLAPPoint[T, dims_record]` measure and dimension compatibility.
- Type `slice_record` access and lower it toward `olap_access_node`.
- Fire TypeChecker-owned OOF-O2, OOF-O3, OOF-O4, and OOF-O5.
- Keep OOF-O1 as a parser/compiler-stage gate for Stage 1 compilers.

Classifier ownership remains limited to escape-fragment assignment and symbol registration;
no OLAP OOF rule should fire in Classifier.

---

## Acceptance Status

| Check | Status |
|-------|--------|
| `ruby igniter-lang/experiments/olap_point_proof/olap_point_proof.rb` | PASS |
| `bundle exec rspec spec/igniter/parser_acceptance_spec.rb` | PASS (61 examples) |
| `ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden` | PASS |
| `ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb` | PASS |
| Parser smoke: `revenue_point.ig` live parse | PASS |

---

## Handoff

```text
[Igniter-Lang Research Agent]
Card: S2-R7-C3-P
Track: igniter-lang/olap-point-parser-implementation-v0
Status: done

[D] Decisions:
- olap_point is implemented as a top-level declaration and appears in ParsedProgram.olap_points.
- dims_record is implemented only as the second OLAPPoint type parameter.
- Typed compute and named bracket slices were added because the OLAP proof source sketch uses them.
- Source clauses are retained as raw parser expressions for now; full source fn typing is deferred.

[S] Signals:
- revenue_point.ig now parses through the live parser with grammar_version olap-point-v0.
- Stage 1 SemanticIR and compilation report shapes are unchanged; only parsed_ast goldens gained olap_points: [].
- Parser remains the only changed compiler library surface in this slice.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/olap_point_proof/olap_point_proof.rb -> PASS
- bundle exec rspec spec/igniter/parser_acceptance_spec.rb -> PASS (61 examples)
- ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden -> PASS
- ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb -> PASS

[R] Risks:
- The parser can carry OLAP shapes, but TypeChecker does not yet validate OLAP declarations or access.
- slice_record is parser-only until the TypeChecker/SemanticIR boundary consumes it.
- source: fn bodies are captured as raw expressions; signature validation is intentionally out of scope.

[Next] OLAPPoint TypeChecker/SemanticIR boundary:
- Build olap_env, validate dims_record compatibility, lower slice_record to olap_access_node,
  and implement OOF-O2/O3/O4/O5 while preserving the parser-owned OOF-O1 gate.
```
