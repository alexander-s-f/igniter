# Track: Compiler Profile Slots Model v0

Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `compiler-profile-slots-model-v0`
Status: done
Date: 2026-05-10

---

## Goal

Extend the profile-assembled compiler foundation with a proof-local
`CompilerProfileSpec`: a profile-of-profile model with named slots,
cardinality, allowed capabilities, slot dependencies, canonical slot order, and
implementation-variant identity.

This slice does not edit compiler implementation, dispatch compiler passes,
change `.igapp`, or authorize native migration.

---

## Why This Layer Exists

`CompilerPack` and `CompilerKernel` answer:

```text
Can these packs be installed?
```

`CompilerProfileSpec` answers the stricter question:

```text
Is this a valid kind of compiler profile?
```

That distinction matters because profile assembly should not become generic
plugin loading. It should be a signed declaration of what this compiler is
allowed to understand.

---

## Implemented Proof Boundary

Added:

```text
igniter-lang/experiments/compiler_profile_slots_model/compiler_profile_slots_model.rb
igniter-lang/experiments/compiler_profile_slots_model/out/compiler_profile_slots_model_summary.json
```

The proof reads the existing shadow profile:

```text
igniter-lang/experiments/compiler_pack_shadow_profile_proof/out/compiler_pack_shadow_profile_proof_summary.json
```

and validates it against a proof-local profile spec.

---

## Profile Spec Slots

| Slot | Cardinality | Accepted pack / capability | Notes |
|---|---|---|---|
| `core` | exactly one | `CoreLanguagePack` / `core_language` | Required baseline. |
| `oof_registry` | exactly one | `OOFRegistry` / `oof_registry` | Required ownership registry. |
| `fragment_registry` | exactly one | `FragmentRegistry` / `fragment_registry` | Required fragment vocabulary registry. |
| `escape_boundary` | exactly one | `EscapeBoundaryPack` / `escape_boundary` | Required external boundary support. |
| `contract_modifiers` | zero or one | `ContractModifiersPack` / `contract_modifiers` | Optional language capability. |
| `temporal` | zero or one | `TemporalPack`, `TemporalPackLedgerBacked` / `temporal` | Allows competing implementations, exactly one at a time. |
| `stream` | zero or one | `StreamPack` / `stream` | Optional language capability. |
| `olap` | zero or one | `OLAPPack` / `olap_point` | Optional language capability. |
| `invariant` | zero or one | `InvariantPack` / `invariant` | Optional language capability. |
| `assumptions` | zero or one | `AssumptionsPack` / `assumptions` | Requires `contract_modifiers`. |
| `evidence_observation` | zero or one | `EvidenceObservationPack` / `evidence_observation` | Optional support surface. |
| `pipeline` | zero or one | `PipelinePack` / `pipeline_surface` | Optional current parser surface. |

Canonical slot order:

```text
core
oof_registry
fragment_registry
escape_boundary
contract_modifiers
temporal
stream
olap
invariant
assumptions
evidence_observation
pipeline
```

---

## Proof Checks

| Check | Meaning |
|---|---|
| `positive.required_slots_present` | Required slots are filled. |
| `positive.optional_slots_present` | Current shadow profile fills expected optional slots. |
| `positive.dispatch_slot_validation_only` | The model does not dispatch compiler passes. |
| `positive.no_igapp_manifest_changes` | The model records no `.igapp` changes. |
| `determinism.input_order_independent_assignments` | Reversed pack input produces same slot assignments. |
| `determinism.input_order_independent_profile_id` | Reversed pack input produces same profile id. |
| `variants.temporal_variant_changes_profile_id` | Replacing temporal implementation changes profile id. |
| `variants.temporal_slot_accepts_alternate_implementation` | `TemporalPackLedgerBacked` can fill the temporal slot. |
| `negative.missing_required_core_rejected` | Missing required baseline slot is rejected. |
| `negative.duplicate_temporal_variants_rejected` | Two temporal implementations at once are rejected. |
| `negative.helper_pack_rejected` | A helper-only pack with no semantic slot is rejected. |
| `negative.assumptions_without_modifiers_rejected` | Assumptions slot requires contract modifiers slot. |

