# Experimental Runtime Artifact Passport Manifest Proof v0

Card: S3-R232-C2-I
Skill: IDD Agent Protocol
Agent: [Implementation Agent]
Role: implementation-agent
Track: experimental-runtime-artifact-passport-manifest-proof-v0
Route: UPDATE
Status: done
Date: 2026-06-02

Depends on:
- S3-R232-C1-A

---

## Purpose

Produce bounded proof-local artifact passport manifests for existing
delegated experimental runtime evidence, using experiments-only write scope.

Generated manifests are evidence/compatibility metadata only.
This proof does not authorize compiler passport emission, `igc run`
implementation, Reference Runtime, public runtime support, stable API,
production, Spark, release evidence, or public performance claims.

---

## Inputs Read (Read-Only)

```text
igniter-lang/docs/tracks/
  experimental-runtime-artifact-passport-manifest-proof-authorization-review-v0.md
igniter-lang/docs/tracks/
  experimental-runtime-artifact-passport-minimum-boundary-decision-v0.md
igniter-lang/examples/experimental_executable_quickstart_v0/out/
  quickstart_result.json
igniter-lang/examples/experimental_executable_quickstart_v0/out/
  Add.igapp/manifest.json
igniter-lang/examples/experimental_executable_quickstart_v0/out/
  Add.igapp/semantic_ir_program.json
igniter-lang/examples/experimental_executable_quickstart_v0/out/
  Add.igapp/compatibility_metadata.json
playgrounds/igniter-lab/igniter-runtime/out/
  ivm_aot_bytecode_file_loading_proof/summary.json
playgrounds/igniter-lab/igniter-runtime/out/
  ivm_aot_bytecode_file_loading_proof/*.igbin  (11 files)
playgrounds/igniter-lab/igniter-runtime/out/
  resident_supervisor_candidate_intake/summary.json
playgrounds/igniter-lab/igniter-runtime/out/
  resident_supervisor_candidate_intake/*.igbin  (6 files)
```

No mainline, CLI, compiler, playground source, or package files were read
or written by this proof beyond the authorized read list above.

---

## Write Scope

```text
igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/
  experimental_runtime_artifact_passport_manifest_v0.rb   [proof script]
  out/Add.igapp.passport.json                              [igapp_dir manifest]
  out/add.igbin.aot.passport.json                         [igbin_aot_binary manifest]
  out/if_module.igbin.resident.passport.json              [igbin_aot_binary manifest]
  out/quickstart_result.evidence_packet.passport.json     [evidence_result_packet]
  out/summary.json                                        [result/summary]
igniter-lang/docs/tracks/
  experimental-runtime-artifact-passport-manifest-proof-v0.md  [this document]
```

---

## Evidence Available

### Compiler-Emitted .igapp

```text
igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/
  manifest.json:
    artifact_hash: sha256:74be8365ea26fa8fc565c3b41c9d9feca8a7e32fbb6eaa376a291cd20a58aaf0
    format: igapp_dir
    format_version: 0.1.0
    semantic_ir_ref: semanticir/d4b79e1278442edc
    source_hash: sha256:d4b79e1278442edc0d527395a38d6d8c4f55831a2553b02a262386d8ccca5cea
    compiled_at: 2026-05-06T00:00:00Z
    assembler: igapp-assembler-proof-stage1-v0
  semantic_ir_program.json:
    contracts: [Add]
    inputs: [a: Integer, b: Integer]
    outputs: [sum: Integer]
    expression: stdlib.integer.add(a, b)
    modifier: pure
```

SemanticIR output contract is derivable from `semantic_ir_program.json`.

### Delegated .igbin Evidence

```text
ivm_aot_bytecode_file_loading_proof/:
  add.igbin (48 bytes)
  gt.igbin (48 bytes)
  if.igbin (64 bytes)
  timing_if.igbin (64 bytes)
  timing_warmup.igbin (64 bytes)
  unsupported_sel.igbin (64 bytes)
  unsupported_unsel.igbin (64 bytes)
  bad_data.igbin (24 bytes)
  bad_header.igbin (20 bytes)
  librunner.dylib
  summary.json — overall: PASS / all AOT-1..AOT-17 checks pass

resident_supervisor_candidate_intake/:
  if_module.igbin (64 bytes)
  bad_magic.igbin (16 bytes)
  truncated.igbin (6 bytes)
  unsupported_module.igbin (64 bytes)
  librunner.dylib
  summary.json — RSUP-1..RSUP-16 all PASS
    runtime_implementation_id: igniter.delegated.experimental.ivm.c_resident
```

All delegated .igbin artifacts are hand-authored proof fixtures.
Source and SemanticIR links are missing (not invented) as required by
the digest chain policy in C1-A.

---

## Canonical Artifact Kinds Used

```text
igapp_dir
  Add.igapp — compiler-emitted, source-backed, SemanticIR-backed

igbin_aot_binary
  add.igbin — AOT file loading proof fixture (c_aot_file_loader substrate)
  if_module.igbin — resident supervisor intake fixture (c_resident_in_memory_module substrate)

evidence_result_packet
  quickstart_result.json — experimental executable quickstart result
```

