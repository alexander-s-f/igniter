# Branch Conditional Counterfactual Audit Vocabulary Spec Sync Decision v0

Card: S3-R206-C4-A  
Agent: [Portfolio Architect Supervisor]  
Role: portfolio-architect-supervisor  
Track: branch-conditional-counterfactual-audit-vocabulary-spec-sync-decision-v0  
Route: UPDATE  
Status: done / accepted-option-a-bounded-docs-sync-authorized  
Date: 2026-05-30

Depends on:
- S3-R206-C1-D
- S3-R206-C2-P1
- S3-R206-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-vocabulary-spec-sync-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-doc-target-survey-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-vocabulary-spec-sync-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round205-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-concept-proof-acceptance-decision-v0.md`
- `igniter-lang/docs/proposals/PROP-032-assumptions-block-v0.md`

---

## Decision

Decision:

```text
accept Level 1 branch-intention vocabulary/spec-sync design
accept C2-P1 target-risk survey
accept C3-X pressure verdict: proceed, no blockers
choose Option A target set for first docs sync
authorize a later bounded docs/spec-index sync implementation
do not authorize spec-body edits in Ch2/Ch5/Ch6/Ch7 yet
do not authorize live implementation, Level 2 dry-run, runtime/report/API changes, or public claims
```

R206 is accepted as a vocabulary and documentation-boundary step only. The
accepted purpose is discoverability and drift prevention after R205, not schema
canonization.

The fixed principle remains:

```text
Runtime is lazy.
Audit is aware.
```

---

## Accepted Vocabulary

The following terms are accepted as Level 1 docs vocabulary and boundary markers
only:

| Term | Accepted status |
| --- | --- |
| `branch_intention` | Static explanatory lens over an `if_expr` branch pair. |
| `actual_branch` | Branch selected by an observed condition value. |
| `latent_branch` | Non-selected branch, structurally described but not evaluated. |
| `branch_role` | Supporting role marker: actual or latent. |
| `branch_label` | Supporting source label: then or else. |
| `condition_observation` | Already-observed condition value or structure; not a new evaluation command. |
| `static_branch_metadata` | Typed/SemanticIR-derived facts for explanation only. |
| `intention_source` | Proof-local source for the explanation. |
| `explanatory_only` | Required non-authority marker. |
| `non_execution_guarantee` | Required positive marker that latent branch evaluation did not occur. |

These terms do not define public API, report fields, receipt fields, source
syntax, SemanticIR schema, runtime behavior, or artifact schema.

---

## Descriptor Shape

The proof-local descriptor kind:

```text
if_expr_branch_intention
```

may appear in docs only under a proof-local / non-canonical label. It must not be
described as:

- a SemanticIR node kind or field;
- a `CompilationReport`, `CompilerResult`, `CompatibilityReport`, receipt, or
  runtime output field;
- a RuntimeSmoke output contract;
- a public API/CLI object;
- a `.igapp`, `.ilk`, manifest, sidecar, golden, or artifact schema;
- release, alpha, first-RC, public demo, stable, production, all-grammar, or
  Spark evidence.

The R205 descriptor shape remains accepted evidence, not canonical object model.

---

## Target-Set Resolution

C1-D proposed a broader spec-body sync across Ch5/Ch6/Ch7. C2-P1 and C3-X
correctly identified authority drift risk in those chapters. C4-A chooses
Option A for the first sync.

Allowed files for the later bounded docs-sync implementation:

```text
igniter-lang/docs/current-status.md
igniter-lang/docs/dev/semantic-governance-heat-map.md
igniter-lang/docs/spec/README.md
igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-vocabulary-spec-sync-v0.md
```

Allowed edit class:

- status pointer / current-lane summary;
- semantic governance row for `branch_intention`;
- one-line spec index pointer labeled proof-local / Level 1 static audit;
- track-doc clarification only if needed to mirror this decision.

Held for a later explicit gate:

```text
igniter-lang/docs/language-spec.md
igniter-lang/docs/spec/ch2-source-surface.md
igniter-lang/docs/spec/ch5-compiler-pipeline.md
igniter-lang/docs/spec/ch6-semanticir.md
igniter-lang/docs/spec/ch7-runtime.md
igniter-lang/docs/proposals/PROP-032-assumptions-block-v0.md
public API/CLI docs
release docs
runtime/report/receipt/CompatibilityReport docs
```

Rationale: the immediate goal is discoverability and anti-drift guidance. It is
not yet necessary to place proof-local vocabulary inside high-authority spec
body chapters where future readers may infer schema or runtime authority.

---

## Required Wording

The later docs-sync implementation must preserve this wording class:

```text
Level 1 branch-intention vocabulary is proof-local static audit vocabulary for
explaining actual and latent if_expr branches without evaluating latent branches.
It is not source syntax, not a SemanticIR schema field, not runtime behavior,
and not public counterfactual audit support.
```

```text
branch_intention names an explanatory lens over an if_expr branch pair. The
actual branch may be tied to actual-path evidence; the latent branch may be
described from typed/SemanticIR structure only and must carry a non-execution
guarantee.
```

```text
Proof-local branch premise refs may be assumptions-shaped, but they are not
PROP-032 branch syntax and are not PROP-032 receipt assumption_refs.
```

```text
Level 1 static audit excludes would-result, would-output, would-fail, latent
runtime value, latent runtime failure, Level 2 dry-run, dependency/cache
authority, and report/result/receipt/CompatibilityReport shape changes.
```

---

## Forbidden Wording

The later docs-sync implementation must not use any of the following as positive
Level 1 claims or output-field names:

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

Also forbidden:

```text
Igniter-Lang supports counterfactual audit.
SemanticIR emits branch_intention records.
RuntimeSmoke supports counterfactual if_expr audit.
Branches can use assumptions with branch-level uses assumptions.
Static latent refs participate in dependency tracking or cache keys.
```

These terms may appear only in a forbidden-vocabulary list or in a future Level
2+ design discussion behind a separate gate.

---

## Assumptions / PROP-032 Stance

Assumptions remain a premise capsule only.

Accepted:

- proof-local branch premise refs may be assumptions-shaped;
- assumptions are a leading candidate capsule for branch premises;
- asymmetric proof-local assumption refs remain valid;
- the relationship may be documented as explanatory-only.

Not accepted:

- PROP-032 amendment;
- branch-level `uses assumptions`;
- canonical branch-level `assumption_refs`;
- PROP-032 receipt semantics for proof-local branch-intention descriptors;
- assumptions as the whole branch-intention model.

`PROP-032-assumptions-block-v0.md` must remain untouched in the next docs-sync
implementation.

---

## Proof Citation Policy

The later docs-sync implementation may cite:

- R205 as proof-local concept evidence;
- R206 as vocabulary/spec-sync boundary decision;
- R204/R205 status docs for current-route context.

It must not cite R205 as:

- public counterfactual audit support;
- public runtime support;
- Level 2 dry-run support;
- release evidence;
- Spark/API/CLI evidence;
- report/result/receipt/CompatibilityReport support.

Accepted maximum claim remains:

```text
Proof-local concept evidence that if_expr branch intentions can be statically
described for actual and latent branches without evaluating latent branches,
using explanatory-only metadata and optional assumptions-shaped premise refs.
```

---

## Required Answers

| Question | Decision |
| --- | --- |
| Is the vocabulary accepted for docs/spec sync? | Yes, as Level 1 terminology and boundary markers only. |
| Does proof-local descriptor shape become canonical? | No. It remains non-canonical proof-local evidence. |
| May `if_expr_branch_intention` appear in docs? | Yes, only labeled proof-local / non-canonical; not as schema, API, report, receipt, runtime, or artifact shape. |
| Do assumptions remain premise capsule only? | Yes. |
| Is a PROP-032 amendment needed now? | No; held and unnecessary for this sync. |
| May docs-sync implementation open next? | Yes, bounded to Option A targets above. |
| Does Level 2 dry-run remain closed? | Yes. |
| Do runtime/API/report/public claims remain closed? | Yes. |
| Do Spark/API/CLI remain closed? | Yes. |

---

## Next Dispatch

Immediate status handoff:

```text
Card: S3-R206-C5-S
Agent: [Status Curator]
Role: status-curator
Track: stage3-round206-status-curation-v0
Route: UPDATE
Depends on:
- S3-R206-C1-D
- S3-R206-C2-P1
- S3-R206-C3-X
- S3-R206-C4-A

