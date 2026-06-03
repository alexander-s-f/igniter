# Experimental Igniter VM Candidate Intake Authorization Review v0

Card: S3-R239-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igniter-vm-candidate-intake-authorization-review-v0
Route: UPDATE
Status: authorized
Date: 2026-06-03

Depends on:
- S3-R238-C4-A

---

## Decision

Authorize bounded read-only / proof-local `igniter-vm` candidate intake.

Authorized next card:

```text
S3-R239-C2-P1
experimental-igniter-vm-candidate-surface-facts-v0
```

Route type:

```text
facts packet / candidate intake
not implementation
not runtime productization
not public runtime support
not Reference Runtime support
```

Reason:

```text
R238 accepted proof-local stdlib candidate evidence.
R238 explicitly sequenced VM intake next.
playgrounds/igniter-lab/igniter-vm has enough discoverable surface for intake:
Cargo crate, lib/bin split, VM execution core, AOT compiler, bytecode opcodes,
stdlib path dependency, temporal backend adapters, and VM tests.
```

This authorization does not accept `igniter-vm` as runtime support. It only
allows a compact facts packet to classify evidence, gaps, and authority
boundaries.

---

## Inputs Read

```text
igniter-lang/docs/tracks/stage3-round238-status-curation-v0.md
igniter-lang/docs/tracks/
  experimental-stdlib-candidate-proof-acceptance-decision-v0.md
igniter-lang/docs/tracks/experimental-stdlib-candidate-proof-v0.md
playgrounds/igniter-lab/igniter-stdlib/out/
  stdlib_candidate_proof/summary.json
playgrounds/igniter-lab/igniter-vm/Cargo.toml
playgrounds/igniter-lab/igniter-vm/Cargo.lock
playgrounds/igniter-lab/igniter-vm/README.md
playgrounds/igniter-lab/igniter-vm/src/lib.rs
playgrounds/igniter-lab/igniter-vm/src/main.rs
playgrounds/igniter-lab/igniter-vm/src/vm.rs
playgrounds/igniter-lab/igniter-vm/src/compiler.rs
playgrounds/igniter-lab/igniter-vm/src/instructions.rs
playgrounds/igniter-lab/igniter-vm/src/value.rs
playgrounds/igniter-lab/igniter-vm/src/tbackend.rs
playgrounds/igniter-lab/igniter-vm/tests/vm_tests.rs
playgrounds/igniter-lab/igniter-vm/tests/reactive_tests.rs
```

---

## Compact Decision Summary

```text
C2-P1 may begin: yes
VM candidate intake: authorized
write VM source: no
write mainline code/docs outside facts doc: no
R238 stdlib proof citation: allowed as dependency context only
adjacent frontier/conformance artifacts: excluded
VM command execution: narrowly allowed
igc run Slice 1: held
public/runtime/reference/stable/performance claims: closed
```

---

## C2-P1 Boundary

Card:

```text
S3-R239-C2-P1
```

Agent:

```text
[Implementation Surface Surveyor]
```

Track:

```text
experimental-igniter-vm-candidate-surface-facts-v0
```

Allowed write scope:

```text
igniter-lang/docs/tracks/
  experimental-igniter-vm-candidate-surface-facts-v0.md
```

Allowed transient build-output scope, only if produced by authorized Cargo
commands:

```text
playgrounds/igniter-lab/igniter-vm/target/**
```

Transient build output is not accepted evidence source, not authority, and must
not be committed unless a later card explicitly authorizes it.

Read-only source scope:

```text
playgrounds/igniter-lab/igniter-vm/**
playgrounds/igniter-lab/igniter-stdlib/**
igniter-lang/docs/tracks/stage3-round238-status-curation-v0.md
igniter-lang/docs/tracks/
  experimental-stdlib-candidate-proof-acceptance-decision-v0.md
igniter-lang/docs/tracks/experimental-stdlib-candidate-proof-v0.md
```

