# Branch Conditional If Expr Scope And Semantics Design v0

Card: S3-R187-C1-D  
Agent: `[Compiler/Grammar Expert]`  
Role: `compiler-grammar-expert`  
Track: `branch-conditional-if-expr-scope-and-semantics-design-v0`  
Route: UPDATE  
Depends on: S3-R186-C4-A  
Status: done  
Date: 2026-05-26

---

## Purpose

Design the branch/conditional `if_expr` scope, semantics, diagnostics, and
proof plan from the accepted post-RC/alpha exclusion evidence, without
implementation.

This track does not authorize parser, TypeChecker, SemanticIR, assembler,
artifact, runtime, release, or public API/CLI changes.

---

## Evidence Read

- `post-release-hygiene-and-next-lane-decision-v0.md`
- `post-release-next-compiler-language-lane-options-v0.md`
- `stage3-round186-status-curation-v0.md`
- `first-rc-branch-conditional-scope-decision-v0.md`
- `first-rc-branch-conditional-scope-disposition-v0.md`
- `compiler-release-acceptance-harness-design-v0.md`
- `docs/current-status.md`
- targeted compiler/artifact search for:
  - `if_expr`
  - `branch`
  - `conditional`
  - `unsupported expression`
  - `OOF-TY0`

Current code evidence:

- parser has `parse_if_expr` and parses keyword `if` as a primary expression;
- parsed AST shape is currently:
  `{ "kind": "if_expr", "cond": ..., "then": block, "else": block_or_nil }`;
- TypeChecker currently falls through to
  `OOF-TY0 Unsupported expression kind: if_expr`;
- SemanticIR emitter currently has generic unsupported-expression fallback;
- first-RC/alpha harness treats branch/conditional `if_expr` as out of scope,
  not HOLD, per S3-R164-C4-A / S3-R165-C1-A.

---

## Current Accepted Exclusion

Accepted alpha/release status:

```text
branch_conditional_if_expr: excluded
```

Meaning:

- first RC / alpha does not claim branch or conditional expression support;
- current `OOF-TY0 Unsupported expression kind: if_expr` is an accepted
  boundary signal before implementation;
- `if_expr` support is a post-RC language/compiler design lane;
- no implementation authority exists from the release decisions.

---

## Recommended v0 Scope

Target a minimal expression-level `if`/`else` only.

Canonical v0 source shape:

```igniter
compute result =
  if condition {
    then_expr
  } else {
    else_expr
  }
```

Accepted v0 source meaning:

- `if_expr` is an expression, not a statement;
- it produces one value;
- it may appear wherever expressions are accepted, subject to TypeChecker and
  SemanticIR support;
- each branch block must have a value-producing final expression;
- `else` is required for v0 because expression-level conditionals must have a
  total result type.

Deferred from v0:

- statement-level `if`;
- guard declarations;
- pattern matching;
- `else if` / multi-branch chains as syntax sugar;
- else-less conditionals;
- branch-local declarations with new scoping rules;
- branch-local effects;
- branch-specific fragment/capability classification;
- runtime scheduling, lazy branch evaluation proof, or production execution
  semantics.

Nested `if_expr` is allowed by semantics only if each nested expression satisfies
the same v0 rules. It is not a separate syntax feature.

---

## Semantics Matrix

| Topic | v0 decision | Deferred / rejected |
| --- | --- | --- |
| Source form | `if <Bool expr> { <expr> } else { <expr> }` | `unless`, ternary, `elsif`, pattern/case |
| Expression vs statement | Expression only | Statement-level branch blocks |
| Else requirement | Required | Else-less form |
| Condition type | Must be `Bool` | Truthiness/coercion |
| Branch result type | Then and else branch types must match exactly | Numeric widening, union types, implicit coercion |
| Branch block shape | Value-producing final expression required | Empty branch, declarations-only branch |
| Branch dependencies | Union of condition, then, and else dependencies | Path-sensitive dependency pruning |
| Nested conditionals | Allowed recursively under same rules | Separate nested-depth policy |
| Unreachable branch | No v0 diagnostic for literal conditions | Future warning/polish |
| Fragment class impact | No new fragment class or capability | Branch-local fragment precedence |
| Runtime semantics | Not opened by design | Production evaluation/lazy branch execution |

---

## Diagnostic Vocabulary

Current pre-implementation diagnostic remains:

