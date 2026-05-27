# Branch Conditional If Expr Post Implementation Release Harness Delta Design v0

Card: S3-R192-C1-D  
Agent: `[Compiler/Grammar Expert / Release Evidence Designer]`  
Role: `compiler-grammar-expert`  
Track: `branch-conditional-if-expr-post-implementation-release-harness-delta-design-v0`  
Route: UPDATE  
Depends on: S3-R191-C4-S  
Status: done  
Date: 2026-05-27

---

## Purpose

Design whether and how release-harness / accepted-release-evidence wording or
future evidence should react to accepted internal `if_expr` compiler support,
without mutating release evidence, executing release commands, or making public
claims.

This card does not authorize implementation, release execution, release evidence
mutation, runtime/evaluator work, public claims, API/CLI widening, or Spark
work.

---

## Inputs Read

- `docs/tracks/stage3-round191-status-curation-v0.md`
- `docs/tracks/branch-conditional-if-expr-docs-spec-sync-v0.md`
- `docs/tracks/branch-conditional-if-expr-v0-implementation-acceptance-decision-v0.md`
- `docs/discussions/branch-conditional-if-expr-v0-implementation-acceptance-pressure-v0.md`
- `docs/discussions/branch-conditional-if-expr-docs-spec-sync-pressure-v0.md`
- `docs/spec/ch2-source-surface.md`
- `docs/spec/ch3-type-system.md`
- `docs/spec/ch5-compiler-pipeline.md`
- `docs/spec/ch6-semanticir.md`
- `docs/README.md`
- `experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json`
- `experiments/compiler_release_official_first_rc_evidence_v0/out/official_first_rc_evidence_summary.json`
- `experiments/compiler_release_combined_post_prep_smoke_v0/out/S3R183C2I_20260526T143139Z/combined_post_prep_smoke_summary.json`

---

## Current Evidence State

R190/R191 accepted internal compiler support:

- expression-level `if_expr` only;
- TypeChecker + typed SemanticIR support;
- `OOF-IF1..OOF-IF4` live diagnostics;
- `OOF-IF5` unowned and out of v0;
- derivative `OOF-TY0` accepted as secondary Unknown-propagation output;
- runtime/evaluator, release evidence, public claims, Spark, and public API/CLI
  remain closed.

Accepted release-harness and official evidence still say:

```text
release_scope.scope: repo_local_compiler_rc
release_scope.excluded_features: ["branch_conditional_if_expr"]
exclusion_basis: S3-R164-C4-A Portfolio acceptance of first_rc_excludes_branch_conditional_if_expr
public_claims_authorized: false
production_runtime_authorized: false
```

The combined package/profile-source smoke also carries:

```text
non_claims.no_branch_conditional_claim: true
```

These packets are historical evidence for a specific release/readiness window.
They must not be edited or relabeled after the fact.

---

## Explicit Answers

### Should accepted alpha / first-RC / release evidence remain unchanged?

Yes.

Accepted evidence packets are historical artifacts. R190 internal support landed
after the first-RC exclusion decision, so the old packets must continue to show
`branch_conditional_if_expr` excluded.

### May a future harness delta remove `branch_conditional_if_expr` from excluded features?

Not in existing accepted evidence.

A future route may create a new evidence packet with a new label and timestamp.
That new packet may either:

- keep historical `release_scope.excluded_features` unchanged and add an
  `internal_compiler_delta.if_expr_v0` section; or
- use a new evidence scope that does not inherit the first-RC excluded-feature
  list.

It must not rewrite R165/R168/R183 outputs or claim that prior alpha evidence
covered `if_expr`.

### Does runtime/evaluator closure block a harness delta?

No for a compiler-only delta. Yes for any runtime/demo/all-grammar/public claim.

A bounded delta may prove `if_expr` compile/diagnostic/SemanticIR behavior
through existing compiler CLI/API surfaces. It must not run or claim runtime
evaluation, lazy branch execution, production execution, or public demo support.

### Should proof-summary hygiene precede a harness delta?

Recommended: yes, if the next evidence packet includes negative `if_expr`
diagnostic cases.

The derivative `OOF-TY0` wording debt is easy for humans and machines to
misread. A small proof-hygiene card should run before or be a prerequisite to a
release-harness delta that records negative `if_expr` cases.

