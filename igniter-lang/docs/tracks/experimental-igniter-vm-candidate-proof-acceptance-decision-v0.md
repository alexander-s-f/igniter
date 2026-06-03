# Experimental Igniter VM Candidate Proof Acceptance Decision v0

Card: S3-R240-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igniter-vm-candidate-proof-acceptance-decision-v0
Route: UPDATE
Status: accepted
Date: 2026-06-03

Depends on:
- S3-R240-C2-I
- S3-R240-C3-X

---

## Decision

Accept the proof-local `igniter-vm` candidate proof.

The accepted evidence is bounded to:

```text
proof-local VM candidate evidence only
delegated experimental candidate evidence only
not public runtime support
not Reference Runtime support
not runtime/API/CLI/package authority
not stable API
not production readiness
not portability or certification authority
```

The C3-X verdict is accepted as unconditional:

```text
PASS - unconditional
VMG-1..VMG-15 accepted
R239 AN-1 observation wording resolved
R239 AN-2 non-selected branch silence resolved
no blockers
```

---

## Inputs Read

```text
igniter-lang/docs/tracks/
  experimental-igniter-vm-candidate-proof-authorization-review-v0.md
igniter-lang/docs/tracks/
  experimental-igniter-vm-candidate-proof-v0.md
igniter-lang/docs/discussions/
  experimental-igniter-vm-candidate-proof-pressure-v0.md
playgrounds/igniter-lab/igniter-vm/out/
  vm_candidate_proof/summary.json
playgrounds/igniter-lab/igniter-vm/proofs/
  vm_candidate_proof.rb
playgrounds/igniter-lab/igniter-vm/tests/
  vm_candidate_proof_tests.rs
igniter-lang/docs/tracks/
  experimental-igniter-vm-candidate-intake-decision-v0.md
```

---

## Exact Changed Files

Accepted C2-I proof files:

```text
playgrounds/igniter-lab/igniter-vm/proofs/vm_candidate_proof.rb
playgrounds/igniter-lab/igniter-vm/tests/vm_candidate_proof_tests.rs
playgrounds/igniter-lab/igniter-vm/out/vm_candidate_proof/summary.json
igniter-lang/docs/tracks/experimental-igniter-vm-candidate-proof-v0.md
```

Accepted pressure artifacts read as review evidence:

```text
igniter-lang/docs/discussions/experimental-igniter-vm-candidate-proof-pressure-v0.md
igniter-lang/docs/discussions/README.md
```

This C4-A decision adds:

```text
igniter-lang/docs/tracks/
  experimental-igniter-vm-candidate-proof-acceptance-decision-v0.md
```

---

## Acceptance Record

| Checkpoint | Decision |
| --- | --- |
| Command matrix | Accepted. Five commands are recorded in the proof track as PASS; summary JSON records the four Cargo evidence commands, with the Ruby proof runner acting as the result-packet generator. C3-X treats the JSON omission as informational only. |
| VMG-1..VMG-15 | Accepted. Summary reports 15 total / 15 pass / 0 fail. VMG-13 is correctly classified/skipped, not failed. |
| Result packet | Accepted. `summary.json` is present and machine-readable. |
| `runtime_implementation_id` | Accepted as proof-local metadata: `igniter.delegated.experimental.vm.rust-tokio.v0`. |
| Evidence class | Accepted as `proof_local_vm_candidate_evidence`. |
| Authority status | Accepted as `non_canonical`, `candidate_only`, `proof_local`, `no_public_runtime_authority`, `no_reference_runtime_authority`, `no_runtime_api_cli_package_authority`. |
| Non-claims | Accepted. C3-X verifies all 13 required non-claims with no missing or extra entries. |
| Decimal delegation parity | Accepted as candidate evidence against the R238 stdlib dependency context, including OOF-TC5 / OOF-DM2 behavior. |
| AOT compiler / stack-register | Accepted as candidate capability evidence. |
| Selected branch | Accepted. |
| Non-selected branch silence | Accepted. The non-selected branch emits zero observations. |
| Unsupported / malformed behavior | Accepted. Unsupported selected paths and unknown opcodes fail closed. |
| Observation trace wording | Accepted. Wording is restricted to "hash-based trace identifier". |
| Reactive/tbackend classification | Accepted as classified/skipped only; no daemon/server evidence is promoted. |
| Closed-surface scan | Accepted. Mainline compiler/runtime/CLI/package/docs surfaces remain unchanged. |

