# Extract Assembler Module v0

Card: S2-R9-C1-P
Role: `[Igniter-Lang Research Agent]`
Track: `extract-assembler-module-v0`
Status: done
Date: 2026-05-07
Depends on: `S2-R8-C1-P`

## Goal

Extract `.igapp` assembler logic into a reusable library boundary while
preserving Stage 1 / Stage 2 proof behavior, `.igapp` artifact shape, and
runtime smoke behavior.

This slice is behavior-preserving. It adds no new language semantics.

## Current Horizon

Before this slice, assembler behavior lived inside:

```text
igniter-lang/experiments/igapp_assembler_proof/igapp_assembler_proof.rb
```

That proof mixed:

```text
assembler validation
.igapp directory writing
canonical artifact hashing
positive / negative proof cases
runtime load/evaluate/checkpoint/resume smoke
operator rejection checks
```

Parser, Classifier, TypeChecker, and SemanticIR emitter already had library
boundaries. Assembler was the final Tier 0 compiler package boundary still
hidden in an experiment namespace.

## Extracted Boundary

New library file:

```text
igniter-lang/lib/igniter_lang/assembler.rb
```

Public API:

```ruby
assembler = IgniterLang::Assembler.new
summary = assembler.assemble_artifacts(
  case_name: "add",
  report: compilation_report_hash,
  semantic_ir: semantic_ir_program_hash,
  target_dir: "path/to/app.igapp"
)
```

The library owns:

```text
IgniterLang::AssemblyRefused
IgniterLang::Assembler
IgniterLang::Assembler::Canonical
assemble_case(case_name)
assemble_artifacts(case_name:, report:, semantic_ir:, target_dir:)
refuse_case(case_name)
SemanticIR / CompilationReport reference validation
OOF contract rejection
stdlib.numeric.* rejection before runtime
manifest.json / semantic_ir_program.json / compilation_report.json writing
contracts/*.json compatibility files
requirements / diagnostics / classified_ast / projections / compatibility metadata
deterministic canonical JSON hashing
```

Output contract:

```text
.igapp/
  manifest.json
  semantic_ir_program.json
  compilation_report.json
  requirements.json
  diagnostics.json
  classified_ast.json
  projections.json
  compatibility_metadata.json
  contracts/*.json
```

## Experiment Wrapper

The assembler proof remains:

```text
igniter-lang/experiments/igapp_assembler_proof/igapp_assembler_proof.rb
```

It now owns:

```text
positive / negative CASES
runtime load/evaluate/checkpoint/resume checks
runtime operator rejection checks
deterministic output check
proof summary printing
```

It calls the library assembler:

```ruby
IgappAssemblerProof::Assembler = IgniterLang::Assembler
```

The aliases preserve the proof surface for any nearby experiment code that
still references the old namespace.

## CLI Coupling

The production compiler CLI no longer calls the proof-local assembler:

```ruby
IgniterLang::Assembler.new.assemble_artifacts(...)
```

It still uses proof-local RuntimeMachine smoke via `compiled_program.rb`. That
is intentionally left for `compiler-orchestrator-v0` / runtime smoke extraction.

## Decisions

[D] Extracted assembler validation and artifact writing into
`IgniterLang::Assembler` without changing artifact shape.

[D] Preserved `IgniterLang::Assembler::Canonical` as the canonical JSON/hash
helper for assembler artifacts.

[D] Preserved `.igapp` proof output paths and summary shape in
`igapp_assembler_proof`.

[D] Updated production compiler CLI to use the library assembler and rescue
`IgniterLang::AssemblyRefused`.

[D] Did not extract RuntimeSmoke, CompiledProgram loading, or RuntimeMachine
integration in this slice.

## Proof Output

Assembler proof:

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
runtime.evaluate_assembled_claim_evidence: ok
runtime.evaluate_assembled_evidence_linked_alert: ok
runtime.compatibility_report_trusted: ok
runtime.rejects_legacy_add: ok
runtime.rejects_stdlib_numeric_add: ok
runtime.rejects_unknown_stdlib_operator: ok
runtime.add.load_status: loaded
runtime.add.output_value: 42
runtime.add.compatibility_report_status: trusted
runtime.claim_evidence.load_status: loaded
runtime.claim_evidence.output_value: claim/synthetic/vendor-status
runtime.claim_evidence.compatibility_report_status: trusted
runtime.evidence_linked_alert.load_status: loaded
runtime.evidence_linked_alert.output_value: true
runtime.evidence_linked_alert.compatibility_report_status: trusted
out: experiments/igapp_assembler_proof/out
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

## Next Delta

[Next] `compiler-orchestrator-v0` should wire the extracted compiler modules:

```text
Parser
  -> Classifier
  -> TypeChecker
  -> SemanticIREmitter
  -> Assembler
  -> RuntimeSmoke
```

The immediate goal should be a small library orchestrator that preserves the
current CLI behavior while reducing direct experiment dependencies.

[Next] Runtime smoke extraction can follow as a separate boundary:

```text
IgniterLang::RuntimeSmoke
```

It should replace the remaining CLI dependency on proof-local
`RuntimeMachineMemoryProof::CompiledProgram` / `RuntimeMachine`.

## Neighbor Notes

[Q] Compiler/Grammar Expert: This card does not alter artifact semantics or add
new lowering behavior. OLAP/stream/invariant production assembly should remain
separate.

[Q] Bridge Agent: The reusable assembler boundary is now available, but runtime
smoke and production TBackend selection remain proof-local.
