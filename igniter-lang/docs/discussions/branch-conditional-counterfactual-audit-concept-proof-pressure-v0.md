# Branch Conditional Counterfactual Audit Concept Proof Pressure v0

Card: S3-R205-C2-X  
Agent: `[Igniter-Lang External Pressure Reviewer]`  
Role: `external-pressure-reviewer`  
Mode: discussion  
Initiator: user  
Track: `branch-conditional-counterfactual-audit-concept-proof-pressure-v0`

---

## Question

Does the S3-R205-C1-I proof-local counterfactual-audit concept proof stay inside
the authorized write scope, prove BIA-1..BIA-10 completely without evaluating
any latent branch, carry required disclaimer text for assumption_refs and
assumptions-shaped metadata, use no forbidden Level 1 vocabulary, introduce no
parser/grammar/syntax mutation, leave all runtime/evaluator/RuntimeSmoke/report/
CompatibilityReport surfaces unchanged, and avoid any dependency/cache authority
or public/release/Spark/API/CLI claim?

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-concept-proof-v0.md` (C1-I track doc)
- `igniter-lang/experiments/branch_conditional_counterfactual_audit_concept_proof_v0/out/branch_conditional_counterfactual_audit_concept_proof_v0_summary.json`
- `igniter-lang/docs/tracks/stage3-round204-status-curation-v0.md` (R204 status)
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-boundary-decision-v0.md` (C4-A)
- `igniter-lang/docs/proposals/PROP-032-assumptions-block-v0.md`

---

## Scope-Check Matrix

| ID | Check | Verdict |
|----|-------|---------|
| SC-1 | Write scope limited to authorized experiment dir and track doc | PASS |
| SC-2 | BIA-1..BIA-10 all present and passing (46/46) | PASS |
| SC-3 | Every branch-intention record has `explanatory_only: true` | PASS |
| SC-4 | Every branch-intention record has all authority fields false | PASS |
| SC-5 | Latent branches have `evaluated: false` and `non_execution_guarantee: true` | PASS |
| SC-6 | No latent branch evaluated or dry-run | PASS |
| SC-7 | No forbidden Level 1 vocabulary in descriptors | PASS |
| SC-8 | Proof-local `assumption_refs` disclaimer present (NB-1 binding) | PASS |
| SC-9 | Assumptions-shaped metadata marked non-canonical (NB-2 standing policy) | PASS |
| SC-10 | No branch-level `uses assumptions` syntax introduced | PASS |
| SC-11 | No parser/grammar/source syntax mutation | PASS |
| SC-12 | No `lib/` edits | PASS |
| SC-13 | No runtime/evaluator/RuntimeSmoke/proof RuntimeMachine edits | PASS |
| SC-14 | No report/result/receipt/CompatibilityReport change | PASS |
| SC-15 | No dependency/cache authority | PASS |
| SC-16 | No public/release/Spark/API/CLI claims | PASS |

**Result: 16/16 PASS — no blockers.**

---

## Detailed Findings

### SC-1: Write Scope

Track doc confirms only three output locations written:
- `experiments/branch_conditional_counterfactual_audit_concept_proof_v0/branch_conditional_counterfactual_audit_concept_proof_v0.rb`
- `experiments/branch_conditional_counterfactual_audit_concept_proof_v0/out/`
- `docs/tracks/branch-conditional-counterfactual-audit-concept-proof-v0.md`

Authorized write scope (C4-A / R204-C5-S):
```text
igniter-lang/experiments/branch_conditional_counterfactual_audit_concept_proof_v0/**
igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-concept-proof-v0.md
```

Both outputs are within scope. JSON proof_scope confirms:
`lib_files_modified: false`, `parser_grammar_changed: false`,
`compiler_result_changed: false`, `compilation_report_changed: false`,
`compiler_orchestrator_changed: false`. No prior proof evidence mutated.

### SC-2: BIA-1..BIA-10 All Present and Passing

All 10 proof groups confirmed in JSON by name. 46/46 PASS. Sub-check counts
match C4-A matrix expectations:

| Group | Checks | Result |
|-------|-------:|--------|
| BIA-1 | 4 | PASS |
| BIA-2 | 5 | PASS |
| BIA-3 | 5 | PASS |
| BIA-4 | 6 | PASS |
| BIA-5 | 4 | PASS |
| BIA-6 | 6 | PASS |
| BIA-7 | 5 | PASS |
| BIA-8 | 4 | PASS |
| BIA-9 | 3 | PASS |
| BIA-10 | 4 | PASS |

### SC-3 / SC-4: `explanatory_only` and Authority Block on All Records

All three branch-intention descriptors in the JSON carry:
```json
{
  "explanatory_only": true,
  "authority": {
    "dependency_authority": false,
    "cache_authority": false,
    "runtime_readiness_authority": false,
    "public_claim": false
  }
}
```

This is the exact authority block required by C4-A. BIA-4 (6 sub-checks) and
BIA-8 independently verify these fields. No descriptor is missing any field.

### SC-5 / SC-6: Latent Branch Non-Execution

For all three fixtures, latent branches carry `evaluated: false` and
`non_execution_guarantee: true`:

- Fixture A (`if:risk_gate_true`): latent `else` / `ref("fallback")` → `evaluated: false`, `non_execution_guarantee: true`
- Fixture B (`if:risk_gate_false`): latent `then` / `apply(add, a, b)` → `evaluated: false`, `non_execution_guarantee: true`
- Fixture C (`if:latent_tbackend_read`): latent `else` / `tbackend_read(...)` → `evaluated: false`, `non_execution_guarantee: true`

Actual branches correctly carry `evaluated: true` and `non_execution_guarantee: false` —
the `non_execution_guarantee` field is semantically correct: false for branches
that ran, true for branches that did not.

BIA-2.evaluator_not_loaded_by_proof verifies `$LOADED_FEATURES` contains no
`semanticir_expression_evaluator`. JSON proof_scope confirms `evaluator_loaded:
false`, `runtime_smoke_loaded: false`, `compiled_program_loaded: false`. The proof
harness is documented as "pure structural Ruby — it never loads or calls the
runtime evaluator, RuntimeSmoke, CompilerOrchestrator, or any `igniter_lang`
library code." This is the strongest possible isolation: not just behavioral
absence of evaluation but load-level separation.

### SC-7: Forbidden Level 1 Vocabulary Absent

Forbidden terms per C4-A: `would_result`, `would_output`, `would_fail`,
`counterfactual result`, `latent runtime value`, `latent runtime failure`.

BIA-6.forbidden_level2_vocabulary_absent_from_all_descriptors: PASS confirms
a scan across all descriptors. Spot-checked in JSON: no `would_*` key appears
anywhere. The latent branch note reads "Latent branch: static metadata only.
Not evaluated. No runtime value, no runtime failure, no side effect." — this
wording is safe. No execution-implying vocabulary is present.

The proof correctly uses `resolved_type: { "name": "Unknown", "params": [] }` for
the `tbackend_read` latent branch (Fixture C) rather than attempting to derive a
type that would require evaluation. This is the right static fallback.

### SC-8: `assumption_refs` Disclaimer (NB-1 Binding Requirement)

The JSON proof summary carries a top-level `disclaimer` block with four fields:

```json
"disclaimer": {
  "assumption_refs_in_this_proof": "proof-local branch premise labels, not PROP-032 receipt assumption_refs and not a PROP-032 grammar extension",
  "assumptions_shaped_metadata": "non-canonical unless accepted by a future PROP or PROP-032 amendment decision",
  "branch_intention_descriptors": "proof-local / explanatory-only; not a compiler report, not a public API, not a CompatibilityReport field, and not a RuntimeSmoke output",
  "level1_boundary": "Static Branch Audit only; Level 2 counterfactual dry-run remains closed and requires a separate future gate"
}
```

