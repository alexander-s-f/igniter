# Compiler Release Acceptance Harness Scope-Aware RC Evidence Authorization Review v0

Card: S3-R165-C1-A  
Agent: `[Portfolio Architect Supervisor]`  
Role: `portfolio-architect-supervisor`  
Route: UPDATE  
Track: `compiler-release-acceptance-harness-scope-aware-rc-evidence-authorization-review-v0`  
Status: done  
Date: 2026-05-24

---

## Inputs Read

- `igniter-lang/docs/tracks/first-rc-branch-conditional-scope-decision-v0.md`
- `igniter-lang/docs/discussions/first-rc-branch-conditional-scope-pressure-v0.md`
- `igniter-lang/docs/tracks/first-rc-branch-conditional-scope-disposition-v0.md`
- `igniter-lang/docs/tracks/compiler-release-harness-semantic-profile-follow-up-closure-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-harness-semantic-profile-refusal-follow-up-v0.md`
- `igniter-lang/docs/tracks/compiler-release-acceptance-harness-implementation-closure-decision-v0.md`
- `igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json`
- `igniter-lang/experiments/compiler_release_acceptance_harness_v0/compiler_release_acceptance_harness_v0.rb`

---

## Decision

Decision:

```text
authorize bounded scope-aware harness update
do not authorize official RC evidence gathering
do not authorize release execution or public claims
do not authorize branch/conditional implementation
do not authorize parser/typechecker/semanticir/compiler changes
```

The current harness has enough proof-local evidence to justify a narrow
scope-aware update: the only remaining `HOLD` is
`branch_conditional_if_expr_unsupported`, and S3-R164-C4-A accepted a narrowed
first-RC scope that explicitly excludes branch/conditional `if_expr`.

This decision authorizes only the update required to make that exclusion
machine-visible and to allow a later review to reason from a `PASS` harness
summary.

---

## Explicit Answers

### Does this card authorize official RC evidence gathering?

No.

This card authorizes a bounded scope-aware harness update only.

Official RC evidence gathering remains closed until a later Portfolio decision
reviews the updated harness output and explicitly opens RC evidence gathering.

### May generated outputs after C2-I be called official RC evidence?

No.

Generated outputs after C2-I may be called:

```text
scope-aware harness update evidence
pre-RC release-readiness evidence
```

They must not be called:

```text
official RC evidence
release-candidate evidence
RC evidence gathered
```

unless a later Portfolio decision explicitly authorizes that label.

### Is a later RC evidence authorization review still required?

Yes.

After C2-I, the next route should review the updated summary and decide whether
official RC evidence gathering may open.

### Does branch/conditional implementation remain closed?

Yes.

Branch/conditional `if_expr` implementation remains closed. This decision does
not authorize branch semantics, parser changes, TypeChecker changes,
SemanticIR changes, assembler changes, or compiler pipeline changes.

### Do parser/TypeChecker/SemanticIR/compiler changes remain closed?

Yes.

No compiler/library implementation is authorized by this decision.

---

## Authorized C2-I Boundary

Authorized card:

```text
Card: S3-R165-C2-I
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: compiler-release-acceptance-harness-scope-aware-update-v0
Route: UPDATE
Depends on:
- S3-R165-C1-A
- S3-R165-C2-S
```

Allowed write scope:

```text
igniter-lang/experiments/compiler_release_acceptance_harness_v0/**
igniter-lang/docs/tracks/compiler-release-acceptance-harness-scope-aware-update-v0.md
```

No other files may be edited.

---

## Required Harness Feature Coverage Mutation

C2-I must update the machine-readable feature coverage entry:

From:

```json
{
  "feature": "branch_conditional_if_expr",
  "status": "hold"
}
```

To:

```json
{
  "feature": "branch_conditional_if_expr",
  "status": "out_of_scope",
  "reason": "excluded from first RC scope by Portfolio decision S3-R164-C4-A; post-RC language/compiler design lane"
}
```

The exact `reason` may include more context, but it must preserve:

- S3-R164-C4-A as the exclusion basis;
- "excluded from first RC scope";
- "post-RC language/compiler design lane" or equivalent wording.

---

## Required `release_scope` Fields

