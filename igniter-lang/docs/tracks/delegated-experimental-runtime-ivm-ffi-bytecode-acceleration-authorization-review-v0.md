# Delegated Experimental Runtime IVM FFI Bytecode Acceleration Authorization Review v0

Card: S3-R227-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-authorization-review-v0
Route: UPDATE
Status: authorized
Date: 2026-06-01

Depends on:
- S3-R226-C5-S

---

## Decision

Authorize a bounded playground-only IVM bytecode acceleration research proof.

Authorized evidence class:

```text
native acceleration research evidence only
delegated experimental runtime evidence only
playground-only non-canonical evidence
```

This authorization opens C2-I only. It does not authorize mainline runtime,
CLI, package, RuntimeSmoke, Reference Runtime, public runtime support, stable
API, production runtime support, public performance claims, or release work.

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round226-status-curation-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-adapter-branch-coverage-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-adapter-branch-coverage-proof-v0.md`
- `igniter-lang/docs/discussions/delegated-experimental-runtime-ivm-adapter-branch-coverage-pressure-v0.md`
- `playgrounds/igniter-runtime/examples/ivm_adapter_branch_coverage_proof.rb`
- `playgrounds/igniter-runtime/out/ivm_adapter_branch_coverage_proof/summary.json`
- `playgrounds/igniter-runtime/lib/ivm/instructions.rb`
- `playgrounds/igniter-runtime/lib/ivm/compiler.rb`
- `playgrounds/igniter-runtime/lib/ivm/vm.rb`

Toolchain availability observed before decision:

```text
clang: /usr/bin/clang
cc: /usr/bin/cc
rustc: /Users/alex/.cargo/bin/rustc
ruby fiddle: available
```

Repository status before decision:

```text
parent repo: clean
playgrounds/igniter-runtime nested repo: clean
```

---

## Rationale

R226 accepted adapter hardening:

```text
fresh minimal_if_else.ig -> fresh_if_else.igapp
fresh minimal_gt.ig -> fresh_gt.igapp
stdlib.integer.gt -> binary_op ">" -> OP_GT
selected branch verified executes
non-selected branch verified silent
unsupported selected path fails closed
unsupported non-selected path does not fire
BCP-1..BCP-15 PASS
```

The remaining market/runtime question is now sharper:

```text
Can the delegated IVM bytecode path escape Ruby-loop overhead without creating
mainline runtime authority?
```

That question is appropriate for a playground-only native acceleration proof.
It is not appropriate for direct mainline runtime productization.

---

## Authorized C2-I Boundary

```text
Card: S3-R227-C2-I
Skill: IDD Agent Protocol
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-proof-v0
Route: UPDATE
Depends on:
- S3-R227-C1-A
```

Allowed write scope:

```text
playgrounds/igniter-runtime/**
igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-proof-v0.md
```

Read-only / closed unless a later card explicitly opens them:

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
```

Build outputs may live only under:

```text
playgrounds/igniter-runtime/out/**
```

---

## Native Boundary Policy

Primary authorized path:

```text
Ruby IVM bytecode / fixtures
  -> proof-local bytecode ABI serialization
  -> native C shared library built under playground out/
  -> Ruby Fiddle bridge under playground proof
  -> native result compared with Ruby IVM oracle
```

Allowed implementation shape:

- C source/header files under `playgrounds/igniter-runtime/**`;
- Ruby Fiddle bridge inside the proof harness;
- compiled shared library under `playgrounds/igniter-runtime/out/**`;
- Ruby-only serializer/deserializer under playground proof files;
- optional Rust secondary runner only if it requires no network dependencies
  and remains entirely under `playgrounds/igniter-runtime/**`.

Preferred path:

```text
C + clang/cc + Ruby Fiddle
```

Rust is allowed as an optional secondary comparison path, not as a requirement.
If C/Fiddle is sufficient, do not add Rust.

Not authorized:

- root require exposure;
- gemspec/package dependency changes;
- mainline runtime loader;
- CLI `igc run`;
- RuntimeSmoke integration;
- Reference Runtime implementation.

---

## Bytecode ABI / IO Policy

C2-I must define a proof-local ABI. It may be simple and narrow.

Recommended minimum:

```text
instructions: flat opcode + integer/string-slot operands
inputs: small integer/bool slot table
output: tagged scalar result
errors: tagged local error code
```

Required semantics:

- `PUSH_LIT`;
- `LOAD_REF`;
- `ADD`;
- `GT`;
- `JMP`;
- `JMP_UNLESS`;
- `RET`;
- `UNSUPPORTED`, or an equivalent fail-closed marker.

The ABI is not canonical and must be labeled:

```text
proof-local ABI
non-canonical
not public API
not stable
```

---

## Benchmark Policy

Benchmarking is allowed only as local research measurement.

Allowed wording:

```text
local measurement
proof-local timing
rough comparison
research signal
```

Forbidden wording:

```text
production performance
public performance claim
benchmark guarantee
fast enough for users
Reference Runtime performance
```

C2-I must record enough context for any measurement:

- hardware/runtime context if cheap to capture;
- iteration count;
- Ruby IVM timing;
- native timing;
- whether warmup was used;
- whether timings are noisy or informational only.

Benchmark failure or noisy results should not fail correctness proof if parity
passes and wording stays honest.

---

## Required Proof Matrix

C2-I must report FFI-1..FFI-16:

| Check | Requirement |
| --- | --- |
| FFI-1 | Toolchain/build capability detected and recorded, or exact HOLD blocker recorded. |
| FFI-2 | Native boundary and bytecode ABI/input/output shape documented. |
| FFI-3 | Native runner loads or receives bytecode without mainline changes. |
| FFI-4 | Add parity: Ruby IVM and native runner return the same value. |
| FFI-5 | GT true parity: Ruby IVM and native runner return true. |
| FFI-6 | GT false parity: Ruby IVM and native runner return false. |
| FFI-7 | Selected branch parity: selected branch executes. |
| FFI-8 | Non-selected branch silence parity: unselected branch does not fire. |
| FFI-9 | Unsupported selected path fails closed or is explicitly rejected. |
| FFI-10 | Unsupported non-selected path does not fire when jumped over. |
| FFI-11 | Malformed bytecode/ABI input fails closed. |
| FFI-12 | Local benchmark measurement captured without public performance wording. |
| FFI-13 | R226 branch coverage proof still passes or is recorded as read-only regression. |
| FFI-14 | No accepted R223/R225/R226 evidence is rewritten. |
| FFI-15 | Closed surfaces remain unchanged. |
| FFI-16 | No Reference Runtime, public runtime, stable API, production, Spark, release, or `igc run` claims. |

If native toolchain invocation is blocked by local environment, C2-I may return
HOLD with FFI-1 blocker evidence and should not simulate a native path.

---

## Required Command Matrix

C2-I must run and report:

```text
ruby -c playgrounds/igniter-runtime/examples/ivm_ffi_bytecode_acceleration_proof.rb
ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/ivm_ffi_bytecode_acceleration_proof.rb
ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/ivm_adapter_branch_coverage_proof.rb
git diff --check
git status --short
git -C playgrounds/igniter-runtime status --short
```

If the native build command is not embedded in the Ruby proof harness, the
exact build command must also be listed and reported.

Optional regression:

```text
rake spec
```

---

## Result Packet Shape

C2-I must deliver:

- proof track doc in `igniter-lang/docs/tracks/`;
- playground proof script and native files under `playgrounds/igniter-runtime/**`;
- summary/result JSON under playground `out/**`;
- compact `[D] [S] [T] [R] [Next]` packet;
- exact native boundary / ABI / support matrix;
- exact command matrix result;
- exact benchmark wording and non-claims.

Summary JSON should include at minimum:

```text
kind
card
track
overall
evidence_class
native_boundary
abi_policy
toolchain
native_artifact_path_or_null
ruby_ivm_oracle_status
parity_status
benchmark_policy
benchmark_results
supported_opcodes
unsupported_policy
closed_surface_scan
non_claims
checks
```

---

## Explicit Answers

Whether C2-I may begin in this round:

```text
Yes. C2-I may begin under the bounded playground-only authorization above.
```

Whether writes under `playgrounds/igniter-runtime/**` are enough:

```text
Yes. They are sufficient and are the only implementation write surface
authorized for native acceleration research.
```

Whether native/C/Rust files may be added under playground only:

```text
Yes. Native C files may be added under playground only. Rust files may be added
only as an optional secondary runner if no network dependency or mainline
surface is introduced. The preferred path is C + clang/cc + Ruby Fiddle.
```

Whether build outputs may live under playground `out/`:

```text
Yes. Build outputs may live only under playgrounds/igniter-runtime/out/**.
```

Whether any `igniter-lang/lib/**`, `bin/igc`, gemspec, README, public docs,
RuntimeSmoke, CompilerResult, or CompilationReport edits are allowed:

```text
No. They remain closed.
```

Whether accelerated execution remains delegated experimental evidence only:

```text
Yes. Any accelerated execution result remains native acceleration research
evidence only and delegated experimental runtime evidence only.
```

Whether Reference Runtime, public runtime support, `igc run`, stable API,
production, Spark, and release claims remain closed:

```text
Yes. All remain closed.
```

---

## Non-Claims

This authorization does not create or imply:

- Reference Runtime support;
- public runtime support;
- production runtime support;
- public performance claims;
- stable API or v1 compatibility;
- public demo support;
- Spark integration;
- package/gemspec surface;
- CLI `igc run`;
- RuntimeSmoke productization;
- report/result/receipt/cache authority;
- release evidence or release execution.

---

## C2-I Dispatch

```text
Card: S3-R227-C2-I
Skill: IDD Agent Protocol
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-proof-v0

Route: UPDATE
Depends on:
- S3-R227-C1-A

Goal:
Run the authorized playground-only native bytecode acceleration research proof:
define proof-local ABI, build a native runner if local toolchain permits,
compare native execution with Ruby IVM oracle, preserve lazy branch and
unsupported-node behavior, capture local benchmark measurements, and keep all
outputs as delegated experimental evidence only.

Allowed write scope:
- playgrounds/igniter-runtime/**
- igniter-lang/docs/tracks/
  delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-proof-v0.md

Required command matrix:
- ruby -c playgrounds/igniter-runtime/examples/
  ivm_ffi_bytecode_acceleration_proof.rb
- ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/
  ivm_ffi_bytecode_acceleration_proof.rb
- ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/
  ivm_adapter_branch_coverage_proof.rb
- git diff --check
- git status --short
- git -C playgrounds/igniter-runtime status --short

Deliver:
- proof track doc
- playground proof files and summary/result JSON
- FFI-1..FFI-16 result
- native boundary / ABI / support matrix
- compact [D] [S] [T] [R] [Next] packet
```
