# Experimental igc run Slice 1 VM Candidate Design Decision v0

Card: S3-R241-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-slice1-vm-candidate-design-decision-v0
Route: UPDATE
Status: accepted / implementation-held / hardening-next
Date: 2026-06-03

Depends on:
- S3-R241-C1-D
- S3-R241-C2-P1
- S3-R241-C3-X

---

## Decision

Accept the experimental `igc run` Slice 1 VM candidate design boundary.

Implementation authorization remains held.

Accepted next Main Line route:

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

Reason:

```text
C1-D correctly designs Slice 1 as a VM-candidate selector boundary.
C2-P1 confirms the current Slice 0 and VM candidate surfaces.
C3-X returns PASS with two non-blocking acceptance notes.

The design is accepted, but implementation must wait because the current
Add.igapp passport targets `igniter.delegated.experimental.ivm.c_resident`,
while the accepted R240 Rust VM candidate uses
`igniter.delegated.experimental.vm.rust-tokio.v0`.
```

The gap is a prerequisite for implementation authorization, not a design
blocker.

---

## Inputs Read

```text
igniter-lang/docs/tracks/
  experimental-igc-run-slice1-vm-candidate-design-boundary-v0.md
igniter-lang/docs/tracks/
  experimental-igc-run-slice1-current-surface-and-vm-candidate-facts-v0.md
igniter-lang/docs/discussions/
  experimental-igc-run-slice1-vm-candidate-design-pressure-v0.md
igniter-lang/docs/tracks/stage3-round240-status-curation-v0.md
igniter-lang/docs/tracks/
  experimental-igniter-vm-candidate-proof-acceptance-decision-v0.md
```

---

## Acceptance Record

| Surface | Decision |
| --- | --- |
| Slice 1 design boundary | Accepted. |
| C2-P1 facts packet | Accepted as facts basis only, not authority. |
| C3-X pressure verdict | Accepted: PASS with two non-blocking acceptance notes. |
| VM candidate naming | Accepted as experimental delegated selector only. |
| User-facing selector | `delegated-experimental:igniter-vm-candidate`. |
| `runtime_implementation_id` | Evidence-facing metadata only: `igniter.delegated.experimental.vm.rust-tokio.v0`. Not the user-typed CLI selector. |
| Passport prerequisite | Accepted as blocker before implementation authorization. A proof-local binding is required. |
| Passport/capability validation | Must be fail-closed and proof-local before any implementation review. |
| Compiler passport emission | Closed. |
| `.igbin` | Closed and excluded from Slice 1. |
| RuntimeSmoke | Closed; no fallback, no productization. |
| Runtime Specification input | Not an immediate blocker. Conditional redirect if hardening exposes selector, failure-code, or capability-spec blockers. |
| Recursion/loop pressure | Pressure input only; not accepted Slice 1 evidence; not implementation scope. |
| Implementation | Held. No live implementation authorized. |
| Public/stable/production/Reference Runtime/Spark/release/performance/portability claims | Closed. |

---

## Acceptance Notes

AN-1:

```text
Loop/recursion tests in `vm_candidate_proof_tests.rs` are lab pressure input
only. They are not accepted as R240 VMG proof evidence and are not accepted
Slice 1 evidence. The authoritative R240 proof record remains
`playgrounds/igniter-lab/igniter-vm/out/vm_candidate_proof/summary.json`
with VMG-1..VMG-15.
```

Slice 1 must fail closed if loop or recursion constructs are encountered until
a separate Runtime Specification / PROP-037+ route accepts them.

AN-2:

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

## Required Hardening Proof Boundary

The next route should decide whether a bounded proof-local hardening proof may
begin.

Allowed future hardening scope should be limited to:

```text
igniter-lang/experiments/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0/**
igniter-lang/docs/tracks/
  experimental-igc-run-slice1-vm-capability-passport-hardening-v0.md
```

Read-only source/evidence inputs:

```text
igniter-lang/docs/tracks/
  experimental-igc-run-slice1-vm-candidate-design-decision-v0.md
igniter-lang/docs/tracks/
  experimental-igc-run-slice1-vm-candidate-design-boundary-v0.md
igniter-lang/docs/tracks/
  experimental-igc-run-slice1-current-surface-and-vm-candidate-facts-v0.md
igniter-lang/docs/discussions/
  experimental-igc-run-slice1-vm-candidate-design-pressure-v0.md
igniter-lang/docs/tracks/
  experimental-igniter-vm-candidate-proof-acceptance-decision-v0.md
playgrounds/igniter-lab/igniter-vm/out/
  vm_candidate_proof/summary.json
igniter-lang/examples/experimental_executable_quickstart_v0/out/
  Add.igapp/**
igniter-lang/experiments/
  experimental_runtime_artifact_passport_manifest_v0/out/Add.igapp.passport.json
igniter-lang/lib/igniter_lang/experimental_igc_run.rb
```

The hardening proof should produce proof-local metadata only:

```text
VM-specific capability/passport binding manifest
capability support/gap matrix
unsupported feature fail-closed matrix
selector and runtime_implementation_id separation proof
non-claims matrix
closed-surface scan
summary JSON
```

It must not edit:

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
playgrounds/igniter-lab/**
```

---

## Proof / Regression Matrix Expectations

The next hardening proof should include at minimum:

```text
S1H-1  proof-local binding manifest exists
S1H-2  artifact_ref / artifact_digest for Add.igapp recompute correctly
S1H-3  runtime_implementation_id matches igniter.delegated.experimental.vm.rust-tokio.v0
S1H-4  CLI selector remains delegated-experimental:igniter-vm-candidate
S1H-5  runtime_implementation_id is not used as a user-typed selector
S1H-6  required capabilities map to accepted VMG-1..VMG-15 evidence only
S1H-7  loop/recursion are classified pressure-only and fail-closed
S1H-8  .igbin remains excluded
S1H-9  compiler passport emission remains absent
S1H-10 RuntimeSmoke remains absent
S1H-11 unsupported feature matrix is fail-closed
S1H-12 result packet shape is evidence-only / pre-v1 / non-stable
S1H-13 public/runtime/reference/stable/performance/portability claims scan passes
S1H-14 closed-surface scan passes
```

If any capability cannot be bound without normative Runtime Specification
wording, the hardening proof must fail closed and recommend a Runtime
Specification input slice before implementation authorization.

---

## Explicit Answers

Whether experimental `igc run` Slice 1 design boundary is accepted:

```text
Yes.
```

Whether implementation authorization may open next:

```text
No. Implementation authorization remains held. Open proof-local
capability/passport hardening authorization review next.
```

Whether `igc run` implementation remains closed now:

```text
Yes.
```

Whether `igniter-vm` may be named by an experimental delegated selector:

```text
Yes, as `delegated-experimental:igniter-vm-candidate` only.
```

Whether generated outputs may still only be delegated experimental evidence:

```text
Yes. Generated outputs remain delegated experimental evidence only and must
carry pre-v1 / non-stable / non-public-runtime non-claims.
```

Whether `.igbin`, compiler passport emission, RuntimeSmoke productization,
Reference Runtime, public runtime, stable API, production, Spark, release,
public demo, public docs claims, public performance claims, official reference
status, alternative certification, and portability guarantees remain closed:

```text
Yes. All remain closed.
```

---

## Compact Decision Summary

```text
Slice 1 design boundary: accepted
implementation authorization: held
next route: VM capability/passport hardening authorization review
selector: delegated-experimental:igniter-vm-candidate
runtime_implementation_id: evidence metadata only
passport mismatch: accepted prerequisite blocker before implementation
compiler passport emission: closed
.igbin: closed
RuntimeSmoke: closed
loops/recursion: pressure input only, fail-closed if encountered
public/runtime/reference/stable/performance/portability claims: closed
```

---

## Exact Next Dispatch Recommendation

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
