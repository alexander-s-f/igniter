# Track: Polymorphic Add Parser Acceptance v0

Status: done
Slice state: done on 2026-05-06
Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/polymorphic-add-parser-acceptance-v0`
Supervisor: `[Architect Supervisor / Codex]`
Neighbors: `[Igniter-Lang Compiler/Grammar Expert]`
Artifacts:
- `igniter-lang/experiments/parser/igniter_lang_parser.rb`
- `igniter-lang/source/polymorphic_add.ig`
- `igniter-lang/source/polymorphic_add.parsed_program.expected.json`

---

## Frame

This slice executes the parser-only phases from
`polymorphic-add-parser-pressure-map-v0`.

The accepted surface is:

```text
trait Additive[T]
impl Additive[Integer] using stdlib.numeric.add
impl Additive[Float] using stdlib.numeric.add
contract_shape AddShape[T]
contract Add[T: Additive] implements AddShape[T]
```

This is syntax acceptance only. The parser preserves unresolved names and type
variables as strings. It does not perform trait coherence, impl resolution,
typechecking, monomorphization, or SemanticIR lowering.

---

## Implemented Phases

Phase 0:

- Added polymorphic keywords: `trait`, `impl`, `using`, `implements`,
  `contract_shape`.
- Confirmed existing identifier handling accepts `_` and lower-case
  dot-qualified refs are stitched by parser helper, not by widening lexer dots.

Phase 1:

- Added `parse_trait_decl`.
- Added signature-only `parse_trait_method`.

Phase 2:

- Added `parse_impl_decl` for `impl Trait[Type] using qualified.ref`.
- Added `parse_qualified_ref`.
- Full impl bodies remain deferred.

Phase 3:

- Added `parse_contract_shape_decl`.
- Shape bodies accept `input` and `output` declarations only.

Phase 4:

- Extended contract headers with generic type params and optional
  `implements`.
- Added bound parsing for `T: Additive`, represented as
  `Additive[T]` in ParsedProgram.

Phase 5:

- `polymorphic_add.ig` now parses to
  `polymorphic_add.parsed_program.expected.json`.
- `grammar_version` for polymorphic constructs is now `polymorphic-v0`.

---

## Output Shape

Top-level ParsedProgram additions:

```text
traits: []
impls: []
contract_shapes: []
```

These are emitted as empty arrays for existing accepted fixtures.

Contract nodes now include:

```text
type_params: []
```

Non-generic contracts get an empty array. Generic contracts carry parsed
type-param bounds. `implements` is emitted only when present.

---

## Proof Output

```text
ruby igniter-lang/experiments/parser/igniter_lang_parser.rb igniter-lang/source/add.ig
  -> parse_errors: []
  -> grammar_version: 0.1.0

ruby igniter-lang/experiments/parser/igniter_lang_parser.rb igniter-lang/source/availability_projection.ig
  -> parse_errors: []
  -> grammar_version: 0.1.0

ruby igniter-lang/experiments/parser/igniter_lang_parser.rb igniter-lang/source/polymorphic_add.ig
  -> parse_errors: []
  -> grammar_version: polymorphic-v0
```

The generated polymorphic JSON matches
`igniter-lang/source/polymorphic_add.parsed_program.expected.json`.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/polymorphic-add-parser-acceptance-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- `polymorphic_add.ig` is now a parser acceptance fixture.
- Parser support is syntax-only.
- Lower-case qualified refs are parsed by `parse_qualified_ref`, not by
  widening lexer dot behavior.
- `impl ... using ...` is the only impl form accepted in this slice.
- Polymorphic parser output uses `grammar_version: polymorphic-v0`.
- Existing accepted fixtures now emit empty `traits`, `impls`,
  `contract_shapes`, and contract `type_params` arrays.

[R] Recommendations:
- Next Compiler/Grammar Expert slice should define ClassifiedProgram handling
  for trait/impl/contract_shape nodes and coherence checks.
- Keep full impl bodies, multi-shape implements lists, and semantic
  monomorphization out of parser work until the classifier/type slices land.

[S] Signals:
- The parser delta was small and additive; no expression parser redesign was
  needed.
- The `Add` contract body was already parseable once the new top-level surfaces
  were recognized.

[T] Tests / Proofs:
- add.ig parses with `parse_errors: []`.
- availability_projection.ig parses with `parse_errors: []`.
- polymorphic_add.ig parses with `parse_errors: []`.
- polymorphic output matches `polymorphic_add.parsed_program.expected.json`.

[Files] Changed:
- igniter-lang/experiments/parser/igniter_lang_parser.rb
- igniter-lang/source/polymorphic_add.ig
- igniter-lang/source/polymorphic_add.parsed_program.expected.json
- igniter-lang/docs/tracks/polymorphic-add-parser-acceptance-v0.md
- igniter-lang/docs/README.md
- igniter-lang/docs/current-status.md

[Q] Open Questions:
- Should full-body `impl` declarations be accepted before classifier work, or
  wait for a semantic reason?
- Should `implements` parse a list now, or wait for a fixture that needs it?

[X] Rejected:
- Trait coherence in the parser.
- Monomorphization in the parser.
- Typechecking or SemanticIR lowering in this slice.

[Next] Proposed next slice:
- polymorphic-add-classifier-v0:
  define ClassifiedProgram nodes for traits, impls, contract shapes, generic
  contracts, and syntax-level coherence diagnostics.
```
