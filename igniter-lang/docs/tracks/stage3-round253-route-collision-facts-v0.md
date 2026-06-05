# Stage 3 Round 253 Route Collision Facts v0

Card: `S3-R253-C2-P1`
Track: `stage3-round253-route-collision-facts-v0`
Role: `implementation-surface-surveyor`
Route: `UPDATE`
Status: `facts-only / no-sequencing-decision`
Date: 2026-06-05

Depends on:

- `S3-R253-C1-D`

---

## Boundary

This packet records facts for the R251/R252 route-number collision and the R255
reservation. It does not choose the final route order, authorize implementation,
edit current status, consume R255, or create public/runtime authority.

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round253-route-collision-and-next-dispatch-resolution-v0.md`
- `igniter-lang/docs/tracks/stage3-round251-status-curation-v0.md`
- `igniter-lang/docs/tracks/stage3-round252-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-managed-local-recursion-prop039-proposal-authoring-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/contract-invocation-forms-type-directed-dispatch-proof-acceptance-decision-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/cards/S3/S3-R253.md`
- `igniter-lang/docs/cards/S3/S3-R255.md`

## Route Collision Table

| Source | Accepted future route named | Route type stated | Authority status |
| --- | --- | --- | --- |
| R251 C4/C5 | `S3-R253-C1-A experimental-managed-local-recursion-prop039-proof-fixture-authorization-review-v0` | proof-local fixture authorization review | proposal-authoring evidence only; implementation closed |
| R252 C4/C5 | `S3-R253-C1-A contract-invocation-forms-semanticir-lowering-design-authorization-review-v0` | design/proof authorization review | proof-local lab-frontier evidence only; implementation closed |
| R253 C1-D | consumes `S3-R253` for route-resolution work | route-resolution / decision | recommendation only until C4-A accepts |
| R255 card | `S3-R255-C1-D igniter-lang-repository-split-boundary-and-migration-plan-v0` | design boundary + surface facts packet + pressure review + decision | reserved; not available for technical-route cleanup |

Facts confirm two different accepted future routes are competing for the same
card number, `S3-R253-C1-A`.

## Exact Route Statements

R251 accepted future route:

```text
Card: S3-R253-C1-A
Track: experimental-managed-local-recursion-prop039-proof-fixture-authorization-review-v0
Route type: proof-local fixture authorization review
```

R252 accepted future route:

```text
Card: S3-R253-C1-A
Track: contract-invocation-forms-semanticir-lowering-design-authorization-review-v0
Route type: design/proof authorization review
```

R252 watchpoint wording:

```text
R251 also named `S3-R253-C1-A` as the future PROP-039 proof-local fixture
authorization review after S3-R252. R252 C4-A independently names
`S3-R253-C1-A` for the forms SemanticIR-lowering design/proof authorization
review. This packet preserves both accepted decisions and records the numbering
collision as a dispatch watchpoint; it does not renumber either route.
```

## R253 and R255 Facts

| Question | Fact |
| --- | --- |
| Does `S3-R253.md` now exist? | Yes. `igniter-lang/docs/cards/S3/S3-R253.md` exists as `Route Collision and Next Dispatch Resolution`. |
| What is R253's main route? | `S3-R253-C1-D stage3-round253-route-collision-and-next-dispatch-resolution-v0`. |
| Does C1-D recommend consuming R253? | Yes, as a recommendation: consume `S3-R253` as the collision-resolution round. |
| Is that recommendation a final decision here? | No. This C2-P1 packet records facts only and does not choose route order. |
| What is R255 status? | `Status: Reserved`. |
| What is R255 reserved for? | `S3-R255-C1-D igniter-lang-repository-split-boundary-and-migration-plan-v0`. |
| Can either technical route safely consume S3-R255? | No. R255 is explicitly reserved for the repository split boundary and migration plan. |

## Current Status Wording

`igniter-lang/docs/current-status.md` records both same-number routes:

```text
R251 accepts bounded PROP-039 proposal authoring as proposal-authoring evidence
only, with `docs/proposals/README.md` indexing PROP-039 as
`authored-pending-review`, and routes the PROP-039 lane to S3-R253-C1-A
proof-local fixture authorization review after the already routed S3-R252 forms
round; R252 accepts proof-local contract invocation forms type-directed dispatch
evidence with FTD-1..FTD-12 PASS, import hiding and overriding held, and routes
forms next to S3-R253-C1-A SemanticIR lowering design/proof authorization
review; R251 and R252 both name S3-R253-C1-A, so dispatch numbering needs
supervisor resolution before launching either same-number card;
```

The active compact status also records:

```text
next forms route per C4-A is S3-R253-C1-A SemanticIR lowering design/proof
authorization review; ... next PROP-039 route is also named S3-R253-C1-A by
R251, so route numbering requires supervisor resolution before dispatch;
```

## Closed Surface Inheritance

| Source | Closed wording inherited |
| --- | --- |
| R251 | No implementation, parser, TypeChecker, SemanticIR, runtime, API, CLI, package, `igc run`, `.igapp`, `.igbin`, compiler passport, RuntimeSmoke, public runtime, Reference Runtime, stable API, production, Spark, release, public demo, performance, official/reference, certification, portability, or lab-canon authority. |
| R252 | No mainline implementation, stable grammar, canonical syntax, parser, TypeChecker, SemanticIR lowering, runtime, VM linker, API, CLI, package, `.igapp`, `.igbin`, compiler passport, RuntimeSmoke, public runtime, Reference Runtime, production, Spark, release, public demo, performance, official/reference, certification, portability, or lab-canon authority. |
| R255 | No repository migration, `git subtree split`, `git filter-repo`, remote push, release execution, package rename, public claims, CI/package changes, framework-to-language authority transfer, or lab behavior as canon. |

## Explicit Answers

### Do the facts confirm one or two routes are competing for `S3-R253-C1-A`?

Two routes are competing for `S3-R253-C1-A`: the R251 PROP-039 proof-local
fixture authorization review and the R252 forms SemanticIR lowering
design/proof authorization review.

### Does either accepted future route already have implementation authority?

No. R251 routes only a proof-local fixture authorization review. R252 routes
only a design/proof authorization review. Both keep implementation authority
closed.

### Can either accepted future route safely consume S3-R255?

No. S3-R255 is reserved for the Igniter Lang repository split boundary and
migration plan. Consuming it for either technical route would violate the
reservation.

### Did this facts packet change source, runtime, or public docs surfaces?

No. This packet adds only
`igniter-lang/docs/tracks/stage3-round253-route-collision-facts-v0.md`.

## C4-A Evidence Notes

- Collision fact: confirmed.
- R253 existence: confirmed as the collision-resolution round card.
- R255 reservation: confirmed and still unconsumed.
- Implementation authority: closed.
- Public/runtime/reference/stable/production/release/performance/certification/portability authority: closed.
- Sequencing decision: not made by this packet.
