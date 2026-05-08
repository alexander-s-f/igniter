# Typed Pass Executable Proof v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/typed-pass-executable-proof-v0`
Status: done
Date: 2026-05-06

## Purpose

Add the next executable compiler proof pass after classification:

```text
ClassifiedProgram JSON -> TypedProgram JSON
```

The proof lives at:

`igniter-lang/experiments/typechecker_proof/typechecker_proof.rb`

It consumes:

`igniter-lang/experiments/classifier_pass_proof/golden/*.classified.json`

and emits:

`igniter-lang/experiments/typechecker_proof/golden/*.typed.json`

## Boundary

This slice does not emit SemanticIR. Every TypedProgram golden includes:

```json
{ "semantic_ir_ref": null }
```

Because the current ClassifiedProgram does not yet carry type declarations or
expression bodies, the proof also reads the matching ParsedProgram golden as
companion metadata. The real compiler extraction gap is to make
ClassifiedProgram self-sufficient for the typed pass.

## What Is Typed

Resolved declared primitives:

- `Integer`
- `Float`
- `String`
- `Bool`
- `ConfidenceLabel`

Resolved record-like type declarations:

- `Claim`
- `EvidenceLink`
- `EvidenceLinkedAlertInput`
- `ConfidenceAssessment`

Typed expression support:

- refs
- literals
- field access
- `stdlib.integer.add`
- `stdlib.integer.gt`
- `stdlib.bool.and`

## Preserved Cases

Accepted:

- `Add`
- `ClaimEvidenceBundle`
- `EvidenceLinkedAlertGate`

Blocked:

- `BadUnresolvedSymbol` -> `OOF-P1`
- `BadEvidenceLessAlertGate` -> `OOF-OS2`
- `BadConfidenceAsBool` -> `OOF-CE4`

## Proof Output

```text
ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb
typed.add: ok
typed.claim_evidence: ok
typed.evidence_linked_alert: ok
typed.accepted_no_unresolved_types: ok
negative.unresolved_symbol_blocked: ok
negative.evidence_less_alert_blocked: ok
negative.confidence_bool_blocked: ok
semanticir.not_emitted: ok
golden.typed_outputs: ok
golden.dir: igniter-lang/experiments/typechecker_proof/golden
PASS typechecker_proof
```

```text
ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden
typed.add: ok
typed.claim_evidence: ok
typed.evidence_linked_alert: ok
typed.accepted_no_unresolved_types: ok
negative.unresolved_symbol_blocked: ok
negative.evidence_less_alert_blocked: ok
negative.confidence_bool_blocked: ok
semanticir.not_emitted: ok
golden.typed_outputs: ok
check.golden_typed_equal: ok
check.canonical_typed_all: ok
check.deterministic_generation: ok
golden.dir: igniter-lang/experiments/typechecker_proof/golden
PASS typechecker_golden_check
```

## Gap List For Real Compiler Extraction

[Q] Compiler/Grammar Expert: make ClassifiedProgram self-sufficient for the
typed pass by carrying type declarations and expression AST references/bodies.

[Q] Compiler/Grammar Expert: decide whether evidence gates (`OOF-OS2`) remain
in classifier output, typed output, or a separate CompilationReport. This proof
preserves the classifier OOF in TypedProgram.

[Q] Compiler/Grammar Expert: define a non-fixture operator table for
`stdlib.integer.add`, `stdlib.integer.gt`, and `stdlib.bool.and`.

[Q] Compiler/Grammar Expert: decide whether a blocked contract may still carry
partially inferred expression types for diagnostics. This proof keeps them.

[Q] Bridge Agent: typed diagnostics should remain separate from SemanticIR so
blocked contracts are not presented as loadable runtime artifacts.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/typed-pass-executable-proof-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Added a standalone ClassifiedProgram JSON -> TypedProgram JSON proof.
- Used classifier goldens as primary input and parsed AST goldens as companion
  metadata until ClassifiedProgram carries enough type/expression data.
- Kept SemanticIR emission out of scope.

[R] Recommendations:
- Promote type declarations and expression references into ClassifiedProgram.
- Split typed diagnostics from loadable SemanticIR before runtime integration.

[S] Signals:
- Accepted fixtures resolve without Unknown types.
- Field access and stdlib operator typing are now executable proof cases.
- OOF-P1, OOF-OS2, and OOF-CE4 remain blocked.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb
  -> PASS typechecker_proof
- ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden
  -> PASS typechecker_golden_check

[Files] Changed:
- igniter-lang/experiments/typechecker_proof/typechecker_proof.rb
- igniter-lang/experiments/typechecker_proof/golden/add.typed.json
- igniter-lang/experiments/typechecker_proof/golden/claim_evidence.typed.json
- igniter-lang/experiments/typechecker_proof/golden/evidence_linked_alert.typed.json
- igniter-lang/experiments/typechecker_proof/golden/negative_unresolved_symbol.typed.json
- igniter-lang/experiments/typechecker_proof/golden/negative_evidence_less_alert.typed.json
- igniter-lang/experiments/typechecker_proof/golden/negative_confidence_bool.typed.json
- igniter-lang/docs/tracks/typed-pass-executable-proof-v0.md

[Q] Open Questions:
- Should TypedProgram include partial types for blocked contracts?
- Should classifier or typed pass own evidence-gate OOF rules?

[X] Rejected:
- No SemanticIR emission.
- No new source syntax.

[Next] Proposed next slice:
- compilation-report-split-proof-v0: emit accepted TypedProgram plus a sibling
  CompilationReport for OOF diagnostics before SemanticIR lowering.
```
