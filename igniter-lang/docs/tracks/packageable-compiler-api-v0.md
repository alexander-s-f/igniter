# Packageable Compiler API v0

Card: S2-R11-C1-P
Role: `[Igniter-Lang Research Agent]`
Track: `packageable-compiler-api-v0`
Status: done
Date: 2026-05-07
Depends on: `S2-R10-C1-P`

## Goal

Put a stable Ruby-facing API over `CompilerOrchestrator` without promoting
Igniter-Lang to a packaged gem yet.

This slice is behavior-preserving. It adds no new language semantics.

## Current Horizon

`compiler-orchestrator-v0` created:

```text
IgniterLang::CompilerOrchestrator
```

That boundary is production-oriented, but consumers still had to instantiate the
orchestrator class directly. This card adds the smaller facade expected from a
packageable Ruby API.

## API Facade

New file:

```text
igniter-lang/lib/igniter_lang.rb
```

Public API:

```ruby
require "igniter_lang"

orchestration = IgniterLang.compile(
  source_path: "path/to/source.ig",
  out_path: "path/to/app.igapp",
  sample_input: { "a" => 2, "b" => 3 },
  runtime_smoke: nil
)

result = orchestration.fetch("result")
```

The facade delegates to:

```text
IgniterLang::CompilerOrchestrator#compile
```

and preserves the same orchestration hash:

```text
status
result                      # CompilerResult hash
parsed_program
classified_program
typed_program
semantic_ir
compilation_report
assembled
sample_input
```

## CLI Update

The production compiler CLI now calls:

```ruby
IgniterLang.compile(...)
```

instead of instantiating `CompilerOrchestrator` directly. The CLI still owns:

```text
argv parsing
fixture sample_input_resolver
proof-local runtime_smoke callback
public JSON printing
```

This keeps CLI stdout, `CompilerResult`, and `CompilationReport` shapes stable.

## Decisions

[D] Added `IgniterLang.compile(...)` as the stable Ruby-facing facade.

[D] Kept `CompilerOrchestrator` as the injectable implementation boundary
behind the facade. The facade accepts an optional `orchestrator:` keyword for
tests/future package wiring.

[D] Kept runtime smoke injectable. The API does not import proof-local
RuntimeMachine code.

[D] Did not create gemspec/package wiring, install hooks, or production runtime
adapter selection in this slice.

## Proof Output

Direct API smoke:

```text
api.status=ok
api.result_status=ok
api.igapp_exists=true
```

Production compiler CLI:

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
positive.sum: 42
negative.category: classifier_oof
```

Source to SemanticIR fixture:

```text
PASS source_to_semanticir_fixture_golden_check
check.golden_semanticir_equal: ok
check.golden_compilation_report_equal: ok
check.golden_ast_equal: ok
check.summary_equal: ok
check.canonical_all: ok
check.compilation_reports_all: ok
check.negative_semanticir_absent: ok
check.deterministic_generation: ok
```

Assembler proof:

```text
PASS igapp_assembler_proof
assembler.positive.add: ok
assembler.positive.claim_evidence: ok
assembler.positive.evidence_linked_alert: ok
runtime.evaluate_assembled_add: ok
runtime.evaluate_assembled_claim_evidence: ok
runtime.evaluate_assembled_evidence_linked_alert: ok
runtime.compatibility_report_trusted: ok
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

## Remaining Gaps

[R] Runtime smoke is still proof-local and callback-injected by the CLI.

[R] `IgniterLang.compile` still requires caller-provided sample input or a
resolver for meaningful runtime smoke. Generic compile without smoke is usable
for artifact emission.

[R] The package boundary still needs load-path/gemspec/bin integration before it
is a distributable package surface.

## Next Delta

[Next] `runtime-smoke-extraction-v0`:

```text
ProductionCompilerCLI::RuntimeSmoke
  -> IgniterLang::RuntimeSmoke
```

Keep smoke optional from `IgniterLang.compile`.

[Next] `compiler-package-boundary-v0`:

```text
require "igniter_lang"
IgniterLang.compile(...)
igniter-lang compile SOURCE --out OUT.igapp
```

with a package-level load path and a minimal test proving both Ruby API and CLI
entrypoint use the same facade.

## Neighbor Notes

[Q] Compiler/Grammar Expert: No pass behavior changed. Stage 2 lowering remains
separate.

[Q] Bridge Agent: The facade is package-shaped, but runtime smoke and TBackend
selection are still explicit/injected rather than production-integrated.
