# Stage 3 Round 237 Status Curation v0

Card: S3-R237-C5-S (implicit status curation; no separate dispatch card)
Skill: IDD Agent Protocol
Agent: [Status Curator]
Role: status-curator
Track: stage3-round237-status-curation-v0
Route: SUMMARY
Status: done
Date: 2026-06-02

Depends on:
- S3-R237-C1-D
- S3-R237-C2-P1
- S3-R237-C3-X
- S3-R237-C4-A

---

## Executive Summary

R237 conditionally accepts `playgrounds/igniter-lab/igniter-stdlib` as stdlib
candidate evidence and PROP-013 applied pressure only.

The accepted next Main Line route is:

```text
S3-R238-C1-A
experimental-stdlib-candidate-proof-authorization-review-v0
```

Route type:

```text
future proof-local authorization review
not live implementation
not mainline stdlib mutation
not public API or runtime authority
```

No mainline stdlib replacement, public stdlib API, runtime/API/CLI/package
change, `igc run` widening, release, public/stable/production, Reference
Runtime, Spark, performance, official/reference, certification, or portability
authority is opened by R237.

---

## Inputs Read

- `igniter-lang/docs/cards/S3/S3-R237.md`
- `igniter-lang/docs/tracks/experimental-stdlib-candidate-intake-and-prop013-pressure-v0.md`
- `igniter-lang/docs/tracks/experimental-stdlib-candidate-surface-facts-v0.md`
- `igniter-lang/docs/discussions/experimental-stdlib-candidate-pressure-v0.md`
- `igniter-lang/docs/tracks/experimental-stdlib-candidate-intake-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round236-status-curation-v0.md`
- `igniter-lang/docs/current-status.md`

---

## Outcome Table

| Card | Status | Curated result |
| --- | --- | --- |
| S3-R237-C1-D | design / recommend proof follow-up | Recommends accepting stdlib candidate evidence and routing proof-local authorization next. |
| S3-R237-C2-P1 | complete | Surface facts accepted; Decimal FFI strongest signal; collections internal Rust-only; temporal/signatures scoped. |
| S3-R237-C3-X | CONDITIONAL PASS | No blockers; mandatory C-1/C-2/C-3 scoping conditions required. |
| S3-R237-C4-A | conditional accept | Accepts candidate evidence only and opens S3-R238-C1-A proof authorization review. |
| S3-R237-C5-S | done | Current status updated with compact R237 delta and exact R238 route. |

---

## Curated Status

Accepted / conditional / held status:

```text
stdlib candidate evidence: conditionally accepted
Decimal FFI evidence: accepted as strongest candidate signal
OOF-TC5 / OOF-DM2 behavior: accepted as candidate evidence
PROP-013 pressure: accepted as applied pressure only
canonical PROP-013 authority: unchanged
implementation next: no
```

Accepted candidate evidence:

```text
Decimal FFI add/sub/mul/div
OOF-TC5 scale mismatch behavior
OOF-DM2 decimal division failure behavior
signature file presence for math, collections, temporal
PROP-013 and Stage 1 stdlib execution vocabulary pressure
```

Conditional / scoped surfaces:

```text
collections: internal Rust-only candidate evidence, not FFI-exported
temporal: domain-specific slot scheduling helper only
stdlib/*.ig signatures: design-pressure only, not accepted Igniter source
verifier PASS: Decimal FFI correctness + signature file presence only
```

Mandatory C4-A conditions recorded:

```text
C-1 Temporal module scoped as domain-specific scheduling example;
    not general bitemporal stdlib, not History[T]/BiHistory[T],
    not as_of / valid_time / transaction_time.

C-2 Verifier scope bounded to Decimal FFI correctness (14 assertions PASS)
    plus signature file presence (3 assertions PASS);
    collections and temporal correctness are not tested.

C-3 stdlib/*.ig signatures are design-pressure only;
    non-current syntax and undefined domain types are not accepted source
    or public stdlib API.
```

---

## Gap Register

Carried into the R238 proof authorization review:

```text
G-1 no Rust unit tests
G-2 collections not FFI-exported
G-3 temporal module is domain-specific, not general bitemporal
G-4 .ig signature types are non-current grammar
G-5 runtime_implementation_id absent
G-6 no evidence class or non-claims in source
G-7 Decimal division truncates; no rounding policy documented
G-8 to_f64 is inexact; utility only
G-9 stdlib.integer.add / stdlib.float.add not FFI-exported
```

---

## Sequencing

R237 keeps:

```text
S3-R238-C1-A proof-local stdlib candidate proof authorization review: open next
igniter-vm candidate intake: held until stdlib proof boundary closes
igc run Slice 1: held
TBackend intake: held pending wording hardening
Runtime Specification input slice: held until proof pressure is sharper
```

---

## Closed Surfaces

R237 does not authorize or imply:

```text
live implementation
mainline stdlib replacement
public stdlib API
runtime/API/CLI/package changes
igc run widening
.igbin execution
compiler passport emission
RuntimeSmoke productization
public runtime support
Reference Runtime support
stable API
production readiness
Spark integration
release execution
public performance claims
official/reference status
alternative certification
portability guarantees
PROP-013 canonical authority change
```

---

## Current Status Delta

`igniter-lang/docs/current-status.md` was updated with:

```text
R237 conditional stdlib candidate acceptance
Decimal FFI / OOF-TC5 / OOF-DM2 evidence status
C-1/C-2/C-3 mandatory scope conditions
R238 proof authorization review next route
closed surfaces preserved
```

---

## Exact Handoff

Next Main Line dispatch:

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
Decimal FFI, verifier-scope hardening, collections/temporal scoping,
design-pressure `.ig` signatures, and igniter-vm dependency readiness, without
authorizing mainline stdlib replacement, public stdlib API, runtime/API/CLI/
package changes, or public/runtime/stable claims.
```
