# Experimental Runtime Artifact Passport Manifest Proof Authorization Review v0

Card: S3-R232-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-runtime-artifact-passport-manifest-proof-authorization-review-v0
Route: UPDATE
Status: authorized / proof-local-manifest-proof-next
Date: 2026-06-02

Depends on:
- S3-R231-C5-S

---

## Decision

Authorize a bounded proof-local artifact passport manifest proof.

Accepted authorization:

```text
C2-I may begin in this round.
Write scope is experiments-only plus one proof track doc.
Generated manifests are evidence/compatibility metadata only.
Compiler passport emission remains closed.
igc run implementation remains closed.
Reference Runtime, public runtime, stable API, production, Spark, release, and
public performance claims remain closed.
```

This authorization does not create portability guarantees, certification,
runtime support, public API support, package identity, release evidence, or
stable API promises.

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round231-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-runtime-artifact-passport-minimum-boundary-decision-v0.md`
- `igniter-lang/docs/tracks/experimental-runtime-artifact-passport-minimum-boundary-v0.md`
- `igniter-lang/docs/tracks/experimental-runtime-artifact-passport-surface-facts-v0.md`
- `igniter-lang/docs/discussions/experimental-runtime-artifact-passport-minimum-boundary-pressure-v0.md`
- `igniter-lang/docs/tracks/experimental-executable-quickstart-acceptance-decision-v0.md`
- `igniter-lang/examples/experimental_executable_quickstart_v0/out/quickstart_result.json`
- `igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/manifest.json`
- `igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/semantic_ir_program.json`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-aot-bytecode-file-loading-acceptance-decision-v0.md`
- `playgrounds/igniter-lab/igniter-runtime/out/ivm_aot_bytecode_file_loading_proof/summary.json`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-resident-supervisor-candidate-intake-acceptance-decision-v0.md`
- `playgrounds/igniter-lab/igniter-runtime/out/resident_supervisor_candidate_intake/summary.json`

No code, compiler, runtime, CLI, package, RuntimeSmoke, public docs, release,
or playground files were edited by this authorization card.

---

## Authorization Basis

R231 accepted the minimum artifact passport boundary as:

```text
evidence/compatibility metadata boundary
not portability guarantee
not certification
not runtime support
not stable API
```

The required source evidence is available:

```text
compiler-emitted .igapp:
  igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/

compiler-emitted SemanticIR:
  igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/
    semantic_ir_program.json

