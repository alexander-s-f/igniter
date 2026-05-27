# Branch Conditional If Expr Semantics Proof Acceptance Decision v0

Card: S3-R188-C3-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-if-expr-semantics-proof-acceptance-decision-v0
Route: UPDATE
Status: done / accepted-proof-implementation-authorization-review-next
Date: 2026-05-27

Depends on:
- S3-R188-C1-P1
- S3-R188-C2-X

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-semantics-proof-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-semantics-proof-pressure-v0.md`
- `igniter-lang/experiments/branch_conditional_if_expr_semantics_proof_v0/out/branch_conditional_if_expr_semantics_proof_summary.json`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-next-route-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round187-status-curation-v0.md`

---

## Decision

Decision:

```text
accept proof-only if_expr semantics fixture
accept C2-X pressure verdict: proceed with non-blocking notes
accept OOF-IF1..OOF-IF4 as proof-stable future diagnostic vocabulary
accept OOF-IF5 dropped from current proof/implementation scope
accept canonical Bool representation: {"name":"Bool","params":[]}
accept direct-expression SemanticIR branch shape as the target v0 direction
open implementation-authorization review next
do not authorize implementation in this card
preserve current OOF-TY0 refusal until implementation is separately accepted
keep release lane paused
```

The proof is accepted as sufficient to open a later implementation-authorization
review. It does not itself authorize parser, TypeChecker, SemanticIR, assembler,
artifact/golden, runtime, public API/CLI, release, or Spark changes.

---

## Acceptance Basis

C1-P1 proof result:

```text
status: PASS
checks: 14/14
canonical_bool_type: {"name":"Bool","params":[]}
semanticir_shape: direct_expression_lowering_no_branch_expr_wrapper
current_refusal: OOF-TY0 Unsupported expression kind: if_expr
```

C2-X pressure verdict:

```text
verdict: proceed with non-blocking notes
checks: 14/15 PASS
blockers: none
non-blocking notes: 2
```

R187 binding gates:

| Gate | Status |
| --- | --- |
| Drop or resolve `OOF-IF5` | satisfied; dropped from proof scope |
| Pin canonical Bool representation | satisfied; `{"name":"Bool","params":[]}` |
| Choose SemanticIR branch shape | satisfied; direct expression lowering, no `branch_expr` wrapper |

The single failed pressure scope check is accepted as non-blocking for proof
acceptance, but binding for the implementation-authorization review.

---

## Accepted Proof Semantics

Accepted v0 proof semantics:

- expression-level `if` / `else` only;
- `else` required;
- condition type must match canonical `Bool`;
- then/else branch result types must match exactly;
- branches must be value-producing;
- nested `if_expr` follows the same rules;
- dependency policy is the union of condition and branch dependencies;
- current mainline compiler still refuses `if_expr` with canonical `OOF-TY0`
  until implementation is separately authorized and accepted.

Accepted proof-local future diagnostics:

| Code | Accepted proof meaning | Stability |
| --- | --- | --- |
| `OOF-IF1` | non-Bool condition | stable enough for implementation-authorization review |
| `OOF-IF2` | missing `else` in expression-level `if_expr` | stable enough for implementation-authorization review |
| `OOF-IF3` | then/else branch type mismatch | stable enough for implementation-authorization review |
| `OOF-IF4` | empty or non-value-producing branch | stable enough for implementation-authorization review |
| `OOF-IF5` | dropped from current scope | not stable, not authorized |

---

## Binding Conditions For Implementation Authorization Review

The next route may be an implementation-authorization review only. Before any
implementation card can be authorized, that review must explicitly close these
binding conditions.

### B1: Recursive SemanticIR Lowering Consistency

C2-X found a nested SemanticIR shape inconsistency:

```text
outer if_expr: condition / then_branch / else_branch
inner if_expr: cond / then / else with branch wrappers
```

Decision:

```text
Implementation-authorization review must prove or require that SemanticIR
lowering applies the accepted condition/then_branch/else_branch flat shape
recursively at all if_expr nesting levels.
```

No SemanticIR implementation may open until this recursive lowering expectation
is named in the authorization boundary and proof/regression matrix.

### B2: Stage Labeling / Key Convention Separation

C2-X found that the proof uses two shapes without explicit stage labels:

```text
TypeChecker typed representation:
  cond / then / else with branch wrappers

SemanticIR lowered representation:
  condition / then_branch / else_branch flat
```

Decision:

```text
Implementation-authorization review must document these as separate stages and
must prevent TypeChecker and SemanticIR key conventions from being conflated.
```

### B3: Empty-Branch Dependency Policy

Non-binding pressure note, promoted to an implementation-review checklist item:

```text
empty-branch rejection may keep only condition deps in proof/error evidence
because the empty branch contributes no value expression dependencies.
```

The implementation-authorization review should name this expected policy or
route it as a small proof addendum if uncertain.

### B4: `OOF-IF5` Remains Unowned

Decision:

```text
OOF-IF5 remains unowned, unimplemented, and outside v0 implementation unless a
future design card assigns a single owner and concrete trigger.
```

---

## Explicit Answers

### Is the proof-only semantics fixture accepted?

Yes.

The proof is accepted with no blockers. The nested SemanticIR concern is binding
for the next implementation-authorization review, not a blocker to proof
acceptance.

### Is `OOF-IF1..OOF-IF4` proof vocabulary stable enough for implementation authorization review?

Yes.

The vocabulary is stable enough to be used in an implementation-authorization
review. It is not yet live compiler behavior.

### Is `OOF-IF5` dropped/resolved?

Dropped.

