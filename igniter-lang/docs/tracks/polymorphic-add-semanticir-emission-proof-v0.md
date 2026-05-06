# Track: Polymorphic Add SemanticIR Emission Proof v0

Status: done
Slice state: done on 2026-05-06
Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/polymorphic-add-semanticir-emission-proof-v0`
Supervisor: `[Architect Supervisor / Codex]`
Neighbors: `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`
Artifacts:
- `igniter-lang/experiments/polymorphic_add_semanticir_emission_proof/polymorphic_add_semanticir_emission_proof.rb`
- `igniter-lang/experiments/polymorphic_add_semanticir_emission_proof/polymorphic_add.semantic_ir.expected.json`
- `igniter-lang/experiments/polymorphic_add_classifier_proof/polymorphic_add_classifier_proof.rb`
- `igniter-lang/fixtures/add.igapp/semantic_ir.json`

---

## Frame

This slice closes the proof loop from the accepted polymorphic ParsedProgram
fixture through the classifier proof's TypedProgram into monomorphic
SemanticIR-like contract shapes.

Input chain:

```text
polymorphic_add.parsed_program.expected.json
  -> polymorphic_add_classifier_proof.rb
  -> TypedProgram
  -> polymorphic_add_semanticir_emission_proof.rb
  -> polymorphic_add.semantic_ir.expected.json
```

The proof remains fixture-only. It does not build a full compiler pass, does
not emit a packaged `.igapp`, and does not call `RuntimeMachine.load`.

---

## What It Emits

SemanticIR-like program:

- `Add[Integer]`
- `Add[Float]`

Each emitted `ContractIR` has:

- concrete `contract_id` and `name`
- `specialization_of` metadata pointing back to the generic source contract
- concrete port type tags
- `compute sum` lowered to `apply("stdlib.numeric.add", ...)`
- concrete `resolved_impl`: `Additive[Integer]` or `Additive[Float]`
- shape descriptor for the matching `AddShape[...]`
- passing `implements` record
- existing Add fixture-compatible dependency graph and lifecycle requirements

`Add[String]` remains absent. The proof reuses the classifier negative result:
`Add[String] -> OOF-TY1` before SemanticIR emission.

---

## Invariants

The checker enforces:

- SIR-1: no unresolved type variable values survive into type tags or operator
  resolution fields.
- SIR-2: no unresolved trait method calls survive; there is no `call add` or
  `trait_method_call` in emitted SemanticIR.
- SIR-3: no generic `Add` `ContractIR` is emitted.
- SIR-4: the operator is the concrete stdlib axiom
  `stdlib.numeric.add`, not surface `add`.

The emitted `type_args` map keeps `{ "T": "Integer" }` /
`{ "T": "Float" }` only as provenance for the monomorphization, matching the
shape already specified in `polymorphic-add-classifier-v0`.

---

## Existing Add Fixture Comparison

The proof compares `Add[Integer]` against
`igniter-lang/fixtures/add.igapp/semantic_ir.json` where the existing fixture
has stable shape:

- `fragment_class`
- normalized input port strings
- normalized output port strings
- dependency graph
- temporal requirements
- lifecycle requirements
- capability requirements

The existing `.igapp` fixture does not yet record compute expressions, so this
proof owns the additional PROP-016 operator-resolution check.

---

## Proof Output

```text
ruby igniter-lang/experiments/polymorphic_add_semanticir_emission_proof/polymorphic_add_semanticir_emission_proof.rb
```

Output:

```text
PASS polymorphic_add_semanticir_emission_proof
prerequisite.classifier_proof: ok
semantic_ir.add_integer: ok
semantic_ir.add_float: ok
invariant.no_type_variables: ok
invariant.no_unresolved_trait_calls: ok
invariant.no_generic_contractir: ok
invariant.stdlib_operator: ok
negative.add_string_absent: ok
compare.add_integer_matches_add_igapp: ok
fixture.semantic_ir_expected: ok
semantic_ir.contracts: Add[Integer], Add[Float]
semantic_ir.fixture: /Users/alex/dev/projects/igniter/igniter-lang/experiments/polymorphic_add_semanticir_emission_proof/polymorphic_add.semantic_ir.expected.json
```

---

## Boundaries

[D] This is an emission proof over the classifier proof's expected
`TypedProgram` shape, not a general SemanticIR compiler pass.

[D] The proof emits one monomorphic `ContractIR` per accepted specialization.
The generic `Add` template remains source/classifier metadata only.

[D] `Add[String]` is absent because the type boundary already rejected it as
`OOF-TY1`.

[X] Rejected: RuntimeMachine load, `.igapp` packaging, runtime overload tables,
dynamic dispatch, and weakening operator checks.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/polymorphic-add-semanticir-emission-proof-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- The proof reuses the classifier proof output as the TypedProgram source.
- SemanticIR emission produces Add[Integer] and Add[Float] only.
- Each emitted compute node uses operator "stdlib.numeric.add".
- Add[String] remains absent because OOF-TY1 happens before SemanticIR.
- Add[Integer] is shape-compared against the existing add.igapp fixture.

[R] Recommendations:
- Next slice should decide whether the emitted fixture becomes a packaged
  polymorphic_add.igapp fixture or feeds a clearly separated RuntimeMachine
  load proof.
- Preserve "one ContractIR per monomorphization" when moving into .igapp.

[S] Signals:
- PROP-016's no-runtime-overload claim now has an executable fixture.
- The existing Add .igapp shape can be reused for Add[Integer] with only
  polymorphism metadata and expression resolution added.

[T] Tests / Proofs:
- polymorphic_add_semanticir_emission_proof.rb -> PASS.
- semantic_ir.add_integer: ok.
- semantic_ir.add_float: ok.
- invariant.no_type_variables: ok.
- invariant.no_unresolved_trait_calls: ok.
- invariant.no_generic_contractir: ok.
- invariant.stdlib_operator: ok.
- negative.add_string_absent: ok.
- compare.add_integer_matches_add_igapp: ok.
- fixture.semantic_ir_expected: ok.

[Files] Changed:
- igniter-lang/experiments/polymorphic_add_semanticir_emission_proof/polymorphic_add_semanticir_emission_proof.rb
- igniter-lang/experiments/polymorphic_add_semanticir_emission_proof/polymorphic_add.semantic_ir.expected.json
- igniter-lang/docs/tracks/polymorphic-add-semanticir-emission-proof-v0.md
- igniter-lang/docs/README.md

[Q] Open Questions:
- Should the next fixture be a full polymorphic_add.igapp directory or remain
  an experiments fixture until RuntimeMachine.load shape is fixed?
- Should SemanticIR keep type parameter names in type_args provenance, or move
  provenance to a separate monomorphization descriptor?

[X] Rejected:
- Loading the emitted fixture into RuntimeMachine in this slice.
- Emitting a generic Add ContractIR.
- Allowing surface operator "add" to survive lowering.

[Next] Proposed next slice:
- polymorphic-add-igapp-fixture-v0:
  package the two monomorphic ContractIRs into a .igapp fixture and define the
  exact RuntimeMachine.load boundary for polymorphic artifacts.
```