No `igbin_file` value was used. Canonical AOT artifact kind is `igbin_aot_binary`.

---

## Digest Chain Policy Compliance

```text
source_digest -> semantic_ir_digest -> artifact_digest
```

For Add.igapp:

```text
source_digest:      sha256:d4b79e1278442edc... (carried from compiler-recorded manifest.source_hash)
semantic_ir_digest: sha256:<recomputed over semantic_ir_program.json>
artifact_digest:    sha256:<recomputed deterministically over Add.igapp/ directory tree>
```

Source file `.ig` is not re-read; compiler provenance is preserved read-only.
Recomputed digests are deterministic: SHA256 over sorted directory file list.

For hand-authored .igbin fixtures:

```text
source_digest:    nil — missing / hand-authored; not invented
semantic_ir_digest: nil — missing / hand-authored; not invented
artifact_digest:  sha256:<recomputed over .igbin file>
```

---

## Surface Dimension Mapping

```text
surface_dimension: executable_runtime
  Add.igapp passport
  add.igbin AOT passport
  if_module.igbin resident passport

surface_dimension: evidence_packet
  quickstart_result.json passport

temporal_backend:      not applicable in this proof
app_consumer_bridge:   not applicable in this proof
```

---

## Runtime / Backend / Consumer Separation (PPM-8)

```text
runtime_implementation_id:
  igniter.delegated.experimental.ivm.c_resident  [evidence metadata only]
  not stable API, not package identity, not public runtime name

backend_implementation_id:
  "deferred / not applicable for [artifact surface]"
  distinct field; temporal_backend is a separate later intake

consumer_surface_id:
  "deferred / not applicable for [artifact surface]"
  distinct field; acts-as-tbackend / todolist are separate later intakes
```

No two non-deferred values share the same runtime/backend/consumer identity.
Deferred values may share similar text when both are inapplicable — this is
correct and does not represent field confusion.

---

## execution_substrate Policy (PPM-10)

```text
Add.igapp:          ruby_delegated_example_local_harness
add.igbin (AOT):    c_aot_file_loader
if_module.igbin:    c_resident_in_memory_module
quickstart result:  none
```

No manifest silently omits `execution_substrate`.

---

## output_contract Stance (PPM-12)

```text
Add.igapp:
  output_contract derived from semantic_ir_program.json outputs
  [{ name: "sum", type: "Integer" }]
  contract_name: Add

.igbin passports:
  output_contract explicitly deferred with rationale:
  "hand-authored .igbin fixture; output contract cannot be derived
   without compiler SemanticIR chain. Required before any future
   igc run design can claim complete executable contract."
  Known outputs recorded as proof-local inference; not certified.
```

---

## Required Field Families (PPM-1)

All generated manifests include or explicitly defer for:

```text
passport_kind             ✓
passport_schema_version   ✓
artifact_kind             ✓
artifact_format_version   ✓
artifact_ref              ✓
artifact_digest           ✓
spec_version              ✓
semantics_profile         ✓
compiler_id               ✓ (or deferred with rationale)
compiler_profile_id       ✓ (or deferred with rationale)
compiled_at               ✓ (or deferred with rationale)
source_ref                ✓ (or nil with explicit link_status)
source_digest             ✓ (or nil with explicit link_status)
semantic_ir_ref           ✓ (or nil with explicit link_status)
semantic_ir_digest        ✓ (or nil with explicit link_status)
surface_dimension         ✓
runtime_target_kind       ✓
runtime_implementation_id ✓
backend_implementation_id ✓
consumer_surface_id       ✓
required_capabilities     ✓
feature_set               ✓
required_opcodes          ✓ (or not_applicable for igapp_dir)
execution_substrate       ✓
input_contract            ✓
output_contract           ✓ (or explicitly deferred with rationale)
failure_policy            ✓
evidence_class            ✓
authority_status          ✓
non_claims                ✓ (machine-readable array, 11 entries)
producer_track            ✓
authorized_by             ✓
```

---

## Required Proof Matrix Results

| Check | Description | Result |
|-------|-------------|--------|
| PPM-1 | manifest schema contains all required minimum field families | PASS |
| PPM-2 | .igapp passport uses artifact_kind: igapp_dir | PASS |
| PPM-3 | .igbin passports use artifact_kind: igbin_aot_binary when evidence present | PASS |
| PPM-4 | artifact digest recomputation is deterministic | PASS |
| PPM-5 | source digest is recorded when source-backed evidence exists | PASS |
| PPM-6 | SemanticIR digest is recorded when SemanticIR exists | PASS |
| PPM-7 | missing source/SemanticIR links are explicit, not invented | PASS |
| PPM-8 | runtime/backend/app-consumer dimensions remain separated | PASS |
| PPM-9 | runtime_implementation_id is evidence metadata only | PASS |
| PPM-10 | execution_substrate is included or explicitly deferred | PASS |
| PPM-11 | input_contract and failure_policy are present | PASS |
| PPM-12 | output_contract is present or explicitly deferred | PASS |
| PPM-13 | evidence_class, authority_status, and non_claims are machine-readable | PASS |
| PPM-14 | forbidden wording scan passes | PASS |
| PPM-15 | source artifact immutability is preserved | PASS |
| PPM-16 | closed-surface scan passes | PASS |

