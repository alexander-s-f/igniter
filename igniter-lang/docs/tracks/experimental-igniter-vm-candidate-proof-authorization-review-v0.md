# Experimental Igniter VM Candidate Proof Authorization Review v0

Card: S3-R240-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igniter-vm-candidate-proof-authorization-review-v0
Route: UPDATE
Status: authorized
Date: 2026-06-03

Depends on:
- S3-R239-C4-A

---

## Decision

Authorize bounded proof-local `igniter-vm` candidate proof.

Authorized next card:

```text
S3-R240-C2-I
experimental-igniter-vm-candidate-proof-v0
```

Route type:

```text
proof-local implementation proof
lab-local only
not runtime productization
not public runtime support
not Reference Runtime support
not igc run widening
```

Reason:

```text
R239 accepted igniter-vm as delegated experimental VM candidate evidence.
R239 identified proof gaps that are small enough for a bounded lab-local proof:
runtime_implementation_id, evidence_class, non_claims, capability surface,
branch-silence proof, unsupported/malformed fail-closed proof, and observation
trace wording.
```

This authorization does not accept `igniter-vm` as runtime support. It only
authorizes proof-local evidence production inside the lab VM candidate.

---

## Inputs Read

```text
igniter-lang/docs/tracks/
  experimental-igniter-vm-candidate-intake-decision-v0.md
igniter-lang/docs/tracks/
  experimental-igniter-vm-candidate-surface-facts-v0.md
igniter-lang/docs/discussions/
  experimental-igniter-vm-candidate-intake-pressure-v0.md
igniter-lang/docs/tracks/
  experimental-igniter-vm-candidate-intake-authorization-review-v0.md
igniter-lang/docs/tracks/
  experimental-stdlib-candidate-proof-acceptance-decision-v0.md
playgrounds/igniter-lab/igniter-stdlib/out/
  stdlib_candidate_proof/summary.json
playgrounds/igniter-lab/igniter-vm/Cargo.toml
playgrounds/igniter-lab/igniter-vm/Cargo.lock
playgrounds/igniter-lab/igniter-vm/README.md
playgrounds/igniter-lab/igniter-vm/src/**
playgrounds/igniter-lab/igniter-vm/tests/**
```

---

## Compact Decision Summary

```text
C2-I may begin: yes
VM proof: authorized
write VM lab candidate: yes, bounded to proof artifacts/tests only
write mainline proof track doc: yes
write other lab packages: no
write mainline runtime/API/CLI/package files: no
result packet: required
runtime_implementation_id: proof-local metadata only
igc run Slice 1: held
reactive/tbackend daemon route: classify or skip, do not execute as proof
public/runtime/reference/stable/performance/portability claims: closed
```

---

## C2-I Boundary

Card:

```text
S3-R240-C2-I
```

Agent:

```text
[Implementation Agent]
```

Track:

```text
experimental-igniter-vm-candidate-proof-v0
```

Allowed write scope:

```text
playgrounds/igniter-lab/igniter-vm/**
igniter-lang/docs/tracks/experimental-igniter-vm-candidate-proof-v0.md
```

Required result packet:

```text
playgrounds/igniter-lab/igniter-vm/out/
  vm_candidate_proof/summary.json
```

Allowed VM-local proof artifacts include:

```text
playgrounds/igniter-lab/igniter-vm/proofs/vm_candidate_proof.rb
playgrounds/igniter-lab/igniter-vm/tests/vm_candidate_proof_tests.rs
playgrounds/igniter-lab/igniter-vm/out/vm_candidate_proof/**
```

The implementation agent may choose a Ruby proof runner, Rust integration tests,
or both. The proof must keep changes scoped to the VM lab candidate and proof
track document.

Read-only / closed unless separately authorized:

```text
playgrounds/igniter-lab/igniter-stdlib/**
playgrounds/igniter-lab/igniter-tbackend/**
playgrounds/igniter-lab/igniter-runtime/**
playgrounds/igniter-lab/igniter-compiler/**
playgrounds/igniter-lab/igniter-apps/**
igniter-lang/lib/**
igniter-lang/bin/igc
igniter-lang/igniter_lang.gemspec
igniter-lang/README.md
igniter-lang/docs/README.md
igniter-lang/docs/ruby-api.md
igniter-lang/lib/igniter_lang/runtime_smoke.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
```

---

## Result Packet Contract

`summary.json` must be machine-readable JSON and include at minimum:

```text
kind
card
track
authorization
date
overall
checks_total
checks_pass
checks_fail
runtime_implementation_id
evidence_class
authority_status
non_claims
capability_surface
command_matrix
proof_matrix
closed_surface_scan
skipped_or_classified_surfaces
```

