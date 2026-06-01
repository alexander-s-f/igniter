# Experimental Runtime Artifact Passport Minimum Boundary Decision v0

Card: S3-R231-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-runtime-artifact-passport-minimum-boundary-decision-v0
Route: UPDATE
Status: accepted / passport-manifest-proof-authorization-next
Date: 2026-06-01

Depends on:
- S3-R231-C1-D
- S3-R231-C2-P1
- S3-R231-C3-X

---

## Decision

Accept the minimum artifact passport boundary.

Accepted status:

```text
C1-D design: accepted
C2-P1 facts packet: accepted as facts input, not canonical wording authority
C3-X pressure verdict: CONDITIONAL accepted as non-blocking watchpoints
Decision: accept boundary with carry-forward constraints
```

Next Main Line route:

```text
S3-R232-C1-A
experimental-runtime-artifact-passport-manifest-proof-authorization-review-v0
```

This next route is an authorization review only. It may decide whether a
bounded proof-local passport manifest proof can begin. It does not authorize
compiler passport emission, `igc run` implementation, Reference Runtime,
public runtime support, stable API, production, Spark, release evidence, or
public performance claims.

---

## Compact Summary

```text
accepted
artifact passport is now accepted as minimum evidence/compatibility metadata
not portability guarantee
not certification
not runtime support
not stable API
manifest proof authorization review opens next
igc run design-only should wait until one proof-local passport manifest exists
Rust TBackend / acts-as-tbackend / todolist remain separate later intakes
all public/stable/production/Spark/release/performance claims remain closed
```

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-runtime-artifact-passport-minimum-boundary-v0.md`
- `igniter-lang/docs/tracks/experimental-runtime-artifact-passport-surface-facts-v0.md`
- `igniter-lang/docs/discussions/experimental-runtime-artifact-passport-minimum-boundary-pressure-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-resident-supervisor-candidate-intake-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round230-status-curation-v0.md`

No code, runtime, API, CLI, package, RuntimeSmoke, public docs, release, or
playground files were edited by this decision.

---

## Accepted Minimum Field Set

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

Accepted recommended / future-required fields:

```text
output_contract:
  recommended now
  required before igc run design can claim a complete executable contract

execution_substrate:
  future-field candidate
  should be carried into S3-R232
  becomes required before Rust TBackend or mixed runtime/backend composition
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

Those remain future certification/productization concerns.

---

## Accepted Field Statuses

Artifact kind status:

```text
accepted
.igapp and .igbin must use distinct artifact_kind values
semantic_ir_program and evidence result packets must also stay distinct
```

Canonical artifact kind carry-forward:

```text
igapp_dir
semantic_ir_program
igbin_aot_binary
evidence_result_packet
temporal_backend_data_or_wire_artifact
```

Note:

```text
C1-D used `igbin_file`; C2-P1 recommended `igbin_aot_binary`.
C3-X correctly flags the split.
C4-A accepts `igbin_aot_binary` as the canonical value for the next manifest
proof route because it is more precise and avoids generic binary-file drift.
```

Runtime implementation id status:

```text
accepted as evidence metadata only
not stable API
not package identity
not certification identity
not public runtime name
```

Capability matching status:

```text
accepted
minimum matching must include artifact_kind, artifact_format_version,
semantics_profile, runtime_target_kind, runtime_implementation_id,
required_capabilities, feature_set, required_opcodes, input_contract, and
failure_policy
```

Digest/source/SemanticIR/artifact status:

```text
accepted
source_digest -> semantic_ir_digest -> artifact_digest is the preferred chain
when all inputs exist
hand-authored proof fixtures must explicitly record missing source/SemanticIR
links rather than pretending compiler provenance
```

Evidence class / authority status / non-claims status:

```text
accepted
every passport must carry evidence_class, authority_status, and non_claims
```

Minimum non-claims:

```text
not stable API
not production ready
not public runtime support
not Reference Runtime support
not Spark integration
not release evidence
not public performance claim
not certified alternative implementation
not artifact portability guarantee
```

---

## Surface Status

