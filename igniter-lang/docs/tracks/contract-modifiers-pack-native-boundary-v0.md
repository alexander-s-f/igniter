# Track: Contract Modifiers Pack Native Boundary v0

Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `contract-modifiers-pack-native-boundary-v0`
Status: done
Date: 2026-05-10

---

## Goal

Take the first bounded step from shadow compiler profile toward a pack-shaped
compiler architecture by proving `ContractModifiersPack` as a native-style
manifest/descriptor boundary.

This slice does not route compiler execution through packs, implement
`CompilerKernel`, edit compiler implementation, change `.igapp`, or authorize a
broader migration.

---

## Implemented Proof Boundary

Added:

```text
igniter-lang/experiments/contract_modifiers_pack_native_boundary/contract_modifiers_pack_native_boundary.rb
igniter-lang/experiments/contract_modifiers_pack_native_boundary/out/contract_modifiers_pack_native_boundary_summary.json
```

The proof defines a proof-local `compiler_pack_manifest` for
`ContractModifiersPack`:

```text
name: ContractModifiersPack
implementation_id: contract_modifiers.pack_boundary_descriptor.v0
boundary_mode: native_manifest_descriptor_only
requires_packs:
  CoreLanguagePack
  EscapeBoundaryPack
  OOFRegistry
  FragmentRegistry
provides_capabilities:
  contract_modifiers
  modifier_fragment_widening
  oof_m1
```

It then validates that manifest against the existing `contract_modifiers_proof`
golden outputs and the shadow compiler profile summary.

---

## Boundary Contract

| Stage | Pack-owned boundary |
|---|---|
| Parser | Owns modifier keywords `pure`, `observed`, `effect`, `privileged`, `irreversible`; normalizes missing modifier to `pure`; emits the `modifier` field. |
| Classifier | Owns modifier-to-fragment widening; preserves temporal precedence over modifier escape widening; owns OOF-M1 detection. |
| TypeChecker | Propagates `modifier`; propagates OOF-M1 and blocks the contract. |
| SemanticIR | Emits `contract_ir.modifier` for accepted contracts; emits no contract IR for OOF-M1 blocked contracts. |
| Assembler | Has only descriptive `manifest_modifier_passthrough`; no `.igapp` format change in this slice. |

---

## Proof Checks

| Check | Meaning |
|---|---|
| `manifest.boundary_mode_descriptor_only` | The pack is manifest/descriptor-only and does not dispatch compiler passes. |
| `manifest.requires_kernel_services` | The pack declares dependency on `OOFRegistry` and `FragmentRegistry`. |
| `manifest.no_igapp_format_change` | The manifest explicitly refuses `.igapp` shape drift. |
| `manifest.oof_m1_owned_by_pack` | OOF-M1 descriptor owner is `ContractModifiersPack`. |
| `shadow_profile.compatible_pack_present` | Shadow profile already contains compatible `ContractModifiersPack` ownership. |
| `parser.modifiers_normalized` | Existing parsed goldens match modifier normalization rules. |
| `classifier.modifier_mapping` | Existing classified goldens match modifier fragment rules. |
| `typechecker.modifier_passthrough` | Typed outputs preserve modifier fields. |
| `semanticir.modifier_field_for_emitted_contracts` | SemanticIR emits the modifier field on accepted contracts. |
| `classifier.oof_m1_negative_case` | `pure` plus escape emits OOF-M1 and classifies as `oof`. |
| `typechecker.oof_m1_blocks` | OOF-M1 propagates to TypeChecker and blocks the contract. |
| `semanticir.oof_m1_no_ir` | Blocked OOF-M1 contract emits no SemanticIR. |
| `classifier.temporal_precedence_over_modifier` | `observed` plus temporal read remains `temporal`, not generic `escape`. |
| `proof.no_runtime_authorization` | The pack does not claim runtime execution authority. |
| `proof.no_manifest_changes` | The proof records no manifest changes. |

---

## Proof Result

Command:

```bash
ruby igniter-lang/experiments/contract_modifiers_pack_native_boundary/contract_modifiers_pack_native_boundary.rb
```

