# PROP-019.1 Direct Runtime Loader v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/prop0191-direct-runtime-loader-v0`
Status: done
Date: 2026-05-06

## Goal

Replace the proof-local `.igapp` compatibility view with direct
RuntimeMachine proof loading of PROP-019.1 artifacts.

## What Changed

[D] `RuntimeMachineMemoryProof::CompiledProgram.load_igapp` now prefers:

```text
manifest.json
compilation_report.json
semantic_ir_program.json
contracts/*.json
```

when `semantic_ir_program.json` is present.

[D] The loader validates the PROP-019.1 link chain:

```text
manifest.semantic_ir_ref == semantic_ir_program.program_id
manifest.compilation_report_ref == semantic_ir_program.compilation_report_ref
compilation_report.pass_result == "ok"
compilation_report.semantic_ir_ref == semantic_ir_program.program_id
semantic_ir_program.compilation_report_ref == compilation_report.program_id
semantic_ir_program.contracts[*].contract_name == contracts/*.json contract_id set
```

[D] `igapp_assembler_proof` no longer writes `semantic_ir.json`. The generated
artifact now proves direct loading instead of a compatibility fallback.

[D] The loader still retains a legacy fallback for older hand-authored
fixtures, such as `fixtures/add.igapp/`, that do not yet contain
`semantic_ir_program.json`.

## Current Artifact Shape

```text
experiments/igapp_assembler_proof/out/<case>.igapp/
  manifest.json
  semantic_ir_program.json
  compilation_report.json
  compatibility_metadata.json
  classified_ast.json
  requirements.json
  diagnostics.json
  projections.json
  contracts/<contract>.json
```

There is intentionally no `semantic_ir.json` in the assembled proof output.

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

Assembled Add runtime proof:

```text
loaded_semantic_ir_program: true
legacy_semantic_ir_json_present: false
sum: 42
compatibility_report_status: trusted
```

## What Is Proven

[S] RuntimeMachine proof loading no longer depends on `semantic_ir.json` for
assembled PROP-019.1 `.igapp/` artifacts.

[S] `assembled_add.igapp` loads from `semantic_ir_program.json`, evaluates
`19 + 23 -> 42`, checkpoints, and resumes with a trusted CompatibilityReport.

[S] OOF/negative compilation reports still refuse before `.igapp/` artifact
writing.

[S] Existing RuntimeMachine memory proof still passes, so older fixture fallback
was preserved.

## Remaining Stage 1 Close Gaps

[D] Follow-up track `runtime-eval-surface-stage1-fixtures-v0` closed the
proof-local eval gap for assembled Stage 1 fixtures: `field_access`,
`stdlib.integer.gt`, and `stdlib.bool.and` now evaluate through the direct
PROP-019.1 loader path.

[Q] `CompiledProgram#apply_operator` still accepts historical `"add"` and
`"stdlib.numeric.add"` for older proof fixtures. The final stdlib registry
should reject pre-resolution overloads at runtime.

[Q] The assembler still emits proof-minimal `classified_ast.json`,
`requirements.json`, and `projections.json`; real compiler extraction should
own those artifacts.

[Q] Artifact hash validation is shallow. A later checker should hash every
trusted file listed by `manifest.json`.

## Rejected

[X] No Stage 2 primitives.

[X] No package/gem integration.

[X] No dependency on legacy `semantic_ir.json` for assembled proof load.

## Changed Files

```text
experiments/runtime_machine_memory_proof/compiled_program.rb
experiments/igapp_assembler_proof/igapp_assembler_proof.rb
experiments/igapp_assembler_proof/out/
docs/tracks/igapp-assembler-proof-stage1-v0.md
docs/tracks/prop0191-direct-runtime-loader-v0.md
```

## Next

[D] Follow-up track `canonical-stdlib-registry-runtime-v0` replaced the mixed
historical operator table with a proof-local canonical stdlib registry that
rejects `"add"`, `stdlib.numeric.add`, and unknown `stdlib.*` operators.

[Next] Extract proof-local assembler/runtime behavior into the production
compiler and package boundary once Stage 1 governance accepts the proof shape.
