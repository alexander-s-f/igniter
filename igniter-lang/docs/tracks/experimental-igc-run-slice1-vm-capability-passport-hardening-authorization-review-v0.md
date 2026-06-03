# Experimental igc run Slice 1 VM Capability Passport Hardening Authorization Review v0

Card: S3-R242-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-slice1-vm-capability-passport-hardening-authorization-review-v0
Route: UPDATE
Status: authorized
Date: 2026-06-03

Depends on:
- S3-R241-C4-A

---

## Decision

Authorize a bounded proof-local VM capability/passport hardening proof.

Authorized next card:

```text
S3-R242-C2-I
experimental-igc-run-slice1-vm-capability-passport-hardening-v0
```

Route type:

```text
proof-local hardening proof
experiments-only write scope
not implementation authorization
not igc run widening
not compiler passport emission
not public runtime support
not Reference Runtime support
```

Reason:

```text
R241 accepted the Slice 1 VM candidate design boundary but held implementation.
The remaining prerequisite is a proof-local binding between an existing .igapp
artifact and the accepted R240 Rust VM candidate runtime_implementation_id:

  igniter.delegated.experimental.vm.rust-tokio.v0

The current Add.igapp passport remains useful as schema/input evidence, but it
targets `igniter.delegated.experimental.ivm.c_resident`, so it must remain
read-only and must not be silently reinterpreted.
```

This authorization produces evidence-only metadata. It does not authorize any
live runtime or CLI behavior.

---

## Inputs Read

```text
igniter-lang/docs/tracks/stage3-round241-status-curation-v0.md
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
  experimental_runtime_artifact_passport_manifest_v0/out/
  Add.igapp.passport.json
igniter-lang/lib/igniter_lang/experimental_igc_run.rb
igniter-lang/source/loops_and_recursion.ig
```

---

## Compact Decision Summary

```text
C2-I may begin: yes
write scope: experiments-only + proof track doc
proof-local binding metadata: allowed
existing Add.igapp: read-only
existing Add.igapp.passport.json: read-only
playgrounds/igniter-lab/**: read-only
igniter-lang/lib/** and bin/igc: closed
compiler passport emission: closed
.igbin execution: closed
RuntimeSmoke: closed
loops_and_recursion.ig: pressure input only
implementation authorization: closed
public/runtime/reference/stable/performance/portability claims: closed
```

---

## C2-I Boundary

Card:

```text
S3-R242-C2-I
```

Agent:

```text
[Implementation Agent]
```

Track:

```text
experimental-igc-run-slice1-vm-capability-passport-hardening-v0
```

Allowed write scope:

```text
igniter-lang/experiments/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0/**
igniter-lang/docs/tracks/
  experimental-igc-run-slice1-vm-capability-passport-hardening-v0.md
```

Required result packet:

```text
igniter-lang/experiments/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/
  summary.json
```

Required proof-local outputs:

```text
proof-local VM-specific binding manifest
capability support/gap matrix
unsupported feature fail-closed matrix
selector and runtime_implementation_id separation proof
non-claims matrix
closed-surface scan
summary JSON
```

Read-only source/evidence scope:

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
  experimental_runtime_artifact_passport_manifest_v0/out/
  Add.igapp.passport.json
igniter-lang/source/loops_and_recursion.ig
igniter-lang/lib/igniter_lang/experimental_igc_run.rb
```

Closed / read-only surfaces:

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
igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/**
igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/
  Add.igapp.passport.json
```

---

## Binding Manifest Shape

The proof-local binding manifest should be machine-readable JSON and include at
minimum:

```text
kind
format_version
card
track
evidence_class
authority_status
non_claims
artifact_ref
artifact_digest
source_digest if reused from source-backed evidence
semantic_ir_digest if reused from source-backed evidence
artifact_kind
runtime_target_kind
runtime_selector
runtime_implementation_id
selector_visibility
runtime_implementation_id_visibility
required_capabilities
feature_set
required_opcodes or explicit not_applicable reason
capability_source_map
unsupported_feature_policy
loop_recursion_policy
input_contract
output_contract
failure_policy
producer_track
authorized_by
generated_at
```

Required values:

```text
artifact_kind: igapp_dir
runtime_target_kind: delegated_experimental_runtime
runtime_selector: delegated-experimental:igniter-vm-candidate
runtime_implementation_id: igniter.delegated.experimental.vm.rust-tokio.v0
selector_visibility: user-facing / experimental / pre-v1
runtime_implementation_id_visibility: evidence-facing metadata only
evidence_class: proof-local VM capability/passport hardening evidence only
authority_status: non-canonical / evidence-only / candidate-only
```

The manifest must not claim compiler passport emission. It is proof-local
metadata only.

---

## Digest / Immutability Policy

Existing artifacts remain read-only:

```text
igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/**
igniter-lang/experiments/
  experimental_runtime_artifact_passport_manifest_v0/out/
  Add.igapp.passport.json
```

Digest recomputation must follow the accepted Slice 0 / R232 policy:

```text
sort all files under the .igapp directory recursively
hash each file with SHA256
join file digests with ":"
SHA256 the joined string
prefix with "sha256:"
```

The proof may generate a new proof-local binding manifest under the allowed
experiment directory. It must not modify or overwrite the existing passport.