This directly satisfies the C4-A binding requirement (NB-1 disposition): "The
next proof summary must distinguish proof-local branch premise labels from PROP-032
receipt `assumption_refs`." The disclaimer is present at schema level, not buried
in prose. BIA-5.assumption_refs_are_proof_local_labels: PASS confirms behavioral
verification of this label.

### SC-9: Assumptions-Shaped Metadata Non-Canonical (NB-2 Standing Policy)

`disclaimer.assumptions_shaped_metadata` reads "non-canonical unless accepted by
a future PROP or PROP-032 amendment decision." This exactly matches the C4-A
NB-2 standing non-promotion policy. The claim_policy JSON block also records:
`assumptions_shaped_metadata_equals_prop032_extension: false`.

### SC-10 / SC-11: No Branch-Level Syntax or Grammar Mutation

BIA-9 (3 sub-checks):
- `no_branch_level_uses_assumptions_in_lib`: PASS — source scan of `lib/**/*.rb`
  confirms no `"then uses assumptions"` or `"else uses assumptions"` or branch-level
  grammar addition
- `no_grammar_mutation_loaded_by_proof`: PASS — proof does not load parser/compiler
- `proof_writes_no_lib_files`: PASS — `lib_files_modified: false`

PROP-032 `uses assumptions NAME` remains contract-body only. No grammar production
is added. No parser rule is changed.

### SC-12: No `lib/` Edits

`lib_files_modified: false` in JSON. Track doc explicitly states this. BIA-9
confirms the write boundary.

### SC-13: No Runtime/Evaluator/RuntimeSmoke/Proof RuntimeMachine Edits

`evaluator_loaded: false`, `runtime_smoke_loaded: false`, `compiled_program_loaded:
false`. BIA-7.no_evaluator_loaded_by_this_proof: PASS. BIA-7 additionally cites
Slice 1 and Slice 2 structural proof strings as intact in the evaluator source
(read-only citation, no edits). The existing lazy proof evidence (RS proof: 53/53
PASS; Slice 1 evaluator proof: 68/68 PASS) is cited as unchanged.

### SC-14: No Report/Result/CompatibilityReport Change

BIA-10 (4 sub-checks):
- `compiler_result_has_no_branch_intention_key`: PASS
- `compilation_report_has_no_branch_intention_key`: PASS
- `compiler_orchestrator_has_no_branch_intention_key`: PASS
- `proof_summary_is_concept_only_not_compiler_report`: PASS

JSON confirms `compiler_result_changed: false`, `compilation_report_changed: false`,
`compiler_orchestrator_changed: false`. The concept summary lives entirely in
`experiments/.../out/`; no compiler report field is widened.

### SC-15: No Dependency/Cache Authority

All three descriptors: `dependency_authority: false`, `cache_authority: false`.
`no_dependency_cache_authority: true` in non-claims. BIA-4 verifies this for each
fixture. The `static_refs` captured by `static_refs_of(...)` are explicitly
`explanatory_only: true`; they do not alter deps, cache invalidation,
requirements, CompatibilityReport, or loader behavior.

### SC-16: No Public/Release/Spark/API/CLI Claims

13 non-claims all `true`:
`no_non_selected_branch_evaluation`, `no_runtime_failure_for_latent_branch`,
`no_counterfactual_dry_run`, `no_level2_comparison_report`,
`no_public_runtime_support`, `no_public_counterfactual_support`,
`no_grammar_parser_mutation`, `no_branch_level_uses_assumptions_syntax`,
`no_prop032_amendment_implied`, `no_report_result_receipt_change`,
`no_dependency_cache_authority`, `no_spark_api_cli_widening`,
`no_release_execution`.

BIA-8 (4 sub-checks): `no_release_commands_in_proof_script`,
`all_descriptors_have_public_claim_false`, `no_spark_integration_loaded_by_proof`,
`no_public_counterfactual_runtime_claim_in_descriptors` — all PASS.

---

## BIA-6 Constraint Compliance (NB-3 Binding)

The C4-A binding constraint: "BIA-6 must derive latent-branch structural facts
from typed/SemanticIR structure only; must not evaluate the latent branch even to
demonstrate failure."

