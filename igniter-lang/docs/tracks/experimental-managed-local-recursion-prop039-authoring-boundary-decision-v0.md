# Experimental Managed Local Recursion PROP-039 Authoring Boundary Decision v0

Card: S3-R249-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-managed-local-recursion-prop039-authoring-boundary-decision-v0
Route: UPDATE
Status: accepted / route-proposal-authoring-authorization-review
Date: 2026-06-04

Depends on:
- S3-R249-C1-D
- S3-R249-C2-P1
- S3-R249-C3-X

---

## Decision

Accept the PROP-039+ managed local recursion / loop-class authoring boundary.

Decision:

```text
accepted
route bounded PROP-039 proposal-authoring authorization review next
implementation remains closed
```

Rationale:

```text
C1-D produced a design-ready authoring boundary.
C2-P1 confirmed current-surface facts and closed-surface posture.
C3-X returned ACCEPT with no blocking claim drift.
R248 proof fixtures are sufficient design input, but their grammar remains
non-canonical.
```

This decision authorizes no live implementation and no source/spec/proposal edit
by itself. It authorizes only the next authorization-review route.

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-managed-local-recursion-and-loop-classes-prop039-authoring-boundary-v0.md`
- `igniter-lang/docs/tracks/experimental-managed-local-recursion-prop039-current-surface-facts-v0.md`
- `igniter-lang/docs/discussions/experimental-managed-local-recursion-prop039-authoring-boundary-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round248-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-loops-recursion-proof-fixture-acceptance-decision-v0.md`

This C4-A decision adds only:

- `igniter-lang/docs/tracks/experimental-managed-local-recursion-prop039-authoring-boundary-decision-v0.md`

---

## Acceptance Record

| Surface | Decision |
| --- | --- |
| PROP-039+ boundary | Accepted as proposal-authoring boundary. |
| C1-D design output | Accepted. Boundary is design-ready. |
| C2-P1 facts packet | Accepted as facts-only current-surface evidence. |
| C3-X pressure verdict | Accepted: `ACCEPT`, no blocking drift. |
| R248 proof fixtures | Sufficient design input only. |
| R248 fixture grammar | Not canonical. |
| Lab evidence | Frontier evidence only. |
| Implementation authority | Closed. |
| Parser / TypeChecker / SemanticIR | Closed. |
| Runtime / API / CLI / package | Closed. |
| `igc run` / `.igapp` / `.igbin` | Closed. |
| Compiler passport / RuntimeSmoke | Closed. |
| Public runtime / Reference Runtime | Closed. |
| Stable API / production / Spark / release | Closed. |
| Performance / official-reference / certification / portability | Closed. |

---

## Boundary Decisions

### 1. Bounded Local Loops

Accepted as PROP-039 proposal-authoring input.

First authoring stance:

```text
FiniteLoop and budgeted local loop should be distinct in the proposal text.
```

No parser, TypeChecker, SemanticIR, runtime, or source syntax support is
accepted by this decision.

### 2. Structural Recursion

Accepted as PROP-039 proposal-authoring input.

First authoring stance:

```text
recursive contract ... decreases <structural_variant>
```

This is proposal input only. No recursion execution support is accepted.

### 3. Fuel-Bounded Recursion

Accepted as PROP-039 proposal-authoring input.

First authoring stance:

```text
fuel_bounded contract ... max_steps <static_literal>
```

This remains separate from structural recursion for the first proposal-authoring
route.

### 4. `decreases fuel`

Accepted as a fuel-bounded design shorthand candidate only.

Decision:

```text
decreases fuel may be authored as a candidate shorthand
decreases fuel is not accepted parser grammar
decreases fuel does not merge structural and fuel-bounded recursion by default
```

### 5. `for` / `loop`

Accepted as an authoring question with a conservative first stance.

Decision:

```text
for Name item in collection { ... }
  finite collection iteration candidate
  no max_steps in the first conservative draft

loop Name item in collection max_steps: N { ... }
  budgeted local loop candidate
  static max_steps first
