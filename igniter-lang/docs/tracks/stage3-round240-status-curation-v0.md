# Stage 3 Round 240 Status Curation v0

Card: S3-R240-C5-S (implicit status curation; no separate dispatch card)
Skill: IDD Agent Protocol
Agent: [Status Curator]
Role: status-curator
Track: stage3-round240-status-curation-v0
Route: SUMMARY
Status: done
Date: 2026-06-03

Depends on:
- S3-R240-C1-A
- S3-R240-C2-I
- S3-R240-C3-X
- S3-R240-C4-A

---

## Executive Summary

R240 accepts the proof-local `igniter-vm` candidate proof.

The accepted next Main Line route is:

```text
S3-R241-C1-D
experimental-igc-run-slice1-vm-candidate-design-boundary-v0
```

Route type:

```text
design-only boundary
not implementation authorization
not igc run widening
not public runtime support
not Reference Runtime support
```

R240 closes the R239 VM proof gaps for proof-local evidence only. It does not
create runtime/API/CLI/package authority.

---

## Inputs Read

- `igniter-lang/docs/cards/S3/S3-R240.md`
- `igniter-lang/docs/tracks/experimental-igniter-vm-candidate-proof-authorization-review-v0.md`
- `igniter-lang/docs/tracks/experimental-igniter-vm-candidate-proof-v0.md`
- `igniter-lang/docs/discussions/experimental-igniter-vm-candidate-proof-pressure-v0.md`
- `igniter-lang/docs/tracks/experimental-igniter-vm-candidate-proof-acceptance-decision-v0.md`
- `playgrounds/igniter-lab/igniter-vm/out/vm_candidate_proof/summary.json`
- `igniter-lang/docs/tracks/stage3-round239-status-curation-v0.md`
- `igniter-lang/docs/current-status.md`

---

## Outcome Table

| Card | Status | Curated result |
| --- | --- | --- |
| S3-R240-C1-A | authorized | Bounded lab-local proof authorized inside `igniter-vm` proof artifacts/tests only. |
| S3-R240-C2-I | done / PASS | VMG-1..VMG-15 complete; summary packet present; proof script and Rust proof tests landed. |
| S3-R240-C3-X | PASS / unconditional | Pressure accepts proof unconditionally; R239 AN-1/AN-2 resolved; no blockers. |
| S3-R240-C4-A | accepted | Accepts proof-local VM candidate evidence and opens S3-R241 design-only Slice 1 boundary route. |
| S3-R240-C5-S | done | Current status updated with compact R240 delta and exact R241 route. |

---

## Curated Status

Accepted / conditional / held status:

```text
proof-local VM candidate proof: accepted
C3-X verdict: PASS - unconditional
VMG-1..VMG-15: accepted
VMG-13: classified/skipped, accepted as non-run classification
checks_total/checks_pass/checks_fail: 15/15/0
result packet: present
igc run Slice 1: design-only may open next; implementation remains closed
```

Result packet:

```text
playgrounds/igniter-lab/igniter-vm/out/
  vm_candidate_proof/summary.json

overall: PASS
evidence_class: proof_local_vm_candidate_evidence
runtime_implementation_id: igniter.delegated.experimental.vm.rust-tokio.v0
authority_status:
  non_canonical
  candidate_only
  proof_local
  no_public_runtime_authority
  no_reference_runtime_authority
  no_runtime_api_cli_package_authority
non_claims: 13/13 required entries present
```

Accepted proof evidence:

```text
runtime_implementation_id proof-local metadata
evidence_class / authority_status / non_claims
scoped command matrix with no daemon/server side effects
Decimal add/sub/mul/div parity against R238 stdlib dependency context
AOT compiler lowering
stack/register execution
selected branch execution
non-selected branch silence with zero observations
unsupported selected-path fail-closed behavior
unknown opcode / malformed input fail-closed behavior
OP_LOAD_AS_OF hash-based trace identifier wording
map-reduce aggregate evidence
reactive/tbackend classified/skipped stance
closed-surface scan
no public/stable/reference/performance/portability claims
```

Accepted C2-I proof files:

```text
playgrounds/igniter-lab/igniter-vm/proofs/vm_candidate_proof.rb
playgrounds/igniter-lab/igniter-vm/tests/vm_candidate_proof_tests.rs
playgrounds/igniter-lab/igniter-vm/out/vm_candidate_proof/summary.json
igniter-lang/docs/tracks/experimental-igniter-vm-candidate-proof-v0.md
```

Command matrix:

```text
cargo test --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml --test vm_tests
cargo test --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml --test vm_candidate_proof_tests
cargo test --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml --lib
cargo metadata --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml --no-deps
ruby playgrounds/igniter-lab/igniter-vm/proofs/vm_candidate_proof.rb
```

Note:

```text
The summary JSON records the four Cargo evidence commands. The Ruby proof
runner is recorded in the proof track as the result-packet generator. C3-X
classified that JSON omission as informational only.
```

---

## Authority Boundary

R240 does not authorize or imply:

```text
live implementation
runtime/API/CLI/package changes
igc run implementation widening
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
reactive/tbackend daemon proof
```

`igc run` Slice 1 status:

```text
design-only boundary may open next
implementation remains closed
```

Runtime Specification input status:

```text
not immediate Main Line route.
Read and pressure-test Runtime Specification inputs inside the Slice 1
design-only route; redirect to a Runtime Specification input slice only if
Slice 1 finds contract or vocabulary blockers.
```

---

## Current Status Delta

`igniter-lang/docs/current-status.md` was updated with:

```text
R240 proof-local VM candidate proof accepted
VMG-1..VMG-15 accepted; VMG-13 classified/skipped
15/15/0 proof summary recorded
R239 AN-1/AN-2 resolved
runtime_implementation_id / evidence_class / non_claims accepted as proof-local
metadata only
R241 design-only Slice 1 boundary next route
implementation and public/runtime authority surfaces preserved closed
```

---

## Exact Handoff

Next Main Line dispatch:

```text
Card: S3-R241-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-slice1-vm-candidate-design-boundary-v0

Route: UPDATE
Depends on:
- S3-R240-C4-A

Goal:
Design a pre-v1 experimental `igc run` Slice 1 boundary that may name the
accepted proof-local `igniter-vm` candidate as delegated experimental evidence,
without authorizing implementation, `.igbin` execution, compiler passport
emission, RuntimeSmoke productization, Reference Runtime support, public runtime
support, stable API, production readiness, Spark integration, release evidence,
public performance claims, alternative certification, or portability
guarantees.
```