No owner or trigger is selected. It must not appear in the v0 implementation
scope unless separately designed.

### Is canonical Bool representation accepted?

Yes.

Accepted representation:

```json
{"name":"Bool","params":[]}
```

### Is SemanticIR branch shape accepted?

Accepted with a condition.

Target v0 direction is direct-expression lowering with no `branch_expr` wrapper.
Implementation authorization must additionally require recursive consistency for
nested `if_expr` lowering.

### Does current `OOF-TY0` refusal remain accepted until implementation?

Yes.

Current behavior remains accepted:

```text
parser accepts if_expr
TypeChecker blocks with OOF-TY0 Unsupported expression kind: if_expr
release evidence keeps branch_conditional_if_expr out_of_scope
```

### May implementation authorization review open next?

Yes.

A review may open next. It must be an authorization review only and must not
itself implement code.

### Is implementation authorized now?

No.

Implementation remains closed until a separate implementation-authorization
review is accepted.

### Does release lane remain paused?

Yes.

No release execution, publish, yank, tag, signing, deployment, or public release
claim route is opened.

### Do public demo / production / all-grammar / Spark / runtime / API widening claims remain closed?

Yes.

All remain closed.

---

## Exact Next Dispatch Recommendation

```text
Card: S3-R189-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-if-expr-implementation-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R188-C3-A

Goal:
Decide whether a bounded first implementation of `if_expr` v0 may begin, using
the accepted R187 design and R188 proof-only semantics fixture.

Scope:
- Read:
  - igniter-lang/docs/tracks/branch-conditional-if-expr-semantics-proof-acceptance-decision-v0.md
  - igniter-lang/docs/tracks/branch-conditional-if-expr-semantics-proof-v0.md
  - igniter-lang/docs/discussions/branch-conditional-if-expr-semantics-proof-pressure-v0.md
  - igniter-lang/experiments/branch_conditional_if_expr_semantics_proof_v0/out/branch_conditional_if_expr_semantics_proof_summary.json
  - igniter-lang/docs/tracks/branch-conditional-if-expr-next-route-decision-v0.md
  - igniter-lang/docs/tracks/branch-conditional-if-expr-current-surface-and-evidence-survey-v0.md
  - igniter-lang/lib/igniter_lang/parser.rb
  - igniter-lang/lib/igniter_lang/typechecker.rb
  - igniter-lang/lib/igniter_lang/semanticir_emitter.rb
  - igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
- Decide:
  - authorize bounded implementation;
  - authorize only implementation prep;
  - hold pending more proof/design;
  - redirect.
- If authorizing implementation, define exact:
  - write scope;
  - TypeChecker output shape;
  - SemanticIR lowered shape and recursive lowering rule;
  - diagnostic vocabulary (`OOF-IF1..OOF-IF4`, no `OOF-IF5`);
  - proof/regression matrix;
  - artifact/golden policy;
  - release harness policy;
  - runtime/evaluator stance;
  - closed surfaces.
- Must explicitly answer:
  - whether recursive SemanticIR lowering consistency is required;
  - whether TypeChecker and SemanticIR stage key conventions are separated;
  - whether empty-branch dependency policy is accepted;
  - whether current OOF-TY0 remains until implementation lands;
  - whether runtime support is in or out of scope;
  - whether release/public demo/all-grammar claims remain closed.

Do not:
- implement code in this card;
- execute release commands;
- authorize public demo, stable, production, all-grammar, Spark, runtime,
  profile discovery/defaulting, or API/CLI widening claims.

Deliver:
- Authorization decision doc in igniter-lang/docs/tracks/ or docs/gates/
- Compact decision summary
- If authorize: exact implementation card boundary
- If hold: exact blocker list
```

Recommended companion after C1-A, if implementation is authorized:

```text
S3-R189-C2-I
Track: branch-conditional-if-expr-v0-implementation-v0
Mode: bounded implementation
```

Status curation should follow the authorization decision:

```text
S3-R189-C3-S / stage3-round189-status-curation-v0
```

---

## Closed Surfaces

Remain closed:

- implementation code;
- parser, TypeChecker, SemanticIR, assembler changes;
- `.igapp`, `.ilk`, manifest, sidecar, artifact-hash, or golden migration;
- release harness corpus mutation;
- accepted alpha/release evidence mutation;
- runtime evaluator changes;
- public API/CLI widening;
- branch/conditional support claim;
- public demo, stable, production, or all-grammar claims;
- profile finalization/discovery/defaulting;
- analyzer/tracer/visualizer implementation;
- loader/report, `CompilationReport`, `CompilerResult`, or CompatibilityReport
  widening;
- release execution, second release route, RubyGems publish, yank, tag push,
  signing, or deployment;
- Spark access, fixtures/specs/integration, public evidence, or production
  behavior;
- Ruby Framework compatibility/export claims;
- Ledger/TBackend, BiHistory, stream/OLAP, cache, signing, deployment, or
  production behavior.

---

## Compact Summary

```text
R188-C3-A accepts if_expr proof-only semantics fixture.

Accepted:
  proof PASS 14/14
  OOF-IF1..OOF-IF4 proof vocabulary
  OOF-IF5 dropped
  Bool = {"name":"Bool","params":[]}
  SemanticIR direct-expression lowering target

Binding for implementation authorization:
  recursive SemanticIR lowering consistency
  explicit TypeChecker vs SemanticIR stage labeling
  empty-branch dep policy named
  OOF-IF5 remains out

Next:
  S3-R189-C1-A implementation-authorization review may open

Still closed:
  implementation, release, runtime, Spark, public demo/production/all-grammar,
  API/CLI widening.
```
