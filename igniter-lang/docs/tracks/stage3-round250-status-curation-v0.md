# Stage 3 Round 250 Status Curation v0

Card: `S3-R250-C5-S`
Track: `stage3-round250-status-curation-v0`
Role: `status-curator`
Route: `SUMMARY`
Status: `done / accepted`
Date: 2026-06-04

## Summary

R250 accepted the contract invocation forms lowering boundary as design-only and
routed the next forms lane step to a proof-local type-directed dispatch
authorization review.

The round accepts LAB-FORMS-P4 as lab-frontier preflight evidence only and
accepts C2-P1 as facts-only current-surface evidence. It does not authorize
implementation, runtime support, stable grammar, public API, release,
performance, certification, portability, or lab behavior as canon.

## Outcome Table

| Card | Artifact | Status | Notes |
| --- | --- | --- | --- |
| S3-R250-C1-D | `contract-invocation-forms-lowering-and-execution-boundary-v0.md` | done / design-ready | Accepts forms lowering as design boundary; implementation held. |
| S3-R250-C2-P1 | `contract-invocation-forms-lowering-current-surface-facts-v0.md` | complete / facts-only | Maps lab sidecar-only state and mainline gaps. |
| S3-R250-C3-X | `contract-invocation-forms-lowering-boundary-pressure-v0.md` | done / accept | No blocking authority drift. |
| S3-R250-C4-A | `contract-invocation-forms-lowering-boundary-decision-v0.md` | accepted | Routes type-directed dispatch proof authorization review next. |
| S3-R250-C5-S | this track | done | Current status updated with compact forms-route delta. |

## Changed Files

C1-D added:

- `igniter-lang/docs/tracks/contract-invocation-forms-lowering-and-execution-boundary-v0.md`

C2-P1 added:

- `igniter-lang/docs/tracks/contract-invocation-forms-lowering-current-surface-facts-v0.md`

C3-X added:

- `igniter-lang/docs/discussions/contract-invocation-forms-lowering-boundary-pressure-v0.md`

C4-A added:

- `igniter-lang/docs/tracks/contract-invocation-forms-lowering-boundary-decision-v0.md`

C5-S changed:

- `igniter-lang/docs/tracks/stage3-round250-status-curation-v0.md`
- `igniter-lang/docs/current-status.md`

## Accepted Boundary

| Surface | Status |
| --- | --- |
| LAB-FORMS-P4 | accepted as lab-frontier preflight evidence only |
| C2-P1 | accepted as facts-only current-surface evidence |
| Forms lowering boundary | accepted as design-only boundary |
| Invocation form vs constructor form | accepted as separate vocabulary |
| Explicit `form (left) "+" (right)` | strongest baseline syntax candidate only; not stable grammar |
| `form:` | DX sugar candidate only; not canonical syntax |
| Sidecar resolution | audit evidence only; not SemanticIR lowering fact |
| Type-directed dispatch | required before implementation authorization |
| Ambiguity policy | `E-FORM-AMBIG` remains hard error after type filtering |
| Declaration order | must not choose semantic winners |
| Primitive pass-through / unresolved trigger | design evidence only; `unresolved_form_error` deferred until type filtering exists |
| Import hiding / overriding | lab parse evidence only; enforcement unproven |
| Lowering target | future explicit `ContractInvocation` or `Call` |
| Inlining / monomorphization | preferred first runtime stance before VM bytecode |
| VM linker / subroutine frames | deferred |

## Closed Surfaces

| Surface | Status |
| --- | --- |
| Implementation authority | closed |
| Mainline parser / TypeChecker / SemanticIR | closed |
| Runtime / VM linker / API / CLI / package | closed |
| Stable grammar / public API | closed |
| Public runtime / Reference Runtime | closed |
| Production / Spark / release / public demo | closed |
| Performance / official-reference / certification / portability | closed |
| Lab behavior as canon | closed |

## Exact Next Route

Open the next available forms Main Line route after the already-routed S3-R251
PROP-039 authorization review:

```text
Card: S3-R252-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: contract-invocation-forms-type-directed-dispatch-proof-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R250-C4-A
```

Route type:

```text
proof-local proof authorization review
```

The future authorization review may decide whether a bounded proof-local
type-directed dispatch proof can begin. It must not authorize mainline
parser/typechecker/SemanticIR/runtime implementation directly.
