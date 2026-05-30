# Branch Conditional Counterfactual Audit Concept Proof v0

Card: S3-R205-C1-I  
Agent: `[Implementation Agent]`  
Role: `implementation-agent`  
Track: `branch-conditional-counterfactual-audit-concept-proof-v0`  
Route: UPDATE  
Status: done  
Date: 2026-05-29

Depends on:
- S3-R204-C5-S

---

## Summary

Proof-local concept evidence that `if_expr` branch intentions can be statically
described for actual and latent branches without evaluating latent branches,
using explanatory-only metadata and optional assumptions-shaped premise refs.

Proves BIA-1..BIA-10 (46 checks, all PASS).

Design principle applied:

```text
Runtime is lazy.
Audit is aware.
```

---

## Authorized Write Scope

Written:
- `igniter-lang/experiments/branch_conditional_counterfactual_audit_concept_proof_v0/branch_conditional_counterfactual_audit_concept_proof_v0.rb`
- `igniter-lang/experiments/branch_conditional_counterfactual_audit_concept_proof_v0/out/` (runtime output)
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-concept-proof-v0.md` (this file)

No `lib/` files, compiler files, runtime files, evaluator files, or prior proof
evidence were modified.

---

## Proof Architecture

The harness is pure structural Ruby — it never loads or calls the runtime
evaluator, RuntimeSmoke, CompilerOrchestrator, or any `igniter_lang` library code.

### Branch-Intention Descriptor Generator

`generate_branch_intention(fixture, actual_label:, condition_observation:, ...)`:

1. Accepts a hand-authored SemanticIR-shaped `if_expr` fixture (plain hash)
2. Identifies actual vs latent branch from `actual_label` (caller-supplied)
3. Extracts expr_kind and resolved_type from fixture structure
4. Runs `static_refs_of(expr)` — a pure structural traversal (no evaluation)
5. Attaches optional `assumption_refs` (proof-local branch premise labels)
6. Returns a descriptor with `explanatory_only: true` and all authority fields false

The latent branch is **never passed to any evaluator**. The `non_execution_guarantee`
field is a structural invariant of the generator, not a runtime assertion.

### Static Ref Traversal

`static_refs_of(expr)` dispatches by `kind`:
- `literal` → `[]`
- `ref` → `[name]`
- `apply` → refs from all operands (recursive, no execution)
- `tbackend_read` → `["tbackend:#{key}"]`
- `if_expr` → refs from condition + both branches (static union, no selection)
- `field_access` → refs from object + `["field:#{field}"]`

This is structural analysis only — it never evaluates, never calls `apply`, never
performs a `tbackend_read`.

### Required Authority Block

Every branch-intention descriptor carries:

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

---

## Proof Fixtures

| Fixture | ID | Condition | Actual | Latent | Notes |
|---------|----|-----------|---------|----|-------|
| A | `if:risk_gate_true` | `literal(true)` | `then` / `literal(42)` | `else` / `ref("fallback")` | assumption_refs on actual |
| B | `if:risk_gate_false` | `literal(false)` | `else` / `literal(99)` | `then` / `apply(add, a, b)` | no assumption_refs |
| C | `if:latent_tbackend_read` | `literal(true)` | `then` / `literal(100)` | `else` / `tbackend_read(key)` | BIA-6: unsupported kind, not evaluated |

---

## Required Disclaimer (NB-1 / binding per C4-A)

```text
assumption_refs in this proof are proof-local branch premise labels,
not PROP-032 receipt assumption_refs and not a PROP-032 grammar extension.

assumptions-shaped metadata is non-canonical unless accepted by a future PROP
or PROP-032 amendment decision.

branch_intention descriptors are proof-local / explanatory-only; not a compiler
report, not a public API, not a CompatibilityReport field, and not a
RuntimeSmoke output.

Level 1 Static Branch Audit only; Level 2 counterfactual dry-run remains closed
and requires a separate future gate.
```

---

## Proof Matrix

| ID | Check | Result |
|----|-------|--------|
| BIA-1 | Actual branch identified from condition value | PASS (4 sub-checks) |
| BIA-2 | Latent branch recorded without evaluation | PASS (5 sub-checks) |
| BIA-3 | Static branch metadata extracted from SemanticIR shape | PASS (5 sub-checks) |
| BIA-4 | Static refs/deps recorded as explanatory-only | PASS (6 sub-checks) |
| BIA-5 | Assumption premise refs linked when present | PASS (4 sub-checks) |
| BIA-6 | Latent branch with would-fail/unsupported kind | PASS (6 sub-checks) |
| BIA-7 | Lazy runtime/evaluator invariant preserved | PASS (5 sub-checks) |
| BIA-8 | Public/release/Spark/API/CLI non-claims | PASS (4 sub-checks) |
| BIA-9 | Parser/grammar/source syntax unchanged | PASS (3 sub-checks) |
| BIA-10 | Report/result/CompatibilityReport unchanged | PASS (4 sub-checks) |

**Total: 46/46 PASS**

---

## Key Findings

### BIA-1: Actual Branch Identification

- Fixture A (condition=true): `actual_branch.branch_label == "then"`, `actual.evaluated == true`
- Fixture B (condition=false): `actual_branch.branch_label == "else"`, `actual.evaluated == true`
- Condition observation recorded from fixture source (`semanticir_static_literal`)

### BIA-2: Latent Branch Without Evaluation

- Fixture A: `latent.branch_label == "else"`, `evaluated == false`, `non_execution_guarantee == true`
- Fixture B: `latent.branch_label == "then"`, `evaluated == false`, `non_execution_guarantee == true`
- Evaluator not loaded: `$LOADED_FEATURES` contains no `semanticir_expression_evaluator`

### BIA-3: Static Metadata Extraction

- expr_kind and resolved_type recorded for both actual and latent branches
- Fixture B latent: `apply` kind captured; Fixture A latent: `ref` kind captured
- `intention_source == "semanticir_static"` on all three descriptors

### BIA-4: Explanatory-Only Refs

- `static_refs_of(ref("fallback"))` → `["fallback"]` (Fixture A latent)
- `static_refs_of(apply(add, ref("a"), ref("b")))` → `["a", "b"]` (Fixture B latent)
- All authority fields false; `explanatory_only: true` on all descriptors

### BIA-5: Optional Assumption Refs

- Fixture A actual branch: `assumption_refs: ["risk_threshold_is_valid"]`
- Fixture B: no assumption refs on either branch — valid; assumptions are optional
- No PROP-032 receipt or grammar extension implied

### BIA-6: Latent Unsupported Kind (tbackend_read)

- Fixture C: `latent.expr_kind == "tbackend_read"`, `evaluated == false`, `non_execution_guarantee == true`
- `static_refs_of(tbackend_read("accounts/active"))` → `["tbackend:accounts/active"]`
- No `would_fail`, `would_result`, `would_output`, `latent runtime value`, or `latent runtime failure`
- No runtime failure produced; no evaluator called

### BIA-7: Lazy Invariant Preserved (Read-Only Citation)

- Slice 1 structural proof strings intact in evaluator source:
  - `eval_expr(expr.fetch("then_branch"), values, call_trace) # line A: then_branch only`
  - `eval_expr(expr.fetch("else_branch"), values, call_trace) # line B: else_branch only`
