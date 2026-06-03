# Experimental igc run Slice 1 VM Candidate Implementation Acceptance Decision v0

Card: S3-R243-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-slice1-vm-candidate-implementation-acceptance-decision-v0
Route: UPDATE
Status: conditional-accept / adjacent-artifact-exclusion-required
Date: 2026-06-03

Depends on:
- S3-R243-C2-I
- S3-R243-C3-X

---

## Decision

Conditionally accept the bounded experimental `igc run` Slice 1 VM candidate
implementation/proof.

Accepted implementation boundary:

```text
Slice 1 selector:
  delegated-experimental:igniter-vm-candidate

runtime_implementation_id:
  igniter.delegated.experimental.vm.rust-tokio.v0

selected AN-1 path:
  Path C fail-closed
```

Condition:

```text
R243 status curation must explicitly record that adjacent source/conformance
artifacts found in the C2-I commit are not accepted as R243 implementation
evidence, runtime authority, conformance authority, portability evidence, or
public claim support.
```

Reason:

```text
C2-I and C3-X show correct Slice 1 Path C behavior: 18/18 IGR-S1 PASS,
machine-readable blocked diagnostics for integer_add / stdlib_integer_add,
Slice 0 compatibility preserved, claim scan clean, and public/runtime/reference
authority closed.

However, the C2-I commit also contains adjacent source/conformance artifacts
outside the S3-R243-C1-A allowed write scope. C3-X treats these as pre-existing
workspace observations, but the git commit includes them. This does not require
rejecting the Slice 1 implementation evidence, but it must be explicitly
excluded from R243 acceptance authority.
```

This decision accepts the bounded implementation evidence only. It does not
accept adjacent conformance/source artifacts.

---

## Inputs Read

```text
igniter-lang/docs/tracks/
  experimental-igc-run-slice1-vm-candidate-implementation-authorization-
  review-v0.md
igniter-lang/docs/tracks/
  experimental-igc-run-slice1-vm-candidate-implementation-v0.md
igniter-lang/docs/discussions/
  experimental-igc-run-slice1-vm-candidate-implementation-pressure-v0.md
igniter-lang/experiments/
  experimental_igc_run_slice1_vm_candidate_v0/out/summary.json
igniter-lang/experiments/
  experimental_igc_run_slice1_vm_candidate_v0/out/
  slice1_integer_add_blocked.result.json
igniter-lang/experiments/
  experimental_igc_run_slice1_vm_candidate_v0/out/slice0_compat.result.json
igniter-lang/lib/igniter_lang/cli.rb
igniter-lang/lib/igniter_lang/experimental_igc_run.rb
igniter-lang/lib/igniter_lang/experimental_igc_run_vm_candidate.rb
igniter-lang/docs/tracks/stage3-round242-status-curation-v0.md
igniter-lang/docs/tracks/
  experimental-igc-run-slice1-vm-capability-passport-hardening-
  decision-v0.md
```

---

## Accepted Files

Accepted as R243 Slice 1 implementation/proof evidence:

```text
igniter-lang/lib/igniter_lang/cli.rb
igniter-lang/lib/igniter_lang/experimental_igc_run.rb
igniter-lang/lib/igniter_lang/experimental_igc_run_vm_candidate.rb
igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/
  experimental_igc_run_slice1_vm_candidate_v0.rb
igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/
  inputs/add_19_23.json
igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/out/
  fake.igbin
igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/out/
  malformed.input.json
igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/out/
  malformed.passport.json
igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/out/
  malformed_input.result.json
igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/out/
  malformed_passport.result.json
igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/out/
  slice0_compat.result.json
igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/out/
  slice1_integer_add_blocked.result.json
igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/out/
  slice1_missing_experimental.result.json
igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/out/
  summary.json
igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/out/
  unsupported_igbin_path.result.json
igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/out/
  unsupported_runtime.result.json
igniter-lang/docs/tracks/
  experimental-igc-run-slice1-vm-candidate-implementation-v0.md
```

