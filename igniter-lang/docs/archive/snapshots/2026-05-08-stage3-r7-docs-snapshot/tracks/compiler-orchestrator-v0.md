# Compiler Orchestrator v0

Card: S2-R10-C1-P
Role: `[Igniter-Lang Research Agent]`
Track: `compiler-orchestrator-v0`
Status: done
Date: 2026-05-07
Depends on: `S2-R9-C1-P`

## Goal

Wire the extracted compiler libraries into one production-oriented compiler
boundary while preserving production compiler CLI behavior and diagnostic/report
shape.

This slice is behavior-preserving. It adds no new language semantics.

## Current Horizon

Before this slice, `production_compiler_cli` still hand-wired the pipeline:

```text
ParsedProgram.parse
  -> SemanticIREmitter
  -> Assembler
  -> RuntimeSmoke
```

That missed the extracted Classifier and TypeChecker boundaries and kept
orchestration logic in an experiment file.

The extracted compiler library set now includes:

```text
parser.rb
classifier.rb
typechecker.rb
semanticir_emitter.rb
assembler.rb
compiler_result.rb
compilation_report.rb
diagnostics.rb
```

## New Boundary

New library file:

```text
igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
```

Public API:

```ruby
orchestration = IgniterLang::CompilerOrchestrator.new.compile(
  source_path: "path/to/source.ig",
  out_path: "path/to/app.igapp",
  sample_input_resolver: ->(parsed_program) { ... },
  runtime_smoke: ->(out_path:, sample_input:) { ... }
)

result = orchestration.fetch("result")
```

The orchestrator owns:

```text
source read
parser invocation
Classifier invocation
TypeChecker invocation
SemanticIR emitter invocation
CompilationReport enrichment
Assembler invocation
refusal report writing
CompilerResult construction
optional runtime smoke callback integration
```

Pass chain:

```text
source.ig
  -> IgniterLang::ParsedProgram.parse
  -> IgniterLang::Classifier#classify
  -> IgniterLang::TypeChecker#typecheck
  -> IgniterLang::SemanticIREmitter#emit
  -> IgniterLang::Assembler#assemble_artifacts
  -> optional runtime_smoke callback
  -> IgniterLang::CompilerResult
```

## CLI Update

The production compiler CLI now delegates its compile path to:

```ruby
IgniterLang::CompilerOrchestrator.new.compile(...)
```

The CLI still owns:

```text
argv parsing
public JSON printing
fixture-specific sample_input_for
proof-local RuntimeSmoke module
```

Runtime smoke remains outside the library orchestrator as a callback, because
production RuntimeMachine smoke extraction is the next boundary and should not
be mixed into this card.

## Decisions

[D] Added `IgniterLang::CompilerOrchestrator` as the first production-oriented
compile boundary over the extracted libraries.

[D] Kept output/report shape stable by returning the same
`IgniterLang::CompilerResult` structure used by the CLI proof.

[D] The orchestrator runs Classifier and TypeChecker for the boundary and keeps
their outputs in the internal orchestration result. The current SemanticIR
emitter still consumes ParsedProgram hash to preserve existing fixture behavior.

[D] Kept runtime smoke injectable. Production CLI passes its existing
proof-local smoke runner, preserving `runtime_smoke` output and `sum: 42`.

[D] Did not add Stage 2 lowering, TypedProgram-driven SemanticIR emission, or a
production RuntimeMachine dependency.

## Proof Output

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

[R] SemanticIR emitter still lowers from ParsedProgram. A future production
slice should move the emitter boundary toward TypedProgram input once that can
be done without changing golden behavior.

[R] Production CLI still borrows fixture sample inputs for non-Add examples.
Packageable compiler API should accept explicit sample/evaluation input or skip
runtime evaluation for generic compile.

[R] Runtime smoke remains proof-local. This should become
`IgniterLang::RuntimeSmoke` or a package-facing smoke adapter next.

## Next Delta

[Next] `runtime-smoke-extraction-v0`:

```text
RuntimeMachineMemoryProof::CompiledProgram / RuntimeMachine
  -> IgniterLang::RuntimeSmoke
```

Keep it proof-compatible first, then decide whether the packageable compiler API
should run smoke by default or expose it as an explicit `--smoke` / `--check`
step.

[Next] `packageable-compiler-api-v0`:

```text
IgniterLang.compile(source_path:, out_path:, ...)
```

as a stable Ruby API over `CompilerOrchestrator`.

## Neighbor Notes

[Q] Compiler/Grammar Expert: This card does not change pass semantics. Stage 2
stream/OLAP/invariant lowering should stay separate.

[Q] Bridge Agent: The compiler package spine is now one boundary, but production
runtime smoke and TBackend adapter selection are still not bridge-ready.
