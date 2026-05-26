# Post Release Hygiene And Next Lane Decision v0

Card: S3-R186-C4-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: post-release-hygiene-and-next-lane-decision-v0
Route: UPDATE
Status: done / accepted-release-hygiene-if-expr-design-next
Date: 2026-05-26

Depends on:
- S3-R186-C1-P1
- S3-R186-C2-P1
- S3-R186-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-process-hygiene-lessons-v0.md`
- `igniter-lang/docs/tracks/post-release-next-compiler-language-lane-options-v0.md`
- `igniter-lang/docs/discussions/post-release-hygiene-and-next-lane-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round185-status-curation-v0.md`
- `igniter-lang/docs/tracks/compiler-release-execution-acceptance-decision-v0.md`

---

## Decision

Decision:

```text
accept release hygiene rules
accept pressure verdict: proceed, 15/15 PASS, no blockers
pause the release lane after R186
keep any second release execution route closed
return to compiler/language feature work
open branch/conditional if_expr scope-and-semantics design/proof planning next
do not authorize implementation
```

R185 remains accepted as a successful `igniter_lang 0.1.0.alpha.1` alpha
release. R186 adds prospective release-process hygiene only; it does not reopen
the release, require incident remediation, or authorize another publish.

---

## Accepted Hygiene Rules

The C1-P1 hygiene packet is accepted as future release guidance:

- future user approval must name package, version, expected SHA256, tag,
  `gem push`, human MFA/2FA, exact tag push, and non-claims;
- prerelease RubyGems listing/collision checks must use `--pre`;
- post-publish docs sync must explicitly say whether install commands may be
  added;
- RubyGems MFA/2FA secrets stay out of chat/docs/logs;
- release execution must rebuild the artifact and enforce SHA match before
  publish;
- only exact tag refs may be pushed;
- no auto-yank after publish; failed verification routes to incident/yank review;
- release payloads must be rebuilt release artifacts, not prior smoke temp
  artifacts;
- future receipts must carry the required release execution fields.

Portfolio refinement from C3-X NB-1:

```text
For future release execution cards, approval_exact_enough: false is a HOLD
before irreversible commands unless a separate Portfolio decision explicitly
records an exceptional post-facto acceptance path.
```

This turns the C1-P1 "prefer HOLD" phrasing into the binding future default.

C3-X NB-2 is accepted as non-blocking: commit-message hygiene and `igc --help`
non-zero behavior may be added to a future release template, but no R186 cleanup
card is required before the next compiler/language route.

---

## Next Lane Decision

The next Portfolio vector is:

```text
branch/conditional if_expr scope-and-semantics design/proof planning
```

Reason:

- `if_expr` is the clearest accepted first-RC/alpha exclusion;
- it is already visible in harness/release evidence as unsupported expression
  behavior;
- resolving it improves future release coverage and richer local POC examples;
- it is a language/compiler semantics boundary, so it should start with
  design/proof planning, not implementation.

Rejected/deferred next routes:

| Route | Decision |
| --- | --- |
| another release execution route | closed; requires fresh Portfolio/user decision |
| analyzer/tracer/visualizer lane | defer behind language feature boundary |
| profile finalization/discovery/defaulting | defer; high claim-drift risk after `PATH.json` transport |
| public demo planning | defer; alpha claims remain intentionally narrow |
| Spark applied-pressure route | out of Main Line release scope |
| no follow-up / passive observe only | not enough movement after alpha |

---

## Explicit Answers

### Are release hygiene rules accepted?

Yes. Accepted with the Portfolio refinement that future
`approval_exact_enough: false` is a pre-irreversible-command HOLD by default.

### Does the release lane pause after R186?

Yes.

The accepted alpha release is published, verified, tagged, and curated. There is
no active release incident, yank, tag remediation, or second-release need.

### Does another release execution route remain closed?

Yes.

No publish, yank, tag creation, tag push, signing, deployment, version change,
or second release execution may proceed without a new explicit Portfolio/user
authorization naming target, version, SHA, evidence delta, and public wording.

### Do public demo / production claims remain closed?

Yes.

Allowed public wording remains limited to bounded alpha availability for
`igniter_lang 0.1.0.alpha.1`, installed `igc compile`, and the accepted
`--compiler-profile-source PATH.json` transport. Stable, production, public
demo, and all-grammar claims remain closed.

### Does Spark remain out of Main Line release scope?

Yes.

Spark may continue as a separate applied-pressure lane, but R186 does not route
Spark fixtures, Spark integration, Spark public evidence, or Spark production
claims into the Main Line release scope.

### Is implementation authorized?

No.

The next route is design/proof planning only. Parser, TypeChecker, SemanticIR,
assembler, artifact, runtime, public API/CLI, and release code changes remain
closed until a separate implementation authorization review.

---

## Closed Surfaces

Remain closed:

- release execution;
- second release route;
- RubyGems publish;
- gem yank;
- tag creation, tag deletion, tag push, broad tag push, or force push;
- signing and deployment;
- stable release claim;
- production readiness claim;
- public demo readiness claim;
- all-grammar support claim;
- branch/conditional `if_expr` implementation;
- parser/classifier/TypeChecker/SemanticIR/assembler changes;
- `.igapp`, `.ilk`, manifest, sidecar, artifact-hash, or golden migration;
- profile finalization/discovery/defaulting;
- named/generated profile lookup;
- inline JSON profile input;
- env/config/sidecar profile lookup;
- public API/CLI widening beyond accepted `igc compile` and
  `--compiler-profile-source PATH.json`;
- analyzer/tracer/visualizer implementation or public tooling;
- loader/report, `CompilationReport`, `CompilerResult`, or
  CompatibilityReport widening;
- Spark access, Spark fixtures/specs/integration, Spark public evidence, or
  Spark production behavior;
- Ruby Framework compatibility/export claims;
- runtime, Ledger/TBackend, BiHistory, stream/OLAP, cache, production behavior.

---

## Exact Next Dispatch Recommendation

```text
Card: S3-R187-C1-D
Agent: [Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: branch-conditional-if-expr-scope-and-semantics-design-v0
Route: UPDATE
Depends on:
- S3-R186-C4-A

Goal:
Design the branch/conditional if_expr scope, semantics, diagnostics, and proof
plan from the accepted post-RC/alpha exclusion evidence, without implementation.

Scope:
- Read:
  - igniter-lang/docs/tracks/post-release-hygiene-and-next-lane-decision-v0.md
  - igniter-lang/docs/tracks/post-release-next-compiler-language-lane-options-v0.md
  - igniter-lang/docs/tracks/first-rc-branch-conditional-scope-decision-v0.md
  - igniter-lang/docs/tracks/first-rc-branch-conditional-scope-disposition-v0.md
  - igniter-lang/docs/tracks/compiler-release-acceptance-harness-design-v0.md
  - igniter-lang/docs/tracks/stage3-round185-status-curation-v0.md
  - igniter-lang/docs/current-status.md
  - current parser, TypeChecker, SemanticIR, assembler, and artifact code/docs
    discovered by targeted rg for if_expr, branch, conditional, and unsupported
    expression behavior.
- Define:
  - current parser status for branch/conditional expression sources;
  - current diagnostic/refusal ownership;
  - required semantics for condition type, branch type unification, missing or
    unsupported branches, and nested conditionals;
  - TypeChecker/SemanticIR/assembler/artifact implications;
  - release-harness corpus implications after future support;
  - minimal proof-only route required before any implementation authorization.
- Do not implement code.
- Do not authorize implementation.
- Do not open release execution, public demo claims, production claims, Spark
  integration, profile discovery/defaulting, analyzer/tracer/visualizer
  implementation, or public API/CLI widening.

Deliver:
- Design track in igniter-lang/docs/tracks/
- Compact semantics/proof matrix
- Exact next proof-only or implementation-authorization-review recommendation
- Closed-surface list
```

Recommended companion pressure card:

```text
Card: S3-R187-C2-X
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: branch-conditional-if-expr-design-pressure-v0
Route: UPDATE
Depends on:
- S3-R187-C1-D

Goal:
Pressure-review the if_expr design/proof boundary for semantic completeness,
surface containment, and absence of implementation authority.

Deliver:
- Discussion doc in igniter-lang/docs/discussions/
- Compact proceed/hold verdict
- Exact blockers or authorization-review recommendation
```

Then:

```text
S3-R187-C3-A: Portfolio / Lang decision on whether proof-only work,
implementation-authorization review, additional design, or hold opens next.
S3-R187-C4-S: status curation.
```

---

## Compact Summary

```text
R186 accepts post-release hygiene and pauses release work.

Accepted:
  C1-P1 release hygiene rules, with approval_exact_enough=false -> HOLD
  default for future irreversible release commands.

Pressure:
  C3-X proceed, 15/15 PASS, no blockers.

Next:
  return to compiler/language lane via if_expr scope-and-semantics design/proof.

Still closed:
  release execution, second publish, yank/tag/push/sign/deploy, stable/
  production/demo/all-grammar claims, if_expr implementation, parser/
  TypeChecker/SemanticIR/assembler changes, profile discovery/defaulting,
  Spark, runtime, API/CLI widening.
```
