# Parser OOF Hardening Decision Fixture v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/parser-oof-hardening-decision-fixture-v0`
Status: done
Date: 2026-05-06

## Goal

Give governance concrete evidence for the remaining parser OOF gap.

This slice does not overbuild the parser and does not change grammar. It
classifies the gap so Meta Expert can decide whether Stage 1 close is blocked.

## Evidence Fixture

Command:

```bash
ruby igniter-lang/experiments/parser_oof_hardening_decision/parser_oof_hardening_decision.rb
```

Output:

```text
PASS parser_oof_hardening_decision
parse_accepts_but_later_oof: ok
parse_rejects_syntax_invalid: ok
classify_or_typecheck_blocks_semantic_oof: ok
negative_unresolved_symbol: parser=accepts later=oof
negative_evidence_less_alert: parser=accepts later=oof
negative_confidence_bool: parser=accepts later=oof
invalid_syntax_missing_colon: parser=rejects later=not_run
summary: igniter-lang/experiments/parser_oof_hardening_decision/parser_oof_hardening_decision.json
```

Machine-readable evidence:

```text
experiments/parser_oof_hardening_decision/parser_oof_hardening_decision.json
```

## Matrix

| construct | parser behavior | later pass behavior | Stage 1 risk |
|---|---|---|---|
| `compute sum = a + missing_b` | accepts, `parse_errors: []` | `OOF-P1`, compilation report `pass_result: "oof"`, TypedProgram blocked | low: unresolved symbol is semantic and blocked before SemanticIR |
| `EvidenceLinkedAlert` gate without admitted evidence refs | accepts, `parse_errors: []` | `OOF-OS2`, compilation report `pass_result: "oof"`, TypedProgram blocked | low: observation/evidence sufficiency is semantic and blocked before SemanticIR |
| `ConfidenceLabel` field used as `Bool` output | accepts, `parse_errors: []` | `OOF-CE4`, compilation report `pass_result: "oof"`, TypedProgram blocked | low: trust/type violation is blocked before SemanticIR |
| syntax-invalid input declaration missing `:` | rejects | later passes not run | none: parser rejects malformed syntax |

## Recommendation

[R] `must_fix_before_stage1_close`: none found in this fixture.

[R] `safe_to_defer_to_grammar_hardening`:

- `OOF-P1` unresolved symbol
- `OOF-OS2` evidence-linked alert without admitted evidence
- `OOF-CE4` ConfidenceLabel used as Bool

[R] `should_become_stage2_grammar_governance_item`:

- Decide whether parser should remain syntax-only or reject selected semantic
  OOF earlier for developer UX.

[R] Meta Expert recommendation:

```text
Do not block Stage 1 close on these semantic OOF cases. They are already
blocked before SemanticIR/.igapp/RuntimeMachine trust. Track parser OOF
hardening as grammar governance, not a close blocker.
```

## Signals

[S] The exact parser-accepted OOF constructs in the current Stage 1 fixture set
are semantic, not malformed syntax.

[S] Every parser-accepted OOF row is blocked before SemanticIR emission:
`semantic_ir_ref: null`.

[S] The syntax-invalid control fixture is rejected by the parser.

## Rejected

[X] No grammar changes in this slice.

[X] No production compiler work.

[X] No Stage 2 primitives.

## Changed Files

```text
experiments/parser_oof_hardening_decision/invalid_syntax.ig
experiments/parser_oof_hardening_decision/parser_oof_hardening_decision.rb
experiments/parser_oof_hardening_decision/parser_oof_hardening_decision.json
docs/tracks/parser-oof-hardening-decision-fixture-v0.md
```

## Next

[Next] Meta Expert should decide whether Stage 1 can close with parser OOF
hardening deferred.

[Next] Compiler/Grammar Expert can later decide if selected semantic OOF rules
should move earlier into parser-facing diagnostics for ergonomics.
