# Branch Conditional If Expr Live Runtime Evaluator Implementation Pressure v0

Card: S3-R199-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Track: branch-conditional-if-expr-live-runtime-evaluator-implementation-pressure-v0

Question:
Does the S3-R199-C2-I Slice 1 live if_expr runtime/evaluator implementation
stay inside the authorized write scope, implement lazy semantics correctly,
keep the non-selected branch un-evaluated, enforce all required failure policies,
use `call_trace` as debug evidence only, keep `tbackend_read`/`apply`/`field_access`
absent, satisfy the NB-1 binding gate condition for `runtime.*` label non-
canonization, pass LRT-IF1..LRT-IF15 (68/68 sub-checks), and leave all closed
surfaces untouched?

Context:
- S3-R199-C1-A authorization review: `branch-conditional-if-expr-live-runtime-evaluator-slice1-implementation-authorization-review-v0.md`
- S3-R199-C2-I track doc: `branch-conditional-if-expr-live-runtime-evaluator-implementation-v0.md`
- Live implementation: `lib/igniter_lang/semanticir_expression_evaluator.rb`
- Proof runner: `experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0.rb`
- Proof summary JSON: `experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/out/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_summary.json`
- Design pressure basis: `branch-conditional-if-expr-live-runtime-evaluator-implementation-design-pressure-v0.md` (S3-R198-C2-X)
- Status basis: `stage3-round198-status-curation-v0.md`

---

## Scope Check Matrix

| ID | Check | Result |
| --- | --- | --- |
| SC-1 | Changed files are inside authorized write scope | PASS |
| SC-2 | Root require `lib/igniter_lang.rb` unchanged | PASS |
| SC-3 | RuntimeSmoke/CompilerOrchestrator/CompilerResult/CompilationReport/Diagnostics/proof RuntimeMachine/parser/TypeChecker/SemanticIR/assembler/release/Spark/API/CLI/cache/counterfactual closed | PASS |
| SC-4 | Supported expression kinds match authorization: `literal`, `ref`, `if_expr` only | PASS |
| SC-5 | `tbackend_read`, `apply`, and `field_access` absent from implementation | PASS |
| SC-6 | Lazy semantics implemented: condition-first, selected-branch-only, Bool guard | PASS |
| SC-7 | Non-selected branch is never evaluated in normal runtime | PASS |
| SC-8 | Malformed/unknown/ref-missing/non-Bool failure policies match authorization | PASS |
| SC-9 | Internal `runtime.*` labels are non-canonical proof/debug labels (NB-1 binding gate satisfied) | PASS |
| SC-10 | `call_trace` is proof/debug evidence only; not dependency authority | PASS |
| SC-11 | LRT-IF1..LRT-IF15 all PASS; 68/68 sub-checks | PASS |
| SC-12 | Command matrix with all 5 required commands recorded | PASS |
| SC-13 | Regression proofs (proof-local 54/54, delta 39/39) unchanged with matching SHA256 | PASS |
| SC-14 | 10 non-claims all true; summary JSON contains all required fields | PASS |

---

## [Agree]

- **Write scope:** Git confirms exactly 4 files changed in the implementation
  commit (`7afa09dd`): the live evaluator, the proof runner, the proof summary
  JSON, and the track doc. All four are within the C1-A authorized scope. Root
  require (`lib/igniter_lang.rb`) is absent from the diff — confirmed by both
  `git show --stat` and LRT-IF14. SC-1 and SC-2 PASS.

- **Closed surfaces:** All critical surfaces verified closed by the LRT-IF15
  10-check scan, by `$LOADED_FEATURES` assertions in LRT-IF13/LRT-IF14, and by
  the closed-surface scan table in the track doc. The summary JSON records
  `runtime_smoke_changed`, `compiler_orchestrator_changed`,
  `runtime_machine_memory_proof_changed`, `compiler_result_changed`, and
  `compilation_report_changed` all `false`. SC-3 PASS.

- **Supported kinds exactly match authorization:** `SUPPORTED_KINDS = %w[literal
  ref if_expr].freeze` is the sole definition. The `eval_expr` case statement
  handles exactly `literal`, `ref`, `if_expr`, and falls to `else` for every
  other kind. There is no `apply`, `field_access`, or `tbackend_read` branch.
  `SUPPORTED_KINDS` is exposed as a constant and the proof summary records it
  as `["literal", "ref", "if_expr"]`. SC-4 and SC-5 PASS.

