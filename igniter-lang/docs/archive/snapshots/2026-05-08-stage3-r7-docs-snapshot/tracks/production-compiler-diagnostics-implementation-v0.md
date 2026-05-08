# Production Compiler Diagnostics Implementation v0

Role: `[Igniter-Lang Research Agent]`
Track: `production-compiler-diagnostics-implementation-v0`
Status: done
Date: 2026-05-07

## Goal

Implement DX-1..DX-11 from
`extract-canonical-json-diagnostics-v0` inside the proof-local production
compiler CLI experiment.

No gem/package extraction was done.

## Decision

[D] Implemented a `ProductionCompilerCLI::Diagnostics` helper module inside
`experiments/production_compiler_cli/production_compiler_cli.rb`.

[D] The canonical stdout object is now `compiler_result`.

[D] Renamed CLI stdout key:

```text
out -> igapp_path
```

[D] OOF/failure diagnostics now carry canonical fields:

```text
category
rule
severity
message
contract
node
path
span
```

[D] `span` is present and may be `null` when the current parser/compiler proof
does not provide source coordinates.

[D] Warnings are represented by a top-level `warnings` array. Current fixtures
emit none.

## Implemented DX Checklist

```text
DX-1  Diagnostics.enrich(...)                      done
DX-2  Diagnostics.from_parse_errors(...)           done
DX-3  Diagnostics.from_classified(...)             done
DX-4  Diagnostics.from_typechecked(...)            done
DX-5  Diagnostics.from_assembler_refusal(...)      done
DX-6  Diagnostics.from_runtime_smoke(...)          done
DX-7  stdout uses igapp_path, not out              done
DX-8  stdout includes stages                       done
DX-9  stdout includes format_version               done
DX-10 stdout includes warnings                     done
DX-11 production_compiler_cli_proof PASS           done
```

## Success Output Shape

The Add fixture now emits:

```json
{
  "kind": "compiler_result",
  "format_version": "0.1.0",
  "status": "ok",
  "program_id": "semanticir/e9664d5446df4e46",
  "stages": {
    "parse": "ok",
    "classify": "ok",
    "typecheck": "ok",
    "emit": "ok",
    "assemble": "ok"
  },
  "igapp_path": ".../out/add.igapp",
  "diagnostics": [],
  "warnings": []
}
```

The proof still includes runtime smoke output for the experiment:

```text
runtime_smoke.outputs.sum -> 42
runtime_smoke.compatibility_report_status -> trusted
```

## OOF Output Shape

The unresolved-symbol fixture now emits:

```json
{
  "kind": "compiler_result",
  "format_version": "0.1.0",
  "status": "oof",
  "stages": {
    "parse": "ok",
    "classify": "oof",
    "typecheck": "skipped",
    "emit": "skipped",
    "assemble": "skipped"
  },
  "igapp_path": null,
  "diagnostics": [
    {
      "category": "classifier_oof",
      "rule": "OOF-P1",
      "severity": "error",
      "message": "Unresolved symbol: missing_b",
      "contract": "BadUnresolvedSymbol",
      "node": "sum",
      "path": "contract:BadUnresolvedSymbol/node:sum",
      "span": null
    }
  ],
  "warnings": []
}
```

The companion refusal `CompilationReport` carries the same enriched diagnostic
entry.

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

## Changed Files

```text
docs/tracks/production-compiler-diagnostics-implementation-v0.md
experiments/production_compiler_cli/production_compiler_cli.rb
experiments/production_compiler_cli/production_compiler_cli_proof.rb
experiments/production_compiler_cli/production_compiler_cli_summary.json
experiments/production_compiler_cli/out/negative_unresolved_symbol.compilation_report.json
```

## Handoff

```text
[Igniter-Lang Research Agent]
Track: production-compiler-diagnostics-implementation-v0
Status: done

[D] Decisions
- Keep diagnostics implementation inside production_compiler_cli.rb for v0.
- Canonical stdout key is igapp_path; old out key removed.
- OOF diagnostics include category plus location fields.
- warnings is always present; empty for current fixtures.

[S] Shipped / Signals
- Added ProductionCompilerCLI::Diagnostics module.
- Updated compiler_result stdout shape.
- Updated refusal CompilationReport diagnostics.
- Updated proof checks for canonical shape.

[T] Tests / Proofs
- ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb -> PASS
- ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb -> PASS

[R] Risks / Recommendations
- Usage-error/internal-error exit-code polish remains a future CLI hardening slice.
- Next extraction can move Diagnostics into a separate diagnostics.rb file.

[Next] Suggested next slice
- production-compiler-diagnostics-extraction-v0 or production-compiler-usage-error-contract-v0.
```