Accepted only as read evidence, not modified authority:

```text
igniter-lang/experiments/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0/**
igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/**
igniter-lang/experiments/
  experimental_runtime_artifact_passport_manifest_v0/out/
  Add.igapp.passport.json
```

---

## Adjacent Artifacts Excluded from Acceptance

The C2-I commit also contains adjacent source/conformance changes outside the
S3-R243-C1-A allowed write scope. These files are not accepted as R243 evidence
or authority:

```text
igniter-lang/source/availability_projection.ig
igniter-lang/source/tenant_availability_projection.ig
igniter-lang/out/conformance/ruby/availability_projection.igapp/
  classified_ast.json
igniter-lang/out/conformance/ruby/availability_projection.igapp/
  compatibility_metadata.json
igniter-lang/out/conformance/ruby/availability_projection.igapp/
  compilation_report.json
igniter-lang/out/conformance/ruby/availability_projection.igapp/contracts/
  availability_projection.json
igniter-lang/out/conformance/ruby/availability_projection.igapp/
  manifest.json
igniter-lang/out/conformance/ruby/availability_projection.igapp/
  semantic_ir_program.json
igniter-lang/out/conformance/ruby/tenant_availability_projection.igapp/
  classified_ast.json
igniter-lang/out/conformance/ruby/tenant_availability_projection.igapp/
  compatibility_metadata.json
igniter-lang/out/conformance/ruby/tenant_availability_projection.igapp/
  compilation_report.json
igniter-lang/out/conformance/ruby/tenant_availability_projection.igapp/contracts/
  tenant_availability_projection.json
igniter-lang/out/conformance/ruby/tenant_availability_projection.igapp/
  manifest.json
igniter-lang/out/conformance/ruby/tenant_availability_projection.igapp/
  semantic_ir_program.json
igniter-lang/out/conformance/rust/availability_projection.igapp/
  classified_ast.json
igniter-lang/out/conformance/rust/availability_projection.igapp/
  compatibility_metadata.json
igniter-lang/out/conformance/rust/availability_projection.igapp/
  compilation_report.json
igniter-lang/out/conformance/rust/availability_projection.igapp/contracts/
  availability_projection.json
igniter-lang/out/conformance/rust/availability_projection.igapp/
  manifest.json
igniter-lang/out/conformance/rust/availability_projection.igapp/
  semantic_ir_program.json
igniter-lang/out/conformance/rust/tenant_availability_projection.igapp/
  classified_ast.json
igniter-lang/out/conformance/rust/tenant_availability_projection.igapp/
  compatibility_metadata.json
igniter-lang/out/conformance/rust/tenant_availability_projection.igapp/
  compilation_report.json
igniter-lang/out/conformance/rust/tenant_availability_projection.igapp/contracts/
  tenant_availability_projection.json
igniter-lang/out/conformance/rust/tenant_availability_projection.igapp/
  manifest.json
igniter-lang/out/conformance/rust/tenant_availability_projection.igapp/
  semantic_ir_program.json
```

Required curation wording:

```text
Adjacent source/conformance artifacts in the C2-I commit are excluded from
R243 acceptance. They create no conformance authority, portability guarantee,
alternative certification, public runtime support, or release evidence.
```

---

## Accepted Results

Command matrix:

```text
ruby -c igniter-lang/lib/igniter_lang/experimental_igc_run.rb: PASS
ruby -c igniter-lang/lib/igniter_lang/experimental_igc_run_vm_candidate.rb: PASS
ruby -c igniter-lang/lib/igniter_lang/cli.rb: PASS
ruby -c igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/
  experimental_igc_run_slice1_vm_candidate_v0.rb: PASS
ruby igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/
  experimental_igc_run_slice1_vm_candidate_v0.rb: PASS
```

IGR-S1 result:

```text
IGR-S1-1  PASS  selector accepted only with --experimental
IGR-S1-2  PASS  selector resolves to Slice 1 VM candidate boundary
IGR-S1-3  PASS  runtime_implementation_id remains evidence-facing metadata
IGR-S1-4  PASS  proof-local binding manifest validates
IGR-S1-5  PASS  artifact digest validates
IGR-S1-6  PASS  existing Add.igapp passport mismatch is not silently
                reinterpreted
IGR-S1-7  PASS  integer_add / stdlib_integer_add follows Path C
IGR-S1-8  PASS  Path C blocked result is explicit and machine-readable
IGR-S1-9  PASS  unsupported loop/recursion markers fail closed
IGR-S1-10 PASS  .igbin fails closed
IGR-S1-11 PASS  RuntimeSmoke is not invoked
IGR-S1-12 PASS  compiler passport emission is not invoked
IGR-S1-13 PASS  Slice 0 delegated-experimental:ivm-proof remains compatible
IGR-S1-14 PASS  result packet keeps pre-v1 / no-stable-API / non-public claims
IGR-S1-15 PASS  forbidden phrase scan passes
IGR-S1-16 PASS  closed-surface scan passes for declared closed surfaces
IGR-S1-17 PASS  command matrix passes
IGR-S1-18 CONDITIONAL  authorized implementation scope is clean, but adjacent
                       committed source/conformance artifacts must be excluded
                       from R243 authority by status curation
```

Path C blocked packet:

```text
kind=experimental_igc_run_slice1_result
status=blocked
runtime_selector=delegated-experimental:igniter-vm-candidate
runtime_implementation_id=igniter.delegated.experimental.vm.rust-tokio.v0
selected_an1_path=Path C fail-closed
diagnostics:
  unsupported_capability_integer_add
  unsupported_capability_stdlib_integer_add
outputs={}
stable_api=false
pre_v1=true
experimental=true
not_runtime_smoke=true
not_compiler_passport_emission=true
```

Slice 0 compatibility:

```text
runtime_selector=delegated-experimental:ivm-proof
status=ok
outputs.sum=42
```

---

## Explicit Answers

Whether Slice 1 implementation/proof is accepted:

```text
Conditionally accepted. The implementation/proof is accepted; adjacent
source/conformance artifacts are excluded and require status-curation wording.
```

Whether generated output may be called experimental delegated-runtime Slice 1
evidence only:

```text
Yes.
```

Whether this creates public runtime support:

```text
No.
```

Whether this creates Reference Runtime support:

```text
No.
```

Whether stable API remains unpromised before v1:

```text
Yes.
```

Whether `.igbin`, compiler passport emission, RuntimeSmoke productization,
Spark, release, production, public demo, public performance, certification, and
portability claims remain closed:

```text
Yes.
```

Whether positive execution of Add.igapp with integer_add is accepted:

```text
No. It remains fail-closed under Path C.
```

---

## Next Route

Immediate required follow-up:

```text
S3-R243-C5-S
stage3-round243-status-curation-v0
```

Required curation condition:

```text
Record R243 as conditional-accepted, with adjacent source/conformance artifacts
explicitly excluded from R243 authority.
```

Next Main Line route after status curation:

```text
S3-R244-C1-A
experimental-igc-run-slice1-quickstart-docs-authorization-review-v0
```

Route intent:

```text
Decide whether bounded internal quickstart/docs exposure may begin for the
accepted experimental `igc run` Slice 1 Path C behavior, describing only
experimental delegated-runtime Slice 1 evidence and explicit integer-add
fail-closed behavior.
```

Keep closed:

```text
positive Add.igapp integer_add execution
.igbin execution
compiler passport emission
RuntimeSmoke productization
Reference Runtime
public runtime support
stable API guarantee
production readiness
Spark integration
release evidence
public performance claims
alternative certification
portability guarantee
adjacent conformance/source artifact authority
```
