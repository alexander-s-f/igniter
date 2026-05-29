# Branch Conditional Counterfactual Audit Boundary Decision v0

Card: S3-R204-C4-A  
Agent: `[Portfolio Architect Supervisor]`  
Role: `portfolio-architect-supervisor`  
Track: `branch-conditional-counterfactual-audit-boundary-decision-v0`  
Route: UPDATE  
Status: done / accepted-boundary-authorize-proof-local-concept-route  
Date: 2026-05-29

Depends on:
- S3-R204-C1-D
- S3-R204-C2-P1
- S3-R204-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-design-boundary-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-assumptions-capsule-fit-analysis-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-design-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round203-status-curation-v0.md`
- `igniter-lang/docs/proposals/PROP-032-assumptions-block-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-future-pressure-v0.md`

---

## Decision

Decision:

```text
accept the if_expr counterfactual-audit / branch-intention boundary
accept Level 1 static branch audit as the only opened conceptual level
accept assumptions as a candidate premise capsule, not the full branch-intention surface
authorize a later proof-local concept route
do not authorize live implementation
do not authorize grammar/parser/source syntax mutation
do not authorize non-selected branch evaluation
do not authorize public counterfactual/runtime claims
```

The accepted principle is:

```text
Runtime is lazy.
Audit is aware.
```

Meaning:

- live runtime continues to evaluate only the selected branch;
- audit/proof may inspect branch structure statically;
- latent branches may be explained as static intentions;
- latent branches must not be evaluated to explain them.

---

## Accepted Boundary

Accepted Level 1 boundary:

```text
Static Branch Audit / Branch Intention
```

The language may know and explain:

- actual branch label;
- latent branch label;
- condition expression structure;
- actual condition value when already observed by actual execution proof;
- branch expression kinds;
- resolved type facts;
- static refs/deps as explanatory-only metadata;
- optional assumption premise references;
- non-execution guarantee for latent branch.

The language must not claim for latent branches:

- runtime value;
- runtime failure;
- side effect;
- temporal/backend read result;
- runtime readiness;
- cache/dependency authority;
- production behavior.

---

## Branch-Intention Vocabulary Stance

Accepted vocabulary for the next proof-local concept route:

| Term | Accepted meaning |
| --- | --- |
| `branch_intention` | Static explanatory record for an `if_expr` branch pair. |
| `actual_branch` | Branch selected by actual evaluated condition. |
| `latent_branch` | Branch not selected and not evaluated. |
| `branch_role` | `actual` or `latent`. |
| `branch_label` | `then` or `else`. |
| `condition_observation` | Actual-path condition observation only, if already available. |
| `static_branch_metadata` | Typed/SemanticIR-derived facts. |
| `intention_source` | Static/proof-local source of explanation. |
| `explanatory_only` | Non-authority marker. |
| `non_execution_guarantee` | Positive marker that latent branch did not run. |

Forbidden for Level 1:

```text
would_result
would_output
would_fail
counterfactual result
latent runtime value
latent runtime failure
```

Those terms imply execution and belong only to a separately authorized future
Level 2 dry-run route, if ever opened.

Any new `intention_source` value, especially one derived from execution, requires
explicit later authorization.

---

## Assumptions Capsule Stance

Accepted stance:

```text
assumptions are the leading candidate capsule for branch premises
assumptions are not the whole branch-intention capsule
SemanticIR remains the native structural source for branch shape
```

PROP-032 `assumptions {}` currently provides named, typed, traceable epistemic
premises. That is highly relevant to branch intentions when a branch is shaped
by a threshold, heuristic, calibration, or declared world premise.

But branch intention has two dimensions:

1. structural branch facts: condition, then/else shape, expression kind,
   resolved type, static refs/deps;
2. epistemic premises: optional assumption references explaining why the branch
   exists or what premise shapes it.

PROP-032 covers dimension 2. It does not by itself cover the full branch
intention model.

Binding constraints:

- `uses assumptions NAME` remains contract-body only under current PROP-032;
- branch-level `uses assumptions` syntax is not authorized;
- proof-local assumptions-shaped metadata does not amend PROP-032;
- proof-local assumptions-shaped metadata does not create canonical grammar,
  parser, TypeChecker, SemanticIR, report, receipt, CLI, or public API shape;
- proof-local `assumption_refs` must be explicitly disclaimed as branch premise
  labels, not PROP-032 receipt fields.

---

## Authorized Next Route

Authorized next route:

```text
Card: S3-R205-C1-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: branch-conditional-counterfactual-audit-concept-proof-v0
Route: UPDATE
Depends on:
- S3-R204-C5-S
```

Route class:

```text
proof-local concept proof
not live implementation
not public feature
not runtime integration
```

Allowed write scope:

```text
igniter-lang/experiments/branch_conditional_counterfactual_audit_concept_proof_v0/**
igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-concept-proof-v0.md
```

Read-only sources may include:

```text
igniter-lang/docs/tracks/stage3-round203-status-curation-v0.md
igniter-lang/docs/proposals/PROP-032-assumptions-block-v0.md
igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-future-pressure-v0.md
igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-boundary-decision-v0.md
igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/out/branch_conditional_if_expr_runtime_smoke_consumer_v0_summary.json
igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/out/branch_conditional_if_expr_v0_implementation_proof_summary.json
```

The proof may build proof-local descriptors from hand-authored typed/SemanticIR
`if_expr` shapes and/or accepted proof summaries. It must not change compiler,
runtime, report, API, or public surfaces.

---

## Required Concept Proof Matrix

The next proof-local concept route must cover at least:

| ID | Required proof | Expected status |
| --- | --- | --- |
| BIA-1 | Actual branch identified from condition value | `actual_branch` recorded; selected output source cited if using actual proof evidence. |
| BIA-2 | Latent branch recorded without evaluation | `evaluated: false`; `non_execution_guarantee: true`. |
| BIA-3 | Static branch metadata extracted from typed/SemanticIR shape | branch expression kind and resolved type recorded. |
| BIA-4 | Static refs/deps recorded as explanatory-only | `dependency_authority: false`; `cache_authority: false`. |
| BIA-5 | Assumption premise refs linked when present | assumptions are optional premise capsule, not required for every branch. |
| BIA-6 | Latent branch with would-fail/unsupported kind | recorded structurally only; no runtime failure produced; latent branch not evaluated even to prove failure. |
| BIA-7 | Lazy runtime/evaluator invariant preserved | existing lazy proof cited or read-only rerun; no live behavior change. |
| BIA-8 | Public/release/Spark/API/CLI non-claims | non-claims recorded. |
| BIA-9 | Parser/grammar/source syntax unchanged | no branch-level `uses assumptions`; no grammar mutation. |
| BIA-10 | Report/result/CompatibilityReport unchanged | concept summary only. |

Every branch-intention record must carry:

```json
{
  "explanatory_only": true,
  "authority": {
    "dependency_authority": false,
    "cache_authority": false,
    "runtime_readiness_authority": false,
    "public_claim": false
  }
}
```

The proof summary must include a schema-level disclaimer:

```text
assumption_refs in this proof are proof-local branch premise labels,
not PROP-032 receipt assumption_refs and not a PROP-032 grammar extension
```

---

## Non-Selected Branch Evaluation Stance

Non-selected branch evaluation remains closed.

The proof may inspect latent branch structure. It may not:

- call evaluator on latent branch;
- call external evaluator on latent branch;
- execute `apply`, `field_access`, `tbackend_read`, effects, or runtime reads
  from latent branch;
- compute latent branch value;
- produce latent branch runtime failure;
- produce `would_result`, `would_output`, or `would_fail`;
- update cache/dependency state from latent branch structure.

Level 2 counterfactual dry-run remains held and requires a separate later gate.

---

## Metadata / Source Stance

Accepted source hierarchy for Level 1:

| Source | Status |
| --- | --- |
| SemanticIR static shape | Preferred structural source. |
| TypeChecker branch wrappers | Useful proof input. |
| R203 RuntimeSmoke proof summary | Actual-path evidence only; not latent execution. |
| PROP-032-shaped assumptions metadata | Candidate premise capsule; proof-local only. |
| Runtime trace | Actual-path evidence only. |
| New source syntax | Closed. |
| Public report/API shape | Closed. |

---

## Pressure Notes Disposition

C3-X reported 8/8 PASS, no blockers, and three non-blocking notes.

### NB-1: `assumption_refs` field-name collision

Disposition:

```text
accepted as a binding proof-summary disclaimer requirement
```

The next proof summary must distinguish proof-local branch premise labels from
PROP-032 receipt `assumption_refs`.

### NB-2: Assumptions-shaped metadata drift

Disposition:

```text
accepted as standing non-promotion policy
```

Proof-local use of assumptions-shaped descriptors does not grant canonical
PROP-032 status and cannot be promoted to canonical shape without a separate
PROP or PROP-032 amendment decision.

### NB-3: Latent failure case must remain static

Disposition:

```text
accepted as binding BIA-6 constraint
```

BIA-6 must derive latent-branch structural facts from typed/SemanticIR structure
only. It must not evaluate the latent branch even to demonstrate failure.

---

## Explicit Answers

### Is the counterfactual audit boundary accepted?

Yes, as Level 1 static branch audit / branch-intention boundary.

### May the language know non-selected branch intentions?

Yes, as static explanatory metadata derived from typed/SemanticIR structure and
optional proof-local premise refs.

### May non-selected branches be evaluated?

No.

### Are assumptions accepted as the native capsule?

Partly.

Assumptions are accepted as the leading candidate capsule for branch premises,
not as the whole branch-intention surface and not as branch-level syntax.

### May proof-local concept work open next?

Yes. S3-R205-C1-I is authorized as a proof-local concept proof under the narrow
write scope and matrix above.

### May live implementation open next?

No.

### Do runtime/evaluator/RuntimeSmoke remain unchanged?

Yes.

### Does dependency/cache authority remain closed?

Yes.

### Do public runtime/counterfactual/demo claims remain closed?

Yes.

### Do Spark/API/CLI remain closed?

Yes.

---

## Remaining Closed Surfaces

Remain closed:

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
- effect sandboxing;
- branch replay;
- runtime failure/value production for latent branch;
- `CompilerOrchestrator`, `CompilerResult`, `CompilationReport`, Diagnostics;
- report/result/receipt/CompatibilityReport shape changes;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden mutation outside
  the next proof-owned output directory;
- release evidence rewrite or relabeling;
- release commands, release execution, RubyGems publish, yank, tag, push, sign,
  deploy;
- public demo/release/stable/production/all-grammar/runtime/counterfactual
  claims;
- public API/CLI widening;
- loader/report or CompatibilityReport behavior;
- cache/path-sensitive dependency tracking;
- RuntimeMachine/Gate 3 production authority, Ledger/TBackend production,
  BiHistory, stream/OLAP, production runtime;
- Spark data, fixtures, specs, ids, integration, or demo behavior.

---

## Compact Decision Summary

R204 accepts the `if_expr` counterfactual-audit / branch-intention boundary as
Level 1 static branch audit.

The language may know and explain latent branch intentions without evaluating
latent branches. SemanticIR/typed structure is the native structural source.
PROP-032 assumptions are accepted as a candidate capsule for branch premises,
not as the whole branch-intention model and not as branch-level syntax.

The next route may be a proof-local concept proof only. Live implementation,
parser/grammar changes, runtime/evaluator/RuntimeSmoke changes,
dependency/cache authority, public counterfactual/runtime claims, Spark/API/CLI,
release, and production remain closed.

---

## Exact Next Dispatch Recommendation

Immediate next status card:

```text
Card: S3-R204-C5-S
Agent: [Status Curator]
Role: status-curator
Track: stage3-round204-status-curation-v0
Route: UPDATE
Depends on:
- S3-R204-C1-D
- S3-R204-C2-P1
- S3-R204-C3-X
- S3-R204-C4-A
```

After C5-S, authorized next proof-local route:

```text
Card: S3-R205-C1-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: branch-conditional-counterfactual-audit-concept-proof-v0
Route: UPDATE
Depends on:
- S3-R204-C5-S
```

Goal:

```text
Build proof-local concept evidence that if_expr branch intentions can be
statically described for actual and latent branches without evaluating latent
branches, using explanatory-only metadata and optional assumptions-shaped
premise refs.
```
