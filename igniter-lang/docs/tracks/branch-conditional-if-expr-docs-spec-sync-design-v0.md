# Branch Conditional If Expr Docs Spec Sync Design v0

Card: S3-R191-C1-D  
Agent: `[Compiler/Grammar Expert]`  
Role: `compiler-grammar-expert`  
Track: `branch-conditional-if-expr-docs-spec-sync-design-v0`  
Route: UPDATE  
Depends on: S3-R190-C3-S  
Status: done  
Date: 2026-05-27

---

## Purpose

Design the bounded docs/spec sync needed after R190 accepted expression-level
`if_expr` v0 as internal compiler support.

This card does not edit spec files, authorize implementation, authorize public
claims, reopen release work, or change runtime/evaluator status.

---

## Inputs Read

- `docs/tracks/stage3-round190-status-curation-v0.md`
- `docs/tracks/branch-conditional-if-expr-v0-implementation-acceptance-decision-v0.md`
- `docs/discussions/branch-conditional-if-expr-v0-implementation-acceptance-pressure-v0.md`
- `docs/tracks/branch-conditional-if-expr-v0-implementation-v0.md`
- `docs/tracks/branch-conditional-if-expr-semantics-proof-acceptance-decision-v0.md`
- `docs/tracks/branch-conditional-if-expr-next-route-decision-v0.md`
- `docs/spec/ch2-source-surface.md`
- `docs/spec/ch3-type-system.md`
- `docs/spec/ch5-compiler-pipeline.md`
- `docs/spec/ch6-semanticir.md`
- `docs/spec/ch7-runtime.md`
- `docs/spec/README.md`
- `docs/language-spec.md`
- `docs/README.md`
- targeted current-status and track-index claim-risk survey
- targeted live code scan of `parser.rb`, `typechecker.rb`, and
  `semanticir_emitter.rb`

---

## Current Accepted State

R190 accepted the bounded `if_expr` v0 implementation closure as internal
compiler support.

Accepted support:

- expression-level `if_expr` only;
- existing parser surface, no new parser syntax;
- TypeChecker inference in `typechecker.rb`;
- typed SemanticIR lowering in `semanticir_emitter.rb`;
- `else` required;
- condition must resolve to canonical Bool:

```json
{"name":"Bool","params":[]}
```

- then/else branch result types must exact-match;
- branches must be value-producing;
- nested `if_expr` follows the same rules;
- TypeChecker deps use union dependency policy;
- TypeChecker and SemanticIR shapes remain distinct;
- SemanticIR recursively lowers to flat `condition` / `then_branch` /
  `else_branch` shape;
- `OOF-IF1..OOF-IF4` are accepted live diagnostics;
- `OOF-IF5` remains unowned and out of v0;
- `OOF-TY0 Unsupported expression kind: if_expr` is closed/replaced;
- derivative `OOF-TY0` type-mismatch diagnostics after rejected `if_expr` are
  accepted secondary diagnostics for now.

Still closed:

- runtime/evaluator support and lazy branch execution;
- release harness mutation and accepted release evidence mutation;
- public demo, stable, production, all-grammar, or release claims;
- Spark claims, fixtures, integration, or production behavior;
- public API/CLI changes;
- parser/classifier/orchestrator/assembler/root-require changes.

---

## Spec-Lag Findings

| File | Finding | Sync need |
| --- | --- | --- |
| `docs/spec/ch2-source-surface.md` | BNF still shows `IfExpr` with optional `else`; that now conflicts with accepted v0 semantics. | Add an `if_expr` v0 subsection and change the accepted v0 grammar to required `else`, while noting the parser may emit `else: nil` only to allow `OOF-IF2`. |
| `docs/spec/ch3-type-system.md` | Typing rules do not mention expression-level `if_expr` or `OOF-IF*`. | Add typing rule and diagnostics for `OOF-IF1..OOF-IF4`; state `OOF-IF5` out/unowned and derivative `OOF-TY0` classification. |
| `docs/spec/ch5-compiler-pipeline.md` | Accepted source surfaces do not list `if_expr`; pipeline text does not name TypeChecker/SemanticIR-only support. | Add `if_expr` to internal compiler accepted surfaces with strict non-claims and stage ownership. |
| `docs/spec/ch6-semanticir.md` | SemanticIR chapter does not define the accepted `if_expr` expression-node shape. | Add `if_expr` SemanticIR expression node shape; clarify no branch wrappers and no `deps` key in lowered SemanticIR node. |
| `docs/spec/README.md` | Coverage matrix has no row for `if_expr` TypeChecker/SemanticIR proof. | Optional low-risk index row if the C3-I sync wants machine-navigation clarity. |
| `docs/language-spec.md` | Index coverage summary has no `if_expr` note. | Optional low-risk summary note only if paired with `docs/spec/README.md`. |
| `docs/README.md` | Release evidence navigation says branch/conditional `if_expr` remains out of scope. | Do not edit in C3-I by default; this is accurate for accepted release evidence, not a general language-state summary. |
| `docs/current-status.md` | R190 status already records the accepted state. | No C3-I edit needed unless Status Curator requests a follow-up. |
| `docs/tracks/README.md` | Historical release-track rows say `if_expr` excluded. | No edit; rows describe historical release evidence. |