---

## Capability Envelope Policy

The proof-local binding may map capabilities only to accepted R240 VMG evidence:

```text
VMG-1 runtime_implementation_id / metadata
VMG-2 evidence_class / authority_status / non_claims
VMG-3 scoped command matrix
VMG-4 Decimal add/sub/mul/div parity against R238 stdlib dependency context
VMG-5 AOT compiler lowering evidence
VMG-6 stack/register execution evidence
VMG-7 selected branch evidence
VMG-8 non-selected branch silence evidence
VMG-9 unsupported selected-path fail-closed evidence
VMG-10 malformed input / unknown opcode behavior evidence
VMG-11 OP_LOAD_AS_OF hash-based trace identifier wording
VMG-12 map-reduce aggregate evidence
VMG-13 reactive/tbackend classified or skipped
VMG-14 closed-surface scan
VMG-15 no public/stable/reference/performance/portability claims
```

The proof must not promote lab-local loop or recursion tests to accepted Slice 1
evidence.

`igniter-lang/source/loops_and_recursion.ig` status:

```text
pressure input only
not accepted Slice 1 capability
not R240 VMG evidence
must be classified fail-closed / unsupported for Slice 1
separate Runtime Specification / PROP-037+ route required before support
```

---

## Required Proof Matrix

C2-I must prove or explicitly fail:

```text
S1H-1  proof-local binding manifest exists
S1H-2  artifact_ref / artifact_digest for Add.igapp recompute correctly
S1H-3  runtime_implementation_id matches
        igniter.delegated.experimental.vm.rust-tokio.v0
S1H-4  CLI selector remains delegated-experimental:igniter-vm-candidate
S1H-5  runtime_implementation_id is not used as a user-typed selector
S1H-6  required capabilities map to accepted VMG-1..VMG-15 evidence only
S1H-7  loop/recursion are classified pressure-only and fail-closed
S1H-8  .igbin remains excluded
S1H-9  compiler passport emission remains absent
S1H-10 RuntimeSmoke remains absent
S1H-11 unsupported feature matrix is fail-closed
S1H-12 result packet shape is evidence-only / pre-v1 / non-stable
S1H-13 public/runtime/reference/stable/performance/portability claim scan passes
S1H-14 closed-surface scan passes
```

If any capability cannot be bound without normative Runtime Specification
wording, the proof must fail closed and recommend a Runtime Specification input
slice before implementation authorization.

---

## Command Matrix

Required commands:

```text
ruby -c igniter-lang/experiments/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0.rb

ruby igniter-lang/experiments/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0.rb
```

Optional read-only checks may be added if useful:

```text
ruby -rjson -e 'JSON.parse(File.read(ARGV.fetch(0)))' PATH
git status --short
```

No command may execute `igc run` Slice 1, `.igbin`, RuntimeSmoke, daemon/server
surfaces, release commands, or public claim tooling.

---

## Explicit Answers

Whether C2-I may begin:

```text
Yes.
```

Whether experiments-only write scope is enough:

```text
Yes.
```

Whether proof-local binding metadata may be generated:

```text
Yes, under the allowed experiment directory only.
```

Whether existing Add.igapp and Add.igapp passport remain read-only:

```text
Yes.
```

Whether `igniter-lang/lib/**`, `bin/igc`, gemspec, README, public docs,
RuntimeSmoke, CompilerResult, or CompilationReport may be edited:

```text
No.
```

Whether `playgrounds/igniter-lab/**` may be edited:

```text
No.
```

Whether `loops_and_recursion.ig` is pressure input only:

```text
Yes.
```

Whether generated output may be called proof-local capability/passport hardening
evidence only:

```text
Yes.
```

Whether implementation authorization remains closed:

```text
Yes.
```

Whether public/stable/production/Reference Runtime/Spark/release/performance/
portability claims remain closed:

```text
Yes.
```

---

## C2-I Dispatch

```text
Card: S3-R242-C2-I
Skill: IDD Agent Protocol
Agent: [Implementation Agent]
Role: implementation-agent
Track: experimental-igc-run-slice1-vm-capability-passport-hardening-v0

Route: IMPLEMENT
Depends on:
- S3-R242-C1-A

Goal:
Implement a bounded proof-local VM capability/passport hardening proof for
experimental `igc run` Slice 1, producing evidence-only binding metadata that
maps an existing `.igapp` artifact to
`igniter.delegated.experimental.vm.rust-tokio.v0` and the accepted R240 VMG
capability envelope, without editing CLI/runtime/package/public surfaces or
authorizing implementation.

Allowed write scope:
- igniter-lang/experiments/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0/**
- igniter-lang/docs/tracks/
  experimental-igc-run-slice1-vm-capability-passport-hardening-v0.md

Required result packet:
- igniter-lang/experiments/
  experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/
  summary.json

Required matrix:
- S1H-1..S1H-14 as defined by S3-R242-C1-A

Closed:
- igniter-lang/lib/**
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

Deliver:
- Proof track doc in `igniter-lang/docs/tracks/`
- Proof-local experiment files and summary JSON
- Compact command matrix
- S1H-1..S1H-14 result table
- Exact C4-A recommendation
```
