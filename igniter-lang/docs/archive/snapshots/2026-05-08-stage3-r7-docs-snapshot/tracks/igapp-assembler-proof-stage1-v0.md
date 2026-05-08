# Stage 1 .igapp Assembler Proof v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/igapp-assembler-proof-stage1-v0`
Status: done
Date: 2026-05-06

## Goal

Implement the first Stage 1 `.igapp/` assembler proof from PROP-019.1
`CompilationReport + SemanticIRProgram` goldens.

## Neighbor Awareness

- `[Igniter-Lang Compiler/Grammar Expert]`: canonical artifact shape and
  semantic boundary checks.
- `[Igniter-Lang Bridge Agent]`: later package/runtime integration once this
  proof shape is approved.

## Inputs

Source artifacts:

```text
experiments/source_to_semanticir_fixture/golden/*.compilation_report.json
experiments/source_to_semanticir_fixture/golden/*.semantic_ir.json
```

Positive cases:

```text
add
claim_evidence
evidence_linked_alert
```

Negative cases:

```text
negative_unresolved_symbol
negative_evidence_less_alert
negative_confidence_bool
```

## Artifact Shape

The assembler writes:

```text
experiments/igapp_assembler_proof/out/<case>.igapp/
  manifest.json
  semantic_ir_program.json      -- preserved PROP-019.1 SemanticIRProgram
  compilation_report.json
  compatibility_metadata.json
  classified_ast.json
  requirements.json
  diagnostics.json
  projections.json
  contracts/<contract>.json
```

[D] `semantic_ir_program.json` is the canonical compiler artifact.

[D] As of `prop0191-direct-runtime-loader-v0`, the assembler no longer writes
`semantic_ir.json`; the proof loader consumes `semantic_ir_program.json`
directly.

[D] `manifest.semantic_ir_ref` must equal
`CompilationReport.semantic_ir_ref`, and `manifest.compilation_report_ref` must
equal `SemanticIRProgram.compilation_report_ref`.

[D] Negative/OFF cases refuse before writing a `.igapp/` directory.

## Proof Output

Command:

```bash
ruby igniter-lang/experiments/igapp_assembler_proof/igapp_assembler_proof.rb
```

Output:

```text
PASS igapp_assembler_proof
assembler.positive.add: ok
assembler.positive.claim_evidence: ok
assembler.positive.evidence_linked_alert: ok
assembler.negative.unresolved_symbol_refused: ok
assembler.negative.evidence_less_alert_refused: ok
assembler.negative.confidence_bool_refused: ok
assembler.deterministic_output: ok
assembler.no_legacy_semantic_ir_json: ok
runtime.load_direct_prop0191: ok
runtime.load_assembled_add: ok
runtime.evaluate_assembled_add: ok
runtime.compatibility_report_trusted: ok
runtime.load_status: loaded
runtime.compatibility_report_status: trusted
out: experiments/igapp_assembler_proof/out
```

## What Is Proven

[S] The assembler gates on `CompilationReport.pass_result == "ok"` before
reading or writing a loadable artifact.

[S] The assembler respects both directions of the successful artifact link:
`CompilationReport.semantic_ir_ref -> SemanticIRProgram.program_id` and
`SemanticIRProgram.compilation_report_ref -> CompilationReport.program_id`.

[S] Successful fixtures assemble deterministically into human-readable
`.igapp/` directories.

[S] OOF fixtures refuse without leaving negative `.igapp/` directories.

[S] `assembled_add.igapp` loads into the current RuntimeMachine memory proof,
evaluates `Add(19, 23) -> 42`, checkpoints, and resumes with a trusted
CompatibilityReport.

## Runtime Compatibility Note

This slice added a minimal compatibility hook to the memory proof evaluator:
`stdlib.integer.add`, `stdlib.float.add`, and `stdlib.decimal.add` route through
the same pure addition path as the old add fixture. This is enough for the
assembled Add proof, but it is not the final stdlib registry.

Follow-up `prop0191-direct-runtime-loader-v0` removed the proof-local
`semantic_ir.json` view from assembled output and taught the loader to validate
`manifest.json`, `compilation_report.json`, `semantic_ir_program.json`, and
`contracts/*.json` directly.

## Remaining Runtime-Load Gaps

[Q] `CompiledProgram#apply_operator` still accepts historical `"add"` and
`"stdlib.numeric.add"` names. A later stdlib registry slice should reject
pre-resolution overloads at runtime.

[Q] `claim_evidence` and `evidence_linked_alert` are loadable artifacts here,
but full evaluation still needs RuntimeMachine support for canonical
`field_access`, `stdlib.integer.gt`, and `stdlib.bool.and`.

[Q] The assembler currently emits proof-minimal `classified_ast.json`,
`requirements.json`, and `projections.json`. A production assembler should
derive these from real ClassifiedProgram/TypedProgram metadata.

## Rejected

[X] No Stage 2 primitives.

[X] No package/gem integration.

[X] No assembly from `pass_result: "oof"` reports.

## Changed Files

```text
experiments/igapp_assembler_proof/
experiments/runtime_machine_memory_proof/compiled_program.rb
docs/tracks/igapp-assembler-proof-stage1-v0.md
```

## Next

[Next] Add a tiny assembler contract/schema verifier that checks every emitted
file hash against `manifest.artifact_hash`.
