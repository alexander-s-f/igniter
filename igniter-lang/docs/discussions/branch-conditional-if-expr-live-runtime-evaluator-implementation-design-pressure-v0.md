# Branch Conditional If Expr Live Runtime Evaluator Implementation Design Pressure v0

Card: S3-R198-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Track: branch-conditional-if-expr-live-runtime-evaluator-implementation-design-pressure-v0

Question:
Does the S3-R198-C1-D live if_expr runtime/evaluator implementation design
correctly bound the live placement, preserve lazy semantics, forbid non-selected
branch execution, specify malformed/unknown policies explicitly, guard the
runtime diagnostic/error surface from becoming public or canonical, defer
counterfactual audit to future pressure, defer dynamic dependency tracking,
keep all live code surfaces closed, and provide a sufficient proof/regression
matrix for a later implementation-authorization review?

Context:
- S3-R198-C1-D design output: `branch-conditional-if-expr-live-runtime-evaluator-implementation-design-v0.md`
- Status basis: `stage3-round197-status-curation-v0.md`
- Acceptance basis: `branch-conditional-if-expr-runtime-evaluator-proof-local-acceptance-decision-v0.md`
- Future pressure: `branch-conditional-counterfactual-audit-future-pressure-v0.md`
- Runtime survey: `experiments/runtime_machine_memory_proof/compiled_program.rb`,
  `lib/igniter_lang/runtime_smoke.rb`, `lib/igniter_lang/compiler_orchestrator.rb`

---

## Scope Check Matrix

| ID | Check | Result |
| --- | --- | --- |
| SC-1 | Design is design-only; no live code written or authorized | PASS |
| SC-2 | Live placement is specific enough for an implementation-authorization review | PASS |
| SC-3 | Lazy semantics remain condition-first, selected-branch-only | PASS |
| SC-4 | Non-selected branch execution is forbidden in normal runtime | PASS |
| SC-5 | Malformed and unknown-expression policies are explicit | PASS |
| SC-6 | Runtime diagnostics/error surface is not accidentally public or canonical | PASS |
| SC-7 | Dependency/cache behavior does not imply path-sensitive tracking | PASS |
| SC-8 | Counterfactual audit recognized as future pressure only; not smuggled | PASS |
| SC-9 | Implementation write scope is future-only and bounded | PASS |
| SC-10 | Parser/TypeChecker/SemanticIR/compiler/assembler changes remain closed | PASS |
| SC-11 | Release/public/Spark/API/CLI claims remain closed | PASS |
| SC-12 | Proof/regression matrix is sufficient for a later implementation-auth review | PASS |

---

## [Agree]

- The design is purely a track document. No live code is introduced. The
  candidate write scope is explicitly labeled "Candidate future write scope"
  and "Potential later write scope." Nothing in the changed file list touches
  `lib/igniter_lang/`, the proof RuntimeMachine, `RuntimeSmoke`, or any
  compiler pipeline file. SC-1 PASS.

- The live placement decision is specific and grounded. `lib/igniter_lang/
  semanticir_expression_evaluator.rb` / `IgniterLang::SemanticIRExpressionEvaluator`
  is a named file path and a named module constant. The direct-require-only
  stance (no root require, no `lib/igniter_lang.rb` change) is explicitly
  stated. The placement rationale is sound: it gives the language a reusable
  evaluator boundary without coupling the first slice to `RuntimeSmoke` or
  the proof RuntimeMachine. SC-2 PASS.

- The "Runtime Semantics" section exactly mirrors the R196/R197 accepted lazy
  semantics policy: condition first, runtime Bool only, selected branch only,
  return selected branch value, apply the same rules recursively for nested
  `if_expr`. The forbidden list is explicit: Ruby truthy/falsy coercion, eager
  branch evaluation, speculative non-selected branch execution, hidden side
  effects from the non-selected branch, and treating proof call traces as
  dependency authority. SC-3 and SC-4 PASS.

- The "Malformed SemanticIR Policy" section is specific and complete. It
  enumerates every fail-closed condition: non-Hash input, missing `kind`,
  missing `condition`/`then_branch`/`else_branch`, unsupported selected-path
  kind, missing selected-path reference, and non-Bool condition value. It
  also correctly notes that non-selected-branch fields must exist (structural
  check) but their expression kind must not be evaluated unless selected. This
  cleanly preserves both fail-closed behavior and lazy semantics. SC-5 PASS.

- The runtime error surface is properly bounded. The four candidate internal
  reason labels (`runtime.if_expr_malformed`, `runtime.if_expr_condition_not_bool`,
  `runtime.expression_unsupported`, `runtime.ref_missing`) are explicitly
  marked "internal/provisional only; not OOF-RT-*; not Diagnostics; not
  CompilationReport; not public result surface; not API/CLI; not release
  evidence wording." Five explicit exception class names are proposed under
  the `IgniterLang::SemanticIRExpressionEvaluator` namespace, not under a
  public namespace. SC-6 PASS.

