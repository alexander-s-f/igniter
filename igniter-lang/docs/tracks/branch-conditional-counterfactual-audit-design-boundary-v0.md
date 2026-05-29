# Branch Conditional Counterfactual Audit Design Boundary v0

Card: S3-R204-C1-D  
Agent: `[Compiler/Grammar Expert]`  
Role: `compiler-grammar-expert`  
Track: `branch-conditional-counterfactual-audit-design-boundary-v0`  
Route: UPDATE  
Depends on: S3-R203-C5-S  
Status: done  
Date: 2026-05-29

---

## Purpose

Design a narrow counterfactual-audit / branch-intention boundary for `if_expr`:
the language may know and explain non-selected branch intentions without
evaluating non-selected branches.

This card does not edit code, does not authorize implementation, does not
authorize parser or grammar changes, and does not authorize runtime changes,
counterfactual dry-runs, or non-selected branch execution.

---

## Inputs Read

- `docs/tracks/stage3-round203-status-curation-v0.md`
- `docs/tracks/branch-conditional-if-expr-runtime-smoke-consumer-proof-acceptance-decision-v0.md`
- `docs/discussions/branch-conditional-counterfactual-audit-future-pressure-v0.md`
- `docs/proposals/PROP-032-assumptions-block-v0.md`
- `docs/tracks/branch-conditional-if-expr-v0-implementation-v0.md`
- `docs/tracks/branch-conditional-if-expr-v0-implementation-acceptance-decision-v0.md`
- `lib/igniter_lang/semanticir_expression_evaluator.rb`
- `experiments/runtime_machine_memory_proof/compiled_program.rb`
- `lib/igniter_lang/runtime_smoke.rb`

---

## Current Accepted Baseline

Compiler/language baseline:

- expression-level `if_expr` v0 is accepted as internal compiler support;
- parser shape already existed and was not widened;
- TypeChecker owns `OOF-IF1..OOF-IF4`;
- `OOF-IF5` remains out/unowned;
- TypeChecker shape has `cond`, `then` branch wrapper, `else` branch wrapper,
  `resolved_type`, and union `deps`;
- SemanticIR shape is flat:
  - `kind: "if_expr"`;
  - `condition`;
  - `then_branch`;
  - `else_branch`;
  - `resolved_type`;
- SemanticIR `if_expr` has no `deps` key.

Runtime/evaluator baseline:

- `SemanticIRExpressionEvaluator` is lazy;
- proof RuntimeMachine consumes `if_expr` through the evaluator adapter;
- RuntimeSmoke has proof-context consumer evidence only;
- non-selected branch evaluation is forbidden;
- dynamic selected-branch dependency tracking remains deferred;
- public runtime support and production/runtime claims remain closed.

R203 maximum accepted claim:

```text
RuntimeSmoke has proof-context consumer evidence for if_expr through the
existing proof RuntimeMachine path.
```

This is not public runtime support.

---

## Design Principle

The counterfactual-audit boundary should follow:

```text
Runtime is lazy.
Audit is aware.
```

Meaning:

- runtime evaluates only the selected branch;
- audit/explanation may inspect static branch structure;
- non-selected branch is never executed merely to explain it;
- static explanation is not cache/dependency authority;
- future counterfactual dry-run, if ever opened, must be explicit, isolated,
  effect-free, and separately authorized.

---

## Branch-Intention Vocabulary

Recommended vocabulary for design/proof discussion:

| Term | Meaning |
| --- | --- |
| `branch_intention` | Static explanation record for an `if_expr` branch pair. |
| `actual_branch` | The branch selected by the evaluated condition. |
| `latent_branch` | The branch not selected and not evaluated. |
| `branch_role` | `actual` or `latent`. |
| `branch_label` | `then` or `else`. |
| `condition_observation` | Runtime observation of condition value, if available from actual execution proof. |
| `static_branch_metadata` | Compile-time/IR-derived information about a branch. |
| `intention_source` | Source of the explanation: `semanticir_static`, `typed_static`, `assumption_ref`, `proof_summary`, or future source. |
| `explanatory_only` | Marker that the record has no dependency/cache/runtime authority. |
| `non_execution_guarantee` | Statement that latent branch was not evaluated. |

Avoid the terms `would_result`, `would_output`, or `would_fail` for v0 static
branch intention unless an explicit future dry-run proof exists. Those terms
imply execution.

Preferred v0 phrase:

```text
latent branch static intention
```

Not:

```text
counterfactual result
```

---

## Selected vs Non-Selected Boundary

| Plane | May record | Must not claim |
| --- | --- | --- |
| Selected / actual branch | selected branch label, condition value, evaluated output, proof trace if available | public runtime support, production support, path-sensitive dependency authority |
| Non-selected / latent branch | branch label, expression shape, resolved type, static refs/deps where derivable, assumption refs, declared capability/contract refs where already present | value, failure, side effect, temporal read result, runtime readiness, cache authority |

The selected branch may have runtime evidence because it was evaluated.

The latent branch may have static evidence only. It must not gain runtime
evidence through normal execution.

