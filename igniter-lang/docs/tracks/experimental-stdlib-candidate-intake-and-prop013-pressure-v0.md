# Experimental Stdlib Candidate Intake and PROP-013 Pressure v0

Card: S3-R237-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-stdlib-candidate-intake-and-prop013-pressure-v0
Route: UPDATE
Status: design / recommend-accept-candidate-evidence-with-proof-follow-up
Date: 2026-06-02

Depends on:
- S3-R236-C4-A

---

## Authority Notice

This is a read-only intake/design document. It does not authorize code edits,
mainline stdlib replacement, public stdlib API, runtime/API/package changes,
`igc run` widening, `.igbin` execution, compiler passport emission,
RuntimeSmoke productization, Reference Runtime support, public runtime
support, stable API, production readiness, Spark integration, release
execution, public performance claims, Official Reference Implementation
status, alternative certification, or portability guarantees.

`playgrounds/igniter-lab/igniter-stdlib` is reviewed here as candidate
evidence and as applied pressure on PROP-013. Evidence is not authority.

---

## Inputs Read

```text
igniter-lang/docs/tracks/stage3-round236-status-curation-v0.md
igniter-lang/docs/tracks/
  experimental-lab-ecosystem-next-route-decision-v0.md
igniter-lang/docs/tracks/
  experimental-lab-ecosystem-surface-facts-v0.md
igniter-lang/docs/tracks/stage3-round235-status-curation-v0.md
igniter-lang/docs/proposals/accepted/
  PROP-013-stdlib-fold-aggregate-v0.md
igniter-lang/docs/tracks/stdlib-execution-kernel-stage1-v0.md
igniter-lang/docs/spec/ch8-stdlib.md
igniter-lang/docs/current-status.md
playgrounds/igniter-lab/igniter-stdlib/Cargo.toml
playgrounds/igniter-lab/igniter-stdlib/Cargo.lock
playgrounds/igniter-lab/igniter-stdlib/src/**
playgrounds/igniter-lab/igniter-stdlib/stdlib/**
playgrounds/igniter-lab/igniter-stdlib/verify_stdlib.rb
```

No verifier command was run by this C1-D route. R236-C2-P1 already recorded a
local `ruby verify_stdlib.rb` PASS signal for the lab candidate; this document
classifies the surface and its gaps.

---

## Recommendation

Accept `igniter-stdlib` as stdlib candidate evidence, with a narrow meaning:

```text
accepted evidence:
  Decimal FFI arithmetic surface
  OOF-TC5 scale mismatch behavior
  OOF-DM2 decimal division failure behavior
  presence of .ig signature files for math, collections, and temporal surfaces
  applied pressure on PROP-013 and Stage 1 stdlib execution vocabulary

not accepted:
  mainline stdlib replacement
  public stdlib API
  canonical stdlib naming authority
  full PROP-013 closure
  RuntimeMachine / igc run / package authority
```

Exact C4-A recommendation:

```text
accept candidate evidence;
route proof-local stdlib candidate proof authorization review next;
keep igniter-vm candidate intake held until this stdlib proof route closes;
keep all implementation and public authority closed.
```

Suggested next route:

```text
Card: S3-R238-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-stdlib-candidate-proof-authorization-review-v0

Route: UPDATE
Depends on:
- S3-R237-C4-A

Goal:
Decide whether a bounded proof-local stdlib candidate proof may begin for
Decimal FFI, canonical-name fit, collections signature pressure, temporal
signature pressure, and igniter-vm dependency readiness, without authorizing
mainline stdlib replacement or public stdlib API.
```

---

## Candidate Surface Summary

`igniter-stdlib` is a Rust crate under the experimental lab:

```text
package: igniter_stdlib
crate type: rlib, cdylib
production authority: none
mainline dependency authority: none
public API authority: none
```

Observed surfaces:

```text
src/lib.rs
  FFI exports:
    stdlib_decimal_add
    stdlib_decimal_sub
    stdlib_decimal_mul
    stdlib_decimal_div

src/decimal.rs
  Decimal { value: i64, scale: u32 }
  scale mismatch failures
  decimal division failures

src/collections.rs
  range, filter, map, fold, first, count over proof-local Value

src/temporal.rs
  availability-oriented JSON helpers

stdlib/math.ig
  Decimal math signatures

stdlib/collections.ig
  bounded collection signatures

stdlib/temporal.ig
  domain-oriented temporal availability signatures

verify_stdlib.rb
  lab verifier for Decimal FFI and signature presence
```

---

## Support / Gap Matrix

