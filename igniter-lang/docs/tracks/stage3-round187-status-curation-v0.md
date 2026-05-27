# Stage 3 Round 187 Status Curation v0

Card: S3-R187-C5-S
Agent: [Status Curator]
Role: status-curator
Track: stage3-round187-status-curation-v0
Route: UPDATE
Status: done
Date: 2026-05-27

Depends on:
- S3-R187-C4-A

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-scope-and-semantics-design-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-current-surface-and-evidence-survey-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-design-pressure-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-next-route-decision-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/cards/S3/S3-R187.md`

---

## R187 Outcome Table

| Card | Output | Status | Curated result |
| --- | --- | --- | --- |
| S3-R187-C1-D | `branch-conditional-if-expr-scope-and-semantics-design-v0.md` | done | Designs the v0 `if_expr` scope as expression-level, else-required, Bool-conditioned, exact-branch-type matched, and proof-only before implementation. |
| S3-R187-C2-P1 | `branch-conditional-if-expr-current-surface-and-evidence-survey-v0.md` | done | Confirms parser already emits `kind: "if_expr"` and TypeChecker currently blocks with `OOF-TY0 Unsupported expression kind: if_expr`; first-RC/alpha harness keeps branch/conditional as out of scope. |
| S3-R187-C3-X | `branch-conditional-if-expr-design-pressure-v0.md` | proceed | Pressure PASS 17/17 with no blockers; three non-blocking proof-gate notes recorded. |
| S3-R187-C4-A | `branch-conditional-if-expr-next-route-decision-v0.md` | done / accepted-design-proof-only-next | Accepts design and survey as a semantic/proof boundary, opens proof-only semantics work next, and keeps implementation authorization closed. |
| S3-R187-C5-S | `stage3-round187-status-curation-v0.md` | done | R187 status curated into the current Stage 3 map and R188 handoff. |

---

## `if_expr` Design Status

Status:

```text
accepted-design-proof-only-next
```

Accepted v0 scope:

- expression-level `if` / `else` only;
- `else` is required;
- condition must be the canonical Bool representation;
- then/else branches must have an exact type match;
- each branch must be value-producing;
- nested `if_expr` is allowed only under the same v0 rules;
- dependency surface is a union of condition, then-branch, and else-branch
  dependencies, with no path-sensitive dependency semantics.

Current pre-implementation behavior remains accepted:

```text
OOF-TY0 Unsupported expression kind: if_expr
```

The parser surface is already present, but downstream compiler implementation
is not authorized by R187.

Binding proof gates for the next route:

- drop or resolve `OOF-IF5` ownership before modeling that diagnostic;
- pin the canonical Bool representation from the live TypeChecker before
  modeling `OOF-IF1`;
- choose and record the SemanticIR branch shape, defaulting to direct
  expression lowering unless live evidence shows an analogous wrapper.

---

## Exact Next Route

Opened next route:

```text
Card: S3-R188-C1-P1
Agent: [Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: branch-conditional-if-expr-semantics-proof-v0
Route: UPDATE
Depends on:
- S3-R187-C4-A
```

Allowed next-route shape:

- proof-only semantics fixture;
- no compiler implementation;
- no parser, TypeChecker, SemanticIR, assembler, artifact, runtime, release,
  public API/CLI, Spark, production, or demo widening.

Recommended companion:

```text
S3-R188-C2-X / branch-conditional-if-expr-semantics-proof-pressure-v0
```

Then route to Architect decision and status curation only after proof and
pressure evidence land.

---

## Release Lane Status

Release lane status:

```text
paused
```

R185 remains the accepted `igniter_lang 0.1.0.alpha.1` alpha release. R187 does
not reopen release execution and does not authorize another version change,
publish, yank, tag creation, tag push, signing, deploy, or public release/demo
claim.

---

## Remaining Closed Surfaces

Remain closed:

- `if_expr` implementation authorization;
- parser, classifier, TypeChecker, SemanticIR, assembler, `.igapp`, `.ilk`,
  manifest, sidecar, artifact-hash, or golden migration changes;
- compile-refusal replacement beyond the current accepted `OOF-TY0` boundary;
- profile finalization/discovery/defaulting;
- public API/CLI widening;
- loader/report, `CompilationReport`, `CompilerResult`, or
  CompatibilityReport widening;
- analyzer/tracer/visualizer implementation or public tooling;
- Spark access, Spark fixtures/specs/integration, Spark public evidence, or
  Spark production behavior;
- release execution, RubyGems publish, gem yank, version change, tag creation,
  tag push, signing, deploy, stable/public-demo/all-grammar claims;
- runtime, Ledger/TBackend, BiHistory, stream/OLAP, cache, deployment, and
  production behavior.

---

## Current-Status Delta

Applied compact current-status update:

- R187 accepts `if_expr` v0 design/survey as design-and-proof boundary only;
- R188 next route is proof-only `branch-conditional-if-expr-semantics-proof-v0`;
- current `OOF-TY0` refusal remains accepted until separately authorized
  implementation;
- release lane remains paused and protected compiler/runtime/public surfaces
  remain closed.

No release commands or compiler/runtime code edits were run by this card.

---

## Compact Handoff

```text
R187 closes as accepted-design-proof-only-next.

Accepted:
  if_expr v0 design/survey as semantic proof boundary
  expression-level if/else only
  else required
  Bool condition
  exact branch type match
  value-producing branches
  union dependency surface

Current behavior:
  parser parses if_expr
  TypeChecker OOF-TY0 remains accepted until implementation
  branch_conditional_if_expr stays out_of_scope in release evidence

Next:
  S3-R188-C1-P1
  branch-conditional-if-expr-semantics-proof-v0
  proof-only semantics fixture

Proof gates:
  drop/resolve OOF-IF5 ownership
  pin canonical Bool representation
  choose SemanticIR branch shape

Still closed:
  implementation, parser/TypeChecker/SemanticIR/assembler changes,
  release execution, publish/yank/tag/push/sign/deploy,
  public release/demo/all-grammar claims, Spark, runtime, production.
```
