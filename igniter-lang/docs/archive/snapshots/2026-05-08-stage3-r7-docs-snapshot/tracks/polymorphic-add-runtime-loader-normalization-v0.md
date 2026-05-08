# Track: Polymorphic Add Runtime Loader Normalization v0

Role: `[Igniter-Lang Research Agent]`
Track: igniter-lang/polymorphic-add-runtime-loader-normalization-v0
Status: done
Date: 2026-05-06
Depends on:
- polymorphic-add-runtime-load-boundary-v0
- polymorphic-add-igapp-fixture-v0
- specialization-request-source-v0

---

## Neighbors Affected

- `[Igniter-Lang Compiler/Grammar Expert]` — the proof confirms the loader
  boundary expected from future compiler output: a specialization manifest,
  monomorphic ContractIRs, and metadata-only generic templates.
- `[Igniter-Lang Bridge Agent]` — runtime evidence now treats
  `polymorphic_add.igapp` as loadable without making generic `Add` a runtime
  contract.

---

## Result

The previous boundary probe is no longer blocked.

```text
ruby igniter-lang/experiments/polymorphic_add_runtime_load_boundary_proof/polymorphic_add_runtime_load_boundary_proof.rb
```

```text
PASS polymorphic_add_runtime_loader_normalization_proof
compiled_program.load_igapp: ok
compiled_program.validate: ok
fixture.loadable_contracts_monomorphic: ok
fixture.generic_add_metadata_only: ok
fixture.specialization_manifest_present: ok
runtime.load_program: ok
runtime.load_program.contracts_loaded: ok
runtime.evaluate_add_integer: ok
runtime.evaluate_add_float: ok
runtime.reject_generic_add: ok
runtime.reject_add_string: ok
runtime.operator_stdlib_numeric_add: ok
program.contracts: Lang.Examples.PolymorphicAdd.Add[Float], Lang.Examples.PolymorphicAdd.Add[Integer]
runtime.load_program.status: loaded
runtime.evaluate_add_integer.sum: 3
runtime.evaluate_add_float.sum: 3.75
runtime.reject_generic_add.error: ArgumentError: Unknown contract: Lang.Examples.PolymorphicAdd.Add
runtime.reject_add_string.error: ArgumentError: Unknown contract: Lang.Examples.PolymorphicAdd.Add[String]
```

---

## Changes Proven

[D] `RuntimeMachine.load_program` now normalizes migration descriptor refs:

- `migration_descriptor_refs`: array of observation ids for load-receipt
  compatibility.
- `migration_descriptor_refs_by_id`: map retained for migration provenance.

[D] `CompiledProgram.load_igapp` reads `specialization_manifest_ref` when it is
present.

[D] `CompiledProgram#validate!` checks:

- `manifest.contracts` matches contract files.
- `semantic_ir.contracts` matches contract files.
- specialization manifest `emitted_contract_id` set matches loadable
  contracts.
- `metadata_only_templates` are not loadable contracts.
- `classified_ast.generic_templates[*].loadable == false`.
- `classified_ast.loadable_contracts` matches contract files when present.

[D] `stdlib.numeric.add` is routed through the toy runtime operator table as
the resolved numeric add axiom for this proof.

---

## Boundary Invariants

[D] Executable contracts:

```text
Lang.Examples.PolymorphicAdd.Add[Integer]
Lang.Examples.PolymorphicAdd.Add[Float]
```

[D] Non-loadable metadata:

```text
Lang.Examples.PolymorphicAdd.Add
```

[D] Rejected:

```text
Lang.Examples.PolymorphicAdd.Add
Lang.Examples.PolymorphicAdd.Add[String]
```

The second rejection is not a weakened type check at runtime. `Add[String]`
is absent because the classifier/type proof rejected it before SemanticIR and
the `.igapp` fixture contains no loadable ContractIR for it.

---

## Remaining Gaps

[G] Compiler artifact generation is still not end-to-end. The `.igapp` remains
hand-authored from proof fixtures.

[G] The runtime axiom/operator table is still local to the toy
`CompiledProgram` evaluator. A real runtime needs a first-class
`AxiomDescriptor`/operator registry for stdlib operators.

[G] Bracketed contract ids are accepted as raw keys. A future loader may want
a reversible artifact-local id map, but this proof does not require one.

[G] Loader validation checks manifest/set consistency, not deep semantic graph
equivalence between `semantic_ir.json` and each contract file.

[G] Manifest `artifact_hash` is fixture-owned here; this proof does not
recompute the package hash from loaded files.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/polymorphic-add-runtime-loader-normalization-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Keep generic Add metadata-only and non-loadable.
- Preserve Add[Integer] and Add[Float] as raw executable contract ids.
- Normalize migration descriptor refs at RuntimeMachine.load_program without
  weakening replacement-image provenance.
- Treat stdlib.numeric.add as the resolved operator accepted by the toy
  runtime evaluator.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/polymorphic_add_runtime_load_boundary_proof/polymorphic_add_runtime_load_boundary_proof.rb -> PASS

[Next]:
- Compiler/Grammar Expert: emit this `.igapp` shape from compiler artifacts,
  including specialization_manifest_ref and metadata-only generic templates.
- Research Agent: package a dedicated `.igapp` hash/manifest validation proof.
- Bridge Agent: decide how stdlib axiom descriptors should appear in bridge
  packet metadata.
```