---

## Proof Result

Command:

```bash
ruby igniter-lang/experiments/compiler_profile_slots_model/compiler_profile_slots_model.rb
```

Result:

```text
PASS compiler_profile_slots_model
positive.profile_kind: ok
positive.required_slots_present: ok
positive.optional_slots_present: ok
positive.dispatch_slot_validation_only: ok
positive.no_igapp_manifest_changes: ok
determinism.input_order_independent_assignments: ok
determinism.input_order_independent_profile_id: ok
variants.temporal_variant_changes_profile_id: ok
variants.temporal_slot_accepts_alternate_implementation: ok
negative.missing_required_core_rejected: ok
negative.duplicate_temporal_variants_rejected: ok
negative.helper_pack_rejected: ok
negative.assumptions_without_modifiers_rejected: ok
profile_id: compiler_profile_slots/sha256:f8ba55dd264db5f1268ba99f
summary: igniter-lang/experiments/compiler_profile_slots_model/out/compiler_profile_slots_model_summary.json
```

---

## Decisions

[D] Add `CompilerProfileSpec` to the target architecture vocabulary. It is the
profile-of-profile layer that defines valid compiler assembly shapes.

[D] Slots should be semantic capability slots, not file/helper slots.
`ParserHelpersPack` is rejected in the proof because it has no semantic slot.

[D] Competing implementations should fill the same slot by capability. A
Ledger-backed temporal implementation can replace metadata-only temporal, but two
temporal implementations cannot be installed together in the same profile.

[D] Slot dependencies should be explicit. `AssumptionsPack` requires the
`contract_modifiers` slot.

[D] Profile IDs should be computed from canonical slot assignments, not input
pack order.

---

## Risks

[R] The proof models slots only; it does not yet merge slots with ordered rule
registries into one final profile fingerprint.

[R] Slot cardinality is simple: `exactly_one` and `zero_or_one`. Future profiles
may need `one_or_more` for diagnostics contributors or backend adapters.

[R] Slot dependencies are pack-level/profile-level only. They do not replace
rule-level `before` / `after` constraints.

[R] The exact production profile families are still unnamed. This proof uses
`Stage3ProofCompilerProfileSpec` as a candidate shape.

---

## Next Recommended Slice

```text
Track: compiler-profile-spec-and-rule-profile-unification-v0
Goal:
- Combine CompilerProfileSpec slot validation with ordered rule registry output.
Scope:
- Validate slots first.
- Build ordered registries second.
- Compute one unified profile fingerprint from slot assignments + ordered rules.
- Keep dispatch disabled.
- No .igapp changes.
Acceptance:
- compiler_profile_slots_model PASS
- compiler_kernel_ordered_rule_precedence PASS
- unified profile id changes when either slot implementation or ordered rule graph changes
```

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: compiler-profile-slots-model-v0
Status: done

[D] Decisions:
- Introduce CompilerProfileSpec as profile-of-profile target layer.
- Slots prevent over-splitting by accepting semantic capability packs only.
- Competing implementations are modeled as variants filling the same slot.
- Slot dependencies are explicit and checked before profile finalization.

[S] Signals:
- Current shadow profile fits the Stage3ProofCompilerProfileSpec.
- Reversed pack input produces the same profile id.
- Temporal implementation variant changes profile id.
- Helper-only pack is rejected.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/compiler_profile_slots_model/compiler_profile_slots_model.rb -> PASS

[R] Risks:
- Slot model and ordered rule model are still separate proof artifacts.
- Production profile families need explicit names and governance.

[Next]
- Route compiler-profile-spec-and-rule-profile-unification-v0.
```