---

## Static Intention Source Candidates

| Candidate | Usefulness | Status |
| --- | --- | --- |
| SemanticIR `if_expr` node | Best current structural source: condition/then/else/resolved_type are explicit and recursive | Preferred v0 source. |
| TypeChecker branch wrappers | Carries branch wrappers and union deps; useful for proof analysis | Good proof input, not runtime artifact. |
| Contract-level `assumption_refs` | Carries epistemic premises via PROP-032 | Useful as "why/premise" link, not all branch intent. |
| PROP-032 `assumption_registry` | Native capsule for declared premises | Candidate, not sole branch-intention carrier. |
| Report-only proof summary | Safest first evidence carrier | Preferred for first concept proof. |
| Future syntax surface | Could express explicit author branch intent | Held; no parser/grammar changes. |
| Runtime trace | Can identify actual branch path | Actual-path evidence only; not latent execution. |

Recommended v0 stance:

```text
branch intention is static metadata derived from existing typed/SemanticIR shape,
optionally linked to assumption_refs when the program already declares relevant
assumptions.
```

Do not add branch-intention syntax now.

---

## Assumptions Relationship

PROP-032 `assumptions {}` is likely the native capsule for epistemic premises,
but not the native capsule for every branch intention.

Use assumptions when:

- a branch condition or branch choice relies on an explicit premise;
- the program already has `uses assumptions NAME`;
- the explanation wants to say "this branch logic is shaped by declared premise
  NAME."

Do not require assumptions for every `if_expr`.

Branch intention has at least two dimensions:

1. structural branch shape: condition, then branch, else branch, resolved type;
2. epistemic premise: optional assumption refs that explain why the branch
   exists or why a threshold/heuristic is used.

Assumptions cover dimension 2. SemanticIR covers dimension 1.

---

## What The Language May Know Without Evaluation

For a latent branch, the language may know:

- branch label: `then` or `else`;
- branch role: `latent`;
- condition expression structure;
- evaluated condition value if actual execution proof recorded it;
- branch expression shape/kind;
- resolved `if_expr` type;
- static refs/dependencies if derived from typed or SemanticIR structure;
- contract-level `assumption_refs`;
- declared static capability/contract refs already present in IR or metadata;
- possible compiler diagnostics that existed before runtime.

The language may not know:

- latent branch runtime value;
- latent branch failure result;
- latent branch side effects;
- latent branch temporal read payload;
- latent branch external capability readiness;
- latent branch cache key or freshness;
- latent branch production/runtime behavior.

---

## Runtime Must Not

Runtime/evaluator must not:

- evaluate a non-selected branch for explanation;
- call `external_evaluator` for a non-selected branch;
- perform `tbackend_read` from a latent branch;
- execute effects from a latent branch;
- compute a latent branch output value;
- catch and report latent branch runtime failures;
- update cache/dependency state from latent branch contents;
- turn proof call traces into dependency authority;
- emit public diagnostics or public audit reports without later authorization.

The existing lazy behavior in `SemanticIRExpressionEvaluator` and proof
RuntimeMachine must remain unchanged.

---

## Candidate Static Record Shape

Proof-only candidate shape:

```json
{
  "kind": "if_expr_branch_intention",
  "format_version": "0.1.0",
  "source": "semanticir_static",
  "explanatory_only": true,
  "condition": {
    "expr_kind": "ref",
    "actual_value": false,
    "actual_value_source": "runtime_smoke_proof"
  },
  "branches": [
    {
      "branch_label": "then",
      "branch_role": "latent",
      "evaluated": false,
      "expr_kind": "apply",
      "resolved_type": { "name": "Integer", "params": [] },
      "static_refs": ["a", "b"],
      "assumption_refs": ["threshold_policy"],
      "non_execution_guarantee": true
    },
    {
      "branch_label": "else",
      "branch_role": "actual",
      "evaluated": true,
      "expr_kind": "ref",
      "resolved_type": { "name": "Integer", "params": [] },
      "static_refs": ["fallback"],
      "assumption_refs": ["threshold_policy"]
    }
  ],
  "authority": {
    "dependency_authority": false,
    "cache_authority": false,
    "runtime_readiness_authority": false,
    "public_claim": false
  }
}
```

This shape is not canon. It is a proof-local candidate for a future concept
proof only.

---

## Dependencies, Contracts, And Capabilities

Branch intentions may mention contracts, capabilities, refs, or dependencies
only as static explanatory metadata.

Required labels:

```text
explanatory_only: true
dependency_authority: false
cache_authority: false
runtime_readiness_authority: false
```

Static mentions must not:

- change `deps`;
- change cache invalidation;
- change `requirements.json`;
- change CompatibilityReport;
- change loader/report behavior;
- imply runtime capability readiness;
- imply a temporal/backend read occurred.

This keeps branch audit from becoming a hidden dependency/cache migration.

---

## Future Proof-Local Concept Boundary

Recommended next route:

```text
branch-conditional-counterfactual-audit-concept-proof-v0
```

Candidate write scope:

```text
igniter-lang/experiments/branch_conditional_counterfactual_audit_concept_proof_v0/**
igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-concept-proof-v0.md
```

Proof constraints:

- no `lib/` edits;
- no parser/grammar edits;
- no RuntimeSmoke/evaluator/proof RuntimeMachine edits;
- no release/public/Spark/API/CLI changes;
- no runtime dry-run;
- no latent branch evaluation;
- generated summary must mark all records proof-local and explanatory-only.

Possible proof inputs:

- hand-authored SemanticIR `if_expr` nodes;
- emitted SemanticIR from existing compiler proof fixtures;
- accepted RuntimeSmoke proof summary for actual branch condition/output;
- optional PROP-032-style assumption refs if existing fixture data is enough.

---

## Future Proof Matrix

| ID | Proof case | Expected result |
| --- | --- | --- |
| BIA-1 | Actual branch identified from condition value | `actual_branch` recorded, selected output source cited. |
| BIA-2 | Latent branch recorded without evaluation | `evaluated: false`, `non_execution_guarantee: true`. |
| BIA-3 | Static branch metadata extracted from SemanticIR | expression kind and resolved type recorded. |
| BIA-4 | Static refs/deps extracted as explanatory-only | no dependency/cache authority. |
| BIA-5 | Assumption refs linked when present | assumptions are optional premise capsule, not required for every branch. |
| BIA-6 | Non-selected branch with would-fail kind | recorded structurally, not executed, no runtime failure produced. |
| BIA-7 | Runtime evaluator unchanged | existing lazy proofs still pass or are read-only cited. |
| BIA-8 | No public/runtime/release/Spark/API/CLI claims | non-claims recorded. |
| BIA-9 | No parser/grammar changes | source syntax unchanged. |
| BIA-10 | No report/result/CompatibilityReport changes | concept summary only. |

Suggested commands for a later proof route:

```bash
ruby -c igniter-lang/experiments/branch_conditional_counterfactual_audit_concept_proof_v0/branch_conditional_counterfactual_audit_concept_proof_v0.rb
ruby igniter-lang/experiments/branch_conditional_counterfactual_audit_concept_proof_v0/branch_conditional_counterfactual_audit_concept_proof_v0.rb
```

Optional read-only regression commands may cite existing R203/R201/R199 proofs,
but the concept proof should not require new runtime execution.

---

## Explicit Answers

### May non-selected branches be evaluated now?

No.

Non-selected branch evaluation remains forbidden.

### May a future proof inspect non-selected branch structure without evaluation?

Yes.

Static inspection of SemanticIR/typed structure is the recommended next proof
route.

### Should branch intention be static metadata, assumption reference, evidence metadata, or undecided?

For v0: static metadata, optionally linked to assumption refs.

Assumption refs are a candidate capsule for epistemic premises, not the whole
branch-intention model. Evidence metadata remains proof-local until separately
authorized.

### Can branch intentions mention contracts/caps/dependencies without becoming dependency/cache authority?

Yes, only as explicitly explanatory static metadata.

They must carry `dependency_authority: false`, `cache_authority: false`, and
`runtime_readiness_authority: false`.

### Are assumptions likely the native capsule?

For epistemic premises: yes, likely.

For full branch intention: no, assumptions are only one candidate dimension.
SemanticIR structure remains the native structural source.

### Should runtime evaluator behavior remain lazy and unchanged?

Yes.

No runtime behavior change is recommended or authorized.

### Is counterfactual audit a public feature now?

No.

It remains design/proof pressure only.

### May implementation open next or must it wait?

Runtime/compiler implementation must wait.

A proof-only concept route may open next if Architect accepts this design.

---

## Closed Surfaces

- code implementation in this card;
- parser/grammar changes;
- runtime/evaluator changes;
- non-selected branch execution;
- counterfactual dry-run;
- effect sandboxing;
- branch comparison reports;
- RuntimeSmoke changes;
- proof RuntimeMachine changes;
- `CompilerOrchestrator`, `CompilerResult`, `CompilationReport`, Diagnostics;
- SemanticIR schema/canon mutation;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, golden mutation outside a
  future proof-owned output directory;
- release evidence rewrite or relabeling;
- release commands, release execution, RubyGems publish, yank, tag, push, sign,
  deploy;
- public demo/release/stable/production/all-grammar/runtime claims;
- public API/CLI widening;
- loader/report or CompatibilityReport behavior;
- cache/path-sensitive dependency tracking;
- RuntimeMachine/Gate 3 production authority, Ledger/TBackend production,
  BiHistory, stream/OLAP, production runtime;
- Spark data, fixtures, specs, ids, integration, or demo behavior.

---

## Compact Design Summary

The branch-intention boundary is static and explanatory:

```text
actual branch may have runtime evidence because it ran;
latent branch may have static intention metadata because it exists;
latent branch must not be evaluated to explain it.
```

Recommended next route: proof-only concept evidence that inspects existing
typed/SemanticIR `if_expr` structure and optionally links declared assumptions,
while preserving lazy runtime behavior, dependency/cache closure, and all public
non-claims.
