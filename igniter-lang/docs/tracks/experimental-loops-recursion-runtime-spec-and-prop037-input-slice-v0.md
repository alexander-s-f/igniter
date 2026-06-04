# Experimental Loops/Recursion Runtime Spec and PROP-037 Input Slice v0

Card: S3-R246-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-loops-recursion-runtime-spec-and-prop037-input-slice-v0
Route: UPDATE
Status: done / recommend-combined-spec-proposal-wording-sync-next
Date: 2026-06-04

Depends on:
- S3-R245-C5-S

---

## Decision Shape

The Runtime Specification / PROP-037+ input is design-ready.

Recommended C4-A decision:

```text
accept Runtime Specification / PROP-037+ input slice
route combined Runtime Spec + PROP-037+ wording sync next
hold implementation authorization
hold proof-local loop/recursion fixtures until wording sync closes
hold igc run widening
```

Reason:

```text
R245 accepted loops/recursion pressure as specification input only.
PROP-037 already covers service liveness as proposal-only, with service loop as
surface and progression as semantic substrate.
Chapter 13 exists but is Stage 4 deferred and stale relative to PROP-037 and
the current no-hidden-now stance.
Managed local loops/recursion still need a dedicated canonical wording route
before proof fixtures or implementation can safely open.
```

This card does not edit Runtime Specification chapters, PROP docs, code,
runtime, CLI, package, public docs, playground files, or generated outputs.

This card does not authorize implementation, `igc run` widening, `.igbin`
execution, compiler passport emission, RuntimeSmoke productization, public
runtime support, Reference Runtime support, stable API, production readiness,
Spark integration, release evidence, public demo, public performance claims,
official/reference status, alternative certification, or portability guarantees.

---

## Inputs Read

```text
igniter-lang/docs/tracks/stage3-round245-status-curation-v0.md
igniter-lang/docs/tracks/
  experimental-loops-recursion-pressure-and-spec-boundary-decision-v0.md
igniter-lang/docs/tracks/
  experimental-loops-recursion-pressure-and-spec-boundary-v0.md
igniter-lang/docs/tracks/
  experimental-loops-recursion-current-surface-facts-v0.md
igniter-lang/docs/discussions/
  experimental-loops-recursion-pressure-boundary-pressure-v0.md
igniter-lang/docs/proposals/
  PROP-037-external-progression-service-liveness-v0.md
igniter-lang/docs/tracks/
  prop037-external-progression-proposal-authoring-v0.md
igniter-lang/docs/spec/ch13-managed-recursion.md
igniter-lang/docs/spec/ch8-stdlib.md
igniter-lang/docs/proposals/README.md
igniter-lang/docs/current-status.md
igniter-lang/source/loops_and_recursion.ig
playgrounds/igniter-lab/lab-docs/
  loops-and-recursion-pressure-package.md
playgrounds/igniter-lab/lab-docs/
  loops-and-recursion-pressure-package-return.md
```

No commands were required beyond read-only file inspection.

---

## Source Status Readout

### R245 Boundary

R245 accepts, as design/specification input only:

```text
bounded local loops
recursion with explicit decreases fuel
service-loop / progression separation
tick.time explicit temporal binding
now() prohibition
Postulate 28 loop naming
draft OOF-L / OOF-SL vocabulary for registry reconciliation
```

R245 explicitly keeps closed:

```text
implementation authorization
igc run widening
.igbin execution
compiler passport emission
RuntimeSmoke productization
public runtime / Reference Runtime support
stable API / production / Spark / release claims
performance / certification / portability claims
lab behavior as canon
```

### PROP-037

PROP-037 is accepted proposal-only for external progression and service liveness.

Stable input from PROP-037:

```text
service loop is the surface
progression is the semantic substrate
Progression is not Stream[T]
Progression is not fold_stream
Progression is not local recursion
Progression is not a runtime scheduler
metadata/capability first
no new PROGRESSION fragment class
closed source_kind vocabulary: clock.every, queue, external_event
```

