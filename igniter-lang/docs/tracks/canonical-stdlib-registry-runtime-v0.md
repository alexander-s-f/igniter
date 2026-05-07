# Canonical Stdlib Registry Runtime v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/canonical-stdlib-registry-runtime-v0`
Status: done
Date: 2026-05-07

## Goal

Replace proof-local RuntimeMachine operator compatibility with a small canonical
stdlib registry.

## Decisions

[D] Runtime execution now accepts only monomorphic canonical stdlib operators:

```text
stdlib.integer.add
stdlib.float.add
stdlib.decimal.add
stdlib.integer.gt
stdlib.bool.and
fold
map
filter
count
or_else
```

[D] `stdlib.numeric.add` remains pre-resolution only. Runtime evaluation rejects
it instead of treating it as executable.

[D] Historical `"add"` is rejected by the RuntimeMachine proof. Old
hand-authored add fixtures were migrated to monomorphic operators instead of
weakening runtime checks.

[D] Non-stdlib proof-local domain operators used by old fixtures, such as
`compute_slots` and `build_snapshot`, remain isolated outside the stdlib
registry.

## Migration Note

[S] `fixtures/add.igapp/contracts/add.json` now uses `stdlib.integer.add`.

[S] `fixtures/polymorphic_add.igapp/` now emits:

```text
Add[Integer] -> stdlib.integer.add
Add[Float]   -> stdlib.float.add
```

The generic `Add` template remains metadata-only and non-loadable.

## Proof Output

```text
PASS igapp_assembler_proof
runtime.evaluate_assembled_add: ok
runtime.evaluate_assembled_claim_evidence: ok
runtime.evaluate_assembled_evidence_linked_alert: ok
runtime.rejects_legacy_add: ok
runtime.rejects_stdlib_numeric_add: ok
runtime.rejects_unknown_stdlib_operator: ok
```

```text
kernel.integer_add: ok
kernel.float_add: ok
kernel.decimal_add_exact: ok
kernel.integer_gt: ok
kernel.bool_and: ok
kernel.fold: ok
kernel.map: ok
kernel.filter: ok
kernel.count: ok
kernel.or_else_some: ok
kernel.or_else_none: ok
kernel.numeric_add_rejected: ok
kernel.legacy_add_rejected: ok
kernel.unknown_stdlib_operator_rejected: ok
runtime.add_igapp_style_integer_add: ok
runtime.add_igapp_style_rejects_numeric_add: ok
runtime.add_igapp_style_rejects_legacy_add: ok
runtime.rejects_unknown_stdlib_operator: ok
```

```text
PASS stage1_close_candidate
classifier: PASS
typechecker: PASS
semanticir: PASS
stdlib_kernel: PASS
igapp_assembler: PASS
```

## Remaining Gaps

[Q] The registry is still proof-local. Production RuntimeMachine/package
integration remains deferred.

[Q] Decimal value representation is still not standardized across `.igapp`,
SemanticIR, and RuntimeMachine.

[Q] `map`/`filter`/`fold` use proof-local bounded function specs; production
compiler extraction needs typed closure/function refs and termination evidence.

## Rejected

[X] No `stdlib.numeric.add` runtime compatibility fallback.

[X] No generic polymorphic operator execution at runtime.

[X] No Stage 2 primitives.

[X] No package/gem integration.

## Changed Files

```text
experiments/runtime_machine_memory_proof/compiled_program.rb
experiments/stdlib_execution_kernel_stage1/stdlib_execution_kernel_stage1.rb
experiments/igapp_assembler_proof/igapp_assembler_proof.rb
experiments/igapp_assembler_proof/out/result_summary.json
experiments/stage1_close_candidate/stage1_close_candidate.json
experiments/polymorphic_add_runtime_load_boundary_proof/polymorphic_add_runtime_load_boundary_proof.rb
fixtures/add.igapp/contracts/add.json
fixtures/polymorphic_add.igapp/contracts/add_integer.json
fixtures/polymorphic_add.igapp/contracts/add_float.json
fixtures/polymorphic_add.igapp/semantic_ir.json
docs/tracks/canonical-stdlib-registry-runtime-v0.md
```

## Next

[Next] Extract the proof-local stdlib registry into the future production
RuntimeMachine boundary once package integration is approved.