---

## Recommended C3-I Write Scope

Recommended exact docs/spec sync boundary:

```text
igniter-lang/docs/spec/ch2-source-surface.md
igniter-lang/docs/spec/ch3-type-system.md
igniter-lang/docs/spec/ch5-compiler-pipeline.md
igniter-lang/docs/spec/ch6-semanticir.md
igniter-lang/docs/spec/README.md              optional index-only
igniter-lang/docs/language-spec.md            optional index-only
igniter-lang/docs/tracks/branch-conditional-if-expr-docs-spec-sync-v0.md
```

Do not include in C3-I by default:

```text
igniter-lang/docs/README.md
igniter-lang/docs/current-status.md
igniter-lang/docs/tracks/README.md
igniter-lang/experiments/**
igniter-lang/lib/**
release harness/evidence files
public API/CLI docs
Spark docs/fixtures
```

Reason: the necessary sync is internal language/spec correction. Public release
navigation still describes accepted release evidence, where branch/conditional
`if_expr` remains excluded.

---

## Exact Wording Boundary

### Ch2 Source Surface

Add a bounded subsection after the grammar kernel or near expression grammar:

````markdown
### Expression-Level IfExpr v0

R190 accepts expression-level `if_expr` as internal compiler support.

Accepted v0 source shape:

```igniter
compute result = if condition { then_expr } else { else_expr }
```

Accepted v0 grammar:

```text
IfExpr := "if" Expr "{" Expr "}" "else" "{" Expr "}"
```

The parser may still emit the current AST shape with `else: null` for a missing
`else` so the TypeChecker can report `OOF-IF2`. A missing `else` is not accepted
source semantics for v0.

Parsed AST shape:

```json
{ "kind": "if_expr", "cond": "...", "then": "...block...", "else": "...block..." }
```
````

Also update the BNF line from optional `else` to required `else`, or add an
explicit note immediately below it if the BNF must preserve parser-tolerant
shape.

### Ch3 Type System

Add a typing rule:

```text
Rule IF-v0:
  Γ ⊢ cond : Bool
  Γ ⊢ then_expr : T
  Γ ⊢ else_expr : T
  --------------------------------
  Γ ⊢ if cond { then_expr } else { else_expr } : T
```

Add diagnostic table:

| Code | Owner | Trigger |
| --- | --- | --- |
| `OOF-IF1` | TypeChecker | condition does not resolve to canonical Bool |
| `OOF-IF2` | TypeChecker | expression-level `if_expr` has no `else` |
| `OOF-IF3` | TypeChecker | then/else branch result types do not exact-match |
| `OOF-IF4` | TypeChecker | branch has no value-producing final expression |

Add notes:

```text
OOF-IF5 is unowned and outside v0.
OOF-TY0 Unsupported expression kind: if_expr is closed/replaced.
Derivative OOF-TY0 type-mismatch diagnostics after rejected if_expr remain
accepted secondary diagnostics for now.
```

### Ch5 Compiler Pipeline

Add `if_expr` to accepted internal compiler surfaces:

```text
Expression-level if_expr v0:
  parser shape exists;
  TypeChecker owns OOF-IF1..OOF-IF4;
  typed SemanticIR lowering exists;
  runtime/evaluator execution remains closed.
```

Add an explicit non-claim:

```text
if_expr internal compiler support is not release evidence mutation, not public
demo/stable/all-grammar support, not runtime/evaluator support, and not Spark
support.
```

### Ch6 SemanticIR

Add an expression node section:

````markdown
### `if_expr` expression node

Typed `if_expr` lowers to a flat expression node:

```json
{
  "kind": "if_expr",
  "condition": { "...": "lowered condition expression" },
  "then_branch": { "...": "lowered then final expression" },
  "else_branch": { "...": "lowered else final expression" },
  "resolved_type": { "name": "Integer", "params": [] }
}
```

