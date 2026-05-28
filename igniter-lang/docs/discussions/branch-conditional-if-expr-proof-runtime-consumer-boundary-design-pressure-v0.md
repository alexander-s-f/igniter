# Branch Conditional If Expr Proof Runtime Consumer Boundary Design Pressure v0

Card: S3-R200-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: architect-supervisor
Track: branch-conditional-if-expr-proof-runtime-consumer-boundary-design-pressure-v0

Context: public-github-only
Write access: none
Canon authority: none

Depends on:
- S3-R200-C1-D
- S3-R199-C5-S

---

## Question

Does the S3-R200-C1-D proof RuntimeMachine consumer boundary design correctly
resolve the naive delegation problem, provide explicit expression-kind ownership,
handle the `tbackend_read` temporal authority question without silently absorbing
it, require backward-compatible API amendment, define a sufficient proof matrix,
and keep RuntimeSmoke / root require / CompilerOrchestrator / CompilerResult /
CompilationReport / release / public / Spark / API / CLI / counterfactual audit
all closed?

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-boundary-design-v0.md`
  (S3-R200-C1-D)
- `igniter-lang/docs/tracks/stage3-round199-status-curation-v0.md`
  (R199 status — routed S3-R200-C1-D design-only next)
- `igniter-lang/docs/tracks/branch-conditional-if-expr-live-runtime-evaluator-implementation-acceptance-decision-v0.md`
  (Slice 1 C4-A — accepted LRT-IF1..LRT-IF15 / 68/68 PASS)
- `igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb`
  (live Slice 1 evaluator — literal/ref/if_expr, SUPPORTED_KINDS frozen)
- `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb`
  (proof RuntimeMachine current eval_expr — apply/field_access/literal/ref/tbackend_read,
   no if_expr case, raises ArgumentError for unknown kinds)
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`
  (RuntimeSmoke — delegates to experiments/runtime_machine_memory_proof via require_relative)

---

## Scope Check Matrix

| SC | Scope check | Result | Evidence |
|----|-------------|--------|----------|
| SC-1 | Design is design-only — no code changed | PASS | Card states "This card does not edit code, does not authorize implementation." No `.rb` files in authorized write surface beyond future candidate paths. |
| SC-2 | Boundary specific enough for a future authorization review | PASS | Named file paths, ownership table, API amendment shape, PRT-IF1..PRT-IF15 proof matrix, 6-command matrix defined. |
| SC-3 | Full current proof-runtime expression corpus accounted for | PASS | All five kinds covered: `literal`, `ref`, `apply`, `field_access`, `tbackend_read` — plus `if_expr` as the bridge kind. |
| SC-4 | `tbackend_read` temporal authority not silently absorbed | PASS | Explicit exclusion from evaluator core. PRT-IF5 conditional on temporal infrastructure. Ownership column assigns to "temporal/proof RuntimeMachine local". |
| SC-5 | `apply` and `field_access` ownership explicit and non-absorbed | PASS | Ownership table assigns both to "proof RuntimeMachine local". Evaluator does not claim them. |
| SC-6 | Slice 1 backward compatibility required by design | PASS | API amendment stated as backward-compatible. Existing `evaluate(expr, values = {}, call_trace: nil)` signature preserved; `external_evaluator:` added as optional kwarg or constructor injection equivalent. |
| SC-7 | Regression matrix protects existing Slice 1 behavior | PASS | PRT-IF12 covers non-`if_expr` fixture regression. Separate command for LRT-IF1..LRT-IF15 regression rerun in command matrix. |
| SC-8 | RuntimeSmoke remains closed | PASS | Explicit "RuntimeSmoke Stance" section. No `require_relative` to RuntimeSmoke added. |
| SC-9 | Root require remains closed | PASS | Explicit answer: "No root require added." |
| SC-10 | CompilerOrchestrator / CompilerResult / CompilationReport closed | PASS | All three explicitly named and closed in forbidden surfaces section. |
| SC-11 | Dynamic dependency tracking / cache authority deferred | PASS | Full section with 5 forbidden behaviors: no path-sensitive dependency receipts, no dynamic dependency authority, no path-sensitive cache keys, no cache invalidation changes, no runtime report fields implying selected-path dependency authority. |
| SC-12 | Counterfactual audit is future pressure only | PASS | Full section. "Runtime is lazy. Audit is aware." 6 explicitly not-authorized items. |
| SC-13 | Release / public / Spark / API / CLI closed | PASS | Explicit answers in closed-surfaces section. |

**Verdict: proceed — 13/13 PASS, no blockers, 2 non-blocking notes.**

---

## Non-Blocking Notes

**NB-1: API amendment spelling not committed.**

The design proposes two alternative forms for the adapter hook — (a) an optional
kwarg `external_evaluator:` passed to `evaluate(...)`, and (b) constructor
injection at `SemanticIRExpressionEvaluator.new(external_evaluator: nil)`. The
design does not select one.

The backward-compatibility semantics differ between the two forms: kwarg allows
per-call override, constructor injection makes the hook a stable instance
attribute. The C3-A authorization review must commit to one form before Slice 2
implementation opens, since both the proof harness API and any caller
(`compiled_program.rb` integration pattern) depend on the selected shape.

Recommended resolution gate: the C3-A authorization review card (or a pre-card
design addendum) must name the committed form with rationale, and the PRT-IF
proof harness must exercise that form exclusively.

**NB-2: PRT-IF5 temporal fixture requirement ambiguous.**

