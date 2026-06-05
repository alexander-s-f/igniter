# Stage 3 Round 253 Route Collision and Next Dispatch Resolution v0

Card: `S3-R253-C1-D`
Track: `stage3-round253-route-collision-and-next-dispatch-resolution-v0`
Role: `portfolio-architect-supervisor`
Route: `UPDATE`
Status: `design-ready / recommend-route-resolution`
Date: 2026-06-05

Depends on:

- `S3-R251-C5-S`
- `S3-R252-C5-S`

---

## Decision Shape

Recommendation:

```text
accept that a route-number collision exists
consume S3-R253 as the collision-resolution round
open forms SemanticIR lowering design/proof authorization review as S3-R254-C1-A
preserve S3-R255 for the Igniter Lang repository split boundary
carry PROP-039 proof-local fixtures to S3-R256-C1-A or later
keep implementation, public, runtime, stable, release, performance,
certification, portability, and repository-migration authority closed
```

R251 and R252 both accepted their respective outputs and both named a future
`S3-R253-C1-A`. The collision is real and should be resolved explicitly rather
than silently renumbering one route in status prose.

R253 should therefore be used as the resolution round itself. This keeps both
accepted decisions intact and gives C4-A one place to assign the next route
without losing auditability.

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round251-status-curation-v0.md`
- `igniter-lang/docs/tracks/stage3-round252-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-managed-local-recursion-prop039-proposal-authoring-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/contract-invocation-forms-type-directed-dispatch-proof-acceptance-decision-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/cards/S3/S3-R255.md`

---

## Collision Facts

| Source | Accepted next route named | Status |
| --- | --- | --- |
| R251 C4/C5 | `S3-R253-C1-A experimental-managed-local-recursion-prop039-proof-fixture-authorization-review-v0` | accepted as next PROP-039 lane route after already-routed R252 |
| R252 C4/C5 | `S3-R253-C1-A contract-invocation-forms-semanticir-lowering-design-authorization-review-v0` | accepted as next forms lane route |
| R252 C5 | route watchpoint | explicitly records the collision and does not renumber either route |
| R255 card | `S3-R255-C1-D igniter-lang-repository-split-boundary-and-migration-plan-v0` | reserved; not available for technical-route collision cleanup |

The route conflict is not semantic. Both accepted routes remain valid as
lane-local recommendations. The conflict is only the shared card number.

---

## Preservation Policy

| Surface | Policy |
| --- | --- |
| R251 accepted decision | Preserved. PROP-039 authoring stays accepted and proof-local fixtures remain the next PROP-039 lane candidate. |
| R252 accepted decision | Preserved. Forms type-directed dispatch stays accepted and SemanticIR lowering remains the next forms lane candidate. |
| R253 | Consumed by this collision-resolution round. Do not reuse `S3-R253-C1-A` for either technical route. |
| R254 | Recommended next technical route: forms SemanticIR lowering design/proof authorization review. |
| R255 | Remains reserved for Igniter Lang repository split boundary and migration plan. |
| R256 or later | Recommended deferred PROP-039 proof-local fixture authorization review. |
| Current status | Should be updated only by C5-S after C4-A accepts the route resolution. |

---

## Route Assignment Matrix

| Candidate | Recommended assignment | Route type | Rationale |
| --- | --- | --- | --- |
| Collision resolution | `S3-R253-C1-D` through `S3-R253-C5-S` | route-resolution / decision | Needed to make numbering unambiguous before dispatch. |
| Forms SemanticIR lowering | `S3-R254-C1-A` | design/proof authorization review | Direct continuation of the most recent accepted R252 forms proof; still non-implementation. |
| Repository split | `S3-R255-C1-D` | design boundary / migration plan | Already reserved to prevent Igniter Ruby Framework and Igniter Lang authority drift. |
| PROP-039 fixtures | `S3-R256-C1-A` or later | proof-local fixture authorization review | Still valid, but should not consume R253 or R255. |

---

## Next Dispatch Recommendation

Open after R253 C4-A acceptance:

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

The route should decide whether a bounded forms SemanticIR lowering design or
proof may begin. It must not authorize live mainline parser, TypeChecker,
SemanticIR, runtime, API, CLI, package, stable grammar, public API, runtime
support, `.igapp` execution, `.igbin` execution, compiler passport emission,
RuntimeSmoke productization, public runtime, Reference Runtime, production,
Spark, release, public demo, public performance, official/reference,
certification, portability, or lab-canon authority.

Carry forward as deferred:

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

R256 or later may be adjusted by C4-A if R255 sequencing changes, but it must
not reuse `S3-R253-C1-A` and must not displace the R255 repository split
reservation.

---

## Options Evaluated

| Option | Verdict | Notes |
| --- | --- | --- |
| R253 collision resolution, R254 forms, R255 split, R256 PROP-039 | Recommended | Highest audit clarity; preserves both accepted decisions and the reserved split boundary. |
| R253 collision resolution, R254 PROP-039, R255 split, R256 forms | Valid but secondary | Preserves numbering, but interrupts the freshly accepted forms lowering chain. |
| Rename one route and let the other remain `S3-R253-C1-A` | Rejected | Creates invisible history drift because R253 is now explicitly a resolution round. |
| Pause | Not needed | The facts are sufficient to resolve numbering without implementation. |

---

## Explicit Answers

### Does a route-number collision exist?

Yes. R251 and R252 both name `S3-R253-C1-A` for different future routes.

### Should R253 itself be used as the collision-resolution round?

Yes. R253 should be consumed by route-resolution cards C1-D, C2-P1, C3-X,
C4-A, and C5-S.

### Which accepted route should open first after R253?

Forms SemanticIR lowering should open first because it directly follows the
freshly accepted R252 forms type-directed dispatch proof and is still only a
design/proof authorization review.

### What exact card number and track should be assigned to the first route?

```text
S3-R254-C1-A
contract-invocation-forms-semanticir-lowering-design-authorization-review-v0
```

### What exact card number and track should be assigned or reserved for the deferred route?

```text
S3-R256-C1-A or later
experimental-managed-local-recursion-prop039-proof-fixture-authorization-review-v0
```

The deferred route should not consume R255.

### Does S3-R255 remain reserved for the repository split boundary?

Yes. S3-R255 remains reserved for
`igniter-lang-repository-split-boundary-and-migration-plan-v0`.

### Does either route create implementation authority?

No. Both future routes remain authorization-review or proof-local candidate
routes only.

### Does parser/typechecker/SemanticIR/runtime/API/CLI/package authority remain closed?

Yes. These surfaces remain closed unless a later route explicitly and narrowly
authorizes them.

### Do protected public claims remain closed?

Yes. Public, stable, production, Reference Runtime, release, performance,
certification, portability, official/reference, Spark, public demo, runtime
support, and lab-canon claims remain closed.

---

## C4-A Recommendation

C4-A should accept the collision-resolution design and open:

```text
S3-R254-C1-A
contract-invocation-forms-semanticir-lowering-design-authorization-review-v0
```

C4-A should record that:

- `S3-R253` is consumed by route-resolution work;
- `S3-R255` remains reserved for repository split;
- PROP-039 proof-local fixtures remain accepted as a future lane candidate and
  should be carried to `S3-R256-C1-A` or later;
- no implementation, public, runtime, stable, release, performance,
  certification, portability, repository migration, or lab-canon authority is
  created.
