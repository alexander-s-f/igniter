# Branch Conditional If Expr Runtime Evaluator Proof Local Pressure v0

Card: S3-R197-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Track: branch-conditional-if-expr-runtime-evaluator-proof-local-pressure-v0

Question:
Does the S3-R197-C2-I proof-local if_expr runtime/evaluator experiment correctly
prove lazy branch semantics, keep non-selected branches entirely un-evaluated,
close on non-Bool conditions and malformed nodes, satisfy RT-IF1..RT-IF13,
defer dynamic dependency tracking, avoid all live runtime/lib/release/public
surfaces, and refrain from canonizing runtime diagnostic vocabulary?

Context:
- S3-R197-C2-I track doc: `branch-conditional-if-expr-runtime-evaluator-proof-local-v0.md`
- Proof runner: `experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/branch_conditional_if_expr_runtime_evaluator_proof_v0.rb`
- Proof summary JSON: `experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/out/branch_conditional_if_expr_runtime_evaluator_proof_summary.json`
- Authorization basis: S3-R197-C1-A track doc
- Design basis: S3-R196-C4-S status curation (lazy accepted, RT-IF12 structural only, dynamic tracking deferred)

---

## Scope Check Matrix

| ID | Check | Result |
| --- | --- | --- |
| SC-1 | RT-IF1..RT-IF13 all present and passing | PASS |
| SC-2 | Non-selected branch failures do not fire | PASS |
| SC-3 | Selected branch failures propagate | PASS |
| SC-4 | Non-Bool condition fails closed; no truthy/falsy coercion | PASS |
| SC-5 | Malformed `if_expr` (missing required keys) fails closed | PASS |
| SC-6 | Unknown selected-path kind fails closed; unknown non-selected doesn't fire | PASS |
| SC-7 | Nested `if_expr` applies lazy semantics recursively | PASS |
| SC-8 | RT-IF12 structural only; `call_trace` is proof instrumentation; no dynamic dependency tracking | PASS |
| SC-9 | No live lib/RuntimeSmoke/CompilerOrchestrator loaded | PASS |
| SC-10 | No runtime diagnostic vocabulary canonized; error classes labeled non-canonical | PASS |
| SC-11 | Write scope bounded to authorized experiment directory + track doc | PASS |

---

## [Agree]

- The `ProofLocal::IfExprEvaluator` is entirely self-contained inside the
  experiment file. No `require` of any `lib/igniter_lang` module, no
  `require` of the runtime machine memory proof, and no `require` of any
  compiler module. RT-IF13.live_lib_runtime_not_loaded,
  RT-IF13.compiler_libs_not_loaded, and
  RT-IF13.runtime_machine_memory_proof_not_loaded all PASS. This satisfies
  the closed-surface requirement completely.

- The lazy evaluation architecture is structurally correct. The `eval_if_expr`
  method evaluates condition first, guards on exactly `true`/`false`, then
  enters one of two mutually exclusive Ruby `if` arms — only the selected
  arm calls `eval_expr`. The non-selected branch expression is never passed
  to `eval_expr`. This is the minimal correct implementation of lazy branch
  semantics.

- RT-IF3 (non-selected then would fail, condition false → no error) and RT-IF4
  (non-selected else would fail, condition true → no error) use a
  `failing_expr` kind that always raises `RuntimeError`. These are the
  strongest possible dynamic proofs of non-selection: if the non-selected
  branch were evaluated at all, the test would immediately fail. Combined
  with call-trace evidence showing `failing_expr` absent from the trace,
  this is dual structural + dynamic proof.

- RT-IF5 proves the correct ordering: condition failure propagates before any
  branch evaluation. The call trace after rescue shows `["if_expr",
  "failing_expr"]` — neither `then_branch` nor `else_branch` appears. This
  confirms the evaluation order is condition → guard → select, with no
  branch evaluation on condition failure.

- RT-IF7 covers 5 distinct non-Bool types: Integer 42, String "truthy", nil
  (NilClass), Integer 0, and Array [true]. All raise `ConditionNotBoolError`.
  Ruby truthy/falsy semantics are completely excluded. The error class is
  `ConditionNotBoolError`, not `BooleanError` — the name correctly signals
  the runtime Bool requirement rather than a general truthiness check.

- RT-IF11 covers 2-level nesting (outer-true → inner-false) and 3-level
  nesting (RT-IF11.nested_three_level_lazy), proving that lazy semantics
  apply recursively through the recursive `eval_expr` call in each arm.
  Failing expressions in non-selected inner branches do not fire.

- RT-IF12 structural proof reads the runner's own source (via `File.read(__FILE__)`)
  and confirms the presence of the two annotated comment lines:
  `# line A: only then_branch` and `# line B: only else_branch`. This
  satisfies the S3-R197-C1-A requirement for structural proof. The
  `rt_if12_requires_dynamic_touch_tracing: false` field confirms the
  R196-C2-X NB-1 concern was resolved by C1-A without reopening scope.

- RT-IF12.no_dynamic_dependency_tracking_infrastructure confirms that the
  evaluator has no `touch_trace`, `dep_receipts`, or `path_sensitive_deps`
  methods. The `call_trace` attribute is proof instrumentation only.

