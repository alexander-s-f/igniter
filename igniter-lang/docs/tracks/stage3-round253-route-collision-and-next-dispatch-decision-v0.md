# Stage 3 Round 253 Route Collision and Next Dispatch Decision v0

Card: `S3-R253-C4-A`
Track: `stage3-round253-route-collision-and-next-dispatch-decision-v0`
Role: `portfolio-architect-supervisor`
Route: `UPDATE`
Status: `accepted / route-resolution`
Date: 2026-06-05

Depends on:

- `S3-R253-C1-D`
- `S3-R253-C2-P1`
- `S3-R253-C3-X`

---

## Decision

Decision:

```text
accept the R251/R252 same-number route collision resolution
consume S3-R253 as the route-collision resolution round
supersede both prior active S3-R253-C1-A technical-route names
open forms SemanticIR lowering design/proof authorization review as S3-R254-C1-A
preserve S3-R255 for the Igniter Lang repository split boundary
defer PROP-039 proof-local fixtures by default to S3-R256-C1-A or later
keep implementation and protected public/runtime authority closed
```

C1-D correctly identified the collision. C2-P1 confirmed the facts. C3-X
returned `CONDITIONAL ACCEPT` with one required hygiene condition: C4-A/C5-S
must explicitly mark both old `S3-R253-C1-A` technical-route names as
superseded by this collision-resolution decision. This decision satisfies that
condition.

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round253-route-collision-and-next-dispatch-resolution-v0.md`
- `igniter-lang/docs/tracks/stage3-round253-route-collision-facts-v0.md`
- `igniter-lang/docs/discussions/stage3-round253-route-collision-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round251-status-curation-v0.md`
- `igniter-lang/docs/tracks/stage3-round252-status-curation-v0.md`
- `igniter-lang/docs/cards/S3/S3-R255.md`

---

## Acceptance Record

| Topic | Status |
| --- | --- |
| Route collision | Accepted as real: R251 and R252 both named different future routes as `S3-R253-C1-A`. |
| R251 future route | Preserved but renumbered/deferred: PROP-039 proof-local fixtures remain a valid future lane candidate. |
| R252 future route | Preserved and selected next: forms SemanticIR lowering design/proof authorization review opens as R254. |
| R253 | Consumed by route-collision resolution work. |
| Old duplicate route names | Superseded. Neither old `S3-R253-C1-A` technical-route name remains active after this decision. |
| Next route | `S3-R254-C1-A contract-invocation-forms-semanticir-lowering-design-authorization-review-v0`. |
| Deferred route | `S3-R256-C1-A experimental-managed-local-recursion-prop039-proof-fixture-authorization-review-v0` by default, or later only by explicit accepted route decision. |
| R255 reservation | Preserved for `igniter-lang-repository-split-boundary-and-migration-plan-v0`. |
| Implementation authority | Closed. |
| Parser / TypeChecker / SemanticIR / runtime / API / CLI / package authority | Closed unless a later route explicitly and narrowly authorizes it. |
| Public / stable / production / reference / release / performance / certification / portability authority | Closed. |

---

## Exact Next Route

Open:

```text
Card: S3-R254-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: contract-invocation-forms-semanticir-lowering-design-authorization-review-v0

Route: UPDATE
Depends on:
- S3-R252-C4-A
- S3-R253-C5-S
```

Route type:

```text
design/proof authorization review
```

Purpose:

```text
Decide whether a bounded contract invocation forms SemanticIR lowering design
or proof-local route may begin, using accepted R252 type-directed dispatch
evidence, without authorizing live mainline implementation, stable grammar,
public API, runtime support, VM linker/subroutine frames, .igapp execution,
.igbin execution, compiler passport emission, RuntimeSmoke productization,
release evidence, public performance claims, certification, portability, or
lab behavior as canon.
```

Recommended R254 C1-A read scope:

- `igniter-lang/docs/tracks/stage3-round252-status-curation-v0.md`
- `igniter-lang/docs/tracks/stage3-round253-status-curation-v0.md`
- `igniter-lang/docs/tracks/contract-invocation-forms-type-directed-dispatch-proof-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/contract-invocation-forms-type-directed-dispatch-proof-v0.md`
- `igniter-lang/docs/tracks/contract-invocation-forms-lowering-boundary-decision-v0.md`
- `playgrounds/igniter-lab/.agents/LAB-FORMS-P4.md`
- `playgrounds/igniter-lab/lab-docs/lab-contract-invocation-forms-lowering-preflight-v0.md`
- `playgrounds/igniter-lab/lab-docs/forms_analysis_and_execution_gaps.md`
- `playgrounds/igniter-lab/igniter-compiler/out/contract_invocation_forms_type_directed_dispatch_proof/summary.json`
- `playgrounds/igniter-lab/igniter-compiler/src/form_resolver.rs`
- `playgrounds/igniter-lab/igniter-compiler/src/typechecker.rs`
- `playgrounds/igniter-lab/igniter-compiler/src/emitter.rs`
- `playgrounds/igniter-lab/igniter-compiler/src/assembler.rs`

Recommended R254 C1-A write scope:

- `igniter-lang/docs/tracks/contract-invocation-forms-semanticir-lowering-design-authorization-review-v0.md`

R254 C1-A must decide whether to authorize:

- proof-local SemanticIR lowering design/prep only;
- proof-local lowering proof;
- proposal/errata authoring;
- hold pending import hiding/overriding or lowered-IR target clarity;
- pause.

R254 C1-A must not directly authorize live parser, TypeChecker, SemanticIR,
runtime, API, CLI, package, stable grammar, public API, VM linker, `.igapp`,
`.igbin`, compiler passport, RuntimeSmoke, release, performance,
certification, portability, or lab-canon authority.

---

## Deferred Route

Carry forward:

```text
Card: S3-R256-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-managed-local-recursion-prop039-proof-fixture-authorization-review-v0

