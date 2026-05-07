# Compiler Diagnostics Library Boundary v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/compiler-diagnostics-library-boundary-v0`
Card: `S2-R3-C3-P`
Status: done
Date: 2026-05-07

## Goal

Prepare production compiler diagnostics for the first reusable
`igniter-lang/lib` boundary while preserving the current proof-local CLI output
contract.

This slice depends on `S2-R2-C3-P`, where `ProductionCompilerCLI::Diagnostics`
was first isolated from CLI orchestration.

## Library Boundary

[D] The reusable diagnostics implementation now lives at:

```text
igniter-lang/lib/igniter_lang/diagnostics.rb
```

[D] The library API is:

```text
IgniterLang::Diagnostics
```

[D] The experiment-local file remains as a compatibility shim:

```text
igniter-lang/experiments/production_compiler_cli/diagnostics.rb
```

It loads the library and preserves the old constant:

```ruby
require_relative "../../lib/igniter_lang/diagnostics"

module ProductionCompilerCLI
  Diagnostics = IgniterLang::Diagnostics unless const_defined?(:Diagnostics, false)
end
```

[D] `production_compiler_cli.rb` still requires the experiment-local
`diagnostics.rb`. Current load path:

```text
production_compiler_cli.rb
  -> experiments/production_compiler_cli/diagnostics.rb
    -> lib/igniter_lang/diagnostics.rb
```

This keeps the CLI proof stable while making `IgniterLang::Diagnostics`
directly reusable with:

```bash
ruby -I igniter-lang/lib -e 'require "igniter_lang/diagnostics"'
```

## API Map

| Experiment-local API | Library API | Status |
|---|---|---|
| `ProductionCompilerCLI::Diagnostics::CATEGORIES` | `IgniterLang::Diagnostics::CATEGORIES` | shimmed |
| `Diagnostics.enrich(entries, category:, contract:)` | `IgniterLang::Diagnostics.enrich(...)` | moved |
| `Diagnostics.from_parse_errors(errors)` | `IgniterLang::Diagnostics.from_parse_errors(errors)` | moved |
| `Diagnostics.from_classified(diagnostics, contract:)` | `IgniterLang::Diagnostics.from_classified(...)` | moved |
| `Diagnostics.from_typechecked(diagnostics, contract:)` | `IgniterLang::Diagnostics.from_typechecked(...)` | moved |
| `Diagnostics.from_assembler_refusal(refusal)` | `IgniterLang::Diagnostics.from_assembler_refusal(refusal)` | moved |
| `Diagnostics.from_runtime_smoke(smoke)` | `IgniterLang::Diagnostics.from_runtime_smoke(smoke)` | moved |
| `Diagnostics.errors(entries)` | `IgniterLang::Diagnostics.errors(entries)` | moved |
| `Diagnostics.warnings(entries)` | `IgniterLang::Diagnostics.warnings(entries)` | moved |

[S] The current boundary remains hash-based. It does not yet introduce
`DiagnosticEntry`, `CompilerResult`, or `CompilationReport` value objects.

## Output Behavior

[D] Public CLI output behavior is unchanged.

The proof confirms canonical diagnostics fields remain present on OOF output:

```text
negative.status=oof
negative.category=classifier_oof
negative.location_keys=true
negative.stages={"parse"=>"ok", "classify"=>"oof", "typecheck"=>"skipped", "emit"=>"skipped", "assemble"=>"skipped"}
negative.warnings=[]
positive.stages={"parse"=>"ok", "classify"=>"ok", "typecheck"=>"ok", "emit"=>"ok", "assemble"=>"ok"}
positive.warnings=[]
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
ruby -c igniter-lang/lib/igniter_lang/diagnostics.rb -> Syntax OK
ruby -c igniter-lang/experiments/production_compiler_cli/diagnostics.rb -> Syntax OK
ruby -c igniter-lang/experiments/production_compiler_cli/production_compiler_cli.rb -> Syntax OK
ruby -I igniter-lang/lib -e 'require "igniter_lang/diagnostics"; ...' -> library_require: ok
```

## Remaining Migration Steps

[R] Keep the shim until `IgniterLang::Compiler` and `IgniterLang::CLI` exist.
At that point, production code can require `igniter_lang/diagnostics` directly
and drop the `ProductionCompilerCLI::Diagnostics` compatibility constant.

[R] The next package extraction unit should be:

```text
compiler-result-report-boundary-v0
```

Target files:

```text
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
```

Reason: `IgniterLang::Diagnostics` now owns entry enrichment and category
mapping, but `production_compiler_cli.rb` still owns status selection, `stages`,
`warnings`, `diagnostics`, `igapp_path`, and the stdout/report split. Those
fields are part of PROP-027's reusable diagnostics/result contract and should
be extracted before freezing the CLI package surface.

[R] After result/report extraction, resume the module extraction map with
`extract-parser-module-v0` or `extract-assembler-module-v0`.

## Changed Files

```text
igniter-lang/docs/tracks/compiler-diagnostics-library-boundary-v0.md
igniter-lang/experiments/production_compiler_cli/diagnostics.rb
igniter-lang/lib/igniter_lang/diagnostics.rb
```

## Handoff

```text
Card: S2-R3-C3-P
[Igniter-Lang Research Agent]
Track: compiler-diagnostics-library-boundary-v0
Status: done

[D] Decisions
- Moved diagnostics implementation to IgniterLang::Diagnostics under
  igniter-lang/lib.
- Kept experiments/production_compiler_cli/diagnostics.rb as a compatibility
  shim for ProductionCompilerCLI::Diagnostics.
- Kept CLI output behavior unchanged.
- Avoided full compiler package/gem work.

[S] Shipped / Signals
- First reusable igniter-lang/lib diagnostics boundary exists.
- Existing production compiler CLI still passes through the old require path:
  CLI -> experiment shim -> library diagnostics.
- Diagnostics still include category and location fields; compiler_result still
  includes stages and warnings.

[T] Tests / Proofs
- ruby -c igniter-lang/lib/igniter_lang/diagnostics.rb -> Syntax OK
- ruby -c igniter-lang/experiments/production_compiler_cli/diagnostics.rb -> Syntax OK
- ruby -c igniter-lang/experiments/production_compiler_cli/production_compiler_cli.rb -> Syntax OK
- ruby -I igniter-lang/lib -e 'require "igniter_lang/diagnostics"; ...' -> library_require: ok
- ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb -> PASS
- ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb -> PASS

[R] Risks / Recommendations
- The boundary is still hash-based; no value objects yet.
- Keep the compatibility shim until IgniterLang::Compiler/IgniterLang::CLI exist.
- Next package extraction unit should be compiler-result-report-boundary-v0,
  because result/report shape fields still live in production_compiler_cli.rb.

[Next] Suggested next slice
- Implement compiler-result-report-boundary-v0:
  IgniterLang::CompilerResult + IgniterLang::CompilationReport helpers that own
  status, stages, diagnostics/warnings partitioning, igapp_path, and report refs.
```
