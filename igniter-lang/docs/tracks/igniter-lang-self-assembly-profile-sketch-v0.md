# Track: Igniter-Lang Self-Assembly Profile Sketch v0

Card: background-foundation
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `igniter-lang-self-assembly-profile-sketch-v0`
Status: done
Date: 2026-05-10

---

## Goal

Sketch how the future Igniter-Lang compiler could describe itself as a
profile-assembled compiler made from capability-owned packs.

This is hypothetical and proof-local. It does not implement a self-hosted
compiler, profile syntax, production `CompilerKernel`, `.igapp` changes, or
runtime authority.

---

## Added Proof

Added:

```text
igniter-lang/experiments/igniter_lang_self_assembly_profile_sketch/igniter_lang_self_assembly_profile_sketch.rb
igniter-lang/experiments/igniter_lang_self_assembly_profile_sketch/out/igniter_lang_self_assembly_profile_model.json
igniter-lang/experiments/igniter_lang_self_assembly_profile_sketch/out/igniter_lang_self_assembly_profile_sketch_summary.json
```

Command:

```bash
ruby igniter-lang/experiments/igniter_lang_self_assembly_profile_sketch/igniter_lang_self_assembly_profile_sketch.rb
```

Result:

```text
PASS igniter_lang_self_assembly_profile_sketch
```

The runner refreshes:

```text
compiler_profile_preflight_chain_index
compilation_receipt_authority_and_storage
```

then emits a proof-local model for a self-describing language profile.

---

## Core Idea

[D] Igniter-Lang self-assembly should mean:

```text
the language can describe the compiler profile that understands the language
```

It should not initially mean:

```text
the current compiler implementation is self-hosted
```

The proof uses an explicit bootstrap trust boundary:

```text
BootstrapDescriptorKernel
  -> load profile source descriptors
  -> validate required slots
  -> validate pack dependency graph
  -> validate ordered registries
  -> freeze profile
  -> compute deterministic profile id
  -> emit proof-local receipt
```

The bootstrap kernel is a trusted seed. It is not erased by the model.

---

## Hypothetical Profile Source

The sketch models a future profile source like:

```text
profile IgniterLang.Stage3SelfAssemblyProfile {
  slot core: CoreLanguagePack
  slot oof_registry: OOFRegistry
  slot fragment_registry: FragmentRegistry
  slot escape_boundary: EscapeBoundaryPack
  slot contract_modifiers: ContractModifiersPack
  slot temporal: TemporalPack implementation temporal.metadata_only.self_assembly.v0
  slot stream: StreamPack
  slot olap: OLAPPack
  slot invariant: InvariantPack
  slot assumptions: AssumptionsPack
  slot evidence_observation: EvidenceObservationPack
  slot compiler_accountability: CompilationReceiptPack
}
```

Parser status:

```text
not_implemented_descriptor_only
```

This avoids claiming syntax authority before a Compiler/Grammar track exists.

---

## Candidate Packs

| Slot | Pack | Capability |
|---|---|---|
| `core` | `CoreLanguagePack` | core contracts, inputs, outputs, compute |
| `oof_registry` | `OOFRegistry` | parser/classifier/typechecker/assembler/runtime OOF descriptors |
| `fragment_registry` | `FragmentRegistry` | core, escape, temporal, stream, oof, epistemic |
| `escape_boundary` | `EscapeBoundaryPack` | escape boundary detection and requirements |
| `contract_modifiers` | `ContractModifiersPack` | observe/assume/modifier metadata |
| `temporal` | `TemporalPack` | History/BiHistory metadata and temporal access nodes |
| `stream` | `StreamPack` | stream input and stream metadata |
| `olap` | `OLAPPack` | OLAPPoint and dims metadata |
| `invariant` | `InvariantPack` | invariant metadata and observations |
| `assumptions` | `AssumptionsPack` | assumption metadata |
| `evidence_observation` | `EvidenceObservationPack` | evidence and observation nodes |
| `compiler_accountability` | `CompilationReceiptPack` | receipt emission, redaction, report linkage |

New signal:

```text
CompilationReceiptPack is a compiler-accountability capability.
```

That means auditable build behavior can be owned by a pack without pretending it
is user-language syntax.

---

## Assembly Pipeline

```text
seed_bootstrap_kernel
  -> load_profile_source
  -> install_packs
  -> validate_slots_and_ordering
  -> emit_compilation_receipt_policy
```

This gives the future compiler two useful identities:

```text
assembled_profile.profile_id
self_assembly_profile_id
```

The first identifies the hypothetical assembled compiler profile. The second
identifies the whole self-assembly model, including bootstrap and authority
claims.

---

## Proof Checks

| Check | Meaning |
|---|---|
| `input.preflight_passed` | Existing profile/pack preflight chain still passes. |
| `input.receipt_storage_passed` | Receipt authority/storage proof still passes. |
| `bootstrap.seed_is_explicit` | The model does not hide the trusted seed. |
| `profile.required_slots_present` | Required slots are present. |
| `profile.all_packs_are_capability_owners` | No helper-only pack sneaks in. |
| `profile.includes_compiler_accountability_pack` | Receipt behavior has a capability owner. |
| `profile.temporal_variant_changes_profile_id` | Alternate Temporal implementation changes identity. |
| `pipeline.bootstrap_before_profile_before_receipt` | Assembly order is explicit. |
| `authority.not_claiming_self_hosted_implementation` | The proof avoids self-hosting overclaim. |
| `authority.no_runtime_execution_authority` | The profile grants no runtime execution authority. |

---

## Migration Path

[R] Keep current Ruby compiler as proof compiler.

[R] Define profile source descriptors as data first, not syntax.

[R] Make `BootstrapDescriptorKernel` validate descriptors without owning full
language semantics.

[R] Compile a profile descriptor into a frozen `CompilerProfile` manifest.

[R] Use `CompilationReceiptPack` to explain the build.

[R] Only after POC closure, replace monolithic dispatch one pack at a time.

---

## Open Questions

[Q] Should profile source become Igniter-Lang syntax, a `.igprofile.json`
descriptor, or both?

[Q] Is `CompilationReceiptPack` part of `CompilerProfile`, or a separate
`BuildAccountabilityProfile` layered over compiler profiles?

[Q] Which layer owns validation that pack rule ids map to slots:
`BootstrapDescriptorKernel`, `CompilerProfileSpec`, or `CompilerKernel`?

[Q] Should `.ilk` index self-assembly profile ids separately from compiled
artifact profile ids?

---

## Handoff

```text
Card: background-foundation
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang-self-assembly-profile-sketch-v0
Status: done

[D] Decisions:
- Self-assembly means self-describing compiler profile first, not self-hosted
  compiler implementation.
- BootstrapDescriptorKernel remains an explicit trusted seed.
- CompilationReceiptPack is a compiler-accountability capability owner.
- The model grants no runtime execution authority.

[S] Signals:
- Igniter-Lang can plausibly describe its future compiler as capability-owned
  pack descriptors plus profile slots and ordered registries.
- Swapping Temporal implementation changes the self-assembly profile id.
- Receipt/storage proofs fit naturally as the accountability layer of assembly.

[T] Tests:
- ruby igniter-lang/experiments/igniter_lang_self_assembly_profile_sketch/igniter_lang_self_assembly_profile_sketch.rb -> PASS

[R] Risks:
- Profile syntax is not authorized.
- Self-hosting implementation is not authorized.
- Bootstrap trust boundary needs formal treatment before any production claim.

[Next]
- Draft `bootstrap-descriptor-kernel-v0`: minimal descriptor language, trusted
  seed responsibilities, validation rules, and what must stay outside the seed.
```
