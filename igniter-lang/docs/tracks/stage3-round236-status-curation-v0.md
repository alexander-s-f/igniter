# Stage 3 Round 236 Status Curation v0

Card: S3-R236-C5-S (implicit status curation; no separate dispatch card)
Skill: IDD Agent Protocol
Agent: [Status Curator]
Role: status-curator
Track: stage3-round236-status-curation-v0
Route: SUMMARY
Status: done
Date: 2026-06-02

Depends on:
- S3-R236-C1-D
- S3-R236-C2-P1
- S3-R236-C3-X
- S3-R236-C4-A

---

## Executive Summary

R236 accepts the experimental lab ecosystem pressure map as the current routing
frame after accepted `igc run` Slice 0 implementation and bounded quickstart
docs.

The accepted next Main Line route is:

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

No implementation, public runtime, Reference Runtime, stable API, production,
Spark, release, public performance, official/reference, certification, or
portability authority is opened by R236.

---

## Inputs Read

- `igniter-lang/docs/cards/S3/S3-R236.md`
- `igniter-lang/docs/tracks/experimental-lab-ecosystem-pressure-map-and-intake-prioritization-v0.md`
- `igniter-lang/docs/tracks/experimental-lab-ecosystem-surface-facts-v0.md`
- `igniter-lang/docs/discussions/experimental-lab-ecosystem-pressure-v0.md`
- `igniter-lang/docs/tracks/experimental-lab-ecosystem-next-route-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round235-status-curation-v0.md`
- `igniter-lang/docs/current-status.md`

---

## Outcome Table

| Card | Status | Curated result |
| --- | --- | --- |
| S3-R236-C1-D | accepted | Lab ecosystem pressure map accepted as routing design; stdlib intake recommended next. |
| S3-R236-C2-P1 | accepted | Source-grounded facts packet accepted; stdlib and VM verifier evidence confirmed, TBackend overclaim risks identified. |
| S3-R236-C3-X | PASS | No blockers; one sequencing note resolved by C4-A. |
| S3-R236-C4-A | accepted | Accepts map/facts/pressure and opens R237 stdlib candidate intake next. |
| S3-R236-C5-S | done | Current status updated with compact R236 delta and exact R237 route. |

---

## Curated Status

Accepted / conditional / held status:

```text
lab ecosystem pressure map: accepted
surface facts packet: accepted
pressure verdict: PASS / no blockers
next Main Line: stdlib candidate intake / PROP-013 pressure
implementation next: no
```

Accepted routing hierarchy:

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

Accepted component classifications:

| Component | Classification | R236 status |
| --- | --- | --- |
| `igniter-compiler` | Alternative experimental compiler candidate | R235 lab evidence carried; GAP-1..GAP-7 remain. |
| `igniter-runtime` | Delegated experimental runtime candidate arena | R225-R228 evidence carried; no widening. |
| `igniter-vm` | Delegated experimental runtime candidate | Strong next-after-stdlib candidate; not opened now. |
| `igniter-stdlib` | Stdlib candidate / PROP-013 pressure source | Open next Main Line intake. |
| `igniter-tbackend` | Backend / substrate candidate | Held pending wording hardening before intake. |
| `acts-as-tbackend` | Adapter / integration candidate | Parked until TBackend intake exists. |
| `igniter-apps/todolist` | App-consumer / UX pressure | Parked as product pressure only. |
| `igniter-apps/benchmark-app` | Benchmark / performance pressure only | Lab-only; no public performance claim. |

Sequencing resolved by C4-A:

```text
1. stdlib candidate intake / PROP-013 pressure
2. igniter-vm candidate intake, if stdlib intake accepts the evidence chain
3. TBackend candidate intake only after README/docs wording hardening
```

---

## Carry-Forward Constraints

`igc run` status:

```text
Slice 0 accepted as bounded pre-v1 delegated-runtime evidence.
Quickstart docs landed in R235.
Slice 1 remains held until at least stdlib intake closes.
No `igc run` widening is authorized by R236.
```

TBackend status:

```text
candidate intake held
wording hardening required first
```

TBackend wording risks from C2/C3:

```text
"zero-dependency" is factually false
"production-grade" must be scoped as lab-local or removed
"prevents PostgreSQL bloat (SparkCRM)" must be scoped or removed
"incredible throughput" / benchmark wording must remain research-only
```

Rust compiler status:

```text
R235 lab evidence carried
hardening gaps remain sidecar/follow-up before portability comparison
```

Rust compiler hardening gaps carried:

```text
GAP-1 vendor_lead_pipeline emits empty contracts
GAP-2 --compiler-profile-source parsed but not applied
GAP-3 compiled_at hardcoded
GAP-4 source_path embeds absolute local machine path
GAP-5 no Cargo tests
GAP-6 OOF-M1 commented out
GAP-7 no runtime_implementation_id in artifacts
```

---

## Closed Surfaces

R236 does not authorize or imply:

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

---

## Current Status Delta

`igniter-lang/docs/current-status.md` was updated with:

```text
R236 C1-D accepted lab ecosystem pressure map
R236 C2-P1 accepted surface facts packet
R236 C3-X PASS / no blockers
R236 C4-A stdlib intake next-route decision
R236 C5-S status curation
R237 exact Main Line route
```

---

## Exact Handoff

Next Main Line dispatch:

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
```

Sidecar, not opened by this curation:

```text
igniter-tbackend lab README wording hardening
Rust compiler lab hardening before portability comparison
```
