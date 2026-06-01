# Stage 3 Round 226 Status Curation v0

Card: S3-R226-C5-S
Skill: IDD Agent Protocol
Agent: [Status Curator]
Role: status-curator
Track: stage3-round226-status-curation-v0
Route: SUMMARY
Status: done
Date: 2026-06-01

Depends on:
- S3-R226-C4-A

---

## IDD Boundary

Smallest useful artifact: compact status receipt plus minimal current-status
delta. R226 accepts playground-only branch/comparison adapter-hardening
evidence; it does not authorize Reference Runtime, public runtime support, CLI
`run`, RuntimeSmoke productization, reusable helper extraction, FFI/C/Rust
implementation, release, Spark, stable API, or production authority.

Closed by this curation:
- no direct implementation opens from R226;
- no FFI/C/Rust acceleration implementation opens yet;
- no reusable helper extraction opens yet;
- no `igc run` implementation opens;
- no RuntimeSmoke productization opens;
- no Reference Runtime implementation opens;
- no public runtime, stable API, public demo, production, Spark, release, or v1
  claim opens.

---

## Inputs Read

- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-adapter-branch-coverage-authorization-review-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-adapter-branch-coverage-proof-v0.md`
- `igniter-lang/docs/discussions/delegated-experimental-runtime-ivm-adapter-branch-coverage-pressure-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-adapter-branch-coverage-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round225-status-curation-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/cards/S3/S3-R226.md`

---

## Outcome Table

| Card | Artifact | Status | Curated result |
| --- | --- | --- | --- |
| S3-R226-C1-A | `delegated-experimental-runtime-ivm-adapter-branch-coverage-authorization-review-v0.md` | authorized | Authorized bounded playground-only branch/comparison adapter-hardening proof. |
| S3-R226-C2-I | `delegated-experimental-runtime-ivm-adapter-branch-coverage-proof-v0.md` | done | BCP-1..BCP-15 PASS; fresh branch/comparison compile, `OP_GT`, selected/non-selected behavior, and digest cleanup proven. |
| S3-R226-C3-X | `delegated-experimental-runtime-ivm-adapter-branch-coverage-pressure-v0.md` | PASS | No blockers; AN-1 says adapter hardening is complete and C4-A must choose among A/B/C. |
| S3-R226-C4-A | `delegated-experimental-runtime-ivm-adapter-branch-coverage-acceptance-decision-v0.md` | accepted / ffi-acceleration-authorization-next | Accepts proof; opens FFI/C/Rust bytecode acceleration authorization review next. |
| S3-R226-C5-S | this file | done | Main Line status updated compactly; next route recorded as authorization review only. |

---

## Curated Status

R226 is accepted.

Branch/comparison adapter-hardening status:

- BCP-1..BCP-15: PASS.
- Evidence class: branch/comparison adapter-hardening evidence only; delegated
  experimental runtime evidence only; playground-only non-canonical evidence.
- Fresh source-backed compile status:
  `minimal_if_else.ig -> fresh_if_else.igapp`;
  `minimal_gt.ig -> fresh_gt.igapp`.
- Branch behavior:
  selected branch verified executes;
  non-selected branch verified silent;
  bytecode uses `OP_JMP_UNLESS` / `OP_JMP` / `RET`.

Source-backed fixture provenance status:

- fresh playground-local compile accepted;
- copied/legacy ambiguity from earlier branch evidence is closed for this route.

`stdlib.integer.gt` stance:

- mapped;
- `stdlib.integer.gt -> binary_op ">" -> OP_GT`;
- `10 > 5 -> true`;
- `3 > 7 -> false`.

Digest cleanup status:

- accepted;
- R225 digest ambiguity resolved;
- `semantic_ir_program_sha256`:
  `1526337ba19eaa83671eeae434f77a6f401bb846177a2b6fa6cf39972c7938fa`;
- `source_igapp_manifest_sha256_or_null`:
  `29e65165bc4fe3a6844a09907ac0454e02218262679b73d886e636d82c8c1766`.

IVM delegated experimental candidate status:

- IVM remains delegated experimental runtime evidence only.
- IVM is not Reference Runtime, public runtime support, or production runtime
  support.

Reusable helper status:

- remains closed for the next card;
- remains useful for TTEU and examples ergonomics later.

FFI/C acceleration status:

- implementation remains closed now;
- S3-R227-C1-A opens only an authorization review to decide whether a bounded
  playground-only FFI/C/Rust bytecode acceleration proof may begin.

CLI `run` status:

- `igc run` remains closed to implementation and public CLI claims.

RuntimeSmoke status:

- RuntimeSmoke source, result shape, and productization remain closed.

Reference Runtime status:

- Reference Runtime remains closed.

Closed surfaces:

- `igniter-lang/lib/**`, `bin/igc`, gemspec/package metadata, README/public
  docs/body spec, `CompilerResult`, `CompilationReport`, report/result/receipt/
  cache authority, public API/CLI widening, stable API/v1 compatibility,
  production readiness, public demo claim, Spark integration, release execution,
  reusable helper extraction, Runtime Specification implementation, and
  Reference Runtime implementation remain closed unless a later authorization
  card opens a narrower route.

---

## Current-Status Delta

Updated `igniter-lang/docs/current-status.md` with:
- compact R226 accepted adapter-hardening state;
- Round 226 landed table;
- exact next route:
  `delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-authorization-review-v0`.

No other status/index surfaces needed edits for this compact SUMMARY route.

---

## Exact Handoff

Next card:

```text
Card: S3-R227-C1-A
Track: delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R226-C5-S
```

Purpose:

```text
Decide whether a bounded playground-only IVM bytecode acceleration research
proof may begin, now that compiler-to-IVM adapter branch/comparison hardening
is accepted.
```

Do not proceed directly to FFI/C/Rust implementation, reusable helper
extraction, `igc run`, RuntimeSmoke productization, Reference Runtime
implementation, package exposure, or release/public claims.
