# Track: Polymorphic Add Runtime Load Boundary v0

Status: blocked
Slice state: blocked on 2026-05-06
Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/polymorphic-add-runtime-load-boundary-v0`
Supervisor: `[Architect Supervisor / Codex]`
Neighbors: `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`
Artifacts:
- `igniter-lang/fixtures/polymorphic_add.igapp/`
- `igniter-lang/experiments/polymorphic_add_runtime_load_boundary_proof/polymorphic_add_runtime_load_boundary_proof.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb`

---

## Frame

This slice tests whether the current `CompiledProgram.load_igapp` and
`RuntimeMachine.load_program` boundary can ingest
`fixtures/polymorphic_add.igapp`.

The invariant remains:

```text
loadable/executable contracts:
  Add[Integer]
  Add[Float]

metadata-only:
  generic Add
```

No generic `Add` `ContractIR` is loadable.

---

## Probe Result

```text
ruby igniter-lang/experiments/polymorphic_add_runtime_load_boundary_proof/polymorphic_add_runtime_load_boundary_proof.rb
```

Output:

```text
BLOCKED polymorphic_add_runtime_load_boundary_proof
compiled_program.load_igapp: ok
compiled_program.validate: ok
fixture.loadable_contracts_monomorphic: ok
fixture.generic_add_metadata_only: ok
fixture.specialization_manifest_present: ok
runtime.load_program.current_boundary_blocked: ok
runtime.load_program.blocker_descriptor_refs_shape: ok
runtime.evaluate_program.next_blocker_stdlib_operator: ok
program.contracts: Lang.Examples.PolymorphicAdd.Add[Float], Lang.Examples.PolymorphicAdd.Add[Integer]
runtime.load_program.error: TypeError: no implicit conversion of Hash into Array
runtime.evaluate_program.error: ArgumentError: Unknown operator: stdlib.numeric.add
```

---

## What Passes

[D] `CompiledProgram.load_igapp("igniter-lang/fixtures/polymorphic_add.igapp")`
can read the fixture.

[D] `CompiledProgram#validate!` passes.

[D] Bracketed contract IDs are accepted as raw contract-map keys:

```text
Lang.Examples.PolymorphicAdd.Add[Integer]
Lang.Examples.PolymorphicAdd.Add[Float]
```

[D] `manifest.contracts`, `semantic_ir.contracts`, and contract files all list
only monomorphic contracts.

[D] Generic `Add` is present only in `classified_ast.generic_templates[]` with
`loadable: false`.

[D] `specialization_manifest.json` exists and its emitted contract IDs match
the two loadable contracts.

---

## Blockers

### B-1: Runtime load descriptor refs shape

`RuntimeMachine.load_program(program)` currently blocks before load receipt:

```text
TypeError: no implicit conversion of Hash into Array
```

Cause:

```text
compiled_program.rb load_program:
  descriptors: descriptor_refs.values + migration_descriptor_refs

runtime_machine_memory_proof.rb emit_migration_descriptors:
  now returns { migration_id => obs_id }
```

The current compiled-program loader expects `migration_descriptor_refs` to be
an array. The RuntimeMachine helper now returns a map so replacement-image
proofs can retain descriptor identity by migration id.

Required normalization:

```text
migration_descriptor_refs_by_id = emit_migration_descriptors(...)
migration_descriptor_refs = migration_descriptor_refs_by_id.values
```

`load_program` should store both:

- `migration_descriptor_refs`: array of obs ids for old consumers.
- `migration_descriptor_refs_by_id`: map for migration provenance.

### B-2: Runtime evaluator operator table

Direct `CompiledProgram#evaluate_contract` reaches the next blocker:

```text
ArgumentError: Unknown operator: stdlib.numeric.add
```

Cause:

```text
compiled_program.rb apply_operator supports:
  add, sub, mul, div, compute_slots, build_snapshot

polymorphic Add SemanticIR emits:
  stdlib.numeric.add
```

Required normalization:

- Either teach the runtime evaluator `stdlib.numeric.add`.
- Or introduce a lowering/runtime operator table that maps
  `stdlib.numeric.add` to the numeric add primitive.

Do not rewrite the fixture operator back to surface `add`; the SemanticIR
invariant requires the resolved stdlib operator.

---

## Loader Changes Needed

1. Normalize migration descriptor refs in `RuntimeMachine.load_program`.

2. Load and validate `specialization_manifest_ref`:
   - manifest reference exists.
   - specialization rows' `emitted_contract_id` values match loadable
     contract IDs.
   - no undeclared emitted specialization is loaded.

3. Treat generic metadata explicitly:
   - `classified_ast.generic_templates[*].loadable == false`.
   - `manifest.metadata_only_templates` must not appear in
     `program.contracts`.
   - generic templates may be emitted as inspection metadata, not descriptors
     for executable contracts.

4. Preserve bracketed contract IDs as valid runtime contract IDs, or introduce
   a reversible artifact-local ID mapping:

```text
runtime id:      add_integer
display/source:  Lang.Examples.PolymorphicAdd.Add[Integer]
```

Current raw string keys already load at `CompiledProgram` level, so this is
not the first blocker.

5. Add `stdlib.numeric.add` to the runtime operator table before evaluating
   these contracts.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/polymorphic-add-runtime-load-boundary-v0
Status: blocked
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- The fixture itself is loadable by CompiledProgram.load_igapp and validates.
- Only Add[Integer] and Add[Float] are present as loadable contracts.
- Generic Add remains metadata-only and non-loadable.
- specialization_manifest.json exists and matches emitted monomorphic
  contract IDs.
- RuntimeMachine.load_program is blocked by descriptor-ref shape drift before
  reaching normal load completion.
- Direct evaluation reveals the next required operator normalization:
  stdlib.numeric.add.

[R] Recommendations:
- First loader patch: normalize migration_descriptor_refs in load_program so
  it accepts the current RuntimeMachine helper's map shape.
- Second loader patch: read/validate specialization_manifest_ref and
  metadata_only_templates.
- Third runtime patch: add stdlib.numeric.add to the operator table or route
  resolved stdlib operators through an axiom table.

[S] Signals:
- Bracketed contract IDs are not the current hard blocker; they are accepted
  as CompiledProgram contract keys.
- The fixture preserves the core invariant: no executable generic Add and no
  Add[String].

[T] Tests / Proofs:
- polymorphic_add_runtime_load_boundary_proof.rb -> BLOCKED with expected
  boundary checks all ok.

[Files] Changed:
- igniter-lang/experiments/polymorphic_add_runtime_load_boundary_proof/polymorphic_add_runtime_load_boundary_proof.rb
- igniter-lang/docs/tracks/polymorphic-add-runtime-load-boundary-v0.md
- igniter-lang/docs/README.md

[Q] Open Questions:
- Should runtime contract IDs remain fully-qualified bracketed strings, or
  should `.igapp` introduce artifact-local IDs plus display/source names?
- Should stdlib operators be handled by `CompiledProgram#apply_operator` or
  by a separate axiom/runtime operator registry?

[X] Rejected:
- Loading generic Add as a ContractIR.
- Rewriting the SemanticIR operator to surface "add".
- Adding Add[String].

[Next] Proposed next slice:
- polymorphic-add-runtime-loader-normalization-v0:
  patch load_program descriptor-ref normalization, validate specialization
  manifest/generic metadata, and add stdlib.numeric.add operator support.
```