Required `runtime_implementation_id`:

```text
igniter.delegated.experimental.vm.rust-tokio.v0
```

Required `evidence_class`:

```text
proof_local_vm_candidate_evidence
```

Required authority stance:

```text
non_canonical
candidate_only
proof_local
no_public_runtime_authority
no_reference_runtime_authority
no_runtime_api_cli_package_authority
```

Required non-claims include:

```text
not_public_runtime_support
not_reference_runtime_support
not_stable_api
not_production_ready
not_spark_integration
not_release_evidence
not_public_performance_claim
not_official_reference_status
not_alternative_certification
not_portability_guarantee
not_igc_run_widening
not_compiler_passport_emission
not_runtime_smoke_productization
```

---

## Required Proof Matrix

C2-I must prove or explicitly fail:

```text
VMG-1 runtime_implementation_id present in proof-local summary metadata
VMG-2 evidence_class / authority_status / non_claims present
VMG-3 command matrix scoped to VM proof, no daemon/server side effects
VMG-4 Decimal add/sub/mul/div delegation parity with R238 dependency context
VMG-5 AOT compiler lowering evidence
VMG-6 stack/register execution evidence
VMG-7 selected branch evidence
VMG-8 non-selected branch silence evidence:
      false condition selects else branch, then branch is not executed, and
      then branch emits no observation to the observation sink
VMG-9 unsupported selected-path fail-closed evidence
VMG-10 malformed input / unknown opcode behavior evidence
VMG-11 OP_LOAD_AS_OF / observation trace evidence using only
       "hash-based trace identifier" wording
VMG-12 map-reduce aggregate evidence
VMG-13 reactive/tbackend surface kept classified or explicitly skipped
VMG-14 closed-surface scan
VMG-15 no public/stable/reference/performance/portability claims
```

If any VMG check cannot be proven inside the allowed scope, the proof must fail
closed and record the blocker in the result packet.

---

## Observation Trace Wording Boundary

Allowed wording:

```text
hash-based trace identifier
proof-local observation trace
trace identifier
observation id
```

Forbidden wording in proof doc, proof script output, and `summary.json`:

```text
tamper-evident
tamper evidence
cryptographic audit chain
digital signature
security authority
security proof
security guarantee
```

Rationale:

```text
R239 pressure found that the current SHA256-derived observation id is a
hash-based trace identifier, not a digital signature or security mechanism.
```

---

## Command Matrix Authorization

Required commands:

```text
cargo test --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml \
  --test vm_tests

cargo test --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml \
  --lib

ruby playgrounds/igniter-lab/igniter-vm/proofs/vm_candidate_proof.rb
```

Required if a new Rust proof integration test is added:

```text
cargo test --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml \
  --test vm_candidate_proof_tests
```

Optional:

```text
cargo metadata --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml \
  --no-deps
```

Not authorized:

```text
cargo test --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml
cargo run --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml
cargo build --release --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml
playgrounds/igniter-lab/igniter-vm/tests/reactive_tests.rs execution
any command that starts tbackend, a listener, a daemon, or a long-running server
release commands
package publish commands
destructive commands
```

Full `cargo test` remains closed because it includes `reactive_tests.rs`, which
starts an external tbackend daemon through an absolute path and opens local
ports.

---

## Reactive / TBackend Stance

The proof may inspect and classify these surfaces:

```text
reactive_tests.rs
ReactiveListener
ProjectionPipeline
LedgerTcpBackend
external tbackend daemon dependency
```

The proof may not execute or promote them as proof evidence unless a later card
explicitly authorizes daemon/server testing.

Required classification:

```text
classified_or_skipped
not runtime proof
not backend authority
not public runtime support
```

---

## Evidence / Authority Stance

Generated output may be called:

```text
proof-local VM candidate evidence only
```

Generated output must not be called:

```text
runtime support evidence
Reference Runtime evidence
public runtime evidence
public API evidence
release evidence
public performance evidence
portability evidence
certification evidence
official/reference evidence
```

---

## Explicit Answers

Whether C2-I may begin:

```text
yes.
```

Whether writes under `playgrounds/igniter-lab/igniter-vm/**` are allowed:

```text
yes, bounded to proof artifacts, proof-local tests, result packet output, and
minimal VM-local changes needed to make the proof executable. These writes do
not create runtime authority.
```

Whether the mainline proof track doc may be written:

```text
yes:
igniter-lang/docs/tracks/experimental-igniter-vm-candidate-proof-v0.md
```

Whether `igniter-stdlib`, `igniter-tbackend`, `igniter-runtime`, or other lab
packages may be edited:

```text
no.
```

Whether `igniter-lang/lib/**`, `bin/igc`, gemspec, README, public docs,
RuntimeSmoke, CompilerResult, or CompilationReport may be edited:

```text
no.
```

Whether a Ruby proof runner, Rust tests, or summary JSON may be added inside
the VM lab candidate:

```text
yes.
```

Whether generated output may be called proof-local VM candidate evidence only:

```text
yes.
```

Whether `igc run` Slice 1 remains held:

```text
yes.
```

Whether public/stable/production/Reference Runtime/Spark/release/performance
and portability claims remain closed:

```text
yes, all remain closed.
```

---

## Exact C2-I Dispatch

```text
Card: S3-R240-C2-I
Skill: IDD Agent Protocol
Agent: [Implementation Agent]
Role: implementation-agent
Track: experimental-igniter-vm-candidate-proof-v0

Route: IMPLEMENT
Depends on:
- S3-R240-C1-A

Goal:
Implement a bounded proof-local `igniter-vm` candidate proof inside the lab VM
candidate, producing a machine-readable result packet and proof track doc
without creating public runtime support, Reference Runtime support,
runtime/API/CLI/package authority, `igc run` widening, `.igbin` execution,
compiler passport emission, RuntimeSmoke productization, stable API,
production readiness, Spark integration, release evidence, public performance
claims, certification, or portability guarantees.

Scope:
- Read:
  - S3-R240-C1-A authorization decision
  - igniter-lang/docs/tracks/
    experimental-igniter-vm-candidate-intake-decision-v0.md
  - igniter-lang/docs/tracks/
    experimental-igniter-vm-candidate-surface-facts-v0.md
  - igniter-lang/docs/discussions/
    experimental-igniter-vm-candidate-intake-pressure-v0.md
  - igniter-lang/docs/tracks/
    experimental-stdlib-candidate-proof-acceptance-decision-v0.md
  - playgrounds/igniter-lab/igniter-stdlib/out/
    stdlib_candidate_proof/summary.json
  - playgrounds/igniter-lab/igniter-vm/**
- Write only:
  - playgrounds/igniter-lab/igniter-vm/**
  - igniter-lang/docs/tracks/experimental-igniter-vm-candidate-proof-v0.md
- Required output:
  - playgrounds/igniter-lab/igniter-vm/out/
    vm_candidate_proof/summary.json
- Required result packet fields:
  - kind
  - card
  - track
  - authorization
  - overall
  - checks_total / checks_pass / checks_fail
  - runtime_implementation_id:
    igniter.delegated.experimental.vm.rust-tokio.v0
  - evidence_class:
    proof_local_vm_candidate_evidence
  - authority_status
  - non_claims
  - capability_surface
  - command_matrix
  - proof_matrix
  - closed_surface_scan
  - skipped_or_classified_surfaces
- Required proof matrix:
  - VMG-1 runtime_implementation_id present in proof-local summary metadata
  - VMG-2 evidence_class / authority_status / non_claims present
  - VMG-3 command matrix scoped to VM proof, no daemon/server side effects
  - VMG-4 Decimal add/sub/mul/div delegation parity with R238 dependency
    context
  - VMG-5 AOT compiler lowering evidence
  - VMG-6 stack/register execution evidence
  - VMG-7 selected branch evidence
  - VMG-8 non-selected branch silence evidence: false condition selects else
    branch, then branch is not executed, and then branch emits no observation
  - VMG-9 unsupported selected-path fail-closed evidence
  - VMG-10 malformed input / unknown opcode behavior evidence
  - VMG-11 OP_LOAD_AS_OF / observation trace evidence using only
    "hash-based trace identifier" wording
  - VMG-12 map-reduce aggregate evidence
  - VMG-13 reactive/tbackend surface kept classified or explicitly skipped
  - VMG-14 closed-surface scan
  - VMG-15 no public/stable/reference/performance/portability claims
- Required commands:
  - cargo test --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml
    --test vm_tests
  - cargo test --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml
    --lib
  - ruby playgrounds/igniter-lab/igniter-vm/proofs/
    vm_candidate_proof.rb
  - if a new Rust proof test is added:
    cargo test --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml
    --test vm_candidate_proof_tests
- Do not run:
  - full cargo test
  - reactive_tests
  - cargo run
  - release build
  - server / daemon / listener commands
  - tbackend startup

Deliver:
- Proof track doc in `igniter-lang/docs/tracks/`
- Proof script/tests/result packet under `playgrounds/igniter-lab/igniter-vm/`
- Compact [D]/[S]/[T]/[R] summary
- Exact C4-A recommendation
```
