# Experimental igc run Slice 1 VM Candidate Implementation Authorization Review v0

Card: S3-R243-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-slice1-vm-candidate-implementation-authorization-review-v0
Route: UPDATE
Status: authorized / Path C fail-closed
Date: 2026-06-03

Depends on:
- S3-R242-C4-A

---

## Decision

Authorize a bounded experimental `igc run` Slice 1 VM candidate implementation
using AN-1 Path C.

Authorized next card:

```text
S3-R243-C2-I
experimental-igc-run-slice1-vm-candidate-implementation-v0
```

Selected AN-1 path:

```text
Path C:
  implement Slice 1 selector and validation boundary, but treat
  integer_add / stdlib_integer_add as explicit fail-closed diagnostics.
  Positive runtime evidence must use only capabilities bound to accepted VMG
  evidence.
```

Reason:

```text
R242 accepted proof-local VM capability/passport hardening evidence and closed
the R241 passport-binding prerequisite as evidence.

The current Add.igapp artifact remains an integer-add artifact:
  feature_set: integer_add, stdlib_integer_add

That capability is recorded as a gap, not accepted runtime capability. A
bounded Slice 1 implementation may still begin if it exposes the VM candidate
selector and proof-local validation path while blocking the integer-add
artifact with a machine-readable fail-closed diagnostic.
```

This authorization is not public runtime support and not Reference Runtime
support.

---

## Inputs Read

```text
igniter-lang/docs/tracks/stage3-round242-status-curation-v0.md
igniter-lang/docs/tracks/
  experimental-igc-run-slice1-vm-capability-passport-hardening-decision-v0.md
igniter-lang/docs/tracks/
  experimental-igc-run-slice1-vm-capability-passport-hardening-v0.md
igniter-lang/experiments/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/
  summary.json
igniter-lang/experiments/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/
  vm_capability_passport_binding_manifest.json
igniter-lang/experiments/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/
  capability_support_gap_matrix.json
igniter-lang/experiments/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/
  unsupported_feature_fail_closed_matrix.json
igniter-lang/docs/discussions/
  experimental-igc-run-slice1-vm-capability-passport-hardening-pressure-v0.md
igniter-lang/docs/tracks/
  experimental-igc-run-slice1-vm-candidate-design-decision-v0.md
igniter-lang/lib/igniter_lang/cli.rb
igniter-lang/lib/igniter_lang/experimental_igc_run.rb
igniter-lang/bin/igc
igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/**
igniter-lang/experiments/
  experimental_runtime_artifact_passport_manifest_v0/out/
  Add.igapp.passport.json
```

---

## Compact Decision Summary

```text
C2-I may begin: yes
selected AN-1 path: Path C fail-closed
Slice 1 selector may be implemented: yes
positive Add.igapp execution: no
integer_add / stdlib_integer_add: explicit fail-closed diagnostic
runtime_implementation_id: evidence-facing metadata only
bin/igc: read-only
.igbin: closed
compiler passport emission: closed
RuntimeSmoke: closed
public/runtime/reference/stable/performance/portability claims: closed
```

---

## Authorization Boundary

Allowed write scope:

```text
igniter-lang/lib/igniter_lang/experimental_igc_run.rb
igniter-lang/lib/igniter_lang/experimental_igc_run_vm_candidate.rb
  if cleaner than expanding experimental_igc_run.rb
igniter-lang/lib/igniter_lang/cli.rb
  only if needed for usage / selector wording
igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/**
igniter-lang/docs/tracks/
  experimental-igc-run-slice1-vm-candidate-implementation-v0.md
```

Required result packet:

```text
igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/out/
  summary.json
```

Read-only / closed unless explicitly authorized:

```text
igniter-lang/bin/igc
igniter-lang/igniter_lang.gemspec
igniter-lang/README.md
igniter-lang/docs/README.md
igniter-lang/docs/ruby-api.md
igniter-lang/lib/igniter_lang/runtime_smoke.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
playgrounds/igniter-lab/**
igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/**
igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/
  Add.igapp.passport.json
igniter-lang/experiments/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0/**
```

---

## Required Slice 1 Behavior

