# TypeChecker Boundary Fixture v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/typechecker-boundary-fixture-v0`
Status: done
Date: 2026-05-06

## Goal

Close the TypeChecker self-contained boundary gap precisely:

```text
ClassifiedProgram JSON -> TypedProgram JSON
```

without requiring the TypeChecker proof to read another proof's golden
directory.

## What Changed

[D] `typechecker_proof` now owns its default ClassifiedProgram input fixtures:

```text
experiments/typechecker_proof/classified/*.classified.json
```

[D] The default `typechecker_proof.rb --check-golden` reads from that owned
fixture directory.

[D] The proof also accepts an explicit ClassifiedProgram boundary directory:

```bash
ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb \
  --classified-dir igniter-lang/experiments/typechecker_proof/classified \
  --check-golden
```

[D] TypedProgram goldens remain owned by:

```text
experiments/typechecker_proof/golden/*.typed.json
```

## Preserved Cases

Accepted:

- `add`
- `claim_evidence`
- `evidence_linked_alert`

Blocked:

- `negative_unresolved_symbol` -> `OOF-P1`
- `negative_evidence_less_alert` -> `OOF-OS2`
- `negative_confidence_bool` -> `OOF-CE4`

## Proof Output

Default check:

```text
typed.add: ok
typed.claim_evidence: ok
typed.evidence_linked_alert: ok
typed.accepted_no_unresolved_types: ok
negative.unresolved_symbol_blocked: ok
negative.evidence_less_alert_blocked: ok
negative.confidence_bool_blocked: ok
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

Explicit boundary mode emits the same PASS output with:

```bash
ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb \
  --classified-dir igniter-lang/experiments/typechecker_proof/classified \
  --check-golden
```

## Gap Status

[S] Closed: the TypeChecker proof no longer depends on
`classifier_pass_proof/golden` as its default input source.

[S] Closed: the proof has a direct runner mode for `ClassifiedProgram` fixture
directories.

[S] Still intentionally out of scope: TypeChecker does not emit SemanticIR in
this slice; every TypedProgram keeps `semantic_ir_ref: null`.

## Remaining Questions

[Q] Should owned boundary fixtures be regenerated mechanically from classifier
goldens during a future end-to-end pipeline check, or treated as stable
cross-pass contract fixtures?

[Q] Should ClassifiedProgram compute expression bodies be normalized into a
formal `ClassifiedExpr` shape before Stage 1 closes, or remain the minimal AST
surface for this proof?

## Rejected

[X] No ParsedProgram reads inside TypeChecker.

[X] No SemanticIR emission.

[X] No package/gem integration.

## Changed Files

```text
experiments/typechecker_proof/typechecker_proof.rb
experiments/typechecker_proof/classified/
docs/tracks/typechecker-boundary-fixture-v0.md
```

## Next

[Next] Use this owned boundary fixture as the input to the next typed-to-
SemanticIR proof, rather than reaching backward into classifier proof outputs.