```

R248's `for ... max_steps: claims.count` remains pressure only.

### 6. Static vs Dynamic `max_steps`

Decision:

```text
static literal max_steps is the first authoring stance
dynamic max_steps remains deferred pressure
```

Dynamic `max_steps` needs later type/audit rules before any implementation
authorization.

### 7. Service Loop / PROP-037

Decision:

```text
service liveness and progression remain PROP-037-owned
PROP-039 may reference service loops only to preserve the boundary
```

PROP-039 does not own scheduler/materialization, checkpoint, cancellation,
backpressure, receipts, progression descriptors, or a `PROGRESSION` fragment
class.

### 8. `tick.time` / `tick.event_id`

Decision:

```text
tick.time remains accepted service/progression event-time input
tick.event_id remains unaccepted fixture pressure only
```

If `tick` structured accessors beyond `tick.time` are desired, route them later
through a PROP-037 companion/accessor decision.

### 9. `now()` / OOF-L6

Decision:

```text
Chapter 8 OOF-L6 remains the current source-level now() prohibition anchor
PROP-039 should cross-reference OOF-L6 rather than mint a replacement code
```

### 10. Postulate 28 Loop Naming

Accepted as proposal-authoring input.

Decision:

```text
semantic loop blocks must have stable names in proposal text
loop naming enforcement remains unimplemented and unclaimed
```

### 11. OOF-L / OOF-R Registry

Decision:

```text
OOF-L / OOF-R / OOF-SL tables may be proposed in PROP-039
registry authority is not accepted by this C4-A
```

Open a separate OOF registry / errata route only if proposal authoring cannot
proceed with candidate diagnostics.

### 12. `break`

Decision:

```text
break remains deferred
first PROP-039 authoring route should exclude break
```

A later break route must specify semantics for evidence, fuel, receipts, and
loop naming before implementation can be considered.

---

## Explicit Answers

### Is the PROP-039+ authoring boundary accepted?

Yes.

### May implementation authorization open next?

No. Implementation remains closed.

### May proposal authoring open next?

Yes, but only through a bounded authorization-review route.

### Are proof fixtures sufficient input?

Yes. R248 fixtures are sufficient design input with these carried constraints:

- `tick.event_id` is pressure only;
- `recursive contract ... decreases fuel max_steps` is not canonical grammar;
- `for ... max_steps: claims.count` is not canonical grammar.

### Does lab behavior or R248 fixture grammar create canonical authority?

No. Lab behavior and R248 fixture grammar remain evidence only.

### Does `igc run` widening remain closed?

Yes.

### Do protected claims remain closed?

Yes. Public runtime, stable API, production, public demo, Reference Runtime,
Spark, release, performance, official/reference, certification, and portability
claims remain closed.

---

## Next Route

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

Candidate C2-I boundary if authorized:

```text
Card: S3-R251-C2-I
Skill: IDD Agent Protocol
Agent: [Compiler / Grammar Expert]
Role: compiler-grammar-expert
Track: experimental-managed-local-recursion-prop039-proposal-authoring-v0
```

Allowed write scope for the future authorization review to consider:

```text
igniter-lang/docs/proposals/PROP-039-managed-local-recursion-and-loop-classes-v0.md
igniter-lang/docs/proposals/README.md
igniter-lang/docs/tracks/experimental-managed-local-recursion-prop039-proposal-authoring-v0.md
```

Closed unless explicitly authorized by that future review:

```text
igniter-lang/lib/**
igniter-lang/bin/igc
igniter-lang/igniter_lang.gemspec
igniter-lang/README.md
igniter-lang/docs/README.md
igniter-lang/docs/ruby-api.md
igniter-lang/docs/spec/**
igniter-lang/source/**
igniter-lang/experiments/**
playgrounds/**
```

Required next-route focus:

- define PROP-039 managed local recursion / loop-class scope;
- separate `FiniteLoop`, `StructuralRecursion`, `FuelBoundedRecursion`,
  `ConvergentLoop`, and `ServiceLoop`;
- preserve PROP-037 service-liveness ownership;
- specify conservative `for` / `loop` split;
- specify static-only first `max_steps`;
- specify structural vs fuel-bounded recursion;
- decide whether `decreases fuel` is accepted as fuel-bounded shorthand;
- cross-reference Ch8 `OOF-L6` for `now()`;
- include Postulate 28 loop naming;
- include proposed OOF candidates without registry authority;
- keep `tick.event_id` pressure-only unless a PROP-037 companion route opens;
- defer `break`;
- keep all implementation/runtime/public/release/performance/certification/
  portability surfaces closed.

Round-close note:

```text
S3-R249-C5-S may curate this accepted decision before S3-R251 dispatch.
```

---

## Compact Decision Summary

[D] Accept the PROP-039+ managed local recursion / loop-class authoring
boundary.

[S] C1-D, C2-P1, and C3-X align: R248 fixtures are sufficient design input,
service liveness remains PROP-037-owned, and lab evidence remains frontier-only.

[T] No code/spec/proposal/source implementation surfaces are authorized. No
parser, TypeChecker, SemanticIR, runtime, CLI, package, `.igapp`, `.igbin`,
compiler passport, or RuntimeSmoke authority is created.

[R] Open `S3-R251-C1-A` as proposal-authoring authorization review after the
reserved S3-R250 forms round. Do not open implementation yet.