- Slice 2 structural proof strings intact: `line A-ext`, `line B-ext`
- RS proof summary: `PASS, checks_fail: 0`
- if_expr v0 proof summary: `PASS, checks_fail: 0`
- Evaluator, RuntimeSmoke, and compiled_program not loaded by this concept proof

### BIA-8: Non-Claims

No release commands, no public counterfactual claims, no Spark integration, no public_claim=true in any descriptor.

### BIA-9: Parser/Grammar Unchanged

- No `"then uses assumptions"` or `"else uses assumptions"` in any `lib/**/*.rb`
- No compiler/grammar code loaded by proof
- Proof writes only to its own `out/` directory

### BIA-10: Report/Result/CompatibilityReport Unchanged

- `compiler_result.rb`: no `branch_intention` key
- `compilation_report.rb`: no `branch_intention` key
- `compiler_orchestrator.rb`: no `branch_intention` key
- Concept summary is in proof `out/` only; no compiler report mutation

---

## Closed Surfaces Verified

| Surface | Status |
|---------|--------|
| Non-selected branch evaluation | Closed — latent branches never passed to evaluator |
| Level 2 counterfactual dry-run | Closed — no dry-run executed |
| Level 3 comparison report | Closed |
| Runtime failure for latent branch | Closed — no `would_fail` produced |
| `lib/` edits | Closed — no lib files modified |
| Parser/grammar changes | Closed — scanned, no `uses assumptions` at branch level |
| Compiler/result/report changes | Closed — scanned, no branch_intention keys |
| RuntimeSmoke edits | Closed |
| Evaluator/compiled_program edits | Closed |
| PROP-032 amendment | Closed — assumption_refs are proof-local labels only |
| Public API/CLI | Closed |
| Release commands | Closed |

---

## Summary JSON

```text
igniter-lang/experiments/branch_conditional_counterfactual_audit_concept_proof_v0/out/branch_conditional_counterfactual_audit_concept_proof_v0_summary.json
sha256:0fc1b8005833478a22abc816ed3bf74364ef7b21c263ea1a57450676d81a8a9a
```

---

## Optional Regression Citations

| Proof | Result |
|-------|--------|
| RS proof (S3-R203-C2-I): 53 checks | PASS |
| Slice 1 evaluator proof (S3-R199-C2-I): 68 checks | PASS |

---

## Command Matrix Output

```bash
ruby -c igniter-lang/experiments/branch_conditional_counterfactual_audit_concept_proof_v0/branch_conditional_counterfactual_audit_concept_proof_v0.rb
# → Syntax OK

ruby igniter-lang/experiments/branch_conditional_counterfactual_audit_concept_proof_v0/branch_conditional_counterfactual_audit_concept_proof_v0.rb
# → PASS branch_conditional_counterfactual_audit_concept_proof_v0
# → checks_total=46 checks_pass=46 checks_fail=0

# Optional regressions:
ruby igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/branch_conditional_if_expr_runtime_smoke_consumer_v0.rb
# → PASS (53/53)
ruby igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0.rb
# → PASS (68/68)
```

---

## Claim Policy (Binding)

```text
explanatory_only descriptors != runtime execution
branch_intention proof != public counterfactual support
assumptions_shaped_metadata != PROP-032 grammar extension
Level 1 static branch audit != Level 2 counterfactual dry-run
```

Maximum allowed description:

```text
Proof-local concept evidence that if_expr branch intentions can be statically
described for actual and latent branches without evaluating latent branches,
using explanatory-only metadata and optional assumptions-shaped premise refs.
```

Forbidden descriptions remain closed:
- `counterfactual runtime support`
- `public branch audit`
- `PROP-032 branch-level assumption syntax`
- `latent branch runtime value`
- `would_fail / would_result evidence`
- `Level 2 dry-run`

---

## Exact Dispatch

```text
Card: S3-R205-C1-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: branch-conditional-counterfactual-audit-concept-proof-v0
Route: UPDATE
Status: done
Depends on:
- S3-R204-C5-S
```
