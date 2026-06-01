# Stage 3 Round 231 Status Curation v0

Card: S3-R231-C5-S
Skill: IDD Agent Protocol
Agent: [Status Curator]
Role: status-curator
Track: stage3-round231-status-curation-v0
Route: SUMMARY
Status: done
Date: 2026-06-01

Depends on:
- S3-R231-C4-A

---

## Executive Summary

R231 accepts the minimum artifact passport boundary as evidence/compatibility
metadata.

The decision accepts the C1-D design, accepts C2-P1 as facts input only, and
accepts the C3-X conditional pressure as non-blocking watchpoints carried into
R232. The boundary does not create a portability guarantee, certification,
runtime support, stable API, `igc run` implementation, public runtime support,
release evidence, or public performance claims.

Exact next route:

```text
S3-R232-C1-A
experimental-runtime-artifact-passport-manifest-proof-authorization-review-v0
```

This next route is an authorization review only. It may decide whether a
bounded proof-local passport manifest proof can begin.

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-runtime-artifact-passport-minimum-boundary-v0.md`
- `igniter-lang/docs/tracks/experimental-runtime-artifact-passport-surface-facts-v0.md`
- `igniter-lang/docs/discussions/experimental-runtime-artifact-passport-minimum-boundary-pressure-v0.md`
- `igniter-lang/docs/tracks/experimental-runtime-artifact-passport-minimum-boundary-decision-v0.md`
- `igniter-lang/docs/current-status.md`

---

## Outcome Table

| Card | Status | Curated result |
| --- | --- | --- |
| S3-R231-C1-D | accepted | Minimum artifact passport boundary design accepted as evidence/compatibility metadata boundary. |
| S3-R231-C2-P1 | accepted as facts input | Surface facts accepted; elevated "Portability Passport" wording is not canonical authority. |
| S3-R231-C3-X | CONDITIONAL accepted | No blockers; W1/W2/W3 watchpoints carry into R232 manifest proof scope. |
| S3-R231-C4-A | accepted | Accepts boundary with carry-forward constraints; opens passport manifest proof authorization review next. |
| S3-R231-C5-S | done | Current status updated with compact R231 delta and R232 route. |

---

## Curated Status

Accepted / conditional / held status:

```text
accepted with carry-forward constraints
```

Minimum artifact passport boundary status:

```text
accepted as evidence/compatibility metadata boundary
not portability guarantee
not certification
not runtime support
not stable API
```

Accepted required field families:

```text
passport_kind
passport_schema_version
artifact_kind
artifact_format_version
artifact_ref
artifact_digest
spec_version
semantics_profile
compiler_id when compiled
compiler_profile_id when compiled
compiled_at when compiled
source_ref when source-backed
source_digest when source-backed
semantic_ir_ref when available
semantic_ir_digest when available
surface_dimension
runtime_target_kind for executable runtime artifacts
runtime_implementation_id when runtime-targeted
backend_implementation_id when backend-targeted
consumer_surface_id when consumer-targeted
required_capabilities
feature_set
required_opcodes for bytecode artifacts
input_contract
failure_policy
evidence_class
authority_status
non_claims
producer_track
authorized_by
```

Recommended / future-required fields:

```text
output_contract: recommended now; required before igc run design can claim a complete executable contract
execution_substrate: future-field candidate; carry into S3-R232; required before Rust TBackend compatibility claims
```

Rejected as minimum-boundary fields:

```text
certification_level
alternative_implementation_certified_by
public_runtime_support_status
package_name
gem_version
release_version
public benchmark fields
```

Canonical artifact kind status:

```text
igapp_dir
semantic_ir_program
igbin_aot_binary
evidence_result_packet
temporal_backend_data_or_wire_artifact
```

`igbin_aot_binary` is canonical for the next manifest proof. Do not introduce
`igbin_file` as a second AOT bytecode value.

`igc run` status:

```text
implementation closed
design-only route waits until one proof-local passport manifest exists
no CLI/API/package changes authorized
```

Runtime/backend/app-consumer separation:

```text
surface_dimension separates executable_runtime, temporal_backend,
app_consumer_bridge, and evidence_packet.
runtime_implementation_id, backend_implementation_id, and consumer_surface_id
stay distinct.
```

Surface status:

```text
IVM / resident supervisor: delegated experimental runtime evidence source only.
Rust TBackend: held as separate temporal_backend candidate intake.
acts-as-tbackend: held as separate app_consumer_bridge intake.
todolist: held as separate app-consumer / experimental product path intake.
```

Closed surfaces:

```text
compiler passport emission: closed
igc run implementation: closed
Reference Runtime: closed
RuntimeSmoke productization: closed
mainline runtime/API/CLI/package changes: closed
public runtime support: closed
stable API / production / Spark / release claims: closed
public performance claims: closed
artifact portability/certification claims: closed
```

---

## Carry-Forward Constraints

R232 and any manifest proof route must carry:

```text
Use C1-D/C4-A vocabulary only.
Forbid "Portability Passport" / "formal Portability Boundary" wording.
Canonicalize AOT bytecode artifact_kind as igbin_aot_binary.
Include or explicitly defer execution_substrate.
Keep runtime/backend/app-consumer dimensions separate.
Keep all non-claims machine-readable.
```

Forbidden downstream wording:

```text
formal Artifact Passport Portability Boundary
PORTABILITY PASSPORT
cryptographic signature chains
portable artifact
certified alternative implementation
```

Allowed replacements:

```text
minimum artifact passport boundary
artifact passport as evidence/compatibility metadata
digest chain
artifact digest fields
```

Performance wording rule:

```text
Any timing ratio must carry inline rough / informational-only language.
A standalone caution block is not sufficient.
```

---

## Current Status Delta

`igniter-lang/docs/current-status.md` was updated because C4-A accepted the
minimum artifact passport boundary and changed Main Line routing.

Delta recorded:

- accepted boundary status;
- C2-P1 facts-only / non-canonical wording status;
- carry-forward watchpoints;
- `igc run`, runtime/backend/app-consumer separation, and closed surfaces;
- exact next route to passport manifest proof authorization review;
- Round 231 card receipt.

No code, public docs, release artifacts, RuntimeSmoke, Reference Runtime,
`igc run` implementation, compiler result/report, package metadata, or Spark
surfaces were edited or authorized.

---

## Exact Handoff

Next card boundary:

```text
Card: S3-R232-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-runtime-artifact-passport-manifest-proof-authorization-review-v0
Route: UPDATE

Goal:
Decide whether a bounded proof-local artifact passport manifest proof may
begin for existing delegated experimental runtime evidence, without
authorizing passport emission in the compiler, igc run implementation,
Reference Runtime, public runtime support, stable API, production, Spark,
release evidence, or public performance claims.
```

Candidate write scope if authorized by C1-A:

```text
igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/**
igniter-lang/docs/tracks/experimental-runtime-artifact-passport-manifest-proof-v0.md
```

Closed:

```text
igniter-lang/lib/**
igniter-lang/bin/igc
igniter-lang/igniter_lang.gemspec
README/public docs/body spec
RuntimeSmoke
CompilerResult / CompilationReport
public API/CLI/package surfaces
playground source changes unless explicitly copied/read-only
release execution
```