PROP-037 does not authorize parser syntax, TypeChecker changes, SemanticIR
changes, RuntimeMachine scheduling, durable queues/checkpoints, Ledger/TBackend
binding, ProgressionPack migration, production execution, or a new fragment
class.

### Chapter 13

`docs/spec/ch13-managed-recursion.md` exists, but remains:

```text
Status: proposed
Stage: 4 deferred
Source PROP: PROP-037+ placeholder
```

It is useful as prior vocabulary, but it needs errata before serving as the
current specification input. Known stale points:

```text
it predates accepted PROP-037 wording;
it still says PROP-037+ placeholder;
it contains now() examples inside service-loop-style snippets;
it mixes service liveness wording with local managed recursion classes;
it uses OOF-R codes that now need reconciliation with R245 OOF-L/OOF-SL
pressure and existing OOF-L6 in Chapter 8.
```

### Chapter 8 / now()

`docs/spec/ch8-stdlib.md` already records:

```text
now() -> DateTime -- OOF-L6: use TemporalCtx.as_of instead
```

R245 pressure includes:

```text
original pressure naming: OOF-M1 / OOF-M2
lab naming: OOF-L2
Chapter 8 existing naming: OOF-L6
```

Therefore `now()` should not be assigned directly in this C1-D. The next route
must reconcile OOF placement before accepting a registry entry.

### Proposal Index

`docs/proposals/README.md` records:

```text
PROP-037: accepted proposal-only for external progression/service liveness
Managed local recursion / loop-class extension placeholders must use PROP-039+
or later until formally assigned.
```

That means R246 should not force local managed loops/recursion into PROP-037.
PROP-037 companion wording may cover service-loop binding, but local loops and
fuel recursion need Chapter 13 errata plus PROP-039+ assignment or an equivalent
later proposal route.

---

## Specification Input Design

### 1. Bounded Local Loops

Bounded local loops should be specified separately from `fold_stream`.

Input shape:

```text
loop Name in collection max_steps: N {
  ...
}
```

Spec-input obligations:

```text
Name is required for Postulate 28 trace/receipt/diagnostic identity.
collection must be finite or explicitly materialized before the loop executes.
max_steps is required even when collection finiteness is known.
loop body remains local computation; it does not imply service liveness.
fold_stream remains governed by stream/window semantics and OOF-S rules.
```

Recommended placement:

```text
Chapter 13 errata / Runtime Specification managed local loop section.
PROP-039+ or later should own local loop-class proposal assignment if a formal
PROP is required.
```

### 2. Recursion / decreases fuel

Recursion with `decreases fuel` belongs in managed local recursion wording, not
PROP-037 service liveness.

Input shape:

```text
def f(args...) -> T decreases fuel {
  ...
}
```

Spec-input obligations:

```text
recursive source-level behavior requires a termination witness;
missing or unsupported termination witness must fail closed;
fuel semantics must be explicit before executable proof;
recursive execution remains unaccepted and unproven;
lab parser/typechecker support is frontier evidence only.
```

Recommended placement:

```text
Chapter 13 errata + PROP-039+ managed local recursion / loop classes route.
```

### 3. Service Loop / PROP-037 Progression

Service-loop wording should be a PROP-037 companion or amendment only where it
clarifies surface-to-progression binding.

Input shape:

```text
loop tick in clock.every(5.seconds) {
  compute as_of = tick.time
}
```

Spec-input obligations:

```text
service loop is a surface;
progression is the semantic substrate;
clock.every maps to a progression source_kind already present in PROP-037;
service steps require bounded materialization, receipt, cancellation,
checkpoint, and backpressure obligations before execution authority;
no new PROGRESSION fragment class is accepted by this route;
lab ESCAPE classification and clock_tick capability are draft pressure only.
```

Recommended placement:

```text
PROP-037 companion/amendment for source-syntax binding and descriptor mapping.
Runtime Specification wording may reference that companion but should not
invent a separate service-loop runtime authority.
```

### 4. tick.time Explicit Binding

`tick.time` is ready as specification input.

Stance:

```text
tick.time is explicit event time from a materialized progression event;
it is not ambient clock access;
it must be distinguishable from materialized_at / scheduled_at if both are
present in progression metadata;
the initial source fixture may bind tick.time to deterministic valid time only.
```

This should be handled in the service-loop / PROP-037 companion wording.

### 5. source-level now() Prohibition

`now()` prohibition is ready as a design stance, but not as a registry decision.

Stance:

```text
source-level now() is hidden ambient time and must be rejected in contract,
function, loop, and service-loop bodies unless a later accepted profile creates
an explicit capability.
```

OOF reconciliation needed:

| Candidate | Source | Status |
| --- | --- | --- |
| `OOF-L6` | Chapter 8 stdlib | Existing spec text |
| `OOF-M1` / `OOF-M2` | pressure package | Draft pressure |
| `OOF-L2` | lab code/facts | Frontier draft pressure |

Recommended stance:

```text
Do not mint a new code in this C1-D.
Route OOF naming into the next wording sync.
Prefer one canonical source-level now() code with aliases/errata notes if older
docs already used another name.
```

### 6. Postulate 28 Loop Naming

Postulate 28 loop naming is ready as spec input.

Input stance:

```text
semantic loop blocks require explicit names.
Names are used for diagnostics, traces, future receipts, and proof fixtures.
```

OOF-L3 robustness requirement:

```text
Before implementation or proof acceptance, a fixture must prove unnamed-loop
diagnostics fire for realistic source patterns.
```

### 7. break

`break` should be excluded from the first spec input slice.

Reason:

```text
R245 found only a lexed keyword and VM opcode; source-level parser/emitter path
is unverified.
Including break now would expand the semantics surface beyond the accepted
pressure boundary.
```

Recommended stance:

```text
Treat break as a future extension. First spec slice should model termination
through collection exhaustion, max_steps/fuel, structural decreases, convergence,
or service cancellation/suspension obligations.
```

---

## Runtime Spec / PROP-037+ Input Matrix

| Surface | Input status | Recommended route |
| --- | --- | --- |
| `fold_stream` | Existing stream/window surface; not arbitrary loop proof | Keep separate; no R246 authoring |
| Bounded local loop | Design-ready | Chapter 13 errata / Runtime Spec wording |
| `max_steps` | Design-ready safety obligation | Chapter 13 errata / Runtime Spec wording |
| Recursion / `decreases fuel` | Design-ready, execution unproven | PROP-039+ / Chapter 13 errata |
| Service loop | Design-ready as surface only | PROP-037 companion/amendment |
| Progression substrate | Already PROP-037 proposal-only | Companion clarifies source syntax mapping |
| New fragment class | Not accepted | Keep closed |
| `tick.time` | Design-ready explicit binding | PROP-037 companion + Runtime Spec reference |
| `now()` prohibition | Design-ready, OOF unresolved | OOF reconciliation in wording sync |
| Postulate 28 loop naming | Design-ready | Chapter 13 errata + fixture requirement |
| OOF-L/OOF-SL registry | Draft input only | Wording sync; no registry acceptance yet |
| `break` | Not ready | Defer |
| Lab evidence | Frontier pressure only | Cite as pressure, not authority |

---

## Next Route Options

| Option | Value | Risk | Recommendation |
| --- | --- | --- | --- |
| Runtime Specification / Chapter 13 errata authoring | Fixes stale Chapter 13 and local recursion wording | Might miss PROP-037 service binding | Good, but not alone |
| PROP-037 companion / amendment authoring | Clarifies service-loop to progression mapping | Does not own local loops/recursion | Good, but not alone |
| Combined Runtime Spec + PROP-037+ wording sync | Handles local loops and service liveness together while keeping ownership split | Needs tight scope to avoid implementation creep | Prefer |
| Proof-local loop/recursion spec fixture | Gives executable-ish evidence after wording | Premature before wording settles | Later |
| Lab-only hardening/facts rerun | Useful for lab quality | Does not settle canon | Hold |
| Pause | Avoids drift only temporarily | Loses momentum | Do not prefer |

