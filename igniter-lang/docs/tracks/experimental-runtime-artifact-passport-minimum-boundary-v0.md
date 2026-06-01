# Experimental Runtime Artifact Passport Minimum Boundary v0

Card: S3-R231-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-runtime-artifact-passport-minimum-boundary-v0
Route: UPDATE
Status: design / recommend-passport-manifest-proof-next
Date: 2026-06-01

Depends on:
- S3-R230-C4-A

---

## Decision Shape

The artifact passport vocabulary is ready to become a minimum boundary for
experimental executable runtime evidence.

Accepted design stance:

```text
artifact passport = evidence/compatibility metadata boundary
artifact passport != portability guarantee
artifact passport != certification
artifact passport != runtime support
artifact passport != stable API
```

Recommended next route for C4-A:

```text
accept boundary
open proof-local passport manifest proof authorization review next
hold igc run design-only until one proof-local passport manifest exists
keep Rust TBackend / acts-as-tbackend / todolist as separate later intakes
```

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round230-status-curation-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-resident-supervisor-candidate-intake-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-resident-supervisor-candidate-intake-v0.md`
- `playgrounds/igniter-runtime/out/resident_supervisor_candidate_intake/summary.json`
- `igniter-lang/docs/tracks/stage3-round229-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-runtime-implementations-and-portability-boundary-decision-v0.md`
- `igniter-lang/docs/tracks/experimental-runtime-implementation-status-model-v0.md`
- `igniter-lang/docs/tracks/experimental-executable-quickstart-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-aot-bytecode-file-loading-acceptance-decision-v0.md`
- `playgrounds/igniter-runtime/out/ivm_aot_bytecode_file_loading_proof/summary.json`
- `igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/manifest.json`
- `igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/semantic_ir_program.json`
- `igniter-lang/examples/experimental_executable_quickstart_v0/out/quickstart_result.json`
- `playgrounds/igniter-tbackend/README.md`
- `playgrounds/igniter-tbackend/Cargo.toml`
- `playgrounds/igniter-tbackend/src/**`
- `playgrounds/acts-as-tbackend/**`

No code, package, CLI, runtime, RuntimeSmoke, public docs, or playground files
were edited by this design card.

---

## Boundary Purpose

R223-R230 proved several useful but non-canonical execution surfaces:

```text
.ig source -> .igapp -> delegated example-local runtime
.igapp / SemanticIR -> IVM adapter
IVM AST/bytecode -> .igbin
.igbin -> native AOT file loader
.igbin -> resident supervisor load-once / execute-many lifecycle
```

Those proofs are valuable, but they currently rely on adjacent result packets
and track docs to explain:

```text
what artifact this is
who produced it
what semantic/profile subset it requires
what runtime/backend can consume it
what evidence class it belongs to
what it explicitly does not claim
```

The passport boundary makes those fields explicit and machine-readable before
any productized execution surface can be designed.

---

## Minimum Passport Field Matrix

Required for every experimental executable artifact passport:

| Field | Required | Meaning |
| --- | --- | --- |
| `passport_kind` | yes | Stable label such as `experimental_runtime_artifact_passport`. |
| `passport_schema_version` | yes | Version of the passport schema itself. |
| `artifact_kind` | yes | Artifact class: `igapp_dir`, `semantic_ir_program`, `igbin_file`, `result_packet`, `wal_file`, etc. |
| `artifact_format_version` | yes | Version of the artifact format, distinct from passport schema. |
| `artifact_ref` | yes | Path, digest ref, or opaque local reference. |
| `artifact_digest` | yes | Digest over the artifact payload or deterministic manifest digest. |
| `spec_version` | yes | Named spec version or `pre_v1_experimental`. |
| `semantics_profile` | yes | Narrow semantics slice, for example `core_add`, `if_expr_lazy`, `aot_bytecode_v0`. |
| `compiler_id` | yes when compiled | Compiler/assembler identity that produced the artifact. |
| `compiler_profile_id` | yes when compiled | Compiler profile or proof profile used. |
| `compiled_at` | yes when compiled | Timestamp or explicit deterministic fixture timestamp. |
| `source_ref` | yes when source-backed | Source path/ref, never public claim authority. |
| `source_digest` | yes when source-backed | Digest over source input. |
| `semantic_ir_ref` | yes when available | SemanticIR ref or path. |
| `semantic_ir_digest` | yes when available | Digest over SemanticIR payload. |
| `surface_dimension` | yes | One of `executable_runtime`, `temporal_backend`, `app_consumer_bridge`, `evidence_packet`. |
| `runtime_target_kind` | yes for executable runtime | `delegated_experimental_runtime`, `reference_runtime`, or `none`; current accepted value is delegated-only. |
| `runtime_implementation_id` | yes when runtime-targeted | Evidence metadata, not stable API or package identity. |
| `backend_implementation_id` | yes when backend-targeted | Separate from runtime id; prevents Rust TBackend conflation. |
| `consumer_surface_id` | yes when consumer-targeted | Separate from runtime/backend id; prevents app bridge conflation. |
| `required_capabilities` | yes | Machine-readable capability list. |
| `feature_set` | yes | Language/runtime feature subset. |
| `required_opcodes` | yes for bytecode | Required bytecode opcodes or empty array if not bytecode. |
| `input_contract` | yes | Inputs expected by the artifact or proof harness. |
| `output_contract` | recommended | Outputs expected; required before `igc run` design. |
| `failure_policy` | yes | Fail-closed / unsupported behavior stance. |
| `evidence_class` | yes | Exact accepted evidence label/class. |
| `authority_status` | yes | `non-canonical / evidence-only` unless a later gate says otherwise. |
| `non_claims` | yes | Explicit negative claims. |
| `producer_track` | yes | Track/card that produced the artifact/passport. |
| `authorized_by` | yes | Authorization card or `none` if legacy observed artifact. |

Not required in the minimum boundary:

```text
certification_level
alternative_implementation_certified_by
public_runtime_support_status
package_name
gem_version
release_version
Spark integration status beyond explicit non-claim
public benchmark fields
```

Those fields are future certification/productization concerns, not minimum
experimental passport fields.

---

## Artifact Kind Stance

`.igapp` and `.igbin` must not share a single vague artifact kind.

Accepted stance:

```text
.igapp directory:
  artifact_kind: igapp_dir
  primary shape: compiler-emitted directory artifact
  carries manifest, SemanticIR, diagnostics, contracts, requirements

semantic_ir_program.json:
  artifact_kind: semantic_ir_program
  primary shape: compiler-emitted semantic program payload
  may be embedded in or referenced by .igapp

.igbin:
  artifact_kind: igbin_file
  primary shape: proof-local delegated bytecode file
  current status: non-canonical / playground-only

summary/result JSON:
  artifact_kind: evidence_result_packet
  primary shape: proof evidence, not executable artifact authority

WAL / TCP fact frames:
  artifact_kind: temporal_backend_data_or_wire_artifact
  primary shape: backend substrate evidence, not executable runtime artifact
```

---

## Runtime / Backend / Consumer Separation

Passport must separate these dimensions:

```text
executable_runtime:
  consumes executable or runtime-lowered artifacts
  examples: IVM adapter, native AOT loader, resident supervisor

temporal_backend:
  stores or serves temporal facts / ledger records
  examples: Rust TBackend

app_consumer_bridge:
  adapts application lifecycle or framework events into backend/runtime use
  examples: acts-as-tbackend ActiveRecord bridge, todolist app consumer
```

This separation is required because a strong Rust backend proof does not imply
executable runtime support, and an app-consumer bridge does not imply public API
support.

---

## Runtime ID and Capability Stance

`runtime_implementation_id` remains evidence metadata only.

Current accepted runtime id:

```text
igniter.delegated.experimental.ivm.c_resident
```

Accepted rule:

```text
An artifact can name a delegated runtime candidate only when the passport also
names evidence_class, authority_status, required_capabilities, and non_claims.
```

Capability matching should be exact enough to prevent accidental execution, but
not so broad that it becomes certification.

Minimum matching dimensions:

```text
artifact_kind
artifact_format_version
semantics_profile
runtime_target_kind
runtime_implementation_id
required_capabilities
feature_set
required_opcodes
input_contract
failure_policy
```

Future `igc run` design should not execute artifacts whose passport does not
match the selected runtime/backend capability profile.

---

## Digest and Source Stance

Digest fields are evidence integrity aids, not release authority.

Required digest chain when available:

```text
source_digest -> semantic_ir_digest -> artifact_digest
```

If a proof-local `.igbin` is produced from a hand-authored fixture, passport
must say so:

```text
source_ref: proof-local fixture
source_digest: present if file-backed
semantic_ir_ref: none
semantic_ir_digest: none
artifact_digest: required
authority_status: non-canonical / evidence-only
```

If `.igbin` is produced from compiler-emitted `.igapp` / SemanticIR, passport
must keep both references:

```text
source_ref
source_digest
semantic_ir_ref
semantic_ir_digest
igapp_ref
igapp_digest
artifact_digest
```

---

## Evidence Class and Non-Claim Block

Every passport must include an explicit non-claim block.

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

Performance fields, if present, must be labeled:

```text
informational research-signal / proof-local timing only
```

Ratios such as `15.6x` or `1.6x` must include inline `rough` or
`informational-only` wording, following R230 AN-1.

---

## Candidate Surface Implications

IVM / resident supervisor:

```text
Needs passport fields now.
Current resident supervisor capability manifest is close to a passport, but it
is not yet a full artifact passport because source/SemanticIR/artifact digest
chain and artifact_kind boundaries are incomplete.
```

Rust TBackend:

```text
Should be mapped as temporal_backend, not executable_runtime.
Needs a separate candidate intake before Main Line effect.
Does not need passport work before intake, but any portability or runtime
composition claim must wait for passport/capability fields.
```

acts-as-tbackend:

```text
Should be mapped as app_consumer_bridge, not runtime and not backend.
Needs a separate intake before Main Line effect.
Does not create public Rails/API support.
```

todolist app:

```text
Should be mapped as app_consumer_surface / experimental product path.
Needs separate intake before it can affect Main Line routing.
```

---

## Route Options

| Option | Decision | Reason |
| --- | --- | --- |
| Minimum docs-only boundary now | Accept | This card defines the boundary with no implementation authority. |
| Proof-local passport manifest proof next | Prefer | Smallest executable next step: generate/read one non-authoritative passport for existing evidence. |
| `igc run` design-only next | Wait | Better after one proof-local passport manifest demonstrates fields. |
| Rust TBackend candidate intake next | Hold | Valuable, but passport proof should land first to prevent runtime/backend conflation. |
| acts-as-tbackend app-consumer intake next | Hold | Valuable after backend/runtime dimensions are less ambiguous. |
| Pause | Reject | Runtime productization momentum benefits from passport proof next. |

---

## Explicit Answers

Whether artifact passport vocabulary is ready to become a minimum boundary:

```text
Yes.
```

Whether passport work is required before `igc run` design:

```text
Yes for implementation.
Recommended before design-only as well: create one proof-local passport manifest
first, then design igc run against concrete fields.
```

Whether passport work is required before additional candidate intakes:

```text
Not strictly. Candidate intakes may proceed as separate evidence reviews.
However, any cross-candidate portability, execution selection, or composition
claim requires passport/capability metadata first.
```

Whether IVM/resident supervisor, Rust TBackend, and app-consumer surfaces need
distinct passport dimensions:

```text
Yes.
Use surface_dimension:
- executable_runtime
- temporal_backend
- app_consumer_bridge
- evidence_packet
```

Whether any portability guarantee is created:

```text
No.
```

Whether implementation may open next:

```text
Only as a future proof-local passport manifest authorization review.
No mainline runtime/API/CLI/package implementation is authorized.
```

Whether Reference Runtime/public runtime/stable API/production/Spark/release/
performance claims remain closed:

```text
Yes. All remain closed.
```

Exact C4-A recommendation:

```text
Accept the minimum artifact passport boundary.
Open proof-local passport manifest proof authorization review next.
Keep igc run design-only held until after one passport manifest proof.
Keep Rust TBackend, acts-as-tbackend, and todolist intakes as separate later
routes.
```

---

## Candidate Next Boundary

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

Candidate write scope:
- igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/**
- igniter-lang/docs/tracks/
  experimental-runtime-artifact-passport-manifest-proof-v0.md

Read-only:
- igniter-lang/lib/**
- igniter-lang/bin/igc
- igniter-lang/igniter_lang.gemspec
- public docs / README
- RuntimeSmoke
- CompilerResult / CompilationReport
- playground source files unless explicitly copied as read-only inputs
```