SemanticIR does not use TypeChecker `then` / `else` branch wrappers and does
not include a `deps` key on the lowered `if_expr` node. Dependency union is a
TypeChecker evidence policy, not a SemanticIR node field in v0.
````

### Spec Indexes

If included, keep index wording minimal:

```text
Ch3 if_expr v0 typing: PASS by branch_conditional_if_expr_v0_implementation_proof.
Ch6 if_expr SemanticIR lowering: PASS by branch_conditional_if_expr_v0_implementation_proof.
```

Do not add public release/readiness wording to indexes.

---

## Claim-Risk Survey

Claim-risk survey result:

```text
No public support claim should open in C3-I.
```

The most visible public-ish wording is `docs/README.md`, which says accepted
release evidence still excludes branch/conditional `if_expr`. That wording is
historically accurate for the release lane and should not be rewritten by an
internal spec-sync card.

Risk to avoid:

- changing release-evidence language into a claim that the alpha/release harness
  covers `if_expr`;
- implying RuntimeMachine evaluate supports `if_expr`;
- implying branch lazy-evaluation semantics are proven;
- implying all branch/conditional grammar is supported;
- implying Spark/demo/public production readiness.

Recommended C3-I stance:

```text
Internal docs/spec sync only. Public release/docs claim update is out of scope.
```

---

## NB Hygiene Disposition

### R190 NB-1: Derivative `OOF-TY0` Proof-Summary Wording

Recommendation:

```text
defer proof-summary artifact cleanup; include the semantic distinction in Ch3
and the C3-I track doc
```

Reason:

- editing proof summary JSON or R189 proof artifacts is outside a spec-sync
  implementation boundary unless explicitly authorized;
- spec text can prevent semantic confusion by recording the accepted
  distinction;
- a later proof-hygiene card can annotate `secondary_rules` if Architect wants
  machine-readable cleanup.

### R190 NB-2: `no_spark_claim` JSON / Track-Doc Consistency

Recommendation:

```text
defer JSON/track-doc consistency cleanup; preserve Spark non-claims in the
C3-I spec-sync track
```

Reason:

- no Spark code/path was touched by R189/R190;
- JSON mutation belongs to a proof-hygiene slice, not internal spec sync;
- C3-I can keep Spark explicitly closed without editing proof outputs.

---

## Required Non-Claims For C3-I

C3-I must state:

- runtime/evaluator support remains closed;
- lazy branch execution semantics are not claimed;
- release harness and accepted release evidence are unchanged;
- public demo/stable/production/all-grammar claims remain closed;
- Spark remains closed;
- public API/CLI remains unchanged;
- parser syntax is not widened;
- classifier, orchestrator, assembler, `.igapp`, manifests, goldens, and
  artifact hashes remain unchanged;
- `OOF-IF5` remains unowned/outside v0;
- derivative `OOF-TY0` is secondary type-propagation output, not unsupported
  `if_expr`.

---

## Exact C3-I Acceptance Bar

Recommended C3-I acceptance criteria:

| Check | Expected |
| --- | --- |
| Ch2 names required-else `if_expr` v0 source shape | PASS |
| Ch2 preserves parser-tolerant `else: nil` only as diagnostic path for `OOF-IF2` | PASS |
| Ch3 records Bool/exact-branch/value-producing semantics | PASS |
| Ch3 records `OOF-IF1..OOF-IF4`, `OOF-IF5` out, derivative `OOF-TY0` distinction | PASS |
| Ch5 records TypeChecker + typed SemanticIR support only | PASS |
| Ch6 records flat SemanticIR `if_expr` node shape | PASS |
| Runtime/release/public/Spark/API non-claims are explicit | PASS |
| No `lib/`, `experiments/`, release evidence, public API/CLI, or Spark files edited | PASS |

Suggested lightweight verification:

```text
rg -n 'if_expr|OOF-IF|branch_conditional_if_expr' igniter-lang/docs/spec igniter-lang/docs/language-spec.md igniter-lang/docs/README.md
git status --short --untracked-files=all
```

No broad compiler proof run is needed for C3-I because the card is docs/spec
sync only and R190 already accepted the implementation proof.

---

## Recommendation

Recommendation:

```text
Open C3-I bounded docs/spec sync with the recommended write scope.
No blockers.
Do not include proof JSON cleanup or public release-doc updates in the first
spec-sync slice.
```
