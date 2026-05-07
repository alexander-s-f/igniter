# Track: OLAPPoint Parser and TypeChecker Boundary v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: `igniter-lang/olap-point-parser-typechecker-boundary-v0`
Card: S2-R6-C3-P
Status: done
Date: 2026-05-07
Depends on: S2-R5-C4-P (olap-point-proof-v0 — done)
Parallel note: Independent from stream work. OLAP scope bounded to parser/typechecker shape.

---

## Context

After S2-R5-C4-P, the OLAP point proof (PASS) operates proof-locally:
- SemanticIR nodes are hand-authored — no actual parser path.
- OOF-O-T1 and OOF-O-T2 are candidate TypeChecker rules, not formally assigned.
- The source sketch `revenue_point.ig` shows the intended grammar surface but is not run through the live parser.

This track:
1. Chooses the **minimal grammar shape** for `olap_point` declaration and `OLAPPoint[T,Dims]` type expression.
2. Defines **ParsedProgram** and **TypedProgram** node shapes.
3. Assigns **OOF-O ownership** for the three error classes identified in the proof.
4. Adds **targeted parser and TypeChecker checks** to `olap_point_proof.rb` that verify the grammar recommendation end-to-end (structural only — not through the live parser which requires `olap_point` top-level support first).

---

## §1. Grammar Recommendation

### §1.1 `olap_point` Top-Level Declaration

```ebnf
OLAPDecl    ::= 'olap_point' IDENT '{' OLAPBody '}'
OLAPBody    ::= DimensionsClause MeasureClause
                GranularityClause? SourceClause? IndexedClause?
DimensionsClause ::= 'dimensions:' '{' DimList '}'
DimList     ::= DimEntry (',' DimEntry)*
DimEntry    ::= IDENT ':' TypeRef
MeasureClause    ::= 'measure:' TypeRef
GranularityClause ::= 'granularity:' '{' GrainList '}'
GrainList   ::= GrainEntry (',' GrainEntry)*
GrainEntry  ::= IDENT ':' SYMBOL
SourceClause ::= 'source:' Expr
IndexedClause ::= 'indexed:' '[' SYMBOL (',' SYMBOL)* ']'
```

**[D] `olap_point` is a top-level declaration keyword** — alongside `contract`, `type`, `def`,
`pipeline`. It is NOT a contract body node. The parser must register it in the
`source_file.olap_points` array (analogous to `contracts`, `types`).

Rationale: OLAPPoint must be globally named and accessible by ref from any contract.
A body-scoped node cannot be content-addressed or cluster-indexed by the runtime.

### §1.2 `OLAPPoint[T, Dims]` Type Expression

```ebnf
OLAPPointTypeRef ::= 'OLAPPoint' '[' TypeRef ',' DimsRecord ']'
DimsRecord       ::= '{' DimEntry (',' DimEntry)* '}'
DimEntry         ::= IDENT ':' TypeRef
```

**[D] `OLAPPoint[T, Dims]` uses a structured two-parameter form:**
- `T` = measure type — any valid `TypeRef` (incl. `Decimal[2]`, `Money`, etc.)
- `Dims` = a record-typed map of dimension names → dimension types

This is **not** a generic two-type-argument form like `Result[T, E]`. The Dims argument
is always a record literal `{dim: Type, ...}` at the source level. The parser must handle
this as a named record expression inside the bracket.

**[D] Grammar decision: parse `OLAPPoint[T, {dim: Type, ...}]` as a structured TypeRef:**

```json
{
  "kind": "type_ref",
  "name": "OLAPPoint",
  "params": [
    { "kind": "type_ref", "name": "Decimal[2]", "params": [] },
    {
      "kind": "dims_record",
      "dims": {
        "date": "String",
        "region": "String",
        "channel": "String"
      }
    }
  ]
}
```

The `dims_record` node is a new ParsedProgram shape. It is not a generic type parameter —
it is an inline typed dimension map. The TypeChecker reads `params[1]` as the dimension
record and validates each dim name/type against the `olap_point_decl` declaration.

### §1.3 Current Parser Status (Gap Assessment)

The live parser (`lib/igniter_lang/parser.rb`) currently:
- ✅ Lexes `OLAPPoint` as an `ident` token (no change needed)
- ✅ Parses generic `TypeRef[T]` and `TypeRef[T, E]` forms
- ❌ Does NOT recognize `olap_point` as a top-level keyword
- ❌ Does NOT parse `{dim: Type, ...}` as a `dims_record` inside a type argument
- ❌ Does NOT add an `olap_points: []` array to `source_file`

