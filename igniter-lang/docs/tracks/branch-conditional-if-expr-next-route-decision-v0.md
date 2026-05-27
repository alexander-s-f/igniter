# Branch Conditional If Expr Next Route Decision v0

Card: S3-R187-C4-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-if-expr-next-route-decision-v0
Route: UPDATE
Status: done / accepted-design-proof-only-next
Date: 2026-05-27

Depends on:
- S3-R187-C1-D
- S3-R187-C2-P1
- S3-R187-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-scope-and-semantics-design-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-current-surface-and-evidence-survey-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-design-pressure-v0.md`
- `igniter-lang/docs/tracks/post-release-hygiene-and-next-lane-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round186-status-curation-v0.md`

---

## Decision

Decision:

```text
accept branch/conditional if_expr v0 scope-and-semantics design
accept current-surface/evidence survey
accept C3-X pressure verdict: proceed with non-blocking notes
open proof-only branch-conditional-if-expr-semantics-proof-v0 next
keep implementation authorization closed
preserve current OOF-TY0 refusal until accepted implementation
keep release lane paused
```

The design is accepted as a semantic/proof boundary only. It does not authorize
parser, TypeChecker, SemanticIR, assembler, artifact, runtime, release, public
API/CLI, or Spark changes.

---

## Acceptance Basis

C1-D design status:

```text
status: done
recommended_v0: expression-level if/else only
else_required: yes
condition_type: Bool
branch_type_policy: exact match
nested_if_expr: allowed under same rules
current_refusal: OOF-TY0 Unsupported expression kind: if_expr
implementation_may_open_next: no
```

C2-P1 survey status:

```text
status: done
parser syntax: exists
AST kind: if_expr
current block: TypeChecker OOF-TY0
release evidence: branch_conditional_if_expr out_of_scope
incorrect public support claims: none found
```

C3-X pressure verdict:

```text
verdict: proceed with non-blocking notes
checks: 17/17 PASS
blockers: none
non-blocking notes: 3
```

The three C3-X notes are accepted as binding gates for the next proof-only card,
not blockers to accepting the design.

---

## Accepted v0 Scope

Accepted v0 target:

```igniter
compute result =
  if condition {
    then_expr
  } else {
    else_expr
  }
