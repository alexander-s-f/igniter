# Track: PROP-032 Assumptions Phase 1 Classifier Implementation v0

Card: S3-R32-C3-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `prop032-assumptions-phase1-classifier-implementation-v0`
Status: done
Date: 2026-05-10

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Bridge Agent]`

---

## Goal

Implement PROP-032 Phase 1 only: assumptions parser/classifier boundary via
hand-authored parsed AST fixtures, `assumption_registry`,
`uses_assumptions` classification, `epistemic` fragment assignment, and OOF-A1.

---

## Inputs Read

- `handoff/onboarding-compiler-grammar-expert-v0.md`
- `docs/tracks/prop032-assumptions-implementation-gate-review-v0.md`
- `docs/proposals/PROP-032-assumptions-block-v0.md`
- `docs/gates/prop-governance-authority-decision-v0.md`
- `docs/dev/canonical-semantic-model.md`
- `lib/igniter_lang/classifier.rb`

---

## Decisions

[D] Use the gate-allowed hand-authored parsed AST path for Phase 1.

No parser grammar changes were made. Therefore the P28 unnamed-assumption
parse-error fixture is not implemented in this slice; it belongs to the later
parser path.

[D] Keep Phase 1 strictly at the Classifier boundary.

No TypeChecker, SemanticIR, constraints/form/ESM/runtime, or evidence-list
validation changes were made. PROP-033 still owns output evidence-list
validation.

[D] Existing programs should not gain empty `assumption_refs` or
`assumption_registry` fields in classified output.

Reason: Phase 1 should preserve existing classifier goldens. The new fields are
emitted when the parsed program actually declares/uses assumptions.

---

## Shipped

[S] Updated `lib/igniter_lang/classifier.rb`:

- builds an assumption registry from `parsed_program.fetch("assumptions", [])`;
- emits top-level `assumption_registry` when non-empty;
- adds a `uses_assumptions` body branch;
- emits `uses_assumptions` declarations with `fragment_class: "epistemic"`;
- records `assumption_refs` on contracts that use assumptions;
- introduces contract-level `epistemic` precedence after `escape` and before the
  fallback;
- detects OOF-A1 for `uses_assumptions NAME` when NAME is absent from the module
  assumption registry.

[S] Added `experiments/assumptions_proof/`:

- `fixtures/assumption_basic.parsed_ast.json`
- `fixtures/epistemic_only_pure.parsed_ast.json`
- `fixtures/oof_a1_undeclared_assumption.parsed_ast.json`
- `golden/*.classified.json`
- `assumptions_proof.rb`

---

## Phase 1 Proof Coverage

| Fixture | Purpose | Result |
| --- | --- | --- |
| `assumption_basic` | declared assumption + observed/escape contract keeps `fragment_class: "escape"` and records `assumption_refs` | PASS |
| `epistemic_only_pure` | pure contract with only core + assumptions becomes `fragment_class: "epistemic"` | PASS |
| `oof_a1_undeclared_assumption` | missing registry entry produces OOF-A1 and contract `fragment_class: "oof"` | PASS |

The proof also checks that evidence-list names are not validated in PROP-032.
`epistemic_only_pure` includes a future PROP-033-only evidence name, and the
Classifier emits no OOF for that evidence entry.

---

## Command Matrix

| Command | Result |
| --- | --- |
| `ruby -c igniter-lang/lib/igniter_lang/classifier.rb` | PASS |
| `ruby -c igniter-lang/experiments/assumptions_proof/assumptions_proof.rb` | PASS |
| `ruby igniter-lang/experiments/assumptions_proof/assumptions_proof.rb` | PASS |
| `ruby igniter-lang/experiments/assumptions_proof/assumptions_proof.rb --check-golden` | PASS |
| `ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb --check-golden` | PASS |
| `ruby igniter-lang/experiments/contract_modifiers_proof/contract_modifiers_proof.rb --check-golden` | PASS |
| `ruby igniter-lang/experiments/temporal_semanticir_access_node/temporal_semanticir_access_node.rb --check-golden` | PASS |

---

## Phase 2 Gate Statement

[D] Phase 2 TypeChecker gate is now unblocked for a bounded TypeChecker slice.

Reason: the Phase 1 classifier goldens required by the S3-R31-C5 gate now exist:

- `assumption_basic.classified.json`;
- `epistemic_only_pure.classified.json`;
- `oof_a1_undeclared_assumption.classified.json`.

OOF-A1 appears in the negative classified golden's `oof_log`, which gives the
TypeChecker slice the required propagation input.

[R] Phase 3 SemanticIR remains blocked until Phase 2 typed goldens exist.

[R] PROP-032 should not be promoted to `experiment-pass` yet. This slice is
Phase 1 only; CSM, Heat Map, Covenant registry, proposal lifecycle, and missing
anchor promotion should wait for the full pipeline proof.

---

## Non-Authorization

[X] No parser syntax implementation.

[X] No TypeChecker/SemanticIR implementation.

[X] No output evidence-list validation.

[X] No constraints/form/ESM/runtime behavior.

---

## Handoff

```text
Card: S3-R32-C3-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: prop032-assumptions-phase1-classifier-implementation-v0
Status: done

[D] Decisions
- Used hand-authored parsed AST fixtures; no parser grammar changes.
- Implemented only Classifier Phase 1.
- OOF-A1 fires only for `uses_assumptions` names absent from the module
  assumption registry.
- Evidence-list validation remains PROP-033 scope.

[S] Shipped / Signals
- Classifier supports `assumption_registry`, `uses_assumptions`,
  `assumption_refs`, and `epistemic` fragment precedence.
- Added assumptions proof fixtures and classified goldens.

[T] Tests / Proofs
- assumptions_proof -> PASS
- assumptions_proof --check-golden -> PASS
- classifier_pass_proof --check-golden -> PASS
- contract_modifiers_proof --check-golden -> PASS
- temporal_semanticir_access_node --check-golden -> PASS

[R] Risks / Recommendations
- Phase 2 TypeChecker gate is now unblocked.
- Phase 3 SemanticIR remains blocked until Phase 2 typed goldens land.
- Do not promote PROP-032 to experiment-pass until the full pipeline proof and
  governance index updates land.

[Next]
- PROP-032 Phase 2 TypeChecker pass-through + OOF-A1 propagation proof.
```
