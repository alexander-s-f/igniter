# Production Compiler Module Extraction Map v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/production-compiler-module-extraction-map-v0`
Status: done
Date: 2026-05-07

## Goal

Turn `production-compiler-package-plan-v0` into a concrete extraction map from
proof files to first package modules.

This is a bridge from proofs to package. It does not implement the extraction.

## Neighbor Awareness

- `[Igniter-Lang Compiler/Grammar Expert]`: owns final pass boundaries,
  diagnostic categories, and whether proof-local checks live in classifier,
  typechecker, or runtime smoke.
- `[Igniter-Lang Bridge Agent]`: should use this map only after Architect
  approval for package integration.

## Target Module Tree

```text
igniter-lang/lib/
  igniter_lang.rb
  igniter_lang/canonical_json.rb
  igniter_lang/diagnostics.rb
  igniter_lang/parser.rb
  igniter_lang/classifier.rb
  igniter_lang/typechecker.rb
  igniter_lang/semantic_ir_emitter.rb
  igniter_lang/assembler.rb
  igniter_lang/runtime_smoke.rb
  igniter_lang/stdlib_registry.rb
  igniter_lang/compiler.rb
  igniter_lang/cli.rb
```

`compiler.rb` should orchestrate modules. It should not own pass internals.

## Module Boundary Table

| Target module | Current source | Extract these classes/functions | Public input -> output | Hidden dependency to remove | First extraction slice | Preserve tests/proofs |
|---|---|---|---|---|---|---|
| `IgniterLang::Parser` | `experiments/parser/igniter_lang_parser.rb` | `Token`, `Lexer`, `ParseError`, `Parser`, `ParsedProgram.parse`, `ParsedProgram#to_h`, parser OOF helpers | `source String, source_path:` -> `ParsedProgram` object/hash with `parse_errors[]` | script-mode stdout/exit; experiment path assumptions | `extract-parser-module-v0` | parser commands for `add.ig`, `availability_projection.ig`, `polymorphic_add.ig`; `parser_oof_hardening_stage2_proof` |
| `IgniterLang::Classifier` | `experiments/classifier_pass_proof/classifier_pass_proof.rb` | `ClassifierPass#classify`, `type_declarations`, `classify_contract`, `symbol_table`, `dependency_graph`, `expr_refs`, `oof` | `ParsedProgram` -> `ClassifiedProgram` | `CASES`, `PARSED_DIR`, `GOLDEN_DIR`, sample-input gates, golden writer/checker | `extract-classifier-module-v0` | `classifier_pass_proof.rb --check-golden`; semantic OOF remains blocked later |
| `IgniterLang::TypeChecker` | `experiments/typechecker_proof/typechecker_proof.rb` | `TypecheckerPass#typecheck`, `type_shapes`, `typecheck_contract`, `infer_expr`, `infer_binary`, `operator_type`, `type_ir`, `dedupe_errors` | `ClassifiedProgram` -> `TypedProgram` | `DEFAULT_CLASSIFIED_DIR`, `GOLDEN_DIR`, `CASES`, file iteration, proof output writer | `extract-typechecker-module-v0` | `typechecker_proof.rb --check-golden`; explicit `--classified-dir` boundary mode |
| `IgniterLang::SemanticIREmitter` | `experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb` | split from `TinyCompiler`: `semantic_ir_program`, `compilation_report`, `contract_ref`, `lower_expr`, `lower_binary`, `type_ir`, `diagnostic` | `TypedProgram` + diagnostics -> `SemanticIRProgram? + CompilationReport` | `CASES`, `sample_input`, `eval_expr`, evidence gate sample checks, direct ParsedProgram reads | `extract-semanticir-emitter-module-v0` | `source_to_semanticir_fixture.rb --check-golden`; PROP-019.1 negative SemanticIR absence |
| `IgniterLang::Assembler` | `experiments/igapp_assembler_proof/igapp_assembler_proof.rb` | `Assembler#assemble_artifacts`, `validate_refs!`, `validate_semantic_ir!`, `build_artifact`, `contract_file`, `compat_expr`, `write_artifact_to` | `CompilationReport + SemanticIRProgram + out_path` -> `.igapp/` summary or refusal | `GOLDEN_DIR`, `OUT_DIR`, proof `assemble_case/refuse_case`, runtime checks, CLI proof runner | `extract-assembler-module-v0` | `igapp_assembler_proof.rb`; `production_compiler_cli_proof` |
| `IgniterLang::RuntimeSmoke` | `experiments/production_compiler_cli/production_compiler_cli.rb`; `experiments/runtime_machine_memory_proof/compiled_program.rb`; `experiments/igapp_assembler_proof/RuntimeProof` | `RuntimeSmoke.run`, `CompiledProgram.load_igapp`, `RuntimeMachine#load_program`, optional `evaluate_program` smoke | `.igapp/ path, optional sample inputs` -> smoke report with trusted/load/evaluate status | checkpoint/resume always-on behavior, fixture sample input inference, proof machine ids | `extract-runtime-smoke-module-v0` | `production_compiler_cli_proof`; `runtime_machine_memory_proof.rb`; `igapp_assembler_proof.rb` |
| `IgniterLang::StdlibRegistry` | `experiments/runtime_machine_memory_proof/compiled_program.rb`; `experiments/stdlib_execution_kernel_stage1/stdlib_execution_kernel_stage1.rb` | `CanonicalStdlibRegistry.call`, `registry_operator?`, `reject_pre_resolution_operator!`, `StdlibKernel#call`, `DecimalValue` decision | `operator String, operands Array` -> value or diagnostic/error | duplicate registries; proof-local Decimal wrapper; runtime-only error types | `extract-stdlib-registry-module-v0` | `stdlib_execution_kernel_stage1.rb`; runtime rejects legacy/pre-resolution/unknown stdlib operators |
| `IgniterLang::Diagnostics` | `source_to_semanticir_fixture`, `classifier_pass_proof`, `typechecker_proof`, `production_compiler_cli`; neighbor `PROP-025` | `DiagnosticEntry`, `CompilationReport`, `CompilerResult`, category mapping, exit/status mapping | pass diagnostics -> canonical report/result JSON | ad hoc hashes, missing categories, source spans mostly nil | `extract-diagnostics-contract-module-v0` | CLI OOF output; parser OOF proof; future PROP-025 acceptance checklist |
| `IgniterLang::Compiler` | `experiments/production_compiler_cli/production_compiler_cli.rb` | `Compiler#compile`, stage orchestration, refusal handling, report path policy | `source_path:, out_path:, options:` -> `CompilerResult` | sample input inference, proof-local status names, direct experiment constants | `extract-compiler-orchestrator-v0` | `production_compiler_cli_proof`; `stage1_close_candidate` |
| `IgniterLang::CLI` | `bin/igniter-lang`; `ProductionCompilerCLI::CLI` | arg parsing, stdout/stderr JSON, exit code selection | `ARGV` -> process exit + JSON result | plain usage text, boolean-only exit, no `PROP-025` exit code split yet | `extract-cli-module-v0` | direct `igniter-lang/bin/igniter-lang compile ...`; usage/error tests |

