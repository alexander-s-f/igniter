# Experimental Lab Ecosystem Next Route Decision v0

Card: S3-R236-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-lab-ecosystem-next-route-decision-v0
Route: UPDATE
Status: accepted / stdlib-intake-next
Date: 2026-06-02

Depends on:
- S3-R236-C1-D
- S3-R236-C2-P1
- S3-R236-C3-X

---

## Decision

Accept the lab ecosystem pressure map and use it as the current routing frame
for experimental executable productization.

Accepted inputs:

```text
S3-R236-C1-D: accepted as design/recommendation
S3-R236-C2-P1: accepted as source-grounded facts packet
S3-R236-C3-X: PASS / no blockers / one sequencing note
```

The next Main Line route is:

```text
S3-R237-C1-D
experimental-stdlib-candidate-intake-and-prop013-pressure-v0
```

Route type:

```text
read-only candidate intake / proof-pressure design
not implementation
not public stdlib API
not package or runtime authority
```

This decision does not authorize implementation, `igc run` widening, `.igbin`
execution, compiler passport emission, RuntimeSmoke productization, Reference
Runtime support, public runtime support, stable API, production readiness,
Spark integration, release execution, public docs claims, public performance
claims, Official Reference Implementation status, alternative certification,
or portability guarantees.

---

## Inputs Read

```text
igniter-lang/docs/tracks/
  experimental-lab-ecosystem-pressure-map-and-intake-prioritization-v0.md
igniter-lang/docs/tracks/
  experimental-lab-ecosystem-surface-facts-v0.md
igniter-lang/docs/discussions/
  experimental-lab-ecosystem-pressure-v0.md
igniter-lang/docs/tracks/stage3-round235-status-curation-v0.md
igniter-lang/docs/tracks/experimental-igc-run-slice0-quickstart-docs-v0.md
igniter-lang/docs/tracks/
  delegated-experimental-compiler-rust-candidate-intake-v0.md
```

---

## Compact Decision Summary

```text
lab ecosystem pressure map: accepted
surface facts packet: accepted
pressure verdict: PASS
lab components: evidence only, not authority
next Main Line: stdlib candidate intake / PROP-013 proof pressure
implementation next: no
igc run Slice 1: held
TBackend intake: held pending wording hardening
VM intake: next after stdlib, unless later pressure redirects
Rust compiler hardening: sidecar/follow-up before portability comparison
```

---

## Accepted Component Classification

| Component | Accepted classification | Decision status |
| --- | --- | --- |
| `igniter-compiler` | Alternative experimental compiler candidate | Accepted as R235 lab evidence; hardening gaps remain. |
| `igniter-runtime` | Delegated experimental runtime candidate arena | Existing R225-R228 evidence carried; no widening. |
| `igniter-vm` | Delegated experimental runtime candidate | Strong next-after-stdlib candidate; not opened now. |
| `igniter-stdlib` | Stdlib candidate / PROP-013 pressure source | **Open next Main Line intake.** |
| `igniter-tbackend` | Backend / substrate candidate | Held pending wording hardening before intake. |
| `acts-as-tbackend` | Adapter / integration candidate | Parked until TBackend intake exists. |
| `igniter-apps/todolist` | App-consumer / UX pressure | Parked as product pressure only. |
| `igniter-apps/benchmark-app` | Benchmark / performance pressure only | Lab-only; no public performance claim. |

Accepted hierarchy vocabulary:

```text
Igniter Specification
  -> Official Reference Implementation
  -> Delegated Experimental Runtimes
  -> Alternative Experimental Compiler Candidates
  -> Backend / substrate candidates
  -> Stdlib candidates
  -> App-consumer / UX pressure surfaces
  -> Alternative Certified Implementations later
```

---

## Accepted Lab Overclaim Policy

Accepted:

```text
lab-local enthusiastic wording may remain tolerated inside playground docs
while the lab is explicitly experimental
```

Binding for mainline:

```text
mainline records must translate lab assertions into strict evidence and
non-claim vocabulary
```

Do not copy lab claims into mainline as authority:

```text
production-grade
zero-dependency
incredible throughput
prevents PostgreSQL bloat (SparkCRM)
public benchmark
official implementation
certified implementation
Reference Runtime support
public runtime support
stable API
portable artifact guarantee
```

C3-X correctly identifies the `igniter-tbackend` README as the highest
overclaim risk. TBackend candidate intake remains held until wording is
hardened or explicitly scoped as lab-local assertion in an intake-safe way.

---

## Sequencing Resolution

C1-D recommended:

```text
stdlib -> TBackend
```

C2-P1 and C3-X recommended:

```text
stdlib -> igniter-vm -> TBackend after wording hardening
```

C4-A resolves the sequence as:

```text
1. stdlib candidate intake / PROP-013 pressure
2. igniter-vm candidate intake, if stdlib intake accepts the evidence chain
3. TBackend candidate intake only after README/docs wording hardening
```

Reason:

```text
igniter-vm depends on igniter-stdlib as a local path dependency and already
has locally confirmed VM tests in C2-P1, while TBackend has high strategic
value but also high wording/claim risk.
```

