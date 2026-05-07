# Extract SemanticIR Emitter Module v0

Card: S2-R8-C1-P
Role: `[Igniter-Lang Research Agent]`
Track: `extract-semanticir-emitter-module-v0`
Status: done
Date: 2026-05-07
Depends on: `S2-R7-C1-P`

## Goal

Move SemanticIR emitter logic toward the reusable production compiler package
boundary while preserving current SemanticIR and CompilationReport golden
outputs.

This slice is behavior-preserving. It does not broaden OLAP, stream, invariant,
parser, classifier, typechecker, or runtime semantics.

## Current Horizon

Before this slice, the SemanticIR emitter lived inside:

```text
igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb
```

That fixture mixed:

```text
source fixture CASES
parser invocation
SemanticIR lowering
CompilationReport emission
golden read/write
canonical checks
```

Parser, Classifier, and TypeChecker already had library boundaries. SemanticIR
emission was the next reusable compiler pass.

## Extracted Boundary

New library file:

```text
igniter-lang/lib/igniter_lang/semanticir_emitter.rb
```

Public API:

```ruby
emitter = IgniterLang::SemanticIREmitter.new
result = emitter.emit(parsed_program_hash, sample_input: sample_input)
```

The library owns:

```text
IgniterLang::SemanticIREmitter::FORMAT_VERSION
IgniterLang::SemanticIREmitter#emit
ParsedProgram hash + synthetic sample input -> SemanticIRProgram / CompilationReport
PROP-019.1 semantic_ir_program envelope shape
compilation_report companion emission
contract_ref hashing
literal/ref/field_access/binary_op lowering
stdlib.integer.add / stdlib.integer.gt / stdlib.bool.and lowering
negative report-only emission for OOF cases
```

Output contract:

```text
{
  "semantic_ir" => SemanticIRProgram | nil,
  "compilation_report" => CompilationReport
}
```

Successful outputs include:

```text
kind: semantic_ir_program
format_version: 0.1.0
compilation_report_ref
contracts[].kind: contract_ir
contracts[].nodes[].expr.resolved_type
```

OOF outputs include:

```text
semantic_ir: nil
compilation_report.pass_result: oof
compilation_report.diagnostics[]
```

## Experiment Wrapper

The source-to-SemanticIR fixture remains:

```text
igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb
```

It now owns:

```text
fixture CASES
sample inputs
parser invocation
golden read/write
canonical SemanticIR checks
determinism checks
summary output
```

It calls the library emitter:

```ruby
IgniterLang::SemanticIREmitter.new.emit(parsed, sample_input: sample_input)
```

## CLI Coupling

The production compiler CLI had a hidden dependency on
`SourceToSemanticIRFixture::TinyCompiler`. This slice replaced that with the
library boundary:

```ruby
IgniterLang::SemanticIREmitter.new.emit(parsed, sample_input: sample_input)
```

The CLI still borrows fixture sample inputs for the proof, but no longer calls
the source fixture for SemanticIR emission.

## Decisions

[D] Extracted the former proof-local emitter into
`IgniterLang::SemanticIREmitter` without introducing value objects. The boundary
stays hash-based to preserve the current ParsedProgram and golden fixture
contract.

[D] Preserved `FORMAT_VERSION = "0.1.0"` and all current SemanticIR /
CompilationReport output shapes.

[D] Preserved the `compile` alias on the emitter for compatibility, while the
fixture and production CLI call the clearer `emit` method.

[D] Kept source parsing, fixture CASES, sample inputs, and golden/canonical
checks in `source_to_semanticir_fixture`.

[D] Did not add OLAPPoint lowering, stream lowering, invariant severity
lowering, or a TypedProgram -> SemanticIRProgram production path in this slice.

## Proof Output

Source to SemanticIR golden check:

```text
parse.add: ok
semanticir.envelope.add: ok
report.add: ok
semanticir.add: ok
parse.claim_evidence: ok
semanticir.envelope.claim_evidence: ok
report.claim_evidence: ok
semanticir.claim_evidence: ok
parse.evidence_linked_alert: ok
semanticir.envelope.evidence_linked_alert: ok
report.evidence_linked_alert: ok
semanticir.evidence_linked_alert: ok
negative.unresolved_symbol: ok
negative.evidence_less_alert: ok
negative.confidence_bool: ok
stdlib.monomorphic_ops: ok
golden.ast_outputs: ok
golden.semanticir_outputs: ok
golden.compilation_report_outputs: ok
check.golden_semanticir_equal: ok
check.golden_compilation_report_equal: ok
check.golden_ast_equal: ok
check.summary_equal: ok
check.canonical_all: ok
check.compilation_reports_all: ok
check.negative_semanticir_absent: ok
check.deterministic_generation: ok
golden.dir: igniter-lang/experiments/source_to_semanticir_fixture/golden
PASS source_to_semanticir_fixture_golden_check
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

Classifier proof:

```text
PASS classifier_pass_proof
stream.oof_s2_missing_window: ok
semanticir.not_emitted: ok
```

TypeChecker proof:

```text
PASS typechecker_proof
semanticir.not_emitted: ok
boundary.classified_program_input_only: ok
```

## Next Extraction Unit

[Next] `extract-assembler-module-v0` should be the next Tier 0 compiler
extraction unit. Parser, Classifier, TypeChecker, and SemanticIR emitter now
have library boundaries; `.igapp` assembly still lives in
`experiments/igapp_assembler_proof`.

[Next] After assembler extraction, add a small compiler orchestrator that wires:

```text
Parser -> Classifier -> TypeChecker -> SemanticIREmitter -> Assembler -> RuntimeSmoke
```

without depending on experiment internals.

## Neighbor Notes

[Q] Compiler/Grammar Expert: OLAPPoint TypeChecker/SemanticIR lowering remains
open and should land as a separate semantic expansion track.

[Q] Bridge Agent: Production CLI now calls the library emitter directly, but it
still borrows source fixture sample inputs and proof-local assembler/runtime
smoke. Bridge/package integration should wait for assembler extraction.
