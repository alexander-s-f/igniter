# Stage 3 Round 206 Status Curation v0

Card: S3-R206-C5-S
Agent: [Status Curator]
Role: status-curator
Track: stage3-round206-status-curation-v0
Route: UPDATE
Status: done
Date: 2026-05-30

Depends on:
- S3-R206-C1-D
- S3-R206-C2-P1
- S3-R206-C3-X
- S3-R206-C4-A

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-vocabulary-spec-sync-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-doc-target-survey-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-vocabulary-spec-sync-pressure-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-vocabulary-spec-sync-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round205-status-curation-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/cards/S3/S3-R206.md`

---

## R206 Outcome Table

| Card | Output | Curated status |
| --- | --- | --- |
| S3-R206-C1-D | `branch-conditional-counterfactual-audit-vocabulary-spec-sync-v0` | Done; designs Level 1 branch-intention vocabulary and keeps `if_expr_branch_intention` proof-local / non-canonical. |
| S3-R206-C2-P1 | `branch-conditional-counterfactual-audit-doc-target-survey-v0` | Done; recommends Option A target set: current status, semantic-governance heat map, optional spec README pointer. |
| S3-R206-C3-X | `branch-conditional-counterfactual-audit-vocabulary-spec-sync-pressure-v0` | Proceed; 7/8 clean PASS, 1 conditional PASS for target-set choice, no blockers. |
| S3-R206-C4-A | `branch-conditional-counterfactual-audit-vocabulary-spec-sync-decision-v0` | Accepted; chooses Option A bounded docs sync and holds spec-body chapter edits for a later gate. |
| S3-R206-C5-S | `stage3-round206-status-curation-v0` | Done; records the accepted vocabulary status and exact R207 docs-sync boundary. |

---

## Vocabulary Status

R206 status:

```text
accepted-option-a-bounded-docs-sync-authorized
```

C4-A accepts Level 1 branch-intention vocabulary as docs vocabulary and boundary
markers only:

- `branch_intention`;
- `actual_branch`;
- `latent_branch`;
- `branch_role`;
- `branch_label`;
- `condition_observation`;
- `static_branch_metadata`;
- `intention_source`;
- `explanatory_only`;
- `non_execution_guarantee`.

Accepted maximum claim:

```text
Level 1 branch-intention vocabulary is proof-local static audit vocabulary for
explaining actual and latent if_expr branches without evaluating latent branches.
It is not source syntax, not a SemanticIR schema field, not runtime behavior,
and not public counterfactual audit support.
```

The fixed principle remains:

```text
Runtime is lazy.
Audit is aware.
```

---

## Descriptor and Assumptions Status

`if_expr_branch_intention` remains proof-local and non-canonical. It may be cited
only as R205 proof evidence, not as:

- SemanticIR node kind or field;
- `CompilationReport`, `CompilerResult`, `CompatibilityReport`, receipt, or
  runtime output field;
- RuntimeSmoke output contract;
- public API/CLI object;
- `.igapp`, `.ilk`, manifest, sidecar, golden, or artifact schema;
- release, alpha, first-RC, public demo, stable, production, all-grammar, or
  Spark evidence.

Assumptions remain a premise capsule only. R206 does not accept a PROP-032
amendment, branch-level `uses assumptions`, canonical branch-level
`assumption_refs`, PROP-032 receipt semantics for proof-local branch-intention
descriptors, or assumptions as the whole branch-intention model.

---

## Docs / Spec Sync Target Status

C4-A resolves the C1-D / C2-P1 target tension by choosing Option A.

Authorized later docs-sync implementation scope:

- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/dev/semantic-governance-heat-map.md`
- `igniter-lang/docs/spec/README.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-vocabulary-spec-sync-v0.md`

Allowed edit class:

- status pointer / current-lane summary;
- semantic governance row for `branch_intention`;
- one-line spec index pointer labeled proof-local / Level 1 static audit;
- track-doc clarification only if needed to mirror the decision.

Held for later explicit gate:

- `igniter-lang/docs/language-spec.md`
- `igniter-lang/docs/spec/ch2-source-surface.md`
- `igniter-lang/docs/spec/ch5-compiler-pipeline.md`
- `igniter-lang/docs/spec/ch6-semanticir.md`
- `igniter-lang/docs/spec/ch7-runtime.md`
- `igniter-lang/docs/proposals/PROP-032-assumptions-block-v0.md`
- public API/CLI docs
- release docs
- runtime/report/receipt/CompatibilityReport docs

---

## Forbidden Positive Claims

The next docs-sync route must not use these as positive Level 1 claims or output
field names:

```text
would_result
would_output
would_fail
counterfactual result
counterfactual output
counterfactual failure
latent runtime value
latent runtime failure
latent execution
latent branch execution
simulated branch result
dry-run result
branch replay
replayed branch value
```

Also forbidden as positive claims:

```text
Igniter-Lang supports counterfactual audit.
SemanticIR emits branch_intention records.
RuntimeSmoke supports counterfactual if_expr audit.
Branches can use assumptions with branch-level uses assumptions.
Static latent refs participate in dependency tracking or cache keys.
```

---

## Remaining Closed Surfaces

Remain closed after R206:

- live implementation;
- parser/grammar/source syntax changes;
- branch-level `uses assumptions` syntax;
- TypeChecker/SemanticIR schema/canon mutation;
- runtime/evaluator changes;
- RuntimeSmoke changes;
- proof RuntimeMachine changes;
- non-selected branch evaluation;
- Level 2 counterfactual dry-run;
- Level 3 comparison report;
- dependency/cache authority;
- report/result/receipt/CompatibilityReport shape changes;
- public API/CLI widening;
- public counterfactual/runtime support claims;
- Spark integration or Spark evidence;
- release execution, public release/demo/stable/all-grammar claims;
- runtime, production, deployment, signing, cache, Ledger/TBackend, BiHistory,
  stream/OLAP, and production behavior.

---

## Exact Next Route Recommendation

Recommended next Main Line route:

```text
Card: S3-R207-C1-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: branch-conditional-counterfactual-audit-vocabulary-docs-sync-v0
Route: UPDATE
Depends on:
- S3-R206-C5-S
```

Goal:

```text
Apply the bounded Option A docs-sync for Level 1 branch-intention vocabulary:
status pointer, semantic-governance row, optional spec README index pointer, and
no spec-body chapter edits.
```

Allowed write scope:

- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/dev/semantic-governance-heat-map.md`
- `igniter-lang/docs/spec/README.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-vocabulary-docs-sync-v0.md`

Forbidden in the next route:

- grammar/parser/source edits;
- Ch2/Ch5/Ch6/Ch7 body edits;
- PROP-032 mutation;
- runtime/evaluator/RuntimeSmoke/proof RuntimeMachine edits;
- report/result/receipt/CompatibilityReport edits;
- dependency/cache authority;
- Level 2 dry-run;
- release/public/Spark/API/CLI claims or behavior.

---

## Current-Status Delta

`igniter-lang/docs/current-status.md` now records R206 as accepted Option A
bounded docs-sync authorization and routes only the R207 bounded docs-sync
implementation next.
