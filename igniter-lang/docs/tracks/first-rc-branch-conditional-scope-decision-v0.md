# First RC Branch Conditional Scope Decision v0

Card: S3-R164-C4-A  
Agent: `[Portfolio Architect Supervisor]`  
Role: `portfolio-architect-supervisor`  
Route: UPDATE  
Track: `first-rc-branch-conditional-scope-decision-v0`  
Status: done  
Date: 2026-05-24

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-harness-semantic-profile-follow-up-closure-decision-v0.md`
- `igniter-lang/docs/tracks/first-rc-branch-conditional-scope-disposition-v0.md`
- `igniter-lang/docs/discussions/first-rc-branch-conditional-scope-pressure-v0.md`
- `igniter-lang/docs/tracks/compiler-release-readiness-map-v0.md`
- `igniter-lang/docs/tracks/compiler-release-acceptance-harness-design-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-acceptance-harness-implementation-closure-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-harness-semantic-profile-refusal-follow-up-v0.md`
- `igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json`

---

## Decision

Decision:

```text
accept narrowed first-RC scope excluding branch/conditional if_expr
accept Option A from S3-R164-C2-D
accept S3-R164-C3-X pressure verdict: proceed with binding non-blockers
authorize only the next authorization-review route
do not authorize official RC evidence gathering yet
do not authorize branch/conditional implementation
```

First RC may be scoped as a repo-local compiler release-candidate boundary for
already supported surfaces. Branch/conditional `if_expr` is explicitly
excluded from the first-RC language-feature scope.

This is a scope decision, not an implementation or release decision.

---

## Accepted Scope Disposition

Accepted disposition:

```text
first_rc_excludes_branch_conditional_if_expr
```

Accepted covered first-RC surface families:

- Add-style baseline compile;
- boolean gate / conjunction;
- integer arithmetic;
- mixed-type multi-input contract;
- POC-derived synthetic contract;
- parse/typecheck/refusal corpus;
- PROP-036 profile-source transport and refusal cases;
- CLI/API/load-path smoke;
- artifact normalization;
- closed-surface scan.

The following feature is excluded from first RC:

```text
branch_conditional_if_expr
```

Rationale:

- R160 explicitly allowed Portfolio to accept a narrower first-RC scope if
  branch/conditional behavior was not already supported.
- Current harness evidence has `14/14 PASS`, `failed_checks: 0`, and only one
  HOLD.
- The remaining HOLD is TypeChecker unsupported behavior:
  `OOF-TY0 Unsupported expression kind: if_expr`.
- Supporting `if_expr` requires a separate language/compiler design and proof
  lane. It is not a release-readiness harness fix.

---

## Excluded Feature Wording

Required wording for first-RC docs and harness non-claims:

```text
First RC excludes branch/conditional `if_expr`. The release-candidate scope
does not claim branch or conditional expression support. Any source requiring
`if_expr` remains unsupported by the current TypeChecker and is outside this
RC. Branch/conditional support remains a post-RC language/compiler design and
proof topic. No branch/conditional implementation is authorized by this RC
scope decision.
```

This wording is mandatory in the next authorization-review route.

---

## Required Harness Scope Marker

The current harness `HOLD` must not be promoted as official RC evidence.

Before any harness output may be labeled official RC evidence, a later
authorization review must require a scope-aware harness update with this
machine-visible marker:

```json
{
  "feature": "branch_conditional_if_expr",
  "status": "out_of_scope",
  "reason": "excluded from first RC scope by Portfolio decision S3-R164-C4-A; post-RC language/compiler design lane"
}
```

The current `hold` feature entry must not remain the RC evidence state after
the scope-aware update.

---

## Required Release Scope Fields

The next harness update route must add machine-readable scope exclusions under
`release_scope`:

```json
{
  "excluded_features": ["branch_conditional_if_expr"],
  "exclusion_basis": "S3-R164-C4-A Portfolio acceptance of first_rc_excludes_branch_conditional_if_expr"
}
```

These fields are required before first-RC evidence can be labeled official.

---

## Required Non-Claims Entry

The next harness update route must add a machine-readable non-claim:

```text
no_branch_conditional_claim: first RC scope explicitly excludes
branch/conditional if_expr; no branch or conditional expression support is
claimed; post-RC language design lane only; no branch/conditional
implementation is authorized by this RC scope decision
```

The wording may be line-wrapped, but the content must be preserved.

---

## HOLD To PASS Gate

The pressure review correctly identifies the main risk: an implementer could
rerun the current harness and call a `HOLD` packet official RC evidence.

This is prohibited.

Binding gate for the next authorization-review route:

```text
The harness must be updated to reflect
branch_conditional_if_expr_unsupported as out_of_scope_excluded
(not HOLD) with this Portfolio decision basis cited before any harness output
is labeled official RC evidence.