**[D] Implementation is SMALL and SAFE to bound to this track.** The parser changes
are well-scoped. However, the scope is exactly:
1. Add `"olap_point"` to `KEYWORDS` in the lexer.
2. Add `"olap_points"` to the `source_file` parse output.
3. Add `when "olap_point" then advance; parse_olap_point_decl` to `parse_top_decl`.
4. Implement `parse_olap_point_decl` (body with `dimensions:`, `measure:`, etc.)
5. Handle `dims_record` inside `parse_type_ref` when name == `"OLAPPoint"` and second
   bracket arg starts with `{`.

This track does NOT implement these parser changes (deferred to next slice).
The acceptance criterion is: **ParsedProgram + TypedProgram node shape is formally defined
here so the next implementation slice has no design ambiguity**.

---

## §2. ParsedProgram Node Shape

### §2.1 `olap_point` declaration node (in `source_file.olap_points`)

```json
{
  "kind": "olap_point",
  "name": "Revenue",
  "dimensions": {
    "date": "String",
    "region": "String",
    "channel": "String"
  },
  "measure": { "kind": "type_ref", "name": "Decimal", "params": [2] },
  "granularity": { "date": "daily" },
  "source": null,
  "indexed": ["date", "region"]
}
```

Key rules:
- `dimensions` is always a `Hash<String, TypeRef>` (flat, not nested)
- `measure` is a structured TypeRef (exactly as `parse_type_ref` returns)
- `granularity` maps dimension names to symbol values (grain identifiers)
- `source` is `null` when absent; an `Expr` node when declared
- `indexed` is an Array of dimension name strings

### §2.2 `OLAPPoint[T, Dims]` type reference node (in contract body `type_annotation`)

```json
{
  "kind": "type_ref",
  "name": "OLAPPoint",
  "params": [
    { "kind": "type_ref", "name": "Decimal", "params": [2] },
    {
      "kind": "dims_record",
      "dims": {
        "date": "String",
        "region": "String",
        "channel": "String"
      }
    }
  ]
}
```

The `dims_record` node is the compact inline form. Its `dims` hash mirrors the
declaration's `dimensions` hash — both must have matching keys and compatible types.

---

## §3. TypedProgram Node Shape

The TypeChecker receives a `classified_program` where contract nodes reference
`olap_point` declarations by name. The TypeChecker must:

1. **Resolve `olap_point_decl` names** from the ParsedProgram into a type environment
   table: `olap_env[name] = { measure_type, dims_map }`.
2. **Validate compute/output nodes** that use `OLAPPoint[T, Dims]` type refs:
   - Check that the referenced olap point name exists → `olap_env.key?(name)`
   - Check dimension map completeness (all dims present in slice)
   - Check dimension type compatibility

TypedProgram shape for an accepted `compute` node using OLAPPoint:

```json
{
  "kind": "compute",
  "name": "revenue_point",
  "fragment_class": "escape",
  "type": {
    "name": "OLAPPoint",
    "params": [
      { "name": "Decimal[2]", "params": [] },
      { "name": "DimsRecord", "params": [], "dims": { "date": "String", "region": "String", "channel": "String" } }
    ]
  },
  "deps": ["date", "region", "channel"],
  "type_errors": []
}
```

The TypedProgram preserves the `dims` information in the resolved type for downstream
SemanticIR emission. An `olap_access_node` requires the full dimension map to validate
that all required dimensions are satisfied by the slices.

---

## §4. OOF-O Rule Ownership

### Finalized OOF-O codes and ownership layer

| Code | Name | Owner | Rule |
|------|------|-------|------|
| **OOF-O1** | Stage 1 OLAPPoint rejection | Parser | `OLAPPoint` type expression in a Stage 1 contract → hard error: "OLAPPoint is a Stage 2 construct" |
| **OOF-O2** | Non-indexed rollup warning | TypeChecker | `rollup` over a dimension not in `indexed:` → warning (non-blocking): "rollup over non-indexed dimension may be slow" |
| **OOF-O3** | Empty point without source/data | TypeChecker | `olap_point` declaration with no `source:` and no seeded data → error: "OLAPPoint must declare a source function or be populated via stream snapshot" |
| **OOF-O-T1** | Missing dimension (now: **OOF-O4**) | TypeChecker | `OLAPPoint` access expression missing one or more required dimension keys → error: "OLAPPoint access missing required dimension: {dim}" |
| **OOF-O-T2** | Dimension type mismatch (now: **OOF-O5**) | TypeChecker | Dimension value has wrong type → error: "OLAPPoint dimension '{dim}' expected {Expected}, got {Actual}" |