Fixture C uses a `tbackend_read("accounts/active")` latent branch — an expression
kind that would require backend access at runtime. The proof records:

- `expr_kind: "tbackend_read"` — structural dispatch from `static_refs_of`
- `resolved_type: { "name": "Unknown", "params": [] }` — static fallback (no
  type derivable without runtime context)
- `static_refs: ["tbackend:accounts/active"]` — structural ref prefix, not a
  backend call
- `evaluated: false`, `non_execution_guarantee: true`
- No `would_fail` key, no runtime failure produced

The `static_refs_of(tbackend_read(...))` path returns `["tbackend:#{key}"]` by
structural switch, performing no I/O and no evaluation. BIA-6 (6 sub-checks)
covers this fixture specifically, including `forbidden_level2_vocabulary_absent_from_all_descriptors`
and `latent_static_refs_captured_without_execution`. Both pass. NB-3 constraint
is correctly implemented.

---

## Claim Policy Verification

Four-level claim hierarchy confirmed in JSON:

```text
explanatory_only_descriptor_equals_runtime_execution: false
branch_intention_proof_equals_public_counterfactual: false
assumptions_shaped_metadata_equals_prop032_extension: false
level1_static_audit_equals_level2_dry_run: false
```

Maximum allowed claim (from JSON):
```text
Proof-local concept evidence that if_expr branch intentions can be statically
described for actual and latent branches without evaluating latent branches,
using explanatory-only metadata and optional assumptions-shaped premise refs.
```

This claim is bounded and accurate.

---

## Optional Regressions Cited

BIA-7 cites (read-only):
- RS proof (S3-R203-C2-I): 53 checks PASS — confirms RuntimeSmoke/evaluator source unchanged
- Slice 1 evaluator proof (S3-R199-C2-I): 68 checks PASS — confirms lazy invariant intact

These are not re-run by the concept proof; they are read-only citations that
verify existing proof SHA integrity and evaluator structural invariants.

---

## Non-Blocking Notes

**NB-1 (informational — proof completeness observation):** Fixtures A, B, C all
use `literal(true)` or `literal(false)` as conditions, meaning `actual_value_source`
is always `"semanticir_static_literal"`. This is the right approach for a
hand-authored concept proof — the condition value is known statically from the
literal expression kind without runtime execution. A future Level 1 proof that
uses emitted SemanticIR from real compiler output would need to handle the case
where the condition is a `ref` or `apply` expression (not a literal), where the
actual condition value would come from a runtime execution summary rather than
static inspection. C3-A should note this as a scope expansion for a later
evidence route, not a gap in this proof.

**NB-2 (informational — assumption_refs on actual branch only):** In Fixture A,
`assumption_refs: ["risk_threshold_is_valid"]` appears on the actual (`then`)
branch only; the latent (`else`) branch has `assumption_refs: []`. This is
consistent with the C4-A intent (assumptions are optional premise refs, not
required on every branch), and the proof correctly demonstrates that both
assumption-linked and assumption-free branches are valid. C3-A should confirm
this asymmetry as intentional and acceptable.

---

## Verdict

```text
proceed — 16/16 PASS, no blockers, 2 non-blocking notes (informational)
```

The S3-R205-C1-I concept proof is correctly bounded. It is pure structural Ruby
with no runtime library loading. All three fixtures produce descriptors that
carry the required `explanatory_only: true` and authority block. Latent branches
are never evaluated. Forbidden vocabulary is absent. The required disclaimer
block satisfies NB-1 and NB-2 from R204. The tbackend_read fixture satisfies the
NB-3 binding constraint. All closed surfaces are confirmed unchanged. BIA-1..BIA-10
all pass (46/46).

---

## C3-A Recommendation

**Accept S3-R205-C1-I as proof-local Level 1 concept evidence.**

Required acceptance decisions for C3-A:

1. **Accept BIA-1..BIA-10 / 46/46 PASS** as proof-local concept evidence that
   `if_expr` branch intentions can be statically described for both actual and
   latent branches without evaluating latent branches.