IVM / resident supervisor status:

```text
accepted as delegated experimental runtime evidence source
resident supervisor remains non-canonical candidate evidence only
runtime_implementation_id: igniter.delegated.experimental.ivm.c_resident
not Reference Runtime
not public runtime
not performance claim authority
```

Rust TBackend status:

```text
held as separate temporal_backend candidate intake
not accepted as executable runtime
not official TBackend
not public server support
not performance claim authority
future intake must remediate/contain README benchmark wording first
```

acts-as-tbackend status:

```text
held as separate app_consumer_bridge intake
not runtime
not backend authority
not public Rails/API support
```

todolist status:

```text
held as separate app-consumer / experimental product path intake
not runtime support
not public demo claim
```

`igc run` status:

```text
implementation closed
design-only route should wait until one proof-local passport manifest exists
```

Portability / certification status:

```text
no portability guarantee
no certified alternative implementation
no artifact compatibility promise
no stable API promise before v1
```

Public/stable/production/Spark/release claim status:

```text
closed
```

---

## Carry-Forward Constraints

The following C3-X watchpoints are accepted as mandatory constraints for
S3-R232-C1-A and any manifest proof route.

1. Canonical wording:

```text
Use: minimum artifact passport boundary
Use: artifact passport as evidence/compatibility metadata
Do not use C2-P1 wording as canonical:
  formal Artifact Passport Portability Boundary
  PORTABILITY PASSPORT
```

2. Canonical AOT artifact kind:

```text
igbin_aot_binary
```

Do not introduce a second AOT bytecode value such as `igbin_file` in proof
outputs.

3. Substrate discriminator:

```text
execution_substrate is a known future-field candidate.
The manifest proof route must either include it as an explicit optional field
or record why it is deferred.
It becomes required before Rust TBackend intake can claim compatibility with
runtime execution artifacts.
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

Performance wording constraint:

```text
Any timing ratio must carry inline rough / informational-only language.
A standalone caution block is not sufficient.
```

---

## Explicit Answers

Whether artifact passport minimum boundary is accepted:

```text
Yes.
```

Whether this creates artifact portability guarantees:

```text
No.
```

Whether passport emission implementation may open next:

```text
Only a proof-local passport manifest authorization review may open next.
Compiler/mainline passport emission remains closed.
```

Whether `igc run` design-only may open next or should wait:

```text
It should wait until one proof-local passport manifest exists.
```

Whether Rust TBackend / acts-as-tbackend / todolist routes remain held or open
next:

```text
Rust TBackend: held / separate later intake
acts-as-tbackend: held / separate later intake
todolist: held / separate later intake
```

Whether Reference Runtime/public runtime/stable API/production/Spark/release/
performance claims remain closed:

```text
Yes. All remain closed.
```

---

## Exact Next Dispatch Recommendation

```text
Card: S3-R232-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-runtime-artifact-passport-manifest-proof-authorization-review-v0
Route: UPDATE

Goal:
Decide whether a bounded proof-local artifact passport manifest proof may begin
for existing delegated experimental runtime evidence, without authorizing
passport emission in the compiler, igc run implementation, Reference Runtime,
public runtime support, stable API, production, Spark, release evidence, or
public performance claims.

Required carry-forward constraints:
- use C1-D/C4-A vocabulary only;
- forbid "Portability Passport" / "formal Portability Boundary" wording;
- canonicalize AOT bytecode artifact_kind as `igbin_aot_binary`;
- include or explicitly defer `execution_substrate`;
- keep runtime/backend/app-consumer dimensions separate;
- keep all non-claims machine-readable.

Candidate write scope:
- igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/**
- igniter-lang/docs/tracks/
  experimental-runtime-artifact-passport-manifest-proof-v0.md

Closed:
- igniter-lang/lib/**
- igniter-lang/bin/igc
- igniter-lang/igniter_lang.gemspec
- README/public docs/body spec
- RuntimeSmoke
- CompilerResult / CompilationReport
- public API/CLI/package surfaces
- playground source changes unless explicitly copied/read-only
- release execution
```
