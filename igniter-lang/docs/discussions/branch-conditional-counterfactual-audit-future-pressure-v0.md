# Branch Conditional Counterfactual Audit Future Pressure v0

Status: captured / future-design-pressure
Date: 2026-05-28
Source: Portfolio discussion after R197 proof-local if_expr runtime/evaluator acceptance

---

## Intent

Capture the future design idea that Igniter branch conditionals can preserve
explainability for both the executed branch and the non-executed branch.

This document does not authorize implementation. It records a design pressure
for future work after the current `if_expr` live runtime/evaluator boundary is
understood.

Working phrase:

```text
Runtime is lazy.
Audit is aware.
```

---

## Current Accepted Baseline

Current `if_expr` direction:

- compile/typechecking sees the full branch structure;
- condition must be `Bool`;
- then/else branches must be value-producing;
- then/else branch value types must match;
- static dependencies remain the union of condition, then branch, and else
  branch;
- runtime/evaluator semantics are lazy;
- only the selected branch is evaluated;
- the non-selected branch must not execute;
- dynamic selected-branch dependency tracking is deferred.

R197 proof-local evidence accepted:

```text
RT-IF1..RT-IF13: PASS
sub-checks: 54/54 PASS
non-selected branch behavior: proven not evaluated
error surface: proof-local / non-canonical
live runtime implementation: closed
```

---

## Concept

`if_expr` can be viewed as a branch superposition with two distinct planes:

```text
actual path:
  the selected branch that runtime really evaluates

latent / counterfactual path:
  the non-selected branch that runtime does not evaluate,
  but the compiler/audit layer can still describe, inspect, or model
```

This is intentionally different from ordinary runtime execution. The runtime
must not eagerly evaluate the latent branch. The audit layer may later explain
what the latent branch contains, what it would require, and what might have
happened under a different condition.

---

## Why This Matters

Most languages answer only:

```text
this condition was true/false, so this branch ran
```

Igniter can eventually answer:

```text
this condition was false, so this branch ran;
the other branch was not executed;
the other branch would have depended on these inputs;
the other branch would have produced this kind of value or failed for this
reason under a counterfactual run;
no side effects from that branch were executed in the actual run.
```

This fits Igniter's larger identity as a contract, artifact, explanation, and
audit system rather than only an expression evaluator.

---

## Possible Future Levels

### Level 1: Static Branch Audit

No execution of the latent branch.

Potential report shape:

```text
condition:
  actual_value: false
selected_branch: else
latent_branch: then
latent_branch_static:
  dependencies: [...]
  output_type: ...
  possible_diagnostics: [...]
```

This can use compiler/typechecker/SemanticIR knowledge only.

### Level 2: Counterfactual Dry Run

The latent branch may be evaluated only in an explicitly isolated dry-run mode.

Constraints:

- no effects;
- no production authority;
- no mutation of actual runtime result;
- no cache/dependency authority unless separately designed;
- no implicit execution during normal runtime.

Potential report shape:

```text
actual:
  selected_branch: else
  result: ...

counterfactual:
  assumed_condition: true
  would_select: then
  would_result: ...
  would_require: [...]
  would_fail_with: null
```

### Level 3: Comparison Report

Compare actual and counterfactual paths.

Potential report shape:

```text
comparison:
  result_delta: ...
  dependency_delta: ...
  risk_delta: ...
  missing_inputs_for_counterfactual: [...]
```

This level is useful for demos, debugging, business explanation, and later
acceptance harnesses, but it is not required for initial live runtime support.

---

## Required Boundaries

Any future counterfactual/audit work must preserve these boundaries unless a
later card explicitly narrows them:

- normal runtime remains lazy;
- non-selected branch remains not executed in normal runtime;
- counterfactual execution, if any, must be explicit;
- counterfactual execution must be effect-free;
- counterfactual output must not replace actual result;
- counterfactual diagnostics must not be canonized accidentally;
- dynamic dependency tracking remains separate from explanatory call tracing;
- public API/CLI widening remains closed until separately authorized;
- release/demo/stable/production/all-grammar claims remain closed until
  separately authorized.

---

## Pressure On Live Runtime Design

The near-term live runtime/evaluator design does not need to implement
counterfactual audit.

However, it should avoid choices that would make future branch audit needlessly
opaque. A good live runtime design should preserve:

- explicit condition / selected-branch shape;
- clear separation between selected evaluation and latent branch metadata;
- clear place where an evaluation trace could later be collected;
- no conflation of proof instrumentation with dependency authority;
- no hidden eager branch evaluation.

---

## Non-Goals For Current Main Line

Not authorized by this document:

- live counterfactual evaluator implementation;
- public `counterfactual` API or CLI;
- runtime diagnostic vocabulary;
- path-sensitive dependency tracking;
- cache invalidation changes;
- effect sandboxing;
- release/demo claims.

This document is future pressure only.