- **Lazy semantics are structurally correct:** The `eval_if_expr` method exactly
  implements the R196/R197/C1-A required semantics:
  1. Fail closed if any of `condition`/`then_branch`/`else_branch` is missing;
  2. Evaluate `condition` first via `eval_expr`;
  3. Guard: `unless cond_val == true || cond_val == false` raises `ConditionNotBoolError`;
  4. Mutually exclusive `if cond_val == true` / `else` arms — `# line A` and
     `# line B` annotations are present for the structural proof scan.
  Ruby truthy/falsy coercion is completely excluded. SC-6 PASS.

- **Non-selected branch never evaluated:** The two `if`/`else` arms are
  mutually exclusive Ruby branches. The non-selected branch Hash is never
  passed to `eval_expr`. LRT-IF3 and LRT-IF4 prove this dynamically using
  `"kind" => "failing_expr_lrt"` — a kind the live evaluator raises
  `UnsupportedExpressionKindError` for when selected. The call traces in
  LRT-IF3/LRT-IF4 confirm `"failing_expr_lrt"` is absent when the branch is
  non-selected. LRT-IF12.structural_proof reads the live file at
  `REPO_ROOT/igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb`
  (not `__FILE__`) and confirms the annotated line-A/line-B arms are present.
  This is stronger than a self-referential check. SC-7 PASS.

- **Failure policies are complete and match C1-A:**
  - Non-Hash or missing `kind`: `MalformedIfExprError` (LRT-IF8.non_hash_expr_raises_malformed) ✓
  - Missing `condition`/`then_branch`/`else_branch`: `MalformedIfExprError` (LRT-IF8.missing_*) ✓
  - Non-Bool condition: `ConditionNotBoolError` (LRT-IF7, 8 sub-checks, 5 types) ✓
  - Unknown selected-path kind: `UnsupportedExpressionKindError` (LRT-IF9) ✓
  - Missing selected-path reference: `MissingReferenceError` (eval_ref implementation) ✓
  - Non-selected path unknown kind: does not fire (LRT-IF10) ✓
  SC-8 PASS.

- **NB-1 binding gate condition satisfied:** S3-R198-C2-X NB-1 (carried into
  C1-A as a binding gate condition) required confirmation that `runtime.*`
  label strings are proof-debug human-readable labels only and not a step
  toward canonizing `runtime.*` diagnostic vocabulary. The implementation
  includes `"Internal reason: runtime.if_expr_malformed"` in the
  `MalformedIfExprError` message and `"Internal reason: runtime.if_expr_condition_not_bool"`
  in the `ConditionNotBoolError` message. The prefix `"Internal reason:"` is
  present in both, making the documentation nature explicit. LRT-IF13.errors_not_oof_rt_vocabulary
  machine-asserts that messages include `"runtime."` and exclude `"OOF-RT"`.
  LRT-IF7.internal_reason_in_message separately asserts the condition-not-bool
  message. `oof_rt_codes_canonized: false`, `diagnostics_integrated: false`,
  and `public_api_exposed: false` are all present in the summary. SC-9 PASS.

- **`call_trace` is proof/debug only:** `call_trace:` is an optional keyword
  argument (default `nil`) on the public `evaluate` method. It is passed
  through to private `eval_expr` calls. The evaluator exposes no
  `dependency_receipts`, `selected_path_deps`, `touch_trace`, or
  `invalidation_hints` methods. LRT-IF12.call_trace_is_debug_not_dep_authority
  and LRT-IF12.no_dynamic_dep_tracking_in_evaluator machine-assert both
  behavioral and source-level absence of dependency tracking infrastructure.
  `rt_lrt_if12_requires_dynamic_touch_tracing: false` is present in the
  summary. SC-10 PASS.

- **LRT-IF1..LRT-IF15 all pass, 68/68 sub-checks:** The command matrix result
  records `checks_total=68`, `checks_pass=68`, `checks_fail=0`,
  `failed_checks=[]`. The proof matrix table (15 rows) shows all 15 LRT-IF
  items as PASS. Sub-check counts per item: 4+4+3+3+3+2+8+5+3+4+5+5+4+5+10=68.
  The proof summary JSON is consistent with the track doc and command matrix
  output. SC-11 PASS.

