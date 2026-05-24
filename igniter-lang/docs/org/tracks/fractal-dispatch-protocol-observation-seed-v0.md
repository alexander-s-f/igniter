# Fractal Dispatch Protocol Observation Seed v0

Card: S3-R158-C4-P1
Agent: [Org Architect Supervisor]
Role: org-architect-supervisor
Track: fractal-dispatch-protocol-observation-seed-v0
Route: UPDATE
Status: done
Date: 2026-05-24
Authority: org-sidecar process observation / non-governance / non-implementation

---

## Goal

Observe the R158 fractal dispatch experiment and return a lightweight process
packet. This track does not rewrite governance, roles, onboarding, or document
lifecycle rules.

---

## Internal Dispatch

```text
ORG-FR158 = [O1-P, O2-X] -> O3-S
```

Internal interpretation:

- `O1-P`: observe whether supervisor seed cards are understandable and
  executable without over-specifying executor cards.
- `O2-X`: pressure-review authority drift, packet shape drift, duplicated work,
  and excessive documentation.
- `O3-S`: return compact process recommendation.

No additional org sub-files were needed for this micro-round.

---

## O1-P Observation

The R158 top-level dispatch is understandable and executable because it gives
each supervisor:

- goal;
- route;
- suggested local dispatch;
- local decision questions;
- explicit closed surfaces;
- expected compact Portfolio packet path/shape;
- freedom to decompose locally inside its own operating surface.

The seed cards avoid a common failure mode: they do not fully specify executor
cards for the child supervisor. That keeps local supervisors responsible for
their own lane mechanics.

Strong pattern:

```text
top-level card defines direction and authority
local supervisor defines local mechanics
packet directory returns compact state to Portfolio
```

---

## O2-X Pressure Review

### Authority Drift

Risk:

```text
local supervisor packet could be mistaken for Portfolio decision
```

Mitigation:

```text
packet must say requested boundary, not authorized boundary
Portfolio C5-A remains the decision point
```

### Packet Shape Drift

Risk:

```text
each supervisor invents a different return shape
```

Mitigation:

```text
keep the R158 packet shape mandatory and compact:
Summary / Evidence / Risks / Requested Next Boundary / Closed Surfaces
```

### Duplicated Work

Risk:

```text
native track and Portfolio packet repeat the same long content
```

Mitigation:

```text
native track = details
Portfolio packet = compact first-read index with exact links
```

### Excessive Documentation

Risk:

```text
fractal mode can multiply documents if every seed spawns full sub-round docs
```

Mitigation:

```text
one local packet is required
detailed local tracks are optional and only when evidence needs them
no broad governance rewrite from this experiment
```

---

## What Worked

- Fractal seed cards make cross-lane parallelism legible without centralizing
  all child execution details in the parent card.
- `docs/cards/S3/R158/` gives Portfolio a compact read-first surface.
- Suggested internal dispatch gives supervisors enough structure without
  forcing identical process internals.
- Closed surfaces are repeated at the seed level, reducing authority leakage.
- The pattern fits lanes with different operating styles: formal Igniter-Lang,
  fast-lane Spark, Ruby release/package review, and Org process observation.

---

## What Drifted

- The term "suggested internal cards" can be read as either optional guidance or
  required local executor cards.
- Packet vs local track can duplicate content if not kept deliberately short.
- If every normal round uses fractal mode, documentation growth will accelerate.
- Cross-lane local recommendations may look like Portfolio authority unless the
  packet shape keeps "requested next boundary" explicit.

---

## Minimal Reusable Seed-Card Template

```text
Card: <round-card-id>
Agent: [<Supervisor>]
Role: <supervisor-role>
Track: <track-id>
Route: UPDATE

Fractal Seed:
<One paragraph: what local supervisor should accomplish and why.>

Suggested internal dispatch:
<LANE-FRxxx> = [A1-P, A2-X] -> A3-S

Suggested internal cards:
- A1-P: <observe/prove/design/inventory>
- A2-X: <pressure-review exact risks>
- A3-S: <return compact packet>

Scope:
- <read/focus boundaries>
- <local decisions to answer>
- <what not to do>

Deliver:
- Local packet/evidence in native operating surface, if needed
- Compact Portfolio packet at:
  <shared packet directory>/<supervisor-packet>.md
  with:
  - outcome;
  - evidence links;
  - risks / drift;
  - requested next boundary;
  - closed surfaces
```

Recommended rule:

```text
Use fractal mode for cross-lane or multi-supervisor rounds only.
Do not use it as the default for ordinary single-lane cards.
```

---

## Continue / Pause Recommendation

Recommendation:

```text
continue fractal mode selectively
```

Use when:

- multiple supervisors need to work in parallel;
- Portfolio needs compact first-read packets;
- local lanes have different process styles;
- the parent round needs one synthesis decision after local packets land.

Avoid when:

- a single card can be executed directly;
- implementation scope is narrow and already owned;
- the likely output is only one small doc;
- the user wants speed over orchestration evidence.

---

## Closed Surfaces

This org packet does not authorize:

- governance rewrite;
- base-role or onboarding changes;
- documentation movement/archive/deletion;
- compiler semantics;
- compiler/runtime implementation;
- Ruby release execution;
- Spark code/data access;
- Spark production adoption;
- public release/demo claims;
- cross-project integration;
- production deployment.

---

## Portfolio Return

Compact Portfolio packet:

```text
igniter-lang/docs/cards/S3/R158/org-architect-supervisor-packet.md
```