C2-I must add the following machine-readable fields:

```json
{
  "excluded_features": ["branch_conditional_if_expr"],
  "exclusion_basis": "S3-R164-C4-A Portfolio acceptance of first_rc_excludes_branch_conditional_if_expr"
}
```

These fields must live under `release_scope`.

---

## Required `non_claims` Entry

C2-I must add a machine-readable branch/conditional non-claim preserving this
content:

```text
no_branch_conditional_claim: first RC scope explicitly excludes
branch/conditional if_expr; no branch or conditional expression support is
claimed; post-RC language design lane only; no branch/conditional
implementation is authorized by this RC scope decision
```

Line wrapping is acceptable. The meaning is not optional.

---

## HOLD-To-PASS Requirement

Binding condition:

```text
The updated harness must re-run and produce status: PASS before any later card
may consider opening official RC evidence gathering.
```

C2-I must ensure:

```text
failed_checks: []
hold_reasons: []
status: PASS
```

This is valid only because `branch_conditional_if_expr` is now explicitly
machine-visible as `out_of_scope`, not because the unsupported feature was
silently ignored.

If any HOLD remains, C2-I must report it and official RC evidence gathering
remains closed.

---

## Command And Proof Matrix

C2-I must run:

```text
ruby -c igniter-lang/experiments/compiler_release_acceptance_harness_v0/compiler_release_acceptance_harness_v0.rb
ruby igniter-lang/experiments/compiler_release_acceptance_harness_v0/compiler_release_acceptance_harness_v0.rb --mode acceptance
```

Required proof results:

| Check | Required result |
| --- | --- |
| Syntax check | PASS |
| Harness command | completes |
| Command matrix | remains PASS |
| Top-level status | PASS |
| `failed_checks` | empty |
| `hold_reasons` | empty |
| `feature_coverage.branch_conditional_if_expr.status` | `out_of_scope` |
| `release_scope.excluded_features` | includes `branch_conditional_if_expr` |
| `release_scope.exclusion_basis` | references S3-R164-C4-A |
| `non_claims` | includes `no_branch_conditional_claim` |
| Branch/conditional implementation | not authorized / not changed |
| Compiler/library files | not changed |
| RC evidence label | not used |

---

## RC Evidence Label Protection

C2-I must not use the phrases below for its outputs:

```text
official RC evidence
release-candidate evidence
RC evidence gathered
```

Allowed language:

```text
scope-aware harness update evidence
pre-RC release-readiness evidence
```

This protection applies to:

- updated summary;
- follow-up track;
- implementation summary;
- round receipt.

---

## Official RC Evidence Gathering Status

Closed.

The expected next route after C2-I is an acceptance/authorization review of the
scope-aware update output, not evidence gathering itself.

Candidate next route after C2-I:

```text
compiler-release-scope-aware-harness-update-acceptance-decision-v0
Mode: acceptance / authorization review
```

That later route may decide whether official first-RC evidence gathering can
open.

---

## Closed Surfaces

This decision does not authorize:

- official RC evidence gathering;
- release execution;
- public release or public demo claims;
- branch/conditional implementation;
- parser changes;
- classifier changes;
- TypeChecker changes;
- SemanticIR changes;
- assembler or compiler changes;
- compiler/library implementation;
- public analyzer/tracer/visualizer implementation or command/UI;
- public API/CLI widening;
- root require changes;
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
card: S3-R165-C1-A
decision: authorize_bounded_scope_aware_harness_update
c2_i_authorized: yes
allowed_write_scope: experiments/compiler_release_acceptance_harness_v0 + scope_aware_update_track
required_feature_status: branch_conditional_if_expr=out_of_scope
required_release_scope_excluded_features: branch_conditional_if_expr
required_exclusion_basis: S3-R164-C4-A
required_non_claim: no_branch_conditional_claim
required_top_level_status_after_update: PASS
official_rc_evidence_gathering: closed
generated_outputs_rc_label_authorized: no
later_rc_evidence_authorization_review_required: yes
branch_conditional_implementation_authorized: no
parser_typechecker_semanticir_compiler_changes_authorized: no
release_execution_authorized: no
public_demo_release_authorized: no
```
