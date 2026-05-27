# Stage 3 Round 190 Status Curation v0

Card: S3-R190-C3-S
Agent: [Status Curator]
Role: status-curator
Track: stage3-round190-status-curation-v0
Route: UPDATE
Status: done
Date: 2026-05-27

Depends on:
- S3-R190-C1-A
- S3-R190-C2-X

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-v0-implementation-acceptance-decision-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-v0-implementation-acceptance-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round189-status-curation-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/cards/S3/S3-R190.md`

---

## R190 Outcome Table

| Card | Output | Status | Curated result |
| --- | --- | --- | --- |
| S3-R190-C1-A | `branch-conditional-if-expr-v0-implementation-acceptance-decision-v0.md` | done / accepted-implementation-closure | Accepts the bounded `if_expr` v0 TypeChecker + SemanticIR implementation closure as internal compiler support. |
| S3-R190-C2-X | `branch-conditional-if-expr-v0-implementation-acceptance-pressure-v0.md` | proceed | Pressure PASS 8/8, no blockers; two non-blocking proof/docs hygiene notes. |
| S3-R190-C3-S | `stage3-round190-status-curation-v0.md` | done | R190 acceptance outcome curated into Stage 3 map and next Main Line boundary. |

---

## Implementation Acceptance Status

Status:

```text
accepted-implementation-closure
```

Accepted internal compiler support:

- expression-level `if_expr` v0;
- TypeChecker inference in `igniter-lang/lib/igniter_lang/typechecker.rb`;
- typed SemanticIR lowering in `igniter-lang/lib/igniter_lang/semanticir_emitter.rb`;
- `else` required;
- canonical Bool condition: `{"name":"Bool","params":[]}`;
- exact then/else result-type match;
- value-producing branches;
- nested `if_expr` under the same rules;
- union dependency policy;
- separated TypeChecker and SemanticIR stage shapes;
- recursive flat SemanticIR lowering.

Accepted proof matrix:

```text
28/28 PASS
```

Accepted diagnostics:

- `OOF-IF1`: non-Bool condition;
- `OOF-IF2`: missing `else`;
- `OOF-IF3`: branch type mismatch;
- `OOF-IF4`: empty or non-value-producing branch.

`OOF-IF5` remains unowned, unimplemented, and outside v0.

---

## OOF-TY0 Hygiene Status

Status:

```text
closed as accepted secondary-diagnostic classification
```

Accepted distinction:

| Diagnostic form | R190 status |
| --- | --- |
| `OOF-TY0 Unsupported expression kind: if_expr` | closed / replaced |
| `OOF-TY0 Type mismatch: expected ..., got Unknown` after rejected `if_expr` | acceptable secondary output/type mismatch diagnostic for now |

C2-X confirms this classification as PASS with a non-blocking proof-summary
wording note. No code cleanup is required by R190.

Non-blocking hygiene to carry forward:

- proof-summary wording should eventually distinguish derivative `OOF-TY0` from
  unsupported-`if_expr` regression more explicitly;
- proof JSON `non_claims` should align with the track doc by including
  `no_spark_claim`.

---

## Runtime, Release, And Public Claims

Runtime/evaluator status:

```text
closed
```

Release lane status:

```text
paused
```

Still not authorized:

- runtime/evaluator support or lazy branch execution;
- release execution, second release route, RubyGems publish, yank, tag, sign, or
  deploy;
- release harness corpus mutation or accepted alpha/release evidence mutation;
- public demo, stable, production, all-grammar, Spark, or public API/CLI claims.

---

## Exact Next Route

Recommended next Main Line boundary:

```text
Card: S3-R191-C1-D
Agent: [Compiler/Grammar Expert / Docs]
Role: compiler-grammar-expert
Track: branch-conditional-if-expr-docs-spec-sync-v0
Route: UPDATE
Depends on:
- S3-R190-C3-S
```

Goal:

```text
Synchronize internal language/spec docs for accepted expression-level if_expr
v0 compiler support while preserving runtime, release, public API/CLI, Spark,
public demo, stable, production, and all-grammar non-claims.
```

Allowed shape:

- docs/spec sync only;
- cite R187 design, R188 proof acceptance, R189 implementation proof, and R190
  acceptance;
- record TypeChecker/SemanticIR-only support;
- record runtime/evaluator closed;
- record OOF-IF1..OOF-IF4 accepted and OOF-IF5 out;
- carry NB proof-summary wording hygiene and `no_spark_claim` JSON consistency
  as optional proof/docs cleanup only if explicitly scoped.

Do not open:

- runtime/evaluator implementation;
- release harness mutation;
- public release/demo claims;
- Spark fixtures/integration;
- public API/CLI widening.

---

## Remaining Closed Surfaces

Remain closed:

- runtime/evaluator support and lazy branch execution;
- parser, classifier, compiler orchestrator, assembler, or root require changes;
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

## Current-Status Delta

Applied compact current-status update:

- R190 accepts the bounded `if_expr` v0 implementation closure as internal
  TypeChecker/SemanticIR compiler support;
- OOF-TY0 hygiene is closed as an accepted secondary-diagnostic distinction;
- runtime/evaluator, release, public claims, Spark, and public API/CLI remain
  closed;
- next route is bounded docs/spec sync.

No release commands, public claims, or compiler/runtime code edits were run by
this status-curation card.

---

## Compact Handoff

```text
R190 closes as accepted-implementation-closure.

Accepted:
  if_expr v0 internal compiler support
  TypeChecker + typed SemanticIR only
  28/28 implementation proof
  C2-X pressure 8/8 PASS
  OOF-IF1..OOF-IF4 live diagnostics
  OOF-IF5 out/unowned
  recursive flat SemanticIR lowering
  TypeChecker/SemanticIR stage separation

OOF-TY0:
  Unsupported expression kind: if_expr is closed/replaced
  derivative type mismatch OOF-TY0 is acceptable secondary diagnostic for now

Next:
  S3-R191-C1-D
  branch-conditional-if-expr-docs-spec-sync-v0
  docs/spec sync only

Carry NB:
  proof-summary wording hygiene for derivative OOF-TY0
  no_spark_claim JSON/track-doc consistency

Still closed:
  runtime/evaluator support, release execution, release harness mutation,
  public API/CLI widening, public release/demo/stable/production/all-grammar
  claims, Spark, production.
```
