# Pre-Gate3 Line Up RQ1/RQ2 Revision v0

Card: S3-R40-C3-P1
Agent: [Igniter-Lang Line Up Summarizer]
Role: line-up-summarizer
Track: pre-gate3-lineup-rq1-rq2-revision-v0
Status: done
Date: 2026-05-12

Route: STALE_REFRESH
Previous known card: S3-R39-C4-P1
Latest observed round: S3-R40 card assigned by supervisor; P-56 from R39
pressure is the target closure.
Same-role newer work: R39 Gate 3 R13-R22 Line Up already landed.
Gate/status changes: none made by this card; documentation authority-hardening
only.

---

## Scope

Close P-56 before R2-R12 discussion redirect or movement by applying RQ-1/RQ-2
to `docs/lineups/old-discussions-pre-gate3-spine.md`. RQ-3 wording hardening
was also safe and applied.

Inputs reread:

- `igniter-lang/handoff/onboarding-line-up-summarizer-v0.md`
- `igniter-lang/handoff/INSTANCE_ROUTING.md`
- `igniter-lang/docs/lineups/old-discussions-pre-gate3-spine.md`
- `igniter-lang/docs/tracks/line-up-authority-hoist-risk-review-v0.md`
- `igniter-lang/docs/discussions/r39-p54-rollout-readiness-and-lineup-pressure-v0.md`

## Changes

| Requirement | Result |
| --- | --- |
| RQ-1 | Tightened `Current route` so History Curator may plan redirects, but must not execute them until the R13-R22 Line Up lands and no-zombie checks pass. |
| RQ-1 authority hardening | Added explicit note that early `History[T]` / `BiHistory[T]` speculation is historical pressure only, not current authority. |
| RQ-2 | Replaced generic `meta-proposals` authority pointer with exact pointers to `docs/gates/`, `docs/current-status.md`, and `docs/agent-context.md`. |
| RQ-3 | Replaced "runtime enforcement" with "guarded approval-enforcement proof tracks, without granting runtime authority". |
| QA anchor | Added the exact standalone anchor required by current onboarding: `source remains authoritative for exact proof logs.` |

## P-56 Closure Summary

P-56 is closed for the assigned Line Up revision:

- RQ-1 applied.
- RQ-2 applied.
- RQ-3 applied opportunistically.
- Exact source paths preserved.
- No source files moved.
- No source files deleted.
- No broad links rewritten.

Discussion-index redirects and movement are still not authorized by this track.
History Curator must still run no-zombie checks before any redirect/movement.

## Handoff

```text
Card: S3-R40-C3-P1
Agent: [Igniter-Lang Line Up Summarizer]
Role: line-up-summarizer
Track: pre-gate3-lineup-rq1-rq2-revision-v0
Status: done

[D] Decisions
- Used STALE_REFRESH because this is a new R40 card after R39 Line Up work.
- Applied RQ-1/RQ-2 exactly to the old pre-Gate-3 Line Up.
- Applied RQ-3 wording hardening because it was safe and reduced authority-hoist risk.
- Treated `History[T]` / `BiHistory[T]` discussion content as historical pressure only.

[S] Shipped / Signals
- Updated `docs/lineups/old-discussions-pre-gate3-spine.md`.
- Created this track doc.
- P-56 closure summary recorded.

[T] Tests / Proofs
- Documentation-only validation.
- Checked exact QA anchor exists as a standalone line.
- Checked RQ-1/RQ-2/RQ-3 target phrases.
- Ran `git diff --check` on changed docs.

[R] Risks / Recommendations
- P-56 closure does not authorize R2-R12 discussion redirects or movement.
- History Curator still needs no-zombie checks.
- P-55 remains separate: Archive/Form verification of Gate 3 R13-R22 Line Up.

[Next] Suggested next slice
- Archive/Form verification of `gate3-r13-r22-discussions-spine.md` (P-55).
```
