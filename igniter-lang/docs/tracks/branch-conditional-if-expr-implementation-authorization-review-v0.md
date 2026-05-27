# Branch Conditional If Expr Implementation Authorization Review v0

Card: S3-R189-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-if-expr-implementation-authorization-review-v0
Route: UPDATE
Status: done / authorized-bounded-if-expr-v0-implementation
Date: 2026-05-27

Depends on:
- S3-R188-C3-A

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-semantics-proof-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-semantics-proof-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-semantics-proof-pressure-v0.md`
- `igniter-lang/experiments/branch_conditional_if_expr_semantics_proof_v0/out/branch_conditional_if_expr_semantics_proof_summary.json`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-next-route-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-current-surface-and-evidence-survey-v0.md`
- `igniter-lang/docs/tracks/stage3-round188-status-curation-v0.md`
- `igniter-lang/lib/igniter_lang/parser.rb`
- `igniter-lang/lib/igniter_lang/typechecker.rb`
- `igniter-lang/lib/igniter_lang/semanticir_emitter.rb`
- `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb`

---

## Decision

Decision:

```text
authorize bounded first if_expr v0 implementation
authorize C2-I in this round
authorize only TypeChecker + SemanticIR emitter internal compiler slice
authorize proof-local implementation evidence
do not authorize parser changes
do not authorize compiler orchestrator changes
do not authorize runtime/evaluator support
do not authorize release harness or historical evidence mutation
do not authorize public demo/stable/production/all-grammar claims
```

R187 design and R188 proof are sufficient to begin the first implementation
slice. The authorization is deliberately narrow: implement expression-level
`if_expr` in the internal compiler pipeline only, and prove it with a local
implementation-proof matrix.

---

## Authorization Basis

Accepted R188 proof:

```text
status: PASS
checks: 14/14
canonical_bool_type: {"name":"Bool","params":[]}
semanticir_shape: direct_expression_lowering_no_branch_expr_wrapper
current_refusal: OOF-TY0 Unsupported expression kind: if_expr
```

Accepted R188 pressure disposition:

```text
verdict: proceed with non-blocking notes
scope checks: 14/15 PASS
blockers: none
binding notes:
  recursive SemanticIR lowering consistency
  TypeChecker vs SemanticIR stage/key separation
  empty-branch dependency policy naming
```

Live surface read confirms the implementation seam:

| Surface | Current state | Authorization disposition |
| --- | --- | --- |
| Parser | `parse_if_expr` already emits `kind: "if_expr"` with `cond` / `then` / `else`. | No parser change authorized. |
| TypeChecker | `infer_expr` falls through to `OOF-TY0 Unsupported expression kind: if_expr`. | Add the first live `if_expr` inference path. |
| SemanticIR emitter | Typed path currently copies expression hashes through `semantic_expr`; legacy parsed path has unsupported fallback. | Add typed `if_expr` lowering in the typed SemanticIR path only. |
| CompilerOrchestrator | Parser -> classifier -> TypeChecker -> typed emitter. | No orchestration change authorized. |

---

## Authorized Write Scope

Only these paths may be changed:

```text
igniter-lang/lib/igniter_lang/typechecker.rb
igniter-lang/lib/igniter_lang/semanticir_emitter.rb
igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/**
igniter-lang/docs/tracks/branch-conditional-if-expr-v0-implementation-v0.md
```

No other `igniter-lang/lib/**`, docs, cards, release harness, fixture, golden,
runtime, assembler, loader/report, public API, CLI, Spark, Ruby Framework, or
package/release file is authorized by this card.

---

## Required Behavior

The implementation must support only the accepted v0 expression form:

```igniter
compute chosen = if flag { a } else { b }
```

Required rules:

- expression-level `if_expr` only;
- `else` is required;
- condition must resolve to canonical Bool:

```json
{"name":"Bool","params":[]}
```

- then/else final values must exact-match resolved types;
- each branch must be value-producing;
- nested `if_expr` must follow the same rules;
- dependencies are conservative union dependencies only;
- no path-sensitive dependency pruning;
- no statement-level `if`;
- no `else if` / multi-branch sugar;
- no branch-local declaration/scoping semantics beyond existing parsed block
  final-expression reading;
- no runtime/lazy branch execution claim.

---

## TypeChecker Shape

The TypeChecker may keep the typed representation close to the current parser
shape:

