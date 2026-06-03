# Stage 3 Round 243 Status Curation v0

Card: S3-R243-C5-S (implicit status curation; no separate dispatch card)
Skill: IDD Agent Protocol
Agent: [Status Curator]
Role: status-curator
Track: stage3-round243-status-curation-v0
Route: SUMMARY
Status: done
Date: 2026-06-03

Depends on:
- S3-R243-C1-A
- S3-R243-C2-I
- S3-R243-C3-X
- S3-R243-C4-A

---

## Executive Summary

R243 conditionally accepts the bounded experimental `igc run` Slice 1 VM
candidate implementation/proof.

The acceptance condition is satisfied by this status curation packet:
adjacent source/conformance artifacts found in the C2-I commit are explicitly
excluded from R243 acceptance authority.

The accepted next Main Line route is:

```text
S3-R244-C1-A
experimental-igc-run-slice1-quickstart-docs-authorization-review-v0
```

Route type:

```text
bounded internal quickstart/docs authorization review
not public runtime support
not Reference Runtime support
not stable API
not release evidence
```

---

## Inputs Read

- `igniter-lang/docs/cards/S3/S3-R243.md`
- `igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-candidate-implementation-authorization-review-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-candidate-implementation-v0.md`
- `igniter-lang/docs/discussions/experimental-igc-run-slice1-vm-candidate-implementation-pressure-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-candidate-implementation-acceptance-decision-v0.md`
- `igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/out/summary.json`
- `igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/out/slice1_integer_add_blocked.result.json`
- `igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/out/slice0_compat.result.json`
- `igniter-lang/docs/tracks/stage3-round242-status-curation-v0.md`
- `igniter-lang/docs/current-status.md`

---

## Outcome Table

| Card | Status | Curated result |
| --- | --- | --- |
| S3-R243-C1-A | authorized / Path C fail-closed | Authorizes bounded Slice 1 implementation with `integer_add` / `stdlib_integer_add` as explicit fail-closed diagnostics. |
| S3-R243-C2-I | done / PASS | Implements Slice 1 selector and validation/fail-closed boundary; proof summary reports 18/18 IGR-S1 PASS. |
| S3-R243-C3-X | PASS | Pressure verifies Path C blocked diagnostics, Slice 0 compatibility, claim scan, and closed surfaces. |
| S3-R243-C4-A | conditional-accept | Accepts bounded implementation evidence only; requires adjacent artifact exclusion wording. |
| S3-R243-C5-S | done | Records conditional acceptance, adjacent-artifact exclusion, and exact R244 route. |

---

## Curated Status

Accepted / conditional / held status:

```text
Slice 1 VM candidate implementation/proof: conditionally accepted
condition: adjacent source/conformance artifacts explicitly excluded here
selected AN-1 path: Path C fail-closed
IGR-S1: 18/18 PASS
Slice 0 compatibility: PASS, sum=42
claim scan: 0 hits
positive Add.igapp integer_add execution: not accepted
```

Accepted implementation boundary:

```text
Slice 1 selector:
  delegated-experimental:igniter-vm-candidate

runtime_implementation_id:
  igniter.delegated.experimental.vm.rust-tokio.v0

selected AN-1 path:
  Path C fail-closed
```

Accepted behavior:

```text
selector accepted only with --experimental
selector resolves to Slice 1 VM candidate boundary
runtime_implementation_id remains evidence-facing metadata
proof-local binding manifest validates
Add.igapp artifact digest validates
existing Add.igapp passport mismatch is acknowledged, not silently reinterpreted
integer_add / stdlib_integer_add fail closed under Path C
blocked result is explicit and machine-readable
loop/recursion markers fail closed
.igbin fails closed
RuntimeSmoke is not invoked
compiler passport emission is not invoked
Slice 0 delegated-experimental:ivm-proof remains compatible
result packet keeps pre-v1 / no-stable-API / non-public claims
```

Path C blocked packet:

```text
kind: experimental_igc_run_slice1_result
status: blocked
runtime_selector: delegated-experimental:igniter-vm-candidate
runtime_implementation_id: igniter.delegated.experimental.vm.rust-tokio.v0
selected_an1_path: Path C fail-closed
diagnostics:
  unsupported_capability_integer_add
  unsupported_capability_stdlib_integer_add
outputs: {}
stable_api: false
pre_v1: true
experimental: true
not_runtime_smoke: true
not_compiler_passport_emission: true
```

Slice 0 compatibility:

```text
runtime_selector: delegated-experimental:ivm-proof
status: ok
outputs.sum: 42
```

---

## Accepted R243 Files

Accepted as R243 Slice 1 implementation/proof evidence:

```text
igniter-lang/lib/igniter_lang/cli.rb
igniter-lang/lib/igniter_lang/experimental_igc_run.rb
igniter-lang/lib/igniter_lang/experimental_igc_run_vm_candidate.rb
igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/**
igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-candidate-implementation-v0.md
```

Accepted only as read evidence, not modified authority:

```text
igniter-lang/experiments/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0/**
igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/**
igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/
  Add.igapp.passport.json
```

---

## Adjacent Artifact Exclusion

Adjacent source/conformance artifacts in the C2-I commit are excluded from R243
acceptance.

They are:

```text
not accepted as R243 implementation evidence
not accepted as runtime authority
not accepted as conformance authority
not accepted as portability evidence
not accepted as public claim support
not accepted as release evidence
not accepted as alternative certification
```

Excluded adjacent paths named by C4-A:

```text
igniter-lang/source/availability_projection.ig
igniter-lang/source/tenant_availability_projection.ig
igniter-lang/out/conformance/ruby/availability_projection.igapp/**
igniter-lang/out/conformance/ruby/tenant_availability_projection.igapp/**
igniter-lang/out/conformance/rust/availability_projection.igapp/**
igniter-lang/out/conformance/rust/tenant_availability_projection.igapp/**
```

Required wording satisfied:

```text
Adjacent source/conformance artifacts in the C2-I commit are excluded from
R243 acceptance. They create no conformance authority, portability guarantee,
alternative certification, public runtime support, or release evidence.
```

---

## Authority Boundary

R243 does not authorize or imply:

```text
positive Add.igapp integer_add execution
igc run Slice 1 widening beyond Path C
.igbin execution
compiler passport emission
RuntimeSmoke productization
Reference Runtime support
public runtime support
stable API guarantee
production readiness
Spark integration
release execution
public demo claims
public performance claims
alternative certification
portability guarantee
adjacent conformance/source artifact authority
```

---

## Current Status Delta

`igniter-lang/docs/current-status.md` was updated with:

```text
R243 Slice 1 VM candidate implementation conditionally accepted
Path C fail-closed selected and implemented
IGR-S1 18/18 PASS recorded
integer_add / stdlib_integer_add blocked diagnostics recorded
Slice 0 compatibility preserved
adjacent source/conformance artifacts explicitly excluded from R243 authority
S3-R244 quickstart/docs authorization review selected next
closed surfaces preserved
```

---

## Exact Handoff

Next Main Line dispatch:

```text
Card: S3-R244-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-slice1-quickstart-docs-authorization-review-v0

Route: UPDATE
Depends on:
- S3-R243-C4-A
- S3-R243-C5-S

Goal:
Decide whether bounded internal quickstart/docs exposure may begin for the
accepted experimental `igc run` Slice 1 Path C behavior, describing only
experimental delegated-runtime Slice 1 evidence and explicit integer-add
fail-closed behavior.
```
