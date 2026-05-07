# Production Compiler CLI Wrapper v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/production-compiler-cli-wrapper-v0`
Status: done
Date: 2026-05-07

## Goal

Create the first callable compiler command over the existing Stage 1 proof
pipeline.

Command:

```bash
igniter-lang/bin/igniter-lang compile path/to/source.ig --out path/to/app.igapp
```

## What Changed

[D] Added a thin CLI proof wrapper:

```text
bin/igniter-lang
experiments/production_compiler_cli/production_compiler_cli.rb
```

[D] The wrapper calls the existing proof components without broad extraction:

```text
parser
  -> SourceToSemanticIRFixture::TinyCompiler
  -> IgappAssemblerProof::Assembler
  -> RuntimeMachineMemoryProof load/evaluate/checkpoint/resume smoke
```

[D] `IgappAssemblerProof::Assembler` now exposes a minimal
`assemble_artifacts(...)` method so callers can assemble in-memory
`CompilationReport + SemanticIRProgram` instead of writing temporary goldens.

[D] Success writes `.igapp/`. OOF/error writes only a
`*.compilation_report.json` refusal report and exits non-zero.

## CLI Output Contract

Success:

```json
{
  "status": "ok",
  "source_path": "path/to/source.ig",
  "out": "path/to/app.igapp",
  "compilation_report_ref": "compilation_report/...",
  "semantic_ir_ref": "semanticir/...",
  "contracts": ["Add"],
  "runtime_smoke": {
    "load_status": "loaded",
    "evaluate_status": "ok",
    "outputs": { "sum": 42 },
    "compatibility_report_status": "trusted",
    "trusted": true
  }
}
```

OOF/error:

```json
{
  "status": "oof",
  "source_path": "path/to/source.ig",
  "out": null,
  "compilation_report_path": "path/to/app.compilation_report.json",
  "diagnostics": [
    { "rule": "OOF-P1", "severity": "error", "message": "..." }
  ]
}
```

## Proof Output

Command:

```bash
ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb
```

Output:

```text
PASS production_compiler_cli_proof
compile.add_exit_zero: ok
compile.add_writes_igapp: ok
runtime.load_output_trusted: ok
runtime.evaluate_add_42: ok
compile.oof_exit_nonzero: ok
compile.oof_writes_report: ok
compile.oof_writes_no_igapp: ok
positive.out: /Users/alex/dev/projects/igniter/igniter-lang/experiments/production_compiler_cli/out/add.igapp
positive.sum: 42
negative.report: /Users/alex/dev/projects/igniter/igniter-lang/experiments/production_compiler_cli/out/negative_unresolved_symbol.compilation_report.json
summary: igniter-lang/experiments/production_compiler_cli/production_compiler_cli_summary.json
```

Direct command smoke:

```bash
igniter-lang/bin/igniter-lang compile \
  igniter-lang/experiments/source_to_semanticir_fixture/add.ig \
  --out /private/tmp/igniter_lang_cli_direct_add.igapp
```

returns `status: "ok"` with `runtime_smoke.outputs.sum == 42` and
`compatibility_report_status == "trusted"`.

## Machine Summary

```text
experiments/production_compiler_cli/production_compiler_cli_summary.json
```

## Proof-Local Code To Extract Next

[Q] `SourceToSemanticIRFixture::TinyCompiler` still compresses classifier,
typechecker, and SemanticIR emitter behavior into one fixture compiler.

[Q] The wrapper uses synthetic sample input inference for proof gates and
RuntimeMachine evaluation smoke. Production extraction needs pass-owned
diagnostics instead of fixture sample values.

[Q] `IgappAssemblerProof::Assembler` is still in an experiment namespace. It
should move to an `IgniterLang::Assembler` module after its artifact contract is
accepted.

[Q] Runtime smoke uses the memory proof RuntimeMachine and checks
load/evaluate/checkpoint/resume. Production packaging needs a load-only smoke
mode and later a separate evaluation smoke fixture surface.

[Q] CLI error taxonomy is minimal: `oof`, `error`, `assembler_refused`, and
`runtime_smoke_failed`. A production package needs stable diagnostic codes and
source spans.

## Rejected

[X] No package/gem integration.

[X] No broad library extraction in this slice.

[X] No arbitrary-language compiler claim.

[X] No `.igapp/` emitted for OOF/error attempts.

## Changed Files

```text
bin/igniter-lang
experiments/production_compiler_cli/
experiments/igapp_assembler_proof/igapp_assembler_proof.rb
docs/tracks/production-compiler-cli-wrapper-v0.md
```

## Next

[Next] `production-compiler-library-extraction-v0`: move stable pieces into
`igniter-lang/lib/igniter_lang/` in this order: canonical JSON, parser,
diagnostics/result objects, assembler, then pass modules.