Route: UPDATE
Depends on:
- S3-R251-C4-A
- S3-R253-C5-S
- S3-R255-C5-S if present
```

Route type:

```text
proof-local fixture authorization review
```

This route remains accepted as a future PROP-039 lane candidate. It is not
opened now. It may move later only through an explicit accepted routing
decision. It must not consume S3-R253 or S3-R255.

---

## Supersession Wording

The following prior duplicate technical-route names are superseded by this
decision:

| Prior name | Superseded by |
| --- | --- |
| `S3-R253-C1-A experimental-managed-local-recursion-prop039-proof-fixture-authorization-review-v0` | deferred by default to `S3-R256-C1-A` or later by explicit accepted route decision |
| `S3-R253-C1-A contract-invocation-forms-semanticir-lowering-design-authorization-review-v0` | renumbered to `S3-R254-C1-A` |

C5-S should remove current-status ambiguity by recording exactly one active
next route after R253: `S3-R254-C1-A`.

---

## Explicit Answers

### Is the route collision resolution accepted?

Yes. The collision-resolution design is accepted.

### Is R253 consumed by collision resolution?

Yes. R253 is consumed by route-resolution work: C1-D, C2-P1, C3-X, C4-A, and
C5-S.

### Does forms SemanticIR lowering or PROP-039 proof fixtures open next?

Forms SemanticIR lowering opens next as a design/proof authorization review.

### What exact route number opens next?

```text
S3-R254-C1-A
contract-invocation-forms-semanticir-lowering-design-authorization-review-v0
```

### What happens to the non-selected route?

PROP-039 proof-local fixtures are deferred by default to:

```text
S3-R256-C1-A
experimental-managed-local-recursion-prop039-proof-fixture-authorization-review-v0
```

or later only by explicit accepted route decision.

### Does S3-R255 remain reserved for repository split?

Yes. S3-R255 remains reserved for:

```text
igniter-lang-repository-split-boundary-and-migration-plan-v0
```

### Does implementation authorization open now?

No.

### Is any public/runtime/reference/stable/release/performance/certification/portability authority created?

No. No public runtime, Reference Runtime, stable API, production, Spark,
release, public demo, public performance, official/reference, alternative
certification, portability, repository migration, or lab-canon authority is
created.

---

## Closed Surfaces

Closed:

- live implementation;
- parser / TypeChecker / SemanticIR implementation;
- runtime / API / CLI / package changes;
- `igc run` widening;
- `.igapp` or `.igbin` execution;
- compiler passport emission;
- RuntimeSmoke productization;
- public runtime support;
- Reference Runtime support;
- stable API;
- production readiness;
- Spark integration;
- release execution or release evidence;
- public demo or public performance claims;
- official/reference status;
- alternative certification;
- portability guarantees;
- repository migration;
- R255 consumption by a non-repository-split route;
- lab behavior as canon.

---

## Compact Decision Summary

```text
ACCEPTED: R251/R252 same-number route collision resolution
SUPERSEDED: both old active S3-R253-C1-A technical-route names
CONSUMED: S3-R253 as route-resolution round
NEXT: S3-R254-C1-A forms SemanticIR lowering design/proof authorization review
RESERVED: S3-R255 repository split boundary
DEFERRED: S3-R256-C1-A or later PROP-039 proof-local fixture authorization
CLOSED: implementation, runtime, public, stable, release, performance,
        certification, portability, repository migration, lab-canon authority
```
