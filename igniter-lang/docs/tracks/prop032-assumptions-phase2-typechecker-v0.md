# Track: PROP-032 Assumptions Phase 2 TypeChecker v0

Card: S3-R33-C2-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `prop032-assumptions-phase2-typechecker-v0`
Status: done
Date: 2026-05-11

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Bridge Agent]`

---

## Goal

Implement PROP-032 Phase 2 TypeChecker support without parser grammar or
SemanticIR implementation:

- propagate OOF-A1 from classified `oof_log` to typed `type_errors`;
- block contracts that use undeclared assumptions;
- pass through `assumption_registry` and contract-level `assumption_refs`;
- type `uses_assumptions` declarations as `Assumption`;
- validate assumption `strength` range as a TypeChecker error.

---

## Inputs Read

- `handoff/onboarding-compiler-grammar-expert-v0.md`
- `roles/compiler-grammar-expert.md`
- `docs/tracks/prop032-assumptions-phase1-classifier-implementation-v0.md`
- `docs/tracks/prop032-assumptions-implementation-gate-review-v0.md`
- `docs/proposals/PROP-032-assumptions-block-v0.md`
- `lib/igniter_lang/typechecker.rb`
- `experiments/assumptions_proof/assumptions_proof.rb`

---

## Decisions

[D] Keep Phase 2 entirely inside the TypeChecker boundary.

No parser grammar, SemanticIR, runtime, constraints/form/ESM, or evidence-list
validation changes were made. PROP-033 still owns output evidence-list
validation.

[D] Reuse existing OOF propagation for OOF-A1.

The TypeChecker already seeds contract `type_errors` from classified `oof_log`.
Phase 2 preserves that path and adds assumptions passthrough/typing around it.

[D] Model `uses_assumptions NAME` as a typed declaration with type `Assumption`.

The built-in `Assumption` shape exposes `kind`, `statement`, `strength`, and
`source` fields for TypeChecker proof use. This keeps `assumption.strength`
typeable as `Decimal` without adding parser syntax.

[D] Use `TASSUMP-1` for invalid assumption strength.

PROP-032 specifies strength range validation as a TypeChecker error, not an OOF.
`TASSUMP-1` is therefore recorded in `type_errors` and blocks contracts using the
invalid assumption, while OOF-A1 remains the only PROP-032 OOF implemented here.

---

## Shipped

[S] Updated `lib/igniter_lang/typechecker.rb`:

- top-level typed programs pass through `assumption_registry` when present;
- contracts pass through non-empty `assumption_refs`;
- `uses_assumptions` declarations become typed declarations;
- `Assumption.strength` resolves as `Decimal`;
- OOF-A1 classified diagnostics block typed contracts through existing
  `oof_log` propagation;
- invalid assumption strengths outside `0.0..1.0` emit `TASSUMP-1`.

[S] Updated `experiments/assumptions_proof/`:

- added TypeChecker execution to the proof harness;
- added typed goldens for:
  - `assumption_basic`;
  - `epistemic_only_pure`;
  - `oof_a1_undeclared_assumption`;
- added proof checks for registry passthrough, refs passthrough, typed
  `uses_assumptions`, OOF-A1 in `type_errors`, and invalid-strength rejection.

[S] Adjusted hand-authored Phase 1 fixtures only where needed for TypeChecker
proofability:

- `assumption_basic` now uses the supported `homophily.strength` expression
  instead of an unsupported future `similarity(...) * ...` expression;
- `oof_a1_undeclared_assumption` literal now carries `type_tag: "Integer"`.

---

## Proof Coverage

| Fixture | TypeChecker expectation | Result |
| --- | --- | --- |
| `assumption_basic` | typed `accepted`, registry/refs pass through, `homophily.strength: Decimal` | PASS |
| `epistemic_only_pure` | typed `accepted`, epistemic contract remains typed without evidence-list validation | PASS |
| `oof_a1_undeclared_assumption` | typed `blocked`, OOF-A1 appears in contract and program `type_errors` | PASS |
| proof-local invalid strength mutation | typed `blocked`, emits `TASSUMP-1`, no SemanticIR emission | PASS |

---

## Command Matrix

| Command | Result |
| --- | --- |
| `ruby igniter-lang/experiments/assumptions_proof/assumptions_proof.rb` | PASS |
| `ruby igniter-lang/experiments/assumptions_proof/assumptions_proof.rb --check-golden` | PASS |
| `ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden` | PASS |
| `ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden` | PASS |
| `ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb --check-golden` | PASS |
| `ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb` | PASS |

---

## Phase 3 Gate Statement

[D] Phase 3 SemanticIR is now unblocked for a bounded implementation card.

Reason: the Phase 2 typed goldens now exist for the three required fixtures, and
the negative OOF-A1 case is blocked at the typed boundary.

[R] Phase 3 should lower only the typed assumptions surface:

- top-level `assumption_registry`;
- contract-level `assumption_refs`;
- typed `uses_assumptions` declarations;
- no output evidence-list validation;
- no constraints/form/ESM/runtime behavior.

[R] PROP-032 still must not be promoted to `experiment-pass`.

The pipeline has Classifier and TypeChecker coverage, but SemanticIR, governance
index updates, CSM/heat-map closure, and experiment-pass status remain future
work.

---

## Non-Authorization

[X] No parser grammar implementation.

[X] No SemanticIR implementation.

[X] No output evidence-list validation.

[X] No constraints/form/ESM/runtime behavior.

---

## Handoff

```text
Card: S3-R33-C2-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: prop032-assumptions-phase2-typechecker-v0
Status: done

[D] Decisions
- Kept the slice strictly TypeChecker-owned.
- Reused classified oof_log -> typed type_errors for OOF-A1 propagation.
- Typed uses_assumptions as Assumption and exposed strength as Decimal.
- Used TASSUMP-1 for invalid strength range as a TypeChecker error, not OOF.

[S] Shipped / Signals
- TypeChecker passes through assumption_registry and assumption_refs.
- OOF-A1 blocks undeclared assumption contracts at typed boundary.
- Added typed goldens for assumption_basic, epistemic_only_pure, and
  oof_a1_undeclared_assumption.
- Proof-local invalid strength mutation blocks with TASSUMP-1.

[T] Tests / Proofs
- assumptions_proof -> PASS
- assumptions_proof --check-golden -> PASS
- typechecker_proof --check-golden -> PASS
- source_to_semanticir_fixture --check-golden -> PASS
- classifier_pass_proof --check-golden -> PASS
- stage1_close_candidate -> PASS

[R] Risks / Recommendations
- Phase 3 SemanticIR is now unblocked as the next bounded card.
- PROP-032 is still not experiment-pass.
- PROP-033 remains the owner of output evidence-list validation.

[Next]
- Implement PROP-032 Phase 3 SemanticIR lowering for typed assumptions surface
  only.
```