### Do public release/demo/all-grammar claims remain closed?

Yes.

No public release/demo/stable/production/all-grammar claim opens from R190/R191
or this design.

### Does Spark remain out of scope?

Yes.

No Spark fixtures, classes, ids, integration, or public evidence should enter
the release-harness delta route.

---

## Option Matrix

| Option | Description | Viable | Notes |
| --- | --- | --- | --- |
| 1 | Keep release evidence unchanged and explicitly historical | Yes | Required baseline; old packets must not mutate. |
| 2 | Open later bounded release-harness delta proof | Yes, later | Compiler-only new packet may be useful after hygiene. |
| 3 | Route proof-summary hygiene first | Yes, preferred first | Prevents derivative `OOF-TY0` / Spark non-claim ambiguity from leaking into new evidence. |
| 4 | Hold/pause because runtime/evaluator support remains closed | Partly | Hold public/runtime claims, but compiler-only delta need not wait. |
| 5 | Redirect to runtime/evaluator design before harness work | Not required | Runtime design is required only for runtime claims, not compiler compile evidence. |

---

## Option 1: Keep Existing Evidence Historical

Recommendation:

```text
accept as the present state and keep old evidence immutable
```

Allowed files/artifacts:

- this design track;
- future status/gate docs may reference old evidence as historical.

Forbidden files/artifacts:

- `experiments/compiler_release_acceptance_harness_v0/out/**`
- `experiments/compiler_release_official_first_rc_evidence_v0/out/**`
- `experiments/compiler_release_combined_post_prep_smoke_v0/out/**`
- release harness corpus/runner files;
- package/release docs that imply public claims.

Evidence label rules:

- keep labels such as `official_first_rc_evidence` intact;
- do not relabel pre-R190 packets as `if_expr` evidence;
- keep `branch_conditional_if_expr` excluded in old packets.

Public non-claims:

- no public demo/stable/production/all-grammar claim;
- no runtime/evaluator claim;
- no Spark claim;
- no API/CLI widening.

Release historical wording policy:

```text
Use "historical first-RC/alpha evidence excluded branch_conditional_if_expr"
instead of "if_expr unsupported" when summarizing old release evidence after
R190.
```

Next card boundary:

```text
No implementation card required.
If accepted, Status Curator may record that historical release evidence remains
unchanged after R190 internal compiler support.
```

---

## Option 2: Later Bounded Release-Harness Delta Proof

Recommendation:

```text
viable after proof-summary hygiene, but not the immediate next card
```

Allowed future write scope:

```text
igniter-lang/experiments/branch_conditional_if_expr_release_harness_delta_v0/**
igniter-lang/docs/tracks/branch-conditional-if-expr-release-harness-delta-proof-v0.md
```

Optional read-only inputs:

- existing compiler release harness corpus and summaries;
- R190 implementation proof summary;
- R191 docs/spec sync track;
- `typechecker.rb` and `semanticir_emitter.rb` as read-only evidence.

Forbidden files/artifacts:

- existing accepted release evidence `out/**` packets;
- existing release harness corpus/runner unless separately authorized;
- `.gem`, tag, publish, signing, deploy, or package outputs;
- public docs/README release claims;
- `lib/**`, parser, TypeChecker, SemanticIR, assembler, runtime code;
- Spark files/fixtures/data.

Evidence label rules:

```text
evidence_label: if_expr_internal_compiler_delta
scope: post_r190_internal_compiler_support_delta
not_official_rc_evidence: true
does_not_relabel_prior_release_evidence: true
release_historical_exclusion_preserved: true
runtime_evaluator_claim: false
public_claims_authorized: false
spark_claim: false
```

Suggested future command/proof matrix:

| ID | Check | Expected |
| --- | --- | --- |
| CM-0 | Syntax check future proof runner | PASS |
| CM-1 | Positive minimal `if_expr` compile via existing CLI | PASS / `.igapp` written inside delta out dir |
| CM-2 | Positive nested `if_expr` compile via existing CLI | PASS / `.igapp` written inside delta out dir |
| CM-3 | Positive minimal `if_expr` compile via existing Ruby API | PASS |
| CM-4 | Negative non-Bool condition | refusal with `OOF-IF1`; unsupported-`if_expr` `OOF-TY0` absent |
| CM-5 | Negative missing else | refusal with `OOF-IF2`; derivative `OOF-TY0` separated as secondary if present |
| CM-6 | Negative branch type mismatch | refusal with `OOF-IF3`; derivative `OOF-TY0` separated as secondary if present |
| CM-7 | Negative empty branch | refusal with `OOF-IF4`; derivative `OOF-TY0` separated as secondary if present |
| CM-8 | SemanticIR shape for positive case | flat `condition` / `then_branch` / `else_branch`, no branch wrapper |
| CM-9 | Old evidence immutability check | prior summaries unchanged by hash or read-only comparison |
| CM-10 | No public/runtime/Spark/API claim scan | PASS |
| CM-11 | Outputs contained under delta experiment `out/` | PASS |

Future summary shape:

```json
{
  "kind": "branch_conditional_if_expr_release_harness_delta_summary",
  "evidence_label": "if_expr_internal_compiler_delta",
  "scope": "post_r190_internal_compiler_support_delta",
  "status": "PASS",
  "historical_release_evidence": {
    "unchanged": true,
    "excluded_features_preserved": ["branch_conditional_if_expr"]
  },
  "compiler_delta": {
    "positive_compile": "PASS",
    "negative_diagnostics": "PASS",
    "semanticir_shape": "PASS"
  },
  "non_claims": {
    "not_official_rc_evidence": true,
    "no_release_execution": true,
    "no_runtime_evaluator_claim": true,
    "no_public_demo_stable_production_all_grammar_claim": true,
    "no_spark_claim": true,
    "no_public_api_cli_widening": true
  }
}
```

This route proves a compiler feature delta only. It does not prove release
readiness, runtime execution, public demo readiness, or all-grammar support.

---

## Option 3: Proof-Summary Hygiene First

Recommendation:

```text
preferred immediate next boundary
```

Allowed future write scope:

```text
igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/**
igniter-lang/docs/tracks/branch-conditional-if-expr-v0-proof-summary-hygiene-v0.md
```

Allowed changes:

- annotate derivative `OOF-TY0` as secondary type-propagation output, not
  unsupported-`if_expr`;
- add `oof_ty0_for_if_expr_absent: true` or equivalent explicit field for all
  negative `if_expr` cases;
- add or align `no_spark_claim` in proof summary `non_claims`;
- regenerate only the proof-owned summary/output files.

Forbidden changes:

- TypeChecker/SemanticIR behavior;
- release harness/evidence files;
- public docs/README release claims;
- runtime/evaluator/Spark/API/CLI surfaces.

Evidence label rules:

```text
evidence_label: proof_summary_hygiene
no_semantic_change: true
no_release_evidence_change: true
```

Suggested command/proof matrix:

| ID | Check | Expected |
| --- | --- | --- |
| CM-0 | `ruby -c branch_conditional_if_expr_v0_implementation_proof.rb` | PASS |
| CM-1 | `ruby branch_conditional_if_expr_v0_implementation_proof.rb` | PASS / same semantic checks |
| CM-2 | Negative cases separate primary `OOF-IF*` from secondary derivative `OOF-TY0` | PASS |
| CM-3 | Unsupported-`if_expr` `OOF-TY0` absent in all cases | PASS |
| CM-4 | `no_spark_claim` present and true | PASS |
| CM-5 | Closed-surface scan: no release/runtime/public/API/Spark edits | PASS |

Why first:

- it closes the ambiguity R190/R191 carried forward;
- it makes any later harness-delta negative cases machine-readable;
- it is smaller and lower-risk than a release-harness delta.

---

## Option 4: Hold/Pause Because Runtime Remains Closed

Recommendation:

```text
use as public/runtime guard, not as total compiler-delta blocker
```

Runtime/evaluator closure blocks:

- public demo support;
- runtime/lazy branch execution claims;
- production readiness claims;
- all-grammar claims;
- any release wording that implies end-to-end evaluation.

Runtime/evaluator closure does not block:

- docs/spec internal compiler support wording;
- proof-summary hygiene;
- a future compiler-only harness delta that compiles/diagnoses/lowers `if_expr`
  without runtime claims.