2. **Accept summary SHA** as anchor:
   `sha256:0fc1b8005833478a22abc816ed3bf74364ef7b21c263ea1a57450676d81a8a9a`

3. **Accept the disclaimer block** as satisfying the C4-A NB-1 and NB-2 binding
   requirements. The proof summary schema-level disclaimer correctly distinguishes
   proof-local `assumption_refs` from PROP-032 receipt fields and marks
   assumptions-shaped metadata non-canonical.

4. **Record maximum allowed claim** as binding constraint:
   ```text
   Proof-local concept evidence that if_expr branch intentions can be statically
   described for actual and latent branches without evaluating latent branches,
   using explanatory-only metadata and optional assumptions-shaped premise refs.
   ```

5. **Record the four-level claim policy** as binding:
   ```text
   explanatory_only descriptor != runtime execution
   branch_intention proof != public counterfactual support
   assumptions_shaped_metadata != PROP-032 grammar extension
   Level 1 static audit != Level 2 counterfactual dry-run
   ```

6. **Accept NB-1 as a future scope note (informational):** The concept proof uses
   literal-valued conditions; a future evidence route using emitted SemanticIR
   from real compiler output will need to handle non-literal condition expressions
   where the actual value comes from a runtime execution summary. This is a
   natural scope expansion, not a gap in this proof.

7. **Accept NB-2 as intentional (informational):** The asymmetric placement of
   `assumption_refs` (on actual branch only in Fixture A, empty on latent branch)
   correctly demonstrates that assumption refs are optional and per-branch, not
   required uniformly.

8. **Confirm all closed surfaces remain closed:**
   - Non-selected branch evaluation: closed
   - Level 2 counterfactual dry-run: closed
   - Level 3 comparison report: closed
   - Runtime/evaluator/RuntimeSmoke/proof RuntimeMachine: unchanged
   - Parser/grammar/source syntax: unchanged
   - Branch-level `uses assumptions` syntax: not introduced
   - lib/ files: unmodified
   - CompilerOrchestrator, CompilerResult, CompilationReport: unchanged
   - Report/result/receipt/CompatibilityReport: unchanged
   - Dependency/cache authority: closed
   - Public/release/Spark/API/CLI: closed

9. **Do not promote Level 1 static branch audit to a public explanation surface**
   without a separate authorization review. The proof is proof-local only. Any
   public API, public report field, CLI option, or public counterfactual feature
   requires its own C1-A.

10. **Do not open Level 2 (counterfactual dry-run)** from this evidence. Level 2
    requires explicit separate authorization: isolation, effect-free guarantee,
    and a new gate.

---

[Agree]
- The proof is correctly bounded as pure structural Ruby with load-level isolation
  from all runtime/evaluator/library code.
- All three fixtures produce descriptors with the required authority block and
  explanatory_only marker.
- Latent branch non-execution is verified both by behavioral assertion
  (`$LOADED_FEATURES` scan) and by structural guarantee (latent branch is never
  passed to any evaluator).
- The disclaimer block satisfies all three NB dispositions from R204.
- Forbidden Level 1 vocabulary is absent from all descriptors.
- BIA-6 tbackend_read constraint is correctly implemented: structural ref prefix
  only, no backend access, `resolved_type: Unknown` as safe static fallback.
- The claim policy is enforced machine-readably in JSON booleans.

[Challenge]
- None. No blockers identified.

[Missing]
- NB-1 (future scope): literal-condition handling does not cover non-literal
  condition values from actual runtime summaries — noted for a future evidence
  expansion.
- NB-2 (informational): asymmetric assumption_refs placement is intentional
  (optional per-branch) — worth explicit C3-A confirmation.

[Sharper Question]
- After this concept proof is accepted, what is the minimum evidence package that
  would justify opening a public Level 1 static branch audit explanation surface —
  and does it require a PROP amendment, a new C1-A, or both?

[Route]
- accept — C3-A should accept S3-R205-C1-I, record the SHA anchor and claim
  policy, and confirm all closed surfaces per the recommendation above.