- All 7 non-claims are `true` in the summary JSON:
  `no_release_execution`, `no_public_demo_claim`,
  `no_stable_production_all_grammar_claim`, `no_spark_claim`,
  `no_public_api_cli_widening`, `no_live_runtime_integration`,
  `no_compiler_behavior_change`. These cover the full required surface.

- Error classes (`MalformedIfExprError`, `ConditionNotBoolError`,
  `UnsupportedExpressionKindError`) are all subclasses of
  `ProofLocal::IfExprProofError` and labeled "(non-canonical)" in the
  summary JSON. `structured_runtime_codes_canonized: false` and
  `oof_rt_codes_canonized: false` are both present. This satisfies the
  C1-A requirement to accept plain raises / proof-local error objects without
  canonizing structured codes.

- The required summary JSON shape from C1-A is fully satisfied. All mandatory
  top-level fields (`status`, `checks_total`, `checks_pass`, `checks_fail`,
  `failed_checks`, `semantics`, `dependency_policy`, `error_surface`,
  `runtime_scope`, `non_claims`) are present with the required field values.

- Static TypeChecker union (condition + then_branch + else_branch) is
  preserved unchanged. The proof correctly records
  `dynamic_selected_branch_tracking: "deferred"` and does not introduce
  any path-sensitive cache key, invalidation, freshness, or dependency
  receipt infrastructure.

- Write scope is correct: the runner, the summary JSON, and the track doc
  are the only changed files, all within the C1-A authorized write scope
  (`experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/**`
  and the track doc path). The closed-surface scan in RT-IF13 is
  comprehensive (12 sub-checks, all PASS).

---

## [Challenge]

No blockers identified. The following observations are offered as precision
notes for the record.

---

## [Missing]

Nothing missing for proof acceptance. Two cosmetic observations noted below.

---

## [Sharper Question]

The proof is complete for a proof-local experiment. The natural follow-on
question is: **what is the required gate for a live `lib/` runtime/evaluator
implementation authorization review?** That question belongs to a future
authorization card, not to this proof-local experiment.

---

## [Route]

proceed — 11/11 PASS, no blockers, two non-blocking notes

---

## Non-Blocking Notes

### NB-1: `call_trace` public reader and potential future misreading

The `call_trace` attribute is public (`attr_reader :call_trace`) on
`IfExprEvaluator`. A future reader arriving at the class without reading
the proof context might briefly wonder whether `call_trace` is a dependency
tracking mechanism. The RT-IF12.no_dynamic_dependency_tracking_infrastructure
check explicitly confirms it is not (no `touch_trace`, `dep_receipts`, or
`path_sensitive_deps` methods exist). The proof function is clear in context.
This is a cosmetic documentation note; it does not affect correctness.

### NB-2: RT-IF13 release-command scan uses split-string pattern

RT-IF13.no_release_commands_in_script scans the runner source for patterns
like `"gem " + "push"` (concatenated to avoid self-referential false
positives) and asserts `<= 1` occurrence. This is a sound technique but has
a subtle assumption: the runner itself contains exactly one occurrence of the
split form (its own scanning string). If a future runner adds comments that
incidentally contain these patterns, the `<= 1` threshold may not catch them.
For the current runner this is not an issue, and the approach is consistent
with prior proof patterns in this track. Non-blocking structural note.

---

## Compact Verdict

```text
card:              S3-R197-C3-X
input:             S3-R197-C2-I (proof-local evaluator experiment)
verdict:           proceed
scope_checks:      11/11 PASS
blockers:          0
non_blocking_notes: 2 (NB-1: call_trace label clarification; NB-2: release command scan self-referential note)
proof_matrix:      RT-IF1..RT-IF13 all PASS (54/54 sub-checks)
lazy_semantics:    proven structurally + dynamically
non_selected_eval: forbidden — proven by RT-IF3/RT-IF4 failing_expr non-fire + call trace exclusion
rt_if12:           structural proof only; rt_if12_requires_dynamic_touch_tracing=false
live_lib_changed:  false
diagnostic_vocab:  non-canonical; not published; not canonized
```

---

## Exact Recommendation for C4-A

Accept the proof-local runtime/evaluator experiment (S3-R197-C2-I):

- Accept RT-IF1..RT-IF13 (54/54 PASS) as sufficient lazy semantics proof for
  the proof-local scope.
- Accept `ProofLocal::IfExprEvaluator` as proof-local only; it does not
  integrate with `lib/` runtime, `RuntimeSmoke`, or `CompilerOrchestrator`.
- Accept proof-local error classes (`MalformedIfExprError`,
  `ConditionNotBoolError`, `UnsupportedExpressionKindError`) as non-canonical
  proof instrumentation. Do not publish or canonize them.
- Accept `rt_if12_requires_dynamic_touch_tracing: false` as the standing policy
  for this proof slice. Dynamic dependency tracking remains deferred.
- Carry NB-1 (call_trace clarification cosmetic) and NB-2 (release command
  scan self-referential note) as cosmetic notes only.
- Keep all live runtime/lib/RuntimeSmoke/CompilerOrchestrator/parser/
  TypeChecker/SemanticIR/assembler/release/public/Spark/API/CLI surfaces
  closed. This proof does not open any of them.
- If a live library implementation authorization review is desired as the next
  route, open only a bounded `live-runtime-evaluator-implementation-authorization-review`
  card. Do not open implementation, release execution, or public claims from
  this proof acceptance alone.