---

## Explicit Answers

Whether proof-local VM candidate proof is accepted:

```text
Yes.
```

Whether generated output may be called proof-local VM candidate evidence only:

```text
Yes. It may not be promoted beyond proof-local VM candidate evidence.
```

Whether this creates public runtime support:

```text
No.
```

Whether this creates Reference Runtime support:

```text
No.
```

Whether this creates runtime/API/CLI/package authority:

```text
No.
```

Whether implementation may open next:

```text
No live implementation is authorized by this card. A future implementation
authorization review may be opened only after a separate design/authorization
route.
```

Whether `igc run` Slice 1 may open next as design-only or remains held:

```text
`igc run` Slice 1 may open next as design-only only. Implementation remains
closed.
```

Whether Runtime Specification input slice should open next:

```text
Not as the immediate Main Line route. Runtime Specification inputs should be
read and pressure-tested inside the Slice 1 design-only route. If Slice 1 finds
contract or vocabulary blockers, redirect to a Runtime Specification input
slice before implementation authorization.
```

Whether public/stable/production/Reference Runtime/Spark/release/performance/portability claims remain closed:

```text
Yes. All remain closed.
```

---

## Closed Surfaces

Still closed:

```text
igniter-lang/lib/**
igniter-lang/bin/igc implementation widening
igniter-lang/igniter_lang.gemspec
igniter-lang/README.md public runtime claims
igniter-lang/docs/README.md public runtime claims
igniter-lang/docs/ruby-api.md public runtime claims
RuntimeSmoke productization
CompilerResult / CompilationReport authority changes
.igbin execution
compiler passport emission
runtime/API/CLI/package authority
Reference Runtime support
public runtime support
stable API
production readiness
Spark integration
release evidence
public performance claims
official/reference status
alternative certification
portability guarantees
```

---

## Compact Decision Summary

```text
VM candidate proof: accepted
evidence class: proof_local_vm_candidate_evidence
authority: candidate-only, non-canonical, proof-local
VMG result: 15/15 accepted; VMG-13 classified/skipped
branch silence: accepted
trace wording: hash-based trace identifier only
reactive/tbackend: classified/skipped, not accepted as runtime evidence
runtime/API/CLI/package authority: closed
igc run Slice 1: design-only may open next; implementation closed
next route: S3-R241-C1-D experimental igc run Slice 1 design-only boundary
```

---

## Next Dispatch Recommendation

Open the next Main Line route:

```text
Card: S3-R241-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-slice1-vm-candidate-design-boundary-v0
Route: UPDATE
Depends on:
- S3-R240-C4-A
```

Recommended goal:

```text
Design a pre-v1 experimental `igc run` Slice 1 boundary that may name the
accepted proof-local `igniter-vm` candidate as delegated experimental evidence,
without authorizing implementation, `.igbin` execution, compiler passport
emission, RuntimeSmoke productization, Reference Runtime support, public runtime
support, stable API, production readiness, Spark integration, release evidence,
public performance claims, alternative certification, or portability
guarantees.
```

Required route type:

```text
design-only
no code edits
no implementation authority
no public claims
```

Required design questions:

```text
whether Slice 1 may select proof-local VM candidate evidence
whether Slice 1 remains `.igapp` only or can design future `.igbin` prerequisites
whether artifact passport metadata is enough for Slice 1 design
whether runtime_implementation_id may be user-facing in an experimental command
whether Runtime Specification input blockers exist
whether lab VM capability manifest needs hardening before authorization review
whether TBackend wording remains a sidecar concern
```

Implementation authorization remains explicitly closed until a later,
narrowly scoped authorization-review card.