```

Accepted semantics:

- `if_expr` is expression-level only;
- `else` is required for v0;
- condition must resolve to canonical `Bool`;
- then/else branch result types must match exactly;
- each branch must have a value-producing final expression;
- nested `if_expr` is allowed only under the same v0 rules;
- dependency behavior starts conservative: union of condition and branch
  dependencies;
- current `OOF-TY0 Unsupported expression kind: if_expr` remains accepted
  pre-implementation behavior.

Deferred from v0:

- statement-level `if`;
- guard declarations;
- pattern matching;
- `else if` / multi-branch sugar;
- else-less conditionals;
- branch-local declaration/scoping semantics;
- branch-local effects;
- path-sensitive dependency pruning;
- runtime/lazy branch execution claims;
- public demo, production, stable, or all-grammar claims.

---

## Binding Proof-Only Conditions

The next proof-only route must satisfy these binding conditions before any later
implementation-authorization review can open.

### NB-1: Drop Or Resolve `OOF-IF5`

C1-D proposed `OOF-IF5` with dual ownership:

```text
Parser or TypeChecker
```

Decision:

```text
OOF-IF5 must be dropped from proof scope unless the proof card assigns one
single owner and one concrete trigger before modeling the OOF-IF vocabulary.
```

Recommended default:

```text
drop OOF-IF5 from proof scope
leave future syntax-boundary diagnostic as TBD
```

### NB-2: Pin Canonical `Bool` Representation

The proof-local `OOF-IF1` model must not hardcode an assumed Bool shape.

Decision:

```text
Before modeling OOF-IF1, the proof card must read the live TypeChecker-resolved
type representation for an accepted Bool input and record the exact comparison
shape used by the proof.
```

### NB-3: Choose SemanticIR Branch Shape

C1-D left open whether SemanticIR should lower branch blocks as wrappers or as
direct final expressions.

Decision:

```text
The proof card must choose one SemanticIR branch model and record why.
```

Recommended default:

```text
direct-expression lowering, no branch_expr wrapper, unless source evidence from
semanticir_emitter.rb shows an established analogous wrapper pattern.
```

---

## Stale Harness README

C2-P1 found a stale local README note:

```text
experiments/compiler_release_acceptance_harness_v0/README.md:32-36
```

Decision:

```text
defer cleanup unless the next proof-only card explicitly names it as a
docs-hygiene write in addition to proof-local artifacts
```

This stale note is not an incorrect support claim and is not a blocker for the
proof-only route.

---

## Explicit Answers

### Is `if_expr` v0 scope accepted?

Yes.

Accepted scope is minimal expression-level if/else only: required Bool
condition, required else, exact branch type match, value-producing branches, and
union dependencies.

### Must proof-only work open before implementation authorization?

Yes.

Proof-only semantics work must run and be accepted before any implementation
authorization review may open.

### May implementation authorization review open next?

No.

The next route is proof-only. Implementation authorization review must wait
until proof-only diagnostics, canonical Bool handling, and SemanticIR branch
shape are accepted.

### Does current `OOF-TY0` refusal remain accepted until implementation?

Yes.

Current behavior remains:

```text
parser accepts if_expr
TypeChecker refuses with OOF-TY0 Unsupported expression kind: if_expr
branch_conditional_if_expr remains out_of_scope in alpha/release evidence
```

### Does release lane remain paused?

Yes.

R185 alpha remains accepted/published/verified. R187 does not reopen release
work and does not authorize another publish, tag, yank, or release route.

### Do public demo / production / all-grammar claims remain closed?

Yes.

Branch/conditional support remains unimplemented and unclaimed. Public demo,
production, stable, and all-grammar claims remain closed.

### Does Spark remain out of Main Line scope?

Yes.

Spark remains out of this Main Line compiler/language route. No Spark access,
fixture, integration, public evidence, or production behavior is authorized.

---

## Exact Next Dispatch Recommendation

```text
Card: S3-R188-C1-P1
Agent: [Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: branch-conditional-if-expr-semantics-proof-v0
Route: UPDATE
Depends on:
- S3-R187-C4-A

Goal:
Build a proof-only semantics fixture for branch/conditional if_expr v0,
without compiler implementation, to validate the accepted design before any
implementation-authorization review.

Scope:
- Read:
  - igniter-lang/docs/tracks/branch-conditional-if-expr-next-route-decision-v0.md
  - igniter-lang/docs/tracks/branch-conditional-if-expr-scope-and-semantics-design-v0.md
  - igniter-lang/docs/tracks/branch-conditional-if-expr-current-surface-and-evidence-survey-v0.md
  - igniter-lang/docs/discussions/branch-conditional-if-expr-design-pressure-v0.md
  - igniter-lang/lib/igniter_lang/parser.rb
  - igniter-lang/lib/igniter_lang/typechecker.rb
  - igniter-lang/lib/igniter_lang/semanticir_emitter.rb
  - existing release harness summary/evidence files cited by R187
- Create proof-local artifacts under:
  - igniter-lang/experiments/branch_conditional_if_expr_semantics_proof_v0/**
  - igniter-lang/docs/tracks/branch-conditional-if-expr-semantics-proof-v0.md
- Prove:
  - parser accepts minimal if/else and produces current `if_expr` AST shape;
  - current mainline compiler still refuses `if_expr` with canonical OOF-TY0;
  - proof-local model accepts Bool condition and same branch type;
  - proof-local model rejects non-Bool condition as future OOF-IF1;
  - proof-local model rejects missing else as future OOF-IF2;
  - proof-local model rejects branch type mismatch as future OOF-IF3;
  - proof-local model rejects empty/non-value branch as future OOF-IF4;
  - OOF-IF5 is dropped from proof scope unless single owner/trigger is chosen;
  - canonical Bool representation is pinned from live TypeChecker evidence;
  - SemanticIR branch shape is chosen and justified;
  - union dependencies are modeled;
  - nested if_expr under same rules is modeled;
  - release harness remains out_of_scope before implementation;
  - closed-surface scan shows no parser/TypeChecker/SemanticIR/assembler,
    artifact/golden, release, runtime, public API/CLI, or Spark edits.
- Optional:
  - clean stale harness README HOLD note only if explicitly recorded as
    docs-hygiene in the proof track.

Do not:
- implement compiler support;
- edit parser, TypeChecker, SemanticIR, assembler, artifacts, goldens, runtime,
  release evidence, public docs, public API/CLI, or Spark code unless the
  optional README hygiene line is explicitly chosen;
- authorize implementation;
- reopen release work.

Deliver:
- Proof track in igniter-lang/docs/tracks/
- Proof-local experiment summary JSON
- Compact proof matrix
- Closed-surface scan
- Recommendation: implementation-authorization review, more proof, or hold
```

Recommended companion:

```text
Card: S3-R188-C2-X
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: branch-conditional-if-expr-semantics-proof-pressure-v0
Route: UPDATE
Depends on:
- S3-R188-C1-P1

Goal:
Pressure-review the proof-only if_expr semantics fixture and decide whether it
is sufficient to consider a later implementation-authorization review.
```

Then:

```text
S3-R188-C3-A: Portfolio decision on proof acceptance and whether an
implementation-authorization review may open later.
S3-R188-C4-S: status curation.
```

---

## Closed Surfaces

Remain closed:

- parser implementation changes;
- TypeChecker implementation changes;
- SemanticIR emitter implementation changes;
- assembler implementation changes;
- `.igapp`, `.ilk`, manifest, sidecar, artifact-hash, or golden migration;
- release harness corpus mutation beyond proof-local outputs;
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
R187-C4-A accepts if_expr v0 design.

Accepted:
  expression-level if/else only
  else required
  condition Bool
  branch type exact match
  union deps
  current OOF-TY0 remains until implementation

Next:
  proof-only branch-conditional-if-expr-semantics-proof-v0

Binding proof gates:
  drop/resolve OOF-IF5
  pin canonical Bool type representation
  choose SemanticIR branch shape

Still closed:
  implementation, parser/TypeChecker/SemanticIR/assembler edits, artifacts,
  release work, public demo/production/all-grammar claims, Spark, runtime,
  API/CLI widening.
```
