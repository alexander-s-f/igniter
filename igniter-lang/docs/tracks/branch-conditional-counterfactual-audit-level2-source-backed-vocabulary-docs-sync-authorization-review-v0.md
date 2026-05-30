# Branch Conditional Counterfactual Audit Level 2 Source-Backed Vocabulary Docs Sync Authorization Review v0

Card: S3-R213-C1-A  
Agent: [Portfolio Architect Supervisor]  
Role: portfolio-architect-supervisor  
Track: branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-authorization-review-v0  
Route: UPDATE  
Status: done / authorized-bounded-docs-only-a-min-sync  
Date: 2026-05-30

Depends on:
- S3-R212-C5-S

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round212-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-spec-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-spec-boundary-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-source-backed-doc-target-survey-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-spec-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round211-status-curation-v0.md`

---

## Decision

Decision:

```text
authorize bounded docs-only Option A-min sync
do not authorize docs/current-status.md edit
do not authorize body spec chapters
do not authorize public docs
do not authorize PROP-032 amendment
do not authorize live implementation
do not authorize runtime/report/API/Spark/CLI/public claims
```

R213 may proceed to a narrow implementation card because R212 accepted the
source-backed Level 2 vocabulary/spec boundary and resolved C3-X NB-1 as
Option A-min. The sync is useful because it makes the accepted R211/R212
vocabulary discoverable in low-authority internal navigation surfaces without
promoting it to language canon, runtime support, report shape, or public
feature status.

---

## Authorized Write Scope

Allowed files:

```text
igniter-lang/docs/dev/semantic-governance-heat-map.md
igniter-lang/docs/spec/README.md
igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-v0.md
```

Closed for this sync:

```text
igniter-lang/docs/current-status.md
```

`docs/current-status.md` already carries the R211/R212 state and should not be
touched by C2-I. A later Status Curator may update it only if C4-A accepts the
round and normal status practice requires it.

---

## Required Wording

Preferred phrase:

```text
source-backed proof-local Level 2 counterfactual dry-run evidence
```

Allowed short form:

```text
source-backed proof-local Level 2 evidence; non-canonical; no runtime/report/API authority
```

Required long-form meaning, if space allows:

```text
Source-backed Level 2 vocabulary names proof-local counterfactual dry-run
evidence derived from proof-owned SemanticIR-shaped artifacts, frozen input
snapshots, explicit premise sets, SHA-256 digest-addressed refs, and
no-authority projection envelopes.
```

Required index-style wording for `docs/spec/README.md`:

```text
No spec chapter: source-backed Level 2 counterfactual dry-run evidence is
proof-local and non-canonical; body spec chapters, PROP-032, runtime/report/API,
and public claims remain closed.
```

Required PROP-032-safe wording if assumptions are mentioned:

```text
Assumptions-shaped premise refs may appear only as proof-local premise labels in
`premise_set` records; they are not branch-level `uses assumptions`, not a
PROP-032 grammar extension, and not receipt `assumption_refs`.
```

---

## Required Non-Claim Block

C2-I must preserve this boundary in the new track doc and, where appropriate,
in compact target wording:

```text
This docs sync is not source syntax, not canonical SemanticIR schema, not
CompilerResult or CompilationReport shape, not report/result/receipt/
CompatibilityReport shape, not runtime behavior, not live non-selected branch
evaluation, not public counterfactual audit support, and not Spark/API/CLI
support.
```

---

## Forbidden Wording Scan Set

C2-I must scan touched files for the following terms. Matches are allowed only
inside explicit forbidden, non-claim, negative-disambiguation, or closed-surface
sections.

Forbidden as positive projection/canon/public vocabulary:

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
symbolic_execution
causal_estimate
alternate_actual_output
```

Forbidden or over-broad as positive claims:

```text
counterfactual audit support
counterfactual audit support landed
runtime counterfactual support
public counterfactual support
counterfactual runtime
runtime can evaluate latent branches
runtime can dry-run latent branches
would output
would result
would fail
SemanticIR emits branch_intention
SemanticIR emits source_branch_intention_ref
source-backed branch intentions are SemanticIR
source_branch_intention_ref is a CompilationReport field
source_branch_intention_ref is a CompilerResult field
dry_run_projection is a CompatibilityReport field
receipt contains counterfactual
public API supports counterfactual dry-run
CLI supports counterfactual dry-run
branch-level uses assumptions
PROP-032 branch syntax
```

