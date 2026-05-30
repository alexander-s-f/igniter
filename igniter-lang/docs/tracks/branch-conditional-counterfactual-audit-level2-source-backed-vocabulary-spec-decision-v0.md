# Branch Conditional Counterfactual Audit Level 2 Source-Backed Vocabulary Spec Decision v0

Card: S3-R212-C4-A  
Agent: [Portfolio Architect Supervisor]  
Role: portfolio-architect-supervisor  
Track: branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-spec-decision-v0  
Route: UPDATE  
Status: done / accepted-vocabulary-boundary-and-authorized-a-min-docs-sync  
Date: 2026-05-30

Depends on:
- S3-R212-C1-D
- S3-R212-C2-P1
- S3-R212-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-spec-boundary-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-source-backed-doc-target-survey-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-spec-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round211-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-proof-acceptance-decision-v0.md`

---

## Decision

Decision:

```text
accept source-backed Level 2 vocabulary/spec boundary
accept C2-P1 doc target survey
accept C3-X pressure verdict: PASS 10/10, no blockers, 2 non-blocking notes
authorize later bounded docs-only A-min vocabulary sync
do not authorize docs/spec edits in this card
do not authorize live implementation
do not authorize public/runtime/report/API claims
```

The R212 vocabulary boundary is accepted because it makes the R211 achievement
discoverable while preventing claim inflation. The next route may open only a
low-authority docs-sync target set. Body spec chapters, PROP-032, public docs,
runtime/report/API docs, and implementation remain held.

The governing principle remains:

```text
Runtime is lazy.
Audit is aware.
Dry-run, if ever accepted, must be isolated.
Evidence must be sourced before it can be explained.
Vocabulary must not outrun authority.
```

---

## Accepted Vocabulary

Accepted internal phrase:

```text
source-backed proof-local Level 2 counterfactual dry-run evidence
```

Allowed short form:

```text
source-backed proof-local Level 2 evidence; non-canonical; no runtime/report/API authority
```

Accepted explanation:

```text
Source-backed Level 2 vocabulary names proof-local counterfactual dry-run
evidence derived from proof-owned SemanticIR-shaped artifacts, frozen input
snapshots, explicit premise sets, SHA-256 digest-addressed refs, and
no-authority projection envelopes.
```

Binding non-claims:

```text
not source syntax
not canonical SemanticIR schema
not CompilerResult or CompilationReport shape
not report/result/receipt/CompatibilityReport shape
not runtime behavior
not live non-selected branch evaluation
not public counterfactual audit support
not Spark/API/CLI support
```

---

## Forbidden / Held Wording

Forbidden as positive claims:

```text
counterfactual audit support
counterfactual audit support landed
runtime counterfactual support
public counterfactual support
counterfactual runtime
runtime can evaluate latent branches
runtime can dry-run latent branches
dry-run result
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

The established 17-term forbidden vocabulary list also remains binding:

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

These terms may appear only in explicit forbidden, non-claim, negative
disambiguation, or closed-surface sections. They must not appear as positive
field names, projection values, feature labels, public claims, or release
claims.

---

## C3-X Notes Resolved

### NB-1: Option A-Min vs Hold

Resolved:

```text
proceed with Option A-min
```

Reason:

The heat map and spec README are low-authority navigation surfaces. Adding a
strictly fenced pointer there will reduce future agent drift and make the R211
result discoverable without promoting it to spec-body, runtime, report/API, or
public support.

### NB-2: Negative Disambiguation Placement

Resolved and binding:

Future proof routes and docs-sync routes after R212 must place negative
disambiguation text outside machine-readable authority/result fields.

Allowed locations:

- prose in track docs;
- explicit forbidden wording sections;
- explicit non-claim blocks;
- explicit closed-surface sections;
- pressure review notes.

Avoid for new proof routes:

- JSON authority fields;
- projection field values;
- schema-like machine-readable result fields;
- feature labels.

The R211 JSON `execution_summary_citation.note` is accepted as a grandfathered
policy-motivating precedent, not as a pattern to continue.

---

## Authorized Next Route

```text
Card: S3-R213-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R212-C5-S
```

Goal:

```text
Decide whether a bounded docs-only low-authority vocabulary sync may begin for
source-backed proof-local Level 2 counterfactual dry-run evidence, limited to
the A-min target set and preserving all public/runtime/report/API/PROP-032
closed surfaces.
```

Candidate docs-sync track if authorized:

```text
branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-v0
```

Candidate allowed files if authorized in R213:

```text
igniter-lang/docs/dev/semantic-governance-heat-map.md
igniter-lang/docs/spec/README.md
igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-v0.md
```

Optional:

```text
igniter-lang/docs/current-status.md
```

Only if the authorizing card requires a tiny wording polish. Default is no-op.

---

## Held / Closed Targets

Remain held:

- `igniter-lang/docs/spec/ch2-source-surface.md`;
- `igniter-lang/docs/spec/ch5-compiler-pipeline.md`;
- `igniter-lang/docs/spec/ch6-semanticir.md`;
- `igniter-lang/docs/spec/ch7-runtime.md`;
- `igniter-lang/docs/language-spec.md`;
- `igniter-lang/docs/proposals/PROP-032-assumptions-block-v0.md`;
- `igniter-lang/docs/README.md`;
- public README/API/CLI docs;
- release notes / release docs;
- report/result/receipt/CompatibilityReport docs;
- runtime docs.

Remain closed:

- live implementation;
- `lib/**`;
- parser/grammar/source syntax;
- branch-level `uses assumptions`;
- TypeChecker/SemanticIR schema mutation;
- runtime/evaluator/RuntimeSmoke behavior;
- live non-selected branch evaluation;
- effect execution, external IO, persistence;
- Ledger/TBackend live reads/writes;
- `tbackend_read` non-refusal behavior;
- dependency/cache authority;
- public API/CLI;
- release evidence rewrite or public demo/stable/production/all-grammar claims;
- Spark data, fixtures, ids, integration, or demo behavior;
- production behavior.

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Is source-backed Level 2 vocabulary accepted? | Yes, as internal proof-local vocabulary only. |
| May docs-sync open next? | Yes, only A-min docs-only low-authority sync via authorization review. |
| Do body spec chapters remain held? | Yes. |
| Do public docs remain held? | Yes. |
| Does PROP-032 remain untouched? | Yes. |
| Do runtime/report/API/Spark claims remain closed? | Yes. |
| What next route opens? | S3-R213-C1-A docs-sync authorization review. |

---

## Compact Handoff

R212 accepts the source-backed Level 2 vocabulary/spec boundary and chooses
Option A-min for a later docs-only low-authority sync. The accepted vocabulary is
`source-backed proof-local Level 2 counterfactual dry-run evidence`; broad
phrases like `counterfactual audit support` remain forbidden as positive claims.
The only next route is a docs-sync authorization review for Heat Map + spec
README + track doc. Body spec chapters, public docs, PROP-032, runtime,
report/API, Spark, and implementation remain closed.
