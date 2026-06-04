# Experimental Loops/Recursion Runtime Spec and PROP-037 Input Decision v0

Card: S3-R246-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-loops-recursion-runtime-spec-and-prop037-input-decision-v0
Route: UPDATE
Status: accepted-with-scope-corrections / route-r247-authorization-review
Date: 2026-06-04

Depends on:
- S3-R246-C1-D
- S3-R246-C2-P1
- S3-R246-C3-X

---

## Decision

Accept the Runtime Specification / PROP-037+ input slice with explicit scope
corrections for the next route.

Decision:

```text
accepted-with-scope-corrections
```

Accepted as:

```text
design/specification input
docs/proposal/spec authoring prerequisite
not implementation authority
not proof fixture authority
not runtime support
not lab certification
not conformance evidence
```

Acceptance basis:

```text
C1-D: design-ready; recommends combined Runtime Spec + PROP-037+ wording sync.
C2-P1: facts-only packet confirms current spec/proposal surfaces and gaps.
C3-X: conditional pass; no authority drift; one write-scope gap requires C4-A
      action before R247 opens.
R245: loops/recursion pressure accepted as design/specification input only.
```

This decision resolves the C3-X scope gap by requiring R247-C1-A to include a
narrow authorization question for `docs/spec/ch8-stdlib.md` and
`docs/language-covenant.md` in the OOF reconciliation scope. R247-C1-A may
authorize those files only for source-level `now()` / OOF cross-reference or
errata wording.

This decision does not authorize code, implementation, `igc run` widening,
`.igbin` execution, compiler passport emission, RuntimeSmoke productization,
public runtime support, Reference Runtime support, stable API, production
readiness, Spark integration, release evidence, public demo, public performance
claims, official/reference status, alternative certification, or portability
guarantees.

---

## Inputs Read

```text
igniter-lang/docs/tracks/
  experimental-loops-recursion-runtime-spec-and-prop037-input-slice-v0.md
igniter-lang/docs/tracks/
  experimental-loops-recursion-runtime-spec-current-surface-facts-v0.md
igniter-lang/docs/discussions/
  r246-runtime-spec-prop037-input-pressure-v0.md
igniter-lang/docs/tracks/stage3-round245-status-curation-v0.md
igniter-lang/docs/tracks/
  experimental-loops-recursion-pressure-and-spec-boundary-decision-v0.md
```

No code, runtime, CLI, package, public docs, playground, generated output, or
spec/proposal source file was edited by this decision.

This C4-A decision adds:

```text
igniter-lang/docs/tracks/
  experimental-loops-recursion-runtime-spec-and-prop037-input-decision-v0.md
```

---

## Accepted Scope Corrections

### 1. OOF Reconciliation Write Scope

C3-X found that C1-D's proposed R247 write scope cannot complete source-level
`now()` OOF reconciliation because it omits the files that hold current or
conflicting OOF anchors:

```text
igniter-lang/docs/spec/ch8-stdlib.md
igniter-lang/docs/language-covenant.md
```

Decision:

```text
R247-C1-A must explicitly decide whether to authorize narrow edits to these
files for OOF reconciliation. The preferred boundary is to allow narrow
cross-reference / errata wording only, not broad chapter rewrites.
```

If R247-C1-A does not authorize those files, it must remove OOF reconciliation
from the C2-I wording-sync goal and route it separately.

### 2. PROP-039+ Slot Correction

Decision:

```text
PROP-039+ or later is the current managed local recursion / loop-class proposal
slot. Any older reference to PROP-036+ as the managed-recursion placeholder is
stale and must not be used by R247 authoring.
```

This preserves PROP-036 as `compiler_profile_id` manifest identity and keeps
local managed loops/recursion out of PROP-037 service-liveness ownership.

### 3. Chapter 13 Section 13.5 Errata Target

Decision:

```text
R247 must explicitly address Chapter 13 section 13.5.
```

Required correction target:

```text
clock.every must be treated as a progression source_kind / service-liveness
source binding, not as semantically equivalent to Stream[DateTime].
```

This is necessary because PROP-037 separates progression from stream and
`fold_stream` surfaces.

### 4. Chapter 13 / PROP-037 Ownership Guard

Decision:

```text
R247-C1-A must separate ownership in the authorization card.
```

Required ownership split:

```text
Chapter 13 / Runtime Spec / PROP-039+ territory:
  bounded local loops
  max_steps
  recursion / decreases fuel
  loop naming / Postulate 28
  local-loop OOF vocabulary

PROP-037 companion territory:
  service-loop surface to progression descriptor mapping
  clock.every source_kind binding
  tick.time event-time binding
  progression materialization / receipt / checkpoint / cancellation /
    backpressure vocabulary references
```

The combined wording sync must not collapse these into one generic loop
concept.

### 5. R247 Dispatch Authority

C1-D proposed concrete R247 card numbers. C4-A treats those as recommendation
input only.

Decision:

```text
Open R247-C1-A as an authorization review.
Do not open R247-C2-I directly from this C4-A.
```