## Key Untangling Decisions

[D] Extract `Assembler` before pass modules. It already has a usable
`assemble_artifacts(...)` boundary and low semantic risk.

[D] Extract `Parser` before classifier/typechecker. It is already namespace
compatible (`IgniterLang`) and has the clearest public API.

[D] Do not extract `TinyCompiler` as-is into production. It is useful as a
bridge but currently fuses classifier, typechecker, emitter, diagnostics, and
sample-input checks.

[D] Extract diagnostics/result objects before freezing the CLI. The current CLI
works, but its JSON does not yet fully match the neighbor diagnostics contract.

[D] Keep `RuntimeSmoke` separate from `RuntimeMachine`. Smoke is a package
verification tool; it should not become the runtime implementation boundary.

## Hidden Dependencies Inventory

```text
Parser:
  - script-mode behavior mixed with reusable parser classes

Classifier:
  - reads parsed AST goldens from source_to_semanticir_fixture
  - CASES supplies sample_input
  - golden writer/checker mixed with pass logic

TypeChecker:
  - default classified fixture directory
  - golden writer/checker mixed with pass logic

SemanticIR emitter:
  - TinyCompiler consumes ParsedProgram directly instead of TypedProgram
  - sample_input drives evidence gates and eval_expr
  - fixture CASES define supported surface

Assembler:
  - proof default golden/out dirs
  - CLI proof runner lives beside reusable assembler behavior

RuntimeSmoke:
  - uses proof RuntimeMachine and MemoryTBackend
  - evaluation inputs are inferred in CLI wrapper
  - checkpoint/resume smoke is stronger than minimal load smoke

StdlibRegistry:
  - duplicated between runtime proof and stdlib kernel proof
  - Decimal representation remains proof-local

Diagnostics:
  - ad hoc diagnostic hashes across passes
  - category fields missing in older proof outputs
  - source spans mostly unavailable after parser
```

## Recommended Implementation Sequence

### Slice 1: `extract-canonical-json-diagnostics-v0`

Move shared JSON/hash/report helpers first:

```text
IgniterLang::CanonicalJSON
IgniterLang::Diagnostics
IgniterLang::CompilerResult
IgniterLang::CompilationReport
```

Preserve:

- `production_compiler_cli_proof`
- OOF report writing
- `git diff --check`

Why first:

Diagnostics are the cross-pass contract. Without them, each extraction repeats
ad hoc report shape decisions.

### Slice 2: `extract-parser-module-v0`

Move parser classes into:

```text
lib/igniter_lang/parser.rb
```

Keep `experiments/parser/igniter_lang_parser.rb` as a thin require + script
wrapper.

Preserve:

- existing parser fixture commands
- `parser_oof_hardening_stage2_proof`
- `stage1_close_candidate`

### Slice 3: `extract-assembler-module-v0`

Move assembler behavior into:

```text
lib/igniter_lang/assembler.rb
```

Keep `igapp_assembler_proof.rb` as fixture runner only.

Preserve:

- `igapp_assembler_proof`
- `production_compiler_cli_proof`
- direct PROP-019.1 loader path

### Slice 4: `extract-stdlib-registry-runtime-smoke-v0`

Create one canonical stdlib registry and a load-smoke wrapper:

```text
lib/igniter_lang/stdlib_registry.rb
lib/igniter_lang/runtime_smoke.rb
```

Preserve:

- `stdlib_execution_kernel_stage1`
- `runtime_machine_memory_proof`
- `igapp_assembler_proof` runtime checks
- `production_compiler_cli_proof`

### Slice 5: `extract-classifier-module-v0`

Move pure `ParsedProgram -> ClassifiedProgram` logic. Remove golden reads from
pass internals.

Preserve:

- `classifier_pass_proof.rb --check-golden`
- semantic OOF later-pass evidence

Open before implementation:

[Q] Should OOF-OS2 and OOF-CE4 stay in classifier proof, move to typechecker,
or become typed classifier gates?

### Slice 6: `extract-typechecker-module-v0`

Move `ClassifiedProgram -> TypedProgram` logic. Keep standalone ClassifiedProgram
input contract.

Preserve:

- `typechecker_proof.rb --check-golden`
- explicit `--classified-dir` mode
- no SemanticIR emission from typechecker

### Slice 7: `extract-semanticir-emitter-module-v0`

Move `TypedProgram -> SemanticIRProgram + CompilationReport`.

Precondition:

Classifier and TypeChecker modules must already produce the metadata the
emitter needs without sample runtime inputs.

Preserve:

- `source_to_semanticir_fixture.rb --check-golden`
- no SemanticIR for OOF cases
- monomorphic stdlib operator checks

### Slice 8: `extract-compiler-cli-v0`

Rebuild the CLI wrapper over package modules:

```text
bin/igniter-lang
lib/igniter_lang/cli.rb
lib/igniter_lang/compiler.rb
```

Preserve:

- `production_compiler_cli_proof`
- direct Add compile/evaluate smoke
- non-zero OOF refusal behavior

## First Test Matrix For Extracted Package

```text
parser.accepts_add
parser.accepts_polymorphic_add
parser.rejects_syntax_owned_oof
classifier.blocks_unresolved_symbol
typechecker.blocks_confidence_bool
semanticir.emits_add_prop0191
semanticir.omits_oof_program
assembler.writes_add_igapp
assembler.refuses_oof_report
runtime_smoke.loads_add_trusted
cli.compile_add_ok
cli.compile_negative_oof_nonzero
stdlib.rejects_numeric_add_runtime
stage1_close_candidate_pass
```

## Bridge Notes

[Next] `[Igniter-Lang Compiler/Grammar Expert]`: settle diagnostic categories
and pass ownership before extracting classifier/typechecker/emitter. The
workspace already has a diagnostics contract proposal; implementation should
converge on it rather than invent a second CLI shape.

[Next] `[Igniter-Lang Bridge Agent]`: after `extract-assembler-module-v0` and
`extract-runtime-smoke-module-v0`, prepare a package integration request only
if Architect approves crossing out of `igniter-lang/`.

## Rejected

[X] No extraction implemented in this slice.

[X] No root package or gem changes.

[X] No new language surface.

[X] No attempt to turn `TinyCompiler` directly into production compiler code.

## Changed Files

```text
docs/tracks/production-compiler-module-extraction-map-v0.md
```

## Next

[Next] `extract-canonical-json-diagnostics-v0`: create the smallest shared
`CanonicalJSON`, `DiagnosticEntry`, `CompilationReport`, and `CompilerResult`
helpers, then adapt the CLI proof without changing behavior.