| Area | Candidate support | Gap / boundary |
| --- | --- | --- |
| Decimal FFI exports | Strong candidate evidence. `add`, `sub`, `mul`, and `div` are exported through `cdylib` FFI. | Evidence only. Does not define mainline ABI, package dependency, or public API. |
| OOF-TC5 | Scale mismatch is represented as a failing Decimal operation. | Needs proof-local assertion shape before it can pressure canonical diagnostics. |
| OOF-DM2 | Decimal division by zero is represented as a failing operation. | Needs proof-local failure envelope comparison with Igniter diagnostics vocabulary. |
| Decimal representation | `Decimal { value: i64, scale: u32 }` is concrete and useful. | Stage 1 already notes Decimal representation is not standardized across `.igapp`, SemanticIR, and RuntimeMachine. |
| Math signatures | `.ig` signatures exist in `stdlib/math.ig`. | Naming is not yet canonical: lab module/signature style must be compared to `stdlib.decimal.*` / monomorphic runtime names. |
| Collections | Rust helpers and `.ig` signatures exist for bounded `range`, `filter`, `map`, `fold`, `first`, `count`. | No observed FFI export surface for collections; no `group_by`, `sum`, `avg`, `Option`, or `Result` closure. |
| Temporal | `stdlib/temporal.ig` and Rust helpers exist. | Current shape is domain availability oriented, not yet canonical `TemporalCtx` date/time primitive coverage. |
| PROP-013 fit | Provides applied evidence for finite collections and stdlib kernel pressure. | Does not close PROP-013; it sharpens which names, envelopes, and failure modes need proof. |
| Stage 1 kernel fit | Reinforces Decimal and bounded collection pressure. | Stage 1 proof remains proof fixture; this lab crate is a separate candidate, not a replacement. |
| `igniter-vm` relationship | Important because `igniter-vm` depends on `igniter-stdlib` as lab dependency. | VM intake should wait until stdlib candidate evidence is accepted and proof-local boundaries are explicit. |

---

## PROP-013 Applied Pressure

PROP-013 expects:

```text
Collection[T]
Option[T]
Result[T, E]
bounded fold / map / filter / group_by / count / sum / avg
TemporalCtx-backed temporal/date primitives
CORE-safe termination over finite collections
```

`igniter-stdlib` pressures PROP-013 in three useful ways:

```text
1. It turns Decimal arithmetic into an actual FFI boundary instead of only a
   symbolic stdlib entry.

2. It shows a plausible bounded collection helper set, but also exposes the
   missing public question: are collection operations exported as runtime
   functions, VM primitives, or compiler-recognized stdlib operators?

3. It shows temporal helpers are likely to split into two categories:
   generic temporal/date primitives and domain/backend availability helpers.
```

Recommended PROP-013 follow-up:

```text
record applied pressure, but do not amend PROP-013 in this route;
use a proof-local stdlib candidate proof to produce concrete naming,
failure, and capability evidence first.
```

---

## Explicit Answers

Whether `igniter-stdlib` can be accepted as candidate evidence:

```text
yes, for candidate evidence only.
```

Whether this creates mainline stdlib replacement authority:

```text
no.
```

Whether this creates public stdlib API authority:

```text
no.
```

Whether Decimal FFI evidence is enough for candidate intake:

```text
yes, enough for candidate intake; not enough for public API, ABI, package, or
canonical stdlib authority.
```

Whether collections/temporal signatures are evidence or blockers:

```text
evidence and pressure, not blockers for candidate intake.
They remain blockers for any broader stdlib support claim.
```

Whether PROP-013 should receive applied-pressure follow-up:

```text
yes. The follow-up should be proof-local first, then vocabulary/spec sync only
after the proof shows which names and envelopes survive.
```

Whether VM intake should wait for this route to close:

```text
yes. `igniter-vm` depends on `igniter-stdlib`; VM intake should wait until the
stdlib candidate status and proof expectations are accepted by C4-A.
```

Whether implementation may open next:

```text
no live/mainline implementation may open next.
A future proof-local stdlib candidate proof authorization review may open if
C4-A accepts this route.
```

Whether public/stable/production/Reference Runtime/Spark/release/performance
and portability claims remain closed:

```text
yes, all remain closed.
```

---

## Exact C4-A Recommendation

```text
Decision:
  accept `igniter-stdlib` as stdlib candidate evidence;
  classify Decimal FFI as strong candidate signal;
  classify collections and temporal signatures as useful pressure with gaps;
  keep PROP-013 canonical authority unchanged;
  keep mainline stdlib/public API/runtime/package authority closed.

Next route:
  experimental-stdlib-candidate-proof-authorization-review-v0

Held:
  igniter-vm candidate intake until stdlib proof boundary closes;
  Runtime Specification input slice until proof pressure is sharper;
  TBackend/acts-as-tbackend/app-consumer routes.

Closed:
  implementation;
  mainline stdlib replacement;
  public stdlib API;
  `igc run` widening;
  `.igbin` execution;
  compiler passport emission;
  RuntimeSmoke productization;
  Reference Runtime support;
  public runtime support;
  stable API;
  production readiness;
  Spark integration;
  release execution;
  public performance claims;
  official/reference status;
  alternative certification;
  portability guarantees.
```