Next card boundary if C3-A selects hold:

```text
No immediate harness delta.
Carry proof-summary hygiene as optional low-risk cleanup.
Revisit release-harness delta only when a new release-readiness route opens.
```

---

## Option 5: Runtime/Evaluator Design Before Harness Work

Recommendation:

```text
not needed before compiler-only harness delta; needed before runtime/public
claim route
```

Runtime design route would need to answer:

- whether branch execution is strict or lazy at RuntimeMachine level;
- whether both branch dependencies are evaluated or selected path only;
- how observations record selected branch and skipped branch;
- how cache keys represent branch selection;
- whether output dependencies remain union or path-sensitive at runtime;
- how errors in unselected branches behave.

That is important future language/runtime work, but it is not a prerequisite for
compiler-only release-harness delta evidence.

Closed until separately authorized:

- runtime implementation;
- RuntimeMachine evaluator changes;
- public/demo/release claims;
- cache/observation policy changes.

---

## Preferred C3-A Decision

Preferred decision:

```text
accept this design;
keep accepted release evidence unchanged and explicitly historical;
open proof-summary hygiene first;
hold release-harness delta until hygiene lands or a later authorization review
names a new evidence packet boundary.
```

Rationale:

- old release evidence is immutable and historically correct;
- R190/R191 already synced internal compiler support into spec;
- proof-summary hygiene is the smallest remaining ambiguity;
- a future harness delta can be clean and self-labeled once hygiene lands;
- runtime/evaluator closure blocks public/runtime claims but not compiler-only
  delta evidence.

---

## C3-A Decision Options

| Option | Decision text | Consequence |
| --- | --- | --- |
| A: Accept preferred boundary | Keep historical release evidence unchanged; open proof-summary hygiene first; harness delta later by separate authorization | Recommended |
| B: Accept and open harness delta immediately | New compiler-only delta packet may open now with strict label/non-claims | Viable but higher ambiguity unless hygiene is bundled |
| C: Hold all harness work until runtime design | No compiler-delta evidence until runtime questions progress | Conservative; not required for compile-only evidence |
| D: Redirect to runtime/evaluator design | Start branch runtime/lazy execution design | Useful later, but premature for release evidence wording |
| E: Status-only close | Record that no release-harness reaction is needed now | Viable if project wants to pause this lane |

Preferred: **Option A**.

---

## Exact Next Card Boundary

Preferred next card:

```text
Card: S3-R192-C2-P1
Agent: [Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: branch-conditional-if-expr-proof-summary-hygiene-v0
Route: UPDATE
Depends on:
- S3-R192-C1-D

Goal:
Close R190/R191 proof-summary hygiene before any release-harness delta evidence.

Allowed write scope:
- igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/**
- igniter-lang/docs/tracks/branch-conditional-if-expr-proof-summary-hygiene-v0.md

Must prove:
- semantic checks remain PASS;
- unsupported-if_expr OOF-TY0 remains absent;
- derivative OOF-TY0 is explicitly marked secondary where present;
- no_spark_claim is present and true in proof summary non_claims;
- no release harness/evidence, runtime, public API/CLI, Spark, or docs/spec
  files are edited.
```

Alternative later card after hygiene:

```text
Track: branch-conditional-if-expr-release-harness-delta-proof-v0
Route: UPDATE
Goal: produce a new post-R190 compiler-only if_expr delta evidence packet,
without mutating accepted release evidence or making runtime/public claims.
```

---

## Closed Surfaces

Remain closed:

- accepted alpha / first-RC / release evidence mutation;
- release execution, publish, yank, tag, sign, deploy;
- public release/demo/stable/production/all-grammar claims;
- runtime/evaluator implementation or lazy branch execution;
- release harness mutation unless separately authorized;
- public API/CLI widening;
- Spark fixtures, integration, public evidence, or production behavior;
- parser/classifier/orchestrator/assembler/root require changes;
- `.igapp`, manifest, sidecar, artifact-hash, golden migration;
- loader/report, `CompilationReport`, `CompilerResult`, CompatibilityReport;
- Ledger/TBackend, BiHistory, stream/OLAP, cache, deployment, production.

