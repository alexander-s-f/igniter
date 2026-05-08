# Typechecker Standalone Classified To Typed v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/typechecker-standalone-classified-to-typed-v0`
Status: done
Date: 2026-05-06

## Purpose

Close the TypeChecker self-contained gap.

Before this slice, `typechecker_proof.rb` passed but read two inputs:

- `classifier_pass_proof/golden/*.classified.json`
- `source_to_semanticir_fixture/golden/*.parsed_ast.json`

Now the TypeChecker proof consumes only ClassifiedProgram JSON.

## Minimal ClassifiedProgram Additions

The previous ClassifiedProgram lacked the metadata needed for typechecking:

- record-like type declarations
- compute expression bodies

The classifier now emits the minimal fields:

```json
{
  "type_declarations": [
    {
      "kind": "type",
      "name": "EvidenceLink",
      "fields": [
        { "name": "target_ref", "type_annotation": "String", "optional": false }
      ]
    }
  ],
  "contracts": [
    {
      "declarations": [
        {
          "kind": "compute",
          "expr_kind": "field_access",
          "expr": { "...": "ParsedProgram expression AST" }
        }
      ]
    }
  ]
}
```

This keeps TypeChecker independent without inventing a new expression syntax.

## TypedProgram Guarantees

[D] Accepted TypedPrograms have no `Unknown` types.

[D] Record field access resolves through `type_declarations`.

[D] Stdlib operators are typed:

- `stdlib.integer.add`
- `stdlib.integer.gt`
- `stdlib.bool.and`

[D] Blocked negatives preserve their original OOF boundary:

- unresolved symbol -> `OOF-P1`
- evidence-less alert -> `OOF-OS2`
- confidence-as-Bool -> `OOF-CE4`

[D] TypedProgram still does not emit SemanticIR:

```json
{ "semantic_ir_ref": null }
```

## Verification

```text
ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb
-> PASS classifier_pass_proof

ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb --check-golden
-> PASS classifier_pass_golden_check

ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb
-> PASS typechecker_proof

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
PASS typechecker_golden_check
```

## Gap Report

[Q] Compiler/Grammar Expert: decide whether ClassifiedProgram should store raw
ParsedProgram expression ASTs long-term, or normalized ClassifiedExpr nodes.
This proof keeps raw expression ASTs as the minimal bridge.

[Q] Compiler/Grammar Expert: define whether `type_declarations` belong at
program level only or should be projected into per-module environments.

[Q] Compiler/Grammar Expert: define richer type refs once structured generics
and Decimal params become typechecker inputs.

[Q] Bridge Agent: TypedProgram diagnostics can now be transported without
access to source/ParsedProgram artifacts; bridges should preserve that boundary.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/typechecker-standalone-classified-to-typed-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- TypeChecker input is now ClassifiedProgram JSON only.
- ClassifiedProgram carries type_declarations and compute expr ASTs.
- TypedProgram goldens remain stable and SemanticIR is still not emitted.

[R] Recommendations:
- Formalize ClassifiedExpr before growing beyond this fixture set.
- Keep TypeChecker from reading ParsedProgram artifacts in future proofs.

[S] Signals:
- Current 9 TypeChecker PASS checks remain green.
- Accepted cases resolve all types; negatives remain blocked.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb
  -> PASS classifier_pass_proof
- ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb --check-golden
  -> PASS classifier_pass_golden_check
- ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb
  -> PASS typechecker_proof
- ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden
  -> PASS typechecker_golden_check

[Files] Changed:
- igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb
- igniter-lang/experiments/classifier_pass_proof/golden/*.classified.json
- igniter-lang/experiments/typechecker_proof/typechecker_proof.rb
- igniter-lang/docs/tracks/typechecker-standalone-classified-to-typed-v0.md

[Q] Open Questions:
- Raw parsed expr AST or normalized ClassifiedExpr?
- Program-level type_declarations or module/type environments?

[X] Rejected:
- No SemanticIR emission.
- No ParsedProgram reads inside TypeChecker.

[Next] Proposed next slice:
- typed-to-semanticir-prop0191-proof-v0: consume TypedProgram plus
  CompilationReport rules and emit clean PROP-019.1 SemanticIR only for
  accepted programs.
```
