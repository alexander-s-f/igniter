# Delegated Experimental Runtime IVM FFI Bytecode Acceleration Acceptance Decision v0

Card: S3-R227-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-acceptance-decision-v0
Route: UPDATE
Status: accepted / aot-bytecode-file-loading-authorization-next
Date: 2026-06-01

Depends on:
- S3-R227-C2-I
- S3-R227-C3-X

---

## Decision

Accept the playground-only IVM FFI bytecode acceleration research proof.

Accepted evidence class:

```text
native acceleration research evidence only
delegated experimental runtime evidence only
playground-only non-canonical evidence
```

Not accepted:

```text
Reference Runtime support
public runtime support
production runtime support
stable API
igc run
RuntimeSmoke productization
mainline runtime/API/CLI/package changes
public performance claims
release evidence
```

Next route:

```text
S3-R228-C1-A
delegated-experimental-runtime-ivm-aot-bytecode-file-loading-authorization-review-v0
```

This is an authorization review only. It may decide whether a playground-only
AOT bytecode file loading proof may begin. It does not itself authorize
implementation.

---

## Inputs Read

- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-authorization-review-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-proof-v0.md`
- `igniter-lang/docs/discussions/delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-pressure-v0.md`
- `playgrounds/igniter-runtime/out/ivm_ffi_bytecode_acceleration_proof/summary.json`
- `igniter-lang/docs/tracks/stage3-round226-status-curation-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-adapter-branch-coverage-acceptance-decision-v0.md`
- `playgrounds/igniter-runtime/examples/ivm_ffi_bytecode_acceleration_proof.rb`
- `playgrounds/igniter-runtime/lib/ivm/runner.c`

Local verification run during C4-A:

```text
ruby -c playgrounds/igniter-runtime/examples/ivm_ffi_bytecode_acceleration_proof.rb
=> Syntax OK

ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/ivm_ffi_bytecode_acceleration_proof.rb
=> PASS; FFI 16/16

ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/ivm_adapter_branch_coverage_proof.rb
=> PASS; BCP 15/15

git diff --check
=> PASS

git status --short
=> clean

git -C playgrounds/igniter-runtime status --short
=> clean
```

Local timing values are noisy and regenerated on each proof run. The accepted
benchmark record remains the C2-I summary packet, not a public performance
claim.

---

## Exact Changed Files Accepted

Mainline tracked files accepted from R227:

```text
igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-authorization-review-v0.md
igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-proof-v0.md
igniter-lang/docs/discussions/delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-pressure-v0.md
igniter-lang/docs/discussions/README.md
```

Playground nested repo accepted from C2-I:

```text
playgrounds/igniter-runtime/examples/ivm_ffi_bytecode_acceleration_proof.rb
playgrounds/igniter-runtime/lib/ivm/runner.c
playgrounds/igniter-runtime/out/ivm_ffi_bytecode_acceleration_proof/librunner.dylib
playgrounds/igniter-runtime/out/ivm_ffi_bytecode_acceleration_proof/summary.json
```

Playground nested commit accepted:

```text
31d15c2 Introduce FFI-based native bytecode acceleration proof with parity validation, experimental runtime benchmarks, and ABI boundary definition
```

Scope note:

```text
The playground nested repo remains sandbox evidence only. The durable Main
Line decision record is the mainline track/discussion docs and this decision.
```

---

## Command Matrix Result

Accepted command matrix:

```text
ruby -c playgrounds/igniter-runtime/examples/ivm_ffi_bytecode_acceleration_proof.rb
=> Syntax OK

ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/ivm_ffi_bytecode_acceleration_proof.rb
=> PASS; 16/16 FFI checks

ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/ivm_adapter_branch_coverage_proof.rb
=> PASS; 15/15 BCP checks

git diff --check
=> PASS

git status --short
=> clean

