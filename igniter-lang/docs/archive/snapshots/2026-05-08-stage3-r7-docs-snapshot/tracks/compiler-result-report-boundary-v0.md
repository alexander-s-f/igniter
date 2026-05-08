# Compiler Result Report Boundary v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/compiler-result-report-boundary-v0`
Card: `S2-R4-C2-P`
Status: done
Date: 2026-05-07

## Goal

Extract small `CompilerResult` / `CompilationReport` helpers toward
`igniter-lang/lib` while preserving the current production compiler CLI proof
JSON shape.

This slice depends on `S2-R3-C3-P`, where diagnostics moved to
`IgniterLang::Diagnostics`.

## Current Construction Map

Before this slice, `production_compiler_cli.rb` owned these JSON construction
sites:

| Old CLI construction | New helper |
|---|---|
| success `compiler_result` hash | `IgniterLang::CompilerResult.ok(...)` |
| OOF/error `compiler_result` hash | `IgniterLang::CompilerResult.refusal(...)` |
| `result.reject { key == "report" }` public stdout filter | `IgniterLang::CompilerResult.public_result(result)` |
| `report.fetch("stages").merge("assemble" => ...)` | `IgniterLang::CompilerResult.stages(report, assemble:)` |
| parser failure report hash | `IgniterLang::CompilationReport.parse_failure(...)` |
| runtime smoke failure report merge | `IgniterLang::CompilationReport.runtime_smoke_failure(...)` |
| assembler/internal error report hash | `IgniterLang::CompilationReport.internal_error(...)` |
| pass report diagnostic enrichment | `IgniterLang::CompilationReport.enrich(...)` |
| diagnostic category selection by stage | `IgniterLang::CompilationReport.diagnostic_category_for(report)` |

## Library Boundary

[D] Added:

```text
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
```

[D] Both helpers require and reuse:

```text
igniter-lang/lib/igniter_lang/diagnostics.rb
```

[D] The boundary remains hash-based. It preserves key order and field names
from the proof-local CLI rather than introducing value objects or a gem surface.

[D] `production_compiler_cli.rb` still owns orchestration, sample input
selection, report path policy, assembler invocation, and runtime smoke
invocation.

## Preserved Output Shape

The proof summary after extraction shows the public stdout keys remain:

```text
positive.keys=kind,format_version,status,program_id,source_path,source_hash,grammar_version,stages,igapp_path,compilation_report_ref,semantic_ir_ref,contracts,diagnostics,warnings,runtime_smoke
negative.keys=kind,format_version,status,program_id,source_path,source_hash,grammar_version,stages,igapp_path,contracts,compilation_report_path,diagnostics,warnings
```

Stages and warnings remain present:

```text
positive.stages={"parse"=>"ok", "classify"=>"ok", "typecheck"=>"ok", "emit"=>"ok", "assemble"=>"ok"}
positive.warnings=[]
negative.stages={"parse"=>"ok", "classify"=>"oof", "typecheck"=>"skipped", "emit"=>"skipped", "assemble"=>"skipped"}
negative.warnings=[]
```

Diagnostics and refusal report shape remain present:

```text
negative.category=classifier_oof
negative.location_keys=true
report.keys=kind,format_version,program_id,grammar_version,source_hash,source_path,pass_result,stages,diagnostics,semantic_ir_ref
report.diagnostic_category=classifier_oof
```

## Proof Output

```text
PASS production_compiler_cli_proof
compile.add_exit_zero: ok
compile.add_writes_igapp: ok
compile.add_stdout_shape: ok
runtime.load_output_trusted: ok
runtime.evaluate_add_42: ok
compile.oof_exit_nonzero: ok
compile.oof_writes_report: ok
compile.oof_writes_no_igapp: ok
compile.oof_uses_igapp_path: ok
compile.oof_diagnostics_have_category: ok
compile.oof_stages_and_warnings: ok
positive.igapp_path: /Users/alex/dev/projects/igniter/igniter-lang/experiments/production_compiler_cli/out/add.igapp
positive.sum: 42
negative.category: classifier_oof
negative.report: /Users/alex/dev/projects/igniter/igniter-lang/experiments/production_compiler_cli/out/negative_unresolved_symbol.compilation_report.json
summary: igniter-lang/experiments/production_compiler_cli/production_compiler_cli_summary.json
```

