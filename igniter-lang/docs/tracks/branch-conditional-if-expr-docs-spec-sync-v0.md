# Branch Conditional If Expr Docs Spec Sync v0

Card: S3-R191-C3-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: branch-conditional-if-expr-docs-spec-sync-v0
Route: UPDATE
Status: done
Date: 2026-05-27

Depends on:
- S3-R191-C1-D
- S3-R191-C2-X

---

## Purpose

Apply the bounded internal docs/spec sync for accepted expression-level `if_expr`
v0 compiler support, exactly within the C1-D/C2-X boundary.

This card does not edit compiler/runtime code, release harness, accepted release
evidence, package/release files, or public API/CLI. It does not make public
demo/stable/production/all-grammar claims and does not touch Spark/Ruby Framework.

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-docs-spec-sync-design-v0.md` (S3-R191-C1-D)
- `igniter-lang/docs/discussions/branch-conditional-if-expr-docs-spec-sync-pressure-v0.md` (S3-R191-C2-X)
- `igniter-lang/docs/tracks/stage3-round190-status-curation-v0.md` (S3-R190-C3-S — read via C1-D)
- `igniter-lang/docs/spec/ch2-source-surface.md`
- `igniter-lang/docs/spec/ch3-type-system.md`
- `igniter-lang/docs/spec/ch5-compiler-pipeline.md`
- `igniter-lang/docs/spec/ch6-semanticir.md`
- `igniter-lang/docs/spec/README.md`
- `igniter-lang/docs/language-spec.md`

---

## Authorization Basis

- C1-D status: `done` — open C3-I with recommended write scope, no blockers
- C2-X verdict: `8/8 PASS, no blockers`, 3 non-blocking notes (NB-1, NB-2, NB-3)

---

## NB Item Handling

| Note | Handling |
| --- | --- |
| NB-1: Ch2 branch grammar — clarify branches are BlockExpr, not bare Expr | Applied — v0 grammar in §2.2.3 uses `BlockExpr` reference; note in BNF inline comment reads "Branch bodies are BlockExpr-shaped" |
| NB-2: Ch2 BNF update — add note below existing line, do not rewrite tolerant parser BNF | Applied — note added as inline comment below `IfExpr` BNF line; §2.2.3 subsection provides the required-else grammar for spec purposes |
| NB-3: Ch3 derivative OOF-TY0 — add one sentence on Unknown-propagation mechanism | Applied — Ch3 §3.6 note extended with sentence explaining Unknown-propagation as secondary consequence |

---

## Changed File List

| File | Change |
| --- | --- |
| `igniter-lang/docs/spec/ch2-source-surface.md` | Added inline note below `IfExpr` BNF line (NB-2); added §2.2.3 expression-level if_expr v0 subsection (NB-1: BlockExpr branches) |
| `igniter-lang/docs/spec/ch3-type-system.md` | Added Rule IF-v0 subsection to §3.3; added if_expr diagnostics table + OOF-IF5/OOF-TY0/derivative notes to §3.6 (NB-3: Unknown-propagation sentence) |
| `igniter-lang/docs/spec/ch5-compiler-pipeline.md` | Added `if_expr` to §5.6 surface list; added §5.6.1 with stage ownership, required-else, non-claim sentence, and release evidence exclusion note; added C-12 to §5.7 |
| `igniter-lang/docs/spec/ch6-semanticir.md` | Added §6.10 Expression Nodes: `if_expr` expression node with flat SemanticIR shape, recursive lowering consistency, and non-claims |
| `igniter-lang/docs/spec/README.md` | Added 3 coverage rows (Ch2 §2.2.3, Ch3 Rule IF-v0, Ch6 §6.10); updated coverage summary with R190 internal line |
| `igniter-lang/docs/language-spec.md` | Added `R190 internal` line to coverage summary |
| `igniter-lang/docs/tracks/branch-conditional-if-expr-docs-spec-sync-v0.md` | This track doc (new) |

No other files changed.

---

## Spec-Lag Closures

| Gap | Closure |
| --- | --- |
| Ch2 BNF shows optional `else`; conflicts with accepted v0 semantics | Note added below BNF line; §2.2.3 provides required-else v0 grammar |
| Ch3 has no `if_expr` typing rule or `OOF-IF*` diagnostics | Rule IF-v0 added to §3.3; OOF-IF1..IF4 table + notes added to §3.6 |
| Ch5 accepted surfaces do not list `if_expr`; no TypeChecker/SemanticIR-only support note | `if_expr` added to §5.6 list; §5.6.1 detailed boundary added; C-12 conformance case added |
| Ch6 has no `if_expr` expression node definition | §6.10 added: flat `condition/then_branch/else_branch` shape, recursive consistency, no deps key, non-claims |

---

## Content Summary By File

### Ch2 §2.2 BNF (inline note)

```text
Added below IfExpr BNF line:
  "the parser accepts the tolerant shape above. V0 accepted semantics
   require else; a missing else produces OOF-IF2, not a parse error.
   Branch bodies are BlockExpr-shaped (Stmt* + final Expr), not bare Expr.
   See §2.2.3 for the accepted v0 source shape and required-else grammar."
```

### Ch2 §2.2.3 (new subsection)

```text
Expression-Level if_expr v0 (R190 Internal Compiler Support)
- Accepted v0 source shape: compute result = if condition { then_expr } else { else_expr }
- Accepted v0 grammar: IfExpr := "if" Expr BlockExpr "else" BlockExpr
  BlockExpr := "{" BlockBody "}"; BlockBody := Stmt* Expr
- Parsed AST shape with cond/then/else and BlockBody stmts+return_expr
- V0 accepted semantics: else required; Bool condition; exact branch type match;
  value-producing branches; nested if_expr same rules
