# Stage 3 Round 225 Status Curation v0

Card: S3-R225-C5-S
Skill: IDD Agent Protocol
Agent: [Status Curator]
Role: status-curator
Track: stage3-round225-status-curation-v0
Route: SUMMARY
Status: done
Date: 2026-05-31

Depends on:
- S3-R225-C4-A

---

## IDD Boundary

Smallest useful artifact: compact status receipt plus minimal current-status
delta. R225 accepts playground-only adapter-fit evidence; it does not authorize
Reference Runtime, public runtime support, CLI `run`, RuntimeSmoke
productization, release, Spark, stable API, or production authority.

Closed by this curation:
- no direct implementation opens from R225;
- no `igc run` implementation opens;
- no RuntimeSmoke productization opens;
- no Reference Runtime implementation opens;
- no FFI/C acceleration opens yet;
- no reusable helper extraction opens yet;
- no public runtime, stable API, public demo, production, Spark, release, or v1
  claim opens.

---

## Inputs Read

- `igniter-lang/docs/tracks/delegated-experimental-runtime-compiler-to-ivm-adapter-authorization-review-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-compiler-to-ivm-adapter-proof-v0.md`
- `igniter-lang/docs/discussions/delegated-experimental-runtime-compiler-to-ivm-adapter-pressure-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-compiler-to-ivm-adapter-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round224-status-curation-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/cards/S3/S3-R225.md`

---

## Outcome Table

| Card | Artifact | Status | Curated result |
| --- | --- | --- | --- |
| S3-R225-C1-A | `delegated-experimental-runtime-compiler-to-ivm-adapter-authorization-review-v0.md` | authorized | Authorized bounded playground-only compiler-to-IVM adapter proof. |
| S3-R225-C2-I | `delegated-experimental-runtime-compiler-to-ivm-adapter-proof-v0.md` | done | Adapter proof PASS; AIP-1..AIP-12 PASS; output 42 through IVM bytecode. |
| S3-R225-C3-X | `delegated-experimental-runtime-compiler-to-ivm-adapter-pressure-v0.md` | PASS | No blockers; AN-1 digest field clarification; AN-2 next-route sequencing resolved by C4-A. |
| S3-R225-C4-A | `delegated-experimental-runtime-compiler-to-ivm-adapter-acceptance-decision-v0.md` | accepted / adapter-hardening-next | Accepts proof as adapter-fit evidence only; defers FFI and helper; opens branch/comparison adapter-hardening authorization review next. |
| S3-R225-C5-S | this file | done | Main Line status updated compactly; next route recorded as authorization review only. |

---

## Curated Status

R225 is accepted.

Adapter proof status:

- AIP-1..AIP-12: PASS.
- Evidence class: adapter-fit evidence only / delegated experimental runtime
  evidence only.
- Accepted Add path:
  `compiler-emitted semantic_ir_program.json -> IVM AST -> 4-opcode bytecode ->
  IVM execution -> 42`.
- Accepted digest:
  `sha256:264b0b4043e294a52cc90e99eddd17098481d4e71d09390a357888ceef8aa62b`.
- AN-1: `source_igapp_sha256` is accepted as the
  `semantic_ir_program.json` digest, not as a canonical directory-level
  `.igapp` digest.

IVM delegated experimental candidate status:

- IVM remains sandbox/playground delegated experimental runtime candidate
  evidence only.
- IVM is not Reference Runtime.
- IVM is not public runtime support or production runtime support.

`.igapp` / SemanticIR adapter fit status:

- Add path is proven from compiler-emitted `semantic_ir_program.json`.
- Supported subset includes `literal`, `ref`, `stdlib.integer.add` to IVM
  `binary_op +`, legacy `apply (stdlib.integer.add)`, and `if_expr` in
  playground branch fixtures.
- Unsupported subset includes `stdlib.integer.gt` and `field_access`.
- Unsupported selected-path nodes fail closed with playground-local
  `UnsupportedNodeError`.

Lazy branch status:

- accepted as verified supplemental playground branch evidence;
- IVM `OP_JMP_UNLESS` and `OP_JMP` branch lowering verified;
- non-selected branch silence verified;
- not yet a fresh compiler-emitted `semantic_ir_program.json` `if_expr`
  adapter proof.

Reusable helper status:

- still valuable;
- deferred until adapter branch/comparison boundary is hardened.

CLI `run` status:

- `igc run` remains closed to implementation and public CLI claims.

RuntimeSmoke status:

- RuntimeSmoke source/result/productization remain closed.

Reference Runtime status:

- Reference Runtime remains closed.

Closed surfaces:

- `igniter-lang/lib/**`, `bin/igc`, gemspec/package metadata, README/public
  docs/body spec, `CompilerResult`, `CompilationReport`, report/result/receipt/
  cache authority, public API/CLI widening, stable API/v1 compatibility,
  production readiness, public demo claim, Spark integration, release execution,
  FFI acceleration, reusable helper extraction, and Runtime Specification
  implementation remain closed unless a later authorization card opens a
  narrower route.

---

## Current-Status Delta

Updated `igniter-lang/docs/current-status.md` with:
- compact R225 accepted adapter-fit state;
- Round 225 landed table;
- exact next route:
  `delegated-experimental-runtime-ivm-adapter-branch-coverage-authorization-review-v0`.

No other status/index surfaces needed edits for this compact SUMMARY route.

---

## Exact Handoff

Next card:

```text
Card: S3-R226-C1-A
Track: delegated-experimental-runtime-ivm-adapter-branch-coverage-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R225-C4-A
```

Purpose:

```text
Decide whether a bounded playground-only adapter hardening proof may begin for
compiler-emitted branch/comparison coverage: fresh or copied
semantic_ir_program.json branch fixture, explicit stdlib.integer.gt stance,
unsupported selected/non-selected path behavior, and digest field cleanup.
```

Do not proceed directly to FFI/C acceleration, reusable helper extraction,
`igc run`, RuntimeSmoke productization, Reference Runtime implementation,
package exposure, or release/public claims.
