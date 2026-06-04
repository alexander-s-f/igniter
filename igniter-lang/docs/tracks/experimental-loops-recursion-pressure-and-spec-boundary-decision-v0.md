# Experimental Loops/Recursion Pressure and Spec Boundary Decision v0

Card: S3-R245-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-loops-recursion-pressure-and-spec-boundary-decision-v0
Route: UPDATE
Status: accepted / route-runtime-spec-prop037-input-slice
Date: 2026-06-04

Depends on:
- S3-R245-C1-D
- S3-R245-C2-P1
- S3-R245-C3-X

---

## Decision

Accept the loops/recursion pressure and specification boundary.

Decision:

```text
accepted
```

Accepted as:

```text
canonical design input
specification pressure
frontier lab evidence input
not implementation authority
not lab certification
not conformance evidence
not runtime support
```

Acceptance basis:

```text
C1-D recommends spec input next, not implementation.
C2-P1 verifies current lab surfaces as facts-only pressure.
C3-X gives CONDITIONAL PASS with no blocking findings.
R244 keeps Slice 1 docs exposure bounded to Path C fail-closed evidence only.
```

C3-X conditions are accepted as record requirements, not blockers. They are
captured below.

This decision does not authorize code, `igc run` widening, `.igbin` execution,
compiler passport emission, RuntimeSmoke productization, public runtime support,
Reference Runtime support, stable API, production readiness, Spark integration,
release evidence, public demo, public performance claims, official/reference
status, alternative certification, or portability guarantees.

---

## Inputs Read

```text
igniter-lang/docs/tracks/
  experimental-loops-recursion-pressure-and-spec-boundary-v0.md
igniter-lang/docs/tracks/
  experimental-loops-recursion-current-surface-facts-v0.md
igniter-lang/docs/discussions/
  experimental-loops-recursion-pressure-boundary-pressure-v0.md
igniter-lang/docs/tracks/stage3-round244-status-curation-v0.md
igniter-lang/docs/tracks/
  experimental-igc-run-slice1-quickstart-docs-acceptance-decision-v0.md
```

No code, runtime, CLI, package, public docs, playground, or generated output
surface was edited by this decision.

This C4-A decision adds:

```text
igniter-lang/docs/tracks/
  experimental-loops-recursion-pressure-and-spec-boundary-decision-v0.md
```

---

## Accepted Record Items

### 1. Service Loop / Progression

Accepted stance:

```text
service loop is a surface
progression is the semantic substrate
PROP-037 metadata/capability-first remains the default
no new PROGRESSION fragment class is accepted now
```

Required precision:

```text
The lab classifier's ESCAPE classification for service loops and
required_capability = "clock_tick" is frontier draft evidence only.
It is not an accepted fragment-class decision and not an accepted ESCAPE-class
authority decision.
```

Service-loop execution remains closed until a later route settles progression
source/materialization/receipt/checkpoint/cancellation/backpressure obligations.

### 2. Stale Pressure-Return

Accepted record:

```text
playgrounds/igniter-lab/lab-docs/
  loops-and-recursion-pressure-package-return.md
is stale where it describes loop/recursion/service-loop support as full gaps.
```

Current lab source has moved beyond that older statement. C4-A must not cite the
pressure-return doc as current capability evidence. C2-P1 is the current facts
packet for this round.

### 3. Conflicting Generated Outputs

Accepted record:

```text
out/loops_and_recursion.compilation_report.json:
  pass_result = oof

out/loops_and_recursion.igapp/compilation_report.json:
  pass_result = ok
```

These generated outputs conflict and may be read only as pressure facts. They do
not constitute conformance evidence, canonical behavior evidence, runtime
support, certification, portability evidence, or public claim support.

### 4. OOF Naming

Accepted stance:

```text
OOF-L / OOF-SL names are draft registry pressure only.
```

The next spec input route must reconcile:

```text
original pressure naming: OOF-M1 / OOF-M2 for now()
current lab naming: OOF-L2 for now()
```

No OOF loop/recursion registry entry is accepted by this C4-A decision.

### 5. OOF-L3 / Loop Naming Robustness

Accepted gap:

