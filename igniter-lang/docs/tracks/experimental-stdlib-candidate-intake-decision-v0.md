# Experimental Stdlib Candidate Intake Decision v0

Card: S3-R237-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-stdlib-candidate-intake-decision-v0
Route: UPDATE
Status: conditional-accept / proof-authorization-review-next
Date: 2026-06-02

Depends on:
- S3-R237-C1-D
- S3-R237-C2-P1
- S3-R237-C3-X

---

## Decision

Conditionally accept `playgrounds/igniter-lab/igniter-stdlib` as stdlib
candidate evidence.

Accepted meaning:

```text
candidate evidence only
PROP-013 applied pressure only
not mainline stdlib replacement
not public stdlib API
not runtime/API/CLI/package authority
```

The next Main Line route is:

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

This decision does not authorize implementation, mainline stdlib replacement,
public stdlib API, runtime/API/CLI/package changes, `igc run` widening,
`.igbin` execution, compiler passport emission, RuntimeSmoke productization,
Reference Runtime support, public runtime support, stable API, production
readiness, Spark integration, release execution, public performance claims,
official/reference status, alternative certification, or portability
guarantees.

---

## Inputs Read

```text
igniter-lang/docs/tracks/
  experimental-stdlib-candidate-intake-and-prop013-pressure-v0.md
igniter-lang/docs/tracks/
  experimental-stdlib-candidate-surface-facts-v0.md
igniter-lang/docs/discussions/
  experimental-stdlib-candidate-pressure-v0.md
igniter-lang/docs/tracks/stage3-round236-status-curation-v0.md
igniter-lang/docs/tracks/
  experimental-lab-ecosystem-next-route-decision-v0.md
```

---

## Compact Decision Summary

```text
stdlib candidate evidence: conditional accept
Decimal FFI evidence: accepted as strongest signal
OOF-TC5 / OOF-DM2: accepted as candidate evidence
.ig signatures: design-pressure only, not accepted Igniter source
collections: internal Rust-only candidate evidence, not FFI/proven stdlib
temporal: domain-specific scheduling helper, not bitemporal stdlib
PROP-013 pressure: accepted, no canonical authority change
VM intake: held until stdlib proof route closes
implementation next: no
igc run Slice 1: held
TBackend intake: held pending wording hardening
```

---

## Mandatory Scope Conditions

S3-R237-C3-X issued a CONDITIONAL PASS. This decision accepts the route only
with the following mandatory scopes.

### C-1: Temporal Module Scope

```text
temporal module: domain-specific slot scheduling example
not general bitemporal stdlib
not History[T] / BiHistory[T] coverage
not as_of / valid_time / transaction_time semantics
intake classification: domain-specific stdlib helper example only
not stdlib.Temporal authority for PROP-022/PROP-028 temporal vocabulary
```

### C-2: Verifier Scope

```text
verifier scope (verify_stdlib.rb):
  Decimal FFI correctness: 14 assertions PASS
  signature file presence: 3 assertions PASS
  collections correctness: not tested
  temporal correctness: not tested
exit string "ALL STANDARD LIBRARY CORRECTNESS": lab-assertion style;
  scope is narrower than the string implies;
  not accepted as collections or temporal correctness evidence
```

### C-3: `.ig` Signature Scope

```text
stdlib/*.ig signatures: design-pressure only
cannot be parsed by current igc compile pipeline
type syntax (Decimal[S], Collection[T], (T) -> Bool, Option[T]) is non-current
domain types (GeoSignal, ScheduleFact, TimeSlot, AvailabilitySnapshot) undefined
intake value: PROP-013 design pressure and API-shape discussion only
not accepted Igniter source
not accepted as stdlib API surface
```

---

## Recorded Status

