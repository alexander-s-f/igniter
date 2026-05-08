# Extract Classifier Module v0

Card: S2-R6-C1-P
Role: `[Igniter-Lang Research Agent]`
Track: `extract-classifier-module-v0`
Status: done
Date: 2026-05-07
Depends on: `S2-R5-C1-P`

## Goal

Move classifier logic toward the reusable production compiler package boundary
while preserving current classifier proof behavior and downstream Stage 1
pipeline behavior.

This slice is behavior-preserving. It does not add new stream or OLAP language
semantics beyond the stream cases already present in the classifier proof
surface.

## Current Horizon

The production compiler package line already has these library boundaries:

```text
igniter-lang/lib/igniter_lang/diagnostics.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
igniter-lang/lib/igniter_lang/parser.rb
```

Before this slice, classifier logic lived inside:

```text
igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb
```

That made the proof pass green only as an experiment, not as a reusable
compiler boundary.

## Extracted Boundary

New library file:

```text
igniter-lang/lib/igniter_lang/classifier.rb
```

Public API:

```ruby
classifier = IgniterLang::Classifier.new
classified = classifier.classify(parsed_program_hash, sample_input: sample_input)
```

The library owns:

```text
IgniterLang::Classifier::DEFAULT_VERSION
IgniterLang::Classifier#classify
IgniterLang::Classifier#type_declarations
```

Output contract:

```text
ParsedProgram hash
  -> ClassifiedProgram hash
       kind: classified_program
       classifier_version
       program_id
       source_path/source_hash/grammar_version/module
       type_declarations
       contracts[].symbols
       contracts[].declarations
       contracts[].dependency_graph
       oof_log
       semantic_ir_ref: nil
```

## Experiment Wrapper

The experiment file remains:

```text
igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb
```

It now owns only:

```text
fixture CASES
golden read/write
proof checks
CLI mode switch
```

It calls the library classifier:

```ruby
IgniterLang::Classifier.new(classifier_version: CLASSIFIER_VERSION)
```

## Decisions

[D] Extracted classifier logic to `lib/igniter_lang/classifier.rb` without
introducing value objects. The boundary stays hash-based to match the parser
and existing proof goldens.

[D] Kept classifier proof as compatibility harness instead of deleting it. The
proof still owns fixtures and golden determinism checks.

[D] Preserved stream classifier cases already present in the working proof
surface:

```text
stream.sc1_ingress_escape
stream.sc2_direct_use_oof_s4
stream.sc3_fold_result_core
```

[D] Did not broaden OLAP semantics or add any new classifier rules for OLAP.

[D] Did not wire production compiler CLI through the extracted classifier yet.
The current CLI still uses the proof-local TinyCompiler path; wiring classifier
into CLI orchestration belongs with the compiler orchestrator extraction.

## Proof Output

Classifier proof:

```text
classified.add: ok
classified.claim_evidence: ok
classified.evidence_linked_alert: ok
classified.stream_ingress_escape: ok
classified.stream_fold_core: ok
core.add_propagates: ok
core.claim_evidence_propagates: ok
core.evidence_linked_alert_propagates: ok
stream.sc1_ingress_escape: ok
stream.sc2_direct_use_oof_s4: ok
stream.sc3_fold_result_core: ok
negative.unresolved_symbol: ok
negative.evidence_less_alert: ok
negative.confidence_bool: ok
semanticir.not_emitted: ok
golden.classified_outputs: ok
golden.dir: igniter-lang/experiments/classifier_pass_proof/golden
PASS classifier_pass_proof
```

Classifier golden check:

```text
PASS classifier_pass_golden_check
check.golden_classified_equal: ok
check.canonical_classified_all: ok
check.deterministic_generation: ok
```

Source to SemanticIR:

```text
PASS source_to_semanticir_fixture_golden_check
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
check.golden_semanticir_equal: ok
check.golden_compilation_report_equal: ok
check.golden_ast_equal: ok
check.summary_equal: ok
check.canonical_all: ok
check.compilation_reports_all: ok
check.negative_semanticir_absent: ok
check.deterministic_generation: ok
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

Direct syntax/library checks:

```text
ruby -c igniter-lang/lib/igniter_lang/classifier.rb -> Syntax OK
ruby -c igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb -> Syntax OK
ruby -I igniter-lang/lib -e 'require "igniter_lang/classifier"; ...' -> classifier-pass-executable-proof-v0
```

## Next Compiler Extraction Unit

Recommended next package unit:

```text
extract-typechecker-module-v0
```

Reason:

```text
Parser and classifier now have lib boundaries.
TypeChecker is the next compiler stage with a standalone proof and owned
ClassifiedProgram input fixtures.
```

Keep separate:

```text
stream classifier expansion beyond current SC checks
OLAPPoint parser/typechecker boundary
SemanticIR emitter extraction
production compiler orchestrator wiring
```

## Changed Files

```text
docs/tracks/extract-classifier-module-v0.md
lib/igniter_lang/classifier.rb
experiments/classifier_pass_proof/classifier_pass_proof.rb
experiments/classifier_pass_proof/golden/stream_ingress_escape.classified.json
experiments/classifier_pass_proof/golden/stream_fold_core.classified.json
experiments/classifier_pass_proof/golden/negative_stream_direct_use.classified.json
experiments/stage1_close_candidate/stage1_close_candidate.json
```

## Handoff

```text
Card: S2-R6-C1-P
[Igniter-Lang Research Agent]
Track: extract-classifier-module-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Extracted classifier logic to igniter-lang/lib/igniter_lang/classifier.rb.
- Kept classifier proof as fixture/golden compatibility harness.
- Preserved existing stream SC checks already present in the classifier proof surface.
- Did not add OLAP semantics or wire production CLI through classifier yet.

[S] Signals:
- ParsedProgram hash -> ClassifiedProgram hash is now a reusable library boundary.
- Existing classifier goldens remain deterministic.
- Stream classified goldens are now emitted by the classifier harness.
- Stage 1 close candidate remains PASS.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb -> PASS
- ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb --check-golden -> PASS
- ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden -> PASS
- ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb -> PASS
- ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb -> PASS

[R] Risks / Recommendations:
- The classifier remains hash-based by design; keep this until TypeChecker extraction lands.
- Production CLI should use parser -> classifier -> typechecker only after compiler orchestration is extracted.
- Stream classifier expansion and OLAP parser/TC work should remain separate neighbor slices.

[Next] Suggested next slice:
- extract-typechecker-module-v0
```