The updated harness must re-run and produce status: PASS before official RC
evidence gathering is authorized.
```

If the updated harness still reports `HOLD`, the evidence remains pre-RC /
proof-local and cannot be promoted to official RC evidence.

---

## RC Evidence Label Protection

Until the scope-aware harness update lands and reruns with `status: PASS`, no
artifact, summary, track, or report may use:

```text
official RC evidence
release-candidate evidence
RC evidence gathered
```

for the current harness outputs.

Current outputs remain:

```text
proof-local harness evidence
pre-RC release-readiness evidence
```

---

## Branch/Conditional Support Lane

Branch/conditional support remains a valid future language/compiler lane, but
it is not required before first RC.

Future route, if chosen later:

```text
branch-conditional-if-expr-scope-and-semantics-design-v0
Mode: design-only
```

This decision does not open that route. It only preserves it as a post-RC or
parallel language-design option.

---

## Next Authorized Route

Authorized next route:

```text
compiler-release-acceptance-harness-scope-aware-rc-evidence-authorization-review-v0
```

Mode:

```text
authorization review only
```

Purpose:

```text
Decide whether to authorize a bounded scope-aware harness update that converts
branch_conditional_if_expr from HOLD to out_of_scope, adds excluded_features,
adds the branch/conditional non-claim, reruns the harness, and only then
decides whether official first-RC evidence gathering may open.
```

Important boundary:

```text
This decision authorizes only the next authorization review.
It does not authorize the scope-aware harness update itself.
It does not authorize official RC evidence gathering.
```

The authorization review must carry the five pressure notes from
`first-rc-branch-conditional-scope-pressure-v0` as binding conditions:

- NB-1: HOLD to PASS transition must be a mandatory gate before RC evidence
  labeling;
- NB-2: `release_scope.excluded_features` is required;
- NB-3: `no_branch_conditional_claim` is required;
- NB-4: non-claims wording must include explicit no-implementation authority;
- NB-5: RC evidence label protection must be explicit.

---

## Official RC Evidence Gathering Status

Closed.

Official RC evidence gathering may not open until a later Portfolio decision
accepts an authorization review that proves the scope-aware harness update
boundary is ready.

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
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden migration;
- PROP-036 or PROP-038 mutation;
- Spark access, fixtures, specs, integration, or production pressure;
- Ruby Framework docs/release/tag/package/compatibility claims;
- runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache, signing,
  deployment, or demo work.

---

## Compact Receipt

```text
card: S3-R164-C4-A
decision: accept_option_a_narrowed_first_rc_scope
first_rc_scope: excludes_branch_conditional_if_expr
excluded_feature: branch_conditional_if_expr
branch_conditional_implementation_authorized: no
required_harness_marker: branch_conditional_if_expr.status=out_of_scope
required_release_scope_fields: excluded_features + exclusion_basis
required_non_claim: no_branch_conditional_claim
hold_to_pass_gate_required: yes
rc_evidence_label_protection_required: yes
next_route: compiler-release-acceptance-harness-scope-aware-rc-evidence-authorization-review-v0
next_route_mode: authorization_review_only
scope_aware_harness_update_authorized_now: no
official_rc_evidence_gathering: closed
release_execution_authorized: no
public_demo_release_authorized: no
compiler_library_changes_authorized: no
```
