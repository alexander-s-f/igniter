# Branch Conditional If Expr Semantics Proof v0

Card: S3-R188-C1-P1  
Agent: `[Compiler/Grammar Expert]`  
Role: `compiler-grammar-expert`  
Track: `branch-conditional-if-expr-semantics-proof-v0`  
Route: UPDATE  
Depends on: S3-R187-C4-A  
Status: done  
Date: 2026-05-27

---

## Purpose

Build a proof-only semantics fixture for branch/conditional `if_expr` v0 before
any implementation-authorization review.

This track does not implement compiler support and does not authorize parser,
TypeChecker, SemanticIR, assembler, artifact/golden, release, runtime, public
API/CLI, or Spark changes.

---

## Artifacts

Proof-local experiment:

- `igniter-lang/experiments/branch_conditional_if_expr_semantics_proof_v0/branch_conditional_if_expr_semantics_proof_v0.rb`
- `igniter-lang/experiments/branch_conditional_if_expr_semantics_proof_v0/fixtures/*.ig`
- `igniter-lang/experiments/branch_conditional_if_expr_semantics_proof_v0/out/branch_conditional_if_expr_semantics_proof_summary.json`
- `igniter-lang/experiments/branch_conditional_if_expr_semantics_proof_v0/out/current_mainline_refusal.json`
- `igniter-lang/experiments/branch_conditional_if_expr_semantics_proof_v0/out/semanticir_branch_shape_model.json`
- `igniter-lang/experiments/branch_conditional_if_expr_semantics_proof_v0/out/closed_surface_scan.json`

Fixture cases:

| Fixture | Purpose | Proof result |
| --- | --- | --- |
| `minimal_if_else.ig` | minimal valid Bool + same branch type | valid |
| `non_bool_condition.ig` | future non-Bool condition rejection | `OOF-IF1` |
| `missing_else.ig` | future missing else rejection | `OOF-IF2` |
| `branch_type_mismatch.ig` | future branch type mismatch rejection | `OOF-IF3` |
| `empty_branch.ig` | future empty/non-value branch rejection | `OOF-IF4` |
| `nested_if_expr.ig` | nested conditional under same rules | valid |

---

## Proof Summary

Result:

```text
PASS branch-conditional-if-expr-semantics-proof-v0
checks: 14/14
canonical_bool_type: {"name":"Bool","params":[]}
semanticir_shape: direct_expression_lowering_no_branch_expr_wrapper
```

Summary JSON:

```text
igniter-lang/experiments/branch_conditional_if_expr_semantics_proof_v0/out/branch_conditional_if_expr_semantics_proof_summary.json
```

---

## Binding R187 Notes

| R187 note | R188 disposition |
| --- | --- |
| Drop or resolve `OOF-IF5` | Dropped from proof scope. No owner/trigger was selected. |
| Pin canonical Bool representation | Pinned from live TypeChecker evidence as `{ "name": "Bool", "params": [] }`. |
| Choose SemanticIR branch shape | Chose direct expression lowering with no `branch_expr` wrapper. |

The stale release harness README HOLD note was not selected for cleanup in this
proof route and remains untouched.

---

## Current Compiler Boundary

The proof confirms the accepted pre-implementation compiler boundary:

| Layer | Observed behavior |
| --- | --- |
| Parser | Accepts minimal `if/else` and produces current `if_expr` AST shape. |
| TypeChecker | Blocks current mainline `if_expr` with canonical `OOF-TY0`. |
| SemanticIR | Not changed; proof models the future shape locally only. |
| Release harness | `branch_conditional_if_expr` remains `out_of_scope`. |

Canonical current refusal:

```text
typed_status: blocked
rule: OOF-TY0
message: Unsupported expression kind: if_expr
```

---

## Proof-Local Semantics Matrix

| Case | Condition | Then/else | Expected | Observed |
| --- | --- | --- | --- | --- |
| minimal valid | `Bool` | `Integer` / `Integer` | accepted | PASS |
| non-Bool condition | `Integer` | `Integer` / `Integer` | `OOF-IF1` | PASS |
| missing else | `Bool` | `Integer` / missing | `OOF-IF2` | PASS |
| branch mismatch | `Bool` | `Integer` / `String` | `OOF-IF3` | PASS |
| empty branch | `Bool` | empty / `Integer` | `OOF-IF4` | PASS |
| nested if | `Bool` outer and inner | all `Integer` | accepted | PASS |

Dependency policy is modeled conservatively as the union of condition and
branch dependencies:

```text
minimal_if_else deps: a, b, flag
nested_if_expr deps: a, b, c, flag, other
```

---

## SemanticIR Shape Model

Chosen proof-local shape:

```json
{
  "kind": "if_expr",
  "condition": { "...": "typed condition expression" },
  "then_branch": { "...": "typed final expression" },
  "else_branch": { "...": "typed final expression" },
  "resolved_type": { "name": "Integer", "params": [] },
  "deps": ["a", "b", "flag"]
}
```

Rationale:

- current `SemanticIREmitter#lower_expr` returns expression nodes directly;
- no established live `branch_expr` wrapper pattern was found;
- direct-expression lowering keeps v0 small and matches the accepted minimal
  expression-level scope;
- path-sensitive dependency lowering remains deferred.

---

## Command Matrix

| Command | Result |
| --- | --- |
| `ruby -c igniter-lang/experiments/branch_conditional_if_expr_semantics_proof_v0/branch_conditional_if_expr_semantics_proof_v0.rb` | PASS |
| `ruby igniter-lang/experiments/branch_conditional_if_expr_semantics_proof_v0/branch_conditional_if_expr_semantics_proof_v0.rb` | PASS |

Proof runner internal matrix:

| Assertion group | Result |
| --- | --- |
| targeted parser probe | PASS |
| targeted TypeChecker refusal probe | PASS |
| proof-local semantics model run | PASS |
| proof-local SemanticIR-shape model run | PASS |
| closed-surface scan | PASS |
| summary JSON generation | PASS |

---

## Closed-Surface Scan

Closed-surface proof result: PASS.

Confirmed by proof-local scan:

- parser, TypeChecker, SemanticIR, assembler, orchestrator, root require, and
  CLI files do not reference the proof track token;
- public API/CLI is not widened;
- release harness is not mutated;
- no Spark input or integration path is used;
- optional stale README hygiene was not selected.

No parser, TypeChecker, SemanticIR, assembler, artifact/golden, release,
runtime, public API/CLI, or Spark files were edited.

---

## Recommendation

Recommendation:

```text
proceed to pressure review; implementation-authorization review may be
considered after acceptance
```

Implementation remains closed until a separate authorization review names the
write scope and required regression matrix.