**Overall: PASS — 16/16 checks pass**

---

## Forbidden Wording Scan (PPM-14)

Forbidden phrases scanned and absent from all generated manifests and JSON:

```text
formal Artifact Passport Portability Boundary  — absent
PORTABILITY PASSPORT                           — absent
cryptographic signature chains                 — absent
portable artifact                              — absent
certified alternative implementation           — absent (appears only in negated
                                                 non-claims as "not certified
                                                 alternative implementation")
```

Scan note: The scanner strips "not <phrase>" occurrences before matching,
ensuring canonical non-claims do not trigger false positives.

---

## Command Matrix Results

```text
ruby -c igniter-lang/experiments/
  experimental_runtime_artifact_passport_manifest_v0/
  experimental_runtime_artifact_passport_manifest_v0.rb
→ Syntax OK

ruby igniter-lang/experiments/
  experimental_runtime_artifact_passport_manifest_v0/
  experimental_runtime_artifact_passport_manifest_v0.rb
→ PASS — 16/16 checks pass
```

---

## Closed Surface Confirmation (PPM-15, PPM-16)

No edits were made to:

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
```

Source artifact digests recorded at proof time and re-verified at check time.
Out directory is scoped entirely within the experiment directory.

---

## Non-Claims (Machine-Readable)

All generated manifests carry:

```json
[
  "not stable API",
  "not production ready",
  "not public runtime support",
  "not Reference Runtime support",
  "not Spark integration",
  "not release evidence",
  "not public performance claim",
  "not certified alternative implementation",
  "not artifact portability guarantee",
  "not compiler passport emission",
  "not igc run implementation"
]
```

---

## Authority Boundary

```text
passport_kind:         artifact_passport
evidence_only:         true
portability_claim:     none
certification_claim:   none
stable_api_claim:      none
release_claim:         none

Compiler passport emission: closed
igc run implementation:     closed
Reference Runtime:          closed
Public runtime support:     closed
Stable API:                 closed
Production readiness:       closed
Spark integration:          closed
Release evidence:           closed
Public performance:         closed
```

---

## Next Recommendation

One proof-local passport manifest now exists. The `igc run` design-only
route may now be considered per C1-A guidance:

```text
igc run design-only route may be considered as one proof-local passport
manifest exists.
```

Separate later intakes remain held:

```text
Rust TBackend:          held / separate temporal_backend intake
acts-as-tbackend:       held / separate app_consumer_bridge intake
todolist:               held / separate app-consumer product path intake
```

All public/stable/production/Spark/release/performance claims remain closed.

---

## Handoff

```text
Card:   S3-R232-C2-I
Agent:  [Implementation Agent]
Role:   implementation-agent
Track:  experimental-runtime-artifact-passport-manifest-proof-v0
Status: done

[D] Decisions
- PPM-8 correctly allows deferred backend/consumer to share similar
  text when both are inapplicable; check enforces no non-deferred
  identity collision between runtime/backend/consumer dimensions.
- PPM-14 scanner strips "not <phrase>" negations before matching to
  prevent false positives from canonical non-claims list.
- source_digest carried from compiler-recorded manifest.source_hash
  (read-only provenance); source file not re-read.
- All .igbin source/SemanticIR links recorded as nil with explicit
  "not invented" status per C1-A digest chain policy.

[S] Shipped / Signals
- experimental_runtime_artifact_passport_manifest_v0.rb — syntax OK,
  16/16 PPM checks PASS
- out/Add.igapp.passport.json — igapp_dir manifest with full chain
- out/add.igbin.aot.passport.json — igbin_aot_binary / c_aot_file_loader
- out/if_module.igbin.resident.passport.json — igbin_aot_binary /
  c_resident_in_memory_module
- out/quickstart_result.evidence_packet.passport.json — evidence_result_packet
- out/summary.json — PASS / 16/16 checks

[T] Tests / Proofs
- ruby -c: Syntax OK
- ruby: PASS 16/16 — PPM-1..PPM-16 all pass
- Forbidden wording scan: 0 hits
- Source immutability: all digests stable
- Closed-surface scan: out dir scoped to experiment only

[R] Risks / Recommendations
- output_contract for .igbin passports is explicitly deferred; this
  is expected and documented. It becomes required before igc run
  design can claim complete executable contract coverage.
- Digest chain for .igbin fixtures is intentionally incomplete
  (source/SemanticIR nil); compiler-emitted artifacts will carry
  the full chain when compiler passport emission opens.
- igc run design-only may now proceed per C1-A authorization;
  implementation remains closed.

[Next] Suggested next slice
- S3-R232-C3 or later: igc run design-only route consideration
  (authorized by C1-A once proof-local manifest exists — now met)
- Rust TBackend: separate temporal_backend candidate intake when ready
- acts-as-tbackend: separate app_consumer_bridge intake when ready
```
