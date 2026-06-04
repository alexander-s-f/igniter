# Experimental Loops/Recursion Runtime Spec Current Surface Facts v0

Card: S3-R246-C2-P1
Skill: IDD Agent Protocol
Agent: [Implementation Surface Surveyor]
Role: implementation-surface-surveyor
Track: experimental-loops-recursion-runtime-spec-current-surface-facts-v0
Route: REVIEW
Status: done / facts-only
Date: 2026-06-04

Depends on:
- S3-R246-C1-D

---

## Authority Notice

This is a facts-only packet for current canonical/spec/proposal surfaces.

It records what existing docs say about loops, recursion, service loops,
progression, `now()`, `tick.time`, OOF diagnostics, and Postulate 28 naming. It
does not edit spec/proposal/code files, accept authority, authorize
implementation, accept lab behavior as canon, widen `igc run`, or make
public/runtime/stable/reference/performance/certification claims.

Write scope for this card:

```text
igniter-lang/docs/tracks/experimental-loops-recursion-runtime-spec-current-surface-facts-v0.md
```

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-loops-recursion-runtime-spec-and-prop037-input-slice-v0.md`
- `igniter-lang/docs/tracks/stage3-round245-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-loops-recursion-current-surface-facts-v0.md`
- `igniter-lang/docs/proposals/PROP-037-external-progression-service-liveness-v0.md`
- `igniter-lang/docs/tracks/prop037-*.md`
- `igniter-lang/docs/spec/ch13-managed-recursion.md`
- `igniter-lang/docs/spec/ch8-stdlib.md`
- `igniter-lang/docs/spec/ch1-identity.md`
- `igniter-lang/docs/spec/ch2-source-surface.md`
- `igniter-lang/docs/spec/ch4-fragment-classification.md`
- `igniter-lang/docs/spec/ch9-stage2-reserved.md`
- `igniter-lang/docs/spec/ch10-contract-modifiers.md`
- `igniter-lang/docs/spec/ch11-profile-system.md`
- `igniter-lang/docs/spec/ch12-effect-surface.md`
- `igniter-lang/docs/proposals/README.md`
- `igniter-lang/docs/language-covenant.md`
- `igniter-lang/docs/tracks/covenant-promise-enforcement-path-rule-v0.md`
- `igniter-lang/docs/dev/canonical-semantic-model.md`
- `igniter-lang/source/loops_and_recursion.ig`
- `playgrounds/igniter-lab/lab-docs/loops-and-recursion-pressure-package.md`
- `playgrounds/igniter-lab/lab-docs/loops-and-recursion-pressure-package-return.md`

No commands were required beyond read-only file inspection/search.

---

## Current Design Boundary Readout

R246-C1-D says the Runtime Specification / PROP-037+ input is design-ready and
recommends a combined Runtime Spec + PROP-037+ wording sync next.

It keeps closed:

```text
implementation authorization
proof-local loop/recursion fixtures
igc run widening
.igbin execution
compiler passport emission
RuntimeSmoke productization
public runtime support
Reference Runtime support
stable API
production readiness
Spark integration
release evidence
public demo / public performance claims
official/reference status
alternative certification
portability guarantees
```

R245 status curation accepts loops/recursion pressure as design/specification
input only, not implementation authority, lab certification, conformance
evidence, or runtime support.

---

## Canonical / Spec Surface Facts

### PROP-037

PROP-037 is accepted proposal-only for external progression and service
liveness.

Facts:

- service loop is the surface;
- progression is the semantic substrate;
- progression is not `Stream[T]`;
- progression is not `fold_stream`;
- progression is not local recursion;
- progression is not a runtime scheduler;
- v0 source kinds include `clock.every`, `queue`, and `external_event`;
- v0 OOF-PR categories are defined for progression descriptor/liveness
  obligations;
- no parser, TypeChecker, SemanticIR, scheduler, durable queue/checkpoint,
  Ledger/TBackend, production execution, ProgressionPack migration, or
  `PROGRESSION` fragment class is authorized.

Conclusion:

```text
PROP-037 settles enough service-loop/progression vocabulary for a companion
source-syntax/descriptor-mapping input route, but not enough for implementation
or runtime execution.
```

### Chapter 13

`docs/spec/ch13-managed-recursion.md` exists, with:

```text
Status: proposed
Stage: 4 (deferred)
Source PROP: PROP-037+ placeholder (not yet authored)
```

It contains useful prior vocabulary:

- five loop classes: `FiniteLoop`, `StructuralRecursion`,
  `FuelBoundedRecursion`, `ConvergentLoop`, `ServiceLoop`;
- `recur()` as a compiler primitive;
- service loop obligations: heartbeat, checkpoint, cancellation,
  `max_step_latency`;
- OOF-R1..OOF-R5 draft rules.

It is stale relative to current accepted/proposed surfaces:

- it predates accepted PROP-037 progression wording;
- it still says `PROP-037+ placeholder`;
- it contains service-loop examples using `now()`;
- it says `clock.every(...)` is semantically equivalent to `Stream[DateTime]`,
  while PROP-037 separates progression from stream/fold surfaces;
- it uses OOF-R codes that now need reconciliation with R245/R246 OOF-L/OOF-SL
  pressure and the existing `now()` OOF text in Chapter 8.

Conclusion:

```text
Chapter 13 is current as a deferred draft/reference, not as implementation or
accepted runtime spec authority. It needs errata before a wording sync can
promote any part of it.
```

### Chapter 8 and Explicit Time

Chapter 1 Law 6 states:

```text
Time is explicit: no ambient Time.now. All reads require TemporalCtx.
```

Chapter 8 states:

```text
now() -> DateTime -- OOF-L6: use TemporalCtx.as_of instead
```

The Language Covenant also forbids `now()` and mentions `OOF-M1` for that
policy, while current pressure docs mention `OOF-M1/M2` and lab facts mention
draft `OOF-L2`.

Conclusion:

```text
The no-hidden-now stance is already anchored, but the exact OOF code namespace
is not settled.
```

### Postulate 28 Naming

Postulate 28 lives in `docs/language-covenant.md`, not primarily in
`docs/spec/**`.

It says unnamed blocks with semantic identity are forbidden. Its listed surfaces
include loop class declarations.

Current enforcement table says:

- invariant block naming is enforced;
- escape declaration naming is unknown;
- loop class declaration naming is not implemented and must be explicit in the
  future managed-recursion proposal;
- assumptions/constraints naming are separate planned surfaces.

The enforcement-path track still names the future managed-recursion placeholder
as `PROP-036+`, while the current proposals index now routes managed local
recursion / loop-class extensions to `PROP-039+ or later`.

Conclusion:

```text
Postulate 28 is a governing anchor for loop naming, but loop-specific naming is
not currently implemented or accepted as a spec rule.
```

### Proposal Index

`docs/proposals/README.md` records:

- PROP-037 is accepted proposal-only for external progression and service
  liveness;
- managed local recursion / loop-class extensions must use `PROP-039+ or later`
  until formally assigned.

Conclusion:

```text
Local bounded loops and recursion should not be forced into PROP-037. Service
loop/progression mapping can be a PROP-037 companion; local loop/recursion
belongs in Chapter 13 errata plus PROP-039+ or later.
```

---

## Canonical Fixture and Pressure Docs

`igniter-lang/source/loops_and_recursion.ig` exists and uses:

- `def factorial(...) -> Integer decreases fuel`;
- `loop ProcessLeads in pending_leads max_steps: 100`;
- `loop tick in clock.every(5.seconds)`;
- `tick.time`;
- no `break`;
- no `now()`;
- no `fold_stream`.

Pressure package facts:

- asks for formal loop/recursion syntax and semantics;
- asks for progression/service-loop relationship;
- asks to ban `now()` and bind time via `tick.time`;
- asks for Postulate 28 loop naming.

Pressure-return facts:

- correctly separates `fold_stream` from arbitrary managed loops/recursion;
- says many loop/service-loop surfaces are full gaps, which R245 facts later
  found stale relative to current lab code;
- proposes draft OOF-L/OOF-SL vocabulary;
- overstates that most draft work can proceed without canonical input; current
  R245/R246 routing instead treats lab work as frontier pressure only.

---

## OOF Namespace Facts

| Namespace | Current occupant / source | R246 relevance |
| --- | --- | --- |
| `OOF-S*` | Stream/window/fold rules in spec/PROP-023, including OOF-S1..S4 | Already occupied; `fold_stream` remains separate from local loops. |
| `OOF-PR*` | PROP-037 progression diagnostics; proof/design tracks reserve `OOF-PR*` for progression | Service-loop/progression companion must respect this namespace. |
| `OOF-PROF*` | Chapter 11 profile diagnostics; replaced older profile OOF-PR collision | Do not reuse for loops. |
| `OOF-M*` | Occupied by imports in Ch2, modifiers/effect surfaces in Ch10/Ch12, and Covenant `now()` mention | Unsafe as a new `now()` namespace without reconciliation. |
| `OOF-L6` | Chapter 8 `now()` ambient clock refusal | Existing spec text, but conflicts with lab/pressure candidate naming. |
| `OOF-R1..R5` | Chapter 13 deferred managed recursion/service loop draft | Stale/deferred; requires errata before use. |
| `OOF-L1..L5` | R245/lab pressure for unbounded loop, `now()`, unnamed loop, recursion without fuel, ESCAPE leak | Draft pressure only. |
| `OOF-SL1..SL2` | R245/lab pressure for service-loop clock binding / CORE boundary | Draft pressure only. |
| `OOF-P28` | Existing/current registry mentions for unnamed semantic blocks and assumptions proof | General P28 precedent, not loop-specific registry ownership. |

Conclusion:

```text
R246 should not accept an OOF code directly. It should route OOF reconciliation
as part of the wording sync.
```

---

## Break Status

No canonical/spec status for source-level `break` was found in the current
Runtime Specification or proposal surfaces.

`break` appears only as lab/frontier implementation pressure from R245 facts:
the lab lexer has a keyword and the VM has an opcode, but the source-level
parser/emitter path is unverified.

Conclusion:

```text
break remains draft pressure only and should stay excluded from the first spec
input slice.
```

---

## Compact Spec / Current-Surface Matrix

| Surface | Current status | Notes |
| --- | --- | --- |
| `fold_stream` | Accepted Stage 2 stream/window surface | Not arbitrary loop proof. |
| Bounded local loops | Design input accepted by R245/R246 | Needs Chapter 13 errata / Runtime Spec wording. |
| `max_steps` | Existing Ch13 draft + source fixture + lab pressure | No accepted local-loop runtime semantics yet. |
| `decreases fuel` recursion | Source fixture + Ch13 draft + lab pressure | Needs PROP-039+ or later; VM execution not accepted. |
| Service loops | PROP-037 service-liveness semantics + Ch13 draft | Needs PROP-037 companion/source mapping; no execution authority. |
| Progression | PROP-037 proposal-only | Metadata/capability-first; no new fragment class. |
| `clock.every` | PROP-037 source_kind + Ch13 draft + fixture | Mapping to source syntax needs wording sync. |
| `tick.time` | Source fixture + R245/R246 design input | Needs explicit event-time wording; not ambient time. |
| `now()` | Forbidden by Law 6 / Ch8 / Covenant | OOF namespace conflict unresolved. |
| Postulate 28 loop naming | Governing covenant anchor | Loop-specific enforcement not implemented; route into future PROP. |
| `break` | No canonical/spec status found | Exclude from first spec slice. |
| OOF-L/OOF-SL | Draft lab/R245 pressure | No registry acceptance. |
| OOF-R | Deferred Ch13 draft | Needs errata/reconciliation. |
| Lab implementation | Frontier evidence only | Not canon, conformance, or runtime support. |

---

## Explicit Answers

Whether writes are limited to the facts track doc:

```text
Yes.
```

Whether spec/proposal/source/lab/code files remain read-only:

```text
Yes.
```

Whether commands are required:

```text
No. Read-only file inspection/search is sufficient for this facts packet.
```

Whether facts create any canonical authority:

```text
No.
```

Whether lab implementation remains frontier evidence only:

```text
Yes.
```

Whether implementation, `igc run`, `.igbin`, RuntimeSmoke, public runtime,
Reference Runtime, stable API, production, release, performance,
certification, and portability surfaces remain closed:

```text
Yes.
```

---

## Exact C4-A Evidence Notes

Recommend C4-A use these facts to support the R246-C1-D route:

```text
accept facts packet as evidence for combined Runtime Spec + PROP-037+ wording
sync authorization review
hold implementation
hold proof fixtures
hold igc run widening
```

Evidence notes:

- PROP-037 is sufficient as service-liveness/progression vocabulary, but not as
  source-level service-loop implementation authority.
- Chapter 13 is the right local managed loop/recursion draft anchor, but it is
  deferred and stale.
- PROP-039+ or later remains the proposal slot for managed local recursion /
  loop-class extensions unless C4-A assigns another route.
- `now()` is already forbidden as ambient time, but OOF naming must be
  reconciled before registry acceptance.
- Postulate 28 anchors loop naming as a governing requirement, but loop-specific
  enforcement is not current.
- `break` remains out of first-slice scope.
- Lab behavior remains frontier pressure only.