Result:

```text
PASS contract_modifiers_pack_native_boundary
manifest.kind: ok
manifest.boundary_mode_descriptor_only: ok
manifest.requires_kernel_services: ok
manifest.no_igapp_format_change: ok
manifest.oof_m1_owned_by_pack: ok
shadow_profile.compatible_pack_present: ok
parser.modifiers_normalized: ok
classifier.modifier_mapping: ok
typechecker.modifier_passthrough: ok
semanticir.modifier_field_for_emitted_contracts: ok
classifier.oof_m1_negative_case: ok
typechecker.oof_m1_blocks: ok
semanticir.oof_m1_no_ir: ok
classifier.temporal_precedence_over_modifier: ok
proof.no_runtime_authorization: ok
proof.no_manifest_changes: ok
manifest_id: compiler_pack_manifest/ContractModifiersPack/sha256:27a7d6a2a7a92369f10e4d70
summary: igniter-lang/experiments/contract_modifiers_pack_native_boundary/out/contract_modifiers_pack_native_boundary_summary.json
```

Compatibility guard:

```bash
ruby igniter-lang/experiments/contract_modifiers_proof/contract_modifiers_proof.rb --check-golden
```

Result: `PASS contract_modifiers_proof_golden_check`.

---

## Decisions

[D] `ContractModifiersPack` is the first pack-shaped boundary proven against
existing compiler goldens.

[D] This is still descriptor-only. The current compiler classes remain the
execution path.

[D] OOF-M1 is pack-owned by `ContractModifiersPack`, detected by Classifier, and
propagated by TypeChecker.

[D] Temporal precedence over modifier escape widening is part of the pack
contract: `observed` plus temporal read remains `fragment_class: "temporal"`.

[D] `.igapp` profile/manifest integration remains deferred.

---

## Risks

[R] This proof validates descriptor ownership, not dynamic registry dispatch.
The next kernel slice must still prove duplicate-key handling, frozen registry
state, and install order.

[R] The pack depends on `FragmentRegistry` semantics that are still candidate
status. Native dispatch should wait for fragment precedence ratification.

[R] OOF descriptors need a broader schema before they become production registry
data: stable message, aliases, deprecation, stage owner, severity, and doc refs.

---

## Next Recommended Slice

```text
Track: compiler-kernel-pack-registry-spike-v0
Goal:
- Build proof-local CompilerKernel registry mechanics without routing the real compiler.
Scope:
- Install the descriptor-only ContractModifiersPack manifest.
- Prove duplicate pack names are rejected.
- Prove missing dependencies are rejected.
- Prove registries freeze after finalize.
- Prove profile fingerprint changes when implementation_id changes.
- No compiler pass dispatch.
- No .igapp changes.
Acceptance:
- contract_modifiers_pack_native_boundary PASS
- compiler_pack_shadow_profile_proof PASS
```

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: contract-modifiers-pack-native-boundary-v0
Status: done

[D] Decisions:
- ContractModifiersPack has a proof-local native-style manifest boundary.
- OOF-M1 ownership is assigned to ContractModifiersPack.
- Existing parser/classifier/typechecker/SemanticIR modifier behavior satisfies the boundary.
- No CompilerKernel dispatch or .igapp integration is authorized.

[S] Signals:
- The manifest can be checked against existing modifier goldens.
- Shadow profile and native-style pack descriptor agree on pack identity and OOF-M1 ownership.
- Temporal precedence over modifier widening is explicitly guarded.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/contract_modifiers_pack_native_boundary/contract_modifiers_pack_native_boundary.rb -> PASS
- ruby igniter-lang/experiments/contract_modifiers_proof/contract_modifiers_proof.rb --check-golden -> PASS

[R] Risks:
- FragmentRegistry precedence remains candidate-only.
- OOF descriptor schema is still too thin for production registry use.
- Native registry installation mechanics are not implemented yet.

[Next]
- Route compiler-kernel-pack-registry-spike-v0 as a proof-local kernel mechanics slice.
```