- The "Dependency and Cache Stance" section is explicit on six forbidden
  behaviors in Slice 1: no path-sensitive dependency receipts, no dynamic
  dependency authority, no path-sensitive cache keys, no cache invalidation
  changes, no freshness state changes, and no runtime report fields implying
  selected-path dependency authority. An optional proof trace may record
  evaluation order, but it is labeled "debug/proof evidence only." SC-7 PASS.

- The "Counterfactual Audit Stance" section correctly names the future pressure
  document phrase ("Runtime is lazy. Audit is aware."), acknowledges it, and
  explicitly declines to implement any of it. The section names exactly what
  is deferred: counterfactual dry-run, comparison reports, effect sandboxing,
  public counterfactual API/CLI. It also correctly notes what the live design
  should preserve for future audit compatibility: explicit condition/branch
  structure and clear separation between selected evaluation and latent branch
  metadata. This is the right posture — acknowledge the design gravity without
  being pulled into premature implementation. SC-8 PASS.

- The three-slice split is correctly framed as future work. Slice 1 (internal
  evaluator core) has a named candidate write scope of 3 paths. Slice 2
  (proof RuntimeMachine consumer) and Slice 3 (RuntimeSmoke consumer) are
  explicitly held until Slice 1 is accepted and until further authorization
  decisions respectively. SC-9 PASS.

- The Integration Boundaries table closes every surface that is currently live:
  root require, RuntimeSmoke, CompilerOrchestrator, CompilerResult,
  CompilationReport, Diagnostics, runtime_machine_memory_proof, assembler/
  `.igapp`, parser/classifier/TypeChecker/SemanticIR emitter, public API/CLI,
  release harness/evidence, and Spark. All are "Closed" or explicitly deferred
  with conditions. SC-10 and SC-11 PASS.

- The LRT-IF1..LRT-IF15 proof matrix extends the R197 RT-IF1..RT-IF13 set by
  adding LRT-IF13 (error surface isolation), LRT-IF14 (direct-require-only
  boundary), and LRT-IF15 (closed-surface scan). The five-command command
  matrix pins the exact runner files and adds a release-harness delta
  regression command. SC-12 PASS.

- The live code survey is grounded. The design correctly identifies that
  `compiled_program.rb` raises `ArgumentError` for unknown expression kinds,
  that `RuntimeSmoke` delegates entirely to the proof RuntimeMachine (no
  independent eval), that `CompilerOrchestrator` takes a `runtime_smoke:`
  callback but does not own expression evaluation, and that no live
  `IgniterLang::SemanticIRExpressionEvaluator` exists. This gives a correct
  basis for the placement recommendation.

- The "C3-A Decision Options" table is honest and complete. The preferred
  option is clearly labeled. The alternatives are not overly narrow. The
  preferred framing "accept design and authorize a later implementation-
  authorization review for Slice 1 only" is the correct minimum gate.

---

## [Challenge]

No blockers identified. The design is well-bounded and grounded in live code
facts. Three non-blocking notes are offered below.

---

## [Missing]

Nothing blocking is absent. The three non-blocking notes identify areas where
the implementation-authorization review should supply additional precision.

---

## [Sharper Question]

The design correctly defers multiple surfaces. The natural follow-on question
for the C3-A gate is: **what binding gate conditions should the Slice 1
implementation-authorization review carry?** Specifically, should the
authorization review explicitly confirm the `runtime.` prefix reason labels as
proof-debug vocabulary only (not a step toward canonizing runtime.* diagnostic
codes), and should it explicitly list the expression kinds that LRT-IF15 must
scan against for closed-surface regression?

---

## [Route]

proceed — 12/12 PASS, no blockers, three non-blocking notes

---

## Non-Blocking Notes

### NB-1: `runtime.` prefix on internal reason labels risks future canonization gravity

The design proposes four internal reason labels for proof summary use:
`runtime.if_expr_malformed`, `runtime.if_expr_condition_not_bool`,
`runtime.expression_unsupported`, `runtime.ref_missing`. These are explicitly
labeled "internal/provisional only; not OOF-RT-*; not Diagnostics; not
CompilationReport; not public result surface." The status is clearly correct.

