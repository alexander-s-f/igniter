# Branch Conditional If Expr v0 Implementation Acceptance Pressure v0

Card: S3-R190-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: architect-supervisor
Track: branch-conditional-if-expr-v0-implementation-acceptance-pressure-v0

Context: internal — full read access to track docs, proof summary JSON, and live compiler source
Write access: none
Canon authority: none

---

## Question

Does the R189 `if_expr` v0 implementation evidence and the S3-R190-C1-A acceptance
decision satisfy all of: authorized write scope, TypeChecker/SemanticIR stage
separation, recursive flat SemanticIR lowering, OOF-IF1..OOF-IF4 semantic
correctness, OOF-IF5 absence, correct OOF-TY0 classification, release harness
non-mutation, and preservation of runtime/evaluator/public API/CLI/Spark/release
closed surfaces?

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-v0-implementation-acceptance-decision-v0.md` (S3-R190-C1-A)
- `igniter-lang/docs/tracks/branch-conditional-if-expr-v0-implementation-v0.md` (S3-R189-C2-I)
- `igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/out/branch_conditional_if_expr_v0_implementation_proof_summary.json`
- `igniter-lang/docs/tracks/stage3-round189-status-curation-v0.md` (S3-R189-C3-S)
- `igniter-lang/docs/tracks/branch-conditional-if-expr-implementation-authorization-review-v0.md` (S3-R189-C1-A)
- `igniter-lang/lib/igniter_lang/typechecker.rb` (live source, read-only)
- `igniter-lang/lib/igniter_lang/semanticir_emitter.rb` (live source, read-only)

---

## Scope Check Matrix

| ID | Check | Evidence | Result |
| --- | --- | --- | --- |
| SC-1 | Implementation write scope exactly matches C1-A authorized paths | `files_modified: ["typechecker.rb", "semanticir_emitter.rb"]`; proof experiment + track doc in authorized scope; `parser_not_modified`, `classifier_not_modified`, `orchestrator_not_modified`, `assembler_not_modified`, `runtime_not_modified` all `true`; `release_harness_not_in_write_scope: true` | PASS |
| SC-2 | TypeChecker and SemanticIR stage shapes are separated and not conflated | TypeChecker shape: `has_cond: true`, `then_kind: "branch"`, `else_kind: "branch"`; SemanticIR shape: `has_condition: true`, `has_then_branch: true`, `has_else_branch: true`, `has_cond: false`, `has_then: false`, `has_else: false`, `has_deps: false` — key conventions confirmed distinct by machine assertions | PASS |
| SC-3 | Nested SemanticIR lowering is recursively flat | `semanticir_outer_keys == ["kind","condition","then_branch","else_branch","resolved_type"]`; `semanticir_inner_keys == ["kind","condition","then_branch","else_branch","resolved_type"]`; `semanticir_inner_kind == "if_expr"`; closes R188 NB-1 | PASS |
| SC-4 | OOF-IF1..OOF-IF4 match accepted semantics, each fires in exactly the right case | `non_bool_condition` → `["OOF-IF1"]`; `missing_else` → `["OOF-IF2","OOF-TY0"]`; `branch_type_mismatch` → `["OOF-IF3","OOF-TY0"]`; `empty_branch` → `["OOF-IF4","OOF-TY0"]`; no diagnostic cross-contamination | PASS |
| SC-5 | OOF-IF5 is absent and unowned | OOF-IF5 absent from all rule arrays in proof summary; absent from live `typechecker.rb` and `semanticir_emitter.rb`; C1-A decision explicitly keeps OOF-IF5 unowned | PASS |
| SC-6 | OOF-TY0 classification is correct: unsupported-if_expr form closed; derivative type-mismatch form acceptable | `non_bool_condition.oof_ty0_for_if_expr_absent: true`; `CM-10.oof_ty0_replaced_for_if_expr` PASS; derivative `OOF-TY0` in three negative cases propagates from `Unknown` resolved_type being checked against declared output type — a type-propagation diagnostic, not an unsupported-expression diagnostic; classification confirmed correct | PASS (NB) |
| SC-7 | Release harness and accepted release evidence are untouched | `harness_summary_intact: true`; `smoke_summary_intact: true`; `release_harness_not_in_write_scope: true`; CM-11 PASS × 2 | PASS |
| SC-8 | Runtime/evaluator, public API/CLI, Spark, and release surfaces remain closed | `no_runtime_evaluator_support`, `no_parser_changes`, `no_orchestrator_changes`, `no_assembler_changes`, `no_release_harness_mutation`, `no_release_evidence_mutation`, `no_public_api_cli_widening`, `no_public_demo_stable_claims`, `no_if_expr_in_release_scope`, `if_expr_proof_local_only` — all `true` in proof JSON; Spark absent from all proof code; `no_spark_claim` present in implementation track doc non-claims table (minor JSON/track-doc gap, non-blocking — Spark not touched by any proof code) | PASS (NB) |

Overall: **8/8 PASS** — no blockers.

---

## [Agree]

- The implementation write scope is exactly the four authorized paths from S3-R189-C1-A.
  No parser, classifier, orchestrator, assembler, runtime, release harness, or public
  surface is included.

- TypeChecker and SemanticIR stage shapes are concretely separated. Machine assertions
  confirm the TypeChecker `cond`/`then`/`else` with `branch` wrappers is distinct from
  the SemanticIR `condition`/`then_branch`/`else_branch` flat keys. Stage labeling
  (R188 NB-2) is satisfied by the C2-I implementation track doc and proof summary.

- Nested SemanticIR lowering is recursively flat. The proof summary reports identical
  outer and inner key sets: `["kind","condition","then_branch","else_branch","resolved_type"]`.
  This directly closes R188 NB-1 (the nested shape inconsistency found in the proof-only model).

- OOF-IF1..OOF-IF4 each fire in exactly the authorized trigger case with no
  cross-contamination. Each check is machine-asserted independently.

- OOF-IF5 is absent. It does not appear in any rule array, live source file, or
  track/decision doc. C1-A keeps it unowned and outside v0.

- The OOF-TY0 classification by C1-A is correct. The specific form
  `OOF-TY0 Unsupported expression kind: if_expr` is replaced (CM-10 PASS,
  `oof_ty0_for_if_expr_absent: true` in the non-Bool condition case). The derivative
  form `OOF-TY0 Type mismatch: expected ..., got Unknown` appearing in three negative
  case rule arrays is a secondary type-propagation diagnostic caused by `Unknown`
  resolved_type, not an unsupported-expression regression.

- Release harness, accepted release evidence, smoke summaries are all intact and not
  in write scope. CM-11 PASS × 2.

- All ten non-claim fields in the proof JSON are `true`. Runtime/evaluator, release
  execution, public API/CLI, Spark, and production surfaces are closed.

- The 28/28 proof check matrix is clean. The C1-A rerun verification (both
  `ruby -c` and `ruby` commands PASS) is a correct independent confirmation step.

- Dependency union policy: OOF-IF2/IF4 → condition deps only (no final branch
  expression to scan); OOF-IF1/IF3 → union of condition + both branch deps; success →
  full union recursively. CM-9 PASS × 3.

---

## [Challenge]

No blocking challenges.

The one area that warrants a hygiene note rather than a challenge: the proof summary
`non_claims` JSON block does not include a `no_spark_claim` key (it is present in the
implementation track doc non-claims table). This is a minor documentation gap. Given
that no Spark code is touched by any file in the proof, and Spark is explicitly closed
in the C1-A decision text, this does not constitute a proof or code blocker. Future
proof iterations should keep the JSON `non_claims` block consistent with the track doc
non-claims table.

---

## [Missing]

No blockers are missing from the acceptance basis. The following are non-blocking
observations for future hygiene:

1. **Proof-summary wording hygiene (NB-1):** The three negative cases `missing_else`,
   `branch_type_mismatch`, and `empty_branch` include `"OOF-TY0"` in their `rules`
   arrays. A reader unfamiliar with the CM-10 check or the C1-A classification decision
   may misread these as unsupported-if_expr regressions. A future proof-summary cleanup
   should annotate these entries (e.g., `"OOF-TY0 [derivative type-mismatch, not
   unsupported-if_expr]"`) or move them to a separate `secondary_rules` key with an
   explicit annotation. This is a documentation debt item, not a code or proof blocker.

