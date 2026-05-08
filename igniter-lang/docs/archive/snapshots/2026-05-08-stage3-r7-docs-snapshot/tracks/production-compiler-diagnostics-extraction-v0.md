# Production Compiler Diagnostics Extraction v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/production-compiler-diagnostics-extraction-v0`
Card: `S2-R2-C3-P`
Status: done
Date: 2026-05-07

## Goal

Extract `ProductionCompilerCLI::Diagnostics` from the proof-local production
compiler CLI orchestration file without changing public compiler_result JSON
behavior.

## Decision

[D] `ProductionCompilerCLI::Diagnostics` now lives in:

```text
igniter-lang/experiments/production_compiler_cli/diagnostics.rb
```

[D] `production_compiler_cli.rb` now loads it with:

```ruby
require_relative "diagnostics"
```

[D] No gem/package structure was created. This remains an experiment-local
extraction, as requested by the card.

[D] Public JSON shape was preserved. The CLI proof still validates:

```text
kind: compiler_result
format_version: 0.1.0
stages
igapp_path
diagnostics
warnings
```

## Extraction Signal

[S] The CLI orchestration file no longer owns diagnostic enrichment internals.
Its diff is now limited to loading `diagnostics.rb` and deleting the inline
helper module.

[S] The extracted helper keeps the same namespace:

```text
ProductionCompilerCLI::Diagnostics
```

Existing call sites such as `Diagnostics.from_parse_errors`,
`Diagnostics.enrich`, `Diagnostics.errors`, and `Diagnostics.warnings` remain
unchanged.

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

Syntax checks:

```text
ruby -c igniter-lang/experiments/production_compiler_cli/diagnostics.rb -> Syntax OK
ruby -c igniter-lang/experiments/production_compiler_cli/production_compiler_cli.rb -> Syntax OK
```

## Changed Files

```text
igniter-lang/docs/tracks/production-compiler-diagnostics-extraction-v0.md
igniter-lang/experiments/production_compiler_cli/diagnostics.rb
igniter-lang/experiments/production_compiler_cli/production_compiler_cli.rb
```

## Handoff

```text
Card: S2-R2-C3-P
[Igniter-Lang Research Agent]
Track: production-compiler-diagnostics-extraction-v0
Status: done

[D] Decisions
- Extracted ProductionCompilerCLI::Diagnostics to diagnostics.rb.
- Kept the same module namespace and call surface.
- Kept extraction experiment-local; no gem/package structure introduced.
- Preserved public compiler_result JSON behavior.

[S] Shipped / Signals
- production_compiler_cli.rb now owns orchestration only.
- diagnostics.rb owns category mapping, enrichment, warning/error partitioning,
  path derivation, and span normalization.
- Diff shows diagnostics logic isolated from CLI orchestration.

[T] Tests / Proofs
- ruby -c igniter-lang/experiments/production_compiler_cli/diagnostics.rb -> Syntax OK
- ruby -c igniter-lang/experiments/production_compiler_cli/production_compiler_cli.rb -> Syntax OK
- ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb -> PASS
- ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb -> PASS

[R] Risks / Recommendations
- Next extraction should keep ProductionCompilerCLI namespace until the
  production compiler package boundary is explicitly approved.
- Usage-error/internal-error exit-code polish remains a separate hardening slice.

[Next] Suggested next slice
- Extract the next proof-local production compiler boundary, likely RuntimeSmoke
  or Compiler orchestration, using production_compiler_cli_proof as the guard.
```