---

## Explicit Answers

Whether Runtime Specification / PROP-037+ input is design-ready:

```text
Yes.
```

Whether bounded local loops should be specified separately from `fold_stream`:

```text
Yes. `fold_stream` remains stream/window bounded reduction; bounded local loops
are a separate managed local repetition surface.
```

Whether recursion / `decreases fuel` belongs in Runtime Specification,
PROP-039+, Chapter 13 errata, or another route:

```text
It belongs in Chapter 13 errata / Runtime Specification wording, with formal
proposal ownership under PROP-039+ or later unless C4-A assigns another route.
It should not be folded into PROP-037 service liveness.
```

Whether service loops are sufficiently covered by PROP-037 or need a
companion/amendment:

```text
PROP-037 covers service-liveness semantics, but a companion/amendment is needed
to map source-level service-loop syntax, tick binding, and descriptor handoff to
the PROP-037 model.
```

Whether service-loop fragment-class authority remains closed:

```text
Yes. PROP-037 metadata/capability-first remains the accepted proposal stance.
No PROGRESSION fragment class is authorized.
```

Whether source-level `now()` prohibition should use OOF-M, OOF-L, or a
reconciled registry route:

```text
Use a reconciled registry route. Existing candidates conflict:
OOF-L6, OOF-M1/M2, and OOF-L2.
```

Whether `tick.time` binding is ready as spec input:

```text
Yes, as explicit event-time binding from a materialized progression event.
```

Whether Postulate 28 loop naming is ready as spec input:

```text
Yes.
```

Whether `break` should be excluded from the first spec input slice:

```text
Yes. Defer break until source-level semantics and parser/emitter path are
separately scoped.
```

Whether implementation authorization may open next or must wait:

```text
It must wait.
```

Whether `igc run` widening remains closed:

```text
Yes.
```

Whether lab implementation remains frontier evidence only:

```text
Yes.
```

---

## Exact C4-A Recommendation

Recommend that S3-R246-C4-A accept this input slice and open:

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

Candidate C2-I boundary, if authorized by R247-C1-A:

```text
Card: S3-R247-C2-I
Agent: [Compiler / Grammar Expert]
Role: compiler-grammar-expert
Track: experimental-loops-recursion-spec-prop037-wording-sync-v0

Allowed write scope:
  - igniter-lang/docs/tracks/
    experimental-loops-recursion-spec-prop037-wording-sync-v0.md
  - igniter-lang/docs/spec/ch13-managed-recursion.md
  - igniter-lang/docs/proposals/
    PROP-037-external-progression-service-liveness-v0.md
    only as companion/amendment wording if C1-A explicitly authorizes
  - igniter-lang/docs/proposals/README.md
    only if C1-A explicitly authorizes index/status wording

Closed unless explicitly authorized:
  - igniter-lang/lib/**
  - igniter-lang/bin/igc
  - igniter-lang/igniter_lang.gemspec
  - igniter-lang/README.md
  - igniter-lang/docs/README.md
  - igniter-lang/docs/ruby-api.md
  - igniter-lang/source/**
  - igniter-lang/out/**
  - igniter-lang/experiments/**
  - playgrounds/**
```

Required R247 authoring goals:

```text
separate fold_stream / bounded local loop / recursion / service-loop surfaces
update Chapter 13 stale PROP-037+ placeholder status
remove or correct stale now() examples
define bounded local loop and decreases fuel design vocabulary
map service-loop source binding to PROP-037 progression descriptors
record no new fragment class / no runtime authority
reconcile OOF-L6 vs OOF-M1/M2 vs OOF-L2 into a proposed registry stance
record OOF-L3 robustness as future fixture requirement
defer break
preserve lab evidence as frontier pressure only
```

Required closed surfaces for R247:

```text
implementation
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

If C4-A finds C2-P1 facts contradict this design, route a facts-only correction
before authoring. Otherwise, R247 should be docs/proposal/spec authoring
authorization review, not proof-local execution.
