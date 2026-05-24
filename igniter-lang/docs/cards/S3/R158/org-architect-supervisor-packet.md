# Org Architect Supervisor Packet - S3-R158

Source card: `S3-R158-C4-P1`
Internal dispatch: `ORG-FR158 = [O1-P, O2-X] -> O3-S`
Status: done

## Summary

- Fractal seed dispatch is useful for cross-lane rounds when the parent card
  defines direction/authority and child supervisors own local decomposition.
- The R158 packet directory gives Portfolio a compact first-read layer before
  deep evidence.
- Recommended posture: continue fractal mode selectively, not as the default
  for ordinary single-lane work.

## Evidence

- Local org track:
  `igniter-lang/docs/org/tracks/fractal-dispatch-protocol-observation-seed-v0.md`
- Top-level dispatch:
  `igniter-lang/docs/cards/S3/S3-R158.md`
- Packet convention:
  `igniter-lang/docs/cards/S3/R158/README.md`

## What Worked

- Supervisor seed cards were understandable without fully specifying executor
  cards.
- Suggested internal dispatch gave enough shape while preserving lane autonomy.
- Compact packet directory reduces Portfolio rereads.
- Closed surfaces were visible at the seed level.

## What Drifted

- "Suggested internal cards" should be treated as guidance, not mandatory
  executor-card bureaucracy.
- Native tracks and Portfolio packets can duplicate content if packets become
  long.
- Local supervisor recommendations can look like authority unless the packet
  says "requested next boundary" instead of "authorized next boundary."

## Recommended Reusable Seed-Card Template

```text
Card: <round-card-id>
Agent: [<Supervisor>]
Role: <supervisor-role>
Track: <track-id>
Route: UPDATE

Fractal Seed:
<one paragraph goal and boundary>

Suggested internal dispatch:
<LANE-FRxxx> = [A1-P, A2-X] -> A3-S

Scope:
- focus/read boundaries
- local questions to answer
- non-authorizations

Deliver:
- native local evidence, if needed
- compact Portfolio packet with:
  outcome / evidence / risks / requested next boundary / closed surfaces
```

## Whether To Continue Fractal Mode

Continue selectively.

Use it for multi-supervisor or cross-lane rounds that need one later Portfolio
synthesis. Avoid it for narrow single-lane cards where it would add documents
without improving coordination.

## Requested Next Boundary

Portfolio may decide whether R158 validates fractal mode as an optional dispatch
pattern. No base-role, onboarding, or governance rewrite is requested.

## Closed Surfaces

- No governance rewrite.
- No base-role/onboarding changes.
- No docs archive/move/delete.
- No compiler/runtime implementation.
- No Ruby release execution.
- No Spark code/data access or production adoption.
- No public release/demo claims.
- No cross-project integration authority.