```json
{
  "kind": "if_expr",
  "cond": { "...": "typed condition expression" },
  "then": {
    "kind": "branch",
    "expr": { "...": "typed final then expression" }
  },
  "else": {
    "kind": "branch",
    "expr": { "...": "typed final else expression" }
  },
  "resolved_type": { "name": "Integer", "params": [] },
  "deps": ["a", "b", "flag"]
}
```

Branch objects may use `kind: "branch"` wrappers at the TypeChecker stage.
This shape is not the SemanticIR shape.

The TypeChecker must reject:

| Code | Trigger |
| --- | --- |
| `OOF-IF1` | condition does not resolve to canonical Bool |
| `OOF-IF2` | missing `else` |
| `OOF-IF3` | then/else branch final value types do not exact-match |
| `OOF-IF4` | then or else branch has no value-producing final expression |

`OOF-IF5` is not authorized.

For supported or diagnosed `if_expr` paths, the current `OOF-TY0 Unsupported
expression kind: if_expr` should be replaced by the specific `OOF-IF*` result
or by successful typing. Other unsupported expression kinds remain owned by
`OOF-TY0`.

---

## SemanticIR Shape

The SemanticIR lowered shape must be flat and must not use a `branch_expr`
wrapper:

```json
{
  "kind": "if_expr",
  "condition": { "...": "lowered condition expression" },
  "then_branch": { "...": "lowered then expression" },
  "else_branch": { "...": "lowered else expression" },
  "resolved_type": { "name": "Integer", "params": [] }
}
```

Recursive lowering consistency is mandatory:

```text
Every nested if_expr, regardless of whether it appears in condition,
then_branch, or else_branch position, must lower to the same
condition / then_branch / else_branch SemanticIR key convention.
```

The implementation must not leak the TypeChecker `cond` / `then` / `else`
with branch-wrapper convention into SemanticIR for nested nodes.

---

## Empty-Branch Dependency Policy

Accepted policy:

```text
An empty rejected branch contributes no value-expression dependencies because
there is no final expression to scan. Error evidence may include condition deps
only for the empty-branch case.
```

Successful `if_expr` dependencies must be the union of:

- condition dependencies;
- then final-expression dependencies;
- else final-expression dependencies;
- recursively nested `if_expr` dependencies.

---

## Proof And Regression Matrix

C2-I must produce an implementation-proof runner under:

```text
igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/
```

Required proof cases:

| Case | Required result |
| --- | --- |
| positive minimal if/else compile | PASS, `if_expr` accepted |
| positive nested if/else compile | PASS, nested `if_expr` accepted |
| negative non-Bool condition | `OOF-IF1` |
| negative missing else | `OOF-IF2` |
| negative branch mismatch | `OOF-IF3` |
| negative empty/non-value branch | `OOF-IF4` |
| SemanticIR minimal shape | `condition` / `then_branch` / `else_branch` flat |
| SemanticIR nested shape | recursive flat lowering at all nesting levels |
| dependency union check | condition + branch deps union |
| closed-surface scan | no unauthorized file/surface drift |

Required command matrix:

```text
ruby -c igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/branch_conditional_if_expr_v0_implementation_proof.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/branch_conditional_if_expr_v0_implementation_proof.rb
```

The proof summary must record:

- status;
- check counts;
- fixture/case names;
- observed diagnostics;
- observed TypeChecker shape for positive cases;
- observed SemanticIR shape for positive cases;
- artifact/golden/release-harness non-mutation status;
- closed-surface scan result.

---

## Artifact / Golden Policy

Authorized:

- proof-local outputs under
  `igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/out/`;
- proof-local temporary `.ig` fixtures inside the experiment directory;
- proof-local compile outputs if the runner needs them and keeps them inside the
  experiment output tree.

Not authorized:

- mutate existing POC outputs;
- mutate accepted release evidence;
- mutate release harness corpus or summaries;
- mutate `.igapp` goldens;
- create or update `.ilk`, receipts, signatures, manifests, sidecars, or
  loader/report artifacts outside the proof output tree.

---

## Release Harness Policy

The release harness and accepted alpha/release evidence remain historical and
untouched.

The implementation proof may say:

```text
if_expr implementation proof passed locally
```

It must not say:

```text
official release evidence updated
branch_conditional_if_expr is now part of alpha release scope
public demo support is available
all grammar is supported
```

Any future release-harness delta must be separately designed and authorized
after implementation acceptance.

---

## Runtime / Evaluator Stance

Runtime/evaluator support is out of scope.