However, the `runtime.` prefix creates a vocabulary gravity risk: a future
reader who encounters these strings in a proof summary JSON may assume they are
the beginning of a canonized `runtime.*` diagnostic namespace. The R196-C2-X
NB-2 pressure note ("candidate runtime.* diagnostic codes deferred without named
gate") was resolved by C1-A and C2-I accepting only plain raises / proof-local
error objects. The live design's internal labels should not reopen that question.

Recommendation for C3-A: confirm explicitly in the implementation-authorization
review that the internal reason label strings are proof-debug human-readable
labels only (analogous to exception message strings), are not a step toward
canonizing a `runtime.*` diagnostic vocabulary, are not to be exposed in public
result shapes, and may be changed without the OOF-RT-* governance gate. This is
a naming hygiene note, not a design blocker.

### NB-2: Slice 1 optional expression kinds (`apply`, `field_access`) and Slice 2 regression coverage

The design recommends that Slice 1 support `literal`, `ref`, `if_expr` as
required, and `apply`/`field_access` optionally only if needed by proof
fixtures. This is a reasonable first-slice stance.

However, the proof RuntimeMachine (`compiled_program.rb`) currently evaluates
`apply`, `field_access`, `literal`, `ref`, and `tbackend_read`. If Slice 2
replaces or wraps the proof RuntimeMachine's expression evaluation with the new
`SemanticIRExpressionEvaluator`, and the Slice 2 card's LRT-IF15 regression
matrix does not pin the full `apply`/`field_access` corpus, there could be a
regression gap between the current proof runtime behavior and the new evaluator.

The design correctly defers this to Slice 2 and requires that "Slice 2 should
wait until Slice 1 is accepted." But the Slice 1 implementation-authorization
review should note explicitly that the Slice 2 LRT-IF15 regression must cover
the full current proof-runtime expression kind corpus, including `apply` and
`field_access`, before the proof RuntimeMachine consumer path may be opened.
Non-blocking; this is a precision note for the authorization chain.

### NB-3: `tbackend_read` exclusion from Slice 1 should be a binding gate condition

The design correctly states that "`tbackend_read` should remain out of Slice 1
unless a separate temporal/runtime authority explicitly opens it." This is the
right policy — temporal access requires explicit authorization separate from
expression evaluation.

The Slice 1 implementation-authorization review should carry this as a named
binding gate condition (not just a design recommendation), so that if a future
implementer is tempted to add `tbackend_read` support to the evaluator for
convenience, there is a clear gate requiring a separate temporal/runtime
authority. Non-blocking; this is a precision note for the authorization chain.

---

## Compact Verdict

```text
card:              S3-R198-C2-X
input:             S3-R198-C1-D (live runtime/evaluator implementation design)
verdict:           proceed
scope_checks:      12/12 PASS
blockers:          0
non_blocking_notes: 3
  NB-1: runtime.* prefix on internal reason labels — naming hygiene; not canonization step
  NB-2: optional apply/field_access in Slice 1; Slice 2 regression must cover full proof corpus
  NB-3: tbackend_read Slice 1 exclusion should be a binding gate condition
design_only:       confirmed (no live code written or authorized)
live_placement:    semanticir_expression_evaluator.rb — specific, grounded, direct-require-only
lazy_semantics:    preserved; condition-first, selected-branch-only, forbidden coercion
non_selected:      forbidden — explicit in design
malformed_policy:  explicit fail-closed enumeration
error_surface:     internal/provisional only; not OOF-RT-*; not Diagnostics; not public
cache_deps:        static union preserved; dynamic tracking deferred; 6 forbidden items
counterfactual:    acknowledged as future pressure; not smuggled
closed_surfaces:   RuntimeSmoke/Orchestrator/Result/Report/assembler/parser/TC/SIR/release/Spark all closed
proof_matrix:      LRT-IF1..LRT-IF15 defined; command matrix pinned
```

---

## Exact Recommendation for C3-A

Accept the live if_expr runtime/evaluator implementation design (S3-R198-C1-D)
and authorize a Slice 1 implementation-authorization review only:

- Accept the live placement decision: `lib/igniter_lang/semanticir_expression_evaluator.rb`
  / `IgniterLang::SemanticIRExpressionEvaluator`, direct-require-only, no root
  require change.
- Accept the three-slice split. The next authorized card is the Slice 1
  implementation-authorization review only.
- Accept LRT-IF1..LRT-IF15 as the required proof matrix for the Slice 1
  implementation card.
- Accept the five-command command matrix as a required gate for Slice 1.
- Carry NB-1 as a binding gate condition for the Slice 1 implementation-
  authorization review: the authorization review must confirm that the internal
  `runtime.` reason label strings are proof-debug human-readable labels only,
  are not a step toward canonizing `runtime.*` diagnostic vocabulary, and are
  not to appear in public result shapes.
- Carry NB-2 as a binding condition for the Slice 2 authorization review (not
  Slice 1): the Slice 2 LRT-IF15 regression matrix must cover the full current
  proof-runtime expression kind corpus including `apply` and `field_access`
  before the proof RuntimeMachine consumer path may open.
- Carry NB-3 as a binding gate condition for Slice 1: `tbackend_read` must be
  explicitly excluded from `SemanticIRExpressionEvaluator` Slice 1, and opening
  it requires a separate temporal/runtime authority decision.
- Keep `RuntimeSmoke`, `CompilerOrchestrator`, `CompilerResult`,
  `CompilationReport`, `Diagnostics`, `runtime_machine_memory_proof`,
  assembler/`.igapp`, parser/TypeChecker/SemanticIR, public API/CLI, release
  harness/evidence, Spark, cache/path-sensitive tracking, and counterfactual
  audit all closed.
- Release lane remains paused. Public demo/stable/production/all-grammar/Spark/
  API/CLI claims remain closed.
