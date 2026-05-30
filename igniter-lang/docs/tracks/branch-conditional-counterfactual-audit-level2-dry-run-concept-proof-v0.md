# Branch Conditional Counterfactual Audit Level 2 Dry-Run Concept Proof v0

Card: S3-R209-C2-I  
Agent: `[Implementation Agent]`  
Role: `implementation-agent`  
Track: `branch-conditional-counterfactual-audit-level2-dry-run-concept-proof-v0`  
Route: UPDATE  
Status: done  
Date: 2026-05-30

Depends on:
- S3-R209-C1-A

---

## Summary

Proof-local Level 2 counterfactual dry-run concept evidence that latent `if_expr`
branches can be explicitly evaluated inside an experiment-local isolated
projection envelope, producing `projected_value` or `projected_failure` that
carry no-authority disclaimers.

Proves L2-DRY-1..L2-DRY-15 (52 checks, all PASS).

Governing principle applied:

```text
Runtime is lazy.
Audit is aware.
Dry-run, if ever accepted, must be isolated.
```

---

## Authorized Write Scope

Written:
- `igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0.rb`
- `igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/out/` (runtime output)
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-dry-run-concept-proof-v0.md` (this file)

No `lib/**`, spec chapters, PROP-032, runtime/evaluator, RuntimeSmoke, or prior
proof evidence were modified.

---

## Proof Architecture

The harness contains a self-contained `isolated_eval` function and
`build_projection` envelope builder. No `igniter_lang` library code is loaded.

### `isolated_eval(expr, values, depth)` — Experiment-Local Dry-Run Evaluator

Pure-structural Ruby function. Isolation invariants:
- Never raises an actual exception (refusals returned as data)
- Never calls any live runtime, Ledger, TBackend, or external IO
- Never mutates any variable outside its own call stack
- Produces no side effects

**Supported kinds:** `literal`, `ref`, `apply` (pure ops), `field_access` (hash),
`if_expr` (lazy — only selected branch evaluated)

**Refused kinds (→ `projected_failure`):** `tbackend_read`, `escape`, `effect`,
`external_call`, `network`, `filesystem`, any unrecognised kind

Laziness structural invariant for `if_expr`:

```ruby
selected = cond_val ? expr["then_branch"] : expr["else_branch"]  # lazy
isolated_eval(selected, values, depth + 1)
```

### `build_projection(...)` — Projection Envelope Builder

Calls `isolated_eval` on the `latent_branch_expr` once and wraps the result in:

```json
{
  "kind":                                    "counterfactual_dry_run_projection",
  "level":                                   2,
  "source_branch_intention_ref":             "...",
  "premise_set":                             { "assumed_condition": ..., "input_snapshot_ref": "...", "assumption_refs": [] },
  "projected_branch":                        "then|else",
  "dry_run_trace":                           [...],
  "projected_value":                         42 | null,
  "projected_failure":                       null | {...},
  "projected_value_is_not_actual_output":    true,
  "projected_failure_is_not_actual_failure": true,
  "no_authority_disclaimer":                 "...",
  "isolation":                               { all false },
  "authority":                               { all false }
}
```

---

## Proof Fixtures

### Level 1 Branch-Intention Fixtures (Input — Not Modified by L2)

| Fixture | if_expr_id | Condition | Actual | Latent |
|---------|-----------|-----------|--------|--------|
| A | `if:risk_gate_true` | `literal(true)` | `then`/lit(42) | `else`/ref("fallback") |
| B | `if:risk_gate_false` | `literal(false)` | `else`/lit(99) | `then`/apply(add,a,b) |
| C | `if:nested_if_expr_latent` | `literal(false)` | `else`/lit | `then`/nested if_expr |
| D | `if:latent_tbackend_read` | `literal(true)` | `then`/lit | `else`/tbackend_read |
| E | `if:latent_escape` | `literal(true)` | `then`/lit | `else`/escape |

### Level 2 Dry-Run Projections

| Projection | Latent Expr | assumed_condition | projected_value | projected_failure |
|-----------|-------------|-------------------|-----------------|-------------------|
| A | `ref("fallback")` / snapshot `{fallback:99}` | false | 99 | — |
| B | `apply(add, ref("a"), ref("b"))` / `{a:10,b:5}` | true | 15 | — |
| B2 | `field_access({"score":77}, "score")` | true | 77 | — |
| C | nested `if_expr(lit(true), apply(add,3,4), escape("laziness_trap"))` | true | 7 | — |
| D | `tbackend_read("accounts/active")` | false | — | refused |
| E | `escape("ExternalService")` | false | — | refused |

---

## Proof Matrix

| ID | Check | Result |
|----|-------|--------|
| L2-DRY-1 | Explicit invocation only | PASS (3 sub-checks) |
| L2-DRY-2 | Level 1 branch-intention consumed as input, not replaced | PASS (4 sub-checks) |
| L2-DRY-3 | Pure latent branch produces `projected_value` | PASS (3 sub-checks) |
| L2-DRY-4 | `projected_value_is_not_actual_output: true` | PASS (1 sub-check) |
| L2-DRY-5 | Selected actual result remains unchanged | PASS (3 sub-checks) |
| L2-DRY-6 | Unsupported expression → `projected_failure`, not actual failure | PASS (3 sub-checks) |
| L2-DRY-7 | `projected_failure_is_not_actual_failure: true` | PASS (1 sub-check) |
| L2-DRY-8 | Effect/external IO refused; no side effect | PASS (3 sub-checks) |
| L2-DRY-9 | `tbackend_read` refused; no live Ledger/TBackend read | PASS (3 sub-checks) |
| L2-DRY-10 | Nested `if_expr` dry-run is lazy inside isolated projection | PASS (3 sub-checks) |
| L2-DRY-11 | `premise_set` records `assumed_condition` and input source | PASS (4 sub-checks) |
| L2-DRY-12 | Isolation block: all mutation fields false | PASS (6 sub-checks) |
| L2-DRY-13 | Authority block: all authority fields false | PASS (6 sub-checks) |
| L2-DRY-14 | Forbidden vocabulary scan passes | PASS (3 sub-checks) |
| L2-DRY-15 | Closed-surface scan | PASS (6 sub-checks) |

**Total: 52/52 PASS**

---

## Key Findings

### L2-DRY-3: Pure Branch Evaluation

- `ref("fallback")` with snapshot `{fallback:99}` → `projected_value: 99`
- `apply(add, ref("a"), ref("b"))` with `{a:10, b:5}` → `projected_value: 15`
- `field_access({"score":77}, "score")` → `projected_value: 77`

### L2-DRY-9: `tbackend_read` Refusal

`tbackend_read("accounts/active")` → `projected_failure: {refused: "tbackend_read_refused_in_dry_run", kind: "projection_refusal", note: "Dry-run refusal — not an actual runtime failure."}`

No live Ledger or TBackend read occurred.

### L2-DRY-10: Laziness Inside Isolated Projection

Nested `if_expr(lit(true), apply(add,3,4), escape("laziness_trap"))`:
- Condition=true → only `then_branch = apply(add,3,4)` evaluated → `projected_value: 7`
- `else_branch = escape("laziness_trap")` never reached
- If eager evaluation occurred, `projected_failure` would be set (escape refusal)
- `projected_failure: nil`, `projected_value: 7` — laziness proven inside dry-run

### L2-DRY-14: Forbidden Vocabulary

All 17 forbidden terms absent from projection field names and values:
`would_result`, `would_output`, `would_fail`, `counterfactual result/output/failure`,
`latent runtime value/failure/execution`, `latent branch execution`,
`simulated branch result`, `dry-run result`, `branch replay`,
`replayed branch value`, `symbolic_execution`, `causal_estimate`,
`alternate_actual_output`.

---

## Required Disclaimers (Binding per C1-A)

```text
projected_value != actual_output
projected_failure != actual_runtime_failure
dry_run_projection != public_runtime_support
Level2_proof != public_counterfactual_support

projected_value and projected_failure carry no dependency/cache/report/
runtime/public authority; they are proof-local concept evidence only.

Level 2 does not invalidate Level 1 non_execution_guarantee for the actual
runtime path.

Proof-local branch premise refs may be assumptions-shaped, but they are not
PROP-032 branch syntax and are not PROP-032 receipt assumption_refs.
```

---

## Closed Surfaces Verified

| Surface | Status |
|---------|--------|
| `lib/**` edits | Closed — no lib files loaded or modified |
| Runtime/evaluator changes | Closed — no igniter_lang code loaded |
| RuntimeSmoke changes | Closed — not loaded |
| Live non-selected branch evaluation | Closed — dry-run uses experiment-local `isolated_eval` only |
| `tbackend_read` live execution | Closed — refused; no live Ledger/TBackend read |
| Effect/escape execution | Closed — refused as `projection_refusal` |
| Compiler result/report modification | Closed — source scanned, no dry_run_projection keys |
| Spec body chapters | Closed — scanned, no L2-DRY- or counterfactual_dry_run_projection |
| PROP-032 | Closed — not touched |
| Public API/CLI | Closed |
| Release commands | Closed |
| Spark integration | Closed |

---

## Summary JSON

```text
igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/out/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0_summary.json
sha256:9463d8dc2ecce570423cf4e1385d1d40f0e4e0231b854d93a4db5fd5848ae8ba
```

---

## Command Matrix Output

```bash
ruby -c igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0.rb
# → Syntax OK

ruby igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0.rb
# → PASS branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0
# → checks_total=52 checks_pass=52 checks_fail=0
```

---

## Claim Policy (Binding)

Maximum allowed description:

```text
Proof-local Level 2 counterfactual dry-run concept evidence: latent branches
can be evaluated inside an experiment-local isolated projection envelope with
no-authority disclaimers, explicit premise_set, and full isolation block.
```

Forbidden descriptions remain closed:
- `would_result` / `would_output` / `would_fail`
- `counterfactual result/output/failure`
- `latent runtime value/failure`
- `symbolic_execution` / `causal_estimate` / `alternate_actual_output`
- public counterfactual audit support
- public runtime support
- Level 2 as live runtime feature

---

## Exact Dispatch

```text
Card: S3-R209-C2-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: branch-conditional-counterfactual-audit-level2-dry-run-concept-proof-v0
Route: UPDATE
Status: done
Depends on:
- S3-R209-C1-A
```