---

## Proof-Local Evidence Citation Stance

C2-I may cite R211/R212 evidence only as internal proof-local evidence:

- R211 source-backed proof-local Level 2 evidence;
- R212 accepted vocabulary/spec boundary;
- proof-owned SemanticIR-shaped artifacts;
- frozen input snapshots;
- explicit premise sets;
- SHA-256 digest-addressed refs;
- no-authority projection envelopes.

C2-I must not imply:

- source evidence is canonical SemanticIR;
- `source_branch_intention_ref` is emitted by compiler surfaces;
- proof projection is an actual runtime result;
- live runtime evaluates latent branches;
- public API/CLI/report/receipt/cache authority exists.

Negative disambiguation text must remain outside machine-readable authority or
result fields. Because this is a docs-only sync, it should live in prose,
forbidden-wording sections, non-claim blocks, or closed-surface sections.

---

## Closed Surfaces

Remain closed:

- body spec chapters:
  - `igniter-lang/docs/spec/ch2-source-surface.md`
  - `igniter-lang/docs/spec/ch5-compiler-pipeline.md`
  - `igniter-lang/docs/spec/ch6-semanticir.md`
  - `igniter-lang/docs/spec/ch7-runtime.md`
- `igniter-lang/docs/language-spec.md`
- `igniter-lang/docs/proposals/PROP-032-assumptions-block-v0.md`
- `igniter-lang/docs/README.md`
- public README/API/CLI docs
- release notes / release docs
- report/result/receipt/CompatibilityReport docs
- runtime docs
- live implementation
- `lib/**`
- parser/grammar/source syntax
- TypeChecker/SemanticIR schema mutation
- runtime/evaluator/RuntimeSmoke/proof RuntimeMachine behavior
- live non-selected branch evaluation
- effect execution, external IO, persistence
- Ledger/TBackend live reads/writes
- dependency/cache authority
- `.igapp` schema or golden artifacts
- public API/CLI
- release evidence rewrite or public demo/stable/production/all-grammar claims
- Spark data, fixtures, ids, integration, or demo behavior
- production behavior

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| May docs-only A-min sync begin? | Yes. C2-I is authorized under the exact write scope above. |
| May `docs/current-status.md` be touched? | No. Closed for C2-I. |
| Do body spec chapters remain held? | Yes. Ch2/Ch5/Ch6/Ch7 remain untouched. |
| Do public docs remain held? | Yes. `docs/README.md`, public README/API/CLI/release docs remain closed. |
| Does PROP-032 remain untouched? | Yes. Assumptions remain premise capsule only; no branch syntax or receipt change. |
| Is source-backed Level 2 vocabulary canonical? | No. It remains proof-local and non-canonical. |
| Is report/result/receipt/cache authority opened? | No. Fully closed. |
| Are runtime/API/Spark/CLI claims opened? | No. Fully closed. |
| Is live implementation authorized? | No. |

---

## Exact C2-I Boundary

```text
Card: S3-R213-C2-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-v0
Route: UPDATE
Depends on:
- S3-R213-C1-A
```

Goal:

```text
Perform a bounded docs-only Option A-min sync that makes source-backed
proof-local Level 2 counterfactual dry-run evidence discoverable in low-authority
internal navigation docs while preserving all non-canonical, no-runtime,
no-report/API, no-public-claim boundaries.
```

Allowed writes:

```text
igniter-lang/docs/dev/semantic-governance-heat-map.md
igniter-lang/docs/spec/README.md
igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-v0.md
```

Required proof:

- exact changed files;
- exact inserted wording;
- forbidden phrase scan of touched files;
- closed-surface scan;
- no `docs/current-status.md` edit;
- no body spec chapter edit;
- no public docs edit;
- no PROP-032 edit;
- no `lib/**` edit;
- compact non-claim block;
- compact summary.

Command/proof suggestions:

```text
git diff -- igniter-lang/docs/dev/semantic-governance-heat-map.md igniter-lang/docs/spec/README.md igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-v0.md
git diff --check
git status --short
```

Expected outcome:

```text
docs-only low-authority sync completed or held with exact blockers
no live implementation
no public/runtime/report/API/Spark/CLI claims
```
