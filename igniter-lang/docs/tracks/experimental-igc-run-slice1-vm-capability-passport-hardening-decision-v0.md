# Experimental igc run Slice 1 VM Capability Passport Hardening Decision v0

Card: S3-R242-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-slice1-vm-capability-passport-hardening-decision-v0
Route: UPDATE
Status: accepted / implementation-authorization-review-next
Date: 2026-06-03

Depends on:
- S3-R242-C2-I
- S3-R242-C3-X

---

## Decision

Accept the proof-local VM capability/passport hardening evidence.

Accepted next Main Line route:

```text
S3-R243-C1-A
experimental-igc-run-slice1-vm-candidate-implementation-authorization-review-v0
```

Route type:

```text
bounded implementation authorization review
not direct implementation
not igc run implementation authorization yet
not compiler passport emission
not .igbin execution
not public runtime support
not Reference Runtime support
```

Reason:

```text
C2-I closes the R241 passport binding prerequisite with proof-local metadata.
C3-X independently verifies S1H-1..S1H-14, artifact digest, claim scan, and
closed-surface compliance.

The hardening evidence is sufficient to open a bounded Slice 1 implementation
authorization review next, but that review must explicitly resolve the
integer_add / stdlib_integer_add gap before any implementation card can begin.
```

This decision accepts evidence only. It does not authorize live implementation.

---

## Inputs Read

```text
igniter-lang/docs/tracks/
  experimental-igc-run-slice1-vm-capability-passport-hardening-
  authorization-review-v0.md
igniter-lang/docs/tracks/
  experimental-igc-run-slice1-vm-capability-passport-hardening-v0.md
igniter-lang/docs/discussions/
  experimental-igc-run-slice1-vm-capability-passport-hardening-pressure-v0.md
igniter-lang/experiments/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/
  vm_capability_passport_binding_manifest.json
igniter-lang/experiments/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/
  summary.json
igniter-lang/docs/tracks/stage3-round241-status-curation-v0.md
igniter-lang/docs/tracks/
  experimental-igc-run-slice1-vm-candidate-design-decision-v0.md
```

---

## Acceptance Record

| Surface | Status |
| --- | --- |
| C2-I proof output | Accepted. |
| C3-X pressure verdict | Accepted: PASS with one non-blocking acceptance note. |
| Binding manifest | Accepted as proof-local evidence-only metadata. |
| Artifact digest | Accepted: `sha256:c402b014620fb7c16903861253e362c7b585223b4c26f75a51d3527029d2c5ee`. |
| Runtime selector | Accepted as proof-local selector: `delegated-experimental:igniter-vm-candidate`. |
| `runtime_implementation_id` | Accepted as evidence-facing metadata only: `igniter.delegated.experimental.vm.rust-tokio.v0`. |
| Selector separation | Accepted; `runtime_implementation_id` is not a user-typed selector. |
| Capability envelope | Accepted, bounded to R240 VMG-1..VMG-15 evidence only. |
| `integer_add` / `stdlib_integer_add` | Accepted as recorded gap only, not accepted runtime capability. |
| Loop/recursion | Pressure-only and fail-closed. |
| `.igbin` | Excluded and fail-closed. |
| Compiler passport emission | Closed. |
| RuntimeSmoke | Closed. |
| Public/stable/production/Reference Runtime/Spark/release/performance/portability claims | Closed. |

---

## Exact Changed Files Accepted

C2-I changed only the authorized proof-local experiment directory plus the
proof track doc:

```text
igniter-lang/experiments/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0.rb
igniter-lang/experiments/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/
  vm_capability_passport_binding_manifest.json
igniter-lang/experiments/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/
  capability_support_gap_matrix.json
igniter-lang/experiments/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/
  unsupported_feature_fail_closed_matrix.json
igniter-lang/experiments/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/
  selector_runtime_implementation_id_separation_proof.json
igniter-lang/experiments/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/
  non_claims_matrix.json
igniter-lang/experiments/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/
  closed_surface_scan.json
igniter-lang/experiments/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/
  summary.json
igniter-lang/docs/tracks/
  experimental-igc-run-slice1-vm-capability-passport-hardening-v0.md
```

No closed surface is accepted as changed.

---

## Command Matrix