- Non-claims: no runtime/lazy branch execution; no else-if sugar;
  no statement-level if; no API/CLI widening
```

### Ch3 §3.3 Rule IF-v0 (new)

```text
Rule IF-v0:
  Γ ⊢ cond : Bool
  Γ ⊢ then_expr : T
  Γ ⊢ else_expr : T
  Γ ⊢ if cond { then_expr } else { else_expr } : T
Note: internal compiler support only; runtime/lazy branch not claimed.
```

### Ch3 §3.6 if_expr Diagnostics (new)

```text
OOF-IF1  condition not Bool
OOF-IF2  missing else
OOF-IF3  then/else type mismatch
OOF-IF4  empty branch (no value-producing final expression)
OOF-IF5  unowned, outside v0
OOF-TY0 for if_expr: closed/replaced
Derivative OOF-TY0: secondary type-propagation (Unknown propagation); not regression
```

### Ch5 §5.6 / §5.6.1 / §5.7 C-12

```text
if_expr added to accepted surfaces list.
§5.6.1: stage ownership (TypeChecker + typed SemanticIR); else required; OOF-IF1..4;
        deps policy; SemanticIR shape reference; runtime not in scope.
Non-claim: "not release evidence mutation, not public demo/stable/all-grammar support,
            not runtime/evaluator support, not Spark support."
C-12: if_expr full positive + four negative cases.
```

### Ch6 §6.10 if_expr expression node

```text
Flat SemanticIR shape: kind=if_expr, condition, then_branch, else_branch, resolved_type.
No branch wrappers. No deps key. Recursive consistency mandatory.
Evidence: branch_conditional_if_expr_v0_implementation_proof 28/28 PASS.
Non-claims: no runtime/lazy execute; release evidence unchanged.
```

---

## Claim-Risk Scan Summary

| Risk | Result |
| --- | --- |
| Runtime/evaluator support implied | CLEAR — explicit non-claims in Ch2 §2.2.3, Ch5 §5.6.1, Ch6 §6.10 |
| Alpha release evidence scope changed | CLEAR — `docs/README.md` excluded per C1-D/C2-X; Ch5 §5.6.1 states "accepted release evidence excludes if_expr and remains unchanged" |
| Public demo/stable/production/all-grammar implied | CLEAR — non-claim sentence explicit in Ch5 §5.6.1 |
| Spark/API/CLI implied | CLEAR — no Spark content added; API/CLI non-claim in Ch2 §2.2.3 |
| if_expr included in release harness evidence | CLEAR — Ch6 §6.10 non-claims section explicit |
| `docs/README.md` rewritten | CLEAR — not edited; excluded per C1-D/C2-X |
| `docs/current-status.md` rewritten | CLEAR — not edited |
| `docs/tracks/README.md` rewritten | CLEAR — not edited |
| Any `lib/` or `experiments/` files edited | CLEAR — confirmed by `git diff` scan |
| Proof summary JSON files edited | CLEAR — not edited; NB-1/2 disposition deferred |
| OOF-IF5 opened | CLEAR — noted as "unowned and outside v0" only |
| Lazy branch execution claimed | CLEAR — explicit non-claim in Ch2 §2.2.3 and Ch6 §6.10 |

---

## C1-D Acceptance Criteria Check

| Check | Expected | Result |
| --- | --- | --- |
| Ch2 names required-else `if_expr` v0 source shape | PASS | PASS — §2.2.3 |
| Ch2 preserves parser-tolerant `else: nil` only as OOF-IF2 diagnostic path | PASS | PASS — BNF note + §2.2.3 |
| Ch3 records Bool/exact-branch/value-producing semantics | PASS | PASS — Rule IF-v0 |
| Ch3 records OOF-IF1..IF4, OOF-IF5 out, derivative OOF-TY0 distinction | PASS | PASS — §3.6 |
| Ch5 records TypeChecker + typed SemanticIR support only | PASS | PASS — §5.6.1 |
| Ch6 records flat SemanticIR `if_expr` node shape | PASS | PASS — §6.10 |
| Runtime/release/public/Spark/API non-claims are explicit | PASS | PASS — Ch2/Ch5/Ch6 |
| No `lib/`, `experiments/`, release evidence, public API/CLI, or Spark files edited | PASS | PASS — confirmed |

All 8 acceptance criteria: **PASS**.

---

## Non-Claims (Required Per C2-X)

```text
runtime/evaluator support remains closed
lazy branch execution semantics not claimed
release harness and accepted release evidence unchanged
public demo/stable/production/all-grammar claims remain closed
Spark remains closed
public API/CLI remains unchanged
parser syntax not widened (existing parser surface; no new syntax)
classifier/orchestrator/assembler unchanged
.igapp artifacts, manifest, goldens, artifact hashes unchanged
OOF-IF5 remains unowned/outside v0
derivative OOF-TY0 is secondary Unknown-propagation, not unsupported-if_expr
proof summary JSON files not edited (NB-1/2 cleanup deferred to proof-hygiene slice)
```

---

## Compact Result

```text
card:                  S3-R191-C3-I
track:                 branch-conditional-if-expr-docs-spec-sync-v0
status:                done
date:                  2026-05-27
files_edited:          6 docs/spec files + docs/language-spec.md + this track doc
c1_d_acceptance:       8/8 PASS
c2_x_nb_items:         3/3 applied (NB-1 BlockExpr precision; NB-2 note-below approach;
                        NB-3 Unknown-propagation sentence)
claim_risk_scan:       12/12 CLEAR
no_lib_changes:        true
no_experiments_changes: true
no_release_evidence_changes: true
no_public_claims_opened: true
```
