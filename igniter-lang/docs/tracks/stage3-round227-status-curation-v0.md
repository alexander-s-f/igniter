# Stage 3 Round 227 Status Curation v0

Card: S3-R227-C5-S
Skill: IDD Agent Protocol
Agent: [Status Curator]
Role: status-curator
Track: stage3-round227-status-curation-v0
Route: SUMMARY
Status: done
Date: 2026-06-01

Depends on:
- S3-R227-C4-A

---

## Executive Summary

R227 is accepted as playground-only native acceleration research evidence.

The accepted proof shows that a proof-local C runner loaded through Ruby Fiddle
can execute a narrow IVM bytecode subset with Ruby IVM parity. This remains
delegated experimental runtime evidence only. It is not Reference Runtime
support, not `igc run`, not public runtime support, not stable API, not release
evidence, and not a public performance claim.

Exact next route:

```text
S3-R228-C1-A
delegated-experimental-runtime-ivm-aot-bytecode-file-loading-authorization-review-v0
```

This next route is authorization review only. It does not itself authorize
implementation.

---

## Inputs Read

- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-authorization-review-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-proof-v0.md`
- `igniter-lang/docs/discussions/delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-pressure-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-acceptance-decision-v0.md`
- `igniter-lang/docs/cards/S3/S3-R227.md`
- `igniter-lang/docs/current-status.md`

---

## Outcome Table

| Card | Status | Curated result |
| --- | --- | --- |
| S3-R227-C1-A | authorized | Opens bounded playground-only FFI/C/Rust native acceleration research proof; mainline runtime/API/CLI/package surfaces stay closed. |
| S3-R227-C2-I | done | FFI proof passes 16/16; C runner and Ruby Fiddle bridge prove native execution parity against Ruby IVM oracle. |
| S3-R227-C3-X | PASS | No blockers; AN-1 asks C4-A to choose AOT file loading vs reusable helper vs Runtime Specification input. |
| S3-R227-C4-A | accepted | Accepts native acceleration research evidence only; chooses AOT bytecode file loading authorization review next. |
| S3-R227-C5-S | done | Current status updated with compact R227 delta and R228 route. |

---

## Curated Status

Accepted / conditional / held status:

```text
accepted
```

Accepted evidence class:

```text
native acceleration research evidence only
delegated experimental runtime evidence only
playground-only non-canonical evidence
```

Native acceleration research evidence status:

```text
FFI-1..FFI-16 PASS
Native C runner built as playground-local librunner.dylib.
Ruby Fiddle loads the native runner without mainline changes.
R226 branch coverage regression remains PASS 15/15.
R223/R225/R226 evidence is not rewritten.
```

ABI/toolchain status:

```text
toolchain: cc
artifact: playgrounds/igniter-runtime/out/ivm_ffi_bytecode_acceleration_proof/librunner.dylib
ABI: proof-local 8-byte instruction { int32_t opcode; int32_t arg }
serialization: Ruby l<l< little-endian pack
signature: execute_bytecode(instructions, count, inputs, error_code) -> int32_t
```

Ruby IVM parity status:

```text
Add: Ruby 42 / native 42
GT true: Ruby true / native 1
GT false: Ruby false / native 0
selected branch: Ruby 42 / native 42
non-selected branch: Ruby 99 / native 99
selected unsupported path: native error code 3; fail closed
non-selected unsupported path: jumped over; returns 100
malformed ABI input: native error code 6; fail closed
```

Benchmark wording status:

```text
accepted as informational proof-local timing only
C2-I summary: 20,000 iterations, 1,000 warmup
Ruby IVM 0.0158s; native FFI 0.0131s; rough_speedup_x 1.2
Fiddle transition / per-run serialization overhead named as bottleneck
no public performance claim
```

Runtime-productization status:

```text
IVM delegated experimental candidate: accepted as playground-only candidate evidence.
Reusable helper extraction: closed for next card; remains useful later for TTEU/developer ergonomics.
Runtime Specification input: closed for next card; remains useful after file-backed native execution question.
CLI run: closed.
RuntimeSmoke: closed to productization/source/result-shape changes.
Reference Runtime: closed.
```

Stable/public/production/Spark/release status:

```text
stable API: closed
public runtime support: closed
production runtime support: closed
Spark authority/integration: closed
release evidence/execution: closed
public performance claims: closed
```

---

## Current Status Delta

`igniter-lang/docs/current-status.md` was updated with:

- R227 accepted native acceleration research evidence status;
- R228 AOT bytecode file loading authorization-review route;
- Round 227 card receipt.

No code, public docs, release artifacts, RuntimeSmoke, Reference Runtime,
`igc run`, compiler result/report, package metadata, or Spark surfaces were
edited or authorized.

---

## Exact Handoff

Next card boundary:

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
```

Required next-card guardrails:

```text
Authorization review only unless C1-A explicitly opens C2-I.
If proof is authorized, it must stay playground-only and evidence-only.
`.igbin` or equivalent bytecode files, if allowed, must be proof-local.
Native file loading must remain delegated experimental evidence only.
Reference Runtime, public runtime support, igc run, stable API, production,
Spark, release, and public performance claims remain closed unless a later
explicit decision changes them.
```
