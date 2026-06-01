# Delegated Experimental Runtime IVM AOT Bytecode File Loading Acceptance Decision v0

Card: S3-R228-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: delegated-experimental-runtime-ivm-aot-bytecode-file-loading-acceptance-decision-v0
Route: UPDATE
Status: accepted / experimental-runtime-surface-design-next
Date: 2026-06-01

Depends on:
- S3-R228-C2-I
- S3-R228-C3-X

---

## Decision

Accept the playground-only IVM AOT bytecode file-loading proof.

Accepted evidence class:

```text
AOT bytecode file-loading research evidence only
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
igc run implementation
RuntimeSmoke productization
mainline runtime/API/CLI/package changes
report/result/receipt/cache authority
public performance claims
release evidence
Spark integration or authority
```

Next route after status curation:

```text
S3-R229-C1-D
experimental-executable-runtime-surface-and-igc-run-boundary-design-v0
```

This next route is design-only. It should move the lane toward experimental
executable use by deciding the pre-v1 runtime surface and `igc run` boundary
without authorizing implementation.

---

## Compact Decision Summary

```text
accepted
AOT-1..AOT-17 PASS
.igbin format accepted as proof-local/non-canonical only
native file loading accepted as delegated experimental evidence only
file-per-execution benchmark exposes I/O bottleneck; load-once/execute-many
  is the correct architectural signal
next route: experimental executable runtime surface / igc run boundary design
implementation remains closed
```

---

## Inputs Read

- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-aot-bytecode-file-loading-authorization-review-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-aot-bytecode-file-loading-proof-v0.md`
- `igniter-lang/docs/discussions/delegated-experimental-runtime-ivm-aot-bytecode-file-loading-pressure-v0.md`
- `playgrounds/igniter-runtime/out/ivm_aot_bytecode_file_loading_proof/summary.json`
- `igniter-lang/docs/tracks/stage3-round227-status-curation-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-acceptance-decision-v0.md`
- `playgrounds/igniter-runtime/examples/ivm_aot_bytecode_file_loading_proof.rb`
- `playgrounds/igniter-runtime/lib/ivm/runner.c`

Local read-only verification during C4-A:

```text
ruby -rjson -e '...' playgrounds/igniter-runtime/out/ivm_aot_bytecode_file_loading_proof/summary.json
=> PASS; 17 checks; all PASS

ruby -rjson -e '...' playgrounds/igniter-runtime/out/ivm_ffi_bytecode_acceleration_proof/summary.json
=> PASS; 16 checks; all PASS

ruby -c playgrounds/igniter-runtime/examples/ivm_aot_bytecode_file_loading_proof.rb
=> Syntax OK

git status --short
=> clean

