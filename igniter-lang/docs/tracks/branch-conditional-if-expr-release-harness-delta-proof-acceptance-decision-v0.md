# Branch Conditional If Expr Release Harness Delta Proof Acceptance Decision v0

Card: S3-R195-C3-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: branch-conditional-if-expr-release-harness-delta-proof-acceptance-decision-v0
Route: UPDATE
Status: done / accepted-delta-proof
Date: 2026-05-27

Depends on:
- S3-R195-C1-I
- S3-R195-C2-X

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-release-harness-delta-proof-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-if-expr-release-harness-delta-proof-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round194-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-release-harness-delta-authorization-review-v0.md`
- `igniter-lang/experiments/branch_conditional_if_expr_release_harness_delta_v0/out/branch_conditional_if_expr_release_harness_delta_summary.json`
- `igniter-lang/experiments/branch_conditional_if_expr_release_harness_delta_v0/branch_conditional_if_expr_release_harness_delta_v0.rb`

Historical release evidence status was read through C1-I/C2-X:

- `igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json`
- `igniter-lang/experiments/compiler_release_official_first_rc_evidence_v0/out/official_first_rc_evidence_summary.json`
- `igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0/out/S3R183C2I_20260526T143139Z/combined_post_prep_smoke_summary.json`

---

## Decision

Decision:

```text
accept compiler-only if_expr delta proof
accept evidence_label: if_expr_internal_compiler_delta
accept evidence_class: post_alpha_compiler_only_delta
accept D-1..D-13 proof matrix: 39/39 PASS
accept old release evidence immutability
accept historical branch_conditional_if_expr exclusion as preserved historical fact
accept generated outputs as if_expr_internal_compiler_delta evidence only
keep accepted alpha / first-RC / release evidence unchanged
keep release lane paused
keep runtime/evaluator implementation closed
keep public release/demo/stable/production/all-grammar claims closed
keep Spark/API/CLI closed
keep TypeChecker/SemanticIR/compiler behavior changes closed
allow runtime/evaluator design-only route to open next
do not authorize release execution or public claims
```

R195 successfully adds a new post-alpha compiler-only evidence layer for
accepted internal `if_expr` support. It does not rewrite the historical release
evidence and does not convert `if_expr` into a public/runtime/release claim.

---

## Acceptance Basis

C1-I result:

```text
status: proof-passed
evidence_label: if_expr_internal_compiler_delta
evidence_class: post_alpha_compiler_only_delta
checks_total: 39
checks_pass: 39
checks_fail: 0
failed_checks: []
proof_matrix: 13/13 D-items PASS
```

C2-X pressure verdict:

```text
verdict: proceed
checks total: 11
checks pass: 11
checks fail: 0
blockers: none
non-blocking notes: 1 cosmetic structural note
```

Accepted changed files:

| File | Accepted status |
| --- | --- |
| `igniter-lang/experiments/branch_conditional_if_expr_release_harness_delta_v0/branch_conditional_if_expr_release_harness_delta_v0.rb` | New proof-local delta runner. |
| `igniter-lang/experiments/branch_conditional_if_expr_release_harness_delta_v0/out/branch_conditional_if_expr_release_harness_delta_summary.json` | New delta summary JSON. |
| `igniter-lang/docs/tracks/branch-conditional-if-expr-release-harness-delta-proof-v0.md` | New implementation/proof track doc. |

No other write scope is accepted by this decision.

---

## Evidence Label And Class

Accepted:

```text
evidence_label: if_expr_internal_compiler_delta
evidence_class: post_alpha_compiler_only_delta
```

Generated outputs may be called only:

```text
if_expr_internal_compiler_delta evidence
```

They must not be called:

```text
official first-RC evidence
alpha release evidence
release execution evidence
public demo evidence
runtime evidence
production evidence
all-grammar evidence
Spark evidence
```

---

## Proof Matrix Status

Accepted proof matrix:

| Area | Status |
| --- | --- |
| Positive minimal `if_expr` TypeChecker + typed SemanticIR | PASS |
| Positive nested `if_expr` TypeChecker + typed SemanticIR | PASS |
| `OOF-IF1` non-Bool condition | PASS |
| `OOF-IF2` missing `else` | PASS |
| `OOF-IF3` branch type mismatch | PASS |
| `OOF-IF4` empty/non-value branch | PASS |
| `OOF-IF5` absent / non-status | PASS |
| Unsupported-`if_expr` `OOF-TY0` absent | PASS |
| Derivative `OOF-TY0` secondary-labeled where present | PASS |
| SemanticIR flat recursive shape | PASS |
| Runtime/evaluator/lazy branch execution not invoked or claimed | PASS |
| Historical release evidence unchanged | PASS |
| Public/Spark/API/CLI/release closed surfaces | PASS |

Detailed result:

```text
D-1..D-13: PASS
sub-checks: 39/39 PASS
```

---

## Old Evidence Immutability

Accepted old-evidence immutability:

| Evidence packet | Status |
| --- | --- |
| `compiler_release_acceptance_harness_summary.json` | unchanged; SHA256 matched anchor |
| `official_first_rc_evidence_summary.json` | unchanged; historical exclusion preserved |
| `combined_post_prep_smoke_summary.json` | unchanged; no branch/conditional claim |

Accepted SHA256 anchor:

```text
bc8d69f65c9267a604cb47e8ce0498a8373a80eaa264a2c53892139552a2618b
```

The historical `branch_conditional_if_expr` excluded-feature marker remains
valid for historical first-RC/alpha evidence. R195 adds new post-alpha
compiler-only delta evidence; it does not rewrite or reinterpret the old
evidence packets.

---

## Diagnostic Status

Accepted diagnostic status:

| Diagnostic | Status |
| --- | --- |
| `OOF-IF1` | live in negative non-Bool condition case |
| `OOF-IF2` | live in missing `else` case |
| `OOF-IF3` | live in branch mismatch case |
| `OOF-IF4` | live in empty/non-value branch case |
| `OOF-IF5` | absent / non-status |
| `OOF-TY0 Unsupported expression kind: if_expr` | absent |
| derivative `OOF-TY0 Type mismatch ... Unknown` | accepted only as `secondary_type_propagation` where present |

This preserves the R193 hygiene closure and prevents the old R190 ambiguity from
returning in the new delta packet.

---

## SemanticIR Status

Accepted SemanticIR delta status:

```text
flat recursive if_expr shape accepted and re-proven
```

Required keys:

```text
condition
then_branch
else_branch
resolved_type
```

Rejected in SemanticIR `if_expr` shape:

```text
cond
then
else
branch wrappers
deps key
```

Nested `if_expr` follows the same flat shape recursively.

---

## Non-Claims Status

Accepted non-claims:

```text
not_official_first_rc_evidence: true
not_alpha_release_evidence: true
not_release_execution_evidence: true
no_release_execution: true
no_public_demo_claim: true
no_stable_production_all_grammar_claim: true
no_runtime_evaluator_support: true
no_spark_claim: true
no_public_api_cli_widening: true
no_typechecker_semanticir_behavior_change: true
```

Release lane remains paused.

Runtime/evaluator support remains closed.

Spark/API/CLI remain closed.

Public release/demo/stable/production/all-grammar claims remain closed.

---

## Cosmetic Note

C2-X records one non-blocking note:

```text
closed_surface_scan.authorized_write_paths records runner-local write scope only,
not the full C1-A card write scope that also includes the track doc.
```

Decision:

```text
accepted as cosmetic / non-blocking
```

Reason:

- the runner correctly reports the paths it can machine-check;
- the track doc is a manually written markdown artifact and is not a closed
  surface;
- C1-I changed-file list and C2-X write-scope review both confirm the full card
  stayed within authorization.

Future proof runners may add a separate `card_authorized_write_paths` field, but
no follow-up is required now.

---

## Explicit Answers

### Is the delta proof accepted?

Yes.

The compiler-only `if_expr` delta proof is accepted.

### May generated outputs be called only `if_expr_internal_compiler_delta` evidence?

Yes.

That is the only accepted evidence label for this packet.

### Does accepted alpha / first-RC / release evidence remain unchanged?

Yes.

All historical evidence remains unchanged and immutable.

### Do public release/demo/stable/production/all-grammar claims remain closed?

Yes.

No public/release/demo/all-grammar claim is opened.

### Does runtime/evaluator support remain closed?

Yes.

Runtime/evaluator implementation and lazy branch execution remain closed.

### Do Spark/API/CLI remain closed?

Yes.

Spark evidence/integration and public API/CLI widening remain closed.

### Does the release lane remain paused?

Yes.

No release execution, publish, yank, tag, sign, or deploy route is opened.

### May a runtime/evaluator design-only route open next?

Yes.

A design-only route may open next to define runtime/evaluator semantics for
`if_expr`, especially lazy branch execution boundaries, but implementation
remains held until that design is accepted.

### Is another compiler/language route preferred?

Not immediately.

The preferred next Main Line route is runtime/evaluator design-only for
`if_expr`; this follows naturally from compiler support and delta evidence while
preserving the release lane pause.

---

## Exact Next Dispatch Recommendation

Recommended next card:

```text
Card: S3-R196-C1-D
Agent: [Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: branch-conditional-if-expr-runtime-evaluator-design-v0
Route: UPDATE
Depends on:
- S3-R195-C4-S
```

Goal:

```text
Design runtime/evaluator semantics for accepted expression-level if_expr v0
without authorizing implementation.
```

Required design focus:

- lazy branch execution vs eager evaluation;
- condition evaluation order;
- then/else branch selection;
- dependency/cache invalidation implications;
- runtime diagnostics and failure propagation;
- proof matrix for later implementation;
- public/API/CLI/release non-claims;
- interaction with existing runtime/evaluator architecture;
- closed surfaces and implementation hold.

Do not authorize runtime/evaluator implementation in the design card.

---

## Remaining Closed Surfaces

Remain closed:

- release execution, publish, yank, tag, sign, deploy;
- accepted alpha / first-RC / release evidence mutation;
- release harness corpus mutation outside accepted proof-local delta output;
- public release/demo/stable/production/all-grammar claims;
- runtime/evaluator implementation and lazy branch execution behavior;
- public API/CLI widening;
- Spark fixtures, integration, public evidence, or production behavior;
- parser, classifier, compiler orchestrator, assembler, root require changes;
- TypeChecker/SemanticIR/compiler behavior changes;
- docs/spec edits;
- `.igapp`, manifest, sidecar, artifact-hash, golden migration;
- loader/report, `CompilationReport`, `CompilerResult`, CompatibilityReport;
- Ledger/TBackend, BiHistory, stream/OLAP, cache, deployment, production.
