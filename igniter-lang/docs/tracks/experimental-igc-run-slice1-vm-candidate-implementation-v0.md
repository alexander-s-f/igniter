# Experimental igc run Slice 1 VM Candidate Implementation v0

Card: S3-R243-C2-I
Skill: IDD Agent Protocol
Agent: [Implementation Agent]
Role: implementation-agent
Track: experimental-igc-run-slice1-vm-candidate-implementation-v0
Route: IMPLEMENT
Status: done
Date: 2026-06-03

Depends on:
- S3-R243-C1-A

---

## Goal

Implement the bounded experimental `igc run` Slice 1 VM candidate behavior
authorized by C1-A, using AN-1 Path C:

```text
delegated-experimental:igniter-vm-candidate
  resolves to Slice 1 VM candidate validation boundary
  runtime_implementation_id=igniter.delegated.experimental.vm.rust-tokio.v0
  Add.igapp integer_add / stdlib_integer_add fails closed
```

No public runtime, Reference Runtime, stable API, production, release,
RuntimeSmoke, compiler passport emission, `.igbin`, certification, or
portability authority is claimed or opened.

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-candidate-implementation-authorization-review-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-capability-passport-hardening-decision-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-capability-passport-hardening-v0.md`
- `igniter-lang/experiments/experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/summary.json`
- `igniter-lang/experiments/experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/vm_capability_passport_binding_manifest.json`
- `igniter-lang/experiments/experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/capability_support_gap_matrix.json`
- `igniter-lang/experiments/experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/unsupported_feature_fail_closed_matrix.json`
- `igniter-lang/lib/igniter_lang/cli.rb`
- `igniter-lang/lib/igniter_lang/experimental_igc_run.rb`
- `igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/**`
- `igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/Add.igapp.passport.json`

---

## Changed Files

Implementation:

- `igniter-lang/lib/igniter_lang/experimental_igc_run.rb`
- `igniter-lang/lib/igniter_lang/experimental_igc_run_vm_candidate.rb`
- `igniter-lang/lib/igniter_lang/cli.rb`

Proof:

- `igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/experimental_igc_run_slice1_vm_candidate_v0.rb`
- `igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/inputs/add_19_23.json`
- `igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/out/*.json`

Track:

- `igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-candidate-implementation-v0.md`

No edits were made to `bin/igc`, gemspec, README/public docs, RuntimeSmoke,
CompilerResult, CompilationReport, playgrounds, existing Add.igapp, existing
Add.igapp passport, or R242 hardening evidence files.

---

## Implementation Summary

`ExperimentalIgcRun` now accepts two experimental selectors:

```text
delegated-experimental:ivm-proof
delegated-experimental:igniter-vm-candidate
```

Slice 0 stays on the existing delegated Ruby proof runtime path.

Slice 1 routes to `IgniterLang::ExperimentalIgcRunVmCandidate`, which validates:

- proof-local binding manifest existence and shape;
- binding selector and `runtime_implementation_id`;
- Add.igapp artifact digest;
- existing passport shape;
- existing passport runtime id mismatch as acknowledged evidence, not silent
  reinterpretation;
- capability gap matrix;
- unsupported/fail-closed matrix.

The proof also directly exercises missing binding and capability matrix fields
as fail-closed helper validation paths.

Under Path C, Add.igapp is not executed as a successful VM run because its
feature set contains:

```text
integer_add
stdlib_integer_add
```

The command writes a blocked machine-readable packet with diagnostics:

```text
unsupported_capability_integer_add
unsupported_capability_stdlib_integer_add
```

---

## Result Packet

Observed blocked packet:

```text
kind=experimental_igc_run_slice1_result
status=blocked
runtime_selector=delegated-experimental:igniter-vm-candidate
runtime_implementation_id=igniter.delegated.experimental.vm.rust-tokio.v0
selected_an1_path=Path C fail-closed
binding_check=ok
capability_check=ok
passport_check=runtime_implementation_id_mismatch_acknowledged
outputs={}
```

The packet includes:

- `experimental: true`;
- `pre_v1: true`;
- `stable_api: false`;
- non-claims;
- `not_compiler_result: true`;
- `not_compilation_report: true`;
- `not_release_evidence: true`;
- `not_public_api_response_contract: true`;
- `not_runtime_smoke: true`;
- `not_compiler_passport_emission: true`.

---

## IGR-S1 Result Table

Observed summary:

```text
kind=experimental_igc_run_slice1_vm_candidate_summary
status=PASS
checks=18/18
failed=0
```

| ID | Result | Evidence |
| --- | --- | --- |
| IGR-S1-1 | PASS | Slice 1 selector blocks without `--experimental`. |
| IGR-S1-2 | PASS | Selector resolves to Slice 1 VM candidate result boundary. |
| IGR-S1-3 | PASS | `runtime_implementation_id` remains metadata, not selector. |
| IGR-S1-4 | PASS | Proof-local binding manifest validates. |
| IGR-S1-5 | PASS | Add.igapp artifact digest validates. |
| IGR-S1-6 | PASS | Existing passport mismatch is acknowledged, not silently reinterpreted. |
| IGR-S1-7 | PASS | `integer_add` / `stdlib_integer_add` follow Path C fail-closed. |
| IGR-S1-8 | PASS | Blocked result is explicit and machine-readable. |
| IGR-S1-9 | PASS | Loop/recursion markers fail closed. |
| IGR-S1-10 | PASS | `.igbin` path fails closed. |
| IGR-S1-11 | PASS | RuntimeSmoke is not invoked. |
| IGR-S1-12 | PASS | Compiler passport emission is not invoked. |
| IGR-S1-13 | PASS | Slice 0 `delegated-experimental:ivm-proof` still returns `sum=42`. |
| IGR-S1-14 | PASS | Result packet keeps pre-v1 / no-stable-API / non-public claims. |
| IGR-S1-15 | PASS | Forbidden positive-claim scan has 0 hits. |
| IGR-S1-16 | PASS | Closed-surface scan passes. |
| IGR-S1-17 | PASS | Command matrix passes. |
| IGR-S1-18 | PASS | Authorized-scope git diff is within C1-A write scope. |

Workspace note:

```text
The proof records a workspace_diff_observation that may include unrelated
pre-existing source changes. The IGR-S1-18 check is scoped to C1-A authorized
write paths for this card.
```

---

## Command Matrix

| Command | Result |
| --- | --- |
| `ruby -c igniter-lang/lib/igniter_lang/experimental_igc_run.rb` | PASS |
| `ruby -c igniter-lang/lib/igniter_lang/experimental_igc_run_vm_candidate.rb` | PASS |
| `ruby -c igniter-lang/lib/igniter_lang/cli.rb` | PASS |
| `ruby -c igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/experimental_igc_run_slice1_vm_candidate_v0.rb` | PASS |
| `ruby igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/experimental_igc_run_slice1_vm_candidate_v0.rb` | PASS |

Proof runner exercised:

- Slice 1 selector with `--experimental`;
- Slice 1 selector without `--experimental`;
- Add.igapp integer capability blocked result;
- unsupported `.igbin` path;
- unsupported runtime selector;
- malformed passport;
- malformed input;
- Slice 0 compatibility for `delegated-experimental:ivm-proof`.

---

## Closed Surfaces

Still closed / not edited:

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
- existing Add.igapp passport;
- R242 hardening evidence files.

No release commands were run.
No `.igbin` execution was implemented.
No compiler passport emission path was implemented.
No RuntimeSmoke productization path was implemented.

---

## Exact C4-A Recommendation

```text
accept bounded Slice 1 Path C implementation
```

Keep the implementation bounded:

```text
do not widen beyond Path C
positive runtime evidence is still blocked for Add.igapp integer capability gap
```