Command vocabulary remains:

```text
igc run ARTIFACT.igapp --passport PATH.json --input PATH.json \
  --runtime delegated-experimental:igniter-vm-candidate \
  --out PATH.json --experimental
```

Required flags:

```text
ARTIFACT.igapp
--passport
--input
--runtime delegated-experimental:igniter-vm-candidate
--out
--experimental
```

Selector resolution:

```text
delegated-experimental:igniter-vm-candidate
  resolves to the proof-local Slice 1 VM candidate boundary backed by
  runtime_implementation_id:
    igniter.delegated.experimental.vm.rust-tokio.v0
```

Selector / metadata separation:

```text
runtime selector:
  user-facing / experimental / pre-v1

runtime_implementation_id:
  evidence-facing metadata only
  not the user-typed CLI selector
```

Path C fail-closed policy:

```text
If the artifact or binding requires integer_add or stdlib_integer_add, the
Slice 1 command must write a result packet with status blocked and an explicit
diagnostic such as:

  code: unsupported_capability_integer_add

The command must not silently dispatch this artifact to a VM execution path and
must not report successful runtime execution for this capability gap.
```

Positive runtime evidence policy:

```text
Positive Slice 1 runtime evidence is allowed only for capabilities bound to
accepted VMG evidence. If no positive artifact exists inside the authorized
scope, the proof may be accepted as selector/validation/fail-closed
implementation evidence only.
```

---

## Validation Requirements

C2-I must validate:

```text
proof-local binding manifest exists
binding runtime_selector matches delegated-experimental:igniter-vm-candidate
binding runtime_implementation_id matches igniter.delegated.experimental.vm.rust-tokio.v0
artifact_digest recomputes for Add.igapp
existing Add.igapp passport mismatch is not silently reinterpreted
feature gaps are read from capability_support_gap_matrix.json
integer_add / stdlib_integer_add fail closed under Path C
loop/recursion fail closed
.igbin fail closed
malformed passport/input fail closed
missing output path / required args fail closed
unsupported runtime selector fail closed
RuntimeSmoke not invoked
compiler passport emission not invoked
```

Result packets must include:

```text
kind
format_version
card
track
status
experimental: true
pre_v1: true
stable_api: false
artifact_ref
passport_ref
input_ref
runtime_selector
runtime_implementation_id
runtime_authority
selected_an1_path
outputs
diagnostics
non_claims
not_compiler_result: true
not_compilation_report: true
not_release_evidence: true
not_public_api_response_contract: true
```

---

## Required Proof Matrix

```text
IGR-S1-1  selector accepted only with --experimental
IGR-S1-2  delegated-experimental:igniter-vm-candidate resolves to Slice 1 VM
          candidate boundary
IGR-S1-3  runtime_implementation_id remains evidence-facing metadata
IGR-S1-4  proof-local binding manifest validates
IGR-S1-5  artifact digest validates
IGR-S1-6  existing Add.igapp passport mismatch is not silently reinterpreted
IGR-S1-7  integer_add / stdlib_integer_add follows Path C
IGR-S1-8  Path C blocked result is explicit and machine-readable
IGR-S1-9  unsupported loop/recursion markers fail closed
IGR-S1-10 .igbin fails closed
IGR-S1-11 RuntimeSmoke is not invoked
IGR-S1-12 compiler passport emission is not invoked
IGR-S1-13 Slice 0 delegated-experimental:ivm-proof behavior remains compatible
IGR-S1-14 result packet keeps pre-v1 / no-stable-API / non-public claims
IGR-S1-15 forbidden phrase scan passes
IGR-S1-16 closed-surface scan passes
IGR-S1-17 command matrix passes
IGR-S1-18 git diff stays within authorized write scope
```

---

## Required Command Matrix

Minimum required commands:

```text
ruby -c igniter-lang/lib/igniter_lang/experimental_igc_run.rb
ruby -c igniter-lang/lib/igniter_lang/experimental_igc_run_vm_candidate.rb
  if created
ruby -c igniter-lang/lib/igniter_lang/cli.rb
ruby -c igniter-lang/experiments/
  experimental_igc_run_slice1_vm_candidate_v0/
  experimental_igc_run_slice1_vm_candidate_v0.rb
ruby igniter-lang/experiments/
  experimental_igc_run_slice1_vm_candidate_v0/
  experimental_igc_run_slice1_vm_candidate_v0.rb
```