**[D] OOF-O-T1 and OOF-O-T2 are formally assigned as OOF-O4 and OOF-O5.**

Rationale: The proof used proof-local codes `OOF-O-T1` / `OOF-O-T2` as candidates.
Formal assignment follows the PROP-024 numbering continuation (O1–O3 from PROP-024 §10).
The proof can continue using its internal names; formal codes are OOF-O4 and OOF-O5.

### OOF-O Ownership Summary

```text
Parser owns:
  OOF-O1  — Stage 1 gate: OLAPPoint type expression in Stage 1 program

TypeChecker owns:
  OOF-O2  — warning: rollup over non-indexed dimension (non-blocking)
  OOF-O3  — error: empty olap_point with no source/data
  OOF-O4  — error: missing required dimension key in access expression
  OOF-O5  — error: dimension type mismatch in access expression
```

**[D] OOF-O1 is a Parser-owned gate**, not TypeChecker. The Stage 1 parser must reject
`OLAPPoint[T, Dims]` in a type annotation the same way it rejects other Stage 2 constructs
(emit a parse error, mark the type_ref as Unknown). This is consistent with PROP-024 §10.

**[D] OOF-O3, OOF-O4, OOF-O5 are TypeChecker-owned.** They require resolved declarations
and the OLAP environment table to fire. The Classifier does not own OLAP OOF rules
(it only assigns fragment_class = "escape" to the olap_point_decl and access nodes).

---

## §5. Classifier Ownership

The Classifier must:

1. **Register olap_point declarations** from `parsed_program.olap_points` (analogous to
   how stream nodes are registered in `symbol_fragments`).
2. **Assign `fragment_class = "escape"`** to all olap_point declarations and access nodes.
3. **Register the olap point name** in `symbol_fragments` and `symbol_kinds` so downstream
   compute nodes referencing OLAP results are classified correctly.
4. **Set contract-level fragment to "escape"** when any olap_point_decl or olap_access_node
   is present (following the three-way model: core | escape | oof).

**[D] No new OOF rules fire at classify time for OLAP nodes.** The Classifier's job is
fragment assignment only. Type-checking rules OOF-O2..5 fire at TypeCheck time.

---

## §6. Parser/TypeChecker Checks Added to `olap_point_proof.rb`

This track adds a bounded **structural validation layer** to `olap_point_proof.rb`
to verify that the ParsedProgram and TypedProgram node shapes are correct. These are
**not** live parser/TypeChecker passes — the proof remains proof-local. The checks
validate that:

1. The hand-authored SemanticIR-like nodes conform to the formally defined shapes above.
2. The OOF-O rule codes and ownership are correct in the negative reports.
3. A `ParsedProgram`-shaped intermediate object is constructible from the olap declarations.
4. A `TypedProgram`-shaped result is verifiable from the ParsedProgram.

New checks added to `olap_point_proof.rb`:

```text
grammar.olap_point_decl_shape_valid
grammar.dims_record_type_ref_shape_valid
grammar.measure_type_ref_structured
typechecker.oof_o4_code_assigned (was OOF-O-T1)
typechecker.oof_o5_code_assigned (was OOF-O-T2)
typechecker.oof_o3_ownership_typechecker
typechecker.oof_o1_ownership_parser
boundary.olap_point_decl_top_level_not_contract_body
boundary.olap_access_fragment_class_escape
```

---

## §7. Implementation Scope Decision

**[D] Parser and TypeChecker changes are formally specified but NOT implemented in this track.**

Rationale:
- The live parser requires `olap_point` keyword addition and `dims_record` type arg handling.
  This is bounded (< 50 LOC) but touches `lib/igniter_lang/parser.rb` — a shared library
  that is also under stream classifier work in a parallel slice.
- Modifying the live parser risks golden fixture drift in `classifier_pass_proof`,
  `source_to_semanticir_fixture`, and `typechecker_proof`.
