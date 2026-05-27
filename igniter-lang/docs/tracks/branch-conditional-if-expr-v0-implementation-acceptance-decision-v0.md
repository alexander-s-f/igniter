# Branch Conditional If Expr v0 Implementation Acceptance Decision v0

Card: S3-R190-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-if-expr-v0-implementation-acceptance-decision-v0
Route: UPDATE
Status: done / accepted-implementation-closure
Date: 2026-05-27

Depends on:
- S3-R189-C2-I
- S3-R189-C3-S

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-implementation-authorization-review-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-v0-implementation-v0.md`
- `igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/out/branch_conditional_if_expr_v0_implementation_proof_summary.json`
- `igniter-lang/docs/tracks/stage3-round189-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-semantics-proof-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-semantics-proof-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-semantics-proof-pressure-v0.md`
- `igniter-lang/lib/igniter_lang/typechecker.rb`
- `igniter-lang/lib/igniter_lang/semanticir_emitter.rb`

Additional verification run by this card:

```text
ruby -c igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/branch_conditional_if_expr_v0_implementation_proof.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/branch_conditional_if_expr_v0_implementation_proof.rb
```

---

## Decision

Decision:

```text
accept bounded if_expr v0 implementation closure
accept 28/28 implementation proof matrix
accept if_expr v0 as internal compiler support
accept TypeChecker/SemanticIR stage separation
accept recursive SemanticIR flat lowering
accept OOF-IF1..OOF-IF4 live diagnostics
keep OOF-IF5 out/unowned
classify derivative OOF-TY0 entries as acceptable secondary output/type mismatch diagnostics, not unsupported-if_expr regressions
keep runtime/evaluator support closed
keep release lane paused
keep public demo/stable/production/all-grammar/Spark/API claims closed
```

The R189 implementation satisfies the R189 authorization boundary. It is now
accepted as the internal compiler foundation for expression-level `if_expr` v0.

This decision does not authorize runtime execution semantics, release evidence
mutation, public claims, or another release route.

---

## Acceptance Basis

R189 implementation proof:

```text
status: PASS
checks_total: 28
checks_pass: 28
checks_fail: 0
failed_checks: none
```

This card reran the proof commands:

| Command | Result |
| --- | --- |
| `ruby -c ...branch_conditional_if_expr_v0_implementation_proof.rb` | PASS |
| `ruby ...branch_conditional_if_expr_v0_implementation_proof.rb` | PASS, 28/28 |

Accepted changed files:

| File | Accepted change |
| --- | --- |
| `igniter-lang/lib/igniter_lang/typechecker.rb` | Adds `if_expr` inference path and `OOF-IF1..OOF-IF4` diagnostics. |
| `igniter-lang/lib/igniter_lang/semanticir_emitter.rb` | Adds typed `if_expr` SemanticIR lowering. |
| `igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/**` | Adds proof runner and summary. |
| `igniter-lang/docs/tracks/branch-conditional-if-expr-v0-implementation-v0.md` | Adds implementation proof track doc. |

No parser, classifier, compiler orchestrator, assembler, runtime, release,
public API/CLI, Spark, or package/release change is accepted by this card.

---

## Accepted Behavior

Accepted internal compiler support:

- expression-level `if_expr` only;
- `else` required;
- condition must resolve to canonical Bool:

```json
{"name":"Bool","params":[]}
```

- then/else final values must exact-match resolved types;
- branches must be value-producing;
- nested `if_expr` follows the same rules;
- dependencies are union dependencies;
- TypeChecker shape remains distinct from SemanticIR shape;
- SemanticIR lowers recursively to the accepted flat shape;
- runtime/evaluator support remains out of scope.

Accepted diagnostic vocabulary:

| Code | Accepted trigger |
| --- | --- |
| `OOF-IF1` | non-Bool condition |
| `OOF-IF2` | missing `else` |
| `OOF-IF3` | then/else branch type mismatch |
| `OOF-IF4` | empty or non-value-producing branch |

`OOF-IF5` remains unowned, unimplemented, and outside v0.

---

## TypeChecker Shape Status

Accepted TypeChecker stage shape:

```json
{
  "kind": "if_expr",
  "cond": { "...": "typed condition expression" },
  "then": {
    "kind": "branch",
    "expr": { "...": "typed then final expression" }
  },
  "else": {
    "kind": "branch",
    "expr": { "...": "typed else final expression" }
  },
  "resolved_type": { "name": "Integer", "params": [] },
  "deps": ["flag", "a", "b"]
}
```

Proof status:

```text
positive minimal: accepted, no type errors, Integer
positive nested: accepted, no type errors, Integer
deps minimal: flag + a + b
deps nested: flag + other + a + b + c
```

---

## SemanticIR Shape Status

Accepted SemanticIR stage shape:

```json
{
  "kind": "if_expr",
  "condition": { "...": "lowered condition expression" },
  "then_branch": { "...": "lowered then expression" },
  "else_branch": { "...": "lowered else expression" },
  "resolved_type": { "name": "Integer", "params": [] }
}
```

Recursive lowering is accepted.

Proof status:

```text
minimal if_expr: flat condition/then_branch/else_branch keys
nested if_expr outer: flat keys
nested if_expr inner: flat keys
branch wrappers: absent from SemanticIR
deps key: absent from lowered SemanticIR if_expr
```

The earlier R188 pressure concern about nested shape inconsistency is closed by
R189 implementation evidence.

---

## OOF-TY0 Hygiene Decision

R189 C3-S correctly flagged a review item:

```text
CM-10 says OOF-TY0 is replaced for if_expr,
but some negative case summary rule arrays include OOF-TY0.
```

Decision:

```text
accepted as secondary derivative diagnostics, not a code blocker
```

Reasoning:

- live `typechecker.rb` now dispatches `when "if_expr"` to `infer_if_expr`;
- `OOF-TY0 Unsupported expression kind: if_expr` is no longer emitted for
  `if_expr` paths;
- the proof runner explicitly checks absence of `OOF-TY0` messages containing
  `Unsupported expression kind: if_expr`;
- the remaining `OOF-TY0` entries in some negative summary rule arrays are
  derivative output/type mismatch diagnostics caused by `Unknown` result type,
  not unsupported `if_expr` diagnostics.

Accepted distinction:

| Diagnostic form | Status |
| --- | --- |
| `OOF-TY0 Unsupported expression kind: if_expr` | closed / replaced |
| `OOF-TY0 Type mismatch: expected ..., got Unknown` after rejected `if_expr` | acceptable secondary diagnostic for now |

Non-blocking note for C2-X:

```text
Pressure review should verify this classification and may recommend later
proof-summary wording hygiene so future readers do not misread derivative
OOF-TY0 as an unsupported-if_expr regression.
```

No code cleanup is required by C1-A.

---

## Release And Evidence Status

Accepted:

- release harness not mutated;
- accepted alpha/release evidence not mutated;
- package smoke summaries not mutated;
- historical `branch_conditional_if_expr` release exclusion remains historical
  and untouched.

Not authorized:

- release harness corpus update;
- accepted release evidence mutation;
- public release/demo wording update;
- second release route;
- RubyGems publish/yank/tag/sign/deploy.

Any future harness delta or public wording update must be separately designed
after this acceptance round is fully curated.

---

## Closed Surfaces

Remain closed:

- parser changes;
- classifier changes;
- compiler orchestrator changes;
- assembler changes;
- root require changes;
- runtime/evaluator support and lazy branch execution;
- `.igapp`, `.ilk`, manifest, sidecar, artifact-hash, receipts, signatures, or
  golden migration;
- release harness corpus mutation and accepted alpha/release evidence mutation;
- public API/CLI widening;
- public demo, stable, production, runtime, or all-grammar claims;
- profile finalization/discovery/defaulting;
- analyzer/tracer/visualizer implementation or public tooling;
- loader/report, `CompilationReport`, `CompilerResult`, or CompatibilityReport
  widening;
- release execution, second release route, RubyGems publish, yank, tag push,
  signing, or deployment;
- Spark access, fixtures/specs/integration, public evidence, or production
  behavior;
- Ruby Framework changes;
- Ledger/TBackend, BiHistory, stream/OLAP, cache, deployment, and production
  behavior.

---

## Explicit Answers

### Is the 28/28 proof matrix accepted?

Yes.

The proof matrix is accepted and was rerun by this card with PASS.

### Are derivative OOF-TY0 entries acceptable?

Yes, with precise classification.

They are acceptable as secondary output/type mismatch diagnostics. They are not
accepted as `Unsupported expression kind: if_expr` diagnostics, and the proof
shows that unsupported-if_expr `OOF-TY0` was replaced.

### Is if_expr v0 accepted as internal compiler support?

Yes.

Expression-level `if_expr` v0 is accepted as internal compiler support in
TypeChecker and SemanticIR.

### Does runtime/evaluator support remain closed?

Yes.

No runtime/evaluator support, lazy branch execution, or runtime claim is opened.

### Does the release lane remain paused?

Yes.

No release command, publish, yank, tag, sign, deploy, or second release route is
opened.

### Do public demo/stable/production/all-grammar claims remain closed?

Yes.

No public support claim is authorized.

### Does Spark remain out of Main Line scope?

Yes.

Spark remains out of this Main Line implementation acceptance.

### May docs/spec sync open next?

Not before C2-X and C3-S finish this acceptance round.

If C2-X agrees with this acceptance decision and C3-S curates it cleanly, the
recommended next route is a bounded `if_expr` docs/spec sync. That route should
update internal language/spec docs only and should preserve release/public claim
boundaries unless separately authorized.

---

## Exact C2-X Pressure Focus

```text
Card: S3-R190-C2-X
Track: branch-conditional-if-expr-v0-implementation-acceptance-pressure-v0

Focus:
- verify accepted implementation stayed inside authorized write scope;
- verify TypeChecker and SemanticIR stage shapes are separated;
- verify nested SemanticIR lowering is recursively flat;
- verify OOF-IF1..OOF-IF4 match accepted semantics;
- verify OOF-IF5 remains absent/unowned;
- verify OOF-TY0 classification:
  - unsupported-if_expr OOF-TY0 is closed/replaced;
  - derivative type-mismatch OOF-TY0 is secondary and acceptable or identify a blocker;
- verify release harness, accepted release evidence, runtime/evaluator, public
  API/CLI, Spark, release, and public claims remain closed.

Recommended pressure outcome:
- proceed if no code/proof blocker;
- optionally recommend proof-summary wording hygiene as a later non-blocking docs/proof cleanup.
```

---

## C3-S Handoff

```text
R190 C1-A accepts if_expr v0 implementation closure.

Status to curate if C2-X agrees:
  accepted-implementation-closure
  internal compiler support landed and accepted
  runtime/evaluator closed
  release lane paused
  public demo/stable/production/all-grammar/Spark/API claims closed

Potential next route after C2-X/C3-S:
  bounded if_expr docs/spec sync

Do not open:
  runtime/evaluator implementation
  release harness mutation
  public release/demo claims
  Spark fixtures/integration
  API/CLI widening
```

