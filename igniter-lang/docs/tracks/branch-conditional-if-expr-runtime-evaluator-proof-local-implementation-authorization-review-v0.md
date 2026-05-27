# Branch Conditional If Expr Runtime Evaluator Proof Local Implementation Authorization Review v0

Card: S3-R197-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-if-expr-runtime-evaluator-proof-local-implementation-authorization-review-v0
Route: UPDATE
Status: done / authorized-proof-local-runtime-evaluator-experiment
Date: 2026-05-27

Depends on:
- S3-R196-C4-S

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round196-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-evaluator-design-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-evaluator-design-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-runtime-evaluator-design-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round195-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-release-harness-delta-proof-acceptance-decision-v0.md`
- `igniter-lang/experiments/branch_conditional_if_expr_release_harness_delta_v0/out/branch_conditional_if_expr_release_harness_delta_summary.json`
- `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb`
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`

---

## Decision

Decision:

```text
authorize proof-local runtime/evaluator experiment
authorize C2-I in this round
authorize local evaluator helper inside experiment only
accept proof-local plain raise / proof-local error object surface
do not require structured runtime.* codes
RT-IF12 must be structural proof only
dynamic dependency tracking remains deferred
live lib runtime/evaluator remains closed
RuntimeSmoke and CompilerOrchestrator changes remain closed
release lane remains paused
public demo/stable/production/all-grammar claims remain closed
Spark/API/CLI remain closed
do not authorize release execution or public claims
```

R196 accepted lazy runtime/evaluator semantics but did not authorize
implementation. This card authorizes only a proof-local experiment to prove
those semantics. It does not authorize live runtime/library integration.

---

## Authorization Basis

Accepted R196 design:

```text
runtime semantics: lazy
evaluation order: condition -> selected branch only -> value
non-selected branch evaluation: forbidden
static dependency union: accepted
dynamic selected-branch dependency tracking: deferred
runtime diagnostics vocabulary: open/provisional
implementation: not yet authorized before this card
```

Relevant current runtime state:

- `RuntimeSmoke` delegates to `experiments/runtime_machine_memory_proof`;
- `runtime_machine_memory_proof/compiled_program.rb` currently supports
  `apply`, `field_access`, `literal`, `ref`, and `tbackend_read`;
- current proof evaluator raises `ArgumentError` for unknown expression kinds;
- no production/library `if_expr` evaluator exists in `lib/`;
- artifact carriage of expressions is not runtime support.

Accepted R195 compiler-only evidence:

```text
evidence_label: if_expr_internal_compiler_delta
evidence_class: post_alpha_compiler_only_delta
status: PASS
checks_total: 39
checks_pass: 39
```

---

## Exact C2-I Boundary

```text
Card: S3-R197-C2-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: branch-conditional-if-expr-runtime-evaluator-proof-local-v0
Route: UPDATE
Depends on:
- S3-R197-C1-A
```

Goal:

```text
Implement the authorized proof-local if_expr runtime/evaluator semantics
experiment.
```

Allowed write scope:

```text
igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/**
igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-evaluator-proof-local-v0.md
```

No other files are authorized.

Required files:

```text
igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/branch_conditional_if_expr_runtime_evaluator_proof_v0.rb
igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/out/branch_conditional_if_expr_runtime_evaluator_proof_summary.json
igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-evaluator-proof-local-v0.md
```

---

## Evaluator Placement

Allowed:

```text
local evaluator helper inside the proof experiment only
```

The helper may copy/adapt minimal expression-evaluation behavior needed for the
proof. It may observe current `runtime_machine_memory_proof` behavior, but must
not modify it.

Not authorized:

- `lib/igniter_lang/**` runtime/evaluator changes;
- `IgniterLang::RuntimeSmoke` changes;
- `CompilerOrchestrator` changes;
- `experiments/runtime_machine_memory_proof/compiled_program.rb` changes;
- assembler or `.igapp` changes;
- public API/CLI changes.

---

## Allowed Error Surface

For this proof-local experiment, allowed error surface:

```text
plain raises and/or proof-local error objects
```

Structured runtime codes are not required.

Do not canonize or publish:

```text
runtime.if_expr_malformed
runtime.if_expr_condition_failed
runtime.if_expr_condition_not_bool
runtime.if_expr_branch_failed
runtime.expression_unsupported
OOF-RT-*
```

The summary may record proof-local error categories as local evidence, but must
state they are non-canonical and not public/runtime diagnostics.

---

## Required Semantics

The proof-local evaluator must implement:

1. Evaluate `condition` first.
2. Require runtime Bool: exactly `true` or `false`.
3. If `true`, evaluate only `then_branch`.
4. If `false`, evaluate only `else_branch`.
5. Return selected branch value.
6. Do not evaluate the non-selected branch.
7. Do not use Ruby truthy/falsy coercion.
8. Fail closed for malformed `if_expr`.
9. Fail closed for unknown selected-path expression kind.
10. Do not fire unknown non-selected-path expression kind.
11. Apply the same lazy semantics recursively for nested `if_expr`.

---

## Required Proof Matrix

The C2-I proof must include RT-IF1..RT-IF13:

