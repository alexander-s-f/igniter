# Compiler Release Harness Semantic Profile Follow-up Closure Decision v0

Card: S3-R164-C1-A  
Agent: `[Portfolio Architect Supervisor]`  
Role: `portfolio-architect-supervisor`  
Route: UPDATE  
Track: `compiler-release-harness-semantic-profile-follow-up-closure-decision-v0`  
Status: done  
Date: 2026-05-24

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-harness-semantic-profile-refusal-follow-up-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round163-status-curation-v0.md`
- `igniter-lang/docs/tracks/compiler-release-harness-semantic-profile-refusal-follow-up-v0.md`
- `igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json`
- `igniter-lang/experiments/compiler_release_acceptance_harness_v0/compiler_release_acceptance_harness_v0.rb`
- `igniter-lang/docs/tracks/compiler-release-acceptance-harness-implementation-closure-decision-v0.md`

---

## Decision

Decision:

```text
accept semantic follow-up closure
formally close the R162 semantic profile-source qualified diagnostic condition
open first-rc-branch-conditional-scope-disposition-v0 as design-only
keep official RC evidence gathering closed
```

The R163 proof-local harness fix satisfies the R162 semantic follow-up
condition.

The remaining acceptance-harness `HOLD` is now only the branch/conditional
scope boundary:

```text
branch_conditional_if_expr_unsupported
```

That boundary is not an implementation failure. It requires a separate
Portfolio scope decision before official RC evidence gathering can open.

---

## Accepted Evidence

Accepted changed files:

```text
igniter-lang/experiments/compiler_release_acceptance_harness_v0/compiler_release_acceptance_harness_v0.rb
igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json
igniter-lang/docs/tracks/compiler-release-harness-semantic-profile-refusal-follow-up-v0.md
```

The changes remain inside the R163 authorized write scope.

No compiler/library file was changed.

---

## Command Matrix Result

Accepted command result:

```text
ruby -c igniter-lang/experiments/compiler_release_acceptance_harness_v0/compiler_release_acceptance_harness_v0.rb
=> Syntax OK

ruby igniter-lang/experiments/compiler_release_acceptance_harness_v0/compiler_release_acceptance_harness_v0.rb --mode acceptance
=> HOLD compiler_release_acceptance_harness_v0
=> command_matrix_entries=14
=> failed_checks=0
=> hold_reasons=1
```

The command matrix remains:

```text
14/14 PASS
```

The top-level harness status remains `HOLD` only because the branch/conditional
feature remains outside current TypeChecker support.

---

## Semantic Profile Wrong-Kind Status

Accepted summary state:

```text
semantic_profile_wrong_kind.pass: true
semantic_profile_wrong_kind.has_qualified_diagnostic: true
semantic_profile_wrong_kind.qualified_diagnostic_source: report_diagnostics
semantic_profile_wrong_kind.observed_qualified_diagnostic:
  add_baseline: compiler_profile_source.wrong_kind: "not_a_compiler_profile_id_source"
```

The harness no longer treats "non-zero exit and no `.igapp`" as sufficient for
this case. The proof now also requires the qualified
`compiler_profile_source.*` diagnostic.

Expected diagnostic:

```text
compiler_profile_source.wrong_kind
```

Accepted source:

```text
wrong_kind_should_not_exist.compilation_report.json diagnostics[].message
```

---

## Failed Checks

Accepted:

```text
failed_checks: []
```

The new sensitivity is also accepted:

```text
preflight.semantic_profile_wrong_kind.no_qualified_diagnostic
```

If the qualified diagnostic disappears, the harness will now fail instead of
silently passing the wrong-kind semantic refusal case.

---

## Remaining HOLD Reasons

Remaining HOLD:

```text
branch_conditional_if_expr_unsupported
```

This HOLD is accepted as the only current harness boundary signal.

It must not be quietly waived. A later Portfolio decision must either:

1. narrow first-RC language scope to exclude branch/conditional `if_expr`; or
2. route branch/conditional support/design/proof before RC evidence gathering.

---

## R162 Semantic Condition Status

Closed:

```text
R162 semantic_profile_wrong_kind qualified diagnostic condition: CLOSED
```

The earlier R162 conditional accept is now fully closed with respect to the
semantic profile-source qualified diagnostic gap.

Separate remaining boundary:

```text
branch_conditional_if_expr_unsupported: OPEN
```

---

## RC Evidence Gathering Status

Official RC evidence gathering remains closed.

Reasons:

- R164 C1-A is an acceptance decision for proof-local harness follow-up only;
- top-level harness status is still `HOLD`;
- branch/conditional first-RC scope disposition is not yet decided;
- no Portfolio decision has authorized official RC evidence gathering.

Generated outputs remain proof-local harness evidence only.

---

## Authorized C2-D Boundary

The next card may open as design-only:

```text
Card: S3-R164-C2-D
Agent: [Igniter-Lang Supervisor]
Role: igniter-lang-supervisor
Track: first-rc-branch-conditional-scope-disposition-v0
Route: UPDATE
Depends on:
- S3-R164-C1-A
```

Allowed work:

- compare first-RC scope options for `branch_conditional_if_expr_unsupported`;
- recommend whether first RC should exclude branch/conditional, wait for
  support, keep HOLD, or route a separate branch/conditional design/proof lane;
- define required non-claims wording and next-route candidates.

Not authorized:

- implementation;
- parser, TypeChecker, SemanticIR, or compiler changes;
- official RC evidence gathering;
- release execution;
- public release/demo claims.

---

## Closed Surfaces

This decision does not authorize:

- official RC evidence gathering;
- release execution;
- public release or public demo claims;
- compiler/library implementation;
- public analyzer/tracer/visualizer implementation or command/UI;
- public API/CLI widening;
- root require changes;
- parser, classifier, TypeChecker, SemanticIR, or assembler changes;
- loader/report;
- `CompilationReport`, `CompilerResult`, or `CompatibilityReport` widening;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden migration
  outside harness-local generated output;
- PROP-036 or PROP-038 mutation;
- Spark access, fixtures, specs, integration, or production pressure;
- Ruby Framework docs/release/tag/package/compatibility claims;
- runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache, signing,
  deployment, or demo work.

---

## Compact Receipt

```text
card: S3-R164-C1-A
decision: accept_semantic_follow_up_closure
r162_semantic_condition: closed
semantic_profile_wrong_kind.pass: true
semantic_profile_wrong_kind.has_qualified_diagnostic: true
qualified_diagnostic_source: report_diagnostics
observed_qualified_diagnostic: compiler_profile_source.wrong_kind
command_matrix: 14/14 PASS
failed_checks: 0
remaining_hold: branch_conditional_if_expr_unsupported
c2_d_authorized: yes_design_only
c2_d_track: first-rc-branch-conditional-scope-disposition-v0
rc_evidence_gathering: closed
release_execution_authorized: no
public_demo_release_authorized: no
compiler_library_changes_authorized: no
```
