# Track: Compiler Pack Shadow Profile Proof v0

Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `compiler-pack-shadow-profile-proof-v0`
Status: done
Date: 2026-05-10

---

## Goal

Prepare the first proof-local foundation for a future profile-assembled
`igniter-lang` compiler by describing the current monolithic compiler as a
deterministic shadow `CompilerProfile`.

This slice does not implement `CompilerKernel`, dispatch compiler passes through
packs, change compiler implementation, change `.igapp` format, or authorize
native pack migration.

---

## Implemented Proof Boundary

Added:

```text
igniter-lang/experiments/compiler_pack_shadow_profile_proof/compiler_pack_shadow_profile_proof.rb
igniter-lang/experiments/compiler_pack_shadow_profile_proof/out/compiler_pack_shadow_profile_proof_summary.json
```

The runner builds a deterministic `compiler_profile_shadow` with:

- `dispatch_mode: "shadow_no_dispatch"`
- `compiler_pipeline: "current_monolithic_parser_classifier_typechecker_emit_typed_assembler"`
- `igapp_manifest_changes: []`
- `compiler_profile_id_in_igapp: "deferred_until_manifest_prop"`
- a deterministic proof-local `profile_id`
- pack manifests for current and proposed language/compiler ownership
- OOF ownership registry
- fragment ownership and candidate precedence registry
- explicit `native_pack_migration_authorized: false`

---

## Shadow Packs

| Pack / registry | Status | Purpose |
|---|---|---|
| `CoreLanguagePack` | current surface shadow | Describes current module/type/contract/core expression/compiler baseline ownership. |
| `OOFRegistry` | kernel service candidate | Describes OOF descriptor and stage ownership as a future registry. |
| `FragmentRegistry` | kernel service candidate | Describes candidate fragment vocabulary and precedence. |
| `EscapeBoundaryPack` | current surface shadow | Describes `escape`, non-temporal `read`, lifecycle/scope/cardinality, and requirements boundary. |
| `TemporalPack` | current surface shadow | Describes `History`, `BiHistory`, temporal access nodes, capabilities, and guarded metadata-only behavior. |
| `StreamPack` | current surface shadow | Describes `stream`, `window`, `fold_stream`, stream OOFs, and stream assembler hooks. |
| `OLAPPack` | current surface shadow | Describes `olap_point`, `OLAPPoint`, dimensions, slices, and OLAP OOF ownership. |
| `InvariantPack` | current surface shadow | Describes invariant severity, output effects, coverage, and invariant OOF ownership. |
| `ContractModifiersPack` | current surface shadow | Describes modifier grammar, fragment widening, and OOF-M1 ownership. |
| `AssumptionsPack` | proposed shadow only | Describes PROP-032 assumption/epistemic ownership without implementing it. |
| `EvidenceObservationPack` | current surface shadow | Describes current evidence/confidence OOF ownership. |
| `PipelinePack` | current parser surface shadow | Describes current pipeline/parser OOF-PG ownership. |

---

## Proof Checks

The proof asserts:

| Check | Meaning |
|---|---|
| `profile.dispatch_mode_shadow` | The profile is descriptive only and does not dispatch compiler passes. |
| `profile.id_deterministic` | The profile fingerprint is stable over canonical JSON. |
| `packs.unique_names` | No duplicate pack or registry names. |
| `packs.dependencies_satisfied` | Every declared `requires_packs` target exists. |
| `packs.implementation_ids_present` | Every pack has implementation-variant identity. |
| `packs.contract_modifiers_recommended_first` | The first native optional pack recommendation remains bounded. |
| `oof.codes_unique` | No two packs own the same OOF code. |
| `oof.required_codes_owned` | Current/proposed required OOF codes have owners. |
| `fragments.required_classes_owned` | `core`, `escape`, `stream`, `temporal`, `epistemic`, and `oof` have owners. |
| `fragments.precedence_candidate_complete` | The candidate precedence list covers the required fragment vocabulary. |
| `igapp.no_manifest_changes` | The proof does not change `.igapp` shape. |
| `shadow.no_runtime_authorization` | No pack claims live executor/runtime authority. |

---

## Proof Result

Command:

```bash
ruby igniter-lang/experiments/compiler_pack_shadow_profile_proof/compiler_pack_shadow_profile_proof.rb
```

Result:

```text
PASS compiler_pack_shadow_profile_proof
profile.kind: ok
profile.dispatch_mode_shadow: ok
profile.id_deterministic: ok
packs.unique_names: ok
packs.dependencies_satisfied: ok
packs.implementation_ids_present: ok
packs.contract_modifiers_recommended_first: ok
oof.codes_unique: ok
oof.required_codes_owned: ok
fragments.required_classes_owned: ok
fragments.precedence_candidate_complete: ok
igapp.no_manifest_changes: ok
shadow.no_runtime_authorization: ok
profile_id: compiler_profile_shadow/sha256:fa566a2c2e27e06ce4a322af
summary: igniter-lang/experiments/compiler_pack_shadow_profile_proof/out/compiler_pack_shadow_profile_proof_summary.json
```

---

## Decisions

[D] The first profile artifact is intentionally a shadow profile, not a new
compiler execution path.

[D] `OOFRegistry` and `FragmentRegistry` are represented as kernel service
candidates rather than language packs. The future Architect/Compiler-Expert
decision remains whether they become installed packs or kernel registries
populated by packs.

[D] `compiler_profile_id` is proven as a deterministic profile fingerprint, but
is not added to `.igapp`. The manifest boundary remains deferred to an explicit
manifest/profile PROP.

[D] Implementation-variant identity is included in every pack. Capability name
alone is not enough because two packs may both provide `temporal` while carrying
different execution or TBackend semantics.

[D] `ContractModifiersPack` remains the recommended first native optional pack
after POC closure and after shadow-profile review.

---

## Risks

[R] The candidate fragment precedence is still not authoritative:

```text
oof > temporal > stream > escape > epistemic > core
```

This should be reviewed before any classifier dispatch migrates.

[R] The OOF registry currently proves ownership coverage, not full descriptor
schema. A later slice should add severity, stage owner, public message stability,
and alias/deprecation metadata.

[R] The proof includes `AssumptionsPack` as `proposed_shadow_only`. It does not
imply PROP-032 implementation authorization.

[R] The proof includes `compiler_profile_id` only as a proof-local fingerprint.
It does not authorize `.igapp` manifest changes.

---

## Next Recommended Slice

```text
Track: contract-modifiers-pack-native-boundary-v0
Goal:
- Convert ContractModifiersPack from shadow manifest to the first native pack-shaped boundary.
Scope:
- Keep current parser/classifier/typechecker/SemanticIR behavior identical.
- Define pack manifest/registry data for modifier parser rules and OOF-M1.
- Do not introduce CompilerKernel dispatch yet unless Architect explicitly authorizes it.
- Do not change .igapp format.
Acceptance:
- contract_modifiers_proof PASS
- source_to_semanticir_fixture --check-golden PASS
- stage1_close_candidate PASS
- compiler_pack_shadow_profile_proof PASS
```

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: compiler-pack-shadow-profile-proof-v0
Status: done

[D] Decisions:
- Current monolithic compiler can be described as a deterministic shadow profile.
- OOFRegistry and FragmentRegistry are modeled as kernel service candidates.
- compiler_profile_id exists proof-locally, but .igapp manifest integration is deferred.
- Implementation variant identity is required for future competing pack implementations.

[S] Signals:
- Shadow profile covers 12 pack/registry units.
- Required OOF code ownership is complete for the current/proposed pack map.
- Required fragment class ownership is complete for core/escape/stream/temporal/epistemic/oof.
- Proof explicitly blocks runtime authorization and manifest shape changes.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/compiler_pack_shadow_profile_proof/compiler_pack_shadow_profile_proof.rb -> PASS

[R] Risks:
- Fragment precedence still needs Architect/Compiler-Expert ratification.
- OOF descriptors need a richer schema before native migration.
- PROP-032 remains proposed shadow-only in this proof.

[Next]
- Review shadow profile with Architect/Compiler-Expert.
- If accepted after POC closure, route contract-modifiers-pack-native-boundary-v0
  as the first bounded native pack-shaped migration slice.
```