git -C playgrounds/igniter-runtime status --short
=> clean
```

C2-I also recorded:

```text
rake spec
=> 686 examples, 0 failures
```

That full suite was accepted from the C2-I packet; it was not rerun in C4-A.

---

## FFI Result Record

| Check | Result | Acceptance note |
| --- | --- | --- |
| FFI-1 | PASS | `cc` built `librunner.dylib` under playground `out/`. |
| FFI-2 | PASS | Native boundary and 8-byte instruction ABI documented. |
| FFI-3 | PASS | Native runner loads through Ruby Fiddle without mainline changes. |
| FFI-4 | PASS | Add parity: Ruby IVM and native runner both return `42`. |
| FFI-5 | PASS | GT true parity: Ruby `true`; native `1`. |
| FFI-6 | PASS | GT false parity: Ruby `false`; native `0`. |
| FFI-7 | PASS | Selected branch parity: both return `42`. |
| FFI-8 | PASS | Non-selected branch silence parity: both return `99`. |
| FFI-9 | PASS | Unsupported selected path fails closed with native error code `3`. |
| FFI-10 | PASS | Unsupported non-selected path is jumped over and returns `100`. |
| FFI-11 | PASS | Malformed bytecode / null ABI input fails closed with error code `6`. |
| FFI-12 | PASS | Benchmark wording is local/informational only. |
| FFI-13 | PASS | R226 branch coverage proof remains green. |
| FFI-14 | PASS | Accepted R223/R225/R226 evidence is not rewritten. |
| FFI-15 | PASS | Closed surfaces remain unchanged. |
| FFI-16 | PASS | No Reference Runtime, public runtime, stable API, production, Spark, release, or `igc run` claims. |

Accepted proof status:

```text
16/16 PASS
```

---

## Evidence Record

Native boundary / ABI status:

```text
Ruby Fiddle + Native C dylib/so
proof-local narrow 8-byte instruction + flat int32 stack/slots
typedef struct { int32_t opcode; int32_t arg; } Instruction
execute_bytecode(instructions, count, inputs, error_code) -> int32_t
```

Toolchain/build status:

```text
compiler: cc
artifact: playgrounds/igniter-runtime/out/ivm_ffi_bytecode_acceleration_proof/librunner.dylib
build_success: true
```

Ruby IVM parity status:

```text
verified_correctness_parity
Add: 42 / 42
GT true: true / 1
GT false: false / 0
selected branch: 42 / 42
non-selected branch: 99 / 99
```

Unsupported behavior status:

```text
selected unsupported path: native error code 3; fail closed
non-selected unsupported path: jumped over; returns 100
malformed ABI input: native error code 6; fail closed
```

Benchmark wording status:

```text
accepted as informational proof-local timing only
accepted C2-I summary: 20,000 iterations, 1,000 warmup,
Ruby IVM 0.0158s, native FFI 0.0131s, rough_speedup_x 1.2
no public performance claim
```

Accepted evidence immutability status:

```text
R223/R225/R226 evidence preserved
R226 branch coverage proof rerun PASS 15/15
```

Closed-surface scan status:

```text
igniter-lang/lib/**: unchanged
bin/igc: unchanged
gemspec/package: unchanged
README/public docs: unchanged
RuntimeSmoke: unchanged
CompilerResult / CompilationReport: unchanged
release surfaces: unchanged
```

---

## Explicit Answers

Whether native acceleration research proof is accepted:

```text
Yes. Accepted.
```

Whether generated output may be called native acceleration research evidence
only:

```text
Yes. Generated output may be called native acceleration research evidence only
and delegated experimental runtime evidence only.
```

Whether this is Reference Runtime support:

```text
No. It is not Reference Runtime support.
```

Whether this is public runtime support:

```text
No. It is not public runtime support.
```

Whether this creates public performance claims:

```text
No. Timing data is accepted only as local informational research measurement.
```

Whether `igc run` remains closed:

```text
Yes. `igc run` remains closed.
```

Whether RuntimeSmoke productization remains closed:

```text
Yes. RuntimeSmoke source, result shape, and productization remain closed.
```

Whether reusable helper extraction opens next or remains closed:

```text
Reusable helper extraction remains closed for the next card. It remains useful
for TTEU/developer ergonomics, but the immediate next route continues runtime
execution depth toward file-backed native bytecode.
```

Whether Runtime Specification input slice opens next or remains closed:

```text
Runtime Specification input slice remains closed for the next card. It remains
important after the file-backed native execution question is answered.
```

Whether stable API, production, public demo, Spark, and release claims remain
closed:

```text
Yes. All remain closed.
```

What next route should open:

```text
S3-R228-C1-A
delegated-experimental-runtime-ivm-aot-bytecode-file-loading-authorization-review-v0
```

---

## Next Route Rationale

R227 proves native execution through Fiddle, but the C2-I and C3-X packets both
identify the same bottleneck:

```text
FFI transition and per-run serialization overhead obscure the value of native
execution.
```

The smallest next runtime-productization question is therefore:

```text
Can a native runner load a proof-local AOT bytecode file directly from disk and
execute it with Ruby IVM parity?
```

This route is chosen over reusable helper extraction and Runtime Specification
input slice for now because it is the shortest continuation toward
experimental executable runtime without mainline authority. The deferrals are
explicit, not forgotten:

- reusable helper extraction remains the next TTEU/developer ergonomics route;
- Runtime Specification input slice remains the next normative capture route;
- neither is authorized in this decision.

---

## Next Dispatch Recommendation

```text
Card: S3-R228-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: delegated-experimental-runtime-ivm-aot-bytecode-file-loading-authorization-review-v0

Route: UPDATE
Depends on:
- S3-R227-C5-S

Goal:
Decide whether a bounded playground-only AOT bytecode file loading proof may
begin, now that FFI native execution parity is accepted.

Scope:
- Read:
  - igniter-lang/docs/tracks/stage3-round227-status-curation-v0.md
  - igniter-lang/docs/tracks/
    delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-acceptance-decision-v0.md
  - igniter-lang/docs/tracks/
    delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-proof-v0.md
  - igniter-lang/docs/discussions/
    delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-pressure-v0.md
  - playgrounds/igniter-runtime/examples/ivm_ffi_bytecode_acceleration_proof.rb
  - playgrounds/igniter-runtime/lib/ivm/runner.c
  - playgrounds/igniter-runtime/out/ivm_ffi_bytecode_acceleration_proof/
    summary.json
- Decide:
  - authorize bounded playground-only AOT bytecode file loading proof;
  - authorize only design/prep;
  - hold pending binary format / file safety clarification;
  - redirect to reusable helper extraction authorization review;
  - redirect to Runtime Specification input slice;
  - pause.
- If authorizing a proof, define exact:
  - allowed write scope;
  - `.igbin` / bytecode-file format policy;
  - file read safety policy;
  - native runner file-loading boundary;
  - Ruby IVM parity matrix;
  - branch/lazy semantics matrix;
  - unsupported/malformed file behavior matrix;
  - benchmark wording policy;
  - no-authority wording;
  - closed surfaces.
- Must explicitly answer:
  - whether C2-I may begin in that round;
  - whether writes under `playgrounds/igniter-runtime/**` are enough;
  - whether `.igbin` or equivalent proof-local bytecode files may be produced
    under playground `out/`;
  - whether native file loading remains delegated experimental evidence only;
  - whether `igniter-lang/lib/**`, `bin/igc`, gemspec, README, public docs,
    RuntimeSmoke, CompilerResult, and CompilationReport remain closed;
  - whether Reference Runtime, public runtime support, `igc run`, stable API,
    production, Spark, release, and public performance claims remain closed.

Do not:
- implement file loading in this card;
- authorize mainline runtime/API/CLI/package changes;
- authorize public runtime support;
- authorize Reference Runtime implementation;
- authorize RuntimeSmoke productization;
- authorize release execution or public claims.

Deliver:
- Authorization decision doc in `igniter-lang/docs/tracks/`
- Compact decision summary
- If authorized: exact proof boundary
- If held/redirected: blocker list
```

---

## Closed Surfaces

Remain closed after this decision:

- `igniter-lang/lib/**`;
- `igniter-lang/bin/igc`;
- `igniter-lang/igniter_lang.gemspec`;
- README/public docs/body spec edits;
- RuntimeSmoke productization;
- `CompilerResult` / `CompilationReport` / report / receipt / cache authority;
- public API/CLI widening;
- `igc run`;
- Reference Runtime implementation;
- Runtime Specification implementation;
- reusable helper extraction implementation;
- AOT file loading implementation until a later card explicitly authorizes it;
- stable API or v1 compatibility claim;
- production readiness claim;
- public demo/support/all-grammar claim;
- public performance claim;
- Spark authority or integration;
- release execution, publish/yank/tag/push/deploy.