```text
OOF-TY0 Unsupported expression kind: if_expr
owner: TypeChecker
status: current accepted refusal before implementation
```

Recommended future v0 diagnostics after implementation is authorized:

| Code | Owner | Severity | Trigger | Notes |
| --- | --- | --- | --- | --- |
| `OOF-IF1` | TypeChecker | error | condition is not `Bool` | Do not allow truthy/falsy coercion. |
| `OOF-IF2` | TypeChecker | error | missing `else` in expression-level `if_expr` | Parser currently permits nil `else`; TypeChecker should reject in v0. |
| `OOF-IF3` | TypeChecker | error | then/else branch result types do not match | Exact type match only. |
| `OOF-IF4` | TypeChecker | error | branch block has no value-producing final expression | Required because expression must produce a value. |
| `OOF-IF5` | Parser or TypeChecker | error | explicitly unsupported branch form is encountered | Reserve for future syntax boundary; do not emit unless needed. |

Diagnostic ownership:

- Parser owns malformed syntax only.
- TypeChecker owns condition type, branch result typing, missing else for
  expression semantics, and branch value requirements.
- SemanticIR should not introduce new primary type diagnostics for well-typed
  `if_expr`; it may carry defensive fallback diagnostics only for malformed
  typed input.

---

## TypeChecker Implications

Future implementation would need a dedicated `infer_if_expr` path:

1. Infer condition expression.
2. Require resolved condition type `Bool`; otherwise emit `OOF-IF1`.
3. Require an `else` block; otherwise emit `OOF-IF2`.
4. Infer final value expression for then and else blocks.
5. Require exact resolved type match; otherwise emit `OOF-IF3`.
6. Return typed expression:

```json
{
  "kind": "if_expr",
  "cond": "...typed expr...",
  "then": "...typed branch...",
  "else": "...typed branch...",
  "resolved_type": "...matched branch type...",
  "deps": ["union", "of", "all", "branch", "deps"]
}
```

V0 should avoid new branch-local symbol scope unless a proof card shows the
existing block shape already has safe scoping semantics. The minimal path is
single final expression per branch.

---

## SemanticIR Implications

Future SemanticIR should lower typed `if_expr` to an expression node inside
compute nodes, not to a new contract-level fragment or capability.

Candidate shape:

```json
{
  "kind": "if_expr",
  "condition": { "...": "typed expression" },
  "then_branch": { "...": "typed expression" },
  "else_branch": { "...": "typed expression" },
  "resolved_type": { "name": "Integer", "params": [] },
  "deps": ["condition_or_branch_deps"]
}
```

Open design detail for proof-only route:

- whether branch blocks lower as `branch_expr` wrappers or directly as final
  expressions;
- whether dependency graph records all branch dependencies or annotates them as
  conditional dependencies.

V0 recommendation:

```text
record union dependencies first; defer path-sensitive conditional dependency
metadata.
```

---

## Assembler / Artifact Implications

Assembler and `.igapp` output implications after future implementation:

- contract JSON compute nodes may contain expression kind `if_expr`;
- dependency graph should include the union of condition/branch dependencies;
- manifest fragment summary should not change solely because `if_expr` exists;
- no new `.igapp` top-level manifest section is required for v0;
- artifact hashes/goldens will change only in future authorized proof/golden
  routes that include `if_expr`;
- RuntimeSmoke may fail until the proof/runtime evaluator understands `if_expr`,
  so compiler proof and runtime proof should be separated unless runtime support
  is explicitly in scope.

No assembler/artifact change is authorized by this design card.

---

## Release Harness Implications

After future support is implemented and accepted:

- add at least one positive branch/conditional compile unit to the release
  acceptance harness corpus;
- convert `branch_conditional_if_expr` feature coverage from `out_of_scope` to
  `covered` only after acceptance;
- preserve the old first-RC/alpha non-claim as historical release evidence;
- include negative cases for non-Bool condition, missing else, and branch type
  mismatch;
- do not retroactively mutate accepted alpha evidence.

Until then:

```text
branch_conditional_if_expr remains excluded/out_of_scope in release evidence.
```

---

## Proof Matrix

Recommended proof-only route before implementation authorization:

```text
branch-conditional-if-expr-semantics-proof-v0
mode: proof-only / no compiler code edits
```

Proof-only matrix:

| Case | Expected proof result |
| --- | --- |
| Parser parses minimal `if { } else { }` source into `if_expr` AST | PASS |
| Current compiler still refuses `if_expr` with `OOF-TY0` | PASS |
| Proof-local TypeChecker model accepts Bool condition and same branch type | PASS |
| Proof-local TypeChecker model rejects non-Bool condition as future `OOF-IF1` | PASS |
| Proof-local TypeChecker model rejects missing else as future `OOF-IF2` | PASS |
| Proof-local TypeChecker model rejects branch type mismatch as future `OOF-IF3` | PASS |
| Proof-local TypeChecker model rejects empty/non-value branch as future `OOF-IF4` | PASS |
| Proof-local SemanticIR sketch preserves `if_expr` node and union deps | PASS |
| Nested `if_expr` under same rules is modeled | PASS |
| Statement/guard/pattern/multi-branch/else-less forms remain out of v0 | PASS |
| Release harness status remains out-of-scope before implementation | PASS |
| Closed surfaces scan shows no parser/TypeChecker/SemanticIR/assembler edit | PASS |

Only after this proof and pressure review should Portfolio decide whether to
open an implementation-authorization review.

---

## Explicit Answers

Should the design target a minimal v0 if/else expression only?

```text
Yes. Target expression-level if/else only. Else-less, statement-level,
guard, pattern, multi-branch, and branch-local effect semantics stay deferred.
```

Does branch/conditional support belong in parser, TypeChecker, SemanticIR,
assembler, or all of them?

```text
Parser already has a source parser for if_expr. Accepted support still requires
TypeChecker semantics, SemanticIR lowering, assembler/artifact compatibility,
and eventually runtime/proof harness handling if runtime smoke is expected.
So full support spans all compiler artifact layers, but v0 implementation
should be staged TypeChecker -> SemanticIR -> assembler/artifact proof, with
runtime handled separately unless explicitly authorized.
```

Does current `OOF-TY0 Unsupported expression kind: if_expr` remain the correct
refusal before implementation?

```text
Yes. It remains the correct current refusal and accepted alpha exclusion signal
until a later implementation route replaces it with typed if_expr semantics and
new OOF-IF diagnostics.
```

May implementation open next?

```text
No. Implementation should wait for proof-only semantics work and pressure
review. The next route should be proof-only, not implementation authorization.
```

---

## Recommended Next Route

Recommended next route:

```text
Card: S3-R187-C2-X
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: branch-conditional-if-expr-design-pressure-v0
Route: UPDATE
Depends on:
- S3-R187-C1-D
```

Then, if pressure proceeds:

```text
Card: S3-R187-C3-P1
Agent: [Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: branch-conditional-if-expr-semantics-proof-v0
Route: UPDATE
Mode: proof-only
```

Implementation authorization review should not open until the proof-only route
passes and its diagnostics/SemanticIR shape are accepted.

---

## Closed Surfaces

This card does not authorize:

- parser edits;
- TypeChecker edits;
- SemanticIR emitter edits;
- assembler edits;
- `.igapp`, `.ilk`, manifest, sidecar, artifact-hash, or golden migration;
- runtime evaluator changes;
- release harness corpus mutation;
- release execution or release docs mutation;
- public demo, stable, production, all-grammar, or branch-support claims;
- public API/CLI widening;
- loader/report, `CompilationReport`, `CompilerResult`, or CompatibilityReport
  widening;
- profile finalization/discovery/defaulting;
- analyzer/tracer/visualizer implementation;
- Spark access, fixtures/specs/integration, or public evidence;
- Ruby Framework compatibility/export claims;
- Ledger/TBackend, BiHistory, stream/OLAP, cache, signing, deployment, or
  production behavior.

---

## Compact Receipt

```text
card: S3-R187-C1-D
track: branch-conditional-if-expr-scope-and-semantics-design-v0
status: done
implementation_authorized: no
current_refusal: OOF-TY0 Unsupported expression kind: if_expr
recommended_v0: expression_level_if_else_only
else_required: yes
condition_type: Bool
branch_type_policy: exact_match
nested_if_expr: allowed_under_same_rules
unreachable_branch_diagnostic: deferred
future_diagnostics: OOF-IF1..OOF-IF5
semanticir_shape: if_expr expression node with union deps
assembler_manifest_change_required: no new top-level section for v0
release_harness_before_support: out_of_scope
next_route: pressure_review_then_proof_only_semantics_fixture
implementation_may_open_next: no
```