| Command | Result | Evidence |
| --- | --- | --- |
| `ruby -c igniter-lang/experiments/experimental_igc_run_slice1_vm_capability_passport_hardening_v0/experimental_igc_run_slice1_vm_capability_passport_hardening_v0.rb` | PASS | `Syntax OK` in C2-I. |
| `ruby igniter-lang/experiments/experimental_igc_run_slice1_vm_capability_passport_hardening_v0/experimental_igc_run_slice1_vm_capability_passport_hardening_v0.rb` | PASS | `PASS experimental_igc_run_slice1_vm_capability_passport_hardening_v0` in C2-I. |
| C3-X independent JSON/digest verification | PASS | 14/14 S1H PASS; digest recomputed; claim scan 0 hits; `written_outside_allowed_scope=[]`. |

No `igc run` Slice 1 command, `.igbin` execution, RuntimeSmoke path, release
command, or public claim command is accepted as executed.

---

## S1H Result

```text
S1H-1  PASS  proof-local binding manifest exists
S1H-2  PASS  Add.igapp artifact digest recomputes correctly
S1H-3  PASS  runtime_implementation_id matches R240 VM id
S1H-4  PASS  selector remains delegated-experimental:igniter-vm-candidate
S1H-5  PASS  runtime_implementation_id is not a user-typed selector
S1H-6  PASS  capabilities map only to accepted VMG-1..VMG-15 evidence
S1H-7  PASS  loop/recursion are pressure-only and fail-closed
S1H-8  PASS  .igbin remains excluded
S1H-9  PASS  compiler passport emission remains absent
S1H-10 PASS  RuntimeSmoke remains absent
S1H-11 PASS  unsupported feature matrix is fail-closed
S1H-12 PASS  result packet is evidence-only / pre-v1 / non-stable
S1H-13 PASS  public/runtime/reference/stable/performance/portability scan passes
S1H-14 PASS  closed-surface scan passes
```

---

## AN-1 Resolution for Next Route

C3-X records one non-blocking acceptance note:

```text
integer_add / stdlib_integer_add is a gap:
  gap_fail_closed_until_runtime_spec_or_vm_integer_parity_evidence
```

C4-A accepts the hardening proof because the gap is honestly represented and
fail-closed. It does not accept `integer_add` as a VM runtime capability.

The next authorization review must choose one of these paths before any C2-I
implementation can begin:

```text
Preferred Path C:
  Slice 1 implementation authorization may proceed only if integer_add /
  stdlib_integer_add is treated as an explicit fail-closed diagnostic.
  Positive execution evidence must use only capabilities that are bound to
  accepted VMG evidence.

Path A:
  Redirect to a VM integer parity evidence proof before implementation.

Path B:
  Use a Decimal-only proof artifact so the integer_add gap does not appear in
  the Slice 1 positive runtime path.
```

This decision recommends Path C for the next authorization review because it
keeps momentum while preserving proof honesty.

---

## Explicit Answers

Whether proof-local hardening evidence is accepted:

```text
Yes.
```

Whether generated output may be called proof-local VM capability/passport
hardening evidence only:

```text
Yes.
```

Whether this creates implementation authorization:

```text
No.
```

Whether bounded Slice 1 implementation authorization review may open next:

```text
Yes, as S3-R243-C1-A. It must explicitly resolve AN-1 before authorizing
implementation.
```

Whether `igc run` implementation remains closed now:

```text
Yes.
```

Whether compiler passport emission remains closed:

```text
Yes.
```

Whether `.igbin` remains closed:

```text
Yes.
```

Whether RuntimeSmoke remains closed:

```text
Yes.
```

Whether loops/recursion remain pressure-only and fail-closed:

```text
Yes.
```

Whether public/stable/production/Reference Runtime/Spark/release/performance/
portability claims remain closed:

```text
Yes.
```

---

## Exact Next Dispatch Recommendation

```text
Card: S3-R243-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-slice1-vm-candidate-implementation-authorization-review-v0

Route: UPDATE
Depends on:
- S3-R242-C4-A

Goal:
Decide whether a bounded experimental `igc run` Slice 1 VM candidate
implementation may begin, using the accepted proof-local capability/passport
hardening evidence, while preserving explicit fail-closed handling for
integer_add / stdlib_integer_add unless a separate parity proof or Decimal-only
artifact path is selected.

Required authorization-review decision:
- choose AN-1 Path C, Path A, or Path B before any implementation boundary;
- if Path C is selected, require explicit fail-closed diagnostic for
  integer_add / stdlib_integer_add;
- keep positive runtime evidence limited to capabilities bound to accepted
  VMG evidence.

Keep closed:
- direct implementation until this authorization review accepts a C2-I boundary;
- compiler passport emission;
- `.igbin` execution;
- RuntimeSmoke productization;
- public runtime support;
- Reference Runtime support;
- stable API, production, Spark, release, public performance, certification,
  and portability claims.
```