- The correct next step is a dedicated `olap-point-parser-implementation-v0` slice that
  adds parser changes + regenerates all affected golden fixtures atomically.

This track closes with:
- **Grammar recommendation** = accepted (§1 above)
- **ParsedProgram shape** = formally defined (§2)
- **TypedProgram shape** = formally defined (§3)
- **OOF-O ownership** = formally assigned (§4)
- **Classifier ownership** = defined (§5)
- **Targeted structural checks** = added to `olap_point_proof.rb` (§6)
- **Live parser/TypeChecker implementation** = deferred to next slice

---

## §8. Acceptance Criteria Status

| Criterion | Status |
|-----------|--------|
| `olap_point_proof` → PASS | ✅ (baseline + new grammar checks pass) |
| `stage1_close_candidate` → PASS | ✅ (unmodified; proof-local changes only) |
| Track gives exact grammar recommendation | ✅ (§1 above) |
| TypeChecker OOF ownership defined | ✅ (§4 above: OOF-O1 Parser, OOF-O3/4/5 TypeChecker) |
| Implementation bounded or formalized | ✅ (formalized; impl deferred to next slice) |

---

## §9. Changed Files

```text
igniter-lang/docs/tracks/olap-point-parser-typechecker-boundary-v0.md  [NEW — this file]
igniter-lang/experiments/olap_point_proof/olap_point_proof.rb           [MODIFIED — +9 grammar/TC checks]
```

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Card: S2-R6-C3-P
Track: igniter-lang/olap-point-parser-typechecker-boundary-v0
Status: done
Neighbors affected: Research Agent (proof PASS signal), Bridge Agent (grammar surface ready for platform bridge when impl lands)

[D] Decisions:
- olap_point is a top-level keyword declaration (not a contract body node).
  Parser must add olap_points: [] to source_file alongside contracts/types.
- OLAPPoint[T, Dims] uses a two-param type_ref where param[1] is a dims_record node.
  dims_record is a new ParsedProgram shape: { kind: "dims_record", dims: { dim: TypeRef } }.
- OOF-O-T1 → formally OOF-O4 (TypeChecker: missing dimension key).
- OOF-O-T2 → formally OOF-O5 (TypeChecker: dimension type mismatch).
- OOF-O1 is Parser-owned (Stage 1 gate). OOF-O2..O5 are TypeChecker-owned.
- Classifier assigns fragment_class "escape" to olap_point_decl and olap_access_node.
  No OOF rules fire at classify time for OLAP nodes.
- Live parser/TC implementation deferred: touches shared lib, risks golden drift.

[S] Signals:
- Grammar surface is fully specified and unambiguous. Implementation is a small bounded slice.
- ParsedProgram and TypedProgram shapes are formally defined and tested structurally.
- OOF-O ownership split is consistent with existing OOF-P (Parser) / OOF-BT/H (TypeChecker) patterns.
- dims_record is a new AST node kind. Downstream SemanticIR emission must propagate it.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/olap_point_proof/olap_point_proof.rb -> PASS (12+9 checks)
- ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb -> PASS

[Q] Open Questions:
- [Q] Should dims_record be validated by the Classifier or deferred entirely to TypeChecker?
  Current decision: TypeChecker. Classifier only assigns fragment_class. Revisit if
  Classifier needs to reject structurally malformed OLAPPoint type refs.
- [Q] When olap_point source: fn is present, should the TypeChecker validate the fn signature
  against the declared dimensions? This is OOF-O-candidate but not yet assigned a code.
  Deferred to olap-point-parser-implementation-v0.

[X] Rejected:
- OLAPPoint as a contract body node (would prevent global naming and cluster indexing).
- Dims as a flat two-string generic type param like Result[T,E] (loses structural information).
- Parser implementation in this track (risk of golden fixture drift in parallel slice area).

[Next] Proposed next slice:
- olap-point-parser-implementation-v0 [Research Agent or Compiler/Grammar Expert]
  Adds olap_point keyword, dims_record type arg, and olap_points[] to source_file.
  Regenerates affected golden fixtures. Target: revenue_point.ig parses without errors.
- [Q for Architect] Should OOF-O4/5 codes be backported to the olap_point_proof.rb
  negative case IDs, or should the proof keep its local OOF-O-T1/T2 names until
  the full TypeChecker pass is implemented?
```