delegated .igbin evidence:
  playgrounds/igniter-lab/igniter-runtime/out/
    ivm_aot_bytecode_file_loading_proof/*.igbin
  playgrounds/igniter-lab/igniter-runtime/out/
    resident_supervisor_candidate_intake/*.igbin

accepted delegated runtime id:
  igniter.delegated.experimental.ivm.c_resident
```

The proof is needed before any `igc run` design-only route can be considered.

---

## Allowed Write Scope

Authorized C2-I write scope:

```text
igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/**
igniter-lang/docs/tracks/
  experimental-runtime-artifact-passport-manifest-proof-v0.md
```

Experiments-only write scope is enough.

The proof may generate manifests for existing `.igapp` and `.igbin` evidence,
but it must not mutate the source artifacts. It may read source artifacts and
compute digests over them. If the implementation needs stable test fixtures, it
may copy read-only evidence into its own experiment `out/` directory only when
the copy is clearly labeled as a proof-local copy and digest-linked to the
original source.

---

## Read-Only / Closed Scope

Closed unless later explicitly authorized:

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
playgrounds/igniter-lab/**
README/public docs/body spec
release artifacts and commands
```

The proof must not edit playground source or evidence artifacts.

---

## Required Manifest Field Set

Each generated proof-local passport manifest must include or explicitly mark
not-applicable/deferred for the accepted minimum field families:

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
output_contract or explicit deferred rationale
failure_policy
evidence_class
authority_status
non_claims
producer_track
authorized_by
```

Canonical artifact kinds:

```text
igapp_dir
semantic_ir_program
igbin_aot_binary
evidence_result_packet
temporal_backend_data_or_wire_artifact
```

The canonical AOT bytecode artifact kind is:

```text
igbin_aot_binary
```

Do not emit `igbin_file` as a second AOT bytecode value.

---

## Digest and Provenance Policy

Digest recomputation is required.

Policy:

```text
source_digest -> semantic_ir_digest -> artifact_digest
```

when all three layers exist.

For hand-authored or proof-local `.igbin` artifacts, missing source or
SemanticIR links must be explicit. The proof must not invent compiler
provenance for bytecode fixtures that were not compiler-emitted.

Digest fields are evidence integrity aids only. They are not release authority,
not signature authority, and not compatibility guarantees.

---

## Runtime / Backend / Consumer Separation

The proof must preserve separate dimensions:

```text
surface_dimension:
  executable_runtime
  temporal_backend
  app_consumer_bridge
  evidence_packet

runtime_implementation_id:
  runtime-targeted evidence metadata only

backend_implementation_id:
  backend-targeted evidence metadata only

consumer_surface_id:
  app-consumer / bridge evidence metadata only
```

For this C2-I, primary runtime-targeted evidence may name:

```text
runtime_implementation_id:
  igniter.delegated.experimental.ivm.c_resident
```

This remains evidence metadata only.

Rust TBackend remains a later temporal_backend candidate intake. The current
proof may mention it only in non-claims or deferred substrate notes, not as an
accepted runtime target.

---

## execution_substrate Policy

`execution_substrate` must be included where the proof can state it honestly.

Accepted examples:

```text
c_resident_in_memory_module
c_aot_file_loader
ruby_delegated_example_local_harness
none
deferred_for_temporal_backend_intake
```

If a manifest cannot provide a concrete substrate, it must include an explicit
deferred rationale.

For Rust TBackend compatibility claims, `execution_substrate` becomes required
later and cannot remain implicit.

---

## output_contract Stance

`output_contract` is mandatory when it can be derived from the artifact or
accepted proof evidence.

For `.igapp` / SemanticIR evidence, the proof should derive output contract
data from SemanticIR outputs where possible.

For `.igbin` evidence, the proof may either:

```text
include a narrow proof-known output_contract
or explicitly defer output_contract with rationale
```

The proof must record that `output_contract` is required before any future
`igc run` design can claim a complete executable contract.

---

## Required non_claims

Every generated manifest must include machine-readable non-claims at least for:

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
not compiler passport emission
not igc run implementation
```

---

## Forbidden Wording Scan

C2-I must scan generated proof docs and JSON/string fields for forbidden
downstream wording:

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

Performance ratios, if any are carried through from source evidence, must use
inline `rough / informational-only` wording.

---

## Required Proof Matrix

```text
PPM-1: manifest schema contains all required minimum field families.
PPM-2: `.igapp` passport uses `artifact_kind: igapp_dir`.
PPM-3: `.igbin` passport uses `artifact_kind: igbin_aot_binary` when
  `.igbin` evidence is present.
PPM-4: artifact digest recomputation is deterministic.
PPM-5: source digest is recorded when source-backed evidence exists.
PPM-6: SemanticIR digest is recorded when SemanticIR exists.
PPM-7: missing source/SemanticIR links are explicit, not invented.
PPM-8: runtime/backend/app-consumer dimensions remain separated.
PPM-9: `runtime_implementation_id` is evidence metadata only.
PPM-10: `execution_substrate` is included or explicitly deferred.
PPM-11: `input_contract` and `failure_policy` are present.
PPM-12: `output_contract` is present or explicitly deferred.
PPM-13: `evidence_class`, `authority_status`, and `non_claims` are
  machine-readable.
PPM-14: forbidden wording scan passes.
PPM-15: source artifact immutability is preserved.
PPM-16: closed-surface scan passes.
```

---

## Required Command Matrix

```text
ruby -c igniter-lang/experiments/
  experimental_runtime_artifact_passport_manifest_v0/
  experimental_runtime_artifact_passport_manifest_v0.rb

ruby igniter-lang/experiments/
  experimental_runtime_artifact_passport_manifest_v0/
  experimental_runtime_artifact_passport_manifest_v0.rb
```

Optional read-only validation:

```text
ruby -rjson -e '...' generated summary/result JSON
ruby -rjson -e '...' generated passport manifest JSON files
```

No release, package, or public docs command is authorized.

---

## Required Result Packet Shape

C2-I must produce a summary/result JSON with:

```text
kind
format_version
card
track
authorized_by
overall
checks_total
checks_pass
checks_fail
failed_checks
generated_manifests
source_artifacts_read
source_artifacts_immutability
proof_matrix
closed_surface_scan
non_claims
next_recommendation
```

---

## Explicit Answers

May C2-I begin in this round?

```text
Yes.
```

Is experiments-only write scope enough?

```text
Yes.
```

May proof generate manifests for existing `.igapp` and `.igbin` evidence?

```text
Yes, as proof-local evidence/compatibility metadata only.
```

May source artifacts be copied?

```text
Prefer read-only digesting in place.
Proof-local copies are allowed only under the experiment `out/` directory when
clearly labeled and digest-linked to original evidence.
```

Is canonical AOT artifact_kind `igbin_aot_binary`?

```text
Yes.
```

Must `execution_substrate` be included?

```text
Include it where it can be honestly stated. Otherwise explicitly defer with
rationale. It must not be silently omitted.
```

Is `output_contract` mandatory?

```text
Mandatory where derivable. Explicit deferred rationale is acceptable for
bytecode-only evidence in this proof. It becomes required before any future
igc run design can claim complete executable contract coverage.
```

Are generated manifests evidence/compatibility metadata only?

```text
Yes.
```

Does compiler passport emission remain closed?

```text
Yes.
```

Does `igc run` implementation remain closed?

```text
Yes.
```

Do Reference Runtime, public runtime support, stable API, production, Spark,
release, and public performance claims remain closed?

```text
Yes.
```

---

## Exact C2-I Boundary

```text
Card: S3-R232-C2-I
Skill: IDD Agent Protocol
Agent: [Implementation Agent]
Role: implementation-agent
Track: experimental-runtime-artifact-passport-manifest-proof-v0

Route: UPDATE
Depends on:
- S3-R232-C1-A

Goal:
Create a bounded proof-local artifact passport manifest proof for existing
delegated experimental runtime evidence, using experiments-only write scope
and preserving all compiler, runtime, CLI, package, public, release, and
playground source surfaces as read-only.

Allowed write scope:
- igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/**
- igniter-lang/docs/tracks/
  experimental-runtime-artifact-passport-manifest-proof-v0.md

Read-only / closed unless explicitly authorized:
- igniter-lang/lib/**
- igniter-lang/bin/igc
- igniter-lang/igniter_lang.gemspec
- igniter-lang/README.md
- igniter-lang/docs/README.md
- igniter-lang/docs/ruby-api.md
- igniter-lang/lib/igniter_lang/runtime_smoke.rb
- igniter-lang/lib/igniter_lang/compiler_result.rb
- igniter-lang/lib/igniter_lang/compilation_report.rb
- playgrounds/igniter-lab/**

Required proof matrix:
- PPM-1..PPM-16 as listed in S3-R232-C1-A.

Required command matrix:
- ruby -c igniter-lang/experiments/
  experimental_runtime_artifact_passport_manifest_v0/
  experimental_runtime_artifact_passport_manifest_v0.rb
- ruby igniter-lang/experiments/
  experimental_runtime_artifact_passport_manifest_v0/
  experimental_runtime_artifact_passport_manifest_v0.rb

Deliver:
- Proof track doc in `igniter-lang/docs/tracks/`
- Proof script and generated manifests under experiment `out/`
- Summary/result JSON
- Compact handoff with D/S/T/R packet
```
