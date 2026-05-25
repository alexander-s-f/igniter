# Compiler Release Public Nonclaims Planning Decision v0

Card: S3-R178-C4-A  
Agent: [Portfolio Architect Supervisor]  
Role: portfolio-architect-supervisor  
Track: compiler-release-public-nonclaims-planning-decision-v0  
Route: UPDATE  
Status: done  
Date: 2026-05-25

Depends on:
- S3-R178-C1-P1
- S3-R178-C2-P1
- S3-R178-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-public-nonclaims-docs-scope-v0.md`
- `igniter-lang/docs/tracks/compiler-release-public-readme-and-demo-claim-risk-survey-v0.md`
- `igniter-lang/docs/discussions/compiler-release-public-nonclaims-pressure-v0.md`
- `igniter-lang/docs/tracks/compiler-release-profile-source-installed-readiness-marker-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round177-status-curation-v0.md`

---

## Decision

Decision:

```text
accept public release/docs non-claims planning
accept safe wording as planning-only / future-authorized wording
accept C2 claim-risk survey classifications
carry CR-1 as required precondition before public docs polish
carry CR-13 as Portfolio-gated before public Spark mention
open bounded docs polish authorization review next
keep public release/demo claims closed
keep release execution closed
keep RubyGems publish closed
keep version/tag/push/publish/sign/deploy closed
keep profile finalization/discovery/defaulting closed
keep branch/conditional if_expr excluded
keep Spark out of scope
```

The R178 planning bundle is accepted. It provides a sound boundary for public
release/docs non-claims work, but it does not authorize public copy placement,
release execution, publication, tags, demo claims, or README edits by itself.

---

## Accepted Planning Bundle

Accepted:

```text
C1-P1: compiler-release-public-nonclaims-docs-scope-v0
C2-P1: compiler-release-public-readme-and-demo-claim-risk-survey-v0
C3-X:  compiler-release-public-nonclaims-pressure-v0
```

C1-P1 is accepted as the planning source for:

- safe wording proposals;
- required non-claims;
- excluded feature/surface wording;
- forbidden phrase shapes;
- release-scope label candidates;
- later docs polish boundary.

C2-P1 is accepted as the current claim-risk survey. Its classifications are
accepted as planning inputs, not code/docs edits.

C3-X is accepted:

```text
verdict: proceed
checks: 12/12 PASS
blockers_on_C4A_acceptance: 0
```

---

## Accepted Safe Wording Status

The safe wording in C1-P1 is accepted only as:

```text
planning wording
future-authorized wording candidate
not current public release copy
```

This means C1 wording may be used by a later bounded docs polish card as source
material, but it is not yet authorized for README, public release notes, demo
pages, package metadata, website copy, or external announcement text.

Accepted preferred phrase shapes:

```text
repo-local compiler RC evidence
local package install smoke
bounded installed profile-source smoke
accepted local evidence
ready for release-authorization review
not a release, publish, production, or demo claim
```

Avoided labels remain:

```text
public_release_ready
rubygems_ready
production_ready
demo_ready
full_compiler_support
spark_ready
```

---

## Claim-Risk Disposition

### CR-1

Accepted classification:

```text
blocker before public docs polish
```

Finding:

```text
experiments/pressure-specimens/mundane-application-pressure-v0/igniter-text-engine.ig:27
Status: production-ready library skeleton
```

Disposition:

```text
CR-1 does not block R178 planning acceptance.
CR-1 does block any public docs polish route that links or quotes pressure
specimens until it is fixed or fenced.
```

Required later action:

- either rewrite/fence the `igniter-text-engine.ig` status line;
- or add a clear non-canonical / not-production-ready disposition header;
- or exclude pressure specimens from public-facing docs navigation.

### CR-13

Accepted classification:

```text
needs Portfolio decision before public mention
```

Finding:

```text
docs/reports/port-2026-05-20-lang-spark-p3-availability-fixture-readiness.md
references Spark production metrics-backed receipt evidence.
```

Disposition:

```text
Keep internal by default.
Do not publicly mention Spark production evidence unless Portfolio explicitly
authorizes wording in a later card.
```

Allowed future guard wording only if explicitly authorized:

```text
Spark supplied pressure evidence for future fixture design. This is not an
Igniter-Lang integration, production behavior, or public release claim.
```

---

## Public Claims Status

Public non-claims wording is accepted as a plan.

Public release/demo claims remain:

```text
closed
```

Release execution remains:

```text
closed
```

RubyGems publish remains:

```text
closed
```

Version/tag/push/publish/sign/deploy remains:

```text
closed
```

Profile finalization/discovery/defaulting remains:

```text
closed
```

Branch/conditional `if_expr` remains:

```text
excluded
```

Spark remains:

```text
out_of_scope
```

---

## Next Route Decision

Next route:

```text
bounded docs polish authorization review
```

This next route should not edit public docs directly unless its authorization
card explicitly allows it. The preferred next step is to authorize a bounded
docs polish slice that first fixes or fences CR-1, then prepares or edits only
the named public/docs surfaces.

Release execution authorization review should wait until public non-claims
wording and docs risk are resolved.

---

## Exact Next Boundary

Recommended next round:

```text
R179 = C1-A -> C2-I -> C3-X -> C4-A -> C5-S
```

Suggested cards:

```text
S3-R179-C1-A
Track: compiler-release-docs-polish-authorization-review-v0
Agent: [Portfolio Architect Supervisor]
Goal: Decide whether a bounded docs polish implementation may begin.
Must include CR-1 fix/fence boundary, allowed files, forbidden public claims,
and proof matrix.
```

```text
S3-R179-C2-I
Track: compiler-release-public-nonclaims-docs-polish-v0
Agent: [Implementation Agent]
Goal: If authorized by C1-A, perform the bounded docs polish only within named
files and preserve all release/public non-claims.
```

```text
S3-R179-C3-X
Track: compiler-release-public-nonclaims-docs-polish-pressure-v0
Agent: [External Pressure Reviewer]
Goal: Pressure-review the docs polish for overclaims, CR-1 closure, CR-13
handling, forbidden phrase absence, and preserved closed surfaces.
```

```text
S3-R179-C4-A
Track: compiler-release-public-nonclaims-docs-polish-acceptance-decision-v0
Agent: [Portfolio Architect Supervisor]
Goal: Accept, conditionally accept, hold, or redirect the docs polish and decide
whether release-execution authorization review may open later.
```

```text
S3-R179-C5-S
Track: stage3-round179-status-curation-v0
Agent: [Status Curator]
Goal: Curate R179 status and preserve all non-authorizations.
```

---

## R179 Authorization Review Requirements

The next authorization review must explicitly define:

- exact files allowed for docs polish;
- whether CR-1 is fixed in-place, fenced, or excluded from public navigation;
- whether any README edit is allowed;
- whether any release-note draft is allowed;
- whether public copy may use C1-P1 safe wording;
- required non-claims block;
- forbidden phrase scan set;
- CR-13 Spark handling;
- proof matrix;
- rollback/hold condition if forbidden wording is found.

Closed unless explicitly narrowed:

```text
release execution
RubyGems publish
version/tag/push/publish/sign/deploy
public release/demo claims
production readiness claims
all-grammar support claims
branch/conditional if_expr support claims
profile finalization/discovery/defaulting
Spark integration
runtime/production behavior
package metadata
gemspec
compiler/runtime code
```

---

## Compact Summary

```text
S3-R178-C4-A accepts public release/docs non-claims planning.
C1-P1 safe wording is accepted as planning-only, not public copy.
C2-P1 claim-risk survey is accepted.
C3-X passes 12/12 with no blockers on planning acceptance.
CR-1 must be fixed/fenced before any public docs polish links or quotes pressure specimens.
CR-13 Spark production evidence remains internal unless Portfolio explicitly authorizes public wording.
Public release/demo claims, release execution, RubyGems publish, version/tag/push/sign/deploy,
profile finalization/discovery/defaulting, if_expr, Spark, runtime, and production remain closed.
Next route: bounded docs polish authorization review.
```
