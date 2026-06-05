# Stage 3 Round 253 Route Collision Pressure v0

Card: `S3-R253-C3-X`  
Skill: IDD Agent Protocol  
Agent: External Pressure Reviewer  
Role: external-pressure-reviewer  
Track: `stage3-round253-route-collision-pressure-v0`  
Route: UPDATE  
Status: done / conditional-accept  
Date: 2026-06-05  

Depends on:
- `S3-R253-C1-D`
- `S3-R253-C2-P1`

## Pressure Verdict

CONDITIONAL ACCEPT with exact wording/numbering fix.

The C1-D recommendation is directionally correct:

```text
S3-R253 = route-collision resolution round
S3-R254-C1-A = forms SemanticIR lowering design/proof authorization review
S3-R255 = reserved repository split boundary
S3-R256-C1-A or later = deferred PROP-039 proof-local fixture authorization review
```

This preserves both accepted decisions, does not create implementation
authority, and does not consume S3-R255.

The condition is only status-wording hygiene: C4-A and C5-S must explicitly
state that both old `S3-R253-C1-A` technical-route names are superseded by the
R253 collision-resolution decision. Do not leave current-status with two active
same-number routes plus an ambiguous "or later" deferred route.

## Inputs Reviewed

- `igniter-lang/docs/tracks/stage3-round253-route-collision-and-next-dispatch-resolution-v0.md`
- `igniter-lang/docs/tracks/stage3-round253-route-collision-facts-v0.md`
- `igniter-lang/docs/tracks/stage3-round251-status-curation-v0.md`
- `igniter-lang/docs/tracks/stage3-round252-status-curation-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/cards/S3/S3-R253.md`
- `igniter-lang/docs/cards/S3/S3-R255.md`

## Pressure Checks

| Check | Verdict | Notes |
| --- | --- | --- |
| Route collision exists | PASS | R251 and R252 both named different future routes as `S3-R253-C1-A`. |
| R253 as resolution round | PASS | Using R253 for C1-D/C2-P1/C3-X/C4-A/C5-S makes the audit trail explicit. |
| Preserve R251 decision | PASS | PROP-039 authoring remains accepted; proof-local fixtures remain the next PROP-039 lane candidate. |
| Preserve R252 decision | PASS | Forms type-directed dispatch remains accepted; SemanticIR lowering design/proof remains the next forms lane candidate. |
| Hidden implementation authority | PASS | Proposed routes are authorization-review / design-proof routes only. Implementation, public, runtime, release, performance, certification, portability, and lab-canon authority remain closed. |
| R255 reservation | PASS | R255 remains reserved for `igniter-lang-repository-split-boundary-and-migration-plan-v0` and is not consumed by either technical route. |
| Forms / PROP-039 separability | PASS | Forms and managed-local-recursion lanes remain independent; sequencing one before the other does not transfer authority. |
| Current-status clarity after C5-S | CONDITIONAL PASS | Clear only if C5-S explicitly marks the two old `S3-R253-C1-A` route names as superseded and records the accepted replacement numbering. |

## Compact Risk List

1. Numbering drift: low if C4-A locks `S3-R254-C1-A` for forms and default
   `S3-R256-C1-A` for PROP-039. Medium if C5-S keeps "S3-R253-C1-A" active in
   current-status.
2. R255 reservation drift: low. C1-D and C2-P1 both preserve R255. C4-A should
   repeat that R255 is not available for either technical route.
3. Sequencing risk: low. Prioritizing forms at R254 is reasonable because it
   directly follows R252. Deferring PROP-039 to R256 preserves the accepted
   R251 decision without interrupting the forms chain.
4. Authority drift: low. The proposed routes do not authorize implementation.
   C4-A should keep that closure explicit because "SemanticIR lowering" wording
   can sound implementation-facing if not bounded as design/proof review.
5. Status ambiguity: medium unless C5-S replaces the old same-number route
   statements with a single route-resolution result.

## Exact Recommendation To C4-A

Accept the route collision resolution with this exact decision shape:

```text
ACCEPT that R251 and R252 created a same-number route collision.
ACCEPT S3-R253 as consumed by route-collision resolution work.
SUPERSEDE both prior active S3-R253-C1-A technical-route names.
OPEN the forms lane next as:
  S3-R254-C1-A
  contract-invocation-forms-semanticir-lowering-design-authorization-review-v0
PRESERVE S3-R255 for:
  S3-R255-C1-D
  igniter-lang-repository-split-boundary-and-migration-plan-v0
DEFER the PROP-039 lane by default to:
  S3-R256-C1-A
  experimental-managed-local-recursion-prop039-proof-fixture-authorization-review-v0
ALLOW "R256 or later" only if a later accepted route-resolution/status decision
explicitly changes sequencing without consuming R255.
KEEP implementation, parser, TypeChecker, SemanticIR implementation, runtime,
API, CLI, package, public, stable, release, performance, certification,
portability, repository migration, and lab-canon authority closed.
```

Required C5-S current-status wording:

```text
R253 resolved the R251/R252 same-number route collision: S3-R253 is consumed by
route-resolution work; the prior duplicate S3-R253-C1-A technical-route names
are superseded; forms SemanticIR lowering design/proof authorization opens as
S3-R254-C1-A; S3-R255 remains reserved for the Igniter Lang repository split
boundary; PROP-039 proof-local fixtures are deferred by default to
S3-R256-C1-A or later by explicit accepted routing decision only; no
implementation, runtime, public, stable, release, performance, certification,
portability, repository migration, or lab-canon authority opens.
```

If C4-A is unwilling to lock the supersession wording, hold pending
route-number correction. Pause is not recommended.
