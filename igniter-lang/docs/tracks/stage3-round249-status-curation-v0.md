# Stage 3 Round 249 Status Curation v0

Card: `S3-R249-C5-S`
Track: `stage3-round249-status-curation-v0`
Role: `status-curator`
Route: `SUMMARY`
Status: `done / accepted`
Date: 2026-06-04

## Summary

R249 accepted the PROP-039+ managed local recursion / loop-class authoring
boundary and routed the next Main Line step to a bounded proposal-authoring
authorization review after the already-reserved S3-R250 forms round.

The round does not authorize proposal authoring by itself. It accepts C1-D as a
design-ready boundary, accepts C2-P1 as facts-only evidence, and keeps
implementation/runtime/public/release/performance/certification surfaces closed.

## Outcome Table

| Card | Artifact | Status | Notes |
| --- | --- | --- | --- |
| S3-R249-C1-D | `experimental-managed-local-recursion-and-loop-classes-prop039-authoring-boundary-v0.md` | done / design-ready | Recommends proposal-authoring authorization review next. |
| S3-R249-C2-P1 | `experimental-managed-local-recursion-prop039-current-surface-facts-v0.md` | done / facts-only | Maps Ch13, PROP-037, R248 fixtures, OOF, lab pressure, and closed surfaces. |
| S3-R249-C3-X | `experimental-managed-local-recursion-prop039-authoring-boundary-pressure-v0.md` | done / accept | No blocking claim drift; recommends accepting boundary. |
| S3-R249-C4-A | `experimental-managed-local-recursion-prop039-authoring-boundary-decision-v0.md` | accepted | Routes bounded PROP-039 proposal-authoring authorization review next. |
| S3-R249-C5-S | this track | done | Current status updated with compact route delta. |

## Changed Files

C1-D added:

- `igniter-lang/docs/tracks/experimental-managed-local-recursion-and-loop-classes-prop039-authoring-boundary-v0.md`

C2-P1 added:

- `igniter-lang/docs/tracks/experimental-managed-local-recursion-prop039-current-surface-facts-v0.md`

C3-X added:

- `igniter-lang/docs/discussions/experimental-managed-local-recursion-prop039-authoring-boundary-pressure-v0.md`

C4-A added:

- `igniter-lang/docs/tracks/experimental-managed-local-recursion-prop039-authoring-boundary-decision-v0.md`

C5-S changed:

- `igniter-lang/docs/tracks/stage3-round249-status-curation-v0.md`
- `igniter-lang/docs/current-status.md`

## Accepted Boundary

| Surface | Status |
| --- | --- |
| PROP-039+ boundary | accepted as proposal-authoring boundary |
| Proposal authoring | not yet authorized; next route is authorization review |
| R248 proof fixtures | sufficient design input only |
| R248 fixture grammar | not canonical |
| Lab evidence | frontier evidence only |
| `FiniteLoop` / budgeted local loop | authoring input; syntax unresolved until PROP-039 text |
| Structural recursion | authoring input; no execution support |
| Fuel-bounded recursion | authoring input; static `max_steps` first stance |
| `decreases fuel` | fuel-bounded shorthand candidate only; not parser grammar |
| `for ... max_steps` | pressure only; conservative split keeps `for` finite and `loop` budgeted |
| Dynamic `max_steps` | deferred pressure |
| Service liveness / progression | remains PROP-037-owned |
| `tick.time` | accepted service/progression event-time input |
| `tick.event_id` | unaccepted fixture pressure only |
| `now()` / OOF-L6 | Ch8 OOF-L6 remains the current source-level anchor |
| OOF-L / OOF-R / OOF-SL | proposed/candidate only; no registry authority |
| Postulate 28 loop naming | proposal input; enforcement unimplemented |
| `break` | deferred; excluded from first PROP-039 authoring route |

## Closed Surfaces

| Surface | Status |
| --- | --- |
| Implementation authority | closed |
| Parser / TypeChecker / SemanticIR | closed |
| Runtime / evaluator / API / CLI / package | closed |
| `igc run`, `.igapp`, `.igbin` | closed |
| Compiler passport / RuntimeSmoke | closed |
| Public runtime / Reference Runtime / stable API | closed |
| Production / Spark / release / public demo | closed |
| Performance / official-reference / certification / portability | closed |
| Mainline source/spec/proposal edits | closed until future authorization review |

## Exact Next Route

Open the next available Main Line route after the already-reserved S3-R250
forms round:

```text
Card: S3-R251-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-managed-local-recursion-prop039-proposal-authoring-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R249-C4-A
```

Route type:

```text
proposal-authoring authorization review
```

The future authorization review may consider proposal/index/track authoring
only. It must not authorize implementation, runtime support, public claims, or
lab behavior as canon unless a later explicit decision changes that boundary.