This keeps runtime momentum without importing backend/product/performance
claims too early.

---

## Route Status Decisions

| Route option | Decision |
| --- | --- |
| stdlib candidate intake / PROP-013 proof pressure | **Open next.** |
| Rust TBackend candidate intake / Phase 2 pressure | Hold pending wording hardening. |
| experimental lab ecosystem docs/status map sync | Optional later; not next. |
| Rust compiler hardening authorization review | Sidecar/follow-up before portability comparison. |
| experimental `igc run` Slice 1 design-only | Hold until at least stdlib intake closes. |
| Runtime Specification input slice | Useful after stdlib/VM sequence; not next. |
| benchmark-app consumer intake | Hold; benchmark claims closed. |
| acts-as-tbackend / Chronicle concept route | Park until TBackend intake exists. |
| pause | Not selected. |

---

## Exact Next Dispatch Recommendation

```text
Card: S3-R237-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-stdlib-candidate-intake-and-prop013-pressure-v0

Route: UPDATE
Depends on:
- S3-R236-C4-A

Goal:
Review `playgrounds/igniter-lab/igniter-stdlib` as a stdlib candidate and
PROP-013 applied-pressure source, preserving candidate/evidence-only status
and keeping runtime/API/package/public authority closed.

Scope:
- Read:
  - igniter-lang/docs/tracks/
    experimental-lab-ecosystem-next-route-decision-v0.md
  - igniter-lang/docs/tracks/
    experimental-lab-ecosystem-surface-facts-v0.md
  - igniter-lang/docs/discussions/
    experimental-lab-ecosystem-pressure-v0.md
  - igniter-lang/docs/tracks/stage3-round235-status-curation-v0.md
  - igniter-lang/docs/proposals/PROP-013-stdlib-kernel-v0.md if present
  - igniter-lang/docs/tracks/stdlib-execution-kernel-stage1-v0.md
    if present
  - playgrounds/igniter-lab/igniter-stdlib/Cargo.toml
  - playgrounds/igniter-lab/igniter-stdlib/src/**
  - playgrounds/igniter-lab/igniter-stdlib/stdlib/**
  - playgrounds/igniter-lab/igniter-stdlib/verify_stdlib.rb
- Review:
  - `.ig` signature surface;
  - Decimal FFI exports;
  - OOF-TC5 and OOF-DM2 behavior;
  - collections and temporal signature status;
  - relationship to PROP-013 and Stage 1 stdlib kernel evidence;
  - whether a bounded proof route may open later.
- Decide:
  - accept as stdlib candidate evidence;
  - conditional accept with exact hardening follow-up;
  - hold pending source/signature/verification fixes;
  - route proof-local stdlib candidate proof authorization review;
  - redirect to Runtime Specification input slice;
  - pause.

Allowed output:
- igniter-lang/docs/tracks/
  experimental-stdlib-candidate-intake-and-prop013-pressure-v0.md

Do not:
- edit code;
- authorize mainline stdlib replacement;
- authorize public stdlib API;
- authorize runtime/API/package changes;
- authorize stable API, production, public runtime, Reference Runtime, Spark,
  release, public performance, official/reference status, alternative
  certification, or portability guarantees.

Deliver:
- Intake/design doc in `igniter-lang/docs/tracks/`
- Compact stdlib candidate support/gap matrix
- Exact C4-A recommendation
```

Parallel sidecar recommendation, not Main Line:

```text
igniter-tbackend lab README wording hardening

Required before TBackend intake:
  correct or remove "zero-dependency"
  scope "production-grade" as lab-local or remove
  scope SparkCRM mention as lab-local or remove
  label all performance/throughput language as research-only
```

---

## Explicit Answers

Whether the lab ecosystem pressure map is accepted:

```text
Yes. Accepted.
```

Whether lab components create authority:

```text
No. Lab components create evidence and pressure only.
```

Whether lab components may be named as delegated/alternative candidates:

```text
Yes, only with explicit evidence-only / non-canonical / non-authoritative
wording.
```

Whether implementation may open next:

```text
No live implementation may open next. The next route is read-only candidate
intake / proof-pressure design.
```

Whether `igc run` widening remains closed:

```text
Yes. `igc run` Slice 1 remains held.
```

Whether `.igbin`, compiler passport emission, RuntimeSmoke productization,
Reference Runtime, public runtime, stable API, production, Spark, release,
public demo, public docs claims, public performance claims, official reference
status, alternative certification, and portability guarantees remain closed:

```text
Yes. All remain closed.
```

---

## Closed Surfaces

This decision does not authorize:

```text
implementation
igc run widening
.igbin execution
compiler passport emission
RuntimeSmoke productization
Reference Runtime implementation
public runtime support
stable API before v1
production readiness
public demo claims
public docs claims
Spark integration
release execution or release evidence
public performance claims
Official Reference Implementation status
alternative certification
artifact portability guarantees
mainline runtime/API/CLI/package changes
mainline stdlib replacement
public stdlib API
```