- **Command matrix complete:** All 5 required commands are recorded in the track
  doc with PASS results:
  1. `ruby -c semanticir_expression_evaluator.rb` → Syntax OK
  2. `ruby -c ...proof_v0.rb` → Syntax OK
  3. `ruby ...proof_v0.rb` → 68/68 PASS
  4. `ruby ...runtime_evaluator_proof_v0.rb` → 54/54 PASS (SHA unchanged — regression OK)
  5. `ruby ...release_harness_delta_v0.rb` → 39/39 PASS (SHA unchanged — regression OK)
  SC-12 PASS.

- **Regression proofs unchanged:** The proof-local evaluator regression SHA256
  (`62be7c1c292b...`) matches the R197-accepted summary SHA, confirming the
  proof-local evaluator experiment is untouched. The release harness delta
  regression SHA (`882f407a5265...`) and evidence label
  (`if_expr_internal_compiler_delta`, `post_alpha_compiler_only_delta`) are
  unchanged. SC-13 PASS.

- **Non-claims all true; summary JSON complete:** All 10 non-claims fields are
  `true`: no release, no public demo, no all-grammar, no Spark, no API/CLI,
  no RuntimeSmoke integration, no CompilerOrchestrator integration, no
  counterfactual audit, no dynamic dependency tracking, no root require change.
  The summary JSON contains all required top-level fields: `kind`,
  `format_version`, `card`, `track`, `authorized_by`, `status`,
  `checks_total`, `checks_pass`, `checks_fail`, `failed_checks`,
  `implementation`, `semantics`, `dependency_policy`, `error_surface`,
  `runtime_scope`, `non_claims`, `checks`, `proof_matrix_summary`,
  `call_trace_evidence`, `closed_surface_scan`. SC-14 PASS.

- The `call_trace:` architectural choice is an improvement over the proof-local
  runner's initialize-time `trace: false` pattern. The live evaluator is
  stateless: each `evaluate` call is independent, and the trace is an optional
  per-call accumulator. This is correct for a reusable internal lib class.

- The internal exception hierarchy is correctly scoped within the evaluator
  class: `Error`, `MalformedIfExprError`, `ConditionNotBoolError`,
  `UnsupportedExpressionKindError`, `MissingReferenceError` all inherit from
  `IgniterLang::SemanticIRExpressionEvaluator::Error`. LRT-IF13.error_hierarchy_is_internal
  machine-asserts the inheritance chain. None of these names are in the
  public `IgniterLang` namespace root; all are under `SemanticIRExpressionEvaluator`.

---

## [Challenge]

No blockers identified. Two non-blocking notes offered below.

---

## [Missing]

Nothing blocking is absent. The two non-blocking notes below identify minor
proof completeness observations for the acceptance record.

---

## [Sharper Question]

The Slice 1 implementation is complete and correct. The natural follow-on
question is: **what is the precise boundary for the Slice 2 proof
RuntimeMachine consumer route?** Specifically, when Slice 2 opens, what does
the LRT-IF15 regression matrix need to cover from the current proof-runtime
expression corpus (`apply`, `field_access`, `literal`, `ref`, `tbackend_read`)?
That question belongs to the Slice 2 authorization card, not to this review.

---

## [Route]

proceed — 14/14 PASS, no blockers, two non-blocking notes

---

## Non-Blocking Notes

### NB-1: LRT-IF14 sub-checks 1 and 2 are functionally identical

`LRT-IF14.root_require_not_edited` and `LRT-IF14.evaluator_not_in_root_require`
both read `igniter-lang/lib/igniter_lang.rb` and check that the string
`"semanticir_expression_evaluator"` is absent. The predicate is identical; the
file read is identical. Both will always give the same result.

This means the 5-sub-check count for LRT-IF14 includes one check that is a
direct duplicate of another. It does not affect correctness — the root require
is genuinely unchanged (confirmed independently by `git show --stat HEAD`).
It is a minor redundancy in the proof harness coverage count. Non-blocking
cosmetic note; no action required for acceptance.

### NB-2: `MissingReferenceError` has no dedicated named proof case