git -C playgrounds/igniter-runtime status --short
=> clean
```

The full proof script was not rerun during C4-A because it rewrites timing and
summary evidence. C4-A accepts the C2-I/C3-X recorded proof outputs plus the
read-only validation above.

---

## Exact Changed Files Accepted

Mainline tracked files accepted from R228 C2/C3:

```text
igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-aot-bytecode-file-loading-proof-v0.md
igniter-lang/docs/discussions/delegated-experimental-runtime-ivm-aot-bytecode-file-loading-pressure-v0.md
igniter-lang/docs/discussions/README.md
```

Playground AOT evidence accepted from the R228 proof packet:

```text
playgrounds/igniter-runtime/examples/ivm_aot_bytecode_file_loading_proof.rb
playgrounds/igniter-runtime/out/ivm_aot_bytecode_file_loading_proof/add.igbin
playgrounds/igniter-runtime/out/ivm_aot_bytecode_file_loading_proof/gt.igbin
playgrounds/igniter-runtime/out/ivm_aot_bytecode_file_loading_proof/if.igbin
playgrounds/igniter-runtime/out/ivm_aot_bytecode_file_loading_proof/bad_header.igbin
playgrounds/igniter-runtime/out/ivm_aot_bytecode_file_loading_proof/bad_data.igbin
playgrounds/igniter-runtime/out/ivm_aot_bytecode_file_loading_proof/unsupported_sel.igbin
playgrounds/igniter-runtime/out/ivm_aot_bytecode_file_loading_proof/unsupported_unsel.igbin
playgrounds/igniter-runtime/out/ivm_aot_bytecode_file_loading_proof/timing_if.igbin
playgrounds/igniter-runtime/out/ivm_aot_bytecode_file_loading_proof/timing_warmup.igbin
playgrounds/igniter-runtime/out/ivm_aot_bytecode_file_loading_proof/librunner.dylib
playgrounds/igniter-runtime/out/ivm_aot_bytecode_file_loading_proof/summary.json
```

Playground runner acceptance boundary:

```text
The AOT file-loading subset of playgrounds/igniter-runtime/lib/ivm/runner.c is
accepted only as evidence for this R228 proof.
```

Out-of-scope playground artifacts observed during C4-A:

```text
playgrounds/igniter-runtime/docs/resident_native_supervisor_research_report.md
playgrounds/igniter-runtime/examples/ivm_resident_supervisor_proof.rb
playgrounds/igniter-runtime/out/ivm_resident_supervisor_proof/**
playgrounds/igniter-runtime/docs/c_temporal_backend_integration_research_report.md
playgrounds/igniter-runtime/docs/concurrency_and_embedded_esp32_mesh_research.md
playgrounds/igniter-runtime/examples/ivm_bitemporal_c_backend_proof.rb
playgrounds/igniter-runtime/out/ivm_bitemporal_c_backend_proof/**
additional temporal backend code now present in playground runner.c
```

Those later playground artifacts are not accepted by this card, not rejected by
this card, and not Main Line authority. They remain sandbox-only material that
requires a separate intake/decision before it can affect Main Line routing.

---

## Command Matrix Result

Accepted command matrix from C2-I/C3-X:

```text
ruby -c playgrounds/igniter-runtime/examples/ivm_aot_bytecode_file_loading_proof.rb
=> Syntax OK

ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/ivm_aot_bytecode_file_loading_proof.rb
=> PASS; 17/17 AOT checks

ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/ivm_ffi_bytecode_acceleration_proof.rb
=> PASS; 16/16 FFI checks

git diff --check
=> clean

git status --short
=> mainline clean

git -C playgrounds/igniter-runtime status --short
=> clean by C4-A time
```

C2-I also reported:

```text
rake spec
=> 686 examples, 0 failures
```

That full suite result is accepted from the C2-I packet; it was not rerun in
C4-A.

---

## AOT Result Record

| Check | Result | Acceptance note |
| --- | --- | --- |
| AOT-1 | PASS | `.igbin` format documented as 16-byte header plus 8-byte instruction records. |
| AOT-2 | PASS | Bytecode files produced under playground `out/` with digest evidence. |
| AOT-3 | PASS | Native runner loads bytecode from file without mainline changes. |
| AOT-4 | PASS | Add parity: file-backed native runner returns `42`. |
| AOT-5 | PASS | GT true parity: native returns `1`. |
| AOT-6 | PASS | GT false parity: native returns `0`. |
| AOT-7 | PASS | Selected branch executes and returns `42`. |
| AOT-8 | PASS | Non-selected branch remains silent and returns `99`. |
| AOT-9 | PASS | Unsupported selected path fails closed with error `3`. |
| AOT-10 | PASS | Unsupported non-selected path does not fire when jumped over. |
| AOT-11 | PASS | Bad magic, bad version, and truncated length fail closed. |
| AOT-12 | PASS | Invalid opcode and out-of-bounds jump fail closed. |
| AOT-13 | PASS | Benchmark wording remains local/informational only. |
| AOT-14 | PASS | R227 FFI proof remains PASS 16/16. |
| AOT-15 | PASS | Accepted R223/R225/R226/R227 evidence is not rewritten. |
| AOT-16 | PASS | Closed surfaces remain unchanged. |
| AOT-17 | PASS | No Reference Runtime, public runtime, stable API, production, Spark, release, `igc run`, or public performance claims. |

Accepted proof status:

```text
17/17 PASS
```

---

## Evidence Record

Bytecode file format status:

```text
extension: .igbin
header: 16 bytes
magic: IGB\0
version: 1
instruction record: int32 opcode + int32 arg
file length rule: exactly 16 + 8 * instruction_count
format authority: proof-local / non-canonical / not stable / not public API
```

Native file-loading status:

```text
Ruby Fiddle + native C file loader
execute_bytecode_file(filepath, inputs, error_code)
build artifact: playgrounds/igniter-runtime/out/ivm_aot_bytecode_file_loading_proof/librunner.dylib
```

Ruby IVM parity status:

```text
Add: 42
GT true: 1
GT false: 0
selected branch: 42
non-selected branch: 99
parity_status: verified_correctness_parity
```

Unsupported / malformed behavior status:

```text
unsupported selected path: error 3; fail closed
unsupported non-selected path: jumped over; returns 100
bad magic: error 11
bad version: error 12
truncated file length: error 14
invalid opcode: error 17
out-of-bounds jump: error 4
```

Benchmark wording status:

```text
accepted as informational proof-local timing only
iterations: 20,000
warmup: 1,000
Ruby IVM: 0.013832s
native file-backed execution: 0.196112s
rough_speed_ratio: 0.1
public performance claim: none
```

Research conclusion:

```text
File-per-execution is I/O-bound and slower than the Ruby IVM loop.
The architectural lesson is load-once / execute-many, not "native is faster"
as a public claim.
```

---

## Pressure Verdict Handling

C3-X verdict:

```text
PASS
No blockers
2 non-blocking acceptance notes
```

AN-1 accepted:

```text
Future acceleration proof summaries should restore machine-readable
closed_surface_scan and non_claims fields, matching R226/R227 summary shape.
```

AN-2 resolved:

```text
C4-A will not silently continue acceleration depth. It routes next to
experimental executable runtime surface / igc run boundary design.
```

Rationale for next route:

```text
R225-R228 have produced enough delegated runtime evidence to begin designing
the user-facing experimental executable surface. More native acceleration can
continue later, but productization sequencing now needs a boundary decision:
what can be exposed pre-v1, what remains playground-only, and how "igc run"
can be discussed without implementing or promising it yet.
```

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Is the AOT bytecode file-loading proof accepted? | Yes. |
| May generated output be called AOT bytecode file-loading research evidence only? | Yes. That wording is binding. |
| Is this Reference Runtime support? | No. |
| Is this public runtime support? | No. |
| Does this create public performance claims? | No. The timing result is local/informational and explicitly shows file-I/O overhead. |
| Does `igc run` remain closed? | Yes. Implementation remains closed. A design-only boundary route opens next. |
| Does RuntimeSmoke productization remain closed? | Yes. |
| Does reusable helper extraction open next? | No. It remains a viable later route, but C4-A chooses runtime surface design first. |
| Does Runtime Specification input slice open next? | No. It remains useful later and should be read by the next design route as context. |
| Do stable API, production, public demo, Spark, and release claims remain closed? | Yes. |
| What next route should open? | `S3-R229-C1-D experimental-executable-runtime-surface-and-igc-run-boundary-design-v0`. |

---

## Next Dispatch Recommendation

Status curation first:

```text
Card: S3-R228-C5-S
Skill: IDD Agent Protocol
Agent: [Status Curator]
Role: status-curator
Track: stage3-round228-status-curation-v0

Route: SUMMARY
Depends on:
- S3-R228-C4-A

Goal:
Curate R228 outcome and update Main Line status after the playground-only IVM
AOT bytecode file-loading acceptance decision.
```

Then open:

```text
Card: S3-R229-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-executable-runtime-surface-and-igc-run-boundary-design-v0

Route: UPDATE
Depends on:
- S3-R228-C5-S

Goal:
Design the pre-v1 experimental executable runtime surface after accepted R223
through R228 delegated runtime evidence, with special focus on whether and how
an experimental `igc run` boundary may be described later without authorizing
implementation, public runtime support, stable API, production readiness,
Reference Runtime, Spark integration, or release work.

Required scope:
- read R223-R228 acceptance/status docs;
- read current CLI/runtime surfaces;
- distinguish example-local helper, playground delegated runtime, RuntimeSmoke,
  Reference Runtime, and possible `igc run` surface;
- decide whether the next implementation authorization should target examples
  helper, docs quickstart, CLI design, or remain held;
- treat resident supervisor / temporal backend playground artifacts as
  unaccepted sandbox material unless separately intaken;
- preserve pre-v1 no-stable-API wording and all public non-claims.

Do not:
- implement code;
- authorize `igc run` implementation;
- authorize public runtime support;
- authorize Reference Runtime implementation;
- authorize RuntimeSmoke productization;
- authorize stable API, production, public demo, Spark, release, or public
  performance claims.
```