| Surface | Status |
| --- | --- |
| Stdlib candidate acceptance | Conditionally accepted as evidence only. |
| Decimal FFI | Accepted as primary candidate evidence: `add`, `sub`, `mul`, `div`. |
| OOF-TC5 | Accepted as candidate evidence for Decimal scale mismatch. |
| OOF-DM2 | Accepted as candidate evidence for Decimal division failure. |
| Decimal division | Accepted only with truncation/rounding-policy caveat; no financial-grade claim. |
| Collections | Internal Rust-only candidate evidence; not FFI-exported; not verifier-proven. |
| Temporal | Domain-specific scheduling helper evidence only; not bitemporal stdlib. |
| `.ig` signatures | Design-pressure only; not accepted Igniter source or stdlib API. |
| PROP-013 pressure | Accepted as applied pressure; no PROP-013 canonical authority change. |
| VM dependency/sequencing | `igniter-vm` intake remains held until stdlib proof boundary closes. |
| Public stdlib/API/runtime authority | Closed. |
| Implementation | Closed. |
| `igc run` Slice 1 | Held. |
| TBackend intake | Held pending wording hardening. |

---

## Next Route Boundary

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

Next route type:

```text
future implementation-authorization review for proof-local work only
```

Allowed read scope for S3-R238-C1-A should include:

```text
igniter-lang/docs/tracks/
  experimental-stdlib-candidate-intake-decision-v0.md
igniter-lang/docs/tracks/
  experimental-stdlib-candidate-intake-and-prop013-pressure-v0.md
igniter-lang/docs/tracks/
  experimental-stdlib-candidate-surface-facts-v0.md
igniter-lang/docs/discussions/
  experimental-stdlib-candidate-pressure-v0.md
igniter-lang/docs/proposals/accepted/
  PROP-013-stdlib-fold-aggregate-v0.md
igniter-lang/docs/tracks/stdlib-execution-kernel-stage1-v0.md
playgrounds/igniter-lab/igniter-stdlib/**
playgrounds/igniter-lab/igniter-vm/Cargo.toml
```

Candidate future proof write scope, if S3-R238-C1-A later authorizes C2-I:

```text
playgrounds/igniter-lab/igniter-stdlib/**
igniter-lang/docs/tracks/
  experimental-stdlib-candidate-proof-v0.md
```

Read-only / closed unless explicitly authorized:

```text
igniter-lang/lib/**
igniter-lang/bin/igc
igniter-lang/igniter_lang.gemspec
igniter-lang/README.md
igniter-lang/docs/README.md
igniter-lang/docs/ruby-api.md
igniter-lang/lib/igniter_lang/runtime_smoke.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
```

Expected proof/facts matrix for the future route:

```text
STD-P1: Decimal FFI add/sub/mul/div behavior confirmed.
STD-P2: OOF-TC5 scale mismatch behavior confirmed.
STD-P3: OOF-DM2 division failure behavior confirmed.
STD-P4: Decimal division truncation and missing rounding policy documented.
STD-P5: Verifier scope is narrowed or proof packet records exact assertion set.
STD-P6: Collections are classified as internal Rust-only unless separately exported.
STD-P7: Temporal is classified as domain-specific scheduling helper only.
STD-P8: `.ig` signatures are classified as design-pressure and non-current syntax.
STD-P9: `runtime_implementation_id` / evidence class / non-claims packet is present.
STD-P10: `igniter-vm` dependency readiness is observed without opening VM intake.
STD-P11: No mainline stdlib, runtime, API, CLI, package, RuntimeSmoke, or report changes.
STD-P12: Public/stable/production/reference/performance/portability claims remain closed.
```

Evidence/authority wording required:

```text
generated output may be called proof-local stdlib candidate evidence only
not mainline stdlib replacement
not public stdlib API
not public runtime support
not Reference Runtime support
not production/stable/performance/portability evidence
```

---

## Explicit Answers

Whether `igniter-stdlib` candidate evidence is accepted:

```text
yes, conditionally, as candidate evidence only.
```

Whether this creates mainline stdlib replacement authority:

```text
no.
```

Whether this creates public stdlib API authority:

```text
no.
```

Whether implementation may open next:

```text
no live implementation may open next.
Only a future proof-local authorization review may open next.
```

Whether VM intake may open next:

```text
no. VM intake remains held until the stdlib proof boundary closes.
```

Whether `igc run` Slice 1 remains held:

```text
yes.
```

Whether TBackend intake remains held pending wording hardening:

```text
yes.
```

Whether public/stable/production/Reference Runtime/Spark/release/performance
and portability claims remain closed:

```text
yes, all remain closed.
```

Exact next dispatch recommendation:

```text
S3-R238-C1-A
experimental-stdlib-candidate-proof-authorization-review-v0
```

---

## Closed Surfaces

This decision keeps closed:

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
```