R247-C1-A must set exact write scope and ownership guards before any authoring
card runs.

### 6. OOF-L3 Robustness

Decision:

```text
OOF-L3 / unnamed-loop enforcement remains a future fixture requirement.
```

R247 may record the requirement but must not claim enforcement is complete.

---

## Acceptance Matrix

| Surface | Decision |
| --- | --- |
| Runtime Spec / PROP-037+ input slice | Accepted with scope corrections. |
| Bounded local loop | Accepted as spec/proposal wording input only. |
| `fold_stream` separation | Confirmed; remains stream/window evidence only. |
| Recursion / `decreases fuel` | Accepted as Chapter 13 / PROP-039+ input only. |
| Service-loop / progression | Accepted as PROP-037 companion input only. |
| Service-loop fragment class | Closed; no `PROGRESSION` fragment class accepted. |
| `tick.time` | Accepted as explicit event-time binding input only. |
| Source-level `now()` | Accepted as prohibition input; OOF namespace unresolved. |
| Postulate 28 loop naming | Accepted as spec input; enforcement unproven. |
| OOF naming / registry | Draft input only; no registry entry accepted. |
| `break` | Excluded from first spec slice; deferred. |
| Lab implementation evidence | Frontier pressure only. |
| Proof-local fixtures | Held until wording sync closes. |
| Implementation authorization | Closed. |
| `igc run` widening | Closed. |
| `.igbin` execution | Closed. |
| Compiler passport emission | Closed. |
| RuntimeSmoke productization | Closed. |
| Public runtime / Reference Runtime | Closed. |
| Stable API / production / Spark / release | Closed. |
| Public performance / certification / portability | Closed. |

---

## Explicit Answers

Whether the Runtime Specification / PROP-037+ input slice is accepted:

```text
Yes, accepted with scope corrections for the next authorization review.
```

Whether implementation authorization may open next:

```text
No.
```

Whether spec/proposal authoring may open next:

```text
Yes, but only through R247-C1-A authorization review. C4-A does not authorize
authoring directly.
```

Whether proof-local fixtures should wait for wording:

```text
Yes.
```

Whether lab behavior creates canonical authority:

```text
No.
```

Whether `igc run` widening remains closed:

```text
Yes.
```

Whether `.igbin`, compiler passport emission, RuntimeSmoke, public runtime,
Reference Runtime, stable API, production, Spark, release, public performance,
official/reference status, alternative certification, and portability claims
remain closed:

```text
Yes. All remain closed.
```

---

## Exact Next Dispatch Recommendation

Open:

```text
Card: S3-R247-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-loops-recursion-spec-prop037-wording-sync-
authorization-review-v0

Route type:
authorization review for docs/proposal/spec authoring only
```

Goal:

```text
Decide whether to authorize a bounded combined Runtime Spec + PROP-037+ wording
sync that fixes the accepted R246 specification-input gaps without authorizing
implementation, proof fixtures, runtime support, public claims, certification,
or portability.
```

Candidate C2-I write scope for R247-C1-A to consider:

```text
Primary candidate files:
  igniter-lang/docs/tracks/
    experimental-loops-recursion-spec-prop037-wording-sync-v0.md
  igniter-lang/docs/spec/ch13-managed-recursion.md
  igniter-lang/docs/proposals/
    PROP-037-external-progression-service-liveness-v0.md
    only as companion/amendment wording if C1-A explicitly authorizes
  igniter-lang/docs/proposals/README.md
    only for narrow status/index wording if C1-A explicitly authorizes

OOF reconciliation candidate files:
  igniter-lang/docs/spec/ch8-stdlib.md
    only for source-level now() / OOF cross-reference or errata wording
  igniter-lang/docs/language-covenant.md
    only for source-level now() / OOF cross-reference or errata wording

Closed unless explicitly authorized:
  igniter-lang/lib/**
  igniter-lang/bin/igc
  igniter-lang/igniter_lang.gemspec
  igniter-lang/README.md
  igniter-lang/docs/README.md
  igniter-lang/docs/ruby-api.md
  igniter-lang/source/**
  igniter-lang/out/**
  igniter-lang/experiments/**
  playgrounds/**
```

R247-C1-A must explicitly decide:

```text
whether ch8-stdlib.md and language-covenant.md may be touched;
whether OOF reconciliation is included now or deferred to a separate errata;
whether PROP-037 is amended directly or receives companion wording only;
whether proposals/README.md may be updated for PROP-039+ routing;
whether Chapter 13 section 13.5 must be corrected in the first authoring pass;
whether break remains deferred;
whether proof fixtures remain held.
```

Required closed surfaces for R247:

```text
implementation
proof-local execution fixtures unless separately authorized later
igc run widening
.igbin execution
compiler passport emission
RuntimeSmoke productization
public runtime support
Reference Runtime support
stable API
production
Spark
release
public performance claims
official/reference status
alternative certification
portability guarantees
lab behavior as canon
```
