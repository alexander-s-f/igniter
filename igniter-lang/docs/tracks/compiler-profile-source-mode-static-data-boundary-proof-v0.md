# Compiler Profile Source-Mode Static-Data Boundary Proof v0

Card: S3-R153-C1-P1  
Agent: `[Igniter-Lang Research Agent]`  
Role: `research-agent`  
Borrowed lens: `compiler-profile-architecture`  
Route: UPDATE  
Depends on: S3-R152-C3-A, S3-R152-C4-S  
Track: `compiler-profile-source-mode-static-data-boundary-proof-v0`  
Status: done / PASS  
Date: 2026-05-23

---

## Role And Neighbor Awareness

Assigned track: prove the accepted source-mode/static-data boundary with
synthetic proof-local data only.

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` - owns any later compiler/profile
  pack integration, classifier wiring, or pass-boundary migration.
- `[Igniter-Lang Bridge Agent]` - owns pressure before public/report/loader,
  CompatibilityReport, artifact, runtime, Spark, production, or demo surfaces
  open.

---

## Current Horizon

```text
R152 accepted source-mode/static-data as architecture boundary only.
Static data remains synthetic proof-local data, not lib data or shared fixture.
profile_candidate and pack_descriptor_candidate remain internal source modes.
finalized_internal remains internal-only, not PROP-036/manifest/runtime identity.
No implementation, public/report/artifact/runtime/Spark/demo surface is opened.
```

---

## Read Set

- `docs/gates/compiler-profile-source-mode-static-data-boundary-decision-v0.md`
- `docs/tracks/compiler-profile-source-mode-static-data-boundary-design-v0.md`
- `docs/discussions/compiler-profile-source-mode-static-data-boundary-pressure-v0.md`
- `docs/tracks/stage3-round152-status-curation-v0.md`
- `docs/current-status.md`
- `lib/igniter_lang/oof_fragment_registry.rb`
- `lib/igniter_lang/internal_profile_assembly_source_packet.rb`
- `lib/igniter_lang/internal_profile_assembly.rb`

---

## Proof Artifacts

Runner:

```text
igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/compiler_profile_source_mode_static_data_boundary_proof.rb
```

Outputs:

```text
igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/out/compiler_profile_source_mode_static_data_boundary_proof_summary.json
igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/out/synthetic_static_data_fixture.json
igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/out/source_packet.helper_envelopes.json
igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/out/duplicate_ownership_rejection.json
```

Key digests:

```text
static_data_fixture_digest: a972e4085efe0ceff0070d2d
valid_packet_digest:        52c59683d52184e7be229648
valid_helper_envelopes:     e00d3e50918648272bd4b745
duplicate_fixture_digest:   0e5cafabda8d7db5aecb308b
```

---

## Synthetic Shape

The proof uses proof-local synthetic data only:

- one synthetic `pack_descriptor_candidate`:
  `pack_descriptor_candidate/proof:SyntheticCorePack`;
- one synthetic OOF descriptor row: `OOF-SYN1`;
- one synthetic profile candidate:
  `profile_candidate/proof:S3-R153-static-boundary`;
- one selected pack reference from the profile to the pack;
- one duplicate ownership negative case by adding a second synthetic pack that
  claims the same OOF row and fragment row.

No shared fixtures, spec/canon examples, Spark-derived data, product data,
generated indexes, or `lib/` static data were created.

---

## Proof Matrix

| Area | Result | Boundary status |
| --- | --- | --- |
| Static-data status matrix | PASS | proof fixture accepted; all non-proof surfaces rejected |
| Minimal synthetic shape | PASS | non-trivial synthetic data used |
| Source-mode mapping | PASS | maps to internal profile-assembly source packet semantics |
| Authority preservation | PASS | pack row authority and profile authority split preserved |
| Lifecycle preservation | PASS | `finalized_internal` remains internal-only |
| PROP-036 negative scan | PASS | required tokens absent from forbidden payload |
| PROP-038 preservation | PASS | no contract/refusal/report/runtime widening |
| Adapter evidence | PASS | proof-local/direct-require evidence only; no classifier authority |
| Closed-surface scans | PASS | all named surfaces remain closed |

Static-data status matrix:

| Surface | Status |
| --- | --- |
| proof fixture static data | accepted proof-local only |
| internal library data | rejected |
| generated index | rejected |
| public/default discovery | rejected |
| loader/report | rejected |
| CompatibilityReport | rejected |
| manifest/artifact | rejected |
| runtime | rejected |
| Spark | rejected |
| production | rejected |
| demo | rejected |

---

## Source-Mode Mapping

The proof builds an `IgniterLang::InternalProfileAssemblySourcePacket` and maps
it to helper envelopes:

```text
profile_candidate          -> oof_fragment_registry_source envelope
pack_descriptor_candidate  -> oof_fragment_registry_source envelope
```

Observed summary:

```text
source_input_kind: compiler_profile_oof_registry_source_input
profile_source_mode: profile_candidate
pack_source_modes: [pack_descriptor_candidate]
public_carrier_leakage: false
```

The proof validates through `IgniterLang::OOFFragmentRegistry` and assembles
through `IgniterLang::InternalProfileAssembly` without compiler pipeline use.

---

## Authority Preservation

Accepted split preserved:

```text
pack_descriptor_candidate:
  owns row identity, provenance, and row-local claims

