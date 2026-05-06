# Classifier Pass Executable Proof v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/classifier-pass-executable-proof-v0`
Status: done
Date: 2026-05-06

## Purpose

Extract the tiny classification boundary from `source_to_semanticir_fixture`
into a standalone executable pass:

```text
ParsedProgram JSON -> ClassifiedProgram JSON
```

This slice stops before typechecking and SemanticIR emission. The proof reads
the existing parsed AST goldens from:

`igniter-lang/experiments/source_to_semanticir_fixture/golden/*.parsed_ast.json`

and writes classified goldens to:

`igniter-lang/experiments/classifier_pass_proof/golden/*.classified.json`

## ClassifiedProgram Shape

Each output has:

- `kind: "classified_program"`
- `classifier_version: "classifier-pass-executable-proof-v0"`
- source identity fields from ParsedProgram
- `contracts[]`
- per-contract `fragment_class`
- `symbols`
- classified `declarations`
- declaration dependency graph
- `oof_log`
- `semantic_ir_ref: null`

The explicit `semantic_ir_ref: null` is intentional: this pass proves the
classifier boundary and does not lower to SemanticIR.

## Preserved Cases

Positive CORE cases:

- `add.classified.json`
- `claim_evidence.classified.json`
- `evidence_linked_alert.classified.json`

Negative OOF cases:

- `negative_unresolved_symbol.classified.json` -> `OOF-P1`
- `negative_evidence_less_alert.classified.json` -> `OOF-OS2`
- `negative_confidence_bool.classified.json` -> `OOF-CE4`

## What Is Proven

[D] Inputs are classified as CORE declarations.

[D] Compute declarations are CORE only when all referenced symbols resolve to
known CORE declarations.

[D] Outputs are CORE only when their source symbol resolves to CORE.

[D] Unresolved refs become OOF-P1 and propagate the affected declaration to OOF.

[D] Evidence-linked alert admission remains visible at classifier boundary for
this proof fixture: empty synthetic signal/claim evidence emits OOF-OS2.

[D] Confidence-label-as-Bool remains rejected before SemanticIR emission with
OOF-CE4.

## Proof Output

Default mode regenerates classified goldens:

```bash
ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb
```

Output:

```text
classified.add: ok
classified.claim_evidence: ok
classified.evidence_linked_alert: ok
core.add_propagates: ok
core.claim_evidence_propagates: ok
core.evidence_linked_alert_propagates: ok
negative.unresolved_symbol: ok
negative.evidence_less_alert: ok
negative.confidence_bool: ok
semanticir.not_emitted: ok
golden.classified_outputs: ok
golden.dir: igniter-lang/experiments/classifier_pass_proof/golden
PASS classifier_pass_proof
```

Golden checker mode:

```bash
ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb --check-golden
```

Output:

```text
check.golden_classified_equal: ok
check.canonical_classified_all: ok
check.deterministic_generation: ok
PASS classifier_pass_golden_check
```

## Gap List For Real Compiler Module Extraction

[Q] Compiler/Grammar Expert: split Pass 0 symbol classification from Pass 1
type/evidence gates. This proof keeps OOF-OS2 and OOF-CE4 visible here for
continuity, but those may belong in a later typed classifier pass.

[Q] Compiler/Grammar Expert: replace fixture-specific evidence checks with a
formal evidence-gate interface. This proof uses synthetic sample input for the
alert admission case.

[Q] Compiler/Grammar Expert: decide whether output declarations should be
classifier nodes or typed/lowering nodes. The proof keeps them in the
declaration graph to show CORE propagation.

[Q] Compiler/Grammar Expert: define stable diagnostic payload shape with source
locations once ParsedProgram carries enough line/span metadata.

[Q] Bridge Agent: future bridge reports should transport ClassifiedProgram and
OOF diagnostics separately from SemanticIR so rejected contracts are not
accidentally treated as loadable.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/classifier-pass-executable-proof-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Built a standalone ParsedProgram JSON -> ClassifiedProgram JSON proof.
- Used existing source_to_semanticir_fixture parsed AST goldens as inputs.
- Kept SemanticIR emission out of scope with semantic_ir_ref: null.

[R] Recommendations:
- Extract symbol classification before SemanticIR lowering.
- Split pure symbol classification from typed/evidence gates in the next formal
  compiler module design.

[S] Signals:
- CORE propagation is executable for Add, ClaimEvidenceBundle, and
  EvidenceLinkedAlertGate.
- OOF-P1, OOF-OS2, and OOF-CE4 remain visible before SemanticIR.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb
  -> PASS classifier_pass_proof
- ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb --check-golden
  -> PASS classifier_pass_golden_check

[Files] Changed:
- igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb
- igniter-lang/experiments/classifier_pass_proof/golden/add.classified.json
- igniter-lang/experiments/classifier_pass_proof/golden/claim_evidence.classified.json
- igniter-lang/experiments/classifier_pass_proof/golden/evidence_linked_alert.classified.json
- igniter-lang/experiments/classifier_pass_proof/golden/negative_unresolved_symbol.classified.json
- igniter-lang/experiments/classifier_pass_proof/golden/negative_evidence_less_alert.classified.json
- igniter-lang/experiments/classifier_pass_proof/golden/negative_confidence_bool.classified.json
- igniter-lang/docs/tracks/classifier-pass-executable-proof-v0.md

[Q] Open Questions:
- Should OOF-OS2 and OOF-CE4 live in this classifier pass or a typed classifier
  pass?
- Should output declarations stay in ClassifiedProgram dependency graphs?

[X] Rejected:
- No SemanticIR emission in this slice.
- No new source syntax.

[Next] Proposed next slice:
- typed-pass-executable-proof-v0: consume ClassifiedProgram JSON, resolve
  declared types/field access/operator result types, and emit TypedProgram JSON.
```
