# Track: Polymorphic Add .igapp Fixture v0

Status: done
Slice state: done on 2026-05-06
Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/polymorphic-add-igapp-fixture-v0`
Supervisor: `[Architect Supervisor / Codex]`
Neighbors: `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`
Artifacts:
- `igniter-lang/fixtures/polymorphic_add.igapp/`
- `igniter-lang/docs/tracks/specialization-request-source-v0.md`
- `igniter-lang/experiments/polymorphic_add_semanticir_emission_proof/polymorphic_add.semantic_ir.expected.json`

---

## Frame

This slice packages the polymorphic Add SemanticIR emission proof into a
human-readable `.igapp` directory fixture.

Input chain:

```text
explicit specialization manifest
  -> Add[T=Integer], Add[T=Float]
  -> polymorphic_add.semantic_ir.expected.json
  -> fixtures/polymorphic_add.igapp/
```

The fixture is a packaged artifact shape, not a RuntimeMachine load proof.

---

## Fixture Layout

```text
igniter-lang/fixtures/polymorphic_add.igapp/
  manifest.json
  specialization_manifest.json
  semantic_ir.json
  classified_ast.json
  requirements.json
  diagnostics.json
  projections.json
  contracts/
    add_integer.json
    add_float.json
```

`semantic_ir.json` is copied from the emission proof fixture and contains only:

- `Add[Integer]`
- `Add[Float]`

`specialization_manifest.json` records the explicit v0 build input:

- `Add[T=Integer]`
- `Add[T=Float]`

`classified_ast.json` carries source/classified metadata for generic `Add`,
`Additive`, `AddShape`, and impl resolution. The generic template is explicitly
inspection-only:

```json
{ "contract_id": "Lang.Examples.PolymorphicAdd.Add", "loadable": false }
```

---

## Decisions

[D] The manifest references `specialization_manifest.json` and also embeds the
two specialization rows so the artifact is inspectable from the top-level file.

[D] `manifest.contracts` lists only loadable monomorphic contract IDs:

```text
Lang.Examples.PolymorphicAdd.Add[Integer]
Lang.Examples.PolymorphicAdd.Add[Float]
```

[D] Generic `Add` is not a loadable `ContractIR`. It exists only in
`classified_ast.json` as metadata for agents and compiler debugging.

[D] `Add[String]` is not present in the fixture. The absence relies on the
prior classifier proof's `OOF-TY1` negative case.

---

## Verification

```text
ruby igniter-lang/experiments/polymorphic_add_classifier_proof/polymorphic_add_classifier_proof.rb
ruby igniter-lang/experiments/polymorphic_add_semanticir_emission_proof/polymorphic_add_semanticir_emission_proof.rb
```

Fixture checks:

```text
json.ok igniter-lang/fixtures/polymorphic_add.igapp/classified_ast.json
json.ok igniter-lang/fixtures/polymorphic_add.igapp/contracts/add_float.json
json.ok igniter-lang/fixtures/polymorphic_add.igapp/contracts/add_integer.json
json.ok igniter-lang/fixtures/polymorphic_add.igapp/diagnostics.json
json.ok igniter-lang/fixtures/polymorphic_add.igapp/manifest.json
json.ok igniter-lang/fixtures/polymorphic_add.igapp/projections.json
json.ok igniter-lang/fixtures/polymorphic_add.igapp/requirements.json
json.ok igniter-lang/fixtures/polymorphic_add.igapp/semantic_ir.json
json.ok igniter-lang/fixtures/polymorphic_add.igapp/specialization_manifest.json
fixture.semantic_ir: ok
fixture.manifest: ok
```

---

## Boundaries

[X] Rejected: generic `Add` as loadable ContractIR.

[X] Rejected: implicit specialization by impl coverage.

[X] Rejected: RuntimeMachine load in this slice.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/polymorphic-add-igapp-fixture-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Created fixtures/polymorphic_add.igapp as a human-readable package.
- semantic_ir.json contains Add[Integer] and Add[Float] only.
- specialization_manifest.json records explicit v0 build requests.
- manifest.json references specialization_manifest.json.
- Generic Add is inspection-only metadata in classified_ast.json.
- Add[String] is absent from the packaged fixture.

[R] Recommendations:
- Next slice should be a RuntimeMachine.load boundary proof for this fixture,
  or a small loader-normalization slice if the current loader cannot accept
  bracketed contract IDs yet.

[S] Signals:
- The specialization manifest decision is now embodied in a concrete artifact.
- The packaged artifact preserves PROP-016's "one ContractIR per
  monomorphization" invariant.

[T] Tests / Proofs:
- polymorphic_add_classifier_proof.rb -> PASS.
- polymorphic_add_semanticir_emission_proof.rb -> PASS.
- Fixture JSON parse check -> all json.ok.
- semantic_ir monomorphic/loadable check -> fixture.semantic_ir: ok.
- manifest linkage/loadable contract check -> fixture.manifest: ok.

[Files] Changed:
- igniter-lang/fixtures/polymorphic_add.igapp/manifest.json
- igniter-lang/fixtures/polymorphic_add.igapp/specialization_manifest.json
- igniter-lang/fixtures/polymorphic_add.igapp/semantic_ir.json
- igniter-lang/fixtures/polymorphic_add.igapp/classified_ast.json
- igniter-lang/fixtures/polymorphic_add.igapp/requirements.json
- igniter-lang/fixtures/polymorphic_add.igapp/diagnostics.json
- igniter-lang/fixtures/polymorphic_add.igapp/projections.json
- igniter-lang/fixtures/polymorphic_add.igapp/contracts/add_integer.json
- igniter-lang/fixtures/polymorphic_add.igapp/contracts/add_float.json
- igniter-lang/docs/tracks/polymorphic-add-igapp-fixture-v0.md
- igniter-lang/docs/README.md

[Q] Open Questions:
- Should bracketed contract IDs be accepted directly by the current .igapp
  loader, or normalized into stable artifact-local IDs with display names?
- Should manifest artifact_hash become mechanically computed by a checker?

[X] Rejected:
- Adding Add[String] as a rejected specialization row inside the fixture.
- Loading into RuntimeMachine in this slice.

[Next] Proposed next slice:
- polymorphic-add-runtime-load-boundary-v0:
  test whether RuntimeMachine.load can ingest the packaged fixture as-is and
  document any loader-normalization requirements separately.
```
