# Stage 3 Round 228 Status Curation v0

Card: S3-R228-C5-S
Skill: IDD Agent Protocol
Agent: [Status Curator]
Role: status-curator
Track: stage3-round228-status-curation-v0
Route: SUMMARY
Status: done
Date: 2026-06-01

Depends on:
- S3-R228-C4-A

---

## Executive Summary

R228 is accepted as playground-only AOT bytecode file-loading research evidence.

The accepted proof shows that a proof-local `.igbin` bytecode file can be
loaded by the playground native runner and executed with Ruby IVM parity. The
result remains delegated experimental runtime evidence only. It is not
Reference Runtime support, not `igc run` implementation, not public runtime
support, not stable API, not release evidence, and not a public performance
claim.

Exact next route:

```text
S3-R229-C1-D
experimental-executable-runtime-surface-and-igc-run-boundary-design-v0
```

This next route is design-only. It moves the lane toward pre-v1 experimental
executable use without authorizing implementation.

---

## Inputs Read

- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-aot-bytecode-file-loading-authorization-review-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-aot-bytecode-file-loading-proof-v0.md`
- `igniter-lang/docs/discussions/delegated-experimental-runtime-ivm-aot-bytecode-file-loading-pressure-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-aot-bytecode-file-loading-acceptance-decision-v0.md`
- `igniter-lang/docs/cards/S3/S3-R228.md`
- `igniter-lang/docs/tracks/stage3-round227-status-curation-v0.md`
- `igniter-lang/docs/current-status.md`

---

## Outcome Table

| Card | Status | Curated result |
| --- | --- | --- |
| S3-R228-C1-A | authorized | Opens bounded playground-only AOT bytecode file-loading proof; `.igbin`/equivalent files allowed under playground `out/` only. |
| S3-R228-C2-I | done | AOT proof passes 17/17; `.igbin` file-backed native execution proves Ruby IVM parity and fail-closed malformed-file behavior. |
| S3-R228-C3-X | PASS | No blockers; AN-1 requests future summary JSON fields; AN-2 requires explicit direction away from silent infinite acceleration. |
| S3-R228-C4-A | accepted | Accepts AOT file-loading evidence only; routes next to experimental runtime surface / `igc run` boundary design. |
| S3-R228-C5-S | done | Current status updated with compact R228 delta and R229 route. |

---

## Curated Status

Accepted / conditional / held status:

```text
accepted
```

Accepted evidence class:

```text
AOT bytecode file-loading research evidence only
native acceleration research evidence only
delegated experimental runtime evidence only
playground-only non-canonical evidence
```

AOT bytecode file-loading research evidence status:

```text
AOT-1..AOT-17 PASS
R227 FFI proof remains PASS 16/16
R223/R225/R226/R227 evidence is not rewritten
closed surfaces remain unchanged
```

Bytecode file format status:

```text
extension: .igbin
header: 16 bytes
magic: IGB\0
version: 1
instruction record: int32 opcode + int32 arg
file length rule: exactly 16 + 8 * instruction_count
authority: proof-local / non-canonical / not stable / not public API
```

Native file-loading status:

```text
Ruby Fiddle + native C file loader
entrypoint: execute_bytecode_file(filepath, inputs, error_code)
artifact: playgrounds/igniter-runtime/out/ivm_aot_bytecode_file_loading_proof/librunner.dylib
all accepted .igbin fixtures live under playground out/
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

Malformed / unsupported behavior status:

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

Runtime-productization status:

```text
IVM delegated experimental candidate: accepted as playground-only candidate evidence.
Reusable helper extraction: closed for next card; remains viable later.
Runtime Specification input: closed for next card; remains useful later.
CLI run: implementation closed; design-only boundary route opens next.
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

## Pressure Notes Carried

AN-1:

```text
Future acceleration proof summaries should restore machine-readable
closed_surface_scan and non_claims fields, matching R226/R227 summary shape.
```

AN-2 resolution:

```text
C4-A does not silently continue acceleration depth. It chooses the
experimental executable runtime surface / igc run boundary design route next.
```

Out-of-scope playground artifacts observed by C4-A:

```text
Resident supervisor / temporal backend playground artifacts are not accepted
or rejected by R228. They remain sandbox-only material requiring separate
intake/decision before affecting Main Line routing.
```

---

## Current Status Delta

`igniter-lang/docs/current-status.md` was updated with:

- R228 accepted AOT file-loading evidence status;
- `.igbin` proof-local file format and native file-loading status;
- benchmark wording and file-I/O bottleneck conclusion;
- R229 experimental runtime surface / `igc run` design-only route;
- Round 228 card receipt.

No code, public docs, release artifacts, RuntimeSmoke, Reference Runtime,
`igc run` implementation, compiler result/report, package metadata, or Spark
surfaces were edited or authorized.

---

## Exact Handoff

Next card boundary:

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
```

Required next-card guardrails:

```text
Design-only.
No code implementation.
No igc run implementation authorization.
No public runtime support.
No Reference Runtime implementation.
No RuntimeSmoke productization.
No stable API, production, public demo, Spark, release, or public performance claims.
Resident supervisor / temporal backend playground artifacts require separate intake.
```