profile_candidate:
  owns selected pack set, selected pack order, and aggregate conflict policy
```

Duplicate ownership negative:

```text
diagnostic:
  oof_registry.source.validation.duplicate_row_ownership
result:
  rejected before finalized_internal
```

The duplicate appears twice because the negative fixture deliberately duplicates
both the OOF descriptor row and the fragment row.

---

## Lifecycle Preservation

The positive packet reaches `finalized_internal`, but only as internal assembly
state.

Machine-checked false meanings:

```text
prop036_identity: false
manifest_identity: false
public_finalization: false
loader_report_status: false
runtime_readiness: false
production_readiness: false
spark_readiness: false
demo_readiness: false
```

---

## PROP-036 Negative Scan

Required exact tokens:

```text
compiler_profile_id
compiler_profile_id_source
compiler_profile_source
profile_source
profile finalization
manifest identity
default profile
named profile
profile discovery
```

Scan target:

```text
forbidden result fields and closed-surface outputs
```

Result:

```text
hits: []
status: PASS
```

The tokens are present only in the explicit negative-scan token list.

---

## Closed-Surface Scan

PASS / closed:

```text
root_require
classifier_wiring
live_dispatch
parser
typechecker
semanticir
assembler
report
.igapp / fixtures
public_api_cli
loader_report
compatibility_report
manifest
sidecar
artifact_hash
golden_migration
spark
runtime
production
demo
prop036_mutation
prop038_mutation
persisted_report_behavior
runtime_refusal_authority
```

Adapter evidence remains closed:

```text
root_require_adapter_reference: false
classifier_adapter_reference: false
live_dispatch_adapter_method_claimed: false
classifiedprogram_field_projection: false
contract_fragment_for_replaced: false
```

---

## Command Matrix

| Command | Result |
| --- | --- |
| `ruby -c igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/compiler_profile_source_mode_static_data_boundary_proof.rb` | Syntax OK |
| `ruby igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/compiler_profile_source_mode_static_data_boundary_proof.rb` | PASS, 16/16 |

No existing proof/regression command was needed to prove this boundary. The new
runner directly validates the internal packet/registry boundary and performs
closed-surface scans. Running broader proofs would rewrite outputs outside this
card's allowed write scope, so this slice kept the command matrix narrow.

---

## Changed Files

```text
experiments/compiler_profile_source_mode_static_data_boundary_proof/
  compiler_profile_source_mode_static_data_boundary_proof.rb
  out/compiler_profile_source_mode_static_data_boundary_proof_summary.json
  out/duplicate_ownership_rejection.json
  out/source_packet.helper_envelopes.json
  out/synthetic_static_data_fixture.json
docs/tracks/compiler-profile-source-mode-static-data-boundary-proof-v0.md
```

No `lib/**`, compiler, parser, TypeChecker, SemanticIR, assembler, report,
`.igapp`, public API/CLI, loader/report, CompatibilityReport, proposal,
spec/canon, shared fixture, Spark, runtime, production, existing golden, or demo
file was edited.

---

## Recommendation

Recommendation for C3-A: **accept proof**.

Do not request implementation acceptance from this proof. A later route would
need a new gate before opening any shared fixture, `lib/` static data, generated
index, compiler integration, public/report carrier, artifact, runtime, Spark,
production, or demo surface.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/compiler-profile-source-mode-static-data-boundary-proof-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Modeled source-mode/static-data as synthetic proof-local data only.
- Mapped profile_candidate and pack_descriptor_candidate into the accepted
  internal profile-assembly source packet semantics.
- Kept finalized_internal as internal-only lifecycle state.
- Treated all non-proof static-data surfaces as rejected/held closed.

[R] Recommendations:
- C3-A may accept this proof.
- Hold implementation, public/report/artifact, Spark, runtime, production, and
  demo routes until a separate gate opens them.

[S] Signals:
- Proof PASS 16/16.
- Duplicate row ownership rejection visible with
  oof_registry.source.validation.duplicate_row_ownership.
- PROP-036 required tokens have zero hits in forbidden payload.
- Closed-surface scan reports all named surfaces closed.

[T] Tests / Proofs:
- PASS `ruby -c igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/compiler_profile_source_mode_static_data_boundary_proof.rb`
- PASS `ruby igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/compiler_profile_source_mode_static_data_boundary_proof.rb`

[Files] Changed:
- `igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/compiler_profile_source_mode_static_data_boundary_proof.rb`
- `igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/out/compiler_profile_source_mode_static_data_boundary_proof_summary.json`
- `igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/out/duplicate_ownership_rejection.json`
- `igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/out/source_packet.helper_envelopes.json`
- `igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/out/synthetic_static_data_fixture.json`
- `igniter-lang/docs/tracks/compiler-profile-source-mode-static-data-boundary-proof-v0.md`

[Q] Open Questions:
- None for proof-only closure.

[X] Rejected:
- No shared fixtures, lib data, generated index, compiler integration,
  public/report carriers, artifacts, runtime behavior, Spark fixture/spec,
  production, or demo work.

[Next] Proposed next slice:
- If C3-A accepts, decide whether the next route is more proof pressure or a
  separate implementation-authorization review for a still-internal carrier.
```