The `MissingReferenceError` is raised by `eval_ref` when a `ref` node's `name`
key is not found in the values hash. The error class is present in the
implementation, included in the `internal_classes` list in the summary JSON,
and verified to inherit from `Error` in LRT-IF13.error_hierarchy_is_internal.
However, the proof matrix does not include a dedicated named check (e.g.,
`LRT-IF8.missing_ref_raises_missing_reference_error`) that fires a
`MissingReferenceError` scenario and asserts the error class and message.

The implementation is correct — the code path is straightforward and the
class hierarchy is machine-verified. C4-A may carry this as an optional
coverage note for a future proof enhancement, or record it as `accepted as-is`
given the error class is verified and the implementation is trivially correct.
Non-blocking; no action required for acceptance.

---

## Compact Verdict

```text
card:              S3-R199-C3-X
input:             S3-R199-C2-I (Slice 1 live if_expr runtime evaluator)
verdict:           proceed
scope_checks:      14/14 PASS
blockers:          0
non_blocking_notes: 2
  NB-1: LRT-IF14 sub-checks 1+2 redundant (cosmetic, no correctness impact)
  NB-2: MissingReferenceError not tested in dedicated proof case (minor coverage gap, impl correct)
proof_matrix:      LRT-IF1..LRT-IF15 all PASS (68/68 sub-checks)
write_scope:       4 files, all authorized; git confirms
root_require:      unchanged (git + LRT-IF14)
lazy_semantics:    correct; condition-first, Bool guard, mutually exclusive arms
non_selected:      forbidden — proven dynamically (LRT-IF3/IF4/IF5) + structurally (LRT-IF12)
supported_kinds:   literal, ref, if_expr only; tbackend_read/apply/field_access absent
nb1_gate:          satisfied — runtime.* labels carry "Internal reason:" prefix; oof_rt_codes_canonized=false
call_trace:        debug evidence only; no dep API; rt_lrt_if12_requires_dynamic_touch_tracing=false
regression:        proof-local 54/54 SHA unchanged; delta 39/39 SHA unchanged
non_claims:        10/10 true
```

---

## Exact Recommendation for C4-A

Accept the Slice 1 live `if_expr` runtime/evaluator implementation (S3-R199-C2-I):

- Accept `IgniterLang::SemanticIRExpressionEvaluator` as a live internal
  direct-require-only evaluator. It is not integrated into root require,
  RuntimeSmoke, CompilerOrchestrator, CompilerResult, CompilationReport, or
  any public API/CLI surface.
- Accept LRT-IF1..LRT-IF15 (68/68 PASS) as sufficient proof of lazy semantics
  correctness for Slice 1.
- Accept the internal exception hierarchy
  (`Error`/`MalformedIfExprError`/`ConditionNotBoolError`/`UnsupportedExpressionKindError`/
  `MissingReferenceError`) as internal and non-canonical. The NB-1 binding gate
  condition (from S3-R198-C2-X) is met: `runtime.*` labels carry the
  `"Internal reason:"` prefix, `oof_rt_codes_canonized: false`, and
  `diagnostics_integrated: false`.
- Accept `call_trace:` as a per-call optional debug argument. It is not
  dependency authority. `rt_lrt_if12_requires_dynamic_touch_tracing: false`
  confirmed.
- Carry NB-1 (LRT-IF14 duplicate sub-checks) as a cosmetic note; no action
  required.
- Carry NB-2 (`MissingReferenceError` no dedicated proof case) as an optional
  future proof enhancement; C4-A may record `accepted as-is` given the
  implementation is trivially correct and the class hierarchy is machine-verified.
- Keep all live runtime/release/public/Spark/API/CLI surfaces closed. Root
  require, RuntimeSmoke, CompilerOrchestrator, CompilerResult, CompilationReport,
  proof RuntimeMachine, assembler/`.igapp`, parser/TypeChecker/SemanticIR,
  release harness, cache/path-sensitive tracking, and counterfactual audit all
  remain closed.
- Slice 2 (proof RuntimeMachine consumer) and Slice 3 (RuntimeSmoke consumer)
  remain gated. The NB-2 binding condition from S3-R198-C2-X for Slice 2 still
  applies: the Slice 2 LRT-IF15 regression matrix must cover the full current
  proof-runtime expression corpus including `apply` and `field_access`.
- Release lane remains paused. Public demo/stable/production/all-grammar/Spark/
  API/CLI claims remain closed.