| ID | Proof case | Required result |
| --- | --- | --- |
| RT-IF1 | Condition `true` | Only `then_branch` evaluated; value returned. |
| RT-IF2 | Condition `false` | Only `else_branch` evaluated; value returned. |
| RT-IF3 | Non-selected `then_branch` would fail | No failure when condition is `false`. |
| RT-IF4 | Non-selected `else_branch` would fail | No failure when condition is `true`. |
| RT-IF5 | Condition expression fails | Branches are not evaluated; condition failure propagates. |
| RT-IF6 | Selected branch fails | Selected-branch failure propagates. |
| RT-IF7 | Condition returns non-Bool | Runtime fails closed; no truthy/falsy coercion. |
| RT-IF8 | Missing condition / then / else | Runtime fails closed as malformed SemanticIR. |
| RT-IF9 | Unknown selected-path expression kind | Runtime fails closed. |
| RT-IF10 | Unknown non-selected-path expression kind | No failure. |
| RT-IF11 | Nested `if_expr` | Lazy semantics apply recursively. |
| RT-IF12 | Static dependency union vs runtime selected path | Static deps stay union; selected-branch call path structurally proven. |
| RT-IF13 | Closed-surface scan | No live runtime/lib, release, Spark/API/CLI, `.igapp`, docs/spec, or compiler behavior changes. |

RT-IF12 clarification:

```text
RT-IF12 does not require dynamic touch tracing, dependency receipts, or
path-sensitive cache tracking.
```

It may be satisfied by structural proof that the local evaluator calls into only
the selected branch after the condition is evaluated.

---

## Required Summary Shape

The C2-I summary JSON must include at minimum:

```json
{
  "status": "PASS|HOLD|FAIL",
  "checks_total": 0,
  "checks_pass": 0,
  "checks_fail": 0,
  "failed_checks": [],
  "semantics": {
    "lazy": true,
    "non_selected_branch_evaluation": "forbidden",
    "truthy_falsy_coercion": false
  },
  "dependency_policy": {
    "static_union": true,
    "dynamic_selected_branch_tracking": "deferred",
    "rt_if12_requires_dynamic_touch_tracing": false
  },
  "error_surface": {
    "kind": "proof_local_plain_raise_or_error_object",
    "structured_runtime_codes_canonized": false,
    "oof_rt_codes_canonized": false
  },
  "runtime_scope": {
    "proof_local_only": true,
    "live_runtime_integration": false,
    "runtime_smoke_changed": false,
    "compiler_orchestrator_changed": false
  },
  "non_claims": {
    "no_release_execution": true,
    "no_public_demo_claim": true,
    "no_stable_production_all_grammar_claim": true,
    "no_spark_claim": true,
    "no_public_api_cli_widening": true,
    "no_live_runtime_integration": true,
    "no_compiler_behavior_change": true
  }
}
```

The proof may extend this shape, but must not omit these fields.

---

## Command Matrix

Required:

```text
ruby -c igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/branch_conditional_if_expr_runtime_evaluator_proof_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/branch_conditional_if_expr_runtime_evaluator_proof_v0.rb
```

Optional read-only regression:

```text
ruby igniter-lang/experiments/branch_conditional_if_expr_release_harness_delta_v0/branch_conditional_if_expr_release_harness_delta_v0.rb
ruby igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/branch_conditional_if_expr_v0_implementation_proof.rb
```

No release commands are authorized.

---

## Explicit Answers

### May C2-I begin in this round?

Yes.

C2-I is authorized as a proof-local runtime/evaluator experiment.

### May the proof implement a local evaluator helper?

Yes.

Only inside the authorized experiment directory.

### Do live `lib/` runtime/evaluator, `RuntimeSmoke`, and `CompilerOrchestrator` remain closed?

Yes.

No live runtime/library integration is authorized.

### Are plain raises / existing runtime errors accepted for proof-local error surface?

Yes.

Plain raises and/or proof-local error objects are accepted for the proof-local
experiment. Structured runtime codes are not required and must not be canonized.

### Does RT-IF12 require dynamic touch-tracing?

No.

RT-IF12 must be structural proof only and must not introduce dynamic dependency
tracking, dependency receipts, path-sensitive cache keys, or touch-trace
infrastructure.

### Does release lane remain paused?

Yes.

No release execution, publish, yank, tag, sign, or deploy route is opened.

### Do public demo/stable/production/all-grammar claims remain closed?

Yes.

No public/runtime/all-grammar support claim is opened.

### Do Spark/API/CLI remain closed?

Yes.

No Spark, public API, or CLI route is opened.

---

## Closed Surfaces

Remain closed:

- live runtime/evaluator implementation;
- `lib/igniter_lang/**` runtime/evaluator changes;
- `RuntimeSmoke` behavior changes;
- `CompilerOrchestrator` behavior changes;
- `experiments/runtime_machine_memory_proof/compiled_program.rb` changes;
- parser, classifier, TypeChecker, SemanticIR, compiler behavior, assembler;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden mutation;
- release harness mutation or release command execution;
- public demo/release/stable/production/all-grammar claims;
- public API/CLI widening;
- loader/report or CompatibilityReport behavior;
- cache/path-sensitive dependency tracking;
- RuntimeMachine/Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, production
  runtime;
- Spark data, fixtures, specs, ids, integration, or demo behavior.

---

## C2-I Handoff

```text
Status: authorized-proof-local-runtime-evaluator-experiment

Next card:
  S3-R197-C2-I
  branch-conditional-if-expr-runtime-evaluator-proof-local-v0

Allowed scope:
  igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/**
  igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-evaluator-proof-local-v0.md

Do not touch live runtime/lib surfaces.
Do not introduce dynamic dependency tracking.
Do not canonize runtime diagnostic codes.
```