The proof runner must exercise:

```text
Slice 1 selector with --experimental
Slice 1 selector without --experimental
Add.igapp integer_add blocked result
unsupported .igbin path
unsupported runtime selector
malformed passport
malformed input
Slice 0 compatibility for delegated-experimental:ivm-proof
```

No release command may run.

---

## Explicit Answers

Whether C2-I may begin:

```text
Yes.
```

Which AN-1 path is selected:

```text
Path C.
```

Whether `igniter-lang/lib/igniter_lang/experimental_igc_run.rb` may be edited:

```text
Yes.
```

Whether `igniter-lang/lib/igniter_lang/cli.rb` may be edited:

```text
Yes, but only for usage / selector wording if needed.
```

Whether a small internal helper file may be created:

```text
Yes:
igniter-lang/lib/igniter_lang/experimental_igc_run_vm_candidate.rb
```

Whether `bin/igc` remains read-only:

```text
Yes.
```

What `delegated-experimental:igniter-vm-candidate` resolves to:

```text
The proof-local Slice 1 VM candidate boundary with evidence-facing
runtime_implementation_id:
  igniter.delegated.experimental.vm.rust-tokio.v0
```

Whether `runtime_implementation_id` remains evidence-facing metadata only:

```text
Yes.
```

Whether Add.igapp with `integer_add` must fail closed:

```text
Yes. Under Path C it must produce explicit blocked diagnostics unless a later
parity proof or Decimal-only path is separately authorized.
```

Whether `.igbin`, compiler passport emission, RuntimeSmoke, README, gemspec,
public docs, CompilerResult, and CompilationReport remain closed:

```text
Yes.
```

Whether stable API, production, public demo, Spark, release, Reference Runtime,
public runtime, public performance, certification, and portability claims
remain closed:

```text
Yes.
```

---

## C2-I Dispatch Boundary

```text
Card: S3-R243-C2-I
Skill: IDD Agent Protocol
Agent: [Implementation Agent]
Role: implementation-agent
Track: experimental-igc-run-slice1-vm-candidate-implementation-v0

Route: IMPLEMENT
Depends on:
- S3-R243-C1-A

Goal:
Implement bounded experimental `igc run` Slice 1 VM candidate selector and
proof-local validation/fail-closed behavior under Path C, preserving Slice 0
compatibility and keeping all public/runtime/reference/stable authority closed.

Allowed write scope:
- igniter-lang/lib/igniter_lang/experimental_igc_run.rb
- igniter-lang/lib/igniter_lang/experimental_igc_run_vm_candidate.rb
  if cleaner than expanding `experimental_igc_run.rb`
- igniter-lang/lib/igniter_lang/cli.rb
  only if needed for usage / selector wording
- igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/**
- igniter-lang/docs/tracks/
  experimental-igc-run-slice1-vm-candidate-implementation-v0.md

Required result packet:
- igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/out/
  summary.json

Required matrix:
- IGR-S1-1..IGR-S1-18 as defined by S3-R243-C1-A

Required selected path:
- Path C fail-closed for integer_add / stdlib_integer_add

Closed:
- igniter-lang/bin/igc
- igniter-lang/igniter_lang.gemspec
- igniter-lang/README.md
- igniter-lang/docs/README.md
- igniter-lang/docs/ruby-api.md
- igniter-lang/lib/igniter_lang/runtime_smoke.rb
- igniter-lang/lib/igniter_lang/compiler_result.rb
- igniter-lang/lib/igniter_lang/compilation_report.rb
- playgrounds/igniter-lab/**
- existing Add.igapp/**
- existing Add.igapp.passport.json
- R242 hardening evidence files

Deliver:
- Implementation/proof doc in `igniter-lang/docs/tracks/`
- Machine-readable summary JSON
- Command matrix
- IGR-S1 result table
- Exact C4-A recommendation or blocker list
```
