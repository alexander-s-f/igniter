# Extract TypeChecker Module v0

Card: S2-R7-C1-P
Role: `[Igniter-Lang Research Agent]`
Track: `extract-typechecker-module-v0`
Status: done
Date: 2026-05-07
Depends on: `S2-R6-C1-P`

## Goal

Move TypeChecker logic toward the reusable production compiler package boundary
while preserving current typechecker proof behavior, golden outputs, and Stage
1 close behavior.

This slice is behavior-preserving. It does not broaden stream, OLAP, invariant
severity, parser, classifier, SemanticIR, or runtime semantics.

## Current Horizon

Before this slice, the TypeChecker pass lived inside:

```text
igniter-lang/experiments/typechecker_proof/typechecker_proof.rb
```

That proof was self-contained, but the reusable compiler package boundary still
ended at Parser and Classifier.

After this slice, the production compiler package line has these core
front-end library boundaries:

```text
igniter-lang/lib/igniter_lang/parser.rb
igniter-lang/lib/igniter_lang/classifier.rb
igniter-lang/lib/igniter_lang/typechecker.rb
```

## Extracted Boundary

New library file:

```text
igniter-lang/lib/igniter_lang/typechecker.rb
```

Public API:

```ruby
typechecker = IgniterLang::TypeChecker.new
typed = typechecker.typecheck(classified_program_hash)
```

The library owns:

```text
IgniterLang::TypeChecker::DEFAULT_VERSION
IgniterLang::TypeChecker#typecheck
type shape extraction
contract declaration typing
field access typing
history_at / bihistory_at proof-local call typing
stdlib.integer.add / stdlib.integer.gt / stdlib.bool.and operator typing
OOF propagation from ClassifiedProgram
TypeChecker-owned OOF diagnostics already present in the proof surface
```

Output contract:

```text
ClassifiedProgram hash
  -> TypedProgram hash
       kind: typed_program
       typechecker_version
       program_id
       classified_program_id
       source_path/source_hash/grammar_version/module
       type_env
       contracts[].symbols
       contracts[].declarations
       type_errors
       semantic_ir_ref: nil
```

## Experiment Wrapper

The experiment file remains:

```text
igniter-lang/experiments/typechecker_proof/typechecker_proof.rb
```

It now owns only:

```text
fixture CASES
classified fixture input paths
golden read/write
proof checks
CLI mode switch
```

It calls the library TypeChecker:

```ruby
IgniterLang::TypeChecker.new
```

## Decisions

[D] Extracted `TypecheckerPass` into `IgniterLang::TypeChecker` without
introducing value objects. The boundary stays hash-based so it can consume the
current ClassifiedProgram JSON fixtures directly.

[D] Preserved the existing `typechecker_version` string:
`typed-pass-executable-proof-v0`. This keeps TypedProgram IDs and golden output
stable.

[D] Kept `typechecker_proof.rb` as the compatibility harness. It still proves
the standalone ClassifiedProgram JSON -> TypedProgram JSON boundary and still
owns dedicated ClassifiedProgram input fixtures.

[D] Preserved existing proof-local temporal call typing for `history_at` and
`bihistory_at`; this was already part of the active TypeChecker proof surface.
No new temporal semantics were added.

[D] Did not wire production compiler CLI through the extracted TypeChecker yet.
That belongs with the compiler orchestrator / SemanticIR emitter extraction
sequence.

## Proof Output

TypeChecker proof:

```text
typed.add: ok
typed.claim_evidence: ok
typed.evidence_linked_alert: ok
typed.bihistory_valid: ok
typed.accepted_no_unresolved_types: ok
negative.unresolved_symbol_blocked: ok
negative.evidence_less_alert_blocked: ok
negative.confidence_bool_blocked: ok
negative.bihistory_missing_vt: ok
negative.bihistory_missing_tt: ok
negative.bihistory_wrong_axis_type: ok
semanticir.not_emitted: ok
boundary.classified_inputs_present: ok
boundary.classified_program_input_only: ok
golden.typed_outputs: ok
classified.dir: igniter-lang/experiments/typechecker_proof/classified
golden.dir: igniter-lang/experiments/typechecker_proof/golden
PASS typechecker_proof
```

TypeChecker golden check:

```text
typed.add: ok
typed.claim_evidence: ok
typed.evidence_linked_alert: ok
typed.bihistory_valid: ok
typed.accepted_no_unresolved_types: ok
negative.unresolved_symbol_blocked: ok
negative.evidence_less_alert_blocked: ok
negative.confidence_bool_blocked: ok
negative.bihistory_missing_vt: ok
negative.bihistory_missing_tt: ok
negative.bihistory_wrong_axis_type: ok
semanticir.not_emitted: ok
boundary.classified_inputs_present: ok
boundary.classified_program_input_only: ok
golden.typed_outputs: ok
check.golden_typed_equal: ok
check.canonical_typed_all: ok
check.deterministic_generation: ok
classified.dir: igniter-lang/experiments/typechecker_proof/classified
golden.dir: igniter-lang/experiments/typechecker_proof/golden
PASS typechecker_golden_check
```

Source to SemanticIR:

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

## Next Extraction Unit

[Next] `extract-semanticir-emitter-module-v0` should be the next Tier 0
compiler extraction unit. Parser, Classifier, and TypeChecker now have library
boundaries; the SemanticIR emitter still lives inside proof-local
`source_to_semanticir_fixture` logic and is the next reusable pass needed before
an orchestrated production compiler path can stop depending on experiment
internals.

[Next] After SemanticIR emitter extraction, extract the assembler boundary and
then wire the production compiler CLI through the reusable modules instead of
the proof-local TinyCompiler path.

## Neighbor Notes

[Q] Compiler/Grammar Expert: Keep stream OOF-S3 and future OLAP TypeChecker
ownership changes separate from this extraction. This slice only relocates the
current TypeChecker proof behavior.

[Q] Bridge Agent: The CLI remains proof-local for TypeChecker orchestration.
The bridge-ready boundary is now available as `IgniterLang::TypeChecker`, but
CLI integration should wait for emitter/orchestrator extraction.
