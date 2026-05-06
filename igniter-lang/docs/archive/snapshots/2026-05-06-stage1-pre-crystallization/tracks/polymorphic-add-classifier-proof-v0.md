# Track: Polymorphic Add Classifier Proof v0

Status: done
Slice state: done on 2026-05-06
Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/polymorphic-add-classifier-proof-v0`
Supervisor: `[Architect Supervisor / Codex]`
Neighbors: `[Igniter-Lang Compiler/Grammar Expert]`
Artifacts:
- `igniter-lang/experiments/polymorphic_add_classifier_proof/polymorphic_add_classifier_proof.rb`
- `igniter-lang/source/polymorphic_add.parsed_program.expected.json`

---

## Frame

This slice implements a tiny stdlib-only proof for the PROP-016
classifier/type boundary described in `polymorphic-add-classifier-v0`.

Input:

```text
polymorphic_add.parsed_program.expected.json
```

Proof stages:

```text
ParsedProgram
  -> TraitEnv
  -> ImplEnv
  -> ShapeEnv
  -> ClassifiedProgram
  -> TypedProgram
```

The proof stops at `TypedProgram`. It does not emit full `SemanticIR`, does not
load `RuntimeMachine`, and does not touch packages.

---

## What It Builds

Classifier:

- `TraitEnv["Additive"]`
- `ImplEnv["Additive[Integer]"]`
- `ImplEnv["Additive[Float]"]`
- `ShapeEnv["AddShape"]`
- generic classified contract `Add`

Typed accepted contracts:

- `Add[Integer]`
- `Add[Float]`

Each accepted typed contract has:

- concrete input ports from `AddShape[T]`
- concrete output port `sum`
- `compute sum` resolved to `apply("stdlib.numeric.add", ...)`
- concrete `resolved_impl`: `Additive[Integer]` or `Additive[Float]`
- passing implements check

Negative proof:

```text
Add[String]
  -> missing ImplEnv["Additive[String]"]
  -> OOF-TY1
  -> rejected before SemanticIR
```

---

## Proof Output

```text
ruby igniter-lang/experiments/polymorphic_add_classifier_proof/polymorphic_add_classifier_proof.rb
```

Output:

```text
PASS polymorphic_add_classifier_proof
classifier.envs: ok
typed.add_integer: ok
typed.add_float: ok
negative.add_string_rejected: ok
typed.contracts: Add[Integer], Add[Float]
negative.errors: OOF-TY1
```

---

## Boundaries

[D] This proof consumes the expected ParsedProgram fixture directly. It does
not invoke the parser.

[D] This proof intentionally emits no SemanticIR. It proves the classifier/type
boundary is small enough to produce concrete typed contracts and reject missing
impls before lowering.

[D] `String` rejection is a compile/type boundary result, not a runtime result.

[X] Rejected: runtime overload dispatch, RuntimeMachine load checks, package
integration, and full type inference.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/polymorphic-add-classifier-proof-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- The proof builds TraitEnv, ImplEnv, ShapeEnv, ClassifiedProgram, and
  TypedProgram from the expected ParsedProgram fixture.
- Accepted TypedContracts are Add[Integer] and Add[Float].
- Add[String] is rejected as OOF-TY1 before SemanticIR.
- The proof remains stdlib-only and has no RuntimeMachine/package dependency.

[R] Recommendations:
- Next slice can turn this proof into a SemanticIR-lowering proof, preserving
  SIR-1/SIR-2/SIR-3 from the classifier track.
- Keep specialization requests explicit for now.

[S] Signals:
- The classifier/type boundary is compact: one trait, two impls, one shape,
  one generic contract, two accepted specializations, one negative.
- Shape-authoritative ports are enough to type the Add fixture body.

[T] Tests / Proofs:
- polymorphic_add_classifier_proof.rb -> PASS.
- classifier.envs: ok.
- typed.add_integer: ok.
- typed.add_float: ok.
- negative.add_string_rejected: ok.

[Files] Changed:
- igniter-lang/experiments/polymorphic_add_classifier_proof/polymorphic_add_classifier_proof.rb
- igniter-lang/docs/tracks/polymorphic-add-classifier-proof-v0.md
- igniter-lang/docs/README.md

[Q] Open Questions:
- Should specialization requests come from a build manifest, call sites, or
  an explicit proof fixture?
- Should shape-authoritative ports become a formal TypedProgram rule before
  SemanticIR lowering proof?

[X] Rejected:
- Emitting full SemanticIR in this slice.
- Treating Add[String] as a runtime rejection.
- Adding RuntimeMachine or package dependencies.

[Next] Proposed next slice:
- polymorphic-add-semanticir-lowering-proof-v0:
  emit minimal monomorphic ContractIR for Add[Integer] and Add[Float], and
  prove no type variables or unresolved trait calls survive.
```
