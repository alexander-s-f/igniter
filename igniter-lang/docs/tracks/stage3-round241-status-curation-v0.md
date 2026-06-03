# Stage 3 Round 241 Status Curation v0

Card: S3-R241-C5-S (implicit status curation; no separate dispatch card)
Skill: IDD Agent Protocol
Agent: [Status Curator]
Role: status-curator
Track: stage3-round241-status-curation-v0
Route: SUMMARY
Status: done
Date: 2026-06-03

Depends on:
- S3-R241-C1-D
- S3-R241-C2-P1
- S3-R241-C3-X
- S3-R241-C4-A

---

## Executive Summary

R241 accepts the experimental `igc run` Slice 1 VM candidate design boundary.

Implementation authorization remains held.

The accepted next Main Line route is:

```text
S3-R242-C1-A
experimental-igc-run-slice1-vm-capability-passport-hardening-authorization-review-v0
```

Route type:

```text
proof-local hardening authorization review
not implementation authorization
not igc run widening
not compiler passport emission
not public runtime support
not Reference Runtime support
```

---

## Inputs Read

- `igniter-lang/docs/cards/S3/S3-R241.md`
- `igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-candidate-design-boundary-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-slice1-current-surface-and-vm-candidate-facts-v0.md`
- `igniter-lang/docs/discussions/experimental-igc-run-slice1-vm-candidate-design-pressure-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-candidate-design-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round240-status-curation-v0.md`
- `igniter-lang/docs/current-status.md`

---

## Outcome Table

| Card | Status | Curated result |
| --- | --- | --- |
| S3-R241-C1-D | done / design-ready-with-prerequisite | Designs Slice 1 as a VM-candidate selector boundary; implementation held pending capability/passport hardening. |
| S3-R241-C2-P1 | done | Facts packet maps Slice 0 command/passport surface, R240 VM evidence, selector gap, passport mismatch, and loop/recursion pressure. |
| S3-R241-C3-X | PASS with notes | Pressure accepts design with AN-1 loop/recursion evidence caution and AN-2 selector/metadata separation. |
| S3-R241-C4-A | accepted / implementation-held / hardening-next | Accepts design boundary and opens S3-R242 hardening authorization review. |
| S3-R241-C5-S | done | Current status updated with compact R241 delta and exact R242 route. |

---

## Curated Status

Accepted / conditional / held status:

```text
Slice 1 design boundary: accepted
implementation authorization: held
next route: VM capability/passport hardening authorization review
igc run implementation: closed
compiler passport emission: closed
.igbin: closed
RuntimeSmoke: closed
```

Accepted design stance:

```text
preserve Slice 0 command spine
design new delegated experimental selector only
user-facing selector: delegated-experimental:igniter-vm-candidate
runtime_implementation_id: igniter.delegated.experimental.vm.rust-tokio.v0
runtime_implementation_id is evidence-facing metadata only
input artifact remains .igapp directory only
explicit --passport / --input / --runtime / --out / --experimental retained
proof-local passport manifests are enough for design vocabulary only
compiler passport emission remains closed
```

Implementation blocker / prerequisite:

```text
Current Add.igapp passport targets:
  igniter.delegated.experimental.ivm.c_resident

Accepted R240 Rust VM candidate uses:
  igniter.delegated.experimental.vm.rust-tokio.v0

This mismatch is a prerequisite blocker before implementation authorization,
not a design blocker.
```

Required next hardening proof should bind:

```text
artifact_ref / artifact_digest for .igapp
runtime_implementation_id matching igniter.delegated.experimental.vm.rust-tokio.v0
capability surface matched only to accepted R240 VMG-1..VMG-15 evidence
selector and runtime_implementation_id separation
unsupported feature fail-closed matrix
non-claims matrix
closed-surface scan
summary JSON
```

---

## Acceptance Notes

AN-1 loop/recursion evidence caution:

```text
Loop/recursion tests in vm_candidate_proof_tests.rs are lab-local pressure
input only. They are not accepted as R240 VMG proof evidence and are not
accepted Slice 1 evidence. The authoritative R240 proof record remains
playgrounds/igniter-lab/igniter-vm/out/vm_candidate_proof/summary.json with
VMG-1..VMG-15.
```

Slice 1 must fail closed if loop/recursion constructs are encountered until a
separate Runtime Specification / PROP-037+ route accepts them.

AN-2 selector separation:

```text
CLI selector:
  delegated-experimental:igniter-vm-candidate

Evidence-facing runtime_implementation_id:
  igniter.delegated.experimental.vm.rust-tokio.v0
```

The `runtime_implementation_id` may appear in machine-readable result packets,
proof-local capability manifests, and proof-local passports. It must not become
the primary user-typed CLI selector.

---

## Authority Boundary

R241 does not authorize or imply:

```text
igc run Slice 1 implementation
runtime/API/CLI/package changes
.igbin execution
compiler passport emission
RuntimeSmoke productization
Reference Runtime support
public runtime support
stable API
production readiness
Spark integration
release execution
public demo claims
public performance claims
official/reference status
alternative certification
portability guarantees
loop/recursion support
reactive/tbackend daemon execution
```

Runtime Specification input status:

```text
conditional redirect only.
If hardening finds selector, failure-code, or capability-spec blockers that
require normative rules, redirect to Runtime Specification input before
implementation authorization.
```

---

## Current Status Delta

`igniter-lang/docs/current-status.md` was updated with:

```text
R241 Slice 1 VM candidate design boundary accepted
implementation authorization held
S3-R242 capability/passport hardening authorization review selected next
selector vs runtime_implementation_id separation recorded
passport mismatch blocker recorded
loop/recursion pressure-only status recorded
closed surfaces preserved
```

---

## Exact Handoff

Next Main Line dispatch:

```text
Card: S3-R242-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-slice1-vm-capability-passport-hardening-authorization-review-v0

Route: UPDATE
Depends on:
- S3-R241-C4-A

Goal:
Decide whether a bounded proof-local VM capability/passport hardening proof may
begin for experimental `igc run` Slice 1, producing evidence-only metadata that
binds an `.igapp` artifact to `igniter.delegated.experimental.vm.rust-tokio.v0`
and its accepted R240 capability envelope, without authorizing implementation,
compiler passport emission, `.igbin` execution, RuntimeSmoke productization,
public runtime support, Reference Runtime support, stable API, production,
Spark, release, public performance claims, official/reference status,
alternative certification, or portability guarantees.
```
