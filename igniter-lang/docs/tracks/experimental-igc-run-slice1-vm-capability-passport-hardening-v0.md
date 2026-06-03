# Experimental igc run Slice 1 VM Capability Passport Hardening v0

Card: S3-R242-C2-I
Skill: IDD Agent Protocol
Agent: [Implementation Agent]
Role: implementation-agent
Track: experimental-igc-run-slice1-vm-capability-passport-hardening-v0
Route: IMPLEMENT
Status: done
Date: 2026-06-03

Depends on:
- S3-R242-C1-A

---

## Goal

Implement a bounded proof-local VM capability/passport hardening proof for
experimental `igc run` Slice 1.

The proof produces evidence-only binding metadata that maps the existing
`.igapp` artifact:

```text
igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp
```

to:

```text
igniter.delegated.experimental.vm.rust-tokio.v0
```

and to the accepted R240 VMG capability envelope, without editing CLI, runtime,
package, public docs, existing `.igapp`, existing passport, or playground
surfaces.

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-capability-passport-hardening-authorization-review-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-candidate-design-decision-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-candidate-design-boundary-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-slice1-current-surface-and-vm-candidate-facts-v0.md`
- `igniter-lang/docs/discussions/experimental-igc-run-slice1-vm-candidate-design-pressure-v0.md`
- `playgrounds/igniter-lab/igniter-vm/out/vm_candidate_proof/summary.json`
- `igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/**`
- `igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/Add.igapp.passport.json`
- `igniter-lang/source/loops_and_recursion.ig`
- `igniter-lang/lib/igniter_lang/experimental_igc_run.rb` as read-only selector surface evidence

---

## Changed Files

Proof-local experiment:

- `igniter-lang/experiments/experimental_igc_run_slice1_vm_capability_passport_hardening_v0/experimental_igc_run_slice1_vm_capability_passport_hardening_v0.rb`
- `igniter-lang/experiments/experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/vm_capability_passport_binding_manifest.json`
- `igniter-lang/experiments/experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/capability_support_gap_matrix.json`
- `igniter-lang/experiments/experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/unsupported_feature_fail_closed_matrix.json`
- `igniter-lang/experiments/experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/selector_runtime_implementation_id_separation_proof.json`
- `igniter-lang/experiments/experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/non_claims_matrix.json`
- `igniter-lang/experiments/experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/closed_surface_scan.json`
- `igniter-lang/experiments/experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/summary.json`

Track:

- `igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-capability-passport-hardening-v0.md`

No files under `igniter-lang/lib/**`, `igniter-lang/bin/igc`,
`playgrounds/igniter-lab/**`, existing Add.igapp, or existing Add.igapp
passport were edited.

---

## Proof Outputs

Primary summary:

```text
igniter-lang/experiments/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/
  summary.json
```

Observed summary:

```text
kind=experimental_igc_run_slice1_vm_capability_passport_hardening_summary
status=PASS
checks=14
failed=0
artifact_digest=sha256:c402b014620fb7c16903861253e362c7b585223b4c26f75a51d3527029d2c5ee
runtime_selector=delegated-experimental:igniter-vm-candidate
runtime_implementation_id=igniter.delegated.experimental.vm.rust-tokio.v0
existing_passport_runtime_implementation_id=igniter.delegated.experimental.ivm.c_resident
```

The artifact digest recomputes with the accepted Slice 0 / R232 policy:

```text
sort files under Add.igapp recursively
SHA256 each file
join file digests with ":"
SHA256 the joined string
prefix "sha256:"
```

---

## S1H Result Table

| ID | Result | Evidence |
| --- | --- | --- |
| S1H-1 | PASS | Proof-local binding manifest exists. |
| S1H-2 | PASS | `artifact_ref` / `artifact_digest` for Add.igapp recompute correctly and match existing passport. |
| S1H-3 | PASS | `runtime_implementation_id` matches `igniter.delegated.experimental.vm.rust-tokio.v0`. |
| S1H-4 | PASS | Proof-local CLI selector is `delegated-experimental:igniter-vm-candidate`. |
| S1H-5 | PASS | `runtime_implementation_id` is not listed as a user-typed selector. |
| S1H-6 | PASS | Required capabilities map only to accepted VMG-1..VMG-15 evidence. |
| S1H-7 | PASS | Loop/recursion source is classified pressure-only and fail-closed. |
| S1H-8 | PASS | `.igbin` remains excluded and fail-closed. |
| S1H-9 | PASS | Compiler passport emission remains absent. |
| S1H-10 | PASS | RuntimeSmoke remains absent. |
| S1H-11 | PASS | Unsupported feature matrix is fail-closed. |
| S1H-12 | PASS | Result packet shape is evidence-only / pre-v1 / non-stable. |
| S1H-13 | PASS | Public/runtime/reference/stable/performance/portability positive-claim scan has 0 hits. |
| S1H-14 | PASS | Closed-surface scan passes; proof writes stay under the allowed experiment directory. |

---

## Capability / Gap Notes

The binding manifest maps required proof capabilities to R240 VMG evidence only:

- VMG-1 runtime identity;
- VMG-2 evidence authority and non-claims;
- VMG-3 scoped proof command matrix;
- VMG-4 decimal arithmetic parity evidence;
- VMG-5 AOT SemanticIR lowering candidate evidence;
- VMG-6 stack/register execution;
- VMG-7 selected branch candidate evidence;
- VMG-8 non-selected branch silence;
- VMG-9 unsupported path fail-closed;
- VMG-10 malformed input / unknown opcode fail-closed;
- VMG-11 temporal trace identifier candidate evidence;
- VMG-12 map-reduce aggregate candidate evidence;
- VMG-13 reactive/tbackend classified/skipped;
- VMG-14 closed-surface preservation;
- VMG-15 public/stable/reference/performance/portability claims closed.

`integer_add` and `stdlib_integer_add` from the existing Add.igapp feature set
are recorded as feature gaps, not public runtime support:

```text
gap_fail_closed_until_runtime_spec_or_vm_integer_parity_evidence
```

This keeps the proof honest: it binds the artifact to the accepted VM candidate
envelope as evidence only and does not authorize execution.

---

## Unsupported / Fail-Closed Matrix

The unsupported feature matrix records fail-closed policy for:

- `.igbin`;
- loops;
- recursion;
- service-loop clock ticks;
- reactive daemon execution;
- TBackend daemon execution;
- projection pipeline execution;
- compiler passport emission;
- RuntimeSmoke.

`igniter-lang/source/loops_and_recursion.ig` is read as pressure input only.
Detected markers include loop syntax, recursion, `decreases fuel`,
`clock.every`, and `tick.time`; all are classified unsupported/fail-closed for
Slice 1.

---

## Selector Separation

Proof-local user-facing selector:

```text
delegated-experimental:igniter-vm-candidate
```

Evidence-facing runtime implementation id:

```text
igniter.delegated.experimental.vm.rust-tokio.v0
```

Existing Slice 0 selector remains:

```text
delegated-experimental:ivm-proof
```

The proof records:

```text
runtime_implementation_id_is_user_typed_selector=false
runtime_implementation_id_present_in_mainline_run_surface=false
```

---

## Closed Surfaces

Closed-surface scan status:

```text
PASS
```

The proof wrote only inside:

```text
igniter-lang/experiments/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0/**
```

This card did not edit:

- `igniter-lang/lib/**`;
- `igniter-lang/bin/igc`;
- `igniter-lang/igniter_lang.gemspec`;
- `igniter-lang/README.md`;
- `igniter-lang/docs/README.md`;
- `igniter-lang/docs/ruby-api.md`;
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`;
- `igniter-lang/lib/igniter_lang/compiler_result.rb`;
- `igniter-lang/lib/igniter_lang/compilation_report.rb`;
- `playgrounds/igniter-lab/**`;
- existing Add.igapp;
- existing Add.igapp passport.

---

## Command Matrix

| Command | Result | Output |
| --- | --- | --- |
| `ruby -c igniter-lang/experiments/experimental_igc_run_slice1_vm_capability_passport_hardening_v0/experimental_igc_run_slice1_vm_capability_passport_hardening_v0.rb` | PASS | `Syntax OK` |
| `ruby igniter-lang/experiments/experimental_igc_run_slice1_vm_capability_passport_hardening_v0/experimental_igc_run_slice1_vm_capability_passport_hardening_v0.rb` | PASS | `PASS experimental_igc_run_slice1_vm_capability_passport_hardening_v0` |

No `igc run` Slice 1 command was executed.
No `.igbin` was executed.
No RuntimeSmoke was invoked.

---

## Non-Claims

The proof output explicitly keeps these closed:

- not stable API;
- not production ready;
- not public runtime support;
- not Reference Runtime support;
- not Spark integration;
- not release evidence;
- not public performance claim;
- not compiler passport emission;
- not RuntimeSmoke productization;
- not `igc run` general runtime support;
- not certified alternative implementation;
- not portability guarantee.

---

## Exact C4-A Recommendation

```text
accept proof-local hardening; keep implementation authorization closed
```

Recommended next route:

```text
C3-X pressure review before any C4-A acceptance decision
```

Implementation authorization remains closed. Runtime Specification redirect is
needed only if C3-X/C4-A finds capability or failure-code blockers.