This card authorizes compile-time TypeChecker and SemanticIR support only. It
does not authorize runtime lazy branch execution, evaluator behavior, execution
engine changes, or runtime/demo claims.

---

## Closed Surfaces

Remain closed:

- parser changes;
- classifier changes;
- compiler orchestrator changes;
- assembler changes;
- root require changes;
- runtime/evaluator changes;
- public API/CLI widening;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, receipts, signing, or
  golden migration;
- release harness corpus or accepted alpha/release evidence mutation;
- release execution, second release route, RubyGems publish/yank/tag/sign/deploy;
- public demo, stable, production, all-grammar, or runtime claims;
- profile discovery/defaulting/finalization;
- analyzer/tracer/visualizer implementation or public tooling;
- loader/report, `CompilationReport`, `CompilerResult`, or CompatibilityReport
  widening;
- Spark access, fixtures, specs, integration, public evidence, or production
  behavior;
- Ruby Framework changes;
- Ledger/TBackend, BiHistory, stream/OLAP, cache, deployment, and production
  behavior.

---

## Explicit Answers

### Is recursive SemanticIR lowering consistency required?

Yes.

This is mandatory and must be proved by C2-I. Nested `if_expr` nodes must lower
to `condition` / `then_branch` / `else_branch` at every nesting level.

### Are TypeChecker and SemanticIR stage key conventions separated?

Yes.

TypeChecker may use `cond` / `then` / `else` with branch wrappers. SemanticIR
must use flat `condition` / `then_branch` / `else_branch`.

### Is empty-branch dependency policy accepted?

Yes.

An empty rejected branch contributes no value-expression deps. The empty-branch
error case may record only condition deps.

### Does current `OOF-TY0` remain until implementation lands?

Yes.

Current live behavior remains accepted until C2-I lands and is accepted:

```text
parser accepts if_expr
TypeChecker blocks with OOF-TY0 Unsupported expression kind: if_expr
```

C2-I may replace `OOF-TY0` only for supported/diagnosed `if_expr` paths.

### Is runtime support in scope?

No.

Runtime/evaluator support is closed.

### Do release / public demo / all-grammar claims remain closed?

Yes.

All release, public demo, stable, production, runtime, and all-grammar claims
remain closed.

### May C2-I run in this round?

Yes.

C2-I may run in S3-R189 under the exact boundary below.

---

## Exact C2-I Boundary

```text
Card: S3-R189-C2-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: branch-conditional-if-expr-v0-implementation-v0

Route: UPDATE
Depends on:
- S3-R189-C1-A

Goal:
Implement the bounded expression-level if_expr v0 compiler slice authorized by
S3-R189-C1-A and prove it with local implementation evidence.

Allowed write scope:
- igniter-lang/lib/igniter_lang/typechecker.rb
- igniter-lang/lib/igniter_lang/semanticir_emitter.rb
- igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/**
- igniter-lang/docs/tracks/branch-conditional-if-expr-v0-implementation-v0.md

Required behavior:
- support expression-level if_expr only;
- require else;
- condition must resolve to canonical Bool {"name":"Bool","params":[]};
- then/else final values must exact-match types;
- branch must be value-producing;
- nested if_expr follows same rules;
- dependencies are union dependencies only;
- TypeChecker typed shape may keep cond/then/else with branch wrappers;
- SemanticIR lowered shape must use condition/then_branch/else_branch flat
  recursively;
- diagnostics OOF-IF1..OOF-IF4 only;
- no OOF-IF5;
- replace OOF-TY0 only for supported/diagnosed if_expr paths.

Required proof/regression:
- positive minimal if/else compile;
- positive nested if/else compile;
- negative non-Bool condition OOF-IF1;
- negative missing else OOF-IF2;
- negative branch mismatch OOF-IF3;
- negative empty/non-value branch OOF-IF4;
- SemanticIR recursive lowering check;
- dependency union check;
- artifact/golden/release-harness non-mutation check;
- closed-surface scan.

Do not:
- change parser, classifier, orchestrator, assembler, runtime, API, CLI,
  release harness, accepted release evidence, goldens, Spark, Ruby Framework,
  package metadata, or release files;
- execute release commands;
- publish/yank/tag/push/sign/deploy;
- authorize public demo, stable, production, runtime, all-grammar, Spark, or
  API/CLI widening claims.

Deliver:
- implementation/proof doc at
  igniter-lang/docs/tracks/branch-conditional-if-expr-v0-implementation-v0.md
- proof summary JSON under
  igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/out/
- compact implementation summary
```

