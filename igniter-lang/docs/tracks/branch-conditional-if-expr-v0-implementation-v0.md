# Branch Conditional If Expr v0 Implementation v0

Card: S3-R189-C2-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: branch-conditional-if-expr-v0-implementation-v0
Route: UPDATE
Status: done / proof-passed
Date: 2026-05-27

Depends on:
- S3-R189-C1-A

---

## Purpose

Implement the bounded expression-level `if_expr` v0 compiler slice authorized by
S3-R189-C1-A and prove it with local implementation evidence.

This card does not authorize runtime/evaluator support, parser changes,
orchestrator changes, assembler changes, public API/CLI widening, release harness
mutation, or release execution.

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-implementation-authorization-review-v0.md` (S3-R189-C1-A)
- `igniter-lang/docs/tracks/branch-conditional-if-expr-semantics-proof-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-semantics-proof-v0.md`
- `igniter-lang/experiments/branch_conditional_if_expr_semantics_proof_v0/out/branch_conditional_if_expr_semantics_proof_summary.json`
- `igniter-lang/lib/igniter_lang/typechecker.rb`
- `igniter-lang/lib/igniter_lang/semanticir_emitter.rb`
- `igniter-lang/lib/igniter_lang/parser.rb` (read-only; parser shape for `if_expr`)
- `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb` (read-only; pipeline shape)

---

## Authorization Basis

C1-A status: `authorized-bounded-if-expr-v0-implementation`

Authorized write scope:

```text
igniter-lang/lib/igniter_lang/typechecker.rb
igniter-lang/lib/igniter_lang/semanticir_emitter.rb
igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/**
igniter-lang/docs/tracks/branch-conditional-if-expr-v0-implementation-v0.md
```

---

## Implementation Summary

### Parser seam (unchanged, confirmed)

The parser already emits `if_expr` nodes:

```ruby
{ "kind" => "if_expr", "cond" => cond, "then" => then_block, "else" => else_block }
```

Where `then_block` / `else_block` are block bodies:

```ruby
{ "stmts" => [...], "return_expr" => expr_or_nil }
```

No parser changes were made or authorized.

---

### TypeChecker changes (`lib/igniter_lang/typechecker.rb`)

Added `when "if_expr"` dispatch in `infer_expr` and the `infer_if_expr` method.

**Required behavior implemented:**

| Rule | Trigger | Result |
| --- | --- | --- |
| OOF-IF2 | `else_block` is nil | OOF-IF2 + condition deps only |
| OOF-IF4 | then/else `return_expr` is nil | OOF-IF4 + condition deps only |
| OOF-IF1 | condition type not canonical Bool | OOF-IF1 (continues to infer branches) |
| OOF-IF3 | then/else resolved types don't match | OOF-IF3 + `Unknown` result type |
| — | all checks pass | accepted + `Integer` (or matched) type |

**TypeChecker shape (distinct from SemanticIR):**

```json
{
  "kind": "if_expr",
  "cond":  { "...typed condition..." },
  "then":  { "kind": "branch", "expr": { "...typed then final expr..." } },
  "else":  { "kind": "branch", "expr": { "...typed else final expr..." } },
  "resolved_type": { "name": "Integer", "params": [] },
  "deps": ["flag", "a", "b"]
}
```

**Dependency policy:**

- OOF-IF2 / OOF-IF4: condition deps only (no branch expressions to scan).
- OOF-IF1 / OOF-IF3: union of condition + both branch deps (branches still inferred).
- Successful: union of condition + then + else deps, recursively.

**OOF-TY0 replacement:**

`OOF-TY0 Unsupported expression kind: if_expr` is no longer emitted for any
`if_expr` path. Other unsupported expression kinds remain owned by `OOF-TY0`.

---

### SemanticIR Emitter changes (`lib/igniter_lang/semanticir_emitter.rb`)

Added `if_expr` special case in `semantic_expr` and the `semantic_if_expr` method.

**SemanticIR shape (flat, no branch wrapper):**

```json
{
  "kind":          "if_expr",
  "condition":     { "...lowered condition expr..." },
  "then_branch":   { "...lowered then final expr..." },
  "else_branch":   { "...lowered else final expr..." },
  "resolved_type": { "name": "Integer", "params": [] }
}
```

**Recursive lowering consistency:**

`semantic_if_expr` calls `semantic_expr` on each sub-expression. Any nested
`if_expr` in `condition`, `then_branch`, or `else_branch` position is lowered
by the same `semantic_if_expr` path at every nesting level.

The TypeChecker `cond`/`then`/`else` with `branch` wrapper convention is never
leaked into SemanticIR for nested nodes.

**Key/deps policy:**

- SemanticIR uses `condition`, `then_branch`, `else_branch` — not `cond`, `then`, `else`.
- No `deps` key in the lowered SemanticIR if_expr node.

---

## Command Matrix

| ID | Command | Status |
| --- | --- | --- |
| CM-0 | `ruby -c typechecker.rb` | PASS |
| CM-0b | `ruby -c semanticir_emitter.rb` | PASS |
| CM-1 | `ruby -c proof_script.rb` | PASS |
| CM-2 | `ruby proof_script.rb` | PASS (28/28) |

Proof script commands (per C1-A required matrix):

```bash
ruby -c igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/branch_conditional_if_expr_v0_implementation_proof.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/branch_conditional_if_expr_v0_implementation_proof.rb
```

Both verified PASS.

---

## Proof / Regression Summary

```text
status:        PASS
checks_total:  28
checks_pass:   28
checks_fail:   0
failed_checks: none
```

| Case | Check | Result |
| --- | --- | --- |
| CM-1 | positive minimal if/else — no type errors | PASS |
| CM-1 | positive minimal if/else — semantic_ir present | PASS |
| CM-1 | positive minimal if/else — typed shape (cond/branch wrappers) | PASS |
| CM-2 | positive nested if/else — no type errors | PASS |
| CM-2 | positive nested if/else — semantic_ir present | PASS |
| CM-2 | positive nested if/else — resolved type Integer | PASS |
| CM-3 | non-Bool condition — OOF-IF1 | PASS |
| CM-3 | non-Bool condition — OOF-TY0 for if_expr absent | PASS |
| CM-4 | missing else — OOF-IF2 | PASS |
| CM-5 | branch type mismatch — OOF-IF3 | PASS |
| CM-6 | empty branch — OOF-IF4 | PASS |
| CM-7 | SemanticIR minimal shape — flat condition/then_branch/else_branch | PASS |
| CM-7 | SemanticIR minimal shape — no branch wrapper | PASS |
| CM-7 | SemanticIR minimal shape — no deps key | PASS |
| CM-7 | SemanticIR minimal shape — resolved_type preserved | PASS |
| CM-8 | SemanticIR nested — outer flat keys | PASS |
| CM-8 | SemanticIR nested — inner if_expr flat keys | PASS |
| CM-8 | SemanticIR nested — inner no branch wrapper | PASS |
| CM-9 | dependency union minimal (flag + a + b) | PASS |
| CM-9 | dependency union nested (flag + other + a + b + c) | PASS |
| CM-9 | no duplicate deps | PASS |
| CM-10 | OOF-TY0 for if_expr replaced across all cases | PASS |
| CM-11 | release harness summary intact (not mutated) | PASS |
| CM-11 | smoke summary intact (not mutated) | PASS |
| CM-12 | parser not in write scope | PASS |
| CM-12 | orchestrator not in write scope | PASS |
| CM-12 | release harness not in write scope | PASS |
| CM-12 | smoke summary not in write scope | PASS |

---

## Observed TypeChecker Shape (positive minimal)

```json
{
  "kind": "if_expr",
  "has_cond": true,
  "then_kind": "branch",
  "else_kind": "branch",
  "resolved_type": { "name": "Integer", "params": [] }
}
```

Deps: `["flag", "a", "b"]`

---

## Observed SemanticIR Shape (positive minimal)

```json
{
  "kind": "if_expr",
  "has_condition": true,
  "has_then_branch": true,
  "has_else_branch": true,
  "has_cond": false,
  "has_then": false,
  "has_else": false,
  "has_deps": false,
  "resolved_type": { "name": "Integer", "params": [] }
}
```

Outer keys: `["kind", "condition", "then_branch", "else_branch", "resolved_type"]`

---

## Observed SemanticIR Shape (positive nested)

```json
{
  "semanticir_outer_keys": ["kind", "condition", "then_branch", "else_branch", "resolved_type"],
  "semanticir_inner_kind": "if_expr",
  "semanticir_inner_keys": ["kind", "condition", "then_branch", "else_branch", "resolved_type"]
}
```

Deps (typed): `["flag", "other", "a", "b", "c"]`

---

## Changed File List

| File | Change |
| --- | --- |
| `igniter-lang/lib/igniter_lang/typechecker.rb` | Added `when "if_expr"` in `infer_expr`; added `infer_if_expr` method |
| `igniter-lang/lib/igniter_lang/semanticir_emitter.rb` | Added `if_expr` special case in `semantic_expr`; added `semantic_if_expr` method |
| `igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/branch_conditional_if_expr_v0_implementation_proof.rb` | Proof runner (new) |
| `igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/out/branch_conditional_if_expr_v0_implementation_proof_summary.json` | Proof summary JSON (new) |
| `igniter-lang/docs/tracks/branch-conditional-if-expr-v0-implementation-v0.md` | This track doc (new) |

No other files changed.

---

## Closed-Surface Scan

| Surface | Status |
| --- | --- |
| parser.rb — not modified | PASS |
| classifier.rb — not modified | PASS |
| compiler_orchestrator.rb — not modified | PASS |
| assembler.rb — not modified | PASS |
| version.rb / gemspec / README / RELEASE_NOTES — not modified | PASS |
| release harness corpus / summaries — not mutated | PASS |
| accepted alpha release evidence (R183 smoke SHA) — not mutated | PASS |
| runtime / evaluator — not modified | PASS |
| public API / CLI — not widened | PASS |
| Spark — not touched | PASS |
| Authorized write scope only | PASS |

---

## Non-Claims

```text
no_runtime_evaluator_support:   true
no_parser_changes:              true
no_orchestrator_changes:        true
no_assembler_changes:           true
no_release_harness_mutation:    true
no_release_evidence_mutation:   true
no_public_api_cli_widening:     true
no_public_demo_stable_claims:   true
no_if_expr_in_release_scope:    true
if_expr_proof_local_only:       true
no_spark_claim:                 true
no_production_claim:            true
no_all_grammar_claim:           true
```

---

## Remaining Blockers

None.

---

## Acceptance Recommendation

```text
implementation proof PASS — route to acceptance review
```

All 28 required checks pass:
- Expression-level `if_expr` accepted by TypeChecker and lowered by SemanticIREmitter.
- OOF-IF1..OOF-IF4 diagnostics fire correctly for each rejection case.
- OOF-TY0 for `if_expr` replaced across all paths.
- TypeChecker shape (`cond`/`then`/`else` with branch wrappers) and SemanticIR
  shape (`condition`/`then_branch`/`else_branch` flat) are separated.
- Recursive SemanticIR lowering consistency proved for nested `if_expr`.
- Dependency union (condition + then + else) proved for minimal and nested cases.
- Release harness and accepted release evidence untouched.
- Closed-surface scan PASS.

---

## Proof Summary Path

```text
igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/out/branch_conditional_if_expr_v0_implementation_proof_summary.json
```

---

## Compact Receipt

```text
card:                   S3-R189-C2-I
track:                  branch-conditional-if-expr-v0-implementation-v0
status:                 done / proof-passed
date:                   2026-05-27
files_modified:         typechecker.rb, semanticir_emitter.rb
proof_checks:           28/28 PASS
failed_checks:          none
typechecker_shape:      cond/then/else with branch wrappers
semanticir_shape:       condition/then_branch/else_branch flat (recursive)
diagnostics:            OOF-IF1, OOF-IF2, OOF-IF3, OOF-IF4
oof_ty0_for_if_expr:    replaced (no longer emitted for if_expr paths)
runtime_support:        not in scope
release_harness:        untouched
release_evidence:       untouched
recommendation:         route to acceptance review
```