2. **`no_spark_claim` absent from proof JSON `non_claims` (NB-2):** The proof summary
   JSON `non_claims` block does not include a `no_spark_claim` field. This field is
   present in the track doc non-claims table. Minor documentation gap; no code impact.

Both items are recommended for a later bounded proof/docs cleanup card. Neither
blocks C3-S curation or any future bounded docs/spec sync.

---

## [Sharper Question]

Can the derivative OOF-TY0 entries in the three negative case rule arrays ever be
misread by a future proof runner or automated check as an unsupported-if_expr
regression rather than a secondary type-propagation diagnostic?

Answer: Yes, by a naive reader or an automated check that does not distinguish the two
OOF-TY0 forms. The `non_bool_condition` case correctly shows `oof_ty0_for_if_expr_absent:
true`. The other three negative cases lack an equivalent explicit field. A future proof
update that adds `oof_ty0_for_if_expr_absent: true` and a `secondary_rules` annotation
to the `missing_else`, `branch_type_mismatch`, and `empty_branch` cases would make the
distinction self-documenting without requiring readers to cross-reference the CM-10
check or C1-A decision text.

---

## [Route]

**Verdict: proceed — all scope checks PASS; no blockers.**

```text
checks total: 8
checks pass:  8
checks fail:  0
blockers:     none
non-blocking notes: 2

NB-1: derivative OOF-TY0 in negative case rule arrays needs proof-summary wording
      hygiene so future readers do not misread as unsupported-if_expr regression
NB-2: no_spark_claim absent from proof JSON non_claims (present in track doc table);
      minor documentation gap
```

**Recommended C3-S decision:**

```text
accept implementation closure
accept 28/28 proof matrix
accept if_expr v0 as internal compiler support (TypeChecker + SemanticIR only)
accept TypeChecker/SemanticIR stage separation
accept recursive SemanticIR flat lowering (closes R188 NB-1)
accept OOF-IF1..OOF-IF4 live diagnostics
accept OOF-TY0 classification:
  unsupported-if_expr OOF-TY0 — closed/replaced
  derivative type-mismatch OOF-TY0 — acceptable secondary diagnostic
keep OOF-IF5 unowned/outside v0
keep runtime/evaluator support closed
keep release lane paused
keep public demo/stable/production/all-grammar/Spark/API claims closed

Potential next route after C2-X/C3-S:
  bounded if_expr docs/spec sync (update internal language/spec docs only)
  preserve release/public claim boundaries unless separately authorized

Do not open:
  runtime/evaluator implementation
  release harness mutation
  public release/demo claims
  Spark fixtures/integration
  API/CLI widening

Carry as non-blocking note for docs/spec sync route:
  NB-1 proof-summary wording hygiene for derivative OOF-TY0 in negative case rules
  NB-2 no_spark_claim JSON/track-doc consistency
```

Route: `track` — curate accepted-implementation-closure status and open bounded
`if_expr` docs/spec sync if C3-S agrees.