Stage 1 regression:

```text
PASS stage1_close_candidate
classifier: PASS
typechecker: PASS
semanticir: PASS
stdlib_kernel: PASS
igapp_assembler: PASS
summary: igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.json
```

Syntax and direct library require:

```text
ruby -c igniter-lang/lib/igniter_lang/compiler_result.rb -> Syntax OK
ruby -c igniter-lang/lib/igniter_lang/compilation_report.rb -> Syntax OK
ruby -c igniter-lang/lib/igniter_lang/diagnostics.rb -> Syntax OK
ruby -c igniter-lang/experiments/production_compiler_cli/production_compiler_cli.rb -> Syntax OK
ruby -I igniter-lang/lib -e 'require "igniter_lang/diagnostics"; require "igniter_lang/compiler_result"; require "igniter_lang/compilation_report"; ...' -> library_require: ok
```

## Remaining Migration Steps

[R] Keep `CompilerResult` / `CompilationReport` hash-based until the compiler
orchestrator boundary exists. The current proof suite cares about JSON shape,
not Ruby object identity.

[R] Do not move `report_path_for` yet. It belongs with the upcoming compiler
orchestrator or CLI filesystem policy, not the pure report envelope.

[R] The next compiler package extraction unit should be:

```text
extract-parser-module-v0
```

Reason: the production compiler CLI still requires the parser experiment
directly, while the parser already has the cleanest public boundary:

```text
source String, source_path: -> ParsedProgram
```

Extracting it to `igniter-lang/lib/igniter_lang/parser.rb` removes the earliest
experiment dependency in the compiler pipeline and gives later classifier /
typechecker extraction a stable library input.

Alternative after parser: `extract-assembler-module-v0`, because assembler
artifact writing already has a practical `assemble_artifacts(...)` boundary.

## Changed Files

```text
igniter-lang/docs/tracks/compiler-result-report-boundary-v0.md
igniter-lang/experiments/production_compiler_cli/production_compiler_cli.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
```

## Handoff

```text
Card: S2-R4-C2-P
[Igniter-Lang Research Agent]
Track: compiler-result-report-boundary-v0
Status: done

[D] Decisions
- Added IgniterLang::CompilerResult for success/refusal compiler_result
  envelopes, public stdout filtering, and assemble-stage composition.
- Added IgniterLang::CompilationReport for parse failure reports, internal
  error reports, runtime smoke failure report merging, and diagnostic category
  enrichment.
- Kept helpers hash-based and stdlib-only.
- Preserved CLI stdout and refusal report JSON shape.
- Avoided full compiler package/gem work.

[S] Shipped / Signals
- production_compiler_cli.rb now delegates result/report envelope construction
  to igniter-lang/lib helpers.
- Diagnostics boundary remains reusable and is required by both new helpers.
- Summary output still shows category, location fields, stages, and warnings.

[T] Tests / Proofs
- ruby -c igniter-lang/lib/igniter_lang/compiler_result.rb -> Syntax OK
- ruby -c igniter-lang/lib/igniter_lang/compilation_report.rb -> Syntax OK
- ruby -c igniter-lang/lib/igniter_lang/diagnostics.rb -> Syntax OK
- ruby -c igniter-lang/experiments/production_compiler_cli/production_compiler_cli.rb -> Syntax OK
- ruby -I igniter-lang/lib -e 'require "igniter_lang/diagnostics"; require "igniter_lang/compiler_result"; require "igniter_lang/compilation_report"; ...' -> library_require: ok
- ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb -> PASS
- ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb -> PASS

[R] Risks / Recommendations
- Result/report helpers are not value objects yet; this is intentional for the
  first package boundary.
- report_path_for remains in the CLI compiler until filesystem policy is
  extracted with compiler orchestration.
- Next compiler package extraction unit should be extract-parser-module-v0.

[Next] Suggested next slice
- Implement extract-parser-module-v0:
  move reusable parser classes/API to igniter-lang/lib/igniter_lang/parser.rb,
  keep the experiment parser file as a thin require/script wrapper, and preserve
  parser OOF + stage1_close_candidate proofs.
```
