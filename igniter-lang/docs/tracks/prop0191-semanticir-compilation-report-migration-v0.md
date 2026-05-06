# PROP-019.1 SemanticIR CompilationReport Migration v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/prop0191-semanticir-compilation-report-migration-v0`
Status: done
Date: 2026-05-06

## Purpose

Close the Slice 0 gate for Stage 1 by migrating
`source_to_semanticir_fixture` goldens to the PROP-019.1 diagnostic split.

## Decisions

[D] `SemanticIRProgram` no longer contains top-level `oof_log`.

[D] `ContractIR` no longer contains contract-level `oof_log`.

[D] Successful SemanticIR outputs include `compilation_report_ref`.

[D] A `*.compilation_report.json` is emitted for every fixture attempt.

[D] Negative/OFF fixtures do not emit `*.semantic_ir.json`; they only emit
`*.compilation_report.json` with `pass_result: "oof"`.

[D] Emitted SemanticIR contains only monomorphic stdlib operator names. The
fixture checks that `stdlib.numeric.*` does not appear; integer Add emits
`stdlib.integer.add`.

## Migrated Files

Successful attempts now have both files:

- `add.semantic_ir.json`
- `add.compilation_report.json`
- `claim_evidence.semantic_ir.json`
- `claim_evidence.compilation_report.json`
- `evidence_linked_alert.semantic_ir.json`
- `evidence_linked_alert.compilation_report.json`

OOF attempts now have only reports:

- `negative_unresolved_symbol.compilation_report.json`
- `negative_evidence_less_alert.compilation_report.json`
- `negative_confidence_bool.compilation_report.json`

The old negative `*.semantic_ir.json` files were removed.

## Verification

```text
ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb
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
PASS source_to_semanticir_fixture
```

```text
ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden
check.golden_semanticir_equal: ok
check.golden_compilation_report_equal: ok
check.golden_ast_equal: ok
check.summary_equal: ok
check.canonical_all: ok
check.compilation_reports_all: ok
check.negative_semanticir_absent: ok
check.deterministic_generation: ok
PASS source_to_semanticir_fixture_golden_check
```

Downstream proofs:

```text
ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb --check-golden
-> PASS classifier_pass_golden_check

ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden
-> PASS typechecker_golden_check
```

## Remaining Assembler Blockers

[Q] Assembler proof is still not implemented. It must read
`CompilationReport.pass_result` first and refuse OOF reports before writing any
`.igapp/`.

[Q] Assembler must verify `SemanticIRProgram.compilation_report_ref` points back
to the report artifact and that report `semantic_ir_ref` points to the emitted
program id.

[Q] Assembler must reject any defensive case where a SemanticIRProgram contains
`fragment_class: "oof"` or deprecated `oof_log`.

[Q] Contract file splitting and manifest shape are still pending for these
source-derived fixtures.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/prop0191-semanticir-compilation-report-migration-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Migrated source_to_semanticir_fixture goldens to PROP-019.1.
- OOF diagnostics live only in CompilationReport.
- Negative fixtures no longer emit SemanticIR.
- Monomorphic stdlib operator check is explicit.

[R] Recommendations:
- Next build the .igapp assembler proof against these migrated goldens.
- Keep CompilationReport as the assembler gate, not SemanticIRProgram itself.

[S] Signals:
- Source fixture, classifier proof, and typechecker proof all remain green.
- Slice 0 gate for Stage 1 is closed for this fixture family.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb
  -> PASS source_to_semanticir_fixture
- ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden
  -> PASS source_to_semanticir_fixture_golden_check
- ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb --check-golden
  -> PASS classifier_pass_golden_check
- ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden
  -> PASS typechecker_golden_check

[Files] Changed:
- igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb
- igniter-lang/experiments/source_to_semanticir_fixture/golden/*.semantic_ir.json
- igniter-lang/experiments/source_to_semanticir_fixture/golden/*.compilation_report.json
- igniter-lang/experiments/source_to_semanticir_fixture/golden/summary.json
- igniter-lang/docs/tracks/prop0191-semanticir-compilation-report-migration-v0.md

[Q] Open Questions:
- Should report/program ids become content-addressed artifacts rather than
  source-hash prefixes before assembler work?

[X] Rejected:
- No .igapp assembler in this slice.
- No SemanticIR for OOF fixtures.

[Next] Proposed next slice:
- prop0191-igapp-assembler-proof-v0: consume CompilationReport +
  SemanticIRProgram goldens and write/reject .igapp directories per PROP-019.1
  A1-A6.
```