PRT-IF5 tests `tbackend_read` in the selected branch. The design states this case
is conditional on temporal infrastructure. Two interpretations are consistent with
the design:

(a) Full temporal fixture: a real or synthetic `tbackend_read` expression is
routed through the proof RuntimeMachine and the `external_evaluator:` hook
correctly delegates it without calling the evaluator core.

(b) Structural scan: a negative scan asserts that the evaluator's
`UnsupportedExpressionKindError` is correctly triggered when `tbackend_read`
reaches the evaluator core, and a positive assertion confirms `tbackend_read` is
never routed to the evaluator core in the accepted consumer integration.

Both are technically defensible, but they require different proof infrastructure.
The C3-A authorization review should clarify which interpretation is required
before the Slice 2 proof harness is written.

---

## [Agree]

- The naive delegation problem is correctly identified. Without a hook, an
  `if_expr` whose selected branch contains `apply`, `field_access`, or
  `tbackend_read` would cause the Slice 1 evaluator to raise
  `UnsupportedExpressionKindError`. The design confronts this directly.
- Option 2 (backward-compatible adapter hook) is architecturally correct. It
  preserves the evaluator's ownership of lazy `if_expr` selection semantics
  while keeping `apply`/`field_access`/`tbackend_read` locally owned by the
  proof RuntimeMachine.
- Expression-kind ownership table is explicit and complete for the current corpus.
  No kind is double-owned or accidentally absorbed.
- The PRT-IF matrix (PRT-IF1..PRT-IF15) is sufficient in range: it covers basic
  delegation, nested `if_expr`, all delegated kinds, `tbackend_read` conditional,
  malformed nodes, nil hook fallback, regression anchors, and non-`if_expr`
  pass-through.
- RuntimeSmoke, root require, CompilerOrchestrator, CompilerResult, and
  CompilationReport are named and explicitly closed. The design does not widen
  any of these surfaces.
- Static dependency union is correctly preserved. The design acknowledges the
  tension (dynamic tracking would require the hook to report which branch was
  selected) but holds dynamic tracking deferred without leaking it.
- Counterfactual audit treatment is correct. "Runtime is lazy. Audit is aware."
  The design preserves explicit branch structure (condition + then_branch +
  else_branch as separate nodes in the expression graph) without evaluating both
  branches, leaving the structure available for future audit inspection without
  committing to a counterfactual evaluation facility now.

---

## [Challenge]

- The `tbackend_read` exclusion from the evaluator core is correct, but the
  design does not state whether the `external_evaluator:` hook is also
  responsible for handling `tbackend_read` delegation or whether `tbackend_read`
  should be structurally unreachable via the evaluator path in accepted consumer
  integration. This distinction matters for PRT-IF5 scope.
- The design proposes a hook but does not specify what happens when the hook
  returns an exception. If the `external_evaluator` raises, does the evaluator
  propagate the exception, wrap it, or convert it to a generic
  `UnsupportedExpressionKindError`? The implementation card will need to decide
  this, and it affects whether the proof matrix is complete.
- The design correctly holds `call_trace` as debug evidence only. However, if the
  `external_evaluator:` hook receives a `call_trace` argument (for delegated
  expression tracing), the design should explicitly state whether the hook is
  responsible for tracing delegated expression kinds or whether tracing stops at
  the delegation boundary. This is minor but affects proof completeness.

---

## [Missing]

- Committed API amendment form (kwarg vs. constructor injection). See NB-1.
  This is the highest-priority missing item for the authorization review.
- PRT-IF5 temporal fixture interpretation. See NB-2.
- `external_evaluator:` exception propagation policy. Not specified in design.
  Should be decided before implementation authorization to prevent the hook from
  accidentally swallowing evaluator-origin errors.

---

## [Sharper Question]

Given that the adapter hook is the central design decision, the smallest better
question is:

> Which hook form — per-call kwarg or constructor injection — produces a simpler
> proof harness while remaining backward-compatible with the accepted Slice 1 API,
> and does the selected form allow `call_trace` to flow through the delegation
> boundary without creating a dependency-tracking surface?

---

## [Route]

Proceed. Route to:

```text
Card: S3-R200-C3-A
Agent: [Compiler/Grammar Expert]
Role: compiler-grammar-expert
Route: AUTHORIZATION REVIEW
Track: branch-conditional-if-expr-proof-runtime-consumer-boundary-design-v0
Depends on:
- S3-R200-C2-X
```

Required before authorization is granted:

1. Commit to one API amendment form (kwarg vs. constructor injection) with
   explicit rationale. This is binding for the Slice 2 proof harness.
2. Clarify PRT-IF5 scope: full temporal fixture, or structural scan asserting
   `tbackend_read` is never routed to the evaluator core (NB-2).
3. Specify `external_evaluator:` exception propagation policy.
4. Confirm that `call_trace` flow through delegation boundary does not open a
   dynamic dependency-tracking surface.

Surfaces that must remain closed through the authorization review and any
subsequent implementation card:

- RuntimeSmoke;
- root require (`igniter-lang/lib/igniter_lang.rb`);
- CompilerOrchestrator, CompilerResult, CompilationReport;
- release execution, RubyGems publish, tag/push/sign/deploy;
- public API/CLI widening;
- counterfactual audit implementation;
- Spark data, fixtures, specs, ids, integration, or demo behavior;
- dynamic dependency/cache authority;
- path-sensitive cache keys;
- `tbackend_read` temporal authority (unless separately opened by temporal/runtime
  authority in a named gate).