Closed unless separately authorized:

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
playgrounds/igniter-lab/igniter-vm/src/**
playgrounds/igniter-lab/igniter-vm/tests/**
playgrounds/igniter-lab/igniter-vm/Cargo.toml
playgrounds/igniter-lab/igniter-vm/Cargo.lock
```

The VM source paths are closed to editing but open to read-only inspection.

---

## Command Matrix Authorization

Authorized:

```text
cargo test --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml \
  --test vm_tests

cargo test --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml \
  --lib
```

Allowed if Surveyor needs dependency/package shape only:

```text
cargo metadata --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml \
  --no-deps
```

Not authorized in C2-P1:

```text
cargo test --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml
cargo run --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml
cargo build --release --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml
playgrounds/igniter-lab/igniter-vm/tests/reactive_tests.rs execution
any command that starts tbackend, a listener, a daemon, or a long-running server
```

Rationale:

```text
tests/reactive_tests.rs starts an external tbackend binary through an absolute
path and opens local ports. That surface is useful to classify, but it is not
part of the read-only VM candidate intake command matrix.
```

---

## Required C2-P1 Facts

C2-P1 must classify:

```text
crate/package shape
lib/bin split
VM instruction set and execution model
AOT compiler input shape
stdlib path dependency and dependency on R238 evidence
runtime_implementation_id / capability manifest presence or absence
input artifact expectations
output/result shape if any
lazy branch / selected branch behavior evidence
unsupported operation / fail-closed behavior
temporal backend surface
reactive pipeline surface, read-only classification only
relationship to artifact passport minimum fields
relationship to igc run Slice 0 and Slice 1 readiness
public/stable/performance wording risk
```

Support/gap matrix should separate:

```text
accepted dependency evidence from R238
VM candidate evidence found in lab
unverified or unrun reactive/backend behavior
missing capability/passport metadata
future proof-local VM proof candidates
```

---

## Evidence / Authority Stance

`igniter-vm` may be named in C2-P1 as:

```text
delegated experimental VM candidate
lab candidate evidence
proof-local candidate intake surface
```

It must not be named as:

```text
Reference Runtime
Official Reference Implementation
public runtime support
stable runtime API
production runtime
portable runtime target
certified alternative implementation
performance-proven runtime
```

Generated C2-P1 output may be called:

```text
VM candidate intake evidence only
```

It may not be called:

```text
runtime support evidence
Reference Runtime evidence
public API evidence
portability evidence
release evidence
public performance evidence
```

---

## Stdlib Dependency Citation Policy

R238 stdlib proof evidence may be cited as dependency context:

```text
Decimal FFI add/sub/mul/div proof-local evidence
OOF-TC5 / OOF-DM2 proof-local evidence
collections internal Rust-only classification
temporal domain-specific helper classification
stdlib/*.ig design-pressure-only classification
```

R238 evidence may not be promoted to:

```text
mainline stdlib replacement
public stdlib API
runtime authority
portability guarantee
```

---

## Adjacent Frontier / Conformance Exclusion

Adjacent frontier/conformance artifacts remain outside this route:

```text
igniter-lang/tests/conformance/conformance_runner.rb
igniter-lang/experiments/polymorphic_traits_proof/**
igniter-lang/experiments/nested_associated_types_proof/**
igniter-lang/source/nested_associated.ig
igniter-lang/out/conformance/**
```

Status:

```text
not accepted by R239-C1-A
not rejected by R239-C1-A
not ratified by R239-C1-A
must not be cited as VM candidate intake evidence
may be routed later through a separate frontier/conformance boundary
```

---

## Explicit Answers

Whether C2-P1 may begin:

```text
yes.
```

Whether writes under `playgrounds/igniter-lab/igniter-vm/**` are allowed:

```text
No source, README, Cargo, test, example, or proof edits are allowed.
Only transient Cargo build output under igniter-vm/target/** is allowed if
created by the authorized command matrix.
```

Whether the mainline facts track doc may be written:

```text
yes:
igniter-lang/docs/tracks/
  experimental-igniter-vm-candidate-surface-facts-v0.md
```

Whether VM commands may be run:

```text
yes, narrowly. VM-only cargo tests and metadata are allowed. Full cargo test,
reactive_tests execution, cargo run, release builds, server/daemon/listener
commands, and tbackend startup are not authorized.
```

Whether R238 stdlib proof evidence may be cited as dependency context:

```text
yes, dependency context only.
```

Whether adjacent frontier/conformance artifacts remain excluded:

```text
yes.
```

Whether generated output may be called VM candidate intake evidence only:

```text
yes.
```

Whether `igniter-lang/lib/**`, `bin/igc`, gemspec, README, public docs,
RuntimeSmoke, CompilerResult, or CompilationReport may be edited:

```text
no.
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

## Exact C2-P1 Dispatch

```text
Card: S3-R239-C2-P1
Skill: IDD Agent Protocol
Agent: [Implementation Surface Surveyor]
Role: implementation-surface-surveyor
Track: experimental-igniter-vm-candidate-surface-facts-v0

Route: REVIEW
Depends on:
- S3-R239-C1-A

Goal:
Produce a compact facts packet for `playgrounds/igniter-lab/igniter-vm` as a
delegated experimental VM candidate, preserving evidence-only status and
leaving all runtime/API/CLI/package/public authority closed.

Scope:
- Read:
  - S3-R239-C1-A authorization decision
  - igniter-lang/docs/tracks/stage3-round238-status-curation-v0.md
  - igniter-lang/docs/tracks/
    experimental-stdlib-candidate-proof-acceptance-decision-v0.md
  - igniter-lang/docs/tracks/experimental-stdlib-candidate-proof-v0.md
  - playgrounds/igniter-lab/igniter-stdlib/out/
    stdlib_candidate_proof/summary.json
  - playgrounds/igniter-lab/igniter-vm/Cargo.toml
  - playgrounds/igniter-lab/igniter-vm/Cargo.lock
  - playgrounds/igniter-lab/igniter-vm/README.md
  - playgrounds/igniter-lab/igniter-vm/src/**
  - playgrounds/igniter-lab/igniter-vm/tests/**
- Review:
  - crate/package shape;
  - VM instruction / execution model;
  - AOT compiler input shape;
  - stdlib dependency surface;
  - runtime_implementation_id and capability manifest status if present;
  - input artifact expectations;
  - output/result shape if present;
  - lazy branch / selected-branch behavior evidence;
  - unsupported operation and malformed input behavior;
  - temporal backend and reactive pipeline surface;
  - relationship to R238 stdlib candidate proof;
  - relationship to artifact passport minimum fields;
  - relationship to `igc run` Slice 0 and Slice 1 readiness;
  - public/stable/performance wording risk.
- Commands:
  - cargo test --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml
    --test vm_tests
  - cargo test --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml
    --lib
  - optional:
    cargo metadata --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml
    --no-deps
  - do not run full cargo test, reactive_tests, cargo run, release builds,
    servers, daemons, listeners, package publish commands, or destructive
    commands.
- Produce:
  - support/gap matrix;
  - command matrix with exact pass/fail/skipped results;
  - evidence-vs-authority classification;
  - closed-surface scan;
  - recommendation for C4-A.

Explicitly answer:
- whether `igniter-vm` is intake-ready as candidate evidence;
- whether it depends on accepted stdlib candidate proof evidence;
- whether it provides enough evidence for later proof-local VM proof
  authorization review;
- whether it creates runtime/public/reference/stable/production authority;
- whether `igc run` Slice 1 should remain held;
- whether frontier/conformance adjacent artifacts were excluded;
- whether public/stable/production/Reference Runtime/Spark/release/
  performance/portability claims remain closed.

Do not:
- edit lab code;
- edit mainline code;
- authorize implementation;
- authorize runtime/API/CLI/package changes;
- authorize `igc run` widening;
- authorize `.igbin` execution;
- authorize compiler passport emission;
- authorize RuntimeSmoke productization;
- authorize public runtime support;
- authorize Reference Runtime support;
- authorize stable API, production, Spark, release, public performance,
  official/reference status, alternative certification, or portability
  guarantees.

Deliver:
- Facts packet in `igniter-lang/docs/tracks/
  experimental-igniter-vm-candidate-surface-facts-v0.md`
- Compact VM candidate support/gap matrix
- Exact C4-A recommendation
```