Goal:
Curate R206 acceptance, record Option A docs-sync target set, and preserve the
closed surfaces before the next implementation card.
```

Authorized next implementation route after C5-S:

```text
Card: S3-R207-C1-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: branch-conditional-counterfactual-audit-vocabulary-docs-sync-v0
Route: UPDATE
Depends on:
- S3-R206-C5-S

Goal:
Apply the bounded Option A docs-sync for Level 1 branch-intention vocabulary:
status pointer, semantic-governance row, optional spec README index pointer,
and no spec-body chapter edits.
```

Allowed write scope:

```text
igniter-lang/docs/current-status.md
igniter-lang/docs/dev/semantic-governance-heat-map.md
igniter-lang/docs/spec/README.md
igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-vocabulary-docs-sync-v0.md
```

Required verification:

```text
rg -n "would_result|would_output|would_fail|counterfactual result|counterfactual output|counterfactual failure|latent runtime value|latent runtime failure|latent execution|latent branch execution|simulated branch result|dry-run result|branch replay|replayed branch value" igniter-lang/docs/current-status.md igniter-lang/docs/dev/semantic-governance-heat-map.md igniter-lang/docs/spec/README.md
rg -n "SemanticIR now emits branch_intention|supports counterfactual audit|RuntimeSmoke supports counterfactual|branch-level uses assumptions|dependency tracking or cache keys" igniter-lang/docs/current-status.md igniter-lang/docs/dev/semantic-governance-heat-map.md igniter-lang/docs/spec/README.md
```

Forbidden in C1-I:

- grammar/parser/source syntax changes;
- Ch2/Ch5/Ch6/Ch7 body edits;
- PROP-032 edits;
- runtime/evaluator/RuntimeSmoke/proof RuntimeMachine edits;
- report/result/receipt/CompatibilityReport shape changes;
- dependency/cache authority;
- Level 2 dry-run;
- release evidence mutation;
- public demo/stable/production/all-grammar/runtime/counterfactual claims;
- Spark/API/CLI changes or claims.

---

## Closed Surfaces

Remain closed after R206:

- live implementation;
- parser/grammar/source syntax;
- branch-level `uses assumptions`;
- TypeChecker/SemanticIR schema/canon mutation;
- runtime/evaluator;
- RuntimeSmoke;
- proof RuntimeMachine;
- non-selected branch evaluation;
- Level 2 counterfactual dry-run;
- Level 3 comparison report;
- effect sandboxing;
- branch replay;
- latent runtime value/failure production;
- `CompilerOrchestrator`, `CompilerResult`, `CompilationReport`, Diagnostics;
- report/result/receipt/CompatibilityReport shape changes;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden mutation;
- release evidence rewrite or relabeling;
- release commands, publish/yank/tag/push/sign/deploy;
- public demo/release/stable/production/all-grammar/runtime/counterfactual
  claims;
- public API/CLI widening;
- loader/report or CompatibilityReport behavior;
- dependency/cache authority;
- RuntimeMachine/Gate 3 production authority;
- Ledger/TBackend production, BiHistory, stream/OLAP, production runtime;
- Spark data, fixtures, specs, ids, integration, or demo behavior.

---

## Compact Handoff

R206 accepts the Level 1 branch-intention vocabulary and the proof-local
counterfactual-audit wording boundary. C4-A chooses Option A: first sync only to
status/dev-map/spec-index surfaces, not Ch2/Ch5/Ch6/Ch7 body chapters. The
descriptor `if_expr_branch_intention` remains non-canonical. Assumptions remain
premise capsule only. Level 2 dry-run, runtime/report/API/public claims, and
Spark/API/CLI remain closed.
