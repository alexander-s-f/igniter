# Track: Compiler Kernel Pack Registry Spike v0

Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `compiler-kernel-pack-registry-spike-v0`
Status: done
Date: 2026-05-10

---

## Goal

Prove proof-local `CompilerKernel` registry mechanics for the future
profile-assembled `igniter-lang` compiler without routing real compiler passes
through packs.

This slice does not edit `Parser`, `Classifier`, `TypeChecker`,
`SemanticIREmitter`, `Assembler`, or `CompilerOrchestrator`. It does not change
`.igapp` format and does not authorize native migration.

---

## Implemented Proof Boundary

Added:

```text
igniter-lang/experiments/compiler_kernel_pack_registry_spike/compiler_kernel_pack_registry_spike.rb
igniter-lang/experiments/compiler_kernel_pack_registry_spike/out/compiler_kernel_pack_registry_spike_summary.json
```

The proof-local spike models:

- `CompilerKernel`
- pack manifest installation
- named registries for parser/classifier/typechecker/SemanticIR/assembler hooks
- OOF descriptor registry
- fragment class registry
- dependency checks
- duplicate pack checks
- duplicate registry-key checks
- registry freezing on finalize
- profile snapshot and fingerprint generation

---

## Installed Positive Profile

The positive path installs descriptor manifests in this order:

```text
CoreLanguagePack
OOFRegistry
FragmentRegistry
EscapeBoundaryPack
ContractModifiersPack
```

`ContractModifiersPack` is loaded from the prior boundary summary:

```text
igniter-lang/experiments/contract_modifiers_pack_native_boundary/out/contract_modifiers_pack_native_boundary_summary.json
```

The resulting profile is registry-only:

```text
dispatch_mode: registry_only_no_compiler_dispatch
igapp_manifest_changes: []
```

---

## Kernel Mechanics Proven

| Check | Meaning |
|---|---|
| `positive.profile_kind` | Finalize produces a `compiler_kernel_profile_spike`. |
| `positive.dispatch_registry_only` | The profile does not dispatch compiler passes. |
| `positive.pack_order` | The expected dependency order installs successfully. |
| `positive.contract_modifier_rules_registered` | Modifier parser keywords register into the parser-rule registry. |
| `positive.oof_m1_registered` | OOF-M1 registers in OOF, Classifier, and TypeChecker registries. |
| `positive.fragment_classes_registered` | Required fragment classes are present. |
| `positive.no_igapp_manifest_changes` | The profile records no `.igapp` manifest changes. |
| `fingerprint.implementation_id_changes_profile` | Changing `ContractModifiersPack.implementation_id` changes the profile fingerprint. |
| `negative.duplicate_pack_rejected` | Installing the same pack twice raises `DuplicatePackError`. |
| `negative.missing_dependency_rejected` | Installing a pack before required dependencies raises `MissingDependencyError`. |
| `negative.duplicate_registry_key_rejected` | Competing packs registering the same hook key raise `DuplicateRegistryKeyError`. |
| `negative.frozen_kernel_rejects_install` | Installing after finalize raises `FrozenKernelError`. |

---

## Proof Result

Command:

```bash
ruby igniter-lang/experiments/compiler_kernel_pack_registry_spike/compiler_kernel_pack_registry_spike.rb
```

Result:

```text
PASS compiler_kernel_pack_registry_spike
positive.profile_kind: ok
positive.dispatch_registry_only: ok
positive.pack_order: ok
positive.contract_modifier_rules_registered: ok
positive.oof_m1_registered: ok
positive.fragment_classes_registered: ok
positive.no_igapp_manifest_changes: ok
fingerprint.implementation_id_changes_profile: ok
negative.duplicate_pack_rejected: ok
negative.missing_dependency_rejected: ok
negative.duplicate_registry_key_rejected: ok
negative.frozen_kernel_rejects_install: ok
profile_id: compiler_kernel_profile_spike/sha256:1378398e4c6ab9769cc34f28
summary: igniter-lang/experiments/compiler_kernel_pack_registry_spike/out/compiler_kernel_pack_registry_spike_summary.json
```

---

## Decisions

[D] A compiler pack kernel can reuse the proven `igniter-contracts` assembly
shape: install manifests, validate dependencies, populate registries, finalize
to a frozen profile.

[D] Pack implementation identity must participate in the profile fingerprint.
The spike proves a changed `implementation_id` changes `profile_id`.

[D] Duplicate registry-key rejection should happen at install time for compiler
hook registries. This avoids ambiguous parser/classifier/typechecker ownership.

[D] `ContractModifiersPack` remains descriptor-only here. The spike validates
registry mechanics around it, not live compiler dispatch.

---

## Risks

[R] The spike stores registry values as booleans. A production-grade registry
needs hook descriptors with callable implementation references, pass ordering,
stage ownership, diagnostics metadata, and doc refs.

[R] The current duplicate-key policy is strict. Some future registries may need
ordered multi-contributor behavior instead of one-owner uniqueness. Parser and
OOF ownership should remain strict; diagnostics contributors may not.

[R] The kernel does not yet model `before` / `after` ordering. It only models
hard dependencies. Classifier and TypeChecker rules will need deterministic
precedence before dispatch migration.

[R] No `.igapp` profile integration is included. `compiler_profile_id` still
requires a separate manifest/profile PROP.

---

## Next Recommended Slice

```text
Track: compiler-kernel-ordered-rule-precedence-v0
Goal:
- Decide and prove ordered rule registry semantics before any compiler dispatch migration.
Scope:
- Model strict single-owner registries for OOF/fragment ownership.
- Model ordered multi-contributor registries for parser/classifier/typechecker rules.
- Prove before/after constraints are deterministic.
- Prove cycles are rejected.
- Keep current compiler execution path untouched.
- No .igapp changes.
Acceptance:
- compiler_kernel_pack_registry_spike PASS
- contract_modifiers_pack_native_boundary PASS
```

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: compiler-kernel-pack-registry-spike-v0
Status: done

[D] Decisions:
- Proof-local CompilerKernel mechanics are viable for pack manifest installation.
- Dependency, duplicate pack, duplicate registry key, and frozen-finalize guards are proven.
- Profile fingerprint changes when implementation_id changes.
- No compiler dispatch or .igapp integration is introduced.

[S] Signals:
- ContractModifiersPack descriptor can install through a kernel-shaped registry.
- OOF-M1 ownership is strict and unambiguous.
- Fragment classes can be registered before dispatch migration.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/compiler_kernel_pack_registry_spike/compiler_kernel_pack_registry_spike.rb -> PASS

[R] Risks:
- Ordered rule precedence remains unresolved.
- Registry values are descriptors/stubs, not callable compiler pass handlers.
- Multi-contributor registries need a separate policy.

[Next]
- Route compiler-kernel-ordered-rule-precedence-v0.
```