```text
Postulate 28 loop naming is accepted as design input, but OOF-L3 robustness is
not proven.
```

The next spec/fixture route should verify that unnamed-loop diagnostics fire for
the intended source patterns before loop-naming enforcement is considered
complete.

---

## Acceptance Matrix

| Surface | Decision |
| --- | --- |
| Loops/recursion pressure boundary | Accepted. |
| Bounded loops | Accepted as canonical design input only. |
| Recursion / `decreases fuel` | Accepted as canonical design input only. |
| Service loop / progression | Accepted as spec input; execution and fragment-class authority closed. |
| `now()` prohibition | Accepted as design input; OOF code placement remains open. |
| `tick.time` binding | Accepted as design input; progression obligations remain open. |
| Loop naming / Postulate 28 | Accepted as design input; OOF-L3 robustness unproven. |
| OOF-L / OOF-SL registry | Draft input only; registry acceptance closed. |
| Lab compiler/VM implementation | Frontier draft evidence only. |
| Generated lab outputs | Pressure facts only; conflicting outputs are non-conformance evidence. |
| `fold_stream` | Separate bounded stream/window evidence; not arbitrary loop proof. |
| `break` | Unresolved future surface; source-level path unverified. |
| User recursion execution | Unverified / unsupported in current facts. |
| `igc run` Slice 1 widening | Closed. |
| `.igbin` execution | Closed. |
| Compiler passport emission | Closed. |
| RuntimeSmoke productization | Closed. |
| Public runtime / Reference Runtime | Closed. |
| Stable API / production / Spark / release | Closed. |
| Public performance / certification / portability | Closed. |

---

## Explicit Answers

Whether loops/recursion pressure boundary is accepted:

```text
Yes. Accepted as specification/design input only.
```

Whether lab implementation creates canonical authority:

```text
No.
```

Whether bounded loops may move into Runtime Specification input next:

```text
Yes.
```

Whether recursion / `decreases fuel` may move into Runtime Specification input
next:

```text
Yes.
```

Whether service loops must wait for progression fragment-class authority:

```text
No new fragment-class authority is required before the next spec input route.
However, service-loop execution remains held until progression obligations are
specified. Lab ESCAPE classification is draft pressure only.
```

Whether OOF loop/recursion registry work should open:

```text
Yes, as part of the next specification input route. Registry acceptance remains
closed until that route settles names and placement.
```

Whether implementation authorization may open next:

```text
No. Implementation authorization must wait.
```

Whether `igc run` widening remains closed:

```text
Yes.
```

Whether `.igbin`, compiler passport emission, RuntimeSmoke, public runtime,
Reference Runtime, stable API, production, Spark, release, public demo, public
performance, certification, and portability claims remain closed:

```text
Yes. All remain closed.
```

---

## Exact Next Dispatch Recommendation

Open:

```text
Card: S3-R246-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-loops-recursion-runtime-spec-and-prop037-input-slice-v0

Route type:
design / specification-input
```

Goal:

```text
Turn accepted loops/recursion pressure into a compact Runtime Specification and
PROP-037+ input slice covering bounded local loops, recursion with explicit
fuel, service-loop/progression separation, tick.time binding, now() prohibition,
Postulate 28 loop naming, and draft OOF-L/OOF-SL registry vocabulary.
```

Required boundary:

```text
Next route is design/specification-input only.
It must not authorize implementation.
It must not widen igc run.
It must not authorize .igbin execution.
It must not authorize compiler passport emission.
It must not authorize RuntimeSmoke productization.
It must not accept lab behavior as canon.
It must not create public runtime, Reference Runtime, stable API, production,
Spark, release, public performance, certification, or portability claims.
```

Required C1-D focus:

```text
bounded local loop grammar and semantics
recursion / decreases fuel semantics
service-loop / PROP-037 progression relationship
tick.time and explicit time binding
now() prohibition
Postulate 28 loop naming
OOF-M vs OOF-L/OOF-SL naming reconciliation
OOF-L3 diagnostic robustness requirement
break inclusion/deferral decision
lab evidence wording as frontier draft only
```

If C4-A status curation is added, it should record R245 as accepted and route
R246-C1-D exactly as above.
